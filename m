From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Thu,  1 Oct 2015 00:12:25 -0400
Subject: [lustre-devel] [PATCH 15/32] staging/lustre/ldlm: Remove
	ldlm_errno2error()
In-Reply-To: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
References: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443672762-982936-16-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

This particular incarnation is only used on the server.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h |  3 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      | 36 ----------------------
 2 files changed, 1 insertion(+), 38 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 72c52ef..432222b 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -1161,8 +1161,7 @@ static inline int ldlm_res_lvbo_update(struct ldlm_resource *res,
 }
 
 int ldlm_error2errno(ldlm_error_t error);
-ldlm_error_t ldlm_errno2error(int err_no); /* don't call it `errno': this
-					    * confuses user-space. */
+
 #if LUSTRE_TRACKS_LOCK_EXP_REFS
 void ldlm_dump_export_locks(struct obd_export *exp);
 #endif
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index 584c4e6..b840200 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -814,42 +814,6 @@ int ldlm_error2errno(ldlm_error_t error)
 }
 EXPORT_SYMBOL(ldlm_error2errno);
 
-/**
- * Dual to ldlm_error2errno(): maps errno values back to ldlm_error_t.
- */
-ldlm_error_t ldlm_errno2error(int err_no)
-{
-	int error;
-
-	switch (err_no) {
-	case 0:
-		error = ELDLM_OK;
-		break;
-	case -ESTALE:
-		error = ELDLM_LOCK_CHANGED;
-		break;
-	case -ENAVAIL:
-		error = ELDLM_LOCK_ABORTED;
-		break;
-	case -ESRCH:
-		error = ELDLM_LOCK_REPLACED;
-		break;
-	case -ENOENT:
-		error = ELDLM_NO_LOCK_DATA;
-		break;
-	case -EEXIST:
-		error = ELDLM_NAMESPACE_EXISTS;
-		break;
-	case -EBADF:
-		error = ELDLM_BAD_NAMESPACE;
-		break;
-	default:
-		error = err_no;
-	}
-	return error;
-}
-EXPORT_SYMBOL(ldlm_errno2error);
-
 #if LUSTRE_TRACKS_LOCK_EXP_REFS
 void ldlm_dump_export_locks(struct obd_export *exp)
 {
-- 
2.1.0
