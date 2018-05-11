From: NeilBrown <neilb@suse.com>
Date: Fri, 11 May 2018 10:37:14 +1000
Subject: [lustre-devel] [PATCH 6/6] staging: lustre: rename lu_keys_guard to
 lu_context_remembered_guard
In-Reply-To: <152599874625.19824.11344372150811845854.stgit@noble>
References: <152599874625.19824.11344372150811845854.stgit@noble>
Message-ID: <152599903439.19824.15096621470698744468.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

The only remaining use of lu_keys_guard is to protect the
lu_context_remembers linked list, and always write_lock()
is used.
So rename it to reflect this, and change to a spinlock.
We move keys_fini() out of the locked region in
lu_context_fini() - once we have removed the context from
the lc_remembers list, there can no longer be a race.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/obdclass/lu_object.c |   22 +++++++++-----------
 1 file changed, 10 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 1c874781066d..688a0428262d 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -1321,7 +1321,6 @@ enum {
 
 static struct lu_context_key *lu_keys[LU_CONTEXT_KEY_NR] = { NULL, };
 
-static DEFINE_RWLOCK(lu_keys_guard);
 static DECLARE_RWSEM(lu_key_initing);
 
 /**
@@ -1508,6 +1507,7 @@ EXPORT_SYMBOL(lu_context_key_get);
  * List of remembered contexts. XXX document me.
  */
 static LIST_HEAD(lu_context_remembered);
+static DEFINE_SPINLOCK(lu_context_remembered_guard);
 
 /**
  * Destroy \a key in all remembered contexts. This is used to destroy key
@@ -1528,13 +1528,12 @@ void lu_context_key_quiesce(struct lu_context_key *key)
 		key->lct_tags |= LCT_QUIESCENT;
 		up_write(&lu_key_initing);
 
-		write_lock(&lu_keys_guard);
+		spin_lock(&lu_context_remembered_guard);
 		list_for_each_entry(ctx, &lu_context_remembered, lc_remember) {
 			spin_until_cond(READ_ONCE(ctx->lc_state) != LCS_LEAVING);
 			key_fini(ctx, key->lct_index);
 		}
-
-		write_unlock(&lu_keys_guard);
+		spin_unlock(&lu_context_remembered_guard);
 	}
 }
 
@@ -1640,9 +1639,9 @@ int lu_context_init(struct lu_context *ctx, __u32 tags)
 	ctx->lc_state = LCS_INITIALIZED;
 	ctx->lc_tags = tags;
 	if (tags & LCT_REMEMBER) {
-		write_lock(&lu_keys_guard);
+		spin_lock(&lu_context_remembered_guard);
 		list_add(&ctx->lc_remember, &lu_context_remembered);
-		write_unlock(&lu_keys_guard);
+		spin_unlock(&lu_context_remembered_guard);
 	} else {
 		INIT_LIST_HEAD(&ctx->lc_remember);
 	}
@@ -1665,14 +1664,13 @@ void lu_context_fini(struct lu_context *ctx)
 
 	if ((ctx->lc_tags & LCT_REMEMBER) == 0) {
 		LASSERT(list_empty(&ctx->lc_remember));
-		keys_fini(ctx);
-
-	} else { /* could race with key degister */
-		write_lock(&lu_keys_guard);
-		keys_fini(ctx);
+	} else {
+		/* could race with key degister */
+		spin_lock(&lu_context_remembered_guard);
 		list_del_init(&ctx->lc_remember);
-		write_unlock(&lu_keys_guard);
+		spin_unlock(&lu_context_remembered_guard);
 	}
+	keys_fini(ctx);
 }
 EXPORT_SYMBOL(lu_context_fini);
 
