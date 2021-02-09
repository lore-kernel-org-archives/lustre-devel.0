Return-Path: <SRS0=GtYW=HL=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0139C433E0
	for <lustre-devel@archiver.kernel.org>; Tue,  9 Feb 2021 00:55:02 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8734F64E77
	for <lustre-devel@archiver.kernel.org>; Tue,  9 Feb 2021 00:55:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8734F64E77
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D1E0130FAE5;
	Mon,  8 Feb 2021 16:54:54 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2DC3730F986
 for <lustre-devel@lists.lustre.org>; Mon,  8 Feb 2021 16:54:32 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 046451006EBD;
 Mon,  8 Feb 2021 19:54:29 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 00D6C4CC21; Mon,  8 Feb 2021 19:54:28 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  8 Feb 2021 19:54:25 -0500
Message-Id: <1612832067-1449-8-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1612832067-1449-1-git-send-email-jsimmons@infradead.org>
References: <1612832067-1449-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 7/9] lustre: obdclass: add option %H for jobid
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
Cc: Yang Sheng <ys@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Yang Sheng <ys@whamcloud.com>

Add a option %H to avoid jobid too long in some cases.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14339
Lustre-commit: cf72ee174bbf7e6 ("LU-14339 obdclass: add option %H for jobid")
Signed-off-by: Yang Sheng <ys@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/41262
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/jobid.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/obdclass/jobid.c b/fs/lustre/obdclass/jobid.c
index 3ee9d40..52ba398 100644
--- a/fs/lustre/obdclass/jobid.c
+++ b/fs/lustre/obdclass/jobid.c
@@ -206,6 +206,7 @@ static void jobid_prune_expedite(void)
  *   %e = executable
  *   %g = gid
  *   %h = hostname
+ *   %H = short hostname
  *   %j = per-session
  *   %p = pid
  *   %u = uid
@@ -222,7 +223,7 @@ static int jobid_interpret_string(const char *jobfmt, char *jobid,
 	char c;
 
 	while ((c = *jobfmt++) && joblen > 1) {
-		char f;
+		char f, *p;
 		int l;
 
 		if (isspace(c)) /* Don't allow embedded spaces */
@@ -232,6 +233,7 @@ static int jobid_interpret_string(const char *jobfmt, char *jobid,
 			*jobid = c;
 			joblen--;
 			jobid++;
+			*jobid = '\0';
 			continue;
 		}
 
@@ -247,6 +249,15 @@ static int jobid_interpret_string(const char *jobfmt, char *jobid,
 			l = snprintf(jobid, joblen, "%s",
 				     init_utsname()->nodename);
 			break;
+		case 'H': /* short hostname. Cut at first dot */
+			l = snprintf(jobid, joblen, "%s",
+				     init_utsname()->nodename);
+			p = strnchr(jobid, joblen, '.');
+			if (p) {
+				*p = '\0';
+				l = p - jobid;
+			}
+			break;
 		case 'j': /* jobid requested by process */
 			l = snprintf(jobid, joblen, "%s",
 				     jobid_current() ?: "jobid");
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
