From: James Simmons <jsimmons@infradead.org>
Date: Wed,  3 Jun 2015 16:43:24 -0400
Subject: [lustre-devel] [PATCH v3 5/8] staging:lustre: separate kernel and
	user land defines in the LNet headers
In-Reply-To: <1433364207-14307-1-git-send-email-jsimmons@infradead.org>
References: <1433364207-14307-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1433364207-14307-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Currently the lnet headers used by user land contain various internal
LNet structures that are only used by kernel space. Move the user land
structures to headers used by user land. The kernel structures are
relocated to headers that are never exposed to user land.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    3 -
 .../staging/lustre/include/linux/lnet/lib-types.h  |  175 ++-----------------
 .../staging/lustre/include/linux/lnet/lnetctl.h    |    7 +-
 drivers/staging/lustre/include/linux/lnet/lnetst.h |    5 +-
 .../staging/lustre/include/linux/lnet/socklnd.h    |    1 -
 drivers/staging/lustre/include/linux/lnet/types.h  |  169 +++++++++++++++++--
 drivers/staging/lustre/lnet/lnet/acceptor.c        |    2 -
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    3 +-
 8 files changed, 180 insertions(+), 185 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index c224062..2750570 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -34,8 +34,6 @@
  * Lustre is a trademark of Sun Microsystems, Inc.
  *
  * lnet/include/lnet/lib-lnet.h
- *
- * Top level include for library side routines
  */
 
 #ifndef __LNET_LIB_LNET_H__
@@ -43,7 +41,6 @@
 
 #include "../libcfs/libcfs.h"
 #include "api.h"
-#include "types.h"
 #include "lnet.h"
 #include "lib-types.h"
 
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 4177da2..fdf94dd 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -42,129 +42,20 @@
 #ifndef __LNET_LIB_TYPES_H__
 #define __LNET_LIB_TYPES_H__
 
-#include "../libcfs/libcfs.h"
-#include <linux/list.h>
-#include "types.h"
-
-#define WIRE_ATTR       __attribute__((packed))
-
-/* Packed version of lnet_process_id_t to transfer via network */
-typedef struct {
-	lnet_nid_t nid;
-	lnet_pid_t pid;   /* node id / process id */
-} WIRE_ATTR lnet_process_id_packed_t;
-
-/* The wire handle's interface cookie only matches one network interface in
- * one epoch (i.e. new cookie when the interface restarts or the node
- * reboots).  The object cookie only matches one object on that interface
- * during that object's lifetime (i.e. no cookie re-use). */
-typedef struct {
-	__u64 wh_interface_cookie;
-	__u64 wh_object_cookie;
-} WIRE_ATTR lnet_handle_wire_t;
-
-typedef enum {
-	LNET_MSG_ACK = 0,
-	LNET_MSG_PUT,
-	LNET_MSG_GET,
-	LNET_MSG_REPLY,
-	LNET_MSG_HELLO,
-} lnet_msg_type_t;
-
-/* The variant fields of the portals message header are aligned on an 8
- * byte boundary in the message header.  Note that all types used in these
- * wire structs MUST be fixed size and the smaller types are placed at the
- * end. */
-typedef struct lnet_ack {
-	lnet_handle_wire_t  dst_wmd;
-	__u64	       match_bits;
-	__u32	       mlength;
-} WIRE_ATTR lnet_ack_t;
-
-typedef struct lnet_put {
-	lnet_handle_wire_t  ack_wmd;
-	__u64	       match_bits;
-	__u64	       hdr_data;
-	__u32	       ptl_index;
-	__u32	       offset;
-} WIRE_ATTR lnet_put_t;
-
-typedef struct lnet_get {
-	lnet_handle_wire_t  return_wmd;
-	__u64	       match_bits;
-	__u32	       ptl_index;
-	__u32	       src_offset;
-	__u32	       sink_length;
-} WIRE_ATTR lnet_get_t;
-
-typedef struct lnet_reply {
-	lnet_handle_wire_t  dst_wmd;
-} WIRE_ATTR lnet_reply_t;
-
-typedef struct lnet_hello {
-	__u64	      incarnation;
-	__u32	      type;
-} WIRE_ATTR lnet_hello_t;
+#include <linux/kthread.h>
+#include <linux/uio.h>
+#include <linux/types.h>
+#include <net/sock.h>
 
-typedef struct {
-	lnet_nid_t	  dest_nid;
-	lnet_nid_t	  src_nid;
-	lnet_pid_t	  dest_pid;
-	lnet_pid_t	  src_pid;
-	__u32	       type;	       /* lnet_msg_type_t */
-	__u32	       payload_length;     /* payload data to follow */
-	/*<------__u64 aligned------->*/
-	union {
-		lnet_ack_t   ack;
-		lnet_put_t   put;
-		lnet_get_t   get;
-		lnet_reply_t reply;
-		lnet_hello_t hello;
-	} msg;
-} WIRE_ATTR lnet_hdr_t;
-
-/* A HELLO message contains a magic number and protocol version
- * code in the header's dest_nid, the peer's NID in the src_nid, and
- * LNET_MSG_HELLO in the type field.  All other common fields are zero
- * (including payload_size; i.e. no payload).
- * This is for use by byte-stream LNDs (e.g. TCP/IP) to check the peer is
- * running the same protocol and to find out its NID. These LNDs should
- * exchange HELLO messages when a connection is first established.  Individual
- * LNDs can put whatever else they fancy in lnet_hdr_t::msg.
- */
-typedef struct {
-	__u32   magic;			  /* LNET_PROTO_TCP_MAGIC */
-	__u16   version_major;		  /* increment on incompatible change */
-	__u16   version_minor;		  /* increment on compatible change */
-} WIRE_ATTR lnet_magicversion_t;
-
-/* PROTO MAGIC for LNDs */
-#define LNET_PROTO_IB_MAGIC		 0x0be91b91
-#define LNET_PROTO_RA_MAGIC		 0x0be91b92
-#define LNET_PROTO_QSW_MAGIC		0x0be91b93
-#define LNET_PROTO_GNI_MAGIC		0xb00fbabe /* ask Kim */
-#define LNET_PROTO_TCP_MAGIC		0xeebc0ded
-#define LNET_PROTO_PTL_MAGIC		0x50746C4E /* 'PtlN' unique magic */
-#define LNET_PROTO_MX_MAGIC		 0x4d583130 /* 'MX10'! */
-#define LNET_PROTO_ACCEPTOR_MAGIC	   0xacce7100
-#define LNET_PROTO_PING_MAGIC	       0x70696E67 /* 'ping' */
-
-/* Placeholder for a future "unified" protocol across all LNDs */
-/* Current LNDs that receive a request with this magic will respond with a
- * "stub" reply using their current protocol */
-#define LNET_PROTO_MAGIC		    0x45726963 /* ! */
-
-#define LNET_PROTO_TCP_VERSION_MAJOR	1
-#define LNET_PROTO_TCP_VERSION_MINOR	0
-
-/* Acceptor connection request */
-typedef struct {
-	__u32       acr_magic;		  /* PTL_ACCEPTOR_PROTO_MAGIC */
-	__u32       acr_version;		/* protocol version */
-	__u64       acr_nid;		    /* target NID */
-} WIRE_ATTR lnet_acceptor_connreq_t;
+#include "types.h"
 
-#define LNET_PROTO_ACCEPTOR_VERSION       1
+/* Max payload size */
+#define LNET_MAX_PAYLOAD      CONFIG_LNET_MAX_PAYLOAD
+#if (LNET_MAX_PAYLOAD < LNET_MTU)
+# error "LNET_MAX_PAYLOAD too small - error in configure --with-max-payload-mb"
+#elif (LNET_MAX_PAYLOAD > (PAGE_SIZE * LNET_MAX_IOV))
+#  error "LNET_MAX_PAYLOAD too large - error in configure --with-max-payload-mb"
+#endif
 
 /* forward refs */
 struct lnet_libmd;
@@ -299,7 +190,7 @@ typedef struct lnet_lnd {
 	int		   lnd_refcount;	 /* # active instances */
 
 	/* fields initialised by the LND */
-	unsigned int	  lnd_type;
+	__u32			lnd_type;
 
 	int  (*lnd_startup)(struct lnet_ni *ni);
 	void (*lnd_shutdown)(struct lnet_ni *ni);
@@ -353,15 +244,6 @@ typedef struct lnet_lnd {
 
 } lnd_t;
 
-#define LNET_NI_STATUS_UP      0x15aac0de
-#define LNET_NI_STATUS_DOWN    0xdeadface
-#define LNET_NI_STATUS_INVALID 0x00000000
-typedef struct {
-	lnet_nid_t ns_nid;
-	__u32      ns_status;
-	__u32      ns_unused;
-} WIRE_ATTR lnet_ni_status_t;
-
 struct lnet_tx_queue {
 	int			tq_credits;	/* # tx credits free */
 	int			tq_credits_min;	/* lowest it's been */
@@ -369,8 +251,6 @@ struct lnet_tx_queue {
 	struct list_head		tq_delayed;	/* delayed TXs */
 };
 
-#define LNET_MAX_INTERFACES   16
-
 typedef struct lnet_ni {
 	spinlock_t		ni_lock;
 	struct list_head		ni_list;	/* chain on ln_nis */
@@ -406,14 +286,6 @@ typedef struct lnet_ni {
 #define LNET_PING_FEAT_MASK		(LNET_PING_FEAT_BASE | \
 					 LNET_PING_FEAT_NI_STATUS)
 
-typedef struct {
-	__u32			pi_magic;
-	__u32			pi_features;
-	lnet_pid_t		pi_pid;
-	__u32			pi_nnis;
-	lnet_ni_status_t	pi_ni[0];
-} WIRE_ATTR lnet_ping_info_t;
-
 /* router checker data, per router */
 #define LNET_MAX_RTR_NIS   16
 #define LNET_PINGINFO_SIZE offsetof(lnet_ping_info_t, pi_ni[LNET_MAX_RTR_NIS])
@@ -496,6 +368,11 @@ typedef struct {
 	__u32		   lrn_net;	/* my net number */
 } lnet_remotenet_t;
 
+/** lnet message has credit and can be submitted to lnd for send/receive */
+#define LNET_CREDIT_OK		0
+/** lnet message is waiting for credit */
+#define LNET_CREDIT_WAIT	1
+
 typedef struct {
 	struct list_head rbp_bufs;	     /* my free buffer pool */
 	struct list_head rbp_msgs;	     /* messages blocking for a buffer */
@@ -511,23 +388,9 @@ typedef struct {
 	lnet_kiov_t	    rb_kiov[0];	  /* the buffer space */
 } lnet_rtrbuf_t;
 
-typedef struct {
-	__u32	msgs_alloc;
-	__u32	msgs_max;
-	__u32	errors;
-	__u32	send_count;
-	__u32	recv_count;
-	__u32	route_count;
-	__u32	drop_count;
-	__u64	send_length;
-	__u64	recv_length;
-	__u64	route_length;
-	__u64	drop_length;
-} WIRE_ATTR lnet_counters_t;
-
 #define LNET_PEER_HASHSIZE   503		/* prime! */
 
-#define LNET_NRBPOOLS	 3		 /* # different router buffer pools */
+#define LNET_NRBPOOLS		3	/* # different router buffer pools */
 
 enum {
 	/* Didn't match anything */
diff --git a/drivers/staging/lustre/include/linux/lnet/lnetctl.h b/drivers/staging/lustre/include/linux/lnet/lnetctl.h
index 98181d3..bdd69b2 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetctl.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetctl.h
@@ -14,12 +14,11 @@
  *   along with Portals; if not, write to the Free Software
  *   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  *
- * header for libptlctl.a
+ * header for lnet ioctl
  */
-#ifndef _PTLCTL_H_
-#define _PTLCTL_H_
+#ifndef _LNETCTL_H_
+#define _LNETCTL_H_
 
-#include "../libcfs/libcfs.h"
 #include "types.h"
 
 #define LNET_DEV_ID 0
diff --git a/drivers/staging/lustre/include/linux/lnet/lnetst.h b/drivers/staging/lustre/include/linux/lnet/lnetst.h
index 885f708..57432fd 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -41,9 +41,7 @@
 #ifndef __LNET_ST_H__
 #define __LNET_ST_H__
 
-#include "../libcfs/libcfs.h"
-#include "lnet.h"
-#include "lib-types.h"
+#include <linux/types.h>
 
 #define LST_FEAT_NONE		(0)
 #define LST_FEAT_BULK_LEN	(1 << 0)	/* enable variable page size */
@@ -468,7 +466,6 @@ typedef struct {
 	int		     png_flags;	      /* reserved flags */
 } lst_test_ping_param_t;
 
-/* more tests */
 typedef struct {
 	__u32 errors;
 	__u32 rpcs_sent;
diff --git a/drivers/staging/lustre/include/linux/lnet/socklnd.h b/drivers/staging/lustre/include/linux/lnet/socklnd.h
index 389038b..f7c7b08 100644
--- a/drivers/staging/lustre/include/linux/lnet/socklnd.h
+++ b/drivers/staging/lustre/include/linux/lnet/socklnd.h
@@ -39,7 +39,6 @@
 #define __LNET_LNET_SOCKLND_H__
 
 #include "types.h"
-#include "lib-types.h"
 
 #define SOCKLND_CONN_NONE     (-1)
 #define SOCKLND_CONN_ANY	0
diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/linux/lnet/types.h
index 15528a1..32b9431 100644
--- a/drivers/staging/lustre/include/linux/lnet/types.h
+++ b/drivers/staging/lustre/include/linux/lnet/types.h
@@ -37,11 +37,11 @@
 #ifndef __LNET_TYPES_H__
 #define __LNET_TYPES_H__
 
+#include <linux/types.h>
+
 /** \addtogroup lnet
  * @{ */
 
-#include "../libcfs/libcfs.h"
-
 /** \addtogroup lnet_addr
  * @{ */
 
@@ -74,6 +74,7 @@ typedef __u32 lnet_pid_t;
 
 #define LNET_PID_RESERVED 0xf0000000 /* reserved bits in PID */
 #define LNET_PID_USERFLAG 0x80000000 /* set in userspace peers */
+#define LNET_PID_LUSTRE	  12345
 
 #define LNET_TIME_FOREVER    (-1)
 
@@ -110,7 +111,158 @@ static inline __u32 LNET_MKNET(__u32 type, __u32 num)
 	return (type << 16) | num;
 }
 
-/**
+#define WIRE_ATTR	__packed
+
+/* Packed version of lnet_process_id_t to transfer via network */
+typedef struct {
+	/* node id / process id */
+	lnet_nid_t	nid;
+	lnet_pid_t	pid;
+} WIRE_ATTR lnet_process_id_packed_t;
+
+/* The wire handle's interface cookie only matches one network interface in
+ * one epoch (i.e. new cookie when the interface restarts or the node
+ * reboots).  The object cookie only matches one object on that interface
+ * during that object's lifetime (i.e. no cookie re-use). */
+typedef struct {
+	__u64	wh_interface_cookie;
+	__u64	wh_object_cookie;
+} WIRE_ATTR lnet_handle_wire_t;
+
+typedef enum {
+	LNET_MSG_ACK = 0,
+	LNET_MSG_PUT,
+	LNET_MSG_GET,
+	LNET_MSG_REPLY,
+	LNET_MSG_HELLO,
+} lnet_msg_type_t;
+
+/* The variant fields of the portals message header are aligned on an 8
+ * byte boundary in the message header.  Note that all types used in these
+ * wire structs MUST be fixed size and the smaller types are placed@the
+ * end. */
+typedef struct lnet_ack {
+	lnet_handle_wire_t	dst_wmd;
+	__u64			match_bits;
+	__u32			mlength;
+} WIRE_ATTR lnet_ack_t;
+
+typedef struct lnet_put {
+	lnet_handle_wire_t	ack_wmd;
+	__u64			match_bits;
+	__u64			hdr_data;
+	__u32			ptl_index;
+	__u32			offset;
+} WIRE_ATTR lnet_put_t;
+
+typedef struct lnet_get {
+	lnet_handle_wire_t	return_wmd;
+	__u64			match_bits;
+	__u32			ptl_index;
+	__u32			src_offset;
+	__u32			sink_length;
+} WIRE_ATTR lnet_get_t;
+
+typedef struct lnet_reply {
+	lnet_handle_wire_t	dst_wmd;
+} WIRE_ATTR lnet_reply_t;
+
+typedef struct lnet_hello {
+	__u64			incarnation;
+	__u32			type;
+} WIRE_ATTR lnet_hello_t;
+
+typedef struct {
+	lnet_nid_t	dest_nid;
+	lnet_nid_t	src_nid;
+	lnet_pid_t	dest_pid;
+	lnet_pid_t	src_pid;
+	__u32		type;		/* lnet_msg_type_t */
+	__u32		payload_length;	/* payload data to follow */
+	/*<------__u64 aligned------->*/
+	union {
+		lnet_ack_t	ack;
+		lnet_put_t	put;
+		lnet_get_t	get;
+		lnet_reply_t	reply;
+		lnet_hello_t	hello;
+	} msg;
+} WIRE_ATTR lnet_hdr_t;
+
+/* A HELLO message contains a magic number and protocol version
+ * code in the header's dest_nid, the peer's NID in the src_nid, and
+ * LNET_MSG_HELLO in the type field.  All other common fields are zero
+ * (including payload_size; i.e. no payload).
+ * This is for use by byte-stream LNDs (e.g. TCP/IP) to check the peer is
+ * running the same protocol and to find out its NID. These LNDs should
+ * exchange HELLO messages when a connection is first established.  Individual
+ * LNDs can put whatever else they fancy in lnet_hdr_t::msg.
+ */
+typedef struct {
+	__u32	magic;		/* LNET_PROTO_TCP_MAGIC */
+	__u16	version_major;	/* increment on incompatible change */
+	__u16	version_minor;	/* increment on compatible change */
+} WIRE_ATTR lnet_magicversion_t;
+
+/* PROTO MAGIC for LNDs */
+#define LNET_PROTO_IB_MAGIC		0x0be91b91
+#define LNET_PROTO_GNI_MAGIC		0xb00fbabe /* ask Kim */
+#define LNET_PROTO_TCP_MAGIC		0xeebc0ded
+#define LNET_PROTO_ACCEPTOR_MAGIC	0xacce7100
+#define LNET_PROTO_PING_MAGIC		0x70696E67 /* 'ping' */
+
+/* Placeholder for a future "unified" protocol across all LNDs */
+/* Current LNDs that receive a request with this magic will respond with a
+ * "stub" reply using their current protocol */
+#define LNET_PROTO_MAGIC		0x45726963 /* ! */
+
+#define LNET_PROTO_TCP_VERSION_MAJOR	1
+#define LNET_PROTO_TCP_VERSION_MINOR	0
+
+/* Acceptor connection request */
+typedef struct {
+	__u32	acr_magic;		/* PTL_ACCEPTOR_PROTO_MAGIC */
+	__u32	acr_version;		/* protocol version */
+	__u64	acr_nid;		/* target NID */
+} WIRE_ATTR lnet_acceptor_connreq_t;
+
+#define LNET_PROTO_ACCEPTOR_VERSION	1
+
+typedef struct {
+	lnet_nid_t	ns_nid;
+	__u32		ns_status;
+	__u32		ns_unused;
+} WIRE_ATTR lnet_ni_status_t;
+
+typedef struct {
+	__u32			pi_magic;
+	__u32			pi_features;
+	lnet_pid_t		pi_pid;
+	__u32			pi_nnis;
+	lnet_ni_status_t	pi_ni[0];
+} WIRE_ATTR lnet_ping_info_t;
+
+typedef struct lnet_counters {
+	__u32	msgs_alloc;
+	__u32	msgs_max;
+	__u32	errors;
+	__u32	send_count;
+	__u32	recv_count;
+	__u32	route_count;
+	__u32	drop_count;
+	__u64	send_length;
+	__u64	recv_length;
+	__u64	route_length;
+	__u64	drop_length;
+} WIRE_ATTR lnet_counters_t;
+
+#define LNET_NI_STATUS_UP      0x15aac0de
+#define LNET_NI_STATUS_DOWN    0xdeadface
+#define LNET_NI_STATUS_INVALID 0x00000000
+
+#define LNET_MAX_INTERFACES    16
+
+/*
  * Objects maintained by the LNet are accessed through handles. Handle types
  * have names of the form lnet_handle_xx_t, where xx is one of the two letter
  * object type codes ('eq' for event queue, 'md' for memory descriptor, and
@@ -311,17 +463,6 @@ typedef struct {
 /** limit on the number of fragments in discontiguous MDs */
 #define LNET_MAX_IOV    256
 
-/* Max payload size */
-# define LNET_MAX_PAYLOAD	CONFIG_LNET_MAX_PAYLOAD
-# if (LNET_MAX_PAYLOAD < LNET_MTU)
-#  error "LNET_MAX_PAYLOAD too small - error in configure --with-max-payload-mb"
-# else
-#  if (LNET_MAX_PAYLOAD > (PAGE_SIZE * LNET_MAX_IOV))
-/*  PAGE_SIZE is a constant: check with cpp! */
-#   error "LNET_MAX_PAYLOAD too large - error in configure --with-max-payload-mb"
-#  endif
-# endif
-
 /**
  * Options for the MD structure. See lnet_md_t::options.
  */
diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
index 1dc7c8a..4928f5c 100644
--- a/drivers/staging/lustre/lnet/lnet/acceptor.c
+++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
@@ -243,8 +243,6 @@ lnet_accept(struct socket *sock, __u32 magic)
 
 		if (magic == le32_to_cpu(LNET_PROTO_TCP_MAGIC))
 			str = "'old' socknal/tcpnal";
-		else if (lnet_accept_magic(magic, LNET_PROTO_RA_MAGIC))
-			str = "'old' ranal";
 		else
 			str = "unrecognised";
 
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index a2d0d10..57e9752 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -35,10 +35,11 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LNET
-#include "../../include/linux/lnet/lib-lnet.h"
 #include <linux/log2.h>
 #include <linux/ktime.h>
 
+#include "../../include/linux/lnet/lib-lnet.h"
+
 #define D_LNI D_CONSOLE
 
 lnet_t the_lnet;			   /* THE state of the network */
-- 
1.7.1
