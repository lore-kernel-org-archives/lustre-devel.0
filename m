From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Thu,  1 Oct 2015 00:12:27 -0400
Subject: [lustre-devel] [PATCH 17/32] staging/lustre/ldlm: Remove
	ldlm_lock_fail_match()
In-Reply-To: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
References: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443672762-982936-18-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

It's not used anywhere.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_dlm.h | 1 -
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     | 8 --------
 2 files changed, 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index 8b2b092..cc5ad4c1 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -1216,7 +1216,6 @@ int  ldlm_lock_addref_try(struct lustre_handle *lockh, __u32 mode);
 void ldlm_lock_decref(struct lustre_handle *lockh, __u32 mode);
 void ldlm_lock_decref_and_cancel(struct lustre_handle *lockh, __u32 mode);
 void ldlm_lock_fail_match_locked(struct ldlm_lock *lock);
-void ldlm_lock_fail_match(struct ldlm_lock *lock);
 void ldlm_lock_allow_match(struct ldlm_lock *lock);
 void ldlm_lock_allow_match_locked(struct ldlm_lock *lock);
 ldlm_mode_t ldlm_lock_match(struct ldlm_namespace *ns, __u64 flags,
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 7f9d3c1..536f97c 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -1158,14 +1158,6 @@ void ldlm_lock_fail_match_locked(struct ldlm_lock *lock)
 }
 EXPORT_SYMBOL(ldlm_lock_fail_match_locked);
 
-void ldlm_lock_fail_match(struct ldlm_lock *lock)
-{
-	lock_res_and_lock(lock);
-	ldlm_lock_fail_match_locked(lock);
-	unlock_res_and_lock(lock);
-}
-EXPORT_SYMBOL(ldlm_lock_fail_match);
-
 /**
  * Mark lock as "matchable" by OST.
  *
-- 
2.1.0
