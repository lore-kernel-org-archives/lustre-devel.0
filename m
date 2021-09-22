Return-Path: <SRS0=2ypu=OM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59A26C433FE
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:21:42 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 1EFCD610A1
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:21:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 1EFCD610A1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 5649121F2D7;
	Tue, 21 Sep 2021 19:21:41 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id CD63D21F17C
 for <lustre-devel@lists.lustre.org>; Tue, 21 Sep 2021 19:20:08 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 1A340369;
 Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 16C17FF4BC; Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Tue, 21 Sep 2021 22:19:47 -0400
Message-Id: <1632277201-6920-11-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
References: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 10/24] lnet: enhance connect/accept to
 support large addr
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

This patch introduces a version-2 of the acceptor protocol.  This
version uses a 'struct lnet_nid' rather than 'lnet_nid_t'

lnet_connect() now accepts a struct lnet_nid and uses version 2 if
necessary.  lnet_accept() accepts either v1 or v2.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 9b0738c53c962f426 ("LU-10391 lnet: enhance connect/accept to support large addr")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/42105
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h       |   5 +-
 include/uapi/linux/lnet/lnet-idl.h  |  11 +++-
 net/lnet/klnds/socklnd/socklnd_cb.c |   8 +--
 net/lnet/lnet/acceptor.c            | 111 +++++++++++++++++++++++-------------
 net/lnet/lnet/api-ni.c              |   9 +++
 5 files changed, 97 insertions(+), 47 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 3842976..9e7d0b8 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -489,6 +489,7 @@ unsigned int lnet_nid_cpt_hash(struct lnet_nid *nid,
 struct lnet_ni *lnet_nid2ni_addref(lnet_nid_t nid);
 struct lnet_ni *lnet_net2ni_locked(u32 net, int cpt);
 struct lnet_ni *lnet_net2ni_addref(u32 net);
+struct lnet_ni *lnet_nid_to_ni_addref(struct lnet_nid *nid);
 struct lnet_net *lnet_get_net_locked(u32 net_id);
 
 extern unsigned int lnet_response_tracking;
@@ -742,9 +743,9 @@ void lnet_copy_kiov2iter(struct iov_iter *to,
 void lnet_register_lnd(struct lnet_lnd *lnd);
 void lnet_unregister_lnd(struct lnet_lnd *lnd);
 
-struct socket *lnet_connect(lnet_nid_t peer_nid, int interface,
+struct socket *lnet_connect(struct lnet_nid *peer_nid, int interface,
 			    struct sockaddr *peeraddr, struct net *ns);
-void lnet_connect_console_error(int rc, lnet_nid_t peer_nid,
+void lnet_connect_console_error(int rc, struct lnet_nid *peer_nid,
 				struct sockaddr *sa);
 int lnet_count_acceptor_nets(void);
 int lnet_acceptor_timeout(void);
diff --git a/include/uapi/linux/lnet/lnet-idl.h b/include/uapi/linux/lnet/lnet-idl.h
index 3fc0df1..b14723e 100644
--- a/include/uapi/linux/lnet/lnet-idl.h
+++ b/include/uapi/linux/lnet/lnet-idl.h
@@ -191,13 +191,22 @@ struct lnet_magicversion {
 
 /* Acceptor connection request */
 struct lnet_acceptor_connreq {
-	__u32	acr_magic;	/* PTL_ACCEPTOR_PROTO_MAGIC */
+	__u32	acr_magic;	/* LNET_PROTO_ACCEPTOR_MAGIC */
 	__u32	acr_version;	/* protocol version */
 	__u64	acr_nid;	/* target NID */
 } __attribute__((packed));
 
 #define LNET_PROTO_ACCEPTOR_VERSION	1
 
+struct lnet_acceptor_connreq_v2 {
+	__u32			acr_magic;	/* LNET_PROTO_ACCEPTOR_MAGIC */
+	__u32			acr_version;	/* protocol version - 2 */
+	struct lnet_nid		acr_nid;	/* target NID */
+} __attribute__((packed));
+
+/* For use with 16-byte addresses */
+#define LNET_PROTO_ACCEPTOR_VERSION_16  2
+
 struct lnet_counters_common {
 	__u32	lcc_msgs_alloc;
 	__u32	lcc_msgs_max;
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index a2298275..edc584a 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -1833,13 +1833,12 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 
 		if (ktime_get_seconds() >= deadline) {
 			rc = -ETIMEDOUT;
-			lnet_connect_console_error(rc,
-						   lnet_nid_to_nid4(&peer_ni->ksnp_id.nid),
+			lnet_connect_console_error(rc, &peer_ni->ksnp_id.nid,
 						   (struct sockaddr *)&conn_cb->ksnr_addr);
 			goto failed;
 		}
 
-		sock = lnet_connect(lnet_nid_to_nid4(&peer_ni->ksnp_id.nid),
+		sock = lnet_connect(&peer_ni->ksnp_id.nid,
 				    conn_cb->ksnr_myiface,
 				    (struct sockaddr *)&conn_cb->ksnr_addr,
 				    peer_ni->ksnp_ni->ni_net_ns);
@@ -1851,8 +1850,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 		rc = ksocknal_create_conn(peer_ni->ksnp_ni, conn_cb, sock,
 					  type);
 		if (rc < 0) {
-			lnet_connect_console_error(rc,
-						   lnet_nid_to_nid4(&peer_ni->ksnp_id.nid),
+			lnet_connect_console_error(rc, &peer_ni->ksnp_id.nid,
 						   (struct sockaddr *)&conn_cb->ksnr_addr);
 			goto failed;
 		}
diff --git a/net/lnet/lnet/acceptor.c b/net/lnet/lnet/acceptor.c
index 243c34f..2306760 100644
--- a/net/lnet/lnet/acceptor.c
+++ b/net/lnet/lnet/acceptor.c
@@ -85,54 +85,58 @@
 EXPORT_SYMBOL(lnet_acceptor_timeout);
 
 void
-lnet_connect_console_error(int rc, lnet_nid_t peer_nid,
+lnet_connect_console_error(int rc, struct lnet_nid *peer_nid,
 			   struct sockaddr *sa)
 {
 	switch (rc) {
 	/* "normal" errors */
 	case -ECONNREFUSED:
 		CNETERR("Connection to %s at host %pISp was refused: check that Lustre is running on that node.\n",
-			libcfs_nid2str(peer_nid), sa);
+			libcfs_nidstr(peer_nid), sa);
 		break;
 	case -EHOSTUNREACH:
 	case -ENETUNREACH:
 		CNETERR("Connection to %s at host %pIS was unreachable: the network or that node may be down, or Lustre may be misconfigured.\n",
-			libcfs_nid2str(peer_nid), sa);
+			libcfs_nidstr(peer_nid), sa);
 		break;
 	case -ETIMEDOUT:
 		CNETERR("Connection to %s at host %pISp took too long: that node may be hung or experiencing high load.\n",
-			libcfs_nid2str(peer_nid), sa);
+			libcfs_nidstr(peer_nid), sa);
 		break;
 	case -ECONNRESET:
 		LCONSOLE_ERROR_MSG(0x11b,
 				   "Connection to %s at host %pISp was reset: is it running a compatible version of Lustre and is %s one of its NIDs?\n",
-				   libcfs_nid2str(peer_nid), sa,
-				   libcfs_nid2str(peer_nid));
+				   libcfs_nidstr(peer_nid), sa,
+				   libcfs_nidstr(peer_nid));
 		break;
 	case -EPROTO:
 		LCONSOLE_ERROR_MSG(0x11c,
 				   "Protocol error connecting to %s at host %pISp: is it running a compatible version of Lustre?\n",
-				   libcfs_nid2str(peer_nid), sa);
+				   libcfs_nidstr(peer_nid), sa);
 		break;
 	case -EADDRINUSE:
 		LCONSOLE_ERROR_MSG(0x11d,
 				   "No privileged ports available to connect to %s at host %pISp\n",
-				   libcfs_nid2str(peer_nid), sa);
+				   libcfs_nidstr(peer_nid), sa);
 		break;
 	default:
 		LCONSOLE_ERROR_MSG(0x11e,
 				   "Unexpected error %d connecting to %s at host %pISp\n",
-				   rc, libcfs_nid2str(peer_nid), sa);
+				   rc, libcfs_nidstr(peer_nid), sa);
 		break;
 	}
 }
 EXPORT_SYMBOL(lnet_connect_console_error);
 
 struct socket *
-lnet_connect(lnet_nid_t peer_nid, int interface, struct sockaddr *peeraddr,
+lnet_connect(struct lnet_nid *peer_nid, int interface,
+	     struct sockaddr *peeraddr,
 	     struct net *ns)
 {
-	struct lnet_acceptor_connreq cr;
+	struct lnet_acceptor_connreq cr1;
+	struct lnet_acceptor_connreq_v2 cr2;
+	void *cr;
+	int crsize;
 	struct socket *sock;
 	int rc;
 	int port;
@@ -156,20 +160,30 @@ struct socket *
 
 		BUILD_BUG_ON(LNET_PROTO_ACCEPTOR_VERSION != 1);
 
-		cr.acr_magic = LNET_PROTO_ACCEPTOR_MAGIC;
-		cr.acr_version = LNET_PROTO_ACCEPTOR_VERSION;
-		cr.acr_nid = peer_nid;
+		if (nid_is_nid4(peer_nid)) {
+			cr1.acr_magic = LNET_PROTO_ACCEPTOR_MAGIC;
+			cr1.acr_version = LNET_PROTO_ACCEPTOR_VERSION;
+			cr1.acr_nid = lnet_nid_to_nid4(peer_nid);
+			cr = &cr1;
+			crsize = sizeof(cr1);
 
-		if (the_lnet.ln_testprotocompat) {
-			/* single-shot proto check */
-			if (test_and_clear_bit(2, &the_lnet.ln_testprotocompat))
-				cr.acr_version++;
+			if (the_lnet.ln_testprotocompat) {
+				/* single-shot proto check */
+				if (test_and_clear_bit(2, &the_lnet.ln_testprotocompat))
+					cr1.acr_version++;
 
-			if (test_and_clear_bit(3, &the_lnet.ln_testprotocompat))
-				cr.acr_magic = LNET_PROTO_MAGIC;
+				if (test_and_clear_bit(3, &the_lnet.ln_testprotocompat))
+					cr1.acr_magic = LNET_PROTO_MAGIC;
+			}
+		} else {
+			cr2.acr_magic = LNET_PROTO_ACCEPTOR_MAGIC;
+			cr2.acr_version = LNET_PROTO_ACCEPTOR_VERSION_16;
+			cr2.acr_nid = *peer_nid;
+			cr = &cr2;
+			crsize = sizeof(cr2);
 		}
 
-		rc = lnet_sock_write(sock, &cr, sizeof(cr), accept_timeout);
+		rc = lnet_sock_write(sock, cr, crsize, accept_timeout);
 		if (rc)
 			goto failed_sock;
 
@@ -191,7 +205,10 @@ struct socket *
 lnet_accept(struct socket *sock, u32 magic)
 {
 	struct lnet_acceptor_connreq cr;
+	struct lnet_acceptor_connreq_v2 cr2;
+	struct lnet_nid nid;
 	struct sockaddr_storage peer;
+	int peer_version;
 	int rc;
 	int flip;
 	struct lnet_ni *ni;
@@ -249,14 +266,14 @@ struct socket *
 	if (flip)
 		__swab32s(&cr.acr_version);
 
-	if (cr.acr_version != LNET_PROTO_ACCEPTOR_VERSION) {
-		/*
-		 * future version compatibility!
+	switch (cr.acr_version) {
+	default:
+		/* future version compatibility!
 		 * An acceptor-specific protocol rev will first send a version
 		 * query.  I send back my current version to tell her I'm
 		 * "old".
 		 */
-		int peer_version = cr.acr_version;
+		peer_version = cr.acr_version;
 
 		memset(&cr, 0, sizeof(cr));
 		cr.acr_magic = LNET_PROTO_ACCEPTOR_MAGIC;
@@ -267,30 +284,47 @@ struct socket *
 			CERROR("Error sending magic+version in response to version %d from %pIS: %d\n",
 			       peer_version, &peer, rc);
 		return -EPROTO;
-	}
 
-	rc = lnet_sock_read(sock, &cr.acr_nid,
-			    sizeof(cr) -
-			    offsetof(struct lnet_acceptor_connreq, acr_nid),
-			    accept_timeout);
+	case LNET_PROTO_ACCEPTOR_VERSION:
+		rc = lnet_sock_read(sock, &cr.acr_nid,
+				    sizeof(cr) -
+				    offsetof(struct lnet_acceptor_connreq,
+					     acr_nid),
+				    accept_timeout);
+		if (rc)
+			break;
+		if (flip)
+			__swab64s(&cr.acr_nid);
+
+		lnet_nid4_to_nid(cr.acr_nid, &nid);
+		break;
+
+	case LNET_PROTO_ACCEPTOR_VERSION_16:
+		rc = lnet_sock_read(sock, &cr2.acr_nid,
+				    sizeof(cr2) -
+				    offsetof(struct lnet_acceptor_connreq_v2,
+					     acr_nid),
+				    accept_timeout);
+		if (rc)
+			break;
+		nid = cr2.acr_nid;
+		break;
+	}
 	if (rc) {
 		CERROR("Error %d reading connection request from %pIS\n",
 		       rc, &peer);
 		return -EIO;
 	}
 
-	if (flip)
-		__swab64s(&cr.acr_nid);
-
-	ni = lnet_nid2ni_addref(cr.acr_nid);
+	ni = lnet_nid_to_ni_addref(&nid);
 	if (!ni ||			/* no matching net */
-	    lnet_nid_to_nid4(&ni->ni_nid) != cr.acr_nid) {
+	    !nid_same(&ni->ni_nid, &nid)) {
 		/* right NET, wrong NID! */
 		if (ni)
 			lnet_ni_decref(ni);
 		LCONSOLE_ERROR_MSG(0x120,
 				   "Refusing connection from %pIS for %s: No matching NI\n",
-				   &peer, libcfs_nid2str(cr.acr_nid));
+				   &peer, libcfs_nidstr(&nid));
 		return -EPERM;
 	}
 
@@ -299,12 +333,11 @@ struct socket *
 		lnet_ni_decref(ni);
 		LCONSOLE_ERROR_MSG(0x121,
 				   "Refusing connection from %pIS for %s: NI doesn not accept IP connections\n",
-				   &peer, libcfs_nid2str(cr.acr_nid));
+				   &peer, libcfs_nidstr(&nid));
 		return -EPERM;
 	}
 
-	CDEBUG(D_NET, "Accept %s from %pIS\n",
-	       libcfs_nid2str(cr.acr_nid), &peer);
+	CDEBUG(D_NET, "Accept %s from %pIS\n", libcfs_nidstr(&nid), &peer);
 
 	rc = ni->ni_net->net_lnd->lnd_accept(ni, sock);
 
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 1f053b3..31ccb2c 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -810,6 +810,15 @@ static void lnet_assert_wire_constants(void)
 	BUILD_BUG_ON((int)offsetof(struct lnet_acceptor_connreq, acr_nid) != 8);
 	BUILD_BUG_ON((int)sizeof(((struct lnet_acceptor_connreq *)0)->acr_nid) != 8);
 
+	/* Checks for struct lnet_acceptor_connreq_v2 */
+	BUILD_BUG_ON((int)sizeof(struct lnet_acceptor_connreq_v2) != 28);
+	BUILD_BUG_ON((int)offsetof(struct lnet_acceptor_connreq_v2, acr_magic) != 0);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_acceptor_connreq_v2 *)0)->acr_magic) != 4);
+	BUILD_BUG_ON((int)offsetof(struct lnet_acceptor_connreq_v2, acr_version) != 4);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_acceptor_connreq_v2 *)0)->acr_version) != 4);
+	BUILD_BUG_ON((int)offsetof(struct lnet_acceptor_connreq_v2, acr_nid) != 8);
+	BUILD_BUG_ON((int)sizeof(((struct lnet_acceptor_connreq_v2 *)0)->acr_nid) != 20);
+
 	/* Checks for struct lnet_counters_common */
 	BUILD_BUG_ON((int)sizeof(struct lnet_counters_common) != 60);
 	BUILD_BUG_ON((int)offsetof(struct lnet_counters_common, lcc_msgs_alloc) != 0);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
