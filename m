From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:34 -0400
Subject: [lustre-devel] [PATCH 095/124] staging: lustre: ptlrpc: fix race
	between connect vs resend
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-96-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Alexander Boyko <alexander_boyko@xyratex.com>, James Simmons <jsimmons@infradead.org>

From: Alexander Boyko <alexander_boyko@xyratex.com>

Buggy code at ptlrpc_connect_interpret()
finish:
    rc = ptlrpc_import_recovery_state_machine(imp);
    ...
    Set import connection flags
When import has FULL state ptlrpc_import_recovery_state_machine()
wakeup all waiters on import and all delayed request, which was
resented. And it could happened that request was send without
updated flags and AT is disabled. If such request is in progress
on the server, server drop the new instance, and could do early reply
for it. But this early reply confuse client, cause it wait real
reply(no AT for this request). Client try to touch buffer outside
reply and got EPROTO error.
The same bug existed for initital connect too. Import became FULL
before import connection flags was set.

Signed-off-by: Alexander Boyko <alexander_boyko@xyratex.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5528
Xyratex-bug-id: MRP-2034
Reviewed-on: http://review.whamcloud.com/11723
Reviewed-by: Li Wei <wei.g.li@intel.com>
Reviewed-by: Alexander Boyko <alexander.boyko@seagate.com>
Reviewed-by: Liang Zhen <liang.zhen@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/import.c |  307 +++++++++++++------------
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c |   28 ++-
 2 files changed, 179 insertions(+), 156 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index 17f3fec..2e107e8 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -752,6 +752,153 @@ static int ptlrpc_busy_reconnect(int rc)
 	return (rc == -EBUSY) || (rc == -EAGAIN);
 }
 
+static int ptlrpc_connect_set_flags(struct obd_import *imp,
+				    struct obd_connect_data *ocd,
+				    u64 old_connect_flags,
+				    struct obd_export *exp, int init_connect)
+{
+	struct client_obd *cli = &imp->imp_obd->u.cli;
+	static bool warned;
+
+	if ((imp->imp_connect_flags_orig & OBD_CONNECT_IBITS) &&
+	    !(ocd->ocd_connect_flags & OBD_CONNECT_IBITS)) {
+		LCONSOLE_WARN("%s: MDS %s does not support ibits lock, either very old or invalid: requested %#llx, replied %#llx\n",
+			      imp->imp_obd->obd_name,
+			      imp->imp_connection->c_remote_uuid.uuid,
+			      imp->imp_connect_flags_orig,
+			      ocd->ocd_connect_flags);
+		return -EPROTO;
+	}
+
+	spin_lock(&imp->imp_lock);
+	list_del(&imp->imp_conn_current->oic_item);
+	list_add(&imp->imp_conn_current->oic_item, &imp->imp_conn_list);
+	imp->imp_last_success_conn = imp->imp_conn_current->oic_last_attempt;
+
+	spin_unlock(&imp->imp_lock);
+
+	if (!warned && (ocd->ocd_connect_flags & OBD_CONNECT_VERSION) &&
+	    (ocd->ocd_version > LUSTRE_VERSION_CODE +
+				LUSTRE_VERSION_OFFSET_WARN ||
+	     ocd->ocd_version < LUSTRE_VERSION_CODE -
+				LUSTRE_VERSION_OFFSET_WARN)) {
+		/*
+		 * Sigh, some compilers do not like #ifdef in the middle
+		 * of macro arguments
+		 */
+		const char *older = "older than client. Consider upgrading server";
+		const char *newer = "newer than client. Consider recompiling application";
+
+		LCONSOLE_WARN("Server %s version (%d.%d.%d.%d) is much %s (%s)\n",
+			      obd2cli_tgt(imp->imp_obd),
+			      OBD_OCD_VERSION_MAJOR(ocd->ocd_version),
+			      OBD_OCD_VERSION_MINOR(ocd->ocd_version),
+			      OBD_OCD_VERSION_PATCH(ocd->ocd_version),
+			      OBD_OCD_VERSION_FIX(ocd->ocd_version),
+			      ocd->ocd_version > LUSTRE_VERSION_CODE ?
+			      newer : older, LUSTRE_VERSION_STRING);
+		warned = true;
+	}
+
+#if LUSTRE_VERSION_CODE < OBD_OCD_VERSION(3, 0, 53, 0)
+	/*
+	 * Check if server has LU-1252 fix applied to not always swab
+	 * the IR MNE entries. Do this only once per connection.  This
+	 * fixup is version-limited, because we don't want to carry the
+	 * OBD_CONNECT_MNE_SWAB flag around forever, just so long as we
+	 * need interop with unpatched 2.2 servers.  For newer servers,
+	 * the client will do MNE swabbing only as needed.  LU-1644
+	 */
+	if (unlikely((ocd->ocd_connect_flags & OBD_CONNECT_VERSION) &&
+		     !(ocd->ocd_connect_flags & OBD_CONNECT_MNE_SWAB) &&
+		     OBD_OCD_VERSION_MAJOR(ocd->ocd_version) == 2 &&
+		     OBD_OCD_VERSION_MINOR(ocd->ocd_version) == 2 &&
+		     OBD_OCD_VERSION_PATCH(ocd->ocd_version) < 55 &&
+		     !strcmp(imp->imp_obd->obd_type->typ_name,
+			     LUSTRE_MGC_NAME)))
+		imp->imp_need_mne_swab = 1;
+	else /* clear if server was upgraded since last connect */
+		imp->imp_need_mne_swab = 0;
+#endif
+
+	if (ocd->ocd_connect_flags & OBD_CONNECT_CKSUM) {
+		/*
+		 * We sent to the server ocd_cksum_types with bits set
+		 * for algorithms we understand. The server masked off
+		 * the checksum types it doesn't support
+		 */
+		if (!(ocd->ocd_cksum_types & cksum_types_supported_client())) {
+			LCONSOLE_WARN("The negotiation of the checksum algorithm to use with server %s failed (%x/%x), disabling checksums\n",
+				      obd2cli_tgt(imp->imp_obd),
+				      ocd->ocd_cksum_types,
+				      cksum_types_supported_client());
+			cli->cl_checksum = 0;
+			cli->cl_supp_cksum_types = OBD_CKSUM_ADLER;
+		} else {
+			cli->cl_supp_cksum_types = ocd->ocd_cksum_types;
+		}
+	} else {
+		/*
+		 * The server does not support OBD_CONNECT_CKSUM.
+		 * Enforce ADLER for backward compatibility
+		 */
+		cli->cl_supp_cksum_types = OBD_CKSUM_ADLER;
+	}
+	cli->cl_cksum_type = cksum_type_select(cli->cl_supp_cksum_types);
+
+	if (ocd->ocd_connect_flags & OBD_CONNECT_BRW_SIZE)
+		cli->cl_max_pages_per_rpc =
+			min(ocd->ocd_brw_size >> PAGE_SHIFT,
+			    cli->cl_max_pages_per_rpc);
+	else if (imp->imp_connect_op == MDS_CONNECT ||
+		 imp->imp_connect_op == MGS_CONNECT)
+		cli->cl_max_pages_per_rpc = 1;
+
+	LASSERT((cli->cl_max_pages_per_rpc <= PTLRPC_MAX_BRW_PAGES) &&
+		(cli->cl_max_pages_per_rpc > 0));
+
+	client_adjust_max_dirty(cli);
+
+	/*
+	 * Reset ns_connect_flags only for initial connect. It might be
+	 * changed in while using FS and if we reset it in reconnect
+	 * this leads to losing user settings done before such as
+	 * disable lru_resize, etc.
+	 */
+	if (old_connect_flags != exp_connect_flags(exp) || init_connect) {
+		CDEBUG(D_HA, "%s: Resetting ns_connect_flags to server flags: %#llx\n",
+		       imp->imp_obd->obd_name, ocd->ocd_connect_flags);
+		imp->imp_obd->obd_namespace->ns_connect_flags =
+			ocd->ocd_connect_flags;
+		imp->imp_obd->obd_namespace->ns_orig_connect_flags =
+			ocd->ocd_connect_flags;
+	}
+
+	if ((ocd->ocd_connect_flags & OBD_CONNECT_AT) &&
+	    (imp->imp_msg_magic == LUSTRE_MSG_MAGIC_V2))
+		/*
+		 * We need a per-message support flag, because
+		 * a. we don't know if the incoming connect reply
+		 *    supports AT or not (in reply_in_callback)
+		 *    until we unpack it.
+		 * b. failovered server means export and flags are gone
+		 *    (in ptlrpc_send_reply).
+		 *    Can only be set when we know AT is supported at
+		 *    both ends
+		 */
+		imp->imp_msghdr_flags |= MSGHDR_AT_SUPPORT;
+	else
+		imp->imp_msghdr_flags &= ~MSGHDR_AT_SUPPORT;
+
+	if ((ocd->ocd_connect_flags & OBD_CONNECT_FULL20) &&
+	    (imp->imp_msg_magic == LUSTRE_MSG_MAGIC_V2))
+		imp->imp_msghdr_flags |= MSGHDR_CKSUM_INCOMPAT18;
+	else
+		imp->imp_msghdr_flags &= ~MSGHDR_CKSUM_INCOMPAT18;
+
+	return 0;
+}
+
 /**
  * interpret_reply callback for connect RPCs.
  * Looks into returned status of connect operation and decides
@@ -764,7 +911,6 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 {
 	struct ptlrpc_connect_async_args *aa = data;
 	struct obd_import *imp = request->rq_import;
-	struct client_obd *cli = &imp->imp_obd->u.cli;
 	struct lustre_handle old_hdl;
 	__u64 old_connect_flags;
 	int msg_flags;
@@ -844,7 +990,6 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 	old_connect_flags = exp_connect_flags(exp);
 	exp->exp_connect_data = *ocd;
 	imp->imp_obd->obd_self_export->exp_connect_data = *ocd;
-	class_export_put(exp);
 
 	/*
 	 * The net statistics after (re-)connect is not valid anymore,
@@ -854,6 +999,13 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 	ptlrpc_at_adj_net_latency(request,
 				  lustre_msg_get_service_time(request->rq_repmsg));
 
+	/* Import flags should be updated before waking import at FULL state */
+	rc = ptlrpc_connect_set_flags(imp, ocd, old_connect_flags, exp,
+				      aa->pcaa_initial_connect);
+	class_export_put(exp);
+	if (rc)
+		goto out;
+
 	obd_import_event(imp->imp_obd, imp, IMP_EVENT_OCD);
 
 	if (aa->pcaa_initial_connect) {
@@ -997,150 +1149,13 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 
 finish:
 	rc = ptlrpc_import_recovery_state_machine(imp);
-	if (rc != 0) {
-		if (rc == -ENOTCONN) {
-			CDEBUG(D_HA, "evicted/aborted by %s@%s during recovery; invalidating and reconnecting\n",
-			       obd2cli_tgt(imp->imp_obd),
-			       imp->imp_connection->c_remote_uuid.uuid);
-			ptlrpc_connect_import(imp);
-			imp->imp_connect_tried = 1;
-			return 0;
-		}
-	} else {
-		static bool warned;
-
-		spin_lock(&imp->imp_lock);
-		list_del(&imp->imp_conn_current->oic_item);
-		list_add(&imp->imp_conn_current->oic_item, &imp->imp_conn_list);
-		imp->imp_last_success_conn =
-			imp->imp_conn_current->oic_last_attempt;
-
-		spin_unlock(&imp->imp_lock);
-
-		if ((imp->imp_connect_flags_orig & OBD_CONNECT_IBITS) &&
-		    !(ocd->ocd_connect_flags & OBD_CONNECT_IBITS)) {
-			LCONSOLE_WARN("%s: MDS %s does not support ibits lock, either very old or invalid: requested %llx, replied %llx\n",
-				      imp->imp_obd->obd_name,
-				      imp->imp_connection->c_remote_uuid.uuid,
-				      imp->imp_connect_flags_orig,
-				      ocd->ocd_connect_flags);
-			rc = -EPROTO;
-			goto out;
-		}
-
-		if (!warned && (ocd->ocd_connect_flags & OBD_CONNECT_VERSION) &&
-		    (ocd->ocd_version > LUSTRE_VERSION_CODE +
-					LUSTRE_VERSION_OFFSET_WARN ||
-		     ocd->ocd_version < LUSTRE_VERSION_CODE -
-					LUSTRE_VERSION_OFFSET_WARN)) {
-			/* Sigh, some compilers do not like #ifdef in the middle
-			 * of macro arguments
-			 */
-			const char *older = "older than client. Consider upgrading server";
-			const char *newer = "newer than client. Consider recompiling application";
-
-			LCONSOLE_WARN("Server %s version (%d.%d.%d.%d) is much %s (%s)\n",
-				      obd2cli_tgt(imp->imp_obd),
-				      OBD_OCD_VERSION_MAJOR(ocd->ocd_version),
-				      OBD_OCD_VERSION_MINOR(ocd->ocd_version),
-				      OBD_OCD_VERSION_PATCH(ocd->ocd_version),
-				      OBD_OCD_VERSION_FIX(ocd->ocd_version),
-				      ocd->ocd_version > LUSTRE_VERSION_CODE ?
-				      newer : older, LUSTRE_VERSION_STRING);
-			warned = true;
-		}
-
-#if OBD_OCD_VERSION(3, 0, 53, 0) > LUSTRE_VERSION_CODE
-		/* Check if server has LU-1252 fix applied to not always swab
-		 * the IR MNE entries. Do this only once per connection.  This
-		 * fixup is version-limited, because we don't want to carry the
-		 * OBD_CONNECT_MNE_SWAB flag around forever, just so long as we
-		 * need interop with unpatched 2.2 servers.  For newer servers,
-		 * the client will do MNE swabbing only as needed.  LU-1644
-		 */
-		if (unlikely((ocd->ocd_connect_flags & OBD_CONNECT_VERSION) &&
-			     !(ocd->ocd_connect_flags & OBD_CONNECT_MNE_SWAB) &&
-			     OBD_OCD_VERSION_MAJOR(ocd->ocd_version) == 2 &&
-			     OBD_OCD_VERSION_MINOR(ocd->ocd_version) == 2 &&
-			     OBD_OCD_VERSION_PATCH(ocd->ocd_version) < 55 &&
-			     strcmp(imp->imp_obd->obd_type->typ_name,
-				    LUSTRE_MGC_NAME) == 0))
-			imp->imp_need_mne_swab = 1;
-		else /* clear if server was upgraded since last connect */
-			imp->imp_need_mne_swab = 0;
-#endif
-
-		if (ocd->ocd_connect_flags & OBD_CONNECT_CKSUM) {
-			/* We sent to the server ocd_cksum_types with bits set
-			 * for algorithms we understand. The server masked off
-			 * the checksum types it doesn't support
-			 */
-			if ((ocd->ocd_cksum_types &
-			     cksum_types_supported_client()) == 0) {
-				LCONSOLE_WARN("The negotiation of the checksum algorithm to use with server %s failed (%x/%x), disabling checksums\n",
-					      obd2cli_tgt(imp->imp_obd),
-					      ocd->ocd_cksum_types,
-					      cksum_types_supported_client());
-				cli->cl_checksum = 0;
-				cli->cl_supp_cksum_types = OBD_CKSUM_ADLER;
-			} else {
-				cli->cl_supp_cksum_types = ocd->ocd_cksum_types;
-			}
-		} else {
-			/* The server does not support OBD_CONNECT_CKSUM.
-			 * Enforce ADLER for backward compatibility
-			 */
-			cli->cl_supp_cksum_types = OBD_CKSUM_ADLER;
-		}
-		cli->cl_cksum_type = cksum_type_select(cli->cl_supp_cksum_types);
-
-		if (ocd->ocd_connect_flags & OBD_CONNECT_BRW_SIZE)
-			cli->cl_max_pages_per_rpc =
-				min(ocd->ocd_brw_size >> PAGE_SHIFT,
-				    cli->cl_max_pages_per_rpc);
-		else if (imp->imp_connect_op == MDS_CONNECT ||
-			 imp->imp_connect_op == MGS_CONNECT)
-			cli->cl_max_pages_per_rpc = 1;
-
-		/* Reset ns_connect_flags only for initial connect. It might be
-		 * changed in while using FS and if we reset it in reconnect
-		 * this leads to losing user settings done before such as
-		 * disable lru_resize, etc.
-		 */
-		if (old_connect_flags != exp_connect_flags(exp) ||
-		    aa->pcaa_initial_connect) {
-			CDEBUG(D_HA, "%s: Resetting ns_connect_flags to server flags: %#llx\n",
-			       imp->imp_obd->obd_name, ocd->ocd_connect_flags);
-			imp->imp_obd->obd_namespace->ns_connect_flags =
-				ocd->ocd_connect_flags;
-			imp->imp_obd->obd_namespace->ns_orig_connect_flags =
-				ocd->ocd_connect_flags;
-		}
-
-		if ((ocd->ocd_connect_flags & OBD_CONNECT_AT) &&
-		    (imp->imp_msg_magic == LUSTRE_MSG_MAGIC_V2))
-			/* We need a per-message support flag, because
-			 * a. we don't know if the incoming connect reply
-			 *    supports AT or not (in reply_in_callback)
-			 *    until we unpack it.
-			 * b. failovered server means export and flags are gone
-			 *    (in ptlrpc_send_reply).
-			 * Can only be set when we know AT is supported at
-			 * both ends
-			 */
-			imp->imp_msghdr_flags |= MSGHDR_AT_SUPPORT;
-		else
-			imp->imp_msghdr_flags &= ~MSGHDR_AT_SUPPORT;
-
-		if ((ocd->ocd_connect_flags & OBD_CONNECT_FULL20) &&
-		    (imp->imp_msg_magic == LUSTRE_MSG_MAGIC_V2))
-			imp->imp_msghdr_flags |= MSGHDR_CKSUM_INCOMPAT18;
-		else
-			imp->imp_msghdr_flags &= ~MSGHDR_CKSUM_INCOMPAT18;
-
-		LASSERT((cli->cl_max_pages_per_rpc <= PTLRPC_MAX_BRW_PAGES) &&
-			(cli->cl_max_pages_per_rpc > 0));
-		client_adjust_max_dirty(cli);
+	if (rc == -ENOTCONN) {
+		CDEBUG(D_HA, "evicted/aborted by %s@%s during recovery; invalidating and reconnecting\n",
+		       obd2cli_tgt(imp->imp_obd),
+		       imp->imp_connection->c_remote_uuid.uuid);
+		ptlrpc_connect_import(imp);
+		imp->imp_connect_tried = 1;
+		return 0;
 	}
 
 out:
diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
index 44f4eae..5bab248 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
@@ -491,7 +491,8 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	struct ptlrpc_connection *connection;
 	lnet_handle_me_t reply_me_h;
 	lnet_md_t reply_md;
-	struct obd_device *obd = request->rq_import->imp_obd;
+	struct obd_import *imp = request->rq_import;
+	struct obd_device *obd = imp->imp_obd;
 
 	if (OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_DROP_RPC))
 		return 0;
@@ -504,7 +505,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	 */
 	LASSERT(!request->rq_receiving_reply);
 	LASSERT(!((lustre_msg_get_flags(request->rq_reqmsg) & MSG_REPLAY) &&
-		  (request->rq_import->imp_state == LUSTRE_IMP_FULL)));
+		  (imp->imp_state == LUSTRE_IMP_FULL)));
 
 	if (unlikely(obd && obd->obd_fail)) {
 		CDEBUG(D_HA, "muting rpc for failed imp obd %s\n",
@@ -517,15 +518,22 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 		return -ENODEV;
 	}
 
-	connection = request->rq_import->imp_connection;
+	connection = imp->imp_connection;
 
 	lustre_msg_set_handle(request->rq_reqmsg,
-			      &request->rq_import->imp_remote_handle);
+			      &imp->imp_remote_handle);
 	lustre_msg_set_type(request->rq_reqmsg, PTL_RPC_MSG_REQUEST);
-	lustre_msg_set_conn_cnt(request->rq_reqmsg,
-				request->rq_import->imp_conn_cnt);
-	lustre_msghdr_set_flags(request->rq_reqmsg,
-				request->rq_import->imp_msghdr_flags);
+	lustre_msg_set_conn_cnt(request->rq_reqmsg, imp->imp_conn_cnt);
+	lustre_msghdr_set_flags(request->rq_reqmsg, imp->imp_msghdr_flags);
+
+	/**
+	 * For enabled AT all request should have AT_SUPPORT in the
+	 * FULL import state when OBD_CONNECT_AT is set
+	 */
+	LASSERT(AT_OFF || imp->imp_state != LUSTRE_IMP_FULL ||
+		(imp->imp_msghdr_flags & MSGHDR_AT_SUPPORT) ||
+		!(imp->imp_connect_data.ocd_connect_flags &
+		OBD_CONNECT_AT));
 
 	if (request->rq_resend)
 		lustre_msg_add_flags(request->rq_reqmsg, MSG_RESENT);
@@ -629,7 +637,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	ptlrpc_request_addref(request);
 	if (obd && obd->obd_svc_stats)
 		lprocfs_counter_add(obd->obd_svc_stats, PTLRPC_REQACTIVE_CNTR,
-			atomic_read(&request->rq_import->imp_inflight));
+			atomic_read(&imp->imp_inflight));
 
 	OBD_FAIL_TIMEOUT(OBD_FAIL_PTLRPC_DELAY_SEND, request->rq_timeout + 5);
 
@@ -641,7 +649,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	request->rq_deadline = request->rq_sent + request->rq_timeout +
 		ptlrpc_at_get_net_latency(request);
 
-	ptlrpc_pinger_sending_on_import(request->rq_import);
+	ptlrpc_pinger_sending_on_import(imp);
 
 	DEBUG_REQ(D_INFO, request, "send flg=%x",
 		  lustre_msg_get_flags(request->rq_reqmsg));
-- 
1.7.1
