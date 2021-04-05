Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CECE0C433ED
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:53:20 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 9269360FF0
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:53:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9269360FF0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 3E016328EF0;
	Mon,  5 Apr 2021 00:52:40 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4F63332821F
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:28 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 287C7EC6;
 Sun,  4 Apr 2021 20:51:17 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 25FE590AAE; Sun,  4 Apr 2021 20:51:17 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:51:06 -0400
Message-Id: <1617583870-32029-38-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
References: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 37/41] lnet: place wire protocol data int own
 headers
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

This macro adds nothing of value, and make the code harder to
read for new readers so it was remove for the Linux client.
We still want to keep track of what data structures are
transmitted over the wire and ensure the protocol does not get
broken. Move the wire protocol structures to their own header
files and add wire checking.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12678
Lustre-commit: 6ae187404a8d7f8a ("LU-12678 lnet: discard WIRE_ATTR")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/37914
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 include/uapi/linux/lnet/libcfs_debug.h |   1 +
 include/uapi/linux/lnet/libcfs_ioctl.h |   1 +
 include/uapi/linux/lnet/lnet-dlc.h     |   1 +
 include/uapi/linux/lnet/lnet-idl.h     | 241 +++++++++++++++++++++++++++++++++
 include/uapi/linux/lnet/lnet-types.h   | 203 +--------------------------
 include/uapi/linux/lnet/lnetctl.h      |   1 +
 include/uapi/linux/lnet/lnetst.h       |   2 +
 include/uapi/linux/lnet/nidstr.h       |   1 +
 include/uapi/linux/lnet/socklnd.h      |   1 +
 net/lnet/klnds/o2iblnd/o2iblnd-idl.h   | 157 +++++++++++++++++++++
 net/lnet/klnds/o2iblnd/o2iblnd.c       | 166 ++++++++++++++++++++++-
 net/lnet/klnds/o2iblnd/o2iblnd.h       | 114 +---------------
 net/lnet/lnet/api-ni.c                 |  49 ++++++-
 13 files changed, 616 insertions(+), 322 deletions(-)
 create mode 100644 include/uapi/linux/lnet/lnet-idl.h
 create mode 100644 net/lnet/klnds/o2iblnd/o2iblnd-idl.h

diff --git a/include/uapi/linux/lnet/libcfs_debug.h b/include/uapi/linux/lnet/libcfs_debug.h
index 6255331..b720e06 100644
--- a/include/uapi/linux/lnet/libcfs_debug.h
+++ b/include/uapi/linux/lnet/libcfs_debug.h
@@ -1,3 +1,4 @@
+/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
 /*
  * GPL HEADER START
  *
diff --git a/include/uapi/linux/lnet/libcfs_ioctl.h b/include/uapi/linux/lnet/libcfs_ioctl.h
index d0b29c52..5a46a48 100644
--- a/include/uapi/linux/lnet/libcfs_ioctl.h
+++ b/include/uapi/linux/lnet/libcfs_ioctl.h
@@ -1,3 +1,4 @@
+/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
 /*
  * GPL HEADER START
  *
diff --git a/include/uapi/linux/lnet/lnet-dlc.h b/include/uapi/linux/lnet/lnet-dlc.h
index ca1f8ae..e775dfe 100644
--- a/include/uapi/linux/lnet/lnet-dlc.h
+++ b/include/uapi/linux/lnet/lnet-dlc.h
@@ -1,3 +1,4 @@
+/* SPDX-License-Identifier: LGPL-2.0+ WITH Linux-syscall-note */
 /*
  * LGPL HEADER START
  *
diff --git a/include/uapi/linux/lnet/lnet-idl.h b/include/uapi/linux/lnet/lnet-idl.h
new file mode 100644
index 0000000..a5b1414
--- /dev/null
+++ b/include/uapi/linux/lnet/lnet-idl.h
@@ -0,0 +1,241 @@
+/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
+/*
+ * GPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 only,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License version 2 for more details (a copy is included
+ * in the LICENSE file that accompanied this code).
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2 along with this program; If not, see
+ * http://www.gnu.org/licenses/gpl-2.0.html
+ *
+ * GPL HEADER END
+ */
+/*
+ * Copyright (c) 2003, 2010, Oracle and/or its affiliates. All rights reserved.
+ * Use is subject to license terms.
+ *
+ * Copyright (c) 2012, 2017, Intel Corporation.
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ * Lustre is a trademark of Sun Microsystems, Inc.
+ */
+
+#ifndef __UAPI_LNET_IDL_H__
+#define __UAPI_LNET_IDL_H__
+
+#include <linux/types.h>
+
+/************************************************************************
+ * Core LNet wire message format.
+ * These are sent in sender's byte order (i.e. receiver flips).
+ */
+
+/**
+ * Address of an end-point in an LNet network.
+ *
+ * A node can have multiple end-points and hence multiple addresses.
+ * An LNet network can be a simple network (e.g. tcp0) or a network of
+ * LNet networks connected by LNet routers. Therefore an end-point address
+ * has two parts: network ID, and address within a network.
+ *
+ * \see LNET_NIDNET, LNET_NIDADDR, and LNET_MKNID.
+ */
+typedef __u64 lnet_nid_t;
+
+/**
+ * ID of a process in a node. Shortened as PID to distinguish from
+ * lnet_process_id, the global process ID.
+ */
+typedef __u32 lnet_pid_t;
+
+/* Packed version of struct lnet_process_id to transfer via network */
+struct lnet_process_id_packed {
+	lnet_nid_t nid;
+	lnet_pid_t pid;	/* node id / process id */
+} __attribute__((packed));
+
+/* The wire handle's interface cookie only matches one network interface in
+ * one epoch (i.e. new cookie when the interface restarts or the node
+ * reboots).  The object cookie only matches one object on that interface
+ * during that object's lifetime (i.e. no cookie re-use).
+ */
+struct lnet_handle_wire {
+	__u64 wh_interface_cookie;
+	__u64 wh_object_cookie;
+} __attribute__((packed));
+
+enum lnet_msg_type {
+	LNET_MSG_ACK = 0,
+	LNET_MSG_PUT,
+	LNET_MSG_GET,
+	LNET_MSG_REPLY,
+	LNET_MSG_HELLO,
+};
+
+/* The variant fields of the portals message header are aligned on an 8
+ * byte boundary in the message header.  Note that all types used in these
+ * wire structs MUST be fixed size and the smaller types are placed at the
+ * end.
+ */
+struct lnet_ack {
+	struct lnet_handle_wire	dst_wmd;
+	__u64			match_bits;
+	__u32			mlength;
+} __attribute__((packed));
+
+struct lnet_put {
+	struct lnet_handle_wire	ack_wmd;
+	__u64			match_bits;
+	__u64			hdr_data;
+	__u32			ptl_index;
+	__u32			offset;
+} __attribute__((packed));
+
+struct lnet_get {
+	struct lnet_handle_wire	return_wmd;
+	__u64			match_bits;
+	__u32			ptl_index;
+	__u32			src_offset;
+	__u32			sink_length;
+} __attribute__((packed));
+
+struct lnet_reply {
+	struct lnet_handle_wire	dst_wmd;
+} __attribute__((packed));
+
+struct lnet_hello {
+	__u64			incarnation;
+	__u32			type;
+} __attribute__((packed));
+
+struct lnet_hdr {
+	lnet_nid_t	dest_nid;
+	lnet_nid_t	src_nid;
+	lnet_pid_t	dest_pid;
+	lnet_pid_t	src_pid;
+	__u32		type;		/* enum lnet_msg_type */
+	__u32		payload_length;	/* payload data to follow */
+	/*<------__u64 aligned------->*/
+	union {
+		struct lnet_ack		ack;
+		struct lnet_put		put;
+		struct lnet_get		get;
+		struct lnet_reply	reply;
+		struct lnet_hello	hello;
+	} msg;
+} __attribute__((packed));
+
+/* A HELLO message contains a magic number and protocol version
+ * code in the header's dest_nid, the peer's NID in the src_nid, and
+ * LNET_MSG_HELLO in the type field.  All other common fields are zero
+ * (including payload_size; i.e. no payload).
+ * This is for use by byte-stream LNDs (e.g. TCP/IP) to check the peer is
+ * running the same protocol and to find out its NID. These LNDs should
+ * exchange HELLO messages when a connection is first established.  Individual
+ * LNDs can put whatever else they fancy in lnet_hdr::msg.
+ */
+struct lnet_magicversion {
+	__u32	magic;		/* LNET_PROTO_TCP_MAGIC */
+	__u16	version_major;	/* increment on incompatible change */
+	__u16	version_minor;	/* increment on compatible change */
+} __attribute__((packed));
+
+/* PROTO MAGIC for LNDs */
+#define LNET_PROTO_IB_MAGIC		0x0be91b91
+#define LNET_PROTO_GNI_MAGIC		0xb00fbabe /* ask Kim */
+#define LNET_PROTO_TCP_MAGIC		0xeebc0ded
+#define LNET_PROTO_ACCEPTOR_MAGIC	0xacce7100
+#define LNET_PROTO_PING_MAGIC		0x70696E67 /* 'ping' */
+
+/* Placeholder for a future "unified" protocol across all LNDs */
+/* Current LNDs that receive a request with this magic will respond
+ * with a "stub" reply using their current protocol */
+#define LNET_PROTO_MAGIC		0x45726963 /* ! */
+
+#define LNET_PROTO_TCP_VERSION_MAJOR	1
+#define LNET_PROTO_TCP_VERSION_MINOR	0
+
+/* Acceptor connection request */
+struct lnet_acceptor_connreq {
+	__u32	acr_magic;	/* PTL_ACCEPTOR_PROTO_MAGIC */
+	__u32	acr_version;	/* protocol version */
+	__u64	acr_nid;	/* target NID */
+} __attribute__((packed));
+
+#define LNET_PROTO_ACCEPTOR_VERSION	1
+
+struct lnet_counters_common {
+	__u32	lcc_msgs_alloc;
+	__u32	lcc_msgs_max;
+	__u32	lcc_errors;
+	__u32	lcc_send_count;
+	__u32	lcc_recv_count;
+	__u32	lcc_route_count;
+	__u32	lcc_drop_count;
+	__u64	lcc_send_length;
+	__u64	lcc_recv_length;
+	__u64	lcc_route_length;
+	__u64	lcc_drop_length;
+} __attribute__((packed));
+
+
+#define LNET_NI_STATUS_UP	0x15aac0de
+#define LNET_NI_STATUS_DOWN	0xdeadface
+#define LNET_NI_STATUS_INVALID	0x00000000
+
+struct lnet_ni_status {
+	lnet_nid_t ns_nid;
+	__u32      ns_status;
+	__u32      ns_unused;
+} __attribute__((packed));
+
+/*
+ * NB: value of these features equal to LNET_PROTO_PING_VERSION_x
+ * of old LNet, so there shouldn't be any compatibility issue
+ */
+#define LNET_PING_FEAT_INVAL		(0)		/* no feature */
+#define LNET_PING_FEAT_BASE		(1 << 0)	/* just a ping */
+#define LNET_PING_FEAT_NI_STATUS	(1 << 1)	/* return NI status */
+#define LNET_PING_FEAT_RTE_DISABLED	(1 << 2)        /* Routing enabled */
+#define LNET_PING_FEAT_MULTI_RAIL	(1 << 3)        /* Multi-Rail aware */
+#define LNET_PING_FEAT_DISCOVERY	(1 << 4)	/* Supports Discovery */
+
+/*
+ * All ping feature bits fit to hit the wire.
+ * In lnet_assert_wire_constants() this is compared against its open-coded
+ * value, and in lnet_ping_target_update() it is used to verify that no
+ * unknown bits have been set.
+ * New feature bits can be added, just be aware that this does change the
+ * over-the-wire protocol.
+ */
+#define LNET_PING_FEAT_BITS		(LNET_PING_FEAT_BASE | \
+					 LNET_PING_FEAT_NI_STATUS | \
+					 LNET_PING_FEAT_RTE_DISABLED | \
+					 LNET_PING_FEAT_MULTI_RAIL | \
+					 LNET_PING_FEAT_DISCOVERY)
+
+struct lnet_ping_info {
+	__u32			pi_magic;
+	__u32			pi_features;
+	lnet_pid_t		pi_pid;
+	__u32			pi_nnis;
+	struct lnet_ni_status	pi_ni[0];
+} __attribute__((packed));
+
+#define LNET_PING_INFO_SIZE(NNIDS) \
+	offsetof(struct lnet_ping_info, pi_ni[NNIDS])
+#define LNET_PING_INFO_LONI(PINFO)      ((PINFO)->pi_ni[0].ns_nid)
+#define LNET_PING_INFO_SEQNO(PINFO)     ((PINFO)->pi_ni[0].ns_status)
+
+#endif
diff --git a/include/uapi/linux/lnet/lnet-types.h b/include/uapi/linux/lnet/lnet-types.h
index 5bf9917..4d0b6f9 100644
--- a/include/uapi/linux/lnet/lnet-types.h
+++ b/include/uapi/linux/lnet/lnet-types.h
@@ -1,3 +1,4 @@
+/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
 /*
  * GPL HEADER START
  *
@@ -34,6 +35,7 @@
 #define __LNET_TYPES_H__
 
 #include <linux/types.h>
+#include <linux/lnet/lnet-idl.h>
 
 /** \addtogroup lnet
  * @{
@@ -50,23 +52,6 @@
  */
 #define LNET_RESERVED_PORTAL	0
 
-/**
- * Address of an end-point in an LNet network.
- *
- * A node can have multiple end-points and hence multiple addresses.
- * An LNet network can be a simple network (e.g. tcp0) or a network of
- * LNet networks connected by LNet routers. Therefore an end-point address
- * has two parts: network ID, and address within a network.
- *
- * \see LNET_NIDNET, LNET_NIDADDR, and LNET_MKNID.
- */
-typedef __u64 lnet_nid_t;
-/**
- * ID of a process in a node. Shortened as PID to distinguish from
- * lnet_process_id, the global process ID.
- */
-typedef __u32 lnet_pid_t;
-
 /** wildcard NID that matches any end-point address */
 #define LNET_NID_ANY	((lnet_nid_t)(-1))
 /** wildcard PID that matches any lnet_pid_t */
@@ -114,186 +99,6 @@ static inline __u32 LNET_MKNET(__u32 type, __u32 num)
 
 #define LNET_NET_ANY LNET_NIDNET(LNET_NID_ANY)
 
-/* Packed version of lnet_process_id to transfer via network */
-struct lnet_process_id_packed {
-	/* node id / process id */
-	lnet_nid_t	nid;
-	lnet_pid_t	pid;
-} __packed;
-
-/*
- * The wire handle's interface cookie only matches one network interface in
- * one epoch (i.e. new cookie when the interface restarts or the node
- * reboots).  The object cookie only matches one object on that interface
- * during that object's lifetime (i.e. no cookie re-use).
- */
-struct lnet_handle_wire {
-	__u64	wh_interface_cookie;
-	__u64	wh_object_cookie;
-} __packed;
-
-enum lnet_msg_type {
-	LNET_MSG_ACK = 0,
-	LNET_MSG_PUT,
-	LNET_MSG_GET,
-	LNET_MSG_REPLY,
-	LNET_MSG_HELLO,
-};
-
-/*
- * The variant fields of the portals message header are aligned on an 8
- * byte boundary in the message header.  Note that all types used in these
- * wire structs MUST be fixed size and the smaller types are placed at the
- * end.
- */
-struct lnet_ack {
-	struct lnet_handle_wire	dst_wmd;
-	__u64			match_bits;
-	__u32			mlength;
-} __packed;
-
-struct lnet_put {
-	struct lnet_handle_wire	ack_wmd;
-	__u64			match_bits;
-	__u64			hdr_data;
-	__u32			ptl_index;
-	__u32			offset;
-} __packed;
-
-struct lnet_get {
-	struct lnet_handle_wire	return_wmd;
-	__u64			match_bits;
-	__u32			ptl_index;
-	__u32			src_offset;
-	__u32			sink_length;
-} __packed;
-
-struct lnet_reply {
-	struct lnet_handle_wire	dst_wmd;
-} __packed;
-
-struct lnet_hello {
-	__u64			incarnation;
-	__u32			type;
-} __packed;
-
-struct lnet_hdr {
-	lnet_nid_t	dest_nid;
-	lnet_nid_t	src_nid;
-	lnet_pid_t	dest_pid;
-	lnet_pid_t	src_pid;
-	__u32		type;		/* enum lnet_msg_type */
-	__u32		payload_length;	/* payload data to follow */
-	/*<------__u64 aligned------->*/
-	union {
-		struct lnet_ack		ack;
-		struct lnet_put		put;
-		struct lnet_get		get;
-		struct lnet_reply	reply;
-		struct lnet_hello	hello;
-	} msg;
-} __packed;
-
-/*
- * NB: value of these features equal to LNET_PROTO_PING_VERSION_x
- * of old LNet, so there shouldn't be any compatibility issue
- */
-#define LNET_PING_FEAT_INVAL		(0)		/* no feature */
-#define LNET_PING_FEAT_BASE		(1 << 0)	/* just a ping */
-#define LNET_PING_FEAT_NI_STATUS	(1 << 1)	/* return NI status */
-#define LNET_PING_FEAT_RTE_DISABLED	(1 << 2)	/* Routing enabled */
-#define LNET_PING_FEAT_MULTI_RAIL	(1 << 3)	/* Multi-Rail aware */
-#define LNET_PING_FEAT_DISCOVERY	(1 << 4)	/* Supports Discovery */
-
-/*
- * All ping feature bits fit to hit the wire.
- * In lnet_assert_wire_constants() this is compared against its open-coded
- * value, and in lnet_ping_target_update() it is used to verify that no
- * unknown bits have been set.
- * New feature bits can be added, just be aware that this does change the
- * over-the-wire protocol.
- */
-#define LNET_PING_FEAT_BITS		(LNET_PING_FEAT_BASE | \
-					 LNET_PING_FEAT_NI_STATUS | \
-					 LNET_PING_FEAT_RTE_DISABLED | \
-					 LNET_PING_FEAT_MULTI_RAIL | \
-					 LNET_PING_FEAT_DISCOVERY)
-
-/*
- * A HELLO message contains a magic number and protocol version
- * code in the header's dest_nid, the peer's NID in the src_nid, and
- * LNET_MSG_HELLO in the type field.  All other common fields are zero
- * (including payload_size; i.e. no payload).
- * This is for use by byte-stream LNDs (e.g. TCP/IP) to check the peer is
- * running the same protocol and to find out its NID. These LNDs should
- * exchange HELLO messages when a connection is first established.  Individual
- * LNDs can put whatever else they fancy in struct lnet_hdr::msg.
- */
-struct lnet_magicversion {
-	__u32	magic;		/* LNET_PROTO_TCP_MAGIC */
-	__u16	version_major;	/* increment on incompatible change */
-	__u16	version_minor;	/* increment on compatible change */
-} __packed;
-
-/* PROTO MAGIC for LNDs */
-#define LNET_PROTO_IB_MAGIC		0x0be91b91
-#define LNET_PROTO_GNI_MAGIC		0xb00fbabe /* ask Kim */
-#define LNET_PROTO_TCP_MAGIC		0xeebc0ded
-#define LNET_PROTO_ACCEPTOR_MAGIC	0xacce7100
-#define LNET_PROTO_PING_MAGIC		0x70696E67 /* 'ping' */
-
-/* Placeholder for a future "unified" protocol across all LNDs */
-/*
- * Current LNDs that receive a request with this magic will respond with a
- * "stub" reply using their current protocol
- */
-#define LNET_PROTO_MAGIC		0x45726963 /* ! */
-
-#define LNET_PROTO_TCP_VERSION_MAJOR	1
-#define LNET_PROTO_TCP_VERSION_MINOR	0
-
-/* Acceptor connection request */
-struct lnet_acceptor_connreq {
-	__u32	acr_magic;		/* PTL_ACCEPTOR_PROTO_MAGIC */
-	__u32	acr_version;		/* protocol version */
-	__u64	acr_nid;		/* target NID */
-} __packed;
-
-#define LNET_PROTO_ACCEPTOR_VERSION	1
-
-struct lnet_ni_status {
-	lnet_nid_t	ns_nid;
-	__u32		ns_status;
-	__u32		ns_unused;
-} __packed;
-
-struct lnet_ping_info {
-	__u32			pi_magic;
-	__u32			pi_features;
-	lnet_pid_t		pi_pid;
-	__u32			pi_nnis;
-	struct lnet_ni_status	pi_ni[0];
-} __packed;
-
-#define LNET_PING_INFO_SIZE(NNIDS) \
-	offsetof(struct lnet_ping_info, pi_ni[NNIDS])
-#define LNET_PING_INFO_LONI(PINFO)	((PINFO)->pi_ni[0].ns_nid)
-#define LNET_PING_INFO_SEQNO(PINFO)	((PINFO)->pi_ni[0].ns_status)
-
-struct lnet_counters_common {
-	__u32	lcc_msgs_alloc;
-	__u32	lcc_msgs_max;
-	__u32	lcc_errors;
-	__u32	lcc_send_count;
-	__u32	lcc_recv_count;
-	__u32	lcc_route_count;
-	__u32	lcc_drop_count;
-	__u64	lcc_send_length;
-	__u64	lcc_recv_length;
-	__u64	lcc_route_length;
-	__u64	lcc_drop_length;
-} __packed;
-
 struct lnet_counters_health {
 	__u32	lch_rst_alloc;
 	__u32	lch_resend_count;
@@ -315,10 +120,6 @@ struct lnet_counters {
 	struct lnet_counters_health lct_health;
 };
 
-#define LNET_NI_STATUS_UP	0x15aac0de
-#define LNET_NI_STATUS_DOWN	0xdeadface
-#define LNET_NI_STATUS_INVALID	0x00000000
-
 #define LNET_INTERFACES_NUM		16
 
 /* The minimum number of interfaces per node supported by LNet. */
diff --git a/include/uapi/linux/lnet/lnetctl.h b/include/uapi/linux/lnet/lnetctl.h
index 3c280f1..3b66ce3 100644
--- a/include/uapi/linux/lnet/lnetctl.h
+++ b/include/uapi/linux/lnet/lnetctl.h
@@ -1,3 +1,4 @@
+/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
 /*
  *   This file is part of Portals, http://www.sf.net/projects/lustre/
  *
diff --git a/include/uapi/linux/lnet/lnetst.h b/include/uapi/linux/lnet/lnetst.h
index dd38a90..af0435f1 100644
--- a/include/uapi/linux/lnet/lnetst.h
+++ b/include/uapi/linux/lnet/lnetst.h
@@ -1,3 +1,4 @@
+/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
 /*
  * GPL HEADER START
  *
@@ -556,6 +557,7 @@ struct lst_test_ping_param {
 	int	png_flags;	/* reserved flags */
 };
 
+/* Both struct srpc_counters and struct sfw_counters are sent over the wire */
 struct srpc_counters {
 	__u32 errors;
 	__u32 rpcs_sent;
diff --git a/include/uapi/linux/lnet/nidstr.h b/include/uapi/linux/lnet/nidstr.h
index 021ee0e..d402a6a 100644
--- a/include/uapi/linux/lnet/nidstr.h
+++ b/include/uapi/linux/lnet/nidstr.h
@@ -1,3 +1,4 @@
+/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
 /*
  * GPL HEADER START
  *
diff --git a/include/uapi/linux/lnet/socklnd.h b/include/uapi/linux/lnet/socklnd.h
index 6453e05..50f2a13 100644
--- a/include/uapi/linux/lnet/socklnd.h
+++ b/include/uapi/linux/lnet/socklnd.h
@@ -1,3 +1,4 @@
+/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
 /*
  * GPL HEADER START
  *
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd-idl.h b/net/lnet/klnds/o2iblnd/o2iblnd-idl.h
new file mode 100644
index 0000000..660440c
--- /dev/null
+++ b/net/lnet/klnds/o2iblnd/o2iblnd-idl.h
@@ -0,0 +1,157 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * GPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 only,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License version 2 for more details (a copy is included
+ * in the LICENSE file that accompanied this code).
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2 along with this program; If not, see
+ * http://www.gnu.org/licenses/gpl-2.0.html
+ *
+ * GPL HEADER END
+ */
+/*
+ * Copyright (c) 2007, 2010, Oracle and/or its affiliates. All rights reserved.
+ * Use is subject to license terms.
+ *
+ * Copyright (c) 2011, 2017, Intel Corporation.
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ * Lustre is a trademark of Sun Microsystems, Inc.
+ *
+ * lnet/klnds/o2iblnd/o2iblnd-idl.h
+ *
+ * Author: Eric Barton <eric@bartonsoftware.com>
+ */
+#ifndef __LNET_O2IBLND_IDL_H__
+#define __LNET_O2IBLND_IDL_H__
+
+#include <uapi/linux/lnet/lnet-idl.h>
+
+/************************************************************************
+ * IB Wire message format.
+ * These are sent in sender's byte order (i.e. receiver flips).
+ */
+
+struct kib_connparams {
+	u16			ibcp_queue_depth;
+	u16			ibcp_max_frags;
+	u32			ibcp_max_msg_size;
+} __packed;
+
+struct kib_immediate_msg {
+	struct lnet_hdr		ibim_hdr;	/* portals header */
+	char			ibim_payload[0];/* piggy-backed payload */
+} __packed;
+
+struct kib_rdma_frag {
+	u32			rf_nob;		/* # bytes this frag */
+	u64			rf_addr;	/* CAVEAT EMPTOR: misaligned!! */
+} __packed;
+
+struct kib_rdma_desc {
+	u32			rd_key;		/* local/remote key */
+	u32			rd_nfrags;	/* # fragments */
+	struct kib_rdma_frag	rd_frags[0];	/* buffer frags */
+} __packed;
+
+struct kib_putreq_msg {
+	struct lnet_hdr		ibprm_hdr;	/* portals header */
+	u64			ibprm_cookie;	/* opaque completion cookie */
+} __packed;
+
+struct kib_putack_msg {
+	u64			ibpam_src_cookie;/* reflected completion cookie */
+	u64			ibpam_dst_cookie;/* opaque completion cookie */
+	struct kib_rdma_desc	ibpam_rd;	/* sender's sink buffer */
+} __packed;
+
+struct kib_get_msg {
+	struct lnet_hdr		ibgm_hdr;	/* portals header */
+	u64			ibgm_cookie;	/* opaque completion cookie */
+	struct kib_rdma_desc	ibgm_rd;	/* rdma descriptor */
+} __packed;
+
+struct kib_completion_msg {
+	u64			ibcm_cookie;	/* opaque completion cookie */
+	s32			ibcm_status;    /* < 0 failure: >= 0 length */
+} __packed;
+
+struct kib_msg {
+	/* First 2 fields fixed FOR ALL TIME */
+	u32			ibm_magic;	/* I'm an ibnal message */
+	u16			ibm_version;	/* this is my version number */
+
+	u8			ibm_type;	/* msg type */
+	u8			ibm_credits;	/* returned credits */
+	u32			ibm_nob;	/* # bytes in whole message */
+	u32			ibm_cksum;	/* checksum (0 == no checksum) */
+	u64			ibm_srcnid;	/* sender's NID */
+	u64			ibm_srcstamp;	/* sender's incarnation */
+	u64			ibm_dstnid;	/* destination's NID */
+	u64			ibm_dststamp;	/* destination's incarnation */
+
+	union {
+		struct kib_connparams		connparams;
+		struct kib_immediate_msg	immediate;
+		struct kib_putreq_msg		putreq;
+		struct kib_putack_msg		putack;
+		struct kib_get_msg		get;
+		struct kib_completion_msg	completion;
+	} __packed ibm_u;
+} __packed;
+
+#define IBLND_MSG_MAGIC LNET_PROTO_IB_MAGIC     /* unique magic */
+
+#define IBLND_MSG_VERSION_1	0x11
+#define IBLND_MSG_VERSION_2	0x12
+#define IBLND_MSG_VERSION	IBLND_MSG_VERSION_2
+
+#define IBLND_MSG_CONNREQ	0xc0	/* connection request */
+#define IBLND_MSG_CONNACK	0xc1	/* connection acknowledge */
+#define IBLND_MSG_NOOP		0xd0	/* nothing (just credits) */
+#define IBLND_MSG_IMMEDIATE	0xd1	/* immediate */
+#define IBLND_MSG_PUT_REQ	0xd2	/* putreq (src->sink) */
+#define IBLND_MSG_PUT_NAK	0xd3	/* completion (sink->src) */
+#define IBLND_MSG_PUT_ACK	0xd4	/* putack (sink->src) */
+#define IBLND_MSG_PUT_DONE	0xd5	/* completion (src->sink) */
+#define IBLND_MSG_GET_REQ	0xd6	/* getreq (sink->src) */
+#define IBLND_MSG_GET_DONE	0xd7	/* completion (src->sink: all OK) */
+
+struct kib_rej {
+	u32			ibr_magic;	/* sender's magic */
+	u16			ibr_version;	/* sender's version */
+	u8			ibr_why;	/* reject reason */
+	u8			ibr_padding;	/* padding */
+	u64			ibr_incarnation;/* incarnation of peer_ni */
+	struct kib_connparams	ibr_cp;		/* connection parameters */
+} __packed;
+
+/* connection rejection reasons */
+#define IBLND_REJECT_CONN_RACE       1          /* You lost connection race */
+#define IBLND_REJECT_NO_RESOURCES    2          /* Out of memory/conns etc */
+#define IBLND_REJECT_FATAL           3          /* Anything else */
+
+#define IBLND_REJECT_CONN_UNCOMPAT   4          /* incompatible version peer_ni */
+#define IBLND_REJECT_CONN_STALE      5          /* stale peer_ni */
+
+/* peer_ni's rdma frags doesn't match mine */
+#define IBLND_REJECT_RDMA_FRAGS      6
+/* peer_ni's msg queue size doesn't match mine */
+#define IBLND_REJECT_MSG_QUEUE_SIZE  7
+#define IBLND_REJECT_INVALID_SRV_ID  8
+
+/***********************************************************************/
+
+#endif /* __LNET_O2IBLND_IDL_H__ */
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index 9147d17..f6865ad3 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2958,6 +2958,164 @@ static int kiblnd_startup(struct lnet_ni *ni)
 	.lnd_recv	= kiblnd_recv,
 };
 
+static void ko2inlnd_assert_wire_constants(void)
+{
+	BUILD_BUG_ON(IBLND_MSG_MAGIC != 0x0be91b91);
+	BUILD_BUG_ON(IBLND_MSG_VERSION_1 != 0x11);
+	BUILD_BUG_ON(IBLND_MSG_VERSION_2 != 0x12);
+	BUILD_BUG_ON(IBLND_MSG_VERSION != IBLND_MSG_VERSION_2);
+
+	BUILD_BUG_ON(IBLND_MSG_CONNREQ != 0xc0);
+	BUILD_BUG_ON(IBLND_MSG_CONNACK != 0xc1);
+	BUILD_BUG_ON(IBLND_MSG_NOOP != 0xd0);
+	BUILD_BUG_ON(IBLND_MSG_IMMEDIATE != 0xd1);
+	BUILD_BUG_ON(IBLND_MSG_PUT_REQ != 0xd2);
+	BUILD_BUG_ON(IBLND_MSG_PUT_NAK != 0xd3);
+	BUILD_BUG_ON(IBLND_MSG_PUT_ACK != 0xd4);
+	BUILD_BUG_ON(IBLND_MSG_PUT_DONE != 0xd5);
+	BUILD_BUG_ON(IBLND_MSG_GET_REQ != 0xd6);
+	BUILD_BUG_ON(IBLND_MSG_GET_DONE != 0xd7);
+
+	BUILD_BUG_ON(IBLND_REJECT_CONN_RACE != 1);
+	BUILD_BUG_ON(IBLND_REJECT_NO_RESOURCES != 2);
+	BUILD_BUG_ON(IBLND_REJECT_FATAL != 3);
+	BUILD_BUG_ON(IBLND_REJECT_CONN_UNCOMPAT != 4);
+	BUILD_BUG_ON(IBLND_REJECT_CONN_STALE != 5);
+	BUILD_BUG_ON(IBLND_REJECT_RDMA_FRAGS != 6);
+	BUILD_BUG_ON(IBLND_REJECT_MSG_QUEUE_SIZE != 7);
+	BUILD_BUG_ON(IBLND_REJECT_INVALID_SRV_ID != 8);
+
+	BUILD_BUG_ON((int)sizeof(struct kib_connparams) != 8);
+	BUILD_BUG_ON((int)offsetof(struct kib_connparams, ibcp_queue_depth) != 0);
+	BUILD_BUG_ON((int)sizeof(((struct kib_connparams *)0)->ibcp_queue_depth) != 2);
+	BUILD_BUG_ON((int)offsetof(struct kib_connparams, ibcp_max_frags) != 2);
+	BUILD_BUG_ON((int)sizeof(((struct kib_connparams *)0)->ibcp_max_frags) != 2);
+	BUILD_BUG_ON((int)offsetof(struct kib_connparams, ibcp_max_msg_size) != 4);
+	BUILD_BUG_ON((int)sizeof(((struct kib_connparams *)0)->ibcp_max_msg_size) != 4);
+
+	BUILD_BUG_ON((int)sizeof(struct kib_immediate_msg) != 72);
+	BUILD_BUG_ON((int)offsetof(struct kib_immediate_msg, ibim_hdr) != 0);
+	BUILD_BUG_ON((int)sizeof(((struct kib_immediate_msg *)0)->ibim_hdr) != 72);
+	BUILD_BUG_ON((int)offsetof(struct kib_immediate_msg, ibim_payload) != 72);
+	BUILD_BUG_ON((int)sizeof(((struct kib_immediate_msg *)0)->ibim_payload) != 0);
+
+	BUILD_BUG_ON((int)sizeof(struct kib_rdma_frag) != 12);
+	BUILD_BUG_ON((int)offsetof(struct kib_rdma_frag, rf_nob) != 0);
+	BUILD_BUG_ON((int)sizeof(((struct kib_rdma_frag *)0)->rf_nob) != 4);
+	BUILD_BUG_ON((int)offsetof(struct kib_rdma_frag, rf_addr) != 4);
+	BUILD_BUG_ON((int)sizeof(((struct kib_rdma_frag *)0)->rf_addr) != 8);
+
+	BUILD_BUG_ON((int)sizeof(struct kib_rdma_desc) != 8);
+	BUILD_BUG_ON((int)offsetof(struct kib_rdma_desc, rd_key) != 0);
+	BUILD_BUG_ON((int)sizeof(((struct kib_rdma_desc *)0)->rd_key) != 4);
+	BUILD_BUG_ON((int)offsetof(struct kib_rdma_desc, rd_nfrags) != 4);
+	BUILD_BUG_ON((int)sizeof(((struct kib_rdma_desc *)0)->rd_nfrags) != 4);
+	BUILD_BUG_ON((int)offsetof(struct kib_rdma_desc, rd_frags) != 8);
+	BUILD_BUG_ON((int)sizeof(((struct kib_rdma_desc *)0)->rd_frags) != 0);
+
+	BUILD_BUG_ON((int)sizeof(struct kib_putreq_msg) != 80);
+	BUILD_BUG_ON((int)offsetof(struct kib_putreq_msg, ibprm_hdr) != 0);
+	BUILD_BUG_ON((int)sizeof(((struct kib_putreq_msg *)0)->ibprm_hdr) != 72);
+	BUILD_BUG_ON((int)offsetof(struct kib_putreq_msg, ibprm_cookie) != 72);
+	BUILD_BUG_ON((int)sizeof(((struct kib_putreq_msg *)0)->ibprm_cookie) != 8);
+
+	BUILD_BUG_ON((int)sizeof(struct kib_putack_msg) != 24);
+	BUILD_BUG_ON((int)offsetof(struct kib_putack_msg, ibpam_src_cookie) != 0);
+	BUILD_BUG_ON((int)sizeof(((struct kib_putack_msg *)0)->ibpam_src_cookie) != 8);
+	BUILD_BUG_ON((int)offsetof(struct kib_putack_msg, ibpam_dst_cookie) != 8);
+	BUILD_BUG_ON((int)sizeof(((struct kib_putack_msg *)0)->ibpam_dst_cookie) != 8);
+	BUILD_BUG_ON((int)offsetof(struct kib_putack_msg, ibpam_rd) != 16);
+	BUILD_BUG_ON((int)sizeof(((struct kib_putack_msg *)0)->ibpam_rd) != 8);
+
+	BUILD_BUG_ON((int)sizeof(struct kib_get_msg) != 88);
+	BUILD_BUG_ON((int)offsetof(struct kib_get_msg, ibgm_hdr) != 0);
+	BUILD_BUG_ON((int)sizeof(((struct kib_get_msg *)0)->ibgm_hdr) != 72);
+	BUILD_BUG_ON((int)offsetof(struct kib_get_msg, ibgm_cookie) != 72);
+	BUILD_BUG_ON((int)sizeof(((struct kib_get_msg *)0)->ibgm_cookie) != 8);
+	BUILD_BUG_ON((int)offsetof(struct kib_get_msg, ibgm_rd) != 80);
+	BUILD_BUG_ON((int)sizeof(((struct kib_get_msg *)0)->ibgm_rd) != 8);
+
+	BUILD_BUG_ON((int)sizeof(struct kib_completion_msg) != 12);
+	BUILD_BUG_ON((int)offsetof(struct kib_completion_msg, ibcm_cookie) != 0);
+	BUILD_BUG_ON((int)sizeof(((struct kib_completion_msg *)0)->ibcm_cookie) != 8);
+	BUILD_BUG_ON((int)offsetof(struct kib_completion_msg, ibcm_status) != 8);
+	BUILD_BUG_ON((int)sizeof(((struct kib_completion_msg *)0)->ibcm_status) != 4);
+
+	/* Checks for struct kib_msg */
+	//BUILD_BUG_ON((int)sizeof(struct kib_msg) != 12);
+	BUILD_BUG_ON((int)offsetof(struct kib_msg, ibm_magic) != 0);
+	BUILD_BUG_ON((int)sizeof(((struct kib_msg *)0)->ibm_magic) != 4);
+	BUILD_BUG_ON((int)offsetof(struct kib_msg, ibm_version) != 4);
+	BUILD_BUG_ON((int)sizeof(((struct kib_msg *)0)->ibm_version) != 2);
+	BUILD_BUG_ON((int)offsetof(struct kib_msg, ibm_type) != 6);
+	BUILD_BUG_ON((int)sizeof(((struct kib_msg *)0)->ibm_type) != 1);
+	BUILD_BUG_ON((int)offsetof(struct kib_msg, ibm_credits) != 7);
+	BUILD_BUG_ON((int)sizeof(((struct kib_msg *)0)->ibm_credits) != 1);
+	BUILD_BUG_ON((int)offsetof(struct kib_msg, ibm_nob) != 8);
+	BUILD_BUG_ON((int)sizeof(((struct kib_msg *)0)->ibm_nob) != 4);
+	BUILD_BUG_ON((int)offsetof(struct kib_msg, ibm_cksum) != 12);
+	BUILD_BUG_ON((int)sizeof(((struct kib_msg *)0)->ibm_cksum) != 4);
+	BUILD_BUG_ON((int)offsetof(struct kib_msg, ibm_srcnid) != 16);
+	BUILD_BUG_ON((int)sizeof(((struct kib_msg *)0)->ibm_srcnid) != 8);
+	BUILD_BUG_ON((int)offsetof(struct kib_msg, ibm_srcstamp) != 24);
+	BUILD_BUG_ON((int)sizeof(((struct kib_msg *)0)->ibm_srcstamp) != 8);
+	BUILD_BUG_ON((int)offsetof(struct kib_msg, ibm_dstnid) != 32);
+	BUILD_BUG_ON((int)sizeof(((struct kib_msg *)0)->ibm_dstnid) != 8);
+	BUILD_BUG_ON((int)offsetof(struct kib_msg, ibm_dststamp) != 40);
+	BUILD_BUG_ON((int)sizeof(((struct kib_msg *)0)->ibm_dststamp) != 8);
+
+	/* Connparams */
+	BUILD_BUG_ON((int)offsetof(struct kib_msg, ibm_u.connparams.ibcp_queue_depth) != 48);
+	BUILD_BUG_ON((int)sizeof(((struct kib_msg *)0)->ibm_u.connparams.ibcp_queue_depth) != 2);
+	BUILD_BUG_ON((int)offsetof(struct kib_msg, ibm_u.connparams.ibcp_max_frags) != 50);
+	BUILD_BUG_ON((int)sizeof(((struct kib_msg *)0)->ibm_u.connparams.ibcp_max_frags) != 2);
+	BUILD_BUG_ON((int)offsetof(struct kib_msg, ibm_u.connparams.ibcp_max_msg_size) != 52);
+	BUILD_BUG_ON((int)sizeof(((struct kib_msg *)0)->ibm_u.connparams.ibcp_max_msg_size) != 4);
+
+	/* Immediate message */
+	BUILD_BUG_ON((int)offsetof(struct kib_msg, ibm_u.immediate.ibim_hdr) != 48);
+	BUILD_BUG_ON((int)sizeof(((struct kib_msg *)0)->ibm_u.immediate.ibim_hdr) != 72);
+	BUILD_BUG_ON((int)offsetof(struct kib_msg, ibm_u.immediate.ibim_payload) != 120);
+	BUILD_BUG_ON((int)sizeof(((struct kib_msg *)0)->ibm_u.immediate.ibim_payload) != 0);
+
+	/* PUT req message */
+	BUILD_BUG_ON((int)offsetof(struct kib_msg, ibm_u.putreq.ibprm_hdr) != 48);
+	BUILD_BUG_ON((int)sizeof(((struct kib_msg *)0)->ibm_u.putreq.ibprm_hdr) != 72);
+	BUILD_BUG_ON((int)offsetof(struct kib_msg, ibm_u.putreq.ibprm_cookie) != 120);
+	BUILD_BUG_ON((int)sizeof(((struct kib_msg *)0)->ibm_u.putreq.ibprm_cookie) != 8);
+
+	/* Put ACK */
+	BUILD_BUG_ON((int)offsetof(struct kib_msg, ibm_u.putack.ibpam_src_cookie) != 48);
+	BUILD_BUG_ON((int)sizeof(((struct kib_msg *)0)->ibm_u.putack.ibpam_src_cookie) != 8);
+	BUILD_BUG_ON((int)offsetof(struct kib_msg, ibm_u.putack.ibpam_dst_cookie) != 56);
+	BUILD_BUG_ON((int)sizeof(((struct kib_msg *)0)->ibm_u.putack.ibpam_dst_cookie) != 8);
+	BUILD_BUG_ON((int)offsetof(struct kib_msg, ibm_u.putack.ibpam_rd) != 64);
+	BUILD_BUG_ON((int)sizeof(((struct kib_msg *)0)->ibm_u.putack.ibpam_rd) != 8);
+
+	/* GET message */
+	BUILD_BUG_ON((int)offsetof(struct kib_msg, ibm_u.get.ibgm_hdr) != 48);
+	BUILD_BUG_ON((int)sizeof(((struct kib_msg *)0)->ibm_u.get.ibgm_hdr) != 72);
+	BUILD_BUG_ON((int)offsetof(struct kib_msg, ibm_u.get.ibgm_cookie) != 120);
+	BUILD_BUG_ON((int)sizeof(((struct kib_msg *)0)->ibm_u.get.ibgm_cookie) != 8);
+	BUILD_BUG_ON((int)offsetof(struct kib_msg, ibm_u.get.ibgm_rd) != 128);
+	BUILD_BUG_ON((int)sizeof(((struct kib_msg *)0)->ibm_u.get.ibgm_rd) != 8);
+
+	/* Completion message */
+	BUILD_BUG_ON((int)offsetof(struct kib_msg, ibm_u.completion.ibcm_cookie) != 48);
+	BUILD_BUG_ON((int)sizeof(((struct kib_msg *)0)->ibm_u.completion.ibcm_cookie) != 8);
+	BUILD_BUG_ON((int)offsetof(struct kib_msg, ibm_u.completion.ibcm_status) != 56);
+	BUILD_BUG_ON((int)sizeof(((struct kib_msg *)0)->ibm_u.completion.ibcm_status) != 4);
+
+	/* Sanity checks */
+	BUILD_BUG_ON(sizeof(struct kib_msg) > IBLND_MSG_SIZE);
+	BUILD_BUG_ON(offsetof(struct kib_msg,
+		     ibm_u.get.ibgm_rd.rd_frags[IBLND_MAX_RDMA_FRAGS]) >
+		     IBLND_MSG_SIZE);
+	BUILD_BUG_ON(offsetof(struct kib_msg,
+		     ibm_u.putack.ibpam_rd.rd_frags[IBLND_MAX_RDMA_FRAGS]) >
+		     IBLND_MSG_SIZE);
+}
+
 static void __exit ko2iblnd_exit(void)
 {
 	lnet_unregister_lnd(&the_o2iblnd);
@@ -2967,13 +3125,7 @@ static int __init ko2iblnd_init(void)
 {
 	int rc;
 
-	BUILD_BUG_ON(sizeof(struct kib_msg) > IBLND_MSG_SIZE);
-	BUILD_BUG_ON(offsetof(struct kib_msg,
-			  ibm_u.get.ibgm_rd.rd_frags[IBLND_MAX_RDMA_FRAGS])
-			  > IBLND_MSG_SIZE);
-	BUILD_BUG_ON(offsetof(struct kib_msg,
-			  ibm_u.putack.ibpam_rd.rd_frags[IBLND_MAX_RDMA_FRAGS])
-			  > IBLND_MSG_SIZE);
+	ko2inlnd_assert_wire_constants();
 
 	kiblnd_tunables_init();
 
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index 12d220c..8db03bd 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -64,6 +64,7 @@
 #define DEBUG_SUBSYSTEM S_LND
 
 #include <linux/lnet/lib-lnet.h>
+#include "o2iblnd-idl.h"
 
 #define IBLND_PEER_HASH_SIZE		101	/* # peer_ni lists */
 
@@ -376,119 +377,6 @@ struct kib_data {
 #define IBLND_INIT_DATA		1
 #define IBLND_INIT_ALL		2
 
-/************************************************************************
- * IB Wire message format.
- * These are sent in sender's byte order (i.e. receiver flips).
- */
-
-struct kib_connparams {
-	u16			ibcp_queue_depth;
-	u16			ibcp_max_frags;
-	u32			ibcp_max_msg_size;
-} __packed;
-
-struct kib_immediate_msg {
-	struct lnet_hdr		ibim_hdr;	 /* portals header */
-	char			ibim_payload[0]; /* piggy-backed payload */
-} __packed;
-
-struct kib_rdma_frag {
-	u32			rf_nob;		/* # bytes this frag */
-	u64			rf_addr;	/* CAVEAT EMPTOR: misaligned!! */
-} __packed;
-
-struct kib_rdma_desc {
-	u32			rd_key;		/* local/remote key */
-	u32			rd_nfrags;	/* # fragments */
-	struct kib_rdma_frag	rd_frags[0];	/* buffer frags */
-} __packed;
-
-struct kib_putreq_msg {
-	struct lnet_hdr		ibprm_hdr;	/* portals header */
-	u64			ibprm_cookie;	/* opaque completion cookie */
-} __packed;
-
-struct kib_putack_msg {
-	u64			ibpam_src_cookie; /* reflected completion cookie */
-	u64			ibpam_dst_cookie; /* opaque completion cookie */
-	struct kib_rdma_desc	ibpam_rd;	  /* sender's sink buffer */
-} __packed;
-
-struct kib_get_msg {
-	struct lnet_hdr		ibgm_hdr;	/* portals header */
-	u64			ibgm_cookie;	/* opaque completion cookie */
-	struct kib_rdma_desc	ibgm_rd;	/* rdma descriptor */
-} __packed;
-
-struct kib_completion_msg {
-	u64			ibcm_cookie;	/* opaque completion cookie */
-	s32			ibcm_status;	/* < 0 failure: >= 0 length */
-} __packed;
-
-struct kib_msg {
-	/* First 2 fields fixed FOR ALL TIME */
-	u32			ibm_magic;	/* I'm an ibnal message */
-	u16			ibm_version;	/* this is my version number */
-
-	u8			ibm_type;	/* msg type */
-	u8			ibm_credits;	/* returned credits */
-	u32			ibm_nob;	/* # bytes in whole message */
-	u32			ibm_cksum;	/* checksum (0 == no checksum) */
-	u64			ibm_srcnid;	/* sender's NID */
-	u64			ibm_srcstamp;	/* sender's incarnation */
-	u64			ibm_dstnid;	/* destination's NID */
-	u64			ibm_dststamp;	/* destination's incarnation */
-
-	union {
-		struct kib_connparams		connparams;
-		struct kib_immediate_msg	immediate;
-		struct kib_putreq_msg		putreq;
-		struct kib_putack_msg		putack;
-		struct kib_get_msg		get;
-		struct kib_completion_msg	completion;
-	} __packed ibm_u;
-} __packed;
-
-#define IBLND_MSG_MAGIC		LNET_PROTO_IB_MAGIC /* unique magic */
-
-#define IBLND_MSG_VERSION_1	0x11
-#define IBLND_MSG_VERSION_2	0x12
-#define IBLND_MSG_VERSION	IBLND_MSG_VERSION_2
-
-#define IBLND_MSG_CONNREQ	0xc0	/* connection request */
-#define IBLND_MSG_CONNACK	0xc1	/* connection acknowledge */
-#define IBLND_MSG_NOOP		0xd0	/* nothing (just credits) */
-#define IBLND_MSG_IMMEDIATE	0xd1	/* immediate */
-#define IBLND_MSG_PUT_REQ	0xd2	/* putreq (src->sink) */
-#define IBLND_MSG_PUT_NAK	0xd3	/* completion (sink->src) */
-#define IBLND_MSG_PUT_ACK	0xd4	/* putack (sink->src) */
-#define IBLND_MSG_PUT_DONE	0xd5	/* completion (src->sink) */
-#define IBLND_MSG_GET_REQ	0xd6	/* getreq (sink->src) */
-#define IBLND_MSG_GET_DONE	0xd7	/* completion (src->sink: all OK) */
-
-struct kib_rej {
-	u32			ibr_magic;	/* sender's magic */
-	u16			ibr_version;	/* sender's version */
-	u8			ibr_why;	/* reject reason */
-	u8			ibr_padding;	/* padding */
-	u64			ibr_incarnation;/* incarnation of peer_ni */
-	struct kib_connparams	ibr_cp;		/* connection parameters */
-} __packed;
-
-/* connection rejection reasons */
-#define IBLND_REJECT_CONN_RACE		1 /* You lost connection race */
-#define IBLND_REJECT_NO_RESOURCES	2 /* Out of memory/conns etc */
-#define IBLND_REJECT_FATAL		3 /* Anything else */
-#define IBLND_REJECT_CONN_UNCOMPAT	4 /* incompatible version peer_ni */
-#define IBLND_REJECT_CONN_STALE		5 /* stale peer_ni */
-/* peer_ni's rdma frags doesn't match mine */
-#define IBLND_REJECT_RDMA_FRAGS		6
-/* peer_ni's msg queue size doesn't match mine */
-#define IBLND_REJECT_MSG_QUEUE_SIZE	7
-#define IBLND_REJECT_INVALID_SRV_ID	8
-
-/***********************************************************************/
-
 struct kib_rx {					/* receive message */
 	struct list_head	rx_list;	/* queue for attention */
 	struct kib_conn        *rx_conn;	/* owning conn */
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index f121d69..542cc2e 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -689,7 +689,17 @@ static void lnet_assert_wire_constants(void)
 	BUILD_BUG_ON(LNET_MSG_REPLY != 3);
 	BUILD_BUG_ON(LNET_MSG_HELLO != 4);
 
-	/* Checks for struct ptl_handle_wire_t */
+	BUILD_BUG_ON((int)sizeof(lnet_nid_t) != 8);
+	BUILD_BUG_ON((int)sizeof(lnet_pid_t) != 4);
+
+	/* Checks for struct lnet_process_id_packed */
+	BUILD_BUG_ON((int)sizeof(struct lnet_process_id_packed) != 12);
+	BUILD_BUG_ON((int)offsetof(struct lnet_process_id_packed, nid) != 0);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_process_id_packed *)0)->nid) != 8);
+	BUILD_BUG_ON((int)offsetof(struct lnet_process_id_packed, pid) != 8);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_process_id_packed *)0)->pid) != 4);
+
+	/* Checks for struct lnet_handle_wire */
 	BUILD_BUG_ON((int)sizeof(struct lnet_handle_wire) != 16);
 	BUILD_BUG_ON((int)offsetof(struct lnet_handle_wire, wh_interface_cookie) != 0);
 	BUILD_BUG_ON((int)sizeof(((struct lnet_handle_wire *)0)->wh_interface_cookie) != 8);
@@ -801,6 +811,43 @@ static void lnet_assert_wire_constants(void)
 	BUILD_BUG_ON((int)sizeof(((struct lnet_ping_info *)0)->pi_nnis) != 4);
 	BUILD_BUG_ON((int)offsetof(struct lnet_ping_info, pi_ni) != 16);
 	BUILD_BUG_ON((int)sizeof(((struct lnet_ping_info *)0)->pi_ni) != 0);
+
+	/* Acceptor connection request */
+	BUILD_BUG_ON(LNET_PROTO_ACCEPTOR_VERSION != 1);
+
+	/* Checks for struct lnet_acceptor_connreq */
+	BUILD_BUG_ON((int)sizeof(struct lnet_acceptor_connreq) != 16);
+	BUILD_BUG_ON((int)offsetof(struct lnet_acceptor_connreq, acr_magic) != 0);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_acceptor_connreq *)0)->acr_magic) != 4);
+	BUILD_BUG_ON((int)offsetof(struct lnet_acceptor_connreq, acr_version) != 4);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_acceptor_connreq *)0)->acr_version) != 4);
+	BUILD_BUG_ON((int)offsetof(struct lnet_acceptor_connreq, acr_nid) != 8);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_acceptor_connreq *)0)->acr_nid) != 8);
+
+	/* Checks for struct lnet_counters_common */
+	BUILD_BUG_ON((int)sizeof(struct lnet_counters_common) != 60);
+	BUILD_BUG_ON((int)offsetof(struct lnet_counters_common, lcc_msgs_alloc) != 0);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_counters_common *)0)->lcc_msgs_alloc) != 4);
+	BUILD_BUG_ON((int)offsetof(struct lnet_counters_common, lcc_msgs_max) != 4);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_counters_common *)0)->lcc_msgs_max) != 4);
+	BUILD_BUG_ON((int)offsetof(struct lnet_counters_common, lcc_errors) != 8);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_counters_common *)0)->lcc_errors) != 4);
+	BUILD_BUG_ON((int)offsetof(struct lnet_counters_common, lcc_send_count) != 12);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_counters_common *)0)->lcc_send_count) != 4);
+	BUILD_BUG_ON((int)offsetof(struct lnet_counters_common, lcc_recv_count) != 16);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_counters_common *)0)->lcc_recv_count) != 4);
+	BUILD_BUG_ON((int)offsetof(struct lnet_counters_common, lcc_route_count) != 20);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_counters_common *)0)->lcc_route_count) != 4);
+	BUILD_BUG_ON((int)offsetof(struct lnet_counters_common, lcc_drop_count) != 24);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_counters_common *)0)->lcc_drop_count) != 4);
+	BUILD_BUG_ON((int)offsetof(struct lnet_counters_common, lcc_send_length) != 28);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_counters_common *)0)->lcc_send_length) != 8);
+	BUILD_BUG_ON((int)offsetof(struct lnet_counters_common, lcc_recv_length) != 36);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_counters_common *)0)->lcc_recv_length) != 8);
+	BUILD_BUG_ON((int)offsetof(struct lnet_counters_common, lcc_route_length) != 44);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_counters_common *)0)->lcc_route_length) != 8);
+	BUILD_BUG_ON((int)offsetof(struct lnet_counters_common, lcc_drop_length) != 52);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_counters_common *)0)->lcc_drop_length) != 8);
 }
 
 static struct lnet_lnd *
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
