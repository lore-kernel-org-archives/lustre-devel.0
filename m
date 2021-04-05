Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DF48C433ED
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:53:08 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id C9D6160FF0
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:53:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C9D6160FF0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 5821A328E66;
	Mon,  5 Apr 2021 00:52:30 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1614032821F
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:28 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 22B00EC4;
 Sun,  4 Apr 2021 20:51:17 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 21C3190AA8; Sun,  4 Apr 2021 20:51:17 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:51:05 -0400
Message-Id: <1617583870-32029-37-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
References: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 36/41] lnet: libcfs: discard cfs_firststr
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

The effect of cfs_firststr() can easily achieved with
skip_space() and strsep().

So use that instead.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: ee5eb07d2f41ac60 ("LU-6142 libcfs: discard cfs_firststr")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/40860
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/libcfs/libcfs_string.c | 28 ----------------------------
 1 file changed, 28 deletions(-)

diff --git a/net/lnet/libcfs/libcfs_string.c b/net/lnet/libcfs/libcfs_string.c
index b042de5..66a108c 100644
--- a/net/lnet/libcfs/libcfs_string.c
+++ b/net/lnet/libcfs/libcfs_string.c
@@ -115,34 +115,6 @@ int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
 	return 0;
 }
 
-/* get the first string out of @str */
-char *cfs_firststr(char *str, size_t size)
-{
-	size_t i = 0;
-	char *end;
-
-	/* trim leading spaces */
-	while (i < size && *str && isspace(*str)) {
-		++i;
-		++str;
-	}
-
-	/* string with all spaces */
-	if (*str == '\0')
-		goto out;
-
-	end = str;
-	while (i < size && *end != '\0' && !isspace(*end)) {
-		++i;
-		++end;
-	}
-
-	*end = '\0';
-out:
-	return str;
-}
-EXPORT_SYMBOL(cfs_firststr);
-
 /**
  * Extracts tokens from strings.
  *
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
