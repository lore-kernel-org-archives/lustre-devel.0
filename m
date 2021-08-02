Return-Path: <SRS0=Kfxm=MZ=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFE5FC4320A
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:52:08 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 970EB60FC2
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:52:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 970EB60FC2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 13E0D352F56;
	Mon,  2 Aug 2021 12:51:48 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 5ABAB352BD9
 for <lustre-devel@lists.lustre.org>; Mon,  2 Aug 2021 12:50:59 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 79AFC1008052;
 Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 78566C2F55; Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  2 Aug 2021 15:50:37 -0400
Message-Id: <1627933851-7603-18-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
References: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 17/25] lnet: check memdup_user_nul using
 IS_ERR
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
Cc: Cyril Bordage <cbordage@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Cyril Bordage <cbordage@whamcloud.com>

Crash in proc_lnet_portal_rotor. memdup_user_nul returns an ERR_PTR
on error, not a NULL pointer. IS_ERR and PTR_ERR functions have to be
used to check and return the correct error code. The fix has been
applied in other locations having the wrong check.

Fixes: 986fbf5bf19 ("lnet: libcfs: discard cfs_trace_copyin_string()")
WC-bug-id: https://jira.whamcloud.com/browse/LU-14788
Lustre-commit: 449d046e55a42cc4 ("LU-14788 lnet: check memdup_user_nul using IS_ERR")
Signed-off-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/44091
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/libcfs/module.c    | 4 ++--
 net/lnet/libcfs/tracefile.c | 8 ++++----
 net/lnet/lnet/router_proc.c | 4 ++--
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/lnet/libcfs/module.c b/net/lnet/libcfs/module.c
index 8059569..a249bdd 100644
--- a/net/lnet/libcfs/module.c
+++ b/net/lnet/libcfs/module.c
@@ -317,8 +317,8 @@ static int proc_dobitmasks(struct ctl_table *table, int write,
 		}
 	} else {
 		tmpstr = memdup_user_nul(buffer, nob);
-		if (!tmpstr)
-			return -ENOMEM;
+		if (IS_ERR(tmpstr))
+			return PTR_ERR(tmpstr);
 
 		rc = libcfs_debug_str2mask(mask, strim(tmpstr), is_subsys);
 		/* Always print LBUG/LASSERT to console, so keep this mask */
diff --git a/net/lnet/libcfs/tracefile.c b/net/lnet/libcfs/tracefile.c
index 6321840..e0ef234 100644
--- a/net/lnet/libcfs/tracefile.c
+++ b/net/lnet/libcfs/tracefile.c
@@ -942,8 +942,8 @@ int cfs_trace_dump_debug_buffer_usrstr(void __user *usr_str, int usr_str_nob)
 	int rc;
 
 	str = memdup_user_nul(usr_str, usr_str_nob);
-	if (!str)
-		return -ENOMEM;
+	if (IS_ERR(str))
+		return PTR_ERR(str);
 
 	path = strim(str);
 	if (path[0] != '/')
@@ -1001,8 +1001,8 @@ int cfs_trace_daemon_command_usrstr(void __user *usr_str, int usr_str_nob)
 	int rc;
 
 	str = memdup_user_nul(usr_str, usr_str_nob);
-	if (!str)
-		return -ENOMEM;
+	if (IS_ERR(str))
+		return PTR_ERR(str);
 
 	rc = cfs_trace_daemon_command(str);
 	kfree(str);
diff --git a/net/lnet/lnet/router_proc.c b/net/lnet/lnet/router_proc.c
index dd52a08..0de6681 100644
--- a/net/lnet/lnet/router_proc.c
+++ b/net/lnet/lnet/router_proc.c
@@ -816,8 +816,8 @@ static int proc_lnet_portal_rotor(struct ctl_table *table, int write,
 	}
 
 	buf = memdup_user_nul(buffer, nob);
-	if (!buf)
-		return -ENOMEM;
+	if (IS_ERR(buf))
+		return PTR_ERR(buf);
 
 	tmp = strim(buf);
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
