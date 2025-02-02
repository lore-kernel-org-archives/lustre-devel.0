Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id B921BC0218F
	for <lustre-devel@archiver.kernel.org>; Sun,  2 Feb 2025 20:50:14 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YmMCY4J3Mz20tw;
	Sun, 02 Feb 2025 12:48:09 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YmM9w3Q9hz1y8x
 for <lustre-devel@lists.lustre.org>; Sun, 02 Feb 2025 12:46:44 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm5-e204-208.ccs.ornl.gov [160.91.203.29])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id A583418232E;
 Sun,  2 Feb 2025 15:46:41 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id A13B2106BE18; Sun,  2 Feb 2025 15:46:41 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  2 Feb 2025 15:46:03 -0500
Message-ID: <20250202204633.1148872-4-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250202204633.1148872-1-jsimmons@infradead.org>
References: <20250202204633.1148872-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 03/33] lustre: llite: EIO is possible on a
 race with page reclaim
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
Cc: Andrew Perepechko <andrew.perepechko@hpe.com>,
 Alexander Zarochentsev <alexander.zarochentsev@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Patrick Farrell <pfarrell@whamcloud.com>

We must clear the 'uptodate' page flag when we delete a
page from Lustre, or stale reads can occur.  However,
generic_file_buffered_read requires any pages returned from
readpage() be uptodate.

So, we must retry reading if page truncation happens in
parallel with the read.

This implements the same fix as:
https://review.whamcloud.com/49647
commit e02cfe39f908 ("lustre: llite: SIGBUS is possible on a race with page reclaim")

did for the mmap path.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16649
Lustre-commit: 1d98e5c32b41e19bb ("LU-16649 llite: EIO is possible on a race with page reclaim")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50344
Reviewed-by: Andrew Perepechko <andrew.perepechko@hpe.com>
Reviewed-by: Qian Yingjin <qian@ddn.com>
Reviewed-by: Alexander Zarochentsev <alexander.zarochentsev@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd_support.h |  1 +
 fs/lustre/llite/file.c          | 11 +++++++----
 fs/lustre/llite/rw.c            |  8 ++++++++
 fs/lustre/llite/vvp_io.c        | 25 ++++++++++++++++++++++---
 4 files changed, 38 insertions(+), 7 deletions(-)

diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index cee7e3164d66..0a63af11db35 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -492,6 +492,7 @@ extern char obd_jobid_var[];
 #define OBD_FAIL_LLITE_PAGE_INVALIDATE_PAUSE		0x1421
 #define OBD_FAIL_LLITE_READPAGE_PAUSE			0x1422
 #define OBD_FAIL_LLITE_PANIC_ON_ESTALE			0x1423
+#define OBD_FAIL_LLITE_READPAGE_PAUSE2			0x1424
 
 #define OBD_FAIL_FID_INDIR				0x1501
 #define OBD_FAIL_FID_INLMA				0x1502
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index c99e9c01bc65..b2751b571ea9 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1990,12 +1990,15 @@ ll_do_fast_read(struct kiocb *iocb, struct iov_iter *iter)
 
 	result = generic_file_read_iter(iocb, iter);
 
-	/*
-	 * If the first page is not in cache, generic_file_aio_read() will be
-	 * returned with -ENODATA.
+	/* If the first page is not in cache, generic_file_aio_read() will be
+	 * returned with -ENODATA.  Fall back to full read path.
 	 * See corresponding code in ll_readpage().
+	 *
+	 * if we raced with page deletion, we might get EIO.  Rather than add
+	 * locking to the fast path for this rare case, fall back to the full
+	 * read path.  (See vvp_io_read_start() for rest of handling.
 	 */
-	if (result == -ENODATA)
+	if (result == -ENODATA || result == -EIO)
 		result = 0;
 
 	if (result > 0) {
diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index 0c73258428e6..92a9c252247e 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -2046,5 +2046,13 @@ int ll_readpage(struct file *file, struct page *vmpage)
 	if (ra.cra_release)
 		cl_read_ahead_release(env, &ra);
 
+	/* this delay gives time for the actual read of the page to finish and
+	 * unlock the page in vvp_page_completion_read before we return to our
+	 * caller and the caller tries to use the page, allowing us to test
+	 * races with the page being unlocked after readpage() but before it's
+	 * used by the caller
+	 */
+	OBD_FAIL_TIMEOUT(OBD_FAIL_LLITE_READPAGE_PAUSE2, cfs_fail_val);
+
 	return result;
 }
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index 26dfaaa76bd9..86dab3b1a39f 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -811,8 +811,10 @@ static int vvp_io_read_start(const struct lu_env *env,
 	size_t cnt = io->u.ci_rd.rd.crw_count;
 	size_t tot = vio->vui_tot_count;
 	struct ll_cl_context *lcc;
+	unsigned int seq;
 	int exceed = 0;
 	int result;
+	int total_bytes_read = 0;
 	struct iov_iter iter;
 	pgoff_t page_offset;
 
@@ -878,12 +880,29 @@ static int vvp_io_read_start(const struct lu_env *env,
 	lcc->lcc_end_index = DIV_ROUND_UP(pos + iter.count, PAGE_SIZE);
 	CDEBUG(D_VFSTRACE, "count:%ld iocb pos:%lld\n", iter.count, pos);
 
-	result = generic_file_read_iter(vio->vui_iocb, &iter);
+	/* this seqlock lets us notice if a page has been deleted on this inode
+	 * during the fault process, allowing us to catch an erroneous short
+	 * read or EIO
+	 * See LU-16160
+	 */
+	do {
+		seq = read_seqbegin(&ll_i2info(inode)->lli_page_inv_lock);
+		result = generic_file_read_iter(vio->vui_iocb, &iter);
+		if (result >= 0) {
+			io->ci_nob += result;
+			total_bytes_read += result;
+		}
+	/* if we got a short read or -EIO and we raced with page invalidation,
+	 * retry
+	 */
+	} while (read_seqretry(&ll_i2info(inode)->lli_page_inv_lock, seq) &&
+		 ((result >= 0 && iov_iter_count(&iter) > 0) ||
+		  result == -EIO));
+
 out:
 	if (result >= 0) {
-		if (result < cnt)
+		if (total_bytes_read < cnt)
 			io->ci_continue = 0;
-		io->ci_nob += result;
 		result = 0;
 	} else if (result == -EIOCBQUEUED) {
 		io->ci_nob += vio->u.readwrite.vui_read;
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
