From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:06:01 -0400
Subject: [lustre-devel] [PATCH 22/42] lnet: Fix reference leak in
 lnet_select_pathway
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-23-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <chris.horn@hpe.com>

We call lnet_nid2peerni_locked() to lookup the peer NI for the message
originator. lnet_nid2peerni_locked() takes a reference on the peer NI
that is never dropped.

Fixes: 92d8fb2620 ("lnet: Allow router to forward to healthier NID")
HPE-bug-id: LUS-9185
WC-bug-id: https://jira.whamcloud.com/browse/LU-13896
Lustre-commit: 3420cd6158cb0 ("LU-13896 lnet: Fix reference leak in lnet_select_pathway")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/39603
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index aa3f3ab..7474d44 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -2517,6 +2517,8 @@ struct lnet_ni *
 		 * try to send it via non-multi-rail criteria
 		 */
 		if (!IS_ERR(src_lpni)) {
+			/* Drop ref taken by lnet_nid2peerni_locked() */
+			lnet_peer_ni_decref_locked(src_lpni);
 			src_lp = lpni->lpni_peer_net->lpn_peer;
 			if (lnet_peer_is_multi_rail(src_lp) &&
 			    !lnet_is_peer_ni_alive(lpni))
-- 
1.8.3.1
