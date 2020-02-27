From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:37 -0500
Subject: [lustre-devel] [PATCH 529/622] lustre: lov: use wait_event() in
 lov_subobject_kill()
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-530-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

lov_subobject_kill() has an open-coded version
of wait_event(). Change it to use the macro.

There is no need to take a spinlock just to check if a variable
have changed value. If there was, the first test would be protected too.

"lti_waiter" now has no users and can be removed from lov_thread_info.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10467
Lustre-commit: c0894d1d32670 ("LU-10467 lov: use wait_event() in lov_subobject_kill()")
Signed-off-by: NeilBrown <neilb@suse.com>
Reviewed-on: https://review.whamcloud.com/36343
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_cl_internal.h |  1 -
 fs/lustre/lov/lov_object.c      | 24 +-----------------------
 2 files changed, 1 insertion(+), 24 deletions(-)

diff --git a/fs/lustre/lov/lov_cl_internal.h b/fs/lustre/lov/lov_cl_internal.h
index 8791e69..e21439d 100644
--- a/fs/lustre/lov/lov_cl_internal.h
+++ b/fs/lustre/lov/lov_cl_internal.h
@@ -474,7 +474,6 @@ struct lov_thread_info {
 	struct ost_lvb		lti_lvb;
 	struct cl_2queue	lti_cl2q;
 	struct cl_page_list     lti_plist;
-	wait_queue_entry_t	lti_waiter;
 };
 
 /**
diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index f2c7bc2..2a35993 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -287,7 +287,6 @@ static void lov_subobject_kill(const struct lu_env *env, struct lov_object *lov,
 	struct cl_object *sub;
 	struct lu_site *site;
 	wait_queue_head_t *wq;
-	wait_queue_entry_t *waiter;
 
 	LASSERT(r0->lo_sub[idx] == los);
 
@@ -303,28 +302,7 @@ static void lov_subobject_kill(const struct lu_env *env, struct lov_object *lov,
 	/* ... wait until it is actually destroyed---sub-object clears its
 	 * ->lo_sub[] slot in lovsub_object_free()
 	 */
-	if (r0->lo_sub[idx] == los) {
-		waiter = &lov_env_info(env)->lti_waiter;
-		init_waitqueue_entry(waiter, current);
-		add_wait_queue(wq, waiter);
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		while (1) {
-			/* this wait-queue is signaled at the end of
-			 * lu_object_free().
-			 */
-			set_current_state(TASK_UNINTERRUPTIBLE);
-			spin_lock(&r0->lo_sub_lock);
-			if (r0->lo_sub[idx] == los) {
-				spin_unlock(&r0->lo_sub_lock);
-				schedule();
-			} else {
-				spin_unlock(&r0->lo_sub_lock);
-				set_current_state(TASK_RUNNING);
-				break;
-			}
-		}
-		remove_wait_queue(wq, waiter);
-	}
+	wait_event(*wq, r0->lo_sub[idx] != los);
 	LASSERT(!r0->lo_sub[idx]);
 }
 
-- 
1.8.3.1
