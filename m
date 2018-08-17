From: James Simmons <jsimmons@infradead.org>
Date: Thu, 16 Aug 2018 23:10:12 -0400
Subject: [lustre-devel] [PATCH 09/38] lustre: llite: add proper error
 handling for ll_debugfs_register_super()
In-Reply-To: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1534475441-15543-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Having the single out label that cleans up everything is not proper
kernel style and can create more bugs. Instead just cleanup the items
we created only by introducing multiple goto label that handle specific
cleanups.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Reviewed-on: https://review.whamcloud.com/24031
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/lproc_llite.c | 34 +++++++++++++++--------
 1 file changed, 22 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 4186a8d..5530156 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -1235,9 +1235,14 @@ int ll_debugfs_register_super(struct super_block *sb, const char *name)
 
 	LASSERT(sbi);
 
+	if (IS_ERR_OR_NULL(llite_root))
+		goto out_ll_kset;
+
 	dir = debugfs_create_dir(name, llite_root);
 	sbi->ll_debugfs_entry = dir;
 
+	ldebugfs_add_vars(sbi->ll_debugfs_entry, lprocfs_llite_obd_vars, sb);
+
 	debugfs_create_file("dump_page_cache", 0444, dir, sbi,
 			    &vvp_dump_pgcache_file_ops);
 	debugfs_create_file("extents_stats", 0644, dir, sbi,
@@ -1252,8 +1257,9 @@ int ll_debugfs_register_super(struct super_block *sb, const char *name)
 					    LPROCFS_STATS_FLAG_NONE);
 	if (!sbi->ll_stats) {
 		err = -ENOMEM;
-		goto out;
+		goto out_debugfs;
 	}
+
 	/* do counter init */
 	for (id = 0; id < LPROC_LL_FILE_OPCODES; id++) {
 		__u32 type = llite_opcode_table[id].type;
@@ -1278,7 +1284,7 @@ int ll_debugfs_register_super(struct super_block *sb, const char *name)
 					       LPROCFS_STATS_FLAG_NONE);
 	if (!sbi->ll_ra_stats) {
 		err = -ENOMEM;
-		goto out;
+		goto out_stats;
 	}
 
 	for (id = 0; id < ARRAY_SIZE(ra_stat_string); id++)
@@ -1287,24 +1293,28 @@ int ll_debugfs_register_super(struct super_block *sb, const char *name)
 
 	debugfs_create_file("stats", 0644, sbi->ll_debugfs_entry,
 			    sbi->ll_ra_stats, &lprocfs_stats_seq_fops);
-
-	ldebugfs_add_vars(sbi->ll_debugfs_entry, lprocfs_llite_obd_vars, sb);
-
+out_ll_kset:
 	/* Yes we also register sysfs mount kset here as well */
 	sbi->ll_kset.kobj.parent = llite_kobj;
 	sbi->ll_kset.kobj.ktype = &llite_ktype;
 	init_completion(&sbi->ll_kobj_unregister);
 	err = kobject_set_name(&sbi->ll_kset.kobj, "%s", name);
 	if (err)
-		goto out;
+		goto out_ra_stats;
 
 	err = kset_register(&sbi->ll_kset);
-out:
-	if (err) {
-		debugfs_remove_recursive(sbi->ll_debugfs_entry);
-		lprocfs_free_stats(&sbi->ll_ra_stats);
-		lprocfs_free_stats(&sbi->ll_stats);
-	}
+	if (err)
+		goto out_ra_stats;
+
+	return 0;
+
+out_ra_stats:
+	lprocfs_free_stats(&sbi->ll_ra_stats);
+out_stats:
+	lprocfs_free_stats(&sbi->ll_stats);
+out_debugfs:
+	debugfs_remove_recursive(sbi->ll_debugfs_entry);
+
 	return err;
 }
 
-- 
1.8.3.1
