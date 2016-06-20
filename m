From: Oleg Drokin <green@linuxhacker.ru>
Date: Mon, 20 Jun 2016 16:55:38 -0400
Subject: [lustre-devel] [PATCH v2 15/29] staging/lustre/llite: flatten
	struct lookup_intent
In-Reply-To: <1466456152-2199975-1-git-send-email-green@linuxhacker.ru>
References: <1466456152-2199975-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1466456152-2199975-16-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: "John L. Hammond" <john.hammond@intel.com>

Replace the union in struct lookup_intent with the members of struct
lustre_indent_data. Remove the then unused struct lustre_intent_data.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Reviewed-on: http://review.whamcloud.com/17069
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7403
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Frank Zago <fzago@cray.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../staging/lustre/lustre/include/lustre_intent.h  | 15 ++--
 drivers/staging/lustre/lustre/llite/dcache.c       | 26 +++----
 drivers/staging/lustre/lustre/llite/dir.c          |  4 +-
 drivers/staging/lustre/lustre/llite/file.c         | 44 ++++++------
 .../staging/lustre/lustre/llite/llite_internal.h   | 14 ++--
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  4 +-
 drivers/staging/lustre/lustre/llite/namei.c        |  8 +--
 drivers/staging/lustre/lustre/llite/statahead.c    | 10 +--
 drivers/staging/lustre/lustre/llite/xattr_cache.c  | 16 ++---
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     | 26 +++----
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |  8 +--
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      | 79 +++++++++++-----------
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |  2 +-
 13 files changed, 125 insertions(+), 131 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_intent.h b/drivers/staging/lustre/lustre/include/lustre_intent.h
index fdc6236..41c03d7 100644
--- a/drivers/staging/lustre/lustre/include/lustre_intent.h
+++ b/drivers/staging/lustre/lustre/include/lustre_intent.h
@@ -34,7 +34,11 @@
 #define LUSTRE_INTENT_H
 
 /* intent IT_XXX are defined in lustre/include/obd.h */
-struct lustre_intent_data {
+
+struct lookup_intent {
+	int		it_op;
+	int		it_create_mode;
+	__u64		it_flags;
 	int		it_disposition;
 	int		it_status;
 	__u64		it_lock_handle;
@@ -46,13 +50,4 @@ struct lustre_intent_data {
 	unsigned int    it_lock_set:1;
 };
 
-struct lookup_intent {
-	int     it_op;
-	int     it_create_mode;
-	__u64   it_flags;
-	union {
-		struct lustre_intent_data lustre;
-	} d;
-};
-
 #endif
diff --git a/drivers/staging/lustre/lustre/llite/dcache.c b/drivers/staging/lustre/lustre/llite/dcache.c
index f002b3a..c5789f7 100644
--- a/drivers/staging/lustre/lustre/llite/dcache.c
+++ b/drivers/staging/lustre/lustre/llite/dcache.c
@@ -202,27 +202,27 @@ int ll_d_init(struct dentry *de)
 
 void ll_intent_drop_lock(struct lookup_intent *it)
 {
-	if (it->it_op && it->d.lustre.it_lock_mode) {
+	if (it->it_op && it->it_lock_mode) {
 		struct lustre_handle handle;
 
-		handle.cookie = it->d.lustre.it_lock_handle;
+		handle.cookie = it->it_lock_handle;
 
 		CDEBUG(D_DLMTRACE, "releasing lock with cookie %#llx from it %p\n",
 		       handle.cookie, it);
-		ldlm_lock_decref(&handle, it->d.lustre.it_lock_mode);
+		ldlm_lock_decref(&handle, it->it_lock_mode);
 
 		/* bug 494: intent_release may be called multiple times, from
 		 * this thread and we don't want to double-decref this lock
 		 */
-		it->d.lustre.it_lock_mode = 0;
-		if (it->d.lustre.it_remote_lock_mode != 0) {
-			handle.cookie = it->d.lustre.it_remote_lock_handle;
+		it->it_lock_mode = 0;
+		if (it->it_remote_lock_mode != 0) {
+			handle.cookie = it->it_remote_lock_handle;
 
 			CDEBUG(D_DLMTRACE, "releasing remote lock with cookie%#llx from it %p\n",
 			       handle.cookie, it);
 			ldlm_lock_decref(&handle,
-					 it->d.lustre.it_remote_lock_mode);
-			it->d.lustre.it_remote_lock_mode = 0;
+					 it->it_remote_lock_mode);
+			it->it_remote_lock_mode = 0;
 		}
 	}
 }
@@ -233,13 +233,13 @@ void ll_intent_release(struct lookup_intent *it)
 	ll_intent_drop_lock(it);
 	/* We are still holding extra reference on a request, need to free it */
 	if (it_disposition(it, DISP_ENQ_OPEN_REF))
-		ptlrpc_req_finished(it->d.lustre.it_data); /* ll_file_open */
+		ptlrpc_req_finished(it->it_data); /* ll_file_open */
 
 	if (it_disposition(it, DISP_ENQ_CREATE_REF)) /* create rec */
-		ptlrpc_req_finished(it->d.lustre.it_data);
+		ptlrpc_req_finished(it->it_data);
 
-	it->d.lustre.it_disposition = 0;
-	it->d.lustre.it_data = NULL;
+	it->it_disposition = 0;
+	it->it_data = NULL;
 }
 
 void ll_invalidate_aliases(struct inode *inode)
@@ -279,7 +279,7 @@ int ll_revalidate_it_finish(struct ptlrpc_request *request,
 
 void ll_lookup_finish_locks(struct lookup_intent *it, struct inode *inode)
 {
-	if (it->d.lustre.it_lock_mode && inode) {
+	if (it->it_lock_mode && inode) {
 		struct ll_sb_info *sbi = ll_i2sbi(inode);
 
 		CDEBUG(D_DLMTRACE, "setting l_data to inode "DFID"(%p)\n",
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 99735f6..a62df87 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -362,7 +362,7 @@ struct page *ll_get_dir_page(struct inode *dir, __u64 hash,
 
 		ll_finish_md_op_data(op_data);
 
-		request = (struct ptlrpc_request *)it.d.lustre.it_data;
+		request = (struct ptlrpc_request *)it.it_data;
 		if (request)
 			ptlrpc_req_finished(request);
 		if (rc < 0) {
@@ -374,7 +374,7 @@ struct page *ll_get_dir_page(struct inode *dir, __u64 hash,
 		CDEBUG(D_INODE, "setting lr_lvb_inode to inode "DFID"(%p)\n",
 		       PFID(ll_inode2fid(dir)), dir);
 		md_set_lock_data(ll_i2sbi(dir)->ll_md_exp,
-				 &it.d.lustre.it_lock_handle, dir, NULL);
+				 &it.it_lock_handle, dir, NULL);
 	} else {
 		/* for cross-ref object, l_ast_data of the lock may not be set,
 		 * we reset it here
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 5436a54..92fab63 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -449,7 +449,7 @@ static int ll_intent_file_open(struct dentry *dentry, void *lmm,
 	}
 
 	rc = ll_prep_inode(&inode, req, NULL, itp);
-	if (!rc && itp->d.lustre.it_lock_mode)
+	if (!rc && itp->it_lock_mode)
 		ll_set_lock_data(sbi->ll_md_exp, inode, itp, NULL);
 
 out:
@@ -476,13 +476,13 @@ void ll_ioepoch_open(struct ll_inode_info *lli, __u64 ioepoch)
 static int ll_och_fill(struct obd_export *md_exp, struct lookup_intent *it,
 		       struct obd_client_handle *och)
 {
-	struct ptlrpc_request *req = it->d.lustre.it_data;
+	struct ptlrpc_request *req = it->it_data;
 	struct mdt_body *body;
 
 	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
 	och->och_fh = body->handle;
 	och->och_fid = body->fid1;
-	och->och_lease_handle.cookie = it->d.lustre.it_lock_handle;
+	och->och_lease_handle.cookie = it->it_lock_handle;
 	och->och_magic = OBD_CLIENT_HANDLE_MAGIC;
 	och->och_flags = it->it_flags;
 
@@ -500,7 +500,7 @@ static int ll_local_open(struct file *file, struct lookup_intent *it,
 	LASSERT(fd);
 
 	if (och) {
-		struct ptlrpc_request *req = it->d.lustre.it_data;
+		struct ptlrpc_request *req = it->it_data;
 		struct mdt_body *body;
 		int rc;
 
@@ -575,7 +575,7 @@ int ll_file_open(struct inode *inode, struct file *file)
 		return 0;
 	}
 
-	if (!it || !it->d.lustre.it_disposition) {
+	if (!it || !it->it_disposition) {
 		/* Convert f_flags into access mode. We cannot use file->f_mode,
 		 * because everything but O_ACCMODE mask was stripped from
 		 * there
@@ -645,7 +645,7 @@ restart:
 		}
 	} else {
 		LASSERT(*och_usecount == 0);
-		if (!it->d.lustre.it_disposition) {
+		if (!it->it_disposition) {
 			/* We cannot just request lock handle now, new ELC code
 			 * means that one of other OPEN locks for this file
 			 * could be cancelled, and since blocking ast handler
@@ -682,7 +682,7 @@ restart:
 
 		LASSERTF(it_disposition(it, DISP_ENQ_OPEN_REF),
 			 "inode %p: disposition %x, status %d\n", inode,
-			 it_disposition(it, ~0), it->d.lustre.it_status);
+			 it_disposition(it, ~0), it->it_status);
 
 		rc = ll_local_open(file, it, fd, *och_p);
 		if (rc)
@@ -725,7 +725,7 @@ out_openerr:
 	}
 
 	if (it && it_disposition(it, DISP_ENQ_OPEN_REF)) {
-		ptlrpc_req_finished(it->d.lustre.it_data);
+		ptlrpc_req_finished(it->it_data);
 		it_clear_disposition(it, DISP_ENQ_OPEN_REF);
 	}
 
@@ -866,12 +866,12 @@ ll_lease_open(struct inode *inode, struct file *file, fmode_t fmode,
 
 	/* already get lease, handle lease lock */
 	ll_set_lock_data(sbi->ll_md_exp, inode, &it, NULL);
-	if (it.d.lustre.it_lock_mode == 0 ||
-	    it.d.lustre.it_lock_bits != MDS_INODELOCK_OPEN) {
+	if (it.it_lock_mode == 0 ||
+	    it.it_lock_bits != MDS_INODELOCK_OPEN) {
 		/* open lock must return for lease */
 		CERROR(DFID "lease granted but no open lock, %d/%llu.\n",
-		       PFID(ll_inode2fid(inode)), it.d.lustre.it_lock_mode,
-		       it.d.lustre.it_lock_bits);
+		       PFID(ll_inode2fid(inode)), it.it_lock_mode,
+		       it.it_lock_bits);
 		rc = -EPROTO;
 		goto out_close;
 	}
@@ -881,10 +881,10 @@ ll_lease_open(struct inode *inode, struct file *file, fmode_t fmode,
 
 out_close:
 	/* Cancel open lock */
-	if (it.d.lustre.it_lock_mode != 0) {
+	if (it.it_lock_mode != 0) {
 		ldlm_lock_decref_and_cancel(&och->och_lease_handle,
-					    it.d.lustre.it_lock_mode);
-		it.d.lustre.it_lock_mode = 0;
+					    it.it_lock_mode);
+		it.it_lock_mode = 0;
 		och->och_lease_handle.cookie = 0ULL;
 	}
 	rc2 = ll_close_inode_openhandle(sbi->ll_md_exp, inode, och, NULL);
@@ -1400,7 +1400,7 @@ int ll_lov_setstripe_ea_info(struct inode *inode, struct dentry *dentry,
 	rc = ll_intent_file_open(dentry, lum, lum_size, &oit);
 	if (rc)
 		goto out_unlock;
-	rc = oit.d.lustre.it_status;
+	rc = oit.it_status;
 	if (rc < 0)
 		goto out_req_free;
 
@@ -1413,7 +1413,7 @@ out_unlock:
 out:
 	return rc;
 out_req_free:
-	ptlrpc_req_finished((struct ptlrpc_request *)oit.d.lustre.it_data);
+	ptlrpc_req_finished((struct ptlrpc_request *)oit.it_data);
 	goto out;
 }
 
@@ -1701,7 +1701,7 @@ int ll_release_openhandle(struct inode *inode, struct lookup_intent *it)
 out:
 	/* this one is in place of ll_file_open */
 	if (it_disposition(it, DISP_ENQ_OPEN_REF)) {
-		ptlrpc_req_finished(it->d.lustre.it_data);
+		ptlrpc_req_finished(it->it_data);
 		it_clear_disposition(it, DISP_ENQ_OPEN_REF);
 	}
 	return rc;
@@ -3610,13 +3610,13 @@ again:
 
 	rc = md_enqueue(sbi->ll_md_exp, &einfo, &it, op_data, &lockh,
 			NULL, 0, NULL, 0);
-	ptlrpc_req_finished(it.d.lustre.it_data);
-	it.d.lustre.it_data = NULL;
+	ptlrpc_req_finished(it.it_data);
+	it.it_data = NULL;
 
 	ll_finish_md_op_data(op_data);
 
-	mode = it.d.lustre.it_lock_mode;
-	it.d.lustre.it_lock_mode = 0;
+	mode = it.it_lock_mode;
+	it.it_lock_mode = 0;
 	ll_intent_drop_lock(&it);
 
 	if (rc == 0) {
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 098155f..3692102 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -1280,7 +1280,7 @@ static inline int ll_file_nolock(const struct file *file)
 static inline void ll_set_lock_data(struct obd_export *exp, struct inode *inode,
 				    struct lookup_intent *it, __u64 *bits)
 {
-	if (!it->d.lustre.it_lock_set) {
+	if (!it->it_lock_set) {
 		struct lustre_handle handle;
 
 		/* If this inode is a remote object, it will get two
@@ -1291,26 +1291,26 @@ static inline void ll_set_lock_data(struct obd_export *exp, struct inode *inode,
 		 * LOOKUP and PERM locks, so revoking either locks will
 		 * case the dcache being cleared
 		 */
-		if (it->d.lustre.it_remote_lock_mode) {
-			handle.cookie = it->d.lustre.it_remote_lock_handle;
+		if (it->it_remote_lock_mode) {
+			handle.cookie = it->it_remote_lock_handle;
 			CDEBUG(D_DLMTRACE, "setting l_data to inode "DFID"%p for remote lock %#llx\n",
 			       PFID(ll_inode2fid(inode)), inode,
 			       handle.cookie);
 			md_set_lock_data(exp, &handle.cookie, inode, NULL);
 		}
 
-		handle.cookie = it->d.lustre.it_lock_handle;
+		handle.cookie = it->it_lock_handle;
 
 		CDEBUG(D_DLMTRACE, "setting l_data to inode "DFID"%p for lock %#llx\n",
 		       PFID(ll_inode2fid(inode)), inode, handle.cookie);
 
 		md_set_lock_data(exp, &handle.cookie, inode,
-				 &it->d.lustre.it_lock_bits);
-		it->d.lustre.it_lock_set = 1;
+				 &it->it_lock_bits);
+		it->it_lock_set = 1;
 	}
 
 	if (bits)
-		*bits = it->d.lustre.it_lock_bits;
+		*bits = it->it_lock_bits;
 }
 
 static inline int d_lustre_invalid(const struct dentry *dentry)
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 83f4e1a..539fdd1 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1998,11 +1998,11 @@ int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
 	 * 3. proc2: refresh layout and layout lock granted
 	 * 4. proc1: to apply a stale layout
 	 */
-	if (it && it->d.lustre.it_lock_mode != 0) {
+	if (it && it->it_lock_mode != 0) {
 		struct lustre_handle lockh;
 		struct ldlm_lock *lock;
 
-		lockh.cookie = it->d.lustre.it_lock_handle;
+		lockh.cookie = it->it_lock_handle;
 		lock = ldlm_handle2lock(&lockh);
 		LASSERT(lock);
 		if (ldlm_has_layout(lock)) {
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index e4df510..7a6da02 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -393,7 +393,7 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 	 * when I return
 	 */
 	CDEBUG(D_DENTRY, "it %p it_disposition %x\n", it,
-	       it->d.lustre.it_disposition);
+	       it->it_disposition);
 	if (!it_disposition(it, DISP_LOOKUP_NEG)) {
 		rc = ll_prep_inode(&inode, request, (*de)->d_sb, it);
 		if (rc)
@@ -445,7 +445,7 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 		/* Check that parent has UPDATE lock. */
 		struct lookup_intent parent_it = {
 					.it_op = IT_GETATTR,
-					.d.lustre.it_lock_handle = 0 };
+					.it_lock_handle = 0 };
 
 		if (md_revalidate_lock(ll_i2mdexp(parent), &parent_it,
 				       &ll_i2info(parent)->lli_fid, NULL)) {
@@ -656,10 +656,10 @@ static struct inode *ll_create_node(struct inode *dir, struct lookup_intent *it)
 	struct ll_sb_info *sbi = ll_i2sbi(dir);
 	int rc;
 
-	LASSERT(it && it->d.lustre.it_disposition);
+	LASSERT(it && it->it_disposition);
 
 	LASSERT(it_disposition(it, DISP_ENQ_CREATE_REF));
-	request = it->d.lustre.it_data;
+	request = it->it_data;
 	it_clear_disposition(it, DISP_ENQ_CREATE_REF);
 	rc = ll_prep_inode(&inode, request, dir->i_sb, it);
 	if (rc) {
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index 03ad858..f775242 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -646,7 +646,7 @@ static void ll_post_statahead(struct ll_statahead_info *sai)
 		}
 	}
 
-	it->d.lustre.it_lock_handle = entry->se_handle;
+	it->it_lock_handle = entry->se_handle;
 	rc = md_revalidate_lock(ll_i2mdexp(dir), it, ll_inode2fid(dir), NULL);
 	if (rc != 1) {
 		rc = -EAGAIN;
@@ -700,7 +700,7 @@ static int ll_statahead_interpret(struct ptlrpc_request *req,
 		 * process enqueues lock on child with parent lock held, eg.
 		 * unlink.
 		 */
-		handle = it->d.lustre.it_lock_handle;
+		handle = it->it_lock_handle;
 		ll_intent_drop_lock(it);
 	}
 
@@ -850,7 +850,7 @@ static int do_sa_revalidate(struct inode *dir, struct ll_sa_entry *entry,
 {
 	struct inode	     *inode = d_inode(dentry);
 	struct lookup_intent      it = { .it_op = IT_GETATTR,
-					 .d.lustre.it_lock_handle = 0 };
+					 .it_lock_handle = 0 };
 	struct md_enqueue_info   *minfo;
 	struct ldlm_enqueue_info *einfo;
 	int rc;
@@ -865,7 +865,7 @@ static int do_sa_revalidate(struct inode *dir, struct ll_sa_entry *entry,
 	rc = md_revalidate_lock(ll_i2mdexp(dir), &it, ll_inode2fid(inode),
 				NULL);
 	if (rc == 1) {
-		entry->se_handle = it.d.lustre.it_lock_handle;
+		entry->se_handle = it.it_lock_handle;
 		ll_intent_release(&it);
 		return 1;
 	}
@@ -1569,7 +1569,7 @@ int do_statahead_enter(struct inode *dir, struct dentry **dentryp,
 		if (entry->se_stat == SA_ENTRY_SUCC && entry->se_inode) {
 			struct inode *inode = entry->se_inode;
 			struct lookup_intent it = { .it_op = IT_GETATTR,
-						    .d.lustre.it_lock_handle =
+						    .it_lock_handle =
 						     entry->se_handle };
 			__u64 bits;
 
diff --git a/drivers/staging/lustre/lustre/llite/xattr_cache.c b/drivers/staging/lustre/lustre/llite/xattr_cache.c
index d7e17ab..0d19645 100644
--- a/drivers/staging/lustre/lustre/llite/xattr_cache.c
+++ b/drivers/staging/lustre/lustre/llite/xattr_cache.c
@@ -288,8 +288,8 @@ static int ll_xattr_find_get_lock(struct inode *inode,
 				       LCK_PR);
 		if (mode != 0) {
 			/* fake oit in mdc_revalidate_lock() manner */
-			oit->d.lustre.it_lock_handle = lockh.cookie;
-			oit->d.lustre.it_lock_mode = mode;
+			oit->it_lock_handle = lockh.cookie;
+			oit->it_lock_mode = mode;
 			goto out;
 		}
 	}
@@ -315,7 +315,7 @@ static int ll_xattr_find_get_lock(struct inode *inode,
 		return rc;
 	}
 
-	*req = (struct ptlrpc_request *)oit->d.lustre.it_data;
+	*req = (struct ptlrpc_request *)oit->it_data;
 out:
 	down_write(&lli->lli_xattrs_list_rwsem);
 	mutex_unlock(&lli->lli_xattrs_enq_lock);
@@ -362,10 +362,10 @@ static int ll_xattr_cache_refill(struct inode *inode, struct lookup_intent *oit)
 		goto out_maybe_drop;
 	}
 
-	if (oit->d.lustre.it_status < 0) {
+	if (oit->it_status < 0) {
 		CDEBUG(D_CACHE, "getxattr intent returned %d for fid "DFID"\n",
-		       oit->d.lustre.it_status, PFID(ll_inode2fid(inode)));
-		rc = oit->d.lustre.it_status;
+		       oit->it_status, PFID(ll_inode2fid(inode)));
+		rc = oit->it_status;
 		/* xattr data is so large that we don't want to cache it */
 		if (rc == -ERANGE)
 			rc = -EAGAIN;
@@ -448,8 +448,8 @@ out_destroy:
 	up_write(&lli->lli_xattrs_list_rwsem);
 
 	ldlm_lock_decref_and_cancel((struct lustre_handle *)
-					&oit->d.lustre.it_lock_handle,
-					oit->d.lustre.it_lock_mode);
+					&oit->it_lock_handle,
+					oit->it_lock_mode);
 
 	goto out_no_unlock;
 }
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index 980c9d4..b3cff23 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -80,11 +80,11 @@ static int lmv_intent_remote(struct obd_export *exp, void *lmm,
 	/*
 	 * We got LOOKUP lock, but we really need attrs.
 	 */
-	pmode = it->d.lustre.it_lock_mode;
+	pmode = it->it_lock_mode;
 	if (pmode) {
-		plock.cookie = it->d.lustre.it_lock_handle;
-		it->d.lustre.it_lock_mode = 0;
-		it->d.lustre.it_data = NULL;
+		plock.cookie = it->it_lock_handle;
+		it->it_lock_mode = 0;
+		it->it_data = NULL;
 	}
 
 	LASSERT(fid_is_sane(&body->fid1));
@@ -130,14 +130,14 @@ static int lmv_intent_remote(struct obd_export *exp, void *lmm,
 	 * maintain dcache consistency. Thus drop UPDATE|PERM lock here
 	 * and put LOOKUP in request.
 	 */
-	if (it->d.lustre.it_lock_mode != 0) {
-		it->d.lustre.it_remote_lock_handle =
-					it->d.lustre.it_lock_handle;
-		it->d.lustre.it_remote_lock_mode = it->d.lustre.it_lock_mode;
+	if (it->it_lock_mode != 0) {
+		it->it_remote_lock_handle =
+					it->it_lock_handle;
+		it->it_remote_lock_mode = it->it_lock_mode;
 	}
 
-	it->d.lustre.it_lock_handle = plock.cookie;
-	it->d.lustre.it_lock_mode = pmode;
+	it->it_lock_handle = plock.cookie;
+	it->it_lock_mode = pmode;
 
 out_free_op_data:
 	kfree(op_data);
@@ -197,9 +197,9 @@ static int lmv_intent_open(struct obd_export *exp, struct md_op_data *op_data,
 	 * Nothing is found, do not access body->fid1 as it is zero and thus
 	 * pointless.
 	 */
-	if ((it->d.lustre.it_disposition & DISP_LOOKUP_NEG) &&
-	    !(it->d.lustre.it_disposition & DISP_OPEN_CREATE) &&
-	    !(it->d.lustre.it_disposition & DISP_OPEN_OPEN))
+	if ((it->it_disposition & DISP_LOOKUP_NEG) &&
+	    !(it->it_disposition & DISP_OPEN_CREATE) &&
+	    !(it->it_disposition & DISP_OPEN_OPEN))
 		return rc;
 
 	body = req_capsule_server_get(&(*reqp)->rq_pill, &RMF_MDT_BODY);
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index ab4f4fb..eb675fa 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1679,7 +1679,7 @@ lmv_enqueue_remote(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 		   struct lustre_handle *lockh, void *lmm, int lmmsize,
 		   __u64 extra_lock_flags)
 {
-	struct ptlrpc_request      *req = it->d.lustre.it_data;
+	struct ptlrpc_request      *req = it->it_data;
 	struct obd_device	  *obd = exp->exp_obd;
 	struct lmv_obd	     *lmv = &obd->u.lmv;
 	struct lustre_handle	plock;
@@ -1701,11 +1701,11 @@ lmv_enqueue_remote(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 	/*
 	 * We got LOOKUP lock, but we really need attrs.
 	 */
-	pmode = it->d.lustre.it_lock_mode;
+	pmode = it->it_lock_mode;
 	LASSERT(pmode != 0);
 	memcpy(&plock, lockh, sizeof(plock));
-	it->d.lustre.it_lock_mode = 0;
-	it->d.lustre.it_data = NULL;
+	it->it_lock_mode = 0;
+	it->it_data = NULL;
 	fid1 = body->fid1;
 
 	ptlrpc_req_finished(req);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 19b549c..5da2a1e 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -52,19 +52,19 @@ struct mdc_getattr_args {
 
 int it_disposition(struct lookup_intent *it, int flag)
 {
-	return it->d.lustre.it_disposition & flag;
+	return it->it_disposition & flag;
 }
 EXPORT_SYMBOL(it_disposition);
 
 void it_set_disposition(struct lookup_intent *it, int flag)
 {
-	it->d.lustre.it_disposition |= flag;
+	it->it_disposition |= flag;
 }
 EXPORT_SYMBOL(it_set_disposition);
 
 void it_clear_disposition(struct lookup_intent *it, int flag)
 {
-	it->d.lustre.it_disposition &= ~flag;
+	it->it_disposition &= ~flag;
 }
 EXPORT_SYMBOL(it_clear_disposition);
 
@@ -72,39 +72,39 @@ int it_open_error(int phase, struct lookup_intent *it)
 {
 	if (it_disposition(it, DISP_OPEN_LEASE)) {
 		if (phase >= DISP_OPEN_LEASE)
-			return it->d.lustre.it_status;
+			return it->it_status;
 		else
 			return 0;
 	}
 	if (it_disposition(it, DISP_OPEN_OPEN)) {
 		if (phase >= DISP_OPEN_OPEN)
-			return it->d.lustre.it_status;
+			return it->it_status;
 		else
 			return 0;
 	}
 
 	if (it_disposition(it, DISP_OPEN_CREATE)) {
 		if (phase >= DISP_OPEN_CREATE)
-			return it->d.lustre.it_status;
+			return it->it_status;
 		else
 			return 0;
 	}
 
 	if (it_disposition(it, DISP_LOOKUP_EXECD)) {
 		if (phase >= DISP_LOOKUP_EXECD)
-			return it->d.lustre.it_status;
+			return it->it_status;
 		else
 			return 0;
 	}
 
 	if (it_disposition(it, DISP_IT_EXECD)) {
 		if (phase >= DISP_IT_EXECD)
-			return it->d.lustre.it_status;
+			return it->it_status;
 		else
 			return 0;
 	}
-	CERROR("it disp: %X, status: %d\n", it->d.lustre.it_disposition,
-	       it->d.lustre.it_status);
+	CERROR("it disp: %X, status: %d\n", it->it_disposition,
+	       it->it_status);
 	LBUG();
 	return 0;
 }
@@ -551,7 +551,6 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 	struct req_capsule  *pill = &req->rq_pill;
 	struct ldlm_request *lockreq;
 	struct ldlm_reply   *lockrep;
-	struct lustre_intent_data *intent = &it->d.lustre;
 	struct ldlm_lock    *lock;
 	void		*lvb_data = NULL;
 	int		  lvb_len = 0;
@@ -585,17 +584,17 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 
 	lockrep = req_capsule_server_get(pill, &RMF_DLM_REP);
 
-	intent->it_disposition = (int)lockrep->lock_policy_res1;
-	intent->it_status = (int)lockrep->lock_policy_res2;
-	intent->it_lock_mode = einfo->ei_mode;
-	intent->it_lock_handle = lockh->cookie;
-	intent->it_data = req;
+	it->it_disposition = (int)lockrep->lock_policy_res1;
+	it->it_status = (int)lockrep->lock_policy_res2;
+	it->it_lock_mode = einfo->ei_mode;
+	it->it_lock_handle = lockh->cookie;
+	it->it_data = req;
 
 	/* Technically speaking rq_transno must already be zero if
 	 * it_status is in error, so the check is a bit redundant
 	 */
-	if ((!req->rq_transno || intent->it_status < 0) && req->rq_replay)
-		mdc_clear_replay_flag(req, intent->it_status);
+	if ((!req->rq_transno || it->it_status < 0) && req->rq_replay)
+		mdc_clear_replay_flag(req, it->it_status);
 
 	/* If we're doing an IT_OPEN which did not result in an actual
 	 * successful open, then we need to remove the bit which saves
@@ -606,11 +605,11 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 	 * (bug 3440)
 	 */
 	if (it->it_op & IT_OPEN && req->rq_replay &&
-	    (!it_disposition(it, DISP_OPEN_OPEN) || intent->it_status != 0))
-		mdc_clear_replay_flag(req, intent->it_status);
+	    (!it_disposition(it, DISP_OPEN_OPEN) || it->it_status != 0))
+		mdc_clear_replay_flag(req, it->it_status);
 
 	DEBUG_REQ(D_RPCTRACE, req, "op: %d disposition: %x, status: %d",
-		  it->it_op, intent->it_disposition, intent->it_status);
+		  it->it_op, it->it_disposition, it->it_status);
 
 	/* We know what to expect, so we do any byte flipping required here */
 	if (it->it_op & (IT_OPEN | IT_UNLINK | IT_LOOKUP | IT_GETATTR)) {
@@ -919,9 +918,9 @@ resend:
 		}
 		ptlrpc_req_finished(req);
 
-		it->d.lustre.it_lock_handle = 0;
-		it->d.lustre.it_lock_mode = 0;
-		it->d.lustre.it_data = NULL;
+		it->it_lock_handle = 0;
+		it->it_lock_mode = 0;
+		it->it_data = NULL;
 	}
 
 	return rc;
@@ -945,8 +944,8 @@ static int mdc_finish_intent_lock(struct obd_export *exp,
 		/* The server failed before it even started executing the
 		 * intent, i.e. because it couldn't unpack the request.
 		 */
-		LASSERT(it->d.lustre.it_status != 0);
-		return it->d.lustre.it_status;
+		LASSERT(it->it_status != 0);
+		return it->it_status;
 	}
 	rc = it_open_error(DISP_IT_EXECD, it);
 	if (rc)
@@ -1029,15 +1028,15 @@ static int mdc_finish_intent_lock(struct obd_export *exp,
 				    LDLM_IBITS, &policy, LCK_NL,
 				    &old_lock, 0)) {
 			ldlm_lock_decref_and_cancel(lockh,
-						    it->d.lustre.it_lock_mode);
+						    it->it_lock_mode);
 			memcpy(lockh, &old_lock, sizeof(old_lock));
-			it->d.lustre.it_lock_handle = lockh->cookie;
+			it->it_lock_handle = lockh->cookie;
 		}
 	}
 	CDEBUG(D_DENTRY,
 	       "D_IT dentry %.*s intent: %s status %d disp %x rc %d\n",
 	       op_data->op_namelen, op_data->op_name, ldlm_it2str(it->it_op),
-	       it->d.lustre.it_status, it->d.lustre.it_disposition, rc);
+	       it->it_status, it->it_disposition, rc);
 	return rc;
 }
 
@@ -1053,8 +1052,8 @@ int mdc_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
 	ldlm_policy_data_t policy;
 	enum ldlm_mode mode;
 
-	if (it->d.lustre.it_lock_handle) {
-		lockh.cookie = it->d.lustre.it_lock_handle;
+	if (it->it_lock_handle) {
+		lockh.cookie = it->it_lock_handle;
 		mode = ldlm_revalidate_lock_handle(&lockh, bits);
 	} else {
 		fid_build_reg_res_name(fid, &res_id);
@@ -1095,11 +1094,11 @@ int mdc_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
 	}
 
 	if (mode) {
-		it->d.lustre.it_lock_handle = lockh.cookie;
-		it->d.lustre.it_lock_mode = mode;
+		it->it_lock_handle = lockh.cookie;
+		it->it_lock_mode = mode;
 	} else {
-		it->d.lustre.it_lock_handle = 0;
-		it->d.lustre.it_lock_mode = 0;
+		it->it_lock_handle = 0;
+		it->it_lock_mode = 0;
 	}
 
 	return !!mode;
@@ -1121,15 +1120,15 @@ int mdc_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
  * ll_create/ll_open gets called.
  *
  * The server will return to us, in it_disposition, an indication of
- * exactly what d.lustre.it_status refers to.
+ * exactly what it_status refers to.
  *
- * If DISP_OPEN_OPEN is set, then d.lustre.it_status refers to the open() call,
+ * If DISP_OPEN_OPEN is set, then it_status refers to the open() call,
  * otherwise if DISP_OPEN_CREATE is set, then it status is the
  * creation failure mode.  In either case, one of DISP_LOOKUP_NEG or
  * DISP_LOOKUP_POS will be set, indicating whether the child lookup
  * was successful.
  *
- * Else, if DISP_LOOKUP_EXECD then d.lustre.it_status is the rc of the
+ * Else, if DISP_LOOKUP_EXECD then it_status is the rc of the
  * child lookup.
  */
 int mdc_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
@@ -1162,7 +1161,7 @@ int mdc_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
 		 * be called in revalidate_it if we already have a lock, let's
 		 * verify that.
 		 */
-		it->d.lustre.it_lock_handle = 0;
+		it->it_lock_handle = 0;
 		rc = mdc_revalidate_lock(exp, it, &op_data->op_fid2, NULL);
 		/* Only return failure if it was not GETATTR by cfid
 		 * (from inode_revalidate)
@@ -1184,7 +1183,7 @@ int mdc_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
 	if (rc < 0)
 		return rc;
 
-	*reqp = it->d.lustre.it_data;
+	*reqp = it->it_data;
 	rc = mdc_finish_intent_lock(exp, *reqp, op_data, it, &lockh);
 	return rc;
 }
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index f371e1d..7f5dfb0 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -661,7 +661,7 @@ int mdc_set_open_replay_data(struct obd_export *exp,
 	struct md_open_data   *mod;
 	struct mdt_rec_create *rec;
 	struct mdt_body       *body;
-	struct ptlrpc_request *open_req = it->d.lustre.it_data;
+	struct ptlrpc_request *open_req = it->it_data;
 	struct obd_import     *imp = open_req->rq_import;
 
 	if (!open_req->rq_replay)
-- 
2.7.4
