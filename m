From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:36 -0500
Subject: [lustre-devel] [PATCH 588/622] lustre: llite: fix deadlock in
 ll_update_lsm_md()
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-589-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

Deadlock may happen in in following senario: a lookup process called
ll_update_lsm_md(), it found lli->lli_lsm_md is NULL, then
down_write(&lli->lli_lsm_sem). but another lookup process initialized
lli->lli_lsm_md after this check and before write lock, so the first
lookup process called up_read(&lli->lli_lsm_sem) and return, so the
write lock is never released, which cause subsequent lookups deadlock.

Rearrange the code to simplify the locking:
1. take read lock.
2. if lsm was initialized and unchanged, release read lock and return.
3. otherwise release read lock and take write lock.
4. free current lsm and initialize with new lsm.
5. release write lock.
6. initialize stripes with read lock.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13121
Lustre-commit: 3746550282c8 ("LU-13121 llite: fix deadlock in ll_update_lsm_md()")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/37182
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_lib.c | 107 +++++++++++++++++++++-----------------------
 1 file changed, 50 insertions(+), 57 deletions(-)

diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index f083a90..1a8a5ec 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1401,6 +1401,7 @@ static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct lmv_stripe_md *lsm = md->lmv;
+	struct cl_attr	*attr;
 	int rc = 0;
 
 	LASSERT(S_ISDIR(inode->i_mode));
@@ -1422,74 +1423,66 @@ static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 	 * normally dir layout doesn't change, only take read lock to check
 	 * that to avoid blocking other MD operations.
 	 */
-	if (lli->lli_lsm_md)
-		down_read(&lli->lli_lsm_sem);
-	else
-		down_write(&lli->lli_lsm_sem);
+	down_read(&lli->lli_lsm_sem);
 
-	/*
-	 * if dir layout mismatch, check whether version is increased, which
-	 * means layout is changed, this happens in dir migration and lfsck.
+	/* some current lookup initialized lsm, and unchanged */
+	if (lli->lli_lsm_md && lsm_md_eq(lli->lli_lsm_md, lsm))
+		goto unlock;
+
+	/* if dir layout doesn't match, check whether version is increased,
+	 * which means layout is changed, this happens in dir split/merge and
+	 * lfsck.
 	 *
 	 * foreign LMV should not change.
 	 */
-	if (lli->lli_lsm_md && !lsm_md_eq(lli->lli_lsm_md, lsm)) {
-		if (lmv_dir_striped(lli->lli_lsm_md) &&
-		    lsm->lsm_md_layout_version <=
-		    lli->lli_lsm_md->lsm_md_layout_version) {
-			CERROR("%s: " DFID " dir layout mismatch:\n",
-			       ll_i2sbi(inode)->ll_fsname,
-			       PFID(&lli->lli_fid));
-			lsm_md_dump(D_ERROR, lli->lli_lsm_md);
-			lsm_md_dump(D_ERROR, lsm);
-			rc = -EINVAL;
-			goto unlock;
-		}
-
-		/* layout changed, switch to write lock */
-		up_read(&lli->lli_lsm_sem);
-		down_write(&lli->lli_lsm_sem);
-		ll_dir_clear_lsm_md(inode);
+	if (lli->lli_lsm_md && lmv_dir_striped(lli->lli_lsm_md) &&
+	    lsm->lsm_md_layout_version <=
+	    lli->lli_lsm_md->lsm_md_layout_version) {
+		CERROR("%s: " DFID " dir layout mismatch:\n",
+		       ll_i2sbi(inode)->ll_fsname, PFID(&lli->lli_fid));
+		lsm_md_dump(D_ERROR, lli->lli_lsm_md);
+		lsm_md_dump(D_ERROR, lsm);
+		rc = -EINVAL;
+		goto unlock;
 	}
 
-	/* set directory layout */
-	if (!lli->lli_lsm_md) {
-		struct cl_attr *attr;
+	up_read(&lli->lli_lsm_sem);
+	down_write(&lli->lli_lsm_sem);
+	/* clear existing lsm */
+	if (lli->lli_lsm_md) {
+		lmv_free_memmd(lli->lli_lsm_md);
+		lli->lli_lsm_md = NULL;
+	}
 
-		rc = ll_init_lsm_md(inode, md);
-		up_write(&lli->lli_lsm_sem);
-		if (rc)
-			return rc;
+	rc = ll_init_lsm_md(inode, md);
+	up_write(&lli->lli_lsm_sem);
 
-		/*
-		 * set lsm_md to NULL, so the following free lustre_md
-		 * will not free this lsm
-		 */
-		md->lmv = NULL;
+	if (rc)
+		return rc;
 
-		/*
-		 * md_merge_attr() may take long, since lsm is already set,
-		 * switch to read lock.
-		 */
-		down_read(&lli->lli_lsm_sem);
+	/* set md->lmv to NULL, so the following free lustre_md will not free
+	 * this lsm.
+	 */
+	md->lmv = NULL;
 
-		if (!lmv_dir_striped(lli->lli_lsm_md))
-			goto unlock;
+	/* md_merge_attr() may take long, since lsm is already set, switch to
+	 * read lock.
+	 */
+	down_read(&lli->lli_lsm_sem);
 
-		attr = kzalloc(sizeof(*attr), GFP_NOFS);
-		if (!attr) {
-			rc = -ENOMEM;
-			goto unlock;
-		}
+	if (!lmv_dir_striped(lli->lli_lsm_md))
+		goto unlock;
 
-		/* validate the lsm */
-		rc = md_merge_attr(ll_i2mdexp(inode), lsm, attr,
-				   ll_md_blocking_ast);
-		if (rc) {
-			kfree(attr);
-			goto unlock;
-		}
+	attr = kzalloc(sizeof(*attr), GFP_NOFS);
+	if (!attr) {
+		rc = -ENOMEM;
+		goto unlock;
+	}
 
+	/* validate the lsm */
+	rc = md_merge_attr(ll_i2mdexp(inode), lli->lli_lsm_md, attr,
+			   ll_md_blocking_ast);
+	if (!rc) {
 		if (md->body->mbo_valid & OBD_MD_FLNLINK)
 			md->body->mbo_nlink = attr->cat_nlink;
 		if (md->body->mbo_valid & OBD_MD_FLSIZE)
@@ -1500,9 +1493,9 @@ static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 			md->body->mbo_ctime = attr->cat_ctime;
 		if (md->body->mbo_valid & OBD_MD_FLMTIME)
 			md->body->mbo_mtime = attr->cat_mtime;
-
-		kfree(attr);
 	}
+
+	kfree(attr);
 unlock:
 	up_read(&lli->lli_lsm_sem);
 
-- 
1.8.3.1
