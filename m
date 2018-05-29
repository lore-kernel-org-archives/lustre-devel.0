From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 29 May 2018 16:29:44 +0200
Subject: [lustre-devel] [PATCH 10/13] staging: lustre: unwrap some
 ldebugfs_register() calls
In-Reply-To: <20180529142947.3250-1-gregkh@linuxfoundation.org>
References: <20180529142947.3250-1-gregkh@linuxfoundation.org>
Message-ID: <20180529142947.3250-10-gregkh@linuxfoundation.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

When the third option (list) to ldebugfs_register() is NULL, it's the
same as just calling debugfs_create_dir().  So unwind this and call
debugfs_create_dir() directly.

This ends up saving lots of code as we do not need to do any error
checking of the return value (because it does not matter).

The ldebugfs_register() call will be removed in a later patch when it is
fully removed, right now there are 2 outstanding users of it in the
tree.

Cc: Oleg Drokin <oleg.drokin@intel.com>
Cc: Andreas Dilger <andreas.dilger@intel.com>
Cc: James Simmons <jsimmons@infradead.org>
Cc: NeilBrown <neilb@suse.com>
Cc: Aastha Gupta <aastha.gupta4104@gmail.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Quentin Bouget <quentin.bouget@cea.fr>
Cc: Patrick Farrell <paf@cray.com>
Cc: Aliaksei Karaliou <akaraliou.dev@gmail.com>
Cc: "John L. Hammond" <john.hammond@intel.com>
Cc: Mathias Rav <mathiasrav@gmail.com>
Cc: Andriy Skulysh <andriy.skulysh@seagate.com>
Cc: Ben Evans <bevans@cray.com>
Cc: Bob Glosman <bob.glossman@intel.com>
Cc: lustre-devel at lists.lustre.org
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 .../staging/lustre/lustre/fid/fid_request.c   | 20 +++--------
 .../staging/lustre/lustre/fld/fld_request.c   | 20 +++--------
 .../staging/lustre/lustre/ldlm/ldlm_pool.c    |  9 +----
 .../lustre/lustre/ldlm/ldlm_resource.c        | 34 +++----------------
 .../staging/lustre/lustre/llite/lproc_llite.c |  7 +---
 drivers/staging/lustre/lustre/lov/lov_obd.c   |  5 ++-
 .../staging/lustre/lustre/obdclass/genops.c   | 11 ++----
 .../lustre/lustre/ptlrpc/lproc_ptlrpc.c       | 11 ++----
 8 files changed, 24 insertions(+), 93 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index c674652af03a..dfcac0afa106 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -299,17 +299,8 @@ static int seq_client_debugfs_init(struct lu_client_seq *seq)
 {
 	int rc;
 
-	seq->lcs_debugfs_entry = ldebugfs_register(seq->lcs_name,
-						   seq_debugfs_dir,
-						   NULL, NULL);
-
-	if (IS_ERR_OR_NULL(seq->lcs_debugfs_entry)) {
-		CERROR("%s: LdebugFS failed in seq-init\n", seq->lcs_name);
-		rc = seq->lcs_debugfs_entry ? PTR_ERR(seq->lcs_debugfs_entry)
-					    : -ENOMEM;
-		seq->lcs_debugfs_entry = NULL;
-		return rc;
-	}
+	seq->lcs_debugfs_entry = debugfs_create_dir(seq->lcs_name,
+						    seq_debugfs_dir);
 
 	rc = ldebugfs_add_vars(seq->lcs_debugfs_entry,
 			       seq_client_debugfs_list, seq);
@@ -424,10 +415,9 @@ static int __init fid_init(void)
 	if (rc)
 		return rc;
 
-	seq_debugfs_dir = ldebugfs_register(LUSTRE_SEQ_NAME,
-					    debugfs_lustre_root,
-					    NULL, NULL);
-	return PTR_ERR_OR_ZERO(seq_debugfs_dir);
+	seq_debugfs_dir = debugfs_create_dir(LUSTRE_SEQ_NAME,
+					     debugfs_lustre_root);
+	return 0;
 }
 
 static void __exit fid_exit(void)
diff --git a/drivers/staging/lustre/lustre/fld/fld_request.c b/drivers/staging/lustre/lustre/fld/fld_request.c
index 7b7ba93a4db6..409850379fc3 100644
--- a/drivers/staging/lustre/lustre/fld/fld_request.c
+++ b/drivers/staging/lustre/lustre/fld/fld_request.c
@@ -221,17 +221,8 @@ static int fld_client_debugfs_init(struct lu_client_fld *fld)
 {
 	int rc;
 
-	fld->lcf_debugfs_entry = ldebugfs_register(fld->lcf_name,
-						   fld_debugfs_dir,
-						   NULL, NULL);
-
-	if (IS_ERR_OR_NULL(fld->lcf_debugfs_entry)) {
-		CERROR("%s: LdebugFS failed in fld-init\n", fld->lcf_name);
-		rc = fld->lcf_debugfs_entry ? PTR_ERR(fld->lcf_debugfs_entry)
-					    : -ENOMEM;
-		fld->lcf_debugfs_entry = NULL;
-		return rc;
-	}
+	fld->lcf_debugfs_entry = debugfs_create_dir(fld->lcf_name,
+						    fld_debugfs_dir);
 
 	rc = ldebugfs_add_vars(fld->lcf_debugfs_entry,
 			       fld_client_debugfs_list, fld);
@@ -455,10 +446,9 @@ static int __init fld_init(void)
 	if (rc)
 		return rc;
 
-	fld_debugfs_dir = ldebugfs_register(LUSTRE_FLD_NAME,
-					    debugfs_lustre_root,
-					    NULL, NULL);
-	return PTR_ERR_OR_ZERO(fld_debugfs_dir);
+	fld_debugfs_dir = debugfs_create_dir(LUSTRE_FLD_NAME,
+					     debugfs_lustre_root);
+	return 0;
 }
 
 static void __exit fld_exit(void)
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
index b83e93256cd1..146b348ca312 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
@@ -572,14 +572,7 @@ static int ldlm_pool_debugfs_init(struct ldlm_pool *pl)
 		rc = -EINVAL;
 		goto out_free_name;
 	}
-	pl->pl_debugfs_entry = ldebugfs_register("pool", debugfs_ns_parent,
-						 NULL, NULL);
-	if (IS_ERR(pl->pl_debugfs_entry)) {
-		CERROR("LdebugFS failed in ldlm-pool-init\n");
-		rc = PTR_ERR(pl->pl_debugfs_entry);
-		pl->pl_debugfs_entry = NULL;
-		goto out_free_name;
-	}
+	pl->pl_debugfs_entry = debugfs_create_dir("pool", debugfs_ns_parent);
 
 	var_name[MAX_STRING_SIZE] = '\0';
 	memset(pool_vars, 0, sizeof(pool_vars));
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index 28cd8398d4ce..691899ef8044 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -110,34 +110,13 @@ int ldlm_debugfs_setup(void)
 {
 	int rc;
 
-	ldlm_debugfs_dir = ldebugfs_register(OBD_LDLM_DEVICENAME,
-					     debugfs_lustre_root,
-					     NULL, NULL);
-	if (IS_ERR_OR_NULL(ldlm_debugfs_dir)) {
-		CERROR("LProcFS failed in ldlm-init\n");
-		rc = ldlm_debugfs_dir ? PTR_ERR(ldlm_debugfs_dir) : -ENOMEM;
-		goto err;
-	}
+	ldlm_debugfs_dir = debugfs_create_dir(OBD_LDLM_DEVICENAME,
+					      debugfs_lustre_root);
 
-	ldlm_ns_debugfs_dir = ldebugfs_register("namespaces",
-						ldlm_debugfs_dir,
-						NULL, NULL);
-	if (IS_ERR_OR_NULL(ldlm_ns_debugfs_dir)) {
-		CERROR("LProcFS failed in ldlm-init\n");
-		rc = ldlm_ns_debugfs_dir ? PTR_ERR(ldlm_ns_debugfs_dir)
-					 : -ENOMEM;
-		goto err_type;
-	}
+	ldlm_ns_debugfs_dir = debugfs_create_dir("namespaces",
+						 ldlm_debugfs_dir);
 
-	ldlm_svc_debugfs_dir = ldebugfs_register("services",
-						 ldlm_debugfs_dir,
-						 NULL, NULL);
-	if (IS_ERR_OR_NULL(ldlm_svc_debugfs_dir)) {
-		CERROR("LProcFS failed in ldlm-init\n");
-		rc = ldlm_svc_debugfs_dir ? PTR_ERR(ldlm_svc_debugfs_dir)
-					  : -ENOMEM;
-		goto err_ns;
-	}
+	ldlm_svc_debugfs_dir = debugfs_create_dir("services", ldlm_debugfs_dir);
 
 	rc = ldebugfs_add_vars(ldlm_debugfs_dir, ldlm_debugfs_list, NULL);
 	if (rc) {
@@ -149,11 +128,8 @@ int ldlm_debugfs_setup(void)
 
 err_svc:
 	ldebugfs_remove(&ldlm_svc_debugfs_dir);
-err_ns:
 	ldebugfs_remove(&ldlm_ns_debugfs_dir);
-err_type:
 	ldebugfs_remove(&ldlm_debugfs_dir);
-err:
 	ldlm_svc_debugfs_dir = NULL;
 	ldlm_ns_debugfs_dir = NULL;
 	ldlm_debugfs_dir = NULL;
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 1f122f8a54dc..1ac36c9ed455 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -1157,12 +1157,7 @@ int ldebugfs_register_mountpoint(struct dentry *parent,
 	snprintf(name, MAX_STRING_SIZE, "%.*s-%p", len,
 		 lsi->lsi_lmd->lmd_profile, sb);
 
-	dir = ldebugfs_register(name, parent, NULL, NULL);
-	if (IS_ERR_OR_NULL(dir)) {
-		err = dir ? PTR_ERR(dir) : -ENOMEM;
-		sbi->ll_debugfs_entry = NULL;
-		return err;
-	}
+	dir = debugfs_create_dir(name, parent);
 	sbi->ll_debugfs_entry = dir;
 
 	debugfs_create_file("dump_page_cache", 0444, dir, sbi,
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index a2a5f59dfc7a..344ff4b20168 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -809,9 +809,8 @@ int lov_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	debugfs_create_file("target_obd", 0444, obd->obd_debugfs_entry, obd,
 			    &lov_proc_target_fops);
 
-	lov->lov_pool_debugfs_entry = ldebugfs_register("pools",
-						     obd->obd_debugfs_entry,
-						     NULL, NULL);
+	lov->lov_pool_debugfs_entry = debugfs_create_dir("pools",
+							 obd->obd_debugfs_entry);
 	return 0;
 
 out:
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index af233b868742..3771452b836c 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -170,15 +170,8 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
 	strcpy(type->typ_name, name);
 	spin_lock_init(&type->obd_type_lock);
 
-	type->typ_debugfs_entry = ldebugfs_register(type->typ_name,
-						    debugfs_lustre_root,
-						    NULL, type);
-	if (IS_ERR_OR_NULL(type->typ_debugfs_entry)) {
-		rc = type->typ_debugfs_entry ? PTR_ERR(type->typ_debugfs_entry)
-					     : -ENOMEM;
-		type->typ_debugfs_entry = NULL;
-		goto failed;
-	}
+	type->typ_debugfs_entry = debugfs_create_dir(type->typ_name,
+						     debugfs_lustre_root);
 
 	type->typ_kobj = kobject_create_and_add(type->typ_name, lustre_kobj);
 	if (!type->typ_kobj) {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
index eb21a8dd3708..62404b08f390 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
@@ -197,15 +197,10 @@ ptlrpc_ldebugfs_register(struct dentry *root, char *dir,
 	if (!svc_stats)
 		return;
 
-	if (dir) {
-		svc_debugfs_entry = ldebugfs_register(dir, root, NULL, NULL);
-		if (IS_ERR(svc_debugfs_entry)) {
-			lprocfs_free_stats(&svc_stats);
-			return;
-		}
-	} else {
+	if (dir)
+		svc_debugfs_entry = debugfs_create_dir(dir, root);
+	else
 		svc_debugfs_entry = root;
-	}
 
 	lprocfs_counter_init(svc_stats, PTLRPC_REQWAIT_CNTR,
 			     svc_counter_config, "req_waittime", "usec");
-- 
2.17.0
