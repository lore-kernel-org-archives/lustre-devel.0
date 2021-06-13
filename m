Return-Path: <SRS0=27wn=LH=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1D38C48BE8
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:12:38 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 89D3A61363
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:12:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89D3A61363
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 769BB21F6AA;
	Sun, 13 Jun 2021 16:12:14 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E372321EBDE
 for <lustre-devel@lists.lustre.org>; Sun, 13 Jun 2021 16:11:44 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id CEC0D100B057;
 Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id CC37E9C303; Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 13 Jun 2021 19:11:25 -0400
Message-Id: <1623625897-17706-16-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
References: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 15/27] lnet: do not crash if
 lnet_sock_getaddr returns error
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

Some issues with network lead to panic in ksocknal_accept

rc = lnet_sock_getaddr(sock, true, &peer_ip, &peer_port);
LASSERT(rc == 0); /* we succeeded before */

Let's pass this error to the caller.

HPE-bug-id: LUS-9256
WC-bug-id: https://jira.whamcloud.com/browse/LU-13950
Lustre-commit: 48a9ea82eb30bbb ("LU-13950 lnet: do not crash if lnet_sock_getaddr returns error")
Signed-off-by: Artem Blagodarenko <artem.blagodarenko@hpe.com>
Reviewed-on: https://es-gerrit.dev.cray.com/157753
Reviewed-by: Andriy Skulysh <c17819@cray.com>
Reviewed-by: Alexander Zarochentsev <c17826@cray.com>
Tested-by: Alexander Lezhoev <c17454@cray.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/39834
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.c | 5 ++++-
 net/lnet/lnet/acceptor.c         | 5 ++++-
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 3a667e5..eb8c736 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -744,7 +744,10 @@ struct ksock_peer_ni *
 	struct sockaddr_storage peer;
 
 	rc = lnet_sock_getaddr(sock, true, &peer);
-	LASSERT(!rc);			/* we succeeded before */
+	if (rc != 0) {
+		CERROR("Can't determine new connection's address\n");
+		return rc;
+	}
 
 	cr = kzalloc(sizeof(*cr), GFP_NOFS);
 	if (!cr) {
diff --git a/net/lnet/lnet/acceptor.c b/net/lnet/lnet/acceptor.c
index b301ffa..3708b89 100644
--- a/net/lnet/lnet/acceptor.c
+++ b/net/lnet/lnet/acceptor.c
@@ -200,7 +200,10 @@ struct socket *
 	LASSERT(sizeof(cr) <= 16);		/* not too big for the stack */
 
 	rc = lnet_sock_getaddr(sock, true, &peer);
-	LASSERT(!rc);				/* we succeeded before */
+	if (rc != 0) {
+		CERROR("Can't determine new connection's address\n");
+		return rc;
+	}
 
 	if (!lnet_accept_magic(magic, LNET_PROTO_ACCEPTOR_MAGIC)) {
 		if (lnet_accept_magic(magic, LNET_PROTO_MAGIC)) {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
