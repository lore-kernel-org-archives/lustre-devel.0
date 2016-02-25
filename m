From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Wed, 24 Feb 2016 22:00:56 -0500
Subject: [lustre-devel] [PATCH v2 73/84] staging/lustre/ptlrpc: Fix style vs
	open parenthesis alignment
In-Reply-To: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
References: <1456369267-904461-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456369267-904461-74-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This mostly fixes checkpatch complaints about
"Alignment should match open parenthesis"

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/ptlrpc/client.c      | 40 +++++-------
 drivers/staging/lustre/lustre/ptlrpc/import.c      | 21 +++----
 drivers/staging/lustre/lustre/ptlrpc/layout.c      | 35 +++++------
 .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    | 15 +++--
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |  4 +-
 drivers/staging/lustre/lustre/ptlrpc/nrs.c         | 19 +++---
 drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c    |  2 +-
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |  4 +-
 drivers/staging/lustre/lustre/ptlrpc/pinger.c      |  5 +-
 drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |  9 ++-
 drivers/staging/lustre/lustre/ptlrpc/recover.c     |  6 +-
 drivers/staging/lustre/lustre/ptlrpc/sec.c         |  6 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_config.c  |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/sec_gc.c      |  4 +-
 drivers/staging/lustre/lustre/ptlrpc/service.c     | 73 ++++++++++------------
 15 files changed, 111 insertions(+), 134 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 9b89068..0003158 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -557,7 +557,7 @@ ptlrpc_prep_req_from_pool(struct ptlrpc_request_pool *pool)
 	}
 
 	request = list_entry(pool->prp_req_list.next, struct ptlrpc_request,
-				 rq_list);
+			     rq_list);
 	list_del_init(&request->rq_list);
 	spin_unlock(&pool->prp_lock);
 
@@ -725,7 +725,7 @@ struct ptlrpc_request *__ptlrpc_request_alloc(struct obd_import *imp,
 		LASSERTF((unsigned long)imp > 0x1000, "%p", imp);
 		LASSERT(imp != LP_POISON);
 		LASSERTF((unsigned long)imp->imp_client > 0x1000, "%p",
-			imp->imp_client);
+			 imp->imp_client);
 		LASSERT(imp->imp_client != LP_POISON);
 
 		request->rq_import = class_import_get(imp);
@@ -896,8 +896,7 @@ void ptlrpc_set_destroy(struct ptlrpc_request_set *set)
 			 RQ_PHASE_COMPLETE : RQ_PHASE_NEW;
 	list_for_each(tmp, &set->set_requests) {
 		struct ptlrpc_request *req =
-			list_entry(tmp, struct ptlrpc_request,
-				       rq_set_chain);
+			list_entry(tmp, struct ptlrpc_request, rq_set_chain);
 
 		LASSERT(req->rq_phase == expected_phase);
 		n++;
@@ -909,8 +908,7 @@ void ptlrpc_set_destroy(struct ptlrpc_request_set *set)
 
 	list_for_each_safe(tmp, next, &set->set_requests) {
 		struct ptlrpc_request *req =
-			list_entry(tmp, struct ptlrpc_request,
-				       rq_set_chain);
+			list_entry(tmp, struct ptlrpc_request, rq_set_chain);
 		list_del_init(&req->rq_set_chain);
 
 		LASSERT(req->rq_phase == expected_phase);
@@ -1331,8 +1329,8 @@ static int after_reply(struct ptlrpc_request *req)
 			struct ptlrpc_request *last;
 
 			last = list_entry(imp->imp_replay_list.prev,
-					      struct ptlrpc_request,
-					      rq_replay_list);
+					  struct ptlrpc_request,
+					  rq_replay_list);
 			/*
 			 * Requests with rq_replay stay on the list even if no
 			 * commit is expected.
@@ -1475,8 +1473,7 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 	INIT_LIST_HEAD(&comp_reqs);
 	list_for_each_safe(tmp, next, &set->set_requests) {
 		struct ptlrpc_request *req =
-			list_entry(tmp, struct ptlrpc_request,
-				       rq_set_chain);
+			list_entry(tmp, struct ptlrpc_request, rq_set_chain);
 		struct obd_import *imp = req->rq_import;
 		int unregistered = 0;
 		int rc = 0;
@@ -1618,8 +1615,7 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 					 */
 					list_del_init(&req->rq_list);
 					list_add_tail(&req->rq_list,
-							  &imp->
-							  imp_delayed_list);
+						      &imp->imp_delayed_list);
 					spin_unlock(&imp->imp_lock);
 					continue;
 				}
@@ -1627,7 +1623,7 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 				if (status != 0) {
 					req->rq_status = status;
 					ptlrpc_rqphase_move(req,
-						RQ_PHASE_INTERPRET);
+							    RQ_PHASE_INTERPRET);
 					spin_unlock(&imp->imp_lock);
 					goto interpret;
 				}
@@ -1642,7 +1638,7 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 
 				list_del_init(&req->rq_list);
 				list_add_tail(&req->rq_list,
-						  &imp->imp_sending_list);
+					      &imp->imp_sending_list);
 
 				spin_unlock(&imp->imp_lock);
 
@@ -1944,8 +1940,7 @@ int ptlrpc_expired_set(void *data)
 	/* A timeout expired. See which reqs it applies to...  */
 	list_for_each(tmp, &set->set_requests) {
 		struct ptlrpc_request *req =
-			list_entry(tmp, struct ptlrpc_request,
-				       rq_set_chain);
+			list_entry(tmp, struct ptlrpc_request, rq_set_chain);
 
 		/* don't expire request waiting for context */
 		if (req->rq_wait_ctx)
@@ -2001,8 +1996,7 @@ void ptlrpc_interrupted_set(void *data)
 
 	list_for_each(tmp, &set->set_requests) {
 		struct ptlrpc_request *req =
-			list_entry(tmp, struct ptlrpc_request,
-				       rq_set_chain);
+			list_entry(tmp, struct ptlrpc_request, rq_set_chain);
 
 		if (req->rq_phase != RQ_PHASE_RPC &&
 		    req->rq_phase != RQ_PHASE_UNREGISTERING)
@@ -2075,7 +2069,7 @@ int ptlrpc_set_wait(struct ptlrpc_request_set *set)
 	else
 		list_for_each(tmp, &set->set_requests) {
 			req = list_entry(tmp, struct ptlrpc_request,
-					     rq_set_chain);
+					 rq_set_chain);
 			if (req->rq_phase == RQ_PHASE_NEW)
 				(void)ptlrpc_send_new_req(req);
 		}
@@ -2149,7 +2143,7 @@ int ptlrpc_set_wait(struct ptlrpc_request_set *set)
 		if (rc == 0 && atomic_read(&set->set_remaining) == 0) {
 			list_for_each(tmp, &set->set_requests) {
 				req = list_entry(tmp, struct ptlrpc_request,
-						     rq_set_chain);
+						 rq_set_chain);
 				spin_lock(&req->rq_lock);
 				req->rq_invalid_rqset = 1;
 				spin_unlock(&req->rq_lock);
@@ -2568,8 +2562,7 @@ void ptlrpc_retain_replayable_request(struct ptlrpc_request *req,
 	ptlrpc_request_addref(req);
 	list_for_each_prev(tmp, &imp->imp_replay_list) {
 		struct ptlrpc_request *iter =
-			list_entry(tmp, struct ptlrpc_request,
-				       rq_replay_list);
+			list_entry(tmp, struct ptlrpc_request, rq_replay_list);
 
 		/*
 		 * We may have duplicate transnos if we create and then
@@ -2842,8 +2835,7 @@ void ptlrpc_abort_set(struct ptlrpc_request_set *set)
 
 	list_for_each_safe(pos, tmp, &set->set_requests) {
 		struct ptlrpc_request *req =
-			list_entry(pos, struct ptlrpc_request,
-				       rq_set_chain);
+			list_entry(pos, struct ptlrpc_request, rq_set_chain);
 
 		spin_lock(&req->rq_lock);
 		if (req->rq_phase != RQ_PHASE_RPC) {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index 70fcac1..9a9c4d3 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -140,7 +140,7 @@ static void deuuidify(char *uuid, const char *prefix, char **uuid_start,
 		return;
 
 	if (!strncmp(*uuid_start + *uuid_len - strlen(UUID_STR),
-		    UUID_STR, strlen(UUID_STR)))
+		     UUID_STR, strlen(UUID_STR)))
 		*uuid_len -= strlen(UUID_STR);
 }
 
@@ -344,18 +344,18 @@ void ptlrpc_invalidate_import(struct obd_import *imp)
 				rc = 0;
 			} else {
 				list_for_each_safe(tmp, n,
-						       &imp->imp_sending_list) {
+						   &imp->imp_sending_list) {
 					req = list_entry(tmp,
-							     struct ptlrpc_request,
-							     rq_list);
+							 struct ptlrpc_request,
+							 rq_list);
 					DEBUG_REQ(D_ERROR, req,
 						  "still on sending list");
 				}
 				list_for_each_safe(tmp, n,
-						       &imp->imp_delayed_list) {
+						   &imp->imp_delayed_list) {
 					req = list_entry(tmp,
-							     struct ptlrpc_request,
-							     rq_list);
+							 struct ptlrpc_request,
+							 rq_list);
 					DEBUG_REQ(D_ERROR, req,
 						  "still on delayed list");
 				}
@@ -511,7 +511,7 @@ static int import_select_connection(struct obd_import *imp)
 		 */
 		if ((conn->oic_last_attempt == 0) ||
 		    cfs_time_beforeq_64(conn->oic_last_attempt,
-				       imp->imp_last_success_conn)) {
+					imp->imp_last_success_conn)) {
 			imp_conn = conn;
 			tried_all = 0;
 			break;
@@ -1032,8 +1032,7 @@ finish:
 
 		spin_lock(&imp->imp_lock);
 		list_del(&imp->imp_conn_current->oic_item);
-		list_add(&imp->imp_conn_current->oic_item,
-			     &imp->imp_conn_list);
+		list_add(&imp->imp_conn_current->oic_item, &imp->imp_conn_list);
 		imp->imp_last_success_conn =
 			imp->imp_conn_current->oic_last_attempt;
 
@@ -1366,7 +1365,7 @@ int ptlrpc_import_recovery_state_machine(struct obd_import *imp)
 		 */
 		class_import_get(imp);
 		task = kthread_run(ptlrpc_invalidate_import_thread, imp,
-				     "ll_imp_inval");
+				   "ll_imp_inval");
 		if (IS_ERR(task)) {
 			class_import_put(imp);
 			CERROR("error starting invalidate thread: %d\n", rc);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index 0e60264..bdd9053 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -890,12 +890,12 @@ EXPORT_SYMBOL(RMF_SYMTGT);
 
 struct req_msg_field RMF_TGTUUID =
 	DEFINE_MSGF("tgtuuid", RMF_F_STRING, sizeof(struct obd_uuid) - 1, NULL,
-	NULL);
+		    NULL);
 EXPORT_SYMBOL(RMF_TGTUUID);
 
 struct req_msg_field RMF_CLUUID =
 	DEFINE_MSGF("cluuid", RMF_F_STRING, sizeof(struct obd_uuid) - 1, NULL,
-	NULL);
+		    NULL);
 EXPORT_SYMBOL(RMF_CLUUID);
 
 struct req_msg_field RMF_STRING =
@@ -1030,7 +1030,7 @@ EXPORT_SYMBOL(RMF_RCS);
 
 struct req_msg_field RMF_EAVALS_LENS =
 	DEFINE_MSGF("eavals_lens", RMF_F_STRUCT_ARRAY, sizeof(__u32),
-		lustre_swab_generic_32s, NULL);
+		    lustre_swab_generic_32s, NULL);
 EXPORT_SYMBOL(RMF_EAVALS_LENS);
 
 struct req_msg_field RMF_OBD_ID =
@@ -1141,17 +1141,17 @@ EXPORT_SYMBOL(RQF_SEC_CTX);
 
 struct req_format RQF_MGS_TARGET_REG =
 	DEFINE_REQ_FMT0("MGS_TARGET_REG", mgs_target_info_only,
-			 mgs_target_info_only);
+			mgs_target_info_only);
 EXPORT_SYMBOL(RQF_MGS_TARGET_REG);
 
 struct req_format RQF_MGS_SET_INFO =
 	DEFINE_REQ_FMT0("MGS_SET_INFO", mgs_set_info,
-			 mgs_set_info);
+			mgs_set_info);
 EXPORT_SYMBOL(RQF_MGS_SET_INFO);
 
 struct req_format RQF_MGS_CONFIG_READ =
 	DEFINE_REQ_FMT0("MGS_CONFIG_READ", mgs_config_read_client,
-			 mgs_config_read_server);
+			mgs_config_read_server);
 EXPORT_SYMBOL(RQF_MGS_CONFIG_READ);
 
 struct req_format RQF_SEQ_QUERY =
@@ -1516,32 +1516,32 @@ EXPORT_SYMBOL(RQF_OST_STATFS);
 
 struct req_format RQF_OST_SET_GRANT_INFO =
 	DEFINE_REQ_FMT0("OST_SET_GRANT_INFO", ost_grant_shrink_client,
-			 ost_body_only);
+			ost_body_only);
 EXPORT_SYMBOL(RQF_OST_SET_GRANT_INFO);
 
 struct req_format RQF_OST_GET_INFO_GENERIC =
 	DEFINE_REQ_FMT0("OST_GET_INFO", ost_get_info_generic_client,
-					ost_get_info_generic_server);
+			ost_get_info_generic_server);
 EXPORT_SYMBOL(RQF_OST_GET_INFO_GENERIC);
 
 struct req_format RQF_OST_GET_INFO_LAST_ID =
 	DEFINE_REQ_FMT0("OST_GET_INFO_LAST_ID", ost_get_info_generic_client,
-						ost_get_last_id_server);
+			ost_get_last_id_server);
 EXPORT_SYMBOL(RQF_OST_GET_INFO_LAST_ID);
 
 struct req_format RQF_OST_GET_INFO_LAST_FID =
 	DEFINE_REQ_FMT0("OST_GET_INFO_LAST_FID", obd_set_info_client,
-						 ost_get_last_fid_server);
+			ost_get_last_fid_server);
 EXPORT_SYMBOL(RQF_OST_GET_INFO_LAST_FID);
 
 struct req_format RQF_OST_SET_INFO_LAST_FID =
 	DEFINE_REQ_FMT0("OST_SET_INFO_LAST_FID", obd_set_info_client,
-						 empty);
+			empty);
 EXPORT_SYMBOL(RQF_OST_SET_INFO_LAST_FID);
 
 struct req_format RQF_OST_GET_INFO_FIEMAP =
 	DEFINE_REQ_FMT0("OST_GET_INFO_FIEMAP", ost_get_fiemap_client,
-					       ost_get_fiemap_server);
+			ost_get_fiemap_server);
 EXPORT_SYMBOL(RQF_OST_GET_INFO_FIEMAP);
 
 #if !defined(__REQ_LAYOUT_USER__)
@@ -1733,8 +1733,8 @@ int req_capsule_server_pack(struct req_capsule *pill)
 			       pill->rc_area[RCL_SERVER], NULL);
 	if (rc != 0) {
 		DEBUG_REQ(D_ERROR, pill->rc_req,
-		       "Cannot pack %d fields in format `%s': ",
-		       count, fmt->rf_name);
+			  "Cannot pack %d fields in format `%s': ",
+			  count, fmt->rf_name);
 	}
 	return rc;
 }
@@ -1751,9 +1751,8 @@ static int __req_capsule_offset(const struct req_capsule *pill,
 	int offset;
 
 	offset = field->rmf_offset[pill->rc_fmt->rf_idx][loc];
-	LASSERTF(offset > 0, "%s:%s, off=%d, loc=%d\n",
-			    pill->rc_fmt->rf_name,
-			    field->rmf_name, offset, loc);
+	LASSERTF(offset > 0, "%s:%s, off=%d, loc=%d\n", pill->rc_fmt->rf_name,
+		 field->rmf_name, offset, loc);
 	offset--;
 
 	LASSERT(0 <= offset && offset < REQ_MAX_FIELD_NR);
@@ -2213,7 +2212,7 @@ void req_capsule_shrink(struct req_capsule *pill,
 	msg = __req_msg(pill, loc);
 	len = lustre_msg_buflen(msg, offset);
 	LASSERTF(newlen <= len, "%s:%s, oldlen=%d, newlen=%d\n",
-				fmt->rf_name, field->rmf_name, len, newlen);
+		 fmt->rf_name, field->rmf_name, len, newlen);
 
 	if (loc == RCL_CLIENT)
 		pill->rc_req->rq_reqlen = lustre_shrink_msg(msg, offset, newlen,
diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
index fcaa289..cee04ef 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
@@ -454,7 +454,7 @@ static const char *nrs_state2str(enum ptlrpc_nrs_pol_state state)
  * \param[out] info  Holds returned status information
  */
 static void nrs_policy_get_info_locked(struct ptlrpc_nrs_policy *policy,
-				struct ptlrpc_nrs_pol_info *info)
+				       struct ptlrpc_nrs_pol_info *info)
 {
 	assert_spin_locked(&policy->pol_nrs->nrs_lock);
 
@@ -518,8 +518,7 @@ again:
 
 		pol_idx = 0;
 
-		list_for_each_entry(policy, &nrs->nrs_policy_list,
-					pol_list) {
+		list_for_each_entry(policy, &nrs->nrs_policy_list, pol_list) {
 			LASSERT(pol_idx < num_pols);
 
 			nrs_policy_get_info_locked(policy, &tmp);
@@ -590,7 +589,7 @@ again:
 	 *	    active: 0
 	 */
 	seq_printf(m, "%s\n",
-		      !hp ?  "\nregular_requests:" : "high_priority_requests:");
+		   !hp ?  "\nregular_requests:" : "high_priority_requests:");
 
 	for (pol_idx = 0; pol_idx < num_pols; pol_idx++) {
 		seq_printf(m,  "  - name: %s\n"
@@ -970,7 +969,7 @@ static int ptlrpc_lprocfs_timeouts_seq_show(struct seq_file *m, void *n)
 
 	if (AT_OFF) {
 		seq_printf(m, "adaptive timeouts off, using obd_timeout %u\n",
-			       obd_timeout);
+			   obd_timeout);
 		return 0;
 	}
 
@@ -981,8 +980,8 @@ static int ptlrpc_lprocfs_timeouts_seq_show(struct seq_file *m, void *n)
 		s2dhms(&ts, ktime_get_real_seconds() - worstt);
 
 		seq_printf(m, "%10s : cur %3u  worst %3u (at %lld, "
-			      DHMS_FMT" ago) ", "service",
-			      cur, worst, (s64)worstt, DHMS_VARS(&ts));
+			   DHMS_FMT " ago) ", "service",
+			   cur, worst, (s64)worstt, DHMS_VARS(&ts));
 
 		lprocfs_at_hist_helper(m, &svcpt->scp_at_estimate);
 	}
@@ -1297,7 +1296,7 @@ int lprocfs_rd_pinger_recov(struct seq_file *m, void *n)
 EXPORT_SYMBOL(lprocfs_rd_pinger_recov);
 
 int lprocfs_wr_pinger_recov(struct file *file, const char __user *buffer,
-		      size_t count, loff_t *off)
+			    size_t count, loff_t *off)
 {
 	struct obd_device *obd = ((struct seq_file *)file->private_data)->private;
 	struct client_obd *cli = &obd->u.cli;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
index c5bbf7b..10b8fe8 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
@@ -507,11 +507,11 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	 */
 	LASSERT(!request->rq_receiving_reply);
 	LASSERT(!((lustre_msg_get_flags(request->rq_reqmsg) & MSG_REPLAY) &&
-		(request->rq_import->imp_state == LUSTRE_IMP_FULL)));
+		  (request->rq_import->imp_state == LUSTRE_IMP_FULL)));
 
 	if (unlikely(obd && obd->obd_fail)) {
 		CDEBUG(D_HA, "muting rpc for failed imp obd %s\n",
-			obd->obd_name);
+		       obd->obd_name);
 		/* this prevents us from waiting in ptlrpc_queue_wait */
 		spin_lock(&request->rq_lock);
 		request->rq_err = 1;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/nrs.c b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
index 58e5d86..1244751 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/nrs.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/nrs.c
@@ -304,7 +304,7 @@ static void nrs_policy_put_locked(struct ptlrpc_nrs_policy *policy)
 
 	policy->pol_ref--;
 	if (unlikely(policy->pol_ref == 0 &&
-	    policy->pol_state == NRS_POL_STATE_STOPPING))
+		     policy->pol_state == NRS_POL_STATE_STOPPING))
 		nrs_policy_stop0(policy);
 }
 
@@ -319,7 +319,7 @@ static void nrs_policy_put(struct ptlrpc_nrs_policy *policy)
  * Find and return a policy by name.
  */
 static struct ptlrpc_nrs_policy *nrs_policy_find_locked(struct ptlrpc_nrs *nrs,
-							 char *name)
+							char *name)
 {
 	struct ptlrpc_nrs_policy *tmp;
 
@@ -797,7 +797,7 @@ static void ptlrpc_nrs_req_add_nolock(struct ptlrpc_request *req)
 	 */
 	if (unlikely(list_empty(&policy->pol_list_queued)))
 		list_add_tail(&policy->pol_list_queued,
-				  &policy->pol_nrs->nrs_policy_queued);
+			      &policy->pol_nrs->nrs_policy_queued);
 }
 
 /**
@@ -978,8 +978,7 @@ again:
 	nrs = nrs_svcpt2nrs(svcpt, hp);
 	nrs->nrs_stopping = 1;
 
-	list_for_each_entry_safe(policy, tmp, &nrs->nrs_policy_list,
-				     pol_list) {
+	list_for_each_entry_safe(policy, tmp, &nrs->nrs_policy_list, pol_list) {
 		rc = nrs_policy_unregister(nrs, policy->pol_desc->pd_name);
 		LASSERT(rc == 0);
 	}
@@ -1100,7 +1099,7 @@ static int ptlrpc_nrs_policy_register(struct ptlrpc_nrs_pol_conf *conf)
 	LASSERT(conf->nc_ops);
 	LASSERT(conf->nc_compat);
 	LASSERT(ergo(conf->nc_compat == nrs_policy_compat_one,
-		conf->nc_compat_svc_name));
+		     conf->nc_compat_svc_name));
 	LASSERT(ergo((conf->nc_flags & PTLRPC_NRS_FL_REG_EXTERN) != 0,
 		     conf->nc_owner));
 
@@ -1414,7 +1413,7 @@ static void nrs_request_removed(struct ptlrpc_nrs_policy *policy)
 			policy->pol_nrs->nrs_req_queued);
 
 		list_move_tail(&policy->pol_list_queued,
-				   &policy->pol_nrs->nrs_policy_queued);
+			       &policy->pol_nrs->nrs_policy_queued);
 	}
 }
 
@@ -1446,8 +1445,7 @@ ptlrpc_nrs_req_get_nolock0(struct ptlrpc_service_part *svcpt, bool hp,
 	 * Always try to drain requests from all NRS polices even if they are
 	 * inactive, because the user can change policy status at runtime.
 	 */
-	list_for_each_entry(policy, &nrs->nrs_policy_queued,
-				pol_list_queued) {
+	list_for_each_entry(policy, &nrs->nrs_policy_queued, pol_list_queued) {
 		nrq = nrs_request_get(policy, peek, force);
 		if (nrq) {
 			if (likely(!peek)) {
@@ -1599,8 +1597,7 @@ void ptlrpc_nrs_fini(void)
 	struct ptlrpc_nrs_pol_desc *desc;
 	struct ptlrpc_nrs_pol_desc *tmp;
 
-	list_for_each_entry_safe(desc, tmp, &nrs_core.nrs_policies,
-				     pd_list) {
+	list_for_each_entry_safe(desc, tmp, &nrs_core.nrs_policies, pd_list) {
 		list_del_init(&desc->pd_list);
 		kfree(desc);
 	}
diff --git a/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c b/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c
index 0d8da35..b123a93 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/nrs_fifo.c
@@ -163,7 +163,7 @@ struct ptlrpc_nrs_request *nrs_fifo_req_get(struct ptlrpc_nrs_policy *policy,
 
 	nrq = unlikely(list_empty(&head->fh_list)) ? NULL :
 	      list_entry(head->fh_list.next, struct ptlrpc_nrs_request,
-			     nr_u.fifo.fr_list);
+			 nr_u.fifo.fr_list);
 
 	if (likely(!peek && nrq)) {
 		struct ptlrpc_request *req = container_of(nrq,
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index f3ac810..492d63f 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -280,7 +280,7 @@ lustre_get_emerg_rs(struct ptlrpc_service_part *svcpt)
 	}
 
 	rs = list_entry(svcpt->scp_rep_idle.next,
-			    struct ptlrpc_reply_state, rs_list);
+			struct ptlrpc_reply_state, rs_list);
 	list_del(&rs->rs_list);
 
 	spin_unlock(&svcpt->scp_rep_lock);
@@ -1908,7 +1908,7 @@ static void print_lum(struct lov_user_md *lum)
 	CDEBUG(D_OTHER, "\tlmm_stripe_size: %#x\n", lum->lmm_stripe_size);
 	CDEBUG(D_OTHER, "\tlmm_stripe_count: %#x\n", lum->lmm_stripe_count);
 	CDEBUG(D_OTHER, "\tlmm_stripe_offset/lmm_layout_gen: %#x\n",
-			lum->lmm_stripe_offset);
+	       lum->lmm_stripe_offset);
 }
 
 static void lustre_swab_lmm_oi(struct ost_id *oi)
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pinger.c b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
index 44bf026..8a86931 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pinger.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
@@ -242,7 +242,7 @@ static int ptlrpc_pinger_main(void *arg)
 		list_for_each(iter, &pinger_imports) {
 			struct obd_import *imp =
 				list_entry(iter, struct obd_import,
-					       imp_pinger_chain);
+					   imp_pinger_chain);
 
 			ptlrpc_pinger_process_import(imp, this_ping);
 			/* obd_timeout might have changed */
@@ -404,7 +404,8 @@ EXPORT_SYMBOL(ptlrpc_pinger_del_import);
  * be called when timeout happens.
  */
 static struct timeout_item *ptlrpc_new_timeout(int time,
-	enum timeout_event event, timeout_cb_t cb, void *data)
+					       enum timeout_event event,
+					       timeout_cb_t cb, void *data)
 {
 	struct timeout_item *ti;
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
index 0c36663..00b19ab 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c
@@ -207,11 +207,10 @@ static int ptlrpcd_steal_rqset(struct ptlrpc_request_set *des,
 	if (likely(!list_empty(&src->set_new_requests))) {
 		list_for_each_safe(pos, tmp, &src->set_new_requests) {
 			req = list_entry(pos, struct ptlrpc_request,
-					     rq_set_chain);
+					 rq_set_chain);
 			req->rq_set = des;
 		}
-		list_splice_init(&src->set_new_requests,
-				     &des->set_requests);
+		list_splice_init(&src->set_new_requests, &des->set_requests);
 		rc = atomic_read(&src->set_new_count);
 		atomic_add(rc, &des->set_remaining);
 		atomic_set(&src->set_new_count, 0);
@@ -285,9 +284,9 @@ static int ptlrpcd_check(struct lu_env *env, struct ptlrpcd_ctl *pc)
 		spin_lock(&set->set_new_req_lock);
 		if (likely(!list_empty(&set->set_new_requests))) {
 			list_splice_init(&set->set_new_requests,
-					     &set->set_requests);
+					 &set->set_requests);
 			atomic_add(atomic_read(&set->set_new_count),
-				       &set->set_remaining);
+				   &set->set_remaining);
 			atomic_set(&set->set_new_count, 0);
 			/*
 			 * Need to calculate its timeout.
diff --git a/drivers/staging/lustre/lustre/ptlrpc/recover.c b/drivers/staging/lustre/lustre/ptlrpc/recover.c
index e5d344d..5f27d9c 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/recover.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/recover.c
@@ -107,8 +107,7 @@ int ptlrpc_replay_next(struct obd_import *imp, int *inflight)
 	/* Replay all the committed open requests on committed_list first */
 	if (!list_empty(&imp->imp_committed_list)) {
 		tmp = imp->imp_committed_list.prev;
-		req = list_entry(tmp, struct ptlrpc_request,
-				     rq_replay_list);
+		req = list_entry(tmp, struct ptlrpc_request, rq_replay_list);
 
 		/* The last request on committed_list hasn't been replayed */
 		if (req->rq_transno > last_transno) {
@@ -195,8 +194,7 @@ int ptlrpc_resend(struct obd_import *imp)
 		return -1;
 	}
 
-	list_for_each_entry_safe(req, next, &imp->imp_sending_list,
-				     rq_list) {
+	list_for_each_entry_safe(req, next, &imp->imp_sending_list, rq_list) {
 		LASSERTF((long)req > PAGE_CACHE_SIZE && req != LP_POISON,
 			 "req %p bad\n", req);
 		LASSERTF(req->rq_type != LI_POISON, "req %p freed\n", req);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
index 85f8f7c..14d0fc7 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
@@ -610,7 +610,7 @@ again:
 
 	if (sec->ps_flvr.sf_rpc != req->rq_flvr.sf_rpc) {
 		CDEBUG(D_SEC, "req %p: flavor has changed %x -> %x\n",
-		      req, req->rq_flvr.sf_rpc, sec->ps_flvr.sf_rpc);
+		       req, req->rq_flvr.sf_rpc, sec->ps_flvr.sf_rpc);
 		req_off_ctx_list(req, ctx);
 		sptlrpc_req_replace_dead_ctx(req);
 		ctx = req->rq_cli_ctx;
@@ -1996,8 +1996,8 @@ int sptlrpc_svc_alloc_rs(struct ptlrpc_request *req, int msglen)
 		   msglen + sizeof(struct ptlrpc_reply_state)) {
 			/* Just return failure if the size is too big */
 			CERROR("size of message is too big (%zd), %d allowed",
-				msglen + sizeof(struct ptlrpc_reply_state),
-				svcpt->scp_service->srv_max_reply_size);
+			       msglen + sizeof(struct ptlrpc_reply_state),
+			       svcpt->scp_service->srv_max_reply_size);
 			return -ENOMEM;
 		}
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
index 93b91bf..ef68afe 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
@@ -467,7 +467,7 @@ static void sptlrpc_conf_free_rsets(struct sptlrpc_conf *conf)
 	sptlrpc_rule_set_free(&conf->sc_rset);
 
 	list_for_each_entry_safe(conf_tgt, conf_tgt_next,
-				     &conf->sc_tgts, sct_list) {
+				 &conf->sc_tgts, sct_list) {
 		sptlrpc_rule_set_free(&conf_tgt->sct_rset);
 		list_del(&conf_tgt->sct_list);
 		kfree(conf_tgt);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
index d5afc4f..9082da0 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
@@ -109,7 +109,7 @@ static void sec_process_ctx_list(void)
 
 	while (!list_empty(&sec_gc_ctx_list)) {
 		ctx = list_entry(sec_gc_ctx_list.next,
-				     struct ptlrpc_cli_ctx, cc_gc_chain);
+				 struct ptlrpc_cli_ctx, cc_gc_chain);
 		list_del_init(&ctx->cc_gc_chain);
 		spin_unlock(&sec_gc_ctx_list_lock);
 
@@ -131,7 +131,7 @@ static void sec_do_gc(struct ptlrpc_sec *sec)
 
 	if (unlikely(sec->ps_gc_next == 0)) {
 		CDEBUG(D_SEC, "sec %p(%s) has 0 gc time\n",
-		      sec, sec->ps_policy->sp_name);
+		       sec, sec->ps_policy->sp_name);
 		return;
 	}
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 89039bf..7941540 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -299,8 +299,8 @@ ptlrpc_server_post_idle_rqbds(struct ptlrpc_service_part *svcpt)
 		}
 
 		rqbd = list_entry(svcpt->scp_rqbd_idle.next,
-				      struct ptlrpc_request_buffer_desc,
-				      rqbd_list);
+				  struct ptlrpc_request_buffer_desc,
+				  rqbd_list);
 		list_del(&rqbd->rqbd_list);
 
 		/* assume we will post successfully */
@@ -770,8 +770,8 @@ static void ptlrpc_server_drop_request(struct ptlrpc_request *req)
 		 */
 		while (svcpt->scp_hist_nrqbds > svc->srv_hist_nrqbds_cpt_max) {
 			rqbd = list_entry(svcpt->scp_hist_rqbds.next,
-					      struct ptlrpc_request_buffer_desc,
-					      rqbd_list);
+					  struct ptlrpc_request_buffer_desc,
+					  rqbd_list);
 
 			list_del(&rqbd->rqbd_list);
 			svcpt->scp_hist_nrqbds--;
@@ -781,7 +781,7 @@ static void ptlrpc_server_drop_request(struct ptlrpc_request *req)
 			 */
 			list_for_each(tmp, &rqbd->rqbd_reqs) {
 				req = list_entry(tmp, struct ptlrpc_request,
-						     rq_list);
+						 rq_list);
 				/* Track the highest culled req seq */
 				if (req->rq_history_seq >
 				    svcpt->scp_hist_seq_culled) {
@@ -795,8 +795,8 @@ static void ptlrpc_server_drop_request(struct ptlrpc_request *req)
 
 			list_for_each_safe(tmp, nxt, &rqbd->rqbd_reqs) {
 				req = list_entry(rqbd->rqbd_reqs.next,
-						     struct ptlrpc_request,
-						     rq_list);
+						 struct ptlrpc_request,
+						 rq_list);
 				list_del(&req->rq_list);
 				ptlrpc_server_free_request(req);
 			}
@@ -808,8 +808,7 @@ static void ptlrpc_server_drop_request(struct ptlrpc_request *req)
 			 */
 			LASSERT(atomic_read(&rqbd->rqbd_req.rq_refcount) ==
 				0);
-			list_add_tail(&rqbd->rqbd_list,
-					  &svcpt->scp_rqbd_idle);
+			list_add_tail(&rqbd->rqbd_list, &svcpt->scp_rqbd_idle);
 		}
 
 		spin_unlock(&svcpt->scp_lock);
@@ -957,12 +956,11 @@ static int ptlrpc_at_add_timed(struct ptlrpc_request *req)
 		/* latest rpcs will have the latest deadlines in the list,
 		 * so search backward.
 		 */
-		list_for_each_entry_reverse(rq,
-						&array->paa_reqs_array[index],
-						rq_timed_list) {
+		list_for_each_entry_reverse(rq, &array->paa_reqs_array[index],
+					    rq_timed_list) {
 			if (req->rq_deadline >= rq->rq_deadline) {
 				list_add(&req->rq_timed_list,
-					     &rq->rq_timed_list);
+					 &rq->rq_timed_list);
 				break;
 			}
 		}
@@ -970,8 +968,7 @@ static int ptlrpc_at_add_timed(struct ptlrpc_request *req)
 
 	/* Add the request at the head of the list */
 	if (list_empty(&req->rq_timed_list))
-		list_add(&req->rq_timed_list,
-			     &array->paa_reqs_array[index]);
+		list_add(&req->rq_timed_list, &array->paa_reqs_array[index]);
 
 	spin_lock(&req->rq_lock);
 	req->rq_at_linked = 1;
@@ -1179,9 +1176,8 @@ static void ptlrpc_at_check_timed(struct ptlrpc_service_part *svcpt)
 	count = array->paa_count;
 	while (count > 0) {
 		count -= array->paa_reqs_count[index];
-		list_for_each_entry_safe(rq, n,
-					     &array->paa_reqs_array[index],
-					     rq_timed_list) {
+		list_for_each_entry_safe(rq, n, &array->paa_reqs_array[index],
+					 rq_timed_list) {
 			if (rq->rq_deadline > now + at_early_margin) {
 				/* update the earliest deadline */
 				if (deadline == -1 ||
@@ -1229,7 +1225,7 @@ static void ptlrpc_at_check_timed(struct ptlrpc_service_part *svcpt)
 	 */
 	while (!list_empty(&work_list)) {
 		rq = list_entry(work_list.next, struct ptlrpc_request,
-				    rq_timed_list);
+				rq_timed_list);
 		list_del_init(&rq->rq_timed_list);
 
 		if (ptlrpc_at_send_early_reply(rq) == 0)
@@ -1278,8 +1274,7 @@ static int ptlrpc_server_hpreq_init(struct ptlrpc_service_part *svcpt,
 		}
 
 		spin_lock_bh(&req->rq_export->exp_rpc_lock);
-		list_add(&req->rq_exp_list,
-			     &req->rq_export->exp_hp_rpcs);
+		list_add(&req->rq_exp_list, &req->rq_export->exp_hp_rpcs);
 		spin_unlock_bh(&req->rq_export->exp_rpc_lock);
 	}
 
@@ -1479,7 +1474,7 @@ ptlrpc_server_handle_req_in(struct ptlrpc_service_part *svcpt,
 	}
 
 	req = list_entry(svcpt->scp_req_incoming.next,
-			     struct ptlrpc_request, rq_list);
+			 struct ptlrpc_request, rq_list);
 	list_del_init(&req->rq_list);
 	svcpt->scp_nreqs_incoming--;
 	/* Consider this still a "queued" request as far as stats are
@@ -2062,7 +2057,7 @@ static int ptlrpc_main(void *arg)
 			continue;
 
 		CERROR("Failed to post rqbd for %s on CPT %d: %d\n",
-			svc->srv_name, svcpt->scp_cpt, rc);
+		       svc->srv_name, svcpt->scp_cpt, rc);
 		goto out_srv_fini;
 	}
 
@@ -2235,9 +2230,8 @@ static int ptlrpc_hr_main(void *arg)
 		while (!list_empty(&replies)) {
 			struct ptlrpc_reply_state *rs;
 
-			rs = list_entry(replies.prev,
-					    struct ptlrpc_reply_state,
-					    rs_list);
+			rs = list_entry(replies.prev, struct ptlrpc_reply_state,
+					rs_list);
 			list_del_init(&rs->rs_list);
 			ptlrpc_handle_rs(rs);
 		}
@@ -2268,8 +2262,8 @@ static void ptlrpc_stop_hr_threads(void)
 		if (!hrp->hrp_thrs)
 			continue; /* uninitialized */
 		wait_event(ptlrpc_hr.hr_waitq,
-			       atomic_read(&hrp->hrp_nstopped) ==
-			       atomic_read(&hrp->hrp_nstarted));
+			   atomic_read(&hrp->hrp_nstopped) ==
+			   atomic_read(&hrp->hrp_nstarted));
 	}
 }
 
@@ -2287,17 +2281,16 @@ static int ptlrpc_start_hr_threads(void)
 			struct task_struct *task;
 
 			task = kthread_run(ptlrpc_hr_main,
-						 &hrp->hrp_thrs[j],
-						 "ptlrpc_hr%02d_%03d",
-						 hrp->hrp_cpt,
-						 hrt->hrt_id);
+					   &hrp->hrp_thrs[j],
+					   "ptlrpc_hr%02d_%03d",
+					   hrp->hrp_cpt, hrt->hrt_id);
 			if (IS_ERR(task)) {
 				rc = PTR_ERR(task);
 				break;
 			}
 		}
 		wait_event(ptlrpc_hr.hr_waitq,
-			       atomic_read(&hrp->hrp_nstarted) == j);
+			   atomic_read(&hrp->hrp_nstarted) == j);
 
 		if (rc < 0) {
 			CERROR("cannot start reply handler thread %d:%d: rc = %d\n",
@@ -2330,7 +2323,7 @@ static void ptlrpc_svcpt_stop_threads(struct ptlrpc_service_part *svcpt)
 
 	while (!list_empty(&svcpt->scp_threads)) {
 		thread = list_entry(svcpt->scp_threads.next,
-					struct ptlrpc_thread, t_link);
+				    struct ptlrpc_thread, t_link);
 		if (thread_is_stopped(thread)) {
 			list_del(&thread->t_link);
 			list_add(&thread->t_link, &zombie);
@@ -2691,7 +2684,7 @@ ptlrpc_service_purge_all(struct ptlrpc_service *svc)
 		spin_lock(&svcpt->scp_rep_lock);
 		while (!list_empty(&svcpt->scp_rep_active)) {
 			rs = list_entry(svcpt->scp_rep_active.next,
-					    struct ptlrpc_reply_state, rs_list);
+					struct ptlrpc_reply_state, rs_list);
 			spin_lock(&rs->rs_lock);
 			ptlrpc_schedule_difficult_reply(rs);
 			spin_unlock(&rs->rs_lock);
@@ -2704,7 +2697,7 @@ ptlrpc_service_purge_all(struct ptlrpc_service *svc)
 		 */
 		while (!list_empty(&svcpt->scp_req_incoming)) {
 			req = list_entry(svcpt->scp_req_incoming.next,
-					     struct ptlrpc_request, rq_list);
+					 struct ptlrpc_request, rq_list);
 
 			list_del(&req->rq_list);
 			svcpt->scp_nreqs_incoming--;
@@ -2730,16 +2723,16 @@ ptlrpc_service_purge_all(struct ptlrpc_service *svc)
 
 		while (!list_empty(&svcpt->scp_rqbd_idle)) {
 			rqbd = list_entry(svcpt->scp_rqbd_idle.next,
-					      struct ptlrpc_request_buffer_desc,
-					      rqbd_list);
+					  struct ptlrpc_request_buffer_desc,
+					  rqbd_list);
 			ptlrpc_free_rqbd(rqbd);
 		}
 		ptlrpc_wait_replies(svcpt);
 
 		while (!list_empty(&svcpt->scp_rep_idle)) {
 			rs = list_entry(svcpt->scp_rep_idle.next,
-					    struct ptlrpc_reply_state,
-					    rs_list);
+					struct ptlrpc_reply_state,
+					rs_list);
 			list_del(&rs->rs_list);
 			kvfree(rs);
 		}
-- 
2.1.0
