From: James Simmons <jsimmons@infradead.org>
Date: Thu, 11 Jun 2015 15:18:07 -0400
Subject: [lustre-devel] [PATCH v4 1/9] staging:lustre: Delete all obsolete
	LND drivers
In-Reply-To: <1434050295-10986-1-git-send-email-jsimmons@infradead.org>
References: <1434050295-10986-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1434050295-10986-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Remove ralnd, ptllnd, mxlnd, qswlnd drivers. They are no
longer supported and have not even been buildable
for a long time.

Signed-off-by: James Simmons <uja.ornl@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6209
Reviewed-on: http://review.whamcloud.com/13663
Reviewed-by: Isaac Huang <he.huang@intel.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/include/linux/libcfs/libcfs_ioctl.h     |    2 +-
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    1 -
 .../staging/lustre/include/linux/lnet/lib-types.h  |    4 -
 drivers/staging/lustre/include/linux/lnet/ptllnd.h |   93 ---------------
 .../lustre/include/linux/lnet/ptllnd_wire.h        |  119 --------------------
 drivers/staging/lustre/lnet/lnet/acceptor.c        |    2 -
 drivers/staging/lustre/lnet/lnet/config.c          |   77 -------------
 7 files changed, 1 insertions(+), 297 deletions(-)
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/ptllnd.h
 delete mode 100644 drivers/staging/lustre/include/linux/lnet/ptllnd_wire.h

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
index 3ee3878..f5d741f 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_ioctl.h
@@ -134,7 +134,7 @@ struct libcfs_ioctl_handler {
 #define IOC_LIBCFS_DEL_PEER		_IOWR('e', 74, long)
 #define IOC_LIBCFS_ADD_PEER		_IOWR('e', 75, long)
 #define IOC_LIBCFS_GET_PEER		_IOWR('e', 76, long)
-#define IOC_LIBCFS_GET_TXDESC	      _IOWR('e', 77, long)
+/* ioctl 77 is free for use */
 #define IOC_LIBCFS_ADD_INTERFACE	   _IOWR('e', 78, long)
 #define IOC_LIBCFS_DEL_INTERFACE	   _IOWR('e', 79, long)
 #define IOC_LIBCFS_GET_INTERFACE	   _IOWR('e', 80, long)
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index ac3be94..ffe88f6 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -623,7 +623,6 @@ void lnet_md_deconstruct(lnet_libmd_t *lmd, lnet_md_t *umd);
 
 void lnet_register_lnd(lnd_t *lnd);
 void lnet_unregister_lnd(lnd_t *lnd);
-int lnet_set_ip_niaddr(lnet_ni_t *ni);
 
 int lnet_connect(struct socket **sockp, lnet_nid_t peer_nid,
 		 __u32 local_ip, __u32 peer_ip, int peer_port);
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 41827a0..ad6df88 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -142,12 +142,8 @@ typedef struct {
 
 /* PROTO MAGIC for LNDs */
 #define LNET_PROTO_IB_MAGIC		 0x0be91b91
-#define LNET_PROTO_RA_MAGIC		 0x0be91b92
-#define LNET_PROTO_QSW_MAGIC		0x0be91b93
 #define LNET_PROTO_GNI_MAGIC		0xb00fbabe /* ask Kim */
 #define LNET_PROTO_TCP_MAGIC		0xeebc0ded
-#define LNET_PROTO_PTL_MAGIC		0x50746C4E /* 'PtlN' unique magic */
-#define LNET_PROTO_MX_MAGIC		 0x4d583130 /* 'MX10'! */
 #define LNET_PROTO_ACCEPTOR_MAGIC	   0xacce7100
 #define LNET_PROTO_PING_MAGIC	       0x70696E67 /* 'ping' */
 
diff --git a/drivers/staging/lustre/include/linux/lnet/ptllnd.h b/drivers/staging/lustre/include/linux/lnet/ptllnd.h
deleted file mode 100644
index c91d653..0000000
--- a/drivers/staging/lustre/include/linux/lnet/ptllnd.h
+++ /dev/null
@@ -1,93 +0,0 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
- *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- *
- * lnet/include/lnet/ptllnd.h
- *
- * Author: PJ Kirner <pjkirner@clusterfs.com>
- */
-
-/*
- * The PTLLND was designed to support Portals with
- * Lustre and non-lustre UNLINK semantics.
- * However for now the two targets are Cray Portals
- * on the XT3 and Lustre Portals (for testing) both
- * have Lustre UNLINK semantics, so this is defined
- * by default.
- */
-#define LUSTRE_PORTALS_UNLINK_SEMANTICS
-
-#ifdef _USING_LUSTRE_PORTALS_
-
-/* NIDs are 64-bits on Lustre Portals */
-#define FMT_NID "%llu"
-#define FMT_PID "%d"
-
-/* When using Lustre Portals Lustre completion semantics are imlicit*/
-#define PTL_MD_LUSTRE_COMPLETION_SEMANTICS      0
-
-#else /* _USING_CRAY_PORTALS_ */
-
-/* NIDs are integers on Cray Portals */
-#define FMT_NID "%u"
-#define FMT_PID "%d"
-
-/* When using Cray Portals this is defined in the Cray Portals Header*/
-/*#define PTL_MD_LUSTRE_COMPLETION_SEMANTICS */
-
-/* Can compare handles directly on Cray Portals */
-#define PtlHandleIsEqual(a, b) ((a) == (b))
-
-/* Different error types on Cray Portals*/
-#define ptl_err_t ptl_ni_fail_t
-
-/*
- * The Cray Portals has no maximum number of IOVs.  The
- * maximum is limited only by memory and size of the
- * int parameters (2^31-1).
- * Lustre only really require that the underyling
- * implementation to support at least LNET_MAX_IOV,
- * so for Cray portals we can safely just use that
- * value here.
- *
- */
-#define PTL_MD_MAX_IOV	  LNET_MAX_IOV
-
-#endif
-
-#define FMT_PTLID "ptlid:"FMT_PID"-"FMT_NID
-
-/* Align incoming small request messages to an 8 byte boundary if this is
- * supported to avoid alignment issues on some architectures */
-#ifndef PTL_MD_LOCAL_ALIGN8
-# define PTL_MD_LOCAL_ALIGN8 0
-#endif
diff --git a/drivers/staging/lustre/include/linux/lnet/ptllnd_wire.h b/drivers/staging/lustre/include/linux/lnet/ptllnd_wire.h
deleted file mode 100644
index 808f37b..0000000
--- a/drivers/staging/lustre/include/linux/lnet/ptllnd_wire.h
+++ /dev/null
@@ -1,119 +0,0 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
- *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- *
- * lnet/include/lnet/ptllnd_wire.h
- *
- * Author: PJ Kirner <pjkirner@clusterfs.com>
- */
-
-/* Minimum buffer size that any peer will post to receive ptllnd messages */
-#define PTLLND_MIN_BUFFER_SIZE  256
-
-/************************************************************************
- * Tunable defaults that {u,k}lnds/ptllnd should have in common.
- */
-
-#define PTLLND_PORTAL	   9	  /* The same portal PTLPRC used when talking to cray portals */
-#define PTLLND_PID	      9	  /* The Portals PID */
-#define PTLLND_PEERCREDITS      8	  /* concurrent sends to 1 peer */
-
-/* Default buffer size for kernel ptllnds (guaranteed eager) */
-#define PTLLND_MAX_KLND_MSG_SIZE 512
-
-/* Default buffer size for catamount ptllnds (not guaranteed eager) - large
- * enough to avoid RDMA for anything sent while control is not in liblustre */
-#define PTLLND_MAX_ULND_MSG_SIZE 512
-
-/************************************************************************
- * Portals LND Wire message format.
- * These are sent in sender's byte order (i.e. receiver flips).
- */
-
-#define PTL_RESERVED_MATCHBITS  0x100	/* below this value is reserved
-					 * above is for bulk data transfer */
-#define LNET_MSG_MATCHBITS       0      /* the value for the message channel */
-
-typedef struct {
-	lnet_hdr_t	kptlim_hdr;	     /* portals header */
-	char	      kptlim_payload[0];      /* piggy-backed payload */
-} WIRE_ATTR kptl_immediate_msg_t;
-
-typedef struct {
-	lnet_hdr_t	kptlrm_hdr;	     /* portals header */
-	__u64	     kptlrm_matchbits;       /* matchbits */
-} WIRE_ATTR kptl_rdma_msg_t;
-
-typedef struct {
-	__u64	     kptlhm_matchbits;       /* matchbits */
-	__u32	     kptlhm_max_msg_size;    /* max message size */
-} WIRE_ATTR kptl_hello_msg_t;
-
-typedef struct {
-	/* First 2 fields fixed FOR ALL TIME */
-	__u32	   ptlm_magic;     /* I'm a Portals LND message */
-	__u16	   ptlm_version;   /* this is my version number */
-	__u8	    ptlm_type;      /* the message type */
-	__u8	    ptlm_credits;   /* returned credits */
-	__u32	   ptlm_nob;       /* # bytes in whole message */
-	__u32	   ptlm_cksum;     /* checksum (0 == no checksum) */
-	__u64	   ptlm_srcnid;    /* sender's NID */
-	__u64	   ptlm_srcstamp;  /* sender's incarnation */
-	__u64	   ptlm_dstnid;    /* destination's NID */
-	__u64	   ptlm_dststamp;  /* destination's incarnation */
-	__u32	   ptlm_srcpid;    /* sender's PID */
-	__u32	   ptlm_dstpid;    /* destination's PID */
-
-	 union {
-		kptl_immediate_msg_t    immediate;
-		kptl_rdma_msg_t	 rdma;
-		kptl_hello_msg_t	hello;
-	} WIRE_ATTR ptlm_u;
-
-} kptl_msg_t;
-
-/* kptl_msg_t::ptlm_credits is only a __u8 */
-#define PTLLND_MSG_MAX_CREDITS ((typeof(((kptl_msg_t *)0)->ptlm_credits)) - 1)
-
-#define PTLLND_MSG_MAGIC		LNET_PROTO_PTL_MAGIC
-#define PTLLND_MSG_VERSION	      0x04
-
-#define PTLLND_RDMA_OK		  0x00
-#define PTLLND_RDMA_FAIL		0x01
-
-#define PTLLND_MSG_TYPE_INVALID	 0x00
-#define PTLLND_MSG_TYPE_PUT	     0x01
-#define PTLLND_MSG_TYPE_GET	     0x02
-#define PTLLND_MSG_TYPE_IMMEDIATE       0x03    /* No bulk data xfer*/
-#define PTLLND_MSG_TYPE_NOOP	    0x04
-#define PTLLND_MSG_TYPE_HELLO	   0x05
-#define PTLLND_MSG_TYPE_NAK	     0x06
diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
index be85035..99f8396 100644
--- a/drivers/staging/lustre/lnet/lnet/acceptor.c
+++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
@@ -243,8 +243,6 @@ lnet_accept(struct socket *sock, __u32 magic)
 
 		if (magic == le32_to_cpu(LNET_PROTO_TCP_MAGIC))
 			str = "'old' socknal/tcpnal";
-		else if (lnet_accept_magic(magic, LNET_PROTO_RA_MAGIC))
-			str = "'old' ranal";
 		else
 			str = "unrecognised";
 
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index efbb74a..9c576ce 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -1210,80 +1210,3 @@ lnet_parse_ip2nets(char **networksp, char *ip2nets)
 
 	return 0;
 }
-
-int
-lnet_set_ip_niaddr(lnet_ni_t *ni)
-{
-	__u32 net = LNET_NIDNET(ni->ni_nid);
-	char **names;
-	int n;
-	__u32 ip;
-	__u32 netmask;
-	int up;
-	int i;
-	int rc;
-
-	/* Convenience for LNDs that use the IP address of a local interface as
-	 * the local address part of their NID */
-
-	if (ni->ni_interfaces[0] != NULL) {
-
-		CLASSERT(LNET_MAX_INTERFACES > 1);
-
-		if (ni->ni_interfaces[1] != NULL) {
-			CERROR("Net %s doesn't support multiple interfaces\n",
-			       libcfs_net2str(net));
-			return -EPERM;
-		}
-
-		rc = lnet_ipif_query(ni->ni_interfaces[0], &up, &ip, &netmask);
-		if (rc != 0) {
-			CERROR("Net %s can't query interface %s: %d\n",
-			       libcfs_net2str(net), ni->ni_interfaces[0], rc);
-			return -EPERM;
-		}
-
-		if (!up) {
-			CERROR("Net %s can't use interface %s: it's down\n",
-			       libcfs_net2str(net), ni->ni_interfaces[0]);
-			return -ENETDOWN;
-		}
-
-		ni->ni_nid = LNET_MKNID(net, ip);
-		return 0;
-	}
-
-	n = lnet_ipif_enumerate(&names);
-	if (n <= 0) {
-		CERROR("Net %s can't enumerate interfaces: %d\n",
-		       libcfs_net2str(net), n);
-		return 0;
-	}
-
-	for (i = 0; i < n; i++) {
-		if (!strcmp(names[i], "lo")) /* skip the loopback IF */
-			continue;
-
-		rc = lnet_ipif_query(names[i], &up, &ip, &netmask);
-		if (rc != 0) {
-			CWARN("Net %s can't query interface %s: %d\n",
-			      libcfs_net2str(net), names[i], rc);
-			continue;
-		}
-
-		if (!up) {
-			CWARN("Net %s ignoring interface %s (down)\n",
-			      libcfs_net2str(net), names[i]);
-			continue;
-		}
-
-		lnet_ipif_free_enumeration(names, n);
-		ni->ni_nid = LNET_MKNID(net, ip);
-		return 0;
-	}
-
-	CERROR("Net %s can't find any interfaces\n", libcfs_net2str(net));
-	lnet_ipif_free_enumeration(names, n);
-	return -ENOENT;
-}
-EXPORT_SYMBOL(lnet_set_ip_niaddr);
-- 
1.7.1
