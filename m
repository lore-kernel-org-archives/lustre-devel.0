From: Arnd Bergmann <arnd@arndb.de>
Date: Thu,  2 Feb 2017 12:26:51 +0100
Subject: [lustre-devel] [PATCH] staging: lustre: remove CLASSERT macro
Message-ID: <20170202113209.612528-1-arnd@arndb.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, "John L. Hammond" <john.hammond@intel.com>, Amir Shehata <amir.shehata@intel.com>, frank zago <fzago@cray.com>, Niu Yawei <yawei.niu@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

lustre uses a fake switch() statement as a compile-time assert, but unfortunately
each use of that causes a warning when building with clang:

drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c:2907:2: warning: no case matching constant switch condition '42'
drivers/staging/lustre/lnet/klnds/socklnd/../../../include/linux/libcfs/libcfs_private.h:294:36: note: expanded from macro 'CLASSERT'
 #define CLASSERT(cond) do {switch (42) {case (cond): case 0: break; } } while (0)

As Greg suggested, let's just kill off this macro completely instead of
fixing it. This replaces it with BUILD_BUG_ON(), which means we have
to negate all the conditions in the process.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 .../lustre/include/linux/libcfs/libcfs_private.h   |  16 --
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |  16 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |   4 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |   2 +-
 .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |   2 +-
 drivers/staging/lustre/lnet/libcfs/hash.c          |   2 +-
 drivers/staging/lustre/lnet/lnet/acceptor.c        |   4 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c          | 134 +++++++-------
 drivers/staging/lustre/lnet/lnet/lib-socket.c      |   2 +-
 drivers/staging/lustre/lnet/lnet/net_fault.c       |   8 +-
 drivers/staging/lustre/lnet/lnet/router_proc.c     |   4 +-
 drivers/staging/lustre/lustre/include/cl_object.h  |   2 +-
 drivers/staging/lustre/lustre/include/lu_object.h  |   2 +-
 drivers/staging/lustre/lustre/include/lustre_net.h |   4 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |   2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |   2 +-
 drivers/staging/lustre/lustre/llite/super25.c      |   2 +-
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |   2 +-
 drivers/staging/lustre/lustre/lov/lov_pack.c       |   6 +-
 drivers/staging/lustre/lustre/mdc/mdc_lib.c        |  12 +-
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |   2 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |   2 +-
 drivers/staging/lustre/lustre/osc/osc_io.c         |   2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |  16 +-
 drivers/staging/lustre/lustre/ptlrpc/client.c      |   4 +-
 drivers/staging/lustre/lustre/ptlrpc/import.c      |   2 +-
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    | 102 +++++------
 drivers/staging/lustre/lustre/ptlrpc/pers.c        |   2 +-
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    | 194 ++++++++++-----------
 29 files changed, 269 insertions(+), 285 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
index aab15d8112a4..2dae85798ec1 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
@@ -277,22 +277,6 @@ do {							    \
 #define CFS_ALLOC_PTR(ptr)      LIBCFS_ALLOC(ptr, sizeof(*(ptr)))
 #define CFS_FREE_PTR(ptr)       LIBCFS_FREE(ptr, sizeof(*(ptr)))
 
-/** Compile-time assertion.
- *
- * Check an invariant described by a constant expression at compile time by
- * forcing a compiler error if it does not hold.  \a cond must be a constant
- * expression as defined by the ISO C Standard:
- *
- *       6.8.4.2  The switch statement
- *       ....
- *       [#3] The expression of each case label shall be  an  integer
- *       constant   expression  and  no  two  of  the  case  constant
- *       expressions in the same switch statement shall have the same
- *       value  after  conversion...
- *
- */
-#define CLASSERT(cond) do {switch (42) {case (cond): case 0: break; } } while (0)
-
 /* max value for numeric network address */
 #define MAX_NUMERIC_VALUE 0xffffffff
 
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 7f761b327166..b1e8508f9fc7 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -258,8 +258,8 @@ int kiblnd_unpack_msg(struct kib_msg *msg, int nob)
 	if (flip) {
 		/* leave magic unflipped as a clue to peer endianness */
 		msg->ibm_version = version;
-		CLASSERT(sizeof(msg->ibm_type) == 1);
-		CLASSERT(sizeof(msg->ibm_credits) == 1);
+		BUILD_BUG_ON(sizeof(msg->ibm_type) != 1);
+		BUILD_BUG_ON(sizeof(msg->ibm_credits) != 1);
 		msg->ibm_nob     = msg_nob;
 		__swab64s(&msg->ibm_srcnid);
 		__swab64s(&msg->ibm_srcstamp);
@@ -1247,10 +1247,10 @@ static void kiblnd_map_tx_pool(struct kib_tx_pool *tpo)
 	dev = net->ibn_dev;
 
 	/* pre-mapped messages are not bigger than 1 page */
-	CLASSERT(IBLND_MSG_SIZE <= PAGE_SIZE);
+	BUILD_BUG_ON(IBLND_MSG_SIZE > PAGE_SIZE);
 
 	/* No fancy arithmetic when we do the buffer calculations */
-	CLASSERT(!(PAGE_SIZE % IBLND_MSG_SIZE));
+	BUILD_BUG_ON(PAGE_SIZE % IBLND_MSG_SIZE);
 
 	tpo->tpo_hdev = kiblnd_current_hdev(dev);
 
@@ -2943,7 +2943,7 @@ static int kiblnd_startup(lnet_ni_t *ni)
 	if (ni->ni_interfaces[0]) {
 		/* Use the IPoIB interface specified in 'networks=' */
 
-		CLASSERT(LNET_MAX_INTERFACES > 1);
+		BUILD_BUG_ON(LNET_MAX_INTERFACES <= 1);
 		if (ni->ni_interfaces[1]) {
 			CERROR("Multiple interfaces not supported\n");
 			goto failed;
@@ -3020,11 +3020,11 @@ static void __exit ko2iblnd_exit(void)
 
 static int __init ko2iblnd_init(void)
 {
-	CLASSERT(sizeof(struct kib_msg) <= IBLND_MSG_SIZE);
-	CLASSERT(offsetof(struct kib_msg,
+	BUILD_BUG_ON(sizeof(struct kib_msg) > IBLND_MSG_SIZE);
+	BUILD_BUG_ON(!offsetof(struct kib_msg,
 			  ibm_u.get.ibgm_rd.rd_frags[IBLND_MAX_RDMA_FRAGS])
 			  <= IBLND_MSG_SIZE);
-	CLASSERT(offsetof(struct kib_msg,
+	BUILD_BUG_ON(!offsetof(struct kib_msg,
 			  ibm_u.putack.ibpam_rd.rd_frags[IBLND_MAX_RDMA_FRAGS])
 			  <= IBLND_MSG_SIZE);
 
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 2181c67a95e8..148db65185cb 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -2904,8 +2904,8 @@ static int __init ksocklnd_init(void)
 	int rc;
 
 	/* check ksnr_connected/connecting field large enough */
-	CLASSERT(SOCKLND_CONN_NTYPES <= 4);
-	CLASSERT(SOCKLND_CONN_ACK == SOCKLND_CONN_BULK_IN);
+	BUILD_BUG_ON(SOCKLND_CONN_NTYPES > 4);
+	BUILD_BUG_ON(SOCKLND_CONN_ACK != SOCKLND_CONN_BULK_IN);
 
 	/* initialize the_ksocklnd */
 	the_ksocklnd.lnd_type     = SOCKLND;
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index 3531e7d99349..95334a80e8b8 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -1658,7 +1658,7 @@ ksocknal_parse_proto_version(ksock_hello_msg_t *hello)
 	if (hello->kshm_magic == le32_to_cpu(LNET_PROTO_TCP_MAGIC)) {
 		struct lnet_magicversion *hmv = (struct lnet_magicversion *)hello;
 
-		CLASSERT(sizeof(struct lnet_magicversion) ==
+		BUILD_BUG_ON(sizeof(struct lnet_magicversion) !=
 			 offsetof(ksock_hello_msg_t, kshm_src_nid));
 
 		if (hmv->version_major == cpu_to_le16(KSOCK_PROTO_V1_MAJOR) &&
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
index b36f181db08e..d367e74d46c2 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
@@ -464,7 +464,7 @@ ksocknal_send_hello_v1(struct ksock_conn *conn, ksock_hello_msg_t *hello)
 	int rc;
 	int i;
 
-	CLASSERT(sizeof(struct lnet_magicversion) == offsetof(struct lnet_hdr, src_nid));
+	BUILD_BUG_ON(sizeof(struct lnet_magicversion) != offsetof(struct lnet_hdr, src_nid));
 
 	LIBCFS_ALLOC(hdr, sizeof(*hdr));
 	if (!hdr) {
diff --git a/drivers/staging/lustre/lnet/libcfs/hash.c b/drivers/staging/lustre/lnet/libcfs/hash.c
index c93c59d8fe6c..5c2ce2ee6fd9 100644
--- a/drivers/staging/lustre/lnet/libcfs/hash.c
+++ b/drivers/staging/lustre/lnet/libcfs/hash.c
@@ -1000,7 +1000,7 @@ cfs_hash_create(char *name, unsigned int cur_bits, unsigned int max_bits,
 	struct cfs_hash *hs;
 	int len;
 
-	CLASSERT(CFS_HASH_THETA_BITS < 15);
+	BUILD_BUG_ON(CFS_HASH_THETA_BITS >= 15);
 
 	LASSERT(name);
 	LASSERT(ops->hs_key);
diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
index a55c6cd6ff37..d5d27e534919 100644
--- a/drivers/staging/lustre/lnet/lnet/acceptor.c
+++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
@@ -149,7 +149,7 @@ lnet_connect(struct socket **sockp, lnet_nid_t peer_nid,
 	int port;
 	int fatal;
 
-	CLASSERT(sizeof(cr) <= 16);	    /* not too big to be on the stack */
+	BUILD_BUG_ON(sizeof(cr) > 16);	    /* too big to be on the stack */
 
 	for (port = LNET_ACCEPTOR_MAX_RESERVED_PORT;
 	     port >= LNET_ACCEPTOR_MIN_RESERVED_PORT;
@@ -164,7 +164,7 @@ lnet_connect(struct socket **sockp, lnet_nid_t peer_nid,
 			continue;
 		}
 
-		CLASSERT(LNET_PROTO_ACCEPTOR_VERSION == 1);
+		BUILD_BUG_ON(LNET_PROTO_ACCEPTOR_VERSION != 1);
 
 		cr.acr_magic   = LNET_PROTO_ACCEPTOR_MAGIC;
 		cr.acr_version = LNET_PROTO_ACCEPTOR_VERSION;
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 79f8534d1056..08b38ef67784 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -180,89 +180,89 @@ static void lnet_assert_wire_constants(void)
 	 */
 
 	/* Constants... */
-	CLASSERT(LNET_PROTO_TCP_MAGIC == 0xeebc0ded);
-	CLASSERT(LNET_PROTO_TCP_VERSION_MAJOR == 1);
-	CLASSERT(LNET_PROTO_TCP_VERSION_MINOR == 0);
-	CLASSERT(LNET_MSG_ACK == 0);
-	CLASSERT(LNET_MSG_PUT == 1);
-	CLASSERT(LNET_MSG_GET == 2);
-	CLASSERT(LNET_MSG_REPLY == 3);
-	CLASSERT(LNET_MSG_HELLO == 4);
+	BUILD_BUG_ON(LNET_PROTO_TCP_MAGIC != 0xeebc0ded);
+	BUILD_BUG_ON(LNET_PROTO_TCP_VERSION_MAJOR != 1);
+	BUILD_BUG_ON(LNET_PROTO_TCP_VERSION_MINOR != 0);
+	BUILD_BUG_ON(LNET_MSG_ACK != 0);
+	BUILD_BUG_ON(LNET_MSG_PUT != 1);
+	BUILD_BUG_ON(LNET_MSG_GET != 2);
+	BUILD_BUG_ON(LNET_MSG_REPLY != 3);
+	BUILD_BUG_ON(LNET_MSG_HELLO != 4);
 
 	/* Checks for struct ptl_handle_wire_t */
-	CLASSERT((int)sizeof(struct lnet_handle_wire) == 16);
-	CLASSERT((int)offsetof(struct lnet_handle_wire, wh_interface_cookie) == 0);
-	CLASSERT((int)sizeof(((struct lnet_handle_wire *)0)->wh_interface_cookie) == 8);
-	CLASSERT((int)offsetof(struct lnet_handle_wire, wh_object_cookie) == 8);
-	CLASSERT((int)sizeof(((struct lnet_handle_wire *)0)->wh_object_cookie) == 8);
+	BUILD_BUG_ON((int)sizeof(struct lnet_handle_wire) != 16);
+	BUILD_BUG_ON((int)offsetof(struct lnet_handle_wire, wh_interface_cookie) != 0);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_handle_wire *)0)->wh_interface_cookie) != 8);
+	BUILD_BUG_ON((int)offsetof(struct lnet_handle_wire, wh_object_cookie) != 8);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_handle_wire *)0)->wh_object_cookie) != 8);
 
 	/* Checks for struct struct lnet_magicversion */
-	CLASSERT((int)sizeof(struct lnet_magicversion) == 8);
-	CLASSERT((int)offsetof(struct lnet_magicversion, magic) == 0);
-	CLASSERT((int)sizeof(((struct lnet_magicversion *)0)->magic) == 4);
-	CLASSERT((int)offsetof(struct lnet_magicversion, version_major) == 4);
-	CLASSERT((int)sizeof(((struct lnet_magicversion *)0)->version_major) == 2);
-	CLASSERT((int)offsetof(struct lnet_magicversion, version_minor) == 6);
-	CLASSERT((int)sizeof(((struct lnet_magicversion *)0)->version_minor) == 2);
+	BUILD_BUG_ON((int)sizeof(struct lnet_magicversion) != 8);
+	BUILD_BUG_ON((int)offsetof(struct lnet_magicversion, magic) != 0);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_magicversion *)0)->magic) != 4);
+	BUILD_BUG_ON((int)offsetof(struct lnet_magicversion, version_major) != 4);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_magicversion *)0)->version_major) != 2);
+	BUILD_BUG_ON((int)offsetof(struct lnet_magicversion, version_minor) != 6);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_magicversion *)0)->version_minor) != 2);
 
 	/* Checks for struct struct lnet_hdr */
-	CLASSERT((int)sizeof(struct lnet_hdr) == 72);
-	CLASSERT((int)offsetof(struct lnet_hdr, dest_nid) == 0);
-	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->dest_nid) == 8);
-	CLASSERT((int)offsetof(struct lnet_hdr, src_nid) == 8);
-	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->src_nid) == 8);
-	CLASSERT((int)offsetof(struct lnet_hdr, dest_pid) == 16);
-	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->dest_pid) == 4);
-	CLASSERT((int)offsetof(struct lnet_hdr, src_pid) == 20);
-	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->src_pid) == 4);
-	CLASSERT((int)offsetof(struct lnet_hdr, type) == 24);
-	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->type) == 4);
-	CLASSERT((int)offsetof(struct lnet_hdr, payload_length) == 28);
-	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->payload_length) == 4);
-	CLASSERT((int)offsetof(struct lnet_hdr, msg) == 32);
-	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->msg) == 40);
+	BUILD_BUG_ON((int)sizeof(struct lnet_hdr) != 72);
+	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, dest_nid) != 0);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->dest_nid) != 8);
+	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, src_nid) != 8);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->src_nid) != 8);
+	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, dest_pid) != 16);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->dest_pid) != 4);
+	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, src_pid) != 20);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->src_pid) != 4);
+	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, type) != 24);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->type) != 4);
+	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, payload_length) != 28);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->payload_length) != 4);
+	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, msg) != 32);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg) != 40);
 
 	/* Ack */
-	CLASSERT((int)offsetof(struct lnet_hdr, msg.ack.dst_wmd) == 32);
-	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->msg.ack.dst_wmd) == 16);
-	CLASSERT((int)offsetof(struct lnet_hdr, msg.ack.match_bits) == 48);
-	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->msg.ack.match_bits) == 8);
-	CLASSERT((int)offsetof(struct lnet_hdr, msg.ack.mlength) == 56);
-	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->msg.ack.mlength) == 4);
+	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, msg.ack.dst_wmd) != 32);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg.ack.dst_wmd) != 16);
+	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, msg.ack.match_bits) != 48);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg.ack.match_bits) != 8);
+	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, msg.ack.mlength) != 56);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg.ack.mlength) != 4);
 
 	/* Put */
-	CLASSERT((int)offsetof(struct lnet_hdr, msg.put.ack_wmd) == 32);
-	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->msg.put.ack_wmd) == 16);
-	CLASSERT((int)offsetof(struct lnet_hdr, msg.put.match_bits) == 48);
-	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->msg.put.match_bits) == 8);
-	CLASSERT((int)offsetof(struct lnet_hdr, msg.put.hdr_data) == 56);
-	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->msg.put.hdr_data) == 8);
-	CLASSERT((int)offsetof(struct lnet_hdr, msg.put.ptl_index) == 64);
-	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->msg.put.ptl_index) == 4);
-	CLASSERT((int)offsetof(struct lnet_hdr, msg.put.offset) == 68);
-	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->msg.put.offset) == 4);
+	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, msg.put.ack_wmd) != 32);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg.put.ack_wmd) != 16);
+	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, msg.put.match_bits) != 48);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg.put.match_bits) != 8);
+	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, msg.put.hdr_data) != 56);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg.put.hdr_data) != 8);
+	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, msg.put.ptl_index) != 64);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg.put.ptl_index) != 4);
+	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, msg.put.offset) != 68);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg.put.offset) != 4);
 
 	/* Get */
-	CLASSERT((int)offsetof(struct lnet_hdr, msg.get.return_wmd) == 32);
-	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->msg.get.return_wmd) == 16);
-	CLASSERT((int)offsetof(struct lnet_hdr, msg.get.match_bits) == 48);
-	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->msg.get.match_bits) == 8);
-	CLASSERT((int)offsetof(struct lnet_hdr, msg.get.ptl_index) == 56);
-	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->msg.get.ptl_index) == 4);
-	CLASSERT((int)offsetof(struct lnet_hdr, msg.get.src_offset) == 60);
-	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->msg.get.src_offset) == 4);
-	CLASSERT((int)offsetof(struct lnet_hdr, msg.get.sink_length) == 64);
-	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->msg.get.sink_length) == 4);
+	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, msg.get.return_wmd) != 32);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg.get.return_wmd) != 16);
+	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, msg.get.match_bits) != 48);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg.get.match_bits) != 8);
+	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, msg.get.ptl_index) != 56);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg.get.ptl_index) != 4);
+	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, msg.get.src_offset) != 60);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg.get.src_offset) != 4);
+	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, msg.get.sink_length) != 64);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg.get.sink_length) != 4);
 
 	/* Reply */
-	CLASSERT((int)offsetof(struct lnet_hdr, msg.reply.dst_wmd) == 32);
-	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->msg.reply.dst_wmd) == 16);
+	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, msg.reply.dst_wmd) != 32);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg.reply.dst_wmd) != 16);
 
 	/* Hello */
-	CLASSERT((int)offsetof(struct lnet_hdr, msg.hello.incarnation) == 32);
-	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->msg.hello.incarnation) == 8);
-	CLASSERT((int)offsetof(struct lnet_hdr, msg.hello.type) == 40);
-	CLASSERT((int)sizeof(((struct lnet_hdr *)0)->msg.hello.type) == 4);
+	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, msg.hello.incarnation) != 32);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg.hello.incarnation) != 8);
+	BUILD_BUG_ON((int)offsetof(struct lnet_hdr, msg.hello.type) != 40);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_hdr *)0)->msg.hello.type) != 4);
 }
 
 static lnd_t *
diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
index 4e6dd5149b4f..654a7b262188 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -97,7 +97,7 @@ lnet_ipif_query(char *name, int *up, __u32 *ip, __u32 *mask)
 		return -EINVAL;
 	}
 
-	CLASSERT(sizeof(ifr.ifr_name) >= IFNAMSIZ);
+	BUILD_BUG_ON(sizeof(ifr.ifr_name) < IFNAMSIZ);
 
 	if (strlen(name) > sizeof(ifr.ifr_name) - 1)
 		return -E2BIG;
diff --git a/drivers/staging/lustre/lnet/lnet/net_fault.c b/drivers/staging/lustre/lnet/lnet/net_fault.c
index bb6e4576a119..18183cbb9859 100644
--- a/drivers/staging/lustre/lnet/lnet/net_fault.c
+++ b/drivers/staging/lustre/lnet/lnet/net_fault.c
@@ -997,10 +997,10 @@ lnet_fault_ctl(int opc, struct libcfs_ioctl_data *data)
 int
 lnet_fault_init(void)
 {
-	CLASSERT(LNET_PUT_BIT == 1 << LNET_MSG_PUT);
-	CLASSERT(LNET_ACK_BIT == 1 << LNET_MSG_ACK);
-	CLASSERT(LNET_GET_BIT == 1 << LNET_MSG_GET);
-	CLASSERT(LNET_REPLY_BIT == 1 << LNET_MSG_REPLY);
+	BUILD_BUG_ON(LNET_PUT_BIT != 1 << LNET_MSG_PUT);
+	BUILD_BUG_ON(LNET_ACK_BIT != 1 << LNET_MSG_ACK);
+	BUILD_BUG_ON(LNET_GET_BIT != 1 << LNET_MSG_GET);
+	BUILD_BUG_ON(LNET_REPLY_BIT != 1 << LNET_MSG_REPLY);
 
 	mutex_init(&delay_dd.dd_mutex);
 	spin_lock_init(&delay_dd.dd_lock);
diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
index 65f65a3fc901..a19e1405e3ea 100644
--- a/drivers/staging/lustre/lnet/lnet/router_proc.c
+++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
@@ -139,7 +139,7 @@ static int proc_lnet_routes(struct ctl_table *table, int write,
 	int ver;
 	int off;
 
-	CLASSERT(sizeof(loff_t) >= 4);
+	BUILD_BUG_ON(sizeof(loff_t) < 4);
 
 	off = LNET_PROC_HOFF_GET(*ppos);
 	ver = LNET_PROC_VER_GET(*ppos);
@@ -404,7 +404,7 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
 	int rc = 0;
 	int len;
 
-	CLASSERT(LNET_PROC_HASH_BITS >= LNET_PEER_HASH_BITS);
+	BUILD_BUG_ON(LNET_PROC_HASH_BITS < LNET_PEER_HASH_BITS);
 	LASSERT(!write);
 
 	if (!*lenp)
diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index dc685610c4c4..9a91090819da 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -2311,7 +2311,7 @@ struct cl_io *cl_io_top(struct cl_io *io);
 do {									\
 	typeof(foo_io) __foo_io = (foo_io);				\
 									\
-	CLASSERT(offsetof(typeof(*__foo_io), base) == 0);		\
+	BUILD_BUG_ON(offsetof(typeof(*__foo_io), base) != 0);		\
 	memset(&__foo_io->base + 1, 0,					\
 	       sizeof(*__foo_io) - sizeof(__foo_io->base));		\
 } while (0)
diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index 69b281252db0..f283a036a748 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -1120,7 +1120,7 @@ struct lu_context_key {
 	{							 \
 		type *value;				      \
 								  \
-		CLASSERT(PAGE_SIZE >= sizeof(*value));        \
+		BUILD_BUG_ON(PAGE_SIZE < sizeof(*value));        \
 								  \
 		value = kzalloc(sizeof(*value), GFP_NOFS);	\
 		if (!value)				\
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 411eb0dc7f38..ef7311b4fbde 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -315,8 +315,8 @@ struct ptlrpc_client {
 union ptlrpc_async_args {
 	/**
 	 * Scratchpad for passing args to completion interpreter. Users
-	 * cast to the struct of their choosing, and CLASSERT that this is
-	 * big enough.  For _tons_ of context, kmalloc a struct and store
+	 * cast to the struct of their choosing, and BUILD_BUG_ON oversized
+	 * arguments.  For _tons_ of context, kmalloc a struct and store
 	 * a pointer to it here.  The pointer_arg ensures this struct is at
 	 * least big enough for that.
 	 */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index c1f8693f94a5..ebfda368b057 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -1972,7 +1972,7 @@ static int replay_one_lock(struct obd_import *imp, struct ldlm_lock *lock)
 	LDLM_DEBUG(lock, "replaying lock:");
 
 	atomic_inc(&req->rq_import->imp_replay_inflight);
-	CLASSERT(sizeof(*aa) <= sizeof(req->rq_async_args));
+	BUILD_BUG_ON(sizeof(*aa) > sizeof(req->rq_async_args));
 	aa = ptlrpc_req_async_args(req);
 	aa->lock_handle = body->lock_handle[0];
 	req->rq_interpret_reply = (ptlrpc_interpterer_t)replay_lock_interpret;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index b22f5bae7201..d16f5e95ef0b 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -1368,7 +1368,7 @@ void ldlm_resource_dump(int level, struct ldlm_resource *res)
 	struct ldlm_lock *lock;
 	unsigned int granted = 0;
 
-	CLASSERT(RES_NAME_SIZE == 4);
+	BUILD_BUG_ON(RES_NAME_SIZE != 4);
 
 	if (!((libcfs_debug | D_ERROR) & level))
 		return;
diff --git a/drivers/staging/lustre/lustre/llite/super25.c b/drivers/staging/lustre/lustre/llite/super25.c
index 106cd00910a7..4759802e062d 100644
--- a/drivers/staging/lustre/lustre/llite/super25.c
+++ b/drivers/staging/lustre/lustre/llite/super25.c
@@ -88,7 +88,7 @@ static int __init lustre_init(void)
 	struct timespec64 ts;
 	int i, rc, seed[2];
 
-	CLASSERT(sizeof(LUSTRE_VOLATILE_HDR) == LUSTRE_VOLATILE_HDR_LEN + 1);
+	BUILD_BUG_ON(sizeof(LUSTRE_VOLATILE_HDR) != LUSTRE_VOLATILE_HDR_LEN + 1);
 
 	/* print an address of _any_ initialized kernel symbol from this
 	 * module, to allow debugging with gdb that doesn't support data
diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index 12c129f7e4ad..3669ea77ee93 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -391,7 +391,7 @@ struct vvp_pgcache_id {
 
 static void vvp_pgcache_id_unpack(loff_t pos, struct vvp_pgcache_id *id)
 {
-	CLASSERT(sizeof(pos) == sizeof(__u64));
+	BUILD_BUG_ON(sizeof(pos) != sizeof(__u64));
 
 	id->vpi_index  = pos & 0xffffffff;
 	id->vpi_depth  = (pos >> PGC_DEPTH_SHIFT) & 0xf;
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index 68fa2de7a6ff..2e1bd47337fd 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -136,7 +136,7 @@ ssize_t lov_lsm_pack(const struct lov_stripe_md *lsm, void *buf,
 	lmmv1->lmm_layout_gen = cpu_to_le16(lsm->lsm_layout_gen);
 
 	if (lsm->lsm_magic == LOV_MAGIC_V3) {
-		CLASSERT(sizeof(lsm->lsm_pool_name) ==
+		BUILD_BUG_ON(sizeof(lsm->lsm_pool_name) !=
 			 sizeof(lmmv3->lmm_pool_name));
 		strlcpy(lmmv3->lmm_pool_name, lsm->lsm_pool_name,
 			sizeof(lmmv3->lmm_pool_name));
@@ -357,8 +357,8 @@ int lov_getstripe(struct lov_object *obj, struct lov_stripe_md *lsm,
 
 	/* FIXME: Bug 1185 - copy fields properly when structs change */
 	/* struct lov_user_md_v3 and struct lov_mds_md_v3 must be the same */
-	CLASSERT(sizeof(lum) == sizeof(struct lov_mds_md_v3));
-	CLASSERT(sizeof(lum.lmm_objects[0]) == sizeof(lmmk->lmm_objects[0]));
+	BUILD_BUG_ON(sizeof(lum) != sizeof(struct lov_mds_md_v3));
+	BUILD_BUG_ON(sizeof(lum.lmm_objects[0]) != sizeof(lmmk->lmm_objects[0]));
 
 	if (cpu_to_le32(LOV_MAGIC) != LOV_MAGIC &&
 	    (lmmk->lmm_magic == cpu_to_le32(LOV_MAGIC_V1) ||
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
index f35e1f9afdef..b1853ff7f8b9 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
@@ -125,7 +125,7 @@ void mdc_create_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	char			*tmp;
 	__u64			 flags;
 
-	CLASSERT(sizeof(struct mdt_rec_reint) == sizeof(struct mdt_rec_create));
+	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) != sizeof(struct mdt_rec_create));
 	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
 
 	rec->cr_opcode   = REINT_CREATE;
@@ -189,7 +189,7 @@ void mdc_open_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	char *tmp;
 	__u64 cr_flags;
 
-	CLASSERT(sizeof(struct mdt_rec_reint) == sizeof(struct mdt_rec_create));
+	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) != sizeof(struct mdt_rec_create));
 	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
 
 	/* XXX do something about time, uid, gid */
@@ -313,7 +313,7 @@ void mdc_setattr_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 	struct mdt_rec_setattr *rec;
 	struct lov_user_md *lum = NULL;
 
-	CLASSERT(sizeof(struct mdt_rec_reint) ==
+	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) !=
 					sizeof(struct mdt_rec_setattr));
 	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
 	mdc_setattr_pack_rec(rec, op_data);
@@ -336,7 +336,7 @@ void mdc_unlink_pack(struct ptlrpc_request *req, struct md_op_data *op_data)
 {
 	struct mdt_rec_unlink *rec;
 
-	CLASSERT(sizeof(struct mdt_rec_reint) == sizeof(struct mdt_rec_unlink));
+	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) != sizeof(struct mdt_rec_unlink));
 	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
 
 	rec->ul_opcode   = op_data->op_cli_flags & CLI_RM_ENTRY ?
@@ -359,7 +359,7 @@ void mdc_link_pack(struct ptlrpc_request *req, struct md_op_data *op_data)
 {
 	struct mdt_rec_link *rec;
 
-	CLASSERT(sizeof(struct mdt_rec_reint) == sizeof(struct mdt_rec_link));
+	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) != sizeof(struct mdt_rec_link));
 	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
 
 	rec->lk_opcode   = REINT_LINK;
@@ -407,7 +407,7 @@ void mdc_rename_pack(struct ptlrpc_request *req, struct md_op_data *op_data,
 {
 	struct mdt_rec_rename *rec;
 
-	CLASSERT(sizeof(struct mdt_rec_reint) == sizeof(struct mdt_rec_rename));
+	BUILD_BUG_ON(sizeof(struct mdt_rec_reint) != sizeof(struct mdt_rec_rename));
 	rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
 
 	/* XXX do something about time, uid, gid */
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index 54ebb9952d66..41165f4536d0 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -1196,7 +1196,7 @@ int mdc_intent_getattr_async(struct obd_export *exp,
 		return rc;
 	}
 
-	CLASSERT(sizeof(*ga) <= sizeof(req->rq_async_args));
+	BUILD_BUG_ON(sizeof(*ga) > sizeof(req->rq_async_args));
 	ga = ptlrpc_req_async_args(req);
 	ga->ga_exp = exp;
 	ga->ga_minfo = minfo;
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 2cfd913f9bc5..b0dfb6b62a44 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -295,7 +295,7 @@ static int mdc_xattr_common(struct obd_export *exp,
 	if (opcode == MDS_REINT) {
 		struct mdt_rec_setxattr *rec;
 
-		CLASSERT(sizeof(struct mdt_rec_setxattr) ==
+		BUILD_BUG_ON(sizeof(struct mdt_rec_setxattr) !=
 			 sizeof(struct mdt_rec_reint));
 		rec = req_capsule_client_get(&req->rq_pill, &RMF_REC_REINT);
 		rec->sx_opcode = REINT_SETXATTR;
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index 9402dfc01668..9f08f0308a57 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -699,7 +699,7 @@ static int osc_io_data_version_start(const struct lu_env *env,
 
 	ptlrpc_request_set_replen(req);
 	req->rq_interpret_reply = osc_data_version_interpret;
-	CLASSERT(sizeof(*dva) <= sizeof(req->rq_async_args));
+	BUILD_BUG_ON(sizeof(*dva) > sizeof(req->rq_async_args));
 	dva = ptlrpc_req_async_args(req);
 	dva->dva_oio = oio;
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 3efae759bdfa..f7352560bbe0 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -251,7 +251,7 @@ int osc_setattr_async(struct obd_export *exp, struct obdo *oa,
 		req->rq_interpret_reply =
 			(ptlrpc_interpterer_t)osc_setattr_interpret;
 
-		CLASSERT(sizeof(*sa) <= sizeof(req->rq_async_args));
+		BUILD_BUG_ON(sizeof(*sa) > sizeof(req->rq_async_args));
 		sa = ptlrpc_req_async_args(req);
 		sa->sa_oa = oa;
 		sa->sa_upcall = upcall;
@@ -349,7 +349,7 @@ int osc_punch_base(struct obd_export *exp, struct obdo *oa,
 	ptlrpc_request_set_replen(req);
 
 	req->rq_interpret_reply = (ptlrpc_interpterer_t)osc_setattr_interpret;
-	CLASSERT(sizeof(*sa) <= sizeof(req->rq_async_args));
+	BUILD_BUG_ON(sizeof(*sa) > sizeof(req->rq_async_args));
 	sa = ptlrpc_req_async_args(req);
 	sa->sa_oa = oa;
 	sa->sa_upcall = upcall;
@@ -430,7 +430,7 @@ int osc_sync_base(struct osc_object *obj, struct obdo *oa,
 	ptlrpc_request_set_replen(req);
 	req->rq_interpret_reply = osc_sync_interpret;
 
-	CLASSERT(sizeof(*fa) <= sizeof(req->rq_async_args));
+	BUILD_BUG_ON(sizeof(*fa) > sizeof(req->rq_async_args));
 	fa = ptlrpc_req_async_args(req);
 	fa->fa_obj = obj;
 	fa->fa_oa = oa;
@@ -1171,7 +1171,7 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 	}
 	ptlrpc_request_set_replen(req);
 
-	CLASSERT(sizeof(*aa) <= sizeof(req->rq_async_args));
+	BUILD_BUG_ON(sizeof(*aa) > sizeof(req->rq_async_args));
 	aa = ptlrpc_req_async_args(req);
 	aa->aa_oa = oa;
 	aa->aa_requested_nob = requested_nob;
@@ -1758,7 +1758,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	cl_req_attr_set(env, osc2cl(obj), crattr);
 	lustre_msg_set_jobid(req->rq_reqmsg, crattr->cra_jobid);
 
-	CLASSERT(sizeof(*aa) <= sizeof(req->rq_async_args));
+	BUILD_BUG_ON(sizeof(*aa) > sizeof(req->rq_async_args));
 	aa = ptlrpc_req_async_args(req);
 	INIT_LIST_HEAD(&aa->aa_oaps);
 	list_splice_init(&rpc_list, &aa->aa_oaps);
@@ -2039,7 +2039,7 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 		if (!rc) {
 			struct osc_enqueue_args *aa;
 
-			CLASSERT(sizeof(*aa) <= sizeof(req->rq_async_args));
+			BUILD_BUG_ON(sizeof(*aa) > sizeof(req->rq_async_args));
 			aa = ptlrpc_req_async_args(req);
 			aa->oa_exp = exp;
 			aa->oa_mode = einfo->ei_mode;
@@ -2196,7 +2196,7 @@ static int osc_statfs_async(struct obd_export *exp,
 	}
 
 	req->rq_interpret_reply = (ptlrpc_interpterer_t)osc_statfs_interpret;
-	CLASSERT(sizeof(*aa) <= sizeof(req->rq_async_args));
+	BUILD_BUG_ON(sizeof(*aa) > sizeof(req->rq_async_args));
 	aa = ptlrpc_req_async_args(req);
 	aa->aa_oi = oinfo;
 
@@ -2401,7 +2401,7 @@ static int osc_set_info_async(const struct lu_env *env, struct obd_export *exp,
 		struct osc_brw_async_args *aa;
 		struct obdo *oa;
 
-		CLASSERT(sizeof(*aa) <= sizeof(req->rq_async_args));
+		BUILD_BUG_ON(sizeof(*aa) > sizeof(req->rq_async_args));
 		aa = ptlrpc_req_async_args(req);
 		oa = kmem_cache_zalloc(obdo_cachep, GFP_NOFS);
 		if (!oa) {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 804741362bc0..44d8eab6f5af 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -3070,7 +3070,7 @@ void ptlrpc_init_xid(void)
 	}
 
 	/* Always need to be aligned to a power-of-two for multi-bulk BRW */
-	CLASSERT(((PTLRPC_BULK_OPS_COUNT - 1) & PTLRPC_BULK_OPS_COUNT) == 0);
+	BUILD_BUG_ON(((PTLRPC_BULK_OPS_COUNT - 1) & PTLRPC_BULK_OPS_COUNT) != 0);
 	ptlrpc_last_xid &= PTLRPC_BULK_OPS_MASK;
 }
 
@@ -3256,7 +3256,7 @@ void *ptlrpcd_alloc_work(struct obd_import *imp,
 	req->rq_no_resend = 1;
 	req->rq_pill.rc_fmt = (void *)&worker_format;
 
-	CLASSERT(sizeof(*args) <= sizeof(req->rq_async_args));
+	BUILD_BUG_ON(sizeof(*args) > sizeof(req->rq_async_args));
 	args = ptlrpc_req_async_args(req);
 	args->cb = cb;
 	args->cbdata = cbdata;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index e8280194001c..93e172fe9ce4 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -703,7 +703,7 @@ int ptlrpc_connect_import(struct obd_import *imp)
 	ptlrpc_request_set_replen(request);
 	request->rq_interpret_reply = ptlrpc_connect_interpret;
 
-	CLASSERT(sizeof(*aa) <= sizeof(request->rq_async_args));
+	BUILD_BUG_ON(sizeof(*aa) > sizeof(request->rq_async_args));
 	aa = ptlrpc_req_async_args(request);
 	memset(aa, 0, sizeof(*aa));
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index b1170277fd84..9456a1825918 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -510,8 +510,8 @@ static int lustre_unpack_msg_v2(struct lustre_msg_v2 *m, int len)
 		__swab32s(&m->lm_repsize);
 		__swab32s(&m->lm_cksum);
 		__swab32s(&m->lm_flags);
-		CLASSERT(offsetof(typeof(*m), lm_padding_2) != 0);
-		CLASSERT(offsetof(typeof(*m), lm_padding_3) != 0);
+		BUILD_BUG_ON(offsetof(typeof(*m), lm_padding_2) == 0);
+		BUILD_BUG_ON(offsetof(typeof(*m), lm_padding_3) == 0);
 	}
 
 	required_len = lustre_msg_hdr_size_v2(m->lm_bufcount);
@@ -1526,18 +1526,18 @@ void lustre_swab_ptlrpc_body(struct ptlrpc_body *b)
 	__swab64s(&b->pb_pre_versions[2]);
 	__swab64s(&b->pb_pre_versions[3]);
 	__swab64s(&b->pb_mbits);
-	CLASSERT(offsetof(typeof(*b), pb_padding0) != 0);
-	CLASSERT(offsetof(typeof(*b), pb_padding1) != 0);
-	CLASSERT(offsetof(typeof(*b), pb_padding64_0) != 0);
-	CLASSERT(offsetof(typeof(*b), pb_padding64_1) != 0);
-	CLASSERT(offsetof(typeof(*b), pb_padding64_2) != 0);
+	BUILD_BUG_ON(offsetof(typeof(*b), pb_padding0) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*b), pb_padding1) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*b), pb_padding64_0) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*b), pb_padding64_1) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*b), pb_padding64_2) == 0);
 	/* While we need to maintain compatibility between
 	 * clients and servers without ptlrpc_body_v2 (< 2.3)
 	 * do not swab any fields beyond pb_jobid, as we are
 	 * using this swab function for both ptlrpc_body
 	 * and ptlrpc_body_v2.
 	 */
-	CLASSERT(offsetof(typeof(*b), pb_jobid) != 0);
+	BUILD_BUG_ON(offsetof(typeof(*b), pb_jobid) == 0);
 }
 
 void lustre_swab_connect(struct obd_connect_data *ocd)
@@ -1568,23 +1568,23 @@ void lustre_swab_connect(struct obd_connect_data *ocd)
 		__swab64s(&ocd->ocd_maxbytes);
 	if (ocd->ocd_connect_flags & OBD_CONNECT_MULTIMODRPCS)
 		__swab16s(&ocd->ocd_maxmodrpcs);
-	CLASSERT(offsetof(typeof(*ocd), padding0));
-	CLASSERT(offsetof(typeof(*ocd), padding1) != 0);
+	BUILD_BUG_ON(!offsetof(typeof(*ocd), padding0));
+	BUILD_BUG_ON(offsetof(typeof(*ocd), padding1) == 0);
 	if (ocd->ocd_connect_flags & OBD_CONNECT_FLAGS2)
 		__swab64s(&ocd->ocd_connect_flags2);
-	CLASSERT(offsetof(typeof(*ocd), padding3) != 0);
-	CLASSERT(offsetof(typeof(*ocd), padding4) != 0);
-	CLASSERT(offsetof(typeof(*ocd), padding5) != 0);
-	CLASSERT(offsetof(typeof(*ocd), padding6) != 0);
-	CLASSERT(offsetof(typeof(*ocd), padding7) != 0);
-	CLASSERT(offsetof(typeof(*ocd), padding8) != 0);
-	CLASSERT(offsetof(typeof(*ocd), padding9) != 0);
-	CLASSERT(offsetof(typeof(*ocd), paddingA) != 0);
-	CLASSERT(offsetof(typeof(*ocd), paddingB) != 0);
-	CLASSERT(offsetof(typeof(*ocd), paddingC) != 0);
-	CLASSERT(offsetof(typeof(*ocd), paddingD) != 0);
-	CLASSERT(offsetof(typeof(*ocd), paddingE) != 0);
-	CLASSERT(offsetof(typeof(*ocd), paddingF) != 0);
+	BUILD_BUG_ON(offsetof(typeof(*ocd), padding3) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*ocd), padding4) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*ocd), padding5) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*ocd), padding6) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*ocd), padding7) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*ocd), padding8) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*ocd), padding9) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*ocd), paddingA) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*ocd), paddingB) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*ocd), paddingC) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*ocd), paddingD) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*ocd), paddingE) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*ocd), paddingF) == 0);
 }
 
 static void lustre_swab_obdo(struct obdo *o)
@@ -1614,9 +1614,9 @@ static void lustre_swab_obdo(struct obdo *o)
 	__swab32s(&o->o_uid_h);
 	__swab32s(&o->o_gid_h);
 	__swab64s(&o->o_data_version);
-	CLASSERT(offsetof(typeof(*o), o_padding_4) != 0);
-	CLASSERT(offsetof(typeof(*o), o_padding_5) != 0);
-	CLASSERT(offsetof(typeof(*o), o_padding_6) != 0);
+	BUILD_BUG_ON(offsetof(typeof(*o), o_padding_4) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*o), o_padding_5) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*o), o_padding_6) == 0);
 }
 
 void lustre_swab_obd_statfs(struct obd_statfs *os)
@@ -1632,15 +1632,15 @@ void lustre_swab_obd_statfs(struct obd_statfs *os)
 	__swab32s(&os->os_namelen);
 	__swab64s(&os->os_maxbytes);
 	__swab32s(&os->os_state);
-	CLASSERT(offsetof(typeof(*os), os_fprecreated) != 0);
-	CLASSERT(offsetof(typeof(*os), os_spare2) != 0);
-	CLASSERT(offsetof(typeof(*os), os_spare3) != 0);
-	CLASSERT(offsetof(typeof(*os), os_spare4) != 0);
-	CLASSERT(offsetof(typeof(*os), os_spare5) != 0);
-	CLASSERT(offsetof(typeof(*os), os_spare6) != 0);
-	CLASSERT(offsetof(typeof(*os), os_spare7) != 0);
-	CLASSERT(offsetof(typeof(*os), os_spare8) != 0);
-	CLASSERT(offsetof(typeof(*os), os_spare9) != 0);
+	BUILD_BUG_ON(offsetof(typeof(*os), os_fprecreated) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*os), os_spare2) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*os), os_spare3) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*os), os_spare4) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*os), os_spare5) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*os), os_spare6) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*os), os_spare7) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*os), os_spare8) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*os), os_spare9) == 0);
 }
 
 void lustre_swab_obd_ioobj(struct obd_ioobj *ioo)
@@ -1680,7 +1680,7 @@ void lustre_swab_gl_desc(union ldlm_gl_desc *desc)
 	__swab64s(&desc->lquota_desc.gl_hardlimit);
 	__swab64s(&desc->lquota_desc.gl_softlimit);
 	__swab64s(&desc->lquota_desc.gl_time);
-	CLASSERT(offsetof(typeof(desc->lquota_desc), gl_pad2) != 0);
+	BUILD_BUG_ON(offsetof(typeof(desc->lquota_desc), gl_pad2) == 0);
 }
 
 void lustre_swab_ost_lvb_v1(struct ost_lvb_v1 *lvb)
@@ -1739,24 +1739,24 @@ void lustre_swab_mdt_body(struct mdt_body *b)
 	__swab32s(&b->mbo_flags);
 	__swab32s(&b->mbo_rdev);
 	__swab32s(&b->mbo_nlink);
-	CLASSERT(offsetof(typeof(*b), mbo_unused2) != 0);
+	BUILD_BUG_ON(offsetof(typeof(*b), mbo_unused2) == 0);
 	__swab32s(&b->mbo_suppgid);
 	__swab32s(&b->mbo_eadatasize);
 	__swab32s(&b->mbo_aclsize);
 	__swab32s(&b->mbo_max_mdsize);
-	CLASSERT(offsetof(typeof(*b), mbo_unused3));
+	BUILD_BUG_ON(!offsetof(typeof(*b), mbo_unused3));
 	__swab32s(&b->mbo_uid_h);
 	__swab32s(&b->mbo_gid_h);
-	CLASSERT(offsetof(typeof(*b), mbo_padding_5) != 0);
+	BUILD_BUG_ON(offsetof(typeof(*b), mbo_padding_5) == 0);
 }
 
 void lustre_swab_mdt_ioepoch(struct mdt_ioepoch *b)
 {
 	/* handle is opaque */
 	/* mio_handle is opaque */
-	CLASSERT(offsetof(typeof(*b), mio_unused1));
-	CLASSERT(offsetof(typeof(*b), mio_unused2));
-	CLASSERT(offsetof(typeof(*b), mio_padding));
+	BUILD_BUG_ON(!offsetof(typeof(*b), mio_unused1));
+	BUILD_BUG_ON(!offsetof(typeof(*b), mio_unused2));
+	BUILD_BUG_ON(!offsetof(typeof(*b), mio_padding));
 }
 
 void lustre_swab_mgs_target_info(struct mgs_target_info *mti)
@@ -1769,7 +1769,7 @@ void lustre_swab_mgs_target_info(struct mgs_target_info *mti)
 	__swab32s(&mti->mti_flags);
 	__swab32s(&mti->mti_instance);
 	__swab32s(&mti->mti_nid_count);
-	CLASSERT(sizeof(lnet_nid_t) == sizeof(__u64));
+	BUILD_BUG_ON(sizeof(lnet_nid_t) != sizeof(__u64));
 	for (i = 0; i < MTI_NIDS_MAX; i++)
 		__swab64s(&mti->mti_nids[i]);
 }
@@ -1785,13 +1785,13 @@ void lustre_swab_mgs_nidtbl_entry(struct mgs_nidtbl_entry *entry)
 
 	/* mne_nid_(count|type) must be one byte size because we're gonna
 	 * access it w/o swapping. */
-	CLASSERT(sizeof(entry->mne_nid_count) == sizeof(__u8));
-	CLASSERT(sizeof(entry->mne_nid_type) == sizeof(__u8));
+	BUILD_BUG_ON(sizeof(entry->mne_nid_count) != sizeof(__u8));
+	BUILD_BUG_ON(sizeof(entry->mne_nid_type) != sizeof(__u8));
 
 	/* remove this assertion if ipv6 is supported. */
 	LASSERT(entry->mne_nid_type == 0);
 	for (i = 0; i < entry->mne_nid_count; i++) {
-		CLASSERT(sizeof(lnet_nid_t) == sizeof(__u64));
+		BUILD_BUG_ON(sizeof(lnet_nid_t) != sizeof(__u64));
 		__swab64s(&entry->u.nids[i]);
 	}
 }
@@ -1829,7 +1829,7 @@ static void lustre_swab_obd_dqblk(struct obd_dqblk *b)
 	__swab64s(&b->dqb_btime);
 	__swab64s(&b->dqb_itime);
 	__swab32s(&b->dqb_valid);
-	CLASSERT(offsetof(typeof(*b), dqb_padding) != 0);
+	BUILD_BUG_ON(offsetof(typeof(*b), dqb_padding) == 0);
 }
 
 void lustre_swab_obd_quotactl(struct obd_quotactl *q)
@@ -1900,7 +1900,7 @@ void lustre_swab_mdt_rec_reint (struct mdt_rec_reint *rr)
 	__swab32s(&rr->rr_flags_h);
 	__swab32s(&rr->rr_umask);
 
-	CLASSERT(offsetof(typeof(*rr), rr_padding_4) != 0);
+	BUILD_BUG_ON(offsetof(typeof(*rr), rr_padding_4) == 0);
 };
 
 void lustre_swab_lov_desc(struct lov_desc *ld)
@@ -1949,7 +1949,7 @@ void lustre_swab_lmv_user_md(struct lmv_user_md *lum)
 	__swab32s(&lum->lum_stripe_offset);
 	__swab32s(&lum->lum_hash_type);
 	__swab32s(&lum->lum_type);
-	CLASSERT(offsetof(typeof(*lum), lum_padding1));
+	BUILD_BUG_ON(!offsetof(typeof(*lum), lum_padding1));
 }
 EXPORT_SYMBOL(lustre_swab_lmv_user_md);
 
@@ -2038,7 +2038,7 @@ void lustre_swab_ldlm_intent(struct ldlm_intent *i)
 static void lustre_swab_ldlm_resource_desc(struct ldlm_resource_desc *r)
 {
 	__swab32s(&r->lr_type);
-	CLASSERT(offsetof(typeof(*r), lr_padding) != 0);
+	BUILD_BUG_ON(offsetof(typeof(*r), lr_padding) == 0);
 	lustre_swab_ldlm_res_id(&r->lr_name);
 }
 
@@ -2061,7 +2061,7 @@ void lustre_swab_ldlm_request(struct ldlm_request *rq)
 void lustre_swab_ldlm_reply(struct ldlm_reply *r)
 {
 	__swab32s(&r->lock_flags);
-	CLASSERT(offsetof(typeof(*r), lock_padding) != 0);
+	BUILD_BUG_ON(offsetof(typeof(*r), lock_padding) == 0);
 	lustre_swab_ldlm_lock_desc(&r->lock_desc);
 	/* lock_handle opaque */
 	__swab64s(&r->lock_policy_res1);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pers.c b/drivers/staging/lustre/lustre/ptlrpc/pers.c
index 94e9fa85d774..601acb84f343 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pers.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pers.c
@@ -45,7 +45,7 @@ void ptlrpc_fill_bulk_md(lnet_md_t *md, struct ptlrpc_bulk_desc *desc,
 {
 	int offset = mdidx * LNET_MAX_IOV;
 
-	CLASSERT(PTLRPC_MAX_BRW_PAGES < LI_POISON);
+	BUILD_BUG_ON(PTLRPC_MAX_BRW_PAGES >= LI_POISON);
 
 	LASSERT(mdidx < desc->bd_md_max_brw);
 	LASSERT(desc->bd_iov_count <= PTLRPC_MAX_BRW_PAGES);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index a04e36cf6dd4..367f7e24e3da 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -61,7 +61,7 @@ void lustre_assert_wire_constants(void)
 		 MDS_DIR_END_OFF);
 	LASSERTF(DEAD_HANDLE_MAGIC == 0xdeadbeefcafebabeULL, "found 0x%.16llxULL\n",
 		 DEAD_HANDLE_MAGIC);
-	CLASSERT(MTI_NAME_MAXLEN == 64);
+	BUILD_BUG_ON(MTI_NAME_MAXLEN != 64);
 	LASSERTF(OST_REPLY == 0, "found %lld\n",
 		 (long long)OST_REPLY);
 	LASSERTF(OST_GETATTR == 1, "found %lld\n",
@@ -306,16 +306,16 @@ void lustre_assert_wire_constants(void)
 		 (long long)LCK_MAXMODE);
 	LASSERTF(LCK_MODE_NUM == 8, "found %lld\n",
 		 (long long)LCK_MODE_NUM);
-	CLASSERT(LDLM_PLAIN == 10);
-	CLASSERT(LDLM_EXTENT == 11);
-	CLASSERT(LDLM_FLOCK == 12);
-	CLASSERT(LDLM_IBITS == 13);
-	CLASSERT(LDLM_MAX_TYPE == 14);
-	CLASSERT(LUSTRE_RES_ID_SEQ_OFF == 0);
-	CLASSERT(LUSTRE_RES_ID_VER_OID_OFF == 1);
-	CLASSERT(LUSTRE_RES_ID_QUOTA_SEQ_OFF == 2);
-	CLASSERT(LUSTRE_RES_ID_QUOTA_VER_OID_OFF == 3);
-	CLASSERT(LUSTRE_RES_ID_HSH_OFF == 3);
+	BUILD_BUG_ON(LDLM_PLAIN != 10);
+	BUILD_BUG_ON(LDLM_EXTENT != 11);
+	BUILD_BUG_ON(LDLM_FLOCK != 12);
+	BUILD_BUG_ON(LDLM_IBITS != 13);
+	BUILD_BUG_ON(LDLM_MAX_TYPE != 14);
+	BUILD_BUG_ON(LUSTRE_RES_ID_SEQ_OFF != 0);
+	BUILD_BUG_ON(LUSTRE_RES_ID_VER_OID_OFF != 1);
+	BUILD_BUG_ON(LUSTRE_RES_ID_QUOTA_SEQ_OFF != 2);
+	BUILD_BUG_ON(LUSTRE_RES_ID_QUOTA_VER_OID_OFF != 3);
+	BUILD_BUG_ON(LUSTRE_RES_ID_HSH_OFF != 3);
 	LASSERTF(OBD_PING == 400, "found %lld\n",
 		 (long long)OBD_PING);
 	LASSERTF(OBD_LOG_CANCEL == 401, "found %lld\n",
@@ -661,7 +661,7 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct ptlrpc_body_v3, pb_slv));
 	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_slv) == 8, "found %lld\n",
 		 (long long)(int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_slv));
-	CLASSERT(PTLRPC_NUM_VERSIONS == 4);
+	BUILD_BUG_ON(PTLRPC_NUM_VERSIONS != 4);
 	LASSERTF((int)offsetof(struct ptlrpc_body_v3, pb_pre_versions) == 88, "found %lld\n",
 		 (long long)(int)offsetof(struct ptlrpc_body_v3, pb_pre_versions));
 	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_pre_versions) == 32, "found %lld\n",
@@ -682,7 +682,7 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct ptlrpc_body_v3, pb_padding64_2));
 	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding64_2) == 8, "found %lld\n",
 		 (long long)(int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding64_2));
-	CLASSERT(LUSTRE_JOBID_SIZE == 32);
+	BUILD_BUG_ON(LUSTRE_JOBID_SIZE != 32);
 	LASSERTF((int)offsetof(struct ptlrpc_body_v3, pb_jobid) == 152, "found %lld\n",
 		 (long long)(int)offsetof(struct ptlrpc_body_v3, pb_jobid));
 	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_jobid) == 32, "found %lld\n",
@@ -1319,27 +1319,27 @@ void lustre_assert_wire_constants(void)
 		 OBD_MD_FLGETATTRLOCK);
 	LASSERTF(OBD_MD_FLDATAVERSION == (0x0010000000000000ULL), "found 0x%.16llxULL\n",
 		 OBD_MD_FLDATAVERSION);
-	CLASSERT(OBD_FL_INLINEDATA == 0x00000001);
-	CLASSERT(OBD_FL_OBDMDEXISTS == 0x00000002);
-	CLASSERT(OBD_FL_DELORPHAN == 0x00000004);
-	CLASSERT(OBD_FL_NORPC == 0x00000008);
-	CLASSERT(OBD_FL_IDONLY == 0x00000010);
-	CLASSERT(OBD_FL_RECREATE_OBJS == 0x00000020);
-	CLASSERT(OBD_FL_DEBUG_CHECK == 0x00000040);
-	CLASSERT(OBD_FL_NO_USRQUOTA == 0x00000100);
-	CLASSERT(OBD_FL_NO_GRPQUOTA == 0x00000200);
-	CLASSERT(OBD_FL_CREATE_CROW == 0x00000400);
-	CLASSERT(OBD_FL_SRVLOCK == 0x00000800);
-	CLASSERT(OBD_FL_CKSUM_CRC32 == 0x00001000);
-	CLASSERT(OBD_FL_CKSUM_ADLER == 0x00002000);
-	CLASSERT(OBD_FL_CKSUM_CRC32C == 0x00004000);
-	CLASSERT(OBD_FL_CKSUM_RSVD2 == 0x00008000);
-	CLASSERT(OBD_FL_CKSUM_RSVD3 == 0x00010000);
-	CLASSERT(OBD_FL_SHRINK_GRANT == 0x00020000);
-	CLASSERT(OBD_FL_MMAP == 0x00040000);
-	CLASSERT(OBD_FL_RECOV_RESEND == 0x00080000);
-	CLASSERT(OBD_FL_NOSPC_BLK == 0x00100000);
-	CLASSERT(OBD_FL_LOCAL_MASK == 0xf0000000);
+	BUILD_BUG_ON(OBD_FL_INLINEDATA != 0x00000001);
+	BUILD_BUG_ON(OBD_FL_OBDMDEXISTS != 0x00000002);
+	BUILD_BUG_ON(OBD_FL_DELORPHAN != 0x00000004);
+	BUILD_BUG_ON(OBD_FL_NORPC != 0x00000008);
+	BUILD_BUG_ON(OBD_FL_IDONLY != 0x00000010);
+	BUILD_BUG_ON(OBD_FL_RECREATE_OBJS != 0x00000020);
+	BUILD_BUG_ON(OBD_FL_DEBUG_CHECK != 0x00000040);
+	BUILD_BUG_ON(OBD_FL_NO_USRQUOTA != 0x00000100);
+	BUILD_BUG_ON(OBD_FL_NO_GRPQUOTA != 0x00000200);
+	BUILD_BUG_ON(OBD_FL_CREATE_CROW != 0x00000400);
+	BUILD_BUG_ON(OBD_FL_SRVLOCK != 0x00000800);
+	BUILD_BUG_ON(OBD_FL_CKSUM_CRC32 != 0x00001000);
+	BUILD_BUG_ON(OBD_FL_CKSUM_ADLER != 0x00002000);
+	BUILD_BUG_ON(OBD_FL_CKSUM_CRC32C != 0x00004000);
+	BUILD_BUG_ON(OBD_FL_CKSUM_RSVD2 != 0x00008000);
+	BUILD_BUG_ON(OBD_FL_CKSUM_RSVD3 != 0x00010000);
+	BUILD_BUG_ON(OBD_FL_SHRINK_GRANT != 0x00020000);
+	BUILD_BUG_ON(OBD_FL_MMAP != 0x00040000);
+	BUILD_BUG_ON(OBD_FL_RECOV_RESEND != 0x00080000);
+	BUILD_BUG_ON(OBD_FL_NOSPC_BLK != 0x00100000);
+	BUILD_BUG_ON(OBD_FL_LOCAL_MASK != 0xf0000000);
 
 	/* Checks for struct lov_ost_data_v1 */
 	LASSERTF((int)sizeof(struct lov_ost_data_v1) == 24, "found %lld\n",
@@ -1388,7 +1388,7 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct lov_mds_md_v1, lmm_objects[0]));
 	LASSERTF((int)sizeof(((struct lov_mds_md_v1 *)0)->lmm_objects[0]) == 24, "found %lld\n",
 		 (long long)(int)sizeof(((struct lov_mds_md_v1 *)0)->lmm_objects[0]));
-	CLASSERT(LOV_MAGIC_V1 == (0x0BD10000 | 0x0BD0));
+	BUILD_BUG_ON(LOV_MAGIC_V1 != (0x0BD10000 | 0x0BD0));
 
 	/* Checks for struct lov_mds_md_v3 */
 	LASSERTF((int)sizeof(struct lov_mds_md_v3) == 48, "found %lld\n",
@@ -1417,7 +1417,7 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct lov_mds_md_v3, lmm_layout_gen));
 	LASSERTF((int)sizeof(((struct lov_mds_md_v3 *)0)->lmm_layout_gen) == 2, "found %lld\n",
 		 (long long)(int)sizeof(((struct lov_mds_md_v3 *)0)->lmm_layout_gen));
-	CLASSERT(LOV_MAXPOOLNAME == 15);
+	BUILD_BUG_ON(LOV_MAXPOOLNAME != 15);
 	LASSERTF((int)offsetof(struct lov_mds_md_v3, lmm_pool_name[16]) == 48, "found %lld\n",
 		 (long long)(int)offsetof(struct lov_mds_md_v3, lmm_pool_name[16]));
 	LASSERTF((int)sizeof(((struct lov_mds_md_v3 *)0)->lmm_pool_name[16]) == 1, "found %lld\n",
@@ -1426,7 +1426,7 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct lov_mds_md_v3, lmm_objects[0]));
 	LASSERTF((int)sizeof(((struct lov_mds_md_v3 *)0)->lmm_objects[0]) == 24, "found %lld\n",
 		 (long long)(int)sizeof(((struct lov_mds_md_v3 *)0)->lmm_objects[0]));
-	CLASSERT(LOV_MAGIC_V3 == (0x0BD30000 | 0x0BD0));
+	BUILD_BUG_ON(LOV_MAGIC_V3 != (0x0BD30000 | 0x0BD0));
 	LASSERTF(LOV_PATTERN_RAID0 == 0x00000001UL, "found 0x%.8xUL\n",
 		 (unsigned int)LOV_PATTERN_RAID0);
 	LASSERTF(LOV_PATTERN_RAID1 == 0x00000002UL, "found 0x%.8xUL\n",
@@ -1479,11 +1479,11 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct lmv_mds_md_v1, lmv_stripe_fids[0]));
 	LASSERTF((int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_stripe_fids[0]) == 16, "found %lld\n",
 		 (long long)(int)sizeof(((struct lmv_mds_md_v1 *)0)->lmv_stripe_fids[0]));
-	CLASSERT(LMV_MAGIC_V1 == 0x0CD20CD0);
-	CLASSERT(LMV_MAGIC_STRIPE == 0x0CD40CD0);
-	CLASSERT(LMV_HASH_TYPE_MASK == 0x0000ffff);
-	CLASSERT(LMV_HASH_FLAG_MIGRATION == 0x80000000);
-	CLASSERT(LMV_HASH_FLAG_DEAD == 0x40000000);
+	BUILD_BUG_ON(LMV_MAGIC_V1 != 0x0CD20CD0);
+	BUILD_BUG_ON(LMV_MAGIC_STRIPE != 0x0CD40CD0);
+	BUILD_BUG_ON(LMV_HASH_TYPE_MASK != 0x0000ffff);
+	BUILD_BUG_ON(LMV_HASH_FLAG_MIGRATION != 0x80000000);
+	BUILD_BUG_ON(LMV_HASH_FLAG_DEAD != 0x40000000);
 
 	/* Checks for struct obd_statfs */
 	LASSERTF((int)sizeof(struct obd_statfs) == 144, "found %lld\n",
@@ -2761,12 +2761,12 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct lov_desc, ld_uuid));
 	LASSERTF((int)sizeof(((struct lov_desc *)0)->ld_uuid) == 40, "found %lld\n",
 		 (long long)(int)sizeof(((struct lov_desc *)0)->ld_uuid));
-	CLASSERT(LOV_DESC_MAGIC == 0xB0CCDE5C);
+	BUILD_BUG_ON(LOV_DESC_MAGIC != 0xB0CCDE5C);
 
 	/* Checks for struct ldlm_res_id */
 	LASSERTF((int)sizeof(struct ldlm_res_id) == 32, "found %lld\n",
 		 (long long)(int)sizeof(struct ldlm_res_id));
-	CLASSERT(RES_NAME_SIZE == 4);
+	BUILD_BUG_ON(RES_NAME_SIZE != 4);
 	LASSERTF((int)offsetof(struct ldlm_res_id, name[4]) == 32, "found %lld\n",
 		 (long long)(int)offsetof(struct ldlm_res_id, name[4]));
 	LASSERTF((int)sizeof(((struct ldlm_res_id *)0)->name[4]) == 8, "found %lld\n",
@@ -3037,7 +3037,7 @@ void lustre_assert_wire_constants(void)
 	/* Checks for struct mgs_send_param */
 	LASSERTF((int)sizeof(struct mgs_send_param) == 1024, "found %lld\n",
 		 (long long)(int)sizeof(struct mgs_send_param));
-	CLASSERT(MGS_PARAM_MAXLEN == 1024);
+	BUILD_BUG_ON(MGS_PARAM_MAXLEN != 1024);
 	LASSERTF((int)offsetof(struct mgs_send_param, mgs_param[1024]) == 1024, "found %lld\n",
 		 (long long)(int)offsetof(struct mgs_send_param, mgs_param[1024]));
 	LASSERTF((int)sizeof(((struct mgs_send_param *)0)->mgs_param[1024]) == 1, "found %lld\n",
@@ -3090,16 +3090,16 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct llog_logid, lgl_ogen));
 	LASSERTF((int)sizeof(((struct llog_logid *)0)->lgl_ogen) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct llog_logid *)0)->lgl_ogen));
-	CLASSERT(OST_SZ_REC == 274730752);
-	CLASSERT(MDS_UNLINK_REC == 274801668);
-	CLASSERT(MDS_UNLINK64_REC == 275325956);
-	CLASSERT(MDS_SETATTR64_REC == 275325953);
-	CLASSERT(OBD_CFG_REC == 274857984);
-	CLASSERT(LLOG_GEN_REC == 274989056);
-	CLASSERT(CHANGELOG_REC == 275120128);
-	CLASSERT(CHANGELOG_USER_REC == 275185664);
-	CLASSERT(LLOG_HDR_MAGIC == 275010873);
-	CLASSERT(LLOG_LOGID_MAGIC == 275010875);
+	BUILD_BUG_ON(OST_SZ_REC != 274730752);
+	BUILD_BUG_ON(MDS_UNLINK_REC != 274801668);
+	BUILD_BUG_ON(MDS_UNLINK64_REC != 275325956);
+	BUILD_BUG_ON(MDS_SETATTR64_REC != 275325953);
+	BUILD_BUG_ON(OBD_CFG_REC != 274857984);
+	BUILD_BUG_ON(LLOG_GEN_REC != 274989056);
+	BUILD_BUG_ON(CHANGELOG_REC != 275120128);
+	BUILD_BUG_ON(CHANGELOG_USER_REC != 275185664);
+	BUILD_BUG_ON(LLOG_HDR_MAGIC != 275010873);
+	BUILD_BUG_ON(LLOG_LOGID_MAGIC != 275010875);
 
 	/* Checks for struct llog_catid */
 	LASSERTF((int)sizeof(struct llog_catid) == 32, "found %lld\n",
@@ -3519,30 +3519,30 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct llogd_body, lgd_cur_offset));
 	LASSERTF((int)sizeof(((struct llogd_body *)0)->lgd_cur_offset) == 8, "found %lld\n",
 		 (long long)(int)sizeof(((struct llogd_body *)0)->lgd_cur_offset));
-	CLASSERT(LLOG_ORIGIN_HANDLE_CREATE == 501);
-	CLASSERT(LLOG_ORIGIN_HANDLE_NEXT_BLOCK == 502);
-	CLASSERT(LLOG_ORIGIN_HANDLE_READ_HEADER == 503);
-	CLASSERT(LLOG_ORIGIN_HANDLE_WRITE_REC == 504);
-	CLASSERT(LLOG_ORIGIN_HANDLE_CLOSE == 505);
-	CLASSERT(LLOG_ORIGIN_CONNECT == 506);
-	CLASSERT(LLOG_CATINFO == 507);
-	CLASSERT(LLOG_ORIGIN_HANDLE_PREV_BLOCK == 508);
-	CLASSERT(LLOG_ORIGIN_HANDLE_DESTROY == 509);
-	CLASSERT(LLOG_FIRST_OPC == 501);
-	CLASSERT(LLOG_LAST_OPC == 510);
-	CLASSERT(LLOG_CONFIG_ORIG_CTXT == 0);
-	CLASSERT(LLOG_CONFIG_REPL_CTXT == 1);
-	CLASSERT(LLOG_MDS_OST_ORIG_CTXT == 2);
-	CLASSERT(LLOG_MDS_OST_REPL_CTXT == 3);
-	CLASSERT(LLOG_SIZE_ORIG_CTXT == 4);
-	CLASSERT(LLOG_SIZE_REPL_CTXT == 5);
-	CLASSERT(LLOG_TEST_ORIG_CTXT == 8);
-	CLASSERT(LLOG_TEST_REPL_CTXT == 9);
-	CLASSERT(LLOG_CHANGELOG_ORIG_CTXT == 12);
-	CLASSERT(LLOG_CHANGELOG_REPL_CTXT == 13);
-	CLASSERT(LLOG_CHANGELOG_USER_ORIG_CTXT == 14);
-	CLASSERT(LLOG_AGENT_ORIG_CTXT == 15);
-	CLASSERT(LLOG_MAX_CTXTS == 16);
+	BUILD_BUG_ON(LLOG_ORIGIN_HANDLE_CREATE != 501);
+	BUILD_BUG_ON(LLOG_ORIGIN_HANDLE_NEXT_BLOCK != 502);
+	BUILD_BUG_ON(LLOG_ORIGIN_HANDLE_READ_HEADER != 503);
+	BUILD_BUG_ON(LLOG_ORIGIN_HANDLE_WRITE_REC != 504);
+	BUILD_BUG_ON(LLOG_ORIGIN_HANDLE_CLOSE != 505);
+	BUILD_BUG_ON(LLOG_ORIGIN_CONNECT != 506);
+	BUILD_BUG_ON(LLOG_CATINFO != 507);
+	BUILD_BUG_ON(LLOG_ORIGIN_HANDLE_PREV_BLOCK != 508);
+	BUILD_BUG_ON(LLOG_ORIGIN_HANDLE_DESTROY != 509);
+	BUILD_BUG_ON(LLOG_FIRST_OPC != 501);
+	BUILD_BUG_ON(LLOG_LAST_OPC != 510);
+	BUILD_BUG_ON(LLOG_CONFIG_ORIG_CTXT != 0);
+	BUILD_BUG_ON(LLOG_CONFIG_REPL_CTXT != 1);
+	BUILD_BUG_ON(LLOG_MDS_OST_ORIG_CTXT != 2);
+	BUILD_BUG_ON(LLOG_MDS_OST_REPL_CTXT != 3);
+	BUILD_BUG_ON(LLOG_SIZE_ORIG_CTXT != 4);
+	BUILD_BUG_ON(LLOG_SIZE_REPL_CTXT != 5);
+	BUILD_BUG_ON(LLOG_TEST_ORIG_CTXT != 8);
+	BUILD_BUG_ON(LLOG_TEST_REPL_CTXT != 9);
+	BUILD_BUG_ON(LLOG_CHANGELOG_ORIG_CTXT != 12);
+	BUILD_BUG_ON(LLOG_CHANGELOG_REPL_CTXT != 13);
+	BUILD_BUG_ON(LLOG_CHANGELOG_USER_ORIG_CTXT != 14);
+	BUILD_BUG_ON(LLOG_AGENT_ORIG_CTXT != 15);
+	BUILD_BUG_ON(LLOG_MAX_CTXTS != 16);
 
 	/* Checks for struct llogd_conn_body */
 	LASSERTF((int)sizeof(struct llogd_conn_body) == 40, "found %lld\n",
@@ -3659,7 +3659,7 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct lustre_capa, lc_expiry));
 	LASSERTF((int)sizeof(((struct lustre_capa *)0)->lc_expiry) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct lustre_capa *)0)->lc_expiry));
-	CLASSERT(CAPA_HMAC_MAX_LEN == 64);
+	BUILD_BUG_ON(CAPA_HMAC_MAX_LEN != 64);
 	LASSERTF((int)offsetof(struct lustre_capa, lc_hmac[64]) == 120, "found %lld\n",
 		 (long long)(int)offsetof(struct lustre_capa, lc_hmac[64]));
 	LASSERTF((int)sizeof(((struct lustre_capa *)0)->lc_hmac[64]) == 1, "found %lld\n",
@@ -3680,7 +3680,7 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct lustre_capa_key, lk_padding));
 	LASSERTF((int)sizeof(((struct lustre_capa_key *)0)->lk_padding) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct lustre_capa_key *)0)->lk_padding));
-	CLASSERT(CAPA_HMAC_KEY_MAX_LEN == 56);
+	BUILD_BUG_ON(CAPA_HMAC_KEY_MAX_LEN != 56);
 	LASSERTF((int)offsetof(struct lustre_capa_key, lk_key[56]) == 72, "found %lld\n",
 		 (long long)(int)offsetof(struct lustre_capa_key, lk_key[56]));
 	LASSERTF((int)sizeof(((struct lustre_capa_key *)0)->lk_key[56]) == 1, "found %lld\n",
@@ -3741,9 +3741,9 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct fiemap, fm_extents));
 	LASSERTF((int)sizeof(((struct fiemap *)0)->fm_extents) == 0, "found %lld\n",
 		 (long long)(int)sizeof(((struct fiemap *)0)->fm_extents));
-	CLASSERT(FIEMAP_FLAG_SYNC == 0x00000001);
-	CLASSERT(FIEMAP_FLAG_XATTR == 0x00000002);
-	CLASSERT(FIEMAP_FLAG_DEVICE_ORDER == 0x40000000);
+	BUILD_BUG_ON(FIEMAP_FLAG_SYNC != 0x00000001);
+	BUILD_BUG_ON(FIEMAP_FLAG_XATTR != 0x00000002);
+	BUILD_BUG_ON(FIEMAP_FLAG_DEVICE_ORDER != 0x40000000);
 
 	/* Checks for struct fiemap_extent */
 	LASSERTF((int)sizeof(struct fiemap_extent) == 56, "found %lld\n",
@@ -3768,18 +3768,18 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct fiemap_extent, fe_reserved[0]));
 	LASSERTF((int)sizeof(((struct fiemap_extent *)0)->fe_reserved[0]) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct fiemap_extent *)0)->fe_reserved[0]));
-	CLASSERT(FIEMAP_EXTENT_LAST == 0x00000001);
-	CLASSERT(FIEMAP_EXTENT_UNKNOWN == 0x00000002);
-	CLASSERT(FIEMAP_EXTENT_DELALLOC == 0x00000004);
-	CLASSERT(FIEMAP_EXTENT_ENCODED == 0x00000008);
-	CLASSERT(FIEMAP_EXTENT_DATA_ENCRYPTED == 0x00000080);
-	CLASSERT(FIEMAP_EXTENT_NOT_ALIGNED == 0x00000100);
-	CLASSERT(FIEMAP_EXTENT_DATA_INLINE == 0x00000200);
-	CLASSERT(FIEMAP_EXTENT_DATA_TAIL == 0x00000400);
-	CLASSERT(FIEMAP_EXTENT_UNWRITTEN == 0x00000800);
-	CLASSERT(FIEMAP_EXTENT_MERGED == 0x00001000);
-	CLASSERT(FIEMAP_EXTENT_NO_DIRECT == 0x40000000);
-	CLASSERT(FIEMAP_EXTENT_NET == 0x80000000);
+	BUILD_BUG_ON(FIEMAP_EXTENT_LAST != 0x00000001);
+	BUILD_BUG_ON(FIEMAP_EXTENT_UNKNOWN != 0x00000002);
+	BUILD_BUG_ON(FIEMAP_EXTENT_DELALLOC != 0x00000004);
+	BUILD_BUG_ON(FIEMAP_EXTENT_ENCODED != 0x00000008);
+	BUILD_BUG_ON(FIEMAP_EXTENT_DATA_ENCRYPTED != 0x00000080);
+	BUILD_BUG_ON(FIEMAP_EXTENT_NOT_ALIGNED != 0x00000100);
+	BUILD_BUG_ON(FIEMAP_EXTENT_DATA_INLINE != 0x00000200);
+	BUILD_BUG_ON(FIEMAP_EXTENT_DATA_TAIL != 0x00000400);
+	BUILD_BUG_ON(FIEMAP_EXTENT_UNWRITTEN != 0x00000800);
+	BUILD_BUG_ON(FIEMAP_EXTENT_MERGED != 0x00001000);
+	BUILD_BUG_ON(FIEMAP_EXTENT_NO_DIRECT != 0x40000000);
+	BUILD_BUG_ON(FIEMAP_EXTENT_NET != 0x80000000);
 
 	/* Checks for type posix_acl_xattr_entry */
 	LASSERTF((int)sizeof(struct posix_acl_xattr_entry) == 8, "found %lld\n",
@@ -3828,7 +3828,7 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct link_ea_header, padding2));
 	LASSERTF((int)sizeof(((struct link_ea_header *)0)->padding2) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct link_ea_header *)0)->padding2));
-	CLASSERT(LINK_EA_MAGIC == 0x11EAF1DFUL);
+	BUILD_BUG_ON(LINK_EA_MAGIC != 0x11EAF1DFUL);
 
 	/* Checks for struct link_ea_entry */
 	LASSERTF((int)sizeof(struct link_ea_entry) == 18, "found %lld\n",
-- 
2.9.0
