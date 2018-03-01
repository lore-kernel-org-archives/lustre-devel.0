From: NeilBrown <neilb@suse.com>
Date: Fri, 02 Mar 2018 10:31:25 +1100
Subject: [lustre-devel] [PATCH 15/17] staging: lustre: ptlrpc: move thread
 creation out of module initialization
In-Reply-To: <151994679573.7628.1024109499321778846.stgit@noble>
References: <151994679573.7628.1024109499321778846.stgit@noble>
Message-ID: <151994708557.7628.14705551472003114360.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

When the ptlrpc module is loaded, it starts the pinger thread and
calls LNetNIInit which starts various threads.

We don't need these threads until the module is actually being
used, such as when a lustre filesystem is mounted.

So move the thread creation into new ptlrpc_inc_ref() (modeled on
ptlrpcd_inc_ref()), and call that when needed, such as at mount time.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/lustre_net.h |    3 +
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |   12 ++++
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   18 +++++-
 .../staging/lustre/lustre/ptlrpc/ptlrpc_module.c   |   56 +++++++++++++-------
 4 files changed, 65 insertions(+), 24 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 108683c54127..d35ae0cda8d2 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -1804,6 +1804,9 @@ int ptlrpc_register_rqbd(struct ptlrpc_request_buffer_desc *rqbd);
  */
 void ptlrpc_request_committed(struct ptlrpc_request *req, int force);
 
+int ptlrpc_inc_ref(void);
+void ptlrpc_dec_ref(void);
+
 void ptlrpc_init_client(int req_portal, int rep_portal, char *name,
 			struct ptlrpc_client *);
 struct ptlrpc_connection *ptlrpc_uuid_to_connection(struct obd_uuid *uuid);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index 58913e628124..c772c68e5a49 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -869,6 +869,10 @@ int ldlm_get_ref(void)
 {
 	int rc = 0;
 
+	rc = ptlrpc_inc_ref();
+	if (rc)
+		return rc;
+
 	mutex_lock(&ldlm_ref_mutex);
 	if (++ldlm_refcount == 1) {
 		rc = ldlm_setup();
@@ -877,14 +881,18 @@ int ldlm_get_ref(void)
 	}
 	mutex_unlock(&ldlm_ref_mutex);
 
+	if (rc)
+		ptlrpc_dec_ref();
+
 	return rc;
 }
 
 void ldlm_put_ref(void)
 {
+	int rc = 0;
 	mutex_lock(&ldlm_ref_mutex);
 	if (ldlm_refcount == 1) {
-		int rc = ldlm_cleanup();
+		rc = ldlm_cleanup();
 
 		if (rc)
 			CERROR("ldlm_cleanup failed: %d\n", rc);
@@ -894,6 +902,8 @@ void ldlm_put_ref(void)
 		ldlm_refcount--;
 	}
 	mutex_unlock(&ldlm_ref_mutex);
+	if (!rc)
+		ptlrpc_dec_ref();
 }
 
 static ssize_t cancel_unused_locks_before_replay_show(struct kobject *kobj,
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 844182ad7dd7..706b14bf8981 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -879,9 +879,15 @@ int ll_fill_super(struct super_block *sb)
 
 	CDEBUG(D_VFSTRACE, "VFS Op: sb %p\n", sb);
 
+	err = ptlrpc_inc_ref();
+	if (err)
+		return err;
+
 	cfg = kzalloc(sizeof(*cfg), GFP_NOFS);
-	if (!cfg)
-		return -ENOMEM;
+	if (!cfg) {
+		err = -ENOMEM;
+		goto out_put;
+	}
 
 	try_module_get(THIS_MODULE);
 
@@ -891,7 +897,8 @@ int ll_fill_super(struct super_block *sb)
 	if (!sbi) {
 		module_put(THIS_MODULE);
 		kfree(cfg);
-		return -ENOMEM;
+		err = -ENOMEM;
+		goto out_put;
 	}
 
 	err = ll_options(lsi->lsi_lmd->lmd_opts, &sbi->ll_flags);
@@ -958,6 +965,9 @@ int ll_fill_super(struct super_block *sb)
 		LCONSOLE_WARN("Mounted %s\n", profilenm);
 
 	kfree(cfg);
+out_put:
+	if (err)
+		ptlrpc_dec_ref();
 	return err;
 } /* ll_fill_super */
 
@@ -1028,6 +1038,8 @@ void ll_put_super(struct super_block *sb)
 	cl_env_cache_purge(~0);
 
 	module_put(THIS_MODULE);
+
+	ptlrpc_dec_ref();
 } /* client_put_super */
 
 struct inode *ll_inode_from_resource_lock(struct ldlm_lock *lock)
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c
index 131fc6d9646e..38923418669f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c
@@ -45,6 +45,42 @@ extern spinlock_t ptlrpc_last_xid_lock;
 extern spinlock_t ptlrpc_rs_debug_lock;
 #endif
 
+DEFINE_MUTEX(ptlrpc_startup);
+static int ptlrpc_active = 0;
+
+int ptlrpc_inc_ref(void)
+{
+	int rc = 0;
+
+	mutex_lock(&ptlrpc_startup);
+	if (ptlrpc_active++ == 0) {
+		ptlrpc_put_connection_superhack = ptlrpc_connection_put;
+
+		rc = ptlrpc_init_portals();
+		if (!rc) {
+			rc= ptlrpc_start_pinger();
+			if (rc)
+				ptlrpc_exit_portals();
+		}
+		if (rc)
+			ptlrpc_active--;
+	}
+	mutex_unlock(&ptlrpc_startup);
+	return rc;
+}
+EXPORT_SYMBOL(ptlrpc_inc_ref);
+
+void ptlrpc_dec_ref(void)
+{
+	mutex_lock(&ptlrpc_startup);
+	if (--ptlrpc_active == 0) {
+		ptlrpc_stop_pinger();
+		ptlrpc_exit_portals();
+	}
+	mutex_unlock(&ptlrpc_startup);
+}
+EXPORT_SYMBOL(ptlrpc_dec_ref);
+
 static int __init ptlrpc_init(void)
 {
 	int rc, cleanup_phase = 0;
@@ -71,24 +107,12 @@ static int __init ptlrpc_init(void)
 	if (rc)
 		goto cleanup;
 
-	cleanup_phase = 2;
-	rc = ptlrpc_init_portals();
-	if (rc)
-		goto cleanup;
-
 	cleanup_phase = 3;
 
 	rc = ptlrpc_connection_init();
 	if (rc)
 		goto cleanup;
 
-	cleanup_phase = 4;
-	ptlrpc_put_connection_superhack = ptlrpc_connection_put;
-
-	rc = ptlrpc_start_pinger();
-	if (rc)
-		goto cleanup;
-
 	cleanup_phase = 5;
 	rc = ldlm_init();
 	if (rc)
@@ -122,15 +146,9 @@ static int __init ptlrpc_init(void)
 		ldlm_exit();
 		/* Fall through */
 	case 5:
-		ptlrpc_stop_pinger();
-		/* Fall through */
-	case 4:
 		ptlrpc_connection_fini();
 		/* Fall through */
 	case 3:
-		ptlrpc_exit_portals();
-		/* Fall through */
-	case 2:
 		ptlrpc_request_cache_fini();
 		/* Fall through */
 	case 1:
@@ -150,8 +168,6 @@ static void __exit ptlrpc_exit(void)
 	ptlrpc_nrs_fini();
 	sptlrpc_fini();
 	ldlm_exit();
-	ptlrpc_stop_pinger();
-	ptlrpc_exit_portals();
 	ptlrpc_request_cache_fini();
 	ptlrpc_hr_fini();
 	ptlrpc_connection_fini();
