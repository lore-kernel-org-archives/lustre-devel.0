From: NeilBrown <neilb@suse.com>
Date: Fri, 07 Sep 2018 10:49:31 +1000
Subject: [lustre-devel] [PATCH 17/34] lnet: move lnet_shutdown_lndnets down
 to after first use
In-Reply-To: <153628058697.8267.6056114844033479774.stgit@noble>
References: <153628058697.8267.6056114844033479774.stgit@noble>
Message-ID: <153628137192.8267.6087363236690952153.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This is part of
    8cbb8cd3e771e7f7e0f99cafc19fad32770dc015
       LU-7734 lnet: Multi-Rail local NI split

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c |   91 ++++++++++++++---------------
 1 file changed, 44 insertions(+), 47 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 2529a11c6c59..46c5ca71bc07 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1155,53 +1155,6 @@ lnet_clear_zombies_nis_locked(struct lnet_net *net)
 	}
 }
 
-static void
-lnet_shutdown_lndnet(struct lnet_net *net);
-
-static void
-lnet_shutdown_lndnets(void)
-{
-	struct lnet_net *net;
-
-	/* NB called holding the global mutex */
-
-	/* All quiet on the API front */
-	LASSERT(!the_lnet.ln_shutdown);
-	LASSERT(!the_lnet.ln_refcount);
-
-	lnet_net_lock(LNET_LOCK_EX);
-	the_lnet.ln_shutdown = 1;	/* flag shutdown */
-
-	while (!list_empty(&the_lnet.ln_nets)) {
-		/*
-		 * move the nets to the zombie list to avoid them being
-		 * picked up for new work. LONET is also included in the
-		 * Nets that will be moved to the zombie list
-		 */
-		net = list_entry(the_lnet.ln_nets.next,
-				 struct lnet_net, net_list);
-		list_move(&net->net_list, &the_lnet.ln_net_zombie);
-	}
-
-	/* Drop the cached loopback Net. */
-	if (the_lnet.ln_loni) {
-		lnet_ni_decref_locked(the_lnet.ln_loni, 0);
-		the_lnet.ln_loni = NULL;
-	}
-	lnet_net_unlock(LNET_LOCK_EX);
-
-	/* iterate through the net zombie list and delete each net */
-	while (!list_empty(&the_lnet.ln_net_zombie)) {
-		net = list_entry(the_lnet.ln_net_zombie.next,
-				 struct lnet_net, net_list);
-		lnet_shutdown_lndnet(net);
-	}
-
-	lnet_net_lock(LNET_LOCK_EX);
-	the_lnet.ln_shutdown = 0;
-	lnet_net_unlock(LNET_LOCK_EX);
-}
-
 /* shutdown down the NI and release refcount */
 static void
 lnet_shutdown_lndni(struct lnet_ni *ni)
@@ -1253,6 +1206,50 @@ lnet_shutdown_lndnet(struct lnet_net *net)
 	lnet_net_free(net);
 }
 
+static void
+lnet_shutdown_lndnets(void)
+{
+	struct lnet_net *net;
+
+	/* NB called holding the global mutex */
+
+	/* All quiet on the API front */
+	LASSERT(!the_lnet.ln_shutdown);
+	LASSERT(!the_lnet.ln_refcount);
+
+	lnet_net_lock(LNET_LOCK_EX);
+	the_lnet.ln_shutdown = 1;	/* flag shutdown */
+
+	while (!list_empty(&the_lnet.ln_nets)) {
+		/*
+		 * move the nets to the zombie list to avoid them being
+		 * picked up for new work. LONET is also included in the
+		 * Nets that will be moved to the zombie list
+		 */
+		net = list_entry(the_lnet.ln_nets.next,
+				 struct lnet_net, net_list);
+		list_move(&net->net_list, &the_lnet.ln_net_zombie);
+	}
+
+	/* Drop the cached loopback Net. */
+	if (the_lnet.ln_loni) {
+		lnet_ni_decref_locked(the_lnet.ln_loni, 0);
+		the_lnet.ln_loni = NULL;
+	}
+	lnet_net_unlock(LNET_LOCK_EX);
+
+	/* iterate through the net zombie list and delete each net */
+	while (!list_empty(&the_lnet.ln_net_zombie)) {
+		net = list_entry(the_lnet.ln_net_zombie.next,
+				 struct lnet_net, net_list);
+		lnet_shutdown_lndnet(net);
+	}
+
+	lnet_net_lock(LNET_LOCK_EX);
+	the_lnet.ln_shutdown = 0;
+	lnet_net_unlock(LNET_LOCK_EX);
+}
+
 static int
 lnet_startup_lndni(struct lnet_ni *ni, struct lnet_lnd_tunables *tun)
 {
