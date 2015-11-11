From: Shivani Bhardwaj <shivanib134@gmail.com>
Date: Wed, 11 Nov 2015 15:51:46 +0530
Subject: [lustre-devel] [PATCH] staging: lustre: cl_lock: Remove
	cl_lock_lockdep_init wrapper
Message-ID: <1447237306-46901-1-git-send-email-shivanib134@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Remove the wrapper function cl_lock_lockdep_init() and replace its only
call with the function it wrapped.

Signed-off-by: Shivani Bhardwaj <shivanib134@gmail.com>
---
 drivers/staging/lustre/lustre/obdclass/cl_lock.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/cl_lock.c b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
index 1836dc0..813d0ab 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_lock.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
@@ -147,11 +147,6 @@ static void cl_lock_trace0(int level, const struct lu_env *env,
 #ifdef CONFIG_LOCKDEP
 static struct lock_class_key cl_lock_key;
 
-static void cl_lock_lockdep_init(struct cl_lock *lock)
-{
-	lockdep_set_class_and_name(lock, &cl_lock_key, "EXT");
-}
-
 static void cl_lock_lockdep_acquire(const struct lu_env *env,
 				    struct cl_lock *lock, __u32 enqflags)
 {
@@ -381,7 +376,7 @@ static struct cl_lock *cl_lock_alloc(const struct lu_env *env,
 		CS_LOCKSTATE_INC(obj, CLS_NEW);
 		CS_LOCK_INC(obj, total);
 		CS_LOCK_INC(obj, create);
-		cl_lock_lockdep_init(lock);
+		lockdep_set_class_and_name(lock, &cl_lock_key, "EXT");
 		list_for_each_entry(obj, &head->loh_layers,
 					co_lu.lo_linkage) {
 			int err;
-- 
2.1.0
