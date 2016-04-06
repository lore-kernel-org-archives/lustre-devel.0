From: James Simmons <jsimmons@infradead.org>
Date: Wed,  6 Apr 2016 15:25:43 -0400
Subject: [lustre-devel] [PATCH 17/24] staging: lustre: selftest: convert
	lstcon_ndlink_t to proper struct
In-Reply-To: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
References: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459970750-5377-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@gmail.com>

Turn typedef lstcon_ndlink_t to proper structure

Signed-off-by: James Simmons <uja.ornl@gmail.com>
---
 drivers/staging/lustre/lnet/selftest/conrpc.c  |    6 +-
 drivers/staging/lustre/lnet/selftest/console.c |   64 ++++++++++++------------
 drivers/staging/lustre/lnet/selftest/console.h |    7 ++-
 3 files changed, 39 insertions(+), 38 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index 194b6dc..5cbd631 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -719,7 +719,7 @@ lstcon_dstnodes_prep(lstcon_group_t *grp, int idx,
 		     int dist, int span, int nkiov, lnet_kiov_t *kiov)
 {
 	lnet_process_id_packed_t *pid;
-	lstcon_ndlink_t *ndl;
+	struct lstcon_ndlink *ndl;
 	struct lstcon_node *nd;
 	int start;
 	int end;
@@ -1086,7 +1086,7 @@ lstcon_rpc_trans_ndlist(struct list_head *ndlist,
 			struct lstcon_rpc_trans **transpp)
 {
 	struct lstcon_rpc_trans *trans;
-	lstcon_ndlink_t *ndl;
+	struct lstcon_ndlink *ndl;
 	struct lstcon_node *nd;
 	struct lstcon_rpc *rpc;
 	unsigned feats;
@@ -1172,7 +1172,7 @@ lstcon_rpc_pinger(void *arg)
 	struct lstcon_rpc *crpc;
 	srpc_msg_t *rep;
 	srpc_debug_reqst_t *drq;
-	lstcon_ndlink_t *ndl;
+	struct lstcon_ndlink *ndl;
 	struct lstcon_node *nd;
 	int intv;
 	int count = 0;
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 32364b4..e068c13 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -71,7 +71,7 @@ lstcon_node_get(struct lstcon_node *nd)
 static int
 lstcon_node_find(lnet_process_id_t id, struct lstcon_node **ndpp, int create)
 {
-	lstcon_ndlink_t	*ndl;
+	struct lstcon_ndlink	*ndl;
 	unsigned int idx = LNET_NIDADDR(id.nid) % LST_GLOBAL_HASHSIZE;
 
 	LASSERT(id.nid != LNET_NID_ANY);
@@ -90,11 +90,11 @@ lstcon_node_find(lnet_process_id_t id, struct lstcon_node **ndpp, int create)
 	if (!create)
 		return -ENOENT;
 
-	LIBCFS_ALLOC(*ndpp, sizeof(struct lstcon_node) + sizeof(lstcon_ndlink_t));
+	LIBCFS_ALLOC(*ndpp, sizeof(struct lstcon_node) + sizeof(struct lstcon_ndlink));
 	if (!*ndpp)
 		return -ENOMEM;
 
-	ndl = (lstcon_ndlink_t *)(*ndpp + 1);
+	ndl = (struct lstcon_ndlink *)(*ndpp + 1);
 
 	ndl->ndl_node = *ndpp;
 
@@ -119,14 +119,14 @@ lstcon_node_find(lnet_process_id_t id, struct lstcon_node **ndpp, int create)
 static void
 lstcon_node_put(struct lstcon_node *nd)
 {
-	lstcon_ndlink_t *ndl;
+	struct lstcon_ndlink *ndl;
 
 	LASSERT(nd->nd_ref > 0);
 
 	if (--nd->nd_ref > 0)
 		return;
 
-	ndl = (lstcon_ndlink_t *)(nd + 1);
+	ndl = (struct lstcon_ndlink *)(nd + 1);
 
 	LASSERT(!list_empty(&ndl->ndl_link));
 	LASSERT(!list_empty(&ndl->ndl_hlink));
@@ -135,15 +135,15 @@ lstcon_node_put(struct lstcon_node *nd)
 	list_del(&ndl->ndl_link);
 	list_del(&ndl->ndl_hlink);
 
-	LIBCFS_FREE(nd, sizeof(struct lstcon_node) + sizeof(lstcon_ndlink_t));
+	LIBCFS_FREE(nd, sizeof(struct lstcon_node) + sizeof(struct lstcon_ndlink));
 }
 
 static int
 lstcon_ndlink_find(struct list_head *hash,
-		   lnet_process_id_t id, lstcon_ndlink_t **ndlpp, int create)
+		   lnet_process_id_t id, struct lstcon_ndlink **ndlpp, int create)
 {
 	unsigned int idx = LNET_NIDADDR(id.nid) % LST_NODE_HASHSIZE;
-	lstcon_ndlink_t *ndl;
+	struct lstcon_ndlink *ndl;
 	struct lstcon_node *nd;
 	int rc;
 
@@ -168,7 +168,7 @@ lstcon_ndlink_find(struct list_head *hash,
 	if (rc)
 		return rc;
 
-	LIBCFS_ALLOC(ndl, sizeof(lstcon_ndlink_t));
+	LIBCFS_ALLOC(ndl, sizeof(struct lstcon_ndlink));
 	if (!ndl) {
 		lstcon_node_put(nd);
 		return -ENOMEM;
@@ -184,7 +184,7 @@ lstcon_ndlink_find(struct list_head *hash,
 }
 
 static void
-lstcon_ndlink_release(lstcon_ndlink_t *ndl)
+lstcon_ndlink_release(struct lstcon_ndlink *ndl)
 {
 	LASSERT(list_empty(&ndl->ndl_link));
 	LASSERT(!list_empty(&ndl->ndl_hlink));
@@ -234,13 +234,13 @@ lstcon_group_addref(lstcon_group_t *grp)
 	grp->grp_ref++;
 }
 
-static void lstcon_group_ndlink_release(lstcon_group_t *, lstcon_ndlink_t *);
+static void lstcon_group_ndlink_release(lstcon_group_t *, struct lstcon_ndlink *);
 
 static void
 lstcon_group_drain(lstcon_group_t *grp, int keep)
 {
-	lstcon_ndlink_t *ndl;
-	lstcon_ndlink_t *tmp;
+	struct lstcon_ndlink *ndl;
+	struct lstcon_ndlink *tmp;
 
 	list_for_each_entry_safe(ndl, tmp, &grp->grp_ndl_list, ndl_link) {
 		if (!(ndl->ndl_node->nd_state & keep))
@@ -287,7 +287,7 @@ lstcon_group_find(const char *name, lstcon_group_t **grpp)
 
 static int
 lstcon_group_ndlink_find(lstcon_group_t *grp, lnet_process_id_t id,
-			 lstcon_ndlink_t **ndlpp, int create)
+			 struct lstcon_ndlink **ndlpp, int create)
 {
 	int rc;
 
@@ -305,7 +305,7 @@ lstcon_group_ndlink_find(lstcon_group_t *grp, lnet_process_id_t id,
 }
 
 static void
-lstcon_group_ndlink_release(lstcon_group_t *grp, lstcon_ndlink_t *ndl)
+lstcon_group_ndlink_release(lstcon_group_t *grp, struct lstcon_ndlink *ndl)
 {
 	list_del_init(&ndl->ndl_link);
 	lstcon_ndlink_release(ndl);
@@ -314,7 +314,7 @@ lstcon_group_ndlink_release(lstcon_group_t *grp, lstcon_ndlink_t *ndl)
 
 static void
 lstcon_group_ndlink_move(lstcon_group_t *old,
-			 lstcon_group_t *new, lstcon_ndlink_t *ndl)
+			 lstcon_group_t *new, struct lstcon_ndlink *ndl)
 {
 	unsigned int idx = LNET_NIDADDR(ndl->ndl_node->nd_id.nid) %
 					LST_NODE_HASHSIZE;
@@ -331,11 +331,11 @@ lstcon_group_ndlink_move(lstcon_group_t *old,
 static void
 lstcon_group_move(lstcon_group_t *old, lstcon_group_t *new)
 {
-	lstcon_ndlink_t *ndl;
+	struct lstcon_ndlink *ndl;
 
 	while (!list_empty(&old->grp_ndl_list)) {
 		ndl = list_entry(old->grp_ndl_list.next,
-				 lstcon_ndlink_t, ndl_link);
+				 struct lstcon_ndlink, ndl_link);
 		lstcon_group_ndlink_move(old, new, ndl);
 	}
 }
@@ -404,7 +404,7 @@ lstcon_group_nodes_add(lstcon_group_t *grp,
 		       unsigned *featp, struct list_head __user *result_up)
 {
 	struct lstcon_rpc_trans *trans;
-	lstcon_ndlink_t	*ndl;
+	struct lstcon_ndlink	*ndl;
 	lstcon_group_t *tmp;
 	lnet_process_id_t id;
 	int i;
@@ -471,7 +471,7 @@ lstcon_group_nodes_remove(lstcon_group_t *grp,
 			  struct list_head __user *result_up)
 {
 	struct lstcon_rpc_trans *trans;
-	lstcon_ndlink_t *ndl;
+	struct lstcon_ndlink *ndl;
 	lstcon_group_t *tmp;
 	lnet_process_id_t id;
 	int rc;
@@ -744,7 +744,7 @@ static int
 lstcon_nodes_getent(struct list_head *head, int *index_p,
 		    int *count_p, lstcon_node_ent_t __user *dents_up)
 {
-	lstcon_ndlink_t *ndl;
+	struct lstcon_ndlink *ndl;
 	struct lstcon_node *nd;
 	int count = 0;
 	int index = 0;
@@ -787,7 +787,7 @@ lstcon_group_info(char *name, lstcon_ndlist_ent_t __user *gents_p,
 {
 	lstcon_ndlist_ent_t *gentp;
 	lstcon_group_t *grp;
-	lstcon_ndlink_t *ndl;
+	struct lstcon_ndlink *ndl;
 	int rc;
 
 	rc = lstcon_group_find(name, &grp);
@@ -936,7 +936,7 @@ lstcon_batch_info(char *name, lstcon_test_batch_ent_t __user *ent_up,
 	struct list_head *srvlst;
 	lstcon_test_t *test = NULL;
 	lstcon_batch_t *bat;
-	lstcon_ndlink_t	*ndl;
+	struct lstcon_ndlink	*ndl;
 	int rc;
 
 	rc = lstcon_batch_find(name, &bat);
@@ -1090,7 +1090,7 @@ lstcon_batch_stop(char *name, int force, struct list_head __user *result_up)
 static void
 lstcon_batch_destroy(lstcon_batch_t *bat)
 {
-	lstcon_ndlink_t *ndl;
+	struct lstcon_ndlink *ndl;
 	lstcon_test_t *test;
 	int i;
 
@@ -1114,7 +1114,7 @@ lstcon_batch_destroy(lstcon_batch_t *bat)
 
 	while (!list_empty(&bat->bat_cli_list)) {
 		ndl = list_entry(bat->bat_cli_list.next,
-				 lstcon_ndlink_t, ndl_link);
+				 struct lstcon_ndlink, ndl_link);
 		list_del_init(&ndl->ndl_link);
 
 		lstcon_ndlink_release(ndl);
@@ -1122,7 +1122,7 @@ lstcon_batch_destroy(lstcon_batch_t *bat)
 
 	while (!list_empty(&bat->bat_srv_list)) {
 		ndl = list_entry(bat->bat_srv_list.next,
-				 lstcon_ndlink_t, ndl_link);
+				 struct lstcon_ndlink, ndl_link);
 		list_del_init(&ndl->ndl_link);
 
 		lstcon_ndlink_release(ndl);
@@ -1145,7 +1145,7 @@ lstcon_testrpc_condition(int transop, struct lstcon_node *nd, void *arg)
 {
 	lstcon_test_t *test;
 	lstcon_batch_t *batch;
-	lstcon_ndlink_t *ndl;
+	struct lstcon_ndlink *ndl;
 	struct list_head *hash;
 	struct list_head *head;
 
@@ -1258,7 +1258,7 @@ static int
 lstcon_verify_group(const char *name, lstcon_group_t **grp)
 {
 	int rc;
-	lstcon_ndlink_t	*ndl;
+	struct lstcon_ndlink	*ndl;
 
 	rc = lstcon_group_find(name, grp);
 	if (rc) {
@@ -1535,7 +1535,7 @@ int
 lstcon_nodes_stat(int count, lnet_process_id_t __user *ids_up,
 		  int timeout, struct list_head __user *result_up)
 {
-	lstcon_ndlink_t	*ndl;
+	struct lstcon_ndlink	*ndl;
 	lstcon_group_t *tmp;
 	lnet_process_id_t id;
 	int i;
@@ -1648,7 +1648,7 @@ lstcon_nodes_debug(int timeout,
 		   struct list_head __user *result_up)
 {
 	lnet_process_id_t id;
-	lstcon_ndlink_t *ndl;
+	struct lstcon_ndlink *ndl;
 	lstcon_group_t *grp;
 	int i;
 	int rc;
@@ -1781,7 +1781,7 @@ lstcon_session_info(lst_sid_t __user *sid_up, int __user *key_up,
 		    char __user *name_up, int len)
 {
 	lstcon_ndlist_ent_t *entp;
-	lstcon_ndlink_t *ndl;
+	struct lstcon_ndlink *ndl;
 	int rc = 0;
 
 	if (console_session.ses_state != LST_SESSION_ACTIVE)
@@ -1910,7 +1910,7 @@ lstcon_acceptor_handle(struct srpc_server_rpc *rpc)
 	srpc_join_reqst_t *jreq = &req->msg_body.join_reqst;
 	srpc_join_reply_t *jrep = &rep->msg_body.join_reply;
 	lstcon_group_t *grp = NULL;
-	lstcon_ndlink_t *ndl;
+	struct lstcon_ndlink *ndl;
 	int rc = 0;
 
 	sfw_unpack_message(req);
diff --git a/drivers/staging/lustre/lnet/selftest/console.h b/drivers/staging/lustre/lnet/selftest/console.h
index 7c37967..dd9674d 100644
--- a/drivers/staging/lustre/lnet/selftest/console.h
+++ b/drivers/staging/lustre/lnet/selftest/console.h
@@ -60,11 +60,12 @@ struct lstcon_node {
 	struct lstcon_rpc nd_ping;    /* ping rpc */
 };
 
-typedef struct {
+/* node link descriptor */
+struct lstcon_ndlink {
 	struct list_head ndl_link;    /* chain on list */
 	struct list_head ndl_hlink;   /* chain on hash */
-	struct lstcon_node	 *ndl_node;   /* pointer to node */
-} lstcon_ndlink_t; /* node link descriptor */
+	struct lstcon_node	*ndl_node;	/* pointer to node */
+};
 
 typedef struct {
 	struct list_head grp_link;		  /* chain on global group list
-- 
1.7.1
