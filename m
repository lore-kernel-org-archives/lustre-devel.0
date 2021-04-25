Return-Path: <SRS0=Gt0B=JW=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28936C433B4
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:09:22 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C9AA66124B
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:09:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C9AA66124B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 75A4E21F7EE;
	Sun, 25 Apr 2021 13:09:05 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 330C321F7A3
 for <lustre-devel@lists.lustre.org>; Sun, 25 Apr 2021 13:08:47 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 35FF110087CE;
 Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 3499769A64; Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 25 Apr 2021 16:08:27 -0400
Message-Id: <1619381316-7719-21-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
References: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 20/29] lnet: o2iblnd: don't resend if there's
 no listener
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

If there's no listener at remote peer, we will
get IB_CM_REJ_INVALID_SERVICE_ID, currently we
will try to resend which makes the discovery longer
than necessary when connecting to a node which is
not up.
Use -EHOSTUNREACH instead of -ECONNREFUSED,
so we don't end up queued for resend.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14536
Lustre-commit: 67ba3ce23d32266e ("LU-14536 o2iblnd: don't resend if there's no listener")
Signed-off-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-on: https://review.whamcloud.com/42109
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 6445f0a..e5e5e02 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -2745,6 +2745,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 kiblnd_rejected(struct kib_conn *conn, int reason, void *priv, int priv_nob)
 {
 	struct kib_peer_ni *peer_ni = conn->ibc_peer;
+	int status = -ECONNREFUSED;
 
 	LASSERT(!in_interrupt());
 	LASSERT(conn->ibc_state == IBLND_CONN_ACTIVE_CONNECT);
@@ -2756,6 +2757,8 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		break;
 
 	case IB_CM_REJ_INVALID_SERVICE_ID:
+		status = -EHOSTUNREACH;
+		peer_ni->ibp_retries++;
 		kiblnd_check_reconnect(conn, IBLND_MSG_VERSION, 0,
 				       IBLND_REJECT_INVALID_SRV_ID, NULL);
 		CNETERR("%s rejected: no listener at %d\n",
@@ -2870,7 +2873,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		break;
 	}
 
-	kiblnd_connreq_done(conn, -ECONNREFUSED);
+	kiblnd_connreq_done(conn, status);
 }
 
 static void
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
