From: James Simmons <jsimmons@infradead.org>
Date: Thu, 31 Jan 2019 12:19:14 -0500
Subject: [lustre-devel] [PATCH 10/26] ldlm: cleanup white spaces
In-Reply-To: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
References: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1548955170-13456-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The ldlm code is very messy and difficult to read. Remove excess
white space and properly align data structures so they are easy on
the eyes.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_flock.c    |  4 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      | 22 +++---
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     | 36 +++++-----
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    | 28 ++++----
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     |  5 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  | 28 ++++----
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c | 78 +++++++++++-----------
 7 files changed, 99 insertions(+), 102 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
index baa5b3a..4fc380d2 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_flock.c
@@ -314,8 +314,8 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req)
 int
 ldlm_flock_completion_ast(struct ldlm_lock *lock, u64 flags, void *data)
 {
-	struct file_lock		*getlk = lock->l_ast_data;
-	int				rc = 0;
+	struct file_lock *getlk = lock->l_ast_data;
+	int rc = 0;
 
 	OBD_FAIL_TIMEOUT(OBD_FAIL_LDLM_CP_CB_WAIT2, 4);
 	if (OBD_FAIL_PRECHECK(OBD_FAIL_LDLM_CP_CB_WAIT3)) {
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index 5a59c15..aef83ff 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -512,11 +512,11 @@ int client_connect_import(const struct lu_env *env,
 			  struct obd_device *obd, struct obd_uuid *cluuid,
 			  struct obd_connect_data *data, void *localdata)
 {
-	struct client_obd       *cli    = &obd->u.cli;
-	struct obd_import       *imp    = cli->cl_import;
+	struct client_obd *cli = &obd->u.cli;
+	struct obd_import *imp = cli->cl_import;
 	struct obd_connect_data *ocd;
-	struct lustre_handle    conn    = { 0 };
-	int		     rc;
+	struct lustre_handle conn = { 0 };
+	int rc;
 
 	*exp = NULL;
 	down_write(&cli->cl_sem);
@@ -703,9 +703,9 @@ int target_pack_pool_reply(struct ptlrpc_request *req)
 void target_send_reply(struct ptlrpc_request *req, int rc, int fail_id)
 {
 	struct ptlrpc_service_part *svcpt;
-	int			netrc;
+	int netrc;
 	struct ptlrpc_reply_state *rs;
-	struct obd_export	 *exp;
+	struct obd_export *exp;
 
 	if (req->rq_no_reply)
 		return;
@@ -736,11 +736,11 @@ void target_send_reply(struct ptlrpc_request *req, int rc, int fail_id)
 
 	/* disable reply scheduling while I'm setting up */
 	rs->rs_scheduled = 1;
-	rs->rs_on_net    = 1;
-	rs->rs_xid       = req->rq_xid;
-	rs->rs_transno   = req->rq_transno;
-	rs->rs_export    = exp;
-	rs->rs_opc       = lustre_msg_get_opc(req->rq_reqmsg);
+	rs->rs_on_net = 1;
+	rs->rs_xid = req->rq_xid;
+	rs->rs_transno = req->rq_transno;
+	rs->rs_export = exp;
+	rs->rs_opc = lustre_msg_get_opc(req->rq_reqmsg);
 
 	spin_lock(&exp->exp_uncommitted_replies_lock);
 	CDEBUG(D_NET, "rs transno = %llu, last committed = %llu\n",
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index e726e76..cea0e22 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -682,7 +682,7 @@ void ldlm_lock_addref_internal_nolock(struct ldlm_lock *lock,
 int ldlm_lock_addref_try(const struct lustre_handle *lockh, enum ldlm_mode mode)
 {
 	struct ldlm_lock *lock;
-	int	       result;
+	int result;
 
 	result = -EAGAIN;
 	lock = ldlm_handle2lock(lockh);
@@ -1344,7 +1344,7 @@ enum ldlm_mode ldlm_lock_match(struct ldlm_namespace *ns, u64 flags,
 			}
 		}
 	}
- out2:
+out2:
 	if (rc) {
 		LDLM_DEBUG(lock, "matched (%llu %llu)",
 			   (type == LDLM_PLAIN || type == LDLM_IBITS) ?
@@ -1568,8 +1568,6 @@ struct ldlm_lock *ldlm_lock_create(struct ldlm_namespace *ns,
 	return ERR_PTR(rc);
 }
 
-
-
 /**
  * Enqueue (request) a lock.
  * On the client this is called from ldlm_cli_enqueue_fini
@@ -1629,9 +1627,9 @@ enum ldlm_error ldlm_lock_enqueue(struct ldlm_namespace *ns,
 ldlm_work_bl_ast_lock(struct ptlrpc_request_set *rqset, void *opaq)
 {
 	struct ldlm_cb_set_arg *arg = opaq;
-	struct ldlm_lock_desc   d;
-	int		     rc;
-	struct ldlm_lock       *lock;
+	struct ldlm_lock_desc d;
+	int rc;
+	struct ldlm_lock *lock;
 
 	if (list_empty(arg->list))
 		return -ENOENT;
@@ -1664,9 +1662,9 @@ enum ldlm_error ldlm_lock_enqueue(struct ldlm_namespace *ns,
 static int
 ldlm_work_cp_ast_lock(struct ptlrpc_request_set *rqset, void *opaq)
 {
-	struct ldlm_cb_set_arg  *arg = opaq;
-	int		      rc = 0;
-	struct ldlm_lock	*lock;
+	struct ldlm_cb_set_arg *arg = opaq;
+	int rc = 0;
+	struct ldlm_lock *lock;
 	ldlm_completion_callback completion_callback;
 
 	if (list_empty(arg->list))
@@ -1711,9 +1709,9 @@ enum ldlm_error ldlm_lock_enqueue(struct ldlm_namespace *ns,
 ldlm_work_revoke_ast_lock(struct ptlrpc_request_set *rqset, void *opaq)
 {
 	struct ldlm_cb_set_arg *arg = opaq;
-	struct ldlm_lock_desc   desc;
-	int		     rc;
-	struct ldlm_lock       *lock;
+	struct ldlm_lock_desc desc;
+	int rc;
+	struct ldlm_lock *lock;
 
 	if (list_empty(arg->list))
 		return -ENOENT;
@@ -1737,10 +1735,10 @@ enum ldlm_error ldlm_lock_enqueue(struct ldlm_namespace *ns,
  */
 static int ldlm_work_gl_ast_lock(struct ptlrpc_request_set *rqset, void *opaq)
 {
-	struct ldlm_cb_set_arg		*arg = opaq;
-	struct ldlm_glimpse_work	*gl_work;
-	struct ldlm_lock		*lock;
-	int				 rc = 0;
+	struct ldlm_cb_set_arg *arg = opaq;
+	struct ldlm_glimpse_work *gl_work;
+	struct ldlm_lock *lock;
+	int rc = 0;
 
 	if (list_empty(arg->list))
 		return -ENOENT;
@@ -1776,8 +1774,8 @@ int ldlm_run_ast_work(struct ldlm_namespace *ns, struct list_head *rpc_list,
 		      enum ldlm_desc_ast_t ast_type)
 {
 	struct ldlm_cb_set_arg *arg;
-	set_producer_func       work_ast_lock;
-	int		     rc;
+	set_producer_func work_ast_lock;
+	int rc;
 
 	if (list_empty(rpc_list))
 		return 0;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index e766f798..bae67ac 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -77,32 +77,32 @@ struct ldlm_bl_pool {
 	 * as a priority. It is used for LDLM_FL_DISCARD_DATA requests.
 	 * see bug 13843
 	 */
-	struct list_head	      blp_prio_list;
+	struct list_head	blp_prio_list;
 
 	/*
 	 * blp_list is used for all other callbacks which are likely
 	 * to take longer to process.
 	 */
-	struct list_head	      blp_list;
+	struct list_head	blp_list;
 
-	wait_queue_head_t	     blp_waitq;
+	wait_queue_head_t	blp_waitq;
 	struct completion	blp_comp;
-	atomic_t	    blp_num_threads;
-	atomic_t	    blp_busy_threads;
-	int		     blp_min_threads;
-	int		     blp_max_threads;
+	atomic_t		blp_num_threads;
+	atomic_t		blp_busy_threads;
+	int			blp_min_threads;
+	int			blp_max_threads;
 };
 
 struct ldlm_bl_work_item {
-	struct list_head	      blwi_entry;
+	struct list_head	blwi_entry;
 	struct ldlm_namespace  *blwi_ns;
 	struct ldlm_lock_desc   blwi_ld;
 	struct ldlm_lock       *blwi_lock;
-	struct list_head	      blwi_head;
-	int		     blwi_count;
+	struct list_head	blwi_head;
+	int			blwi_count;
 	struct completion	blwi_comp;
-	enum ldlm_cancel_flags  blwi_flags;
-	int		     blwi_mem_pressure;
+	enum ldlm_cancel_flags	blwi_flags;
+	int			blwi_mem_pressure;
 };
 
 /**
@@ -928,8 +928,8 @@ static ssize_t cancel_unused_locks_before_replay_store(struct kobject *kobj,
 
 static int ldlm_setup(void)
 {
-	static struct ptlrpc_service_conf	conf;
-	struct ldlm_bl_pool			*blp = NULL;
+	static struct ptlrpc_service_conf conf;
+	struct ldlm_bl_pool *blp = NULL;
 	int rc = 0;
 	int i;
 
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
index e94d8a3..5b23767f 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
@@ -465,8 +465,7 @@ static ssize_t grant_speed_show(struct kobject *kobj, struct attribute *attr,
 {
 	struct ldlm_pool *pl = container_of(kobj, struct ldlm_pool,
 					    pl_kobj);
-
-	int	       grant_speed;
+	int grant_speed;
 
 	spin_lock(&pl->pl_lock);
 	/* serialize with ldlm_pool_recalc */
@@ -902,7 +901,7 @@ static void ldlm_pools_recalc(struct work_struct *ws)
 	 * Recalc at least ldlm_namespace_nr_read(client) namespaces.
 	 */
 	for (nr = ldlm_namespace_nr_read(client); nr > 0; nr--) {
-		int     skip;
+		int skip;
 		/*
 		 * Lock the list, get first @ns in the list, getref, move it
 		 * to the tail, unlock and call pool recalc. This way we avoid
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index a7fe8c6..b819ade 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -565,9 +565,9 @@ int ldlm_prep_elc_req(struct obd_export *exp, struct ptlrpc_request *req,
 		      int version, int opc, int canceloff,
 		      struct list_head *cancels, int count)
 {
-	struct ldlm_namespace   *ns = exp->exp_obd->obd_namespace;
-	struct req_capsule      *pill = &req->rq_pill;
-	struct ldlm_request     *dlm = NULL;
+	struct ldlm_namespace *ns = exp->exp_obd->obd_namespace;
+	struct req_capsule *pill = &req->rq_pill;
+	struct ldlm_request *dlm = NULL;
 	int flags, avail, to_free, pack = 0;
 	LIST_HEAD(head);
 	int rc;
@@ -675,11 +675,11 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 		     struct lustre_handle *lockh, int async)
 {
 	struct ldlm_namespace *ns;
-	struct ldlm_lock      *lock;
-	struct ldlm_request   *body;
-	int		    is_replay = *flags & LDLM_FL_REPLAY;
-	int		    req_passed_in = 1;
-	int		    rc, err;
+	struct ldlm_lock *lock;
+	struct ldlm_request *body;
+	int is_replay = *flags & LDLM_FL_REPLAY;
+	int req_passed_in = 1;
+	int rc, err;
 	struct ptlrpc_request *req;
 
 	ns = exp->exp_obd->obd_namespace;
@@ -1718,8 +1718,8 @@ static int ldlm_cli_hash_cancel_unused(struct cfs_hash *hs,
 				       struct cfs_hash_bd *bd,
 				       struct hlist_node *hnode, void *arg)
 {
-	struct ldlm_resource	   *res = cfs_hash_object(hs, hnode);
-	struct ldlm_cli_cancel_arg     *lc = arg;
+	struct ldlm_resource *res = cfs_hash_object(hs, hnode);
+	struct ldlm_cli_cancel_arg *lc = arg;
 
 	ldlm_cli_cancel_unused_resource(ldlm_res_to_ns(res), &res->lr_name,
 					NULL, LCK_MINMODE,
@@ -1878,9 +1878,9 @@ static int replay_lock_interpret(const struct lu_env *env,
 				 struct ptlrpc_request *req,
 				 struct ldlm_async_args *aa, int rc)
 {
-	struct ldlm_lock     *lock;
-	struct ldlm_reply    *reply;
-	struct obd_export    *exp;
+	struct ldlm_lock *lock;
+	struct ldlm_reply *reply;
+	struct obd_export *exp;
 
 	atomic_dec(&req->rq_import->imp_replay_inflight);
 	if (rc != ELDLM_OK)
@@ -1920,7 +1920,7 @@ static int replay_one_lock(struct obd_import *imp, struct ldlm_lock *lock)
 {
 	struct ptlrpc_request *req;
 	struct ldlm_async_args *aa;
-	struct ldlm_request   *body;
+	struct ldlm_request *body;
 	int flags;
 
 	/* Bug 11974: Do not replay a lock which is actively being canceled */
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index e0b9918..85c5047 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -132,9 +132,9 @@ static ssize_t resource_count_show(struct kobject *kobj, struct attribute *attr,
 {
 	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
 						 ns_kobj);
-	u64		  res = 0;
-	struct cfs_hash_bd	  bd;
-	int		    i;
+	u64 res = 0;
+	struct cfs_hash_bd bd;
+	int i;
 
 	/* result is not strictly consistent */
 	cfs_hash_for_each_bucket(ns->ns_rs_hash, &bd, i)
@@ -148,7 +148,7 @@ static ssize_t lock_count_show(struct kobject *kobj, struct attribute *attr,
 {
 	struct ldlm_namespace *ns = container_of(kobj, struct ldlm_namespace,
 						 ns_kobj);
-	u64		  locks;
+	u64 locks;
 
 	locks = lprocfs_stats_collector(ns->ns_stats, LDLM_NSS_LOCKS,
 					LPROCFS_FIELDS_FLAGS_SUM);
@@ -407,9 +407,9 @@ struct ldlm_resource *ldlm_resource_getref(struct ldlm_resource *res)
 static unsigned int ldlm_res_hop_hash(struct cfs_hash *hs,
 				      const void *key, unsigned int mask)
 {
-	const struct ldlm_res_id     *id  = key;
-	unsigned int		val = 0;
-	unsigned int		i;
+	const struct ldlm_res_id *id  = key;
+	unsigned int val = 0;
+	unsigned int i;
 
 	for (i = 0; i < RES_NAME_SIZE; i++)
 		val += id->name[i];
@@ -420,9 +420,9 @@ static unsigned int ldlm_res_hop_fid_hash(struct cfs_hash *hs,
 					  const void *key, unsigned int mask)
 {
 	const struct ldlm_res_id *id = key;
-	struct lu_fid       fid;
-	u32	       hash;
-	u32	       val;
+	struct lu_fid fid;
+	u32 hash;
+	u32 val;
 
 	fid.f_seq = id->name[LUSTRE_RES_ID_SEQ_OFF];
 	fid.f_oid = (u32)id->name[LUSTRE_RES_ID_VER_OID_OFF];
@@ -448,7 +448,7 @@ static unsigned int ldlm_res_hop_fid_hash(struct cfs_hash *hs,
 
 static void *ldlm_res_hop_key(struct hlist_node *hnode)
 {
-	struct ldlm_resource   *res;
+	struct ldlm_resource *res;
 
 	res = hlist_entry(hnode, struct ldlm_resource, lr_hash);
 	return &res->lr_name;
@@ -456,7 +456,7 @@ static void *ldlm_res_hop_key(struct hlist_node *hnode)
 
 static int ldlm_res_hop_keycmp(const void *key, struct hlist_node *hnode)
 {
-	struct ldlm_resource   *res;
+	struct ldlm_resource *res;
 
 	res = hlist_entry(hnode, struct ldlm_resource, lr_hash);
 	return ldlm_res_eq((const struct ldlm_res_id *)key,
@@ -506,13 +506,13 @@ static void ldlm_res_hop_put(struct cfs_hash *hs, struct hlist_node *hnode)
 };
 
 struct ldlm_ns_hash_def {
-	enum ldlm_ns_type nsd_type;
+	enum ldlm_ns_type	nsd_type;
 	/** hash bucket bits */
-	unsigned int	nsd_bkt_bits;
+	unsigned int		nsd_bkt_bits;
 	/** hash bits */
-	unsigned int	nsd_all_bits;
+	unsigned int		nsd_all_bits;
 	/** hash operations */
-	struct cfs_hash_ops *nsd_hops;
+	struct cfs_hash_ops	*nsd_hops;
 };
 
 static struct ldlm_ns_hash_def ldlm_ns_hash_defs[] = {
@@ -578,10 +578,10 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 {
 	struct ldlm_namespace *ns = NULL;
 	struct ldlm_ns_bucket *nsb;
-	struct ldlm_ns_hash_def    *nsd;
-	struct cfs_hash_bd	  bd;
-	int		    idx;
-	int		    rc;
+	struct ldlm_ns_hash_def *nsd;
+	struct cfs_hash_bd bd;
+	int idx;
+	int rc;
 
 	LASSERT(obd);
 
@@ -625,10 +625,10 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 		nsb->nsb_namespace = ns;
 	}
 
-	ns->ns_obd      = obd;
+	ns->ns_obd = obd;
 	ns->ns_appetite = apt;
-	ns->ns_client   = client;
-	ns->ns_name     = kstrdup(name, GFP_KERNEL);
+	ns->ns_client = client;
+	ns->ns_name = kstrdup(name, GFP_KERNEL);
 	if (!ns->ns_name)
 		goto out_hash;
 
@@ -638,13 +638,13 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 	atomic_set(&ns->ns_bref, 0);
 	init_waitqueue_head(&ns->ns_waitq);
 
-	ns->ns_max_parallel_ast   = LDLM_DEFAULT_PARALLEL_AST_LIMIT;
-	ns->ns_nr_unused	  = 0;
-	ns->ns_max_unused	 = LDLM_DEFAULT_LRU_SIZE;
-	ns->ns_max_age	    = LDLM_DEFAULT_MAX_ALIVE;
+	ns->ns_max_parallel_ast = LDLM_DEFAULT_PARALLEL_AST_LIMIT;
+	ns->ns_nr_unused = 0;
+	ns->ns_max_unused = LDLM_DEFAULT_LRU_SIZE;
+	ns->ns_max_age = LDLM_DEFAULT_MAX_ALIVE;
 	ns->ns_orig_connect_flags = 0;
-	ns->ns_connect_flags      = 0;
-	ns->ns_stopping	   = 0;
+	ns->ns_connect_flags = 0;
+	ns->ns_stopping = 0;
 
 	rc = ldlm_namespace_sysfs_register(ns);
 	if (rc != 0) {
@@ -775,7 +775,7 @@ static int ldlm_resource_clean(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 static int ldlm_resource_complain(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 				  struct hlist_node *hnode, void *arg)
 {
-	struct ldlm_resource  *res = cfs_hash_object(hs, hnode);
+	struct ldlm_resource *res = cfs_hash_object(hs, hnode);
 
 	lock_res(res);
 	CERROR("%s: namespace resource " DLDLMRES
@@ -1045,11 +1045,11 @@ struct ldlm_resource *
 		  const struct ldlm_res_id *name, enum ldlm_type type,
 		  int create)
 {
-	struct hlist_node     *hnode;
+	struct hlist_node *hnode;
 	struct ldlm_resource *res = NULL;
-	struct cfs_hash_bd	 bd;
-	u64		 version;
-	int		      ns_refcount = 0;
+	struct cfs_hash_bd bd;
+	u64 version;
+	int ns_refcount = 0;
 	int rc;
 
 	LASSERT(!parent);
@@ -1075,9 +1075,9 @@ struct ldlm_resource *
 	if (!res)
 		return ERR_PTR(-ENOMEM);
 
-	res->lr_ns_bucket  = cfs_hash_bd_extra_get(ns->ns_rs_hash, &bd);
-	res->lr_name       = *name;
-	res->lr_type       = type;
+	res->lr_ns_bucket = cfs_hash_bd_extra_get(ns->ns_rs_hash, &bd);
+	res->lr_name = *name;
+	res->lr_type = type;
 
 	cfs_hash_bd_lock(ns->ns_rs_hash, &bd, 1);
 	hnode = (version == cfs_hash_bd_version_get(&bd)) ?  NULL :
@@ -1179,7 +1179,7 @@ static void __ldlm_resource_putref_final(struct cfs_hash_bd *bd,
 void ldlm_resource_putref(struct ldlm_resource *res)
 {
 	struct ldlm_namespace *ns = ldlm_res_to_ns(res);
-	struct cfs_hash_bd   bd;
+	struct cfs_hash_bd bd;
 
 	LASSERT_ATOMIC_GT_LT(&res->lr_refcount, 0, LI_POISON);
 	CDEBUG(D_INFO, "putref res: %p count: %d\n",
@@ -1253,7 +1253,7 @@ static int ldlm_res_hash_dump(struct cfs_hash *hs, struct cfs_hash_bd *bd,
 			      struct hlist_node *hnode, void *arg)
 {
 	struct ldlm_resource *res = cfs_hash_object(hs, hnode);
-	int    level = (int)(unsigned long)arg;
+	int level = (int)(unsigned long)arg;
 
 	lock_res(res);
 	ldlm_resource_dump(level, res);
-- 
1.8.3.1
