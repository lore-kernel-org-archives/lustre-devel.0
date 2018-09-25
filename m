From: NeilBrown <neilb@suse.com>
Date: Tue, 25 Sep 2018 11:07:16 +1000
Subject: [lustre-devel] [PATCH 29/34] LU-7734 lnet: double free in
 lnet_add_net_common()
In-Reply-To: <153783752960.32103.8394391715843917125.stgit@noble>
References: <153783752960.32103.8394391715843917125.stgit@noble>
Message-ID: <153783763597.32103.14845230051684461634.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Olaf Weber <olaf@sgi.com>

lnet_startup_lndnet() always consumes its net parameter, so we
should not free net after the function has been called. This
fixes a double free triggered by adding a network twice.

Eliminate the netl local variable.

Signed-off-by: Olaf Weber <olaf@sgi.com>
Change-Id: I1cfc3494eada4660b792f6a1ebd96b5dc80d9945
Reviewed-on: http://review.whamcloud.com/21446
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Tested-by: Amir Shehata <amir.shehata@intel.com>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c |   23 +++++++++++------------
 1 file changed, 11 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index f57200eab746..ea27d38f78c5 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -2143,7 +2143,6 @@ lnet_get_ni_config(struct lnet_ioctl_config_ni *cfg_ni,
 static int lnet_add_net_common(struct lnet_net *net,
 			       struct lnet_ioctl_config_lnd_tunables *tun)
 {
-	struct lnet_net *netl = NULL;
 	u32 net_id;
 	struct lnet_ping_info *pinfo;
 	struct lnet_handle_md md_handle;
@@ -2162,8 +2161,8 @@ static int lnet_add_net_common(struct lnet_net *net,
 	if (rnet) {
 		CERROR("Adding net %s will invalidate routing configuration\n",
 		       libcfs_net2str(net->net_id));
-		rc = -EUSERS;
-		goto failed1;
+		lnet_net_free(net);
+		return -EUSERS;
 	}
 
 	/*
@@ -2180,8 +2179,11 @@ static int lnet_add_net_common(struct lnet_net *net,
 	rc = lnet_ping_info_setup(&pinfo, &md_handle,
 				  net_ni_count + lnet_get_ni_count(),
 				  false);
-	if (rc < 0)
-		goto failed1;
+	if (rc < 0) {
+		lnet_net_free(net);
+		return rc;
+	}
+
 	if (tun)
 		memcpy(&net->net_tunables,
 		       &tun->lt_cmn, sizeof(net->net_tunables));
@@ -2204,17 +2206,16 @@ static int lnet_add_net_common(struct lnet_net *net,
 		goto failed;
 
 	lnet_net_lock(LNET_LOCK_EX);
-	netl = lnet_get_net_locked(net_id);
+	net = lnet_get_net_locked(net_id);
 	lnet_net_unlock(LNET_LOCK_EX);
 
-	LASSERT(netl);
+	LASSERT(net);
 
 	/*
 	 * Start the acceptor thread if this is the first network
 	 * being added that requires the thread.
 	 */
-	if (netl->net_lnd->lnd_accept &&
-	    num_acceptor_nets == 0) {
+	if (net->net_lnd->lnd_accept && num_acceptor_nets == 0) {
 		rc = lnet_acceptor_start();
 		if (rc < 0) {
 			/* shutdown the net that we just started */
@@ -2225,7 +2226,7 @@ static int lnet_add_net_common(struct lnet_net *net,
 	}
 
 	lnet_net_lock(LNET_LOCK_EX);
-	lnet_peer_net_added(netl);
+	lnet_peer_net_added(net);
 	lnet_net_unlock(LNET_LOCK_EX);
 
 	lnet_ping_target_update(pinfo, md_handle);
@@ -2235,8 +2236,6 @@ static int lnet_add_net_common(struct lnet_net *net,
 failed:
 	lnet_ping_md_unlink(pinfo, &md_handle);
 	lnet_ping_info_free(pinfo);
-failed1:
-	lnet_net_free(net);
 	return rc;
 }
 
