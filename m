Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 4E45EC433F5
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Jan 2022 01:38:41 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6B67B3AD9D0;
	Thu, 13 Jan 2022 17:38:30 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 10D8E3AD7BC
 for <lustre-devel@lists.lustre.org>; Thu, 13 Jan 2022 17:38:12 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id EB4FC100F33A;
 Thu, 13 Jan 2022 20:38:04 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id EA020A8102; Thu, 13 Jan 2022 20:38:04 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 13 Jan 2022 20:37:58 -0500
Message-Id: <1642124283-10148-20-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
References: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 19/24] lustre: uapi: set default max-inherit
 to 3
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
Cc: Lei Feng <flei@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Lei Feng <flei@whamcloud.com>

Change LMV_INHERIT_DEFAULT from 0 to 3. So that the default stripe
policy of dir will not be inherited unlimited and reduce performance
unexpectly.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15314
Lustre-commit: 956b4b1e0d9f18c6f ("LU-15314 utils: set default max-inherit to 3")
Signed-off-by: Lei Feng <flei@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/45874
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/uapi/linux/lustre/lustre_user.h | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 1e66930..3b53a5b 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -838,23 +838,25 @@ enum lmv_type {
  */
 enum {
 	/* for historical reason, 0 means unlimited inheritance */
-	LMV_INHERIT_UNLIMITED	= 0,
-	/* unlimited lum_max_inherit by default */
-	LMV_INHERIT_DEFAULT	= 0,
+	LMV_INHERIT_UNLIMITED		= 0,
+	/* unlimited lum_max_inherit by default for plain stripe (0 or 1) */
+	LMV_INHERIT_DEFAULT_PLAIN	= LMV_INHERIT_UNLIMITED,
 	/* not inherit any more */
-	LMV_INHERIT_END		= 1,
+	LMV_INHERIT_END			= 1,
+	/* for multiple stripes, the default lum_max_inherit is 3 */
+	LMV_INHERIT_DEFAULT_STRIPED	= 3,
 	/* max inherit depth */
-	LMV_INHERIT_MAX		= 250,
+	LMV_INHERIT_MAX			= 250,
 	/* [251, 254] are reserved */
 	/* not set, or when inherit depth goes beyond end,  */
-	LMV_INHERIT_NONE	= 255,
+	LMV_INHERIT_NONE		= 255,
 };
 
 enum {
 	/* not set, or when inherit_rr depth goes beyond end,  */
 	LMV_INHERIT_RR_NONE		= 0,
 	/* disable lum_max_inherit_rr by default */
-	LMV_INHERIT_RR_DEFAULT		= 0,
+	LMV_INHERIT_RR_DEFAULT		= LMV_INHERIT_RR_NONE,
 	/* not inherit any more */
 	LMV_INHERIT_RR_END		= 1,
 	/* default inherit_rr of ROOT */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
