Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 5D3C2C4332F
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Oct 2022 21:38:51 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Mq0Bg01VZz1y5c;
	Fri, 14 Oct 2022 14:38:50 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Mq0BB55jGz21Bx
 for <lustre-devel@lists.lustre.org>; Fri, 14 Oct 2022 14:38:26 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 228C3100CA0F;
 Fri, 14 Oct 2022 17:38:14 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 2034ADD6C6; Fri, 14 Oct 2022 17:38:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 14 Oct 2022 17:38:07 -0400
Message-Id: <1665783491-13827-17-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
References: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 16/20] lnet: socklnd: remove remnants of tcp
 bonding
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

->ksnp_n_passive_ips is now always zero, so remove it and all uses of
it.  ->ksnp_passive_ips is gone too, as is ksocknal_ip2iface().

WC-bug-id: https://jira.whamcloud.com/browse/LU-13641
Lustre-commit: 3630e1eaf9db562a1 ("LU-13641 socklnd: remove remnants of tcp bonding")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48568
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.c | 73 +++-----------------------------
 net/lnet/klnds/socklnd/socklnd.h |  4 --
 2 files changed, 6 insertions(+), 71 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 8999580b67b4..9c8b75f0b2a2 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -46,20 +46,6 @@
 static struct lnet_lnd the_ksocklnd;
 struct ksock_nal_data ksocknal_data;
 
-static struct ksock_interface *
-ksocknal_ip2iface(struct lnet_ni *ni, struct sockaddr *addr)
-{
-	struct ksock_net *net = ni->ni_data;
-	struct ksock_interface *iface;
-
-	iface = &net->ksnn_interface;
-
-	if (rpc_cmp_addr((struct sockaddr *)&iface->ksni_addr, addr))
-		return iface;
-
-	return NULL;
-}
-
 static struct ksock_interface *
 ksocknal_index2iface(struct lnet_ni *ni, int index)
 {
@@ -281,28 +267,6 @@ ksocknal_find_peer(struct lnet_ni *ni, struct lnet_processid *id)
 static void
 ksocknal_unlink_peer_locked(struct ksock_peer_ni *peer_ni)
 {
-	int i;
-	struct ksock_interface *iface;
-
-	for (i = 0; i < peer_ni->ksnp_n_passive_ips; i++) {
-		struct sockaddr_in sa = { .sin_family = AF_INET };
-
-		LASSERT(i < LNET_INTERFACES_NUM);
-		sa.sin_addr.s_addr = htonl(peer_ni->ksnp_passive_ips[i]);
-
-		iface = ksocknal_ip2iface(peer_ni->ksnp_ni,
-					  (struct sockaddr *)&sa);
-		/*
-		 * All IPs in peer_ni->ksnp_passive_ips[] come from the
-		 * interface list, therefore the call must succeed.
-		 */
-		LASSERT(iface);
-
-		CDEBUG(D_NET, "peer_ni=%p iface=%p ksni_nroutes=%d\n",
-		       peer_ni, iface, iface->ksni_nroutes);
-		iface->ksni_npeers--;
-	}
-
 	LASSERT(list_empty(&peer_ni->ksnp_conns));
 	LASSERT(!peer_ni->ksnp_conn_cb);
 	LASSERT(!peer_ni->ksnp_closing);
@@ -320,7 +284,6 @@ ksocknal_get_peer_info(struct lnet_ni *ni, int index,
 	struct ksock_peer_ni *peer_ni;
 	struct ksock_conn_cb *conn_cb;
 	int i;
-	int j;
 	int rc = -ENOENT;
 
 	read_lock(&ksocknal_data.ksnd_global_lock);
@@ -328,12 +291,11 @@ ksocknal_get_peer_info(struct lnet_ni *ni, int index,
 	hash_for_each(ksocknal_data.ksnd_peers, i, peer_ni, ksnp_list) {
 		if (peer_ni->ksnp_ni != ni)
 			continue;
+		if (index-- > 0)
+			continue;
 
-		if (!peer_ni->ksnp_n_passive_ips &&
-		    !peer_ni->ksnp_conn_cb) {
-			if (index-- > 0)
-				continue;
-
+		conn_cb = peer_ni->ksnp_conn_cb;
+		if (!conn_cb) {
 			*id = peer_ni->ksnp_id;
 			*myip = 0;
 			*peer_ip = 0;
@@ -341,29 +303,7 @@ ksocknal_get_peer_info(struct lnet_ni *ni, int index,
 			*conn_count = 0;
 			*share_count = 0;
 			rc = 0;
-			goto out;
-		}
-
-		for (j = 0; j < peer_ni->ksnp_n_passive_ips; j++) {
-			if (index-- > 0)
-				continue;
-
-			*id = peer_ni->ksnp_id;
-			*myip = peer_ni->ksnp_passive_ips[j];
-			*peer_ip = 0;
-			*port = 0;
-			*conn_count = 0;
-			*share_count = 0;
-			rc = 0;
-			goto out;
-		}
-
-		if (peer_ni->ksnp_conn_cb) {
-			if (index-- > 0)
-				continue;
-
-			conn_cb = peer_ni->ksnp_conn_cb;
-
+		} else {
 			*id = peer_ni->ksnp_id;
 			if (conn_cb->ksnr_addr.ss_family == AF_INET) {
 				struct sockaddr_in *sa;
@@ -383,10 +323,9 @@ ksocknal_get_peer_info(struct lnet_ni *ni, int index,
 			}
 			*conn_count = conn_cb->ksnr_conn_count;
 			*share_count = 1;
-			goto out;
 		}
+		break;
 	}
-out:
 	read_unlock(&ksocknal_data.ksnd_global_lock);
 	return rc;
 }
diff --git a/net/lnet/klnds/socklnd/socklnd.h b/net/lnet/klnds/socklnd/socklnd.h
index 93368bd4139f..dcb4b2952f8e 100644
--- a/net/lnet/klnds/socklnd/socklnd.h
+++ b/net/lnet/klnds/socklnd/socklnd.h
@@ -438,10 +438,6 @@ struct ksock_peer_ni {
 							 */
 	time64_t		ksnp_send_keepalive;	/* time to send keepalive */
 	struct lnet_ni	       *ksnp_ni;		/* which network */
-	int			ksnp_n_passive_ips;	/* # of... */
-
-	/* preferred local interfaces */
-	u32			ksnp_passive_ips[LNET_INTERFACES_NUM];
 };
 
 struct ksock_connreq {
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
