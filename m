From: James Simmons <jsimmons@infradead.org>
Date: Thu, 17 Nov 2016 14:35:39 -0500
Subject: [lustre-devel] [PATCH 01/19] staging: lustre: lnet: don't use bare
	unsigned
In-Reply-To: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
References: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1479411357-28979-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Turn all bare unsigned to unsigned int that were
detected by checkpatch in the LNet/libcfs layer.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |    4 +-
 drivers/staging/lustre/lnet/libcfs/debug.c         |    2 +-
 drivers/staging/lustre/lnet/libcfs/hash.c          |   26 ++++++++++----------
 drivers/staging/lustre/lnet/libcfs/libcfs_string.c |    8 +++---
 .../staging/lustre/lnet/libcfs/linux/linux-cpu.c   |    6 ++--
 drivers/staging/lustre/lnet/lnet/nidstrings.c      |    2 +-
 drivers/staging/lustre/lnet/selftest/conctl.c      |    2 +-
 drivers/staging/lustre/lnet/selftest/conrpc.c      |   18 +++++++------
 drivers/staging/lustre/lnet/selftest/conrpc.h      |   20 ++++++++-------
 drivers/staging/lustre/lnet/selftest/console.c     |   10 ++++---
 drivers/staging/lustre/lnet/selftest/console.h     |   16 ++++++------
 drivers/staging/lustre/lnet/selftest/framework.c   |    8 +++---
 drivers/staging/lustre/lnet/selftest/ping_test.c   |    4 +-
 drivers/staging/lustre/lnet/selftest/selftest.h    |    4 +-
 14 files changed, 68 insertions(+), 62 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index e6ca0cf..c51c16b 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -216,8 +216,8 @@ struct ksock_nal_data {
 	time64_t                ksnd_connd_starting_stamp;/* time stamp of the
 							   * last starting connd
 							   */
-	unsigned                ksnd_connd_starting;    /* # starting connd */
-	unsigned                ksnd_connd_running;     /* # running connd */
+	unsigned int		ksnd_connd_starting;	/* # starting connd */
+	unsigned int		ksnd_connd_running;	/* # running connd */
 	spinlock_t              ksnd_connd_lock;        /* serialise */
 
 	struct list_head        ksnd_idle_noop_txs;     /* list head for freed
diff --git a/drivers/staging/lustre/lnet/libcfs/debug.c b/drivers/staging/lustre/lnet/libcfs/debug.c
index 23b36b8..9fe4227 100644
--- a/drivers/staging/lustre/lnet/libcfs/debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/debug.c
@@ -57,7 +57,7 @@ static int libcfs_param_debug_mb_set(const char *val,
 				     const struct kernel_param *kp)
 {
 	int rc;
-	unsigned num;
+	unsigned int num;
 
 	rc = kstrtouint(val, 0, &num);
 	if (rc < 0)
diff --git a/drivers/staging/lustre/lnet/libcfs/hash.c b/drivers/staging/lustre/lnet/libcfs/hash.c
index 997b8a5..3137f12 100644
--- a/drivers/staging/lustre/lnet/libcfs/hash.c
+++ b/drivers/staging/lustre/lnet/libcfs/hash.c
@@ -682,7 +682,7 @@ struct hlist_node *
 
 static void
 cfs_hash_multi_bd_lock(struct cfs_hash *hs, struct cfs_hash_bd *bds,
-		       unsigned n, int excl)
+		       unsigned int n, int excl)
 {
 	struct cfs_hash_bucket *prev = NULL;
 	int i;
@@ -704,7 +704,7 @@ struct hlist_node *
 
 static void
 cfs_hash_multi_bd_unlock(struct cfs_hash *hs, struct cfs_hash_bd *bds,
-			 unsigned n, int excl)
+			 unsigned int n, int excl)
 {
 	struct cfs_hash_bucket *prev = NULL;
 	int i;
@@ -719,10 +719,10 @@ struct hlist_node *
 
 static struct hlist_node *
 cfs_hash_multi_bd_lookup_locked(struct cfs_hash *hs, struct cfs_hash_bd *bds,
-				unsigned n, const void *key)
+				unsigned int n, const void *key)
 {
 	struct hlist_node *ehnode;
-	unsigned i;
+	unsigned int i;
 
 	cfs_hash_for_each_bd(bds, n, i) {
 		ehnode = cfs_hash_bd_lookup_intent(hs, &bds[i], key, NULL,
@@ -735,12 +735,12 @@ struct hlist_node *
 
 static struct hlist_node *
 cfs_hash_multi_bd_findadd_locked(struct cfs_hash *hs, struct cfs_hash_bd *bds,
-				 unsigned n, const void *key,
+				 unsigned int n, const void *key,
 				 struct hlist_node *hnode, int noref)
 {
 	struct hlist_node *ehnode;
 	int intent;
-	unsigned i;
+	unsigned int i;
 
 	LASSERT(hnode);
 	intent = (!noref * CFS_HS_LOOKUP_MASK_REF) | CFS_HS_LOOKUP_IT_PEEK;
@@ -766,7 +766,7 @@ struct hlist_node *
 
 static struct hlist_node *
 cfs_hash_multi_bd_finddel_locked(struct cfs_hash *hs, struct cfs_hash_bd *bds,
-				 unsigned n, const void *key,
+				 unsigned int n, const void *key,
 				 struct hlist_node *hnode)
 {
 	struct hlist_node *ehnode;
@@ -992,10 +992,10 @@ static inline void cfs_hash_depth_wi_cancel(struct cfs_hash *hs) {}
 #endif /* CFS_HASH_DEBUG_LEVEL >= CFS_HASH_DEBUG_1 */
 
 struct cfs_hash *
-cfs_hash_create(char *name, unsigned cur_bits, unsigned max_bits,
-		unsigned bkt_bits, unsigned extra_bytes,
-		unsigned min_theta, unsigned max_theta,
-		struct cfs_hash_ops *ops, unsigned flags)
+cfs_hash_create(char *name, unsigned int cur_bits, unsigned int max_bits,
+		unsigned int bkt_bits, unsigned int extra_bytes,
+		unsigned int min_theta, unsigned int max_theta,
+		struct cfs_hash_ops *ops, unsigned int flags)
 {
 	struct cfs_hash *hs;
 	int len;
@@ -1664,7 +1664,7 @@ struct cfs_hash_cond_arg {
 cfs_hash_for_each_empty(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
 			void *data)
 {
-	unsigned i = 0;
+	unsigned int i = 0;
 
 	if (cfs_hash_with_no_lock(hs))
 		return -EOPNOTSUPP;
@@ -1684,7 +1684,7 @@ struct cfs_hash_cond_arg {
 EXPORT_SYMBOL(cfs_hash_for_each_empty);
 
 void
-cfs_hash_hlist_for_each(struct cfs_hash *hs, unsigned hindex,
+cfs_hash_hlist_for_each(struct cfs_hash *hs, unsigned int hindex,
 			cfs_hash_for_each_cb_t func, void *data)
 {
 	struct hlist_head *hhead;
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
index 56a614d..8db9157 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
@@ -222,8 +222,8 @@ int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
  * \retval 0 otherwise
  */
 int
-cfs_str2num_check(char *str, int nob, unsigned *num,
-		  unsigned min, unsigned max)
+cfs_str2num_check(char *str, int nob, unsigned int *num,
+		  unsigned int min, unsigned int max)
 {
 	bool all_numbers = true;
 	char *endp, cache;
@@ -273,7 +273,7 @@ int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
  * -ENOMEM will be returned.
  */
 static int
-cfs_range_expr_parse(struct cfs_lstr *src, unsigned min, unsigned max,
+cfs_range_expr_parse(struct cfs_lstr *src, unsigned int min, unsigned int max,
 		     int bracketed, struct cfs_range_expr **expr)
 {
 	struct cfs_range_expr	*re;
@@ -501,7 +501,7 @@ int cfs_str2mask(const char *str, const char *(*bit2str)(int bit),
  * \retval -errno otherwise
  */
 int
-cfs_expr_list_parse(char *str, int len, unsigned min, unsigned max,
+cfs_expr_list_parse(char *str, int len, unsigned int min, unsigned int max,
 		    struct cfs_expr_list **elpp)
 {
 	struct cfs_expr_list	*expr_list;
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
index 6a31521..268a8ef 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
@@ -678,9 +678,9 @@ struct cfs_cpt_table *
 static unsigned int
 cfs_cpt_num_estimate(void)
 {
-	unsigned nnode = num_online_nodes();
-	unsigned ncpu  = num_online_cpus();
-	unsigned ncpt;
+	unsigned int nnode = num_online_nodes();
+	unsigned int ncpu = num_online_cpus();
+	unsigned int ncpt;
 
 	if (ncpu <= CPT_WEIGHT_MIN) {
 		ncpt = 1;
diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
index a6d7a61..63379f7 100644
--- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
+++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
@@ -193,7 +193,7 @@ struct addrrange {
 	struct netstrfns *nf;
 	struct nidrange *nr;
 	int endlen;
-	unsigned netnum;
+	unsigned int netnum;
 
 	if (src->ls_len >= LNET_NIDSTR_SIZE)
 		return NULL;
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index b786f8b..02847bf 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -315,7 +315,7 @@
 static int
 lst_nodes_add_ioctl(lstio_group_nodes_args_t *args)
 {
-	unsigned feats;
+	unsigned int feats;
 	int rc;
 	char *name;
 
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index 8a3a2da..3d071b4 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -86,7 +86,7 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 }
 
 static int
-lstcon_rpc_init(struct lstcon_node *nd, int service, unsigned feats,
+lstcon_rpc_init(struct lstcon_node *nd, int service, unsigned int feats,
 		int bulk_npg, int bulk_len, int embedded, struct lstcon_rpc *crpc)
 {
 	crpc->crp_rpc = sfw_create_rpc(nd->nd_id, service,
@@ -111,7 +111,7 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 }
 
 static int
-lstcon_rpc_prep(struct lstcon_node *nd, int service, unsigned feats,
+lstcon_rpc_prep(struct lstcon_node *nd, int service, unsigned int feats,
 		int bulk_npg, int bulk_len, struct lstcon_rpc **crpcpp)
 {
 	struct lstcon_rpc *crpc = NULL;
@@ -589,7 +589,7 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 
 int
 lstcon_sesrpc_prep(struct lstcon_node *nd, int transop,
-		   unsigned feats, struct lstcon_rpc **crpc)
+		   unsigned int feats, struct lstcon_rpc **crpc)
 {
 	struct srpc_mksn_reqst *msrq;
 	struct srpc_rmsn_reqst *rsrq;
@@ -627,7 +627,8 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 }
 
 int
-lstcon_dbgrpc_prep(struct lstcon_node *nd, unsigned feats, struct lstcon_rpc **crpc)
+lstcon_dbgrpc_prep(struct lstcon_node *nd, unsigned int feats,
+		   struct lstcon_rpc **crpc)
 {
 	struct srpc_debug_reqst *drq;
 	int rc;
@@ -645,7 +646,7 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 }
 
 int
-lstcon_batrpc_prep(struct lstcon_node *nd, int transop, unsigned feats,
+lstcon_batrpc_prep(struct lstcon_node *nd, int transop, unsigned int feats,
 		   struct lstcon_tsb_hdr *tsb, struct lstcon_rpc **crpc)
 {
 	struct lstcon_batch *batch;
@@ -678,7 +679,8 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 }
 
 int
-lstcon_statrpc_prep(struct lstcon_node *nd, unsigned feats, struct lstcon_rpc **crpc)
+lstcon_statrpc_prep(struct lstcon_node *nd, unsigned int feats,
+		    struct lstcon_rpc **crpc)
 {
 	struct srpc_stat_reqst *srq;
 	int rc;
@@ -803,7 +805,7 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 }
 
 int
-lstcon_testrpc_prep(struct lstcon_node *nd, int transop, unsigned feats,
+lstcon_testrpc_prep(struct lstcon_node *nd, int transop, unsigned int feats,
 		    struct lstcon_test *test, struct lstcon_rpc **crpc)
 {
 	struct lstcon_group *sgrp = test->tes_src_grp;
@@ -1086,7 +1088,7 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 	struct lstcon_ndlink *ndl;
 	struct lstcon_node *nd;
 	struct lstcon_rpc *rpc;
-	unsigned feats;
+	unsigned int feats;
 	int rc;
 
 	/* Creating session RPG for list of nodes */
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.h b/drivers/staging/lustre/lnet/selftest/conrpc.h
index 7ec6fc9..27ba639 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.h
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.h
@@ -78,8 +78,8 @@ struct lstcon_rpc_trans {
 	struct list_head  tas_olink;	     /* link chain on owner list */
 	struct list_head  tas_link;	     /* link chain on global list */
 	int		  tas_opc;	     /* operation code of transaction */
-	unsigned	  tas_feats_updated; /* features mask is uptodate */
-	unsigned	  tas_features;      /* test features mask */
+	unsigned int	  tas_feats_updated; /* features mask is uptodate */
+	unsigned int	  tas_features;      /* test features mask */
 	wait_queue_head_t tas_waitq;	     /* wait queue head */
 	atomic_t	  tas_remaining;     /* # of un-scheduled rpcs */
 	struct list_head  tas_rpcs_list;     /* queued requests */
@@ -106,14 +106,16 @@ typedef int (*lstcon_rpc_readent_func_t)(int, struct srpc_msg *,
 					 lstcon_rpc_ent_t __user *);
 
 int  lstcon_sesrpc_prep(struct lstcon_node *nd, int transop,
-			unsigned version, struct lstcon_rpc **crpc);
+			unsigned int version, struct lstcon_rpc **crpc);
 int  lstcon_dbgrpc_prep(struct lstcon_node *nd,
-			unsigned version, struct lstcon_rpc **crpc);
-int  lstcon_batrpc_prep(struct lstcon_node *nd, int transop, unsigned version,
-			struct lstcon_tsb_hdr *tsb, struct lstcon_rpc **crpc);
-int  lstcon_testrpc_prep(struct lstcon_node *nd, int transop, unsigned version,
-			 struct lstcon_test *test, struct lstcon_rpc **crpc);
-int  lstcon_statrpc_prep(struct lstcon_node *nd, unsigned version,
+			unsigned int version, struct lstcon_rpc **crpc);
+int  lstcon_batrpc_prep(struct lstcon_node *nd, int transop,
+			unsigned int version, struct lstcon_tsb_hdr *tsb,
+			struct lstcon_rpc **crpc);
+int  lstcon_testrpc_prep(struct lstcon_node *nd, int transop,
+			 unsigned int version, struct lstcon_test *test,
+			 struct lstcon_rpc **crpc);
+int  lstcon_statrpc_prep(struct lstcon_node *nd, unsigned int version,
 			 struct lstcon_rpc **crpc);
 void lstcon_rpc_put(struct lstcon_rpc *crpc);
 int  lstcon_rpc_trans_prep(struct list_head *translist,
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index a0fcbf3..faa5320 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -397,7 +397,8 @@
 static int
 lstcon_group_nodes_add(struct lstcon_group *grp,
 		       int count, lnet_process_id_t __user *ids_up,
-		       unsigned *featp, struct list_head __user *result_up)
+		       unsigned int *featp,
+		       struct list_head __user *result_up)
 {
 	struct lstcon_rpc_trans *trans;
 	struct lstcon_ndlink	*ndl;
@@ -542,7 +543,8 @@
 
 int
 lstcon_nodes_add(char *name, int count, lnet_process_id_t __user *ids_up,
-		 unsigned *featp, struct list_head __user *result_up)
+		 unsigned int *featp,
+		 struct list_head __user *result_up)
 {
 	struct lstcon_group *grp;
 	int rc;
@@ -1702,7 +1704,7 @@
 }
 
 int
-lstcon_session_new(char *name, int key, unsigned feats,
+lstcon_session_new(char *name, int key, unsigned int feats,
 		   int timeout, int force, lst_sid_t __user *sid_up)
 {
 	int rc = 0;
@@ -1868,7 +1870,7 @@
 }
 
 int
-lstcon_session_feats_check(unsigned feats)
+lstcon_session_feats_check(unsigned int feats)
 {
 	int rc = 0;
 
diff --git a/drivers/staging/lustre/lnet/selftest/console.h b/drivers/staging/lustre/lnet/selftest/console.h
index 78388a6..5b11b2c 100644
--- a/drivers/staging/lustre/lnet/selftest/console.h
+++ b/drivers/staging/lustre/lnet/selftest/console.h
@@ -144,13 +144,13 @@ struct lstcon_session {
 	int		    ses_timeout;      /* timeout in seconds */
 	time64_t	    ses_laststamp;    /* last operation stamp (seconds)
 					       */
-	unsigned	    ses_features;     /* tests features of the session
+	unsigned int	    ses_features;     /* tests features of the session
 					       */
-	unsigned	    ses_feats_updated:1; /* features are synced with
+	unsigned int	    ses_feats_updated:1; /* features are synced with
 						  * remote test nodes */
-	unsigned	    ses_force:1;      /* force creating */
-	unsigned	    ses_shutdown:1;   /* session is shutting down */
-	unsigned	    ses_expired:1;    /* console is timedout */
+	unsigned int	    ses_force:1;      /* force creating */
+	unsigned int	    ses_shutdown:1;   /* session is shutting down */
+	unsigned int	    ses_expired:1;    /* console is timedout */
 	__u64		    ses_id_cookie;    /* batch id cookie */
 	char		    ses_name[LST_NAME_SIZE];/* session name */
 	struct lstcon_rpc_trans	*ses_ping;		/* session pinger */
@@ -188,14 +188,14 @@ struct lstcon_session {
 int lstcon_console_init(void);
 int lstcon_console_fini(void);
 int lstcon_session_match(lst_sid_t sid);
-int lstcon_session_new(char *name, int key, unsigned version,
+int lstcon_session_new(char *name, int key, unsigned int version,
 		       int timeout, int flags, lst_sid_t __user *sid_up);
 int lstcon_session_info(lst_sid_t __user *sid_up, int __user *key,
 			unsigned __user *verp, lstcon_ndlist_ent_t __user *entp,
 			char __user *name_up, int len);
 int lstcon_session_end(void);
 int lstcon_session_debug(int timeout, struct list_head __user *result_up);
-int lstcon_session_feats_check(unsigned feats);
+int lstcon_session_feats_check(unsigned int feats);
 int lstcon_batch_debug(int timeout, char *name,
 		       int client, struct list_head __user *result_up);
 int lstcon_group_debug(int timeout, char *name,
@@ -207,7 +207,7 @@ int lstcon_nodes_debug(int timeout, int nnd, lnet_process_id_t __user *nds_up,
 int lstcon_group_clean(char *name, int args);
 int lstcon_group_refresh(char *name, struct list_head __user *result_up);
 int lstcon_nodes_add(char *name, int nnd, lnet_process_id_t __user *nds_up,
-		     unsigned *featp, struct list_head __user *result_up);
+		     unsigned int *featp, struct list_head __user *result_up);
 int lstcon_nodes_remove(char *name, int nnd, lnet_process_id_t __user *nds_up,
 			struct list_head __user *result_up);
 int lstcon_group_info(char *name, lstcon_ndlist_ent_t __user *gent_up,
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 2774327..8f9ee3f 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -254,7 +254,7 @@
 
 static inline void
 sfw_init_session(struct sfw_session *sn, lst_sid_t sid,
-		 unsigned features, const char *name)
+		 unsigned int features, const char *name)
 {
 	struct stt_timer *timer = &sn->sn_timer;
 
@@ -897,7 +897,7 @@
 
 int
 sfw_create_test_rpc(struct sfw_test_unit *tsu, lnet_process_id_t peer,
-		    unsigned features, int nblk, int blklen,
+		    unsigned int features, int nblk, int blklen,
 		    struct srpc_client_rpc **rpcpp)
 {
 	struct srpc_client_rpc *rpc = NULL;
@@ -1225,7 +1225,7 @@
 	struct srpc_service *sv = rpc->srpc_scd->scd_svc;
 	struct srpc_msg *reply = &rpc->srpc_replymsg;
 	struct srpc_msg *request = &rpc->srpc_reqstbuf->buf_msg;
-	unsigned features = LST_FEATS_MASK;
+	unsigned int features = LST_FEATS_MASK;
 	int rc = 0;
 
 	LASSERT(!sfw_data.fw_active_srpc);
@@ -1375,7 +1375,7 @@
 
 struct srpc_client_rpc *
 sfw_create_rpc(lnet_process_id_t peer, int service,
-	       unsigned features, int nbulkiov, int bulklen,
+	       unsigned int features, int nbulkiov, int bulklen,
 	       void (*done)(struct srpc_client_rpc *), void *priv)
 {
 	struct srpc_client_rpc *rpc = NULL;
diff --git a/drivers/staging/lustre/lnet/selftest/ping_test.c b/drivers/staging/lustre/lnet/selftest/ping_test.c
index 9331ca4..b9601b0 100644
--- a/drivers/staging/lustre/lnet/selftest/ping_test.c
+++ b/drivers/staging/lustre/lnet/selftest/ping_test.c
@@ -159,8 +159,8 @@ struct lst_ping_data {
 
 	ktime_get_real_ts64(&ts);
 	CDEBUG(D_NET, "%d reply in %u usec\n", reply->pnr_seq,
-	       (unsigned)((ts.tv_sec - reqst->pnr_time_sec) * 1000000 +
-			  (ts.tv_nsec / NSEC_PER_USEC - reqst->pnr_time_usec)));
+	       (unsigned int)((ts.tv_sec - reqst->pnr_time_sec) * 1000000 +
+			      (ts.tv_nsec / NSEC_PER_USEC - reqst->pnr_time_usec)));
 }
 
 static int
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 877bb36..4a1eb29 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -410,10 +410,10 @@ struct sfw_test_case {
 
 struct srpc_client_rpc *
 sfw_create_rpc(lnet_process_id_t peer, int service,
-	       unsigned features, int nbulkiov, int bulklen,
+	       unsigned int features, int nbulkiov, int bulklen,
 	       void (*done)(struct srpc_client_rpc *), void *priv);
 int sfw_create_test_rpc(struct sfw_test_unit *tsu,
-			lnet_process_id_t peer, unsigned features,
+			lnet_process_id_t peer, unsigned int features,
 			int nblk, int blklen, struct srpc_client_rpc **rpc);
 void sfw_abort_rpc(struct srpc_client_rpc *rpc);
 void sfw_post_rpc(struct srpc_client_rpc *rpc);
-- 
1.7.1
