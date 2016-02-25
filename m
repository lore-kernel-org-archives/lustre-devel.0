From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 22:00:35 -0500
Subject: [lustre-devel] [PATCH v2 52/84] staging/lustre/obdclass: Adjust
	comments to better conform to coding style
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-53-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This patch fixes "Block comments use a trailing */ on a separate line"
warnings from checkpatch

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/obdclass/cl_io.c     | 13 +++--
 drivers/staging/lustre/lustre/obdclass/cl_lock.c   | 24 +++++---
 drivers/staging/lustre/lustre/obdclass/class_obd.c |  5 +-
 drivers/staging/lustre/lustre/obdclass/genops.c    | 42 ++++++++------
 .../lustre/lustre/obdclass/linux/linux-module.c    |  3 +-
 drivers/staging/lustre/lustre/obdclass/llog.c      |  6 +-
 drivers/staging/lustre/lustre/obdclass/llog_obd.c  |  3 +-
 drivers/staging/lustre/lustre/obdclass/llog_swab.c |  3 +-
 .../lustre/lustre/obdclass/lprocfs_counters.c      |  6 +-
 drivers/staging/lustre/lustre/obdclass/lu_object.c |  3 +-
 .../lustre/lustre/obdclass/lustre_handles.c        |  3 +-
 .../staging/lustre/lustre/obdclass/lustre_peer.c   |  3 +-
 .../staging/lustre/lustre/obdclass/obd_config.c    | 42 +++++++++-----
 drivers/staging/lustre/lustre/obdclass/obd_mount.c | 67 ++++++++++++++--------
 drivers/staging/lustre/lustre/obdclass/obdo.c      |  6 +-
 15 files changed, 144 insertions(+), 85 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index 58b46a7..8cc7aa1 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -44,6 +44,7 @@
 #include "../include/obd_support.h"
 #include "../include/lustre_fid.h"
 #include <linux/list.h>
+#include <linux/sched.h>
 #include "../include/cl_object.h"
 #include "cl_internal.h"
 
@@ -308,7 +309,8 @@ static void cl_io_locks_sort(struct cl_io *io)
 							   &prev->cill_linkage);
 					done = 0;
 					continue; /* don't change prev: it's
-						   * still "previous" */
+						   * still "previous"
+						   */
 				case -1: /* already in order */
 					break;
 				}
@@ -419,7 +421,8 @@ static int cl_lockset_lock(const struct lu_env *env, struct cl_io *io,
 	list_for_each_entry_safe(link, temp, &set->cls_todo, cill_linkage) {
 		if (!cl_lockset_match(set, &link->cill_descr)) {
 			/* XXX some locking to guarantee that locks aren't
-			 * expanded in between. */
+			 * expanded in between.
+			 */
 			result = cl_lockset_lock_one(env, io, set, link);
 			if (result != 0)
 				break;
@@ -1053,7 +1056,8 @@ EXPORT_SYMBOL(cl_page_list_init);
 void cl_page_list_add(struct cl_page_list *plist, struct cl_page *page)
 {
 	/* it would be better to check that page is owned by "current" io, but
-	 * it is not passed here. */
+	 * it is not passed here.
+	 */
 	LASSERT(page->cp_owner);
 	LINVRNT(plist->pl_owner == current);
 
@@ -1510,9 +1514,6 @@ void cl_req_attr_set(const struct lu_env *env, struct cl_req *req,
 }
 EXPORT_SYMBOL(cl_req_attr_set);
 
-/* XXX complete(), init_completion(), and wait_for_completion(), until they are
- * implemented in libcfs. */
-# include <linux/sched.h>
 
 /**
  * Initialize synchronous io wait anchor, for transfer of \a nrpages pages.
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_lock.c b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
index 57cb100..6f44dde 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_lock.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
@@ -935,7 +935,8 @@ int cl_lock_state_wait(const struct lu_env *env, struct cl_lock *lock)
 	if (result == 0) {
 		/* To avoid being interrupted by the 'non-fatal' signals
 		 * (SIGCHLD, for instance), we'd block them temporarily.
-		 * LU-305 */
+		 * LU-305
+		 */
 		blocked = cfs_block_sigsinv(LUSTRE_FATAL_SIGS);
 
 		init_waitqueue_entry(&waiter, current);
@@ -946,7 +947,8 @@ int cl_lock_state_wait(const struct lu_env *env, struct cl_lock *lock)
 		LASSERT(cl_lock_nr_mutexed(env) == 0);
 
 		/* Returning ERESTARTSYS instead of EINTR so syscalls
-		 * can be restarted if signals are pending here */
+		 * can be restarted if signals are pending here
+		 */
 		result = -ERESTARTSYS;
 		if (likely(!OBD_FAIL_CHECK(OBD_FAIL_LOCK_STATE_WAIT_INTR))) {
 			schedule();
@@ -1170,7 +1172,8 @@ int cl_enqueue_try(const struct lu_env *env, struct cl_lock *lock,
 			/* kick layers. */
 			result = cl_enqueue_kick(env, lock, io, flags);
 			/* For AGL case, the cl_lock::cll_state may
-			 * become CLS_HELD already. */
+			 * become CLS_HELD already.
+			 */
 			if (result == 0 && lock->cll_state == CLS_QUEUING)
 				cl_lock_state_set(env, lock, CLS_ENQUEUED);
 			break;
@@ -1300,7 +1303,8 @@ int cl_unuse_try(const struct lu_env *env, struct cl_lock *lock)
 	}
 
 	/* Only if the lock is in CLS_HELD or CLS_ENQUEUED state, it can hold
-	 * underlying resources. */
+	 * underlying resources.
+	 */
 	if (!(lock->cll_state == CLS_HELD || lock->cll_state == CLS_ENQUEUED)) {
 		cl_lock_user_del(env, lock);
 		return 0;
@@ -1777,13 +1781,15 @@ struct cl_lock *cl_lock_at_pgoff(const struct lu_env *env,
 	lock = NULL;
 
 	need->cld_mode = CLM_READ; /* CLM_READ matches both READ & WRITE, but
-				    * not PHANTOM */
+				    * not PHANTOM
+				    */
 	need->cld_start = need->cld_end = index;
 	need->cld_enq_flags = 0;
 
 	spin_lock(&head->coh_lock_guard);
 	/* It is fine to match any group lock since there could be only one
-	 * with a uniq gid and it conflicts with all other lock modes too */
+	 * with a uniq gid and it conflicts with all other lock modes too
+	 */
 	list_for_each_entry(scan, &head->coh_locks, cll_linkage) {
 		if (scan != except &&
 		    (scan->cll_descr.cld_mode == CLM_GROUP ||
@@ -1798,7 +1804,8 @@ struct cl_lock *cl_lock_at_pgoff(const struct lu_env *env,
 		    (canceld || !(scan->cll_flags & CLF_CANCELLED)) &&
 		    (pending || !(scan->cll_flags & CLF_CANCELPEND))) {
 			/* Don't increase cs_hit here since this
-			 * is just a helper function. */
+			 * is just a helper function.
+			 */
 			cl_lock_get_trust(scan);
 			lock = scan;
 			break;
@@ -1843,7 +1850,8 @@ static int check_and_discard_cb(const struct lu_env *env, struct cl_io *io,
 			/* Cache the first-non-overlapped index so as to skip
 			 * all pages within [index, clt_fn_index). This
 			 * is safe because if tmp lock is canceled, it will
-			 * discard these pages. */
+			 * discard these pages.
+			 */
 			info->clt_fn_index = tmp->cll_descr.cld_end + 1;
 			if (tmp->cll_descr.cld_end == CL_PAGE_EOF)
 				info->clt_fn_index = CL_PAGE_EOF;
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index f805693..c1310c2 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -508,7 +508,8 @@ static int __init init_obdclass(void)
 
 	/* Default the dirty page cache cap to 1/2 of system memory.
 	 * For clients with less memory, a larger fraction is needed
-	 * for other purposes (mostly for BGL). */
+	 * for other purposes (mostly for BGL).
+	 */
 	if (totalram_pages <= 512 << (20 - PAGE_CACHE_SHIFT))
 		obd_max_dirty_pages = totalram_pages / 4;
 	else
@@ -543,8 +544,6 @@ static int __init init_obdclass(void)
 	return err;
 }
 
-/* liblustre doesn't call cleanup_obdclass, apparently.  we carry on in this
- * ifdef to the end of the file to cover module and versioning goo.*/
 static void cleanup_obdclass(void)
 {
 	int i;
diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
index 10b8d33..9042632 100644
--- a/drivers/staging/lustre/lustre/obdclass/genops.c
+++ b/drivers/staging/lustre/lustre/obdclass/genops.c
@@ -381,7 +381,8 @@ int class_name2dev(const char *name)
 
 		if (obd && strcmp(name, obd->obd_name) == 0) {
 			/* Make sure we finished attaching before we give
-			   out any references */
+			 * out any references
+			 */
 			LASSERT(obd->obd_magic == OBD_DEVICE_MAGIC);
 			if (obd->obd_attached) {
 				read_unlock(&obd_dev_lock);
@@ -456,8 +457,9 @@ struct obd_device *class_num2obd(int num)
 EXPORT_SYMBOL(class_num2obd);
 
 /* Search for a client OBD connected to tgt_uuid.  If grp_uuid is
-   specified, then only the client with that uuid is returned,
-   otherwise any client connected to the tgt is returned. */
+ * specified, then only the client with that uuid is returned,
+ * otherwise any client connected to the tgt is returned.
+ */
 struct obd_device *class_find_client_obd(struct obd_uuid *tgt_uuid,
 					  const char *typ_name,
 					  struct obd_uuid *grp_uuid)
@@ -488,9 +490,10 @@ struct obd_device *class_find_client_obd(struct obd_uuid *tgt_uuid,
 EXPORT_SYMBOL(class_find_client_obd);
 
 /* Iterate the obd_device list looking devices have grp_uuid. Start
-   searching at *next, and if a device is found, the next index to look
-   at is saved in *next. If next is NULL, then the first matching device
-   will always be returned. */
+ * searching at *next, and if a device is found, the next index to look
+ * at is saved in *next. If next is NULL, then the first matching device
+ * will always be returned.
+ */
 struct obd_device *class_devices_in_group(struct obd_uuid *grp_uuid, int *next)
 {
 	int i;
@@ -708,7 +711,8 @@ EXPORT_SYMBOL(class_export_put);
 
 /* Creates a new export, adds it to the hash table, and returns a
  * pointer to it. The refcount is 2: one for the hash reference, and
- * one for the pointer returned by this function. */
+ * one for the pointer returned by this function.
+ */
 struct obd_export *class_new_export(struct obd_device *obd,
 				    struct obd_uuid *cluuid)
 {
@@ -891,8 +895,9 @@ static void init_imp_at(struct imp_at *at)
 	at_init(&at->iat_net_latency, 0, 0);
 	for (i = 0; i < IMP_AT_MAX_PORTALS; i++) {
 		/* max service estimates are tracked on the server side, so
-		   don't use the AT history here, just use the last reported
-		   val. (But keep hist for proc histogram, worst_ever) */
+		 * don't use the AT history here, just use the last reported
+		 * val. (But keep hist for proc histogram, worst_ever)
+		 */
 		at_init(&at->iat_service_estimate[i], INITIAL_CONNECT_TIMEOUT,
 			AT_FLG_NOHIST);
 	}
@@ -931,7 +936,8 @@ struct obd_import *class_new_import(struct obd_device *obd)
 	init_imp_at(&imp->imp_at);
 
 	/* the default magic is V2, will be used in connect RPC, and
-	 * then adjusted according to the flags in request/reply. */
+	 * then adjusted according to the flags in request/reply.
+	 */
 	imp->imp_msg_magic = LUSTRE_MSG_MAGIC_V2;
 
 	return imp;
@@ -994,9 +1000,10 @@ EXPORT_SYMBOL(__class_export_del_lock_ref);
 #endif
 
 /* A connection defines an export context in which preallocation can
-   be managed. This releases the export pointer reference, and returns
-   the export handle, so the export refcount is 1 when this function
-   returns. */
+ * be managed. This releases the export pointer reference, and returns
+ * the export handle, so the export refcount is 1 when this function
+ * returns.
+ */
 int class_connect(struct lustre_handle *conn, struct obd_device *obd,
 		  struct obd_uuid *cluuid)
 {
@@ -1024,7 +1031,8 @@ EXPORT_SYMBOL(class_connect);
  * and if disconnect really need
  * 2 - removing from hash
  * 3 - in client_unlink_export
- * The export pointer passed to this function can destroyed */
+ * The export pointer passed to this function can destroyed
+ */
 int class_disconnect(struct obd_export *export)
 {
 	int already_disconnected;
@@ -1041,7 +1049,8 @@ int class_disconnect(struct obd_export *export)
 
 	/* class_cleanup(), abort_recovery(), and class_fail_export()
 	 * all end up in here, and if any of them race we shouldn't
-	 * call extra class_export_puts(). */
+	 * call extra class_export_puts().
+	 */
 	if (already_disconnected)
 		goto no_disconn;
 
@@ -1081,7 +1090,8 @@ void class_fail_export(struct obd_export *exp)
 
 	/* Most callers into obd_disconnect are removing their own reference
 	 * (request, for example) in addition to the one from the hash table.
-	 * We don't have such a reference here, so make one. */
+	 * We don't have such a reference here, so make one.
+	 */
 	class_export_get(exp);
 	rc = obd_disconnect(exp);
 	if (rc)
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
index f3c4a17..8eddf20 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
@@ -102,7 +102,8 @@ int obd_ioctl_getdata(char **buf, int *len, void __user *arg)
 	/* When there are lots of processes calling vmalloc on multi-core
 	 * system, the high lock contention will hurt performance badly,
 	 * obdfilter-survey is an example, which relies on ioctl. So we'd
-	 * better avoid vmalloc on ioctl path. LU-66 */
+	 * better avoid vmalloc on ioctl path. LU-66
+	 */
 	*buf = libcfs_kvzalloc(hdr.ioc_len, GFP_NOFS);
 	if (!*buf) {
 		CERROR("Cannot allocate control buffer of len %d\n",
diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
index 96de2e1..f7ee605 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog.c
@@ -260,7 +260,8 @@ repeat:
 
 		/* NB: when rec->lrh_len is accessed it is already swabbed
 		 * since it is used at the "end" of the loop and the rec
-		 * swabbing is done at the beginning of the loop. */
+		 * swabbing is done at the beginning of the loop.
+		 */
 		for (rec = (struct llog_rec_hdr *)buf;
 		     (char *)rec < buf + LLOG_CHUNK_SIZE;
 		     rec = (struct llog_rec_hdr *)((char *)rec + rec->lrh_len)) {
@@ -377,7 +378,8 @@ int llog_process_or_fork(const struct lu_env *env,
 		struct task_struct *task;
 
 		/* The new thread can't use parent env,
-		 * init the new one in llog_process_thread_daemonize. */
+		 * init the new one in llog_process_thread_daemonize.
+		 */
 		lpi->lpi_env = NULL;
 		init_completion(&lpi->lpi_completion);
 		task = kthread_run(llog_process_thread_daemonize, lpi,
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_obd.c b/drivers/staging/lustre/lustre/obdclass/llog_obd.c
index a06a5ea..826623f 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_obd.c
@@ -88,7 +88,8 @@ int __llog_ctxt_put(const struct lu_env *env, struct llog_ctxt *ctxt)
 	spin_unlock(&obd->obd_dev_lock);
 
 	/* obd->obd_starting is needed for the case of cleanup
-	 * in error case while obd is starting up. */
+	 * in error case while obd is starting up.
+	 */
 	LASSERTF(obd->obd_starting == 1 ||
 		 obd->obd_stopping == 1 || obd->obd_set_up == 0,
 		 "wrong obd state: %d/%d/%d\n", !!obd->obd_starting,
diff --git a/drivers/staging/lustre/lustre/obdclass/llog_swab.c b/drivers/staging/lustre/lustre/obdclass/llog_swab.c
index 7b8379a..967ba2e 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog_swab.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog_swab.c
@@ -386,7 +386,8 @@ void lustre_swab_cfg_marker(struct cfg_marker *marker, int swab, int size)
 		 *
 		 * Overwrite fields from the end first, so they are not
 		 * clobbered, and use memmove() instead of memcpy() because
-		 * the source and target buffers overlap.  bug 16771 */
+		 * the source and target buffers overlap.  bug 16771
+		 */
 		createtime = cm32->cm_createtime;
 		canceltime = cm32->cm_canceltime;
 		memmove(marker->cm_comment, cm32->cm_comment, MTI_NAMELEN32);
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_counters.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_counters.c
index 4b04124..13aca5b 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_counters.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_counters.c
@@ -55,7 +55,8 @@ void lprocfs_counter_add(struct lprocfs_stats *stats, int idx, long amount)
 		 "idx %d, ls_num %hu\n", idx, stats->ls_num);
 
 	/* With per-client stats, statistics are allocated only for
-	 * single CPU area, so the smp_id should be 0 always. */
+	 * single CPU area, so the smp_id should be 0 always.
+	 */
 	smp_id = lprocfs_stats_lock(stats, LPROCFS_GET_SMP_ID, &flags);
 	if (smp_id < 0)
 		return;
@@ -103,7 +104,8 @@ void lprocfs_counter_sub(struct lprocfs_stats *stats, int idx, long amount)
 		 "idx %d, ls_num %hu\n", idx, stats->ls_num);
 
 	/* With per-client stats, statistics are allocated only for
-	 * single CPU area, so the smp_id should be 0 always. */
+	 * single CPU area, so the smp_id should be 0 always.
+	 */
 	smp_id = lprocfs_stats_lock(stats, LPROCFS_GET_SMP_ID, &flags);
 	if (smp_id < 0)
 		return;
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 15ffbbf..0fa4bac 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -532,7 +532,8 @@ static struct lu_object *htable_lookup(struct lu_site *s,
 	*version = ver;
 	bkt = cfs_hash_bd_extra_get(s->ls_obj_hash, bd);
 	/* cfs_hash_bd_peek_locked is a somehow "internal" function
-	 * of cfs_hash, it doesn't add refcount on object. */
+	 * of cfs_hash, it doesn't add refcount on object.
+	 */
 	hnode = cfs_hash_bd_peek_locked(s->ls_obj_hash, bd, (void *)f);
 	if (!hnode) {
 		lprocfs_counter_incr(s->ls_stats, LU_SS_CACHE_MISS);
diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
index 2bbbc9f..403ceea 100644
--- a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
+++ b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
@@ -143,7 +143,8 @@ void *class_handle2object(__u64 cookie)
 	LASSERT(handle_hash);
 
 	/* Be careful when you want to change this code. See the
-	 * rcu_read_lock() definition on top this file. - jxiong */
+	 * rcu_read_lock() definition on top this file. - jxiong
+	 */
 	bucket = handle_hash + (cookie & HANDLE_HASH_MASK);
 
 	rcu_read_lock();
diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_peer.c b/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
index e90041b..b10ea31 100644
--- a/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
+++ b/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
@@ -93,7 +93,8 @@ int lustre_uuid_to_peer(const char *uuid, lnet_nid_t *peer_nid, int index)
 EXPORT_SYMBOL(lustre_uuid_to_peer);
 
 /* Add a nid to a niduuid.  Multiple nids can be added to a single uuid;
-   LNET will choose the best one. */
+ * LNET will choose the best one.
+ */
 int class_add_uuid(const char *uuid, __u64 nid)
 {
 	struct uuid_nid_data *data, *entry;
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_config.c b/drivers/staging/lustre/lustre/obdclass/obd_config.c
index 6417946..885f266 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_config.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_config.c
@@ -71,7 +71,8 @@ int class_find_param(char *buf, char *key, char **valp)
 EXPORT_SYMBOL(class_find_param);
 
 /* returns 0 if this is the first key in the buffer, else 1.
-   valp points to first char after key. */
+ * valp points to first char after key.
+ */
 static int class_match_param(char *buf, const char *key, char **valp)
 {
 	if (!buf)
@@ -114,9 +115,10 @@ enum {
 };
 
 /* 0 is good nid,
-   1 not found
-   < 0 error
-   endh is set to next separator */
+ * 1 not found
+ * < 0 error
+ * endh is set to next separator
+ */
 static int class_parse_value(char *buf, int opc, void *value, char **endh,
 			     int quiet)
 {
@@ -230,7 +232,8 @@ static int class_attach(struct lustre_cfg *lcfg)
 	mutex_init(&obd->obd_dev_mutex);
 	spin_lock_init(&obd->obd_osfs_lock);
 	/* obd->obd_osfs_age must be set to a value in the distant
-	 * past to guarantee a fresh statfs is fetched on mount. */
+	 * past to guarantee a fresh statfs is fetched on mount.
+	 */
 	obd->obd_osfs_age = cfs_time_shift_64(-1000);
 
 	/* XXX belongs in setup not attach  */
@@ -315,7 +318,8 @@ static int class_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 		return -EEXIST;
 	}
 	/* just leave this on forever.  I can't use obd_set_up here because
-	   other fns check that status, and we're not actually set up yet. */
+	 * other fns check that status, and we're not actually set up yet.
+	 */
 	obd->obd_starting = 1;
 	obd->obd_uuid_hash = NULL;
 	spin_unlock(&obd->obd_dev_lock);
@@ -503,7 +507,8 @@ void class_decref(struct obd_device *obd, const char *scope, const void *source)
 
 	if ((refs == 1) && obd->obd_stopping) {
 		/* All exports have been destroyed; there should
-		   be no more in-progress ops by this point.*/
+		 * be no more in-progress ops by this point.
+		 */
 
 		spin_lock(&obd->obd_self_export->exp_lock);
 		obd->obd_self_export->exp_flags |= exp_flags_from_obd(obd);
@@ -723,7 +728,8 @@ static int class_set_global(char *ptr, int val, struct lustre_cfg *lcfg)
 }
 
 /* We can't call ll_process_config or lquota_process_config directly because
- * it lives in a module that must be loaded after this one. */
+ * it lives in a module that must be loaded after this one.
+ */
 static int (*client_process_config)(struct lustre_cfg *lcfg);
 static int (*quota_process_config)(struct lustre_cfg *lcfg);
 
@@ -812,7 +818,8 @@ int class_process_config(struct lustre_cfg *lcfg)
 		       lustre_cfg_string(lcfg, 2),
 		       lustre_cfg_string(lcfg, 3));
 		/* set these mount options somewhere, so ll_fill_super
-		 * can find them. */
+		 * can find them.
+		 */
 		err = class_add_profile(LUSTRE_CFG_BUFLEN(lcfg, 1),
 					lustre_cfg_string(lcfg, 1),
 					LUSTRE_CFG_BUFLEN(lcfg, 2),
@@ -988,8 +995,9 @@ int class_process_proc_param(char *prefix, struct lprocfs_vars *lvars,
 	fakefile.private_data = &fake_seqfile;
 	fake_seqfile.private = data;
 	/* e.g. tunefs.lustre --param mdt.group_upcall=foo /r/tmp/lustre-mdt
-	   or   lctl conf_param lustre-MDT0000.mdt.group_upcall=bar
-	   or   lctl conf_param lustre-OST0000.osc.max_dirty_mb=36 */
+	 * or   lctl conf_param lustre-MDT0000.mdt.group_upcall=bar
+	 * or   lctl conf_param lustre-OST0000.osc.max_dirty_mb=36
+	 */
 	for (i = 1; i < lcfg->lcfg_bufcount; i++) {
 		key = lustre_cfg_buf(lcfg, i);
 		/* Strip off prefix */
@@ -1027,7 +1035,8 @@ int class_process_proc_param(char *prefix, struct lprocfs_vars *lvars,
 		}
 		if (!matched) {
 			/* If the prefix doesn't match, return error so we
-			   can pass it down the stack */
+			 * can pass it down the stack
+			 */
 			if (strnchr(key, keylen, '.'))
 			    return -ENOSYS;
 			CERROR("%s: unknown param %s\n",
@@ -1116,7 +1125,8 @@ int class_config_llog_handler(const struct lu_env *env,
 			}
 		}
 		/* A config command without a start marker before it is
-		   illegal (post 146) */
+		 * illegal (post 146)
+		 */
 		if (!(clli->cfg_flags & CFG_F_COMPAT146) &&
 		    !(clli->cfg_flags & CFG_F_MARKER) &&
 		    (lcfg->lcfg_command != LCFG_MARKER)) {
@@ -1182,7 +1192,8 @@ int class_config_llog_handler(const struct lu_env *env,
 		}
 
 		/* we override the llog's uuid for clients, to insure they
-		are unique */
+		 * are unique
+		 */
 		if (clli && clli->cfg_instance &&
 		    lcfg->lcfg_command == LCFG_ATTACH) {
 			lustre_cfg_bufs_set_string(&bufs, 2,
@@ -1211,7 +1222,8 @@ int class_config_llog_handler(const struct lu_env *env,
 		lcfg_new->lcfg_flags = lcfg->lcfg_flags;
 
 		/* XXX Hack to try to remain binary compatible with
-		 * pre-newconfig logs */
+		 * pre-newconfig logs
+		 */
 		if (lcfg->lcfg_nal != 0 &&      /* pre-newconfig log? */
 		    (lcfg->lcfg_nid >> 32) == 0) {
 			__u32 addr = (__u32)(lcfg->lcfg_nid & 0xffffffff);
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index 5fa6ce6..d138e05 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -283,9 +283,10 @@ int lustre_start_mgc(struct super_block *sb)
 		recov_bk = 0;
 
 		/* Try all connections, but only once (again).
-		   We don't want to block another target from starting
-		   (using its local copy of the log), but we do want to connect
-		   if at all possible. */
+		 * We don't want to block another target from starting
+		 * (using its local copy of the log), but we do want to connect
+		 * if at all possible.
+		 */
 		recov_bk++;
 		CDEBUG(D_MOUNT, "%s: Set MGC reconnect %d\n", mgcname,
 		       recov_bk);
@@ -375,7 +376,8 @@ int lustre_start_mgc(struct super_block *sb)
 		goto out_free;
 
 	/* Keep a refcount of servers/clients who started with "mount",
-	   so we know when we can get rid of the mgc. */
+	 * so we know when we can get rid of the mgc.
+	 */
 	atomic_set(&obd->u.cli.cl_mgc_refcount, 1);
 
 	/* We connect to the MGS at setup, and don't disconnect until cleanup */
@@ -403,7 +405,8 @@ int lustre_start_mgc(struct super_block *sb)
 
 out:
 	/* Keep the mgc info in the sb. Note that many lsi's can point
-	   to the same mgc.*/
+	 * to the same mgc.
+	 */
 	lsi->lsi_mgc = obd;
 out_free:
 	mutex_unlock(&mgc_start_lock);
@@ -432,7 +435,8 @@ static int lustre_stop_mgc(struct super_block *sb)
 	LASSERT(atomic_read(&obd->u.cli.cl_mgc_refcount) > 0);
 	if (!atomic_dec_and_test(&obd->u.cli.cl_mgc_refcount)) {
 		/* This is not fatal, every client that stops
-		   will call in here. */
+		 * will call in here.
+		 */
 		CDEBUG(D_MOUNT, "mgc still has %d references.\n",
 		       atomic_read(&obd->u.cli.cl_mgc_refcount));
 		rc = -EBUSY;
@@ -440,19 +444,20 @@ static int lustre_stop_mgc(struct super_block *sb)
 	}
 
 	/* The MGC has no recoverable data in any case.
-	 * force shutdown set in umount_begin */
+	 * force shutdown set in umount_begin
+	 */
 	obd->obd_no_recov = 1;
 
 	if (obd->u.cli.cl_mgc_mgsexp) {
 		/* An error is not fatal, if we are unable to send the
-		   disconnect mgs ping evictor cleans up the export */
+		 * disconnect mgs ping evictor cleans up the export
+		 */
 		rc = obd_disconnect(obd->u.cli.cl_mgc_mgsexp);
 		if (rc)
 			CDEBUG(D_MOUNT, "disconnect failed %d\n", rc);
 	}
 
-	/* Save the obdname for cleaning the nid uuids, which are
-	   obdname_XX */
+	/* Save the obdname for cleaning the nid uuids, which are obdname_XX */
 	len = strlen(obd->obd_name) + 6;
 	niduuid = kzalloc(len, GFP_NOFS);
 	if (niduuid) {
@@ -545,7 +550,8 @@ static int lustre_free_lsi(struct super_block *sb)
 }
 
 /* The lsi has one reference for every server that is using the disk -
-   e.g. MDT, MGS, and potentially MGC */
+ * e.g. MDT, MGS, and potentially MGC
+ */
 static int lustre_put_lsi(struct super_block *sb)
 {
 	struct lustre_sb_info *lsi = s2lsi(sb);
@@ -597,9 +603,10 @@ static int server_name2fsname(const char *svname, char *fsname,
 }
 
 /* Get the index from the obd name.
-   rc = server type, or
-   rc < 0  on error
-   if endptr isn't NULL it is set to end of name */
+ *  rc = server type, or
+ * rc < 0  on error
+ * if endptr isn't NULL it is set to end of name
+ */
 static int server_name2index(const char *svname, __u32 *idx,
 			     const char **endptr)
 {
@@ -658,7 +665,8 @@ int lustre_common_put_super(struct super_block *sb)
 			return rc;
 		}
 		/* BUSY just means that there's some other obd that
-		   needs the mgc.  Let him clean it up. */
+		 * needs the mgc.  Let him clean it up.
+		 */
 		CDEBUG(D_MOUNT, "MGC still in use\n");
 	}
 	/* Drop a ref to the mounted disk */
@@ -728,8 +736,9 @@ static int lmd_make_exclusion(struct lustre_mount_data *lmd, const char *ptr)
 	int rc = 0, devmax;
 
 	/* The shortest an ost name can be is 8 chars: -OST0000.
-	   We don't actually know the fsname at this time, so in fact
-	   a user could specify any fsname. */
+	 * We don't actually know the fsname at this time, so in fact
+	 * a user could specify any fsname.
+	 */
 	devmax = strlen(ptr) / 8 + 1;
 
 	/* temp storage until we figure out how many we have */
@@ -753,7 +762,8 @@ static int lmd_make_exclusion(struct lustre_mount_data *lmd, const char *ptr)
 			       (uint)(s2-s1), s1, rc);
 		s1 = s2;
 		/* now we are pointing@':' (next exclude)
-		   or ',' (end of excludes) */
+		 * or ',' (end of excludes)
+		 */
 		if (lmd->lmd_exclude_count >= devmax)
 			break;
 	}
@@ -906,10 +916,12 @@ static int lmd_parse(char *options, struct lustre_mount_data *lmd)
 			s1++;
 
 		/* Client options are parsed in ll_options: eg. flock,
-		   user_xattr, acl */
+		 * user_xattr, acl
+		 */
 
 		/* Parse non-ldiskfs options here. Rather than modifying
-		   ldiskfs, we just zero these out here */
+		 * ldiskfs, we just zero these out here
+		 */
 		if (strncmp(s1, "abort_recov", 11) == 0) {
 			lmd->lmd_flags |= LMD_FLG_ABORT_RECOV;
 			clear++;
@@ -937,7 +949,8 @@ static int lmd_parse(char *options, struct lustre_mount_data *lmd)
 				   sizeof(PARAM_MGSNODE) - 1) == 0) {
 			s2 = s1 + sizeof(PARAM_MGSNODE) - 1;
 			/* Assume the next mount opt is the first
-			   invalid nid we get to. */
+			 * invalid nid we get to.
+			 */
 			rc = lmd_parse_mgs(lmd, &s2);
 			if (rc)
 				goto invalid;
@@ -997,11 +1010,13 @@ static int lmd_parse(char *options, struct lustre_mount_data *lmd)
 			clear++;
 		}
 		/* Linux 2.4 doesn't pass the device, so we stuck it at the
-		   end of the options. */
+		 * end of the options.
+		 */
 		else if (strncmp(s1, "device=", 7) == 0) {
 			devname = s1 + 7;
 			/* terminate options right before device.  device
-			   must be the last one. */
+			 * must be the last one.
+			 */
 			*s1 = '\0';
 			break;
 		}
@@ -1133,7 +1148,8 @@ static int lustre_fill_super(struct super_block *sb, void *data, int silent)
 	}
 
 	/* If error happens in fill_super() call, @lsi will be killed there.
-	 * This is why we do not put it here. */
+	 * This is why we do not put it here.
+	 */
 	goto out;
 out:
 	if (rc) {
@@ -1148,7 +1164,8 @@ out:
 }
 
 /* We can't call ll_fill_super by name because it lives in a module that
-   must be loaded after this one. */
+ * must be loaded after this one.
+ */
 void lustre_register_client_fill_super(int (*cfs)(struct super_block *sb,
 						  struct vfsmount *mnt))
 {
diff --git a/drivers/staging/lustre/lustre/obdclass/obdo.c b/drivers/staging/lustre/lustre/obdclass/obdo.c
index 75e1dea..e6436cb 100644
--- a/drivers/staging/lustre/lustre/obdclass/obdo.c
+++ b/drivers/staging/lustre/lustre/obdclass/obdo.c
@@ -55,7 +55,8 @@ void obdo_set_parent_fid(struct obdo *dst, const struct lu_fid *parent)
 EXPORT_SYMBOL(obdo_set_parent_fid);
 
 /* WARNING: the file systems must take care not to tinker with
-   attributes they don't manage (such as blocks). */
+ * attributes they don't manage (such as blocks).
+ */
 void obdo_from_inode(struct obdo *dst, struct inode *src, u32 valid)
 {
 	u32 newvalid = 0;
@@ -122,7 +123,8 @@ void obdo_to_ioobj(struct obdo *oa, struct obd_ioobj *ioobj)
 		ostid_set_seq_mdt0(&ioobj->ioo_oid);
 
 	/* Since 2.4 this does not contain o_mode in the low 16 bits.
-	 * Instead, it holds (bd_md_max_brw - 1) for multi-bulk BRW RPCs */
+	 * Instead, it holds (bd_md_max_brw - 1) for multi-bulk BRW RPCs
+	 */
 	ioobj->ioo_max_brw = 0;
 }
 EXPORT_SYMBOL(obdo_to_ioobj);
-- 
2.1.0
