From: NeilBrown <neilb@suse.com>
Date: Fri, 07 Sep 2018 10:49:32 +1000
Subject: [lustre-devel] [PATCH 25/34] lnet: swap 'then' and 'else' branches
 in lnet_startup_lndnet
In-Reply-To: <153628058697.8267.6056114844033479774.stgit@noble>
References: <153628058697.8267.6056114844033479774.stgit@noble>
Message-ID: <153628137225.8267.589541269937133692.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This swap makes the diff for the next patch more readable.
We also stop storing the return value from lnet_net_unique()
as it is never used.

This is part of
    8cbb8cd3e771e7f7e0f99cafc19fad32770dc015
       LU-7734 lnet: Multi-Rail local NI split

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c |   55 +++++++++++++++--------------
 1 file changed, 28 insertions(+), 27 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 2b5c25a1dc7c..ab4d093c04da 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1372,8 +1372,34 @@ lnet_startup_lndnet(struct lnet_net *net, struct lnet_lnd_tunables *tun)
 	LASSERT(libcfs_isknown_lnd(lnd_type));
 
 	/* Make sure this new NI is unique. */
-	rc = lnet_net_unique(net->net_id, &the_lnet.ln_nets);
-	if (!rc) {
+	if (lnet_net_unique(net->net_id, &the_lnet.ln_nets)) {
+		mutex_lock(&the_lnet.ln_lnd_mutex);
+		lnd = lnet_find_lnd_by_type(lnd_type);
+
+		if (lnd == NULL) {
+			mutex_unlock(&the_lnet.ln_lnd_mutex);
+			rc = request_module("%s", libcfs_lnd2modname(lnd_type));
+			mutex_lock(&the_lnet.ln_lnd_mutex);
+
+			lnd = lnet_find_lnd_by_type(lnd_type);
+			if (lnd == NULL) {
+				mutex_unlock(&the_lnet.ln_lnd_mutex);
+				CERROR("Can't load LND %s, module %s, rc=%d\n",
+				libcfs_lnd2str(lnd_type),
+				libcfs_lnd2modname(lnd_type), rc);
+				rc = -EINVAL;
+				goto failed0;
+			}
+		}
+
+		lnet_net_lock(LNET_LOCK_EX);
+		lnd->lnd_refcount++;
+		lnet_net_unlock(LNET_LOCK_EX);
+
+		net->net_lnd = lnd;
+
+		mutex_unlock(&the_lnet.ln_lnd_mutex);
+	} else {
 		if (lnd_type == LOLND) {
 			lnet_net_free(net);
 			return 0;
@@ -1385,31 +1411,6 @@ lnet_startup_lndnet(struct lnet_net *net, struct lnet_lnd_tunables *tun)
 		goto failed0;
 	}
 
-	mutex_lock(&the_lnet.ln_lnd_mutex);
-	lnd = lnet_find_lnd_by_type(lnd_type);
-
-	if (!lnd) {
-		mutex_unlock(&the_lnet.ln_lnd_mutex);
-		rc = request_module("%s", libcfs_lnd2modname(lnd_type));
-		mutex_lock(&the_lnet.ln_lnd_mutex);
-
-		lnd = lnet_find_lnd_by_type(lnd_type);
-		if (!lnd) {
-			mutex_unlock(&the_lnet.ln_lnd_mutex);
-			CERROR("Can't load LND %s, module %s, rc=%d\n",
-			       libcfs_lnd2str(lnd_type),
-			       libcfs_lnd2modname(lnd_type), rc);
-			rc = -EINVAL;
-			goto failed0;
-		}
-	}
-
-	lnet_net_lock(LNET_LOCK_EX);
-	lnd->lnd_refcount++;
-	lnet_net_unlock(LNET_LOCK_EX);
-	net->net_lnd = lnd;
-	mutex_unlock(&the_lnet.ln_lnd_mutex);
-
 	while (!list_empty(&net->net_ni_added)) {
 		ni = list_entry(net->net_ni_added.next, struct lnet_ni,
 				ni_netlist);
