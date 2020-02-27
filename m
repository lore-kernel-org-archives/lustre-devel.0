From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:18:01 -0500
Subject: [lustre-devel] [PATCH 613/622] lustre: osc: glimpse and lock cancel
 race
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-614-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexander Zarochentsev <c17826@cray.com>

osc_dlm_blocking_ast0 clears l_ast_data before writing
file data to OST and opens a race window. Neither a glimpse
AST nor ldlm_cb_interpret can find correct file attributes at
that moment.

Cray-bug-id: LUS-8344
WC-bug-id: https://jira.whamcloud.com/browse/LU-13128
Lustre-commit: 7c99f67d9d39 ("LU-13128 osc: glimpse and lock cancel race")
Signed-off-by: Alexander Zarochentsev <c17826@cray.com>
Reviewed-on: https://review.whamcloud.com/37215
Reviewed-by: Andrew Perepechko <c17827@cray.com>
Reviewed-by: Andriy Skulysh <c17819@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h | 1 +
 fs/lustre/mdc/mdc_dev.c         | 2 +-
 fs/lustre/osc/osc_lock.c        | 8 ++++++--
 3 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 7dfef0f..f7fed0e 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -332,6 +332,7 @@
 #define OBD_FAIL_OSC_CONNECT_GRANT_PARAM		0x413
 #define OBD_FAIL_OSC_DELAY_IO				0x414
 #define OBD_FAIL_OSC_NO_SIZE_DATA			0x415
+#define OBD_FAIL_OSC_DELAY_CANCEL			0x416
 
 #define OBD_FAIL_PTLRPC					0x500
 #define OBD_FAIL_PTLRPC_ACK				0x501
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index 496491f..5a6be44 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -313,7 +313,6 @@ static int mdc_dlm_blocking_ast0(const struct lu_env *env,
 
 	if (dlmlock->l_ast_data) {
 		obj = osc2cl(dlmlock->l_ast_data);
-		dlmlock->l_ast_data = NULL;
 		cl_object_get(obj);
 	}
 	unlock_res_and_lock(dlmlock);
@@ -332,6 +331,7 @@ static int mdc_dlm_blocking_ast0(const struct lu_env *env,
 		 */
 		/* losing a lock, update kms */
 		lock_res_and_lock(dlmlock);
+		dlmlock->l_ast_data = NULL;
 		cl_object_attr_lock(obj);
 		attr->cat_kms = 0;
 		cl_object_attr_update(env, obj, attr, CAT_KMS);
diff --git a/fs/lustre/osc/osc_lock.c b/fs/lustre/osc/osc_lock.c
index ce592d7..3bb5bbd 100644
--- a/fs/lustre/osc/osc_lock.c
+++ b/fs/lustre/osc/osc_lock.c
@@ -419,13 +419,13 @@ static int __osc_dlm_blocking_ast(const struct lu_env *env,
 
 	if (dlmlock->l_ast_data) {
 		obj = osc2cl(dlmlock->l_ast_data);
-		dlmlock->l_ast_data = NULL;
-
 		cl_object_get(obj);
 	}
 
 	unlock_res_and_lock(dlmlock);
 
+	OBD_FAIL_TIMEOUT(OBD_FAIL_OSC_DELAY_CANCEL, 5);
+
 	/* if l_ast_data is NULL, the dlmlock was enqueued by AGL or
 	 * the object has been destroyed.
 	 */
@@ -442,6 +442,10 @@ static int __osc_dlm_blocking_ast(const struct lu_env *env,
 
 		/* losing a lock, update kms */
 		lock_res_and_lock(dlmlock);
+		/* clearing l_ast_data after flushing data,
+		 * to let glimpse ast find the lock and the object
+		 */
+		dlmlock->l_ast_data = NULL;
 		cl_object_attr_lock(obj);
 		/* Must get the value under the lock to avoid race. */
 		old_kms = cl2osc(obj)->oo_oinfo->loi_kms;
-- 
1.8.3.1
