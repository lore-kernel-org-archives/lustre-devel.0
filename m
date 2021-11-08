Return-Path: <SRS0=Xi2l=P3=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9310CC433F5
	for <lustre-devel@archiver.kernel.org>; Mon,  8 Nov 2021 15:08:33 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 597D36105A
	for <lustre-devel@archiver.kernel.org>; Mon,  8 Nov 2021 15:08:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 597D36105A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 44A3821F3DE;
	Mon,  8 Nov 2021 07:08:19 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (SMTP3.CCS.ORNL.GOV [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1C15921C967
 for <lustre-devel@lists.lustre.org>; Mon,  8 Nov 2021 07:07:49 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 161642223;
 Mon,  8 Nov 2021 10:07:46 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 0D010E080F; Mon,  8 Nov 2021 10:07:46 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  8 Nov 2021 10:07:32 -0500
Message-Id: <1636384063-13838-5-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1636384063-13838-1-git-send-email-jsimmons@infradead.org>
References: <1636384063-13838-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 04/15] lnet: socklnd: lock ksnc_tx_queue list
 processing
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
Cc: Artem Blagodarenko <artem.blagodarenko@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Artem Blagodarenko <artem.blagodarenko@hpe.com>

A GFP occurred in the ksocknal_find_timed_out_conn() while processing
ksnc_tx_queue list.

Add locking to this list.

HPE-bug-id: LUS-10248
Fixes: 3f8b895465 ("lnet: handle socklnd tx failure")
WC-bug-id: https://jira.whamcloud.com/browse/LU-15076
Lustre-commit: 13c7c2e3c248c8cdb ("LU-15076 socklnd: lock ksnc_tx_queue list processing")
Signed-off-by: Artem Blagodarenko <artem.blagodarenko@hpe.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-on: https://review.whamcloud.com/45179
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd_cb.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index edc584a..b2a1267 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -2188,12 +2188,14 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	/* We're called with a shared lock on ksnd_global_lock */
 	struct ksock_conn *conn;
 	struct ksock_tx *tx;
+	struct ksock_sched *sched;
 
 	list_for_each_entry(conn, &peer_ni->ksnp_conns, ksnc_list) {
 		int error;
 
 		/* Don't need the {get,put}connsock dance to deref ksnc_sock */
 		LASSERT(!conn->ksnc_closing);
+		sched = conn->ksnc_scheduler;
 
 		error = conn->ksnc_sock->sk->sk_err;
 		if (error) {
@@ -2234,6 +2236,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 			return conn;
 		}
 
+		spin_lock_bh(&sched->kss_lock);
 		if ((!list_empty(&conn->ksnc_tx_queue) ||
 		     conn->ksnc_sock->sk->sk_wmem_queued) &&
 		    ktime_get_seconds() >= conn->ksnc_tx_deadline) {
@@ -2249,8 +2252,10 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 			CNETERR("Timeout sending data to %s (%pISp) the network or that node may be down.\n",
 				libcfs_idstr(&peer_ni->ksnp_id),
 				&conn->ksnc_peeraddr);
+			spin_unlock_bh(&sched->kss_lock);
 			return conn;
 		}
+		spin_unlock_bh(&sched->kss_lock);
 	}
 
 	return NULL;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
