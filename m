Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 68AE3C433EF
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:32:08 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6D0B121CAB6;
	Sun, 20 Mar 2022 06:31:43 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9D3A121CAB7
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:11 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 0697FED9;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id F0246E0D4D; Sun, 20 Mar 2022 09:31:07 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:21 -0400
Message-Id: <1647783064-20688-8-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 07/50] lnet: socklnd: don't deref lnet_hdr in
 LNDs
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

The lnd_hdr structure needs to be extended to support larger
addresses.  To assist this we need to minimize the number of places
that its content are accessed.

Currently the internals of lnet_hdr are larely untouched inside the
various LNDs, but there are some exceptions in socklnd.
These exceptions are not necessary - the same data is available from
elsewhere in the lnet_msg.

So change those accesses to use the lnet_msg info instead.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 321fe9fa12d244bb7 ("LU-10391 socklnd: don't deref lnet_hdr in LNDs")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/43602
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd_cb.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index feab2a07..dede642 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -356,10 +356,10 @@ struct ksock_tx *
 
 		if (error && tx->tx_lnetmsg) {
 			CNETERR("Deleting packet type %d len %d %s->%s\n",
-				le32_to_cpu(tx->tx_lnetmsg->msg_hdr.type),
-				le32_to_cpu(tx->tx_lnetmsg->msg_hdr.payload_length),
-				libcfs_nid2str(le64_to_cpu(tx->tx_lnetmsg->msg_hdr.src_nid)),
-				libcfs_nid2str(le64_to_cpu(tx->tx_lnetmsg->msg_hdr.dest_nid)));
+				tx->tx_lnetmsg->msg_type,
+				tx->tx_lnetmsg->msg_len,
+				libcfs_nidstr(&tx->tx_lnetmsg->msg_initiator),
+				libcfs_nidstr(&tx->tx_lnetmsg->msg_target.nid));
 		} else if (error) {
 			CNETERR("Deleting noop packet\n");
 		}
@@ -697,8 +697,8 @@ struct ksock_conn *
 	LASSERT(tx->tx_resid == tx->tx_nob);
 
 	CDEBUG(D_NET, "Packet %p type %d, nob %d niov %d nkiov %d\n",
-	       tx, (tx->tx_lnetmsg) ? tx->tx_lnetmsg->msg_hdr.type :
-					      KSOCK_MSG_NOOP,
+	       tx, tx->tx_lnetmsg ? tx->tx_lnetmsg->msg_hdr.type :
+				    KSOCK_MSG_NOOP,
 	       tx->tx_nob, tx->tx_niov, tx->tx_nkiov);
 
 	bufnob = conn->ksnc_sock->sk->sk_wmem_queued;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
