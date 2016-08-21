From: Oleg Drokin <green@linuxhacker.ru>
Date: Sun, 21 Aug 2016 18:04:35 -0400
Subject: [lustre-devel] [PATCH 2/3] staging/lustre: Make alignment match
	open parenthesis
In-Reply-To: <1471817076-563589-1-git-send-email-green@linuxhacker.ru>
References: <1471817076-563589-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1471817076-563589-3-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>, Emoly Liu <emoly.liu@intel.com>

This patch fixes most of checkpatch occurences of
"CHECK: Alignment should match open parenthesis"
in Lustre code.

Signed-off-by: Emoly Liu <emoly.liu@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |   6 +-
 .../lustre/include/linux/libcfs/libcfs_debug.h     |  10 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   2 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |   5 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |   2 +-
 .../lustre/lnet/libcfs/linux/linux-crypto.c        |   4 +-
 drivers/staging/lustre/lustre/include/cl_object.h  |   2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c   |   4 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |   4 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_internal.h |  17 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |   8 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |  26 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |  21 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     |   4 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |  10 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |   5 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   4 +-
 drivers/staging/lustre/lustre/llite/rw.c           |   4 +-
 drivers/staging/lustre/lustre/llite/statahead.c    |   3 +-
 drivers/staging/lustre/lustre/llite/vvp_page.c     |   4 +-
 drivers/staging/lustre/lustre/lov/lov_obd.c        |   4 +-
 drivers/staging/lustre/lustre/mdc/mdc_locks.c      |   3 +-
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |   2 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c      |   4 +-
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |   3 +-
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |   5 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |   5 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_plain.c   |  18 +-
 drivers/staging/lustre/lustre/ptlrpc/service.c     |  22 +-
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    | 288 ++++++++++-----------
 30 files changed, 255 insertions(+), 244 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 3f6447c..3b92d38 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -138,8 +138,8 @@ struct lnet_debugfs_symlink_def {
 void lustre_insert_debugfs(struct ctl_table *table,
 			   const struct lnet_debugfs_symlink_def *symlinks);
 int lprocfs_call_handler(void *data, int write, loff_t *ppos,
-			  void __user *buffer, size_t *lenp,
-			  int (*handler)(void *data, int write,
-			  loff_t pos, void __user *buffer, int len));
+			 void __user *buffer, size_t *lenp,
+			 int (*handler)(void *data, int write, loff_t pos,
+					void __user *buffer, int len));
 
 #endif /* _LIBCFS_H */
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
index 25adab1..b7bd6e8 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_debug.h
@@ -247,19 +247,19 @@ do {									\
 #define LCONSOLE_EMERG(format, ...) CDEBUG(D_CONSOLE | D_EMERG, format, ## __VA_ARGS__)
 
 int libcfs_debug_msg(struct libcfs_debug_msg_data *msgdata,
-			    const char *format1, ...)
+		     const char *format1, ...)
 	__printf(2, 3);
 
 int libcfs_debug_vmsg2(struct libcfs_debug_msg_data *msgdata,
-			      const char *format1,
-			      va_list args, const char *format2, ...)
+		       const char *format1,
+		       va_list args, const char *format2, ...)
 	__printf(4, 5);
 
 /* other external symbols that tracefile provides: */
 int cfs_trace_copyin_string(char *knl_buffer, int knl_buffer_nob,
-		const char __user *usr_buffer, int usr_buffer_nob);
+			    const char __user *usr_buffer, int usr_buffer_nob);
 int cfs_trace_copyout_string(char __user *usr_buffer, int usr_buffer_nob,
-		const char *knl_buffer, char *append);
+			     const char *knl_buffer, char *append);
 
 #define LIBCFS_DEBUG_FILE_PATH_DEFAULT "/tmp/lustre-log"
 
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 4f5978b..e93dbeb 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -618,7 +618,7 @@ static int kiblnd_get_completion_vector(struct kib_conn *conn, int cpt)
 }
 
 struct kib_conn *kiblnd_create_conn(struct kib_peer *peer, struct rdma_cm_id *cmid,
-			       int state, int version)
+				    int state, int version)
 {
 	/*
 	 * CAVEAT EMPTOR:
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 25f87e5..1563428 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -41,9 +41,10 @@
 static void kiblnd_peer_alive(struct kib_peer *peer);
 static void kiblnd_peer_connect_failed(struct kib_peer *peer, int active, int error);
 static void kiblnd_init_tx_msg(lnet_ni_t *ni, struct kib_tx *tx,
-				int type, int body_nob);
+			       int type, int body_nob);
 static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
-			     int resid, struct kib_rdma_desc *dstrd, __u64 dstcookie);
+			    int resid, struct kib_rdma_desc *dstrd,
+			    __u64 dstcookie);
 static void kiblnd_queue_tx_locked(struct kib_tx *tx, struct kib_conn *conn);
 static void kiblnd_queue_tx(struct kib_tx *tx, struct kib_conn *conn);
 static void kiblnd_unmap_tx(lnet_ni_t *ni, struct kib_tx *tx);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index 068440e..e6ca0cf 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -631,7 +631,7 @@ int  ksocknal_close_peer_conns_locked(struct ksock_peer *peer,
 int ksocknal_close_conn_and_siblings(struct ksock_conn *conn, int why);
 int ksocknal_close_matching_conns(lnet_process_id_t id, __u32 ipaddr);
 struct ksock_conn *ksocknal_find_conn_locked(struct ksock_peer *peer,
-					struct ksock_tx *tx, int nonblk);
+					     struct ksock_tx *tx, int nonblk);
 
 int  ksocknal_launch_packet(lnet_ni_t *ni, struct ksock_tx *tx,
 			    lnet_process_id_t id);
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
index 5c0116a..7f56d2c 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-crypto.c
@@ -95,8 +95,8 @@ static int cfs_crypto_hash_alloc(enum cfs_crypto_hash_alg hash_alg,
 		err = crypto_ahash_setkey(tfm, key, key_len);
 	else if ((*type)->cht_key != 0)
 		err = crypto_ahash_setkey(tfm,
-					 (unsigned char *)&((*type)->cht_key),
-					 (*type)->cht_size);
+					  (unsigned char *)&((*type)->cht_key),
+					  (*type)->cht_size);
 
 	if (err != 0) {
 		ahash_request_free(*req);
diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index db9466a..4c00be2 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -323,7 +323,7 @@ struct cl_object_operations {
 	 *	 to be used instead of newly created.
 	 */
 	int  (*coo_page_init)(const struct lu_env *env, struct cl_object *obj,
-				struct cl_page *page, pgoff_t index);
+			      struct cl_page *page, pgoff_t index);
 	/**
 	 * Initialize lock slice for this layer. Called top-to-bottom through
 	 * every object layer when a new cl_lock is instantiated. Layer
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
index f5023d9..ecf472e 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
@@ -221,7 +221,7 @@ void ldlm_extent_unlink_lock(struct ldlm_lock *lock)
 }
 
 void ldlm_extent_policy_wire_to_local(const ldlm_wire_policy_data_t *wpolicy,
-				     ldlm_policy_data_t *lpolicy)
+				      ldlm_policy_data_t *lpolicy)
 {
 	memset(lpolicy, 0, sizeof(*lpolicy));
 	lpolicy->l_extent.start = wpolicy->l_extent.start;
@@ -230,7 +230,7 @@ void ldlm_extent_policy_wire_to_local(const ldlm_wire_policy_data_t *wpolicy,
 }
 
 void ldlm_extent_policy_local_to_wire(const ldlm_policy_data_t *lpolicy,
-				     ldlm_wire_policy_data_t *wpolicy)
+				      ldlm_wire_policy_data_t *wpolicy)
 {
 	memset(wpolicy, 0, sizeof(*wpolicy));
 	wpolicy->l_extent.start = lpolicy->l_extent.start;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index 61d649f..78a8450 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -166,7 +166,7 @@ reprocess:
 		 */
 		list_for_each(tmp, &res->lr_granted) {
 			lock = list_entry(tmp, struct ldlm_lock,
-					      l_res_link);
+					  l_res_link);
 			if (ldlm_same_flock_owner(lock, req)) {
 				ownlocks = tmp;
 				break;
@@ -182,7 +182,7 @@ reprocess:
 		 */
 		list_for_each(tmp, &res->lr_granted) {
 			lock = list_entry(tmp, struct ldlm_lock,
-					      l_res_link);
+					  l_res_link);
 
 			if (ldlm_same_flock_owner(lock, req)) {
 				if (!ownlocks)
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
index e4cf65d..dc0e4af 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_internal.h
@@ -100,8 +100,8 @@ enum {
 int ldlm_cancel_lru(struct ldlm_namespace *ns, int nr,
 		    enum ldlm_cancel_flags sync, int flags);
 int ldlm_cancel_lru_local(struct ldlm_namespace *ns,
-			 struct list_head *cancels, int count, int max,
-			 enum ldlm_cancel_flags cancel_flags, int flags);
+			  struct list_head *cancels, int count, int max,
+			  enum ldlm_cancel_flags cancel_flags, int flags);
 extern int ldlm_enqueue_min;
 
 /* ldlm_resource.c */
@@ -200,8 +200,7 @@ ldlm_interval_extent(struct ldlm_interval *node)
 
 	LASSERT(!list_empty(&node->li_group));
 
-	lock = list_entry(node->li_group.next, struct ldlm_lock,
-			      l_sl_policy);
+	lock = list_entry(node->li_group.next, struct ldlm_lock, l_sl_policy);
 	return &lock->l_policy_data.l_extent;
 }
 
@@ -302,7 +301,7 @@ static inline int is_granted_or_cancelled(struct ldlm_lock *lock)
 
 	lock_res_and_lock(lock);
 	if ((lock->l_req_mode == lock->l_granted_mode) &&
-	     !ldlm_is_cp_reqd(lock))
+	    !ldlm_is_cp_reqd(lock))
 		ret = 1;
 	else if (ldlm_is_failed(lock) || ldlm_is_cancel(lock))
 		ret = 1;
@@ -326,13 +325,13 @@ void ldlm_ibits_policy_wire_to_local(const ldlm_wire_policy_data_t *wpolicy,
 void ldlm_ibits_policy_local_to_wire(const ldlm_policy_data_t *lpolicy,
 				     ldlm_wire_policy_data_t *wpolicy);
 void ldlm_extent_policy_wire_to_local(const ldlm_wire_policy_data_t *wpolicy,
-				     ldlm_policy_data_t *lpolicy);
+				      ldlm_policy_data_t *lpolicy);
 void ldlm_extent_policy_local_to_wire(const ldlm_policy_data_t *lpolicy,
-				     ldlm_wire_policy_data_t *wpolicy);
+				      ldlm_wire_policy_data_t *wpolicy);
 void ldlm_flock_policy_wire18_to_local(const ldlm_wire_policy_data_t *wpolicy,
-				     ldlm_policy_data_t *lpolicy);
+				       ldlm_policy_data_t *lpolicy);
 void ldlm_flock_policy_wire21_to_local(const ldlm_wire_policy_data_t *wpolicy,
-				     ldlm_policy_data_t *lpolicy);
+				       ldlm_policy_data_t *lpolicy);
 
 void ldlm_flock_policy_local_to_wire(const ldlm_policy_data_t *lpolicy,
 				     ldlm_wire_policy_data_t *wpolicy);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index 3c98ce2..0d466e2 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -82,7 +82,7 @@ static int import_set_conn(struct obd_import *imp, struct obd_uuid *uuid,
 			if (priority) {
 				list_del(&item->oic_item);
 				list_add(&item->oic_item,
-					     &imp->imp_conn_list);
+					 &imp->imp_conn_list);
 				item->oic_last_attempt = 0;
 			}
 			CDEBUG(D_HA, "imp %p@%s: found existing conn %s%s\n",
@@ -102,7 +102,7 @@ static int import_set_conn(struct obd_import *imp, struct obd_uuid *uuid,
 			list_add(&imp_conn->oic_item, &imp->imp_conn_list);
 		else
 			list_add_tail(&imp_conn->oic_item,
-					  &imp->imp_conn_list);
+				      &imp->imp_conn_list);
 		CDEBUG(D_HA, "imp %p@%s: add connection %s at %s\n",
 		       imp, imp->imp_obd->obd_name, uuid->uuid,
 		       (priority ? "head" : "tail"));
@@ -692,7 +692,7 @@ void target_send_reply(struct ptlrpc_request *req, int rc, int fail_id)
 	if (rs->rs_transno > exp->exp_last_committed) {
 		/* not committed already */
 		list_add_tail(&rs->rs_obd_list,
-				  &exp->exp_uncommitted_replies);
+			      &exp->exp_uncommitted_replies);
 	}
 	spin_unlock(&exp->exp_uncommitted_replies_lock);
 
@@ -797,7 +797,7 @@ void ldlm_dump_export_locks(struct obd_export *exp)
 		CERROR("dumping locks for export %p,ignore if the unmount doesn't hang\n",
 		       exp);
 		list_for_each_entry(lock, &exp->exp_locks_list,
-					l_exp_refs_link)
+				    l_exp_refs_link)
 			LDLM_ERROR(lock, "lock:");
 	}
 	spin_unlock(&exp->exp_locks_list_guard);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 7a34caf..55b7460 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -937,7 +937,7 @@ static void search_granted_lock(struct list_head *queue,
 				/* go to next policy group within mode group */
 				tmp = policy_end->l_res_link.next;
 				lock = list_entry(tmp, struct ldlm_lock,
-						      l_res_link);
+						  l_res_link);
 			}  /* loop over policy groups within the mode group */
 
 			/* insert point is last lock of the mode group,
@@ -1116,7 +1116,7 @@ static struct ldlm_lock *search_queue(struct list_head *queue,
 		 * of bits.
 		 */
 		if (lock->l_resource->lr_type == LDLM_IBITS &&
-		     ((lock->l_policy_data.l_inodebits.bits &
+		    ((lock->l_policy_data.l_inodebits.bits &
 		      policy->l_inodebits.bits) !=
 		      policy->l_inodebits.bits))
 			continue;
@@ -1376,12 +1376,12 @@ int ldlm_fill_lvb(struct ldlm_lock *lock, struct req_capsule *pill,
 		if (size == sizeof(struct ost_lvb)) {
 			if (loc == RCL_CLIENT)
 				lvb = req_capsule_client_swab_get(pill,
-						&RMF_DLM_LVB,
-						lustre_swab_ost_lvb);
+								  &RMF_DLM_LVB,
+							lustre_swab_ost_lvb);
 			else
 				lvb = req_capsule_server_swab_get(pill,
-						&RMF_DLM_LVB,
-						lustre_swab_ost_lvb);
+								  &RMF_DLM_LVB,
+							lustre_swab_ost_lvb);
 			if (unlikely(!lvb)) {
 				LDLM_ERROR(lock, "no LVB");
 				return -EPROTO;
@@ -1393,8 +1393,8 @@ int ldlm_fill_lvb(struct ldlm_lock *lock, struct req_capsule *pill,
 
 			if (loc == RCL_CLIENT)
 				lvb = req_capsule_client_swab_get(pill,
-						&RMF_DLM_LVB,
-						lustre_swab_ost_lvb_v1);
+								  &RMF_DLM_LVB,
+							lustre_swab_ost_lvb_v1);
 			else
 				lvb = req_capsule_server_sized_swab_get(pill,
 						&RMF_DLM_LVB, size,
@@ -1418,12 +1418,12 @@ int ldlm_fill_lvb(struct ldlm_lock *lock, struct req_capsule *pill,
 		if (size == sizeof(struct lquota_lvb)) {
 			if (loc == RCL_CLIENT)
 				lvb = req_capsule_client_swab_get(pill,
-						&RMF_DLM_LVB,
-						lustre_swab_lquota_lvb);
+								  &RMF_DLM_LVB,
+							lustre_swab_lquota_lvb);
 			else
 				lvb = req_capsule_server_swab_get(pill,
-						&RMF_DLM_LVB,
-						lustre_swab_lquota_lvb);
+								  &RMF_DLM_LVB,
+							lustre_swab_lquota_lvb);
 			if (unlikely(!lvb)) {
 				LDLM_ERROR(lock, "no LVB");
 				return -EPROTO;
@@ -1709,7 +1709,7 @@ static int ldlm_work_gl_ast_lock(struct ptlrpc_request_set *rqset, void *opaq)
 		return -ENOENT;
 
 	gl_work = list_entry(arg->list->next, struct ldlm_glimpse_work,
-				 gl_list);
+			     gl_list);
 	list_del_init(&gl_work->gl_list);
 
 	lock = gl_work->gl_lock;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index 821939f..b91b26d 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -706,12 +706,12 @@ static struct ldlm_bl_work_item *ldlm_bl_get_work(struct ldlm_bl_pool *blp)
 	if (!list_empty(&blp->blp_list) &&
 	    (list_empty(&blp->blp_prio_list) || num_bl == 0))
 		blwi = list_entry(blp->blp_list.next,
-				      struct ldlm_bl_work_item, blwi_entry);
+				  struct ldlm_bl_work_item, blwi_entry);
 	else
 		if (!list_empty(&blp->blp_prio_list))
 			blwi = list_entry(blp->blp_prio_list.next,
-					      struct ldlm_bl_work_item,
-					      blwi_entry);
+					  struct ldlm_bl_work_item,
+					  blwi_entry);
 
 	if (blwi) {
 		if (++num_bl >= atomic_read(&blp->blp_num_threads))
@@ -741,7 +741,7 @@ static int ldlm_bl_thread_start(struct ldlm_bl_pool *blp)
 	init_completion(&bltd.bltd_comp);
 	bltd.bltd_num = atomic_read(&blp->blp_num_threads);
 	snprintf(bltd.bltd_name, sizeof(bltd.bltd_name),
-		"ldlm_bl_%02d", bltd.bltd_num);
+		 "ldlm_bl_%02d", bltd.bltd_num);
 	task = kthread_run(ldlm_bl_thread_main, &bltd, "%s", bltd.bltd_name);
 	if (IS_ERR(task)) {
 		CERROR("cannot start LDLM thread ldlm_bl_%02d: rc %ld\n",
@@ -786,8 +786,8 @@ static int ldlm_bl_thread_main(void *arg)
 		if (!blwi) {
 			atomic_dec(&blp->blp_busy_threads);
 			l_wait_event_exclusive(blp->blp_waitq,
-					 (blwi = ldlm_bl_get_work(blp)),
-					 &lwi);
+					       (blwi = ldlm_bl_get_work(blp)),
+					       &lwi);
 			busy = atomic_inc_return(&blp->blp_busy_threads);
 		} else {
 			busy = atomic_read(&blp->blp_busy_threads);
@@ -1094,16 +1094,17 @@ int ldlm_init(void)
 		return -ENOMEM;
 
 	ldlm_lock_slab = kmem_cache_create("ldlm_locks",
-			      sizeof(struct ldlm_lock), 0,
-			      SLAB_HWCACHE_ALIGN | SLAB_DESTROY_BY_RCU, NULL);
+					   sizeof(struct ldlm_lock), 0,
+					   SLAB_HWCACHE_ALIGN |
+					   SLAB_DESTROY_BY_RCU, NULL);
 	if (!ldlm_lock_slab) {
 		kmem_cache_destroy(ldlm_resource_slab);
 		return -ENOMEM;
 	}
 
 	ldlm_interval_slab = kmem_cache_create("interval_node",
-					sizeof(struct ldlm_interval),
-					0, SLAB_HWCACHE_ALIGN, NULL);
+					       sizeof(struct ldlm_interval),
+					       0, SLAB_HWCACHE_ALIGN, NULL);
 	if (!ldlm_interval_slab) {
 		kmem_cache_destroy(ldlm_resource_slab);
 		kmem_cache_destroy(ldlm_lock_slab);
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
index 657ed40..2fc319e 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
@@ -995,7 +995,7 @@ static int ldlm_pools_thread_main(void *arg)
 	wake_up(&thread->t_ctl_waitq);
 
 	CDEBUG(D_DLMTRACE, "%s: pool thread starting, process %d\n",
-		"ldlm_poold", current_pid());
+	       "ldlm_poold", current_pid());
 
 	while (1) {
 		struct l_wait_info lwi;
@@ -1025,7 +1025,7 @@ static int ldlm_pools_thread_main(void *arg)
 	wake_up(&thread->t_ctl_waitq);
 
 	CDEBUG(D_DLMTRACE, "%s: pool thread exiting, process %d\n",
-		"ldlm_poold", current_pid());
+	       "ldlm_poold", current_pid());
 
 	complete_and_exit(&ldlm_pools_comp, 0);
 }
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index ce579a2..1dc8d21 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -1178,8 +1178,7 @@ static enum ldlm_policy_res ldlm_cancel_lrur_policy(struct ldlm_namespace *ns,
 
 	slv = ldlm_pool_get_slv(pl);
 	lvf = ldlm_pool_get_lvf(pl);
-	la = cfs_duration_sec(cfs_time_sub(cur,
-			      lock->l_last_used));
+	la = cfs_duration_sec(cfs_time_sub(cur, lock->l_last_used));
 	lv = lvf * la * unused;
 
 	/* Inform pool about current CLV to see it via debugfs. */
@@ -1372,7 +1371,7 @@ static int ldlm_prepare_lru_list(struct ldlm_namespace *ns,
 			break;
 
 		list_for_each_entry_safe(lock, next, &ns->ns_unused_list,
-					     l_lru) {
+					 l_lru) {
 			/* No locks which got blocking requests. */
 			LASSERT(!ldlm_is_bl_ast(lock));
 
@@ -1608,8 +1607,7 @@ int ldlm_cli_cancel_list(struct list_head *cancels, int count,
 	 */
 	while (count > 0) {
 		LASSERT(!list_empty(cancels));
-		lock = list_entry(cancels->next, struct ldlm_lock,
-				      l_bl_ast);
+		lock = list_entry(cancels->next, struct ldlm_lock, l_bl_ast);
 		LASSERT(lock->l_conn_export);
 
 		if (exp_connect_cancelset(lock->l_conn_export)) {
@@ -2008,7 +2006,7 @@ static void ldlm_cancel_unused_locks_for_replay(struct ldlm_namespace *ns)
 					 LCF_LOCAL, LDLM_CANCEL_NO_WAIT);
 
 	CDEBUG(D_DLMTRACE, "Canceled %d unused locks from namespace %s\n",
-			   canceled, ldlm_ns_name(ns));
+	       canceled, ldlm_ns_name(ns));
 }
 
 int ldlm_replay_locks(struct obd_import *imp)
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index c37a7b0..e2c2587 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -758,8 +758,7 @@ static void cleanup_resource(struct ldlm_resource *res, struct list_head *q,
 		 */
 		lock_res(res);
 		list_for_each(tmp, q) {
-			lock = list_entry(tmp, struct ldlm_lock,
-					      l_res_link);
+			lock = list_entry(tmp, struct ldlm_lock, l_res_link);
 			if (ldlm_is_cleaned(lock)) {
 				lock = NULL;
 				continue;
@@ -1381,7 +1380,7 @@ void ldlm_resource_dump(int level, struct ldlm_resource *res)
 	if (!list_empty(&res->lr_granted)) {
 		CDEBUG(level, "Granted locks (in reverse order):\n");
 		list_for_each_entry_reverse(lock, &res->lr_granted,
-						l_res_link) {
+					    l_res_link) {
 			LDLM_DEBUG_LIMIT(level, lock, "###");
 			if (!(level & D_CANTMASK) &&
 			    ++granted > ldlm_dump_granted_max) {
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index b7f399e..72ff7c4 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1357,8 +1357,8 @@ static int ll_setattr_done_writing(struct inode *inode,
 		rc = ll_som_update(inode, op_data);
 	else if (rc) {
 		CERROR("%s: inode "DFID" mdc truncate failed: rc = %d\n",
-		      ll_i2sbi(inode)->ll_md_exp->exp_obd->obd_name,
-		      PFID(ll_inode2fid(inode)), rc);
+		       ll_i2sbi(inode)->ll_md_exp->exp_obd->obd_name,
+		       PFID(ll_inode2fid(inode)), rc);
 	}
 	return rc;
 }
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index f053f55..bb85d16 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -648,8 +648,8 @@ static void ras_update_stride_detector(struct ll_readahead_state *ras,
 {
 	unsigned long stride_gap = index - ras->ras_last_readpage - 1;
 
-	if (!stride_io_mode(ras) && (stride_gap != 0 ||
-	    ras->ras_consecutive_stride_requests == 0)) {
+	if ((stride_gap != 0 || ras->ras_consecutive_stride_requests == 0) &&
+	    !stride_io_mode(ras)) {
 		ras->ras_stride_pages = ras->ras_consecutive_pages;
 		ras->ras_stride_length = ras->ras_consecutive_pages +
 					 stride_gap;
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index dfd51af..4ac0d6a 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -918,7 +918,8 @@ static void ll_statahead_one(struct dentry *parent, const char *entry_name,
 
 	if (rc) {
 		rc1 = ll_sa_entry_to_stated(sai, entry,
-					rc < 0 ? SA_ENTRY_INVA : SA_ENTRY_SUCC);
+					    rc < 0 ? SA_ENTRY_INVA :
+					    SA_ENTRY_SUCC);
 		if (rc1 == 0 && entry->se_index == sai->sai_index_wait)
 			wake_up(&sai->sai_waitq);
 	} else {
diff --git a/drivers/staging/lustre/lustre/llite/vvp_page.c b/drivers/staging/lustre/lustre/llite/vvp_page.c
index 2e566d9..2818a68 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_page.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_page.c
@@ -249,7 +249,7 @@ static void vvp_vmpage_error(struct inode *inode, struct page *vmpage, int ioret
 			set_bit(AS_EIO, &inode->i_mapping->flags);
 
 		if ((ioret == -ESHUTDOWN || ioret == -EINTR) &&
-		     obj->vob_discard_page_warned == 0) {
+		    obj->vob_discard_page_warned == 0) {
 			obj->vob_discard_page_warned = 1;
 			ll_dirty_page_discard_warn(vmpage, ioret);
 		}
@@ -549,7 +549,7 @@ static const struct cl_page_operations vvp_transient_page_ops = {
 };
 
 int vvp_page_init(const struct lu_env *env, struct cl_object *obj,
-		struct cl_page *page, pgoff_t index)
+		  struct cl_page *page, pgoff_t index)
 {
 	struct vvp_page *vpg = cl_object_page_slice(obj, page);
 	struct page     *vmpage = page->cp_vmpage;
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 1f8a0fc..2817f38 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -2162,8 +2162,8 @@ static int lov_set_info_async(const struct lu_env *env, struct obd_export *exp,
 						 &mgi->group, set);
 		} else if (next_id) {
 			err = obd_set_info_async(env, tgt->ltd_exp,
-					 keylen, key, vallen,
-					 ((struct obd_id_info *)val)->data, set);
+						 keylen, key, vallen,
+					((struct obd_id_info *)val)->data, set);
 		} else {
 			/* Only want a specific OSC */
 			if (check_uuid &&
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index c234e35..f38339a 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -665,7 +665,8 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 		lvb_len = req_capsule_get_size(pill, &RMF_DLM_LVB, RCL_SERVER);
 		if (lvb_len > 0) {
 			lvb_data = req_capsule_server_sized_get(pill,
-							&RMF_DLM_LVB, lvb_len);
+								&RMF_DLM_LVB,
+								lvb_len);
 			if (!lvb_data)
 				return -EPROTO;
 		}
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index 0c48257..ae702ce 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -68,7 +68,7 @@ static void (*kill_super_cb)(struct super_block *sb);
  *   this log, and is added to the mgc's list of logs to follow.
  */
 int lustre_process_log(struct super_block *sb, char *logname,
-		      struct config_llog_instance *cfg)
+		       struct config_llog_instance *cfg)
 {
 	struct lustre_cfg *lcfg;
 	struct lustre_cfg_bufs *bufs;
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index ebcebe8..97f936e 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -958,8 +958,8 @@ static int osc_extent_wait(const struct lu_env *env, struct osc_extent *ext,
 	rc = l_wait_event(ext->oe_waitq, extent_wait_cb(ext, state), &lwi);
 	if (rc == -ETIMEDOUT) {
 		OSC_EXTENT_DUMP(D_ERROR, ext,
-			"%s: wait ext to %d timedout, recovery in progress?\n",
-			osc_export(obj)->exp_obd->obd_name, state);
+				"%s: wait ext to %d timedout, recovery in progress?\n",
+				osc_export(obj)->exp_obd->obd_name, state);
 
 		lwi = LWI_INTR(NULL, NULL);
 		rc = l_wait_event(ext->oe_waitq, extent_wait_cb(ext, state),
diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
index 11ec825..44f4eae 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
@@ -398,7 +398,8 @@ int ptlrpc_send_reply(struct ptlrpc_request *req, int flags)
 	lustre_msg_set_status(req->rq_repmsg,
 			      ptlrpc_status_hton(req->rq_status));
 	lustre_msg_set_opc(req->rq_repmsg,
-		req->rq_reqmsg ? lustre_msg_get_opc(req->rq_reqmsg) : 0);
+			   req->rq_reqmsg ?
+			   lustre_msg_get_opc(req->rq_reqmsg) : 0);
 
 	target_pack_pool_reply(req);
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 9c03a9a..2cf3a51 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -1203,8 +1203,9 @@ __u32 lustre_msg_calc_cksum(struct lustre_msg *msg)
 		unsigned int hsize = 4;
 
 		cfs_crypto_hash_digest(CFS_HASH_ALG_CRC32, (unsigned char *)pb,
-				   lustre_msg_buflen(msg, MSG_PTLRPC_BODY_OFF),
-				   NULL, 0, (unsigned char *)&crc, &hsize);
+				       lustre_msg_buflen(msg,
+							 MSG_PTLRPC_BODY_OFF),
+				       NULL, 0, (unsigned char *)&crc, &hsize);
 		return crc;
 	}
 	default:
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
index bb00185..fdb32d5 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
@@ -523,8 +523,9 @@ int sptlrpc_get_bulk_checksum(struct ptlrpc_bulk_desc *desc, __u8 alg,
 
 	for (i = 0; i < desc->bd_iov_count; i++) {
 		cfs_crypto_hash_update_page(hdesc, desc->bd_iov[i].bv_page,
-				  desc->bd_iov[i].bv_offset & ~PAGE_MASK,
-				  desc->bd_iov[i].bv_len);
+					    desc->bd_iov[i].bv_offset &
+					    ~PAGE_MASK,
+					    desc->bd_iov[i].bv_len);
 	}
 
 	if (hashsize > buflen) {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
index 8322550..cd305bc 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_plain.c
@@ -249,9 +249,12 @@ int plain_ctx_verify(struct ptlrpc_cli_ctx *ctx, struct ptlrpc_request *req)
 		unsigned int hsize = 4;
 
 		cfs_crypto_hash_digest(CFS_HASH_ALG_CRC32,
-				lustre_msg_buf(msg, PLAIN_PACK_MSG_OFF, 0),
-				lustre_msg_buflen(msg, PLAIN_PACK_MSG_OFF),
-				NULL, 0, (unsigned char *)&cksum, &hsize);
+				       lustre_msg_buf(msg, PLAIN_PACK_MSG_OFF,
+						      0),
+				       lustre_msg_buflen(msg,
+							 PLAIN_PACK_MSG_OFF),
+				       NULL, 0, (unsigned char *)&cksum,
+				       &hsize);
 		if (cksum != msg->lm_cksum) {
 			CDEBUG(D_SEC,
 			       "early reply checksum mismatch: %08x != %08x\n",
@@ -869,9 +872,12 @@ int plain_authorize(struct ptlrpc_request *req)
 		unsigned int hsize = 4;
 
 		cfs_crypto_hash_digest(CFS_HASH_ALG_CRC32,
-			lustre_msg_buf(msg, PLAIN_PACK_MSG_OFF, 0),
-			lustre_msg_buflen(msg, PLAIN_PACK_MSG_OFF),
-			NULL, 0, (unsigned char *)&msg->lm_cksum, &hsize);
+				       lustre_msg_buf(msg, PLAIN_PACK_MSG_OFF,
+						      0),
+				       lustre_msg_buflen(msg,
+							 PLAIN_PACK_MSG_OFF),
+				       NULL, 0, (unsigned char *)&msg->lm_cksum,
+				       &hsize);
 		req->rq_reply_off = 0;
 	}
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index be3c96c..a2fce66 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -1990,11 +1990,12 @@ ptlrpc_wait_event(struct ptlrpc_service_part *svcpt,
 	cond_resched();
 
 	l_wait_event_exclusive_head(svcpt->scp_waitq,
-				ptlrpc_thread_stopping(thread) ||
-				ptlrpc_server_request_incoming(svcpt) ||
-				ptlrpc_server_request_pending(svcpt, false) ||
-				ptlrpc_rqbd_pending(svcpt) ||
-				ptlrpc_at_check(svcpt), &lwi);
+				    ptlrpc_thread_stopping(thread) ||
+				    ptlrpc_server_request_incoming(svcpt) ||
+				    ptlrpc_server_request_pending(svcpt,
+								  false) ||
+				    ptlrpc_rqbd_pending(svcpt) ||
+				    ptlrpc_at_check(svcpt), &lwi);
 
 	if (ptlrpc_thread_stopping(thread))
 		return -EINTR;
@@ -2357,7 +2358,7 @@ static void ptlrpc_svcpt_stop_threads(struct ptlrpc_service_part *svcpt)
 
 	while (!list_empty(&zombie)) {
 		thread = list_entry(zombie.next,
-					struct ptlrpc_thread, t_link);
+				    struct ptlrpc_thread, t_link);
 		list_del(&thread->t_link);
 		kfree(thread);
 	}
@@ -2547,8 +2548,8 @@ int ptlrpc_hr_init(void)
 		LASSERT(hrp->hrp_nthrs > 0);
 		hrp->hrp_thrs =
 			kzalloc_node(hrp->hrp_nthrs * sizeof(*hrt), GFP_NOFS,
-				cfs_cpt_spread_node(ptlrpc_hr.hr_cpt_table,
-						    i));
+				     cfs_cpt_spread_node(ptlrpc_hr.hr_cpt_table,
+							 i));
 		if (!hrp->hrp_thrs) {
 			rc = -ENOMEM;
 			goto out;
@@ -2601,7 +2602,8 @@ static void ptlrpc_wait_replies(struct ptlrpc_service_part *svcpt)
 						     NULL, NULL);
 
 		rc = l_wait_event(svcpt->scp_waitq,
-		     atomic_read(&svcpt->scp_nreps_difficult) == 0, &lwi);
+				  atomic_read(&svcpt->scp_nreps_difficult) == 0,
+				  &lwi);
 		if (rc == 0)
 			break;
 		CWARN("Unexpectedly long timeout %s %p\n",
@@ -2647,7 +2649,7 @@ ptlrpc_service_unlink_rqbd(struct ptlrpc_service *svc)
 		 * event with its 'unlink' flag set for each posted rqbd
 		 */
 		list_for_each_entry(rqbd, &svcpt->scp_rqbd_posted,
-					rqbd_list) {
+				    rqbd_list) {
 			rc = LNetMDUnlink(rqbd->rqbd_md_h);
 			LASSERT(rc == 0 || rc == -ENOENT);
 		}
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index 3748f71..eb6d88e 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -195,25 +195,25 @@ void lustre_assert_wire_constants(void)
 	LASSERTF(REINT_MAX == 10, "found %lld\n",
 		 (long long)REINT_MAX);
 	LASSERTF(DISP_IT_EXECD == 0x00000001UL, "found 0x%.8xUL\n",
-		(unsigned)DISP_IT_EXECD);
+		 (unsigned)DISP_IT_EXECD);
 	LASSERTF(DISP_LOOKUP_EXECD == 0x00000002UL, "found 0x%.8xUL\n",
-		(unsigned)DISP_LOOKUP_EXECD);
+		 (unsigned)DISP_LOOKUP_EXECD);
 	LASSERTF(DISP_LOOKUP_NEG == 0x00000004UL, "found 0x%.8xUL\n",
-		(unsigned)DISP_LOOKUP_NEG);
+		 (unsigned)DISP_LOOKUP_NEG);
 	LASSERTF(DISP_LOOKUP_POS == 0x00000008UL, "found 0x%.8xUL\n",
-		(unsigned)DISP_LOOKUP_POS);
+		 (unsigned)DISP_LOOKUP_POS);
 	LASSERTF(DISP_OPEN_CREATE == 0x00000010UL, "found 0x%.8xUL\n",
-		(unsigned)DISP_OPEN_CREATE);
+		 (unsigned)DISP_OPEN_CREATE);
 	LASSERTF(DISP_OPEN_OPEN == 0x00000020UL, "found 0x%.8xUL\n",
-		(unsigned)DISP_OPEN_OPEN);
+		 (unsigned)DISP_OPEN_OPEN);
 	LASSERTF(DISP_ENQ_COMPLETE == 0x00400000UL, "found 0x%.8xUL\n",
-		(unsigned)DISP_ENQ_COMPLETE);
+		 (unsigned)DISP_ENQ_COMPLETE);
 	LASSERTF(DISP_ENQ_OPEN_REF == 0x00800000UL, "found 0x%.8xUL\n",
-		(unsigned)DISP_ENQ_OPEN_REF);
+		 (unsigned)DISP_ENQ_OPEN_REF);
 	LASSERTF(DISP_ENQ_CREATE_REF == 0x01000000UL, "found 0x%.8xUL\n",
-		(unsigned)DISP_ENQ_CREATE_REF);
+		 (unsigned)DISP_ENQ_CREATE_REF);
 	LASSERTF(DISP_OPEN_LOCK == 0x02000000UL, "found 0x%.8xUL\n",
-		(unsigned)DISP_OPEN_LOCK);
+		 (unsigned)DISP_OPEN_LOCK);
 	LASSERTF(MDS_STATUS_CONN == 1, "found %lld\n",
 		 (long long)MDS_STATUS_CONN);
 	LASSERTF(MDS_STATUS_LOV == 2, "found %lld\n",
@@ -221,55 +221,55 @@ void lustre_assert_wire_constants(void)
 	LASSERTF(LUSTRE_BFLAG_UNCOMMITTED_WRITES == 1, "found %lld\n",
 		 (long long)LUSTRE_BFLAG_UNCOMMITTED_WRITES);
 	LASSERTF(MF_SOM_CHANGE == 0x00000001UL, "found 0x%.8xUL\n",
-		(unsigned)MF_SOM_CHANGE);
+		 (unsigned)MF_SOM_CHANGE);
 	LASSERTF(MF_EPOCH_OPEN == 0x00000002UL, "found 0x%.8xUL\n",
-		(unsigned)MF_EPOCH_OPEN);
+		 (unsigned)MF_EPOCH_OPEN);
 	LASSERTF(MF_EPOCH_CLOSE == 0x00000004UL, "found 0x%.8xUL\n",
-		(unsigned)MF_EPOCH_CLOSE);
+		 (unsigned)MF_EPOCH_CLOSE);
 	LASSERTF(MF_MDC_CANCEL_FID1 == 0x00000008UL, "found 0x%.8xUL\n",
-		(unsigned)MF_MDC_CANCEL_FID1);
+		 (unsigned)MF_MDC_CANCEL_FID1);
 	LASSERTF(MF_MDC_CANCEL_FID2 == 0x00000010UL, "found 0x%.8xUL\n",
-		(unsigned)MF_MDC_CANCEL_FID2);
+		 (unsigned)MF_MDC_CANCEL_FID2);
 	LASSERTF(MF_MDC_CANCEL_FID3 == 0x00000020UL, "found 0x%.8xUL\n",
-		(unsigned)MF_MDC_CANCEL_FID3);
+		 (unsigned)MF_MDC_CANCEL_FID3);
 	LASSERTF(MF_MDC_CANCEL_FID4 == 0x00000040UL, "found 0x%.8xUL\n",
-		(unsigned)MF_MDC_CANCEL_FID4);
+		 (unsigned)MF_MDC_CANCEL_FID4);
 	LASSERTF(MF_SOM_AU == 0x00000080UL, "found 0x%.8xUL\n",
-		(unsigned)MF_SOM_AU);
+		 (unsigned)MF_SOM_AU);
 	LASSERTF(MF_GETATTR_LOCK == 0x00000100UL, "found 0x%.8xUL\n",
-		(unsigned)MF_GETATTR_LOCK);
+		 (unsigned)MF_GETATTR_LOCK);
 	LASSERTF(MDS_ATTR_MODE == 0x0000000000000001ULL, "found 0x%.16llxULL\n",
-			(long long)MDS_ATTR_MODE);
+		 (long long)MDS_ATTR_MODE);
 	LASSERTF(MDS_ATTR_UID == 0x0000000000000002ULL, "found 0x%.16llxULL\n",
-			(long long)MDS_ATTR_UID);
+		 (long long)MDS_ATTR_UID);
 	LASSERTF(MDS_ATTR_GID == 0x0000000000000004ULL, "found 0x%.16llxULL\n",
-			(long long)MDS_ATTR_GID);
+		 (long long)MDS_ATTR_GID);
 	LASSERTF(MDS_ATTR_SIZE == 0x0000000000000008ULL, "found 0x%.16llxULL\n",
-			(long long)MDS_ATTR_SIZE);
+		 (long long)MDS_ATTR_SIZE);
 	LASSERTF(MDS_ATTR_ATIME == 0x0000000000000010ULL, "found 0x%.16llxULL\n",
-			(long long)MDS_ATTR_ATIME);
+		 (long long)MDS_ATTR_ATIME);
 	LASSERTF(MDS_ATTR_MTIME == 0x0000000000000020ULL, "found 0x%.16llxULL\n",
-			(long long)MDS_ATTR_MTIME);
+		 (long long)MDS_ATTR_MTIME);
 	LASSERTF(MDS_ATTR_CTIME == 0x0000000000000040ULL, "found 0x%.16llxULL\n",
-			(long long)MDS_ATTR_CTIME);
+		 (long long)MDS_ATTR_CTIME);
 	LASSERTF(MDS_ATTR_ATIME_SET == 0x0000000000000080ULL, "found 0x%.16llxULL\n",
-			(long long)MDS_ATTR_ATIME_SET);
+		 (long long)MDS_ATTR_ATIME_SET);
 	LASSERTF(MDS_ATTR_MTIME_SET == 0x0000000000000100ULL, "found 0x%.16llxULL\n",
-			(long long)MDS_ATTR_MTIME_SET);
+		 (long long)MDS_ATTR_MTIME_SET);
 	LASSERTF(MDS_ATTR_FORCE == 0x0000000000000200ULL, "found 0x%.16llxULL\n",
-			(long long)MDS_ATTR_FORCE);
+		 (long long)MDS_ATTR_FORCE);
 	LASSERTF(MDS_ATTR_ATTR_FLAG == 0x0000000000000400ULL, "found 0x%.16llxULL\n",
-			(long long)MDS_ATTR_ATTR_FLAG);
+		 (long long)MDS_ATTR_ATTR_FLAG);
 	LASSERTF(MDS_ATTR_KILL_SUID == 0x0000000000000800ULL, "found 0x%.16llxULL\n",
-			(long long)MDS_ATTR_KILL_SUID);
+		 (long long)MDS_ATTR_KILL_SUID);
 	LASSERTF(MDS_ATTR_KILL_SGID == 0x0000000000001000ULL, "found 0x%.16llxULL\n",
-			(long long)MDS_ATTR_KILL_SGID);
+		 (long long)MDS_ATTR_KILL_SGID);
 	LASSERTF(MDS_ATTR_CTIME_SET == 0x0000000000002000ULL, "found 0x%.16llxULL\n",
-			(long long)MDS_ATTR_CTIME_SET);
+		 (long long)MDS_ATTR_CTIME_SET);
 	LASSERTF(MDS_ATTR_FROM_OPEN == 0x0000000000004000ULL, "found 0x%.16llxULL\n",
-			(long long)MDS_ATTR_FROM_OPEN);
+		 (long long)MDS_ATTR_FROM_OPEN);
 	LASSERTF(MDS_ATTR_BLOCKS == 0x0000000000008000ULL, "found 0x%.16llxULL\n",
-			(long long)MDS_ATTR_BLOCKS);
+		 (long long)MDS_ATTR_BLOCKS);
 	LASSERTF(FLD_QUERY == 900, "found %lld\n",
 		 (long long)FLD_QUERY);
 	LASSERTF(FLD_FIRST_OPC == 900, "found %lld\n",
@@ -420,15 +420,15 @@ void lustre_assert_wire_constants(void)
 	LASSERTF((int)sizeof(((struct lustre_mdt_attrs *)0)->lma_self_fid) == 16, "found %lld\n",
 		 (long long)(int)sizeof(((struct lustre_mdt_attrs *)0)->lma_self_fid));
 	LASSERTF(LMAI_RELEASED == 0x00000001UL, "found 0x%.8xUL\n",
-		(unsigned)LMAI_RELEASED);
+		 (unsigned)LMAI_RELEASED);
 	LASSERTF(LMAC_HSM == 0x00000001UL, "found 0x%.8xUL\n",
-		(unsigned)LMAC_HSM);
+		 (unsigned)LMAC_HSM);
 	LASSERTF(LMAC_SOM == 0x00000002UL, "found 0x%.8xUL\n",
-		(unsigned)LMAC_SOM);
+		 (unsigned)LMAC_SOM);
 	LASSERTF(LMAC_NOT_IN_OI == 0x00000004UL, "found 0x%.8xUL\n",
-		(unsigned)LMAC_NOT_IN_OI);
+		 (unsigned)LMAC_NOT_IN_OI);
 	LASSERTF(LMAC_FID_ON_OST == 0x00000008UL, "found 0x%.8xUL\n",
-		(unsigned)LMAC_FID_ON_OST);
+		 (unsigned)LMAC_FID_ON_OST);
 
 	/* Checks for struct ost_id */
 	LASSERTF((int)sizeof(struct ost_id) == 16, "found %lld\n",
@@ -454,35 +454,35 @@ void lustre_assert_wire_constants(void)
 	LASSERTF(FID_SEQ_IGIF == 12, "found %lld\n",
 		 (long long)FID_SEQ_IGIF);
 	LASSERTF(FID_SEQ_IGIF_MAX == 0x00000000ffffffffULL, "found 0x%.16llxULL\n",
-			(long long)FID_SEQ_IGIF_MAX);
+		 (long long)FID_SEQ_IGIF_MAX);
 	LASSERTF(FID_SEQ_IDIF == 0x0000000100000000ULL, "found 0x%.16llxULL\n",
-			(long long)FID_SEQ_IDIF);
+		 (long long)FID_SEQ_IDIF);
 	LASSERTF(FID_SEQ_IDIF_MAX == 0x00000001ffffffffULL, "found 0x%.16llxULL\n",
-			(long long)FID_SEQ_IDIF_MAX);
+		 (long long)FID_SEQ_IDIF_MAX);
 	LASSERTF(FID_SEQ_START == 0x0000000200000000ULL, "found 0x%.16llxULL\n",
-			(long long)FID_SEQ_START);
+		 (long long)FID_SEQ_START);
 	LASSERTF(FID_SEQ_LOCAL_FILE == 0x0000000200000001ULL, "found 0x%.16llxULL\n",
-			(long long)FID_SEQ_LOCAL_FILE);
+		 (long long)FID_SEQ_LOCAL_FILE);
 	LASSERTF(FID_SEQ_DOT_LUSTRE == 0x0000000200000002ULL, "found 0x%.16llxULL\n",
-			(long long)FID_SEQ_DOT_LUSTRE);
+		 (long long)FID_SEQ_DOT_LUSTRE);
 	LASSERTF(FID_SEQ_SPECIAL == 0x0000000200000004ULL, "found 0x%.16llxULL\n",
-			(long long)FID_SEQ_SPECIAL);
+		 (long long)FID_SEQ_SPECIAL);
 	LASSERTF(FID_SEQ_QUOTA == 0x0000000200000005ULL, "found 0x%.16llxULL\n",
-			(long long)FID_SEQ_QUOTA);
+		 (long long)FID_SEQ_QUOTA);
 	LASSERTF(FID_SEQ_QUOTA_GLB == 0x0000000200000006ULL, "found 0x%.16llxULL\n",
-			(long long)FID_SEQ_QUOTA_GLB);
+		 (long long)FID_SEQ_QUOTA_GLB);
 	LASSERTF(FID_SEQ_ROOT == 0x0000000200000007ULL, "found 0x%.16llxULL\n",
-			(long long)FID_SEQ_ROOT);
+		 (long long)FID_SEQ_ROOT);
 	LASSERTF(FID_SEQ_NORMAL == 0x0000000200000400ULL, "found 0x%.16llxULL\n",
-			(long long)FID_SEQ_NORMAL);
+		 (long long)FID_SEQ_NORMAL);
 	LASSERTF(FID_SEQ_LOV_DEFAULT == 0xffffffffffffffffULL, "found 0x%.16llxULL\n",
-			(long long)FID_SEQ_LOV_DEFAULT);
+		 (long long)FID_SEQ_LOV_DEFAULT);
 	LASSERTF(FID_OID_SPECIAL_BFL == 0x00000001UL, "found 0x%.8xUL\n",
-		(unsigned)FID_OID_SPECIAL_BFL);
+		 (unsigned)FID_OID_SPECIAL_BFL);
 	LASSERTF(FID_OID_DOT_LUSTRE == 0x00000001UL, "found 0x%.8xUL\n",
-		(unsigned)FID_OID_DOT_LUSTRE);
+		 (unsigned)FID_OID_DOT_LUSTRE);
 	LASSERTF(FID_OID_DOT_LUSTRE_OBF == 0x00000002UL, "found 0x%.8xUL\n",
-		(unsigned)FID_OID_DOT_LUSTRE_OBF);
+		 (unsigned)FID_OID_DOT_LUSTRE_OBF);
 
 	/* Checks for struct lu_dirent */
 	LASSERTF((int)sizeof(struct lu_dirent) == 32, "found %lld\n",
@@ -512,11 +512,11 @@ void lustre_assert_wire_constants(void)
 	LASSERTF((int)sizeof(((struct lu_dirent *)0)->lde_name[0]) == 1, "found %lld\n",
 		 (long long)(int)sizeof(((struct lu_dirent *)0)->lde_name[0]));
 	LASSERTF(LUDA_FID == 0x00000001UL, "found 0x%.8xUL\n",
-		(unsigned)LUDA_FID);
+		 (unsigned)LUDA_FID);
 	LASSERTF(LUDA_TYPE == 0x00000002UL, "found 0x%.8xUL\n",
-		(unsigned)LUDA_TYPE);
+		 (unsigned)LUDA_TYPE);
 	LASSERTF(LUDA_64BITHASH == 0x00000004UL, "found 0x%.8xUL\n",
-		(unsigned)LUDA_64BITHASH);
+		 (unsigned)LUDA_64BITHASH);
 
 	/* Checks for struct luda_type */
 	LASSERTF((int)sizeof(struct luda_type) == 2, "found %lld\n",
@@ -604,9 +604,9 @@ void lustre_assert_wire_constants(void)
 	LASSERTF((int)sizeof(((struct lustre_msg_v2 *)0)->lm_buflens[0]) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct lustre_msg_v2 *)0)->lm_buflens[0]));
 	LASSERTF(LUSTRE_MSG_MAGIC_V2 == 0x0BD00BD3, "found 0x%.8x\n",
-		LUSTRE_MSG_MAGIC_V2);
+		 LUSTRE_MSG_MAGIC_V2);
 	LASSERTF(LUSTRE_MSG_MAGIC_V2_SWABBED == 0xD30BD00B, "found 0x%.8x\n",
-		LUSTRE_MSG_MAGIC_V2_SWABBED);
+		 LUSTRE_MSG_MAGIC_V2_SWABBED);
 
 	/* Checks for struct ptlrpc_body */
 	LASSERTF((int)sizeof(struct ptlrpc_body_v3) == 184, "found %lld\n",
@@ -782,61 +782,61 @@ void lustre_assert_wire_constants(void)
 	LASSERTF(MSG_PTLRPC_HEADER_OFF == 31, "found %lld\n",
 		 (long long)MSG_PTLRPC_HEADER_OFF);
 	LASSERTF(PTLRPC_MSG_VERSION == 0x00000003, "found 0x%.8x\n",
-		PTLRPC_MSG_VERSION);
+		 PTLRPC_MSG_VERSION);
 	LASSERTF(LUSTRE_VERSION_MASK == 0xffff0000, "found 0x%.8x\n",
-		LUSTRE_VERSION_MASK);
+		 LUSTRE_VERSION_MASK);
 	LASSERTF(LUSTRE_OBD_VERSION == 0x00010000, "found 0x%.8x\n",
-		LUSTRE_OBD_VERSION);
+		 LUSTRE_OBD_VERSION);
 	LASSERTF(LUSTRE_MDS_VERSION == 0x00020000, "found 0x%.8x\n",
-		LUSTRE_MDS_VERSION);
+		 LUSTRE_MDS_VERSION);
 	LASSERTF(LUSTRE_OST_VERSION == 0x00030000, "found 0x%.8x\n",
-		LUSTRE_OST_VERSION);
+		 LUSTRE_OST_VERSION);
 	LASSERTF(LUSTRE_DLM_VERSION == 0x00040000, "found 0x%.8x\n",
-		LUSTRE_DLM_VERSION);
+		 LUSTRE_DLM_VERSION);
 	LASSERTF(LUSTRE_LOG_VERSION == 0x00050000, "found 0x%.8x\n",
-		LUSTRE_LOG_VERSION);
+		 LUSTRE_LOG_VERSION);
 	LASSERTF(LUSTRE_MGS_VERSION == 0x00060000, "found 0x%.8x\n",
-		LUSTRE_MGS_VERSION);
+		 LUSTRE_MGS_VERSION);
 	LASSERTF(MSGHDR_AT_SUPPORT == 1, "found %lld\n",
 		 (long long)MSGHDR_AT_SUPPORT);
 	LASSERTF(MSGHDR_CKSUM_INCOMPAT18 == 2, "found %lld\n",
 		 (long long)MSGHDR_CKSUM_INCOMPAT18);
 	LASSERTF(MSG_OP_FLAG_MASK == 0xffff0000UL, "found 0x%.8xUL\n",
-		(unsigned)MSG_OP_FLAG_MASK);
+		 (unsigned)MSG_OP_FLAG_MASK);
 	LASSERTF(MSG_OP_FLAG_SHIFT == 16, "found %lld\n",
 		 (long long)MSG_OP_FLAG_SHIFT);
 	LASSERTF(MSG_GEN_FLAG_MASK == 0x0000ffffUL, "found 0x%.8xUL\n",
-		(unsigned)MSG_GEN_FLAG_MASK);
+		 (unsigned)MSG_GEN_FLAG_MASK);
 	LASSERTF(MSG_LAST_REPLAY == 0x00000001UL, "found 0x%.8xUL\n",
-		(unsigned)MSG_LAST_REPLAY);
+		 (unsigned)MSG_LAST_REPLAY);
 	LASSERTF(MSG_RESENT == 0x00000002UL, "found 0x%.8xUL\n",
-		(unsigned)MSG_RESENT);
+		 (unsigned)MSG_RESENT);
 	LASSERTF(MSG_REPLAY == 0x00000004UL, "found 0x%.8xUL\n",
-		(unsigned)MSG_REPLAY);
+		 (unsigned)MSG_REPLAY);
 	LASSERTF(MSG_DELAY_REPLAY == 0x00000010UL, "found 0x%.8xUL\n",
-		(unsigned)MSG_DELAY_REPLAY);
+		 (unsigned)MSG_DELAY_REPLAY);
 	LASSERTF(MSG_VERSION_REPLAY == 0x00000020UL, "found 0x%.8xUL\n",
-		(unsigned)MSG_VERSION_REPLAY);
+		 (unsigned)MSG_VERSION_REPLAY);
 	LASSERTF(MSG_REQ_REPLAY_DONE == 0x00000040UL, "found 0x%.8xUL\n",
-		(unsigned)MSG_REQ_REPLAY_DONE);
+		 (unsigned)MSG_REQ_REPLAY_DONE);
 	LASSERTF(MSG_LOCK_REPLAY_DONE == 0x00000080UL, "found 0x%.8xUL\n",
-		(unsigned)MSG_LOCK_REPLAY_DONE);
+		 (unsigned)MSG_LOCK_REPLAY_DONE);
 	LASSERTF(MSG_CONNECT_RECOVERING == 0x00000001UL, "found 0x%.8xUL\n",
-		(unsigned)MSG_CONNECT_RECOVERING);
+		 (unsigned)MSG_CONNECT_RECOVERING);
 	LASSERTF(MSG_CONNECT_RECONNECT == 0x00000002UL, "found 0x%.8xUL\n",
-		(unsigned)MSG_CONNECT_RECONNECT);
+		 (unsigned)MSG_CONNECT_RECONNECT);
 	LASSERTF(MSG_CONNECT_REPLAYABLE == 0x00000004UL, "found 0x%.8xUL\n",
-		(unsigned)MSG_CONNECT_REPLAYABLE);
+		 (unsigned)MSG_CONNECT_REPLAYABLE);
 	LASSERTF(MSG_CONNECT_LIBCLIENT == 0x00000010UL, "found 0x%.8xUL\n",
-		(unsigned)MSG_CONNECT_LIBCLIENT);
+		 (unsigned)MSG_CONNECT_LIBCLIENT);
 	LASSERTF(MSG_CONNECT_INITIAL == 0x00000020UL, "found 0x%.8xUL\n",
-		(unsigned)MSG_CONNECT_INITIAL);
+		 (unsigned)MSG_CONNECT_INITIAL);
 	LASSERTF(MSG_CONNECT_ASYNC == 0x00000040UL, "found 0x%.8xUL\n",
-		(unsigned)MSG_CONNECT_ASYNC);
+		 (unsigned)MSG_CONNECT_ASYNC);
 	LASSERTF(MSG_CONNECT_NEXT_VER == 0x00000080UL, "found 0x%.8xUL\n",
-		(unsigned)MSG_CONNECT_NEXT_VER);
+		 (unsigned)MSG_CONNECT_NEXT_VER);
 	LASSERTF(MSG_CONNECT_TRANSNO == 0x00000100UL, "found 0x%.8xUL\n",
-		(unsigned)MSG_CONNECT_TRANSNO);
+		 (unsigned)MSG_CONNECT_TRANSNO);
 
 	/* Checks for struct obd_connect_data */
 	LASSERTF((int)sizeof(struct obd_connect_data) == 192, "found %lld\n",
@@ -1078,11 +1078,11 @@ void lustre_assert_wire_constants(void)
 	LASSERTF(OBD_CONNECT_DIR_STRIPE == 0x400000000000000ULL, "found 0x%.16llxULL\n",
 		 OBD_CONNECT_DIR_STRIPE);
 	LASSERTF(OBD_CKSUM_CRC32 == 0x00000001UL, "found 0x%.8xUL\n",
-		(unsigned)OBD_CKSUM_CRC32);
+		 (unsigned)OBD_CKSUM_CRC32);
 	LASSERTF(OBD_CKSUM_ADLER == 0x00000002UL, "found 0x%.8xUL\n",
-		(unsigned)OBD_CKSUM_ADLER);
+		 (unsigned)OBD_CKSUM_ADLER);
 	LASSERTF(OBD_CKSUM_CRC32C == 0x00000004UL, "found 0x%.8xUL\n",
-		(unsigned)OBD_CKSUM_CRC32C);
+		 (unsigned)OBD_CKSUM_CRC32C);
 
 	/* Checks for struct obdo */
 	LASSERTF((int)sizeof(struct obdo) == 208, "found %lld\n",
@@ -1394,13 +1394,13 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)sizeof(((struct lov_mds_md_v3 *)0)->lmm_objects[0]));
 	CLASSERT(LOV_MAGIC_V3 == (0x0BD30000 | 0x0BD0));
 	LASSERTF(LOV_PATTERN_RAID0 == 0x00000001UL, "found 0x%.8xUL\n",
-		(unsigned)LOV_PATTERN_RAID0);
+		 (unsigned)LOV_PATTERN_RAID0);
 	LASSERTF(LOV_PATTERN_RAID1 == 0x00000002UL, "found 0x%.8xUL\n",
-		(unsigned)LOV_PATTERN_RAID1);
+		 (unsigned)LOV_PATTERN_RAID1);
 	LASSERTF(LOV_PATTERN_FIRST == 0x00000100UL, "found 0x%.8xUL\n",
-		(unsigned)LOV_PATTERN_FIRST);
+		 (unsigned)LOV_PATTERN_FIRST);
 	LASSERTF(LOV_PATTERN_CMOBD == 0x00000200UL, "found 0x%.8xUL\n",
-		(unsigned)LOV_PATTERN_CMOBD);
+		 (unsigned)LOV_PATTERN_CMOBD);
 
 	/* Checks for struct lmv_mds_md_v1 */
 	LASSERTF((int)sizeof(struct lmv_mds_md_v1) == 56, "found %lld\n",
@@ -1639,15 +1639,15 @@ void lustre_assert_wire_constants(void)
 	LASSERTF((int)sizeof(((struct obd_dqblk *)0)->dqb_padding) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct obd_dqblk *)0)->dqb_padding));
 	LASSERTF(Q_QUOTACHECK == 0x800100, "found 0x%.8x\n",
-		Q_QUOTACHECK);
+		 Q_QUOTACHECK);
 	LASSERTF(Q_INITQUOTA == 0x800101, "found 0x%.8x\n",
-		Q_INITQUOTA);
+		 Q_INITQUOTA);
 	LASSERTF(Q_GETOINFO == 0x800102, "found 0x%.8x\n",
-		Q_GETOINFO);
+		 Q_GETOINFO);
 	LASSERTF(Q_GETOQUOTA == 0x800103, "found 0x%.8x\n",
-		Q_GETOQUOTA);
+		 Q_GETOQUOTA);
 	LASSERTF(Q_FINVALIDATE == 0x800104, "found 0x%.8x\n",
-		Q_FINVALIDATE);
+		 Q_FINVALIDATE);
 
 	/* Checks for struct niobuf_remote */
 	LASSERTF((int)sizeof(struct niobuf_remote) == 16, "found %lld\n",
@@ -1665,27 +1665,27 @@ void lustre_assert_wire_constants(void)
 	LASSERTF((int)sizeof(((struct niobuf_remote *)0)->flags) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct niobuf_remote *)0)->flags));
 	LASSERTF(OBD_BRW_READ == 0x01, "found 0x%.8x\n",
-		OBD_BRW_READ);
+		 OBD_BRW_READ);
 	LASSERTF(OBD_BRW_WRITE == 0x02, "found 0x%.8x\n",
-		OBD_BRW_WRITE);
+		 OBD_BRW_WRITE);
 	LASSERTF(OBD_BRW_SYNC == 0x08, "found 0x%.8x\n",
-		OBD_BRW_SYNC);
+		 OBD_BRW_SYNC);
 	LASSERTF(OBD_BRW_CHECK == 0x10, "found 0x%.8x\n",
-		OBD_BRW_CHECK);
+		 OBD_BRW_CHECK);
 	LASSERTF(OBD_BRW_FROM_GRANT == 0x20, "found 0x%.8x\n",
-		OBD_BRW_FROM_GRANT);
+		 OBD_BRW_FROM_GRANT);
 	LASSERTF(OBD_BRW_GRANTED == 0x40, "found 0x%.8x\n",
-		OBD_BRW_GRANTED);
+		 OBD_BRW_GRANTED);
 	LASSERTF(OBD_BRW_NOCACHE == 0x80, "found 0x%.8x\n",
-		OBD_BRW_NOCACHE);
+		 OBD_BRW_NOCACHE);
 	LASSERTF(OBD_BRW_NOQUOTA == 0x100, "found 0x%.8x\n",
-		OBD_BRW_NOQUOTA);
+		 OBD_BRW_NOQUOTA);
 	LASSERTF(OBD_BRW_SRVLOCK == 0x200, "found 0x%.8x\n",
-		OBD_BRW_SRVLOCK);
+		 OBD_BRW_SRVLOCK);
 	LASSERTF(OBD_BRW_ASYNC == 0x400, "found 0x%.8x\n",
-		OBD_BRW_ASYNC);
+		 OBD_BRW_ASYNC);
 	LASSERTF(OBD_BRW_MEMALLOC == 0x800, "found 0x%.8x\n",
-		OBD_BRW_MEMALLOC);
+		 OBD_BRW_MEMALLOC);
 	LASSERTF(OBD_BRW_OVER_USRQUOTA == 0x1000, "found 0x%.8x\n",
 		 OBD_BRW_OVER_USRQUOTA);
 	LASSERTF(OBD_BRW_OVER_GRPQUOTA == 0x2000, "found 0x%.8x\n",
@@ -1854,69 +1854,69 @@ void lustre_assert_wire_constants(void)
 	LASSERTF((int)sizeof(((struct mdt_body *)0)->mbo_padding_10) == 8, "found %lld\n",
 		 (long long)(int)sizeof(((struct mdt_body *)0)->mbo_padding_10));
 	LASSERTF(MDS_FMODE_CLOSED == 000000000000UL, "found 0%.11oUL\n",
-		MDS_FMODE_CLOSED);
+		 MDS_FMODE_CLOSED);
 	LASSERTF(MDS_FMODE_EXEC == 000000000004UL, "found 0%.11oUL\n",
-		MDS_FMODE_EXEC);
+		 MDS_FMODE_EXEC);
 	LASSERTF(MDS_FMODE_EPOCH == 000001000000UL, "found 0%.11oUL\n",
-		MDS_FMODE_EPOCH);
+		 MDS_FMODE_EPOCH);
 	LASSERTF(MDS_FMODE_TRUNC == 000002000000UL, "found 0%.11oUL\n",
-		MDS_FMODE_TRUNC);
+		 MDS_FMODE_TRUNC);
 	LASSERTF(MDS_FMODE_SOM == 000004000000UL, "found 0%.11oUL\n",
-		MDS_FMODE_SOM);
+		 MDS_FMODE_SOM);
 	LASSERTF(MDS_OPEN_CREATED == 000000000010UL, "found 0%.11oUL\n",
-		MDS_OPEN_CREATED);
+		 MDS_OPEN_CREATED);
 	LASSERTF(MDS_OPEN_CROSS == 000000000020UL, "found 0%.11oUL\n",
-		MDS_OPEN_CROSS);
+		 MDS_OPEN_CROSS);
 	LASSERTF(MDS_OPEN_CREAT == 000000000100UL, "found 0%.11oUL\n",
-		MDS_OPEN_CREAT);
+		 MDS_OPEN_CREAT);
 	LASSERTF(MDS_OPEN_EXCL == 000000000200UL, "found 0%.11oUL\n",
-		MDS_OPEN_EXCL);
+		 MDS_OPEN_EXCL);
 	LASSERTF(MDS_OPEN_TRUNC == 000000001000UL, "found 0%.11oUL\n",
-		MDS_OPEN_TRUNC);
+		 MDS_OPEN_TRUNC);
 	LASSERTF(MDS_OPEN_APPEND == 000000002000UL, "found 0%.11oUL\n",
-		MDS_OPEN_APPEND);
+		 MDS_OPEN_APPEND);
 	LASSERTF(MDS_OPEN_SYNC == 000000010000UL, "found 0%.11oUL\n",
-		MDS_OPEN_SYNC);
+		 MDS_OPEN_SYNC);
 	LASSERTF(MDS_OPEN_DIRECTORY == 000000200000UL, "found 0%.11oUL\n",
-		MDS_OPEN_DIRECTORY);
+		 MDS_OPEN_DIRECTORY);
 	LASSERTF(MDS_OPEN_BY_FID == 000040000000UL, "found 0%.11oUL\n",
-		MDS_OPEN_BY_FID);
+		 MDS_OPEN_BY_FID);
 	LASSERTF(MDS_OPEN_DELAY_CREATE == 000100000000UL, "found 0%.11oUL\n",
-		MDS_OPEN_DELAY_CREATE);
+		 MDS_OPEN_DELAY_CREATE);
 	LASSERTF(MDS_OPEN_OWNEROVERRIDE == 000200000000UL, "found 0%.11oUL\n",
-		MDS_OPEN_OWNEROVERRIDE);
+		 MDS_OPEN_OWNEROVERRIDE);
 	LASSERTF(MDS_OPEN_JOIN_FILE == 000400000000UL, "found 0%.11oUL\n",
-		MDS_OPEN_JOIN_FILE);
+		 MDS_OPEN_JOIN_FILE);
 	LASSERTF(MDS_OPEN_LOCK == 004000000000UL, "found 0%.11oUL\n",
-		MDS_OPEN_LOCK);
+		 MDS_OPEN_LOCK);
 	LASSERTF(MDS_OPEN_HAS_EA == 010000000000UL, "found 0%.11oUL\n",
-		MDS_OPEN_HAS_EA);
+		 MDS_OPEN_HAS_EA);
 	LASSERTF(MDS_OPEN_HAS_OBJS == 020000000000UL, "found 0%.11oUL\n",
-		MDS_OPEN_HAS_OBJS);
+		 MDS_OPEN_HAS_OBJS);
 	LASSERTF(MDS_OPEN_NORESTORE == 00000000000100000000000ULL, "found 0%.22lloULL\n",
-			(long long)MDS_OPEN_NORESTORE);
+		 (long long)MDS_OPEN_NORESTORE);
 	LASSERTF(MDS_OPEN_NEWSTRIPE == 00000000000200000000000ULL, "found 0%.22lloULL\n",
-			(long long)MDS_OPEN_NEWSTRIPE);
+		 (long long)MDS_OPEN_NEWSTRIPE);
 	LASSERTF(MDS_OPEN_VOLATILE == 00000000000400000000000ULL, "found 0%.22lloULL\n",
-			(long long)MDS_OPEN_VOLATILE);
+		 (long long)MDS_OPEN_VOLATILE);
 	LASSERTF(LUSTRE_SYNC_FL == 0x00000008, "found 0x%.8x\n",
-		LUSTRE_SYNC_FL);
+		 LUSTRE_SYNC_FL);
 	LASSERTF(LUSTRE_IMMUTABLE_FL == 0x00000010, "found 0x%.8x\n",
-		LUSTRE_IMMUTABLE_FL);
+		 LUSTRE_IMMUTABLE_FL);
 	LASSERTF(LUSTRE_APPEND_FL == 0x00000020, "found 0x%.8x\n",
-		LUSTRE_APPEND_FL);
+		 LUSTRE_APPEND_FL);
 	LASSERTF(LUSTRE_NOATIME_FL == 0x00000080, "found 0x%.8x\n",
-		LUSTRE_NOATIME_FL);
+		 LUSTRE_NOATIME_FL);
 	LASSERTF(LUSTRE_DIRSYNC_FL == 0x00010000, "found 0x%.8x\n",
-		LUSTRE_DIRSYNC_FL);
+		 LUSTRE_DIRSYNC_FL);
 	LASSERTF(MDS_INODELOCK_LOOKUP == 0x000001, "found 0x%.8x\n",
-		MDS_INODELOCK_LOOKUP);
+		 MDS_INODELOCK_LOOKUP);
 	LASSERTF(MDS_INODELOCK_UPDATE == 0x000002, "found 0x%.8x\n",
-		MDS_INODELOCK_UPDATE);
+		 MDS_INODELOCK_UPDATE);
 	LASSERTF(MDS_INODELOCK_OPEN == 0x000004, "found 0x%.8x\n",
-		MDS_INODELOCK_OPEN);
+		 MDS_INODELOCK_OPEN);
 	LASSERTF(MDS_INODELOCK_LAYOUT == 0x000008, "found 0x%.8x\n",
-		MDS_INODELOCK_LAYOUT);
+		 MDS_INODELOCK_LAYOUT);
 
 	/* Checks for struct mdt_ioepoch */
 	LASSERTF((int)sizeof(struct mdt_ioepoch) == 24, "found %lld\n",
@@ -3984,9 +3984,9 @@ void lustre_assert_wire_constants(void)
 	LASSERTF((int)sizeof(((struct hsm_progress *)0)->padding) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct hsm_progress *)0)->padding));
 	LASSERTF(HP_FLAG_COMPLETED == 0x01, "found 0x%.8x\n",
-		HP_FLAG_COMPLETED);
+		 HP_FLAG_COMPLETED);
 	LASSERTF(HP_FLAG_RETRY == 0x02, "found 0x%.8x\n",
-		HP_FLAG_RETRY);
+		 HP_FLAG_RETRY);
 
 	LASSERTF((int)offsetof(struct hsm_copy, hc_data_version) == 0, "found %lld\n",
 		 (long long)(int)offsetof(struct hsm_copy, hc_data_version));
@@ -4141,9 +4141,9 @@ void lustre_assert_wire_constants(void)
 	LASSERTF((int)sizeof(((struct hsm_request *)0)->hr_data_len) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct hsm_request *)0)->hr_data_len));
 	LASSERTF(HSM_FORCE_ACTION == 0x00000001UL, "found 0x%.8xUL\n",
-		(unsigned)HSM_FORCE_ACTION);
+		 (unsigned)HSM_FORCE_ACTION);
 	LASSERTF(HSM_GHOST_COPY == 0x00000002UL, "found 0x%.8xUL\n",
-		(unsigned)HSM_GHOST_COPY);
+		 (unsigned)HSM_GHOST_COPY);
 
 	/* Checks for struct hsm_user_request */
 	LASSERTF((int)sizeof(struct hsm_user_request) == 24, "found %lld\n",
-- 
2.7.4
