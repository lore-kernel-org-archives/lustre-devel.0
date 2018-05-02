From: James Simmons <jsimmons@infradead.org>
Date: Wed,  2 May 2018 14:21:45 -0400
Subject: [lustre-devel] [PATCH 1/4] staging: lustre: obdclass: change
 spinlock of key to rwlock
In-Reply-To: <1525285308-15347-1-git-send-email-jsimmons@infradead.org>
References: <1525285308-15347-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1525285308-15347-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Lai Siyao <lai.siyao@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, NeilBrown <neilb@suse.com>
Cc: Gu Zheng <gzheng@ddn.com>, Li Xi <lixi@ddn.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Li Xi <lixi@ddn.com>

Most of the time, keys are never changed. So rwlock might be
better for the concurrency of key read.

Signed-off-by: Li Xi <lixi@ddn.com>
Signed-off-by: Gu Zheng <gzheng@ddn.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6800
Reviewed-on: http://review.whamcloud.com/15558
Reviewed-by: Faccini Bruno <bruno.faccini@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/lu_object.c | 38 +++++++++++-----------
 1 file changed, 19 insertions(+), 19 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index fa986f2..04475e9 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -1317,7 +1317,7 @@ enum {
 
 static struct lu_context_key *lu_keys[LU_CONTEXT_KEY_NR] = { NULL, };
 
-static DEFINE_SPINLOCK(lu_keys_guard);
+static DEFINE_RWLOCK(lu_keys_guard);
 static atomic_t lu_key_initing_cnt = ATOMIC_INIT(0);
 
 /**
@@ -1341,7 +1341,7 @@ int lu_context_key_register(struct lu_context_key *key)
 	LASSERT(key->lct_tags != 0);
 
 	result = -ENFILE;
-	spin_lock(&lu_keys_guard);
+	write_lock(&lu_keys_guard);
 	for (i = 0; i < ARRAY_SIZE(lu_keys); ++i) {
 		if (!lu_keys[i]) {
 			key->lct_index = i;
@@ -1353,7 +1353,7 @@ int lu_context_key_register(struct lu_context_key *key)
 			break;
 		}
 	}
-	spin_unlock(&lu_keys_guard);
+	write_unlock(&lu_keys_guard);
 	return result;
 }
 EXPORT_SYMBOL(lu_context_key_register);
@@ -1387,7 +1387,7 @@ void lu_context_key_degister(struct lu_context_key *key)
 	lu_context_key_quiesce(key);
 
 	++key_set_version;
-	spin_lock(&lu_keys_guard);
+	write_lock(&lu_keys_guard);
 	key_fini(&lu_shrink_env.le_ctx, key->lct_index);
 
 	/**
@@ -1395,18 +1395,18 @@ void lu_context_key_degister(struct lu_context_key *key)
 	 * run lu_context_key::lct_fini() method.
 	 */
 	while (atomic_read(&key->lct_used) > 1) {
-		spin_unlock(&lu_keys_guard);
+		write_unlock(&lu_keys_guard);
 		CDEBUG(D_INFO, "%s: \"%s\" %p, %d\n",
 		       __func__, module_name(key->lct_owner),
 		       key, atomic_read(&key->lct_used));
 		schedule();
-		spin_lock(&lu_keys_guard);
+		write_lock(&lu_keys_guard);
 	}
 	if (lu_keys[key->lct_index]) {
 		lu_keys[key->lct_index] = NULL;
 		lu_ref_fini(&key->lct_reference);
 	}
-	spin_unlock(&lu_keys_guard);
+	write_unlock(&lu_keys_guard);
 
 	LASSERTF(atomic_read(&key->lct_used) == 1,
 		 "key has instances: %d\n",
@@ -1526,7 +1526,7 @@ void lu_context_key_quiesce(struct lu_context_key *key)
 		/*
 		 * XXX memory barrier has to go here.
 		 */
-		spin_lock(&lu_keys_guard);
+		write_lock(&lu_keys_guard);
 		key->lct_tags |= LCT_QUIESCENT;
 
 		/**
@@ -1534,19 +1534,19 @@ void lu_context_key_quiesce(struct lu_context_key *key)
 		 * have completed.
 		 */
 		while (atomic_read(&lu_key_initing_cnt) > 0) {
-			spin_unlock(&lu_keys_guard);
+			write_unlock(&lu_keys_guard);
 			CDEBUG(D_INFO, "%s: \"%s\" %p, %d (%d)\n",
 			       __func__,
 			       module_name(key->lct_owner),
 			       key, atomic_read(&key->lct_used),
 			atomic_read(&lu_key_initing_cnt));
 			schedule();
-			spin_lock(&lu_keys_guard);
+			write_lock(&lu_keys_guard);
 		}
 
 		list_for_each_entry(ctx, &lu_context_remembered, lc_remember)
 			key_fini(ctx, key->lct_index);
-		spin_unlock(&lu_keys_guard);
+		write_unlock(&lu_keys_guard);
 		++key_set_version;
 	}
 }
@@ -1584,9 +1584,9 @@ static int keys_fill(struct lu_context *ctx)
 	 * An atomic_t variable is still used, in order not to reacquire the
 	 * lock when decrementing the counter.
 	 */
-	spin_lock(&lu_keys_guard);
+	read_lock(&lu_keys_guard);
 	atomic_inc(&lu_key_initing_cnt);
-	spin_unlock(&lu_keys_guard);
+	read_unlock(&lu_keys_guard);
 
 	LINVRNT(ctx->lc_value);
 	for (i = 0; i < ARRAY_SIZE(lu_keys); ++i) {
@@ -1655,9 +1655,9 @@ int lu_context_init(struct lu_context *ctx, __u32 tags)
 	ctx->lc_state = LCS_INITIALIZED;
 	ctx->lc_tags = tags;
 	if (tags & LCT_REMEMBER) {
-		spin_lock(&lu_keys_guard);
+		write_lock(&lu_keys_guard);
 		list_add(&ctx->lc_remember, &lu_context_remembered);
-		spin_unlock(&lu_keys_guard);
+		write_unlock(&lu_keys_guard);
 	} else {
 		INIT_LIST_HEAD(&ctx->lc_remember);
 	}
@@ -1683,10 +1683,10 @@ void lu_context_fini(struct lu_context *ctx)
 		keys_fini(ctx);
 
 	} else { /* could race with key degister */
-		spin_lock(&lu_keys_guard);
+		write_lock(&lu_keys_guard);
 		keys_fini(ctx);
 		list_del_init(&ctx->lc_remember);
-		spin_unlock(&lu_keys_guard);
+		write_unlock(&lu_keys_guard);
 	}
 }
 EXPORT_SYMBOL(lu_context_fini);
@@ -1714,7 +1714,7 @@ void lu_context_exit(struct lu_context *ctx)
 		for (i = 0; i < ARRAY_SIZE(lu_keys); ++i) {
 			/* could race with key quiescency */
 			if (ctx->lc_tags & LCT_REMEMBER)
-				spin_lock(&lu_keys_guard);
+				read_lock(&lu_keys_guard);
 			if (ctx->lc_value[i]) {
 				struct lu_context_key *key;
 
@@ -1724,7 +1724,7 @@ void lu_context_exit(struct lu_context *ctx)
 						      key, ctx->lc_value[i]);
 			}
 			if (ctx->lc_tags & LCT_REMEMBER)
-				spin_unlock(&lu_keys_guard);
+				read_unlock(&lu_keys_guard);
 		}
 	}
 }
-- 
1.8.3.1
