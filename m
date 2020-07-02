From: James Simmons <jsimmons@infradead.org>
Date: Wed,  1 Jul 2020 20:04:43 -0400
Subject: [lustre-devel] [PATCH 03/18] lustre: sec: encryption for write path
In-Reply-To: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
References: <1593648298-10571-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1593648298-10571-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

First aspect is to make sure encryption context is properly set on
files/dirs that are created or opened/looked up.
Then encryption itself is carried out in osc_brw_prep_request(), just
before pages are added to the request to be sent. Because pages in
the page cache must hold clear text data, we have to use bounce pages
for encryption. The allocation is handled by fscrypt, and for
deallocation we call fscrypt_pullback_bio_page() and/or
fscrypt_pullback_bio_page().

WC-bug-id: https://jira.whamcloud.com/browse/LU-12275
Lustre-commit: a9ed5b149646f ("LU-12275 sec: encryption for write path")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/36144
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_osc.h    |  1 +
 fs/lustre/include/obd.h           | 17 ++++++++
 fs/lustre/include/obd_support.h   |  5 +++
 fs/lustre/llite/crypto.c          |  5 ++-
 fs/lustre/llite/dir.c             | 16 +++++++
 fs/lustre/llite/namei.c           | 87 ++++++++++++++++++++++++++++++++++-----
 fs/lustre/llite/rw26.c            |  4 ++
 fs/lustre/obdecho/echo_client.c   |  2 +
 fs/lustre/obdecho/echo_internal.h |  3 ++
 fs/lustre/osc/osc_internal.h      |  1 +
 fs/lustre/osc/osc_request.c       | 77 +++++++++++++++++++++++++++++++++-
 11 files changed, 206 insertions(+), 12 deletions(-)

diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index 4b448b9..11b7e92 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -52,6 +52,7 @@
 #include <obd.h>
 #include <cl_object.h>
 #include <linux/libcfs/libcfs_hash.h>
+#include <lustre_crypto.h>
 
 struct osc_quota_info {
 	/* linkage for quota hash table */
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 0ff19c8..f9e0920 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -116,6 +116,11 @@ struct brw_page {
 	struct page	       *pg;
 	unsigned int		count;
 	u32			flag;
+	/* used for encryption: difference with offset in clear text page */
+	u16			bp_off_diff;
+	/* used for encryption: difference with count in clear text page */
+	u16			bp_count_diff;
+	u32			bp_padding;
 };
 
 struct timeout_item {
@@ -1161,4 +1166,16 @@ static inline void client_adjust_max_dirty(struct client_obd *cli)
 					   1 << (20 - PAGE_SHIFT));
 }
 
+static inline struct inode *page2inode(struct page *page)
+{
+	if (page->mapping) {
+		if (PageAnon(page))
+			return NULL;
+		else
+			return page->mapping->host;
+	} else {
+		return NULL;
+	}
+}
+
 #endif /* __OBD_H */
diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index b5736f8..35c7ef3 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -583,4 +583,9 @@ struct obd_heat_instance {
 	u64 ohi_count;
 };
 
+/* Define a fixed 4096-byte encryption unit size */
+#define LUSTRE_ENCRYPTION_BLOCKBITS	12
+#define LUSTRE_ENCRYPTION_UNIT_SIZE	((size_t)1 << LUSTRE_ENCRYPTION_BLOCKBITS)
+#define LUSTRE_ENCRYPTION_MASK		(~(LUSTRE_ENCRYPTION_UNIT_SIZE - 1))
+
 #endif
diff --git a/fs/lustre/llite/crypto.c b/fs/lustre/llite/crypto.c
index 94189c9..f411343 100644
--- a/fs/lustre/llite/crypto.c
+++ b/fs/lustre/llite/crypto.c
@@ -52,7 +52,7 @@ static int ll_set_context(struct inode *inode, const void *ctx, size_t len,
 	struct ptlrpc_request *req = NULL;
 	int rc;
 
-	if (inode == NULL)
+	if (!inode)
 		return 0;
 
 	ext_flags = ll_inode_to_ext_flags(inode->i_flags) | LUSTRE_ENCRYPT_FL;
@@ -80,6 +80,9 @@ static int ll_set_context(struct inode *inode, const void *ctx, size_t len,
 	if (rc)
 		return rc;
 
+	/* used as encryption unit size */
+	if (S_ISREG(inode->i_mode))
+		inode->i_blkbits = LUSTRE_ENCRYPTION_BLOCKBITS;
 	ll_update_inode_flags(inode, ext_flags);
 	return 0;
 }
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 0ffe134..2c93908 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -388,6 +388,7 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 					       strlen(dirname)),
 		},
 	};
+	bool encrypt = false;
 	int err;
 
 	if (unlikely(!lmv_user_magic_supported(lump->lum_magic)))
@@ -446,6 +447,18 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
+	if (IS_ENCRYPTED(parent) ||
+	    unlikely(llcrypt_dummy_context_enabled(parent))) {
+		err = llcrypt_get_encryption_info(parent);
+		if (err)
+			goto out_op_data;
+		if (!llcrypt_has_encryption_key(parent)) {
+			err = -ENOKEY;
+			goto out_op_data;
+		}
+		encrypt = true;
+	}
+
 	if (sbi->ll_flags & LL_SBI_FILE_SECCTX) {
 		/*
 		 * selinux_dentry_init_security() uses dentry->d_parent and name
@@ -484,6 +497,9 @@ static int ll_dir_setdirstripe(struct dentry *dparent, struct lmv_user_md *lump,
 		err = ll_inode_init_security(&dentry, inode, parent);
 	}
 
+	if (encrypt)
+		err = llcrypt_inherit_context(parent, inode, NULL, false);
+
 out_inode:
 	iput(inode);
 out_request:
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index aa2dd13..2353a8f 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -47,7 +47,8 @@
 #include "llite_internal.h"
 
 static int ll_create_it(struct inode *dir, struct dentry *dentry,
-			struct lookup_intent *it, void *secctx, u32 secctxlen);
+			struct lookup_intent *it,
+			void *secctx, u32 secctxlen, bool encrypt);
 
 /* called from iget5_locked->find_inode() under inode_hash_lock spinlock */
 static int ll_test_inode(struct inode *inode, void *opaque)
@@ -605,7 +606,7 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 			       struct lookup_intent *it,
 			       struct inode *parent, struct dentry **de,
 			       void *secctx, u32 secctxlen,
-			       ktime_t kstart)
+			       ktime_t kstart, bool encrypt)
 {
 	struct inode *inode = NULL;
 	u64 bits = 0;
@@ -679,6 +680,16 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 		/* We have the "lookup" lock, so unhide dentry */
 		if (bits & MDS_INODELOCK_LOOKUP)
 			d_lustre_revalidate(*de);
+
+		if (encrypt) {
+			rc = llcrypt_get_encryption_info(inode);
+			if (rc)
+				goto out;
+			if (!llcrypt_has_encryption_key(inode)) {
+				rc = -ENOKEY;
+				goto out;
+			}
+		}
 	} else if (!it_disposition(it, DISP_OPEN_CREATE)) {
 		/*
 		 * If file was created on the server, the dentry is revalidated
@@ -725,7 +736,8 @@ static int ll_lookup_it_finish(struct ptlrpc_request *request,
 static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 				   struct lookup_intent *it, void **secctx,
 				   u32 *secctxlen,
-				   struct pcc_create_attach *pca)
+				   struct pcc_create_attach *pca,
+				   bool encrypt)
 {
 	ktime_t kstart = ktime_get();
 	struct lookup_intent lookup_it = { .it_op = IT_LOOKUP };
@@ -894,7 +906,7 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 	rc = ll_lookup_it_finish(req, it, parent, &dentry,
 				 secctx ? *secctx : NULL,
 				 secctxlen ? *secctxlen : 0,
-				kstart);
+				 kstart, encrypt);
 	if (rc != 0) {
 		ll_intent_release(it);
 		retval = ERR_PTR(rc);
@@ -952,7 +964,7 @@ static struct dentry *ll_lookup_nd(struct inode *parent, struct dentry *dentry,
 		itp = NULL;
 	else
 		itp = &it;
-	de = ll_lookup_it(parent, dentry, itp, NULL, NULL, NULL);
+	de = ll_lookup_it(parent, dentry, itp, NULL, NULL, NULL, false);
 
 	if (itp)
 		ll_intent_release(itp);
@@ -972,8 +984,9 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 	void *secctx = NULL;
 	u32 secctxlen = 0;
 	struct dentry *de;
-	struct ll_sb_info *sbi;
+	struct ll_sb_info *sbi = NULL;
 	struct pcc_create_attach pca = { NULL, NULL };
+	bool encrypt = false;
 	int rc = 0;
 
 	CDEBUG(D_VFSTRACE,
@@ -1025,8 +1038,23 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 	it->it_flags = (open_flags & ~O_ACCMODE) | OPEN_FMODE(open_flags);
 	it->it_flags &= ~MDS_OPEN_FL_INTERNAL;
 
+	if (IS_ENCRYPTED(dir)) {
+		/* we know that we are going to create a regular file because
+		 * we set S_IFREG bit on it->it_create_mode above
+		 */
+		rc = llcrypt_get_encryption_info(dir);
+		if (rc)
+			goto out_release;
+		if (!llcrypt_has_encryption_key(dir)) {
+			rc = -ENOKEY;
+			goto out_release;
+		}
+		encrypt = true;
+		rc = 0;
+	}
+
 	/* Dentry added to dcache tree in ll_lookup_it */
-	de = ll_lookup_it(dir, dentry, it, &secctx, &secctxlen, &pca);
+	de = ll_lookup_it(dir, dentry, it, &secctx, &secctxlen, &pca, encrypt);
 	if (IS_ERR(de))
 		rc = PTR_ERR(de);
 	else if (de)
@@ -1035,7 +1063,8 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 	if (!rc) {
 		if (it_disposition(it, DISP_OPEN_CREATE)) {
 			/* Dentry instantiated in ll_create_it. */
-			rc = ll_create_it(dir, dentry, it, secctx, secctxlen);
+			rc = ll_create_it(dir, dentry, it, secctx, secctxlen,
+					  encrypt);
 			security_release_secctx(secctx, secctxlen);
 			if (rc) {
 				/* We dget in ll_splice_alias. */
@@ -1150,7 +1179,8 @@ static struct inode *ll_create_node(struct inode *dir, struct lookup_intent *it)
  * with d_instantiate().
  */
 static int ll_create_it(struct inode *dir, struct dentry *dentry,
-			struct lookup_intent *it, void *secctx, u32 secctxlen)
+			struct lookup_intent *it,
+			void *secctx, u32 secctxlen, bool encrypt)
 {
 	struct inode *inode;
 	u64 bits = 0;
@@ -1185,6 +1215,12 @@ static int ll_create_it(struct inode *dir, struct dentry *dentry,
 
 	d_instantiate(dentry, inode);
 
+	if (encrypt) {
+		rc = llcrypt_inherit_context(dir, inode, dentry, true);
+		if (rc)
+			return rc;
+	}
+
 	if (!(ll_i2sbi(inode)->ll_flags & LL_SBI_FILE_SECCTX))
 		rc = ll_inode_init_security(dentry, inode, dir);
 
@@ -1214,10 +1250,11 @@ static int ll_new_node(struct inode *dir, struct dentry *dentry,
 		       u32 opc)
 {
 	struct ptlrpc_request *request = NULL;
-	struct md_op_data *op_data;
+	struct md_op_data *op_data = NULL;
 	struct inode *inode = NULL;
 	struct ll_sb_info *sbi = ll_i2sbi(dir);
 	int tgt_len = 0;
+	int encrypt = 0;
 	int err;
 
 	if (unlikely(tgt))
@@ -1241,6 +1278,19 @@ static int ll_new_node(struct inode *dir, struct dentry *dentry,
 			goto err_exit;
 	}
 
+	if ((IS_ENCRYPTED(dir) &&
+	    (S_ISREG(mode) || S_ISDIR(mode) || S_ISLNK(mode))) ||
+	    (unlikely(llcrypt_dummy_context_enabled(dir)) && S_ISDIR(mode))) {
+		err = llcrypt_get_encryption_info(dir);
+		if (err)
+			goto err_exit;
+		if (!llcrypt_has_encryption_key(dir)) {
+			err = -ENOKEY;
+			goto err_exit;
+		}
+		encrypt = 1;
+	}
+
 	err = md_create(sbi->ll_md_exp, op_data, tgt, tgt_len, mode,
 			from_kuid(&init_user_ns, current_fsuid()),
 			from_kgid(&init_user_ns, current_fsgid()),
@@ -1335,6 +1385,12 @@ static int ll_new_node(struct inode *dir, struct dentry *dentry,
 
 	d_instantiate(dentry, inode);
 
+	if (encrypt) {
+		err = llcrypt_inherit_context(dir, inode, NULL, true);
+		if (err)
+			goto err_exit;
+	}
+
 	if (!(sbi->ll_flags & LL_SBI_FILE_SECCTX))
 		err = ll_inode_init_security(dentry, inode, dir);
 err_exit:
@@ -1547,6 +1603,10 @@ static int ll_link(struct dentry *old_dentry, struct inode *dir,
 	       PFID(ll_inode2fid(src)), src, PFID(ll_inode2fid(dir)), dir,
 	       new_dentry);
 
+	err = llcrypt_prepare_link(old_dentry, dir, new_dentry);
+	if (err)
+		return err;
+
 	op_data = ll_prep_md_op_data(NULL, src, dir, new_dentry->d_name.name,
 				     new_dentry->d_name.len,
 				     0, LUSTRE_OPC_ANY, NULL);
@@ -1584,6 +1644,13 @@ static int ll_rename(struct inode *src, struct dentry *src_dchild,
 	       src_dchild, PFID(ll_inode2fid(src)), src,
 	       tgt_dchild, PFID(ll_inode2fid(tgt)), tgt);
 
+	if (unlikely(d_mountpoint(src_dchild) || d_mountpoint(tgt_dchild)))
+		return -EBUSY;
+
+	err = llcrypt_prepare_rename(src, src_dchild, tgt, tgt_dchild, flags);
+	if (err)
+		return err;
+
 	op_data = ll_prep_md_op_data(NULL, src, tgt, NULL, 0, 0,
 				     LUSTRE_OPC_ANY, NULL);
 	if (IS_ERR(op_data))
diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index 5e7aa6e..0971185 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -291,6 +291,10 @@ static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 	loff_t file_offset = iocb->ki_pos;
 	int rw = iov_iter_rw(iter);
 
+	/* if file is encrypted, return 0 so that we fall back to buffered IO */
+	if (IS_ENCRYPTED(inode))
+		return 0;
+
 	/* Check EOF by ourselves */
 	if (rw == READ && file_offset >= i_size_read(inode))
 		return 0;
diff --git a/fs/lustre/obdecho/echo_client.c b/fs/lustre/obdecho/echo_client.c
index 2324e38..a52e0362 100644
--- a/fs/lustre/obdecho/echo_client.c
+++ b/fs/lustre/obdecho/echo_client.c
@@ -1317,6 +1317,8 @@ static int echo_client_kbrw(struct echo_device *ed, int rw, struct obdo *oa,
 		if (!pgp->pg)
 			goto out;
 
+		/* set mapping so page is not considered encrypted */
+		pgp->pg->mapping = ECHO_MAPPING_UNENCRYPTED;
 		pages[i] = pgp->pg;
 		pgp->count = PAGE_SIZE;
 		pgp->off = off;
diff --git a/fs/lustre/obdecho/echo_internal.h b/fs/lustre/obdecho/echo_internal.h
index f9bb0b91..95b0149 100644
--- a/fs/lustre/obdecho/echo_internal.h
+++ b/fs/lustre/obdecho/echo_internal.h
@@ -43,4 +43,7 @@
 int block_debug_setup(void *addr, int len, u64 off, u64 id);
 int block_debug_check(char *who, void *addr, int len, u64 off, u64 id);
 
+/* mapping value to tell page is not encrypted */
+#define ECHO_MAPPING_UNENCRYPTED ((void *)1)
+
 #endif
diff --git a/fs/lustre/osc/osc_internal.h b/fs/lustre/osc/osc_internal.h
index d05595a..6bec6bf 100644
--- a/fs/lustre/osc/osc_internal.h
+++ b/fs/lustre/osc/osc_internal.h
@@ -216,4 +216,5 @@ static inline void osc_set_io_portal(struct ptlrpc_request *req)
 	else
 		req->rq_request_portal = OST_IO_PORTAL;
 }
+
 #endif /* OSC_INTERNAL_H */
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index b1bf8c6..db97d37 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -36,6 +36,7 @@
 #include <linux/workqueue.h>
 #include <linux/falloc.h>
 #include <linux/highmem.h>
+#include <linux/pagemap.h>
 #include <linux/sched/mm.h>
 
 #include <lustre_dlm.h>
@@ -1354,6 +1355,26 @@ static int osc_checksum_bulk_rw(const char *obd_name,
 	return rc;
 }
 
+static inline void osc_release_bounce_pages(struct brw_page **pga,
+					    u32 page_count)
+{
+#ifdef CONFIG_FS_ENCRYPTION
+	int i;
+
+	for (i = 0; i < page_count; i++) {
+		if (pga[i]->pg->mapping)
+			/* bounce pages are unmapped */
+			continue;
+		if (pga[i]->flag & OBD_BRW_SYNC)
+			/* sync transfer cannot have encrypted pages */
+			continue;
+		llcrypt_finalize_bounce_page(&pga[i]->pg);
+		pga[i]->count -= pga[i]->bp_count_diff;
+		pga[i]->off += pga[i]->bp_off_diff;
+	}
+#endif
+}
+
 static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 				struct obdo *oa, u32 page_count,
 				struct brw_page **pga,
@@ -1371,7 +1392,9 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 	struct brw_page *pg_prev;
 	void *short_io_buf;
 	const char *obd_name = cli->cl_import->imp_obd->obd_name;
+	struct inode *inode;
 
+	inode = page2inode(pga[0]->pg);
 	if (OBD_FAIL_CHECK(OBD_FAIL_OSC_BRW_PREP_REQ))
 		return -ENOMEM; /* Recoverable */
 	if (OBD_FAIL_CHECK(OBD_FAIL_OSC_BRW_PREP_REQ2))
@@ -1389,6 +1412,51 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 	if (!req)
 		return -ENOMEM;
 
+	if (opc == OST_WRITE && inode && IS_ENCRYPTED(inode)) {
+		for (i = 0; i < page_count; i++) {
+			struct brw_page *pg = pga[i];
+			struct page *data_page = NULL;
+			bool retried = false;
+			bool lockedbymyself;
+
+retry_encrypt:
+			/* The page can already be locked when we arrive here.
+			 * This is possible when cl_page_assume/vvp_page_assume
+			 * is stuck on wait_on_page_writeback with page lock
+			 * held. In this case there is no risk for the lock to
+			 * be released while we are doing our encryption
+			 * processing, because writeback against that page will
+			 * end in vvp_page_completion_write/cl_page_completion,
+			 * which means only once the page is fully processed.
+			 */
+			lockedbymyself = trylock_page(pg->pg);
+			data_page =
+				llcrypt_encrypt_pagecache_blocks(pg->pg,
+								 PAGE_SIZE, 0,
+								 GFP_NOFS);
+			if (lockedbymyself)
+				unlock_page(pg->pg);
+			if (IS_ERR(data_page)) {
+				rc = PTR_ERR(data_page);
+				if (rc == -ENOMEM && !retried) {
+					retried = true;
+					rc = 0;
+					goto retry_encrypt;
+				}
+				ptlrpc_request_free(req);
+				return rc;
+			}
+			/* len is forced to PAGE_SIZE, and poff to 0
+			 * so store the old, clear text info
+			 */
+			pg->pg = data_page;
+			pg->bp_count_diff = PAGE_SIZE - pg->count;
+			pg->count = PAGE_SIZE;
+			pg->bp_off_diff = pg->off & ~PAGE_MASK;
+			pg->off = pg->off & PAGE_MASK;
+		}
+	}
+
 	for (niocount = i = 1; i < page_count; i++) {
 		if (!can_merge_pages(pga[i - 1], pga[i]))
 			niocount++;
@@ -2115,6 +2183,10 @@ static int brw_interpret(const struct lu_env *env,
 
 	rc = osc_brw_fini_request(req, rc);
 	CDEBUG(D_INODE, "request %p aa %p rc %d\n", req, aa, rc);
+
+	/* restore clear text pages */
+	osc_release_bounce_pages(aa->aa_ppga, aa->aa_page_count);
+
 	/*
 	 * When server returns -EINPROGRESS, client should always retry
 	 * regardless of the number of times the bulk was resent already.
@@ -2430,7 +2502,10 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 		LASSERT(!req);
 
 		kmem_cache_free(osc_obdo_kmem, oa);
-		kfree(pga);
+		if (pga) {
+			osc_release_bounce_pages(pga, page_count);
+			osc_release_ppga(pga, page_count);
+		}
 		/* this should happen rarely and is pretty bad, it makes the
 		 * pending list not follow the dirty order
 		 */
-- 
1.8.3.1
