Return-Path: <SRS0=EXfh=KK=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B33C3C433B4
	for <lustre-devel@archiver.kernel.org>; Sat, 15 May 2021 13:06:53 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 74E2F61355
	for <lustre-devel@archiver.kernel.org>; Sat, 15 May 2021 13:06:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 74E2F61355
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2C0AB21FAC2;
	Sat, 15 May 2021 06:06:35 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E9F4821CAD2
 for <lustre-devel@lists.lustre.org>; Sat, 15 May 2021 06:06:14 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 833581006773;
 Sat, 15 May 2021 09:06:12 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 75EE19814B; Sat, 15 May 2021 09:06:12 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sat, 15 May 2021 09:06:01 -0400
Message-Id: <1621083970-32463-5-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1621083970-32463-1-git-send-email-jsimmons@infradead.org>
References: <1621083970-32463-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 04/13] lnet: socklnd: add conns_per_peer
 parameter
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
Cc: Serguei Smirnov <ssmirnov@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Serguei Smirnov <ssmirnov@whamcloud.com>

Introduce conns_per_peer ksocklnd module parameter.
In typed mode, this parameter shall control
the number of BULK_IN and BULK_OUT tcp connections,
while the number of CONTROL connections shall stay
at 1. In untyped mode, this parameter shall control
the number of untyped connections.
The default conns_per_peer is 1. Max is 127.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12815
Lustre-commit: 71b2476e4ddb95aa ("LU-12815 socklnd: add conns_per_peer parameter")
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/41056
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.c           | 92 ++++++++++++++++++++++++++++--
 net/lnet/klnds/socklnd/socklnd.h           | 23 ++++++--
 net/lnet/klnds/socklnd/socklnd_cb.c        |  3 +-
 net/lnet/klnds/socklnd/socklnd_modparams.c |  9 +++
 4 files changed, 115 insertions(+), 12 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 4c79d1a..3a667e5 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -132,6 +132,9 @@ static int ksocknal_ip2index(struct sockaddr *addr, struct lnet_ni *ni)
 	conn_cb->ksnr_connected = 0;
 	conn_cb->ksnr_deleted = 0;
 	conn_cb->ksnr_conn_count = 0;
+	conn_cb->ksnr_ctrl_conn_count = 0;
+	conn_cb->ksnr_blki_conn_count = 0;
+	conn_cb->ksnr_blko_conn_count = 0;
 
 	return conn_cb;
 }
@@ -364,6 +367,73 @@ struct ksock_peer_ni *
 	return rc;
 }
 
+static unsigned int
+ksocknal_get_conn_count_by_type(struct ksock_conn_cb *conn_cb,
+				int type)
+{
+	unsigned int count = 0;
+
+	switch (type) {
+	case SOCKLND_CONN_CONTROL:
+		count = conn_cb->ksnr_ctrl_conn_count;
+		break;
+	case SOCKLND_CONN_BULK_IN:
+		count = conn_cb->ksnr_blki_conn_count;
+		break;
+	case SOCKLND_CONN_BULK_OUT:
+		count = conn_cb->ksnr_blko_conn_count;
+		break;
+	case SOCKLND_CONN_ANY:
+		count = conn_cb->ksnr_conn_count;
+		break;
+	default:
+		LBUG();
+		break;
+	}
+
+	return count;
+}
+
+static void
+ksocknal_incr_conn_count(struct ksock_conn_cb *conn_cb,
+			 int type)
+{
+	conn_cb->ksnr_conn_count++;
+
+	/* check if all connections of the given type got created */
+	switch (type) {
+	case SOCKLND_CONN_CONTROL:
+		conn_cb->ksnr_ctrl_conn_count++;
+		/* there's a single control connection per peer */
+		conn_cb->ksnr_connected |= BIT(type);
+		break;
+	case SOCKLND_CONN_BULK_IN:
+		conn_cb->ksnr_blki_conn_count++;
+		if (conn_cb->ksnr_blki_conn_count >=
+		    *ksocknal_tunables.ksnd_conns_per_peer)
+			conn_cb->ksnr_connected |= BIT(type);
+		break;
+	case SOCKLND_CONN_BULK_OUT:
+		conn_cb->ksnr_blko_conn_count++;
+		if (conn_cb->ksnr_blko_conn_count >=
+		    *ksocknal_tunables.ksnd_conns_per_peer)
+			conn_cb->ksnr_connected |= BIT(type);
+		break;
+	case SOCKLND_CONN_ANY:
+		if (conn_cb->ksnr_conn_count >=
+		    *ksocknal_tunables.ksnd_conns_per_peer)
+			conn_cb->ksnr_connected |= BIT(type);
+		break;
+	default:
+		LBUG();
+		break;
+	}
+
+	CDEBUG(D_NET, "Add conn type %d, ksnr_connected %x conns_per_peer %d\n",
+	       type, conn_cb->ksnr_connected,
+	       *ksocknal_tunables.ksnd_conns_per_peer);
+}
+
 static void
 ksocknal_associate_cb_conn_locked(struct ksock_conn_cb *conn_cb,
 				  struct ksock_conn *conn)
@@ -407,8 +477,7 @@ struct ksock_peer_ni *
 			iface->ksni_nroutes++;
 	}
 
-	conn_cb->ksnr_connected |= (1 << type);
-	conn_cb->ksnr_conn_count++;
+	ksocknal_incr_conn_count(conn_cb, type);
 
 	/* Successful connection => further attempts can
 	 * proceed immediately
@@ -728,6 +797,7 @@ struct ksock_peer_ni *
 	int rc2;
 	int rc;
 	int active;
+	int num_dup = 0;
 	char *warn = NULL;
 
 	active = !!conn_cb;
@@ -928,11 +998,14 @@ struct ksock_peer_ni *
 			    conn2->ksnc_type != conn->ksnc_type)
 				continue;
 
-			/*
-			 * Reply on a passive connection attempt so the peer
+			num_dup++;
+			if (num_dup < *ksocknal_tunables.ksnd_conns_per_peer)
+				continue;
+
+			/* Reply on a passive connection attempt so the peer_ni
 			 * realises we're connected.
 			 */
-			LASSERT(!rc);
+			LASSERT(rc == 0);
 			if (!active)
 				rc = EALREADY;
 
@@ -1148,7 +1221,14 @@ struct ksock_peer_ni *
 	if (conn_cb) {
 		/* dissociate conn from cb... */
 		LASSERT(!conn_cb->ksnr_deleted);
-		LASSERT(conn_cb->ksnr_connected & BIT(conn->ksnc_type));
+
+		/* connected bit is set only if all connections
+		 * of the given type got created
+		 */
+		if (ksocknal_get_conn_count_by_type(conn_cb, conn->ksnc_type) ==
+		    *ksocknal_tunables.ksnd_conns_per_peer)
+			LASSERT((conn_cb->ksnr_connected &
+				BIT(conn->ksnc_type)) != 0);
 
 		list_for_each_entry(conn2, &peer_ni->ksnp_conns, ksnc_list) {
 			if (conn2->ksnc_conn_cb == conn_cb &&
diff --git a/net/lnet/klnds/socklnd/socklnd.h b/net/lnet/klnds/socklnd/socklnd.h
index 9f8fe8a..dac8559 100644
--- a/net/lnet/klnds/socklnd/socklnd.h
+++ b/net/lnet/klnds/socklnd/socklnd.h
@@ -163,6 +163,11 @@ struct ksock_tunables {
 	int		*ksnd_zc_recv_min_nfrags; /* minimum # of fragments to
 						   * enable ZC receive
 						   */
+	int		*ksnd_conns_per_peer;	/* for typed mode, yields:
+						 * 1 + 2*conns_per_peer total
+						 * for untyped:
+						 * conns_per_peer total
+						 */
 };
 
 struct ksock_net {
@@ -371,6 +376,8 @@ struct ksock_conn {
 							 */
 };
 
+#define SOCKNAL_CONN_COUNT_MAX_BITS	8	/* max conn count bits */
+
 struct ksock_conn_cb {
 	struct list_head	ksnr_connd_list;	/* chain on ksnr_connd_routes */
 	struct ksock_peer_ni   *ksnr_peer;		/* owning peer_ni */
@@ -389,8 +396,11 @@ struct ksock_conn_cb {
 							 * type
 							 */
 	unsigned int		ksnr_deleted:1;		/* been removed from peer_ni? */
-	int			ksnr_conn_count;	/* # conns established by this
-							 * route
+	unsigned int            ksnr_ctrl_conn_count:1; /* # conns by type */
+	unsigned int		ksnr_blki_conn_count:8;
+	unsigned int		ksnr_blko_conn_count:8;
+	int			ksnr_conn_count;	/* total # conns for
+							 * this cb
 							 */
 };
 
@@ -595,9 +605,12 @@ struct ksock_proto {
 
 static inline int ksocknal_timeout(void)
 {
-	return *ksocknal_tunables.ksnd_timeout ?
-		*ksocknal_tunables.ksnd_timeout :
-		lnet_get_lnd_timeout();
+	return *ksocknal_tunables.ksnd_timeout ?: lnet_get_lnd_timeout();
+}
+
+static inline int ksocknal_conns_per_peer(void)
+{
+	return *ksocknal_tunables.ksnd_conns_per_peer ?: 1;
 }
 
 int ksocknal_startup(struct lnet_ni *ni);
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index 43658b2..bfb98f5 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -1818,7 +1818,8 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 			type = SOCKLND_CONN_ANY;
 		} else if (wanted & BIT(SOCKLND_CONN_CONTROL)) {
 			type = SOCKLND_CONN_CONTROL;
-		} else if (wanted & BIT(SOCKLND_CONN_BULK_IN)) {
+		} else if (wanted & BIT(SOCKLND_CONN_BULK_IN) &&
+			   conn_cb->ksnr_blki_conn_count <= conn_cb->ksnr_blko_conn_count) {
 			type = SOCKLND_CONN_BULK_IN;
 		} else {
 			LASSERT(wanted & BIT(SOCKLND_CONN_BULK_OUT));
diff --git a/net/lnet/klnds/socklnd/socklnd_modparams.c b/net/lnet/klnds/socklnd/socklnd_modparams.c
index 017627f..bc772e4 100644
--- a/net/lnet/klnds/socklnd/socklnd_modparams.c
+++ b/net/lnet/klnds/socklnd/socklnd_modparams.c
@@ -139,6 +139,10 @@
 module_param(zc_recv_min_nfrags, int, 0644);
 MODULE_PARM_DESC(zc_recv_min_nfrags, "minimum # of fragments to enable ZC recv");
 
+static unsigned int conns_per_peer = 1;
+module_param(conns_per_peer, uint, 0444);
+MODULE_PARM_DESC(conns_per_peer, "number of connections per peer");
+
 #if SOCKNAL_VERSION_DEBUG
 static int protocol = 3;
 module_param(protocol, int, 0644);
@@ -177,6 +181,11 @@ int ksocknal_tunables_init(void)
 	ksocknal_tunables.ksnd_zc_min_payload = &zc_min_payload;
 	ksocknal_tunables.ksnd_zc_recv = &zc_recv;
 	ksocknal_tunables.ksnd_zc_recv_min_nfrags = &zc_recv_min_nfrags;
+	if (conns_per_peer > ((1 << SOCKNAL_CONN_COUNT_MAX_BITS) - 1)) {
+		CWARN("socklnd conns_per_peer is capped at %u.\n",
+		      (1 << SOCKNAL_CONN_COUNT_MAX_BITS) - 1);
+	}
+	ksocknal_tunables.ksnd_conns_per_peer     = &conns_per_peer;
 
 #if SOCKNAL_VERSION_DEBUG
 	ksocknal_tunables.ksnd_protocol = &protocol;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
