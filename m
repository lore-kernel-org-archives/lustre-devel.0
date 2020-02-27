From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:36 -0500
Subject: [lustre-devel] [PATCH 228/622] lustre: llite: limit statfs ffree if
 less than OST ffree
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-229-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

If the OSTs report fewer total free objects than the MDTs, then
use the free files count reported by the OSTs, since it represents
the minimum number of files that can be created in the filesystem
(creating more may be possible, but this depends on other factors).
This has always been what ll_statfs_internal() reports, but the
statfs aggregation via the MDT missed this step in lod_statfs().

Fix a minor defect in sanity test_418() that would let it loop
forever until the test was killed due to timeout if the "df -i"
and "lfs df -i" output did not converge.

Fixes: 41a201a04c0f ("lustre: protocol: MDT as a statfs proxy")
WC-bug-id: https://jira.whamcloud.com/browse/LU-11721
Lustre-commit: a829595add80 ("LU-11721 lod: limit statfs ffree if less than OST ffree")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34167
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: Nikitas Angelinas <nangelinas@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_class.h |  5 +++--
 fs/lustre/llite/llite_lib.c   | 22 +++++++++++-----------
 fs/lustre/lmv/lmv_obd.c       |  4 ++--
 3 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index 434bb79..6a4b6a5 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -898,8 +898,9 @@ static inline int obd_statfs_async(struct obd_export *exp,
 
 	obd = exp->exp_obd;
 	if (!obd->obd_type || !obd->obd_type->typ_dt_ops->statfs) {
-		CERROR("%s: no %s operation\n", obd->obd_name, __func__);
-		return -EOPNOTSUPP;
+		rc = -EOPNOTSUPP;
+		CERROR("%s: no statfs operation: rc = %d\n", obd->obd_name, rc);
+		return rc;
 	}
 
 	CDEBUG(D_SUPER, "%s: age %lld, max_age %lld\n",
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 84fc54d..4d41981a 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1723,17 +1723,15 @@ int ll_setattr(struct dentry *de, struct iattr *attr)
 int ll_statfs_internal(struct ll_sb_info *sbi, struct obd_statfs *osfs,
 		       u32 flags)
 {
-	struct obd_statfs obd_osfs;
+	struct obd_statfs obd_osfs = { 0 };
 	time64_t max_age;
 	int rc;
 
 	max_age = ktime_get_seconds() - OBD_STATFS_CACHE_SECONDS;
 
 	rc = obd_statfs(NULL, sbi->ll_md_exp, osfs, max_age, flags);
-	if (rc) {
-		CERROR("md_statfs fails: rc = %d\n", rc);
+	if (rc)
 		return rc;
-	}
 
 	osfs->os_type = LL_SUPER_MAGIC;
 
@@ -1749,8 +1747,9 @@ int ll_statfs_internal(struct ll_sb_info *sbi, struct obd_statfs *osfs,
 
 	rc = obd_statfs(NULL, sbi->ll_dt_exp, &obd_osfs, max_age, flags);
 	if (rc) {
-		CERROR("obd_statfs fails: rc = %d\n", rc);
-		return rc;
+		/* Possibly a filesystem with no OSTs.  Report MDT totals. */
+		rc = 0;
+		goto out;
 	}
 
 	CDEBUG(D_SUPER, "OSC blocks %llu/%llu objects %llu/%llu\n",
@@ -1762,13 +1761,14 @@ int ll_statfs_internal(struct ll_sb_info *sbi, struct obd_statfs *osfs,
 	osfs->os_bfree = obd_osfs.os_bfree;
 	osfs->os_bavail = obd_osfs.os_bavail;
 
-	/* If we don't have as many objects free on the OST as inodes
-	 * on the MDS, we reduce the total number of inodes to
-	 * compensate, so that the "inodes in use" number is correct.
+	/* If we have _some_ OSTs, but don't have as many free objects on the
+	 * OSTs as inodes on the MDTs, reduce the reported number of inodes
+	 * to compensate, so that the "inodes in use" number is correct.
+	 * This should be kept in sync with lod_statfs() behaviour.
 	 */
-	if (obd_osfs.os_ffree < osfs->os_ffree) {
+	if (obd_osfs.os_files && obd_osfs.os_ffree < osfs->os_ffree) {
 		osfs->os_files = (osfs->os_files - osfs->os_ffree) +
-			obd_osfs.os_ffree;
+				 obd_osfs.os_ffree;
 		osfs->os_ffree = obd_osfs.os_ffree;
 	}
 
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 0685925..6ad100c 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -1402,8 +1402,8 @@ static int lmv_statfs(const struct lu_env *env, struct obd_export *exp,
 		rc = obd_statfs(env, lmv->tgts[idx]->ltd_exp, temp,
 				max_age, flags);
 		if (rc) {
-			CERROR("can't stat MDS #%d (%s), error %d\n", i,
-			       lmv->tgts[idx]->ltd_exp->exp_obd->obd_name,
+			CERROR("%s: can't stat MDS #%d: rc = %d\n",
+			       lmv->tgts[idx]->ltd_exp->exp_obd->obd_name, i,
 			       rc);
 			goto out_free_temp;
 		}
-- 
1.8.3.1
