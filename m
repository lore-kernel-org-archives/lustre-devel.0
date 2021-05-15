Return-Path: <SRS0=EXfh=KK=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC30FC433ED
	for <lustre-devel@archiver.kernel.org>; Sat, 15 May 2021 13:06:26 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3933361287
	for <lustre-devel@archiver.kernel.org>; Sat, 15 May 2021 13:06:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3933361287
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6D7AF21F9E8;
	Sat, 15 May 2021 06:06:20 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 7913321CAD2
 for <lustre-devel@lists.lustre.org>; Sat, 15 May 2021 06:06:15 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 8823F100677B;
 Sat, 15 May 2021 09:06:12 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 7B7139815B; Sat, 15 May 2021 09:06:12 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sat, 15 May 2021 09:06:03 -0400
Message-Id: <1621083970-32463-7-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1621083970-32463-1-git-send-email-jsimmons@infradead.org>
References: <1621083970-32463-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 06/13] lustre: readahead: fix reserving for
 unaliged read
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
Cc: Wang Shilong <wshilong@ddn.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Wang Shilong <wshilong@ddn.com>

If read is [2K, 3K] on x86 platform, we only need
read one page, but it was calculated as 2 pages.

This could be problem, as we need reserve more
pages credits, vvp_page_completion_read() will only
free actual reading pages, which cause @ra_cur_pages
leaked.

Fixes: cc603a90cca ("lustre: llite: Fix page count for unaligned reads")
WC-bug-id: https://jira.whamcloud.com/browse/LU-14616
Lustre-commit: 5e7e9240d27a4b74 ("LU-14616 readahead: fix reserving for unaliged read")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/43377
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/rw.c     |  7 +++++++
 fs/lustre/llite/vvp_io.c | 18 ++++++++++++------
 2 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index 8dcbef3..184e5e8 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -90,6 +90,13 @@ static unsigned long ll_ra_count_get(struct ll_sb_info *sbi,
 	 * LRU pages, otherwise, it could cause deadlock.
 	 */
 	pages = min(sbi->ll_cache->ccc_lru_max >> 2, pages);
+	/**
+	 * if this happen, we reserve more pages than needed,
+	 * this will make us leak @ra_cur_pages, because
+	 * ll_ra_count_put() acutally freed @pages.
+	 */
+	if (WARN_ON_ONCE(pages_min > pages))
+		pages_min = pages;
 
 	/*
 	 * If read-ahead pages left are less than 1M, do not do read-ahead,
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index e98792b..12a28d9 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -798,6 +798,7 @@ static int vvp_io_read_start(const struct lu_env *env,
 	int exceed = 0;
 	int result;
 	struct iov_iter iter;
+	pgoff_t page_offset;
 
 	CLOBINVRNT(env, obj, vvp_object_invariant(obj));
 
@@ -839,15 +840,20 @@ static int vvp_io_read_start(const struct lu_env *env,
 	if (!vio->vui_ra_valid) {
 		vio->vui_ra_valid = true;
 		vio->vui_ra_start_idx = cl_index(obj, pos);
-		vio->vui_ra_pages = cl_index(obj, tot + PAGE_SIZE - 1);
-		/* If both start and end are unaligned, we read one more page
-		 * than the index math suggests.
-		 */
-		if ((pos & ~PAGE_MASK) != 0 && ((pos + tot) & ~PAGE_MASK) != 0)
+		vio->vui_ra_pages = 0;
+		page_offset = pos & ~PAGE_MASK;
+		if (page_offset) {
 			vio->vui_ra_pages++;
+			if (tot > PAGE_SIZE - page_offset)
+				tot -= (PAGE_SIZE - page_offset);
+			else
+				tot = 0;
+		}
+		vio->vui_ra_pages += (tot + PAGE_SIZE - 1) >> PAGE_SHIFT;
 
 		CDEBUG(D_READA, "tot %zu, ra_start %lu, ra_count %lu\n",
-		       tot, vio->vui_ra_start_idx, vio->vui_ra_pages);
+		       vio->vui_tot_count, vio->vui_ra_start_idx,
+		       vio->vui_ra_pages);
 	}
 
 	/* BUG: 5972 */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
