From: James Simmons <jsimmons@infradead.org>
Date: Tue, 11 Aug 2020 08:20:10 -0400
Subject: [lustre-devel] [PATCH 14/23] lnet: Ensure LNet pings and pushes are
 always tracked
In-Reply-To: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
References: <1597148419-20629-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1597148419-20629-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

Add the appropriate option to the MD used for LNet pings and pushes
to ensure that these are always tracked via LNet's response tracking
mechanism, regardless of the value of lnet_response_tracking
variable.

HPE-bug-id: LUS-8827
WC-bug-id: https://jira.whamcloud.com/browse/LU-13502
Lustre-commit: 9ed12d2e8f3f2 ("LU-13502 lnet: Ensure LNet pings and pushes are always tracked")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/38451
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 2 +-
 net/lnet/lnet/peer.c     | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index c0dd30c..aa6fe37 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -3340,7 +3340,7 @@ struct lnet_mt_event_info {
 	md.length = LNET_PING_INFO_SIZE(nnis);
 	md.threshold = 2; /* GET/REPLY */
 	md.max_size = 0;
-	md.options = LNET_MD_TRUNCATE;
+	md.options = LNET_MD_TRUNCATE | LNET_MD_TRACK_RESPONSE;
 	md.user_ptr = user_data;
 	md.handler = handler;
 
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index f745394..578591d 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -3097,7 +3097,7 @@ static int lnet_peer_send_push(struct lnet_peer *lp)
 	md.length = LNET_PING_INFO_SIZE(pbuf->pb_nnis);
 	md.threshold = 2; /* Put/Ack */
 	md.max_size = 0;
-	md.options = 0;
+	md.options = LNET_MD_TRACK_RESPONSE;
 	md.handler = the_lnet.ln_dc_handler;
 	md.user_ptr = lp;
 
-- 
1.8.3.1
