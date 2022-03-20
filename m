Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id CA95DC433EF
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:31:48 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A0C2921EB78;
	Sun, 20 Mar 2022 06:31:32 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2DDC021EB5C
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:15 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 3144BEEB;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 2DE52AB; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:35 -0400
Message-Id: <1647783064-20688-22-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 21/50] lnet: socklnd: move lnet_hdr unpack
 into ->pro_unpack
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

Converting the lnet_hdr from network-format to host-format
is currently done in ksocknal_process_recv().
Move it to ->pro_unpack() so that a different protocol
can send it in a different format.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 15365f3de34ed7d25 ("LU-10391 socklnd: move lnet_hdr unpack into ->pro_unpack")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/43609
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.h       | 2 +-
 net/lnet/klnds/socklnd/socklnd_cb.c    | 4 +---
 net/lnet/klnds/socklnd/socklnd_proto.c | 7 ++++---
 3 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.h b/net/lnet/klnds/socklnd/socklnd.h
index 5d0be68..bd38ee2 100644
--- a/net/lnet/klnds/socklnd/socklnd.h
+++ b/net/lnet/klnds/socklnd/socklnd.h
@@ -473,7 +473,7 @@ struct ksock_proto {
 	void	(*pro_pack)(struct ksock_tx *);
 
 	/* message unpack */
-	void	(*pro_unpack)(struct ksock_msg *);
+	void	(*pro_unpack)(struct ksock_msg *msg, struct lnet_hdr *hdr);
 
 	/* queue tx on the connection */
 	struct ksock_tx *(*pro_queue_tx_msg)(struct ksock_conn *, struct ksock_tx *);
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index 925494b..822de50 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -1174,9 +1174,7 @@ struct ksock_conn_cb *
 
 	case SOCKNAL_RX_LNET_HEADER:
 		/* unpack message header */
-		conn->ksnc_proto->pro_unpack(&conn->ksnc_msg);
-
-		lnet_hdr_from_nid4(&hdr, &conn->ksnc_msg.ksm_u.lnetmsg_nid4);
+		conn->ksnc_proto->pro_unpack(&conn->ksnc_msg, &hdr);
 
 		if (conn->ksnc_peer->ksnp_id.pid & LNET_PID_USERFLAG) {
 			/* Userspace peer_ni */
diff --git a/net/lnet/klnds/socklnd/socklnd_proto.c b/net/lnet/klnds/socklnd/socklnd_proto.c
index 20a582b..14b1394 100644
--- a/net/lnet/klnds/socklnd/socklnd_proto.c
+++ b/net/lnet/klnds/socklnd/socklnd_proto.c
@@ -760,18 +760,19 @@
 }
 
 static void
-ksocknal_unpack_msg_v1(struct ksock_msg *msg)
+ksocknal_unpack_msg_v1(struct ksock_msg *msg, struct lnet_hdr *hdr)
 {
 	msg->ksm_csum = 0;
 	msg->ksm_type = KSOCK_MSG_LNET;
 	msg->ksm_zc_cookies[0] = 0;
 	msg->ksm_zc_cookies[1] = 0;
+	lnet_hdr_from_nid4(hdr, &msg->ksm_u.lnetmsg_nid4);
 }
 
 static void
-ksocknal_unpack_msg_v2(struct ksock_msg *msg)
+ksocknal_unpack_msg_v2(struct ksock_msg *msg, struct lnet_hdr *hdr)
 {
-	return;  /* Do nothing */
+	lnet_hdr_from_nid4(hdr, &msg->ksm_u.lnetmsg_nid4);
 }
 
 const struct ksock_proto ksocknal_protocol_v1x = {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
