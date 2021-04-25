Return-Path: <SRS0=Gt0B=JW=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 79B69C433B4
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:09:56 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3961061260
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:09:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3961061260
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id C636421FA1C;
	Sun, 25 Apr 2021 13:09:26 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 71C5221F7C2
 for <lustre-devel@lists.lustre.org>; Sun, 25 Apr 2021 13:08:47 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 39A2A10087D0;
 Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 378AB69A85; Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 25 Apr 2021 16:08:28 -0400
Message-Id: <1619381316-7719-22-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
References: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 21/29] lnet: obi2lnd: don't try to reconnect
 if there's no listener
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
Cc: Li Dongyang <dongyangli@ddn.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Li Dongyang <dongyangli@ddn.com>

For each discovery we try to reconnect up to retry_count times,
default to 5. during MDT mount process conf log, there will be
multiple discovery made for each OST.
If the OSTs are not up, the mount will have a long time out.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14536
Lustre-commit: 67ba3ce23d32266e ("LU-14536 obi2lnd: don't try to reconnect if there's no listener")
Signed-off-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-on: https://review.whamcloud.com/42111
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.h    |  2 --
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 16 ----------------
 2 files changed, 18 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index a5a66ee..c578673 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -510,8 +510,6 @@ struct kib_peer_ni {
 	unsigned char		ibp_races;
 	/* # consecutive reconnection attempts to this peer_ni */
 	unsigned int		ibp_reconnected;
-	/* number of total active retries */
-	unsigned int		ibp_retries;
 	/* errno on closing this peer_ni */
 	int			ibp_error;
 	/* max map_on_demand */
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index e5e5e02..de3b42e 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -2201,9 +2201,6 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	/* connection established */
 	write_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
 
-	/* reset retry count */
-	peer_ni->ibp_retries = 0;
-
 	conn->ibc_last_send = ktime_get();
 	kiblnd_set_conn_state(conn, IBLND_CONN_ESTABLISHED);
 	kiblnd_peer_alive(peer_ni);
@@ -2654,11 +2651,6 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		goto out;
 	}
 
-	if (peer_ni->ibp_retries > *kiblnd_tunables.kib_retry_count) {
-		reason = "retry count exceeded due to no listener";
-		goto out;
-	}
-
 	switch (why) {
 	default:
 		reason = "Unknown";
@@ -2714,11 +2706,6 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	case IBLND_REJECT_CONN_UNCOMPAT:
 		reason = "version negotiation";
 		break;
-
-	case IBLND_REJECT_INVALID_SRV_ID:
-		peer_ni->ibp_retries++;
-		reason = "invalid service id";
-		break;
 	}
 
 	conn->ibc_reconnect = 1;
@@ -2758,9 +2745,6 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 
 	case IB_CM_REJ_INVALID_SERVICE_ID:
 		status = -EHOSTUNREACH;
-		peer_ni->ibp_retries++;
-		kiblnd_check_reconnect(conn, IBLND_MSG_VERSION, 0,
-				       IBLND_REJECT_INVALID_SRV_ID, NULL);
 		CNETERR("%s rejected: no listener at %d\n",
 			libcfs_nid2str(peer_ni->ibp_nid),
 			*kiblnd_tunables.kib_service);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
