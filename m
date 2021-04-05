Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E830C433B4
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:51:56 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 0D2D96138E
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:51:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D2D96138E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1C70D21F8E7;
	Mon,  5 Apr 2021 00:51:41 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 3110821FB85
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:26 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 077B6E35;
 Sun,  4 Apr 2021 20:51:17 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 0474F4436E; Sun,  4 Apr 2021 20:51:17 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:50:58 -0400
Message-Id: <1617583870-32029-30-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
References: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 29/41] lustre: llite: remove unused
 ll_teardown_mmaps()
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

The ll_teardown_mmaps() function is no longer used and can be
removed.

Fixes: d5419b40599b ("lustre: use generic_error_remove_page()")
WC-bug-id: https://jira.whamcloud.com/browse/LU-12477
Lustre-commit: 647c96562b27cef ("LU-12477 llite: remove unused ll_teardown_mmaps()")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/41086
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_internal.h |  1 -
 fs/lustre/llite/llite_mmap.c     | 17 -----------------
 2 files changed, 18 deletions(-)

diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 0fe0b562..3bd774b 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -1265,7 +1265,6 @@ void ll_io_init(struct cl_io *io, const struct file *file, int write,
 
 /* llite/llite_mmap.c */
 
-int ll_teardown_mmaps(struct address_space *mapping, u64 first, u64 last);
 int ll_file_mmap(struct file *file, struct vm_area_struct *vma);
 void policy_from_vma(union ldlm_policy_data *policy, struct vm_area_struct *vma,
 		     unsigned long addr, size_t count);
diff --git a/fs/lustre/llite/llite_mmap.c b/fs/lustre/llite/llite_mmap.c
index b9a73e0..0963757 100644
--- a/fs/lustre/llite/llite_mmap.c
+++ b/fs/lustre/llite/llite_mmap.c
@@ -511,23 +511,6 @@ static void ll_vm_close(struct vm_area_struct *vma)
 	pcc_vm_close(vma);
 }
 
-/* XXX put nice comment here.  talk about __free_pte -> dirty pages and
- * nopage's reference passing to the pte
- */
-int ll_teardown_mmaps(struct address_space *mapping, u64 first, u64 last)
-{
-	int rc = -ENOENT;
-
-	LASSERTF(last > first, "last %llu first %llu\n", last, first);
-	if (mapping_mapped(mapping)) {
-		rc = 0;
-		unmap_mapping_range(mapping, first + PAGE_SIZE - 1,
-				    last - first + 1, 0);
-	}
-
-	return rc;
-}
-
 static const struct vm_operations_struct ll_file_vm_ops = {
 	.fault			= ll_fault,
 	.page_mkwrite		= ll_page_mkwrite,
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
