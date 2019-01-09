From: NeilBrown <neilb@suse.com>
Date: Wed, 09 Jan 2019 17:24:01 +1100
Subject: [lustre-devel] [PATCH 03/29] lustre: osc: simplify osc_extent_wait()
In-Reply-To: <154701488711.26726.17363928508883972338.stgit@noble>
References: <154701488711.26726.17363928508883972338.stgit@noble>
Message-ID: <154701504111.26726.7861020038366907898.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Taking a spinlock to check the current value of the state is
unnecessary.
The wake_up() and wait_event() calls have sufficient barriers
to ensure that the value will be seen and the wait will abort
properly.

In most cases, osc_extent_wait() is followed by osc_object_lock()
before any shared data is touched - in those cases there is no need
for osc_extent_wait() to wait for the spinlock to be released.

The one case where osc_object_lock() does not immediately follow is
in osc_cache_truncate_start().  The extra locking was introduced in a
patch which fixed a problem with truncation, so it is likely that this
is the call that was thought to be relevant.
In that case, following osc_extent_wait(), an extent that had been
detached from the per-object list (oe_link linkage) and proceeds to
work on it without any locking.
In this case the code is waiting for OES_TRUNC, so any changes that
happen after the osc_extent_state_set(ext, OES_TRUNC) and when the
lock is dropped, might not be seen by the woken code.
The only thing changed is ->oe_trunc_pending, and the woken code
doesn't look at that.

The only remaining possible need for extra synchronization is if some
other value was changed before the wakeup and is needed after the
wait.  According to memory-barriers.txt, a barrier might be needed
to ensure that is visible.  Such a barrier is most clearly presented
by used smp_store_release() to set the state before wakeup, and
smp_load_acquire() to view it after waiting.

Also use a simple wake_up() instead of wake_up_all() - the latter is
only needed when exclusive waiting is being used.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c |   22 +++++++---------------
 1 file changed, 7 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 1ce9f673f1bf..00056dffceb9 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -345,8 +345,8 @@ static void osc_extent_state_set(struct osc_extent *ext, int state)
 	/* LASSERT(sanity_check_nolock(ext) == 0); */
 
 	/* TODO: validate the state machine */
-	ext->oe_state = state;
-	wake_up_all(&ext->oe_waitq);
+	smp_store_release(&ext->oe_state, state);
+	wake_up(&ext->oe_waitq);
 }
 
 static struct osc_extent *osc_extent_alloc(struct osc_object *obj)
@@ -948,17 +948,6 @@ int osc_extent_finish(const struct lu_env *env, struct osc_extent *ext,
 	return 0;
 }
 
-static int extent_wait_cb(struct osc_extent *ext, enum osc_extent_state state)
-{
-	int ret;
-
-	osc_object_lock(ext->oe_obj);
-	ret = ext->oe_state == state;
-	osc_object_unlock(ext->oe_obj);
-
-	return ret;
-}
-
 /**
  * Wait for the extent's state to become @state.
  */
@@ -989,13 +978,16 @@ static int osc_extent_wait(const struct lu_env *env, struct osc_extent *ext,
 
 	/* wait for the extent until its state becomes @state */
 	rc = wait_event_idle_timeout(ext->oe_waitq,
-				     extent_wait_cb(ext, state), 600 * HZ);
+				     smp_load_acquire(&ext->oe_state) == state,
+				     600 * HZ);
 	if (rc == 0) {
 		OSC_EXTENT_DUMP(D_ERROR, ext,
 				"%s: wait ext to %u timedout, recovery in progress?\n",
 				cli_name(osc_cli(obj)), state);
 
-		wait_event_idle(ext->oe_waitq, extent_wait_cb(ext, state));
+		wait_event_idle(ext->oe_waitq,
+				smp_load_acquire(&ext->oe_state) == state);
+
 	}
 	if (ext->oe_rc < 0)
 		rc = ext->oe_rc;
