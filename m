From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:27:57 -0400
Subject: [lustre-devel] [PATCH 01/41] staging: lustre: obdclass: fix race
	during key quiescency
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bruno Faccini <bruno.faccini@intel.com>, James Simmons <jsimmons@infradead.org>

From: Bruno Faccini <bruno.faccini@intel.com>

Upon umount, presumably of last device using same OSD back-end,
to prepare for module unload, lu_context_key_quiesce() is run to
remove all module's key reference in any context linked on
lu_context_remembered list.
Threads must protect against such transversal processing when
exiting from its context.

Signed-off-by: Bruno Faccini <bruno.faccini@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5264
Reviewed-on: http://review.whamcloud.com/13103
Reviewed-by: Mike Pershin <mike.pershin@intel.com>
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/lu_object.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 054e567..f0e74c6 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -1663,6 +1663,9 @@ void lu_context_exit(struct lu_context *ctx)
 	ctx->lc_state = LCS_LEFT;
 	if (ctx->lc_tags & LCT_HAS_EXIT && ctx->lc_value) {
 		for (i = 0; i < ARRAY_SIZE(lu_keys); ++i) {
+			/* could race with key quiescency */
+			if (ctx->lc_tags & LCT_REMEMBER)
+				spin_lock(&lu_keys_guard);
 			if (ctx->lc_value[i]) {
 				struct lu_context_key *key;
 
@@ -1671,6 +1674,8 @@ void lu_context_exit(struct lu_context *ctx)
 					key->lct_exit(ctx,
 						      key, ctx->lc_value[i]);
 			}
+			if (ctx->lc_tags & LCT_REMEMBER)
+				spin_unlock(&lu_keys_guard);
 		}
 	}
 }
-- 
1.7.1
