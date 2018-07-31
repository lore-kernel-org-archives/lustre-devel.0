From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Jul 2018 22:25:54 -0400
Subject: [lustre-devel] [PATCH 02/31] lustre: obd: add 'network' client
 mount option
In-Reply-To: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1533003983-29311-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

Add a 'network' mount option on client side. All connections made by
the client must be on the LNet network specified in the 'network'
option.

This option can be useful in case of several Lustre client mount
points on the same node, with each mount point using a different
network. It is also interesting when running Lustre clients from
containers, by restricting each container to a specific network.

This new option is added by tampering with two config commands:
- setup: add a fourth parameter, which is the net to restrict
  connections to. This parameter will be passed down to
  ptlrpc_uuid_to_peer() so that client only connects to peers on the
  restricted network.
- add_conn: skip this command if uuid to connect to is not on
  restricted network.

Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-7845
Reviewed-on: https://review.whamcloud.com/19792
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lustre/include/lustre_disk.h    |  1 +
 drivers/staging/lustre/lustre/include/lustre_net.h |  3 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      | 28 ++++++++++++++-
 .../staging/lustre/lustre/obdclass/obd_config.c    | 42 ++++++++++++++++++++++
 drivers/staging/lustre/lustre/obdclass/obd_mount.c | 38 ++++++++++++++++++++
 drivers/staging/lustre/lustre/ptlrpc/client.c      |  4 ++-
 drivers/staging/lustre/lustre/ptlrpc/events.c      |  4 +++
 7 files changed, 117 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_disk.h b/drivers/staging/lustre/lustre/include/lustre_disk.h
index d5fadde..103eb6a 100644
--- a/drivers/staging/lustre/lustre/include/lustre_disk.h
+++ b/drivers/staging/lustre/lustre/include/lustre_disk.h
@@ -87,6 +87,7 @@ struct lustre_mount_data {
 	__u32	*lmd_exclude;	/* array of OSTs to ignore */
 	char	*lmd_mgs;	/* MGS nid */
 	char	*lmd_osd_type;	/* OSD type */
+	char    *lmd_nidnet;	/* network to restrict this client to */
 };
 
 #define LMD_FLG_SERVER		0x0001	/* Mounting a server */
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index dcad90b..361b897 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -1812,7 +1812,8 @@ static inline int ptlrpc_client_bulk_active(struct ptlrpc_request *req)
 
 void ptlrpc_init_client(int req_portal, int rep_portal, char *name,
 			struct ptlrpc_client *);
-struct ptlrpc_connection *ptlrpc_uuid_to_connection(struct obd_uuid *uuid);
+struct ptlrpc_connection *ptlrpc_uuid_to_connection(struct obd_uuid *uuid,
+						    lnet_nid_t nid4refnet);
 
 int ptlrpc_queue_wait(struct ptlrpc_request *req);
 int ptlrpc_replay_req(struct ptlrpc_request *req);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index 07baea7..5da8c88 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -55,6 +55,7 @@ static int import_set_conn(struct obd_import *imp, struct obd_uuid *uuid,
 {
 	struct ptlrpc_connection *ptlrpc_conn;
 	struct obd_import_conn *imp_conn = NULL, *item;
+	lnet_nid_t nid4refnet = LNET_NID_ANY;
 	int rc = 0;
 
 	if (!create && !priority) {
@@ -62,7 +63,12 @@ static int import_set_conn(struct obd_import *imp, struct obd_uuid *uuid,
 		return -EINVAL;
 	}
 
-	ptlrpc_conn = ptlrpc_uuid_to_connection(uuid);
+	if (imp->imp_connection &&
+	    imp->imp_connection->c_remote_uuid.uuid[0] == 0)
+		/* nid4refnet is used to restrict network connections */
+		nid4refnet = imp->imp_connection->c_self;
+
+	ptlrpc_conn = ptlrpc_uuid_to_connection(uuid, nid4refnet);
 	if (!ptlrpc_conn) {
 		CDEBUG(D_HA, "can't find connection %s\n", uuid->uuid);
 		return -ENOENT;
@@ -233,6 +239,7 @@ void client_destroy_import(struct obd_import *imp)
  * 1 - client UUID
  * 2 - server UUID
  * 3 - inactive-on-startup
+ * 4 - restrictive net
  */
 int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 {
@@ -242,6 +249,10 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 	int rq_portal, rp_portal, connect_op;
 	char *name = obddev->obd_type->typ_name;
 	enum ldlm_ns_type ns_type = LDLM_NS_TYPE_UNKNOWN;
+	struct ptlrpc_connection fake_conn = {
+		.c_self = 0,
+		.c_remote_uuid.uuid[0] = 0
+	};
 	int rc;
 
 	/* In a more perfect world, we would hang a ptlrpc_client off of
@@ -412,11 +423,26 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 	       LUSTRE_CFG_BUFLEN(lcfg, 1));
 	class_import_put(imp);
 
+	if (lustre_cfg_buf(lcfg, 4)) {
+		u32 refnet = libcfs_str2net(lustre_cfg_string(lcfg, 4));
+
+		if (refnet == LNET_NIDNET(LNET_NID_ANY)) {
+			rc = -EINVAL;
+			CERROR("%s: bad mount option 'network=%s': rc = %d\n",
+			       obddev->obd_name, lustre_cfg_string(lcfg, 4),
+			       rc);
+			goto err_import;
+		}
+		fake_conn.c_self = LNET_MKNID(refnet, 0);
+		imp->imp_connection = &fake_conn;
+	}
+
 	rc = client_import_add_conn(imp, &server_uuid, 1);
 	if (rc) {
 		CERROR("can't add initial connection\n");
 		goto err_import;
 	}
+	imp->imp_connection = NULL;
 
 	cli->cl_import = imp;
 	/* cli->cl_max_mds_easize updated by mdc_init_ea_size() */
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index cfcd17e..6d47435 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -40,6 +40,8 @@
 #include <linux/uaccess.h>
 #include <linux/string.h>
 
+#include <uapi/linux/lustre/lustre_idl.h>
+#include <lustre_disk.h>
 #include <uapi/linux/lustre/lustre_ioctl.h>
 #include <llog_swab.h>
 #include <lprocfs_status.h>
@@ -1280,6 +1282,7 @@ int class_config_llog_handler(const struct lu_env *env,
 				lcfg->lcfg_command = LCFG_LOV_ADD_INA;
 		}
 
+		lustre_cfg_bufs_reset(&bufs, NULL);
 		lustre_cfg_bufs_init(&bufs, lcfg);
 
 		if (clli && clli->cfg_instance &&
@@ -1323,6 +1326,45 @@ int class_config_llog_handler(const struct lu_env *env,
 						   clli->cfg_obdname);
 		}
 
+		/* Add net info to setup command
+		 * if given on command line.
+		 * So config log will be:
+		 * [0]: client name
+		 * [1]: client UUID
+		 * [2]: server UUID
+		 * [3]: inactive-on-startup
+		 * [4]: restrictive net
+		 */
+		if (clli && clli->cfg_sb && s2lsi(clli->cfg_sb)) {
+			struct lustre_sb_info *lsi = s2lsi(clli->cfg_sb);
+			char *nidnet = lsi->lsi_lmd->lmd_nidnet;
+
+			if (lcfg->lcfg_command == LCFG_SETUP &&
+			    lcfg->lcfg_bufcount != 2 && nidnet) {
+				CDEBUG(D_CONFIG,
+				       "Adding net %s info to setup command for client %s\n",
+				       nidnet, lustre_cfg_string(lcfg, 0));
+				lustre_cfg_bufs_set_string(&bufs, 4, nidnet);
+			}
+		}
+
+		/* Skip add_conn command if uuid is not on restricted net */
+		if (clli && clli->cfg_sb && s2lsi(clli->cfg_sb)) {
+			struct lustre_sb_info *lsi = s2lsi(clli->cfg_sb);
+			char *uuid_str = lustre_cfg_string(lcfg, 1);
+
+			if (lcfg->lcfg_command == LCFG_ADD_CONN &&
+			    lsi->lsi_lmd->lmd_nidnet &&
+			    LNET_NIDNET(libcfs_str2nid(uuid_str)) !=
+			    libcfs_str2net(lsi->lsi_lmd->lmd_nidnet)) {
+				CDEBUG(D_CONFIG, "skipping add_conn for %s\n",
+				       uuid_str);
+				rc = 0;
+				/* No processing! */
+				break;
+			}
+		}
+
 		lcfg_len = lustre_cfg_len(bufs.lcfg_bufcount, bufs.lcfg_buflen);
 		lcfg_new = kzalloc(lcfg_len, GFP_NOFS);
 		if (!lcfg_new) {
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index b84bca4..1d88e8c 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -550,6 +550,7 @@ static int lustre_free_lsi(struct super_block *sb)
 		kfree(lsi->lsi_lmd->lmd_mgs);
 		kfree(lsi->lsi_lmd->lmd_osd_type);
 		kfree(lsi->lsi_lmd->lmd_params);
+		kfree(lsi->lsi_lmd->lmd_nidnet);
 
 		kfree(lsi->lsi_lmd);
 	}
@@ -827,6 +828,27 @@ static int lmd_parse_mgssec(struct lustre_mount_data *lmd, char *ptr)
 	return 0;
 }
 
+static int lmd_parse_network(struct lustre_mount_data *lmd, char *ptr)
+{
+	char *tail;
+	int length;
+
+	kfree(lmd->lmd_nidnet);
+	lmd->lmd_nidnet = NULL;
+
+	tail = strchr(ptr, ',');
+	if (!tail)
+		length = strlen(ptr);
+	else
+		length = tail - ptr;
+
+	lmd->lmd_nidnet = kstrndup(ptr, length, GFP_KERNEL);
+	if (!lmd->lmd_nidnet)
+		return -ENOMEM;
+
+	return 0;
+}
+
 static int lmd_parse_string(char **handle, char *ptr)
 {
 	char   *tail;
@@ -1146,6 +1168,11 @@ int lmd_parse(char *options, struct lustre_mount_data *lmd)
 			 */
 			*s1 = '\0';
 			break;
+		} else if (strncmp(s1, "network=", 8) == 0) {
+			rc = lmd_parse_network(lmd, s1 + 8);
+			if (rc)
+				goto invalid;
+			clear++;
 		}
 
 		/* Find next opt */
@@ -1192,6 +1219,17 @@ int lmd_parse(char *options, struct lustre_mount_data *lmd)
 			if (!lmd->lmd_fileset)
 				return -ENOMEM;
 		}
+	} else {
+		/* server mount */
+		if (lmd->lmd_nidnet) {
+			/* 'network=' mount option forbidden for server */
+			kfree(lmd->lmd_nidnet);
+			lmd->lmd_nidnet = NULL;
+			rc = -EINVAL;
+			CERROR("%s: option 'network=' not allowed for Lustre servers: rc = %d\n",
+			       devname, rc);
+			return rc;
+		}
 	}
 
 	/* Freed in lustre_free_lsi */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 91dd098..4bf26a4 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -77,7 +77,8 @@ void ptlrpc_init_client(int req_portal, int rep_portal, char *name,
 /**
  * Return PortalRPC connection for remote uud \a uuid
  */
-struct ptlrpc_connection *ptlrpc_uuid_to_connection(struct obd_uuid *uuid)
+struct ptlrpc_connection *ptlrpc_uuid_to_connection(struct obd_uuid *uuid,
+						    lnet_nid_t nid4refnet)
 {
 	struct ptlrpc_connection *c;
 	lnet_nid_t self;
@@ -89,6 +90,7 @@ struct ptlrpc_connection *ptlrpc_uuid_to_connection(struct obd_uuid *uuid)
 	 * before accessing its values.
 	 * coverity[uninit_use_in_call]
 	 */
+	peer.nid = nid4refnet;
 	err = ptlrpc_uuid_to_peer(uuid, &peer, &self);
 	if (err != 0) {
 		CNETERR("cannot find peer %s!\n", uuid->uuid);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/events.c b/drivers/staging/lustre/lustre/ptlrpc/events.c
index 130bacc..ebf985e 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/events.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/events.c
@@ -462,6 +462,10 @@ int ptlrpc_uuid_to_peer(struct obd_uuid *uuid,
 
 	/* Choose the matching UUID that's closest */
 	while (lustre_uuid_to_peer(uuid->uuid, &dst_nid, count++) == 0) {
+		if (peer->nid != LNET_NID_ANY && LNET_NIDADDR(peer->nid) == 0 &&
+		    LNET_NIDNET(dst_nid) != LNET_NIDNET(peer->nid))
+			continue;
+
 		dist = LNetDist(dst_nid, &src_nid, &order);
 		if (dist < 0)
 			continue;
-- 
1.8.3.1
