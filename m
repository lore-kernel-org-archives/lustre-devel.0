From: James Simmons <jsimmons@infradead.org>
Date: Tue, 12 Apr 2016 12:16:01 -0400
Subject: [lustre-devel] [PATCH v2 1/2] staging: lustre: selftest: convert
	lstcon_test_t to proper struct
In-Reply-To: <1460477762-14167-1-git-send-email-jsimmons@infradead.org>
References: <1460477762-14167-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1460477762-14167-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Turn typedef lstcon_test_t to proper structure

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/selftest/conctl.c  |    2 +-
 drivers/staging/lustre/lnet/selftest/conrpc.c  |    5 ++-
 drivers/staging/lustre/lnet/selftest/console.c |   26 ++++++++++++------------
 drivers/staging/lustre/lnet/selftest/console.h |    7 +++--
 4 files changed, 21 insertions(+), 19 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index a76f1c3..408c614 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -743,7 +743,7 @@ static int lst_test_add_ioctl(lstio_test_args_t *args)
 	if (args->lstio_tes_param &&
 	    (args->lstio_tes_param_len <= 0 ||
 	     args->lstio_tes_param_len >
-	     PAGE_SIZE - sizeof(lstcon_test_t)))
+	     PAGE_SIZE - sizeof(struct lstcon_test)))
 		return -EINVAL;
 
 	LIBCFS_ALLOC(batch_name, args->lstio_tes_bat_nmlen + 1);
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index 31d7b4f..bc96ef8 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -807,7 +807,7 @@ lstcon_bulkrpc_v1_prep(lst_test_bulk_param_t *param, srpc_test_reqst_t *req)
 
 int
 lstcon_testrpc_prep(struct lstcon_node *nd, int transop, unsigned feats,
-		    lstcon_test_t *test, struct lstcon_rpc **crpc)
+		    struct lstcon_test *test, struct lstcon_rpc **crpc)
 {
 	struct lstcon_group *sgrp = test->tes_src_grp;
 	struct lstcon_group *dgrp = test->tes_dst_grp;
@@ -1128,7 +1128,8 @@ lstcon_rpc_trans_ndlist(struct list_head *ndlist,
 		case LST_TRANS_TSBCLIADD:
 		case LST_TRANS_TSBSRVADD:
 			rc = lstcon_testrpc_prep(nd, transop, feats,
-						 (lstcon_test_t *)arg, &rpc);
+						 (struct lstcon_test *)arg,
+						 &rpc);
 			break;
 		case LST_TRANS_TSBRUN:
 		case LST_TRANS_TSBSTOP:
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 03c73b0..6568e8e 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -934,7 +934,7 @@ lstcon_batch_info(char *name, lstcon_test_batch_ent_t __user *ent_up,
 	lstcon_test_batch_ent_t *entp;
 	struct list_head *clilst;
 	struct list_head *srvlst;
-	lstcon_test_t *test = NULL;
+	struct lstcon_test *test = NULL;
 	struct lstcon_batch *bat;
 	struct lstcon_ndlink	*ndl;
 	int rc;
@@ -1091,14 +1091,14 @@ static void
 lstcon_batch_destroy(struct lstcon_batch *bat)
 {
 	struct lstcon_ndlink *ndl;
-	lstcon_test_t *test;
+	struct lstcon_test *test;
 	int i;
 
 	list_del(&bat->bat_link);
 
 	while (!list_empty(&bat->bat_test_list)) {
 		test = list_entry(bat->bat_test_list.next,
-				  lstcon_test_t, tes_link);
+				  struct lstcon_test, tes_link);
 		LASSERT(list_empty(&test->tes_trans_list));
 
 		list_del(&test->tes_link);
@@ -1106,7 +1106,7 @@ lstcon_batch_destroy(struct lstcon_batch *bat)
 		lstcon_group_decref(test->tes_src_grp);
 		lstcon_group_decref(test->tes_dst_grp);
 
-		LIBCFS_FREE(test, offsetof(lstcon_test_t,
+		LIBCFS_FREE(test, offsetof(struct lstcon_test,
 					   tes_param[test->tes_paramlen]));
 	}
 
@@ -1143,13 +1143,13 @@ lstcon_batch_destroy(struct lstcon_batch *bat)
 static int
 lstcon_testrpc_condition(int transop, struct lstcon_node *nd, void *arg)
 {
-	lstcon_test_t *test;
+	struct lstcon_test *test;
 	struct lstcon_batch *batch;
 	struct lstcon_ndlink *ndl;
 	struct list_head *hash;
 	struct list_head *head;
 
-	test = (lstcon_test_t *)arg;
+	test = (struct lstcon_test *)arg;
 	LASSERT(test);
 
 	batch = test->tes_batch;
@@ -1185,7 +1185,7 @@ lstcon_testrpc_condition(int transop, struct lstcon_node *nd, void *arg)
 }
 
 static int
-lstcon_test_nodes_add(lstcon_test_t *test, struct list_head __user *result_up)
+lstcon_test_nodes_add(struct lstcon_test *test, struct list_head __user *result_up)
 {
 	struct lstcon_rpc_trans *trans;
 	struct lstcon_group *grp;
@@ -1283,7 +1283,7 @@ lstcon_test_add(char *batch_name, int type, int loop,
 		void *param, int paramlen, int *retp,
 		struct list_head __user *result_up)
 {
-	lstcon_test_t *test = NULL;
+	struct lstcon_test *test = NULL;
 	int rc;
 	struct lstcon_group *src_grp = NULL;
 	struct lstcon_group *dst_grp = NULL;
@@ -1309,7 +1309,7 @@ lstcon_test_add(char *batch_name, int type, int loop,
 	if (dst_grp->grp_userland)
 		*retp = 1;
 
-	LIBCFS_ALLOC(test, offsetof(lstcon_test_t, tes_param[paramlen]));
+	LIBCFS_ALLOC(test, offsetof(struct lstcon_test, tes_param[paramlen]));
 	if (!test) {
 		CERROR("Can't allocate test descriptor\n");
 		rc = -ENOMEM;
@@ -1356,7 +1356,7 @@ lstcon_test_add(char *batch_name, int type, int loop,
 	return rc;
 out:
 	if (test)
-		LIBCFS_FREE(test, offsetof(lstcon_test_t, tes_param[paramlen]));
+		LIBCFS_FREE(test, offsetof(struct lstcon_test, tes_param[paramlen]));
 
 	if (dst_grp)
 		lstcon_group_decref(dst_grp);
@@ -1368,9 +1368,9 @@ out:
 }
 
 static int
-lstcon_test_find(struct lstcon_batch *batch, int idx, lstcon_test_t **testpp)
+lstcon_test_find(struct lstcon_batch *batch, int idx, struct lstcon_test **testpp)
 {
-	lstcon_test_t *test;
+	struct lstcon_test *test;
 
 	list_for_each_entry(test, &batch->bat_test_list, tes_link) {
 		if (idx == test->tes_hdr.tsb_index) {
@@ -1408,7 +1408,7 @@ lstcon_test_batch_query(char *name, int testidx, int client,
 	struct list_head *ndlist;
 	struct lstcon_tsb_hdr *hdr;
 	struct lstcon_batch *batch;
-	lstcon_test_t *test = NULL;
+	struct lstcon_test *test = NULL;
 	int transop;
 	int rc;
 
diff --git a/drivers/staging/lustre/lnet/selftest/console.h b/drivers/staging/lustre/lnet/selftest/console.h
index ccd4982..becd22e 100644
--- a/drivers/staging/lustre/lnet/selftest/console.h
+++ b/drivers/staging/lustre/lnet/selftest/console.h
@@ -99,7 +99,7 @@ struct lstcon_batch {
 					   * for run, force for stop */
 	char		 bat_name[LST_NAME_SIZE];/* name of batch */
 
-	struct list_head bat_test_list;   /* list head of tests (lstcon_test_t)
+	struct list_head bat_test_list;   /* list head of tests (struct lstcon_test)
 					   */
 	struct list_head bat_trans_list;  /* list head of transaction */
 	struct list_head bat_cli_list;	  /* list head of client nodes
@@ -109,7 +109,8 @@ struct lstcon_batch {
 	struct list_head *bat_srv_hash;   /* hash table of server nodes */
 };
 
-typedef struct lstcon_test {
+/* a single test descriptor */
+struct lstcon_test {
 	struct lstcon_tsb_hdr	tes_hdr;	/* test batch header */
 	struct list_head tes_link;	 /* chain on batch's tests list */
 	struct lstcon_batch	*tes_batch;	 /* pointer to batch */
@@ -129,7 +130,7 @@ typedef struct lstcon_test {
 
 	int		 tes_paramlen;	 /* test parameter length */
 	char		 tes_param[0];	 /* test parameter */
-} lstcon_test_t; /* a single test descriptor */
+};
 
 #define LST_GLOBAL_HASHSIZE 503	     /* global nodes hash table size */
 #define LST_NODE_HASHSIZE   239	     /* node hash table (for batch or group) */
-- 
1.7.1
