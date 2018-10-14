From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 14:57:58 -0400
Subject: [lustre-devel] [PATCH 08/28] lustre: hsm: add kkuc before sending
 registration RPCs
In-Reply-To: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543498-29105-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Henri Doreau <henri.doreau@cea.fr>

This avoids a situation where the registration completes and the CDT
sends HSM actions just before the kkuc registration happens. In this
case the client drops the actions because there are no CT pipes in the
kkuc list.

Signed-off-by: Henri Doreau <henri.doreau@cea.fr>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9416
Reviewed-on: https://review.whamcloud.com/28751
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Faccini Bruno <bruno.faccini@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lmv/lmv_obd.c | 44 +++++++++++++++++------------
 1 file changed, 26 insertions(+), 18 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 71bd843..952c68e 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -784,9 +784,23 @@ static int lmv_hsm_ct_register(struct lmv_obd *lmv, unsigned int cmd, int len,
 {
 	struct file *filp;
 	__u32 i, j;
-	int err, rc = 0;
+	int err;
 	bool any_set = false;
-	struct kkuc_ct_data kcd = { 0 };
+	struct kkuc_ct_data kcd = {
+		.kcd_magic	= KKUC_CT_DATA_MAGIC,
+		.kcd_uuid	= lmv->cluuid,
+		.kcd_archive	= lk->lk_data
+	};
+	int rc = 0;
+
+	filp = fget(lk->lk_wfd);
+	if (!filp)
+		return -EBADF;
+
+	rc = libcfs_kkuc_group_add(filp, lk->lk_uid, lk->lk_group,
+				   &kcd, sizeof(kcd));
+	if (rc)
+		goto err_fput;
 
 	/* All or nothing: try to register to all MDS.
 	 * In case of failure, unregister from previous MDS,
@@ -815,7 +829,7 @@ static int lmv_hsm_ct_register(struct lmv_obd *lmv, unsigned int cmd, int len,
 					obd_iocontrol(cmd, tgt->ltd_exp, len,
 						      lk, uarg);
 				}
-				return rc;
+				goto err_kkuc_rem;
 			}
 			/* else: transient error.
 			 * kuc will register to the missing MDT when it is back
@@ -825,24 +839,18 @@ static int lmv_hsm_ct_register(struct lmv_obd *lmv, unsigned int cmd, int len,
 		}
 	}
 
-	if (!any_set)
+	if (!any_set) {
 		/* no registration done: return error */
-		return -ENOTCONN;
-
-	/* at least one registration done, with no failure */
-	filp = fget(lk->lk_wfd);
-	if (!filp)
-		return -EBADF;
-
-	kcd.kcd_magic = KKUC_CT_DATA_MAGIC;
-	kcd.kcd_uuid = lmv->cluuid;
-	kcd.kcd_archive = lk->lk_data;
+		rc = -ENOTCONN;
+		goto err_kkuc_rem;
+	}
 
-	rc = libcfs_kkuc_group_add(filp, lk->lk_uid, lk->lk_group,
-				   &kcd, sizeof(kcd));
-	if (rc)
-		fput(filp);
+	return 0;
 
+err_kkuc_rem:
+	libcfs_kkuc_group_rem(lk->lk_uid, lk->lk_group);
+err_fput:
+	fput(filp);
 	return rc;
 }
 
-- 
1.8.3.1
