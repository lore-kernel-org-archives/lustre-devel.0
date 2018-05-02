From: James Simmons <jsimmons@infradead.org>
Date: Wed,  2 May 2018 14:21:46 -0400
Subject: [lustre-devel] [PATCH 2/4] staging: lustre: obdclass: hoist locking
 in lu_context_exit()
In-Reply-To: <1525285308-15347-1-git-send-email-jsimmons@infradead.org>
References: <1525285308-15347-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1525285308-15347-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Lai Siyao <lai.siyao@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, NeilBrown <neilb@suse.com>
Cc: "John L. Hammond" <john.hammond@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: "John L. Hammond" <john.hammond@intel.com>

Hoist lu_keys_guard locking out of the for loop in lu_context_exit().

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8918
Reviewed-on: https://review.whamcloud.com/24217
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/lu_object.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 04475e9..4e4dd58 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -1711,10 +1711,11 @@ void lu_context_exit(struct lu_context *ctx)
 	LINVRNT(ctx->lc_state == LCS_ENTERED);
 	ctx->lc_state = LCS_LEFT;
 	if (ctx->lc_tags & LCT_HAS_EXIT && ctx->lc_value) {
+		/* could race with key quiescency */
+		if (ctx->lc_tags & LCT_REMEMBER)
+			read_lock(&lu_keys_guard);
+
 		for (i = 0; i < ARRAY_SIZE(lu_keys); ++i) {
-			/* could race with key quiescency */
-			if (ctx->lc_tags & LCT_REMEMBER)
-				read_lock(&lu_keys_guard);
 			if (ctx->lc_value[i]) {
 				struct lu_context_key *key;
 
@@ -1723,9 +1724,10 @@ void lu_context_exit(struct lu_context *ctx)
 					key->lct_exit(ctx,
 						      key, ctx->lc_value[i]);
 			}
-			if (ctx->lc_tags & LCT_REMEMBER)
-				read_unlock(&lu_keys_guard);
 		}
+
+		if (ctx->lc_tags & LCT_REMEMBER)
+			read_unlock(&lu_keys_guard);
 	}
 }
 EXPORT_SYMBOL(lu_context_exit);
-- 
1.8.3.1
