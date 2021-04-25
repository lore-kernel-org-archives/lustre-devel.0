Return-Path: <SRS0=Gt0B=JW=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D326CC43460
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:09:24 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 90EED611ED
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:09:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90EED611ED
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0117521F946;
	Sun, 25 Apr 2021 13:09:06 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A12D621F513
 for <lustre-devel@lists.lustre.org>; Sun, 25 Apr 2021 13:08:44 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 1EBE310087C5;
 Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 1BB4169A7E; Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 25 Apr 2021 16:08:19 -0400
Message-Id: <1619381316-7719-13-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
References: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 12/29] lnet: o2iblnd: Use REMOTE_DROPPED for
 ECONNREFUSED
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
Cc: Chris Horn <chris.horn@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Chris Horn <chris.horn@hpe.com>

ECONNREFUSED means that we received a response from the remote end,
so setting the LNet health status to REMOTE_DROPPED is more
appropriate than setting LOCAL_DROPPED. Using REMOTE_DROPPED will
decrement the peer NI health and allow us to try other peer NIs for
future sends.

Decrementing the peer NI health will also result in routes being
marked down, as appropriate, for cases where a router has refused the
connection request.

HPE-bug-id: LUS-9853
WC-bug-id: https://jira.whamcloud.com/browse/LU-14540
Lustre-commit: f9d837b479232bfc ("LU-14540 o2iblnd: Use REMOTE_DROPPED for ECONNREFUSED")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/42114
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 21 +++++++++++++++------
 1 file changed, 15 insertions(+), 6 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 5066c93..6445f0a 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -2105,6 +2105,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 {
 	LIST_HEAD(zombies);
 	unsigned long flags;
+	enum lnet_msg_hstatus hstatus;
 
 	LASSERT(error);
 	LASSERT(!in_interrupt());
@@ -2150,12 +2151,20 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	CNETERR("Deleting messages for %s: connection failed\n",
 		libcfs_nid2str(peer_ni->ibp_nid));
 
-	if (error == -EHOSTUNREACH || error == -ETIMEDOUT)
-		kiblnd_txlist_done(&zombies, error,
-				   LNET_MSG_STATUS_NETWORK_TIMEOUT);
-	else
-		kiblnd_txlist_done(&zombies, error,
-				   LNET_MSG_STATUS_LOCAL_DROPPED);
+	switch (error) {
+	case -EHOSTUNREACH:
+	case -ETIMEDOUT:
+		hstatus = LNET_MSG_STATUS_NETWORK_TIMEOUT;
+		break;
+	case -ECONNREFUSED:
+		hstatus = LNET_MSG_STATUS_REMOTE_DROPPED;
+		break;
+	default:
+		hstatus = LNET_MSG_STATUS_LOCAL_DROPPED;
+		break;
+	}
+
+	kiblnd_txlist_done(&zombies, error, hstatus);
 }
 
 static void
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
