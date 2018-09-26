From: James Simmons <jsimmons@infradead.org>
Date: Tue, 25 Sep 2018 22:47:59 -0400
Subject: [lustre-devel] [PATCH 07/25] lustre: lnet: rename
 LNET_MAX_INTERFACES
In-Reply-To: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
References: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1537930097-11624-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Olaf Weber <olaf.weber@hpe.com>

LNET_MAX_INTERFACES is the number of interfaces supported by
interface bonding in the ksocknal LND. It shows up in LNet
because a number of data structures are shared between LNDs.

Rename it to LNET_NUM_INTERFACES to reduce the confusion of
what it does. Also it allows us to build the userland tools.

Signed-off-by: Olaf Weber <olaf.weber@hpe.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9119
Reviewed-on: https://review.whamcloud.com/26693
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/lnet/lib-types.h  |  2 +-
 .../lustre/include/uapi/linux/lnet/lnet-dlc.h      |  4 ++--
 .../lustre/include/uapi/linux/lnet/lnet-types.h    |  2 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |  2 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    | 22 +++++++++++-----------
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |  4 ++--
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |  2 +-
 .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |  4 ++--
 drivers/staging/lustre/lnet/lnet/config.c          | 10 +++++-----
 9 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 6abac19..90f7577 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -371,7 +371,7 @@ struct lnet_ni {
 	 * equivalent interfaces to use
 	 * This is an array because socklnd bonding can still be configured
 	 */
-	char			 *ni_interfaces[LNET_MAX_INTERFACES];
+	char			 *ni_interfaces[LNET_NUM_INTERFACES];
 	/* original net namespace */
 	struct net		 *ni_net_ns;
 };
diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
index e603455..07516fd 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-dlc.h
@@ -81,7 +81,7 @@ struct lnet_ioctl_config_lnd_tunables {
 };
 
 struct lnet_ioctl_net_config {
-	char ni_interfaces[LNET_MAX_INTERFACES][LNET_MAX_STR_LEN];
+	char ni_interfaces[LNET_NUM_INTERFACES][LNET_MAX_STR_LEN];
 	__u32 ni_status;
 	__u32 ni_cpts[LNET_MAX_SHOW_NUM_CPT];
 	char cfg_bulk[0];
@@ -184,7 +184,7 @@ struct lnet_ioctl_element_msg_stats {
 struct lnet_ioctl_config_ni {
 	struct libcfs_ioctl_hdr lic_cfg_hdr;
 	lnet_nid_t		lic_nid;
-	char			lic_ni_intf[LNET_MAX_INTERFACES][LNET_MAX_STR_LEN];
+	char			lic_ni_intf[LNET_NUM_INTERFACES][LNET_MAX_STR_LEN];
 	char			lic_legacy_ip2nets[LNET_MAX_STR_LEN];
 	__u32			lic_cpts[LNET_MAX_SHOW_NUM_CPT];
 	__u32			lic_ncpts;
diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
index 837e5fe..a373b9c 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
@@ -264,7 +264,7 @@ struct lnet_counters {
 #define LNET_NI_STATUS_DOWN    0xdeadface
 #define LNET_NI_STATUS_INVALID 0x00000000
 
-#define LNET_MAX_INTERFACES    16
+#define LNET_NUM_INTERFACES    16
 
 /**
  * Objects maintained by the LNet are accessed through handles. Handle types
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index b3a4344..aea83a5 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2870,7 +2870,7 @@ static int kiblnd_startup(struct lnet_ni *ni)
 	if (ni->ni_interfaces[0]) {
 		/* Use the IPoIB interface specified in 'networks=' */
 
-		BUILD_BUG_ON(LNET_MAX_INTERFACES <= 1);
+		BUILD_BUG_ON(LNET_NUM_INTERFACES <= 1);
 		if (ni->ni_interfaces[1]) {
 			CERROR("Multiple interfaces not supported\n");
 			goto failed;
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 9b9cc87..ad94837 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -53,7 +53,7 @@
 	struct ksock_interface *iface;
 
 	for (i = 0; i < net->ksnn_ninterfaces; i++) {
-		LASSERT(i < LNET_MAX_INTERFACES);
+		LASSERT(i < LNET_NUM_INTERFACES);
 		iface = &net->ksnn_interfaces[i];
 
 		if (iface->ksni_ipaddr == ip)
@@ -221,7 +221,7 @@ struct ksock_peer *
 	struct ksock_interface *iface;
 
 	for (i = 0; i < peer_ni->ksnp_n_passive_ips; i++) {
-		LASSERT(i < LNET_MAX_INTERFACES);
+		LASSERT(i < LNET_NUM_INTERFACES);
 		ip = peer_ni->ksnp_passive_ips[i];
 
 		iface = ksocknal_ip2iface(peer_ni->ksnp_ni, ip);
@@ -678,7 +678,7 @@ struct ksock_peer *
 	read_lock(&ksocknal_data.ksnd_global_lock);
 
 	nip = net->ksnn_ninterfaces;
-	LASSERT(nip <= LNET_MAX_INTERFACES);
+	LASSERT(nip <= LNET_NUM_INTERFACES);
 
 	/*
 	 * Only offer interfaces for additional connections if I have
@@ -759,8 +759,8 @@ struct ksock_peer *
 	 */
 	write_lock_bh(global_lock);
 
-	LASSERT(n_peerips <= LNET_MAX_INTERFACES);
-	LASSERT(net->ksnn_ninterfaces <= LNET_MAX_INTERFACES);
+	LASSERT(n_peerips <= LNET_NUM_INTERFACES);
+	LASSERT(net->ksnn_ninterfaces <= LNET_NUM_INTERFACES);
 
 	/*
 	 * Only match interfaces for additional connections
@@ -879,7 +879,7 @@ struct ksock_peer *
 		return;
 	}
 
-	LASSERT(npeer_ipaddrs <= LNET_MAX_INTERFACES);
+	LASSERT(npeer_ipaddrs <= LNET_NUM_INTERFACES);
 
 	for (i = 0; i < npeer_ipaddrs; i++) {
 		if (newroute) {
@@ -908,7 +908,7 @@ struct ksock_peer *
 		best_nroutes = 0;
 		best_netmatch = 0;
 
-		LASSERT(net->ksnn_ninterfaces <= LNET_MAX_INTERFACES);
+		LASSERT(net->ksnn_ninterfaces <= LNET_NUM_INTERFACES);
 
 		/* Select interface to connect from */
 		for (j = 0; j < net->ksnn_ninterfaces; j++) {
@@ -1048,7 +1048,7 @@ struct ksock_peer *
 	atomic_set(&conn->ksnc_tx_nob, 0);
 
 	hello = kvzalloc(offsetof(struct ksock_hello_msg,
-				  kshm_ips[LNET_MAX_INTERFACES]),
+				  kshm_ips[LNET_NUM_INTERFACES]),
 			 GFP_KERNEL);
 	if (!hello) {
 		rc = -ENOMEM;
@@ -1956,7 +1956,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 	if (iface) {
 		/* silently ignore dups */
 		rc = 0;
-	} else if (net->ksnn_ninterfaces == LNET_MAX_INTERFACES) {
+	} else if (net->ksnn_ninterfaces == LNET_NUM_INTERFACES) {
 		rc = -ENOSPC;
 	} else {
 		iface = &net->ksnn_interfaces[net->ksnn_ninterfaces++];
@@ -2594,7 +2594,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 			continue;
 		}
 
-		if (j == LNET_MAX_INTERFACES) {
+		if (j == LNET_NUM_INTERFACES) {
 			CWARN("Ignoring interface %s (too many interfaces)\n",
 			      name);
 			continue;
@@ -2782,7 +2782,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 
 		net->ksnn_ninterfaces = rc;
 	} else {
-		for (i = 0; i < LNET_MAX_INTERFACES; i++) {
+		for (i = 0; i < LNET_NUM_INTERFACES; i++) {
 			if (!ni->ni_interfaces[i])
 				break;
 			rc = ksocknal_enumerate_interfaces(net, ni->ni_interfaces[i]);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index cc813e4..95ca2aa 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -173,7 +173,7 @@ struct ksock_net {
 	int		  ksnn_npeers;		/* # peers */
 	int		  ksnn_shutdown;	/* shutting down? */
 	int		  ksnn_ninterfaces;	/* IP interfaces */
-	struct ksock_interface ksnn_interfaces[LNET_MAX_INTERFACES];
+	struct ksock_interface ksnn_interfaces[LNET_NUM_INTERFACES];
 };
 
 /** connd timeout */
@@ -441,7 +441,7 @@ struct ksock_peer {
 	int                ksnp_n_passive_ips;  /* # of... */
 
 	/* preferred local interfaces */
-	__u32              ksnp_passive_ips[LNET_MAX_INTERFACES];
+	u32		   ksnp_passive_ips[LNET_NUM_INTERFACES];
 };
 
 struct ksock_connreq {
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index 2e99a17..73321a7 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -1580,7 +1580,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	/* CAVEAT EMPTOR: this byte flips 'ipaddrs' */
 	struct ksock_net *net = (struct ksock_net *)ni->ni_data;
 
-	LASSERT(hello->kshm_nips <= LNET_MAX_INTERFACES);
+	LASSERT(hello->kshm_nips <= LNET_NUM_INTERFACES);
 
 	/* rely on caller to hold a ref on socket so it wouldn't disappear */
 	LASSERT(conn->ksnc_proto);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
index 8c10eda..10a2757 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
@@ -614,7 +614,7 @@
 	hello->kshm_nips            = le32_to_cpu(hdr->payload_length) /
 						  sizeof(__u32);
 
-	if (hello->kshm_nips > LNET_MAX_INTERFACES) {
+	if (hello->kshm_nips > LNET_NUM_INTERFACES) {
 		CERROR("Bad nips %d from ip %pI4h\n",
 		       hello->kshm_nips, &conn->ksnc_ipaddr);
 		rc = -EPROTO;
@@ -684,7 +684,7 @@
 		__swab32s(&hello->kshm_nips);
 	}
 
-	if (hello->kshm_nips > LNET_MAX_INTERFACES) {
+	if (hello->kshm_nips > LNET_NUM_INTERFACES) {
 		CERROR("Bad nips %d from ip %pI4h\n",
 		       hello->kshm_nips, &conn->ksnc_ipaddr);
 		return -EPROTO;
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index 4c22416..3ea56c8 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -123,10 +123,10 @@ struct lnet_text_buf {	    /* tmp struct for parsing routes */
 /* check that the NI is unique to the interfaces with in the same NI.
  * This is only a consideration if use_tcp_bonding is set */
 static bool
-lnet_ni_unique_ni(char *iface_list[LNET_MAX_INTERFACES], char *iface)
+lnet_ni_unique_ni(char *iface_list[LNET_NUM_INTERFACES], char *iface)
 {
 	int i;
-	for (i = 0; i < LNET_MAX_INTERFACES; i++) {
+	for (i = 0; i < LNET_NUM_INTERFACES; i++) {
 		if (iface_list[i] &&
 		    strncmp(iface_list[i], iface, strlen(iface)) == 0)
 			return false;
@@ -304,7 +304,7 @@ struct lnet_text_buf {	    /* tmp struct for parsing routes */
 
 	kfree(ni->ni_cpts);
 
-	for (i = 0; i < LNET_MAX_INTERFACES && ni->ni_interfaces[i]; i++)
+	for (i = 0; i < LNET_NUM_INTERFACES && ni->ni_interfaces[i]; i++)
 		kfree(ni->ni_interfaces[i]);
 
 	/* release reference to net namespace */
@@ -397,11 +397,11 @@ struct lnet_net *
 	 * can free the tokens at the end of the function.
 	 * The newly allocated ni_interfaces[] can be
 	 * freed when freeing the NI */
-	while (niface < LNET_MAX_INTERFACES &&
+	while (niface < LNET_NUM_INTERFACES &&
 	       ni->ni_interfaces[niface])
 		niface++;
 
-	if (niface >= LNET_MAX_INTERFACES) {
+	if (niface >= LNET_NUM_INTERFACES) {
 		LCONSOLE_ERROR_MSG(0x115, "Too many interfaces "
 				   "for net %s\n",
 				   libcfs_net2str(LNET_NIDNET(ni->ni_nid)));
-- 
1.8.3.1
