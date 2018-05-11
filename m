From: NeilBrown <neilb@suse.com>
Date: Fri, 11 May 2018 10:37:14 +1000
Subject: [lustre-devel] [PATCH 3/6] staging: lustre: remove locking from
 lu_context_exit()
In-Reply-To: <152599874625.19824.11344372150811845854.stgit@noble>
References: <152599874625.19824.11344372150811845854.stgit@noble>
Message-ID: <152599903431.19824.12215038963445376774.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Recent patches suggest that the locking in lu_context_exit() hurts
performance as the changes that make are to improve performance.
Let's go all the way and remove the locking completely.

The race of interest is between lu_context_exit() finalizing a
value with ->lct_exit, and lu_context_key_quiesce() freeing
the value with key_fini().

If lu_context_key_quiesce() has started, there is no need to
finalize the value - it can just be freed.  So lu_context_exit()
is changed to skip the call to ->lcu_exit if LCT_QUIESCENT it set.

If lc_context_exit() has started, lu_context_key_quiesce() must wait
for it to complete - it cannot just skip the freeing.  To allow
this we introduce a new lc_state, LCS_LEAVING.  This indicates that
->lcu_exit might be called.  Before calling key_fini() on a context,
lu_context_key_quiesce() waits (spinning) for lc_state to move on from
LCS_LEAVING.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/lu_object.h  |    1 
 drivers/staging/lustre/lustre/obdclass/lu_object.c |   41 ++++++++++++--------
 2 files changed, 26 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index f29bbca5af65..4153db762518 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -881,6 +881,7 @@ enum lu_xattr_flags {
 enum lu_context_state {
 	LCS_INITIALIZED = 1,
 	LCS_ENTERED,
+	LCS_LEAVING,
 	LCS_LEFT,
 	LCS_FINALIZED
 };
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 2f7a2589e508..7bcf5ee47e04 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -44,6 +44,7 @@
 #include <linux/libcfs/libcfs.h>
 
 #include <linux/module.h>
+#include <linux/processor.h>
 
 /* hash_long() */
 #include <linux/libcfs/libcfs_hash.h>
@@ -1535,8 +1536,11 @@ void lu_context_key_quiesce(struct lu_context_key *key)
 		up_write(&lu_key_initing);
 
 		write_lock(&lu_keys_guard);
-		list_for_each_entry(ctx, &lu_context_remembered, lc_remember)
+		list_for_each_entry(ctx, &lu_context_remembered, lc_remember) {
+			spin_until_cond(READ_ONCE(ctx->lc_state) != LCS_LEAVING);
 			key_fini(ctx, key->lct_index);
+		}
+
 		write_unlock(&lu_keys_guard);
 	}
 }
@@ -1697,26 +1701,31 @@ void lu_context_exit(struct lu_context *ctx)
 	unsigned int i;
 
 	LINVRNT(ctx->lc_state == LCS_ENTERED);
-	ctx->lc_state = LCS_LEFT;
+	/*
+	 * Ensure lu_context_key_quiesce() sees LCS_LEAVING
+	 * or we see LCT_QUIESCENT
+	 */
+	smp_store_mb(ctx->lc_state, LCS_LEAVING);
+	/*
+	 * Disable preempt to ensure we get a warning if
+	 * any lct_exit ever tries to sleep.  That would hurt
+	 * lu_context_key_quiesce() which spins waiting for us.
+	 */
+	preempt_disable();
 	if (ctx->lc_tags & LCT_HAS_EXIT && ctx->lc_value) {
-		/* could race with key quiescency */
-		if (ctx->lc_tags & LCT_REMEMBER)
-			read_lock(&lu_keys_guard);
-
 		for (i = 0; i < ARRAY_SIZE(lu_keys); ++i) {
-			if (ctx->lc_value[i]) {
-				struct lu_context_key *key;
+			struct lu_context_key *key;
 
-				key = lu_keys[i];
-				if (key->lct_exit)
-					key->lct_exit(ctx,
-						      key, ctx->lc_value[i]);
-			}
+			key = lu_keys[i];
+			if (ctx->lc_value[i] &&
+			    !(key->lct_tags & LCT_QUIESCENT) &&
+			    key->lct_exit)
+				key->lct_exit(ctx, key, ctx->lc_value[i]);
 		}
-
-		if (ctx->lc_tags & LCT_REMEMBER)
-			read_unlock(&lu_keys_guard);
 	}
+
+	preempt_enable();
+	smp_store_release(&ctx->lc_state, LCS_LEFT);
 }
 EXPORT_SYMBOL(lu_context_exit);
 
