From: Imre Deak <imre.deak@intel.com>
Date: Sat, 24 Sep 2016 04:11:37 +0300
Subject: [lustre-devel] [PATCH] staging: lustre: ldlm: Fix extern variable
	declaration
Message-ID: <1474679497-31549-1-git-send-email-imre.deak@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Imre Deak <imre.deak@gmail.com>

Move the extern declaration to a header file common to all users of the
variable. This fixes the following sparse warning:
symbol 'ldlm_cancel_unused_locks_before_replay' was not declared.
Should it be static?

Signed-off-by: Imre Deak <imre.deak@gmail.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h | 1 +
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    | 2 --
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index 6536832..5e82cfc 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -103,6 +103,7 @@ int ldlm_cancel_lru_local(struct ldlm_namespace *ns,
 			  struct list_head *cancels, int count, int max,
 			  enum ldlm_cancel_flags cancel_flags, int flags);
 extern unsigned int ldlm_enqueue_min;
+extern unsigned int ldlm_cancel_unused_locks_before_replay;
 
 /* ldlm_resource.c */
 int ldlm_resource_putref_locked(struct ldlm_resource *res);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index ff2c28e..fde697e 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -877,8 +877,6 @@ void ldlm_put_ref(void)
 }
 EXPORT_SYMBOL(ldlm_put_ref);
 
-extern unsigned int ldlm_cancel_unused_locks_before_replay;
-
 static ssize_t cancel_unused_locks_before_replay_show(struct kobject *kobj,
 						      struct attribute *attr,
 						      char *buf)
-- 
2.5.0
