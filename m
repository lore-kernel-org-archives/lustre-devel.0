From: NeilBrown <neilb@suse.com>
Date: Wed, 24 Oct 2018 09:34:17 +1100
Subject: [lustre-devel] [PATCH] lustre: lu_object: fix possible hang waiting
 for LCS_LEAVING
In-Reply-To: <878t2q8unf.fsf@notabene.neil.brown.name>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
 <878t2q8unf.fsf@notabene.neil.brown.name>
Message-ID: <87d0s070nq.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


As lu_context_key_quiesce() spins waiting for LCS_LEAVING to
change, it is important the we set and then clear in within a
non-preemptible region.  If the thread that spins pre-empty the
thread that sets-and-clears the state while the state is LCS_LEAVING,
then it can spin indefinitely, particularly on a single-CPU machine.

Also update the comment to explain this dependency.

Fixes: ac3f8fd6e61b ("staging: lustre: remove locking from lu_context_exit()")
---

This is the cause of the "something" that went wrong in my recent
testing that I mentioned.  I wonder if preempt_enable() has recently
been enhanced to encourage a preempt, to make this sort of bug easier to
see.


 drivers/staging/lustre/lustre/obdclass/lu_object.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index cb57abf03644..51497c144dd6 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -1654,17 +1654,20 @@ void lu_context_exit(struct lu_context *ctx)
 	unsigned int i;
 
 	LINVRNT(ctx->lc_state == LCS_ENTERED);
-	/*
-	 * Ensure lu_context_key_quiesce() sees LCS_LEAVING
-	 * or we see LCT_QUIESCENT
-	 */
-	smp_store_mb(ctx->lc_state, LCS_LEAVING);
 	/*
 	 * Disable preempt to ensure we get a warning if
 	 * any lct_exit ever tries to sleep.  That would hurt
 	 * lu_context_key_quiesce() which spins waiting for us.
+	 * This also ensure we aren't preempted while the state
+	 * is LCS_LEAVING, as that too would cause problems for
+	 * lu_context_key_quiesce().
 	 */
 	preempt_disable();
+	/*
+	 * Ensure lu_context_key_quiesce() sees LCS_LEAVING
+	 * or we see LCT_QUIESCENT
+	 */
+	smp_store_mb(ctx->lc_state, LCS_LEAVING);
 	if (ctx->lc_tags & LCT_HAS_EXIT && ctx->lc_value) {
 		for (i = 0; i < ARRAY_SIZE(lu_keys); ++i) {
 			struct lu_context_key *key;
@@ -1677,8 +1680,8 @@ void lu_context_exit(struct lu_context *ctx)
 		}
 	}
 
-	preempt_enable();
 	smp_store_release(&ctx->lc_state, LCS_LEFT);
+	preempt_enable();
 }
 EXPORT_SYMBOL(lu_context_exit);
 
-- 
2.14.0.rc0.dirty

-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181024/a789b872/attachment.sig>
