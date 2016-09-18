From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:49 -0400
Subject: [lustre-devel] [PATCH 110/124] staging: lustre: obdclass: remove
	unnecessary EXPORT_SYMBOL
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-111-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, frank zago <fzago@cray.com>, James Simmons <jsimmons@infradead.org>

From: frank zago <fzago@cray.com>

A lot of symbols don't need to be exported at all because they are
only used in the module they belong to.

Signed-off-by: frank zago <fzago@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5829
Reviewed-on: http://review.whamcloud.com/13323
Reviewed-by: Jian Yu <jian.yu@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/obdclass/cl_io.c     |    1 -
 drivers/staging/lustre/lustre/obdclass/cl_page.c   |    2 --
 drivers/staging/lustre/lustre/obdclass/class_obd.c |    3 ---
 drivers/staging/lustre/lustre/obdclass/genops.c    |    8 --------
 .../lustre/lustre/obdclass/linux/linux-module.c    |    1 -
 drivers/staging/lustre/lustre/obdclass/llog_obd.c  |    1 -
 drivers/staging/lustre/lustre/obdclass/llog_swab.c |    2 --
 .../lustre/lustre/obdclass/lprocfs_status.c        |    2 --
 drivers/staging/lustre/lustre/obdclass/lu_object.c |    4 ----
 .../staging/lustre/lustre/obdclass/lustre_peer.c   |    1 -
 10 files changed, 0 insertions(+), 25 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index 7894cf9..bc4b7b6 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -73,7 +73,6 @@ int cl_io_is_going(const struct lu_env *env)
 {
 	return cl_env_info(env)->clt_current_io != NULL;
 }
-EXPORT_SYMBOL(cl_io_is_going);
 
 /**
  * cl_io invariant that holds at all times when exported cl_io_*() functions
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
index 18784a8..63973ba 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
@@ -170,7 +170,6 @@ struct cl_page *cl_page_alloc(const struct lu_env *env,
 	}
 	return page;
 }
-EXPORT_SYMBOL(cl_page_alloc);
 
 /**
  * Returns a cl_page with index \a idx at the object \a o, and associated with
@@ -1006,7 +1005,6 @@ int cl_page_cancel(const struct lu_env *env, struct cl_page *page)
 			      (const struct lu_env *,
 			       const struct cl_page_slice *));
 }
-EXPORT_SYMBOL(cl_page_cancel);
 
 /**
  * Converts a byte offset within object \a obj into a page index.
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 4c30d6b..76e1ee8 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -44,7 +44,6 @@
 #include "llog_internal.h"
 
 struct obd_device *obd_devs[MAX_OBD_DEVICES];
-EXPORT_SYMBOL(obd_devs);
 struct list_head obd_types;
 DEFINE_RWLOCK(obd_dev_lock);
 
@@ -79,8 +78,6 @@ atomic_long_t obd_dirty_transit_pages;
 EXPORT_SYMBOL(obd_dirty_transit_pages);
 
 char obd_jobid_var[JOBSTATS_JOBID_VAR_MAX_LEN + 1] = JOBSTATS_DISABLE;
-EXPORT_SYMBOL(obd_jobid_var);
-
 char obd_jobid_node[LUSTRE_JOBID_SIZE + 1];
 
 /* Get jobid of current process from stored variable or calculate
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 0bc623e..cf8bb2a 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -133,7 +133,6 @@ void class_put_type(struct obd_type *type)
 	module_put(type->typ_dt_ops->owner);
 	spin_unlock(&type->obd_type_lock);
 }
-EXPORT_SYMBOL(class_put_type);
 
 #define CLASS_MAX_NAME 1024
 
@@ -391,7 +390,6 @@ int class_name2dev(const char *name)
 
 	return -1;
 }
-EXPORT_SYMBOL(class_name2dev);
 
 struct obd_device *class_name2obd(const char *name)
 {
@@ -421,7 +419,6 @@ int class_uuid2dev(struct obd_uuid *uuid)
 
 	return -1;
 }
-EXPORT_SYMBOL(class_uuid2dev);
 
 /**
  * Get obd device from ::obd_devs[]
@@ -450,7 +447,6 @@ struct obd_device *class_num2obd(int num)
 
 	return obd;
 }
-EXPORT_SYMBOL(class_num2obd);
 
 /* Search for a client OBD connected to tgt_uuid.  If grp_uuid is
  * specified, then only the client with that uuid is returned,
@@ -817,7 +813,6 @@ void class_unlink_export(struct obd_export *exp)
 	spin_unlock(&exp->exp_obd->obd_dev_lock);
 	class_export_put(exp);
 }
-EXPORT_SYMBOL(class_unlink_export);
 
 /* Import management functions */
 static void class_import_destroy(struct obd_import *imp)
@@ -973,7 +968,6 @@ void __class_export_add_lock_ref(struct obd_export *exp, struct ldlm_lock *lock)
 	       lock, exp, lock->l_exp_refs_nr);
 	spin_unlock(&exp->exp_locks_list_guard);
 }
-EXPORT_SYMBOL(__class_export_add_lock_ref);
 
 void __class_export_del_lock_ref(struct obd_export *exp, struct ldlm_lock *lock)
 {
@@ -991,7 +985,6 @@ void __class_export_del_lock_ref(struct obd_export *exp, struct ldlm_lock *lock)
 	       lock, exp, lock->l_exp_refs_nr);
 	spin_unlock(&exp->exp_locks_list_guard);
 }
-EXPORT_SYMBOL(__class_export_del_lock_ref);
 #endif
 
 /* A connection defines an export context in which preallocation can
@@ -1100,7 +1093,6 @@ EXPORT_SYMBOL(class_fail_export);
 
 #if LUSTRE_TRACKS_LOCK_EXP_REFS
 void (*class_export_dump_hook)(struct obd_export *) = NULL;
-EXPORT_SYMBOL(class_export_dump_hook);
 #endif
 
 /* Total amount of zombies to be destroyed */
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
index ae172c4..be09e04 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
@@ -158,7 +158,6 @@ int obd_ioctl_popdata(void __user *arg, void *data, int len)
 	err = copy_to_user(arg, data, len) ? -EFAULT : 0;
 	return err;
 }
-EXPORT_SYMBOL(obd_ioctl_popdata);
 
 /*  opening /dev/obd */
 static int obd_class_open(struct inode *inode, struct file *file)
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_obd.c b/drivers/staging/lustre/lustre/obdclass/llog_obd.c
index 6ace7e0..a4277d6 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_obd.c
@@ -210,7 +210,6 @@ LU_KEY_INIT_FINI(llog, struct llog_thread_info);
 /* context key: llog_thread_key */
 LU_CONTEXT_KEY_DEFINE(llog, LCT_MD_THREAD | LCT_MG_THREAD | LCT_LOCAL);
 LU_KEY_INIT_GENERIC(llog);
-EXPORT_SYMBOL(llog_thread_key);
 
 int llog_info_init(void)
 {
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_swab.c b/drivers/staging/lustre/lustre/obdclass/llog_swab.c
index 21ab90c..8c4c1b3 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_swab.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_swab.c
@@ -347,7 +347,6 @@ void lustre_swab_lustre_cfg(struct lustre_cfg *lcfg)
 
 	print_lustre_cfg(lcfg);
 }
-EXPORT_SYMBOL(lustre_swab_lustre_cfg);
 
 /* used only for compatibility with old on-disk cfg_marker data */
 struct cfg_marker32 {
@@ -407,4 +406,3 @@ void lustre_swab_cfg_marker(struct cfg_marker *marker, int swab, int size)
 		__swab64s(&marker->cm_canceltime);
 	}
 }
-EXPORT_SYMBOL(lustre_swab_cfg_marker);
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index be6b6af..852a5ac 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -621,7 +621,6 @@ void lprocfs_stats_collect(struct lprocfs_stats *stats, int idx,
 
 	lprocfs_stats_unlock(stats, LPROCFS_GET_NUM_CPU, &flags);
 }
-EXPORT_SYMBOL(lprocfs_stats_collect);
 
 /**
  * Append a space separated list of current set flags to str.
@@ -1049,7 +1048,6 @@ int lprocfs_stats_alloc_one(struct lprocfs_stats *stats, unsigned int cpuid)
 	}
 	return rc;
 }
-EXPORT_SYMBOL(lprocfs_stats_alloc_one);
 
 struct lprocfs_stats *lprocfs_alloc_stats(unsigned int num,
 					  enum lprocfs_stats_flags flags)
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 3f1fb28..054e567 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -1300,7 +1300,6 @@ void lu_stack_fini(const struct lu_env *env, struct lu_device *top)
 		}
 	}
 }
-EXPORT_SYMBOL(lu_stack_fini);
 
 enum {
 	/**
@@ -1522,14 +1521,12 @@ void lu_context_key_quiesce(struct lu_context_key *key)
 		++key_set_version;
 	}
 }
-EXPORT_SYMBOL(lu_context_key_quiesce);
 
 void lu_context_key_revive(struct lu_context_key *key)
 {
 	key->lct_tags &= ~LCT_QUIESCENT;
 	++key_set_version;
 }
-EXPORT_SYMBOL(lu_context_key_revive);
 
 static void keys_fini(struct lu_context *ctx)
 {
@@ -1688,7 +1685,6 @@ int lu_context_refill(struct lu_context *ctx)
 {
 	return likely(ctx->lc_version == key_set_version) ? 0 : keys_fill(ctx);
 }
-EXPORT_SYMBOL(lu_context_refill);
 
 /**
  * lu_ctx_tags/lu_ses_tags will be updated if there are new types of
diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_peer.c b/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
index 5974a9b..ffa740a 100644
--- a/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
+++ b/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
@@ -139,7 +139,6 @@ int class_add_uuid(const char *uuid, __u64 nid)
 	}
 	return 0;
 }
-EXPORT_SYMBOL(class_add_uuid);
 
 /* Delete the nids for one uuid if specified, otherwise delete all */
 int class_del_uuid(const char *uuid)
-- 
1.7.1
