From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:33 -0500
Subject: [lustre-devel] [PATCH 585/622] lnet: socklnd: initialize
 the_ksocklnd at compile-time.
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-586-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

All other lnds initialize this struct at compile-time.
It is best for socklnd to do so too.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12678
Lustre-commit: b30930a242c6 ("LU-12678 socklnd: initialize the_ksocklnd at compile-time.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/36831
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.c | 23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 9a19a3f..016e005 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -2804,6 +2804,18 @@ static void __exit ksocklnd_exit(void)
 	lnet_unregister_lnd(&the_ksocklnd);
 }
 
+static struct lnet_lnd the_ksocklnd = {
+	.lnd_type		= SOCKLND,
+	.lnd_startup		= ksocknal_startup,
+	.lnd_shutdown		= ksocknal_shutdown,
+	.lnd_ctl		= ksocknal_ctl,
+	.lnd_send		= ksocknal_send,
+	.lnd_recv		= ksocknal_recv,
+	.lnd_notify_peer_down	= ksocknal_notify_gw_down,
+	.lnd_query		= ksocknal_query,
+	.lnd_accept		= ksocknal_accept,
+};
+
 static int __init ksocklnd_init(void)
 {
 	int rc;
@@ -2812,17 +2824,6 @@ static int __init ksocklnd_init(void)
 	BUILD_BUG_ON(SOCKLND_CONN_NTYPES > 4);
 	BUILD_BUG_ON(SOCKLND_CONN_ACK != SOCKLND_CONN_BULK_IN);
 
-	/* initialize the_ksocklnd */
-	the_ksocklnd.lnd_type = SOCKLND;
-	the_ksocklnd.lnd_startup = ksocknal_startup;
-	the_ksocklnd.lnd_shutdown = ksocknal_shutdown;
-	the_ksocklnd.lnd_ctl = ksocknal_ctl;
-	the_ksocklnd.lnd_send = ksocknal_send;
-	the_ksocklnd.lnd_recv = ksocknal_recv;
-	the_ksocklnd.lnd_notify_peer_down = ksocknal_notify_gw_down;
-	the_ksocklnd.lnd_query = ksocknal_query;
-	the_ksocklnd.lnd_accept = ksocknal_accept;
-
 	rc = ksocknal_tunables_init();
 	if (rc)
 		return rc;
-- 
1.8.3.1
