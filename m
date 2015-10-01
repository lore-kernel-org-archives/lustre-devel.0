From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Thu,  1 Oct 2015 00:12:42 -0400
Subject: [lustre-devel] [PATCH 32/32] staging/lustre/ldlm: Make
	ldlm_add_ast_work_item() static
In-Reply-To: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
References: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443672762-982936-33-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

Now that ldlm_flock code no longer uses it.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h | 2 --
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     | 5 +++--
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index 6cf3f9f..db3c9b7 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -142,8 +142,6 @@ void ldlm_lock_addref_internal(struct ldlm_lock *, __u32 mode);
 void ldlm_lock_addref_internal_nolock(struct ldlm_lock *, __u32 mode);
 void ldlm_lock_decref_internal(struct ldlm_lock *, __u32 mode);
 void ldlm_lock_decref_internal_nolock(struct ldlm_lock *, __u32 mode);
-void ldlm_add_ast_work_item(struct ldlm_lock *lock, struct ldlm_lock *new,
-			    struct list_head *work_list);
 int ldlm_run_ast_work(struct ldlm_namespace *ns, struct list_head *rpc_list,
 		      enum ldlm_desc_ast_t ast_type);
 int ldlm_lock_remove_from_lru(struct ldlm_lock *lock);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 0ba1ac3..f39375c 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -644,8 +644,9 @@ static void ldlm_add_cp_work_item(struct ldlm_lock *lock,
  * adding function.
  * Must be called with lr_lock held.
  */
-void ldlm_add_ast_work_item(struct ldlm_lock *lock, struct ldlm_lock *new,
-			    struct list_head *work_list)
+static void ldlm_add_ast_work_item(struct ldlm_lock *lock,
+				   struct ldlm_lock *new,
+				   struct list_head *work_list)
 {
 	check_res_locked(lock->l_resource);
 	if (new)
-- 
2.1.0
