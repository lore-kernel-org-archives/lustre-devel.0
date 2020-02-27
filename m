From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:51 -0500
Subject: [lustre-devel] [PATCH 603/622] lnet: modules: use list_move were
 appropriate.
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-604-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

Rather than
  list_del(&foo);
  list_add(&foo, &bar);
use
  list_move(&foo, &bar);

Similarly for list_add_tail and list_move_tail.

In lnet_attach_rsp_tracker, local_rspt already has a suitably
initialised ->rspt_on_list, so the new_entry variable can
be discarded.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9679
Lustre-commit: 7525fd36a266 ("LU-9679 modules: use list_move were appropriate.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/36670
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index ca292a6..47d5389 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -4374,7 +4374,6 @@ void lnet_monitor_thr_stop(void)
 			struct lnet_libmd *md, struct lnet_handle_md mdh)
 {
 	s64 timeout_ns;
-	bool new_entry = true;
 	struct lnet_rsp_tracker *local_rspt;
 
 	/* MD has a refcount taken by message so it's not going away.
@@ -4391,7 +4390,6 @@ void lnet_monitor_thr_stop(void)
 		 * update the deadline on that one.
 		 */
 		lnet_rspt_free(rspt, cpt);
-		new_entry = false;
 	} else {
 		/* new md */
 		rspt->rspt_mdh = mdh;
@@ -4406,9 +4404,7 @@ void lnet_monitor_thr_stop(void)
 	 * list in order to expire all the older entries first.
 	 */
 	lnet_net_lock(cpt);
-	if (!new_entry && !list_empty(&local_rspt->rspt_on_list))
-		list_del_init(&local_rspt->rspt_on_list);
-	list_add_tail(&local_rspt->rspt_on_list, the_lnet.ln_mt_rstq[cpt]);
+	list_move_tail(&local_rspt->rspt_on_list, the_lnet.ln_mt_rstq[cpt]);
 	lnet_net_unlock(cpt);
 	lnet_res_unlock(cpt);
 }
-- 
1.8.3.1
