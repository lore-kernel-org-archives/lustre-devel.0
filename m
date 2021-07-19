Return-Path: <SRS0=HxeM=ML=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D588CC07E9B
	for <lustre-devel@archiver.kernel.org>; Mon, 19 Jul 2021 12:32:57 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 99FE06112D
	for <lustre-devel@archiver.kernel.org>; Mon, 19 Jul 2021 12:32:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 99FE06112D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 47AA734FAB6;
	Mon, 19 Jul 2021 05:32:37 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 66B6834F976
 for <lustre-devel@lists.lustre.org>; Mon, 19 Jul 2021 05:32:20 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id AD5D86C8;
 Mon, 19 Jul 2021 08:32:15 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id A56D3BD1CC; Mon, 19 Jul 2021 08:32:15 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 19 Jul 2021 08:32:07 -0400
Message-Id: <1626697933-6971-13-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1626697933-6971-1-git-send-email-jsimmons@infradead.org>
References: <1626697933-6971-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 12/18] lnet: o2iblnd: Move racy NULL
 assignment
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
Cc: Mike Marciniszyn <mike.marciniszyn@cornelisnetworks.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mike Marciniszyn <mike.marciniszyn@cornelisnetworks.com>

kiblnd_fmr_pool_unmap() can race map and subsequent processing
because of this flaw in unmap:

if (frd) {
        frd->frd_valid = false;
        spin_lock(&fps->fps_lock);
        list_add_tail(&frd->frd_list, &fpo->fast_reg.fpo_pool_list);
        spin_unlock(&fps->fps_lock);
        fmr->fmr_frd = NULL;
}

The fmr can be pulled off the list in kiblnd_fmr_pool_unmap() on
another CPU an fmr_frd could be in a state of flux and
potentially be seen incorrectly later on as the kib_tx is processed.

Fix my moving the fmr_frd assignment to before the fmr is added to the
list.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14733
Lustre-commit: 023113fb8946f356 ("LU-14733 o2iblnd: Move racy NULL assignment")
Signed-off-by: Mike Marciniszyn <mike.marciniszyn@cornelisnetworks.com>
Reviewed-on: https://review.whamcloud.com/44189
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index d722e6c..81d9e4d 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1539,10 +1539,10 @@ void kiblnd_fmr_pool_unmap(struct kib_fmr *fmr, int status)
 	fps = fpo->fpo_owner;
 	if (frd) {
 		frd->frd_valid = false;
+		fmr->fmr_frd = NULL;
 		spin_lock(&fps->fps_lock);
 		list_add_tail(&frd->frd_list, &fpo->fast_reg.fpo_pool_list);
 		spin_unlock(&fps->fps_lock);
-		fmr->fmr_frd = NULL;
 	}
 	fmr->fmr_pool = NULL;
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
