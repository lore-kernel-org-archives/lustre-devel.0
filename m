From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 29 May 2018 16:29:47 +0200
Subject: [lustre-devel] [PATCH 13/13] staging: lustre: get rid of
 ldebugfs_remove()
In-Reply-To: <20180529142947.3250-1-gregkh@linuxfoundation.org>
References: <20180529142947.3250-1-gregkh@linuxfoundation.org>
Message-ID: <20180529142947.3250-13-gregkh@linuxfoundation.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

It was just a dumb wrapper around debugfs_remove_recursive() so just
call the function properly.  Also, there is no need to set the dentry to
NULL, it's gone, who cares about it anymore...

Cc: Oleg Drokin <oleg.drokin@intel.com>
Cc: Andreas Dilger <andreas.dilger@intel.com>
Cc: James Simmons <jsimmons@infradead.org>
Cc: NeilBrown <neilb@suse.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Roman Storozhenko <romeusmeister@gmail.com>
Cc: Aastha Gupta <aastha.gupta4104@gmail.com>
Cc: Ben Evans <bevans@cray.com>
Cc: Quentin Bouget <quentin.bouget@cea.fr>
Cc: Arvind Yadav <arvind.yadav.cs@gmail.com>
Cc: Arushi Singhal <arushisinghal19971997@gmail.com>
Cc: Patrick Farrell <paf@cray.com>
Cc: Aliaksei Karaliou <akaraliou.dev@gmail.com>
Cc: Mathias Rav <mathiasrav@gmail.com>
Cc: Andriy Skulysh <andriy.skulysh@seagate.com>
Cc: Dafna Hirschfeld <dafna3@gmail.com>
Cc: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Cc: Bob Glosman <bob.glossman@intel.com>
Cc: lustre-devel at lists.lustre.org
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 .../staging/lustre/lustre/fid/fid_request.c   |  6 ++----
 .../staging/lustre/lustre/fld/fld_request.c   |  6 ++----
 .../lustre/lustre/include/lprocfs_status.h    |  2 --
 .../staging/lustre/lustre/ldlm/ldlm_pool.c    |  5 +----
 .../lustre/lustre/ldlm/ldlm_resource.c        | 21 ++++---------------
 .../staging/lustre/lustre/llite/lproc_llite.c | 14 ++++++-------
 drivers/staging/lustre/lustre/lov/lov_pool.c  |  4 ++--
 .../staging/lustre/lustre/obdclass/genops.c   |  3 +--
 .../lustre/lustre/obdclass/lprocfs_status.c   | 10 +--------
 .../lustre/lustre/ptlrpc/lproc_ptlrpc.c       |  6 ++----
 .../staging/lustre/lustre/ptlrpc/sec_lproc.c  |  3 +--
 11 files changed, 22 insertions(+), 58 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index bc748ab6645d..a34fd90ca5e5 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -291,8 +291,7 @@ EXPORT_SYMBOL(seq_client_flush);
 
 static void seq_client_debugfs_fini(struct lu_client_seq *seq)
 {
-	if (!IS_ERR_OR_NULL(seq->lcs_debugfs_entry))
-		ldebugfs_remove(&seq->lcs_debugfs_entry);
+	debugfs_remove_recursive(seq->lcs_debugfs_entry);
 }
 
 static void seq_client_debugfs_init(struct lu_client_seq *seq)
@@ -399,8 +398,7 @@ static int __init fid_init(void)
 
 static void __exit fid_exit(void)
 {
-	if (!IS_ERR_OR_NULL(seq_debugfs_dir))
-		ldebugfs_remove(&seq_debugfs_dir);
+	debugfs_remove_recursive(seq_debugfs_dir);
 }
 
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
diff --git a/drivers/staging/lustre/lustre/fld/fld_request.c b/drivers/staging/lustre/lustre/fld/fld_request.c
index cb67fee19451..97f7ea632346 100644
--- a/drivers/staging/lustre/lustre/fld/fld_request.c
+++ b/drivers/staging/lustre/lustre/fld/fld_request.c
@@ -227,8 +227,7 @@ static void fld_client_debugfs_init(struct lu_client_fld *fld)
 
 void fld_client_debugfs_fini(struct lu_client_fld *fld)
 {
-	if (!IS_ERR_OR_NULL(fld->lcf_debugfs_entry))
-		ldebugfs_remove(&fld->lcf_debugfs_entry);
+	debugfs_remove_recursive(fld->lcf_debugfs_entry);
 }
 EXPORT_SYMBOL(fld_client_debugfs_fini);
 
@@ -435,8 +434,7 @@ static int __init fld_init(void)
 
 static void __exit fld_exit(void)
 {
-	if (!IS_ERR_OR_NULL(fld_debugfs_dir))
-		ldebugfs_remove(&fld_debugfs_dir);
+	debugfs_remove_recursive(fld_debugfs_dir);
 }
 
 MODULE_AUTHOR("OpenSFS, Inc. <http://www.lustre.org/>");
diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index b18bcb337504..495e6f5f676b 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -453,8 +453,6 @@ extern const struct file_operations lprocfs_stats_seq_fops;
 void ldebugfs_add_vars(struct dentry *parent, struct lprocfs_vars *var,
 		       void *data);
 
-void ldebugfs_remove(struct dentry **entryp);
-
 int lprocfs_obd_setup(struct obd_device *obd, struct lprocfs_vars *list,
 		      const struct attribute_group *attrs);
 int lprocfs_obd_cleanup(struct obd_device *obd);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
index 146b348ca312..36d14ee4e5b1 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
@@ -640,10 +640,7 @@ static void ldlm_pool_debugfs_fini(struct ldlm_pool *pl)
 		lprocfs_free_stats(&pl->pl_stats);
 		pl->pl_stats = NULL;
 	}
-	if (pl->pl_debugfs_entry) {
-		ldebugfs_remove(&pl->pl_debugfs_entry);
-		pl->pl_debugfs_entry = NULL;
-	}
+	debugfs_remove_recursive(pl->pl_debugfs_entry);
 }
 
 int ldlm_pool_init(struct ldlm_pool *pl, struct ldlm_namespace *ns,
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index 6b94a2b2a0fc..c93b019b8e37 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -121,18 +121,9 @@ void ldlm_debugfs_setup(void)
 
 void ldlm_debugfs_cleanup(void)
 {
-	if (!IS_ERR_OR_NULL(ldlm_svc_debugfs_dir))
-		ldebugfs_remove(&ldlm_svc_debugfs_dir);
-
-	if (!IS_ERR_OR_NULL(ldlm_ns_debugfs_dir))
-		ldebugfs_remove(&ldlm_ns_debugfs_dir);
-
-	if (!IS_ERR_OR_NULL(ldlm_debugfs_dir))
-		ldebugfs_remove(&ldlm_debugfs_dir);
-
-	ldlm_svc_debugfs_dir = NULL;
-	ldlm_ns_debugfs_dir = NULL;
-	ldlm_debugfs_dir = NULL;
+	debugfs_remove_recursive(ldlm_svc_debugfs_dir);
+	debugfs_remove_recursive(ldlm_ns_debugfs_dir);
+	debugfs_remove_recursive(ldlm_debugfs_dir);
 }
 
 static ssize_t resource_count_show(struct kobject *kobj, struct attribute *attr,
@@ -358,11 +349,7 @@ static struct kobj_type ldlm_ns_ktype = {
 
 static void ldlm_namespace_debugfs_unregister(struct ldlm_namespace *ns)
 {
-	if (IS_ERR_OR_NULL(ns->ns_debugfs_entry))
-		CERROR("dlm namespace %s has no procfs dir?\n",
-		       ldlm_ns_name(ns));
-	else
-		ldebugfs_remove(&ns->ns_debugfs_entry);
+	debugfs_remove_recursive(ns->ns_debugfs_entry);
 
 	if (ns->ns_stats)
 		lprocfs_free_stats(&ns->ns_stats);
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index d2f42c727ed4..49bf1b7ee311 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -1234,7 +1234,7 @@ int ldebugfs_register_mountpoint(struct dentry *parent,
 				obd->obd_type->typ_name);
 out:
 	if (err) {
-		ldebugfs_remove(&sbi->ll_debugfs_entry);
+		debugfs_remove_recursive(sbi->ll_debugfs_entry);
 		lprocfs_free_stats(&sbi->ll_ra_stats);
 		lprocfs_free_stats(&sbi->ll_stats);
 	}
@@ -1243,13 +1243,11 @@ int ldebugfs_register_mountpoint(struct dentry *parent,
 
 void ldebugfs_unregister_mountpoint(struct ll_sb_info *sbi)
 {
-	if (sbi->ll_debugfs_entry) {
-		ldebugfs_remove(&sbi->ll_debugfs_entry);
-		kobject_put(&sbi->ll_kobj);
-		wait_for_completion(&sbi->ll_kobj_unregister);
-		lprocfs_free_stats(&sbi->ll_ra_stats);
-		lprocfs_free_stats(&sbi->ll_stats);
-	}
+	debugfs_remove_recursive(sbi->ll_debugfs_entry);
+	kobject_put(&sbi->ll_kobj);
+	wait_for_completion(&sbi->ll_kobj_unregister);
+	lprocfs_free_stats(&sbi->ll_ra_stats);
+	lprocfs_free_stats(&sbi->ll_stats);
 }
 
 #undef MAX_STRING_SIZE
diff --git a/drivers/staging/lustre/lustre/lov/lov_pool.c b/drivers/staging/lustre/lustre/lov/lov_pool.c
index 9ce7038c9b0e..b2a88ba72eb2 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pool.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pool.c
@@ -410,7 +410,7 @@ int lov_pool_new(struct obd_device *obd, char *poolname)
 	list_del_init(&new_pool->pool_list);
 	lov->lov_pool_count--;
 	spin_unlock(&obd->obd_dev_lock);
-	ldebugfs_remove(&new_pool->pool_debugfs_entry);
+	debugfs_remove_recursive(new_pool->pool_debugfs_entry);
 	lov_ost_pool_free(&new_pool->pool_obds);
 	kfree(new_pool);
 
@@ -435,7 +435,7 @@ int lov_pool_del(struct obd_device *obd, char *poolname)
 	if (!pool)
 		return -ENOENT;
 
-	ldebugfs_remove(&pool->pool_debugfs_entry);
+	debugfs_remove_recursive(pool->pool_debugfs_entry);
 	lov_pool_putref(pool);
 
 	spin_lock(&obd->obd_dev_lock);
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 3771452b836c..234f383ce6d9 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -224,8 +224,7 @@ int class_unregister_type(const char *name)
 	if (type->typ_kobj)
 		kobject_put(type->typ_kobj);
 
-	if (!IS_ERR_OR_NULL(type->typ_debugfs_entry))
-		ldebugfs_remove(&type->typ_debugfs_entry);
+	debugfs_remove_recursive(type->typ_debugfs_entry);
 
 	if (type->typ_lu)
 		lu_device_type_fini(type->typ_lu);
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index a8299a8cdad9..bdbe6f52031a 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -328,13 +328,6 @@ void ldebugfs_add_vars(struct dentry *parent, struct lprocfs_vars *list,
 }
 EXPORT_SYMBOL_GPL(ldebugfs_add_vars);
 
-void ldebugfs_remove(struct dentry **entryp)
-{
-	debugfs_remove_recursive(*entryp);
-	*entryp = NULL;
-}
-EXPORT_SYMBOL_GPL(ldebugfs_remove);
-
 /* Generic callbacks */
 static ssize_t uuid_show(struct kobject *kobj, struct attribute *attr,
 			 char *buf)
@@ -1010,8 +1003,7 @@ int lprocfs_obd_cleanup(struct obd_device *obd)
 	if (!obd)
 		return -EINVAL;
 
-	if (!IS_ERR_OR_NULL(obd->obd_debugfs_entry))
-		ldebugfs_remove(&obd->obd_debugfs_entry);
+	debugfs_remove_recursive(obd->obd_debugfs_entry);
 
 	kobject_put(&obd->obd_kobj);
 	wait_for_completion(&obd->obd_kobj_unregister);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
index 62404b08f390..0b638837f88b 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
@@ -1158,8 +1158,7 @@ EXPORT_SYMBOL(ptlrpc_lprocfs_brw);
 
 void ptlrpc_lprocfs_unregister_service(struct ptlrpc_service *svc)
 {
-	if (!IS_ERR_OR_NULL(svc->srv_debugfs_entry))
-		ldebugfs_remove(&svc->srv_debugfs_entry);
+	debugfs_remove_recursive(svc->srv_debugfs_entry);
 
 	if (svc->srv_stats)
 		lprocfs_free_stats(&svc->srv_stats);
@@ -1167,8 +1166,7 @@ void ptlrpc_lprocfs_unregister_service(struct ptlrpc_service *svc)
 
 void ptlrpc_lprocfs_unregister_obd(struct obd_device *obd)
 {
-	if (!IS_ERR_OR_NULL(obd->obd_svc_debugfs_entry))
-		ldebugfs_remove(&obd->obd_svc_debugfs_entry);
+	debugfs_remove_recursive(obd->obd_svc_debugfs_entry);
 
 	if (obd->obd_svc_stats)
 		lprocfs_free_stats(&obd->obd_svc_stats);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c b/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c
index e8076dc7c950..2bb75ebd5d98 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_lproc.c
@@ -166,6 +166,5 @@ void sptlrpc_lproc_init(void)
 
 void sptlrpc_lproc_fini(void)
 {
-	if (!IS_ERR_OR_NULL(sptlrpc_debugfs_dir))
-		ldebugfs_remove(&sptlrpc_debugfs_dir);
+	debugfs_remove_recursive(sptlrpc_debugfs_dir);
 }
-- 
2.17.0
