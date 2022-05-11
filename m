Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 3B44FC433FE
	for <lustre-devel@archiver.kernel.org>; Wed, 11 May 2022 19:38:57 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id ABFB321C993;
	Wed, 11 May 2022 12:38:54 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 97C2A216163
 for <lustre-devel@lists.lustre.org>; Wed, 11 May 2022 12:38:48 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 97D04ED7;
 Wed, 11 May 2022 15:38:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 89C2C58951; Wed, 11 May 2022 15:38:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>, Sebastien Buisson <sbuisson@ddn.com>
Date: Wed, 11 May 2022 15:38:42 -0400
Message-Id: <1652297923-16141-5-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1652297923-16141-1-git-send-email-jsimmons@infradead.org>
References: <1652297923-16141-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 4/5] lustre: llite: disable fast_read and
 workaround
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

From: "John L. Hammond" <jhammond@whamcloud.com>

Revert the fast_read stale data workaround from LU-14541 and disable
fast_read by default. The workaround causes applications to receive
spurious SIGBUGs when reclaim is concurrent with mmap page fault
handlers. We disable fast read to avoid the stale data issue entirely.

This reverts commit 15caffd4dc36c45f53458c2d6493f07b95acf507 and
re-exposes us to the consistency issues described in LU-14541.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15815
Lustre-commit: 201ade9442828fbb3 ("LU-15815 llite: disable fast_read and workaround")
Signed-off-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/47204
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_lib.c | 2 +-
 fs/lustre/llite/vvp_page.c  | 6 ------
 2 files changed, 1 insertion(+), 7 deletions(-)

diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index ad77ef0..4578a9e 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -169,7 +169,7 @@ static struct ll_sb_info *ll_init_sbi(void)
 	atomic_set(&sbi->ll_sa_running, 0);
 	atomic_set(&sbi->ll_agl_total, 0);
 	set_bit(LL_SBI_AGL_ENABLED, sbi->ll_flags);
-	set_bit(LL_SBI_FAST_READ, sbi->ll_flags);
+	/* Disable LL_SBI_FAST_READ by default, see LU-15815. */
 	set_bit(LL_SBI_TINY_WRITE, sbi->ll_flags);
 	set_bit(LL_SBI_PARALLEL_DIO, sbi->ll_flags);
 	ll_sbi_set_encrypt(sbi, true);
diff --git a/fs/lustre/llite/vvp_page.c b/fs/lustre/llite/vvp_page.c
index 1e95ede..7744e9b 100644
--- a/fs/lustre/llite/vvp_page.c
+++ b/fs/lustre/llite/vvp_page.c
@@ -164,12 +164,6 @@ static void vvp_page_delete(const struct lu_env *env,
 
 	ClearPagePrivate(vmpage);
 	vmpage->private = 0;
-
-	/**
-	 * Vmpage might not be released due page refcount != 2,
-	 * clear Page uptodate here to avoid stale data.
-	 */
-	ClearPageUptodate(vmpage);
 	/*
 	 * Reference from vmpage to cl_page is removed, but the reference back
 	 * is still here. It is removed later in vvp_page_fini().
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
