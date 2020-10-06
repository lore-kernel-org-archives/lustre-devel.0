From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:05:51 -0400
Subject: [lustre-devel] [PATCH 12/42] lnet: Do not set preferred NI for MR
 peer
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <chris.horn@hpe.com>

The preferred NI exists to ensure that a consistent source address is
used when communicating with a non-multi-rail peer. We needn't ever
set a preferred NI for a MR peer.

HPE-bug-id: LUS-9058
WC-bug-id: https://jira.whamcloud.com/browse/LU-13736
Lustre-commit: 4596ea5c247c9 ("LU-13736 lnet: Do not set preferred NI for MR peer")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/39229
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index f521817..cf14f32 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1615,7 +1615,8 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 lnet_set_non_mr_pref_nid(struct lnet_peer_ni *lpni, struct lnet_ni *lni,
 			 struct lnet_msg *msg)
 {
-	if (!lnet_msg_is_response(msg) && lpni->lpni_pref_nnids == 0) {
+	if (!lnet_peer_is_multi_rail(lpni->lpni_peer_net->lpn_peer) &&
+	    !lnet_msg_is_response(msg) && lpni->lpni_pref_nnids == 0) {
 		CDEBUG(D_NET, "Setting preferred local NID %s on NMR peer %s\n",
 		       libcfs_nid2str(lni->ni_nid),
 		       libcfs_nid2str(lpni->lpni_nid));
-- 
1.8.3.1
