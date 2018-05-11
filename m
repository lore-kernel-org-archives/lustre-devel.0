From: NeilBrown <neilb@suse.com>
Date: Fri, 11 May 2018 10:37:14 +1000
Subject: [lustre-devel] [PATCH 1/6] staging: lustre: make key_set_version an
 atomic_t
In-Reply-To: <152599874625.19824.11344372150811845854.stgit@noble>
References: <152599874625.19824.11344372150811845854.stgit@noble>
Message-ID: <152599903422.19824.6448081685151609850.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

As a first step to simplifying the locking in lu_object.c,
change key_set_version to an atomic_t.  This will mean
we don't need to hold a spinlock when incrementing.

It is clear that keys_fill() (and so lu_context_refill())
cannot race with itself as it holds no locks for the main
part of the work.  So updates to lc_version, and testing of
that value cannot need locking either.
So remove the locking from keys_fill() and lu_context_refill()
as there is no longer anything to protect.  The locking around
lu_keys_initing_cnt is preserved for now.

Also, don't increment when deregistering or quiescing a key.
key_set_version is *only* use to avoid filling new key values
if there have been no changes to the set of key.
Deregistering a key does not mean that we need to try filling
any new value, so the increment is pointless.

Finally, remove the refill loop in keys_fill().  If a key
is registered or revived while keys_fill() is running it must be safe
to ignore it just as we would if it was registered immediately
after keys_fill() ran.  The important thing is that the
keys_set_version stored in ctx->lc_version must be sampled
*before* those unseen keys were added.
So sample keys_set_version early.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/obdclass/lu_object.c |   26 ++++----------------
 1 file changed, 5 insertions(+), 21 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index f14e3509f059..b38adf75e8e4 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -1329,7 +1329,7 @@ static atomic_t lu_key_initing_cnt = ATOMIC_INIT(0);
  * lu_context_refill(). No locking is provided, as initialization and shutdown
  * are supposed to be externally serialized.
  */
-static unsigned int key_set_version;
+static atomic_t key_set_version = ATOMIC_INIT(0);
 
 /**
  * Register new key.
@@ -1352,7 +1352,7 @@ int lu_context_key_register(struct lu_context_key *key)
 			lu_keys[i] = key;
 			lu_ref_init(&key->lct_reference);
 			result = 0;
-			++key_set_version;
+			atomic_inc(&key_set_version);
 			break;
 		}
 	}
@@ -1390,7 +1390,6 @@ void lu_context_key_degister(struct lu_context_key *key)
 	lu_context_key_quiesce(key);
 
 	write_lock(&lu_keys_guard);
-	++key_set_version;
 	key_fini(&lu_shrink_env.le_ctx, key->lct_index);
 
 	/**
@@ -1550,7 +1549,6 @@ void lu_context_key_quiesce(struct lu_context_key *key)
 		list_for_each_entry(ctx, &lu_context_remembered, lc_remember)
 			key_fini(ctx, key->lct_index);
 
-		++key_set_version;
 		write_unlock(&lu_keys_guard);
 	}
 }
@@ -1559,7 +1557,7 @@ void lu_context_key_revive(struct lu_context_key *key)
 {
 	write_lock(&lu_keys_guard);
 	key->lct_tags &= ~LCT_QUIESCENT;
-	++key_set_version;
+	atomic_inc(&key_set_version);
 	write_unlock(&lu_keys_guard);
 }
 
@@ -1579,7 +1577,6 @@ static void keys_fini(struct lu_context *ctx)
 
 static int keys_fill(struct lu_context *ctx)
 {
-	unsigned int pre_version;
 	unsigned int i;
 
 	/*
@@ -1593,10 +1590,9 @@ static int keys_fill(struct lu_context *ctx)
 	 */
 	read_lock(&lu_keys_guard);
 	atomic_inc(&lu_key_initing_cnt);
-	pre_version = key_set_version;
 	read_unlock(&lu_keys_guard);
+	ctx->lc_version = atomic_read(&key_set_version);
 
-refill:
 	LINVRNT(ctx->lc_value);
 	for (i = 0; i < ARRAY_SIZE(lu_keys); ++i) {
 		struct lu_context_key *key;
@@ -1639,15 +1635,7 @@ static int keys_fill(struct lu_context *ctx)
 		}
 	}
 
-	read_lock(&lu_keys_guard);
-	if (pre_version != key_set_version) {
-		pre_version = key_set_version;
-		read_unlock(&lu_keys_guard);
-		goto refill;
-	}
-	ctx->lc_version = key_set_version;
 	atomic_dec(&lu_key_initing_cnt);
-	read_unlock(&lu_keys_guard);
 	return 0;
 }
 
@@ -1756,13 +1744,9 @@ EXPORT_SYMBOL(lu_context_exit);
  */
 int lu_context_refill(struct lu_context *ctx)
 {
-	read_lock(&lu_keys_guard);
-	if (likely(ctx->lc_version == key_set_version)) {
-		read_unlock(&lu_keys_guard);
+	if (likely(ctx->lc_version == atomic_read(&key_set_version)))
 		return 0;
-	}
 
-	read_unlock(&lu_keys_guard);
 	return keys_fill(ctx);
 }
 
