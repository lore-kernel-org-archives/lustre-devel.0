From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 12:30:40 -0500
Subject: [lustre-devel] [PATCH 10/35] staging: lustre: lmv: revalidate the
	dentry for striped dir
In-Reply-To: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1478799065-24841-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, wang di <di.wang@intel.com>, James Simmons <jsimmons@infradead.org>

From: wang di <di.wang@intel.com>

If there are bad stripe during striped dir revalidation,
most likely due the race between close(unlink) and
getattr, then let's revalidate the dentry, instead of
return error, like normal directory.

Signed-off-by: wang di <di.wang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6831
Reviewed-on: http://review.whamcloud.com/15720
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7078
Reviewed-on: http://review.whamcloud.com/16382
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/file.c      |    7 +++++
 drivers/staging/lustre/lustre/llite/llite_lib.c |   30 ++++++++++++++++++++++-
 drivers/staging/lustre/lustre/lmv/lmv_intent.c  |   11 +++++++-
 3 files changed, 45 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 7adbf31..28c2501 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -2732,6 +2732,13 @@ static int ll_inode_revalidate_fini(struct inode *inode, int rc)
 	/* Already unlinked. Just update nlink and return success */
 	if (rc == -ENOENT) {
 		clear_nlink(inode);
+		/* If it is striped directory, and there is bad stripe
+		 * Let's revalidate the dentry again, instead of returning
+		 * error
+		 */
+		if (S_ISDIR(inode->i_mode) && ll_i2info(inode)->lli_lsm_md)
+			return 0;
+
 		/* This path cannot be hit for regular files unless in
 		 * case of obscure races, so no need to validate size.
 		 */
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index c1b646c..4a4741b 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1194,16 +1194,44 @@ static int ll_update_lsm_md(struct inode *inode, struct lustre_md *md)
 
 	/* set the directory layout */
 	if (!lli->lli_lsm_md) {
+		struct cl_attr *attr;
+
 		rc = ll_init_lsm_md(inode, md);
 		if (rc)
 			return rc;
 
-		lli->lli_lsm_md = lsm;
 		/*
 		 * set lsm_md to NULL, so the following free lustre_md
 		 * will not free this lsm
 		 */
 		md->lmv = NULL;
+		lli->lli_lsm_md = lsm;
+
+		attr = kzalloc(sizeof(*attr), GFP_NOFS);
+		if (!attr)
+			return -ENOMEM;
+
+		/* validate the lsm */
+		rc = md_merge_attr(ll_i2mdexp(inode), lsm, attr,
+				   ll_md_blocking_ast);
+		if (rc) {
+			kfree(attr);
+			return rc;
+		}
+
+		if (md->body->mbo_valid & OBD_MD_FLNLINK)
+			md->body->mbo_nlink = attr->cat_nlink;
+		if (md->body->mbo_valid & OBD_MD_FLSIZE)
+			md->body->mbo_size = attr->cat_size;
+		if (md->body->mbo_valid & OBD_MD_FLATIME)
+			md->body->mbo_atime = attr->cat_atime;
+		if (md->body->mbo_valid & OBD_MD_FLCTIME)
+			md->body->mbo_ctime = attr->cat_ctime;
+		if (md->body->mbo_valid & OBD_MD_FLMTIME)
+			md->body->mbo_mtime = attr->cat_mtime;
+
+		kfree(attr);
+
 		CDEBUG(D_INODE, "Set lsm %p magic %x to "DFID"\n", lsm,
 		       lsm->lsm_md_magic, PFID(ll_inode2fid(inode)));
 		return 0;
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index 9f4e826..b1071cf 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -223,7 +223,14 @@ int lmv_revalidate_slaves(struct obd_export *exp,
 			LASSERT(body);
 
 			if (unlikely(body->mbo_nlink < 2)) {
-				CERROR("%s: nlink %d < 2 corrupt stripe %d "DFID":" DFID"\n",
+				/*
+				 * If this is bad stripe, most likely due
+				 * to the race between close(unlink) and
+				 * getattr, let's return -EONENT, so llite
+				 * will revalidate the dentry see
+				 * ll_inode_revalidate_fini()
+				 */
+				CDEBUG(D_INODE, "%s: nlink %d < 2 corrupt stripe %d "DFID":" DFID"\n",
 				       obd->obd_name, body->mbo_nlink, i,
 				       PFID(&lsm->lsm_md_oinfo[i].lmo_fid),
 				       PFID(&lsm->lsm_md_oinfo[0].lmo_fid));
@@ -233,7 +240,7 @@ int lmv_revalidate_slaves(struct obd_export *exp,
 					it.it_lock_mode = 0;
 				}
 
-				rc = -EIO;
+				rc = -ENOENT;
 				goto cleanup;
 			}
 
-- 
1.7.1
