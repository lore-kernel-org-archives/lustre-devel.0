Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 5FB5EC0218F
	for <lustre-devel@archiver.kernel.org>; Sun,  2 Feb 2025 20:57:13 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YmMFT0ljyz211K;
	Sun, 02 Feb 2025 12:49:49 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YmMCn3W5wz20vp
 for <lustre-devel@lists.lustre.org>; Sun, 02 Feb 2025 12:48:21 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm-e204-208.ccs.ornl.gov [160.91.203.12])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id D063D899ADB;
 Sun,  2 Feb 2025 15:46:41 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id CD62A106BE16; Sun,  2 Feb 2025 15:46:41 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  2 Feb 2025 15:46:14 -0500
Message-ID: <20250202204633.1148872-15-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250202204633.1148872-1-jsimmons@infradead.org>
References: <20250202204633.1148872-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 14/33] lustre: llite: remove OBD_ -> CFS_
 macros
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Arshad Hussain <arshad.hussain@aeoncomputing.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Timothy Day <timday@amazon.com>

Remove OBD macros that are simply redefinitions
of CFS macros.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12610
Lustre-commit: 407d34a639c93dc3b ("LU-12610 llite: remove OBD_ -> CFS_ macros")
Signed-off-by: Timothy Day <timday@amazon.com>
Signed-off-by: Ben Evans <beevans@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50804
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c         |  2 +-
 fs/lustre/llite/file.c        |  8 ++++----
 fs/lustre/llite/glimpse.c     |  2 +-
 fs/lustre/llite/llite_lib.c   | 10 +++++-----
 fs/lustre/llite/namei.c       |  6 +++---
 fs/lustre/llite/pcc.c         |  8 ++++----
 fs/lustre/llite/rw.c          |  4 ++--
 fs/lustre/llite/rw26.c        |  4 ++--
 fs/lustre/llite/vvp_io.c      |  8 ++++----
 fs/lustre/llite/vvp_object.c  |  2 +-
 fs/lustre/llite/xattr_cache.c |  2 +-
 fs/lustre/lmv/lmv_obd.c       |  2 +-
 fs/lustre/lov/lov_object.c    |  2 +-
 13 files changed, 30 insertions(+), 30 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 98da2c95ca37..0f4dc2f1ce5e 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -462,7 +462,7 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 		return -EINVAL;
 
 	if (IS_DEADDIR(parent) &&
-	    !OBD_FAIL_CHECK(OBD_FAIL_LLITE_NO_CHECK_DEAD))
+	    !CFS_FAIL_CHECK(OBD_FAIL_LLITE_NO_CHECK_DEAD))
 		return -ENOENT;
 
 	/* MDS < 2.14 doesn't support 'crush' hash type, and cannot handle
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index e5bbe35de473..84c204e5f9ee 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -620,7 +620,7 @@ static int ll_intent_file_open(struct dentry *de, void *lmm, int lmmsize,
 	 * if server supports open-by-fid, or file name is invalid, don't pack
 	 * name in open request
 	 */
-	if (OBD_FAIL_CHECK(OBD_FAIL_LLITE_OPEN_BY_NAME) ||
+	if (CFS_FAIL_CHECK(OBD_FAIL_LLITE_OPEN_BY_NAME) ||
 	    !(exp_connect_flags(sbi->ll_md_exp) & OBD_CONNECT_OPEN_BY_FID)) {
 retry:
 		len = de->d_name.len;
@@ -654,7 +654,7 @@ static int ll_intent_file_open(struct dentry *de, void *lmm, int lmmsize,
 	op_data->op_data = lmm;
 	op_data->op_data_size = lmmsize;
 
-	OBD_FAIL_TIMEOUT(OBD_FAIL_LLITE_OPEN_DELAY, cfs_fail_val);
+	CFS_FAIL_TIMEOUT(OBD_FAIL_LLITE_OPEN_DELAY, cfs_fail_val);
 
 	rc = md_intent_lock(sbi->ll_md_exp, op_data, itp, &req,
 			    &ll_md_blocking_ast, 0);
@@ -1454,7 +1454,7 @@ static int ll_merge_attr_nolock(const struct lu_env *env, struct inode *inode)
 	ctime = inode->i_ctime.tv_sec;
 
 	cl_object_attr_lock(obj);
-	if (OBD_FAIL_CHECK(OBD_FAIL_MDC_MERGE))
+	if (CFS_FAIL_CHECK(OBD_FAIL_MDC_MERGE))
 		rc = -EINVAL;
 	else
 		rc = cl_object_attr_get(env, obj, attr);
@@ -5454,7 +5454,7 @@ int ll_getattr_dentry(struct dentry *de, struct kstat *stat, u32 request_mask,
 	}
 
 fill_attr:
-	OBD_FAIL_TIMEOUT(OBD_FAIL_GETATTR_DELAY, 30);
+	CFS_FAIL_TIMEOUT(OBD_FAIL_GETATTR_DELAY, 30);
 
 	stat->dev = inode->i_sb->s_dev;
 	if (ll_need_32bit_api(sbi)) {
diff --git a/fs/lustre/llite/glimpse.c b/fs/lustre/llite/glimpse.c
index 0190cb52f875..1579fa18bc06 100644
--- a/fs/lustre/llite/glimpse.c
+++ b/fs/lustre/llite/glimpse.c
@@ -215,7 +215,7 @@ int __cl_glimpse_size(struct inode *inode, int agl)
 				io->ci_need_restart = 1;
 		}
 
-		OBD_FAIL_TIMEOUT(OBD_FAIL_GLIMPSE_DELAY, 2);
+		CFS_FAIL_TIMEOUT(OBD_FAIL_GLIMPSE_DELAY, cfs_fail_val ? : 4);
 		cl_io_fini(env, io);
 	} while (unlikely(io->ci_need_restart));
 
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 908ca3d43ee3..7efa5b0246b8 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -334,7 +334,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 
 	data->ocd_cksum_types = obd_cksum_types_supported_client();
 
-	if (OBD_FAIL_CHECK(OBD_FAIL_MDC_LIGHTWEIGHT))
+	if (CFS_FAIL_CHECK(OBD_FAIL_MDC_LIGHTWEIGHT))
 		/* flag mdc connection as lightweight, only used for test
 		 * purpose, use with care
 		 */
@@ -563,7 +563,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 				   OBD_CONNECT2_INC_XID | OBD_CONNECT2_LSEEK |
 				   OBD_CONNECT2_REP_MBITS;
 
-	if (!OBD_FAIL_CHECK(OBD_FAIL_OSC_CONNECT_GRANT_PARAM))
+	if (!CFS_FAIL_CHECK(OBD_FAIL_OSC_CONNECT_GRANT_PARAM))
 		data->ocd_connect_flags |= OBD_CONNECT_GRANT_PARAM;
 
 	/* OBD_CONNECT_CKSUM should always be set, even if checksums are
@@ -573,7 +573,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	 */
 	data->ocd_connect_flags |= OBD_CONNECT_CKSUM;
 
-	if (OBD_FAIL_CHECK(OBD_FAIL_OSC_CKSUM_ADLER_ONLY))
+	if (CFS_FAIL_CHECK(OBD_FAIL_OSC_CKSUM_ADLER_ONLY))
 		data->ocd_cksum_types = OBD_CKSUM_ADLER;
 	else
 		data->ocd_cksum_types = obd_cksum_types_supported_client();
@@ -1241,7 +1241,7 @@ int ll_fill_super(struct super_block *sb)
 
 	CDEBUG(D_VFSTRACE, "VFS Op: sb %p\n", sb);
 
-	OBD_RACE(OBD_FAIL_LLITE_RACE_MOUNT);
+	CFS_RACE(OBD_FAIL_LLITE_RACE_MOUNT);
 
 	cfg = kzalloc(sizeof(*cfg), GFP_NOFS);
 	if (!cfg) {
@@ -1429,7 +1429,7 @@ void ll_put_super(struct super_block *sb)
 	}
 
 	/* imitate failed cleanup */
-	if (OBD_FAIL_CHECK(OBD_FAIL_OBD_CLEANUP))
+	if (CFS_FAIL_CHECK(OBD_FAIL_OBD_CLEANUP))
 		goto skip_cleanup;
 
 	next = 0;
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 59a7bbb7a99f..85a5902b0598 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -204,7 +204,7 @@ static int ll_dom_lock_cancel(struct inode *inode, struct ldlm_lock *lock)
 	if (IS_ERR(env))
 		return PTR_ERR(env);
 
-	OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_REPLAY_PAUSE, cfs_fail_val);
+	CFS_FAIL_TIMEOUT(OBD_FAIL_LDLM_REPLAY_PAUSE, cfs_fail_val);
 
 	/* reach MDC layer to flush data under  the DoM ldlm lock */
 	rc = cl_object_flush(env, lli->lli_clob, lock);
@@ -1213,7 +1213,7 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 		}
 	}
 
-	OBD_FAIL_TIMEOUT(OBD_FAIL_LLITE_CREATE_FILE_PAUSE2, cfs_fail_val);
+	CFS_FAIL_TIMEOUT(OBD_FAIL_LLITE_CREATE_FILE_PAUSE2, cfs_fail_val);
 
 	/* We can only arrive at this path when we have no inode, so
 	 * we only need to request open lock if it was requested
@@ -1340,7 +1340,7 @@ static struct inode *ll_create_node(struct inode *dir, struct lookup_intent *it)
 	}
 
 	/* Pause to allow for a race with concurrent access by fid */
-	OBD_FAIL_TIMEOUT(OBD_FAIL_LLITE_CREATE_NODE_PAUSE, cfs_fail_val);
+	CFS_FAIL_TIMEOUT(OBD_FAIL_LLITE_CREATE_NODE_PAUSE, cfs_fail_val);
 
 	/* We asked for a lock on the directory, but were granted a
 	 * lock on the inode.  Since we finally have an inode pointer,
diff --git a/fs/lustre/llite/pcc.c b/fs/lustre/llite/pcc.c
index ec35061052b2..ac9124f9554e 100644
--- a/fs/lustre/llite/pcc.c
+++ b/fs/lustre/llite/pcc.c
@@ -1674,7 +1674,7 @@ ssize_t pcc_file_write_iter(struct kiocb *iocb,
 	if (!*cached)
 		return 0;
 
-	if (OBD_FAIL_CHECK(OBD_FAIL_LLITE_PCC_FAKE_ERROR)) {
+	if (CFS_FAIL_CHECK(OBD_FAIL_LLITE_PCC_FAKE_ERROR)) {
 		result = -ENOSPC;
 		goto out;
 	}
@@ -1911,7 +1911,7 @@ vm_fault_t pcc_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 		return VM_FAULT_RETRY | VM_FAULT_NOPAGE;
 	}
 	/* Pause to allow for a race with concurrent detach */
-	OBD_FAIL_TIMEOUT(OBD_FAIL_LLITE_PCC_MKWRITE_PAUSE, cfs_fail_val);
+	CFS_FAIL_TIMEOUT(OBD_FAIL_LLITE_PCC_MKWRITE_PAUSE, cfs_fail_val);
 
 	pcc_io_init(inode, PIT_PAGE_MKWRITE, cached);
 	if (!*cached) {
@@ -1944,7 +1944,7 @@ vm_fault_t pcc_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 	 * This fault injection can also be used to simulate -ENOSPC and
 	 * -EDQUOT failure of underlying PCC backend fs.
 	 */
-	if (OBD_FAIL_CHECK(OBD_FAIL_LLITE_PCC_DETACH_MKWRITE)) {
+	if (CFS_FAIL_CHECK(OBD_FAIL_LLITE_PCC_DETACH_MKWRITE)) {
 		pcc_io_fini(inode);
 		pcc_ioctl_detach(inode, PCC_DETACH_OPT_UNCACHE);
 		mmap_read_unlock(mm);
@@ -2401,7 +2401,7 @@ int pcc_readwrite_attach(struct file *file, struct inode *inode,
 		goto out_fput;
 
 	/* Pause to allow for a race with concurrent HSM remove */
-	OBD_FAIL_TIMEOUT(OBD_FAIL_LLITE_PCC_ATTACH_PAUSE, cfs_fail_val);
+	CFS_FAIL_TIMEOUT(OBD_FAIL_LLITE_PCC_ATTACH_PAUSE, cfs_fail_val);
 
 	pcc_inode_lock(inode);
 	pcci = ll_i2pcci(inode);
diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index c7adfc6d4faf..d2e400182ecf 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -1875,9 +1875,9 @@ int ll_readpage(struct file *file, struct page *vmpage)
 	struct cl_page *page;
 	int result;
 
-	if (OBD_FAIL_PRECHECK(OBD_FAIL_LLITE_READPAGE_PAUSE)) {
+	if (CFS_FAIL_PRECHECK(OBD_FAIL_LLITE_READPAGE_PAUSE)) {
 		unlock_page(vmpage);
-		OBD_FAIL_TIMEOUT(OBD_FAIL_LLITE_READPAGE_PAUSE, cfs_fail_val);
+		CFS_FAIL_TIMEOUT(OBD_FAIL_LLITE_READPAGE_PAUSE, cfs_fail_val);
 		lock_page(vmpage);
 	}
 
diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index 5f0186cb9ecb..ad7308a8c902 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -97,9 +97,9 @@ static void ll_invalidatepage(struct page *vmpage, unsigned int offset,
 		cl_env_percpu_put(env);
 	}
 
-	if (OBD_FAIL_PRECHECK(OBD_FAIL_LLITE_PAGE_INVALIDATE_PAUSE)) {
+	if (CFS_FAIL_PRECHECK(OBD_FAIL_LLITE_PAGE_INVALIDATE_PAUSE)) {
 		unlock_page(vmpage);
-		OBD_FAIL_TIMEOUT(OBD_FAIL_LLITE_PAGE_INVALIDATE_PAUSE,
+		CFS_FAIL_TIMEOUT(OBD_FAIL_LLITE_PAGE_INVALIDATE_PAUSE,
 				 cfs_fail_val);
 		lock_page(vmpage);
 	}
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index 1b5628d1502d..c5f479c6f7e2 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -76,7 +76,7 @@ static bool can_populate_pages(const struct lu_env *env, struct cl_io *io,
 		 * extent lock and GROUP lock has to hold to swap layout
 		 */
 		if (ll_layout_version_get(lli) != vio->vui_layout_gen ||
-		    OBD_FAIL_CHECK_RESET(OBD_FAIL_LLITE_LOST_LAYOUT, 0)) {
+		    CFS_FAIL_CHECK_RESET(OBD_FAIL_LLITE_LOST_LAYOUT, 0)) {
 			io->ci_need_restart = 1;
 			/* this will cause a short read/write */
 			io->ci_continue = 0;
@@ -1230,10 +1230,10 @@ static int vvp_io_write_start(const struct lu_env *env,
 	}
 
 	/* Tests to verify we take the i_mutex correctly */
-	if (OBD_FAIL_CHECK(OBD_FAIL_LLITE_IMUTEX_SEC) && !lock_inode)
+	if (CFS_FAIL_CHECK(OBD_FAIL_LLITE_IMUTEX_SEC) && !lock_inode)
 		return -EINVAL;
 
-	if (OBD_FAIL_CHECK(OBD_FAIL_LLITE_IMUTEX_NOSEC) && lock_inode)
+	if (CFS_FAIL_CHECK(OBD_FAIL_LLITE_IMUTEX_NOSEC) && lock_inode)
 		return -EINVAL;
 
 	if (!(file->f_flags & O_DIRECT)) {
@@ -1423,7 +1423,7 @@ static int vvp_io_fault_start(const struct lu_env *env,
 	vmpage = cfio->ft_vmpage;
 	LASSERT(PageLocked(vmpage));
 
-	if (OBD_FAIL_CHECK(OBD_FAIL_LLITE_FAULT_TRUNC_RACE))
+	if (CFS_FAIL_CHECK(OBD_FAIL_LLITE_FAULT_TRUNC_RACE))
 		generic_error_remove_page(vmpage->mapping, vmpage);
 
 	size = i_size_read(inode);
diff --git a/fs/lustre/llite/vvp_object.c b/fs/lustre/llite/vvp_object.c
index c79bc5c0e6c9..5120ec095862 100644
--- a/fs/lustre/llite/vvp_object.c
+++ b/fs/lustre/llite/vvp_object.c
@@ -215,7 +215,7 @@ static void vvp_req_attr_set(const struct lu_env *env, struct cl_object *obj,
 	}
 	obdo_from_inode(oa, inode, valid_flags & attr->cra_flags);
 	obdo_set_parent_fid(oa, &ll_i2info(inode)->lli_fid);
-	if (OBD_FAIL_CHECK(OBD_FAIL_LFSCK_INVALID_PFID))
+	if (CFS_FAIL_CHECK(OBD_FAIL_LFSCK_INVALID_PFID))
 		oa->o_parent_oid++;
 
 	attr->cra_uid = lli->lli_uid;
diff --git a/fs/lustre/llite/xattr_cache.c b/fs/lustre/llite/xattr_cache.c
index d8ddb90f2042..719dfda0a8a6 100644
--- a/fs/lustre/llite/xattr_cache.c
+++ b/fs/lustre/llite/xattr_cache.c
@@ -454,7 +454,7 @@ static int ll_xattr_cache_refill(struct inode *inode)
 		} else if (xval + *xsizes > xvtail) {
 			CERROR("xattr protocol violation (vals are broken)\n");
 			rc = -EPROTO;
-		} else if (OBD_FAIL_CHECK(OBD_FAIL_LLITE_XATTR_ENOMEM)) {
+		} else if (CFS_FAIL_CHECK(OBD_FAIL_LLITE_XATTR_ENOMEM)) {
 			rc = -ENOMEM;
 		} else if (!strcmp(xdata, XATTR_NAME_ACL_ACCESS)) {
 			/* Filter out ACL ACCESS since it's cached separately */
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 27345a2a65b0..27c1df26849c 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1680,7 +1680,7 @@ lmv_locate_tgt_by_name(struct lmv_obd *lmv, struct lmv_stripe_md *lsm,
 		return tgt;
 	}
 
-	if (OBD_FAIL_CHECK(OBD_FAIL_LFSCK_BAD_NAME_HASH)) {
+	if (CFS_FAIL_CHECK(OBD_FAIL_LFSCK_BAD_NAME_HASH)) {
 		if (cfs_fail_val >= lsm->lsm_md_stripe_count)
 			return ERR_PTR(-EBADF);
 		oinfo = &lsm->lsm_md_oinfo[cfs_fail_val];
diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index 7c20f6eae03b..bc0f0a772d1d 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -132,7 +132,7 @@ static int lov_init_sub(const struct lu_env *env, struct lov_object *lov,
 	struct cl_object_header *parent;
 	int result;
 
-	if (OBD_FAIL_CHECK(OBD_FAIL_LOV_INIT)) {
+	if (CFS_FAIL_CHECK(OBD_FAIL_LOV_INIT)) {
 		/* For sanity:test_206.
 		 * Do not leave the object in cache to avoid accessing
 		 * freed memory. This is because osc_object is referring to
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
