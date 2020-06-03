From: James Simmons <jsimmons@infradead.org>
Date: Tue,  2 Jun 2020 20:59:48 -0400
Subject: [lustre-devel] [PATCH 09/22] lustre: ldlm: no current source if
 lu_ref_del not in same tsk
In-Reply-To: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
References: <1591146001-27171-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1591146001-27171-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bruno Faccini <bruno.faccini@intel.com>

Running with USE_LU_REF ("configure --enable-lu_ref") configured
triggers a LBUG (because "ref->lf_failed > 0" condition false)
due to to using "current" as the lu_ref source, but in some cases
lu_ref_del() occurs within a different task context.
To avoid this, lu_ref source is changed to ldlm_lock address by
this patch.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13262
Lustre-commit: 419325a2c9a29e ("LU-13262 ldlm: no current source if lu_ref_del not in same tsk")
Signed-off-by: Bruno Faccini <bruno.faccini@intel.com>
Reviewed-on: https://review.whamcloud.com/37624
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h | 2 +-
 fs/lustre/ldlm/ldlm_lock.c     | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index 74c380e..28e766b 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -1085,7 +1085,7 @@ static inline struct ldlm_lock *ldlm_handle2lock(const struct lustre_handle *h)
 }
 
 #define LDLM_LOCK_REF_DEL(lock) \
-	lu_ref_del(&lock->l_reference, "handle", current)
+	lu_ref_del(&lock->l_reference, "handle", lock)
 
 static inline struct ldlm_lock *
 ldlm_handle2lock_long(const struct lustre_handle *h, u64 flags)
diff --git a/fs/lustre/ldlm/ldlm_lock.c b/fs/lustre/ldlm/ldlm_lock.c
index 3e71e4e..7fda7b8 100644
--- a/fs/lustre/ldlm/ldlm_lock.c
+++ b/fs/lustre/ldlm/ldlm_lock.c
@@ -528,7 +528,7 @@ struct ldlm_lock *__ldlm_handle2lock(const struct lustre_handle *handle,
 	 * destroyed after we did handle2object on it
 	 */
 	if (flags == 0 && !ldlm_is_destroyed(lock)) {
-		lu_ref_add_atomic(&lock->l_reference, "handle", current);
+		lu_ref_add_atomic(&lock->l_reference, "handle", lock);
 		return lock;
 	}
 
@@ -536,7 +536,7 @@ struct ldlm_lock *__ldlm_handle2lock(const struct lustre_handle *handle,
 
 	LASSERT(lock->l_resource);
 
-	lu_ref_add_atomic(&lock->l_reference, "handle", current);
+	lu_ref_add_atomic(&lock->l_reference, "handle", lock);
 	if (unlikely(ldlm_is_destroyed(lock))) {
 		unlock_res_and_lock(lock);
 		CDEBUG(D_INFO, "lock already destroyed: lock %p\n", lock);
-- 
1.8.3.1
