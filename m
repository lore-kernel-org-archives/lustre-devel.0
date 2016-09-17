From: Baoyou Xie <baoyou.xie@linaro.org>
Date: Sat, 17 Sep 2016 21:30:35 +0800
Subject: [lustre-devel] [PATCH] staging: lustre: obdclass: clean function
	declarations in obd_config.c and class_obd.c up
Message-ID: <1474119035-15629-1-git-send-email-baoyou.xie@linaro.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org, john.hammond@intel.com, shraddha.6596@gmail.com, di.wang@intel.com, ksenija.stanojevic@gmail.com, mike.rapoport@gmail.com, andrew.perepechko@seagate.com, kirill.shutemov@linux.intel.com, emoly.liu@intel.com, arnd@arndb.de, amir.shehata@intel.com, dmitry.eremin@intel.com
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn

We get 3 warnings when building kernel with W=1:

drivers/staging/lustre/lustre/obdclass/obd_mount.c:705:5: warning: no previous prototype for 'lustre_check_exclusion' [-Wmissing-prototypes]
drivers/staging/lustre/lustre/obdclass/obd_mount.c:1226:5: warning: no previous prototype for 'lustre_register_fs' [-Wmissing-prototypes]
drivers/staging/lustre/lustre/obdclass/obd_mount.c:1231:5: warning: no previous prototype for 'lustre_unregister_fs' [-Wmissing-prototypes]

In fact, the first function is declared in
drivers/staging/lustre/lustre/obdclass/obd_config.c,
and the other two functions are declared in
drivers/staging/lustre/lustre/obdclass/class_obd.c,
but all of these functions should be declared in 
a header file, thus can be recognized in other file.

So this patch moves the declarations into
drivers/staging/lustre/lustre/include/obd_class.h.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/staging/lustre/lustre/include/obd_class.h   | 3 +++
 drivers/staging/lustre/lustre/obdclass/class_obd.c  | 4 ----
 drivers/staging/lustre/lustre/obdclass/obd_config.c | 2 --
 3 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 9965a01..4a8a459 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -1696,6 +1696,9 @@ struct lwp_register_item {
 extern int (*ptlrpc_put_connection_superhack)(struct ptlrpc_connection *c);
 
 /* obd_mount.c */
+int lustre_unregister_fs(void);
+int lustre_register_fs(void);
+int lustre_check_exclusion(struct super_block *sb, char *svname);
 
 /* sysctl.c */
 int obd_sysctl_init(void);
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 397929a..381b8ba 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -451,8 +451,6 @@ static int __init obdclass_init(void)
 {
 	int i, err;
 
-	int lustre_register_fs(void);
-
 	LCONSOLE_INFO("Lustre: Build Version: " LUSTRE_VERSION_STRING "\n");
 
 	spin_lock_init(&obd_types_lock);
@@ -519,8 +517,6 @@ static int __init obdclass_init(void)
 
 static void obdclass_exit(void)
 {
-	int lustre_unregister_fs(void);
-
 	lustre_unregister_fs();
 
 	misc_deregister(&obd_psdev);
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index b7dcadb..036f396 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -1047,8 +1047,6 @@ int class_process_proc_param(char *prefix, struct lprocfs_vars *lvars,
 }
 EXPORT_SYMBOL(class_process_proc_param);
 
-extern int lustre_check_exclusion(struct super_block *sb, char *svname);
-
 /** Parse a configuration llog, doing various manipulations on them
  * for various reasons, (modifications for compatibility, skip obsolete
  * records, change uuids, etc), then class_process_config() resulting
-- 
2.7.4
