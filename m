Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 44AE9C77B70
	for <lustre-devel@archiver.kernel.org>; Mon, 17 Apr 2023 14:07:50 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Q0T5G5DZ8z215b;
	Mon, 17 Apr 2023 06:52:34 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Q0T2p2FRyz21JT
 for <lustre-devel@lists.lustre.org>; Mon, 17 Apr 2023 06:50:26 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id C158B100849B;
 Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id C00BA372; Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 17 Apr 2023 09:47:21 -0400
Message-Id: <1681739243-29375-26-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
References: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 25/27] lustre: statahead: batched statahead
 processing
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Qian Yingjin <qian@ddn.com>

Batched metadata processing can get a big performance boost.
In this patch, it implements a batched statahead mechanism which
can also increase the performance for a directory traverse or
listing such as the command 'ls'.

For the batched statahead, one batch getattr() RPC equals to
'N' normal lookup/getattr RPCs. It can pack a number of dentry
name getting from the readdir() call and prepared lock handles
one client side lock namespace into one large batched RPC
transferring via bulk I/O to obtain ibits DLM locks and
associated attributes for a lot of files in one blow.
When MDS receives a batched getattr() RPC, it executes the sub
requests in it one by one serially.

A tunable parameter named "statahead_batch_max" is defined, it
means the maximal items can be batched and processed within one
aggregate RPC. Once the number of sub requests exceeds this
predefined limit, it will pack and trigger the batched RPC.
The batched RPC will also be triggered explicitly when the
readdir() call comes to the end position of the directory or
the statahead thread exits abnormally.

Batched metadata processing can get a big performance boost.
The mdtest performance results without/with this patch series are
as follow:
mdtest-easy-stat      720.562369 kIOPS : time 118.695 seconds
mdtest-easy-stat     1218.290192 kIOPS : time 70.656 seconds

In this patch, we set statahead_batch_max=0 and disabled batched
statahead by default. It will enable accordingly once some
subsequent fixes about batched RPC have been merged.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14139
Lustre-commit: 4435d0121f72aac3ad ("LU-14139 statahead: batched statahead processing")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/40720
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_dlm.h        |  10 ++-
 fs/lustre/include/lustre_req_layout.h |   7 ++
 fs/lustre/include/obd.h               |   2 +
 fs/lustre/ldlm/ldlm_request.c         |  80 ++++++++++++++---
 fs/lustre/llite/llite_internal.h      |  18 +++-
 fs/lustre/llite/llite_lib.c           |   4 +-
 fs/lustre/llite/lproc_llite.c         |  47 ++++++++--
 fs/lustre/llite/statahead.c           |  98 +++++++++++++++++---
 fs/lustre/lmv/lmv_obd.c               |  27 ++++++
 fs/lustre/mdc/mdc_batch.c             | 163 +++++++++++++++++++++++++++++++++-
 fs/lustre/mdc/mdc_dev.c               |   4 +-
 fs/lustre/mdc/mdc_internal.h          |   6 ++
 fs/lustre/mdc/mdc_locks.c             |  24 ++---
 fs/lustre/osc/osc_request.c           |   5 +-
 fs/lustre/ptlrpc/layout.c             |  40 +++++++++
 15 files changed, 485 insertions(+), 50 deletions(-)

diff --git a/fs/lustre/include/lustre_dlm.h b/fs/lustre/include/lustre_dlm.h
index d08c48f..a3a339f 100644
--- a/fs/lustre/include/lustre_dlm.h
+++ b/fs/lustre/include/lustre_dlm.h
@@ -1342,11 +1342,19 @@ int ldlm_prep_elc_req(struct obd_export *exp,
 		      struct list_head *cancels, int count);
 
 struct ptlrpc_request *ldlm_enqueue_pack(struct obd_export *exp, int lvb_len);
-int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
+int ldlm_cli_enqueue_fini(struct obd_export *exp, struct req_capsule *pill,
 			  struct ldlm_enqueue_info *einfo, u8 with_policy,
 			  u64 *flags, void *lvb, u32 lvb_len,
 			  const struct lustre_handle *lockh, int rc,
 			  bool request_slot);
+int ldlm_cli_lock_create_pack(struct obd_export *exp,
+			      struct ldlm_request *dlmreq,
+			      struct ldlm_enqueue_info *einfo,
+			      const struct ldlm_res_id *res_id,
+			      union ldlm_policy_data const *policy,
+			      u64 *flags, void *lvb, u32 lvb_len,
+			      enum lvb_type lvb_type,
+			      struct lustre_handle *lockh);
 int ldlm_cli_convert_req(struct ldlm_lock *lock, u32 *flags, u64 new_bits);
 int ldlm_cli_convert(struct ldlm_lock *lock,
 		     enum ldlm_cancel_flags cancel_flags);
diff --git a/fs/lustre/include/lustre_req_layout.h b/fs/lustre/include/lustre_req_layout.h
index a7ed89b..505e9a1 100644
--- a/fs/lustre/include/lustre_req_layout.h
+++ b/fs/lustre/include/lustre_req_layout.h
@@ -80,6 +80,12 @@ void req_capsule_init(struct req_capsule *pill, struct ptlrpc_request *req,
 void req_capsule_fini(struct req_capsule *pill);
 
 void req_capsule_set(struct req_capsule *pill, const struct req_format *fmt);
+void req_capsule_subreq_init(struct req_capsule *pill,
+			     const struct req_format *fmt,
+			     struct ptlrpc_request *req,
+			     struct lustre_msg *reqmsg,
+			     struct lustre_msg *repmsg,
+			     enum req_location loc);
 size_t req_capsule_filled_sizes(struct req_capsule *pill,
 				enum req_location loc);
 int req_capsule_server_pack(struct req_capsule *pill);
@@ -282,6 +288,7 @@ static inline void req_capsule_set_rep_swabbed(struct req_capsule *pill,
 extern struct req_format RQF_CONNECT;
 
 /* Batch UpdaTe req_format */
+extern struct req_format RQF_BUT_GETATTR;
 extern struct req_format RQF_MDS_BATCH;
 
 /* Batch UpdaTe format */
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index bd167ac..4d65775 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -852,6 +852,8 @@ struct md_op_item {
 	struct inode			*mop_dir;
 	struct req_capsule		*mop_pill;
 	struct work_struct		 mop_work;
+	u64				 mop_lock_flags;
+	unsigned int			 mop_subpill_allocated:1;
 };
 
 enum lu_batch_flags {
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 11071d9..57cf1c0 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -369,7 +369,7 @@ static bool ldlm_request_slot_needed(struct ldlm_enqueue_info *einfo)
  *
  * Called after receiving reply from server.
  */
-int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
+int ldlm_cli_enqueue_fini(struct obd_export *exp, struct req_capsule *pill,
 			  struct ldlm_enqueue_info *einfo,
 			  u8 with_policy, u64 *ldlm_flags, void *lvb,
 			  u32 lvb_len, const struct lustre_handle *lockh,
@@ -382,10 +382,17 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 	struct ldlm_reply *reply;
 	int cleanup_phase = 1;
 
-	if (request_slot)
-		obd_put_request_slot(&req->rq_import->imp_obd->u.cli);
+	if (req_capsule_ptlreq(pill)) {
+		struct ptlrpc_request *req = pill->rc_req;
 
-	ptlrpc_put_mod_rpc_slot(req);
+		if (request_slot)
+			obd_put_request_slot(&req->rq_import->imp_obd->u.cli);
+
+		ptlrpc_put_mod_rpc_slot(req);
+
+		if (req && req->rq_svc_thread)
+			env = req->rq_svc_thread->t_env;
+	}
 
 	lock = ldlm_handle2lock(lockh);
 	/* ldlm_cli_enqueue is holding a reference on this lock. */
@@ -407,7 +414,7 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 	}
 
 	/* Before we return, swab the reply */
-	reply = req_capsule_server_get(&req->rq_pill, &RMF_DLM_REP);
+	reply = req_capsule_server_get(pill, &RMF_DLM_REP);
 	if (!reply) {
 		rc = -EPROTO;
 		goto cleanup;
@@ -416,8 +423,7 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 	if (lvb_len > 0) {
 		int size = 0;
 
-		size = req_capsule_get_size(&req->rq_pill, &RMF_DLM_LVB,
-					    RCL_SERVER);
+		size = req_capsule_get_size(pill, &RMF_DLM_LVB, RCL_SERVER);
 		if (size < 0) {
 			LDLM_ERROR(lock, "Fail to get lvb_len, rc = %d", size);
 			rc = size;
@@ -434,7 +440,7 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 
 	if (rc == ELDLM_LOCK_ABORTED) {
 		if (lvb_len > 0 && lvb)
-			rc = ldlm_fill_lvb(lock, &req->rq_pill, RCL_SERVER,
+			rc = ldlm_fill_lvb(lock, pill, RCL_SERVER,
 					   lvb, lvb_len);
 		if (rc == 0)
 			rc = ELDLM_LOCK_ABORTED;
@@ -520,7 +526,7 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
 		 */
 		lock_res_and_lock(lock);
 		if (!ldlm_is_granted(lock))
-			rc = ldlm_fill_lvb(lock, &req->rq_pill, RCL_SERVER,
+			rc = ldlm_fill_lvb(lock, pill, RCL_SERVER,
 					   lock->l_lvb_data, lvb_len);
 		unlock_res_and_lock(lock);
 		if (rc < 0) {
@@ -857,8 +863,9 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 
 	rc = ptlrpc_queue_wait(req);
 
-	err = ldlm_cli_enqueue_fini(exp, req, einfo, policy ? 1 : 0, flags,
-				    lvb, lvb_len, lockh, rc, need_req_slot);
+	err = ldlm_cli_enqueue_fini(exp, &req->rq_pill, einfo, policy ? 1 : 0,
+				    flags, lvb, lvb_len, lockh, rc,
+				    need_req_slot);
 
 	/*
 	 * If ldlm_cli_enqueue_fini did not find the lock, we need to free
@@ -880,6 +887,57 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 EXPORT_SYMBOL(ldlm_cli_enqueue);
 
 /**
+ * Client-side IBITS lock create and pack for WBC EX lock request.
+ */
+int ldlm_cli_lock_create_pack(struct obd_export *exp,
+			      struct ldlm_request *dlmreq,
+			      struct ldlm_enqueue_info *einfo,
+			      const struct ldlm_res_id *res_id,
+			      union ldlm_policy_data const *policy,
+			      u64 *flags, void *lvb, u32 lvb_len,
+			      enum lvb_type lvb_type,
+			      struct lustre_handle *lockh)
+{
+	const struct ldlm_callback_suite cbs = {
+		.lcs_completion	= einfo->ei_cb_cp,
+		.lcs_blocking	= einfo->ei_cb_bl,
+		.lcs_glimpse	= einfo->ei_cb_gl
+	};
+	struct ldlm_namespace *ns;
+	struct ldlm_lock *lock;
+
+	LASSERT(exp);
+	LASSERT(!(*flags & LDLM_FL_REPLAY));
+
+	ns = exp->exp_obd->obd_namespace;
+	lock = ldlm_lock_create(ns, res_id, einfo->ei_type, einfo->ei_mode,
+				&cbs, einfo->ei_cbdata, lvb_len, lvb_type);
+	if (IS_ERR(lock))
+		return PTR_ERR(lock);
+
+	/* For the local lock, add the reference */
+	ldlm_lock_addref_internal(lock, einfo->ei_mode);
+	ldlm_lock2handle(lock, lockh);
+	if (policy)
+		lock->l_policy_data = *policy;
+
+	LDLM_DEBUG(lock, "client-side enqueue START, flags %#llx", *flags);
+	lock->l_conn_export = exp;
+	lock->l_export = NULL;
+	lock->l_blocking_ast = einfo->ei_cb_bl;
+	lock->l_flags |= (*flags & (LDLM_FL_NO_LRU | LDLM_FL_EXCL |
+				    LDLM_FL_ATOMIC_CB));
+	lock->l_activity = ktime_get_real_seconds();
+
+	ldlm_lock2desc(lock, &dlmreq->lock_desc);
+	dlmreq->lock_flags = ldlm_flags_to_wire(*flags);
+	dlmreq->lock_handle[0] = *lockh;
+
+	return 0;
+}
+EXPORT_SYMBOL(ldlm_cli_lock_create_pack);
+
+/**
  * Client-side IBITS lock convert.
  *
  * Inform server that lock has been converted instead of canceling.
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 129c817..6088da08 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -792,6 +792,9 @@ struct ll_sb_info {
 	unsigned int		ll_sa_running_max; /* max concurrent
 						    * statahead instances
 						    */
+	unsigned int		ll_sa_batch_max;/* max SUB request count in
+						 * a batch PTLRPC request
+						 */
 	unsigned int		ll_sa_max;	/* max statahead RPCs */
 	atomic_t		ll_sa_total;	/* statahead thread started
 						 * count
@@ -1520,9 +1523,10 @@ enum ras_update_flags {
 void ll_ra_stats_inc(struct inode *inode, enum ra_stat which);
 
 /* statahead.c */
-#define LL_SA_RPC_MIN	   2
-#define LL_SA_RPC_DEF	   32
-#define LL_SA_RPC_MAX		512
+
+#define LL_SA_RPC_MIN		8
+#define LL_SA_RPC_DEF		32
+#define LL_SA_RPC_MAX		2048
 
 /* XXX: If want to support more concurrent statahead instances,
  *	please consider to decentralize the RPC lists attached
@@ -1532,7 +1536,10 @@ enum ras_update_flags {
 #define LL_SA_RUNNING_MAX	256
 #define LL_SA_RUNNING_DEF	16
 
-#define LL_SA_CACHE_BIT	 5
+#define LL_SA_BATCH_MAX		1024
+#define LL_SA_BATCH_DEF		0
+
+#define LL_SA_CACHE_BIT		5
 #define LL_SA_CACHE_SIZE	BIT(LL_SA_CACHE_BIT)
 #define LL_SA_CACHE_MASK	(LL_SA_CACHE_SIZE - 1)
 
@@ -1576,6 +1583,9 @@ struct ll_statahead_info {
 	struct list_head	sai_cache[LL_SA_CACHE_SIZE];
 	spinlock_t		sai_cache_lock[LL_SA_CACHE_SIZE];
 	atomic_t		sai_cache_count; /* entry count in cache */
+	struct lu_batch		*sai_bh;
+	u32			sai_max_batch_count;
+	u64			sai_index_end;
 };
 
 int ll_revalidate_statahead(struct inode *dir, struct dentry **dentry,
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 002e870..b1bbeb3 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -167,6 +167,7 @@ static struct ll_sb_info *ll_init_sbi(struct lustre_sb_info *lsi)
 
 	/* metadata statahead is enabled by default */
 	sbi->ll_sa_running_max = LL_SA_RUNNING_DEF;
+	sbi->ll_sa_batch_max = LL_SA_BATCH_DEF;
 	sbi->ll_sa_max = LL_SA_RPC_DEF;
 	atomic_set(&sbi->ll_sa_total, 0);
 	atomic_set(&sbi->ll_sa_wrong, 0);
@@ -324,7 +325,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 				   OBD_CONNECT2_GETATTR_PFID |
 				   OBD_CONNECT2_DOM_LVB |
 				   OBD_CONNECT2_REP_MBITS |
-				   OBD_CONNECT2_ATOMIC_OPEN_LOCK;
+				   OBD_CONNECT2_ATOMIC_OPEN_LOCK |
+				   OBD_CONNECT2_BATCH_RPC;
 
 	if (test_bit(LL_SBI_LRU_RESIZE, sbi->ll_flags))
 		data->ocd_connect_flags |= OBD_CONNECT_LRU_RESIZE;
diff --git a/fs/lustre/llite/lproc_llite.c b/fs/lustre/llite/lproc_llite.c
index 8b6c86f..4ea0bb2 100644
--- a/fs/lustre/llite/lproc_llite.c
+++ b/fs/lustre/llite/lproc_llite.c
@@ -768,6 +768,41 @@ static ssize_t statahead_running_max_store(struct kobject *kobj,
 }
 LUSTRE_RW_ATTR(statahead_running_max);
 
+static ssize_t statahead_batch_max_show(struct kobject *kobj,
+					struct attribute *attr,
+					char *buf)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+
+	return snprintf(buf, 16, "%u\n", sbi->ll_sa_batch_max);
+}
+
+static ssize_t statahead_batch_max_store(struct kobject *kobj,
+					 struct attribute *attr,
+					 const char *buffer,
+					 size_t count)
+{
+	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
+					      ll_kset.kobj);
+	unsigned long val;
+	int rc;
+
+	rc = kstrtoul(buffer, 0, &val);
+	if (rc)
+		return rc;
+
+	if (val > LL_SA_BATCH_MAX) {
+		CWARN("%s: statahead_batch_max value %lu limited to maximum %d\n",
+		      sbi->ll_fsname, val, LL_SA_BATCH_MAX);
+		val = LL_SA_BATCH_MAX;
+	}
+
+	sbi->ll_sa_batch_max = val;
+	return count;
+}
+LUSTRE_RW_ATTR(statahead_batch_max);
+
 static ssize_t statahead_max_show(struct kobject *kobj,
 				  struct attribute *attr,
 				  char *buf)
@@ -792,12 +827,13 @@ static ssize_t statahead_max_store(struct kobject *kobj,
 	if (rc)
 		return rc;
 
-	if (val <= LL_SA_RPC_MAX)
-		sbi->ll_sa_max = val;
-	else
-		CERROR("Bad statahead_max value %lu. Valid values are in the range [0, %d]\n",
-		       val, LL_SA_RPC_MAX);
+	if (val > LL_SA_RPC_MAX) {
+		CWARN("%s: statahead_max value %lu limited to maximum %d\n",
+		      sbi->ll_fsname, val, LL_SA_RPC_MAX);
+		val = LL_SA_RPC_MAX;
+	}
 
+	sbi->ll_sa_max = val;
 	return count;
 }
 LUSTRE_RW_ATTR(statahead_max);
@@ -1788,6 +1824,7 @@ struct ldebugfs_vars lprocfs_llite_obd_vars[] = {
 	&lustre_attr_stats_track_ppid.attr,
 	&lustre_attr_stats_track_gid.attr,
 	&lustre_attr_statahead_running_max.attr,
+	&lustre_attr_statahead_batch_max.attr,
 	&lustre_attr_statahead_max.attr,
 	&lustre_attr_statahead_agl.attr,
 	&lustre_attr_lazystatfs.attr,
diff --git a/fs/lustre/llite/statahead.c b/fs/lustre/llite/statahead.c
index 12d8266..59688b4 100644
--- a/fs/lustre/llite/statahead.c
+++ b/fs/lustre/llite/statahead.c
@@ -132,6 +132,21 @@ static inline int sa_sent_full(struct ll_statahead_info *sai)
 	return atomic_read(&sai->sai_cache_count) >= sai->sai_max;
 }
 
+/* Batch metadata handle */
+static inline bool sa_has_batch_handle(struct ll_statahead_info *sai)
+{
+	return sai->sai_bh != NULL;
+}
+
+static inline void ll_statahead_flush_nowait(struct ll_statahead_info *sai)
+{
+	if (sa_has_batch_handle(sai)) {
+		sai->sai_index_end = sai->sai_index - 1;
+		(void) md_batch_flush(ll_i2mdexp(sai->sai_dentry->d_inode),
+				      sai->sai_bh, false);
+	}
+}
+
 static inline int agl_list_empty(struct ll_statahead_info *sai)
 {
 	return list_empty(&sai->sai_agls);
@@ -256,19 +271,35 @@ static void sa_free(struct ll_statahead_info *sai, struct sa_entry *entry)
 
 /* called by scanner after use, sa_entry will be killed */
 static void
-sa_put(struct ll_statahead_info *sai, struct sa_entry *entry)
+sa_put(struct inode *dir, struct ll_statahead_info *sai, struct sa_entry *entry)
 {
+	struct ll_inode_info *lli = ll_i2info(dir);
 	struct sa_entry *tmp, *next;
+	bool wakeup = false;
 
 	if (entry && entry->se_state == SA_ENTRY_SUCC) {
 		struct ll_sb_info *sbi = ll_i2sbi(sai->sai_dentry->d_inode);
 
 		sai->sai_hit++;
 		sai->sai_consecutive_miss = 0;
-		sai->sai_max = min(2 * sai->sai_max, sbi->ll_sa_max);
+		if (sai->sai_max < sbi->ll_sa_max) {
+			sai->sai_max = min(2 * sai->sai_max, sbi->ll_sa_max);
+			wakeup = true;
+		} else if (sai->sai_max_batch_count > 0) {
+			if (sai->sai_max >= sai->sai_max_batch_count &&
+			   (sai->sai_index_end - entry->se_index) %
+			   sai->sai_max_batch_count == 0) {
+				wakeup = true;
+			} else if (entry->se_index == sai->sai_index_end) {
+				wakeup = true;
+			}
+		} else {
+			wakeup = true;
+		}
 	} else {
 		sai->sai_miss++;
 		sai->sai_consecutive_miss++;
+		wakeup = true;
 	}
 
 	if (entry)
@@ -283,6 +314,11 @@ static void sa_free(struct ll_statahead_info *sai, struct sa_entry *entry)
 			break;
 		sa_kill(sai, tmp);
 	}
+
+	spin_lock(&lli->lli_sa_lock);
+	if (wakeup && sai->sai_task)
+		wake_up_process(sai->sai_task);
+	spin_unlock(&lli->lli_sa_lock);
 }
 
 /*
@@ -326,6 +362,9 @@ static void sa_fini_data(struct md_op_item *item)
 		kfree(op_data->op_name);
 	ll_unlock_md_op_lsm(op_data);
 	iput(item->mop_dir);
+	/* make sure it wasn't allocated with kmem_cache_alloc */
+	if (item->mop_subpill_allocated)
+		kfree(item->mop_pill);
 	kfree(item);
 }
 
@@ -356,6 +395,7 @@ static void sa_fini_data(struct md_op_item *item)
 	if (!child)
 		op_data->op_fid2 = entry->se_fid;
 
+	item->mop_opc = MD_OP_GETATTR;
 	item->mop_it.it_op = IT_GETATTR;
 	item->mop_dir = igrab(dir);
 	item->mop_cb = ll_statahead_interpret;
@@ -657,8 +697,12 @@ static void ll_statahead_interpret_work(struct work_struct *work)
 	}
 
 	rc = ll_prep_inode(&child, pill, dir->i_sb, it);
-	if (rc)
+	if (rc) {
+		CERROR("%s: getattr callback for %.*s "DFID": rc = %d\n",
+		       ll_i2sbi(dir)->ll_fsname, entry->se_qstr.len,
+		       entry->se_qstr.name, PFID(&entry->se_fid), rc);
 		goto out;
+	}
 
 	/* If encryption context was returned by MDT, put it in
 	 * inode now to save an extra getxattr.
@@ -782,6 +826,19 @@ static int ll_statahead_interpret(struct md_op_item *item, int rc)
 	return rc;
 }
 
+static inline int sa_getattr(struct inode *dir, struct md_op_item *item)
+{
+	struct ll_statahead_info *sai = ll_i2info(dir)->lli_sai;
+	int rc;
+
+	if (sa_has_batch_handle(sai))
+		rc = md_batch_add(ll_i2mdexp(dir), sai->sai_bh, item);
+	else
+		rc = md_intent_getattr_async(ll_i2mdexp(dir), item);
+
+	return rc;
+}
+
 /* async stat for file not found in dcache */
 static int sa_lookup(struct inode *dir, struct sa_entry *entry)
 {
@@ -792,8 +849,8 @@ static int sa_lookup(struct inode *dir, struct sa_entry *entry)
 	if (IS_ERR(item))
 		return PTR_ERR(item);
 
-	rc = md_intent_getattr_async(ll_i2mdexp(dir), item);
-	if (rc)
+	rc = sa_getattr(dir, item);
+	if (rc < 0)
 		sa_fini_data(item);
 
 	return rc;
@@ -837,7 +894,7 @@ static int sa_revalidate(struct inode *dir, struct sa_entry *entry,
 		return 1;
 	}
 
-	rc = md_intent_getattr_async(ll_i2mdexp(dir), item);
+	rc = sa_getattr(dir, item);
 	if (rc) {
 		entry->se_inode = NULL;
 		iput(inode);
@@ -880,6 +937,9 @@ static void sa_statahead(struct dentry *parent, const char *name, int len,
 		sai->sai_sent++;
 
 	sai->sai_index++;
+
+	if (sa_sent_full(sai))
+		ll_statahead_flush_nowait(sai);
 }
 
 /* async glimpse (agl) thread main function */
@@ -991,6 +1051,7 @@ static int ll_statahead_thread(void *arg)
 	struct ll_sb_info *sbi = ll_i2sbi(dir);
 	struct ll_statahead_info *sai = lli->lli_sai;
 	struct page *page = NULL;
+	struct lu_batch *bh = NULL;
 	u64 pos = 0;
 	int first = 0;
 	int rc = 0;
@@ -999,6 +1060,17 @@ static int ll_statahead_thread(void *arg)
 	CDEBUG(D_READA, "statahead thread starting: sai %p, parent %pd\n",
 	       sai, parent);
 
+	sai->sai_max_batch_count = sbi->ll_sa_batch_max;
+	if (sai->sai_max_batch_count) {
+		bh = md_batch_create(ll_i2mdexp(dir), BATCH_FL_RDONLY,
+				     sai->sai_max_batch_count);
+		if (IS_ERR(bh)) {
+			rc = PTR_ERR(bh);
+			goto out_stop_agl;
+		}
+	}
+
+	sai->sai_bh = bh;
 	op_data = kzalloc(sizeof(*op_data), GFP_NOFS);
 	if (!op_data) {
 		rc = -ENOMEM;
@@ -1164,6 +1236,8 @@ static int ll_statahead_thread(void *arg)
 		spin_unlock(&lli->lli_sa_lock);
 	}
 
+	ll_statahead_flush_nowait(sai);
+
 	/*
 	 * statahead is finished, but statahead entries need to be cached, wait
 	 * for file release closedir() call to stop me.
@@ -1175,6 +1249,12 @@ static int ll_statahead_thread(void *arg)
 	}
 	__set_current_state(TASK_RUNNING);
 out:
+	if (bh) {
+		rc = md_batch_stop(ll_i2mdexp(dir), sai->sai_bh);
+		sai->sai_bh = NULL;
+	}
+
+out_stop_agl:
 	ll_stop_agl(sai);
 
 	/*
@@ -1553,11 +1633,7 @@ static int revalidate_statahead_dentry(struct inode *dir,
 	 */
 	ldd = ll_d2d(*dentryp);
 	ldd->lld_sa_generation = lli->lli_sa_generation;
-	sa_put(sai, entry);
-	spin_lock(&lli->lli_sa_lock);
-	if (sai->sai_task)
-		wake_up_process(sai->sai_task);
-	spin_unlock(&lli->lli_sa_lock);
+	sa_put(dir, sai, entry);
 
 	return rc;
 }
diff --git a/fs/lustre/lmv/lmv_obd.c b/fs/lustre/lmv/lmv_obd.c
index 157498c..54f8673 100644
--- a/fs/lustre/lmv/lmv_obd.c
+++ b/fs/lustre/lmv/lmv_obd.c
@@ -3913,11 +3913,38 @@ static int lmv_batch_flush(struct obd_export *exp, struct lu_batch *bh,
 static inline struct lmv_tgt_desc *
 lmv_batch_locate_tgt(struct lmv_obd *lmv, struct md_op_item *item)
 {
+	struct md_op_data *op_data = &item->mop_data;
 	struct lmv_tgt_desc *tgt;
 
 	switch (item->mop_opc) {
+	case MD_OP_GETATTR:
+		if (fid_is_sane(&op_data->op_fid2)) {
+			struct lmv_tgt_desc *ptgt;
+
+			ptgt = lmv_locate_tgt(lmv, op_data);
+			if (IS_ERR(ptgt)) {
+				tgt = ptgt;
+			} else {
+				tgt = lmv_fid2tgt(lmv, &op_data->op_fid2);
+				if (!IS_ERR(tgt)) {
+					/*
+					 * Remote object needs two RPCs to
+					 * lookup and getattr, considering
+					 * the complexity don't support
+					 * statahead for now.
+					 */
+					if (tgt != ptgt)
+						tgt = ERR_PTR(-EREMOTE);
+				}
+			}
+		} else {
+			tgt = ERR_PTR(-EINVAL);
+		}
+		break;
+
 	default:
 		tgt = ERR_PTR(-EOPNOTSUPP);
+		break;
 	}
 
 	return tgt;
diff --git a/fs/lustre/mdc/mdc_batch.c b/fs/lustre/mdc/mdc_batch.c
index 496d61e3..73f5a8c 100644
--- a/fs/lustre/mdc/mdc_batch.c
+++ b/fs/lustre/mdc/mdc_batch.c
@@ -41,9 +41,163 @@
 
 #include "mdc_internal.h"
 
-static md_update_pack_t mdc_update_packers[MD_OP_MAX];
+static int mdc_ldlm_lock_pack(struct obd_export *exp,
+			      struct req_capsule *pill,
+			      union ldlm_policy_data *policy,
+			      struct lu_fid *fid, struct md_op_item *item)
+{
+	struct ldlm_request *dlmreq;
+	struct ldlm_res_id res_id;
+	struct ldlm_enqueue_info *einfo = &item->mop_einfo;
+
+	dlmreq = req_capsule_client_get(pill, &RMF_DLM_REQ);
+	if (IS_ERR(dlmreq))
+		return PTR_ERR(dlmreq);
+
+	/* With Data-on-MDT the glimpse callback is needed too.
+	 * It is set here in advance but not in mdc_finish_enqueue()
+	 * to avoid possible races. It is safe to have glimpse handler
+	 * for non-DOM locks and costs nothing.
+	 */
+	if (!einfo->ei_cb_gl)
+		einfo->ei_cb_gl = mdc_ldlm_glimpse_ast;
+
+	fid_build_reg_res_name(fid, &res_id);
+
+	return ldlm_cli_lock_create_pack(exp, dlmreq, einfo, &res_id,
+					 policy, &item->mop_lock_flags,
+					 NULL, 0, LVB_T_NONE, &item->mop_lockh);
+}
+
+static int mdc_batch_getattr_pack(struct batch_update_head *head,
+				  struct lustre_msg *reqmsg,
+				  size_t *max_pack_size,
+				  struct md_op_item *item)
+{
+	struct obd_export *exp = head->buh_exp;
+	struct lookup_intent *it = &item->mop_it;
+	struct md_op_data *op_data = &item->mop_data;
+	u64 valid = OBD_MD_FLGETATTR | OBD_MD_FLEASIZE | OBD_MD_FLMODEASIZE |
+		    OBD_MD_FLDIREA | OBD_MD_MEA | OBD_MD_FLACL |
+		    OBD_MD_DEFAULT_MEA;
+	union ldlm_policy_data policy = {
+		.l_inodebits = { MDS_INODELOCK_LOOKUP | MDS_INODELOCK_UPDATE }
+	};
+	struct ldlm_intent *lit;
+	bool have_secctx = false;
+	struct req_capsule pill;
+	u32 easize;
+	u32 size;
+	int rc;
+
+	req_capsule_subreq_init(&pill, &RQF_BUT_GETATTR, NULL,
+				reqmsg, NULL, RCL_CLIENT);
+
+	/* send name of security xattr to get upon intent */
+	if (it->it_op & (IT_LOOKUP | IT_GETATTR) &&
+	    req_capsule_has_field(&pill, &RMF_FILE_SECCTX_NAME,
+				  RCL_CLIENT) &&
+	    op_data->op_file_secctx_name_size > 0 &&
+	    op_data->op_file_secctx_name) {
+		have_secctx = true;
+		req_capsule_set_size(&pill, &RMF_FILE_SECCTX_NAME, RCL_CLIENT,
+				     op_data->op_file_secctx_name_size);
+	}
+
+	req_capsule_set_size(&pill, &RMF_NAME, RCL_CLIENT,
+			     op_data->op_namelen + 1);
+
+	size = req_capsule_msg_size(&pill, RCL_CLIENT);
+	if (unlikely(size >= *max_pack_size)) {
+		*max_pack_size = size;
+		return -E2BIG;
+	}
+
+	req_capsule_client_pack(&pill);
+	/* pack the intent */
+	lit = req_capsule_client_get(&pill, &RMF_LDLM_INTENT);
+	lit->opc = (u64)it->it_op;
+
+	easize = MAX_MD_SIZE_OLD; /* obd->u.cli.cl_default_mds_easize; */
+
+	/* pack the intended request */
+	mdc_getattr_pack(&pill, valid, it->it_flags, op_data, easize);
+
+	item->mop_lock_flags |= LDLM_FL_HAS_INTENT;
+	rc = mdc_ldlm_lock_pack(head->buh_exp, &pill, &policy,
+				&item->mop_data.op_fid1, item);
+	if (rc)
+		return rc;
 
-static object_update_interpret_t mdc_update_interpreters[MD_OP_MAX];
+	req_capsule_set_size(&pill, &RMF_MDT_MD, RCL_SERVER, easize);
+	req_capsule_set_size(&pill, &RMF_ACL, RCL_SERVER,
+			     LUSTRE_POSIX_ACL_MAX_SIZE_OLD);
+	req_capsule_set_size(&pill, &RMF_DEFAULT_MDT_MD, RCL_SERVER,
+			     sizeof(struct lmv_user_md));
+
+	if (have_secctx) {
+		char *secctx_name;
+
+		secctx_name = req_capsule_client_get(&pill,
+						     &RMF_FILE_SECCTX_NAME);
+		memcpy(secctx_name, op_data->op_file_secctx_name,
+		       op_data->op_file_secctx_name_size);
+
+		req_capsule_set_size(&pill, &RMF_FILE_SECCTX,
+				     RCL_SERVER, easize);
+
+		CDEBUG(D_SEC, "packed '%.*s' as security xattr name\n",
+		       op_data->op_file_secctx_name_size,
+		       op_data->op_file_secctx_name);
+	} else {
+		req_capsule_set_size(&pill, &RMF_FILE_SECCTX, RCL_SERVER, 0);
+	}
+
+	if (exp_connect_encrypt(exp) && it->it_op & (IT_LOOKUP | IT_GETATTR))
+		req_capsule_set_size(&pill, &RMF_FILE_ENCCTX,
+				     RCL_SERVER, easize);
+	else
+		req_capsule_set_size(&pill, &RMF_FILE_ENCCTX,
+				     RCL_SERVER, 0);
+
+	req_capsule_set_replen(&pill);
+	reqmsg->lm_opc = BUT_GETATTR;
+	*max_pack_size = size;
+	return rc;
+}
+
+static md_update_pack_t mdc_update_packers[MD_OP_MAX] = {
+	[MD_OP_GETATTR] = mdc_batch_getattr_pack,
+};
+
+static int mdc_batch_getattr_interpret(struct ptlrpc_request *req,
+				       struct lustre_msg *repmsg,
+				       struct object_update_callback *ouc,
+				       int rc)
+{
+	struct md_op_item *item = (struct md_op_item *)ouc->ouc_data;
+	struct ldlm_enqueue_info *einfo = &item->mop_einfo;
+	struct batch_update_head *head = ouc->ouc_head;
+	struct obd_export *exp = head->buh_exp;
+	struct req_capsule *pill = item->mop_pill;
+
+	req_capsule_subreq_init(pill, &RQF_BUT_GETATTR, req,
+				NULL, repmsg, RCL_CLIENT);
+
+	rc = ldlm_cli_enqueue_fini(exp, pill, einfo, 1, &item->mop_lock_flags,
+				   NULL, 0, &item->mop_lockh, rc, false);
+	if (rc)
+		goto out;
+
+	rc = mdc_finish_enqueue(exp, pill, einfo, &item->mop_it,
+				&item->mop_lockh, rc);
+out:
+	return item->mop_cb(item, rc);
+}
+
+object_update_interpret_t mdc_update_interpreters[MD_OP_MAX] = {
+	[MD_OP_GETATTR] = mdc_batch_getattr_interpret,
+};
 
 int mdc_batch_add(struct obd_export *exp, struct lu_batch *bh,
 		  struct md_op_item *item)
@@ -57,6 +211,11 @@ int mdc_batch_add(struct obd_export *exp, struct lu_batch *bh,
 		return -EFAULT;
 	}
 
+	item->mop_pill = kzalloc(sizeof(*item->mop_pill), GFP_NOFS);
+	if (!item->mop_pill)
+		return -ENOMEM;
+
+	item->mop_subpill_allocated = 1;
 	return cli_batch_add(exp, bh, item, mdc_update_packers[opc],
 			     mdc_update_interpreters[opc]);
 }
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index 984d1a8..74911da 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -663,8 +663,8 @@ int mdc_enqueue_interpret(const struct lu_env *env, struct ptlrpc_request *req,
 	OBD_FAIL_TIMEOUT(OBD_FAIL_OSC_CP_ENQ_RACE, 1);
 
 	/* Complete obtaining the lock procedure. */
-	rc = ldlm_cli_enqueue_fini(aa->oa_exp, req, &einfo, 1, aa->oa_flags,
-				   aa->oa_lvb, aa->oa_lvb ?
+	rc = ldlm_cli_enqueue_fini(aa->oa_exp, &req->rq_pill, &einfo, 1,
+				   aa->oa_flags, aa->oa_lvb, aa->oa_lvb ?
 				   sizeof(*aa->oa_lvb) : 0, lockh, rc, true);
 	/* Complete mdc stuff. */
 	rc = mdc_enqueue_fini(aa->oa_exp, req, aa->oa_upcall, aa->oa_cookie,
diff --git a/fs/lustre/mdc/mdc_internal.h b/fs/lustre/mdc/mdc_internal.h
index ae12a37..e752414 100644
--- a/fs/lustre/mdc/mdc_internal.h
+++ b/fs/lustre/mdc/mdc_internal.h
@@ -194,6 +194,12 @@ int mdc_ldlm_blocking_ast(struct ldlm_lock *dlmlock,
 int mdc_ldlm_glimpse_ast(struct ldlm_lock *dlmlock, void *data);
 int mdc_fill_lvb(struct req_capsule *pill, struct ost_lvb *lvb);
 
+int mdc_finish_enqueue(struct obd_export *exp,
+		       struct req_capsule *pill,
+		       struct ldlm_enqueue_info *einfo,
+		       struct lookup_intent *it,
+		       struct lustre_handle *lockh, int rc);
+
 /* the minimum inline repsize should be PAGE_SIZE at least */
 #define MDC_DOM_DEF_INLINE_REPSIZE max(8192UL, PAGE_SIZE)
 #define MDC_DOM_MAX_INLINE_REPSIZE XATTR_SIZE_MAX
diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index f36e0ec..7695c78 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -665,13 +665,13 @@ static struct ptlrpc_request *mdc_enqueue_pack(struct obd_export *exp,
 	return req;
 }
 
-static int mdc_finish_enqueue(struct obd_export *exp,
-			      struct ptlrpc_request *req,
-			      struct ldlm_enqueue_info *einfo,
-			      struct lookup_intent *it,
-			      struct lustre_handle *lockh, int rc)
+int mdc_finish_enqueue(struct obd_export *exp,
+		       struct req_capsule *pill,
+		       struct ldlm_enqueue_info *einfo,
+		       struct lookup_intent *it,
+		       struct lustre_handle *lockh, int rc)
 {
-	struct req_capsule *pill = &req->rq_pill;
+	struct ptlrpc_request *req = pill->rc_req;
 	struct ldlm_request *lockreq;
 	struct ldlm_reply *lockrep;
 	struct ldlm_lock *lock;
@@ -1067,7 +1067,7 @@ int mdc_enqueue_base(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 		goto resend;
 	}
 
-	rc = mdc_finish_enqueue(exp, req, einfo, it, lockh, rc);
+	rc = mdc_finish_enqueue(exp, &req->rq_pill, einfo, it, lockh, rc);
 	if (rc < 0) {
 		if (lustre_handle_is_used(lockh)) {
 			ldlm_lock_decref(lockh, einfo->ei_mode);
@@ -1369,13 +1369,14 @@ static int mdc_intent_getattr_async_interpret(const struct lu_env *env,
 	struct ldlm_enqueue_info *einfo = &item->mop_einfo;
 	struct lookup_intent *it = &item->mop_it;
 	struct lustre_handle *lockh = &item->mop_lockh;
+	struct req_capsule *pill = &req->rq_pill;
 	struct ldlm_reply *lockrep;
 	u64 flags = LDLM_FL_HAS_INTENT;
 
 	if (OBD_FAIL_CHECK(OBD_FAIL_MDC_GETATTR_ENQUEUE))
 		rc = -ETIMEDOUT;
 
-	rc = ldlm_cli_enqueue_fini(exp, req, einfo, 1, &flags, NULL, 0,
+	rc = ldlm_cli_enqueue_fini(exp, pill, einfo, 1, &flags, NULL, 0,
 				   lockh, rc, true);
 	if (rc < 0) {
 		CERROR("%s: ldlm_cli_enqueue_fini() failed: rc = %d\n",
@@ -1384,19 +1385,20 @@ static int mdc_intent_getattr_async_interpret(const struct lu_env *env,
 		goto out;
 	}
 
-	lockrep = req_capsule_server_get(&req->rq_pill, &RMF_DLM_REP);
+	lockrep = req_capsule_server_get(pill, &RMF_DLM_REP);
+	LASSERT(lockrep);
 
 	lockrep->lock_policy_res2 =
 		ptlrpc_status_ntoh(lockrep->lock_policy_res2);
 
-	rc = mdc_finish_enqueue(exp, req, einfo, it, lockh, rc);
+	rc = mdc_finish_enqueue(exp, pill, einfo, it, lockh, rc);
 	if (rc)
 		goto out;
 
 	rc = mdc_finish_intent_lock(exp, req, &item->mop_data, it, lockh);
 
 out:
-	item->mop_pill = &req->rq_pill;
+	item->mop_pill = pill;
 	item->mop_cb(item, rc);
 	return 0;
 }
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 6ea1db6..35dd009 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -2990,8 +2990,9 @@ int osc_enqueue_interpret(const struct lu_env *env, struct ptlrpc_request *req,
 	}
 
 	/* Complete obtaining the lock procedure. */
-	rc = ldlm_cli_enqueue_fini(aa->oa_exp, req, &einfo, 1, aa->oa_flags,
-				   lvb, lvb_len, lockh, rc, false);
+	rc = ldlm_cli_enqueue_fini(aa->oa_exp, &req->rq_pill, &einfo, 1,
+				   aa->oa_flags, lvb, lvb_len, lockh, rc,
+				   false);
 	/* Complete osc stuff. */
 	rc = osc_enqueue_fini(req, aa->oa_upcall, aa->oa_cookie, lockh, mode,
 			      aa->oa_flags, aa->oa_speculative, rc);
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index 0fe74ff..5beebb7 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -722,6 +722,26 @@
 	&RMF_GENERIC_DATA,
 };
 
+static const struct req_msg_field *mds_batch_getattr_client[] = {
+	&RMF_DLM_REQ,
+	&RMF_LDLM_INTENT,
+	&RMF_MDT_BODY,     /* coincides with mds_getattr_name_client[] */
+	&RMF_CAPA1,
+	&RMF_NAME,
+	&RMF_FILE_SECCTX_NAME
+};
+
+static const struct req_msg_field *mds_batch_getattr_server[] = {
+	&RMF_DLM_REP,
+	&RMF_MDT_BODY,
+	&RMF_MDT_MD,
+	&RMF_ACL,
+	&RMF_CAPA1,
+	&RMF_FILE_SECCTX,
+	&RMF_DEFAULT_MDT_MD,
+	&RMF_FILE_ENCCTX,
+};
+
 static struct req_format *req_formats[] = {
 	&RQF_OBD_PING,
 	&RQF_OBD_SET_INFO,
@@ -811,6 +831,7 @@
 	&RQF_LLOG_ORIGIN_HANDLE_PREV_BLOCK,
 	&RQF_LLOG_ORIGIN_HANDLE_READ_HEADER,
 	&RQF_CONNECT,
+	&RQF_BUT_GETATTR,
 	&RQF_MDS_BATCH,
 };
 
@@ -1701,6 +1722,11 @@ struct req_format RQF_OST_LADVISE =
 	DEFINE_REQ_FMT0("OST_LADVISE", ost_ladvise, ost_body_only);
 EXPORT_SYMBOL(RQF_OST_LADVISE);
 
+struct req_format RQF_BUT_GETATTR =
+	DEFINE_REQ_FMT0("MDS_BATCH_GETATTR", mds_batch_getattr_client,
+			mds_batch_getattr_server);
+EXPORT_SYMBOL(RQF_BUT_GETATTR);
+
 /* Convenience macro */
 #define FMT_FIELD(fmt, i, j) ((fmt)->rf_fields[(i)].d[(j)])
 
@@ -2472,6 +2498,20 @@ void req_capsule_shrink(struct req_capsule *pill,
 }
 EXPORT_SYMBOL(req_capsule_shrink);
 
+void req_capsule_subreq_init(struct req_capsule *pill,
+			     const struct req_format *fmt,
+			     struct ptlrpc_request *req,
+			     struct lustre_msg *reqmsg,
+			     struct lustre_msg *repmsg,
+			     enum req_location loc)
+{
+	req_capsule_init(pill, req, loc);
+	req_capsule_set(pill, fmt);
+	pill->rc_reqmsg = reqmsg;
+	pill->rc_repmsg = repmsg;
+}
+EXPORT_SYMBOL(req_capsule_subreq_init);
+
 void req_capsule_set_replen(struct req_capsule *pill)
 {
 	if (req_capsule_ptlreq(pill)) {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
