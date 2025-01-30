Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id DBCC4C0218A
	for <lustre-devel@archiver.kernel.org>; Thu, 30 Jan 2025 14:48:13 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YkLjp239Lz22LJ;
	Thu, 30 Jan 2025 06:18:54 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YkLZw5yVwz1y22
 for <lustre-devel@lists.lustre.org>; Thu, 30 Jan 2025 06:12:56 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 2AFD5899ADB;
 Thu, 30 Jan 2025 09:11:33 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 27255106BE16; Thu, 30 Jan 2025 09:11:33 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 30 Jan 2025 09:11:08 -0500
Message-ID: <20250130141115.950749-19-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250130141115.950749-1-jsimmons@infradead.org>
References: <20250130141115.950749-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 18/25] lustre: llite: Check for page deletion
 after fault
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
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
Cc: Zhenyu Xu <bobijam@hotmail.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Patrick Farrell <pfarrell@whamcloud.com>

Before completing a page fault and returning to the kernel,
we lock the page and verify it has not been truncated.  But
we must also verify the page has not been deleted from
Lustre, or we can return a disconnected (ie, not tracked by
Lustre) page to the kernel.

We mark deleted pages !uptodate, but this doesn't matter
for faulted pages, because the kernel assumes they are
returned uptodate, and maps them in to the process address
space. Once mapped, the page state is not checked until
the page is unmapped.

But because the page is referenced by the mapping, it stays
in the page cache even though it's been disconnected from
Lustre.

Because the page is disconnected from Lustre, it will not
be found and cancelled on lock cancellation.  This can
result in stale data reads.

This is particularly an issue with releasepage (called from
drop_caches or under memory pressure), which can delete
pages separately from cancelling covering locks.

If releasepage is disabled, which is effectively what
"LU-14541 llite: Check vmpage in releasepage"
does, this is not an issue.  But disabling releasepage
causes other problems and is incorrect anyway.

Fixes: 9c78efe1a4 ("lustre: llite: Check vmpage in releasepage")
WC-bug-id: https://jira.whamcloud.com/browse/LU-14541
Lustre-commit: b3d2114e538cf95a7 ("LU-14541 llite: Check for page deletion after fault")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49653
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Qian Yingjin <qian@ddn.com>
Reviewed-by: Zhenyu Xu <bobijam@hotmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_mmap.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/llite/llite_mmap.c b/fs/lustre/llite/llite_mmap.c
index db069de1ef31..d6c1a6fd0794 100644
--- a/fs/lustre/llite/llite_mmap.c
+++ b/fs/lustre/llite/llite_mmap.c
@@ -418,15 +418,22 @@ static vm_fault_t ll_fault(struct vm_fault *vmf)
 	    !(result & (VM_FAULT_RETRY | VM_FAULT_ERROR | VM_FAULT_LOCKED))) {
 		struct page *vmpage = vmf->page;
 
-		/* check if this page has been truncated */
+		/* lock the page, then check if this page has been truncated
+		 * or deleted from Lustre and retry if so
+		 */
 		lock_page(vmpage);
-		if (unlikely(!vmpage->mapping)) { /* unlucky */
+		if (unlikely(vmpage->mapping == NULL) ||
+		    vmpage->private == 0) { /* unlucky */
 			unlock_page(vmpage);
 			put_page(vmpage);
 			vmf->page = NULL;
 
 			if (!printed && ++count > 16) {
-				CWARN("the page is under heavy contention, maybe your app(%s) needs revising :-)\n",
+				struct inode *inode = file_inode(vma->vm_file);
+
+				CWARN("%s: FID "DFID" under heavy mmap contention by '%s', consider revising IO pattern\n",
+				      ll_i2sbi(inode)->ll_fsname,
+				      PFID(&ll_i2info(inode)->lli_fid),
 				      current->comm);
 				printed = true;
 			}
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
