From: James Simmons <jsimmons@infradead.org>
Date: Wed,  6 Apr 2016 15:25:41 -0400
Subject: [lustre-devel] [PATCH 15/24] staging: lustre: selftest: convert
	lstcon_rpc_trans_t to proper struct
In-Reply-To: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
References: <1459970750-5377-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459970750-5377-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@gmail.com>

Turn typedef lstcon_rpc_trans_t to proper structure

Signed-off-by: James Simmons <uja.ornl@gmail.com>
---
 drivers/staging/lustre/lnet/selftest/conrpc.c  |   36 ++++++++++++------------
 drivers/staging/lustre/lnet/selftest/conrpc.h  |   20 ++++++------
 drivers/staging/lustre/lnet/selftest/console.c |   20 ++++++------
 drivers/staging/lustre/lnet/selftest/console.h |    2 +-
 4 files changed, 39 insertions(+), 39 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index edef693..aab4be6 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -46,7 +46,7 @@
 #include "conrpc.h"
 #include "console.h"
 
-void lstcon_rpc_stat_reply(lstcon_rpc_trans_t *, srpc_msg_t *,
+void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, srpc_msg_t *,
 			   lstcon_node_t *, lstcon_trans_stat_t *);
 
 static void
@@ -185,7 +185,7 @@ lstcon_rpc_put(struct lstcon_rpc *crpc)
 static void
 lstcon_rpc_post(struct lstcon_rpc *crpc)
 {
-	lstcon_rpc_trans_t *trans = crpc->crp_trans;
+	struct lstcon_rpc_trans *trans = crpc->crp_trans;
 
 	LASSERT(trans);
 
@@ -236,9 +236,9 @@ lstcon_rpc_trans_name(int transop)
 
 int
 lstcon_rpc_trans_prep(struct list_head *translist, int transop,
-		      lstcon_rpc_trans_t **transpp)
+		      struct lstcon_rpc_trans **transpp)
 {
-	lstcon_rpc_trans_t *trans;
+	struct lstcon_rpc_trans *trans;
 
 	if (translist) {
 		list_for_each_entry(trans, translist, tas_link) {
@@ -278,14 +278,14 @@ lstcon_rpc_trans_prep(struct list_head *translist, int transop,
 }
 
 void
-lstcon_rpc_trans_addreq(lstcon_rpc_trans_t *trans, struct lstcon_rpc *crpc)
+lstcon_rpc_trans_addreq(struct lstcon_rpc_trans *trans, struct lstcon_rpc *crpc)
 {
 	list_add_tail(&crpc->crp_link, &trans->tas_rpcs_list);
 	crpc->crp_trans = trans;
 }
 
 void
-lstcon_rpc_trans_abort(lstcon_rpc_trans_t *trans, int error)
+lstcon_rpc_trans_abort(struct lstcon_rpc_trans *trans, int error)
 {
 	struct srpc_client_rpc *rpc;
 	struct lstcon_rpc *crpc;
@@ -326,7 +326,7 @@ lstcon_rpc_trans_abort(lstcon_rpc_trans_t *trans, int error)
 }
 
 static int
-lstcon_rpc_trans_check(lstcon_rpc_trans_t *trans)
+lstcon_rpc_trans_check(struct lstcon_rpc_trans *trans)
 {
 	if (console_session.ses_shutdown &&
 	    !list_empty(&trans->tas_olink)) /* Not an end session RPC */
@@ -336,7 +336,7 @@ lstcon_rpc_trans_check(lstcon_rpc_trans_t *trans)
 }
 
 int
-lstcon_rpc_trans_postwait(lstcon_rpc_trans_t *trans, int timeout)
+lstcon_rpc_trans_postwait(struct lstcon_rpc_trans *trans, int timeout)
 {
 	struct lstcon_rpc *crpc;
 	int rc;
@@ -423,7 +423,7 @@ lstcon_rpc_get_reply(struct lstcon_rpc *crpc, srpc_msg_t **msgpp)
 }
 
 void
-lstcon_rpc_trans_stat(lstcon_rpc_trans_t *trans, lstcon_trans_stat_t *stat)
+lstcon_rpc_trans_stat(struct lstcon_rpc_trans *trans, lstcon_trans_stat_t *stat)
 {
 	struct lstcon_rpc *crpc;
 	srpc_msg_t *rep;
@@ -466,7 +466,7 @@ lstcon_rpc_trans_stat(lstcon_rpc_trans_t *trans, lstcon_trans_stat_t *stat)
 }
 
 int
-lstcon_rpc_trans_interpreter(lstcon_rpc_trans_t *trans,
+lstcon_rpc_trans_interpreter(struct lstcon_rpc_trans *trans,
 			     struct list_head __user *head_up,
 			     lstcon_rpc_readent_func_t readent)
 {
@@ -539,7 +539,7 @@ lstcon_rpc_trans_interpreter(lstcon_rpc_trans_t *trans,
 }
 
 void
-lstcon_rpc_trans_destroy(lstcon_rpc_trans_t *trans)
+lstcon_rpc_trans_destroy(struct lstcon_rpc_trans *trans)
 {
 	struct srpc_client_rpc *rpc;
 	struct lstcon_rpc *crpc;
@@ -915,7 +915,7 @@ lstcon_testrpc_prep(lstcon_node_t *nd, int transop, unsigned feats,
 }
 
 static int
-lstcon_sesnew_stat_reply(lstcon_rpc_trans_t *trans,
+lstcon_sesnew_stat_reply(struct lstcon_rpc_trans *trans,
 			 lstcon_node_t *nd, srpc_msg_t *reply)
 {
 	srpc_mksn_reply_t *mksn_rep = &reply->msg_body.mksn_reply;
@@ -962,7 +962,7 @@ lstcon_sesnew_stat_reply(lstcon_rpc_trans_t *trans,
 }
 
 void
-lstcon_rpc_stat_reply(lstcon_rpc_trans_t *trans, srpc_msg_t *msg,
+lstcon_rpc_stat_reply(struct lstcon_rpc_trans *trans, srpc_msg_t *msg,
 		      lstcon_node_t *nd, lstcon_trans_stat_t *stat)
 {
 	srpc_rmsn_reply_t *rmsn_rep;
@@ -1083,9 +1083,9 @@ int
 lstcon_rpc_trans_ndlist(struct list_head *ndlist,
 			struct list_head *translist, int transop,
 			void *arg, lstcon_rpc_cond_func_t condition,
-			lstcon_rpc_trans_t **transpp)
+			struct lstcon_rpc_trans **transpp)
 {
-	lstcon_rpc_trans_t *trans;
+	struct lstcon_rpc_trans *trans;
 	lstcon_ndlink_t *ndl;
 	lstcon_node_t *nd;
 	struct lstcon_rpc *rpc;
@@ -1168,7 +1168,7 @@ static void
 lstcon_rpc_pinger(void *arg)
 {
 	struct stt_timer *ptimer = (struct stt_timer *)arg;
-	lstcon_rpc_trans_t *trans;
+	struct lstcon_rpc_trans *trans;
 	struct lstcon_rpc *crpc;
 	srpc_msg_t *rep;
 	srpc_debug_reqst_t *drq;
@@ -1325,7 +1325,7 @@ lstcon_rpc_pinger_stop(void)
 void
 lstcon_rpc_cleanup_wait(void)
 {
-	lstcon_rpc_trans_t *trans;
+	struct lstcon_rpc_trans *trans;
 	struct lstcon_rpc *crpc;
 	struct lstcon_rpc *temp;
 	struct list_head *pacer;
@@ -1337,7 +1337,7 @@ lstcon_rpc_cleanup_wait(void)
 
 	while (!list_empty(&console_session.ses_trans_list)) {
 		list_for_each(pacer, &console_session.ses_trans_list) {
-			trans = list_entry(pacer, lstcon_rpc_trans_t,
+			trans = list_entry(pacer, struct lstcon_rpc_trans,
 					   tas_link);
 
 			CDEBUG(D_NET, "Session closed, wakeup transaction %s\n",
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.h b/drivers/staging/lustre/lnet/selftest/conrpc.h
index abd7bb0..7281abd 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.h
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.h
@@ -78,7 +78,7 @@ struct lstcon_rpc {
 	unsigned long		 crp_stamp;	/* replied time stamp */
 };
 
-typedef struct lstcon_rpc_trans {
+struct lstcon_rpc_trans {
 	struct list_head  tas_olink;	     /* link chain on owner list */
 	struct list_head  tas_link;	     /* link chain on global list */
 	int		  tas_opc;	     /* operation code of transaction */
@@ -87,7 +87,7 @@ typedef struct lstcon_rpc_trans {
 	wait_queue_head_t tas_waitq;	     /* wait queue head */
 	atomic_t	  tas_remaining;     /* # of un-scheduled rpcs */
 	struct list_head  tas_rpcs_list;     /* queued requests */
-} lstcon_rpc_trans_t;
+};
 
 #define LST_TRANS_PRIVATE	0x1000
 
@@ -121,20 +121,20 @@ int  lstcon_statrpc_prep(struct lstcon_node *nd, unsigned version,
 			 struct lstcon_rpc **crpc);
 void lstcon_rpc_put(struct lstcon_rpc *crpc);
 int  lstcon_rpc_trans_prep(struct list_head *translist,
-			   int transop, lstcon_rpc_trans_t **transpp);
+			   int transop, struct lstcon_rpc_trans **transpp);
 int  lstcon_rpc_trans_ndlist(struct list_head *ndlist,
 			     struct list_head *translist, int transop,
 			     void *arg, lstcon_rpc_cond_func_t condition,
-			     lstcon_rpc_trans_t **transpp);
-void lstcon_rpc_trans_stat(lstcon_rpc_trans_t *trans,
+			     struct lstcon_rpc_trans **transpp);
+void lstcon_rpc_trans_stat(struct lstcon_rpc_trans *trans,
 			   lstcon_trans_stat_t *stat);
-int  lstcon_rpc_trans_interpreter(lstcon_rpc_trans_t *trans,
+int  lstcon_rpc_trans_interpreter(struct lstcon_rpc_trans *trans,
 				  struct list_head __user *head_up,
 				  lstcon_rpc_readent_func_t readent);
-void lstcon_rpc_trans_abort(lstcon_rpc_trans_t *trans, int error);
-void lstcon_rpc_trans_destroy(lstcon_rpc_trans_t *trans);
-void lstcon_rpc_trans_addreq(lstcon_rpc_trans_t *trans, struct lstcon_rpc *req);
-int  lstcon_rpc_trans_postwait(lstcon_rpc_trans_t *trans, int timeout);
+void lstcon_rpc_trans_abort(struct lstcon_rpc_trans *trans, int error);
+void lstcon_rpc_trans_destroy(struct lstcon_rpc_trans *trans);
+void lstcon_rpc_trans_addreq(struct lstcon_rpc_trans *trans, struct lstcon_rpc *req);
+int  lstcon_rpc_trans_postwait(struct lstcon_rpc_trans *trans, int timeout);
 int  lstcon_rpc_pinger_start(void);
 void lstcon_rpc_pinger_stop(void);
 void lstcon_rpc_cleanup_wait(void);
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 23696e7..08de007 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -403,7 +403,7 @@ lstcon_group_nodes_add(lstcon_group_t *grp,
 		       int count, lnet_process_id_t __user *ids_up,
 		       unsigned *featp, struct list_head __user *result_up)
 {
-	lstcon_rpc_trans_t *trans;
+	struct lstcon_rpc_trans *trans;
 	lstcon_ndlink_t	*ndl;
 	lstcon_group_t *tmp;
 	lnet_process_id_t id;
@@ -470,7 +470,7 @@ lstcon_group_nodes_remove(lstcon_group_t *grp,
 			  int count, lnet_process_id_t __user *ids_up,
 			  struct list_head __user *result_up)
 {
-	lstcon_rpc_trans_t *trans;
+	struct lstcon_rpc_trans *trans;
 	lstcon_ndlink_t *ndl;
 	lstcon_group_t *tmp;
 	lnet_process_id_t id;
@@ -578,7 +578,7 @@ lstcon_nodes_add(char *name, int count, lnet_process_id_t __user *ids_up,
 int
 lstcon_group_del(char *name)
 {
-	lstcon_rpc_trans_t *trans;
+	struct lstcon_rpc_trans *trans;
 	lstcon_group_t *grp;
 	int rc;
 
@@ -683,7 +683,7 @@ lstcon_nodes_remove(char *name, int count, lnet_process_id_t __user *ids_up,
 int
 lstcon_group_refresh(char *name, struct list_head __user *result_up)
 {
-	lstcon_rpc_trans_t *trans;
+	struct lstcon_rpc_trans *trans;
 	lstcon_group_t *grp;
 	int rc;
 
@@ -1023,7 +1023,7 @@ static int
 lstcon_batch_op(lstcon_batch_t *bat, int transop,
 		struct list_head __user *result_up)
 {
-	lstcon_rpc_trans_t *trans;
+	struct lstcon_rpc_trans *trans;
 	int rc;
 
 	rc = lstcon_rpc_trans_ndlist(&bat->bat_cli_list,
@@ -1187,7 +1187,7 @@ lstcon_testrpc_condition(int transop, lstcon_node_t *nd, void *arg)
 static int
 lstcon_test_nodes_add(lstcon_test_t *test, struct list_head __user *result_up)
 {
-	lstcon_rpc_trans_t *trans;
+	struct lstcon_rpc_trans *trans;
 	lstcon_group_t *grp;
 	int transop;
 	int rc;
@@ -1403,7 +1403,7 @@ int
 lstcon_test_batch_query(char *name, int testidx, int client,
 			int timeout, struct list_head __user *result_up)
 {
-	lstcon_rpc_trans_t *trans;
+	struct lstcon_rpc_trans *trans;
 	struct list_head *translist;
 	struct list_head *ndlist;
 	lstcon_tsb_hdr_t *hdr;
@@ -1490,7 +1490,7 @@ lstcon_ndlist_stat(struct list_head *ndlist,
 		   int timeout, struct list_head __user *result_up)
 {
 	struct list_head head;
-	lstcon_rpc_trans_t *trans;
+	struct lstcon_rpc_trans *trans;
 	int rc;
 
 	INIT_LIST_HEAD(&head);
@@ -1580,7 +1580,7 @@ lstcon_debug_ndlist(struct list_head *ndlist,
 		    struct list_head *translist,
 		    int timeout, struct list_head __user *result_up)
 {
-	lstcon_rpc_trans_t *trans;
+	struct lstcon_rpc_trans *trans;
 	int rc;
 
 	rc = lstcon_rpc_trans_ndlist(ndlist, translist, LST_TRANS_SESQRY,
@@ -1812,7 +1812,7 @@ lstcon_session_info(lst_sid_t __user *sid_up, int __user *key_up,
 int
 lstcon_session_end(void)
 {
-	lstcon_rpc_trans_t *trans;
+	struct lstcon_rpc_trans *trans;
 	lstcon_group_t *grp;
 	lstcon_batch_t *bat;
 	int rc = 0;
diff --git a/drivers/staging/lustre/lnet/selftest/console.h b/drivers/staging/lustre/lnet/selftest/console.h
index 554f582..c573b56 100644
--- a/drivers/staging/lustre/lnet/selftest/console.h
+++ b/drivers/staging/lustre/lnet/selftest/console.h
@@ -152,7 +152,7 @@ struct lstcon_session {
 	unsigned	    ses_expired:1;    /* console is timedout */
 	__u64		    ses_id_cookie;    /* batch id cookie */
 	char		    ses_name[LST_NAME_SIZE];/* session name */
-	lstcon_rpc_trans_t  *ses_ping;	      /* session pinger */
+	struct lstcon_rpc_trans	*ses_ping;		/* session pinger */
 	struct stt_timer	 ses_ping_timer;   /* timer for pinger */
 	lstcon_trans_stat_t ses_trans_stat;   /* transaction stats */
 
-- 
1.7.1
