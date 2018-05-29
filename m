From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 29 May 2018 16:29:43 +0200
Subject: [lustre-devel] [PATCH 09/13] staging: lustre: remove
 ldebugfs_obd_seq_create() wrapper function
In-Reply-To: <20180529142947.3250-1-gregkh@linuxfoundation.org>
References: <20180529142947.3250-1-gregkh@linuxfoundation.org>
Message-ID: <20180529142947.3250-9-gregkh@linuxfoundation.org>
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
Cc: Ben Evans <bevans@cray.com>
Cc: NeilBrown <neilb@suse.com>
Cc: Arushi Singhal <arushisinghal19971997@gmail.com>
Cc: Arvind Yadav <arvind.yadav.cs@gmail.com>
Cc: Julia Lawall <julia.lawall@lip6.fr>
Cc: Dafna Hirschfeld <dafna3@gmail.com>
Cc: Mathias Rav <mathiasrav@gmail.com>
Cc: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Cc: Roman Storozhenko <romeusmeister@gmail.com>
Cc: lustre-devel at lists.lustre.org
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 .../lustre/lustre/include/lprocfs_status.h    |  6 ------
 .../lustre/lustre/obdclass/lprocfs_status.c   | 11 ----------
 drivers/staging/lustre/lustre/osc/lproc_osc.c | 10 +++------
 .../staging/lustre/lustre/osc/osc_internal.h  |  2 +-
 .../staging/lustre/lustre/ptlrpc/sec_lproc.c  | 21 ++++---------------
 5 files changed, 8 insertions(+), 42 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index 54abcc2eaeb6..cc230c520189 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -465,12 +465,6 @@ int lprocfs_obd_setup(struct obd_device *obd, struct lprocfs_vars *list,
 		      const struct attribute_group *attrs);
 int lprocfs_obd_cleanup(struct obd_device *obd);
 
-int ldebugfs_obd_seq_create(struct obd_device *dev,
-			    const char *name,
-			    umode_t mode,
-			    const struct file_operations *seq_fops,
-			    void *data);
-
 /* Generic callbacks */
 
 int lprocfs_rd_uint(struct seq_file *m, void *data);
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 6e0ea4e76a1b..6e306cafa95a 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -1538,17 +1538,6 @@ char *lprocfs_find_named_value(const char *buffer, const char *name,
 }
 EXPORT_SYMBOL(lprocfs_find_named_value);
 
-int ldebugfs_obd_seq_create(struct obd_device *dev,
-			    const char *name,
-			    umode_t mode,
-			    const struct file_operations *seq_fops,
-			    void *data)
-{
-	debugfs_create_file(name, mode, dev->obd_debugfs_entry, data, seq_fops);
-	return 0;
-}
-EXPORT_SYMBOL_GPL(ldebugfs_obd_seq_create);
-
 void lprocfs_oh_tally(struct obd_histogram *oh, unsigned int value)
 {
 	if (value >= OBD_HIST_MAX)
diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
index 31f49f3fca59..6a705bc5420c 100644
--- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
+++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
@@ -801,16 +801,12 @@ static ssize_t osc_stats_seq_write(struct file *file,
 
 LPROC_SEQ_FOPS(osc_stats);
 
-int lproc_osc_attach_seqstat(struct obd_device *dev)
+void lproc_osc_attach_seqstat(struct obd_device *dev)
 {
-	int rc;
-
 	debugfs_create_file("osc_stats", 0644, dev->obd_debugfs_entry, dev,
 			    &osc_stats_fops);
-	rc = ldebugfs_obd_seq_create(dev, "rpc_stats", 0644,
-				     &osc_rpc_stats_fops, dev);
-
-	return rc;
+	debugfs_create_file("rpc_stats", 0644, dev->obd_debugfs_entry, dev,
+			    &osc_rpc_stats_fops);
 }
 
 static struct attribute *osc_attrs[] = {
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index fca020568c19..4ddba1354bef 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -141,7 +141,7 @@ unsigned long osc_ldlm_weigh_ast(struct ldlm_lock *dlmlock);
 
 int osc_setup(struct obd_device *obd, struct lustre_cfg *lcfg);
 
-int lproc_osc_attach_seqstat(struct obd_device *dev);
+void lproc_osc_attach_seqstat(struct obd_device *dev);
 void lprocfs_osc_init_vars(struct lprocfs_static_vars *lvars);
 
 extern struct lu_device_type osc_device_type;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c b/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c
index fd609b63d2de..cd1bb3dabb63 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c
@@ -133,8 +133,6 @@ LPROC_SEQ_FOPS_RO(sptlrpc_ctxs_lprocfs);
 
 int sptlrpc_lprocfs_cliobd_attach(struct obd_device *dev)
 {
-	int rc;
-
 	if (strcmp(dev->obd_type->typ_name, LUSTRE_OSC_NAME) != 0 &&
 	    strcmp(dev->obd_type->typ_name, LUSTRE_MDC_NAME) != 0 &&
 	    strcmp(dev->obd_type->typ_name, LUSTRE_MGC_NAME) != 0) {
@@ -143,21 +141,10 @@ int sptlrpc_lprocfs_cliobd_attach(struct obd_device *dev)
 		return -EINVAL;
 	}
 
-	rc = ldebugfs_obd_seq_create(dev, "srpc_info", 0444,
-				     &sptlrpc_info_lprocfs_fops, dev);
-	if (rc) {
-		CERROR("create proc entry srpc_info for %s: %d\n",
-		       dev->obd_name, rc);
-		return rc;
-	}
-
-	rc = ldebugfs_obd_seq_create(dev, "srpc_contexts", 0444,
-				     &sptlrpc_ctxs_lprocfs_fops, dev);
-	if (rc) {
-		CERROR("create proc entry srpc_contexts for %s: %d\n",
-		       dev->obd_name, rc);
-		return rc;
-	}
+	debugfs_create_file("srpc_info", 0444, dev->obd_debugfs_entry, dev,
+			    &sptlrpc_info_lprocfs_fops);
+	debugfs_create_file("srpc_contexts", 0444, dev->obd_debugfs_entry, dev,
+			    &sptlrpc_ctxs_lprocfs_fops);
 
 	return 0;
 }
-- 
2.17.0
