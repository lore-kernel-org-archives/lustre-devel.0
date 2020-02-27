From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:59 -0500
Subject: [lustre-devel] [PATCH 071/622] lustre: mdt: read on open for DoM
 files
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-72-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhail Pershin <mpershin@whamcloud.com>

Read file data upon open and return it in reply. That works
only for file with Data-on-MDT layout and no OST components
initialized. There are three possible cases may occur:
1) file data fits in already allocated reply buffer (~9K)
   and is returned in that buffer in OPEN reply.
2) File fits in the maximum reply buffer (128K) and reply is
   returned with larger size to the client causing resend
   with re-allocated buffer.
3) File doesn't fit in reply buffer but its tail fills page
   partially then that tail is returned. This can be useful
   for an append case

WC-bug-id: https://jira.whamcloud.com/browse/LU-10181
Lustre-commit: 13372d6c243c ("LU-10181 mdt: read on open for DoM files")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/23011
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_req_layout.h |   1 +
 fs/lustre/include/obd.h               |  11 +++
 fs/lustre/llite/file.c                | 131 +++++++++++++++++++++++++++++++++-
 fs/lustre/llite/llite_internal.h      |   3 +
 fs/lustre/llite/namei.c               |   3 +
 fs/lustre/mdc/lproc_mdc.c             |  32 +++++++++
 fs/lustre/mdc/mdc_internal.h          |   4 ++
 fs/lustre/mdc/mdc_locks.c             |  28 +++++++-
 fs/lustre/mdc/mdc_request.c           |   2 +
 fs/lustre/ptlrpc/layout.c             |  11 ++-
 fs/lustre/ptlrpc/niobuf.c             |   5 ++
 11 files changed, 227 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/include/lustre_req_layout.h b/fs/lustre/include/lustre_req_layout.h
index 2737240..807d080 100644
--- a/fs/lustre/include/lustre_req_layout.h
+++ b/fs/lustre/include/lustre_req_layout.h
@@ -291,6 +291,7 @@ void req_capsule_shrink(struct req_capsule *pill,
 extern struct req_msg_field RMF_OBD_ID;
 extern struct req_msg_field RMF_FID;
 extern struct req_msg_field RMF_NIOBUF_REMOTE;
+extern struct req_msg_field RMF_NIOBUF_INLINE;
 extern struct req_msg_field RMF_RCS;
 extern struct req_msg_field RMF_FIEMAP_KEY;
 extern struct req_msg_field RMF_FIEMAP_VAL;
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index c712979..de9642f 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -184,6 +184,17 @@ struct client_obd {
 	 */
 	u32			 cl_max_mds_easize;
 
+	/* Data-on-MDT specific value to set larger reply buffer for possible
+	 * data read along with open/stat requests. By default it tries to use
+	 * unused space in reply buffer.
+	 * This value is used to ensure that reply buffer has at least as
+	 * much free space as value indicates. That free space is gained from
+	 * LOV EA buffer which is small for DoM files and on big systems can
+	 * provide up to 32KB of extra space in reply buffer.
+	 * Default value is 8K now.
+	 */
+	u32			 cl_dom_min_inline_repsize;
+
 	enum lustre_sec_part     cl_sp_me;
 	enum lustre_sec_part     cl_sp_to;
 	struct sptlrpc_flavor    cl_flvr_mgc;   /* fixed flavor of mgc->mgs */
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 837add1..7657c79 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -393,6 +393,132 @@ int ll_file_release(struct inode *inode, struct file *file)
 	return rc;
 }
 
+static inline int ll_dom_readpage(void *data, struct page *page)
+{
+	struct niobuf_local *lnb = data;
+	void *kaddr;
+
+	kaddr = kmap_atomic(page);
+	memcpy(kaddr, lnb->lnb_data, lnb->lnb_len);
+	if (lnb->lnb_len < PAGE_SIZE)
+		memset(kaddr + lnb->lnb_len, 0,
+		       PAGE_SIZE - lnb->lnb_len);
+	flush_dcache_page(page);
+	SetPageUptodate(page);
+	kunmap_atomic(kaddr);
+	unlock_page(page);
+
+	return 0;
+}
+
+void ll_dom_finish_open(struct inode *inode, struct ptlrpc_request *req,
+			struct lookup_intent *it)
+{
+	struct ll_inode_info *lli = ll_i2info(inode);
+	struct cl_object *obj = lli->lli_clob;
+	struct address_space *mapping = inode->i_mapping;
+	struct page *vmpage;
+	struct niobuf_remote *rnb;
+	char *data;
+	struct lu_env *env;
+	struct cl_io *io;
+	u16 refcheck;
+	struct lustre_handle lockh;
+	struct ldlm_lock *lock;
+	unsigned long index, start;
+	struct niobuf_local lnb;
+	int rc;
+	bool dom_lock = false;
+
+	if (!obj)
+		return;
+
+	if (it->it_lock_mode != 0) {
+		lockh.cookie = it->it_lock_handle;
+		lock = ldlm_handle2lock(&lockh);
+		if (lock)
+			dom_lock = ldlm_has_dom(lock);
+		LDLM_LOCK_PUT(lock);
+	}
+
+	if (!dom_lock)
+		return;
+
+	env = cl_env_get(&refcheck);
+	if (IS_ERR(env))
+		return;
+
+	if (!req_capsule_has_field(&req->rq_pill, &RMF_NIOBUF_INLINE,
+				   RCL_SERVER)) {
+		rc = -ENODATA;
+		goto out_env;
+	}
+
+	rnb = req_capsule_server_get(&req->rq_pill, &RMF_NIOBUF_INLINE);
+	data = (char *)rnb + sizeof(*rnb);
+
+	if (!rnb || rnb->rnb_len == 0) {
+		rc = 0;
+		goto out_env;
+	}
+
+	CDEBUG(D_INFO, "Get data buffer along with open, len %i, i_size %llu\n",
+	       rnb->rnb_len, i_size_read(inode));
+
+	io = vvp_env_thread_io(env);
+	io->ci_obj = obj;
+	io->ci_ignore_layout = 1;
+	rc = cl_io_init(env, io, CIT_MISC, obj);
+	if (rc)
+		goto out_io;
+
+	lnb.lnb_file_offset = rnb->rnb_offset;
+	start = lnb.lnb_file_offset / PAGE_SIZE;
+	index = 0;
+	LASSERT(lnb.lnb_file_offset % PAGE_SIZE == 0);
+	lnb.lnb_page_offset = 0;
+	do {
+		struct cl_page *clp;
+
+		lnb.lnb_data = data + (index << PAGE_SHIFT);
+		lnb.lnb_len = rnb->rnb_len - (index << PAGE_SHIFT);
+		if (lnb.lnb_len > PAGE_SIZE)
+			lnb.lnb_len = PAGE_SIZE;
+
+		vmpage = read_cache_page(mapping, index + start,
+					 ll_dom_readpage, &lnb);
+		if (IS_ERR(vmpage)) {
+			CWARN("%s: cannot fill page %lu for "DFID
+			      " with data: rc = %li\n",
+			      ll_get_fsname(inode->i_sb, NULL, 0),
+			      index + start, PFID(lu_object_fid(&obj->co_lu)),
+			      PTR_ERR(vmpage));
+			break;
+		}
+		lock_page(vmpage);
+		clp = cl_page_find(env, obj, vmpage->index, vmpage,
+				   CPT_CACHEABLE);
+		if (IS_ERR(clp)) {
+			unlock_page(vmpage);
+			put_page(vmpage);
+			rc = PTR_ERR(clp);
+			goto out_io;
+		}
+
+		/* export page */
+		cl_page_export(env, clp, 1);
+		cl_page_put(env, clp);
+		unlock_page(vmpage);
+		put_page(vmpage);
+		index++;
+	} while (rnb->rnb_len > (index << PAGE_SHIFT));
+	rc = 0;
+out_io:
+	cl_io_fini(env, io);
+out_env:
+	cl_env_put(env, &refcheck);
+}
+
 static int ll_intent_file_open(struct dentry *de, void *lmm, int lmmsize,
 			       struct lookup_intent *itp)
 {
@@ -450,8 +576,11 @@ static int ll_intent_file_open(struct dentry *de, void *lmm, int lmmsize,
 	}
 
 	rc = ll_prep_inode(&inode, req, NULL, itp);
-	if (!rc && itp->it_lock_mode)
+
+	if (!rc && itp->it_lock_mode) {
+		ll_dom_finish_open(d_inode(de), req, itp);
 		ll_set_lock_data(sbi->ll_md_exp, inode, itp, NULL);
+	}
 
 out:
 	ptlrpc_req_finished(req);
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 6bdbf28..7491397 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -916,6 +916,9 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 ssize_t ll_copy_user_md(const struct lov_user_md __user *md,
 			struct lov_user_md **kbuf);
 
+void ll_dom_finish_open(struct inode *inode, struct ptlrpc_request *req,
+			struct lookup_intent *it);
+
 /* Compute expected user md size when passing in a md from user space */
 static inline ssize_t ll_lov_user_md_size(const struct lov_user_md *lum)
 {
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index f835abb..4ac62b2 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -600,6 +600,9 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 		if (rc)
 			return rc;
 
+		if (it->it_op & IT_OPEN)
+			ll_dom_finish_open(inode, request, it);
+
 		ll_set_lock_data(ll_i2sbi(parent)->ll_md_exp, inode, it, &bits);
 
 		/* We used to query real size from OSTs here, but actually
diff --git a/fs/lustre/mdc/lproc_mdc.c b/fs/lustre/mdc/lproc_mdc.c
index 6b87e76..0c52bcf 100644
--- a/fs/lustre/mdc/lproc_mdc.c
+++ b/fs/lustre/mdc/lproc_mdc.c
@@ -456,6 +456,36 @@ static ssize_t mdc_stats_seq_write(struct file *file,
 }
 LPROC_SEQ_FOPS(mdc_stats);
 
+static int mdc_dom_min_repsize_seq_show(struct seq_file *m, void *v)
+{
+	struct obd_device *dev = m->private;
+
+	seq_printf(m, "%u\n", dev->u.cli.cl_dom_min_inline_repsize);
+
+	return 0;
+}
+
+static ssize_t mdc_dom_min_repsize_seq_write(struct file *file,
+					     const char __user *buffer,
+					     size_t count, loff_t *off)
+{
+	struct obd_device *dev;
+	unsigned int val;
+	int rc;
+
+	dev =  ((struct seq_file *)file->private_data)->private;
+	rc = kstrtouint_from_user(buffer, count, 0, &val);
+	if (rc)
+		return rc;
+
+	if (val > MDC_DOM_MAX_INLINE_REPSIZE)
+		return -ERANGE;
+
+	dev->u.cli.cl_dom_min_inline_repsize = val;
+	return count;
+}
+LPROC_SEQ_FOPS(mdc_dom_min_repsize);
+
 LPROC_SEQ_FOPS_RO_TYPE(mdc, connect_flags);
 LPROC_SEQ_FOPS_RO_TYPE(mdc, server_uuid);
 LPROC_SEQ_FOPS_RO_TYPE(mdc, timeouts);
@@ -489,6 +519,8 @@ static ssize_t mdc_stats_seq_write(struct file *file,
 	  .fops	=	&mdc_unstable_stats_fops	},
 	{ .name	=	"mdc_stats",
 	  .fops	=	&mdc_stats_fops			},
+	{ .name	=	"mdc_dom_min_repsize",
+	  .fops	=	&mdc_dom_min_repsize_fops	},
 	{ NULL }
 };
 
diff --git a/fs/lustre/mdc/mdc_internal.h b/fs/lustre/mdc/mdc_internal.h
index 079539d..6cfa79c 100644
--- a/fs/lustre/mdc/mdc_internal.h
+++ b/fs/lustre/mdc/mdc_internal.h
@@ -159,4 +159,8 @@ int mdc_ldlm_blocking_ast(struct ldlm_lock *dlmlock,
 			  struct ldlm_lock_desc *new, void *data, int flag);
 int mdc_ldlm_glimpse_ast(struct ldlm_lock *dlmlock, void *data);
 int mdc_fill_lvb(struct ptlrpc_request *req, struct ost_lvb *lvb);
+
+#define MDC_DOM_DEF_INLINE_REPSIZE 8192
+#define MDC_DOM_MAX_INLINE_REPSIZE XATTR_SIZE_MAX
+
 #endif
diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index 2e4a5c6..abbc908 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -254,8 +254,9 @@ static int mdc_save_lovea(struct ptlrpc_request *req,
 	u32 lmmsize = op_data->op_data_size;
 	LIST_HEAD(cancels);
 	int count = 0;
-	int mode;
+	enum ldlm_mode mode;
 	int rc;
+	int repsize;
 
 	it->it_create_mode = (it->it_create_mode & ~S_IFMT) | S_IFREG;
 
@@ -336,7 +337,32 @@ static int mdc_save_lovea(struct ptlrpc_request *req,
 			     obddev->u.cli.cl_max_mds_easize);
 	req_capsule_set_size(&req->rq_pill, &RMF_ACL, RCL_SERVER, acl_bufsize);
 
+	/**
+	 * Inline buffer for possible data from Data-on-MDT files.
+	 */
+	req_capsule_set_size(&req->rq_pill, &RMF_NIOBUF_INLINE, RCL_SERVER,
+			     sizeof(struct niobuf_remote));
 	ptlrpc_request_set_replen(req);
+
+	/* Get real repbuf allocated size as rounded up power of 2 */
+	repsize = size_roundup_power2(req->rq_replen +
+				      lustre_msg_early_size());
+
+	/* Estimate free space for DoM files in repbuf */
+	repsize -= req->rq_replen - obddev->u.cli.cl_max_mds_easize +
+		   sizeof(struct lov_comp_md_v1) +
+		   sizeof(struct lov_comp_md_entry_v1) +
+		   lov_mds_md_size(0, LOV_MAGIC_V3);
+
+	if (repsize < obddev->u.cli.cl_dom_min_inline_repsize) {
+		repsize = obddev->u.cli.cl_dom_min_inline_repsize - repsize;
+		req_capsule_set_size(&req->rq_pill, &RMF_NIOBUF_INLINE,
+				     RCL_SERVER,
+				     sizeof(struct niobuf_remote) + repsize);
+		ptlrpc_request_set_replen(req);
+		CDEBUG(D_INFO, "Increase repbuf by %d bytes, total: %d\n",
+		       repsize, req->rq_replen);
+	}
 	return req;
 }
 
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index feac374..b173937 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -2551,6 +2551,8 @@ int mdc_setup(struct obd_device *obd, struct lustre_cfg *cfg)
 	if (rc)
 		goto err_osc_cleanup;
 
+	obd->u.cli.cl_dom_min_inline_repsize = MDC_DOM_DEF_INLINE_REPSIZE;
+
 	ns_register_cancel(obd->obd_namespace, mdc_cancel_weight);
 
 	obd->obd_namespace->ns_lvbo = &inode_lvbo;
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index 8fe661d..c11b1b0 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -414,7 +414,8 @@
 	&RMF_MDT_MD,
 	&RMF_ACL,
 	&RMF_CAPA1,
-	&RMF_CAPA2
+	&RMF_CAPA2,
+	&RMF_NIOBUF_INLINE,
 };
 
 static const struct req_msg_field *ldlm_intent_getattr_client[] = {
@@ -1065,8 +1066,14 @@ struct req_msg_field RMF_NIOBUF_REMOTE =
 		    dump_rniobuf);
 EXPORT_SYMBOL(RMF_NIOBUF_REMOTE);
 
+struct req_msg_field RMF_NIOBUF_INLINE =
+	DEFINE_MSGF("niobuf_inline", RMF_F_NO_SIZE_CHECK,
+		    sizeof(struct niobuf_remote), lustre_swab_niobuf_remote,
+		    dump_rniobuf);
+EXPORT_SYMBOL(RMF_NIOBUF_INLINE);
+
 struct req_msg_field RMF_RCS =
-	DEFINE_MSGF("niobuf_remote", RMF_F_STRUCT_ARRAY, sizeof(u32),
+	DEFINE_MSGF("niobuf_rcs", RMF_F_STRUCT_ARRAY, sizeof(u32),
 		    lustre_swab_generic_32s, dump_rcs);
 EXPORT_SYMBOL(RMF_RCS);
 
diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index 2e866fe..e8ba57b 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -617,6 +617,11 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 				request->rq_status = rc;
 				goto cleanup_bulk;
 			}
+			/* Use real allocated value in lm_repsize,
+			 * so the server may use whole reply buffer
+			 * without resends where it is needed.
+			 */
+			request->rq_reqmsg->lm_repsize = request->rq_repbuf_len;
 		} else {
 			request->rq_repdata = NULL;
 			request->rq_repmsg = NULL;
-- 
1.8.3.1
