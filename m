From: James Simmons <jsimmons@infradead.org>
Date: Wed,  6 Apr 2016 15:25:44 -0400
Subject: [lustre-devel] [PATCH 18/24] staging: lustre: selftest: convert
	lstcon_group_t to proper struct
In-Reply-To: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
References: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459970750-5377-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@gmail.com>

Turn typedef lstcon_group_t to proper structure

Signed-off-by: James Simmons <uja.ornl@gmail.com>
---
 drivers/staging/lustre/lnet/selftest/conrpc.c  |    6 +-
 drivers/staging/lustre/lnet/selftest/console.c |   80 ++++++++++++------------
 drivers/staging/lustre/lnet/selftest/console.h |    9 ++-
 3 files changed, 48 insertions(+), 47 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index 5cbd631..3aae59b 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -715,7 +715,7 @@ lstcon_next_id(int idx, int nkiov, lnet_kiov_t *kiov)
 }
 
 static int
-lstcon_dstnodes_prep(lstcon_group_t *grp, int idx,
+lstcon_dstnodes_prep(struct lstcon_group *grp, int idx,
 		     int dist, int span, int nkiov, lnet_kiov_t *kiov)
 {
 	lnet_process_id_packed_t *pid;
@@ -809,8 +809,8 @@ int
 lstcon_testrpc_prep(struct lstcon_node *nd, int transop, unsigned feats,
 		    lstcon_test_t *test, struct lstcon_rpc **crpc)
 {
-	lstcon_group_t *sgrp = test->tes_src_grp;
-	lstcon_group_t *dgrp = test->tes_dst_grp;
+	struct lstcon_group *sgrp = test->tes_src_grp;
+	struct lstcon_group *dgrp = test->tes_dst_grp;
 	srpc_test_reqst_t *trq;
 	struct srpc_bulk *bulk;
 	int i;
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index e068c13..47338f5 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -196,12 +196,12 @@ lstcon_ndlink_release(struct lstcon_ndlink *ndl)
 }
 
 static int
-lstcon_group_alloc(char *name, lstcon_group_t **grpp)
+lstcon_group_alloc(char *name, struct lstcon_group **grpp)
 {
-	lstcon_group_t *grp;
+	struct lstcon_group *grp;
 	int i;
 
-	LIBCFS_ALLOC(grp, offsetof(lstcon_group_t,
+	LIBCFS_ALLOC(grp, offsetof(struct lstcon_group,
 				   grp_ndl_hash[LST_NODE_HASHSIZE]));
 	if (!grp)
 		return -ENOMEM;
@@ -209,7 +209,7 @@ lstcon_group_alloc(char *name, lstcon_group_t **grpp)
 	grp->grp_ref = 1;
 	if (name) {
 		if (strlen(name) > sizeof(grp->grp_name) - 1) {
-			LIBCFS_FREE(grp, offsetof(lstcon_group_t,
+			LIBCFS_FREE(grp, offsetof(struct lstcon_group,
 				    grp_ndl_hash[LST_NODE_HASHSIZE]));
 			return -E2BIG;
 		}
@@ -229,15 +229,15 @@ lstcon_group_alloc(char *name, lstcon_group_t **grpp)
 }
 
 static void
-lstcon_group_addref(lstcon_group_t *grp)
+lstcon_group_addref(struct lstcon_group *grp)
 {
 	grp->grp_ref++;
 }
 
-static void lstcon_group_ndlink_release(lstcon_group_t *, struct lstcon_ndlink *);
+static void lstcon_group_ndlink_release(struct lstcon_group *, struct lstcon_ndlink *);
 
 static void
-lstcon_group_drain(lstcon_group_t *grp, int keep)
+lstcon_group_drain(struct lstcon_group *grp, int keep)
 {
 	struct lstcon_ndlink *ndl;
 	struct lstcon_ndlink *tmp;
@@ -249,7 +249,7 @@ lstcon_group_drain(lstcon_group_t *grp, int keep)
 }
 
 static void
-lstcon_group_decref(lstcon_group_t *grp)
+lstcon_group_decref(struct lstcon_group *grp)
 {
 	int i;
 
@@ -264,14 +264,14 @@ lstcon_group_decref(lstcon_group_t *grp)
 	for (i = 0; i < LST_NODE_HASHSIZE; i++)
 		LASSERT(list_empty(&grp->grp_ndl_hash[i]));
 
-	LIBCFS_FREE(grp, offsetof(lstcon_group_t,
+	LIBCFS_FREE(grp, offsetof(struct lstcon_group,
 				  grp_ndl_hash[LST_NODE_HASHSIZE]));
 }
 
 static int
-lstcon_group_find(const char *name, lstcon_group_t **grpp)
+lstcon_group_find(const char *name, struct lstcon_group **grpp)
 {
-	lstcon_group_t *grp;
+	struct lstcon_group *grp;
 
 	list_for_each_entry(grp, &console_session.ses_grp_list, grp_link) {
 		if (strncmp(grp->grp_name, name, LST_NAME_SIZE))
@@ -286,7 +286,7 @@ lstcon_group_find(const char *name, lstcon_group_t **grpp)
 }
 
 static int
-lstcon_group_ndlink_find(lstcon_group_t *grp, lnet_process_id_t id,
+lstcon_group_ndlink_find(struct lstcon_group *grp, lnet_process_id_t id,
 			 struct lstcon_ndlink **ndlpp, int create)
 {
 	int rc;
@@ -305,7 +305,7 @@ lstcon_group_ndlink_find(lstcon_group_t *grp, lnet_process_id_t id,
 }
 
 static void
-lstcon_group_ndlink_release(lstcon_group_t *grp, struct lstcon_ndlink *ndl)
+lstcon_group_ndlink_release(struct lstcon_group *grp, struct lstcon_ndlink *ndl)
 {
 	list_del_init(&ndl->ndl_link);
 	lstcon_ndlink_release(ndl);
@@ -313,8 +313,8 @@ lstcon_group_ndlink_release(lstcon_group_t *grp, struct lstcon_ndlink *ndl)
 }
 
 static void
-lstcon_group_ndlink_move(lstcon_group_t *old,
-			 lstcon_group_t *new, struct lstcon_ndlink *ndl)
+lstcon_group_ndlink_move(struct lstcon_group *old,
+			 struct lstcon_group *new, struct lstcon_ndlink *ndl)
 {
 	unsigned int idx = LNET_NIDADDR(ndl->ndl_node->nd_id.nid) %
 					LST_NODE_HASHSIZE;
@@ -329,7 +329,7 @@ lstcon_group_ndlink_move(lstcon_group_t *old,
 }
 
 static void
-lstcon_group_move(lstcon_group_t *old, lstcon_group_t *new)
+lstcon_group_move(struct lstcon_group *old, struct lstcon_group *new)
 {
 	struct lstcon_ndlink *ndl;
 
@@ -343,7 +343,7 @@ lstcon_group_move(lstcon_group_t *old, lstcon_group_t *new)
 static int
 lstcon_sesrpc_condition(int transop, struct lstcon_node *nd, void *arg)
 {
-	lstcon_group_t *grp = (lstcon_group_t *)arg;
+	struct lstcon_group *grp = (struct lstcon_group *)arg;
 
 	switch (transop) {
 	case LST_TRANS_SESNEW:
@@ -399,13 +399,13 @@ lstcon_sesrpc_readent(int transop, srpc_msg_t *msg,
 }
 
 static int
-lstcon_group_nodes_add(lstcon_group_t *grp,
+lstcon_group_nodes_add(struct lstcon_group *grp,
 		       int count, lnet_process_id_t __user *ids_up,
 		       unsigned *featp, struct list_head __user *result_up)
 {
 	struct lstcon_rpc_trans *trans;
 	struct lstcon_ndlink	*ndl;
-	lstcon_group_t *tmp;
+	struct lstcon_group *tmp;
 	lnet_process_id_t id;
 	int i;
 	int rc;
@@ -466,13 +466,13 @@ lstcon_group_nodes_add(lstcon_group_t *grp,
 }
 
 static int
-lstcon_group_nodes_remove(lstcon_group_t *grp,
+lstcon_group_nodes_remove(struct lstcon_group *grp,
 			  int count, lnet_process_id_t __user *ids_up,
 			  struct list_head __user *result_up)
 {
 	struct lstcon_rpc_trans *trans;
 	struct lstcon_ndlink *ndl;
-	lstcon_group_t *tmp;
+	struct lstcon_group *tmp;
 	lnet_process_id_t id;
 	int rc;
 	int i;
@@ -523,7 +523,7 @@ error:
 int
 lstcon_group_add(char *name)
 {
-	lstcon_group_t *grp;
+	struct lstcon_group *grp;
 	int rc;
 
 	rc = lstcon_group_find(name, &grp) ? 0 : -EEXIST;
@@ -548,7 +548,7 @@ int
 lstcon_nodes_add(char *name, int count, lnet_process_id_t __user *ids_up,
 		 unsigned *featp, struct list_head __user *result_up)
 {
-	lstcon_group_t *grp;
+	struct lstcon_group *grp;
 	int rc;
 
 	LASSERT(count > 0);
@@ -579,7 +579,7 @@ int
 lstcon_group_del(char *name)
 {
 	struct lstcon_rpc_trans *trans;
-	lstcon_group_t *grp;
+	struct lstcon_group *grp;
 	int rc;
 
 	rc = lstcon_group_find(name, &grp);
@@ -621,7 +621,7 @@ lstcon_group_del(char *name)
 int
 lstcon_group_clean(char *name, int args)
 {
-	lstcon_group_t *grp = NULL;
+	struct lstcon_group *grp = NULL;
 	int rc;
 
 	rc = lstcon_group_find(name, &grp);
@@ -654,7 +654,7 @@ int
 lstcon_nodes_remove(char *name, int count, lnet_process_id_t __user *ids_up,
 		    struct list_head __user *result_up)
 {
-	lstcon_group_t *grp = NULL;
+	struct lstcon_group *grp = NULL;
 	int rc;
 
 	rc = lstcon_group_find(name, &grp);
@@ -684,7 +684,7 @@ int
 lstcon_group_refresh(char *name, struct list_head __user *result_up)
 {
 	struct lstcon_rpc_trans *trans;
-	lstcon_group_t *grp;
+	struct lstcon_group *grp;
 	int rc;
 
 	rc = lstcon_group_find(name, &grp);
@@ -725,7 +725,7 @@ lstcon_group_refresh(char *name, struct list_head __user *result_up)
 int
 lstcon_group_list(int index, int len, char __user *name_up)
 {
-	lstcon_group_t *grp;
+	struct lstcon_group *grp;
 
 	LASSERT(index >= 0);
 	LASSERT(name_up);
@@ -786,7 +786,7 @@ lstcon_group_info(char *name, lstcon_ndlist_ent_t __user *gents_p,
 		  lstcon_node_ent_t __user *dents_up)
 {
 	lstcon_ndlist_ent_t *gentp;
-	lstcon_group_t *grp;
+	struct lstcon_group *grp;
 	struct lstcon_ndlink *ndl;
 	int rc;
 
@@ -1188,7 +1188,7 @@ static int
 lstcon_test_nodes_add(lstcon_test_t *test, struct list_head __user *result_up)
 {
 	struct lstcon_rpc_trans *trans;
-	lstcon_group_t *grp;
+	struct lstcon_group *grp;
 	int transop;
 	int rc;
 
@@ -1255,7 +1255,7 @@ lstcon_verify_batch(const char *name, lstcon_batch_t **batch)
 }
 
 static int
-lstcon_verify_group(const char *name, lstcon_group_t **grp)
+lstcon_verify_group(const char *name, struct lstcon_group **grp)
 {
 	int rc;
 	struct lstcon_ndlink	*ndl;
@@ -1285,8 +1285,8 @@ lstcon_test_add(char *batch_name, int type, int loop,
 {
 	lstcon_test_t *test = NULL;
 	int rc;
-	lstcon_group_t *src_grp = NULL;
-	lstcon_group_t *dst_grp = NULL;
+	struct lstcon_group *src_grp = NULL;
+	struct lstcon_group *dst_grp = NULL;
 	lstcon_batch_t *batch = NULL;
 
 	/*
@@ -1515,7 +1515,7 @@ int
 lstcon_group_stat(char *grp_name, int timeout,
 		  struct list_head __user *result_up)
 {
-	lstcon_group_t *grp;
+	struct lstcon_group *grp;
 	int rc;
 
 	rc = lstcon_group_find(grp_name, &grp);
@@ -1536,7 +1536,7 @@ lstcon_nodes_stat(int count, lnet_process_id_t __user *ids_up,
 		  int timeout, struct list_head __user *result_up)
 {
 	struct lstcon_ndlink	*ndl;
-	lstcon_group_t *tmp;
+	struct lstcon_group *tmp;
 	lnet_process_id_t id;
 	int i;
 	int rc;
@@ -1628,7 +1628,7 @@ int
 lstcon_group_debug(int timeout, char *name,
 		   struct list_head __user *result_up)
 {
-	lstcon_group_t *grp;
+	struct lstcon_group *grp;
 	int rc;
 
 	rc = lstcon_group_find(name, &grp);
@@ -1649,7 +1649,7 @@ lstcon_nodes_debug(int timeout,
 {
 	lnet_process_id_t id;
 	struct lstcon_ndlink *ndl;
-	lstcon_group_t *grp;
+	struct lstcon_group *grp;
 	int i;
 	int rc;
 
@@ -1813,7 +1813,7 @@ int
 lstcon_session_end(void)
 {
 	struct lstcon_rpc_trans *trans;
-	lstcon_group_t *grp;
+	struct lstcon_group *grp;
 	lstcon_batch_t *bat;
 	int rc = 0;
 
@@ -1856,7 +1856,7 @@ lstcon_session_end(void)
 	/* destroy all groups */
 	while (!list_empty(&console_session.ses_grp_list)) {
 		grp = list_entry(console_session.ses_grp_list.next,
-				 lstcon_group_t, grp_link);
+				 struct lstcon_group, grp_link);
 		LASSERT(grp->grp_ref == 1);
 
 		lstcon_group_decref(grp);
@@ -1909,7 +1909,7 @@ lstcon_acceptor_handle(struct srpc_server_rpc *rpc)
 	srpc_msg_t *req	= &rpc->srpc_reqstbuf->buf_msg;
 	srpc_join_reqst_t *jreq = &req->msg_body.join_reqst;
 	srpc_join_reply_t *jrep = &rep->msg_body.join_reply;
-	lstcon_group_t *grp = NULL;
+	struct lstcon_group *grp = NULL;
 	struct lstcon_ndlink *ndl;
 	int rc = 0;
 
diff --git a/drivers/staging/lustre/lnet/selftest/console.h b/drivers/staging/lustre/lnet/selftest/console.h
index dd9674d..74bfcd8 100644
--- a/drivers/staging/lustre/lnet/selftest/console.h
+++ b/drivers/staging/lustre/lnet/selftest/console.h
@@ -67,7 +67,8 @@ struct lstcon_ndlink {
 	struct lstcon_node	*ndl_node;	/* pointer to node */
 };
 
-typedef struct {
+/* (alias of nodes) group descriptor */
+struct lstcon_group {
 	struct list_head grp_link;		  /* chain on global group list
 						   */
 	int		 grp_ref;		  /* reference count */
@@ -78,7 +79,7 @@ typedef struct {
 	struct list_head grp_trans_list;	  /* transaction list */
 	struct list_head grp_ndl_list;		  /* nodes list */
 	struct list_head grp_ndl_hash[0];	  /* hash table for nodes */
-} lstcon_group_t; /* (alias of nodes) group descriptor */
+};
 
 #define LST_BATCH_IDLE	  0xB0	    /* idle batch */
 #define LST_BATCH_RUNNING 0xB1	    /* running batch */
@@ -122,8 +123,8 @@ typedef struct lstcon_test {
 	int		 tes_cliidx;	 /* client index, used for RPC creating */
 
 	struct list_head tes_trans_list; /* transaction list */
-	lstcon_group_t	 *tes_src_grp;	 /* group run the test */
-	lstcon_group_t	 *tes_dst_grp;	 /* target group */
+	struct lstcon_group	*tes_src_grp;	/* group run the test */
+	struct lstcon_group	*tes_dst_grp;	/* target group */
 
 	int		 tes_paramlen;	 /* test parameter length */
 	char		 tes_param[0];	 /* test parameter */
-- 
1.7.1
