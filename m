Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 324A6C433ED
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:03:40 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id E44EF610CB
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:03:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E44EF610CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 61B2532F74E;
	Wed, 14 Apr 2021 21:03:19 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 79DF132F4D3
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:51 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 724E2100F351;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 70E109188E; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:08 -0400
Message-Id: <1618459361-17909-17-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 16/49] lustre: lmv: striped directory as
 subdirectory mount
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
Cc: Lai Siyao <lai.siyao@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Lai Siyao <lai.siyao@whamcloud.com>

lmv_intent_lookup() will replace fid1 with stripe FID, but if striped
directory is mounted as subdirectory mount, it should be handled
differently. Because fid2 is directory master object, if stripe is
located on different MDT as master object, it will be treated as
remote object by server, thus server won't reply LOOKUP lock back,
therefore each file access needs to lookup "/".

And remote directory (either plain or striped) shouldn't be used for
subdirectory mount, because remote object can't get LOOKUP lock.
Add an option "mdt_enable_remote_subdir_mount" (1 by default for
backward compatibility), mdt_get_root() will return -EREMOTE if
user specified subdir is a remote directory and this option is
disabled.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14490
Lustre-commit: 775f88ed6c8b623 ("LU-14490 lmv: striped directory as subdirectory mount")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/41893
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Yingjin Qian <qian@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lmv/lmv_intent.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/lmv/lmv_intent.c b/fs/lustre/lmv/lmv_intent.c
index 38b8c75..2a15ec2 100644
--- a/fs/lustre/lmv/lmv_intent.c
+++ b/fs/lustre/lmv/lmv_intent.c
@@ -451,11 +451,20 @@ static int lmv_intent_lookup(struct obd_export *exp,
 
 retry:
 	if (op_data->op_flags & MF_GETATTR_BY_FID) {
-		/* getattr by FID, replace fid1 with stripe FID */
+		/* getattr by FID, replace fid1 with stripe FID,
+		 * NB, don't replace if name is "/", because it may be a subtree
+		 * mount, and if it's a striped directory, fid1 will be replaced
+		 * to stripe FID by hash, while fid2 is master object FID, which
+		 * will be treated as a remote object if the two FIDs are
+		 * located on different MDTs, and LOOKUP lock can't be fetched.
+		 */
 		LASSERT(op_data->op_name);
-		tgt = lmv_locate_tgt(lmv, op_data);
-		if (IS_ERR(tgt))
-			return PTR_ERR(tgt);
+		if (op_data->op_namelen != 1 ||
+		    strncmp(op_data->op_name, "/", 1) != 0) {
+			tgt = lmv_locate_tgt(lmv, op_data);
+			if (IS_ERR(tgt))
+				return PTR_ERR(tgt);
+		}
 
 		/* name is used to locate stripe target, clear it here
 		 * to avoid packing name in request, so that MDS knows
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
