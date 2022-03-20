Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id C4951C433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:32:14 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id F291B21F988;
	Sun, 20 Mar 2022 06:31:46 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 673A921EB66
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:15 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 3534CEEC;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 31880D5A47; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:36 -0400
Message-Id: <1647783064-20688-23-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 22/50] lnet: socklnd: Change ksock_hello_msg
 to struct lnet_nid
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

From: Mr NeilBrown <neilb@suse.de>

'struct ksock_hello_msg' now stores 'struct lnet_nid', but it is
converted to 'struct ksock_hello_msg_nid4' - the old format - for
transmit, which is converted back on receive.

This opens the way for a new version of the hello protocol
which will use 16byte addresses.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: d1fb459cca931f84f ("LU-10391 socklnd: Change ksock_hello_msg to struct lnet_nid")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/43610
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/socklnd.h           | 24 +++++++++---
 net/lnet/klnds/socklnd/socklnd.c       | 35 ++++++++---------
 net/lnet/klnds/socklnd/socklnd.h       |  5 ++-
 net/lnet/klnds/socklnd/socklnd_cb.c    | 33 ++++++++--------
 net/lnet/klnds/socklnd/socklnd_proto.c | 70 +++++++++++++++++++++++++++-------
 5 files changed, 110 insertions(+), 57 deletions(-)

diff --git a/include/linux/lnet/socklnd.h b/include/linux/lnet/socklnd.h
index 025112b..ddfcf76 100644
--- a/include/linux/lnet/socklnd.h
+++ b/include/linux/lnet/socklnd.h
@@ -39,17 +39,31 @@
 #include <uapi/linux/lnet/socklnd.h>
 
 struct ksock_hello_msg {
-	u32		kshm_magic;	/* magic number of socklnd message */
-	u32		kshm_version;	/* version of socklnd message */
+	u32		kshm_magic;	/* LNET_PROTO_MAGIC */
+	u32		kshm_version;	/* KSOCK_PROTO_V* */
+	struct lnet_nid	kshm_src_nid;	/* sender's nid */
+	struct lnet_nid	kshm_dst_nid;	/* destination nid */
+	lnet_pid_t	kshm_src_pid;	/* sender's pid */
+	lnet_pid_t	kshm_dst_pid;   /* destination pid */
+	u64		kshm_src_incarnation; /* sender's incarnation */
+	u64		kshm_dst_incarnation; /* destination's incarnation */
+	u32		kshm_ctype;	/* SOCKLND_CONN_* */
+	u32		kshm_nips;	/* always sent as zero */
+	u32		kshm_ips[0];	/* deprecated */
+} __packed;
+
+struct ksock_hello_msg_nid4 {
+	u32		kshm_magic;	/* LNET_PROTO_MAGIC */
+	u32		kshm_version;	/* KSOCK_PROTO_V* */
 	lnet_nid_t	kshm_src_nid;	/* sender's nid */
 	lnet_nid_t	kshm_dst_nid;	/* destination nid */
 	lnet_pid_t	kshm_src_pid;	/* sender's pid */
 	lnet_pid_t	kshm_dst_pid;	/* destination pid */
 	u64		kshm_src_incarnation; /* sender's incarnation */
 	u64		kshm_dst_incarnation; /* destination's incarnation */
-	u32		kshm_ctype;	/* connection type */
-	u32		kshm_nips;	/* # IP addrs */
-	u32		kshm_ips[0];	/* IP addrs */
+	u32		kshm_ctype;	/* SOCKLND_CONN_* */
+	u32		kshm_nips;	/* sent as zero */
+	u32		kshm_ips[0];	/* deprecated */
 } __packed;
 
 struct ksock_msg_hdr {
diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index e3201d1..4267832 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -854,7 +854,7 @@ struct ksock_peer_ni *
 {
 	rwlock_t *global_lock = &ksocknal_data.ksnd_global_lock;
 	LIST_HEAD(zombies);
-	struct lnet_process_id peerid4;
+	struct lnet_processid peerid;
 	u64 incarnation;
 	struct ksock_conn *conn;
 	struct ksock_conn *conn2;
@@ -928,7 +928,7 @@ struct ksock_peer_ni *
 
 		/* Active connection sends HELLO eagerly */
 		hello->kshm_nips =  0;
-		peerid4 = lnet_pid_to_pid4(&peer_ni->ksnp_id);
+		peerid = peer_ni->ksnp_id;
 
 		write_lock_bh(global_lock);
 		conn->ksnc_proto = peer_ni->ksnp_proto;
@@ -944,34 +944,31 @@ struct ksock_peer_ni *
 #endif
 		}
 
-		rc = ksocknal_send_hello(ni, conn, peerid4.nid, hello);
+		rc = ksocknal_send_hello(ni, conn, &peerid.nid, hello);
 		if (rc)
 			goto failed_1;
 	} else {
-		peerid4.nid = LNET_NID_ANY;
-		peerid4.pid = LNET_PID_ANY;
+		peerid.nid = LNET_ANY_NID;
+		peerid.pid = LNET_PID_ANY;
 
 		/* Passive, get protocol from peer_ni */
 		conn->ksnc_proto = NULL;
 	}
 
-	rc = ksocknal_recv_hello(ni, conn, hello, &peerid4, &incarnation);
+	rc = ksocknal_recv_hello(ni, conn, hello, &peerid, &incarnation);
 	if (rc < 0)
 		goto failed_1;
 
 	LASSERT(!rc || active);
 	LASSERT(conn->ksnc_proto);
-	LASSERT(peerid4.nid != LNET_NID_ANY);
+	LASSERT(!LNET_NID_IS_ANY(&peerid.nid));
 
-	cpt = lnet_cpt_of_nid(peerid4.nid, ni);
+	cpt = lnet_nid2cpt(&peerid.nid, ni);
 
 	if (active) {
 		ksocknal_peer_addref(peer_ni);
 		write_lock_bh(global_lock);
 	} else {
-		struct lnet_processid peerid;
-
-		lnet_pid4_to_pid(peerid4, &peerid);
 		peer_ni = ksocknal_create_peer(ni, &peerid);
 		if (IS_ERR(peer_ni)) {
 			rc = PTR_ERR(peer_ni);
@@ -1004,7 +1001,7 @@ struct ksock_peer_ni *
 		 * Am I already connecting to this guy?  Resolve in
 		 * favour of higher NID...
 		 */
-		if (peerid4.nid < lnet_nid_to_nid4(&ni->ni_nid) &&
+		if (memcmp(&peerid.nid, &ni->ni_nid, sizeof(peerid.nid)) < 0 &&
 		    ksocknal_connecting(peer_ni->ksnp_conn_cb,
 					((struct sockaddr *)&conn->ksnc_peeraddr))) {
 			rc = EALREADY;
@@ -1164,9 +1161,7 @@ struct ksock_peer_ni *
 	}
 
 	write_unlock_bh(global_lock);
-
-	/*
-	 * We've now got a new connection.  Any errors from here on are just
+	/* We've now got a new connection.  Any errors from here on are just
 	 * like "normal" comms errors and we close the connection normally.
 	 * NB (a) we still have to send the reply HELLO for passive
 	 *	connections,
@@ -1175,13 +1170,13 @@ struct ksock_peer_ni *
 	 */
 	CDEBUG(D_NET,
 	       "New conn %s p %d.x %pIS -> %pISp incarnation:%lld sched[%d]\n",
-	       libcfs_id2str(peerid4), conn->ksnc_proto->pro_version,
+	       libcfs_idstr(&peerid), conn->ksnc_proto->pro_version,
 	       &conn->ksnc_myaddr, &conn->ksnc_peeraddr,
 	       incarnation, cpt);
 
 	if (!active) {
 		hello->kshm_nips = 0;
-		rc = ksocknal_send_hello(ni, conn, peerid4.nid, hello);
+		rc = ksocknal_send_hello(ni, conn, &peerid.nid, hello);
 	}
 
 	kvfree(hello);
@@ -1237,10 +1232,10 @@ struct ksock_peer_ni *
 	if (warn) {
 		if (rc < 0)
 			CERROR("Not creating conn %s type %d: %s\n",
-			       libcfs_id2str(peerid4), conn->ksnc_type, warn);
+			       libcfs_idstr(&peerid), conn->ksnc_type, warn);
 		else
 			CDEBUG(D_NET, "Not creating conn %s type %d: %s\n",
-			       libcfs_id2str(peerid4), conn->ksnc_type, warn);
+			       libcfs_idstr(&peerid), conn->ksnc_type, warn);
 	}
 
 	if (!active) {
@@ -1251,7 +1246,7 @@ struct ksock_peer_ni *
 			 */
 			conn->ksnc_type = SOCKLND_CONN_NONE;
 			hello->kshm_nips = 0;
-			ksocknal_send_hello(ni, conn, peerid4.nid, hello);
+			ksocknal_send_hello(ni, conn, &peerid.nid, hello);
 		}
 
 		write_lock_bh(global_lock);
diff --git a/net/lnet/klnds/socklnd/socklnd.h b/net/lnet/klnds/socklnd/socklnd.h
index bd38ee2..094f635 100644
--- a/net/lnet/klnds/socklnd/socklnd.h
+++ b/net/lnet/klnds/socklnd/socklnd.h
@@ -674,10 +674,11 @@ struct ksock_conn_cb *
 int ksocknal_connd(void *arg);
 int ksocknal_reaper(void *arg);
 int ksocknal_send_hello(struct lnet_ni *ni, struct ksock_conn *conn,
-			lnet_nid_t peer_nid, struct ksock_hello_msg *hello);
+			struct lnet_nid *peer_nid,
+			struct ksock_hello_msg *hello);
 int ksocknal_recv_hello(struct lnet_ni *ni, struct ksock_conn *conn,
 			struct ksock_hello_msg *hello,
-			struct lnet_process_id *id,
+			struct lnet_processid *id,
 			u64 *incarnation);
 void ksocknal_read_callback(struct ksock_conn *conn);
 void ksocknal_write_callback(struct ksock_conn *conn);
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index 822de50..c93f43f 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -1580,7 +1580,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 
 int
 ksocknal_send_hello(struct lnet_ni *ni, struct ksock_conn *conn,
-		    lnet_nid_t peer_nid, struct ksock_hello_msg *hello)
+		    struct lnet_nid *peer_nid, struct ksock_hello_msg *hello)
 {
 	/* CAVEAT EMPTOR: this byte flips 'ipaddrs' */
 	struct ksock_net *net = (struct ksock_net *)ni->ni_data;
@@ -1590,8 +1590,8 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	/* rely on caller to hold a ref on socket so it wouldn't disappear */
 	LASSERT(conn->ksnc_proto);
 
-	hello->kshm_src_nid = lnet_nid_to_nid4(&ni->ni_nid);
-	hello->kshm_dst_nid = peer_nid;
+	hello->kshm_src_nid = ni->ni_nid;
+	hello->kshm_dst_nid = *peer_nid;
 	hello->kshm_src_pid = the_lnet.ln_pid;
 
 	hello->kshm_src_incarnation = net->ksnn_incarnation;
@@ -1619,7 +1619,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 int
 ksocknal_recv_hello(struct lnet_ni *ni, struct ksock_conn *conn,
 		    struct ksock_hello_msg *hello,
-		    struct lnet_process_id *peerid,
+		    struct lnet_processid *peerid,
 		    u64 *incarnation)
 {
 	/* Return < 0	fatal error
@@ -1633,7 +1633,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	int proto_match;
 	int rc;
 	const struct ksock_proto *proto;
-	struct lnet_process_id recv_id;
+	struct lnet_processid recv_id;
 
 	/* socket type set on active connections - not set on passive */
 	LASSERT(!active == !(conn->ksnc_type != SOCKLND_CONN_NONE));
@@ -1683,8 +1683,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 				conn->ksnc_proto = &ksocknal_protocol_v1x;
 #endif
 			hello->kshm_nips = 0;
-			ksocknal_send_hello(ni, conn,
-					    lnet_nid_to_nid4(&ni->ni_nid),
+			ksocknal_send_hello(ni, conn, &ni->ni_nid,
 					    hello);
 		}
 
@@ -1709,7 +1708,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 
 	*incarnation = hello->kshm_src_incarnation;
 
-	if (hello->kshm_src_nid == LNET_NID_ANY) {
+	if (LNET_NID_IS_ANY(&hello->kshm_src_nid)) {
 		CERROR("Expecting a HELLO hdr with a NID, but got LNET_NID_ANY from %pIS\n",
 		       &conn->ksnc_peeraddr);
 		return -EPROTO;
@@ -1722,9 +1721,11 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 		recv_id.pid = rpc_get_port((struct sockaddr *)
 					   &conn->ksnc_peeraddr) |
 					   LNET_PID_USERFLAG;
-		recv_id.nid = LNET_MKNID(LNET_NID_NET(&ni->ni_nid),
-					 ntohl(((struct sockaddr_in *)
-					 &conn->ksnc_peeraddr)->sin_addr.s_addr));
+		memset(&recv_id.nid, 0, sizeof(recv_id.nid));
+		recv_id.nid.nid_type = ni->ni_nid.nid_type;
+		recv_id.nid.nid_num = ni->ni_nid.nid_num;
+		recv_id.nid.nid_addr[0] =
+			((struct sockaddr_in *)&conn->ksnc_peeraddr)->sin_addr.s_addr;
 	} else {
 		recv_id.nid = hello->kshm_src_nid;
 		recv_id.pid = hello->kshm_src_pid;
@@ -1737,7 +1738,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 		conn->ksnc_type = ksocknal_invert_type(hello->kshm_ctype);
 		if (conn->ksnc_type == SOCKLND_CONN_NONE) {
 			CERROR("Unexpected type %d from %s ip %pIS\n",
-			       hello->kshm_ctype, libcfs_id2str(*peerid),
+			       hello->kshm_ctype, libcfs_idstr(peerid),
 			       &conn->ksnc_peeraddr);
 			return -EPROTO;
 		}
@@ -1746,12 +1747,12 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	}
 
 	if (peerid->pid != recv_id.pid ||
-	    peerid->nid != recv_id.nid) {
+	    !nid_same(&peerid->nid,  &recv_id.nid)) {
 		LCONSOLE_ERROR_MSG(0x130,
 				   "Connected successfully to %s on host %pIS, but they claimed they were %s; please check your Lustre configuration.\n",
-				   libcfs_id2str(*peerid),
+				   libcfs_idstr(peerid),
 				   &conn->ksnc_peeraddr,
-				   libcfs_id2str(recv_id));
+				   libcfs_idstr(&recv_id));
 		return -EPROTO;
 	}
 
@@ -1762,7 +1763,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 
 	if (ksocknal_invert_type(hello->kshm_ctype) != conn->ksnc_type) {
 		CERROR("Mismatched types: me %d, %s ip %pIS %d\n",
-		       conn->ksnc_type, libcfs_id2str(*peerid),
+		       conn->ksnc_type, libcfs_idstr(peerid),
 		       &conn->ksnc_peeraddr, hello->kshm_ctype);
 		return -EPROTO;
 	}
diff --git a/net/lnet/klnds/socklnd/socklnd_proto.c b/net/lnet/klnds/socklnd/socklnd_proto.c
index 14b1394..783c62f 100644
--- a/net/lnet/klnds/socklnd/socklnd_proto.c
+++ b/net/lnet/klnds/socklnd/socklnd_proto.c
@@ -493,7 +493,7 @@
 			hmv->magic = LNET_PROTO_MAGIC;
 	}
 
-	hdr->src_nid = cpu_to_le64(hello->kshm_src_nid);
+	hdr->src_nid = cpu_to_le64(lnet_nid_to_nid4(&hello->kshm_src_nid));
 	hdr->src_pid = cpu_to_le32(hello->kshm_src_pid);
 	hdr->type = cpu_to_le32(LNET_MSG_HELLO);
 	hdr->payload_length = cpu_to_le32(hello->kshm_nips * sizeof(u32));
@@ -531,19 +531,49 @@
 ksocknal_send_hello_v2(struct ksock_conn *conn, struct ksock_hello_msg *hello)
 {
 	struct socket *sock = conn->ksnc_sock;
+	struct ksock_hello_msg_nid4 *hello4;
 	int rc;
 
+	hello4 = kzalloc(sizeof(*hello4), GFP_NOFS);
+	if (!hello4) {
+		CERROR("Can't allocate struct ksock_hello_msg_nid4\n");
+		return -ENOMEM;
+	}
+
 	hello->kshm_magic = LNET_PROTO_MAGIC;
 	hello->kshm_version = conn->ksnc_proto->pro_version;
 
+	hello4->kshm_magic = LNET_PROTO_MAGIC;
+	hello4->kshm_version = conn->ksnc_proto->pro_version;
+	hello4->kshm_src_nid = lnet_nid_to_nid4(&hello->kshm_src_nid);
+	hello4->kshm_dst_nid = lnet_nid_to_nid4(&hello->kshm_dst_nid);
+	hello4->kshm_src_pid = hello->kshm_src_pid;
+	hello4->kshm_dst_pid = hello->kshm_dst_pid;
+	hello4->kshm_src_incarnation = hello->kshm_src_incarnation;
+	hello4->kshm_dst_incarnation = hello->kshm_dst_incarnation;
+	hello4->kshm_ctype = hello->kshm_ctype;
+	hello4->kshm_nips = hello->kshm_nips;
+
 	if (the_lnet.ln_testprotocompat) {
 		/* single-shot proto check */
 		if (test_and_clear_bit(0, &the_lnet.ln_testprotocompat))
 			hello->kshm_version++;   /* just different! */
 	}
 
-	rc = lnet_sock_write(sock, hello, offsetof(struct ksock_hello_msg, kshm_ips),
+	hello4->kshm_magic = LNET_PROTO_MAGIC;
+	hello4->kshm_version = hello->kshm_version;
+	hello4->kshm_src_nid = lnet_nid_to_nid4(&hello->kshm_src_nid);
+	hello4->kshm_dst_nid = lnet_nid_to_nid4(&hello->kshm_dst_nid);
+	hello4->kshm_src_pid = hello->kshm_src_pid;
+	hello4->kshm_dst_pid = hello->kshm_dst_pid;
+	hello4->kshm_src_incarnation = hello->kshm_src_incarnation;
+	hello4->kshm_dst_incarnation = hello->kshm_dst_incarnation;
+	hello4->kshm_ctype = hello->kshm_ctype;
+	hello4->kshm_nips = hello->kshm_nips;
+
+	rc = lnet_sock_write(sock, hello4, sizeof(*hello4),
 			     lnet_acceptor_timeout());
+	kfree(hello4);
 	if (rc) {
 		CNETERR("Error %d sending HELLO hdr to %pISp\n",
 			rc, &conn->ksnc_peeraddr);
@@ -600,7 +630,7 @@
 		goto out;
 	}
 
-	hello->kshm_src_nid = le64_to_cpu(hdr->src_nid);
+	lnet_nid4_to_nid(le64_to_cpu(hdr->src_nid), &hello->kshm_src_nid);
 	hello->kshm_src_pid = le32_to_cpu(hdr->src_pid);
 	hello->kshm_src_incarnation = le64_to_cpu(hdr->msg.hello.incarnation);
 	hello->kshm_ctype = le32_to_cpu(hdr->msg.hello.type);
@@ -646,6 +676,7 @@
 		       int timeout)
 {
 	struct socket *sock = conn->ksnc_sock;
+	struct ksock_hello_msg_nid4 *hello4 = (void *)hello;
 	int rc;
 	int i;
 
@@ -654,9 +685,9 @@
 	else
 		conn->ksnc_flip = 1;
 
-	rc = lnet_sock_read(sock, &hello->kshm_src_nid,
-			    offsetof(struct ksock_hello_msg, kshm_ips) -
-				     offsetof(struct ksock_hello_msg, kshm_src_nid),
+	rc = lnet_sock_read(sock, &hello4->kshm_src_nid,
+			    offsetof(struct ksock_hello_msg_nid4, kshm_ips) -
+			    offsetof(struct ksock_hello_msg_nid4, kshm_src_nid),
 			    timeout);
 	if (rc) {
 		CERROR("Error %d reading HELLO from %pIS\n",
@@ -666,14 +697,25 @@
 	}
 
 	if (conn->ksnc_flip) {
-		__swab32s(&hello->kshm_src_pid);
-		__swab64s(&hello->kshm_src_nid);
-		__swab32s(&hello->kshm_dst_pid);
-		__swab64s(&hello->kshm_dst_nid);
-		__swab64s(&hello->kshm_src_incarnation);
-		__swab64s(&hello->kshm_dst_incarnation);
-		__swab32s(&hello->kshm_ctype);
-		__swab32s(&hello->kshm_nips);
+		/* These must be copied in reverse order to avoid corruption. */
+		hello->kshm_nips = __swab32(hello4->kshm_nips);
+		hello->kshm_ctype = __swab32(hello4->kshm_ctype);
+		hello->kshm_dst_incarnation = __swab64(hello4->kshm_dst_incarnation);
+		hello->kshm_src_incarnation = __swab64(hello4->kshm_src_incarnation);
+		hello->kshm_dst_pid = __swab32(hello4->kshm_dst_pid);
+		hello->kshm_src_pid = __swab32(hello4->kshm_src_pid);
+		lnet_nid4_to_nid(hello4->kshm_dst_nid, &hello->kshm_dst_nid);
+		lnet_nid4_to_nid(hello4->kshm_src_nid, &hello->kshm_src_nid);
+	} else {
+		/* These must be copied in reverse order to avoid corruption. */
+		hello->kshm_nips = hello4->kshm_nips;
+		hello->kshm_ctype = hello4->kshm_ctype;
+		hello->kshm_dst_incarnation = hello4->kshm_dst_incarnation;
+		hello->kshm_src_incarnation = hello4->kshm_src_incarnation;
+		hello->kshm_dst_pid = hello4->kshm_dst_pid;
+		hello->kshm_src_pid = hello4->kshm_src_pid;
+		lnet_nid4_to_nid(hello4->kshm_dst_nid, &hello->kshm_dst_nid);
+		lnet_nid4_to_nid(hello4->kshm_src_nid, &hello->kshm_src_nid);
 	}
 
 	if (hello->kshm_nips > LNET_INTERFACES_NUM) {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
