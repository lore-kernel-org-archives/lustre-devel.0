From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:13 -0500
Subject: [lustre-devel] [PATCH 565/622] lnet: fix rspt counter
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-566-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexey Lyashkov <c17817@cray.com>

rsp entries must freed via lnet_rspt_free function to avoid counter
leak. handle NULL allocation properly.

Cray-bug-id: LUS-8189
WC-bug-id: https://jira.whamcloud.com/browse/LU-12991
Lustre-commit: 027a4722b26d ("LU-12991 lnet: fix rspt counter")
Signed-off-by: Alexey Lyashkov <c17817@cray.com>
Reviewed-on: https://review.whamcloud.com/36895
Reviewed-by: Alexandr Boyko <c17825@cray.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h | 8 +++++---
 net/lnet/lnet/lib-move.c      | 6 +++---
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 56556fd..3b597e3 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -438,9 +438,11 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 	struct lnet_rsp_tracker *rspt;
 
 	rspt = kzalloc(sizeof(*rspt), GFP_NOFS);
-	lnet_net_lock(cpt);
-	the_lnet.ln_counters[cpt]->lct_health.lch_rst_alloc++;
-	lnet_net_unlock(cpt);
+	if (rspt) {
+		lnet_net_lock(cpt);
+		the_lnet.ln_counters[cpt]->lct_health.lch_rst_alloc++;
+		lnet_net_unlock(cpt);
+	}
 	return rspt;
 }
 
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index da73009..73f9d20 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -4390,7 +4390,7 @@ void lnet_monitor_thr_stop(void)
 		/* we already have an rspt attached to the md, so we'll
 		 * update the deadline on that one.
 		 */
-		kfree(rspt);
+		lnet_rspt_free(rspt, cpt);
 		new_entry = false;
 	} else {
 		/* new md */
@@ -4511,7 +4511,7 @@ void lnet_monitor_thr_stop(void)
 			       md->md_me->me_portal);
 		lnet_res_unlock(cpt);
 
-		kfree(rspt);
+		lnet_rspt_free(rspt, cpt);
 		kfree(msg);
 		return -ENOENT;
 	}
@@ -4745,7 +4745,7 @@ struct lnet_msg *
 		lnet_res_unlock(cpt);
 
 		kfree(msg);
-		kfree(rspt);
+		lnet_rspt_free(rspt, cpt);
 		return -ENOENT;
 	}
 
-- 
1.8.3.1
