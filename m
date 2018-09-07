From: NeilBrown <neilb@suse.com>
Date: Fri, 07 Sep 2018 10:49:31 +1000
Subject: [lustre-devel] [PATCH 16/34] lnet: lnet_shutdown_lndnets - remove
 some cleanup code.
In-Reply-To: <153628058697.8267.6056114844033479774.stgit@noble>
References: <153628058697.8267.6056114844033479774.stgit@noble>
Message-ID: <153628137187.8267.1370078359892639459.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I don't know what this did, or why it is being removed.

This is part of
    8cbb8cd3e771e7f7e0f99cafc19fad32770dc015
       LU-7734 lnet: Multi-Rail local NI split

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c |   14 --------------
 1 file changed, 14 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 18d111cb826b..2529a11c6c59 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1161,7 +1161,6 @@ lnet_shutdown_lndnet(struct lnet_net *net);
 static void
 lnet_shutdown_lndnets(void)
 {
-	int i;
 	struct lnet_net *net;
 
 	/* NB called holding the global mutex */
@@ -1198,19 +1197,6 @@ lnet_shutdown_lndnets(void)
 		lnet_shutdown_lndnet(net);
 	}
 
-	/*
-	 * Clear lazy portals and drop delayed messages which hold refs
-	 * on their lnet_msg::msg_rxpeer
-	 */
-	for (i = 0; i < the_lnet.ln_nportals; i++)
-		LNetClearLazyPortal(i);
-
-	/*
-	 * Clear the peer table and wait for all peers to go (they hold refs on
-	 * their NIs)
-	 */
-	lnet_peer_tables_cleanup(NULL);
-
 	lnet_net_lock(LNET_LOCK_EX);
 	the_lnet.ln_shutdown = 0;
 	lnet_net_unlock(LNET_LOCK_EX);
