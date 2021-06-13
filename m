Return-Path: <SRS0=27wn=LH=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1CB9BC48BDF
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:12:20 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id D904161363
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:12:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D904161363
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E8A5B21F5DD;
	Sun, 13 Jun 2021 16:12:03 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E510521F1C6
 for <lustre-devel@lists.lustre.org>; Sun, 13 Jun 2021 16:11:45 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id D9551100B05B;
 Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id D85559C30D; Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 13 Jun 2021 19:11:29 -0400
Message-Id: <1623625897-17706-20-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
References: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 19/27] lnet: libcfs: allow comma-separated
 masks
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

From: Andreas Dilger <adilger@whamcloud.com>

For debug and changelog mask names, allow a comma-separated list
of names to be given, so that the space-separated list does not
need to be quoted for use.

Fix a couple of test cases where the debug parameter is set and
printed overly verbosely during tests.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13055
Lustre-commit: 6b6fde1026311a28 ("LU-13055 libcfs: allow comma-separated masks")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/43741
Reviewed-by: Emoly Liu <emoly@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/libcfs/libcfs_string.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/lnet/libcfs/libcfs_string.c b/net/lnet/libcfs/libcfs_string.c
index d2460f3..4259f8b8 100644
--- a/net/lnet/libcfs/libcfs_string.c
+++ b/net/lnet/libcfs/libcfs_string.c
@@ -52,14 +52,14 @@ int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
 	char op = '\0';
 	int newmask = minmask, i, len, found = 0;
 
-	/* <str> must be a list of tokens separated by whitespace
+	/* <str> must be a list of tokens separated by whitespace or comma,
 	 * and optionally an operator ('+' or '-').  If an operator
 	 * appears first in <str>, '*oldmask' is used as the starting point
 	 * (relative), otherwise minmask is used (absolute).  An operator
 	 * applies to all following tokens up to the next operator.
 	 */
 	while (*str != '\0') {
-		while (isspace(*str))
+		while (isspace(*str) || *str == ',')
 			str++;
 		if (*str == '\0')
 			break;
@@ -77,7 +77,7 @@ int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
 		/* find token length */
 		len = 0;
 		while (str[len] != '\0' && !isspace(str[len]) &&
-		       str[len] != '+' && str[len] != '-')
+		       str[len] != '+' && str[len] != '-' && str[len] != ',')
 			len++;
 
 		/* match token */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
