Return-Path: <SRS0=GtYW=HL=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70318C433DB
	for <lustre-devel@archiver.kernel.org>; Tue,  9 Feb 2021 00:55:00 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id F12D564E79
	for <lustre-devel@archiver.kernel.org>; Tue,  9 Feb 2021 00:54:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F12D564E79
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B114430F9BC;
	Mon,  8 Feb 2021 16:54:51 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E88B630F95B
 for <lustre-devel@lists.lustre.org>; Mon,  8 Feb 2021 16:54:32 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 094AE1006EC0;
 Mon,  8 Feb 2021 19:54:29 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 0791B4CC35; Mon,  8 Feb 2021 19:54:29 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  8 Feb 2021 19:54:27 -0500
Message-Id: <1612832067-1449-10-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1612832067-1449-1-git-send-email-jsimmons@infradead.org>
References: <1612832067-1449-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 9/9] lustre: lov: return stripe_count=1
 instead of 0 for DoM files
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

From: Emoly Liu <emoly@whamcloud.com>

Return stripe_count=1 instead of 0 for DoM files to avoid
divide-by-zero for older userspace that calls this ioctl,
e.g. lustre ADIO driver.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14337
Lustre-commit: b538826f2bdb39b ("LU-14337 lov: return stripe_count=1 instead of 0 for DoM files")
Signed-off-by: Emoly Liu <emoly@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/41265
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_pack.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/lustre/lov/lov_pack.c b/fs/lustre/lov/lov_pack.c
index d200a62..ffe9687 100644
--- a/fs/lustre/lov/lov_pack.c
+++ b/fs/lustre/lov/lov_pack.c
@@ -456,6 +456,14 @@ int lov_getstripe(const struct lu_env *env, struct lov_object *obj,
 		lmm = lmmk;
 		lmm_size = lmmk_size;
 	}
+
+	/**
+	 * Return stripe_count=1 instead of 0 for DoM files to avoid
+	 * divide-by-zero for older userspace that calls this ioctl,
+	 * e.g. lustre ADIO driver.
+	 */
+	if ((lum.lmm_stripe_count == 0) && (lum.lmm_pattern & LOV_PATTERN_MDT))
+		lum.lmm_stripe_count = 1;
 	/**
 	 * User specified limited buffer size, usually the buffer is
 	 * from ll_lov_setstripe(), and the buffer can only hold basic
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
