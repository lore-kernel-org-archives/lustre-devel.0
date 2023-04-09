Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 96D97C77B70
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:29:02 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWLd5yWqz21Hj;
	Sun,  9 Apr 2023 05:16:57 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWHK1ppRz1yCH
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:14:05 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id E63551008278;
 Sun,  9 Apr 2023 08:13:27 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id E39C62B4; Sun,  9 Apr 2023 08:13:27 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:12:50 -0400
Message-Id: <1681042400-15491-11-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 10/40] lustre: llite: check truncated page in
 ->readpage()
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Qian Yingjin <qian@ddn.com>

The page end offset calculation in filemap_get_read_batch() was
off by one. This bug was introduced in commit v5.11-10234-gcbd59c48ae
("mm/filemap: use head pages in generic_file_buffered_read")

When a read is submitted with end offset 1048575, it calculates
the end page index for read of 256 where it should be 255. This
results in the readpage() call for the page with index 256 is over
stripe boundary and may not be covered by a DLM extent lock.

This happens in a corner race case: filemap_get_read_batch()
batches the page with index 256 for read, but later this page is
removed from page cache due to the lock protected it being revoked,
but has a reference count due to the batch.  This results in this
page in the read path is not covered by any DLM lock.

The solution is simple. We can check whether the page was
truncated and removed from page cache in ->readpage() by the
address_sapce pointer of the page. If it was truncated, return
AOP_TRUNCATED_PAGE to the upper caller.  This will cause the
kernel to retry to batch pages and the truncated page will not
be added as it was already removed from page cache of the file.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16412
Lustre-commit: 209afbe28b5f164bd ("LU-16412 llite: check truncated page in ->readpage()")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49433
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Zhenyu Xu <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h |  6 ++++--
 fs/lustre/llite/rw.c            | 35 +++++++++++++++++++++++++++++++++++
 fs/lustre/llite/rw26.c          |  7 +++++++
 3 files changed, 46 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index a2930c8..4ef5c61 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -458,8 +458,8 @@
 /* was	OBD_FAIL_LLOG_CATINFO_NET			0x1309 until 2.3 */
 #define OBD_FAIL_MDS_SYNC_CAPA_SL			0x1310
 #define OBD_FAIL_SEQ_ALLOC				0x1311
-#define OBD_FAIL_PLAIN_RECORDS			    0x1319
-#define OBD_FAIL_CATALOG_FULL_CHECK		    0x131a
+#define OBD_FAIL_PLAIN_RECORDS				0x1319
+#define OBD_FAIL_CATALOG_FULL_CHECK			0x131a
 
 #define OBD_FAIL_LLITE					0x1400
 #define OBD_FAIL_LLITE_FAULT_TRUNC_RACE			0x1401
@@ -488,6 +488,8 @@
 #define OBD_FAIL_LLITE_PAGE_ALLOC			0x1418
 #define OBD_FAIL_LLITE_OPEN_DELAY			0x1419
 #define OBD_FAIL_LLITE_XATTR_PAUSE			0x1420
+#define OBD_FAIL_LLITE_PAGE_INVALIDATE_PAUSE		0x1421
+#define OBD_FAIL_LLITE_READPAGE_PAUSE			0x1422
 
 #define OBD_FAIL_FID_INDIR				0x1501
 #define OBD_FAIL_FID_INLMA				0x1502
diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index 0b14ea6..dea2af1 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -1865,6 +1865,41 @@ int ll_readpage(struct file *file, struct page *vmpage)
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 	int result;
 
+	if (OBD_FAIL_PRECHECK(OBD_FAIL_LLITE_READPAGE_PAUSE)) {
+		unlock_page(vmpage);
+		OBD_FAIL_TIMEOUT(OBD_FAIL_LLITE_READPAGE_PAUSE, cfs_fail_val);
+		lock_page(vmpage);
+	}
+
+	/*
+	 * The @vmpage got truncated.
+	 * This is a kernel bug introduced since kernel 5.12:
+	 * comment: cbd59c48ae2bcadc4a7599c29cf32fd3f9b78251
+	 * ("mm/filemap: use head pages in generic_file_buffered_read")
+	 *
+	 * The page end offset calculation in filemap_get_read_batch() was off
+	 * by one.  When a read is submitted with end offset 1048575, then it
+	 * calculates the end page for read of 256 where it should be 255. This
+	 * results in the readpage() for the page with index 256 is over stripe
+	 * boundary and may not covered by a DLM extent lock.
+	 *
+	 * This happens in a corner race case: filemap_get_read_batch() adds
+	 * the page with index 256 for read which is not in the current read
+	 * I/O context, and this page is being invalidated and will be removed
+	 * from page cache due to the lock protected it being revoken. This
+	 * results in this page in the read path not covered by any DLM lock.
+	 *
+	 * The solution is simple. Check whether the page was truncated in
+	 * ->readpage(). If so, just return AOP_TRUNCATED_PAGE to the upper
+	 * caller. Then the kernel will retry to batch pages, and it will not
+	 * add the truncated page into batches as it was removed from page
+	 * cache of the file.
+	 */
+	if (vmpage->mapping != inode->i_mapping) {
+		unlock_page(vmpage);
+		return AOP_TRUNCATED_PAGE;
+	}
+
 	lcc = ll_cl_find(inode);
 	if (lcc) {
 		env = lcc->lcc_env;
diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index cadded4..6700717 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -96,6 +96,13 @@ static void ll_invalidatepage(struct page *vmpage, unsigned int offset,
 		}
 		cl_env_percpu_put(env);
 	}
+
+	if (OBD_FAIL_PRECHECK(OBD_FAIL_LLITE_PAGE_INVALIDATE_PAUSE)) {
+		unlock_page(vmpage);
+		OBD_FAIL_TIMEOUT(OBD_FAIL_LLITE_PAGE_INVALIDATE_PAUSE,
+				 cfs_fail_val);
+		lock_page(vmpage);
+	}
 }
 
 static int ll_releasepage(struct page *vmpage, gfp_t gfp_mask)
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
