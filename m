Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 98AADC433FE
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Jan 2022 01:39:27 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B42A73AD998;
	Thu, 13 Jan 2022 17:38:53 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id CC8C63AD7BC
 for <lustre-devel@lists.lustre.org>; Thu, 13 Jan 2022 17:38:11 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id E7314100F339;
 Thu, 13 Jan 2022 20:38:04 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id E5D31DF4C4; Thu, 13 Jan 2022 20:38:04 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 13 Jan 2022 20:37:57 -0500
Message-Id: <1642124283-10148-19-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
References: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 18/24] lnet: libcfs: set x->ls_len to 0 when
 x->ls_str is NULL
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

From: Etienne AUJAMES <eaujames@ddn.com>

cfs_gettok() set next->ls_str to NULL if no delimiter is found but
it does not update next->ls_len to 0.

This patch fix cfs_gettok() to update "next->ls_len = 0;" if no
delimiter is found.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15130
Lustre-commit: cec864b7938f1138d ("LU-15130 nrs: null pointer dereference in nrs_tbf_id_parse")
Signed-off-by: Etienne AUJAMES <eaujames@ddn.com>
Reviewed-on: https://review.whamcloud.com/45291
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/libcfs/libcfs_string.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/lnet/libcfs/libcfs_string.c b/net/lnet/libcfs/libcfs_string.c
index 4259f8b8..0563c42 100644
--- a/net/lnet/libcfs/libcfs_string.c
+++ b/net/lnet/libcfs/libcfs_string.c
@@ -154,6 +154,7 @@ int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
 		/* there is no the delimeter in the string */
 		end = next->ls_str + next->ls_len;
 		next->ls_str = NULL;
+		next->ls_len = 0;
 	} else {
 		next->ls_str = end + 1;
 		next->ls_len -= (end - res->ls_str + 1);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
