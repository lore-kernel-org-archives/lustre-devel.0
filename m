From: NeilBrown <neilb@suse.com>
Date: Mon, 21 May 2018 14:35:12 +1000
Subject: [lustre-devel] [PATCH 02/30] staging: lustre: refactor libcfs
 initialization.
In-Reply-To: <152687724799.24196.7718555295926047576.stgit@noble>
References: <152687724799.24196.7718555295926047576.stgit@noble>
Message-ID: <152687731241.24196.14303163540777378961.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Many lustre modules depend on libcfs having initialized
properly, but do not explicit check that it did.
When lustre is built as discrete modules, this does not
cause a problem because if the libcfs module fails
initialization, the other modules don't even get loaded.

When lustre is compiled into the kernel, all module_init()
routines get run, so they need to check the required initialization
succeeded.

This patch splits out the initialization of libcfs into a new
libcfs_setup(), and has all modules call that.

The misc_register() call is kept separate as it does not allocate any
resources and if it fails, it fails hard - no point in retrying.
Other set-up allocates resources and so is best delayed until they
are needed, and can be worth retrying.

Ideally, the initialization would happen at mount time (or similar)
rather than at load time.  Doing this requires each module to
check dependencies when they are activated rather than when
they are loaded.  Achieving that is a much larger job that would
have to progress in stages.

For now, this change ensures that if some initialization in libcfs
fails, other modules will fail-safe.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |    1 
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    6 ++
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    4 +
 .../lustre/lnet/libcfs/linux/linux-crypto.c        |    6 +-
 drivers/staging/lustre/lnet/libcfs/module.c        |   64 +++++++++++++-------
 drivers/staging/lustre/lnet/lnet/module.c          |    4 +
 drivers/staging/lustre/lnet/selftest/module.c      |    6 ++
 drivers/staging/lustre/lustre/fid/fid_request.c    |    6 ++
 drivers/staging/lustre/lustre/fld/fld_request.c    |    6 ++
 drivers/staging/lustre/lustre/llite/super25.c      |    4 +
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |    5 ++
 drivers/staging/lustre/lustre/lov/lov_obd.c        |    4 +
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    5 ++
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |    6 ++
 drivers/staging/lustre/lustre/obdclass/class_obd.c |    5 ++
 .../staging/lustre/lustre/obdecho/echo_client.c    |    6 ++
 drivers/staging/lustre/lustre/osc/osc_request.c    |    4 +
 .../staging/lustre/lustre/ptlrpc/ptlrpc_module.c   |    4 +
 18 files changed, 122 insertions(+), 24 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index d420449b620e..4c91ef45abb6 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -137,6 +137,7 @@ struct libcfs_ioctl_handler {
 
 int libcfs_register_ioctl(struct libcfs_ioctl_handler *hand);
 int libcfs_deregister_ioctl(struct libcfs_ioctl_handler *hand);
+int libcfs_setup(void);
 
 #define _LIBCFS_H
 
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index cace9ba6f474..f0b4eb42bc1d 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2928,6 +2928,8 @@ static void __exit ko2iblnd_exit(void)
 
 static int __init ko2iblnd_init(void)
 {
+	int rc;
+
 	BUILD_BUG_ON(sizeof(struct kib_msg) > IBLND_MSG_SIZE);
 	BUILD_BUG_ON(offsetof(struct kib_msg,
 			  ibm_u.get.ibgm_rd.rd_frags[IBLND_MAX_RDMA_FRAGS])
@@ -2938,6 +2940,10 @@ static int __init ko2iblnd_init(void)
 
 	kiblnd_tunables_init();
 
+	rc = libcfs_setup();
+	if (rc)
+		return rc;
+
 	lnet_register_lnd(&the_o2iblnd);
 
 	return 0;
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 79b98cdd0f9d..f01b34ac1a53 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -2903,6 +2903,10 @@ static int __init ksocklnd_init(void)
 	if (rc)
 		return rc;
 
+	rc = libcfs_setup();
+	if (rc)
+		return rc;
+
 	lnet_register_lnd(&the_ksocklnd);
 
 	return 0;
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
index b55006264155..18113335503b 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
@@ -426,7 +426,8 @@ int cfs_crypto_register(void)
 {
 	request_module("crc32c");
 
-	adler32 = cfs_crypto_adler32_register();
+	if (cfs_crypto_adler32_register() == 0)
+		adler32 = 1;
 
 	/* check all algorithms and do performance test */
 	cfs_crypto_test_hashes();
@@ -438,6 +439,7 @@ int cfs_crypto_register(void)
  */
 void cfs_crypto_unregister(void)
 {
-	if (!adler32)
+	if (adler32)
 		cfs_crypto_adler32_unregister();
+	adler32 = 0;
 }
diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index ca942f474a55..0e3bfe4e2cb1 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -314,12 +314,14 @@ static const struct file_operations libcfs_fops = {
 	.unlocked_ioctl	= libcfs_psdev_ioctl,
 };
 
-struct miscdevice libcfs_dev = {
+static struct miscdevice libcfs_dev = {
 	.minor = MISC_DYNAMIC_MINOR,
 	.name = "lnet",
 	.fops = &libcfs_fops,
 };
 
+static int libcfs_dev_registered;
+
 int lprocfs_call_handler(void *data, int write, loff_t *ppos,
 			 void __user *buffer, size_t *lenp,
 			 int (*handler)(void *data, int write, loff_t pos,
@@ -687,49 +689,70 @@ static void lustre_remove_debugfs(void)
 	lnet_debugfs_root = NULL;
 }
 
-static int libcfs_init(void)
+static DEFINE_MUTEX(libcfs_startup);
+static int libcfs_active;
+
+int libcfs_setup(void)
 {
-	int rc;
+	int rc = -EINVAL;
+
+	mutex_lock(&libcfs_startup);
+	if (libcfs_active)
+		goto out;
+
+	if (!libcfs_dev_registered)
+		goto err;
 
 	rc = libcfs_debug_init(5 * 1024 * 1024);
 	if (rc < 0) {
 		pr_err("LustreError: libcfs_debug_init: %d\n", rc);
-		return rc;
+		goto err;
 	}
 
 	rc = cfs_cpu_init();
 	if (rc)
-		goto cleanup_debug;
-
-	rc = misc_register(&libcfs_dev);
-	if (rc) {
-		CERROR("misc_register: error %d\n", rc);
-		goto cleanup_cpu;
-	}
+		goto err;
 
 	cfs_rehash_wq = alloc_workqueue("cfs_rh", WQ_SYSFS, 4);
 	if (!cfs_rehash_wq) {
 		CERROR("Failed to start rehash workqueue.\n");
 		rc = -ENOMEM;
-		goto cleanup_deregister;
+		goto err;
 	}
 
 	rc = cfs_crypto_register();
 	if (rc) {
 		CERROR("cfs_crypto_register: error %d\n", rc);
-		goto cleanup_deregister;
+		goto err;
 	}
 
 	lustre_insert_debugfs(lnet_table, lnet_debugfs_symlinks);
 
 	CDEBUG(D_OTHER, "portals setup OK\n");
+out:
+	libcfs_active = 1;
+	mutex_unlock(&libcfs_startup);
 	return 0;
- cleanup_deregister:
-	misc_deregister(&libcfs_dev);
-cleanup_cpu:
+err:
+	cfs_crypto_unregister();
+	if (cfs_rehash_wq)
+		destroy_workqueue(cfs_rehash_wq);
 	cfs_cpu_fini();
- cleanup_debug:
 	libcfs_debug_cleanup();
+	mutex_unlock(&libcfs_startup);
+	return rc;
+}
+EXPORT_SYMBOL(libcfs_setup);
+
+static int libcfs_init(void)
+{
+	int rc;
+
+	rc = misc_register(&libcfs_dev);
+	if (rc)
+		CERROR("misc_register: error %d\n", rc);
+	else
+		libcfs_dev_registered = 1;
 	return rc;
 }
 
@@ -739,14 +762,13 @@ static void libcfs_exit(void)
 
 	lustre_remove_debugfs();
 
-	if (cfs_rehash_wq) {
+	if (cfs_rehash_wq)
 		destroy_workqueue(cfs_rehash_wq);
-		cfs_rehash_wq = NULL;
-	}
 
 	cfs_crypto_unregister();
 
-	misc_deregister(&libcfs_dev);
+	if (libcfs_dev_registered)
+		misc_deregister(&libcfs_dev);
 
 	cfs_cpu_fini();
 
diff --git a/drivers/staging/lustre/lnet/lnet/module.c b/drivers/staging/lustre/lnet/lnet/module.c
index c0c4723f72fd..f6e912e79ca7 100644
--- a/drivers/staging/lustre/lnet/lnet/module.c
+++ b/drivers/staging/lustre/lnet/lnet/module.c
@@ -184,6 +184,10 @@ static int __init lnet_init(void)
 
 	mutex_init(&lnet_config_mutex);
 
+	rc = libcfs_setup();
+	if (rc)
+		return rc;
+
 	rc = lnet_lib_init();
 	if (rc) {
 		CERROR("lnet_lib_init: error %d\n", rc);
diff --git a/drivers/staging/lustre/lnet/selftest/module.c b/drivers/staging/lustre/lnet/selftest/module.c
index 7359aa56d9b3..9ba65320f748 100644
--- a/drivers/staging/lustre/lnet/selftest/module.c
+++ b/drivers/staging/lustre/lnet/selftest/module.c
@@ -89,9 +89,13 @@ static int
 lnet_selftest_init(void)
 {
 	int nscheds;
-	int rc = -ENOMEM;
+	int rc;
 	int i;
 
+	rc = libcfs_setup();
+	if (rc)
+		return rc;
+
 	lst_serial_wq = alloc_ordered_workqueue("lst_s", 0);
 	if (!lst_serial_wq) {
 		CERROR("Failed to create serial WI scheduler for LST\n");
diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index 030680f37c79..fc6582fe117f 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -419,6 +419,12 @@ EXPORT_SYMBOL(client_fid_fini);
 
 static int __init fid_init(void)
 {
+	int rc;
+
+	rc = libcfs_setup();
+	if (rc)
+		return rc;
+
 	seq_debugfs_dir = ldebugfs_register(LUSTRE_SEQ_NAME,
 					    debugfs_lustre_root,
 					    NULL, NULL);
diff --git a/drivers/staging/lustre/lustre/fld/fld_request.c b/drivers/staging/lustre/lustre/fld/fld_request.c
index 068c364adda8..b2d77c8d3dc7 100644
--- a/drivers/staging/lustre/lustre/fld/fld_request.c
+++ b/drivers/staging/lustre/lustre/fld/fld_request.c
@@ -450,6 +450,12 @@ void fld_client_flush(struct lu_client_fld *fld)
 
 static int __init fld_init(void)
 {
+	int rc;
+
+	rc = libcfs_setup();
+	if (rc)
+		return rc;
+
 	fld_debugfs_dir = ldebugfs_register(LUSTRE_FLD_NAME,
 					    debugfs_lustre_root,
 					    NULL, NULL);
diff --git a/drivers/staging/lustre/lustre/llite/super25.c b/drivers/staging/lustre/lustre/llite/super25.c
index 861e7a60f408..d335f29556c2 100644
--- a/drivers/staging/lustre/lustre/llite/super25.c
+++ b/drivers/staging/lustre/lustre/llite/super25.c
@@ -90,6 +90,10 @@ static int __init lustre_init(void)
 	BUILD_BUG_ON(sizeof(LUSTRE_VOLATILE_HDR) !=
 		     LUSTRE_VOLATILE_HDR_LEN + 1);
 
+	rc = libcfs_setup();
+	if (rc)
+		return rc;
+
 	/* print an address of _any_ initialized kernel symbol from this
 	 * module, to allow debugging with gdb that doesn't support data
 	 * symbols from modules.
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 7198a6384028..b55be6cb52bb 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -3108,9 +3108,14 @@ static struct md_ops lmv_md_ops = {
 static int __init lmv_init(void)
 {
 	struct lprocfs_static_vars lvars;
+	int rc;
 
 	lprocfs_lmv_init_vars(&lvars);
 
+	rc = libcfs_setup();
+	if (rc)
+		return rc;
+
 	return class_register_type(&lmv_obd_ops, &lmv_md_ops,
 				 LUSTRE_LMV_NAME, NULL);
 }
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 94da35e673f7..d091e03098b5 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -1403,6 +1403,10 @@ static int __init lov_init(void)
 	 */
 	CDEBUG(D_INFO, "Lustre LOV module (%p).\n", &lov_caches);
 
+	rc = libcfs_setup();
+	if (rc)
+		return rc;
+
 	rc = lu_kmem_init(lov_caches);
 	if (rc)
 		return rc;
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 7d577bf535aa..0eaf35c55966 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -2733,6 +2733,11 @@ static struct md_ops mdc_md_ops = {
 static int __init mdc_init(void)
 {
 	struct lprocfs_static_vars lvars = { NULL };
+	int rc;
+
+	rc = libcfs_setup();
+	if (rc)
+		return rc;
 
 	lprocfs_mdc_init_vars(&lvars);
 
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index c61cd23a96df..36c3f13ab9f4 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -1826,6 +1826,12 @@ static struct obd_ops mgc_obd_ops = {
 
 static int __init mgc_init(void)
 {
+	int rc;
+
+	rc = libcfs_setup();
+	if (rc)
+		return rc;
+
 	return class_register_type(&mgc_obd_ops, NULL,
 				   LUSTRE_MGC_NAME, NULL);
 }
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 7b5be6b123bf..2dd8728760d1 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -449,6 +449,11 @@ static int __init obdclass_init(void)
 	LCONSOLE_INFO("Lustre: Build Version: " LUSTRE_VERSION_STRING "\n");
 
 	spin_lock_init(&obd_types_lock);
+
+	err = libcfs_setup();
+	if (err)
+		return err;
+
 	obd_zombie_impexp_init();
 
 	err = obd_init_checks();
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 767067b61109..9a078358188b 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -1701,10 +1701,16 @@ static void echo_client_exit(void)
 
 static int __init obdecho_init(void)
 {
+	int rc;
+
 	LCONSOLE_INFO("Echo OBD driver; http://www.lustre.org/\n");
 
 	LASSERT(PAGE_SIZE % OBD_ECHO_BLOCK_SIZE == 0);
 
+	rc = libcfs_setup();
+	if (rc)
+		return rc;
+
 	return echo_client_init();
 }
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 0b5245741e42..2c92119b37be 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2831,6 +2831,10 @@ static int __init osc_init(void)
 	 */
 	CDEBUG(D_INFO, "Lustre OSC module (%p).\n", &osc_caches);
 
+	rc = libcfs_setup();
+	if (rc)
+		return rc;
+
 	rc = lu_kmem_init(osc_caches);
 	if (rc)
 		return rc;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c
index 38923418669f..5c32b657b3b5 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_module.c
@@ -94,6 +94,10 @@ static int __init ptlrpc_init(void)
 	mutex_init(&ptlrpcd_mutex);
 	ptlrpc_init_xid();
 
+	rc = libcfs_setup();
+	if (rc)
+		return rc;
+
 	rc = req_layout_init();
 	if (rc)
 		return rc;
