From: NeilBrown <neilb@suse.com>
Date: Fri, 11 May 2018 10:37:14 +1000
Subject: [lustre-devel] [PATCH 2/6] staging: lustre: use an rwsem instead of
 lu_key_initing_cnt.
In-Reply-To: <152599874625.19824.11344372150811845854.stgit@noble>
References: <152599874625.19824.11344372150811845854.stgit@noble>
Message-ID: <152599903427.19824.5140207718686100721.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

The main use of lu_key_initing_cnt is to wait for it to be zero, so
that lu_context_key_quiesce() can continue.  This is a lot
like the behavior of a semaphore.

So use an rwsem instead.

When keys_fill() calls down_read() it will opportunistically spin
while the writer is running.  As the writer is very short - just
setting a bit for keys_fill() to see, this is likey to always
be the case.
lu_context_key_quiesce() will now, if necessary, go to sleep until
woken, rather than spin repeatedly calling schedule.

Code is much more readable this way and lu_keys_guard is no longer
involved in this locking.

We can remove the write_lock from lu_context_key_revive() as there is
nothing to protect against.  This already mustn't race with
lu_context_key_quiesce(), and if keys_fill() runs concurrently and
doesn't see that LCT_QUIESCENT has been cleared, it hardly matters.
After it is cleared, lu_context_refill() will need to be run anyway.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/obdclass/lu_object.c |   53 +++++++-------------
 1 file changed, 18 insertions(+), 35 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index b38adf75e8e4..2f7a2589e508 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -1321,7 +1321,7 @@ enum {
 static struct lu_context_key *lu_keys[LU_CONTEXT_KEY_NR] = { NULL, };
 
 static DEFINE_RWLOCK(lu_keys_guard);
-static atomic_t lu_key_initing_cnt = ATOMIC_INIT(0);
+static DECLARE_RWSEM(lu_key_initing);
 
 /**
  * Global counter incremented whenever key is registered, unregistered,
@@ -1526,39 +1526,25 @@ void lu_context_key_quiesce(struct lu_context_key *key)
 
 	if (!(key->lct_tags & LCT_QUIESCENT)) {
 		/*
-		 * XXX memory barrier has to go here.
+		 * The write-lock on lu_key_initing will ensure that any
+		 * keys_fill() which didn't see LCT_QUIESCENT will have
+		 * finished before we call key_fini().
 		 */
-		write_lock(&lu_keys_guard);
+		down_write(&lu_key_initing);
 		key->lct_tags |= LCT_QUIESCENT;
+		up_write(&lu_key_initing);
 
-		/**
-		 * Wait until all lu_context_key::lct_init() methods
-		 * have completed.
-		 */
-		while (atomic_read(&lu_key_initing_cnt) > 0) {
-			write_unlock(&lu_keys_guard);
-			CDEBUG(D_INFO, "%s: \"%s\" %p, %d (%d)\n",
-			       __func__,
-			       module_name(key->lct_owner),
-			       key, atomic_read(&key->lct_used),
-			atomic_read(&lu_key_initing_cnt));
-			schedule();
-			write_lock(&lu_keys_guard);
-		}
-
+		write_lock(&lu_keys_guard);
 		list_for_each_entry(ctx, &lu_context_remembered, lc_remember)
 			key_fini(ctx, key->lct_index);
-
 		write_unlock(&lu_keys_guard);
 	}
 }
 
 void lu_context_key_revive(struct lu_context_key *key)
 {
-	write_lock(&lu_keys_guard);
 	key->lct_tags &= ~LCT_QUIESCENT;
 	atomic_inc(&key_set_version);
-	write_unlock(&lu_keys_guard);
 }
 
 static void keys_fini(struct lu_context *ctx)
@@ -1578,19 +1564,16 @@ static void keys_fini(struct lu_context *ctx)
 static int keys_fill(struct lu_context *ctx)
 {
 	unsigned int i;
+	int rc = 0;
 
 	/*
-	 * A serialisation with lu_context_key_quiesce() is needed, but some
-	 * "key->lct_init()" are calling kernel memory allocation routine and
-	 * can't be called while holding a spin_lock.
-	 * "lu_keys_guard" is held while incrementing "lu_key_initing_cnt"
-	 * to ensure the start of the serialisation.
-	 * An atomic_t variable is still used, in order not to reacquire the
-	 * lock when decrementing the counter.
+	 * A serialisation with lu_context_key_quiesce() is needed, to
+	 * ensure we see LCT_QUIESCENT and don't allocate a new value
+	 * after it freed one.  The rwsem provides this.  As down_read()
+	 * does optimistic spinning while the writer is active, this is
+	 * unlikely to ever sleep.
 	 */
-	read_lock(&lu_keys_guard);
-	atomic_inc(&lu_key_initing_cnt);
-	read_unlock(&lu_keys_guard);
+	down_read(&lu_key_initing);
 	ctx->lc_version = atomic_read(&key_set_version);
 
 	LINVRNT(ctx->lc_value);
@@ -1618,8 +1601,8 @@ static int keys_fill(struct lu_context *ctx)
 
 			value = key->lct_init(ctx, key);
 			if (unlikely(IS_ERR(value))) {
-				atomic_dec(&lu_key_initing_cnt);
-				return PTR_ERR(value);
+				rc = PTR_ERR(value);
+				break;
 			}
 
 			lu_ref_add_atomic(&key->lct_reference, "ctx", ctx);
@@ -1635,8 +1618,8 @@ static int keys_fill(struct lu_context *ctx)
 		}
 	}
 
-	atomic_dec(&lu_key_initing_cnt);
-	return 0;
+	up_read(&lu_key_initing);
+	return rc;
 }
 
 static int keys_init(struct lu_context *ctx)
