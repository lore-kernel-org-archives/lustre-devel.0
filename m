Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 16171C433EF
	for <lustre-devel@archiver.kernel.org>; Sun, 28 Nov 2021 23:28:36 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2F422205743;
	Sun, 28 Nov 2021 15:28:21 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 7D046200E3B
 for <lustre-devel@lists.lustre.org>; Sun, 28 Nov 2021 15:28:00 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 95AB9245;
 Sun, 28 Nov 2021 18:27:56 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 8F167C1AC4; Sun, 28 Nov 2021 18:27:56 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 28 Nov 2021 18:27:41 -0500
Message-Id: <1638142074-5945-7-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1638142074-5945-1-git-send-email-jsimmons@infradead.org>
References: <1638142074-5945-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 06/19] lustre: llite: tighten condition for
 fault not drop mmap_sem
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

From: Bobi Jam <bobijam@whamcloud.com>

As __lock_page_or_retry() indicates, filemap_fault() will return
VM_FAULT_RETRY without releasing mmap_sem iff flags contains
FAULT_FLAG_ALLOW_RETRY and FAULT_FLAG_RETRY_NOWAIT.

So ll_fault0() should pass in FAULT_FLAG_ALLOW_RETRY |
FAULT_FLAG_RETRY_NOWAIT in ll_filemap_fault() so that when it
returns VM_FAULT_RETRY, we can pass on trying normal fault
under DLM lock as mmap_sem is still being held.

While in Linux 5.1 (6b4c9f4469819) FAULT_FLAG_RETRY_NOWAIT is enough
to not drop mmap_sem when failed to lock the page.

Fixes: 22cceab961 ("lustre: llite: Avoid eternel retry loops with MAP_POPULATE")
WC-bug-id: https://jira.whamcloud.com/browse/LU-14713
Lustre-commit: 81aec05103558f57a ("LU-14713 llite: tighten condition for fault not drop mmap_sem")
Signed-off-by: Bobi Jam <bobijam@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/44715
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_mmap.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/llite/llite_mmap.c b/fs/lustre/llite/llite_mmap.c
index 8047786..0009c5f 100644
--- a/fs/lustre/llite/llite_mmap.c
+++ b/fs/lustre/llite/llite_mmap.c
@@ -285,18 +285,25 @@ static vm_fault_t __ll_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 
 	if (ll_sbi_has_fast_read(ll_i2sbi(inode))) {
 		/* do fast fault */
+		bool allow_retry = vmf->flags & FAULT_FLAG_ALLOW_RETRY;
 		bool has_retry = vmf->flags & FAULT_FLAG_RETRY_NOWAIT;
 
 		/* To avoid loops, instruct downstream to not drop mmap_sem */
-		vmf->flags |= FAULT_FLAG_RETRY_NOWAIT;
+		/**
+		 * only need FAULT_FLAG_ALLOW_RETRY prior to Linux 5.1
+		 * (6b4c9f4469819), where FAULT_FLAG_RETRY_NOWAIT is enough
+		 * to not drop mmap_sem when failed to lock the page.
+		 */
+		vmf->flags |= FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT;
 		ll_cl_add(inode, env, NULL, LCC_MMAP);
 		fault_ret = filemap_fault(vmf);
 		ll_cl_remove(inode, env);
 		if (has_retry)
 			vmf->flags &= ~FAULT_FLAG_RETRY_NOWAIT;
+		if (!allow_retry)
+			vmf->flags &= ~FAULT_FLAG_ALLOW_RETRY;
 
-		/*
-		 * - If there is no error, then the page was found in cache and
+		/* - If there is no error, then the page was found in cache and
 		 *   uptodate;
 		 * - If VM_FAULT_RETRY is set, the page existed but failed to
 		 *   lock. We will try slow path to avoid loops.
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
