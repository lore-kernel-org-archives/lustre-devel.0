From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:17 -0500
Subject: [lustre-devel] [PATCH 389/622] lnet: honor discovery setting
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-390-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

If discovery is off do not push out any updates. This could be
triggered in case of a gateway's interface changing.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12423
Lustre-commit: a06b656639c4 ("LU-12423 lnet: honor discovery setting")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35192
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/peer.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index e33dc0e..b0ca1de 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -877,6 +877,8 @@ struct lnet_peer_ni *
 	int cpt;
 
 	lnet_net_lock(LNET_LOCK_EX);
+	if (lnet_peer_discovery_disabled)
+		force = 0;
 	lncpt = cfs_percpt_number(the_lnet.ln_peer_tables);
 	for (cpt = 0; cpt < lncpt; cpt++) {
 		ptable = the_lnet.ln_peer_tables[cpt];
-- 
1.8.3.1
