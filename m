From: James Simmons <jsimmons@infradead.org>
Date: Wed,  6 Apr 2016 15:25:42 -0400
Subject: [lustre-devel] [PATCH 16/24] staging: lustre: selftest: convert
	lstcon_node_t to proper struct
In-Reply-To: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
References: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459970750-5377-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@gmail.com>

Turn typedef lstcon_node_t to proper structure

Signed-off-by: James Simmons <uja.ornl@gmail.com>
---
 drivers/staging/lustre/lnet/selftest/conrpc.c  |   32 ++++++++++++------------
 drivers/staging/lustre/lnet/selftest/console.c |   20 +++++++-------
 drivers/staging/lustre/lnet/selftest/console.h |    9 +++---
 3 files changed, 31 insertions(+), 30 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index aab4be6..194b6dc 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -47,7 +47,7 @@
 #include "console.h"
 
 void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, srpc_msg_t *,
-			   lstcon_node_t *, lstcon_trans_stat_t *);
+			   struct lstcon_node *, lstcon_trans_stat_t *);
 
 static void
 lstcon_rpc_done(struct srpc_client_rpc *rpc)
@@ -90,7 +90,7 @@ lstcon_rpc_done(struct srpc_client_rpc *rpc)
 }
 
 static int
-lstcon_rpc_init(lstcon_node_t *nd, int service, unsigned feats,
+lstcon_rpc_init(struct lstcon_node *nd, int service, unsigned feats,
 		int bulk_npg, int bulk_len, int embedded, struct lstcon_rpc *crpc)
 {
 	crpc->crp_rpc = sfw_create_rpc(nd->nd_id, service,
@@ -115,7 +115,7 @@ lstcon_rpc_init(lstcon_node_t *nd, int service, unsigned feats,
 }
 
 static int
-lstcon_rpc_prep(lstcon_node_t *nd, int service, unsigned feats,
+lstcon_rpc_prep(struct lstcon_node *nd, int service, unsigned feats,
 		int bulk_npg, int bulk_len, struct lstcon_rpc **crpcpp)
 {
 	struct lstcon_rpc *crpc = NULL;
@@ -289,7 +289,7 @@ lstcon_rpc_trans_abort(struct lstcon_rpc_trans *trans, int error)
 {
 	struct srpc_client_rpc *rpc;
 	struct lstcon_rpc *crpc;
-	lstcon_node_t *nd;
+	struct lstcon_node *nd;
 
 	list_for_each_entry(crpc, &trans->tas_rpcs_list, crp_link) {
 		rpc = crpc->crp_rpc;
@@ -388,7 +388,7 @@ lstcon_rpc_trans_postwait(struct lstcon_rpc_trans *trans, int timeout)
 static int
 lstcon_rpc_get_reply(struct lstcon_rpc *crpc, srpc_msg_t **msgpp)
 {
-	lstcon_node_t *nd = crpc->crp_node;
+	struct lstcon_node *nd = crpc->crp_node;
 	struct srpc_client_rpc *rpc = crpc->crp_rpc;
 	srpc_generic_reply_t *rep;
 
@@ -476,7 +476,7 @@ lstcon_rpc_trans_interpreter(struct lstcon_rpc_trans *trans,
 	srpc_generic_reply_t *rep;
 	struct lstcon_rpc *crpc;
 	srpc_msg_t *msg;
-	lstcon_node_t *nd;
+	struct lstcon_node *nd;
 	long dur;
 	struct timeval tv;
 	int error;
@@ -592,7 +592,7 @@ lstcon_rpc_trans_destroy(struct lstcon_rpc_trans *trans)
 }
 
 int
-lstcon_sesrpc_prep(lstcon_node_t *nd, int transop,
+lstcon_sesrpc_prep(struct lstcon_node *nd, int transop,
 		   unsigned feats, struct lstcon_rpc **crpc)
 {
 	srpc_mksn_reqst_t *msrq;
@@ -631,7 +631,7 @@ lstcon_sesrpc_prep(lstcon_node_t *nd, int transop,
 }
 
 int
-lstcon_dbgrpc_prep(lstcon_node_t *nd, unsigned feats, struct lstcon_rpc **crpc)
+lstcon_dbgrpc_prep(struct lstcon_node *nd, unsigned feats, struct lstcon_rpc **crpc)
 {
 	srpc_debug_reqst_t *drq;
 	int rc;
@@ -649,7 +649,7 @@ lstcon_dbgrpc_prep(lstcon_node_t *nd, unsigned feats, struct lstcon_rpc **crpc)
 }
 
 int
-lstcon_batrpc_prep(lstcon_node_t *nd, int transop, unsigned feats,
+lstcon_batrpc_prep(struct lstcon_node *nd, int transop, unsigned feats,
 		   lstcon_tsb_hdr_t *tsb, struct lstcon_rpc **crpc)
 {
 	lstcon_batch_t *batch;
@@ -682,7 +682,7 @@ lstcon_batrpc_prep(lstcon_node_t *nd, int transop, unsigned feats,
 }
 
 int
-lstcon_statrpc_prep(lstcon_node_t *nd, unsigned feats, struct lstcon_rpc **crpc)
+lstcon_statrpc_prep(struct lstcon_node *nd, unsigned feats, struct lstcon_rpc **crpc)
 {
 	srpc_stat_reqst_t *srq;
 	int rc;
@@ -720,7 +720,7 @@ lstcon_dstnodes_prep(lstcon_group_t *grp, int idx,
 {
 	lnet_process_id_packed_t *pid;
 	lstcon_ndlink_t *ndl;
-	lstcon_node_t *nd;
+	struct lstcon_node *nd;
 	int start;
 	int end;
 	int i = 0;
@@ -806,7 +806,7 @@ lstcon_bulkrpc_v1_prep(lst_test_bulk_param_t *param, srpc_test_reqst_t *req)
 }
 
 int
-lstcon_testrpc_prep(lstcon_node_t *nd, int transop, unsigned feats,
+lstcon_testrpc_prep(struct lstcon_node *nd, int transop, unsigned feats,
 		    lstcon_test_t *test, struct lstcon_rpc **crpc)
 {
 	lstcon_group_t *sgrp = test->tes_src_grp;
@@ -916,7 +916,7 @@ lstcon_testrpc_prep(lstcon_node_t *nd, int transop, unsigned feats,
 
 static int
 lstcon_sesnew_stat_reply(struct lstcon_rpc_trans *trans,
-			 lstcon_node_t *nd, srpc_msg_t *reply)
+			 struct lstcon_node *nd, srpc_msg_t *reply)
 {
 	srpc_mksn_reply_t *mksn_rep = &reply->msg_body.mksn_reply;
 	int status = mksn_rep->mksn_status;
@@ -963,7 +963,7 @@ lstcon_sesnew_stat_reply(struct lstcon_rpc_trans *trans,
 
 void
 lstcon_rpc_stat_reply(struct lstcon_rpc_trans *trans, srpc_msg_t *msg,
-		      lstcon_node_t *nd, lstcon_trans_stat_t *stat)
+		      struct lstcon_node *nd, lstcon_trans_stat_t *stat)
 {
 	srpc_rmsn_reply_t *rmsn_rep;
 	srpc_debug_reply_t *dbg_rep;
@@ -1087,7 +1087,7 @@ lstcon_rpc_trans_ndlist(struct list_head *ndlist,
 {
 	struct lstcon_rpc_trans *trans;
 	lstcon_ndlink_t *ndl;
-	lstcon_node_t *nd;
+	struct lstcon_node *nd;
 	struct lstcon_rpc *rpc;
 	unsigned feats;
 	int rc;
@@ -1173,7 +1173,7 @@ lstcon_rpc_pinger(void *arg)
 	srpc_msg_t *rep;
 	srpc_debug_reqst_t *drq;
 	lstcon_ndlink_t *ndl;
-	lstcon_node_t *nd;
+	struct lstcon_node *nd;
 	int intv;
 	int count = 0;
 	int rc;
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 08de007..32364b4 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -61,7 +61,7 @@ do {							\
 struct lstcon_session console_session;
 
 static void
-lstcon_node_get(lstcon_node_t *nd)
+lstcon_node_get(struct lstcon_node *nd)
 {
 	LASSERT(nd->nd_ref >= 1);
 
@@ -69,7 +69,7 @@ lstcon_node_get(lstcon_node_t *nd)
 }
 
 static int
-lstcon_node_find(lnet_process_id_t id, lstcon_node_t **ndpp, int create)
+lstcon_node_find(lnet_process_id_t id, struct lstcon_node **ndpp, int create)
 {
 	lstcon_ndlink_t	*ndl;
 	unsigned int idx = LNET_NIDADDR(id.nid) % LST_GLOBAL_HASHSIZE;
@@ -90,7 +90,7 @@ lstcon_node_find(lnet_process_id_t id, lstcon_node_t **ndpp, int create)
 	if (!create)
 		return -ENOENT;
 
-	LIBCFS_ALLOC(*ndpp, sizeof(lstcon_node_t) + sizeof(lstcon_ndlink_t));
+	LIBCFS_ALLOC(*ndpp, sizeof(struct lstcon_node) + sizeof(lstcon_ndlink_t));
 	if (!*ndpp)
 		return -ENOMEM;
 
@@ -117,7 +117,7 @@ lstcon_node_find(lnet_process_id_t id, lstcon_node_t **ndpp, int create)
 }
 
 static void
-lstcon_node_put(lstcon_node_t *nd)
+lstcon_node_put(struct lstcon_node *nd)
 {
 	lstcon_ndlink_t *ndl;
 
@@ -135,7 +135,7 @@ lstcon_node_put(lstcon_node_t *nd)
 	list_del(&ndl->ndl_link);
 	list_del(&ndl->ndl_hlink);
 
-	LIBCFS_FREE(nd, sizeof(lstcon_node_t) + sizeof(lstcon_ndlink_t));
+	LIBCFS_FREE(nd, sizeof(struct lstcon_node) + sizeof(lstcon_ndlink_t));
 }
 
 static int
@@ -144,7 +144,7 @@ lstcon_ndlink_find(struct list_head *hash,
 {
 	unsigned int idx = LNET_NIDADDR(id.nid) % LST_NODE_HASHSIZE;
 	lstcon_ndlink_t *ndl;
-	lstcon_node_t *nd;
+	struct lstcon_node *nd;
 	int rc;
 
 	if (id.nid == LNET_NID_ANY)
@@ -341,7 +341,7 @@ lstcon_group_move(lstcon_group_t *old, lstcon_group_t *new)
 }
 
 static int
-lstcon_sesrpc_condition(int transop, lstcon_node_t *nd, void *arg)
+lstcon_sesrpc_condition(int transop, struct lstcon_node *nd, void *arg)
 {
 	lstcon_group_t *grp = (lstcon_group_t *)arg;
 
@@ -745,7 +745,7 @@ lstcon_nodes_getent(struct list_head *head, int *index_p,
 		    int *count_p, lstcon_node_ent_t __user *dents_up)
 {
 	lstcon_ndlink_t *ndl;
-	lstcon_node_t *nd;
+	struct lstcon_node *nd;
 	int count = 0;
 	int index = 0;
 
@@ -998,7 +998,7 @@ lstcon_batch_info(char *name, lstcon_test_batch_ent_t __user *ent_up,
 }
 
 static int
-lstcon_batrpc_condition(int transop, lstcon_node_t *nd, void *arg)
+lstcon_batrpc_condition(int transop, struct lstcon_node *nd, void *arg)
 {
 	switch (transop) {
 	case LST_TRANS_TSBRUN:
@@ -1141,7 +1141,7 @@ lstcon_batch_destroy(lstcon_batch_t *bat)
 }
 
 static int
-lstcon_testrpc_condition(int transop, lstcon_node_t *nd, void *arg)
+lstcon_testrpc_condition(int transop, struct lstcon_node *nd, void *arg)
 {
 	lstcon_test_t *test;
 	lstcon_batch_t *batch;
diff --git a/drivers/staging/lustre/lnet/selftest/console.h b/drivers/staging/lustre/lnet/selftest/console.h
index c573b56..7c37967 100644
--- a/drivers/staging/lustre/lnet/selftest/console.h
+++ b/drivers/staging/lustre/lnet/selftest/console.h
@@ -50,19 +50,20 @@
 #include "selftest.h"
 #include "conrpc.h"
 
-typedef struct lstcon_node {
+/* node descriptor */
+struct lstcon_node {
 	lnet_process_id_t nd_id;      /* id of the node */
 	int		  nd_ref;     /* reference count */
 	int		  nd_state;   /* state of the node */
 	int		  nd_timeout; /* session timeout */
 	unsigned long	  nd_stamp;   /* timestamp of last replied RPC */
 	struct lstcon_rpc nd_ping;    /* ping rpc */
-} lstcon_node_t; /* node descriptor */
+};
 
 typedef struct {
 	struct list_head ndl_link;    /* chain on list */
 	struct list_head ndl_hlink;   /* chain on hash */
-	lstcon_node_t	 *ndl_node;   /* pointer to node */
+	struct lstcon_node	 *ndl_node;   /* pointer to node */
 } lstcon_ndlink_t; /* node link descriptor */
 
 typedef struct {
@@ -99,7 +100,7 @@ typedef struct {
 					   */
 	struct list_head bat_trans_list;  /* list head of transaction */
 	struct list_head bat_cli_list;	  /* list head of client nodes
-					   * (lstcon_node_t) */
+					   * (struct lstcon_node) */
 	struct list_head *bat_cli_hash;   /* hash table of client nodes */
 	struct list_head bat_srv_list;	  /* list head of server nodes */
 	struct list_head *bat_srv_hash;   /* hash table of server nodes */
-- 
1.7.1
