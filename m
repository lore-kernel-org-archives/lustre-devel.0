From: James Simmons <jsimmons@infradead.org>
Date: Sun, 25 Nov 2018 21:48:21 -0500
Subject: [lustre-devel] [PATCH 05/12] lustre: llite: avoid duplicate stats
 debugfs registration
In-Reply-To: <1543200508-6838-1-git-send-email-jsimmons@infradead.org>
References: <1543200508-6838-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1543200508-6838-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The unwinding of debugfs handling in llite introduced a bug. Two
different debugfs files are currently being registered with the
same name "stats". Change the registration of the ll_ra_stats
debugfs file to its proper name "read_ahead_stats".

Fixes: cd514eac8029 ("staging: lustre: remove ldebugfs_register_stats() wrapper function")
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/lproc_llite.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 10dc7a8..8139f84 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -1381,7 +1381,7 @@ int ll_debugfs_register_super(struct super_block *sb, const char *name)
 		lprocfs_counter_init(sbi->ll_ra_stats, id, 0,
 				     ra_stat_string[id], "pages");
 
-	debugfs_create_file("stats", 0644, sbi->ll_debugfs_entry,
+	debugfs_create_file("read_ahead_stats", 0644, sbi->ll_debugfs_entry,
 			    sbi->ll_ra_stats, &lprocfs_stats_seq_fops);
 out_ll_kset:
 	/* Yes we also register sysfs mount kset here as well */
-- 
1.8.3.1
