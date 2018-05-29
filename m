From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 29 May 2018 16:29:42 +0200
Subject: [lustre-devel] [PATCH 08/13] staging: lustre: remove
 ldebugfs_seq_create() wrapper function
In-Reply-To: <20180529142947.3250-1-gregkh@linuxfoundation.org>
References: <20180529142947.3250-1-gregkh@linuxfoundation.org>
Message-ID: <20180529142947.3250-8-gregkh@linuxfoundation.org>
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
Cc: Quentin Bouget <quentin.bouget@cea.fr>
Cc: NeilBrown <neilb@suse.com>
Cc: Ben Evans <bevans@cray.com>
Cc: Arushi Singhal <arushisinghal19971997@gmail.com>
Cc: Arvind Yadav <arvind.yadav.cs@gmail.com>
Cc: "John L. Hammond" <john.hammond@intel.com>
Cc: Vitaly Fertman <vitaly.fertman@seagate.com>
Cc: Julia Lawall <julia.lawall@lip6.fr>
Cc: Dafna Hirschfeld <dafna3@gmail.com>
Cc: Mathias Rav <mathiasrav@gmail.com>
Cc: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Cc: Bob Glosman <bob.glossman@intel.com>
Cc: lustre-devel at lists.lustre.org
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 .../lustre/lustre/include/lprocfs_status.h    |  5 ----
 .../staging/lustre/lustre/llite/lproc_llite.c | 30 ++++++-------------
 drivers/staging/lustre/lustre/lmv/lmv_obd.c   |  7 ++---
 drivers/staging/lustre/lustre/lov/lov_obd.c   |  6 ++--
 .../lustre/lustre/obdclass/lprocfs_status.c   | 19 ++----------
 drivers/staging/lustre/lustre/osc/lproc_osc.c |  9 +++---
 .../lustre/lustre/ptlrpc/lproc_ptlrpc.c       |  8 ++---
 7 files changed, 21 insertions(+), 63 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index 7aafe873cb39..54abcc2eaeb6 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -465,11 +465,6 @@ int lprocfs_obd_setup(struct obd_device *obd, struct lprocfs_vars *list,
 		      const struct attribute_group *attrs);
 int lprocfs_obd_cleanup(struct obd_device *obd);
 
-int ldebugfs_seq_create(struct dentry *parent,
-			const char *name,
-			umode_t mode,
-			const struct file_operations *seq_fops,
-			void *data);
 int ldebugfs_obd_seq_create(struct obd_device *dev,
 			    const char *name,
 			    umode_t mode,
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 2297a14f00ca..1f122f8a54dc 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -1139,7 +1139,7 @@ int ldebugfs_register_mountpoint(struct dentry *parent,
 	struct obd_device *obd;
 	struct dentry *dir;
 	char name[MAX_STRING_SIZE + 1], *ptr;
-	int err, id, len, rc;
+	int err, id, len;
 
 	name[MAX_STRING_SIZE] = '\0';
 
@@ -1165,26 +1165,14 @@ int ldebugfs_register_mountpoint(struct dentry *parent,
 	}
 	sbi->ll_debugfs_entry = dir;
 
-	rc = ldebugfs_seq_create(sbi->ll_debugfs_entry, "dump_page_cache", 0444,
-				 &vvp_dump_pgcache_file_ops, sbi);
-	if (rc)
-		CWARN("Error adding the dump_page_cache file\n");
-
-	rc = ldebugfs_seq_create(sbi->ll_debugfs_entry, "extents_stats", 0644,
-				 &ll_rw_extents_stats_fops, sbi);
-	if (rc)
-		CWARN("Error adding the extent_stats file\n");
-
-	rc = ldebugfs_seq_create(sbi->ll_debugfs_entry,
-				 "extents_stats_per_process",
-				 0644, &ll_rw_extents_stats_pp_fops, sbi);
-	if (rc)
-		CWARN("Error adding the extents_stats_per_process file\n");
-
-	rc = ldebugfs_seq_create(sbi->ll_debugfs_entry, "offset_stats", 0644,
-				 &ll_rw_offset_stats_fops, sbi);
-	if (rc)
-		CWARN("Error adding the offset_stats file\n");
+	debugfs_create_file("dump_page_cache", 0444, dir, sbi,
+			    &vvp_dump_pgcache_file_ops);
+	debugfs_create_file("extents_stats", 0644, dir, sbi,
+			    &ll_rw_extents_stats_fops);
+	debugfs_create_file("extents_stats_per_process", 0644,
+			    dir, sbi, &ll_rw_extents_stats_pp_fops);
+	debugfs_create_file("offset_stats", 0644, dir, sbi,
+			    &ll_rw_offset_stats_fops);
 
 	/* File operations stats */
 	sbi->ll_stats = lprocfs_alloc_stats(LPROC_LL_FILE_OPCODES,
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 60cdba99e4a4..85b6e8392759 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1264,11 +1264,8 @@ static int lmv_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	lprocfs_lmv_init_vars(&lvars);
 
 	lprocfs_obd_setup(obd, lvars.obd_vars, lvars.sysfs_vars);
-	rc = ldebugfs_seq_create(obd->obd_debugfs_entry, "target_obd",
-				 0444, &lmv_proc_target_fops, obd);
-	if (rc)
-		CWARN("%s: error adding LMV target_obd file: rc = %d\n",
-		      obd->obd_name, rc);
+	debugfs_create_file("target_obd", 0444, obd->obd_debugfs_entry, obd,
+			    &lmv_proc_target_fops);
 	rc = fld_client_init(&lmv->lmv_fld, obd->obd_name,
 			     LUSTRE_CLI_FLD_HASH_DHT);
 	if (rc) {
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 7123972d4d5b..a2a5f59dfc7a 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -806,10 +806,8 @@ int lov_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	lprocfs_lov_init_vars(&lvars);
 	lprocfs_obd_setup(obd, lvars.obd_vars, lvars.sysfs_vars);
 
-	rc = ldebugfs_seq_create(obd->obd_debugfs_entry, "target_obd",
-				 0444, &lov_proc_target_fops, obd);
-	if (rc)
-		CWARN("Error adding the target_obd file\n");
+	debugfs_create_file("target_obd", 0444, obd->obd_debugfs_entry, obd,
+			    &lov_proc_target_fops);
 
 	lov->lov_pool_debugfs_entry = ldebugfs_register("pools",
 						     obd->obd_debugfs_entry,
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 089a3d74f3ea..6e0ea4e76a1b 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -1538,29 +1538,14 @@ char *lprocfs_find_named_value(const char *buffer, const char *name,
 }
 EXPORT_SYMBOL(lprocfs_find_named_value);
 
-int ldebugfs_seq_create(struct dentry *parent, const char *name,
-			umode_t mode, const struct file_operations *seq_fops,
-			void *data)
-{
-	struct dentry *entry;
-
-	/* Disallow secretly (un)writable entries. */
-	LASSERT((!seq_fops->write) == ((mode & 0222) == 0));
-
-	entry = debugfs_create_file(name, mode, parent, data, seq_fops);
-
-	return 0;
-}
-EXPORT_SYMBOL_GPL(ldebugfs_seq_create);
-
 int ldebugfs_obd_seq_create(struct obd_device *dev,
 			    const char *name,
 			    umode_t mode,
 			    const struct file_operations *seq_fops,
 			    void *data)
 {
-	return ldebugfs_seq_create(dev->obd_debugfs_entry, name,
-				   mode, seq_fops, data);
+	debugfs_create_file(name, mode, dev->obd_debugfs_entry, data, seq_fops);
+	return 0;
 }
 EXPORT_SYMBOL_GPL(ldebugfs_obd_seq_create);
 
diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index dc76c35ae801..31f49f3fca59 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -805,11 +805,10 @@ int lproc_osc_attach_seqstat(struct obd_device *dev)
 {
 	int rc;
 
-	rc = ldebugfs_seq_create(dev->obd_debugfs_entry, "osc_stats", 0644,
-				 &osc_stats_fops, dev);
-	if (rc == 0)
-		rc = ldebugfs_obd_seq_create(dev, "rpc_stats", 0644,
-					     &osc_rpc_stats_fops, dev);
+	debugfs_create_file("osc_stats", 0644, dev->obd_debugfs_entry, dev,
+			    &osc_stats_fops);
+	rc = ldebugfs_obd_seq_create(dev, "rpc_stats", 0644,
+				     &osc_rpc_stats_fops, dev);
 
 	return rc;
 }
diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
index 6022246c4459..eb21a8dd3708 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
@@ -1099,8 +1099,6 @@ void ptlrpc_ldebugfs_register_service(struct dentry *entry,
 		.release     = lprocfs_seq_release,
 	};
 
-	int rc;
-
 	ptlrpc_ldebugfs_register(entry, svc->srv_name,
 				 "stats", &svc->srv_debugfs_entry,
 				 &svc->srv_stats);
@@ -1110,10 +1108,8 @@ void ptlrpc_ldebugfs_register_service(struct dentry *entry,
 
 	ldebugfs_add_vars(svc->srv_debugfs_entry, lproc_vars, NULL);
 
-	rc = ldebugfs_seq_create(svc->srv_debugfs_entry, "req_history",
-				 0400, &req_history_fops, svc);
-	if (rc)
-		CWARN("Error adding the req_history file\n");
+	debugfs_create_file("req_history", 0400, svc->srv_debugfs_entry, svc,
+			    &req_history_fops);
 }
 
 void ptlrpc_lprocfs_register_obd(struct obd_device *obddev)
-- 
2.17.0
