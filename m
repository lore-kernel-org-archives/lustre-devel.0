From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 22:00:41 -0500
Subject: [lustre-devel] [PATCH v2 58/84] staging/lustre: Remove commented
	out obd functions
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-59-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

obd_register_page_removal_cb, obd_unregister_page_removal_cb
obd_register_lock_cancel_cb, obd_unregister_lock_cancel_cb

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/obd_class.h | 51 -----------------------
 1 file changed, 51 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 7ea5801..8515218 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -1328,57 +1328,6 @@ static inline int obd_register_observer(struct obd_device *obd,
 	return 0;
 }
 
-#if 0
-static inline int obd_register_page_removal_cb(struct obd_export *exp,
-					       obd_page_removal_cb_t cb,
-					       obd_pin_extent_cb pin_cb)
-{
-	int rc;
-
-	OBD_CHECK_DT_OP(exp->exp_obd, register_page_removal_cb, 0);
-	OBD_COUNTER_INCREMENT(exp->exp_obd, register_page_removal_cb);
-
-	rc = OBP(exp->exp_obd, register_page_removal_cb)(exp, cb, pin_cb);
-	return rc;
-}
-
-static inline int obd_unregister_page_removal_cb(struct obd_export *exp,
-						 obd_page_removal_cb_t cb)
-{
-	int rc;
-
-	OBD_CHECK_DT_OP(exp->exp_obd, unregister_page_removal_cb, 0);
-	OBD_COUNTER_INCREMENT(exp->exp_obd, unregister_page_removal_cb);
-
-	rc = OBP(exp->exp_obd, unregister_page_removal_cb)(exp, cb);
-	return rc;
-}
-
-static inline int obd_register_lock_cancel_cb(struct obd_export *exp,
-					      obd_lock_cancel_cb cb)
-{
-	int rc;
-
-	OBD_CHECK_DT_OP(exp->exp_obd, register_lock_cancel_cb, 0);
-	OBD_COUNTER_INCREMENT(exp->exp_obd, register_lock_cancel_cb);
-
-	rc = OBP(exp->exp_obd, register_lock_cancel_cb)(exp, cb);
-	return rc;
-}
-
-static inline int obd_unregister_lock_cancel_cb(struct obd_export *exp,
-						 obd_lock_cancel_cb cb)
-{
-	int rc;
-
-	OBD_CHECK_DT_OP(exp->exp_obd, unregister_lock_cancel_cb, 0);
-	OBD_COUNTER_INCREMENT(exp->exp_obd, unregister_lock_cancel_cb);
-
-	rc = OBP(exp->exp_obd, unregister_lock_cancel_cb)(exp, cb);
-	return rc;
-}
-#endif
-
 /* metadata helpers */
 static inline int md_getstatus(struct obd_export *exp, struct lu_fid *fid)
 {
-- 
2.1.0
