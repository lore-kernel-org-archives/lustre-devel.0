From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:18 -0500
Subject: [lustre-devel] [PATCH 150/622] lustre: lov: add debugging info for
 statfs
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-151-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

In obd_statfs() print the device name in the debug logs for clarity.

WC-bug-id: https://jira.whamcloud.com/browse/LU-7770
Lustre-commit: b917406a7f0a ("LU-7770 lov: fix statfs for conf-sanity test_50b")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33369
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_class.h | 14 +++++++-------
 fs/lustre/lov/lov_obd.c       |  4 +---
 2 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index 01eb385..742e92a 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -891,8 +891,8 @@ static inline int obd_statfs_async(struct obd_export *exp,
 				   time64_t max_age,
 				   struct ptlrpc_request_set *rqset)
 {
-	int rc = 0;
 	struct obd_device *obd;
+	int rc = 0;
 
 	if (!exp || !exp->exp_obd)
 		return -EINVAL;
@@ -903,8 +903,8 @@ static inline int obd_statfs_async(struct obd_export *exp,
 		return -EOPNOTSUPP;
 	}
 
-	CDEBUG(D_SUPER, "%s: osfs %p age %lld, max_age %lld\n",
-	       obd->obd_name, &obd->obd_osfs, obd->obd_osfs_age, max_age);
+	CDEBUG(D_SUPER, "%s: age %lld, max_age %lld\n",
+	       obd->obd_name, obd->obd_osfs_age, max_age);
 	if (obd->obd_osfs_age < max_age) {
 		rc = OBP(obd, statfs_async)(exp, oinfo, max_age, rqset);
 	} else {
@@ -935,20 +935,20 @@ static inline int obd_statfs(const struct lu_env *env, struct obd_export *exp,
 	struct obd_device *obd = exp->exp_obd;
 	int rc = 0;
 
-	if (!obd)
+	if (unlikely(!obd))
 		return -EINVAL;
 
 	rc = obd_check_dev_active(obd);
 	if (rc)
 		return rc;
 
-	if (!obd->obd_type || !obd->obd_type->typ_dt_ops->statfs) {
+	if (unlikely(!obd->obd_type || !obd->obd_type->typ_dt_ops->statfs)) {
 		CERROR("%s: no %s operation\n", obd->obd_name, __func__);
 		return -EOPNOTSUPP;
 	}
 
-	CDEBUG(D_SUPER, "osfs %lld, max_age %lld\n",
-	       obd->obd_osfs_age, max_age);
+	CDEBUG(D_SUPER, "%s: age %lld, max_age %lld\n",
+	       obd->obd_name, obd->obd_osfs_age, max_age);
 	/* ignore cache if aggregated isn't expected */
 	if (obd->obd_osfs_age < max_age ||
 	    ((obd->obd_osfs.os_state & OS_STATE_SUM) &&
diff --git a/fs/lustre/lov/lov_obd.c b/fs/lustre/lov/lov_obd.c
index 9a6ffe8..a16c663 100644
--- a/fs/lustre/lov/lov_obd.c
+++ b/fs/lustre/lov/lov_obd.c
@@ -1122,9 +1122,7 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 			if (!lov->lov_tgts[i] || !lov->lov_tgts[i]->ltd_exp)
 				continue;
 
-			/* ll_umount_begin() sets force flag but for lov, not
-			 * osc. Let's pass it through
-			 */
+			/* ll_umount_begin() sets force on lov, pass to osc */
 			osc_obd = class_exp2obd(lov->lov_tgts[i]->ltd_exp);
 			osc_obd->obd_force = obddev->obd_force;
 			err = obd_iocontrol(cmd, lov->lov_tgts[i]->ltd_exp,
-- 
1.8.3.1
