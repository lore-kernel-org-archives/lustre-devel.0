From: James Simmons <jsimmons@infradead.org>
Date: Wed,  6 Apr 2016 15:25:46 -0400
Subject: [lustre-devel] [PATCH 20/24] staging: lustre: selftest: convert
	lstcon_batch_t to proper struct
In-Reply-To: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
References: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459970750-5377-21-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@gmail.com>

Turn typedef lstcon_batch_t to proper structure

Signed-off-by: James Simmons <uja.ornl@gmail.com>
---
 drivers/staging/lustre/lnet/selftest/conrpc.c  |    4 +-
 drivers/staging/lustre/lnet/selftest/console.c |   46 ++++++++++++------------
 drivers/staging/lustre/lnet/selftest/console.h |    7 ++--
 3 files changed, 29 insertions(+), 28 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index be94b9c..19c9b5c 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -652,7 +652,7 @@ int
 lstcon_batrpc_prep(struct lstcon_node *nd, int transop, unsigned feats,
 		   struct lstcon_tsb_hdr *tsb, struct lstcon_rpc **crpc)
 {
-	lstcon_batch_t *batch;
+	struct lstcon_batch *batch;
 	srpc_batch_reqst_t *brq;
 	int rc;
 
@@ -675,7 +675,7 @@ lstcon_batrpc_prep(struct lstcon_node *nd, int transop, unsigned feats,
 
 	LASSERT(!tsb->tsb_index);
 
-	batch = (lstcon_batch_t *)tsb;
+	batch = (struct lstcon_batch *)tsb;
 	brq->bar_arg = batch->bat_arg;
 
 	return 0;
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 41f732b..deb0bc0 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -828,9 +828,9 @@ lstcon_group_info(char *name, lstcon_ndlist_ent_t __user *gents_p,
 }
 
 static int
-lstcon_batch_find(const char *name, lstcon_batch_t **batpp)
+lstcon_batch_find(const char *name, struct lstcon_batch **batpp)
 {
-	lstcon_batch_t *bat;
+	struct lstcon_batch *bat;
 
 	list_for_each_entry(bat, &console_session.ses_bat_list, bat_link) {
 		if (!strncmp(bat->bat_name, name, LST_NAME_SIZE)) {
@@ -845,7 +845,7 @@ lstcon_batch_find(const char *name, lstcon_batch_t **batpp)
 int
 lstcon_batch_add(char *name)
 {
-	lstcon_batch_t *bat;
+	struct lstcon_batch *bat;
 	int i;
 	int rc;
 
@@ -855,7 +855,7 @@ lstcon_batch_add(char *name)
 		return rc;
 	}
 
-	LIBCFS_ALLOC(bat, sizeof(lstcon_batch_t));
+	LIBCFS_ALLOC(bat, sizeof(struct lstcon_batch));
 	if (!bat) {
 		CERROR("Can't allocate descriptor for batch %s\n", name);
 		return -ENOMEM;
@@ -865,7 +865,7 @@ lstcon_batch_add(char *name)
 		     sizeof(struct list_head) * LST_NODE_HASHSIZE);
 	if (!bat->bat_cli_hash) {
 		CERROR("Can't allocate hash for batch %s\n", name);
-		LIBCFS_FREE(bat, sizeof(lstcon_batch_t));
+		LIBCFS_FREE(bat, sizeof(struct lstcon_batch));
 
 		return -ENOMEM;
 	}
@@ -875,7 +875,7 @@ lstcon_batch_add(char *name)
 	if (!bat->bat_srv_hash) {
 		CERROR("Can't allocate hash for batch %s\n", name);
 		LIBCFS_FREE(bat->bat_cli_hash, LST_NODE_HASHSIZE);
-		LIBCFS_FREE(bat, sizeof(lstcon_batch_t));
+		LIBCFS_FREE(bat, sizeof(struct lstcon_batch));
 
 		return -ENOMEM;
 	}
@@ -883,7 +883,7 @@ lstcon_batch_add(char *name)
 	if (strlen(name) > sizeof(bat->bat_name) - 1) {
 		LIBCFS_FREE(bat->bat_srv_hash, LST_NODE_HASHSIZE);
 		LIBCFS_FREE(bat->bat_cli_hash, LST_NODE_HASHSIZE);
-		LIBCFS_FREE(bat, sizeof(lstcon_batch_t));
+		LIBCFS_FREE(bat, sizeof(struct lstcon_batch));
 		return -E2BIG;
 	}
 	strncpy(bat->bat_name, name, sizeof(bat->bat_name));
@@ -911,7 +911,7 @@ lstcon_batch_add(char *name)
 int
 lstcon_batch_list(int index, int len, char __user *name_up)
 {
-	lstcon_batch_t *bat;
+	struct lstcon_batch *bat;
 
 	LASSERT(name_up);
 	LASSERT(index >= 0);
@@ -935,7 +935,7 @@ lstcon_batch_info(char *name, lstcon_test_batch_ent_t __user *ent_up,
 	struct list_head *clilst;
 	struct list_head *srvlst;
 	lstcon_test_t *test = NULL;
-	lstcon_batch_t *bat;
+	struct lstcon_batch *bat;
 	struct lstcon_ndlink	*ndl;
 	int rc;
 
@@ -1020,7 +1020,7 @@ lstcon_batrpc_condition(int transop, struct lstcon_node *nd, void *arg)
 }
 
 static int
-lstcon_batch_op(lstcon_batch_t *bat, int transop,
+lstcon_batch_op(struct lstcon_batch *bat, int transop,
 		struct list_head __user *result_up)
 {
 	struct lstcon_rpc_trans *trans;
@@ -1046,7 +1046,7 @@ lstcon_batch_op(lstcon_batch_t *bat, int transop,
 int
 lstcon_batch_run(char *name, int timeout, struct list_head __user *result_up)
 {
-	lstcon_batch_t *bat;
+	struct lstcon_batch *bat;
 	int rc;
 
 	if (lstcon_batch_find(name, &bat)) {
@@ -1068,7 +1068,7 @@ lstcon_batch_run(char *name, int timeout, struct list_head __user *result_up)
 int
 lstcon_batch_stop(char *name, int force, struct list_head __user *result_up)
 {
-	lstcon_batch_t *bat;
+	struct lstcon_batch *bat;
 	int rc;
 
 	if (lstcon_batch_find(name, &bat)) {
@@ -1088,7 +1088,7 @@ lstcon_batch_stop(char *name, int force, struct list_head __user *result_up)
 }
 
 static void
-lstcon_batch_destroy(lstcon_batch_t *bat)
+lstcon_batch_destroy(struct lstcon_batch *bat)
 {
 	struct lstcon_ndlink *ndl;
 	lstcon_test_t *test;
@@ -1137,14 +1137,14 @@ lstcon_batch_destroy(lstcon_batch_t *bat)
 		    sizeof(struct list_head) * LST_NODE_HASHSIZE);
 	LIBCFS_FREE(bat->bat_srv_hash,
 		    sizeof(struct list_head) * LST_NODE_HASHSIZE);
-	LIBCFS_FREE(bat, sizeof(lstcon_batch_t));
+	LIBCFS_FREE(bat, sizeof(struct lstcon_batch));
 }
 
 static int
 lstcon_testrpc_condition(int transop, struct lstcon_node *nd, void *arg)
 {
 	lstcon_test_t *test;
-	lstcon_batch_t *batch;
+	struct lstcon_batch *batch;
 	struct lstcon_ndlink *ndl;
 	struct list_head *hash;
 	struct list_head *head;
@@ -1236,7 +1236,7 @@ again:
 }
 
 static int
-lstcon_verify_batch(const char *name, lstcon_batch_t **batch)
+lstcon_verify_batch(const char *name, struct lstcon_batch **batch)
 {
 	int rc;
 
@@ -1287,7 +1287,7 @@ lstcon_test_add(char *batch_name, int type, int loop,
 	int rc;
 	struct lstcon_group *src_grp = NULL;
 	struct lstcon_group *dst_grp = NULL;
-	lstcon_batch_t *batch = NULL;
+	struct lstcon_batch *batch = NULL;
 
 	/*
 	 * verify that a batch of the given name exists, and the groups
@@ -1368,7 +1368,7 @@ out:
 }
 
 static int
-lstcon_test_find(lstcon_batch_t *batch, int idx, lstcon_test_t **testpp)
+lstcon_test_find(struct lstcon_batch *batch, int idx, lstcon_test_t **testpp)
 {
 	lstcon_test_t *test;
 
@@ -1407,7 +1407,7 @@ lstcon_test_batch_query(char *name, int testidx, int client,
 	struct list_head *translist;
 	struct list_head *ndlist;
 	struct lstcon_tsb_hdr *hdr;
-	lstcon_batch_t *batch;
+	struct lstcon_batch *batch;
 	lstcon_test_t *test = NULL;
 	int transop;
 	int rc;
@@ -1610,7 +1610,7 @@ int
 lstcon_batch_debug(int timeout, char *name,
 		   int client, struct list_head __user *result_up)
 {
-	lstcon_batch_t *bat;
+	struct lstcon_batch *bat;
 	int rc;
 
 	rc = lstcon_batch_find(name, &bat);
@@ -1757,7 +1757,7 @@ lstcon_session_new(char *name, int key, unsigned feats,
 
 	rc = lstcon_rpc_pinger_start();
 	if (rc) {
-		lstcon_batch_t *bat = NULL;
+		struct lstcon_batch *bat = NULL;
 
 		lstcon_batch_find(LST_DEFAULT_BATCH, &bat);
 		lstcon_batch_destroy(bat);
@@ -1814,7 +1814,7 @@ lstcon_session_end(void)
 {
 	struct lstcon_rpc_trans *trans;
 	struct lstcon_group *grp;
-	lstcon_batch_t *bat;
+	struct lstcon_batch *bat;
 	int rc = 0;
 
 	LASSERT(console_session.ses_state == LST_SESSION_ACTIVE);
@@ -1848,7 +1848,7 @@ lstcon_session_end(void)
 	/* destroy all batches */
 	while (!list_empty(&console_session.ses_bat_list)) {
 		bat = list_entry(console_session.ses_bat_list.next,
-				 lstcon_batch_t, bat_link);
+				 struct lstcon_batch, bat_link);
 
 		lstcon_batch_destroy(bat);
 	}
diff --git a/drivers/staging/lustre/lnet/selftest/console.h b/drivers/staging/lustre/lnet/selftest/console.h
index 427bc9b..ccd4982 100644
--- a/drivers/staging/lustre/lnet/selftest/console.h
+++ b/drivers/staging/lustre/lnet/selftest/console.h
@@ -89,7 +89,8 @@ struct lstcon_tsb_hdr {
 	int		 tsb_index;	 /* test index */
 };
 
-typedef struct {
+/* (tests ) batch descriptor */
+struct lstcon_batch {
 	struct lstcon_tsb_hdr	bat_hdr;	/* test_batch header */
 	struct list_head bat_link;	  /* chain on session's batches list */
 	int		 bat_ntest;	  /* # of test */
@@ -106,12 +107,12 @@ typedef struct {
 	struct list_head *bat_cli_hash;   /* hash table of client nodes */
 	struct list_head bat_srv_list;	  /* list head of server nodes */
 	struct list_head *bat_srv_hash;   /* hash table of server nodes */
-} lstcon_batch_t; /* (tests ) batch descriptor */
+};
 
 typedef struct lstcon_test {
 	struct lstcon_tsb_hdr	tes_hdr;	/* test batch header */
 	struct list_head tes_link;	 /* chain on batch's tests list */
-	lstcon_batch_t	 *tes_batch;	 /* pointer to batch */
+	struct lstcon_batch	*tes_batch;	 /* pointer to batch */
 
 	int		 tes_type;	 /* type of the test, i.e: bulk, ping */
 	int		 tes_stop_onerr; /* stop on error */
-- 
1.7.1
