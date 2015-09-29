From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 28 Sep 2015 23:43:55 -0400
Subject: [lustre-devel] [PATCH 12/29] staging/lustre/obdclass: Remove unused
	functions from genops.c
In-Reply-To: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
References: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443498252-1974801-13-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

These functions are mostly used on the server.

class_uuid2obd, get_devices_count, class_obd_list, class_conn2obd,
class_conn2cliimp, class_connected_export, obd_exports_barrier,
kuc_* (kernel-userspace communications).

Reported-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../staging/lustre/lustre/include/lustre_import.h  |   1 -
 drivers/staging/lustre/lustre/include/obd_class.h  |  11 --
 drivers/staging/lustre/lustre/obdclass/genops.c    | 189 ---------------------
 3 files changed, 201 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_import.h b/drivers/staging/lustre/lustre/include/lustre_import.h
index 079db52..660d290 100644
--- a/drivers/staging/lustre/lustre/include/lustre_import.h
+++ b/drivers/staging/lustre/lustre/include/lustre_import.h
@@ -374,7 +374,6 @@ extern unsigned int at_max;
 /* genops.c */
 struct obd_export;
 struct obd_import *class_exp2cliimp(struct obd_export *);
-struct obd_import *class_conn2cliimp(struct lustre_handle *);
 
 /** @} import */
 
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 8bfdc97..b323403 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -64,7 +64,6 @@ extern struct obd_device *obd_devs[MAX_OBD_DEVICES];
 extern rwlock_t obd_dev_lock;
 
 /* OBD Operations Declarations */
-struct obd_device *class_conn2obd(struct lustre_handle *);
 struct obd_device *class_exp2obd(struct obd_export *);
 int class_handle_ioctl(unsigned int cmd, unsigned long arg);
 int lustre_get_jobid(char *jobid);
@@ -84,15 +83,12 @@ void class_release_dev(struct obd_device *obd);
 int class_name2dev(const char *name);
 struct obd_device *class_name2obd(const char *name);
 int class_uuid2dev(struct obd_uuid *uuid);
-struct obd_device *class_uuid2obd(struct obd_uuid *uuid);
-void class_obd_list(void);
 struct obd_device *class_find_client_obd(struct obd_uuid *tgt_uuid,
 					  const char *typ_name,
 					  struct obd_uuid *grp_uuid);
 struct obd_device *class_devices_in_group(struct obd_uuid *grp_uuid,
 					   int *next);
 struct obd_device *class_num2obd(int num);
-int get_devices_count(void);
 
 int class_notify_sptlrpc_conf(const char *fsname, int namelen);
 
@@ -104,12 +100,6 @@ int obd_zombie_impexp_init(void);
 void obd_zombie_impexp_stop(void);
 void obd_zombie_impexp_cull(void);
 void obd_zombie_barrier(void);
-void obd_exports_barrier(struct obd_device *obd);
-int kuc_len(int payload_len);
-struct kuc_hdr *kuc_ptr(void *p);
-int kuc_ispayload(void *p);
-void *kuc_alloc(int payload_len, int transport, int type);
-void kuc_free(void *p, int payload_len);
 
 struct llog_handle;
 struct llog_rec_hdr;
@@ -283,7 +273,6 @@ int class_connect(struct lustre_handle *conn, struct obd_device *obd,
 		  struct obd_uuid *cluuid);
 int class_disconnect(struct obd_export *exp);
 void class_fail_export(struct obd_export *exp);
-int class_connected_export(struct obd_export *exp);
 int class_manual_cleanup(struct obd_device *obd);
 static inline enum obd_option exp_flags_from_obd(struct obd_device *obd)
 {
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 059611b..4467baa 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -439,16 +439,6 @@ int class_uuid2dev(struct obd_uuid *uuid)
 }
 EXPORT_SYMBOL(class_uuid2dev);
 
-struct obd_device *class_uuid2obd(struct obd_uuid *uuid)
-{
-	int dev = class_uuid2dev(uuid);
-
-	if (dev < 0)
-		return NULL;
-	return class_num2obd(dev);
-}
-EXPORT_SYMBOL(class_uuid2obd);
-
 /**
  * Get obd device from ::obd_devs[]
  *
@@ -478,55 +468,6 @@ struct obd_device *class_num2obd(int num)
 }
 EXPORT_SYMBOL(class_num2obd);
 
-/**
- * Get obd devices count. Device in any
- *    state are counted
- * \retval obd device count
- */
-int get_devices_count(void)
-{
-	int index, max_index = class_devno_max(), dev_count = 0;
-
-	read_lock(&obd_dev_lock);
-	for (index = 0; index <= max_index; index++) {
-		struct obd_device *obd = class_num2obd(index);
-
-		if (obd != NULL)
-			dev_count++;
-	}
-	read_unlock(&obd_dev_lock);
-
-	return dev_count;
-}
-EXPORT_SYMBOL(get_devices_count);
-
-void class_obd_list(void)
-{
-	char *status;
-	int i;
-
-	read_lock(&obd_dev_lock);
-	for (i = 0; i < class_devno_max(); i++) {
-		struct obd_device *obd = class_num2obd(i);
-
-		if (!obd)
-			continue;
-		if (obd->obd_stopping)
-			status = "ST";
-		else if (obd->obd_set_up)
-			status = "UP";
-		else if (obd->obd_attached)
-			status = "AT";
-		else
-			status = "--";
-		LCONSOLE(D_CONFIG, "%3d %s %s %s %s %d\n",
-			 i, status, obd->obd_type->typ_name,
-			 obd->obd_name, obd->obd_uuid.uuid,
-			 atomic_read(&obd->obd_refcount));
-	}
-	read_unlock(&obd_dev_lock);
-}
-
 /* Search for a client OBD connected to tgt_uuid.  If grp_uuid is
    specified, then only the client with that uuid is returned,
    otherwise any client connected to the tgt is returned. */
@@ -705,21 +646,6 @@ struct obd_device *class_exp2obd(struct obd_export *exp)
 }
 EXPORT_SYMBOL(class_exp2obd);
 
-struct obd_device *class_conn2obd(struct lustre_handle *conn)
-{
-	struct obd_export *export;
-
-	export = class_conn2export(conn);
-	if (export) {
-		struct obd_device *obd = export->exp_obd;
-
-		class_export_put(export);
-		return obd;
-	}
-	return NULL;
-}
-EXPORT_SYMBOL(class_conn2obd);
-
 struct obd_import *class_exp2cliimp(struct obd_export *exp)
 {
 	struct obd_device *obd = exp->exp_obd;
@@ -730,16 +656,6 @@ struct obd_import *class_exp2cliimp(struct obd_export *exp)
 }
 EXPORT_SYMBOL(class_exp2cliimp);
 
-struct obd_import *class_conn2cliimp(struct lustre_handle *conn)
-{
-	struct obd_device *obd = class_conn2obd(conn);
-
-	if (!obd)
-		return NULL;
-	return obd->u.cli.cl_import;
-}
-EXPORT_SYMBOL(class_conn2cliimp);
-
 /* Export management functions */
 static void class_export_destroy(struct obd_export *exp)
 {
@@ -1208,21 +1124,6 @@ no_disconn:
 }
 EXPORT_SYMBOL(class_disconnect);
 
-/* Return non-zero for a fully connected export */
-int class_connected_export(struct obd_export *exp)
-{
-	if (exp) {
-		int connected;
-
-		spin_lock(&exp->exp_lock);
-		connected = exp->exp_conn_cnt > 0;
-		spin_unlock(&exp->exp_lock);
-		return connected;
-	}
-	return 0;
-}
-EXPORT_SYMBOL(class_connected_export);
-
 void class_fail_export(struct obd_export *exp)
 {
 	int rc, already_failed;
@@ -1325,29 +1226,6 @@ void dump_exports(struct obd_device *obd, int locks)
 }
 EXPORT_SYMBOL(dump_exports);
 
-void obd_exports_barrier(struct obd_device *obd)
-{
-	int waited = 2;
-
-	LASSERT(list_empty(&obd->obd_exports));
-	spin_lock(&obd->obd_dev_lock);
-	while (!list_empty(&obd->obd_unlinked_exports)) {
-		spin_unlock(&obd->obd_dev_lock);
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		schedule_timeout(cfs_time_seconds(waited));
-		if (waited > 5 && IS_PO2(waited)) {
-			LCONSOLE_WARN("%s is waiting for obd_unlinked_exports more than %d seconds. The obd refcount = %d. Is it stuck?\n",
-				      obd->obd_name, waited,
-				      atomic_read(&obd->obd_refcount));
-			dump_exports(obd, 1);
-		}
-		waited *= 2;
-		spin_lock(&obd->obd_dev_lock);
-	}
-	spin_unlock(&obd->obd_dev_lock);
-}
-EXPORT_SYMBOL(obd_exports_barrier);
-
 /* Total amount of zombies to be destroyed */
 static int zombies_count;
 
@@ -1558,70 +1436,3 @@ void obd_zombie_impexp_stop(void)
 	obd_zombie_impexp_notify();
 	wait_for_completion(&obd_zombie_stop);
 }
-
-/***** Kernel-userspace comm helpers *******/
-
-/* Get length of entire message, including header */
-int kuc_len(int payload_len)
-{
-	return sizeof(struct kuc_hdr) + payload_len;
-}
-EXPORT_SYMBOL(kuc_len);
-
-/* Get a pointer to kuc header, given a ptr to the payload
- * @param p Pointer to payload area
- * @returns Pointer to kuc header
- */
-struct kuc_hdr *kuc_ptr(void *p)
-{
-	struct kuc_hdr *lh = ((struct kuc_hdr *)p) - 1;
-
-	LASSERT(lh->kuc_magic == KUC_MAGIC);
-	return lh;
-}
-EXPORT_SYMBOL(kuc_ptr);
-
-/* Test if payload is part of kuc message
- * @param p Pointer to payload area
- * @returns boolean
- */
-int kuc_ispayload(void *p)
-{
-	struct kuc_hdr *kh = ((struct kuc_hdr *)p) - 1;
-
-	if (kh->kuc_magic == KUC_MAGIC)
-		return 1;
-	else
-		return 0;
-}
-EXPORT_SYMBOL(kuc_ispayload);
-
-/* Alloc space for a message, and fill in header
- * @return Pointer to payload area
- */
-void *kuc_alloc(int payload_len, int transport, int type)
-{
-	struct kuc_hdr *lh;
-	int len = kuc_len(payload_len);
-
-	lh = kzalloc(len, GFP_NOFS);
-	if (!lh)
-		return ERR_PTR(-ENOMEM);
-
-	lh->kuc_magic = KUC_MAGIC;
-	lh->kuc_transport = transport;
-	lh->kuc_msgtype = type;
-	lh->kuc_msglen = len;
-
-	return (void *)(lh + 1);
-}
-EXPORT_SYMBOL(kuc_alloc);
-
-/* Takes pointer to payload area */
-inline void kuc_free(void *p, int payload_len)
-{
-	struct kuc_hdr *lh = kuc_ptr(p);
-
-	kfree(lh);
-}
-EXPORT_SYMBOL(kuc_free);
-- 
2.1.0
