Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C555C433ED
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:52:02 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id CF6F461398
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:52:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF6F461398
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 56577328AAD;
	Mon,  5 Apr 2021 00:51:44 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 3C04621F521
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:19 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 9799B6B9;
 Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 8E55790AB2; Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:50:33 -0400
Message-Id: <1617583870-32029-5-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
References: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 04/41] lustre: llite: quiet spurious ioctl
 warning
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

Calling "lfs setstripe" prints a suprious warning about using the old
ioctl(LL_IOC_LOV_GETSTRIPE) when that is not actually the case.

Remove the ioctl warning for now and deal with related issues later.

Fixes: 1288417cb488 ("lustre: llite: restore ll_file_getstripe in ll_lov_setstripe")
WC-bug-id: https://jira.whamcloud.com/browse/LU-14316
Lustre-commit: c6f65d8af11647 ("LU-14316 llite: quiet spurious ioctl warning")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/41427
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_pack.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/fs/lustre/lov/lov_pack.c b/fs/lustre/lov/lov_pack.c
index ffe9687..1962472 100644
--- a/fs/lustre/lov/lov_pack.c
+++ b/fs/lustre/lov/lov_pack.c
@@ -351,7 +351,6 @@ int lov_getstripe(const struct lu_env *env, struct lov_object *obj,
 	struct lov_user_md_v1 lum;
 	size_t lmmk_size, lum_size = 0;
 	ssize_t lmm_size;
-	static bool printed;
 	int rc = 0;
 
 	if (lsm->lsm_magic != LOV_MAGIC_V1 && lsm->lsm_magic != LOV_MAGIC_V3 &&
@@ -363,13 +362,6 @@ int lov_getstripe(const struct lu_env *env, struct lov_object *obj,
 		goto out;
 	}
 
-	if (!printed) {
-		LCONSOLE_WARN("%s: using old ioctl(LL_IOC_LOV_GETSTRIPE) on " DFID ", use llapi_layout_get_by_path()\n",
-			      current->comm,
-			      PFID(&obj->lo_cl.co_lu.lo_header->loh_fid));
-		printed = true;
-	}
-
 	lmmk_size = lov_comp_md_size(lsm);
 	lmmk = kvzalloc(lmmk_size, GFP_KERNEL);
 	if (!lmmk) {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
