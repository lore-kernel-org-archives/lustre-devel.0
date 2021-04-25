Return-Path: <SRS0=Gt0B=JW=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C949CC433B4
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:09:08 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7344C6124B
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:09:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7344C6124B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0679821F7FB;
	Sun, 25 Apr 2021 13:08:58 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9248D21F513
 for <lustre-devel@lists.lustre.org>; Sun, 25 Apr 2021 13:08:43 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 15BDC10084FC;
 Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 0A5D969A91; Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 25 Apr 2021 16:08:14 -0400
Message-Id: <1619381316-7719-8-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
References: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 07/29] lustre: readahead: limit over
 reservation
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

For performance reason, exceeding @ra_max_pages are allowed to
cover current read window, but this should be limited with RPC
size in case a large block size read issued. Trim to RPC boundary.

Otherwise, too many read ahead pages might be issued and
make client short of LRU pages.

Fixes: 35b7c43c21 ("lustre: llite: allow current readahead to exceed reservation")
WC-bug-id: https://jira.whamcloud.com/browse/LU-12142
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/42060
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/lproc_llite.c | 10 ++++++++--
 fs/lustre/llite/rw.c          |  8 ++++++++
 2 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index ec241a4..4ce6fab 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -455,6 +455,7 @@ static int ll_max_cached_mb_seq_show(struct seq_file *m, void *v)
 	struct super_block *sb = m->private;
 	struct ll_sb_info *sbi = ll_s2sbi(sb);
 	struct cl_client_cache *cache = sbi->ll_cache;
+	struct ll_ra_info *ra = &sbi->ll_ra_info;
 	long max_cached_mb;
 	long unused_mb;
 
@@ -462,17 +463,22 @@ static int ll_max_cached_mb_seq_show(struct seq_file *m, void *v)
 	max_cached_mb = PAGES_TO_MiB(cache->ccc_lru_max);
 	unused_mb = PAGES_TO_MiB(atomic_long_read(&cache->ccc_lru_left));
 	mutex_unlock(&cache->ccc_max_cache_mb_lock);
+
 	seq_printf(m,
 		   "users: %d\n"
 		   "max_cached_mb: %ld\n"
 		   "used_mb: %ld\n"
 		   "unused_mb: %ld\n"
-		   "reclaim_count: %u\n",
+		   "reclaim_count: %u\n"
+		   "max_read_ahead_mb: %lu\n"
+		   "used_read_ahead_mb: %d\n",
 		   refcount_read(&cache->ccc_users),
 		   max_cached_mb,
 		   max_cached_mb - unused_mb,
 		   unused_mb,
-		   cache->ccc_lru_shrinkers);
+		   cache->ccc_lru_shrinkers,
+		   PAGES_TO_MiB(ra->ra_max_pages),
+		   PAGES_TO_MiB(atomic_read(&ra->ra_cur_pages)));
 	return 0;
 }
 
diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index 8bba97f..2d08767 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -788,6 +788,14 @@ static int ll_readahead(const struct lu_env *env, struct cl_io *io,
 			vio->vui_ra_start_idx + vio->vui_ra_pages - 1;
 		pages_min = vio->vui_ra_start_idx + vio->vui_ra_pages -
 			    ria->ria_start_idx;
+		/**
+		 * For performance reason, exceeding @ra_max_pages
+		 * are allowed, but this should be limited with RPC
+		 * size in case a large block size read issued. Trim
+		 * to RPC boundary.
+		 */
+		pages_min = min(pages_min, ras->ras_rpc_pages -
+				(ria->ria_start_idx % ras->ras_rpc_pages));
 	}
 
 	/* don't over reserved for mmap range read */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
