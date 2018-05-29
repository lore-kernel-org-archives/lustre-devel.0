From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 29 May 2018 16:29:45 +0200
Subject: [lustre-devel] [PATCH 11/13] staging: lustre: remove last two users
 of ldebugfs_register()
In-Reply-To: <20180529142947.3250-1-gregkh@linuxfoundation.org>
References: <20180529142947.3250-1-gregkh@linuxfoundation.org>
Message-ID: <20180529142947.3250-11-gregkh@linuxfoundation.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

ldebugfs_register() is just a call to debugfs_create_dir() and
ldebugfs_add_vars() if the list option is set.  Fix up the last two
users of this function to just call these two functions instead, and
delete the now unused ldebugfs_register() call.

This ends up cleaning up more code and making things smaller, always a
good thing.

Cc: Oleg Drokin <oleg.drokin@intel.com>
Cc: Andreas Dilger <andreas.dilger@intel.com>
Cc: James Simmons <jsimmons@infradead.org>
Cc: NeilBrown <neilb@suse.com>
Cc: Ben Evans <bevans@cray.com>
Cc: Quentin Bouget <quentin.bouget@cea.fr>
Cc: Arvind Yadav <arvind.yadav.cs@gmail.com>
Cc: Arushi Singhal <arushisinghal19971997@gmail.com>
Cc: Julia Lawall <julia.lawall@lip6.fr>
Cc: Mathias Rav <mathiasrav@gmail.com>
Cc: Dafna Hirschfeld <dafna3@gmail.com>
Cc: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Cc: Patrick Farrell <paf@cray.com>
Cc: Nadav Amit <namit@vmware.com>
Cc: lustre-devel at lists.lustre.org
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 .../lustre/lustre/include/lprocfs_status.h    |  5 ---
 .../lustre/lustre/obdclass/lprocfs_status.c   | 39 ++-----------------
 .../lustre/lustre/ptlrpc/ptlrpc_internal.h    |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec.c    |  6 +--
 .../staging/lustre/lustre/ptlrpc/sec_lproc.c  | 17 ++------
 5 files changed, 8 insertions(+), 61 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index cc230c520189..912c65b2f72b 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -454,11 +454,6 @@ int ldebugfs_add_vars(struct dentry *parent,
 		      struct lprocfs_vars *var,
 		      void *data);
 
-struct dentry *ldebugfs_register(const char *name,
-				 struct dentry *parent,
-				 struct lprocfs_vars *list,
-				 void *data);
-
 void ldebugfs_remove(struct dentry **entryp);
 
 int lprocfs_obd_setup(struct obd_device *obd, struct lprocfs_vars *list,
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 6e306cafa95a..91af79facbc0 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -338,32 +338,6 @@ void ldebugfs_remove(struct dentry **entryp)
 }
 EXPORT_SYMBOL_GPL(ldebugfs_remove);
 
-struct dentry *ldebugfs_register(const char *name,
-				 struct dentry *parent,
-				 struct lprocfs_vars *list, void *data)
-{
-	struct dentry *entry;
-
-	entry = debugfs_create_dir(name, parent);
-	if (IS_ERR_OR_NULL(entry)) {
-		entry = entry ?: ERR_PTR(-ENOMEM);
-		goto out;
-	}
-
-	if (!IS_ERR_OR_NULL(list)) {
-		int rc;
-
-		rc = ldebugfs_add_vars(entry, list, data);
-		if (rc != 0) {
-			debugfs_remove(entry);
-			entry = ERR_PTR(rc);
-		}
-	}
-out:
-	return entry;
-}
-EXPORT_SYMBOL_GPL(ldebugfs_register);
-
 /* Generic callbacks */
 static ssize_t uuid_show(struct kobject *kobj, struct attribute *attr,
 			 char *buf)
@@ -1026,16 +1000,9 @@ int lprocfs_obd_setup(struct obd_device *obd, struct lprocfs_vars *list,
 		}
 	}
 
-	obd->obd_debugfs_entry = ldebugfs_register(obd->obd_name,
-						   obd->obd_type->typ_debugfs_entry,
-						   list, obd);
-	if (IS_ERR_OR_NULL(obd->obd_debugfs_entry)) {
-		rc = obd->obd_debugfs_entry ? PTR_ERR(obd->obd_debugfs_entry)
-					    : -ENOMEM;
-		CERROR("error %d setting up lprocfs for %s\n",
-		       rc, obd->obd_name);
-		obd->obd_debugfs_entry = NULL;
-	}
+	obd->obd_debugfs_entry = debugfs_create_dir(obd->obd_name,
+					obd->obd_type->typ_debugfs_entry);
+	ldebugfs_add_vars(obd->obd_debugfs_entry, list, obd);
 
 	return rc;
 }
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
index b7a8d7537a66..134b74234519 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
@@ -264,7 +264,7 @@ void sptlrpc_enc_pool_fini(void);
 int sptlrpc_proc_enc_pool_seq_show(struct seq_file *m, void *v);
 
 /* sec_lproc.c */
-int  sptlrpc_lproc_init(void);
+void sptlrpc_lproc_init(void);
 void sptlrpc_lproc_fini(void);
 
 /* sec_gc.c */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
index 256421465bcd..e193f3346e6f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
@@ -2352,14 +2352,10 @@ int sptlrpc_init(void)
 	if (rc)
 		goto out_null;
 
-	rc = sptlrpc_lproc_init();
-	if (rc)
-		goto out_plain;
+	sptlrpc_lproc_init();
 
 	return 0;
 
-out_plain:
-	sptlrpc_plain_fini();
 out_null:
 	sptlrpc_null_fini();
 out_pool:
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c b/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c
index cd1bb3dabb63..e8076dc7c950 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c
@@ -158,21 +158,10 @@ static struct lprocfs_vars sptlrpc_lprocfs_vars[] = {
 
 static struct dentry *sptlrpc_debugfs_dir;
 
-int sptlrpc_lproc_init(void)
+void sptlrpc_lproc_init(void)
 {
-	int rc;
-
-	LASSERT(!sptlrpc_debugfs_dir);
-
-	sptlrpc_debugfs_dir = ldebugfs_register("sptlrpc", debugfs_lustre_root,
-						sptlrpc_lprocfs_vars, NULL);
-	if (IS_ERR_OR_NULL(sptlrpc_debugfs_dir)) {
-		rc = sptlrpc_debugfs_dir ? PTR_ERR(sptlrpc_debugfs_dir)
-					 : -ENOMEM;
-		sptlrpc_debugfs_dir = NULL;
-		return rc;
-	}
-	return 0;
+	sptlrpc_debugfs_dir = debugfs_create_dir("sptlrpc", debugfs_lustre_root);
+	ldebugfs_add_vars(sptlrpc_debugfs_dir, sptlrpc_lprocfs_vars, NULL);
 }
 
 void sptlrpc_lproc_fini(void)
-- 
2.17.0
