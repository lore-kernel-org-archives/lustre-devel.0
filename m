From: James Simmons <jsimmons@infradead.org>
Date: Fri, 12 Feb 2016 12:06:00 -0500
Subject: [lustre-devel] [PATCH 02/11] staging: lustre: format properly all
	comment blocks for LNet core
In-Reply-To: <1455296769-5481-1-git-send-email-jsimmons@infradead.org>
References: <1455296769-5481-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1455296769-5481-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Dorkin <oleg.dorkin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

In several places in the LNet core comment blocks don't follow the
linux kernel style. This patch cleans those problems up.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/api.h    |   22 ++-
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    9 +-
 .../staging/lustre/include/linux/lnet/lib-types.h  |   54 +++--
 drivers/staging/lustre/include/linux/lnet/nidstr.h |    6 +-
 .../staging/lustre/include/linux/lnet/socklnd.h    |    6 +-
 drivers/staging/lustre/include/linux/lnet/types.h  |   47 +++--
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   90 ++++++---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |  181 ++++++++++------
 .../lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c  |    6 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |  218 +++++++++++++-------
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |   25 ++-
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |  215 +++++++++++++-------
 .../lustre/lnet/klnds/socklnd/socklnd_lib.c        |   76 +++++---
 .../lustre/lnet/klnds/socklnd/socklnd_modparams.c  |    6 +-
 .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |    6 +-
 drivers/staging/lustre/lnet/lnet/acceptor.c        |   21 ++-
 drivers/staging/lustre/lnet/lnet/api-ni.c          |   68 ++++---
 drivers/staging/lustre/lnet/lnet/lib-eq.c          |   37 +++--
 drivers/staging/lustre/lnet/lnet/lib-md.c          |   30 ++-
 drivers/staging/lustre/lnet/lnet/lib-move.c        |  140 ++++++++-----
 drivers/staging/lustre/lnet/lnet/lib-msg.c         |   43 +++--
 drivers/staging/lustre/lnet/lnet/lib-ptl.c         |   48 +++--
 drivers/staging/lustre/lnet/lnet/lib-socket.c      |   19 +-
 drivers/staging/lustre/lnet/lnet/module.c          |   12 +-
 drivers/staging/lustre/lnet/lnet/nidstrings.c      |   12 +-
 drivers/staging/lustre/lnet/lnet/router.c          |   92 +++++---
 drivers/staging/lustre/lnet/lnet/router_proc.c     |   26 ++-
 drivers/staging/lustre/lnet/selftest/brw_test.c    |   18 +-
 drivers/staging/lustre/lnet/selftest/conrpc.c      |   19 +-
 drivers/staging/lustre/lnet/selftest/console.c     |   12 +-
 drivers/staging/lustre/lnet/selftest/framework.c   |   30 ++-
 drivers/staging/lustre/lnet/selftest/rpc.c         |   91 ++++++---
 drivers/staging/lustre/lnet/selftest/rpc.h         |    6 +-
 33 files changed, 1092 insertions(+), 599 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/api.h b/drivers/staging/lustre/include/linux/lnet/api.h
index fa5fad3..cb0d6b4 100644
--- a/drivers/staging/lustre/include/linux/lnet/api.h
+++ b/drivers/staging/lustre/include/linux/lnet/api.h
@@ -48,7 +48,8 @@
 
 /** \defgroup lnet_init_fini Initialization and cleanup
  * The LNet must be properly initialized before any LNet calls can be made.
- * @{ */
+ * @{
+ */
 int LNetNIInit(lnet_pid_t requested_pid);
 int LNetNIFini(void);
 /** @} lnet_init_fini */
@@ -71,7 +72,8 @@ int LNetNIFini(void);
  * it's an entry in the portals table of a process.
  *
  * \see LNetMEAttach
- * @{ */
+ * @{
+ */
 int LNetGetId(unsigned int index, lnet_process_id_t *id);
 int LNetDist(lnet_nid_t nid, lnet_nid_t *srcnid, __u32 *order);
 void LNetSnprintHandle(char *str, int str_len, lnet_handle_any_t handle);
@@ -89,7 +91,8 @@ void LNetSnprintHandle(char *str, int str_len, lnet_handle_any_t handle);
  * incoming requests based on process ID or the match bits provided in the
  * request. MEs can be dynamically inserted into a match list by LNetMEAttach()
  * and LNetMEInsert(), and removed from its list by LNetMEUnlink().
- * @{ */
+ * @{
+ */
 int LNetMEAttach(unsigned int      portal,
 		 lnet_process_id_t match_id_in,
 		 __u64		   match_bits_in,
@@ -120,7 +123,8 @@ int LNetMEUnlink(lnet_handle_me_t current_in);
  * The LNet API provides two operations to create MDs: LNetMDAttach()
  * and LNetMDBind(); one operation to unlink and release the resources
  * associated with a MD: LNetMDUnlink().
- * @{ */
+ * @{
+ */
 int LNetMDAttach(lnet_handle_me_t  current_in,
 		 lnet_md_t	   md_in,
 		 lnet_unlink_t     unlink_in,
@@ -154,7 +158,8 @@ int LNetMDUnlink(lnet_handle_md_t md_in);
  * event from an EQ, and LNetEQWait() can be used to block a process until
  * an EQ has at least one event. LNetEQPoll() can be used to test or wait
  * on multiple EQs.
- * @{ */
+ * @{
+ */
 int LNetEQAlloc(unsigned int       count_in,
 		lnet_eq_handler_t  handler,
 		lnet_handle_eq_t  *handle_out);
@@ -172,7 +177,8 @@ int LNetEQPoll(lnet_handle_eq_t *eventqs_in,
  *
  * The LNet API provides two data movement operations: LNetPut()
  * and LNetGet().
- * @{ */
+ * @{
+ */
 int LNetPut(lnet_nid_t	      self,
 	    lnet_handle_md_t  md_in,
 	    lnet_ack_req_t    ack_req_in,
@@ -192,8 +198,8 @@ int LNetGet(lnet_nid_t	      self,
 
 /** \defgroup lnet_misc Miscellaneous operations.
  * Miscellaneous operations.
- * @{ */
-
+ * @{
+ */
 int LNetSetLazyPortal(int portal);
 int LNetClearLazyPortal(int portal);
 int LNetCtl(unsigned int cmd, void *arg);
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 40acddd..c3bf5e8 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -79,7 +79,8 @@ static inline int lnet_md_exhausted(lnet_libmd_t *md)
 
 static inline int lnet_md_unlinkable(lnet_libmd_t *md)
 {
-	/* Should unlink md when its refcount is 0 and either:
+	/*
+	 * Should unlink md when its refcount is 0 and either:
 	 *  - md has been flagged for deletion (by auto unlink or
 	 *    LNetM[DE]Unlink, in the latter case md may not be exhausted).
 	 *  - auto unlink is on and md is exhausted.
@@ -102,8 +103,10 @@ lnet_cpt_of_cookie(__u64 cookie)
 {
 	unsigned int cpt = (cookie >> LNET_COOKIE_TYPE_BITS) & LNET_CPT_MASK;
 
-	/* LNET_CPT_NUMBER doesn't have to be power2, which means we can
-	 * get illegal cpt from it's invalid cookie */
+	/*
+	 * LNET_CPT_NUMBER doesn't have to be power2, which means we can
+	 * get illegal cpt from it's invalid cookie
+	 */
 	return cpt < LNET_CPT_NUMBER ? cpt : cpt % LNET_CPT_NUMBER;
 }
 
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 3bb9468..55d9d43 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -85,8 +85,7 @@ typedef struct lnet_msg {
 	unsigned int	msg_receiving:1;	/* being received */
 	unsigned int	msg_txcredit:1;		/* taken an NI send credit */
 	unsigned int	msg_peertxcredit:1;	/* taken a peer send credit */
-	unsigned int	msg_rtrcredit:1;	/* taken a global
-						   router credit */
+	unsigned int	msg_rtrcredit:1;	/* taken a global router credit */
 	unsigned int	msg_peerrtrcredit:1;	/* taken a peer router credit */
 	unsigned int	msg_onactivelist:1;	/* on the activelist */
 
@@ -190,7 +189,8 @@ typedef struct lnet_lnd {
 	void (*lnd_shutdown)(struct lnet_ni *ni);
 	int  (*lnd_ctl)(struct lnet_ni *ni, unsigned int cmd, void *arg);
 
-	/* In data movement APIs below, payload buffers are described as a set
+	/*
+	 * In data movement APIs below, payload buffers are described as a set
 	 * of 'niov' fragments which are...
 	 * EITHER
 	 *    in virtual memory (struct iovec *iov != NULL)
@@ -201,30 +201,36 @@ typedef struct lnet_lnd {
 	 * fragments to start from
 	 */
 
-	/* Start sending a preformatted message.  'private' is NULL for PUT and
+	/*
+	 * Start sending a preformatted message.  'private' is NULL for PUT and
 	 * GET messages; otherwise this is a response to an incoming message
 	 * and 'private' is the 'private' passed to lnet_parse().  Return
 	 * non-zero for immediate failure, otherwise complete later with
-	 * lnet_finalize() */
+	 * lnet_finalize()
+	 */
 	int (*lnd_send)(struct lnet_ni *ni, void *private, lnet_msg_t *msg);
 
-	/* Start receiving 'mlen' bytes of payload data, skipping the following
+	/*
+	 * Start receiving 'mlen' bytes of payload data, skipping the following
 	 * 'rlen' - 'mlen' bytes. 'private' is the 'private' passed to
 	 * lnet_parse().  Return non-zero for immediate failure, otherwise
 	 * complete later with lnet_finalize().  This also gives back a receive
-	 * credit if the LND does flow control. */
+	 * credit if the LND does flow control.
+	 */
 	int (*lnd_recv)(struct lnet_ni *ni, void *private, lnet_msg_t *msg,
 			int delayed, unsigned int niov,
 			struct kvec *iov, lnet_kiov_t *kiov,
 			unsigned int offset, unsigned int mlen,
 			unsigned int rlen);
 
-	/* lnet_parse() has had to delay processing of this message
+	/*
+	 * lnet_parse() has had to delay processing of this message
 	 * (e.g. waiting for a forwarding buffer or send credits).  Give the
 	 * LND a chance to free urgently needed resources.  If called, return 0
 	 * for success and do NOT give back a receive credit; that has to wait
 	 * until lnd_recv() gets called.  On failure return < 0 and
-	 * release resources; lnd_recv() will not be called. */
+	 * release resources; lnd_recv() will not be called.
+	 */
 	int (*lnd_eager_recv)(struct lnet_ni *ni, void *private,
 			      lnet_msg_t *msg, void **new_privatep);
 
@@ -272,8 +278,10 @@ typedef struct lnet_ni {
 
 #define LNET_PROTO_PING_MATCHBITS	0x8000000000000000LL
 
-/* NB: value of these features equal to LNET_PROTO_PING_VERSION_x
- * of old LNet, so there shouldn't be any compatibility issue */
+/*
+ * NB: value of these features equal to LNET_PROTO_PING_VERSION_x
+ * of old LNet, so there shouldn't be any compatibility issue
+ */
 #define LNET_PING_FEAT_INVAL		(0)		/* no feature */
 #define LNET_PING_FEAT_BASE		(1 << 0)	/* just a ping */
 #define LNET_PING_FEAT_NI_STATUS	(1 << 1)	/* return NI status */
@@ -347,8 +355,10 @@ struct lnet_peer_table {
 	struct list_head	*pt_hash;	/* NID->peer hash */
 };
 
-/* peer aliveness is enabled only on routers for peers in a network where the
- * lnet_ni_t::ni_peertimeout has been set to a positive value */
+/*
+ * peer aliveness is enabled only on routers for peers in a network where the
+ * lnet_ni_t::ni_peertimeout has been set to a positive value
+ */
 #define lnet_peer_aliveness_enabled(lp) (the_lnet.ln_routing != 0 && \
 					 (lp)->lp_ni->ni_peertimeout > 0)
 
@@ -433,12 +443,16 @@ struct lnet_match_info {
 #define LNET_MT_HASH_BITS		8
 #define LNET_MT_HASH_SIZE		(1 << LNET_MT_HASH_BITS)
 #define LNET_MT_HASH_MASK		(LNET_MT_HASH_SIZE - 1)
-/* we allocate (LNET_MT_HASH_SIZE + 1) entries for lnet_match_table::mt_hash,
- * the last entry is reserved for MEs with ignore-bits */
+/*
+ * we allocate (LNET_MT_HASH_SIZE + 1) entries for lnet_match_table::mt_hash,
+ * the last entry is reserved for MEs with ignore-bits
+ */
 #define LNET_MT_HASH_IGNORE		LNET_MT_HASH_SIZE
-/* __u64 has 2^6 bits, so need 2^(LNET_MT_HASH_BITS - LNET_MT_BITS_U64) which
+/*
+ * __u64 has 2^6 bits, so need 2^(LNET_MT_HASH_BITS - LNET_MT_BITS_U64) which
  * is 4 __u64s as bit-map, and add an extra __u64 (only use one bit) for the
- * ME-list with ignore-bits, which is mtable::mt_hash[LNET_MT_HASH_IGNORE] */
+ * ME-list with ignore-bits, which is mtable::mt_hash[LNET_MT_HASH_IGNORE]
+ */
 #define LNET_MT_BITS_U64		6	/* 2^6 bits */
 #define LNET_MT_EXHAUSTED_BITS		(LNET_MT_HASH_BITS - LNET_MT_BITS_U64)
 #define LNET_MT_EXHAUSTED_BMAP		((1 << LNET_MT_EXHAUSTED_BITS) + 1)
@@ -448,8 +462,10 @@ struct lnet_match_table {
 	/* reserved for upcoming patches, CPU partition ID */
 	unsigned int		 mt_cpt;
 	unsigned int		 mt_portal;	/* portal index */
-	/* match table is set as "enabled" if there's non-exhausted MD
-	 * attached on mt_mhash, it's only valid for wildcard portal */
+	/*
+	 * match table is set as "enabled" if there's non-exhausted MD
+	 * attached on mt_mhash, it's only valid for wildcard portal
+	 */
 	unsigned int		 mt_enabled;
 	/* bitmap to flag whether MEs on mt_hash are exhausted or not */
 	__u64			 mt_exhausted[LNET_MT_EXHAUSTED_BMAP];
diff --git a/drivers/staging/lustre/include/linux/lnet/nidstr.h b/drivers/staging/lustre/include/linux/lnet/nidstr.h
index 4fc9ddc..9a705e1 100644
--- a/drivers/staging/lustre/include/linux/lnet/nidstr.h
+++ b/drivers/staging/lustre/include/linux/lnet/nidstr.h
@@ -34,8 +34,10 @@
  *  Lustre Network Driver types.
  */
 enum {
-	/* Only add to these values (i.e. don't ever change or redefine them):
-	 * network addresses depend on them... */
+	/*
+	 * Only add to these values (i.e. don't ever change or redefine them):
+	 * network addresses depend on them...
+	 */
 	QSWLND		= 1,
 	SOCKLND		= 2,
 	GMLND		= 3,
diff --git a/drivers/staging/lustre/include/linux/lnet/socklnd.h b/drivers/staging/lustre/include/linux/lnet/socklnd.h
index 599c9f6..3df5065 100644
--- a/drivers/staging/lustre/include/linux/lnet/socklnd.h
+++ b/drivers/staging/lustre/include/linux/lnet/socklnd.h
@@ -91,8 +91,10 @@ socklnd_init_msg(ksock_msg_t *msg, int type)
 #define KSOCK_MSG_NOOP	0xC0	/* ksm_u empty */
 #define KSOCK_MSG_LNET	0xC1	/* lnet msg */
 
-/* We need to know this number to parse hello msg from ksocklnd in
- * other LND (usocklnd, for example) */
+/*
+ * We need to know this number to parse hello msg from ksocklnd in
+ * other LND (usocklnd, for example)
+ */
 #define KSOCK_PROTO_V2	2
 #define KSOCK_PROTO_V3	3
 
diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/linux/lnet/types.h
index 1163018..81d01f1 100644
--- a/drivers/staging/lustre/include/linux/lnet/types.h
+++ b/drivers/staging/lustre/include/linux/lnet/types.h
@@ -36,10 +36,12 @@
 #include <linux/types.h>
 
 /** \addtogroup lnet
- * @{ */
+ * @{
+ */
 
 /** \addtogroup lnet_addr
- * @{ */
+ * @{
+ */
 
 /** Portal reserved for LNet's own use.
  * \see lustre/include/lustre/lustre_idl.h for Lustre portal assignments.
@@ -116,10 +118,12 @@ typedef struct {
 	lnet_pid_t	pid;
 } WIRE_ATTR lnet_process_id_packed_t;
 
-/* The wire handle's interface cookie only matches one network interface in
+/*
+ * The wire handle's interface cookie only matches one network interface in
  * one epoch (i.e. new cookie when the interface restarts or the node
  * reboots).  The object cookie only matches one object on that interface
- * during that object's lifetime (i.e. no cookie re-use). */
+ * during that object's lifetime (i.e. no cookie re-use).
+ */
 typedef struct {
 	__u64	wh_interface_cookie;
 	__u64	wh_object_cookie;
@@ -133,10 +137,12 @@ typedef enum {
 	LNET_MSG_HELLO,
 } lnet_msg_type_t;
 
-/* The variant fields of the portals message header are aligned on an 8
+/*
+ * The variant fields of the portals message header are aligned on an 8
  * byte boundary in the message header.  Note that all types used in these
  * wire structs MUST be fixed size and the smaller types are placed at the
- * end. */
+ * end.
+ */
 typedef struct lnet_ack {
 	lnet_handle_wire_t	dst_wmd;
 	__u64			match_bits;
@@ -185,7 +191,8 @@ typedef struct {
 	} msg;
 } WIRE_ATTR lnet_hdr_t;
 
-/* A HELLO message contains a magic number and protocol version
+/*
+ * A HELLO message contains a magic number and protocol version
  * code in the header's dest_nid, the peer's NID in the src_nid, and
  * LNET_MSG_HELLO in the type field.  All other common fields are zero
  * (including payload_size; i.e. no payload).
@@ -208,8 +215,10 @@ typedef struct {
 #define LNET_PROTO_PING_MAGIC		0x70696E67 /* 'ping' */
 
 /* Placeholder for a future "unified" protocol across all LNDs */
-/* Current LNDs that receive a request with this magic will respond with a
- * "stub" reply using their current protocol */
+/*
+ * Current LNDs that receive a request with this magic will respond with a
+ * "stub" reply using their current protocol
+ */
 #define LNET_PROTO_MAGIC		0x45726963 /* ! */
 
 #define LNET_PROTO_TCP_VERSION_MAJOR	1
@@ -258,7 +267,7 @@ typedef struct lnet_counters {
 
 #define LNET_MAX_INTERFACES    16
 
-/*
+/**
  * Objects maintained by the LNet are accessed through handles. Handle types
  * have names of the form lnet_handle_xx_t, where xx is one of the two letter
  * object type codes ('eq' for event queue, 'md' for memory descriptor, and
@@ -318,7 +327,8 @@ typedef struct {
 /** @} lnet_addr */
 
 /** \addtogroup lnet_me
- * @{ */
+ * @{
+ */
 
 /**
  * Specifies whether the match entry or memory descriptor should be unlinked
@@ -348,7 +358,8 @@ typedef enum {
 /** @} lnet_me */
 
 /** \addtogroup lnet_md
- * @{ */
+ * @{
+ */
 
 /**
  * Defines the visible parts of a memory descriptor. Values of this type
@@ -450,9 +461,11 @@ typedef struct {
 	lnet_handle_eq_t eq_handle;
 } lnet_md_t;
 
-/* Max Transfer Unit (minimum supported everywhere).
+/*
+ * Max Transfer Unit (minimum supported everywhere).
  * CAVEAT EMPTOR, with multinet (i.e. routers forwarding between networks)
- * these limits are system wide and not interface-local. */
+ * these limits are system wide and not interface-local.
+ */
 #define LNET_MTU_BITS	20
 #define LNET_MTU	(1 << LNET_MTU_BITS)
 
@@ -506,7 +519,8 @@ typedef struct {
 /** @} lnet_md */
 
 /** \addtogroup lnet_eq
- * @{ */
+ * @{
+ */
 
 /**
  * Six types of events can be logged in an event queue.
@@ -640,7 +654,8 @@ typedef void (*lnet_eq_handler_t)(lnet_event_t *event);
 /** @} lnet_eq */
 
 /** \addtogroup lnet_data
- * @{ */
+ * @{
+ */
 
 /**
  * Specify whether an acknowledgment should be sent by target when the PUT
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 49cd333..c5bf059 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -189,8 +189,10 @@ void kiblnd_pack_msg(lnet_ni_t *ni, kib_msg_t *msg, int version,
 {
 	kib_net_t *net = ni->ni_data;
 
-	/* CAVEAT EMPTOR! all message fields not set here should have been
-	 * initialised previously. */
+	/*
+	 * CAVEAT EMPTOR! all message fields not set here should have been
+	 * initialised previously.
+	 */
 	msg->ibm_magic    = IBLND_MSG_MAGIC;
 	msg->ibm_version  = version;
 	/*   ibm_type */
@@ -249,8 +251,10 @@ int kiblnd_unpack_msg(kib_msg_t *msg, int nob)
 		return -EPROTO;
 	}
 
-	/* checksum must be computed with ibm_cksum zero and BEFORE anything
-	 * gets flipped */
+	/*
+	 * checksum must be computed with ibm_cksum zero and BEFORE anything
+	 * gets flipped
+	 */
 	msg_cksum = flip ? __swab32(msg->ibm_cksum) : msg->ibm_cksum;
 	msg->ibm_cksum = 0;
 	if (msg_cksum != 0 &&
@@ -375,17 +379,21 @@ void kiblnd_destroy_peer(kib_peer_t *peer)
 
 	LIBCFS_FREE(peer, sizeof(*peer));
 
-	/* NB a peer's connections keep a reference on their peer until
+	/*
+	 * NB a peer's connections keep a reference on their peer until
 	 * they are destroyed, so we can be assured that _all_ state to do
 	 * with this peer has been cleaned up when its refcount drops to
-	 * zero. */
+	 * zero.
+	 */
 	atomic_dec(&net->ibn_npeers);
 }
 
 kib_peer_t *kiblnd_find_peer_locked(lnet_nid_t nid)
 {
-	/* the caller is responsible for accounting the additional reference
-	 * that this creates */
+	/*
+	 * the caller is responsible for accounting the additional reference
+	 * that this creates
+	 */
 	struct list_head *peer_list = kiblnd_nid2peerlist(nid);
 	struct list_head *tmp;
 	kib_peer_t *peer;
@@ -474,8 +482,10 @@ static void kiblnd_del_peer_locked(kib_peer_t *peer)
 		}
 		/* NB closing peer's last conn unlinked it. */
 	}
-	/* NB peer now unlinked; might even be freed if the peer table had the
-	 * last ref on it. */
+	/*
+	 * NB peer now unlinked; might even be freed if the peer table had the
+	 * last ref on it.
+	 */
 }
 
 static int kiblnd_del_peer(lnet_ni_t *ni, lnet_nid_t nid)
@@ -636,13 +646,15 @@ static int kiblnd_get_completion_vector(kib_conn_t *conn, int cpt)
 kib_conn_t *kiblnd_create_conn(kib_peer_t *peer, struct rdma_cm_id *cmid,
 				int state, int version)
 {
-	/* CAVEAT EMPTOR:
+	/*
+	 * CAVEAT EMPTOR:
 	 * If the new conn is created successfully it takes over the caller's
 	 * ref on 'peer'.  It also "owns" 'cmid' and destroys it when it itself
 	 * is destroyed.  On failure, the caller's ref on 'peer' remains and
 	 * she must dispose of 'cmid'.  (Actually I'd block forever if I tried
 	 * to destroy 'cmid' here since I'm called from the CM which still has
-	 * its ref on 'cmid'). */
+	 * its ref on 'cmid').
+	 */
 	rwlock_t *glock = &kiblnd_data.kib_global_lock;
 	kib_net_t *net = peer->ibp_ni->ni_data;
 	kib_dev_t *dev;
@@ -800,15 +812,19 @@ kib_conn_t *kiblnd_create_conn(kib_peer_t *peer, struct rdma_cm_id *cmid,
 			/* Make posted receives complete */
 			kiblnd_abort_receives(conn);
 
-			/* correct # of posted buffers
-			 * NB locking needed now I'm racing with completion */
+			/*
+			 * correct # of posted buffers
+			 * NB locking needed now I'm racing with completion
+			 */
 			spin_lock_irqsave(&sched->ibs_lock, flags);
 			conn->ibc_nrx -= IBLND_RX_MSGS(version) - i;
 			spin_unlock_irqrestore(&sched->ibs_lock, flags);
 
-			/* cmid will be destroyed by CM(ofed) after cm_callback
+			/*
+			 * cmid will be destroyed by CM(ofed) after cm_callback
 			 * returned, so we can't refer it anymore
-			 * (by kiblnd_connd()->kiblnd_destroy_conn) */
+			 * (by kiblnd_connd()->kiblnd_destroy_conn)
+			 */
 			rdma_destroy_qp(conn->ibc_cmid);
 			conn->ibc_cmid = NULL;
 
@@ -1077,8 +1093,10 @@ void kiblnd_query(lnet_ni_t *ni, lnet_nid_t nid, unsigned long *when)
 	if (last_alive != 0)
 		*when = last_alive;
 
-	/* peer is not persistent in hash, trigger peer creation
-	 * and connection establishment with a NULL tx */
+	/*
+	 * peer is not persistent in hash, trigger peer creation
+	 * and connection establishment with a NULL tx
+	 */
 	if (peer == NULL)
 		kiblnd_launch_tx(ni, NULL, nid);
 
@@ -2070,8 +2088,10 @@ static int kiblnd_net_init_pools(kib_net_t *net, __u32 *cpts, int ncpts)
 
 static int kiblnd_hdev_get_attr(kib_hca_dev_t *hdev)
 {
-	/* It's safe to assume a HCA can handle a page size
-	 * matching that of the native system */
+	/*
+	 * It's safe to assume a HCA can handle a page size
+	 * matching that of the native system
+	 */
 	hdev->ibh_page_shift = PAGE_SHIFT;
 	hdev->ibh_page_size  = 1 << PAGE_SHIFT;
 	hdev->ibh_page_mask  = ~((__u64)hdev->ibh_page_size - 1);
@@ -2175,7 +2195,8 @@ static int kiblnd_dev_need_failover(kib_dev_t *dev)
 	    *kiblnd_tunables.kib_dev_failover > 1) /* debugging */
 		return 1;
 
-	/* XXX: it's UGLY, but I don't have better way to find
+	/*
+	 * XXX: it's UGLY, but I don't have better way to find
 	 * ib-bonding HCA failover because:
 	 *
 	 * a. no reliable CM event for HCA failover...
@@ -2184,7 +2205,8 @@ static int kiblnd_dev_need_failover(kib_dev_t *dev)
 	 * We have only two choices at this point:
 	 *
 	 * a. rdma_bind_addr(), it will conflict with listener cmid
-	 * b. rdma_resolve_addr() to zero addr */
+	 * b. rdma_resolve_addr() to zero addr
+	 */
 	cmid = kiblnd_rdma_create_id(kiblnd_dummy_callback, dev, RDMA_PS_TCP,
 				     IB_QPT_RC);
 	if (IS_ERR(cmid)) {
@@ -2239,15 +2261,19 @@ int kiblnd_dev_failover(kib_dev_t *dev)
 
 	if (dev->ibd_hdev != NULL &&
 	    dev->ibd_hdev->ibh_cmid != NULL) {
-		/* XXX it's not good to close old listener at here,
+		/*
+		 * XXX it's not good to close old listener at here,
 		 * because we can fail to create new listener.
 		 * But we have to close it now, otherwise rdma_bind_addr
-		 * will return EADDRINUSE... How crap! */
+		 * will return EADDRINUSE... How crap!
+		 */
 		write_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
 
 		cmid = dev->ibd_hdev->ibh_cmid;
-		/* make next schedule of kiblnd_dev_need_failover()
-		 * return 1 for me */
+		/*
+		 * make next schedule of kiblnd_dev_need_failover()
+		 * return 1 for me
+		 */
 		dev->ibd_hdev->ibh_cmid  = NULL;
 		write_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
 
@@ -2433,9 +2459,11 @@ static void kiblnd_base_shutdown(void)
 		/* flag threads to terminate; wake and wait for them to die */
 		kiblnd_data.kib_shutdown = 1;
 
-		/* NB: we really want to stop scheduler threads net by net
+		/*
+		 * NB: we really want to stop scheduler threads net by net
 		 * instead of the whole module, this should be improved
-		 * with dynamic configuration LNet */
+		 * with dynamic configuration LNet
+		 */
 		cfs_percpt_for_each(sched, i, kiblnd_data.kib_scheds)
 			wake_up_all(&sched->ibs_waitq);
 
@@ -2585,8 +2613,10 @@ static int kiblnd_base_startup(void)
 		if (*kiblnd_tunables.kib_nscheds > 0) {
 			nthrs = min(nthrs, *kiblnd_tunables.kib_nscheds);
 		} else {
-			/* max to half of CPUs, another half is reserved for
-			 * upper layer modules */
+			/*
+			 * max to half of CPUs, another half is reserved for
+			 * upper layer modules
+			 */
 			nthrs = min(max(IBLND_N_SCHED, nthrs >> 1), nthrs);
 		}
 
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 176c79b..5093244 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -409,10 +409,11 @@ kiblnd_handle_rx(kib_rx_t *rx)
 		}
 
 		LASSERT(tx->tx_waiting);
-		/* CAVEAT EMPTOR: I could be racing with tx_complete, but...
+		/*
+		 * CAVEAT EMPTOR: I could be racing with tx_complete, but...
 		 * (a) I can overwrite tx_msg since my peer has received it!
-		 * (b) tx_waiting set tells tx_complete() it's not done. */
-
+		 * (b) tx_waiting set tells tx_complete() it's not done.
+		 */
 		tx->tx_nwrq = 0;		/* overwrite PUT_REQ */
 
 		rc2 = kiblnd_init_rdma(conn, tx, IBLND_MSG_PUT_DONE,
@@ -587,8 +588,10 @@ kiblnd_fmr_map_tx(kib_net_t *net, kib_tx_t *tx, kib_rdma_desc_t *rd, int nob)
 		return rc;
 	}
 
-	/* If rd is not tx_rd, it's going to get sent to a peer, who will need
-	 * the rkey */
+	/*
+	 * If rd is not tx_rd, it's going to get sent to a peer, who will need
+	 * the rkey
+	 */
 	rd->rd_key = (rd != tx->tx_rd) ? tx->fmr.fmr_pfmr->fmr->rkey :
 					 tx->fmr.fmr_pfmr->fmr->lkey;
 	rd->rd_frags[0].rf_addr &= ~hdev->ibh_page_mask;
@@ -625,8 +628,10 @@ static int kiblnd_map_tx(lnet_ni_t *ni, kib_tx_t *tx, kib_rdma_desc_t *rd,
 	__u32 nob;
 	int i;
 
-	/* If rd is not tx_rd, it's going to get sent to a peer and I'm the
-	 * RDMA sink */
+	/*
+	 * If rd is not tx_rd, it's going to get sent to a peer and I'm the
+	 * RDMA sink
+	 */
 	tx->tx_dmadir = (rd != tx->tx_rd) ? DMA_FROM_DEVICE : DMA_TO_DEVICE;
 	tx->tx_nfrags = nfrags;
 
@@ -799,9 +804,11 @@ kiblnd_post_tx_locked(kib_conn_t *conn, kib_tx_t *tx, int credit)
 	    (!kiblnd_need_noop(conn) ||     /* redundant NOOP */
 	     (IBLND_OOB_CAPABLE(ver) && /* posted enough NOOP */
 	      conn->ibc_noops_posted == IBLND_OOB_MSGS(ver)))) {
-		/* OK to drop when posted enough NOOPs, since
+		/*
+		 * OK to drop when posted enough NOOPs, since
 		 * kiblnd_check_sends will queue NOOP again when
-		 * posted NOOPs complete */
+		 * posted NOOPs complete
+		 */
 		spin_unlock(&conn->ibc_lock);
 		kiblnd_tx_done(peer->ibp_ni, tx);
 		spin_lock(&conn->ibc_lock);
@@ -820,12 +827,14 @@ kiblnd_post_tx_locked(kib_conn_t *conn, kib_tx_t *tx, int credit)
 	if (msg->ibm_type == IBLND_MSG_NOOP)
 		conn->ibc_noops_posted++;
 
-	/* CAVEAT EMPTOR!  This tx could be the PUT_DONE of an RDMA
+	/*
+	 * CAVEAT EMPTOR!  This tx could be the PUT_DONE of an RDMA
 	 * PUT.  If so, it was first queued here as a PUT_REQ, sent and
 	 * stashed on ibc_active_txs, matched by an incoming PUT_ACK,
 	 * and then re-queued here.  It's (just) possible that
 	 * tx_sending is non-zero if we've not done the tx_complete()
-	 * from the first send; hence the ++ rather than = below. */
+	 * from the first send; hence the ++ rather than = below.
+	 */
 	tx->tx_sending++;
 	list_add(&tx->tx_list, &conn->ibc_active_txs);
 
@@ -845,8 +854,10 @@ kiblnd_post_tx_locked(kib_conn_t *conn, kib_tx_t *tx, int credit)
 	if (rc == 0)
 		return 0;
 
-	/* NB credits are transferred in the actual
-	 * message, which can only be the last work item */
+	/*
+	 * NB credits are transferred in the actual
+	 * message, which can only be the last work item
+	 */
 	conn->ibc_credits += credit;
 	conn->ibc_outstanding_credits += msg->ibm_credits;
 	conn->ibc_nsends_posted--;
@@ -975,9 +986,10 @@ kiblnd_tx_complete(kib_tx_t *tx, int status)
 
 	spin_lock(&conn->ibc_lock);
 
-	/* I could be racing with rdma completion.  Whoever makes 'tx' idle
-	 * gets to free it, which also drops its ref on 'conn'. */
-
+	/*
+	 * I could be racing with rdma completion.  Whoever makes 'tx' idle
+	 * gets to free it, which also drops its ref on 'conn'.
+	 */
 	tx->tx_sending--;
 	conn->ibc_nsends_posted--;
 	if (tx->tx_msg->ibm_type == IBLND_MSG_NOOP)
@@ -1301,14 +1313,17 @@ kiblnd_launch_tx(lnet_ni_t *ni, kib_tx_t *tx, lnet_nid_t nid)
 	unsigned long flags;
 	int rc;
 
-	/* If I get here, I've committed to send, so I complete the tx with
-	 * failure on any problems */
-
+	/*
+	 * If I get here, I've committed to send, so I complete the tx with
+	 * failure on any problems
+	 */
 	LASSERT(tx == NULL || tx->tx_conn == NULL); /* only set when assigned a conn */
 	LASSERT(tx == NULL || tx->tx_nwrq > 0);     /* work items have been set up */
 
-	/* First time, just use a read lock since I expect to find my peer
-	 * connected */
+	/*
+	 * First time, just use a read lock since I expect to find my peer
+	 * connected
+	 */
 	read_lock_irqsave(g_lock, flags);
 
 	peer = kiblnd_find_peer_locked(nid);
@@ -1630,8 +1645,7 @@ kiblnd_reply(lnet_ni_t *ni, kib_rx_t *rx, lnet_msg_t *lntmsg)
 		/* No RDMA: local completion may happen now! */
 		lnet_finalize(ni, lntmsg, 0);
 	} else {
-		/* RDMA: lnet_finalize(lntmsg) when it
-		 * completes */
+		/* RDMA: lnet_finalize(lntmsg) when it completes */
 		tx->tx_lntmsg[0] = lntmsg;
 	}
 
@@ -1814,12 +1828,14 @@ kiblnd_peer_notify(kib_peer_t *peer)
 void
 kiblnd_close_conn_locked(kib_conn_t *conn, int error)
 {
-	/* This just does the immediate housekeeping.  'error' is zero for a
+	/*
+	 * This just does the immediate housekeeping. 'error' is zero for a
 	 * normal shutdown which can happen only after the connection has been
 	 * established.  If the connection is established, schedule the
-	 * connection to be finished off by the connd.  Otherwise the connd is
+	 * connection to be finished off by the connd. Otherwise the connd is
 	 * already dealing with it (either to set it up or tear it down).
-	 * Caller holds kib_global_lock exclusively in irq context */
+	 * Caller holds kib_global_lock exclusively in irq context
+	 */
 	kib_peer_t *peer = conn->ibc_peer;
 	kib_dev_t *dev;
 	unsigned long flags;
@@ -1957,14 +1973,17 @@ kiblnd_finalise_conn(kib_conn_t *conn)
 
 	kiblnd_set_conn_state(conn, IBLND_CONN_DISCONNECTED);
 
-	/* abort_receives moves QP state to IB_QPS_ERR.  This is only required
+	/*
+	 * abort_receives moves QP state to IB_QPS_ERR.  This is only required
 	 * for connections that didn't get as far as being connected, because
-	 * rdma_disconnect() does this for free. */
+	 * rdma_disconnect() does this for free.
+	 */
 	kiblnd_abort_receives(conn);
 
-	/* Complete all tx descs not waiting for sends to complete.
-	 * NB we should be safe from RDMA now that the QP has changed state */
-
+	/*
+	 * Complete all tx descs not waiting for sends to complete.
+	 * NB we should be safe from RDMA now that the QP has changed state
+	 */
 	kiblnd_abort_txs(conn, &conn->ibc_tx_noops);
 	kiblnd_abort_txs(conn, &conn->ibc_tx_queue);
 	kiblnd_abort_txs(conn, &conn->ibc_tx_queue_rsrvd);
@@ -2067,8 +2086,10 @@ kiblnd_connreq_done(kib_conn_t *conn, int status)
 	kiblnd_set_conn_state(conn, IBLND_CONN_ESTABLISHED);
 	kiblnd_peer_alive(peer);
 
-	/* Add conn to peer's list and nuke any dangling conns from a different
-	 * peer instance... */
+	/*
+	 * Add conn to peer's list and nuke any dangling conns from a different
+	 * peer instance...
+	 */
 	kiblnd_conn_addref(conn);	       /* +1 ref for ibc_list */
 	list_add(&conn->ibc_list, &peer->ibp_conns);
 	if (active)
@@ -2180,12 +2201,14 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 		goto failed;
 	}
 
-	/* Future protocol version compatibility support!  If the
+	/*
+	 * Future protocol version compatibility support!  If the
 	 * o2iblnd-specific protocol changes, or when LNET unifies
 	 * protocols over all LNDs, the initial connection will
 	 * negotiate a protocol version.  I trap this here to avoid
 	 * console errors; the reject tells the peer which protocol I
-	 * speak. */
+	 * speak.
+	 */
 	if (reqmsg->ibm_magic == LNET_PROTO_MAGIC ||
 	    reqmsg->ibm_magic == __swab32(LNET_PROTO_MAGIC))
 		goto failed;
@@ -2352,9 +2375,10 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 		goto failed;
 	}
 
-	/* conn now "owns" cmid, so I return success from here on to ensure the
-	 * CM callback doesn't destroy cmid. */
-
+	/*
+	 * conn now "owns" cmid, so I return success from here on to ensure the
+	 * CM callback doesn't destroy cmid.
+	 */
 	conn->ibc_incarnation      = reqmsg->ibm_srcstamp;
 	conn->ibc_credits          = IBLND_MSG_QUEUE_SIZE(version);
 	conn->ibc_reserved_credits = IBLND_MSG_QUEUE_SIZE(version);
@@ -2423,11 +2447,13 @@ kiblnd_reconnect(kib_conn_t *conn, int version,
 
 	write_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
 
-	/* retry connection if it's still needed and no other connection
+	/*
+	 * retry connection if it's still needed and no other connection
 	 * attempts (active or passive) are in progress
 	 * NB: reconnect is still needed even when ibp_tx_queue is
 	 * empty if ibp_version != version because reconnect may be
-	 * initiated by kiblnd_query() */
+	 * initiated by kiblnd_query()
+	 */
 	if ((!list_empty(&peer->ibp_tx_queue) ||
 	     peer->ibp_version != version) &&
 	    peer->ibp_connecting == 1 &&
@@ -2520,9 +2546,11 @@ kiblnd_rejected(kib_conn_t *conn, int reason, void *priv, int priv_nob)
 
 			if (priv_nob >= sizeof(kib_rej_t) &&
 			    rej->ibr_version > IBLND_MSG_VERSION_1) {
-				/* priv_nob is always 148 in current version
+				/*
+				 * priv_nob is always 148 in current version
 				 * of OFED, so we still need to check version.
-				 * (define of IB_CM_REJ_PRIVATE_DATA_SIZE) */
+				 * (define of IB_CM_REJ_PRIVATE_DATA_SIZE)
+				 */
 				cp = &rej->ibr_cp;
 
 				if (flip) {
@@ -2698,11 +2726,12 @@ kiblnd_check_connreply(kib_conn_t *conn, void *priv, int priv_nob)
 	return;
 
  failed:
-	/* NB My QP has already established itself, so I handle anything going
+	/*
+	 * NB My QP has already established itself, so I handle anything going
 	 * wrong here by setting ibc_comms_error.
 	 * kiblnd_connreq_done(0) moves the conn state to ESTABLISHED, but then
-	 * immediately tears it down. */
-
+	 * immediately tears it down.
+	 */
 	LASSERT(rc != 0);
 	conn->ibc_comms_error = rc;
 	kiblnd_connreq_done(conn, 0);
@@ -2735,10 +2764,11 @@ kiblnd_active_connect(struct rdma_cm_id *cmid)
 		return -ENOMEM;
 	}
 
-	/* conn "owns" cmid now, so I return success from here on to ensure the
+	/*
+	 * conn "owns" cmid now, so I return success from here on to ensure the
 	 * CM callback doesn't destroy cmid. conn also takes over cmid's ref
-	 * on peer */
-
+	 * on peer
+	 */
 	msg = &conn->ibc_connvars->cv_msg;
 
 	memset(msg, 0, sizeof(*msg));
@@ -2932,8 +2962,10 @@ kiblnd_cm_callback(struct rdma_cm_id *cmid, struct rdma_cm_event *event)
 		LCONSOLE_ERROR_MSG(0x131,
 				   "Received notification of device removal\n"
 				   "Please shutdown LNET to allow this to proceed\n");
-		/* Can't remove network from underneath LNET for now, so I have
-		 * to ignore this */
+		/*
+		 * Can't remove network from underneath LNET for now, so I have
+		 * to ignore this
+		 */
 		return 0;
 
 	case RDMA_CM_EVENT_ADDR_CHANGE:
@@ -2992,9 +3024,11 @@ kiblnd_check_conns(int idx)
 	struct list_head *ctmp;
 	unsigned long flags;
 
-	/* NB. We expect to have a look at all the peers and not find any
+	/*
+	 * NB. We expect to have a look at all the peers and not find any
 	 * RDMAs to time out, so we just use a shared lock while we
-	 * take a look... */
+	 * take a look...
+	 */
 	read_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
 
 	list_for_each(ptmp, peers) {
@@ -3039,18 +3073,22 @@ kiblnd_check_conns(int idx)
 
 	read_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
 
-	/* Handle timeout by closing the whole
+	/*
+	 * Handle timeout by closing the whole
 	 * connection. We can only be sure RDMA activity
-	 * has ceased once the QP has been modified. */
+	 * has ceased once the QP has been modified.
+	 */
 	list_for_each_entry_safe(conn, tmp, &closes, ibc_connd_list) {
 		list_del(&conn->ibc_connd_list);
 		kiblnd_close_conn(conn, -ETIMEDOUT);
 		kiblnd_conn_decref(conn);
 	}
 
-	/* In case we have enough credits to return via a
+	/*
+	 * In case we have enough credits to return via a
 	 * NOOP, but there were no non-blocking tx descs
-	 * free to do it last time... */
+	 * free to do it last time...
+	 */
 	while (!list_empty(&checksends)) {
 		conn = list_entry(checksends.next,
 				      kib_conn_t, ibc_connd_list);
@@ -3135,14 +3173,15 @@ kiblnd_connd(void *arg)
 			spin_unlock_irqrestore(&kiblnd_data.kib_connd_lock, flags);
 			dropped_lock = 1;
 
-			/* Time to check for RDMA timeouts on a few more
+			/*
+			 * Time to check for RDMA timeouts on a few more
 			 * peers: I do checks every 'p' seconds on a
 			 * proportion of the peer table and I need to check
 			 * every connection 'n' times within a timeout
 			 * interval, to ensure I detect a timeout on any
 			 * connection within (n+1)/n times the timeout
-			 * interval. */
-
+			 * interval.
+			 */
 			if (*kiblnd_tunables.kib_timeout > n * p)
 				chunk = (chunk * n * p) /
 					*kiblnd_tunables.kib_timeout;
@@ -3205,12 +3244,14 @@ kiblnd_complete(struct ib_wc *wc)
 		LBUG();
 
 	case IBLND_WID_RDMA:
-		/* We only get RDMA completion notification if it fails.  All
+		/*
+		 * We only get RDMA completion notification if it fails.  All
 		 * subsequent work items, including the final SEND will fail
 		 * too.  However we can't print out any more info about the
 		 * failing RDMA because 'tx' might be back on the idle list or
 		 * even reused already if we didn't manage to post all our work
-		 * items */
+		 * items
+		 */
 		CNETERR("RDMA (tx: %p) failed: %d\n",
 			kiblnd_wreqid2ptr(wc->wr_id), wc->status);
 		return;
@@ -3229,11 +3270,13 @@ kiblnd_complete(struct ib_wc *wc)
 void
 kiblnd_cq_completion(struct ib_cq *cq, void *arg)
 {
-	/* NB I'm not allowed to schedule this conn once its refcount has
+	/*
+	 * NB I'm not allowed to schedule this conn once its refcount has
 	 * reached 0.  Since fundamentally I'm racing with scheduler threads
 	 * consuming my CQ I could be called after all completions have
 	 * occurred.  But in this case, ibc_nrx == 0 && ibc_nsends_posted == 0
-	 * and this CQ is about to be destroyed so I NOOP. */
+	 * and this CQ is about to be destroyed so I NOOP.
+	 */
 	kib_conn_t *conn = arg;
 	struct kib_sched_info *sched = conn->ibc_sched;
 	unsigned long flags;
@@ -3346,9 +3389,11 @@ kiblnd_scheduler(void *arg)
 			spin_lock_irqsave(&sched->ibs_lock, flags);
 
 			if (rc != 0 || conn->ibc_ready) {
-				/* There may be another completion waiting; get
+				/*
+				 * There may be another completion waiting; get
 				 * another scheduler to check while I handle
-				 * this one... */
+				 * this one...
+				 */
 				/* +1 ref for sched_conns */
 				kiblnd_conn_addref(conn);
 				list_add_tail(&conn->ibc_sched_list,
@@ -3461,10 +3506,12 @@ kiblnd_failover_thread(void *arg)
 		if (!long_sleep || rc != 0)
 			continue;
 
-		/* have a long sleep, routine check all active devices,
+		/*
+		 * have a long sleep, routine check all active devices,
 		 * we need checking like this because if there is not active
 		 * connection on the dev and no SEND from local, we may listen
-		 * on wrong HCA for ever while there is a bonding failover */
+		 * on wrong HCA for ever while there is a bonding failover
+		 */
 		list_for_each_entry(dev, &kiblnd_data.kib_devs, ibd_list) {
 			if (kiblnd_dev_can_failover(dev)) {
 				list_add_tail(&dev->ibd_fail_list,
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
index 1d4e7ef..afbd6d1 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
@@ -52,8 +52,10 @@ static int timeout = 50;
 module_param(timeout, int, 0644);
 MODULE_PARM_DESC(timeout, "timeout (seconds)");
 
-/* Number of threads in each scheduler pool which is percpt,
- * we will estimate reasonable value based on CPUs if it's set to zero. */
+/*
+ * Number of threads in each scheduler pool which is percpt,
+ * we will estimate reasonable value based on CPUs if it's set to zero.
+ */
 static int nscheds;
 module_param(nscheds, int, 0444);
 MODULE_PARM_DESC(nscheds, "number of threads in each scheduler pool");
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 05aa90e..a237cde 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -163,10 +163,12 @@ ksocknal_destroy_peer(ksock_peer_t *peer)
 
 	LIBCFS_FREE(peer, sizeof(*peer));
 
-	/* NB a peer's connections and routes keep a reference on their peer
+	/*
+	 * NB a peer's connections and routes keep a reference on their peer
 	 * until they are destroyed, so we can be assured that _all_ state to
 	 * do with this peer has been cleaned up when its refcount drops to
-	 * zero. */
+	 * zero.
+	 */
 	spin_lock_bh(&net->ksnn_lock);
 	net->ksnn_npeers--;
 	spin_unlock_bh(&net->ksnn_lock);
@@ -226,8 +228,10 @@ ksocknal_unlink_peer_locked(ksock_peer_t *peer)
 		ip = peer->ksnp_passive_ips[i];
 
 		iface = ksocknal_ip2iface(peer->ksnp_ni, ip);
-		/* All IPs in peer->ksnp_passive_ips[] come from the
-		 * interface list, therefore the call must succeed. */
+		/*
+		 * All IPs in peer->ksnp_passive_ips[] come from the
+		 * interface list, therefore the call must succeed.
+		 */
 		LASSERT(iface != NULL);
 
 		CDEBUG(D_NET, "peer=%p iface=%p ksni_nroutes=%d\n",
@@ -358,8 +362,10 @@ ksocknal_associate_route_conn_locked(ksock_route_t *route, ksock_conn_t *conn)
 	route->ksnr_connected |= (1<<type);
 	route->ksnr_conn_count++;
 
-	/* Successful connection => further attempts can
-	 * proceed immediately */
+	/*
+	 * Successful connection => further attempts can
+	 * proceed immediately
+	 */
 	route->ksnr_retry_interval = 0;
 }
 
@@ -438,8 +444,10 @@ ksocknal_del_route_locked(ksock_route_t *route)
 
 	if (list_empty(&peer->ksnp_routes) &&
 	    list_empty(&peer->ksnp_conns)) {
-		/* I've just removed the last route to a peer with no active
-		 * connections */
+		/*
+		 * I've just removed the last route to a peer with no active
+		 * connections
+		 */
 		ksocknal_unlink_peer_locked(peer);
 	}
 }
@@ -539,9 +547,10 @@ ksocknal_del_peer_locked(ksock_peer_t *peer, __u32 ip)
 	}
 
 	if (nshared == 0) {
-		/* remove everything else if there are no explicit entries
-		 * left */
-
+		/*
+		 * remove everything else if there are no explicit entries
+		 * left
+		 */
 		list_for_each_safe(tmp, nxt, &peer->ksnp_routes) {
 			route = list_entry(tmp, ksock_route_t, ksnr_list);
 
@@ -692,8 +701,10 @@ ksocknal_local_ipvec(lnet_ni_t *ni, __u32 *ipaddrs)
 	nip = net->ksnn_ninterfaces;
 	LASSERT(nip <= LNET_MAX_INTERFACES);
 
-	/* Only offer interfaces for additional connections if I have
-	 * more than one. */
+	/*
+	 * Only offer interfaces for additional connections if I have
+	 * more than one.
+	 */
 	if (nip < 2) {
 		read_unlock(&ksocknal_data.ksnd_global_lock);
 		return 0;
@@ -757,33 +768,38 @@ ksocknal_select_ips(ksock_peer_t *peer, __u32 *peerips, int n_peerips)
 	int best_netmatch;
 	int best_npeers;
 
-	/* CAVEAT EMPTOR: We do all our interface matching with an
+	/*
+	 * CAVEAT EMPTOR: We do all our interface matching with an
 	 * exclusive hold of global lock@IRQ priority.  We're only
 	 * expecting to be dealing with small numbers of interfaces, so the
-	 * O(n**3)-ness shouldn't matter */
-
-	/* Also note that I'm not going to return more than n_peerips
-	 * interfaces, even if I have more myself */
-
+	 * O(n**3)-ness shouldn't matter
+	 */
+	/*
+	 * Also note that I'm not going to return more than n_peerips
+	 * interfaces, even if I have more myself
+	 */
 	write_lock_bh(global_lock);
 
 	LASSERT(n_peerips <= LNET_MAX_INTERFACES);
 	LASSERT(net->ksnn_ninterfaces <= LNET_MAX_INTERFACES);
 
-	/* Only match interfaces for additional connections
-	 * if I have > 1 interface */
+	/*
+	 * Only match interfaces for additional connections
+	 * if I have > 1 interface
+	 */
 	n_ips = (net->ksnn_ninterfaces < 2) ? 0 :
 		min(n_peerips, net->ksnn_ninterfaces);
 
 	for (i = 0; peer->ksnp_n_passive_ips < n_ips; i++) {
 		/*	      ^ yes really... */
 
-		/* If we have any new interfaces, first tick off all the
+		/*
+		 * If we have any new interfaces, first tick off all the
 		 * peer IPs that match old interfaces, then choose new
 		 * interfaces to match the remaining peer IPS.
 		 * We don't forget interfaces we've stopped using; we might
-		 * start using them again... */
-
+		 * start using them again...
+		 */
 		if (i < peer->ksnp_n_passive_ips) {
 			/* Old interface. */
 			ip = peer->ksnp_passive_ips[i];
@@ -860,16 +876,19 @@ ksocknal_create_routes(ksock_peer_t *peer, int port,
 	int i;
 	int j;
 
-	/* CAVEAT EMPTOR: We do all our interface matching with an
+	/*
+	 * CAVEAT EMPTOR: We do all our interface matching with an
 	 * exclusive hold of global lock at IRQ priority.  We're only
 	 * expecting to be dealing with small numbers of interfaces, so the
-	 * O(n**3)-ness here shouldn't matter */
-
+	 * O(n**3)-ness here shouldn't matter
+	 */
 	write_lock_bh(global_lock);
 
 	if (net->ksnn_ninterfaces < 2) {
-		/* Only create additional connections
-		 * if I have > 1 interface */
+		/*
+		 * Only create additional connections
+		 * if I have > 1 interface
+		 */
 		write_unlock_bh(global_lock);
 		return;
 	}
@@ -1039,8 +1058,10 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 	conn->ksnc_peer = NULL;
 	conn->ksnc_route = NULL;
 	conn->ksnc_sock = sock;
-	/* 2 ref, 1 for conn, another extra ref prevents socket
-	 * being closed before establishment of connection */
+	/*
+	 * 2 ref, 1 for conn, another extra ref prevents socket
+	 * being closed before establishment of connection
+	 */
 	atomic_set(&conn->ksnc_sock_refcount, 2);
 	conn->ksnc_type = type;
 	ksocknal_lib_save_callback(sock, conn);
@@ -1067,11 +1088,12 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 	if (rc != 0)
 		goto failed_1;
 
-	/* Find out/confirm peer's NID and connection type and get the
+	/*
+	 * Find out/confirm peer's NID and connection type and get the
 	 * vector of interfaces she's willing to let me connect to.
 	 * Passive connections use the listener timeout since the peer sends
-	 * eagerly */
-
+	 * eagerly
+	 */
 	if (active) {
 		peer = route->ksnr_peer;
 		LASSERT(ni == peer->ksnp_ni);
@@ -1130,8 +1152,10 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 
 		peer2 = ksocknal_find_peer_locked(ni, peerid);
 		if (peer2 == NULL) {
-			/* NB this puts an "empty" peer in the peer
-			 * table (which takes my ref) */
+			/*
+			 * NB this puts an "empty" peer in the peer
+			 * table (which takes my ref)
+			 */
 			list_add_tail(&peer->ksnp_list,
 					  ksocknal_nid2peerlist(peerid.nid));
 		} else {
@@ -1143,8 +1167,10 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 		ksocknal_peer_addref(peer);
 		peer->ksnp_accepting++;
 
-		/* Am I already connecting to this guy?  Resolve in
-		 * favour of higher NID... */
+		/*
+		 * Am I already connecting to this guy?  Resolve in
+		 * favour of higher NID...
+		 */
 		if (peerid.nid < ni->ni_nid &&
 		    ksocknal_connecting(peer, conn->ksnc_ipaddr)) {
 			rc = EALREADY;
@@ -1162,7 +1188,8 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 	}
 
 	if (peer->ksnp_proto == NULL) {
-		/* Never connected before.
+		/*
+		 * Never connected before.
 		 * NB recv_hello may have returned EPROTO to signal my peer
 		 * wants a different protocol than the one I asked for.
 		 */
@@ -1198,8 +1225,10 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 		goto failed_2;
 	}
 
-	/* Refuse to duplicate an existing connection, unless this is a
-	 * loopback connection */
+	/*
+	 * Refuse to duplicate an existing connection, unless this is a
+	 * loopback connection
+	 */
 	if (conn->ksnc_ipaddr != conn->ksnc_myipaddr) {
 		list_for_each(tmp, &peer->ksnp_conns) {
 			conn2 = list_entry(tmp, ksock_conn_t, ksnc_list);
@@ -1209,8 +1238,10 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 			    conn2->ksnc_type != conn->ksnc_type)
 				continue;
 
-			/* Reply on a passive connection attempt so the peer
-			 * realises we're connected. */
+			/*
+			 * Reply on a passive connection attempt so the peer
+			 * realises we're connected.
+			 */
 			LASSERT(rc == 0);
 			if (!active)
 				rc = EALREADY;
@@ -1220,9 +1251,11 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 		}
 	}
 
-	/* If the connection created by this route didn't bind to the IP
+	/*
+	 * If the connection created by this route didn't bind to the IP
 	 * address the route connected to, the connection/route matching
-	 * code below probably isn't going to work. */
+	 * code below probably isn't going to work.
+	 */
 	if (active &&
 	    route->ksnr_ipaddr != conn->ksnc_ipaddr) {
 		CERROR("Route %s %pI4h connected to %pI4h\n",
@@ -1231,10 +1264,12 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 		       &conn->ksnc_ipaddr);
 	}
 
-	/* Search for a route corresponding to the new connection and
+	/*
+	 * Search for a route corresponding to the new connection and
 	 * create an association.  This allows incoming connections created
 	 * by routes in my peer to match my own route entries so I don't
-	 * continually create duplicate routes. */
+	 * continually create duplicate routes.
+	 */
 	list_for_each(tmp, &peer->ksnp_routes) {
 		route = list_entry(tmp, ksock_route_t, ksnr_list);
 
@@ -1278,14 +1313,14 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 
 	write_unlock_bh(global_lock);
 
-	/* We've now got a new connection.  Any errors from here on are just
+	/*
+	 * We've now got a new connection.  Any errors from here on are just
 	 * like "normal" comms errors and we close the connection normally.
 	 * NB (a) we still have to send the reply HELLO for passive
 	 *	connections,
 	 *    (b) normal I/O on the conn is blocked until I setup and call the
 	 *	socket callbacks.
 	 */
-
 	CDEBUG(D_NET, "New conn %s p %d.x %pI4h -> %pI4h/%d incarnation:%lld sched[%d:%d]\n",
 	       libcfs_id2str(peerid), conn->ksnc_proto->pro_version,
 	       &conn->ksnc_myipaddr, &conn->ksnc_ipaddr,
@@ -1305,11 +1340,13 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 	LIBCFS_FREE(hello, offsetof(ksock_hello_msg_t,
 				    kshm_ips[LNET_MAX_INTERFACES]));
 
-	/* setup the socket AFTER I've received hello (it disables
+	/*
+	 * setup the socket AFTER I've received hello (it disables
 	 * SO_LINGER).  I might call back to the acceptor who may want
 	 * to send a protocol version response and then close the
 	 * socket; this ensures the socket only tears down after the
-	 * response has been sent. */
+	 * response has been sent.
+	 */
 	if (rc == 0)
 		rc = ksocknal_lib_setup_sock(sock);
 
@@ -1363,8 +1400,10 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 
 	if (!active) {
 		if (rc > 0) {
-			/* Request retry by replying with CONN_NONE
-			 * ksnc_proto has been set already */
+			/*
+			 * Request retry by replying with CONN_NONE
+			 * ksnc_proto has been set already
+			 */
 			conn->ksnc_type = SOCKLND_CONN_NONE;
 			hello->kshm_nips = 0;
 			ksocknal_send_hello(ni, conn, peerid.nid, hello);
@@ -1393,9 +1432,11 @@ failed_0:
 void
 ksocknal_close_conn_locked(ksock_conn_t *conn, int error)
 {
-	/* This just does the immmediate housekeeping, and queues the
+	/*
+	 * This just does the immmediate housekeeping, and queues the
 	 * connection for the reaper to terminate.
-	 * Caller holds ksnd_global_lock exclusively in irq context */
+	 * Caller holds ksnd_global_lock exclusively in irq context
+	 */
 	ksock_peer_t *peer = conn->ksnc_peer;
 	ksock_route_t *route;
 	ksock_conn_t *conn2;
@@ -1445,8 +1486,10 @@ ksocknal_close_conn_locked(ksock_conn_t *conn, int error)
 
 			LASSERT(conn->ksnc_proto == &ksocknal_protocol_v3x);
 
-			/* throw them to the last connection...,
-			 * these TXs will be send to /dev/null by scheduler */
+			/*
+			 * throw them to the last connection...,
+			 * these TXs will be send to /dev/null by scheduler
+			 */
 			list_for_each_entry(tx, &peer->ksnp_tx_queue,
 						tx_list)
 				ksocknal_tx_prep(conn, tx);
@@ -1461,8 +1504,10 @@ ksocknal_close_conn_locked(ksock_conn_t *conn, int error)
 		peer->ksnp_error = error;       /* stash last conn close reason */
 
 		if (list_empty(&peer->ksnp_routes)) {
-			/* I've just closed last conn belonging to a
-			 * peer with no routes to it */
+			/*
+			 * I've just closed last conn belonging to a
+			 * peer with no routes to it
+			 */
 			ksocknal_unlink_peer_locked(peer);
 		}
 	}
@@ -1482,10 +1527,11 @@ ksocknal_peer_failed(ksock_peer_t *peer)
 	int notify = 0;
 	unsigned long last_alive = 0;
 
-	/* There has been a connection failure or comms error; but I'll only
+	/*
+	 * There has been a connection failure or comms error; but I'll only
 	 * tell LNET I think the peer is dead if it's to another kernel and
-	 * there are no connections or connection attempts in existence. */
-
+	 * there are no connections or connection attempts in existence.
+	 */
 	read_lock(&ksocknal_data.ksnd_global_lock);
 
 	if ((peer->ksnp_id.pid & LNET_PID_USERFLAG) == 0 &&
@@ -1511,8 +1557,10 @@ ksocknal_finalize_zcreq(ksock_conn_t *conn)
 	ksock_tx_t *tmp;
 	LIST_HEAD(zlist);
 
-	/* NB safe to finalize TXs because closing of socket will
-	 * abort all buffered data */
+	/*
+	 * NB safe to finalize TXs because closing of socket will
+	 * abort all buffered data
+	 */
 	LASSERT(conn->ksnc_sock == NULL);
 
 	spin_lock(&peer->ksnp_lock);
@@ -1542,10 +1590,12 @@ ksocknal_finalize_zcreq(ksock_conn_t *conn)
 void
 ksocknal_terminate_conn(ksock_conn_t *conn)
 {
-	/* This gets called by the reaper (guaranteed thread context) to
+	/*
+	 * This gets called by the reaper (guaranteed thread context) to
 	 * disengage the socket from its callbacks and close it.
 	 * ksnc_refcount will eventually hit zero, and then the reaper will
-	 * destroy it. */
+	 * destroy it.
+	 */
 	ksock_peer_t *peer = conn->ksnc_peer;
 	ksock_sched_t *sched = conn->ksnc_scheduler;
 	int failed = 0;
@@ -1576,8 +1626,10 @@ ksocknal_terminate_conn(ksock_conn_t *conn)
 
 	ksocknal_lib_reset_callback(conn->ksnc_sock, conn);
 
-	/* OK, so this conn may not be completely disengaged from its
-	 * scheduler yet, but it _has_ committed to terminate... */
+	/*
+	 * OK, so this conn may not be completely disengaged from its
+	 * scheduler yet, but it _has_ committed to terminate...
+	 */
 	conn->ksnc_scheduler->kss_nconns--;
 
 	if (peer->ksnp_error != 0) {
@@ -1592,11 +1644,13 @@ ksocknal_terminate_conn(ksock_conn_t *conn)
 	if (failed)
 		ksocknal_peer_failed(peer);
 
-	/* The socket is closed on the final put; either here, or in
+	/*
+	 * The socket is closed on the final put; either here, or in
 	 * ksocknal_{send,recv}msg().  Since we set up the linger2 option
 	 * when the connection was established, this will close the socket
 	 * immediately, aborting anything buffered in it. Any hung
-	 * zero-copy transmits will therefore complete in finite time. */
+	 * zero-copy transmits will therefore complete in finite time.
+	 */
 	ksocknal_connsock_decref(conn);
 }
 
@@ -1760,8 +1814,10 @@ ksocknal_close_matching_conns(lnet_process_id_t id, __u32 ipaddr)
 void
 ksocknal_notify(lnet_ni_t *ni, lnet_nid_t gw_nid, int alive)
 {
-	/* The router is telling me she's been notified of a change in
-	 * gateway state.... */
+	/*
+	 * The router is telling me she's been notified of a change in
+	 * gateway state....
+	 */
 	lnet_process_id_t id = {0};
 
 	id.nid = gw_nid;
@@ -1776,8 +1832,10 @@ ksocknal_notify(lnet_ni_t *ni, lnet_nid_t gw_nid, int alive)
 		return;
 	}
 
-	/* ...otherwise do nothing.  We can only establish new connections
-	 * if we have autroutes, and these connect on demand. */
+	/*
+	 * ...otherwise do nothing.  We can only establish new connections
+	 * if we have autroutes, and these connect on demand.
+	 */
 }
 
 void
@@ -2397,8 +2455,10 @@ ksocknal_base_startup(void)
 		if (*ksocknal_tunables.ksnd_nscheds > 0) {
 			nthrs = min(nthrs, *ksocknal_tunables.ksnd_nscheds);
 		} else {
-			/* max to half of CPUs, assume another half should be
-			 * reserved for upper layer modules */
+			/*
+			 * max to half of CPUs, assume another half should be
+			 * reserved for upper layer modules
+			 */
 			nthrs = min(max(SOCKNAL_NSCHEDS, nthrs >> 1), nthrs);
 		}
 
@@ -2425,8 +2485,10 @@ ksocknal_base_startup(void)
 	ksocknal_data.ksnd_connd_starting       = 0;
 	ksocknal_data.ksnd_connd_failed_stamp   = 0;
 	ksocknal_data.ksnd_connd_starting_stamp = ktime_get_real_seconds();
-	/* must have at least 2 connds to remain responsive to accepts while
-	 * connecting */
+	/*
+	 * must have at least 2 connds to remain responsive to accepts while
+	 * connecting
+	 */
 	if (*ksocknal_tunables.ksnd_nconnds < SOCKNAL_CONND_RESV + 1)
 		*ksocknal_tunables.ksnd_nconnds = SOCKNAL_CONND_RESV + 1;
 
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index f4fa725..a4117ad 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -69,8 +69,10 @@
 
 #define SOCKNAL_VERSION_DEBUG   0     /* enable protocol version debugging */
 
-/* risk kmap deadlock on multi-frag I/O (backs off to single-frag if disabled).
- * no risk if we're not running on a CONFIG_HIGHMEM platform. */
+/*
+ * risk kmap deadlock on multi-frag I/O (backs off to single-frag if disabled).
+ * no risk if we're not running on a CONFIG_HIGHMEM platform.
+ */
 #ifdef CONFIG_HIGHMEM
 # define SOCKNAL_RISK_KMAP_DEADLOCK  0
 #else
@@ -237,15 +239,16 @@ typedef struct {
 #define SOCKNAL_INIT_DATA    1
 #define SOCKNAL_INIT_ALL     2
 
-/* A packet just assembled for transmission is represented by 1 or more
+/*
+ * A packet just assembled for transmission is represented by 1 or more
  * struct iovec fragments (the first frag contains the portals header),
  * followed by 0 or more lnet_kiov_t fragments.
  *
  * On the receive side, initially 1 struct iovec fragment is posted for
  * receive (the header).  Once the header has been received, the payload is
  * received into either struct iovec or lnet_kiov_t fragments, depending on
- * what the header matched or whether the message needs forwarding. */
-
+ * what the header matched or whether the message needs forwarding.
+ */
 struct ksock_conn;  /* forward ref */
 struct ksock_peer;  /* forward ref */
 struct ksock_route; /* forward ref */
@@ -288,8 +291,10 @@ typedef struct                             /* transmit packet */
 
 /* network zero copy callback descriptor embedded in ksock_tx_t */
 
-/* space for the rx frag descriptors; we either read a single contiguous
- * header, or up to LNET_MAX_IOV frags of payload of either type. */
+/*
+ * space for the rx frag descriptors; we either read a single contiguous
+ * header, or up to LNET_MAX_IOV frags of payload of either type.
+ */
 typedef union {
 	struct kvec      iov[LNET_MAX_IOV];
 	lnet_kiov_t      kiov[LNET_MAX_IOV];
@@ -463,11 +468,13 @@ typedef struct ksock_proto {
 	/* handle ZC ACK */
 	int        (*pro_handle_zcack)(ksock_conn_t *, __u64, __u64);
 
-	/* msg type matches the connection type:
+	/*
+	 * msg type matches the connection type:
 	 * return value:
 	 *   return MATCH_NO  : no
 	 *   return MATCH_YES : matching type
-	 *   return MATCH_MAY : can be backup */
+	 *   return MATCH_MAY : can be backup
+	 */
 	int        (*pro_match_tx)(ksock_conn_t *, ksock_tx_t *, int);
 } ksock_proto_t;
 
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index a0955d2..f53677d 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -216,8 +216,10 @@ ksocknal_transmit (ksock_conn_t *conn, ksock_tx_t *tx)
 			conn->ksnc_tx_bufnob += rc; /* account it */
 
 		if (bufnob < conn->ksnc_tx_bufnob) {
-			/* allocated send buffer bytes < computed; infer
-			 * something got ACKed */
+			/*
+			 * allocated send buffer bytes < computed; infer
+			 * something got ACKed
+			 */
 			conn->ksnc_tx_deadline =
 				cfs_time_shift(*ksocknal_tunables.ksnd_timeout);
 			conn->ksnc_peer->ksnp_last_alive = cfs_time_current();
@@ -256,8 +258,10 @@ ksocknal_recv_iov (ksock_conn_t *conn)
 
 	LASSERT(conn->ksnc_rx_niov > 0);
 
-	/* Never touch conn->ksnc_rx_iov or change connection
-	 * status inside ksocknal_lib_recv_iov */
+	/*
+	 * Never touch conn->ksnc_rx_iov or change connection
+	 * status inside ksocknal_lib_recv_iov
+	 */
 	rc = ksocknal_lib_recv_iov(conn);
 
 	if (rc <= 0)
@@ -301,8 +305,10 @@ ksocknal_recv_kiov (ksock_conn_t *conn)
 
 	LASSERT(conn->ksnc_rx_nkiov > 0);
 
-	/* Never touch conn->ksnc_rx_kiov or change connection
-	 * status inside ksocknal_lib_recv_iov */
+	/*
+	 * Never touch conn->ksnc_rx_kiov or change connection
+	 * status inside ksocknal_lib_recv_iov
+	 */
 	rc = ksocknal_lib_recv_kiov(conn);
 
 	if (rc <= 0)
@@ -340,9 +346,11 @@ ksocknal_recv_kiov (ksock_conn_t *conn)
 static int
 ksocknal_receive (ksock_conn_t *conn)
 {
-	/* Return 1 on success, 0 on EOF, < 0 on error.
+	/*
+	 * Return 1 on success, 0 on EOF, < 0 on error.
 	 * Caller checks ksnc_rx_nob_wanted to determine
-	 * progress/completion. */
+	 * progress/completion.
+	 */
 	int rc;
 
 	if (ksocknal_data.ksnd_stall_rx != 0) {
@@ -435,12 +443,14 @@ ksocknal_check_zc_req(ksock_tx_t *tx)
 	ksock_conn_t *conn = tx->tx_conn;
 	ksock_peer_t *peer = conn->ksnc_peer;
 
-	/* Set tx_msg.ksm_zc_cookies[0] to a unique non-zero cookie and add tx
+	/*
+	 * Set tx_msg.ksm_zc_cookies[0] to a unique non-zero cookie and add tx
 	 * to ksnp_zc_req_list if some fragment of this message should be sent
 	 * zero-copy.  Our peer will send an ACK containing this cookie when
 	 * she has received this message to tell us we can signal completion.
 	 * tx_msg.ksm_zc_cookies[0] remains non-zero while tx is on
-	 * ksnp_zc_req_list. */
+	 * ksnp_zc_req_list.
+	 */
 	LASSERT(tx->tx_msg.ksm_type != KSOCK_MSG_NOOP);
 	LASSERT(tx->tx_zc_capable);
 
@@ -450,9 +460,10 @@ ksocknal_check_zc_req(ksock_tx_t *tx)
 	    !conn->ksnc_zc_capable)
 		return;
 
-	/* assign cookie and queue tx to pending list, it will be released when
-	 * a matching ack is received. See ksocknal_handle_zcack() */
-
+	/*
+	 * assign cookie and queue tx to pending list, it will be released when
+	 * a matching ack is received. See ksocknal_handle_zcack()
+	 */
 	ksocknal_tx_addref(tx);
 
 	spin_lock(&peer->ksnp_lock);
@@ -688,10 +699,12 @@ ksocknal_queue_tx_locked (ksock_tx_t *tx, ksock_conn_t *conn)
 	ksock_tx_t *ztx = NULL;
 	int bufnob = 0;
 
-	/* called holding global lock (read or irq-write) and caller may
+	/*
+	 * called holding global lock (read or irq-write) and caller may
 	 * not have dropped this lock between finding conn and calling me,
 	 * so we don't need the {get,put}connsock dance to deref
-	 * ksnc_sock... */
+	 * ksnc_sock...
+	 */
 	LASSERT(!conn->ksnc_closing);
 
 	CDEBUG(D_NET, "Sending to %s ip %pI4h:%d\n",
@@ -701,12 +714,14 @@ ksocknal_queue_tx_locked (ksock_tx_t *tx, ksock_conn_t *conn)
 
 	ksocknal_tx_prep(conn, tx);
 
-	/* Ensure the frags we've been given EXACTLY match the number of
+	/*
+	 * Ensure the frags we've been given EXACTLY match the number of
 	 * bytes we want to send.  Many TCP/IP stacks disregard any total
 	 * size parameters passed to them and just look at the frags.
 	 *
 	 * We always expect at least 1 mapped fragment containing the
-	 * complete ksocknal message header. */
+	 * complete ksocknal message header.
+	 */
 	LASSERT(lnet_iov_nob (tx->tx_niov, tx->tx_iov) +
 		lnet_kiov_nob(tx->tx_nkiov, tx->tx_kiov) ==
 		(unsigned int)tx->tx_nob);
@@ -736,8 +751,10 @@ ksocknal_queue_tx_locked (ksock_tx_t *tx, ksock_conn_t *conn)
 	}
 
 	if (msg->ksm_type == KSOCK_MSG_NOOP) {
-		/* The packet is noop ZC ACK, try to piggyback the ack_cookie
-		 * on a normal packet so I don't need to send it */
+		/*
+		 * The packet is noop ZC ACK, try to piggyback the ack_cookie
+		 * on a normal packet so I don't need to send it
+		 */
 		LASSERT(msg->ksm_zc_cookies[1] != 0);
 		LASSERT(conn->ksnc_proto->pro_queue_tx_zcack != NULL);
 
@@ -745,8 +762,10 @@ ksocknal_queue_tx_locked (ksock_tx_t *tx, ksock_conn_t *conn)
 			ztx = tx; /* ZC ACK piggybacked on ztx release tx later */
 
 	} else {
-		/* It's a normal packet - can it piggback a noop zc-ack that
-		 * has been queued already? */
+		/*
+		 * It's a normal packet - can it piggback a noop zc-ack that
+		 * has been queued already?
+		 */
 		LASSERT(msg->ksm_zc_cookies[1] == 0);
 		LASSERT(conn->ksnc_proto->pro_queue_tx_msg != NULL);
 
@@ -846,9 +865,11 @@ ksocknal_launch_packet (lnet_ni_t *ni, ksock_tx_t *tx, lnet_process_id_t id)
 			if (ksocknal_find_connectable_route_locked(peer) == NULL) {
 				conn = ksocknal_find_conn_locked(peer, tx, tx->tx_nonblk);
 				if (conn != NULL) {
-					/* I've got no routes that need to be
+					/*
+					 * I've got no routes that need to be
 					 * connecting and I do have an actual
-					 * connection... */
+					 * connection...
+					 */
 					ksocknal_queue_tx_locked (tx, conn);
 					read_unlock(g_lock);
 					return 0;
@@ -932,9 +953,10 @@ ksocknal_send(lnet_ni_t *ni, void *private, lnet_msg_t *lntmsg)
 	int desc_size;
 	int rc;
 
-	/* NB 'private' is different depending on what we're sending.
-	 * Just ignore it... */
-
+	/*
+	 * NB 'private' is different depending on what we're sending.
+	 * Just ignore it...
+	 */
 	CDEBUG(D_NET, "sending %u bytes in %d frags to %s\n",
 	       payload_nob, payload_niov, libcfs_id2str(target));
 
@@ -1075,9 +1097,10 @@ ksocknal_new_packet (ksock_conn_t *conn, int nob_to_skip)
 		return 1;
 	}
 
-	/* Set up to skip as much as possible now.  If there's more left
-	 * (ran out of iov entries) we'll get called again */
-
+	/*
+	 * Set up to skip as much as possible now.  If there's more left
+	 * (ran out of iov entries) we'll get called again
+	 */
 	conn->ksnc_rx_state = SOCKNAL_RX_SLOP;
 	conn->ksnc_rx_nob_left = nob_to_skip;
 	conn->ksnc_rx_iov = (struct kvec *)&conn->ksnc_rx_iov_space;
@@ -1416,10 +1439,12 @@ int ksocknal_scheduler(void *arg)
 			LASSERT(conn->ksnc_rx_scheduled);
 			LASSERT(conn->ksnc_rx_ready);
 
-			/* clear rx_ready in case receive isn't complete.
+			/*
+			 * clear rx_ready in case receive isn't complete.
 			 * Do it BEFORE we call process_recv, since
 			 * data_ready can set it any time after we release
-			 * kss_lock. */
+			 * kss_lock.
+			 */
 			conn->ksnc_rx_ready = 0;
 			spin_unlock_bh(&sched->kss_lock);
 
@@ -1435,9 +1460,11 @@ int ksocknal_scheduler(void *arg)
 				conn->ksnc_rx_ready = 1;
 
 			if (conn->ksnc_rx_state == SOCKNAL_RX_PARSE) {
-				/* Conn blocked waiting for ksocknal_recv()
+				/*
+				 * Conn blocked waiting for ksocknal_recv()
 				 * I change its state (under lock) to signal
-				 * it can be rescheduled */
+				 * it can be rescheduled
+				 */
 				conn->ksnc_rx_state = SOCKNAL_RX_PARSE_WAIT;
 			} else if (conn->ksnc_rx_ready) {
 				/* reschedule for rx */
@@ -1478,16 +1505,20 @@ int ksocknal_scheduler(void *arg)
 			/* dequeue now so empty list => more to send */
 			list_del(&tx->tx_list);
 
-			/* Clear tx_ready in case send isn't complete.  Do
+			/*
+			 * Clear tx_ready in case send isn't complete.  Do
 			 * it BEFORE we call process_transmit, since
 			 * write_space can set it any time after we release
-			 * kss_lock. */
+			 * kss_lock.
+			 */
 			conn->ksnc_tx_ready = 0;
 			spin_unlock_bh(&sched->kss_lock);
 
 			if (!list_empty(&zlist)) {
-				/* free zombie noop txs, it's fast because
-				 * noop txs are just put in freelist */
+				/*
+				 * free zombie noop txs, it's fast because
+				 * noop txs are just put in freelist
+				 */
 				ksocknal_txlist_done(NULL, &zlist, 0);
 			}
 
@@ -1508,8 +1539,10 @@ int ksocknal_scheduler(void *arg)
 			}
 
 			if (rc == -ENOMEM) {
-				/* Do nothing; after a short timeout, this
-				 * conn will be reposted on kss_tx_conns. */
+				/*
+				 * Do nothing; after a short timeout, this
+				 * conn will be reposted on kss_tx_conns.
+				 */
 			} else if (conn->ksnc_tx_ready &&
 				   !list_empty(&conn->ksnc_tx_queue)) {
 				/* reschedule for tx */
@@ -1850,8 +1883,10 @@ ksocknal_connect (ksock_route_t *route)
 	for (;;) {
 		wanted = ksocknal_route_mask() & ~route->ksnr_connected;
 
-		/* stop connecting if peer/route got closed under me, or
-		 * route got connected while queued */
+		/*
+		 * stop connecting if peer/route got closed under me, or
+		 * route got connected while queued
+		 */
 		if (peer->ksnp_closing || route->ksnr_deleted ||
 		    wanted == 0) {
 			retry_later = 0;
@@ -1904,8 +1939,10 @@ ksocknal_connect (ksock_route_t *route)
 			goto failed;
 		}
 
-		/* A +ve RC means I have to retry because I lost the connection
-		 * race or I have to renegotiate protocol version */
+		/*
+		 * A +ve RC means I have to retry because I lost the connection
+		 * race or I have to renegotiate protocol version
+		 */
 		retry_later = (rc != 0);
 		if (retry_later)
 			CDEBUG(D_NET, "peer %s: conn race, retry later.\n",
@@ -1918,15 +1955,18 @@ ksocknal_connect (ksock_route_t *route)
 	route->ksnr_connecting = 0;
 
 	if (retry_later) {
-		/* re-queue for attention; this frees me up to handle
-		 * the peer's incoming connection request */
-
+		/*
+		 * re-queue for attention; this frees me up to handle
+		 * the peer's incoming connection request
+		 */
 		if (rc == EALREADY ||
 		    (rc == 0 && peer->ksnp_accepting > 0)) {
-			/* We want to introduce a delay before next
+			/*
+			 * We want to introduce a delay before next
 			 * attempt to connect if we lost conn race,
 			 * but the race is resolved quickly usually,
-			 * so min_reconnectms should be good heuristic */
+			 * so min_reconnectms should be good heuristic
+			 */
 			route->ksnr_retry_interval =
 				cfs_time_seconds(*ksocknal_tunables.ksnd_min_reconnectms)/1000;
 			route->ksnr_timeout = cfs_time_add(cfs_time_current(),
@@ -1963,16 +2003,20 @@ ksocknal_connect (ksock_route_t *route)
 	    ksocknal_find_connecting_route_locked(peer) == NULL) {
 		ksock_conn_t *conn;
 
-		/* ksnp_tx_queue is queued on a conn on successful
-		 * connection for V1.x and V2.x */
+		/*
+		 * ksnp_tx_queue is queued on a conn on successful
+		 * connection for V1.x and V2.x
+		 */
 		if (!list_empty (&peer->ksnp_conns)) {
 			conn = list_entry(peer->ksnp_conns.next,
 					      ksock_conn_t, ksnc_list);
 			LASSERT (conn->ksnc_proto == &ksocknal_protocol_v3x);
 		}
 
-		/* take all the blocked packets while I've got the lock and
-		 * complete below... */
+		/*
+		 * take all the blocked packets while I've got the lock and
+		 * complete below...
+		 */
 		list_splice_init(&peer->ksnp_tx_queue, &zombies);
 	}
 
@@ -2011,8 +2055,10 @@ ksocknal_connd_check_start(time64_t sec, long *timeout)
 
 	if (total >= *ksocknal_tunables.ksnd_nconnds_max ||
 	    total > ksocknal_data.ksnd_connd_connecting + SOCKNAL_CONND_RESV) {
-		/* can't create more connd, or still have enough
-		 * threads to handle more connecting */
+		/*
+		 * can't create more connd, or still have enough
+		 * threads to handle more connecting
+		 */
 		return 0;
 	}
 
@@ -2093,8 +2139,10 @@ ksocknal_connd_check_stop(time64_t sec, long *timeout)
 	       ksocknal_data.ksnd_connd_connecting + SOCKNAL_CONND_RESV;
 }
 
-/* Go through connd_routes queue looking for a route that we can process
- * right now, @timeout_p can be updated if we need to come back later */
+/*
+ * Go through connd_routes queue looking for a route that we can process
+ * right now, @timeout_p can be updated if we need to come back later
+ */
 static ksock_route_t *
 ksocknal_connd_get_route_locked(signed long *timeout_p)
 {
@@ -2172,9 +2220,11 @@ ksocknal_connd (void *arg)
 			spin_lock_bh(connd_lock);
 		}
 
-		/* Only handle an outgoing connection request if there
+		/*
+		 * Only handle an outgoing connection request if there
 		 * is a thread left to handle incoming connections and
-		 * create new connd */
+		 * create new connd
+		 */
 		if (ksocknal_data.ksnd_connd_connecting + SOCKNAL_CONND_RESV <
 		    ksocknal_data.ksnd_connd_running) {
 			route = ksocknal_connd_get_route_locked(&timeout);
@@ -2245,8 +2295,10 @@ ksocknal_find_timed_out_conn (ksock_peer_t *peer)
 		/* Don't need the {get,put}connsock dance to deref ksnc_sock */
 		LASSERT(!conn->ksnc_closing);
 
-		/* SOCK_ERROR will reset error code of socket in
-		 * some platform (like Darwin8.x) */
+		/*
+		 * SOCK_ERROR will reset error code of socket in
+		 * some platform (like Darwin8.x)
+		 */
 		error = conn->ksnc_sock->sk->sk_err;
 		if (error != 0) {
 			ksocknal_conn_addref(conn);
@@ -2295,8 +2347,10 @@ ksocknal_find_timed_out_conn (ksock_peer_t *peer)
 		     conn->ksnc_sock->sk->sk_wmem_queued != 0) &&
 		    cfs_time_aftereq(cfs_time_current(),
 				     conn->ksnc_tx_deadline)) {
-			/* Timed out messages queued for sending or
-			 * buffered in the socket's send buffer */
+			/*
+			 * Timed out messages queued for sending or
+			 * buffered in the socket's send buffer
+			 */
 			ksocknal_conn_addref(conn);
 			CNETERR("Timeout sending data to %s (%pI4h:%d) the network or that node may be down.\n",
 				libcfs_id2str(peer->ksnp_id),
@@ -2357,8 +2411,10 @@ ksocknal_send_keepalive_locked(ksock_peer_t *peer)
 	if (time_before(cfs_time_current(), peer->ksnp_send_keepalive))
 		return 0;
 
-	/* retry 10 secs later, so we wouldn't put pressure
-	 * on this peer if we failed to send keepalive this time */
+	/*
+	 * retry 10 secs later, so we wouldn't put pressure
+	 * on this peer if we failed to send keepalive this time
+	 */
 	peer->ksnp_send_keepalive = cfs_time_shift(10);
 
 	conn = ksocknal_find_conn_locked(peer, NULL, 1);
@@ -2404,9 +2460,11 @@ ksocknal_check_peer_timeouts (int idx)
 	ksock_tx_t *tx;
 
  again:
-	/* NB. We expect to have a look at all the peers and not find any
+	/*
+	 * NB. We expect to have a look at all the peers and not find any
 	 * connections to time out, so we just use a shared lock while we
-	 * take a look... */
+	 * take a look...
+	 */
 	read_lock(&ksocknal_data.ksnd_global_lock);
 
 	list_for_each_entry(peer, peers, ksnp_list) {
@@ -2426,15 +2484,19 @@ ksocknal_check_peer_timeouts (int idx)
 
 			ksocknal_close_conn_and_siblings (conn, -ETIMEDOUT);
 
-			/* NB we won't find this one again, but we can't
+			/*
+			 * NB we won't find this one again, but we can't
 			 * just proceed with the next peer, since we dropped
-			 * ksnd_global_lock and it might be dead already! */
+			 * ksnd_global_lock and it might be dead already!
+			 */
 			ksocknal_conn_decref(conn);
 			goto again;
 		}
 
-		/* we can't process stale txs right here because we're
-		 * holding only shared lock */
+		/*
+		 * we can't process stale txs right here because we're
+		 * holding only shared lock
+		 */
 		if (!list_empty (&peer->ksnp_tx_queue)) {
 			ksock_tx_t *tx =
 				list_entry (peer->ksnp_tx_queue.next,
@@ -2581,13 +2643,14 @@ ksocknal_reaper (void *arg)
 			const int p = 1;
 			int chunk = ksocknal_data.ksnd_peer_hash_size;
 
-			/* Time to check for timeouts on a few more peers: I do
+			/*
+			 * Time to check for timeouts on a few more peers: I do
 			 * checks every 'p' seconds on a proportion of the peer
 			 * table and I need to check every connection 'n' times
 			 * within a timeout interval, to ensure I detect a
 			 * timeout on any connection within (n+1)/n times the
-			 * timeout interval. */
-
+			 * timeout interval.
+			 */
 			if (*ksocknal_tunables.ksnd_timeout > n * p)
 				chunk = (chunk * n * p) /
 					*ksocknal_tunables.ksnd_timeout;
@@ -2604,9 +2667,11 @@ ksocknal_reaper (void *arg)
 		}
 
 		if (nenomem_conns != 0) {
-			/* Reduce my timeout if I rescheduled ENOMEM conns.
+			/*
+			 * Reduce my timeout if I rescheduled ENOMEM conns.
 			 * This also prevents me getting woken immediately
-			 * if any go back on my enomem list. */
+			 * if any go back on my enomem list.
+			 */
 			timeout = SOCKNAL_ENOMEM_RETRY;
 		}
 		ksocknal_data.ksnd_reaper_waketime =
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
index cf8e43b..f0edf30 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
@@ -67,8 +67,10 @@ ksocknal_lib_zc_capable(ksock_conn_t *conn)
 	if (conn->ksnc_proto == &ksocknal_protocol_v1x)
 		return 0;
 
-	/* ZC if the socket supports scatter/gather and doesn't need software
-	 * checksums */
+	/*
+	 * ZC if the socket supports scatter/gather and doesn't need software
+	 * checksums
+	 */
 	return ((caps & NETIF_F_SG) != 0 && (caps & NETIF_F_CSUM_MASK) != 0);
 }
 
@@ -85,9 +87,10 @@ ksocknal_lib_send_iov(ksock_conn_t *conn, ksock_tx_t *tx)
 	    tx->tx_msg.ksm_csum == 0)		     /* not checksummed  */
 		ksocknal_lib_csum_tx(tx);
 
-	/* NB we can't trust socket ops to either consume our iovs
-	 * or leave them alone. */
-
+	/*
+	 * NB we can't trust socket ops to either consume our iovs
+	 * or leave them alone.
+	 */
 	{
 #if SOCKNAL_SINGLE_FRAG_TX
 		struct kvec scratch;
@@ -125,8 +128,10 @@ ksocknal_lib_send_kiov(ksock_conn_t *conn, ksock_tx_t *tx)
 	/* Not NOOP message */
 	LASSERT(tx->tx_lnetmsg != NULL);
 
-	/* NB we can't trust socket ops to either consume our iovs
-	 * or leave them alone. */
+	/*
+	 * NB we can't trust socket ops to either consume our iovs
+	 * or leave them alone.
+	 */
 	if (tx->tx_msg.ksm_zc_cookies[0] != 0) {
 		/* Zero copy is enabled */
 		struct sock *sk = sock->sk;
@@ -187,11 +192,12 @@ ksocknal_lib_eager_ack(ksock_conn_t *conn)
 	int opt = 1;
 	struct socket *sock = conn->ksnc_sock;
 
-	/* Remind the socket to ACK eagerly.  If I don't, the socket might
+	/*
+	 * Remind the socket to ACK eagerly.  If I don't, the socket might
 	 * think I'm about to send something it could piggy-back the ACK
 	 * on, introducing delay in completing zero-copy sends in my
-	 * peer. */
-
+	 * peer.
+	 */
 	kernel_setsockopt(sock, SOL_TCP, TCP_QUICKACK,
 			       (char *)&opt, sizeof(opt));
 }
@@ -218,8 +224,10 @@ ksocknal_lib_recv_iov(ksock_conn_t *conn)
 	int sum;
 	__u32 saved_csum;
 
-	/* NB we can't trust socket ops to either consume our iovs
-	 * or leave them alone. */
+	/*
+	 * NB we can't trust socket ops to either consume our iovs
+	 * or leave them alone.
+	 */
 	LASSERT(niov > 0);
 
 	for (nob = i = 0; i < niov; i++) {
@@ -329,8 +337,10 @@ ksocknal_lib_recv_kiov(ksock_conn_t *conn)
 	int fragnob;
 	int n;
 
-	/* NB we can't trust socket ops to either consume our iovs
-	 * or leave them alone. */
+	/*
+	 * NB we can't trust socket ops to either consume our iovs
+	 * or leave them alone.
+	 */
 	addr = ksocknal_lib_kiov_vmap(kiov, niov, scratchiov, pages);
 	if (addr != NULL) {
 		nob = scratchiov[0].iov_len;
@@ -354,10 +364,12 @@ ksocknal_lib_recv_kiov(ksock_conn_t *conn)
 		for (i = 0, sum = rc; sum > 0; i++, sum -= fragnob) {
 			LASSERT(i < niov);
 
-			/* Dang! have to kmap again because I have nowhere to
+			/*
+			 * Dang! have to kmap again because I have nowhere to
 			 * stash the mapped address.  But by doing it while the
 			 * page is still mapped, the kernel just bumps the map
-			 * count and returns me the address it stashed. */
+			 * count and returns me the address it stashed.
+			 */
 			base = kmap(kiov[i].kiov_page) + kiov[i].kiov_offset;
 			fragnob = kiov[i].kiov_len;
 			if (fragnob > sum)
@@ -463,9 +475,10 @@ ksocknal_lib_setup_sock(struct socket *sock)
 
 	sock->sk->sk_allocation = GFP_NOFS;
 
-	/* Ensure this socket aborts active sends immediately when we close
-	 * it. */
-
+	/*
+	 * Ensure this socket aborts active sends immediately when we close
+	 * it.
+	 */
 	linger.l_onoff = 0;
 	linger.l_linger = 0;
 
@@ -637,10 +650,11 @@ ksocknal_write_space(struct sock *sk)
 	if (wspace >= min_wpace) {	      /* got enough space */
 		ksocknal_write_callback(conn);
 
-		/* Clear SOCK_NOSPACE _after_ ksocknal_write_callback so the
+		/*
+		 * Clear SOCK_NOSPACE _after_ ksocknal_write_callback so the
 		 * ENOMEM check in ksocknal_transmit is race-free (think about
-		 * it). */
-
+		 * it).
+		 */
 		clear_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
 	}
 
@@ -666,15 +680,19 @@ ksocknal_lib_set_callback(struct socket *sock,  ksock_conn_t *conn)
 void
 ksocknal_lib_reset_callback(struct socket *sock, ksock_conn_t *conn)
 {
-	/* Remove conn's network callbacks.
+	/*
+	 * Remove conn's network callbacks.
 	 * NB I _have_ to restore the callback, rather than storing a noop,
-	 * since the socket could survive past this module being unloaded!! */
+	 * since the socket could survive past this module being unloaded!!
+	 */
 	sock->sk->sk_data_ready = conn->ksnc_saved_data_ready;
 	sock->sk->sk_write_space = conn->ksnc_saved_write_space;
 
-	/* A callback could be in progress already; they hold a read lock
+	/*
+	 * A callback could be in progress already; they hold a read lock
 	 * on ksnd_global_lock (to serialise with me) and NOOP if
-	 * sk_user_data is NULL. */
+	 * sk_user_data is NULL.
+	 */
 	sock->sk->sk_user_data = NULL;
 
 	return ;
@@ -691,14 +709,16 @@ ksocknal_lib_memory_pressure(ksock_conn_t *conn)
 
 	if (!test_bit(SOCK_NOSPACE, &conn->ksnc_sock->flags) &&
 	    !conn->ksnc_tx_ready) {
-		/* SOCK_NOSPACE is set when the socket fills
+		/*
+		 * SOCK_NOSPACE is set when the socket fills
 		 * and cleared in the write_space callback
 		 * (which also sets ksnc_tx_ready).  If
 		 * SOCK_NOSPACE and ksnc_tx_ready are BOTH
 		 * zero, I didn't fill the socket and
 		 * write_space won't reschedule me, so I
 		 * return -ENOMEM to get my caller to retry
-		 * after a timeout */
+		 * after a timeout
+		 */
 		rc = -ENOMEM;
 	}
 
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c
index fdb2b23..374ba67 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_modparams.c
@@ -41,8 +41,10 @@ static int peer_timeout = 180;
 module_param(peer_timeout, int, 0444);
 MODULE_PARM_DESC(peer_timeout, "Seconds without aliveness news to declare peer dead (<=0 to disable)");
 
-/* Number of daemons in each thread pool which is percpt,
- * we will estimate reasonable value based on CPUs if it's not set. */
+/*
+ * Number of daemons in each thread pool which is percpt,
+ * we will estimate reasonable value based on CPUs if it's not set.
+ */
 static unsigned int nscheds;
 module_param(nscheds, int, 0444);
 MODULE_PARM_DESC(nscheds, "# scheduler daemons in each pool while starting");
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
index 986bce4..82ac02c 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
@@ -468,8 +468,10 @@ ksocknal_send_hello_v1(ksock_conn_t *conn, ksock_hello_msg_t *hello)
 
 	hmv = (lnet_magicversion_t *)&hdr->dest_nid;
 
-	/* Re-organize V2.x message header to V1.x (lnet_hdr_t)
-	 * header and send out */
+	/*
+	 * Re-organize V2.x message header to V1.x (lnet_hdr_t)
+	 * header and send out
+	 */
 	hmv->magic         = cpu_to_le32 (LNET_PROTO_TCP_MAGIC);
 	hmv->version_major = cpu_to_le16 (KSOCK_PROTO_V1_MAJOR);
 	hmv->version_minor = cpu_to_le16 (KSOCK_PROTO_V1_MINOR);
diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
index fed57d9..5260de2 100644
--- a/drivers/staging/lustre/lnet/lnet/acceptor.c
+++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
@@ -78,9 +78,11 @@ static char *accept_type;
 static int
 lnet_acceptor_get_tunables(void)
 {
-	/* Userland acceptor uses 'accept_type' instead of 'accept', due to
+	/*
+	 * Userland acceptor uses 'accept_type' instead of 'accept', due to
 	 * conflict with 'accept(2)', but kernel acceptor still uses 'accept'
-	 * for compatibility. Hence the trick. */
+	 * for compatibility. Hence the trick.
+	 */
 	accept_type = accept;
 	return 0;
 }
@@ -223,11 +225,12 @@ lnet_accept(struct socket *sock, __u32 magic)
 	if (!lnet_accept_magic(magic, LNET_PROTO_ACCEPTOR_MAGIC)) {
 
 		if (lnet_accept_magic(magic, LNET_PROTO_MAGIC)) {
-			/* future version compatibility!
+			/*
+			 * future version compatibility!
 			 * When LNET unifies protocols over all LNDs, the first
-			 * thing sent will be a version query.  I send back
-			 * LNET_PROTO_ACCEPTOR_MAGIC to tell her I'm "old" */
-
+			 * thing sent will be a version query. I send back
+			 * LNET_PROTO_ACCEPTOR_MAGIC to tell her I'm "old"
+			 */
 			memset(&cr, 0, sizeof(cr));
 			cr.acr_magic = LNET_PROTO_ACCEPTOR_MAGIC;
 			cr.acr_version = LNET_PROTO_ACCEPTOR_VERSION;
@@ -264,10 +267,12 @@ lnet_accept(struct socket *sock, __u32 magic)
 		__swab32s(&cr.acr_version);
 
 	if (cr.acr_version != LNET_PROTO_ACCEPTOR_VERSION) {
-		/* future version compatibility!
+		/*
+		 * future version compatibility!
 		 * An acceptor-specific protocol rev will first send a version
 		 * query.  I send back my current version to tell her I'm
-		 * "old". */
+		 * "old".
+		 */
 		int peer_version = cr.acr_version;
 
 		memset(&cr, 0, sizeof(cr));
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index d33fbdf..79447bf 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -174,10 +174,12 @@ lnet_create_locks(void)
 
 static void lnet_assert_wire_constants(void)
 {
-	/* Wire protocol assertions generated by 'wirecheck'
+	/*
+	 * Wire protocol assertions generated by 'wirecheck'
 	 * running on Linux robert.bartonsoftware.com 2.6.8-1.521
 	 * #1 Mon Aug 16 09:01:18 EDT 2004 i686 athlon i386 GNU/Linux
-	 * with gcc version 3.3.3 20040412 (Red Hat Linux 3.3.3-7) */
+	 * with gcc version 3.3.3 20040412 (Red Hat Linux 3.3.3-7)
+	 */
 
 	/* Constants... */
 	CLASSERT(LNET_PROTO_TCP_MAGIC == 0xeebc0ded);
@@ -398,9 +400,11 @@ lnet_res_container_cleanup(struct lnet_res_container *rec)
 	}
 
 	if (count > 0) {
-		/* Found alive MD/ME/EQ, user really should unlink/free
+		/*
+		 * Found alive MD/ME/EQ, user really should unlink/free
 		 * all of them before finalize LNet, but if someone didn't,
-		 * we have to recycle garbage for him */
+		 * we have to recycle garbage for him
+		 */
 		CERROR("%d active elements on exit of %s container\n",
 		       count, lnet_res_type2str(rec->rec_type));
 	}
@@ -605,11 +609,12 @@ lnet_prepare(lnet_pid_t requested_pid)
 int
 lnet_unprepare(void)
 {
-	/* NB no LNET_LOCK since this is the last reference.  All LND instances
+	/*
+	 * NB no LNET_LOCK since this is the last reference.  All LND instances
 	 * have shut down already, so it is safe to unlink and free all
 	 * descriptors, even those that appear committed to a network op (eg MD
-	 * with non-zero pending count) */
-
+	 * with non-zero pending count)
+	 */
 	lnet_fail_nid(LNET_NID_ANY, 0);
 
 	LASSERT(the_lnet.ln_refcount == 0);
@@ -877,18 +882,24 @@ lnet_shutdown_lndnis(void)
 
 	lnet_net_unlock(LNET_LOCK_EX);
 
-	/* Clear lazy portals and drop delayed messages which hold refs
-	 * on their lnet_msg_t::msg_rxpeer */
+	/*
+	 * Clear lazy portals and drop delayed messages which hold refs
+	 * on their lnet_msg_t::msg_rxpeer
+	 */
 	for (i = 0; i < the_lnet.ln_nportals; i++)
 		LNetClearLazyPortal(i);
 
-	/* Clear the peer table and wait for all peers to go (they hold refs on
-	 * their NIs) */
+	/*
+	 * Clear the peer table and wait for all peers to go (they hold refs on
+	 * their NIs)
+	 */
 	lnet_peer_tables_cleanup();
 
 	lnet_net_lock(LNET_LOCK_EX);
-	/* Now wait for the NI's I just nuked to show up on ln_zombie_nis
-	 * and shut them down in guaranteed thread context */
+	/*
+	 * Now wait for the NI's I just nuked to show up on ln_zombie_nis
+	 * and shut them down in guaranteed thread context
+	 */
 	i = 2;
 	while (!list_empty(&the_lnet.ln_nis_zombie)) {
 		int *ref;
@@ -926,9 +937,10 @@ lnet_shutdown_lndnis(void)
 		LASSERT(!in_interrupt());
 		(ni->ni_lnd->lnd_shutdown)(ni);
 
-		/* can't deref lnd anymore now; it might have unregistered
-		 * itself...  */
-
+		/*
+		 * can't deref lnd anymore now; it might have unregistered
+		 * itself...
+		 */
 		if (!islo)
 			CDEBUG(D_LNI, "Removed LNI %s\n",
 			       libcfs_nid2str(ni->ni_nid));
@@ -1139,9 +1151,11 @@ lnet_init(void)
 	INIT_LIST_HEAD(&the_lnet.ln_rcd_zombie);
 	INIT_LIST_HEAD(&the_lnet.ln_rcd_deathrow);
 
-	/* The hash table size is the number of bits it takes to express the set
+	/*
+	 * The hash table size is the number of bits it takes to express the set
 	 * ln_num_routes, minus 1 (better to under estimate than over so we
-	 * don't waste memory). */
+	 * don't waste memory).
+	 */
 	if (rnet_htable_size <= 0)
 		rnet_htable_size = LNET_REMOTE_NETS_HASH_DEFAULT;
 	else if (rnet_htable_size > LNET_REMOTE_NETS_HASH_MAX)
@@ -1149,9 +1163,11 @@ lnet_init(void)
 	the_lnet.ln_remote_nets_hbits = max_t(int, 1,
 					   order_base_2(rnet_htable_size) - 1);
 
-	/* All LNDs apart from the LOLND are in separate modules.  They
+	/*
+	 * All LNDs apart from the LOLND are in separate modules.  They
 	 * register themselves when their module loads, and unregister
-	 * themselves when their module is unloaded. */
+	 * themselves when their module is unloaded.
+	 */
 	lnet_register_lnd(&the_lolnd);
 	return 0;
 }
@@ -1244,8 +1260,10 @@ LNetNIInit(lnet_pid_t requested_pid)
 	the_lnet.ln_refcount = 1;
 	/* Now I may use my own API functions... */
 
-	/* NB router checker needs the_lnet.ln_ping_info in
-	 * lnet_router_checker -> lnet_update_ni_status_locked */
+	/*
+	 * NB router checker needs the_lnet.ln_ping_info in
+	 * lnet_router_checker -> lnet_update_ni_status_locked
+	  */
 	rc = lnet_ping_target_init();
 	if (rc != 0)
 		goto failed3;
@@ -1554,8 +1572,10 @@ lnet_ping_target_init(void)
 	if (rc != 0)
 		return rc;
 
-	/* We can have a tiny EQ since we only need to see the unlink event on
-	 * teardown, which by definition is the last one! */
+	/*
+	 * We can have a tiny EQ since we only need to see the unlink event on
+	 * teardown, which by definition is the last one!
+	 */
 	rc = LNetEQAlloc(2, LNET_EQ_HANDLER_NONE, &the_lnet.ln_ping_target_eq);
 	if (rc != 0) {
 		CERROR("Can't allocate ping EQ: %d\n", rc);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-eq.c b/drivers/staging/lustre/lnet/lnet/lib-eq.c
index bfbc313..e543cb4 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-eq.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-eq.c
@@ -75,18 +75,21 @@ LNetEQAlloc(unsigned int count, lnet_eq_handler_t callback,
 	LASSERT(the_lnet.ln_init);
 	LASSERT(the_lnet.ln_refcount > 0);
 
-	/* We need count to be a power of 2 so that when eq_{enq,deq}_seq
+	/*
+	 * We need count to be a power of 2 so that when eq_{enq,deq}_seq
 	 * overflow, they don't skip entries, so the queue has the same
-	 * apparent capacity at all times */
-
+	 * apparent capacity at all times
+	 */
 	if (count)
 		count = roundup_pow_of_two(count);
 
 	if (callback != LNET_EQ_HANDLER_NONE && count != 0)
 		CWARN("EQ callback is guaranteed to get every event, do you still want to set eqcount %d for polling event which will have locking overhead? Please contact with developer to confirm\n", count);
 
-	/* count can be 0 if only need callback, we can eliminate
-	 * overhead of enqueue event */
+	/*
+	 * count can be 0 if only need callback, we can eliminate
+	 * overhead of enqueue event
+	 */
 	if (count == 0 && callback == LNET_EQ_HANDLER_NONE)
 		return -EINVAL;
 
@@ -98,8 +101,10 @@ LNetEQAlloc(unsigned int count, lnet_eq_handler_t callback,
 		LIBCFS_ALLOC(eq->eq_events, count * sizeof(lnet_event_t));
 		if (eq->eq_events == NULL)
 			goto failed;
-		/* NB allocator has set all event sequence numbers to 0,
-		 * so all them should be earlier than eq_deq_seq */
+		/*
+		 * NB allocator has set all event sequence numbers to 0,
+		 * so all them should be earlier than eq_deq_seq
+		 */
 	}
 
 	eq->eq_deq_seq = 1;
@@ -114,8 +119,10 @@ LNetEQAlloc(unsigned int count, lnet_eq_handler_t callback,
 
 	/* MUST hold both exclusive lnet_res_lock */
 	lnet_res_lock(LNET_LOCK_EX);
-	/* NB: hold lnet_eq_wait_lock for EQ link/unlink, so we can do
-	 * both EQ lookup and poll event with only lnet_eq_wait_lock */
+	/*
+	 * NB: hold lnet_eq_wait_lock for EQ link/unlink, so we can do
+	 * both EQ lookup and poll event with only lnet_eq_wait_lock
+	 */
 	lnet_eq_wait_lock();
 
 	lnet_res_lh_initialize(&the_lnet.ln_eq_container, &eq->eq_lh);
@@ -164,8 +171,10 @@ LNetEQFree(lnet_handle_eq_t eqh)
 	LASSERT(the_lnet.ln_refcount > 0);
 
 	lnet_res_lock(LNET_LOCK_EX);
-	/* NB: hold lnet_eq_wait_lock for EQ link/unlink, so we can do
-	 * both EQ lookup and poll event with only lnet_eq_wait_lock */
+	/*
+	 * NB: hold lnet_eq_wait_lock for EQ link/unlink, so we can do
+	 * both EQ lookup and poll event with only lnet_eq_wait_lock
+	 */
 	lnet_eq_wait_lock();
 
 	eq = lnet_handle2eq(&eqh);
@@ -256,8 +265,10 @@ lnet_eq_dequeue_event(lnet_eq_t *eq, lnet_event_t *ev)
 	if (eq->eq_deq_seq == new_event->sequence) {
 		rc = 1;
 	} else {
-		/* don't complain with CERROR: some EQs are sized small
-		 * anyway; if it's important, the caller should complain */
+		/*
+		 * don't complain with CERROR: some EQs are sized small
+		 * anyway; if it's important, the caller should complain
+		 */
 		CDEBUG(D_NET, "Event Queue Overflow: eq seq %lu ev seq %lu\n",
 		       eq->eq_deq_seq, new_event->sequence);
 		rc = -EOVERFLOW;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-md.c b/drivers/staging/lustre/lnet/lnet/lib-md.c
index b3d8364..fef517d 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-md.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-md.c
@@ -52,9 +52,11 @@ lnet_md_unlink(lnet_libmd_t *md)
 
 		md->md_flags |= LNET_MD_FLAG_ZOMBIE;
 
-		/* Disassociate from ME (if any),
+		/*
+		 * Disassociate from ME (if any),
 		 * and unlink it if it was created
-		 * with LNET_UNLINK */
+		 * with LNET_UNLINK
+		 */
 		if (me != NULL) {
 			/* detach MD from portal */
 			lnet_ptl_detach_md(me, md);
@@ -169,14 +171,18 @@ lnet_md_link(lnet_libmd_t *md, lnet_handle_eq_t eq_handle, int cpt)
 {
 	struct lnet_res_container *container = the_lnet.ln_md_containers[cpt];
 
-	/* NB we are passed an allocated, but inactive md.
+	/*
+	 * NB we are passed an allocated, but inactive md.
 	 * if we return success, caller may lnet_md_unlink() it.
 	 * otherwise caller may only lnet_md_free() it.
 	 */
-	/* This implementation doesn't know how to create START events or
+	/*
+	 * This implementation doesn't know how to create START events or
 	 * disable END events.  Best to LASSERT our caller is compliant so
-	 * we find out quickly...  */
-	/*  TODO - reevaluate what should be here in light of
+	 * we find out quickly...
+	 */
+	/*
+	 * TODO - reevaluate what should be here in light of
 	 * the removal of the start and end events
 	 * maybe there we shouldn't even allow LNET_EQ_NONE!)
 	 * LASSERT (eq == NULL);
@@ -306,8 +312,10 @@ LNetMDAttach(lnet_handle_me_t meh, lnet_md_t umd,
 	if (rc != 0)
 		goto failed;
 
-	/* attach this MD to portal of ME and check if it matches any
-	 * blocked msgs on this portal */
+	/*
+	 * attach this MD to portal of ME and check if it matches any
+	 * blocked msgs on this portal
+	 */
 	lnet_ptl_attach_md(me, md, &matches, &drops);
 
 	lnet_md2handle(handle, md);
@@ -438,9 +446,11 @@ LNetMDUnlink(lnet_handle_md_t mdh)
 	}
 
 	md->md_flags |= LNET_MD_FLAG_ABORTED;
-	/* If the MD is busy, lnet_md_unlink just marks it for deletion, and
+	/*
+	 * If the MD is busy, lnet_md_unlink just marks it for deletion, and
 	 * when the LND is done, the completion event flags that the MD was
-	 * unlinked.  Otherwise, we enqueue an event now... */
+	 * unlinked.  Otherwise, we enqueue an event now...
+	 */
 	if (md->md_eq != NULL && md->md_refcount == 0) {
 		lnet_build_unlink_event(md, &ev);
 		lnet_eq_enqueue_event(md->md_eq, &ev);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index fb8f7be..0268ce5 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -119,9 +119,11 @@ fail_peer(lnet_nid_t nid, int outgoing)
 		if (tp->tp_threshold == 0) {
 			/* zombie entry */
 			if (outgoing) {
-				/* only cull zombies on outgoing tests,
+				/*
+				 * only cull zombies on outgoing tests,
 				 * since we may be at interrupt priority on
-				 * incoming messages. */
+				 * incoming messages.
+				 */
 				list_del(&tp->tp_list);
 				list_add(&tp->tp_list, &cull);
 			}
@@ -233,9 +235,11 @@ lnet_extract_iov(int dst_niov, struct kvec *dst,
 		  int src_niov, struct kvec *src,
 		  unsigned int offset, unsigned int len)
 {
-	/* Initialise 'dst' to the subset of 'src' starting at 'offset',
+	/*
+	 * Initialise 'dst' to the subset of 'src' starting at 'offset',
 	 * for exactly 'len' bytes, and return the number of entries.
-	 * NB not destructive to 'src' */
+	 * NB not destructive to 'src'
+	 */
 	unsigned int frag_len;
 	unsigned int niov;
 
@@ -332,10 +336,11 @@ lnet_copy_kiov2kiov(unsigned int ndiov, lnet_kiov_t *diov, unsigned int doffset,
 			saddr = ((char *)kmap(siov->kiov_page)) +
 				siov->kiov_offset + soffset;
 
-		/* Vanishing risk of kmap deadlock when mapping 2 pages.
+		/*
+		 * Vanishing risk of kmap deadlock when mapping 2 pages.
 		 * However in practice at least one of the kiovs will be mapped
-		 * kernel pages and the map/unmap will be NOOPs */
-
+		 * kernel pages and the map/unmap will be NOOPs
+		 */
 		memcpy(daddr, saddr, this_nob);
 		nob -= this_nob;
 
@@ -514,9 +519,11 @@ lnet_extract_kiov(int dst_niov, lnet_kiov_t *dst,
 		   int src_niov, lnet_kiov_t *src,
 		   unsigned int offset, unsigned int len)
 {
-	/* Initialise 'dst' to the subset of 'src' starting at 'offset',
+	/*
+	 * Initialise 'dst' to the subset of 'src' starting at 'offset',
 	 * for exactly 'len' bytes, and return the number of entries.
-	 * NB not destructive to 'src' */
+	 * NB not destructive to 'src'
+	 */
 	unsigned int frag_len;
 	unsigned int niov;
 
@@ -726,8 +733,10 @@ lnet_peer_is_alive(lnet_peer_t *lp, unsigned long now)
 	return alive;
 }
 
-/* NB: returns 1 when alive, 0 when dead, negative when error;
- *     may drop the lnet_net_lock */
+/*
+ * NB: returns 1 when alive, 0 when dead, negative when error;
+ *     may drop the lnet_net_lock
+ */
 static int
 lnet_peer_alive_locked(lnet_peer_t *lp)
 {
@@ -739,8 +748,10 @@ lnet_peer_alive_locked(lnet_peer_t *lp)
 	if (lnet_peer_is_alive(lp, now))
 		return 1;
 
-	/* Peer appears dead, but we should avoid frequent NI queries (at
-	 * most once per lnet_queryinterval seconds). */
+	/*
+	 * Peer appears dead, but we should avoid frequent NI queries (at
+	 * most once per lnet_queryinterval seconds).
+	 */
 	if (lp->lp_last_query != 0) {
 		static const int lnet_queryinterval = 1;
 
@@ -888,9 +899,11 @@ lnet_msg2bufpool(lnet_msg_t *msg)
 static int
 lnet_post_routed_recv_locked(lnet_msg_t *msg, int do_recv)
 {
-	/* lnet_parse is going to lnet_net_unlock immediately after this, so it
+	/*
+	 * lnet_parse is going to lnet_net_unlock immediately after this, so it
 	 * sets do_recv FALSE and I don't do the unlock/send/lock bit.  I
-	 * return EAGAIN if msg blocked and 0 if received or OK to receive */
+	 * return EAGAIN if msg blocked and 0 if received or OK to receive
+	 */
 	lnet_peer_t *lp = msg->msg_rxpeer;
 	lnet_rtrbufpool_t *rbp;
 	lnet_rtrbuf_t *rb;
@@ -1030,9 +1043,11 @@ lnet_return_rx_credits_locked(lnet_msg_t *msg)
 		lnet_rtrbuf_t *rb;
 		lnet_rtrbufpool_t *rbp;
 
-		/* NB If a msg ever blocks for a buffer in rbp_msgs, it stays
+		/*
+		 * NB If a msg ever blocks for a buffer in rbp_msgs, it stays
 		 * there until it gets one allocated, or aborts the wait
-		 * itself */
+		 * itself
+		 */
 		LASSERT(msg->msg_kiov != NULL);
 
 		rb = list_entry(msg->msg_kiov, lnet_rtrbuf_t, rb_kiov[0]);
@@ -1127,9 +1142,10 @@ lnet_find_route_locked(lnet_ni_t *ni, lnet_nid_t target, lnet_nid_t rtr_nid)
 	struct lnet_peer *lp;
 	int rc;
 
-	/* If @rtr_nid is not LNET_NID_ANY, return the gateway with
-	 * rtr_nid nid, otherwise find the best gateway I can use */
-
+	/*
+	 * If @rtr_nid is not LNET_NID_ANY, return the gateway with
+	 * rtr_nid nid, otherwise find the best gateway I can use
+	 */
 	rnet = lnet_find_net_locked(LNET_NIDNET(target));
 	if (rnet == NULL)
 		return NULL;
@@ -1168,9 +1184,11 @@ lnet_find_route_locked(lnet_ni_t *ni, lnet_nid_t target, lnet_nid_t rtr_nid)
 		lp_best = lp;
 	}
 
-	/* set sequence number on the best router to the latest sequence + 1
+	/*
+	 * set sequence number on the best router to the latest sequence + 1
 	 * so we can round-robin all routers, it's race and inaccurate but
-	 * harmless and functional  */
+	 * harmless and functional
+	 */
 	if (rtr_best != NULL)
 		rtr_best->lr_seq = rtr_last->lr_seq + 1;
 	return lp_best;
@@ -1187,9 +1205,11 @@ lnet_send(lnet_nid_t src_nid, lnet_msg_t *msg, lnet_nid_t rtr_nid)
 	int cpt2;
 	int rc;
 
-	/* NB: rtr_nid is set to LNET_NID_ANY for all current use-cases,
+	/*
+	 * NB: rtr_nid is set to LNET_NID_ANY for all current use-cases,
 	 * but we might want to use pre-determined router for ACK/REPLY
-	 * in the future */
+	 * in the future
+	 */
 	/* NB: ni != NULL == interface pre-determined (ACK/REPLY) */
 	LASSERT(msg->msg_txpeer == NULL);
 	LASSERT(!msg->msg_sending);
@@ -1283,10 +1303,12 @@ lnet_send(lnet_nid_t src_nid, lnet_msg_t *msg, lnet_nid_t rtr_nid)
 			return -EHOSTUNREACH;
 		}
 
-		/* rtr_nid is LNET_NID_ANY or NID of pre-determined router,
+		/*
+		 * rtr_nid is LNET_NID_ANY or NID of pre-determined router,
 		 * it's possible that rtr_nid isn't LNET_NID_ANY and lp isn't
 		 * pre-determined router, this can happen if router table
-		 * was changed when we release the lock */
+		 * was changed when we release the lock
+		 */
 		if (rtr_nid != lp->lp_nid) {
 			cpt2 = lnet_cpt_of_nid_locked(lp->lp_nid);
 			if (cpt2 != cpt) {
@@ -1368,8 +1390,10 @@ lnet_recv_put(lnet_ni_t *ni, lnet_msg_t *msg)
 
 	lnet_build_msg_event(msg, LNET_EVENT_PUT);
 
-	/* Must I ACK?  If so I'll grab the ack_wmd out of the header and put
-	 * it back into the ACK during lnet_finalize() */
+	/*
+	 * Must I ACK?  If so I'll grab the ack_wmd out of the header and put
+	 * it back into the ACK during lnet_finalize()
+	 */
 	msg->msg_ack = (!lnet_is_wire_handle_none(&hdr->msg.put.ack_wmd) &&
 			(msg->msg_md->md_options & LNET_MD_ACK_DISABLE) == 0);
 
@@ -1775,10 +1799,11 @@ lnet_parse(lnet_ni_t *ni, lnet_hdr_t *hdr, lnet_nid_t from_nid,
 		lnet_ni_unlock(ni);
 	}
 
-	/* Regard a bad destination NID as a protocol error.  Senders should
+	/*
+	 * Regard a bad destination NID as a protocol error.  Senders should
 	 * know what they're doing; if they don't they're misconfigured, buggy
-	 * or malicious so we chop them off at the knees :) */
-
+	 * or malicious so we chop them off at the knees :)
+	 */
 	if (!for_me) {
 		if (LNET_NIDNET(dest_nid) == LNET_NIDNET(ni->ni_nid)) {
 			/* should have gone direct */
@@ -1790,8 +1815,10 @@ lnet_parse(lnet_ni_t *ni, lnet_hdr_t *hdr, lnet_nid_t from_nid,
 		}
 
 		if (lnet_islocalnid(dest_nid)) {
-			/* dest is another local NI; sender should have used
-			 * this node's NID on its own network */
+			/*
+			 * dest is another local NI; sender should have used
+			 * this node's NID on its own network
+			 */
 			CERROR("%s, src %s: Bad dest nid %s (it's my nid but on a different network)\n",
 			       libcfs_nid2str(from_nid),
 			       libcfs_nid2str(src_nid),
@@ -1816,9 +1843,10 @@ lnet_parse(lnet_ni_t *ni, lnet_hdr_t *hdr, lnet_nid_t from_nid,
 		}
 	}
 
-	/* Message looks OK; we're not going to return an error, so we MUST
-	 * call back lnd_recv() come what may... */
-
+	/*
+	 * Message looks OK; we're not going to return an error, so we MUST
+	 * call back lnd_recv() come what may...
+	 */
 	if (!list_empty(&the_lnet.ln_test_peers) && /* normally we don't */
 	    fail_peer(src_nid, 0)) {	     /* shall we now? */
 		CERROR("%s, src %s: Dropping %s to simulate failure\n",
@@ -1962,10 +1990,11 @@ lnet_drop_delayed_msg_list(struct list_head *head, char *reason)
 		      msg->msg_hdr.msg.put.offset,
 		      msg->msg_hdr.payload_length, reason);
 
-		/* NB I can't drop msg's ref on msg_rxpeer until after I've
+		/*
+		 * NB I can't drop msg's ref on msg_rxpeer until after I've
 		 * called lnet_drop_message(), so I just hang onto msg as well
-		 * until that's done */
-
+		 * until that's done
+		 */
 		lnet_drop_message(msg->msg_rxpeer->lp_ni,
 				  msg->msg_rxpeer->lp_cpt,
 				  msg->msg_private, msg->msg_len);
@@ -1988,9 +2017,10 @@ lnet_recv_delayed_msg_list(struct list_head *head)
 		msg = list_entry(head->next, lnet_msg_t, msg_list);
 		list_del(&msg->msg_list);
 
-		/* md won't disappear under me, since each msg
-		 * holds a ref on it */
-
+		/*
+		 * md won't disappear under me, since each msg
+		 * holds a ref on it
+		 */
 		id.nid = msg->msg_hdr.src_nid;
 		id.pid = msg->msg_hdr.src_pid;
 
@@ -2142,13 +2172,14 @@ EXPORT_SYMBOL(LNetPut);
 lnet_msg_t *
 lnet_create_reply_msg(lnet_ni_t *ni, lnet_msg_t *getmsg)
 {
-	/* The LND can DMA direct to the GET md (i.e. no REPLY msg).  This
+	/*
+	 * The LND can DMA direct to the GET md (i.e. no REPLY msg).  This
 	 * returns a msg for the LND to pass to lnet_finalize() when the sink
 	 * data has been received.
 	 *
 	 * CAVEAT EMPTOR: 'getmsg' is the original GET, which is freed when
-	 * lnet_finalize() is called on it, so the LND must call this first */
-
+	 * lnet_finalize() is called on it, so the LND must call this first
+	 */
 	struct lnet_msg *msg = lnet_msg_alloc();
 	struct lnet_libmd *getmd = getmsg->msg_md;
 	lnet_process_id_t peer_id = getmsg->msg_target;
@@ -2219,14 +2250,18 @@ EXPORT_SYMBOL(lnet_create_reply_msg);
 void
 lnet_set_reply_msg_len(lnet_ni_t *ni, lnet_msg_t *reply, unsigned int len)
 {
-	/* Set the REPLY length, now the RDMA that elides the REPLY message has
-	 * completed and I know it. */
+	/*
+	 * Set the REPLY length, now the RDMA that elides the REPLY message has
+	 * completed and I know it.
+	 */
 	LASSERT(reply != NULL);
 	LASSERT(reply->msg_type == LNET_MSG_GET);
 	LASSERT(reply->msg_ev.type == LNET_EVENT_REPLY);
 
-	/* NB I trusted my peer to RDMA.  If she tells me she's written beyond
-	 * the end of my buffer, I might as well be dead. */
+	/*
+	 * NB I trusted my peer to RDMA.  If she tells me she's written beyond
+	 * the end of my buffer, I might as well be dead.
+	 */
 	LASSERT(len <= reply->msg_ev.mlength);
 
 	reply->msg_ev.mlength = len;
@@ -2358,11 +2393,12 @@ LNetDist(lnet_nid_t dstnid, lnet_nid_t *srcnidp, __u32 *orderp)
 	__u32 order = 2;
 	struct list_head *rn_list;
 
-	/* if !local_nid_dist_zero, I don't return a distance of 0 ever
+	/*
+	 * if !local_nid_dist_zero, I don't return a distance of 0 ever
 	 * (when lustre sees a distance of 0, it substitutes 0 at lo), so I
 	 * keep order 0 free for 0 at lo and order 1 free for a local NID
-	 * match */
-
+	 * match
+	 */
 	LASSERT(the_lnet.ln_init);
 	LASSERT(the_lnet.ln_refcount > 0);
 
diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
index 43977e8..62717ee 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
@@ -203,8 +203,10 @@ lnet_msg_decommit_tx(lnet_msg_t *msg, int status)
 
 	case LNET_EVENT_GET:
 		LASSERT(msg->msg_rx_committed);
-		/* overwritten while sending reply, we should never be
-		 * here for optimized GET */
+		/*
+		 * overwritten while sending reply, we should never be
+		 * here for optimized GET
+		 */
 		LASSERT(msg->msg_type == LNET_MSG_REPLY);
 		msg->msg_type = LNET_MSG_GET; /* fix type */
 		break;
@@ -240,10 +242,12 @@ lnet_msg_decommit_rx(lnet_msg_t *msg, int status)
 		break;
 
 	case LNET_EVENT_GET:
-		/* type is "REPLY" if it's an optimized GET on passive side,
+		/*
+		 * type is "REPLY" if it's an optimized GET on passive side,
 		 * because optimized GET will never be committed for sending,
 		 * so message type wouldn't be changed back to "GET" by
-		 * lnet_msg_decommit_tx(), see details in lnet_parse_get() */
+		 * lnet_msg_decommit_tx(), see details in lnet_parse_get()
+		 */
 		LASSERT(msg->msg_type == LNET_MSG_REPLY ||
 			msg->msg_type == LNET_MSG_GET);
 		counters->send_length += msg->msg_wanted;
@@ -254,8 +258,10 @@ lnet_msg_decommit_rx(lnet_msg_t *msg, int status)
 		break;
 
 	case LNET_EVENT_REPLY:
-		/* type is "GET" if it's an optimized GET on active side,
-		 * see details in lnet_create_reply_msg() */
+		/*
+		 * type is "GET" if it's an optimized GET on active side,
+		 * see details in lnet_create_reply_msg()
+		 */
 		LASSERT(msg->msg_type == LNET_MSG_GET ||
 			msg->msg_type == LNET_MSG_REPLY);
 		break;
@@ -309,10 +315,12 @@ lnet_msg_attach_md(lnet_msg_t *msg, lnet_libmd_t *md,
 		   unsigned int offset, unsigned int mlen)
 {
 	/* NB: @offset and @len are only useful for receiving */
-	/* Here, we attach the MD on lnet_msg and mark it busy and
+	/*
+	 * Here, we attach the MD on lnet_msg and mark it busy and
 	 * decrementing its threshold. Come what may, the lnet_msg "owns"
 	 * the MD until a call to lnet_msg_detach_md or lnet_finalize()
-	 * signals completion. */
+	 * signals completion.
+	 */
 	LASSERT(!msg->msg_routing);
 
 	msg->msg_md = md;
@@ -383,8 +391,10 @@ lnet_complete_msg_locked(lnet_msg_t *msg, int cpt)
 		msg->msg_hdr.msg.ack.match_bits = msg->msg_ev.match_bits;
 		msg->msg_hdr.msg.ack.mlength = cpu_to_le32(msg->msg_ev.mlength);
 
-		/* NB: we probably want to use NID of msg::msg_from as 3rd
-		 * parameter (router NID) if it's routed message */
+		/*
+		 * NB: we probably want to use NID of msg::msg_from as 3rd
+		 * parameter (router NID) if it's routed message
+		 */
 		rc = lnet_send(msg->msg_ev.target.nid, msg, LNET_NID_ANY);
 
 		lnet_net_lock(cpt);
@@ -491,9 +501,10 @@ lnet_finalize(lnet_ni_t *ni, lnet_msg_t *msg, int status)
 	container = the_lnet.ln_msg_containers[cpt];
 	list_add_tail(&msg->msg_list, &container->msc_finalizing);
 
-	/* Recursion breaker.  Don't complete the message here if I am (or
-	 * enough other threads are) already completing messages */
-
+	/*
+	 * Recursion breaker.  Don't complete the message here if I am (or
+	 * enough other threads are) already completing messages
+	 */
 	my_slot = -1;
 	for (i = 0; i < container->msc_nfinalizers; i++) {
 		if (container->msc_finalizers[i] == current)
@@ -516,8 +527,10 @@ lnet_finalize(lnet_ni_t *ni, lnet_msg_t *msg, int status)
 
 		list_del(&msg->msg_list);
 
-		/* NB drops and regains the lnet lock if it actually does
-		 * anything, so my finalizing friends can chomp along too */
+		/*
+		 * NB drops and regains the lnet lock if it actually does
+		 * anything, so my finalizing friends can chomp along too
+		 */
 		rc = lnet_complete_msg_locked(msg, cpt);
 		if (rc != 0)
 			break;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-ptl.c b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
index bd7b071..3a82fb6 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-ptl.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
@@ -139,8 +139,10 @@ static int
 lnet_try_match_md(lnet_libmd_t *md,
 		  struct lnet_match_info *info, struct lnet_msg *msg)
 {
-	/* ALWAYS called holding the lnet_res_lock, and can't lnet_res_unlock;
-	 * lnet_match_blocked_msg() relies on this to avoid races */
+	/*
+	 * ALWAYS called holding the lnet_res_lock, and can't lnet_res_unlock;
+	 * lnet_match_blocked_msg() relies on this to avoid races
+	 */
 	unsigned int offset;
 	unsigned int mlength;
 	lnet_me_t *me = md->md_me;
@@ -203,9 +205,11 @@ lnet_try_match_md(lnet_libmd_t *md,
 	if (!lnet_md_exhausted(md))
 		return LNET_MATCHMD_OK;
 
-	/* Auto-unlink NOW, so the ME gets unlinked if required.
+	/*
+	 * Auto-unlink NOW, so the ME gets unlinked if required.
 	 * We bumped md->md_refcount above so the MD just gets flagged
-	 * for unlink when it is finalized. */
+	 * for unlink when it is finalized.
+	 */
 	if ((md->md_flags & LNET_MD_FLAG_AUTO_UNLINK) != 0)
 		lnet_md_unlink(md);
 
@@ -248,8 +252,10 @@ lnet_mt_of_attach(unsigned int index, lnet_process_id_t id,
 		return NULL;
 	case LNET_INS_BEFORE:
 	case LNET_INS_AFTER:
-		/* posted by no affinity thread, always hash to specific
-		 * match-table to avoid buffer stealing which is heavy */
+		/*
+		 * posted by no affinity thread, always hash to specific
+		 * match-table to avoid buffer stealing which is heavy
+		 */
 		return ptl->ptl_mtables[ptl->ptl_index % LNET_CPT_NUMBER];
 	case LNET_INS_LOCAL:
 		/* posted by cpu-affinity thread */
@@ -299,9 +305,11 @@ lnet_mt_of_match(struct lnet_match_info *info, struct lnet_msg *msg)
 		nmaps = ptl->ptl_mt_nmaps;
 		/* map to an active mtable to avoid heavy "stealing" */
 		if (nmaps != 0) {
-			/* NB: there is possibility that ptl_mt_maps is being
+			/*
+			 * NB: there is possibility that ptl_mt_maps is being
 			 * changed because we are not under protection of
-			 * lnet_ptl_lock, but it shouldn't hurt anything */
+			 * lnet_ptl_lock, but it shouldn't hurt anything
+			 */
 			cpt = ptl->ptl_mt_maps[rotor % nmaps];
 		}
 	}
@@ -401,8 +409,10 @@ lnet_mt_match_md(struct lnet_match_table *mtable,
 			exhausted = 0; /* mlist is not empty */
 
 		if ((rc & LNET_MATCHMD_FINISH) != 0) {
-			/* don't return EXHAUSTED bit because we don't know
-			 * whether the mlist is empty or not */
+			/*
+			 * don't return EXHAUSTED bit because we don't know
+			 * whether the mlist is empty or not
+			 */
 			return rc & ~LNET_MATCHMD_EXHAUSTED;
 		}
 	}
@@ -430,8 +440,10 @@ lnet_ptl_match_early(struct lnet_portal *ptl, struct lnet_msg *msg)
 {
 	int rc;
 
-	/* message arrived before any buffer posting on this portal,
-	 * simply delay or drop this message */
+	/*
+	 * message arrived before any buffer posting on this portal,
+	 * simply delay or drop this message
+	 */
 	if (likely(lnet_ptl_is_wildcard(ptl) || lnet_ptl_is_unique(ptl)))
 		return 0;
 
@@ -465,9 +477,11 @@ lnet_ptl_match_delay(struct lnet_portal *ptl,
 	int rc = 0;
 	int i;
 
-	/* steal buffer from other CPTs, and delay it if nothing to steal,
+	/*
+	 * steal buffer from other CPTs, and delay it if nothing to steal,
 	 * this function is more expensive than a regular match, but we
-	 * don't expect it can happen a lot */
+	 * don't expect it can happen a lot
+	 */
 	LASSERT(lnet_ptl_is_wildcard(ptl));
 
 	for (i = 0; i < LNET_CPT_NUMBER; i++) {
@@ -498,8 +512,10 @@ lnet_ptl_match_delay(struct lnet_portal *ptl,
 				list_del_init(&msg->msg_list);
 
 		} else {
-			/* could be matched by lnet_ptl_attach_md()
-			 * which is called by another thread */
+			/*
+			 * could be matched by lnet_ptl_attach_md()
+			 * which is called by another thread
+			 */
 			rc = msg->msg_md == NULL ?
 			     LNET_MATCHMD_DROP : LNET_MATCHMD_OK;
 		}
diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
index 589ecc8..c383595 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -258,9 +258,10 @@ lnet_sock_write(struct socket *sock, void *buffer, int nob, int timeout)
 	struct timeval tv;
 
 	LASSERT(nob > 0);
-	/* Caller may pass a zero timeout if she thinks the socket buffer is
-	 * empty enough to take the whole message immediately */
-
+	/*
+	 * Caller may pass a zero timeout if she thinks the socket buffer is
+	 * empty enough to take the whole message immediately
+	 */
 	for (;;) {
 		struct kvec  iov = {
 			.iov_base = buffer,
@@ -524,8 +525,10 @@ lnet_sock_accept(struct socket **newsockp, struct socket *sock)
 
 	init_waitqueue_entry(&wait, current);
 
-	/* XXX this should add a ref to sock->ops->owner, if
-	 * TCP could be a module */
+	/*
+	 * XXX this should add a ref to sock->ops->owner, if
+	 * TCP could be a module
+	 */
 	rc = sock_create_lite(PF_PACKET, sock->type, IPPROTO_TCP, &newsock);
 	if (rc) {
 		CERROR("Can't allocate socket\n");
@@ -578,10 +581,12 @@ lnet_sock_connect(struct socket **sockp, int *fatal, __u32 local_ip,
 	if (rc == 0)
 		return 0;
 
-	/* EADDRNOTAVAIL probably means we're already connected to the same
+	/*
+	 * EADDRNOTAVAIL probably means we're already connected to the same
 	 * peer/port on the same local port on a differently typed
 	 * connection.  Let our caller retry with a different local
-	 * port... */
+	 * port...
+	 */
 	*fatal = !(rc == -EADDRNOTAVAIL);
 
 	CDEBUG_LIMIT(*fatal ? D_NETERROR : D_NET,
diff --git a/drivers/staging/lustre/lnet/lnet/module.c b/drivers/staging/lustre/lnet/lnet/module.c
index c93c007..1e88033 100644
--- a/drivers/staging/lustre/lnet/lnet/module.c
+++ b/drivers/staging/lustre/lnet/lnet/module.c
@@ -96,9 +96,11 @@ lnet_ioctl(unsigned int cmd, struct libcfs_ioctl_data *data)
 		return lnet_unconfigure();
 
 	default:
-		/* Passing LNET_PID_ANY only gives me a ref if the net is up
+		/*
+		 * Passing LNET_PID_ANY only gives me a ref if the net is up
 		 * already; I'll need it to ensure the net can't go down while
-		 * I'm called into it */
+		 * I'm called into it
+		 */
 		rc = LNetNIInit(LNET_PID_ANY);
 		if (rc >= 0) {
 			rc = LNetCtl(cmd, data);
@@ -127,8 +129,10 @@ init_lnet(void)
 	LASSERT(rc == 0);
 
 	if (config_on_load) {
-		/* Have to schedule a separate thread to avoid deadlocking
-		 * in modload */
+		/*
+		 * Have to schedule a separate thread to avoid deadlocking
+		 * in modload
+		 */
 		(void) kthread_run(lnet_configure, NULL, "lnet_initd");
 	}
 
diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
index 80f585a..36577fe 100644
--- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
+++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
@@ -210,9 +210,11 @@ add_nidrange(const struct cfs_lstr *src,
 		/* network name only, e.g. "elan" or "tcp" */
 		netnum = 0;
 	else {
-		/* e.g. "elan25" or "tcp23", refuse to parse if
+		/*
+		 * e.g. "elan25" or "tcp23", refuse to parse if
 		 * network name is not appended with decimal or
-		 * hexadecimal number */
+		 * hexadecimal number
+		 */
 		if (!cfs_str2num_check(src->ls_str + strlen(nf->nf_name),
 				       endlen, &netnum, 0, MAX_NUMERIC_VALUE))
 			return NULL;
@@ -784,12 +786,14 @@ libcfs_ip_addr2str(__u32 addr, char *str, size_t size)
 		 (addr >> 8) & 0xff, addr & 0xff);
 }
 
-/* CAVEAT EMPTOR XscanfX
+/*
+ * CAVEAT EMPTOR XscanfX
  * I use "%n" at the end of a sscanf format to detect trailing junk.  However
  * sscanf may return immediately if it sees the terminating '0' in a string, so
  * I initialise the %n variable to the expected length.  If sscanf sets it;
  * fine, if it doesn't, then the scan ended at the end of the string, which is
- * fine too :) */
+ * fine too :)
+ */
 static int
 libcfs_ip_str2addr(const char *str, int nob, __u32 *addr)
 {
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index f5faa41..b6b2ed8 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -61,8 +61,10 @@ lnet_peer_buffer_credits(lnet_ni_t *ni)
 	if (peer_buffer_credits > 0)
 		return peer_buffer_credits;
 
-	/* As an approximation, allow this peer the same number of router
-	 * buffers as it is allowed outstanding sends */
+	/*
+	 * As an approximation, allow this peer the same number of router
+	 * buffers as it is allowed outstanding sends
+	 */
 	return ni->ni_peertxcredits;
 }
 
@@ -131,10 +133,11 @@ lnet_ni_notify_locked(lnet_ni_t *ni, lnet_peer_t *lp)
 	int alive;
 	int notifylnd;
 
-	/* Notify only in 1 thread at any time to ensure ordered notification.
+	/*
+	 * Notify only in 1 thread at any time to ensure ordered notification.
 	 * NB individual events can be missed; the only guarantee is that you
-	 * always get the most recent news */
-
+	 * always get the most recent news
+	 */
 	if (lp->lp_notifying || ni == NULL)
 		return;
 
@@ -150,9 +153,10 @@ lnet_ni_notify_locked(lnet_ni_t *ni, lnet_peer_t *lp)
 		if (notifylnd && ni->ni_lnd->lnd_notify != NULL) {
 			lnet_net_unlock(lp->lp_cpt);
 
-			/* A new notification could happen now; I'll handle it
-			 * when control returns to me */
-
+			/*
+			 * A new notification could happen now; I'll handle it
+			 * when control returns to me
+			 */
 			(ni->ni_lnd->lnd_notify)(ni, lp->lp_nid, alive);
 
 			lnet_net_lock(lp->lp_cpt);
@@ -245,8 +249,10 @@ static void lnet_shuffle_seed(void)
 
 	cfs_get_random_bytes(seed, sizeof(seed));
 
-	/* Nodes with small feet have little entropy
-	 * the NID for this node gives the most entropy in the low bits */
+	/*
+	 * Nodes with small feet have little entropy
+	 * the NID for this node gives the most entropy in the low bits
+	 */
 	list_for_each(tmp, &the_lnet.ln_nis) {
 		ni = list_entry(tmp, lnet_ni_t, ni_list);
 		lnd_type = LNET_NETTYP(LNET_NIDNET(ni->ni_nid));
@@ -472,9 +478,10 @@ lnet_del_route(__u32 net, lnet_nid_t gw_nid)
 	CDEBUG(D_NET, "Del route: net %s : gw %s\n",
 	       libcfs_net2str(net), libcfs_nid2str(gw_nid));
 
-	/* NB Caller may specify either all routes via the given gateway
-	 * or a specific route entry actual NIDs) */
-
+	/*
+	 * NB Caller may specify either all routes via the given gateway
+	 * or a specific route entry actual NIDs)
+	 */
 	lnet_net_lock(LNET_LOCK_EX);
 	if (net == LNET_NIDNET(LNET_NID_ANY))
 		rn_list = &the_lnet.ln_remote_nets_hash[0];
@@ -663,8 +670,10 @@ lnet_parse_rc_info(lnet_rc_data_t *rcd)
 					up = 1;
 					break;
 				}
-				/* ptl NIs are considered down only when
-				 * they're all down */
+				/*
+				 * ptl NIs are considered down only when
+				 * they're all down
+				 */
 				if (LNET_NETTYP(LNET_NIDNET(nid)) == PTLLND)
 					ptl_status = LNET_NI_STATUS_UP;
 				continue;
@@ -703,9 +712,11 @@ lnet_router_checker_event(lnet_event_t *event)
 	lp = rcd->rcd_gateway;
 	LASSERT(lp != NULL);
 
-	 /* NB: it's called with holding lnet_res_lock, we have a few
-	  * places need to hold both locks at the same time, please take
-	  * care of lock ordering */
+	/*
+	 * NB: it's called with holding lnet_res_lock, we have a few
+	 * places need to hold both locks at the same time, please take
+	 * care of lock ordering
+	 */
 	lnet_net_lock(lp->lp_cpt);
 	if (!lnet_isrouter(lp) || lp->lp_rcd != rcd) {
 		/* ignore if no longer a router or rcd is replaced */
@@ -719,17 +730,20 @@ lnet_router_checker_event(lnet_event_t *event)
 	}
 
 	/* LNET_EVENT_REPLY */
-	/* A successful REPLY means the router is up.  If _any_ comms
+	/*
+	 * A successful REPLY means the router is up.  If _any_ comms
 	 * to the router fail I assume it's down (this will happen if
 	 * we ping alive routers to try to detect router death before
-	 * apps get burned). */
-
+	 * apps get burned).
+	 */
 	lnet_notify_locked(lp, 1, (event->status == 0), cfs_time_current());
-	/* The router checker will wake up very shortly and do the
+
+	/*
+	 * The router checker will wake up very shortly and do the
 	 * actual notification.
 	 * XXX If 'lp' stops being a router before then, it will still
-	 * have the notification pending!!! */
-
+	 * have the notification pending!!!
+	 */
 	if (avoid_asym_router_failure && event->status == 0)
 		lnet_parse_rc_info(rcd);
 
@@ -816,8 +830,10 @@ lnet_update_ni_status_locked(void)
 		if (ni->ni_status->ns_status != LNET_NI_STATUS_DOWN) {
 			CDEBUG(D_NET, "NI(%s:%d) status changed to down\n",
 			       libcfs_nid2str(ni->ni_nid), timeout);
-			/* NB: so far, this is the only place to set
-			 * NI status to "down" */
+			/*
+			 * NB: so far, this is the only place to set
+			 * NI status to "down"
+			 */
 			ni->ni_status->ns_status = LNET_NI_STATUS_DOWN;
 		}
 		lnet_ni_unlock(ni);
@@ -1018,8 +1034,10 @@ lnet_router_checker_start(void)
 		return 0;
 
 	sema_init(&the_lnet.ln_rc_signal, 0);
-	/* EQ size doesn't matter; the callback is guaranteed to get every
-	 * event */
+	/*
+	 * EQ size doesn't matter; the callback is guaranteed to get every
+	 * event
+	 */
 	eqsz = 0;
 	rc = LNetEQAlloc(eqsz, lnet_router_checker_event,
 			 &the_lnet.ln_rc_eqh);
@@ -1042,9 +1060,11 @@ lnet_router_checker_start(void)
 	}
 
 	if (check_routers_before_use) {
-		/* Note that a helpful side-effect of pinging all known routers
+		/*
+		 * Note that a helpful side-effect of pinging all known routers
 		 * at startup is that it makes them drop stale connections they
-		 * may have to a previous instance of me. */
+		 * may have to a previous instance of me.
+		 */
 		lnet_wait_known_routerstate();
 	}
 
@@ -1199,9 +1219,11 @@ rescan:
 
 		lnet_prune_rc_data(0); /* don't wait for UNLINK */
 
-		/* Call schedule_timeout() here always adds 1 to load average
+		/*
+		 * Call schedule_timeout() here always adds 1 to load average
 		 * because kernel counts # active tasks as nr_running
-		 * + nr_uninterruptible. */
+		 * + nr_uninterruptible.
+		 */
 		set_current_state(TASK_INTERRUPTIBLE);
 		schedule_timeout(cfs_time_seconds(1));
 	}
@@ -1541,10 +1563,12 @@ lnet_notify(lnet_ni_t *ni, lnet_nid_t nid, int alive, unsigned long when)
 		return 0;
 	}
 
-	/* We can't fully trust LND on reporting exact peer last_alive
+	/*
+	 * We can't fully trust LND on reporting exact peer last_alive
 	 * if he notifies us about dead peer. For example ksocklnd can
 	 * call us with when == _time_when_the_node_was_booted_ if
-	 * no connections were successfully established */
+	 * no connections were successfully established
+	 */
 	if (ni != NULL && !alive && when < lp->lp_last_alive)
 		when = lp->lp_last_alive;
 
diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
index 396c7c4..339c276 100644
--- a/drivers/staging/lustre/lnet/lnet/router_proc.c
+++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
@@ -25,8 +25,10 @@
 #include "../../include/linux/libcfs/libcfs.h"
 #include "../../include/linux/lnet/lib-lnet.h"
 
-/* This is really lnet_proc.c. You might need to update sanity test 215
- * if any file format is changed. */
+/*
+ * This is really lnet_proc.c. You might need to update sanity test 215
+ * if any file format is changed.
+ */
 
 #define LNET_LOFFT_BITS		(sizeof(loff_t) * 8)
 /*
@@ -358,9 +360,11 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
 			if ((peer->lp_ping_feats &
 			     LNET_PING_FEAT_NI_STATUS) != 0) {
 				list_for_each_entry(rtr, &peer->lp_routes,
-							lr_gwlist) {
-					/* downis on any route should be the
-					 * number of downis on the gateway */
+						    lr_gwlist) {
+					/*
+					 * downis on any route should be the
+					 * number of downis on the gateway
+					 */
 					if (rtr->lr_downis != 0) {
 						down_ni = rtr->lr_downis;
 						break;
@@ -479,9 +483,11 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
 				if (skip == 0) {
 					peer = lp;
 
-					/* minor optimization: start from idx+1
+					/*
+					 * minor optimization: start from idx+1
 					 * on next iteration if we've just
-					 * drained lp_hashlist */
+					 * drained lp_hashlist
+					 */
 					if (lp->lp_hashlist.next ==
 					    &ptable->pt_hash[hash]) {
 						hoff = 1;
@@ -710,8 +716,10 @@ static int proc_lnet_nis(struct ctl_table *table, int write,
 				LNET_NI_STATUS_UP) ? "up" : "down";
 			lnet_ni_unlock(ni);
 
-			/* we actually output credits information for
-			 * TX queue of each partition */
+			/*
+			 * we actually output credits information for
+			 * TX queue of each partition
+			 */
 			cfs_percpt_for_each(tq, i, ni->ni_tx_queues) {
 				for (j = 0; ni->ni_cpts != NULL &&
 				     j < ni->ni_ncpts; j++) {
diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
index 1f04cc1..8b159b6 100644
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -86,15 +86,19 @@ brw_client_init(sfw_test_instance_t *tsi)
 		opc   = breq->blk_opc;
 		flags = breq->blk_flags;
 		npg   = breq->blk_npg;
-		/* NB: this is not going to work for variable page size,
-		 * but we have to keep it for compatibility */
+		/*
+		 * NB: this is not going to work for variable page size,
+		 * but we have to keep it for compatibility
+		 */
 		len   = npg * PAGE_CACHE_SIZE;
 
 	} else {
 		test_bulk_req_v1_t *breq = &tsi->tsi_u.bulk_v1;
 
-		/* I should never get this step if it's unknown feature
-		 * because make_session will reject unknown feature */
+		/*
+		 * I should never get this step if it's unknown feature
+		 * because make_session will reject unknown feature
+		 */
 		LASSERT((sn->sn_features & ~LST_FEATS_MASK) == 0);
 
 		opc   = breq->blk_opc;
@@ -279,8 +283,10 @@ brw_client_prep_rpc(sfw_test_unit_t *tsu,
 	} else {
 		test_bulk_req_v1_t *breq = &tsi->tsi_u.bulk_v1;
 
-		/* I should never get this step if it's unknown feature
-		 * because make_session will reject unknown feature */
+		/*
+		 * I should never get this step if it's unknown feature
+		 * because make_session will reject unknown feature
+		 */
 		LASSERT((sn->sn_features & ~LST_FEATS_MASK) == 0);
 
 		opc   = breq->blk_opc;
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index 15a61de..4f09b51 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -60,8 +60,10 @@ lstcon_rpc_done(srpc_client_rpc_t *rpc)
 	spin_lock(&rpc->crpc_lock);
 
 	if (crpc->crp_trans == NULL) {
-		/* Orphan RPC is not in any transaction,
-		 * I'm just a poor body and nobody loves me */
+		/*
+		 * Orphan RPC is not in any transaction,
+		 * I'm just a poor body and nobody loves me
+		 */
 		spin_unlock(&rpc->crpc_lock);
 
 		/* release it */
@@ -241,8 +243,10 @@ lstcon_rpc_trans_prep(struct list_head *translist,
 
 	if (translist != NULL) {
 		list_for_each_entry(trans, translist, tas_link) {
-			/* Can't enqueue two private transaction on
-			 * the same object */
+			/*
+			 * Can't enqueue two private transaction on
+			 * the same object
+			 */
 			if ((trans->tas_opc & transop) == LST_TRANS_PRIVATE)
 				return -EPERM;
 		}
@@ -563,11 +567,12 @@ lstcon_rpc_trans_destroy(lstcon_rpc_trans_t *trans)
 			continue;
 		}
 
-		/* rpcs can be still not callbacked (even LNetMDUnlink is called)
+		/*
+		 * rpcs can be still not callbacked (even LNetMDUnlink is called)
 		 * because huge timeout for inaccessible network, don't make
 		 * user wait for them, just abandon them, they will be recycled
-		 * in callback */
-
+		 * in callback
+		 */
 		LASSERT(crpc->crp_status != 0);
 
 		crpc->crp_node  = NULL;
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 366211e..1cc7038 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -104,9 +104,11 @@ lstcon_node_find(lnet_process_id_t id, lstcon_node_t **ndpp, int create)
 	ndl->ndl_node->nd_timeout = 0;
 	memset(&ndl->ndl_node->nd_ping, 0, sizeof(lstcon_rpc_t));
 
-	/* queued in global hash & list, no refcount is taken by
+	/*
+	 * queued in global hash & list, no refcount is taken by
 	 * global hash & list, if caller release his refcount,
-	 * node will be released */
+	 * node will be released
+	 */
 	list_add_tail(&ndl->ndl_hlink, &console_session.ses_ndl_hash[idx]);
 	list_add_tail(&ndl->ndl_link, &console_session.ses_ndl_list);
 
@@ -601,8 +603,10 @@ lstcon_group_del(char *name)
 	lstcon_rpc_trans_destroy(trans);
 
 	lstcon_group_decref(grp);
-	/* -ref for session, it's destroyed,
-	 * status can't be rolled back, destroy group anyway */
+	/*
+	 * -ref for session, it's destroyed,
+	 * status can't be rolled back, destroy group anyway
+	 */
 	lstcon_group_decref(grp);
 
 	return rc;
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 1a2da74..1bf707b 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -386,8 +386,10 @@ sfw_get_stats(srpc_stat_reqst_t *request, srpc_stat_reply_t *reply)
 	lnet_counters_get(&reply->str_lnet);
 	srpc_get_counters(&reply->str_rpc);
 
-	/* send over the msecs since the session was started
-	 - with 32 bits to send, this is ~49 days */
+	/*
+	 * send over the msecs since the session was started
+	 * with 32 bits to send, this is ~49 days
+	 */
 	cnt->running_ms	     = jiffies_to_msecs(jiffies - sn->sn_started);
 	cnt->brw_errors      = atomic_read(&sn->sn_brw_errors);
 	cnt->ping_errors     = atomic_read(&sn->sn_ping_errors);
@@ -437,12 +439,14 @@ sfw_make_session(srpc_mksn_reqst_t *request, srpc_mksn_reply_t *reply)
 		}
 	}
 
-	/* reject the request if it requires unknown features
+	/*
+	 * reject the request if it requires unknown features
 	 * NB: old version will always accept all features because it's not
 	 * aware of srpc_msg_t::msg_ses_feats, it's a defect but it's also
 	 * harmless because it will return zero feature to console, and it's
 	 * console's responsibility to make sure all nodes in a session have
-	 * same feature mask. */
+	 * same feature mask.
+	 */
 	if ((msg->msg_ses_feats & ~LST_FEATS_MASK) != 0) {
 		reply->mksn_status = EPROTO;
 		return 0;
@@ -570,10 +574,12 @@ sfw_load_test(struct sfw_test_instance *tsi)
 	if (rc != 0) {
 		CWARN("Failed to reserve enough buffers: service %s, %d needed: %d\n",
 		      svc->sv_name, nbuf, rc);
-		/* NB: this error handler is not strictly correct, because
+		/*
+		 * NB: this error handler is not strictly correct, because
 		 * it may release more buffers than already allocated,
 		 * but it doesn't matter because request portal should
-		 * be lazy portal and will grow buffers if necessary. */
+		 * be lazy portal and will grow buffers if necessary.
+		 */
 		srpc_service_remove_buffers(svc, nbuf);
 		return -ENOMEM;
 	}
@@ -594,9 +600,11 @@ sfw_unload_test(struct sfw_test_instance *tsi)
 	if (tsi->tsi_is_client)
 		return;
 
-	/* shrink buffers, because request portal is lazy portal
+	/*
+	 * shrink buffers, because request portal is lazy portal
 	 * which can grow buffers at runtime so we may leave
-	 * some buffers behind, but never mind... */
+	 * some buffers behind, but never mind...
+	 */
 	srpc_service_remove_buffers(tsc->tsc_srv_service,
 				    sfw_test_buffers(tsi));
 	return;
@@ -1272,9 +1280,11 @@ sfw_handle_server_rpc(struct srpc_server_rpc *rpc)
 		}
 
 	} else if ((request->msg_ses_feats & ~LST_FEATS_MASK) != 0) {
-		/* NB: at this point, old version will ignore features and
+		/*
+		 * NB: at this point, old version will ignore features and
 		 * create new session anyway, so console should be able
-		 * to handle this */
+		 * to handle this
+		 */
 		reply->msg_body.reply.status = EPROTO;
 		goto out;
 	}
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index 2acf6ec..14f2024 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -278,16 +278,20 @@ srpc_service_init(struct srpc_service *svc)
 		scd->scd_ev.ev_data = scd;
 		scd->scd_ev.ev_type = SRPC_REQUEST_RCVD;
 
-		/* NB: don't use lst_sched_serial for adding buffer,
-		 * see details in srpc_service_add_buffers() */
+		/*
+		 * NB: don't use lst_sched_serial for adding buffer,
+		 * see details in srpc_service_add_buffers()
+		 */
 		swi_init_workitem(&scd->scd_buf_wi, scd,
 				  srpc_add_buffer, lst_sched_test[i]);
 
 		if (i != 0 && srpc_serv_is_framework(svc)) {
-			/* NB: framework service only needs srpc_service_cd for
+			/*
+			 * NB: framework service only needs srpc_service_cd for
 			 * one partition, but we allocate for all to make
 			 * it easier to implement, it will waste a little
-			 * memory but nobody should care about this */
+			 * memory but nobody should care about this
+			 */
 			continue;
 		}
 
@@ -414,9 +418,11 @@ srpc_post_active_rdma(int portal, __u64 matchbits, void *buf, int len,
 		return -ENOMEM;
 	}
 
-	/* this is kind of an abuse of the LNET_MD_OP_{PUT,GET} options.
+	/*
+	 * this is kind of an abuse of the LNET_MD_OP_{PUT,GET} options.
 	 * they're only meaningful for MDs attached to an ME (i.e. passive
-	 * buffers... */
+	 * buffers...
+	 */
 	if ((options & LNET_MD_OP_PUT) != 0) {
 		rc = LNetPut(self, *mdh, LNET_NOACK_REQ, peer,
 			     portal, matchbits, 0, 0);
@@ -431,7 +437,8 @@ srpc_post_active_rdma(int portal, __u64 matchbits, void *buf, int len,
 			((options & LNET_MD_OP_PUT) != 0) ? "Put" : "Get",
 			libcfs_id2str(peer), portal, matchbits, rc);
 
-		/* The forthcoming unlink event will complete this operation
+		/*
+		 * The forthcoming unlink event will complete this operation
 		 * with failure, so fall through and return success here.
 		 */
 		rc = LNetMDUnlink(*mdh);
@@ -476,10 +483,11 @@ srpc_service_post_buffer(struct srpc_service_cd *scd, struct srpc_buffer *buf)
 				      msg, sizeof(*msg), &buf->buf_mdh,
 				      &scd->scd_ev);
 
-	/* At this point, a RPC (new or delayed) may have arrived in
+	/*
+	 * At this point, a RPC (new or delayed) may have arrived in
 	 * msg and its event handler has been called. So we must add
-	 * buf to scd_buf_posted _before_ dropping scd_lock */
-
+	 * buf to scd_buf_posted _before_ dropping scd_lock
+	 */
 	spin_lock(&scd->scd_lock);
 
 	if (rc == 0) {
@@ -487,8 +495,10 @@ srpc_service_post_buffer(struct srpc_service_cd *scd, struct srpc_buffer *buf)
 			return 0;
 
 		spin_unlock(&scd->scd_lock);
-		/* srpc_shutdown_service might have tried to unlink me
-		 * when my buf_mdh was still invalid */
+		/*
+		 * srpc_shutdown_service might have tried to unlink me
+		 * when my buf_mdh was still invalid
+		 */
 		LNetMDUnlink(buf->buf_mdh);
 		spin_lock(&scd->scd_lock);
 		return 0;
@@ -514,9 +524,11 @@ srpc_add_buffer(struct swi_workitem *wi)
 	struct srpc_buffer *buf;
 	int rc = 0;
 
-	/* it's called by workitem scheduler threads, these threads
+	/*
+	 * it's called by workitem scheduler threads, these threads
 	 * should have been set CPT affinity, so buffers will be posted
-	 * on CPT local list of Portal */
+	 * on CPT local list of Portal
+	 */
 	spin_lock(&scd->scd_lock);
 
 	while (scd->scd_buf_adjust > 0 &&
@@ -732,9 +744,11 @@ srpc_abort_service(struct srpc_service *sv)
 	cfs_percpt_for_each(scd, i, sv->sv_cpt_data) {
 		spin_lock(&scd->scd_lock);
 
-		/* schedule in-flight RPCs to notice the abort, NB:
+		/*
+		 * schedule in-flight RPCs to notice the abort, NB:
 		 * racing with incoming RPCs; complete fix should make test
-		 * RPCs carry session ID in its headers */
+		 * RPCs carry session ID in its headers
+		 */
 		list_for_each_entry(rpc, &scd->scd_rpc_active, srpc_list) {
 			rpc->srpc_aborted = 1;
 			swi_schedule_workitem(&rpc->srpc_wi);
@@ -772,8 +786,10 @@ srpc_shutdown_service(srpc_service_t *sv)
 
 		spin_unlock(&scd->scd_lock);
 
-		/* OK to traverse scd_buf_posted without lock, since no one
-		 * touches scd_buf_posted now */
+		/*
+		 * OK to traverse scd_buf_posted without lock, since no one
+		 * touches scd_buf_posted now
+		 */
 		list_for_each_entry(buf, &scd->scd_buf_posted, buf_list)
 			LNetMDUnlink(buf->buf_mdh);
 	}
@@ -915,8 +931,10 @@ srpc_server_rpc_done(struct srpc_server_rpc *rpc, int status)
 	spin_lock(&scd->scd_lock);
 
 	if (rpc->srpc_reqstbuf != NULL) {
-		/* NB might drop sv_lock in srpc_service_recycle_buffer, but
-		 * sv won't go away for scd_rpc_active must not be empty */
+		/*
+		 * NB might drop sv_lock in srpc_service_recycle_buffer, but
+		 * sv won't go away for scd_rpc_active must not be empty
+		 */
 		srpc_service_recycle_buffer(scd, rpc->srpc_reqstbuf);
 		rpc->srpc_reqstbuf = NULL;
 	}
@@ -1102,7 +1120,8 @@ srpc_add_client_rpc_timer(srpc_client_rpc_t *rpc)
  * Called with rpc->crpc_lock held.
  *
  * Upon exit the RPC expiry timer is not queued and the handler is not
- * running on any CPU. */
+ * running on any CPU.
+ */
 static void
 srpc_del_client_rpc_timer(srpc_client_rpc_t *rpc)
 {
@@ -1210,9 +1229,11 @@ srpc_send_rpc(swi_workitem_t *wi)
 		break;
 
 	case SWI_STATE_REQUEST_SUBMITTED:
-		/* CAVEAT EMPTOR: rqtev, rpyev, and bulkev may come in any
+		/*
+		 * CAVEAT EMPTOR: rqtev, rpyev, and bulkev may come in any
 		 * order; however, they're processed in a strict order:
-		 * rqt, rpy, and bulk. */
+		 * rqt, rpy, and bulk.
+		 */
 		if (!rpc->crpc_reqstev.ev_fired)
 			break;
 
@@ -1259,10 +1280,12 @@ srpc_send_rpc(swi_workitem_t *wi)
 
 		rc = do_bulk ? rpc->crpc_bulkev.ev_status : 0;
 
-		/* Bulk buffer was unlinked due to remote error. Clear error
+		/*
+		 * Bulk buffer was unlinked due to remote error. Clear error
 		 * since reply buffer still contains valid data.
 		 * NB rpc->crpc_done shouldn't look into bulk data in case of
-		 * remote error. */
+		 * remote error.
+		 */
 		if (do_bulk && rpc->crpc_bulkev.ev_lnet == LNET_EVENT_UNLINK &&
 		    rpc->crpc_status == 0 && reply->msg_body.reply.status != 0)
 			rc = 0;
@@ -1364,8 +1387,10 @@ srpc_send_reply(struct srpc_server_rpc *rpc)
 	spin_lock(&scd->scd_lock);
 
 	if (!sv->sv_shuttingdown && !srpc_serv_is_framework(sv)) {
-		/* Repost buffer before replying since test client
-		 * might send me another RPC once it gets the reply */
+		/*
+		 * Repost buffer before replying since test client
+		 * might send me another RPC once it gets the reply
+		 */
 		if (srpc_service_post_buffer(scd, buffer) != 0)
 			CWARN("Failed to repost %s buffer\n", sv->sv_name);
 		rpc->srpc_reqstbuf = NULL;
@@ -1472,8 +1497,10 @@ srpc_lnet_ev_handler(lnet_event_t *ev)
 		scd->scd_buf_nposted--;
 
 		if (sv->sv_shuttingdown) {
-			/* Leave buffer on scd->scd_buf_nposted since
-			 * srpc_finish_service needs to traverse it. */
+			/*
+			 * Leave buffer on scd->scd_buf_nposted since
+			 * srpc_finish_service needs to traverse it.
+			 */
 			spin_unlock(&scd->scd_lock);
 			break;
 		}
@@ -1507,9 +1534,11 @@ srpc_lnet_ev_handler(lnet_event_t *ev)
 			       ev->status, ev->mlength,
 			       msg->msg_type, msg->msg_magic);
 
-			/* NB can't call srpc_service_recycle_buffer here since
+			/*
+			 * NB can't call srpc_service_recycle_buffer here since
 			 * it may call LNetM[DE]Attach. The invalid magic tells
-			 * srpc_handle_rpc to drop this RPC */
+			 * srpc_handle_rpc to drop this RPC
+			 */
 			msg->msg_magic = 0;
 		}
 
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.h b/drivers/staging/lustre/lnet/selftest/rpc.h
index 6b4a32a..9dfb366 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.h
+++ b/drivers/staging/lustre/lnet/selftest/rpc.h
@@ -281,8 +281,10 @@ srpc_unpack_msg_hdr(srpc_msg_t *msg)
 	if (msg->msg_magic == SRPC_MSG_MAGIC)
 		return; /* no flipping needed */
 
-	/* We do not swap the magic number here as it is needed to
-	   determine whether the body needs to be swapped. */
+	/*
+	 * We do not swap the magic number here as it is needed to
+	 * determine whether the body needs to be swapped.
+	 */
 	/* __swab32s(&msg->msg_magic); */
 	__swab32s(&msg->msg_type);
 	__swab32s(&msg->msg_version);
-- 
1.7.1
