From: James Simmons <jsimmons@infradead.org>
Date: Sat, 21 Jan 2017 19:40:29 -0500
Subject: [lustre-devel] [PATCH 5/8] staging: lustre: lnet: change
	lnet_acceptor_connreq_t to proper structure
In-Reply-To: <1485045632-5886-1-git-send-email-jsimmons@infradead.org>
References: <1485045632-5886-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485045632-5886-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lnet_acceptor_connreq_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6142
Reviewed-on: https://review.whamcloud.com/24566
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/types.h | 4 ++--
 drivers/staging/lustre/lnet/lnet/acceptor.c       | 6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/linux/lnet/types.h
index 3c3b6676..c14015a 100644
--- a/drivers/staging/lustre/include/linux/lnet/types.h
+++ b/drivers/staging/lustre/include/linux/lnet/types.h
@@ -228,11 +228,11 @@ struct lnet_handle_wire {
 #define LNET_PROTO_TCP_VERSION_MINOR	0
 
 /* Acceptor connection request */
-typedef struct {
+struct lnet_acceptor_connreq {
 	__u32	acr_magic;		/* PTL_ACCEPTOR_PROTO_MAGIC */
 	__u32	acr_version;		/* protocol version */
 	__u64	acr_nid;		/* target NID */
-} WIRE_ATTR lnet_acceptor_connreq_t;
+} WIRE_ATTR;
 
 #define LNET_PROTO_ACCEPTOR_VERSION	1
 
diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
index 8c50c99..a55c6cd 100644
--- a/drivers/staging/lustre/lnet/lnet/acceptor.c
+++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
@@ -143,7 +143,7 @@
 lnet_connect(struct socket **sockp, lnet_nid_t peer_nid,
 	     __u32 local_ip, __u32 peer_ip, int peer_port)
 {
-	lnet_acceptor_connreq_t cr;
+	struct lnet_acceptor_connreq cr;
 	struct socket *sock;
 	int rc;
 	int port;
@@ -206,7 +206,7 @@
 static int
 lnet_accept(struct socket *sock, __u32 magic)
 {
-	lnet_acceptor_connreq_t cr;
+	struct lnet_acceptor_connreq cr;
 	__u32 peer_ip;
 	int peer_port;
 	int rc;
@@ -284,7 +284,7 @@
 
 	rc = lnet_sock_read(sock, &cr.acr_nid,
 			    sizeof(cr) -
-			    offsetof(lnet_acceptor_connreq_t, acr_nid),
+			    offsetof(struct lnet_acceptor_connreq, acr_nid),
 			    accept_timeout);
 	if (rc) {
 		CERROR("Error %d reading connection request from %pI4h\n",
-- 
1.8.3.1
