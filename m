Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 315B7C43217
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Oct 2022 21:38:58 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Mq0Bn6BPXz21JS;
	Fri, 14 Oct 2022 14:38:57 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Mq0BD19dPz21D4
 for <lustre-devel@lists.lustre.org>; Fri, 14 Oct 2022 14:38:28 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 2D9B5100CA14;
 Fri, 14 Oct 2022 17:38:14 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 29A37DD53E; Fri, 14 Oct 2022 17:38:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 14 Oct 2022 17:38:09 -0400
Message-Id: <1665783491-13827-19-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
References: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 18/20] lnet: o2iblnd: fix deadline for tx on
 peer queue
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

In o2iblnd, deadline is checked for txs on peer queue,
but not set prior to adding the tx to the queue. This
may cause the tx to be dropped unnecessarily with
"Timed out tx for ..." warning.

Fix it by setting the tx_deadline when adding tx to peer queue.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16184
Lustre-commit: 4c89ee7d7b098c7f1 ("LU-16184 o2iblnd: fix deadline for tx on peer queue")
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48640
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 919b83d5c6e2..6f040964121c 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1422,6 +1422,7 @@ kiblnd_launch_tx(struct lnet_ni *ni, struct kib_tx *tx, lnet_nid_t nid)
 	int rc;
 	int i;
 	struct lnet_ioctl_config_o2iblnd_tunables *tunables;
+	s64 timeout_ns;
 
 	/*
 	 * If I get here, I've committed to send, so I complete the tx with
@@ -1450,6 +1451,7 @@ kiblnd_launch_tx(struct lnet_ni *ni, struct kib_tx *tx, lnet_nid_t nid)
 		return;
 	}
 
+	timeout_ns = kiblnd_timeout() * NSEC_PER_SEC;
 	read_unlock(g_lock);
 	/* Re-try with a write lock */
 	write_lock(g_lock);
@@ -1459,9 +1461,12 @@ kiblnd_launch_tx(struct lnet_ni *ni, struct kib_tx *tx, lnet_nid_t nid)
 		if (list_empty(&peer_ni->ibp_conns)) {
 			/* found a peer_ni, but it's still connecting... */
 			LASSERT(kiblnd_peer_connecting(peer_ni));
-			if (tx)
+			if (tx) {
+				tx->tx_deadline = ktime_add_ns(ktime_get(),
+							       timeout_ns);
 				list_add_tail(&tx->tx_list,
 					      &peer_ni->ibp_tx_queue);
+			}
 			write_unlock_irqrestore(g_lock, flags);
 		} else {
 			conn = kiblnd_get_conn_locked(peer_ni);
@@ -1498,9 +1503,12 @@ kiblnd_launch_tx(struct lnet_ni *ni, struct kib_tx *tx, lnet_nid_t nid)
 		if (list_empty(&peer2->ibp_conns)) {
 			/* found a peer_ni, but it's still connecting... */
 			LASSERT(kiblnd_peer_connecting(peer2));
-			if (tx)
+			if (tx) {
+				tx->tx_deadline = ktime_add_ns(ktime_get(),
+							       timeout_ns);
 				list_add_tail(&tx->tx_list,
 					      &peer2->ibp_tx_queue);
+			}
 			write_unlock_irqrestore(g_lock, flags);
 		} else {
 			conn = kiblnd_get_conn_locked(peer2);
@@ -1525,8 +1533,10 @@ kiblnd_launch_tx(struct lnet_ni *ni, struct kib_tx *tx, lnet_nid_t nid)
 	/* always called with a ref on ni, which prevents ni being shutdown */
 	LASSERT(!((struct kib_net *)ni->ni_data)->ibn_shutdown);
 
-	if (tx)
+	if (tx) {
+		tx->tx_deadline = ktime_add_ns(ktime_get(), timeout_ns);
 		list_add_tail(&tx->tx_list, &peer_ni->ibp_tx_queue);
+	}
 
 	kiblnd_peer_addref(peer_ni);
 	hash_add(kiblnd_data.kib_peers, &peer_ni->ibp_list, nid);
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
