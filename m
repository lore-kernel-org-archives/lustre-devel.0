Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 57308C77B70
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:17:00 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWHR3mHCz1yD2;
	Sun,  9 Apr 2023 05:14:11 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWGq1npkz1y6k
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:13:39 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id D737D1008271;
 Sun,  9 Apr 2023 08:13:27 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id CB18B2B6; Sun,  9 Apr 2023 08:13:27 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:12:45 -0400
Message-Id: <1681042400-15491-6-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 05/40] lustre: readahead: add stats for
 read-ahead page count
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

This patch adds the stats for read-ahead page count:

lctl get_param llite.*.read_ahead_stats
llite.lustre-ffff938b7849d000.read_ahead_stats=
snapshot_time           4011.320890492 secs.nsecs
start_time              0.000000000 secs.nsecs
elapsed_time            4011.320890492 secs.nsecs
hits                    4 samples [pages]
misses                  1 samples [pages]
zero_size_window        4 samples [pages]
failed_to_reach_end     1 samples [pages]
failed_to_fast_read     1 samples [pages]
readahead_pages         1 samples [pages] 255 255 255

WC-bug-id: https://jira.whamcloud.com/browse/LU-16338
Lustre-commit: cdcf97e17e73dfdd6 ("LU-16338 readahead: add stats for read-ahead page count")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49224
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <farr0186@gmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_internal.h |  1 +
 fs/lustre/llite/lproc_llite.c    | 15 ++++++++++++---
 fs/lustre/llite/rw.c             | 12 ++++++++++++
 3 files changed, 25 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 0dac71d..1d85d0b 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -578,6 +578,7 @@ enum ra_stat {
 	RA_STAT_ASYNC,
 	RA_STAT_FAILED_FAST_READ,
 	RA_STAT_MMAP_RANGE_READ,
+	RA_STAT_READAHEAD_PAGES,
 	_NR_RA_STAT,
 };
 
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 3d64a93..70dbc87 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -1858,6 +1858,7 @@ void ll_stats_ops_tally(struct ll_sb_info *sbi, int op, long count)
 	[RA_STAT_ASYNC]			= "async readahead",
 	[RA_STAT_FAILED_FAST_READ]	= "failed to fast read",
 	[RA_STAT_MMAP_RANGE_READ]	= "mmap range read",
+	[RA_STAT_READAHEAD_PAGES]	= "readahead_pages",
 };
 
 int ll_debugfs_register_super(struct super_block *sb, const char *name)
@@ -1911,9 +1912,17 @@ int ll_debugfs_register_super(struct super_block *sb, const char *name)
 		goto out_stats;
 	}
 
-	for (id = 0; id < ARRAY_SIZE(ra_stat_string); id++)
-		lprocfs_counter_init(sbi->ll_ra_stats, id, LPROCFS_TYPE_PAGES,
-				     ra_stat_string[id]);
+	for (id = 0; id < ARRAY_SIZE(ra_stat_string); id++) {
+		if (id == RA_STAT_READAHEAD_PAGES)
+			lprocfs_counter_init(sbi->ll_ra_stats, id,
+					     LPROCFS_TYPE_PAGES |
+					     LPROCFS_CNTR_AVGMINMAX,
+					     ra_stat_string[id]);
+		else
+			lprocfs_counter_init(sbi->ll_ra_stats, id,
+					     LPROCFS_TYPE_PAGES,
+					     ra_stat_string[id]);
+	}
 
 	debugfs_create_file("read_ahead_stats", 0644, sbi->ll_debugfs_entry,
 			    sbi->ll_ra_stats, &lprocfs_stats_seq_fops);
diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index 2290b31..0b14ea6 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -150,6 +150,14 @@ void ll_ra_stats_inc(struct inode *inode, enum ra_stat which)
 	ll_ra_stats_inc_sbi(sbi, which);
 }
 
+void ll_ra_stats_add(struct inode *inode, enum ra_stat which, long count)
+{
+	struct ll_sb_info *sbi = ll_i2sbi(inode);
+
+	LASSERTF(which < _NR_RA_STAT, "which: %u\n", which);
+	lprocfs_counter_add(sbi->ll_ra_stats, which, count);
+}
+
 #define RAS_CDEBUG(ras) \
 	CDEBUG(D_READA,							     \
 	       "lre %llu cr %lu cb %llu wsi %lu wp %lu nra %lu rpc %lu r %lu csr %lu so %llu sb %llu sl %llu lr %lu\n", \
@@ -528,6 +536,10 @@ static bool ras_inside_ra_window(pgoff_t idx, struct ra_io_arg *ria)
 	}
 	cl_read_ahead_release(env, &ra);
 
+	if (count)
+		ll_ra_stats_add(vvp_object_inode(io->ci_obj),
+				RA_STAT_READAHEAD_PAGES, count);
+
 	return count;
 }
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
