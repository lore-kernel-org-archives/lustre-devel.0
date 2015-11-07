From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Date: Sat, 7 Nov 2015 20:46:33 +0530
Subject: [lustre-devel] [PATCH] staging: lustre: obdclass: Move extern
 declarations to header files
Message-ID: <20151107151632.GA7355@amitoj-Inspiron-3542>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This patch moves extern declarations to respective header files.

This patch also removes extern keyword from function declarations
since functions have the extern specifier by default.

Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
---
 drivers/staging/lustre/lustre/obdclass/cl_internal.h   | 3 +++
 drivers/staging/lustre/lustre/obdclass/cl_object.c     | 2 --
 drivers/staging/lustre/lustre/obdclass/class_obd.c     | 5 -----
 drivers/staging/lustre/lustre/obdclass/llog_internal.h | 7 +++++++
 drivers/staging/lustre/lustre/obdclass/obd_config.c    | 2 --
 5 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/cl_internal.h b/drivers/staging/lustre/lustre/obdclass/cl_internal.h
index 7eb0ad7..a9cc2e2 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_internal.h
+++ b/drivers/staging/lustre/lustre/obdclass/cl_internal.h
@@ -118,4 +118,7 @@ struct cl_thread_info {
 
 struct cl_thread_info *cl_env_info(const struct lu_env *env);
 
+extern __u32 lu_context_tags_default;
+extern __u32 lu_session_tags_default;
+
 #endif /* _CL_INTERNAL_H */
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index 89ff7f1..a1d76b9 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -70,8 +70,6 @@ static struct lock_class_key cl_lock_guard_class;
 /** Lock class of cl_object_header::coh_attr_guard */
 static struct lock_class_key cl_attr_guard_class;
 
-extern __u32 lu_context_tags_default;
-extern __u32 lu_session_tags_default;
 /**
  * Initialize cl_object_header.
  */
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index e8a1558..407354e 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -471,13 +471,9 @@ static int obd_init_checks(void)
 	return ret;
 }
 
-extern int class_procfs_init(void);
-extern int class_procfs_clean(void);
-
 static int __init init_obdclass(void)
 {
 	int i, err;
-	int lustre_register_fs(void);
 
 	LCONSOLE_INFO("Lustre: Build Version: "BUILD_VERSION"\n");
 
@@ -548,7 +544,6 @@ static int __init init_obdclass(void)
 static void cleanup_obdclass(void)
 {
 	int i;
-	int lustre_unregister_fs(void);
 
 	lustre_unregister_fs();
 
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_internal.h b/drivers/staging/lustre/lustre/obdclass/llog_internal.h
index b9fe4b0..9f30e01 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_internal.h
+++ b/drivers/staging/lustre/lustre/obdclass/llog_internal.h
@@ -60,6 +60,13 @@ struct llog_thread_info {
 };
 
 extern struct lu_context_key llog_thread_key;
+int lustre_check_exclusion(struct super_block *sb, char *svname);
+
+int class_procfs_init(void);
+int class_procfs_clean(void);
+
+int lustre_register_fs(void);
+int lustre_unregister_fs(void);
 
 int llog_info_init(void);
 void llog_info_fini(void);
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index b8ca324..6623626 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -1054,8 +1054,6 @@ int class_process_proc_param(char *prefix, struct lprocfs_vars *lvars,
 }
 EXPORT_SYMBOL(class_process_proc_param);
 
-extern int lustre_check_exclusion(struct super_block *sb, char *svname);
-
 /** Parse a configuration llog, doing various manipulations on them
  * for various reasons, (modifications for compatibility, skip obsolete
  * records, change uuids, etc), then class_process_config() resulting
-- 
1.9.1
