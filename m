Return-Path: <SRS0=NZgA=GY=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EAE0C433E0
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:18:51 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2CFA123A5D
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:18:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2CFA123A5D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 867C021FF4A;
	Thu, 21 Jan 2021 09:18:03 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2749921FCA0
 for <lustre-devel@lists.lustre.org>; Thu, 21 Jan 2021 09:17:16 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 8F2311008495;
 Thu, 21 Jan 2021 12:17:05 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 8DA421B49E; Thu, 21 Jan 2021 12:17:05 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 21 Jan 2021 12:17:00 -0500
Message-Id: <1611249422-556-38-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
References: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 37/39] lnet: use an unbound cred in
 kiblnd_resolve_addr()
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

From: "John L. Hammond" <jhammond@whamcloud.com>

In kiblnd_resolve_addr() call prepare_kernel_cred(NULL) rather than
prepare_creds() to get a cred with unbound capabilities.

Fixes: 5fc342b471a ("lnet: o2ib: raise bind cap before resolving address")
WC-bug-id: https://jira.whamcloud.com/browse/LU-14296
Lustre-commit: 30b356a28b5094 ("LU-14296 lnet: use an unbound cred in kiblnd_resolve_addr()")
Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/41137
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index c799453..e29cb4b 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1207,8 +1207,6 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	unsigned short port;
 	int rc;
 
-	LASSERT(capable(CAP_NET_BIND_SERVICE));
-
 	/* allow the port to be reused */
 	rc = rdma_set_reuseaddr(cmid, 1);
 	if (rc) {
@@ -1234,7 +1232,8 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		}
 	}
 
-	CERROR("Failed to bind to a free privileged port\n");
+	CERROR("cannot bind to a free privileged port: rc = %d\n", rc);
+
 	return rc;
 }
 
@@ -1249,7 +1248,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	int rc;
 
 	if (!capable(CAP_NET_BIND_SERVICE)) {
-		new_creds = prepare_creds();
+		new_creds = prepare_kernel_cred(NULL);
 		if (!new_creds)
 			return -ENOMEM;
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
