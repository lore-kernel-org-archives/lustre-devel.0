From: NeilBrown <neilb@suse.com>
Date: Fri, 07 Sep 2018 10:49:31 +1000
Subject: [lustre-devel] [PATCH 13/34] lnet: reverse order of
 lnet_startup_lnd{net, ni}
In-Reply-To: <153628058697.8267.6056114844033479774.stgit@noble>
References: <153628058697.8267.6056114844033479774.stgit@noble>
Message-ID: <153628137175.8267.2271624767774752203.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Change the order - no other change.

This is part of
    8cbb8cd3e771e7f7e0f99cafc19fad32770dc015
       LU-7734 lnet: Multi-Rail local NI split

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c |  135 ++++++++++++++---------------
 1 file changed, 66 insertions(+), 69 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 8afddf11b5e2..09ea7e506128 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1267,75 +1267,6 @@ lnet_shutdown_lndnet(struct lnet_net *net)
 	lnet_net_free(net);
 }
 
-static int
-lnet_startup_lndni(struct lnet_ni *ni, struct lnet_lnd_tunables *tun);
-
-static int
-lnet_startup_lndnet(struct lnet_net *net, struct lnet_lnd_tunables *tun)
-{
-	struct lnet_ni		*ni;
-	__u32			lnd_type;
-	struct lnet_lnd		*lnd;
-	int rc;
-
-	lnd_type = LNET_NETTYP(net->net_id);
-
-	LASSERT(libcfs_isknown_lnd(lnd_type));
-
-	/* Make sure this new NI is unique. */
-	lnet_net_lock(LNET_LOCK_EX);
-	rc = lnet_net_unique(net->net_id, &the_lnet.ln_nets);
-	lnet_net_unlock(LNET_LOCK_EX);
-	if (!rc) {
-		if (lnd_type == LOLND) {
-			lnet_net_free(net);
-			return 0;
-		}
-
-		CERROR("Net %s is not unique\n",
-		       libcfs_net2str(net->net_id));
-		rc = -EEXIST;
-		goto failed0;
-	}
-
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
-	ni = list_first_entry(&net->net_ni_list, struct lnet_ni, ni_netlist);
-
-	rc = lnet_startup_lndni(ni, tun);
-	if (rc < 0)
-		return rc;
-	return 1;
-
-failed0:
-	lnet_net_free(net);
-
-	return rc;
-}
-
 static int
 lnet_startup_lndni(struct lnet_ni *ni, struct lnet_lnd_tunables *tun)
 {
@@ -1427,6 +1358,72 @@ lnet_startup_lndni(struct lnet_ni *ni, struct lnet_lnd_tunables *tun)
 	return rc;
 }
 
+static int
+lnet_startup_lndnet(struct lnet_net *net, struct lnet_lnd_tunables *tun)
+{
+	struct lnet_ni		*ni;
+	__u32			lnd_type;
+	struct lnet_lnd		*lnd;
+	int			rc;
+
+	lnd_type = LNET_NETTYP(net->net_id);
+
+	LASSERT(libcfs_isknown_lnd(lnd_type));
+
+	/* Make sure this new NI is unique. */
+	lnet_net_lock(LNET_LOCK_EX);
+	rc = lnet_net_unique(net->net_id, &the_lnet.ln_nets);
+	lnet_net_unlock(LNET_LOCK_EX);
+	if (!rc) {
+		if (lnd_type == LOLND) {
+			lnet_net_free(net);
+			return 0;
+		}
+
+		CERROR("Net %s is not unique\n",
+		       libcfs_net2str(net->net_id));
+		rc = -EEXIST;
+		goto failed0;
+	}
+
+	mutex_lock(&the_lnet.ln_lnd_mutex);
+	lnd = lnet_find_lnd_by_type(lnd_type);
+
+	if (!lnd) {
+		mutex_unlock(&the_lnet.ln_lnd_mutex);
+		rc = request_module("%s", libcfs_lnd2modname(lnd_type));
+		mutex_lock(&the_lnet.ln_lnd_mutex);
+
+		lnd = lnet_find_lnd_by_type(lnd_type);
+		if (!lnd) {
+			mutex_unlock(&the_lnet.ln_lnd_mutex);
+			CERROR("Can't load LND %s, module %s, rc=%d\n",
+			       libcfs_lnd2str(lnd_type),
+			       libcfs_lnd2modname(lnd_type), rc);
+			rc = -EINVAL;
+			goto failed0;
+		}
+	}
+
+	lnet_net_lock(LNET_LOCK_EX);
+	lnd->lnd_refcount++;
+	lnet_net_unlock(LNET_LOCK_EX);
+	net->net_lnd = lnd;
+	mutex_unlock(&the_lnet.ln_lnd_mutex);
+
+	ni = list_first_entry(&net->net_ni_list, struct lnet_ni, ni_netlist);
+
+	rc = lnet_startup_lndni(ni, tun);
+	if (rc < 0)
+		return rc;
+	return 1;
+
+failed0:
+	lnet_net_free(net);
+
+	return rc;
+}
+
 static int
 lnet_startup_lndnets(struct list_head *netlist)
 {
