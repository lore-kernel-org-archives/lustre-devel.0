From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 29 May 2018 16:29:41 +0200
Subject: [lustre-devel] [PATCH 07/13] staging: lustre: remove
 ldebugfs_register_stats() wrapper function
In-Reply-To: <20180529142947.3250-1-gregkh@linuxfoundation.org>
References: <20180529142947.3250-1-gregkh@linuxfoundation.org>
Message-ID: <20180529142947.3250-7-gregkh@linuxfoundation.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

It was just calling debugfs_create_file() so unwind things and just call
the real function instead.  This ends up saving a number of lines as
there was never any error handling happening anyway, so that all can be
removed as well.

Cc: Oleg Drokin <oleg.drokin@intel.com>
Cc: Andreas Dilger <andreas.dilger@intel.com>
Cc: James Simmons <jsimmons@infradead.org>
Cc: Ben Evans <bevans@cray.com>
Cc: Quentin Bouget <quentin.bouget@cea.fr>
Cc: NeilBrown <neilb@suse.com>
Cc: Arushi Singhal <arushisinghal19971997@gmail.com>
Cc: Arvind Yadav <arvind.yadav.cs@gmail.com>
Cc: Patrick Farrell <paf@cray.com>
Cc: Aliaksei Karaliou <akaraliou.dev@gmail.com>
Cc: Aastha Gupta <aastha.gupta4104@gmail.com>
Cc: Dafna Hirschfeld <dafna3@gmail.com>
Cc: Mathias Rav <mathiasrav@gmail.com>
Cc: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Cc: Bob Glosman <bob.glossman@intel.com>
Cc: lustre-devel at lists.lustre.org
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 .../lustre/lustre/include/lprocfs_status.h      |  4 +---
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c  |  4 ++--
 .../staging/lustre/lustre/llite/lproc_llite.c   | 13 +++++--------
 .../lustre/lustre/obdclass/lprocfs_status.c     | 16 ++--------------
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c | 17 ++++++-----------
 5 files changed, 16 insertions(+), 38 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index 9eac7dac8c7b..7aafe873cb39 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -447,9 +447,7 @@ void lprocfs_counter_init(struct lprocfs_stats *stats, int index,
 			  const char *units);
 struct obd_export;
 int lprocfs_exp_cleanup(struct obd_export *exp);
-int ldebugfs_register_stats(struct dentry *parent,
-			    const char *name,
-			    struct lprocfs_stats *stats);
+extern const struct file_operations lprocfs_stats_seq_fops;
 
 /* lprocfs_status.c */
 int ldebugfs_add_vars(struct dentry *parent,
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
index 53b8f33e54b5..b83e93256cd1 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
@@ -627,8 +627,8 @@ static int ldlm_pool_debugfs_init(struct ldlm_pool *pl)
 	lprocfs_counter_init(pl->pl_stats, LDLM_POOL_TIMING_STAT,
 			     LPROCFS_CNTR_AVGMINMAX | LPROCFS_CNTR_STDDEV,
 			     "recalc_timing", "sec");
-	rc = ldebugfs_register_stats(pl->pl_debugfs_entry, "stats",
-				     pl->pl_stats);
+	debugfs_create_file("stats", 0644, pl->pl_debugfs_entry, pl->pl_stats,
+			    &lprocfs_stats_seq_fops);
 
 out_free_name:
 	kfree(var_name);
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 164fe4d6b6b8..2297a14f00ca 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -1209,10 +1209,9 @@ int ldebugfs_register_mountpoint(struct dentry *parent,
 				     (type & LPROCFS_CNTR_AVGMINMAX),
 				     llite_opcode_table[id].opname, ptr);
 	}
-	err = ldebugfs_register_stats(sbi->ll_debugfs_entry, "stats",
-				      sbi->ll_stats);
-	if (err)
-		goto out;
+
+	debugfs_create_file("stats", 0644, sbi->ll_debugfs_entry, sbi->ll_stats,
+			    &lprocfs_stats_seq_fops);
 
 	sbi->ll_ra_stats = lprocfs_alloc_stats(ARRAY_SIZE(ra_stat_string),
 					       LPROCFS_STATS_FLAG_NONE);
@@ -1225,10 +1224,8 @@ int ldebugfs_register_mountpoint(struct dentry *parent,
 		lprocfs_counter_init(sbi->ll_ra_stats, id, 0,
 				     ra_stat_string[id], "pages");
 
-	err = ldebugfs_register_stats(sbi->ll_debugfs_entry, "read_ahead_stats",
-				      sbi->ll_ra_stats);
-	if (err)
-		goto out;
+	debugfs_create_file("stats", 0644, sbi->ll_debugfs_entry,
+			    sbi->ll_ra_stats, &lprocfs_stats_seq_fops);
 
 	err = ldebugfs_add_vars(sbi->ll_debugfs_entry,
 				lprocfs_llite_obd_vars, sb);
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 68e85f46a146..089a3d74f3ea 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -1315,7 +1315,7 @@ static int lprocfs_stats_seq_open(struct inode *inode, struct file *file)
 	return 0;
 }
 
-static const struct file_operations lprocfs_stats_seq_fops = {
+const struct file_operations lprocfs_stats_seq_fops = {
 	.owner   = THIS_MODULE,
 	.open    = lprocfs_stats_seq_open,
 	.read    = seq_read,
@@ -1323,19 +1323,7 @@ static const struct file_operations lprocfs_stats_seq_fops = {
 	.llseek  = seq_lseek,
 	.release = lprocfs_seq_release,
 };
-
-int ldebugfs_register_stats(struct dentry *parent, const char *name,
-			    struct lprocfs_stats *stats)
-{
-	struct dentry *entry;
-
-	LASSERT(!IS_ERR_OR_NULL(parent));
-
-	entry = debugfs_create_file(name, 0644, parent, stats,
-				    &lprocfs_stats_seq_fops);
-	return 0;
-}
-EXPORT_SYMBOL_GPL(ldebugfs_register_stats);
+EXPORT_SYMBOL_GPL(lprocfs_stats_seq_fops);
 
 void lprocfs_counter_init(struct lprocfs_stats *stats, int index,
 			  unsigned int conf, const char *name,
diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
index 36eea50a77e7..6022246c4459 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
@@ -185,7 +185,7 @@ ptlrpc_ldebugfs_register(struct dentry *root, char *dir,
 {
 	struct dentry *svc_debugfs_entry;
 	struct lprocfs_stats *svc_stats;
-	int i, rc;
+	int i;
 	unsigned int svc_counter_config = LPROCFS_CNTR_AVGMINMAX |
 					  LPROCFS_CNTR_STDDEV;
 
@@ -241,16 +241,11 @@ ptlrpc_ldebugfs_register(struct dentry *root, char *dir,
 				     ll_opcode2str(opcode), "usec");
 	}
 
-	rc = ldebugfs_register_stats(svc_debugfs_entry, name, svc_stats);
-	if (rc < 0) {
-		if (dir)
-			ldebugfs_remove(&svc_debugfs_entry);
-		lprocfs_free_stats(&svc_stats);
-	} else {
-		if (dir)
-			*debugfs_root_ret = svc_debugfs_entry;
-		*stats_ret = svc_stats;
-	}
+	debugfs_create_file("stats", 0644, svc_debugfs_entry, svc_stats,
+			    &lprocfs_stats_seq_fops);
+	if (dir)
+		*debugfs_root_ret = svc_debugfs_entry;
+	*stats_ret = svc_stats;
 }
 
 static int
-- 
2.17.0
