Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 8449EC433FE
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Oct 2022 21:39:01 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Mq0Bs1mdRz1y30;
	Fri, 14 Oct 2022 14:39:01 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Mq0BF4trQz21D4
 for <lustre-devel@lists.lustre.org>; Fri, 14 Oct 2022 14:38:29 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 34294100CA16;
 Fri, 14 Oct 2022 17:38:14 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 31851DD53C; Fri, 14 Oct 2022 17:38:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 14 Oct 2022 17:38:11 -0400
Message-Id: <1665783491-13827-21-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
References: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 20/20] lnet: socklnd: limit retries on
 conns_per_peer mismatch
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
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

If connection initiator has a higher conns-per-peer setting than
its peer, don't try to create extra connections forever as the
peer will keep rejecting them. A few retries should suffice to
resolve a valid race.

Fixes: 511ace4a ("lnet: socklnd: add conns_per_peer parameter")
WC-bug-id: https://jira.whamcloud.com/browse/LU-16191
Lustre-commit: da893c6c9707ca3b2 ("LU-16191 socklnd: limit retries on conns_per_peer mismatch")
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48664
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.c    |  1 +
 net/lnet/klnds/socklnd/socklnd.h    |  4 ++++
 net/lnet/klnds/socklnd/socklnd_cb.c | 25 +++++++++++++++++++------
 3 files changed, 24 insertions(+), 6 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 9c8b75f0b2a2..00e33c88dfaa 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -144,6 +144,7 @@ ksocknal_create_conn_cb(struct sockaddr *addr)
 	conn_cb->ksnr_blki_conn_count = 0;
 	conn_cb->ksnr_blko_conn_count = 0;
 	conn_cb->ksnr_max_conns = 0;
+	conn_cb->ksnr_busy_retry_count = 0;
 
 	return conn_cb;
 }
diff --git a/net/lnet/klnds/socklnd/socklnd.h b/net/lnet/klnds/socklnd/socklnd.h
index dcb4b2952f8e..bb68a3df596a 100644
--- a/net/lnet/klnds/socklnd/socklnd.h
+++ b/net/lnet/klnds/socklnd/socklnd.h
@@ -379,6 +379,7 @@ struct ksock_conn {
 };
 
 #define SOCKNAL_CONN_COUNT_MAX_BITS	8	/* max conn count bits */
+#define SOCKNAL_MAX_BUSY_RETRIES	3
 
 struct ksock_conn_cb {
 	struct list_head	ksnr_connd_list;	/* chain on ksnr_connd_routes */
@@ -407,6 +408,9 @@ struct ksock_conn_cb {
 	unsigned int		ksnr_max_conns;		/* conns_per_peer at
 							 * peer creation
 							 */
+	unsigned int		ksnr_busy_retry_count;	/* counts retry attempts
+							 * due to EALREADY rc
+							 */
 };
 
 #define SOCKNAL_KEEPALIVE_PING	1	/* cookie for keepalive ping */
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index b2da535fbfbe..f358875a2afe 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -1785,7 +1785,7 @@ ksocknal_connect(struct ksock_conn_cb *conn_cb)
 {
 	LIST_HEAD(zombies);
 	struct ksock_peer_ni *peer_ni = conn_cb->ksnr_peer;
-	int type;
+	int type = SOCKLND_CONN_NONE;
 	int wanted;
 	struct socket *sock;
 	time64_t deadline;
@@ -1863,14 +1863,18 @@ ksocknal_connect(struct ksock_conn_cb *conn_cb)
 			goto failed;
 		}
 
-		/*
-		 * A +ve RC means I have to retry because I lost the connection
+		if (rc == EALREADY && conn_cb->ksnr_conn_count > 0)
+			conn_cb->ksnr_busy_retry_count += 1;
+		else
+			conn_cb->ksnr_busy_retry_count = 0;
+
+		/* A +ve RC means I have to retry because I lost the connection
 		 * race or I have to renegotiate protocol version
 		 */
-		retry_later = (rc);
+		retry_later = (rc != 0);
 		if (retry_later)
-			CDEBUG(D_NET, "peer_ni %s: conn race, retry later.\n",
-			       libcfs_nidstr(&peer_ni->ksnp_id.nid));
+			CDEBUG(D_NET, "peer_ni %s: conn race, retry later. rc %d\n",
+			       libcfs_nidstr(&peer_ni->ksnp_id.nid), rc);
 
 		write_lock_bh(&ksocknal_data.ksnd_global_lock);
 	}
@@ -1878,6 +1882,15 @@ ksocknal_connect(struct ksock_conn_cb *conn_cb)
 	conn_cb->ksnr_scheduled = 0;
 	conn_cb->ksnr_connecting = 0;
 
+	if (conn_cb->ksnr_busy_retry_count >= SOCKNAL_MAX_BUSY_RETRIES &&
+	    type > SOCKLND_CONN_NONE) {
+		/* After so many retries due to EALREADY assume that
+		 * the peer doesn't support as many connections as we want
+		 */
+		conn_cb->ksnr_connected |= BIT(type);
+		retry_later = false;
+	}
+
 	if (retry_later) {
 		/*
 		 * re-queue for attention; this frees me up to handle
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
