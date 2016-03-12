From: James Simmons <jsimmons@infradead.org>
Date: Fri, 11 Mar 2016 20:29:51 -0500
Subject: [lustre-devel] [PATCH 10/10] staging: lustre: fix aligments in lnet
	selftest
In-Reply-To: <1457746191-27981-1-git-send-email-jsimmons@infradead.org>
References: <1457746191-27981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1457746191-27981-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Some aligment issues were not caught by checkpatch. We address them
here. Some of the alignment issues caused greater than 80 character
checkpatch issues. Some changes were done to just make the code more
readable and to match our production code.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/selftest/conctl.c    |   10 +++++-----
 drivers/staging/lustre/lnet/selftest/conrpc.c    |   11 +++++------
 drivers/staging/lustre/lnet/selftest/console.c   |    7 ++++---
 drivers/staging/lustre/lnet/selftest/framework.c |    5 ++---
 drivers/staging/lustre/lnet/selftest/module.c    |    3 +--
 5 files changed, 17 insertions(+), 19 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index d045ac5..6e2a81d 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -278,8 +278,7 @@ lst_group_update_ioctl(lstio_group_update_args_t *args)
 	if (!name)
 		return -ENOMEM;
 
-	if (copy_from_user(name,
-			   args->lstio_grp_namep,
+	if (copy_from_user(name, args->lstio_grp_namep,
 			   args->lstio_grp_nmlen)) {
 		LIBCFS_FREE(name, args->lstio_grp_nmlen + 1);
 		return -EFAULT;
@@ -375,8 +374,8 @@ lst_group_list_ioctl(lstio_group_list_args_t *args)
 		return -EINVAL;
 
 	return lstcon_group_list(args->lstio_grp_idx,
-			      args->lstio_grp_nmlen,
-			      args->lstio_grp_namep);
+				 args->lstio_grp_nmlen,
+				 args->lstio_grp_namep);
 }
 
 static int
@@ -743,7 +742,8 @@ static int lst_test_add_ioctl(lstio_test_args_t *args)
 	/* have parameter, check if parameter length is valid */
 	if (args->lstio_tes_param &&
 	    (args->lstio_tes_param_len <= 0 ||
-	     args->lstio_tes_param_len > PAGE_CACHE_SIZE - sizeof(lstcon_test_t)))
+	     args->lstio_tes_param_len >
+	     PAGE_CACHE_SIZE - sizeof(lstcon_test_t)))
 		return -EINVAL;
 
 	LIBCFS_ALLOC(batch_name, args->lstio_tes_bat_nmlen + 1);
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index db5a0dc..15b3b00 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -235,8 +235,8 @@ lstcon_rpc_trans_name(int transop)
 }
 
 int
-lstcon_rpc_trans_prep(struct list_head *translist,
-		      int transop, lstcon_rpc_trans_t **transpp)
+lstcon_rpc_trans_prep(struct list_head *translist, int transop,
+		      lstcon_rpc_trans_t **transpp)
 {
 	lstcon_rpc_trans_t *trans;
 
@@ -547,8 +547,7 @@ lstcon_rpc_trans_destroy(lstcon_rpc_trans_t *trans)
 	lstcon_rpc_t *tmp;
 	int count = 0;
 
-	list_for_each_entry_safe(crpc, tmp, &trans->tas_rpcs_list,
-				 crp_link) {
+	list_for_each_entry_safe(crpc, tmp, &trans->tas_rpcs_list, crp_link) {
 		rpc = crpc->crp_rpc;
 
 		spin_lock(&rpc->crpc_lock);
@@ -668,8 +667,8 @@ lstcon_batrpc_prep(lstcon_node_t *nd, int transop, unsigned feats,
 	brq->bar_bid = tsb->tsb_id;
 	brq->bar_testidx = tsb->tsb_index;
 	brq->bar_opc = transop == LST_TRANS_TSBRUN ? SRPC_BATCH_OPC_RUN :
-			   (transop == LST_TRANS_TSBSTOP ? SRPC_BATCH_OPC_STOP :
-			    SRPC_BATCH_OPC_QUERY);
+		       (transop == LST_TRANS_TSBSTOP ? SRPC_BATCH_OPC_STOP :
+		       SRPC_BATCH_OPC_QUERY);
 
 	if (transop != LST_TRANS_TSBRUN &&
 	    transop != LST_TRANS_TSBSTOP)
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 25917ac..fa6d5e7 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -76,7 +76,8 @@ lstcon_node_find(lnet_process_id_t id, lstcon_node_t **ndpp, int create)
 
 	LASSERT(id.nid != LNET_NID_ANY);
 
-	list_for_each_entry(ndl, &console_session.ses_ndl_hash[idx], ndl_hlink) {
+	list_for_each_entry(ndl, &console_session.ses_ndl_hash[idx],
+			    ndl_hlink) {
 		if (ndl->ndl_node->nd_id.nid != id.nid ||
 		    ndl->ndl_node->nd_id.pid != id.pid)
 			continue;
@@ -316,7 +317,7 @@ lstcon_group_ndlink_move(lstcon_group_t *old,
 			 lstcon_group_t *new, lstcon_ndlink_t *ndl)
 {
 	unsigned int idx = LNET_NIDADDR(ndl->ndl_node->nd_id.nid) %
-			   LST_NODE_HASHSIZE;
+					LST_NODE_HASHSIZE;
 
 	list_del(&ndl->ndl_hlink);
 	list_del(&ndl->ndl_link);
@@ -918,7 +919,7 @@ lstcon_batch_list(int index, int len, char __user *name_up)
 	list_for_each_entry(bat, &console_session.ses_bat_list, bat_link) {
 		if (!index--) {
 			return copy_to_user(name_up, bat->bat_name, len) ?
-			       -EFAULT : 0;
+					    -EFAULT : 0;
 		}
 	}
 
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 54ad6d8..b6fe1ab 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -406,7 +406,7 @@ sfw_make_session(srpc_mksn_reqst_t *request, srpc_mksn_reply_t *reply)
 {
 	sfw_session_t *sn = sfw_data.fw_session;
 	srpc_msg_t *msg = container_of(request, srpc_msg_t,
-					  msg_body.mksn_reqst);
+				       msg_body.mksn_reqst);
 	int cplen = 0;
 
 	if (request->mksn_sid.ses_nid == LNET_NID_ANY) {
@@ -1017,8 +1017,7 @@ sfw_run_batch(sfw_batch_t *tsb)
 			tsu->tsu_loop = tsi->tsi_loop;
 			wi = &tsu->tsu_worker;
 			swi_init_workitem(wi, tsu, sfw_run_test,
-					  lst_sched_test[\
-					  lnet_cpt_of_nid(tsu->tsu_dest.nid)]);
+					  lst_sched_test[lnet_cpt_of_nid(tsu->tsu_dest.nid)]);
 			swi_schedule_workitem(wi);
 		}
 	}
diff --git a/drivers/staging/lustre/lnet/selftest/module.c b/drivers/staging/lustre/lnet/selftest/module.c
index 1e858e9..cc046b1 100644
--- a/drivers/staging/lustre/lnet/selftest/module.c
+++ b/drivers/staging/lustre/lnet/selftest/module.c
@@ -116,8 +116,7 @@ lnet_selftest_init(void)
 		rc = cfs_wi_sched_create("lst_t", lnet_cpt_table(), i,
 					 nthrs, &lst_sched_test[i]);
 		if (rc) {
-			CERROR("Failed to create CPT affinity WI scheduler %d for LST\n",
-			       i);
+			CERROR("Failed to create CPT affinity WI scheduler %d for LST\n", i);
 			goto error;
 		}
 	}
-- 
1.7.1
