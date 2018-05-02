From: James Simmons <jsimmons@infradead.org>
Date: Wed,  2 May 2018 14:21:47 -0400
Subject: [lustre-devel] [PATCH 3/4] staging: lustre: obdclass: guarantee all
 keys filled
In-Reply-To: <1525285308-15347-1-git-send-email-jsimmons@infradead.org>
References: <1525285308-15347-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1525285308-15347-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Lai Siyao <lai.siyao@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, NeilBrown <neilb@suse.com>
Cc: Hongchao Zhang <hongchao.zhang@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Hongchao Zhang <hongchao.zhang@intel.com>

In keys_fill, the key_set_version could be changed after
the keys are filled, then the keys in this context won't
be refilled by the following lu_context_refill for its
version is equal to the current key_set_version.

In lu_context_refill, the key_set_version should be protected
before comparing it to version stored in the lu_context.

Signed-off-by: Hongchao Zhang <hongchao.zhang@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8346
Reviewed-on: https://review.whamcloud.com/26099
Reviewed-on: https://review.whamcloud.com/27448
Reviewed-on: https://review.whamcloud.com/27994
Reviewed-by: Patrick Farrell <paf@cray.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Mike Pershin <mike.pershin@intel.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/lu_object.c | 29 +++++++++++++++++++---
 1 file changed, 25 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 4e4dd58..8b507f1 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -1386,8 +1386,8 @@ void lu_context_key_degister(struct lu_context_key *key)
 
 	lu_context_key_quiesce(key);
 
-	++key_set_version;
 	write_lock(&lu_keys_guard);
+	++key_set_version;
 	key_fini(&lu_shrink_env.le_ctx, key->lct_index);
 
 	/**
@@ -1546,15 +1546,18 @@ void lu_context_key_quiesce(struct lu_context_key *key)
 
 		list_for_each_entry(ctx, &lu_context_remembered, lc_remember)
 			key_fini(ctx, key->lct_index);
-		write_unlock(&lu_keys_guard);
+
 		++key_set_version;
+		write_unlock(&lu_keys_guard);
 	}
 }
 
 void lu_context_key_revive(struct lu_context_key *key)
 {
+	write_lock(&lu_keys_guard);
 	key->lct_tags &= ~LCT_QUIESCENT;
 	++key_set_version;
+	write_unlock(&lu_keys_guard);
 }
 
 static void keys_fini(struct lu_context *ctx)
@@ -1573,6 +1576,7 @@ static void keys_fini(struct lu_context *ctx)
 
 static int keys_fill(struct lu_context *ctx)
 {
+	unsigned int pre_version;
 	unsigned int i;
 
 	/*
@@ -1586,8 +1590,10 @@ static int keys_fill(struct lu_context *ctx)
 	 */
 	read_lock(&lu_keys_guard);
 	atomic_inc(&lu_key_initing_cnt);
+	pre_version = key_set_version;
 	read_unlock(&lu_keys_guard);
 
+refill:
 	LINVRNT(ctx->lc_value);
 	for (i = 0; i < ARRAY_SIZE(lu_keys); ++i) {
 		struct lu_context_key *key;
@@ -1628,9 +1634,17 @@ static int keys_fill(struct lu_context *ctx)
 			if (key->lct_exit)
 				ctx->lc_tags |= LCT_HAS_EXIT;
 		}
-		ctx->lc_version = key_set_version;
 	}
+
+	read_lock(&lu_keys_guard);
+	if (pre_version != key_set_version) {
+		pre_version = key_set_version;
+		read_unlock(&lu_keys_guard);
+		goto refill;
+	}
+	ctx->lc_version = key_set_version;
 	atomic_dec(&lu_key_initing_cnt);
+	read_unlock(&lu_keys_guard);
 	return 0;
 }
 
@@ -1739,7 +1753,14 @@ void lu_context_exit(struct lu_context *ctx)
  */
 int lu_context_refill(struct lu_context *ctx)
 {
-	return likely(ctx->lc_version == key_set_version) ? 0 : keys_fill(ctx);
+	read_lock(&lu_keys_guard);
+	if (likely(ctx->lc_version == key_set_version)) {
+		read_unlock(&lu_keys_guard);
+		return 0;
+	}
+
+	read_unlock(&lu_keys_guard);
+	return keys_fill(ctx);
 }
 
 /**
-- 
1.8.3.1
