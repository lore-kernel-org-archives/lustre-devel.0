From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:40 -0500
Subject: [lustre-devel] [PATCH 592/622] lnet: peer lookup handle shutdown
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-593-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

When LNet is shutting down, looking up peer_nis shouldn't assert
but return NULL. Callers handle NULL return

WC-bug-id: https://jira.whamcloud.com/browse/LU-13049
Lustre-commit: f46b22aa6a28 ("LU-13049 lnet: peer lookup handle shutdown")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/36925
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/peer.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index b168c97..f987fff 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -647,7 +647,8 @@ void lnet_peer_uninit(void)
 	struct list_head *peers;
 	struct lnet_peer_ni *lp;
 
-	LASSERT(the_lnet.ln_state == LNET_STATE_RUNNING);
+	if (the_lnet.ln_state != LNET_STATE_RUNNING)
+		return NULL;
 
 	peers = &ptable->pt_hash[lnet_nid2peerhash(nid)];
 	list_for_each_entry(lp, peers, lpni_hashlist) {
-- 
1.8.3.1
