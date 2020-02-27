From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:36 -0500
Subject: [lustre-devel] [PATCH 108/622] lustre: obd: check '-o network' and
 peer discovery conflict
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-109-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sebastien Buisson <sbuisson@ddn.com>

"-o network=net" client mount option is not taken into account
when LNet dynamic peer discovery is active.
Check if LNet dynamic peer discovery is active on local node. If it
is, return error if "-o network=net" option is specified.

This patch will have to be reverted when the incompatibility between
"-o network=net" client mount option and LNet dynamic peer discovery
is resolved.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11057
Lustre-commit: 2269d27e07cb ("LU-11057 obd: check '-o network' and peer discovery conflict")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/32562
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/obd_mount.c |  7 +++++++
 include/linux/lnet/api.h       |  1 +
 net/lnet/lnet/api-ni.c         | 13 +++++++++++++
 3 files changed, 21 insertions(+)

diff --git a/fs/lustre/obdclass/obd_mount.c b/fs/lustre/obdclass/obd_mount.c
index 5cf404c..d143112 100644
--- a/fs/lustre/obdclass/obd_mount.c
+++ b/fs/lustre/obdclass/obd_mount.c
@@ -1169,6 +1169,13 @@ int lmd_parse(char *options, struct lustre_mount_data *lmd)
 			rc = lmd_parse_network(lmd, s1 + 8);
 			if (rc)
 				goto invalid;
+
+			/* check if LNet dynamic peer discovery is activated */
+			if (LNetGetPeerDiscoveryStatus()) {
+				CERROR("LNet Dynamic Peer Discovery is enabled on this node. 'network' mount option cannot be taken into account.\n");
+				goto invalid;
+			}
+
 			clear++;
 		}
 
diff --git a/include/linux/lnet/api.h b/include/linux/lnet/api.h
index a57ecc8..4b152c8 100644
--- a/include/linux/lnet/api.h
+++ b/include/linux/lnet/api.h
@@ -207,6 +207,7 @@ int LNetGet(lnet_nid_t self,
 int LNetClearLazyPortal(int portal);
 int LNetCtl(unsigned int cmd, void *arg);
 void LNetDebugPeer(struct lnet_process_id id);
+int LNetGetPeerDiscoveryStatus(void);
 
 /** @} lnet_misc */
 
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 07bc29f..c81f46f 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -4038,3 +4038,16 @@ static int lnet_ping(struct lnet_process_id id, signed long timeout,
 	kfree(buf);
 	return rc;
 }
+
+/**
+ * Retrieve peer discovery status.
+ *
+ * Return	1 if lnet_peer_discovery_disabled is 0
+ *		0 if lnet_peer_discovery_disabled is 1
+ */
+int
+LNetGetPeerDiscoveryStatus(void)
+{
+	return !lnet_peer_discovery_disabled;
+}
+EXPORT_SYMBOL(LNetGetPeerDiscoveryStatus);
-- 
1.8.3.1
