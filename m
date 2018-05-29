From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 29 May 2018 16:29:46 +0200
Subject: [lustre-devel] [PATCH 12/13] staging: lustre: make
 ldebugfs_add_vars a void function
In-Reply-To: <20180529142947.3250-1-gregkh@linuxfoundation.org>
References: <20180529142947.3250-1-gregkh@linuxfoundation.org>
Message-ID: <20180529142947.3250-12-gregkh@linuxfoundation.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The call to ldebugfs_add_vars() can not really fail, so have it just
return nothing, which allows us to clean up a lot of unused error
handling code.

Cc: Oleg Drokin <oleg.drokin@intel.com>
Cc: Andreas Dilger <andreas.dilger@intel.com>
Cc: James Simmons <jsimmons@infradead.org>
Cc: NeilBrown <neilb@suse.com>
Cc: Roman Storozhenko <romeusmeister@gmail.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Quentin Bouget <quentin.bouget@cea.fr>
Cc: Aastha Gupta <aastha.gupta4104@gmail.com>
Cc: Ben Evans <bevans@cray.com>
Cc: Arvind Yadav <arvind.yadav.cs@gmail.com>
Cc: Arushi Singhal <arushisinghal19971997@gmail.com>
Cc: Frank Zago <fzago@cray.com>
Cc: Patrick Farrell <paf@cray.com>
Cc: Simo Koskinen <koskisoft@gmail.com>
Cc: Andriy Skulysh <andriy.skulysh@seagate.com>
Cc: "John L. Hammond" <john.hammond@intel.com>
Cc: Mathias Rav <mathiasrav@gmail.com>
Cc: Dafna Hirschfeld <dafna3@gmail.com>
Cc: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Cc: lustre-devel at lists.lustre.org
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 .../staging/lustre/lustre/fid/fid_request.c   | 37 ++++---------------
 .../staging/lustre/lustre/fld/fld_request.c   | 30 +++------------
 .../lustre/lustre/include/lprocfs_status.h    |  5 +--
 .../lustre/lustre/include/lustre_dlm.h        |  2 +-
 .../staging/lustre/lustre/ldlm/ldlm_lockd.c   |  4 +-
 .../lustre/lustre/ldlm/ldlm_resource.c        | 21 +----------
 .../staging/lustre/lustre/llite/lproc_llite.c |  5 +--
 .../lustre/lustre/obdclass/lprocfs_status.c   | 17 ++++-----
 8 files changed, 27 insertions(+), 94 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index dfcac0afa106..bc748ab6645d 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -295,26 +295,12 @@ static void seq_client_debugfs_fini(struct lu_client_seq *seq)
 		ldebugfs_remove(&seq->lcs_debugfs_entry);
 }
 
-static int seq_client_debugfs_init(struct lu_client_seq *seq)
+static void seq_client_debugfs_init(struct lu_client_seq *seq)
 {
-	int rc;
-
 	seq->lcs_debugfs_entry = debugfs_create_dir(seq->lcs_name,
 						    seq_debugfs_dir);
 
-	rc = ldebugfs_add_vars(seq->lcs_debugfs_entry,
-			       seq_client_debugfs_list, seq);
-	if (rc) {
-		CERROR("%s: Can't init sequence manager debugfs, rc %d\n",
-		       seq->lcs_name, rc);
-		goto out_cleanup;
-	}
-
-	return 0;
-
-out_cleanup:
-	seq_client_debugfs_fini(seq);
-	return rc;
+	ldebugfs_add_vars(seq->lcs_debugfs_entry, seq_client_debugfs_list, seq);
 }
 
 static void seq_client_fini(struct lu_client_seq *seq)
@@ -327,13 +313,9 @@ static void seq_client_fini(struct lu_client_seq *seq)
 	}
 }
 
-static int seq_client_init(struct lu_client_seq *seq,
-			   struct obd_export *exp,
-			   enum lu_cli_type type,
-			   const char *prefix)
+static void seq_client_init(struct lu_client_seq *seq, struct obd_export *exp,
+			    enum lu_cli_type type, const char *prefix)
 {
-	int rc;
-
 	LASSERT(seq);
 	LASSERT(prefix);
 
@@ -354,10 +336,7 @@ static int seq_client_init(struct lu_client_seq *seq,
 	snprintf(seq->lcs_name, sizeof(seq->lcs_name),
 		 "cli-%s", prefix);
 
-	rc = seq_client_debugfs_init(seq);
-	if (rc)
-		seq_client_fini(seq);
-	return rc;
+	seq_client_debugfs_init(seq);
 }
 
 int client_fid_init(struct obd_device *obd,
@@ -380,12 +359,10 @@ int client_fid_init(struct obd_device *obd,
 	snprintf(prefix, MAX_OBD_NAME + 5, "cli-%s", obd->obd_name);
 
 	/* Init client side sequence-manager */
-	rc = seq_client_init(cli->cl_seq, exp, type, prefix);
+	seq_client_init(cli->cl_seq, exp, type, prefix);
 	kfree(prefix);
-	if (rc)
-		goto out_free_seq;
 
-	return rc;
+	return 0;
 out_free_seq:
 	kfree(cli->cl_seq);
 	cli->cl_seq = NULL;
diff --git a/drivers/staging/lustre/lustre/fld/fld_request.c b/drivers/staging/lustre/lustre/fld/fld_request.c
index 409850379fc3..cb67fee19451 100644
--- a/drivers/staging/lustre/lustre/fld/fld_request.c
+++ b/drivers/staging/lustre/lustre/fld/fld_request.c
@@ -217,25 +217,12 @@ int fld_client_del_target(struct lu_client_fld *fld, __u64 idx)
 
 static struct dentry *fld_debugfs_dir;
 
-static int fld_client_debugfs_init(struct lu_client_fld *fld)
+static void fld_client_debugfs_init(struct lu_client_fld *fld)
 {
-	int rc;
-
 	fld->lcf_debugfs_entry = debugfs_create_dir(fld->lcf_name,
 						    fld_debugfs_dir);
 
-	rc = ldebugfs_add_vars(fld->lcf_debugfs_entry,
-			       fld_client_debugfs_list, fld);
-	if (rc) {
-		CERROR("%s: Can't init FLD debufs, rc %d\n", fld->lcf_name, rc);
-		goto out_cleanup;
-	}
-
-	return 0;
-
-out_cleanup:
-	fld_client_debugfs_fini(fld);
-	return rc;
+	ldebugfs_add_vars(fld->lcf_debugfs_entry, fld_client_debugfs_list, fld);
 }
 
 void fld_client_debugfs_fini(struct lu_client_fld *fld)
@@ -254,7 +241,7 @@ int fld_client_init(struct lu_client_fld *fld,
 		    const char *prefix, int hash)
 {
 	int cache_size, cache_threshold;
-	int rc;
+	int rc = 0;
 
 	snprintf(fld->lcf_name, sizeof(fld->lcf_name),
 		 "cli-%s", prefix);
@@ -284,15 +271,10 @@ int fld_client_init(struct lu_client_fld *fld,
 		goto out;
 	}
 
-	rc = fld_client_debugfs_init(fld);
-	if (rc)
-		goto out;
+	fld_client_debugfs_init(fld);
 out:
-	if (rc)
-		fld_client_fini(fld);
-	else
-		CDEBUG(D_INFO, "%s: Using \"%s\" hash\n",
-		       fld->lcf_name, fld->lcf_hash->fh_name);
+	CDEBUG(D_INFO, "%s: Using \"%s\" hash\n",
+	       fld->lcf_name, fld->lcf_hash->fh_name);
 	return rc;
 }
 EXPORT_SYMBOL(fld_client_init);
diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index 912c65b2f72b..b18bcb337504 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -450,9 +450,8 @@ int lprocfs_exp_cleanup(struct obd_export *exp);
 extern const struct file_operations lprocfs_stats_seq_fops;
 
 /* lprocfs_status.c */
-int ldebugfs_add_vars(struct dentry *parent,
-		      struct lprocfs_vars *var,
-		      void *data);
+void ldebugfs_add_vars(struct dentry *parent, struct lprocfs_vars *var,
+		       void *data);
 
 void ldebugfs_remove(struct dentry **entryp);
 
diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index b3532adac31c..2c55241258cc 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -1185,7 +1185,7 @@ void ldlm_namespace_free_prior(struct ldlm_namespace *ns,
 void ldlm_namespace_free_post(struct ldlm_namespace *ns);
 void ldlm_namespace_get(struct ldlm_namespace *ns);
 void ldlm_namespace_put(struct ldlm_namespace *ns);
-int ldlm_debugfs_setup(void);
+void ldlm_debugfs_setup(void);
 void ldlm_debugfs_cleanup(void);
 
 /* resource.c - internal */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index b0a29f50c7d6..5963e90d0938 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -979,9 +979,7 @@ static int ldlm_setup(void)
 		goto out;
 	}
 
-	rc = ldlm_debugfs_setup();
-	if (rc != 0)
-		goto out;
+	ldlm_debugfs_setup();
 
 	memset(&conf, 0, sizeof(conf));
 	conf = (typeof(conf)) {
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index 691899ef8044..6b94a2b2a0fc 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -106,10 +106,8 @@ static struct lprocfs_vars ldlm_debugfs_list[] = {
 	{ NULL }
 };
 
-int ldlm_debugfs_setup(void)
+void ldlm_debugfs_setup(void)
 {
-	int rc;
-
 	ldlm_debugfs_dir = debugfs_create_dir(OBD_LDLM_DEVICENAME,
 					      debugfs_lustre_root);
 
@@ -118,22 +116,7 @@ int ldlm_debugfs_setup(void)
 
 	ldlm_svc_debugfs_dir = debugfs_create_dir("services", ldlm_debugfs_dir);
 
-	rc = ldebugfs_add_vars(ldlm_debugfs_dir, ldlm_debugfs_list, NULL);
-	if (rc) {
-		CERROR("LProcFS failed in ldlm-init\n");
-		goto err_svc;
-	}
-
-	return 0;
-
-err_svc:
-	ldebugfs_remove(&ldlm_svc_debugfs_dir);
-	ldebugfs_remove(&ldlm_ns_debugfs_dir);
-	ldebugfs_remove(&ldlm_debugfs_dir);
-	ldlm_svc_debugfs_dir = NULL;
-	ldlm_ns_debugfs_dir = NULL;
-	ldlm_debugfs_dir = NULL;
-	return rc;
+	ldebugfs_add_vars(ldlm_debugfs_dir, ldlm_debugfs_list, NULL);
 }
 
 void ldlm_debugfs_cleanup(void)
diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
index 1ac36c9ed455..d2f42c727ed4 100644
--- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
+++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
@@ -1210,10 +1210,7 @@ int ldebugfs_register_mountpoint(struct dentry *parent,
 	debugfs_create_file("stats", 0644, sbi->ll_debugfs_entry,
 			    sbi->ll_ra_stats, &lprocfs_stats_seq_fops);
 
-	err = ldebugfs_add_vars(sbi->ll_debugfs_entry,
-				lprocfs_llite_obd_vars, sb);
-	if (err)
-		goto out;
+	ldebugfs_add_vars(sbi->ll_debugfs_entry, lprocfs_llite_obd_vars, sb);
 
 	sbi->ll_kobj.kset = llite_kset;
 	init_completion(&sbi->ll_kobj_unregister);
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 91af79facbc0..a8299a8cdad9 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -302,15 +302,13 @@ EXPORT_SYMBOL(lprocfs_seq_release);
 
 static const struct file_operations lprocfs_generic_fops = { };
 
-int ldebugfs_add_vars(struct dentry *parent,
-		      struct lprocfs_vars *list,
-		      void *data)
+void ldebugfs_add_vars(struct dentry *parent, struct lprocfs_vars *list,
+		       void *data)
 {
 	if (IS_ERR_OR_NULL(parent) || IS_ERR_OR_NULL(list))
-		return -EINVAL;
+		return;
 
 	while (list->name) {
-		struct dentry *entry;
 		umode_t mode = 0;
 
 		if (list->proc_mode != 0000) {
@@ -321,13 +319,12 @@ int ldebugfs_add_vars(struct dentry *parent,
 			if (list->fops->write)
 				mode |= 0200;
 		}
-		entry = debugfs_create_file(list->name, mode, parent,
-					    list->data ?: data,
-					    list->fops ?: &lprocfs_generic_fops
-					   );
+		debugfs_create_file(list->name, mode, parent,
+				    list->data ?: data,
+				    list->fops ?: &lprocfs_generic_fops);
 		list++;
 	}
-	return 0;
+	return;
 }
 EXPORT_SYMBOL_GPL(ldebugfs_add_vars);
 
-- 
2.17.0
