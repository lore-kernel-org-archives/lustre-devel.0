From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:15:19 -0500
Subject: [lustre-devel] [PATCH 451/622] lustre: ptlrpc: make DEBUG_REQ
 messages consistent
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-452-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Remove linefeed from DEBUG_REQ() messages, since this results in
debug logs that are split across multiple lines and do not start
with the proper timestamp or other standard fields.  This makes
post-processing difficult.

Some error and debug messages are checked for explicitly in tests.
Add a comment by those lines in the code to alert the reader that
changes to those messages may cause test failures, and make the
tests more forgiving in case of minor changes to the formatting.

Fix several tests to check for actual error message.  Some tests
have been broken for so long (1.5/1.8) that there is no point to
also check for the old messages, so use only the new messages.

The EINPROGRESS messages should not use D_ERROR, since they can be
hit under normal usage (e.g. LFSCK running), so D_WARNING at most.
Don't print every one to the console, that would be too verbose.

Fix code style of affected lines.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12368
Lustre-commit: c0fa0ba4a8ef ("LU-12368 ptlrpc: make DEBUG_REQ messages consistent")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35311
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h |  2 +-
 fs/lustre/ldlm/ldlm_request.c  |  4 ++--
 fs/lustre/llite/llite_lib.c    |  1 +
 fs/lustre/mdc/mdc_locks.c      |  5 ++--
 fs/lustre/mdc/mdc_request.c    | 11 +++++----
 fs/lustre/osc/osc_request.c    | 21 ++++++++++-------
 fs/lustre/ptlrpc/client.c      | 53 ++++++++++++++++++++++--------------------
 fs/lustre/ptlrpc/events.c      |  2 +-
 fs/lustre/ptlrpc/import.c      | 15 +++++++++---
 fs/lustre/ptlrpc/layout.c      |  4 ++--
 fs/lustre/ptlrpc/niobuf.c      |  6 ++---
 fs/lustre/ptlrpc/ptlrpcd.c     |  2 +-
 fs/lustre/ptlrpc/recover.c     |  2 +-
 fs/lustre/ptlrpc/sec.c         |  6 ++++-
 fs/lustre/ptlrpc/service.c     | 18 ++++++++------
 net/lnet/libcfs/module.c       |  1 +
 16 files changed, 90 insertions(+), 63 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index caf766d..f16c6d3 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -2202,7 +2202,7 @@ static inline int ptlrpc_status_ntoh(int n)
 			atomic_dec(&req->rq_import->imp_unregistering);
 	}
 
-	DEBUG_REQ(D_INFO, req, "move req \"%s\" -> \"%s\"",
+	DEBUG_REQ(D_INFO, req, "move request phase from %s to %s",
 		  ptlrpc_rqphase2str(req), ptlrpc_phase2str(new_phase));
 
 	req->rq_phase = new_phase;
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 0dd9fea..20bdba4 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -777,7 +777,7 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 	}
 
 	if (*flags & LDLM_FL_NDELAY) {
-		DEBUG_REQ(D_DLMTRACE, req, "enque lock with no delay\n");
+		DEBUG_REQ(D_DLMTRACE, req, "enqueue lock with no delay");
 		req->rq_no_resend = req->rq_no_delay = 1;
 		/*
 		 * probably set a shorter timeout value and handle ETIMEDOUT
@@ -1248,7 +1248,7 @@ int ldlm_cli_update_pool(struct ptlrpc_request *req)
 	if (lustre_msg_get_slv(req->rq_repmsg) == 0 ||
 	    lustre_msg_get_limit(req->rq_repmsg) == 0) {
 		DEBUG_REQ(D_HA, req,
-			  "Zero SLV or Limit found (SLV: %llu, Limit: %u)",
+			  "Zero SLV or limit found (SLV=%llu, limit=%u)",
 			  lustre_msg_get_slv(req->rq_repmsg),
 			  lustre_msg_get_limit(req->rq_repmsg));
 		return 0;
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 8946dc6..217268e 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2731,6 +2731,7 @@ void ll_dirty_page_discard_warn(struct page *page, int ioret)
 			path = dentry_path_raw(dentry, buf, PAGE_SIZE);
 	}
 
+	/* The below message is checked in recovery-small.sh test_24b */
 	CDEBUG(D_WARNING,
 	       "%s: dirty page discard: %s/fid: " DFID "/%s may get corrupted (rc %d)\n",
 	       ll_i2sbi(inode)->ll_fsname,
diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index 5885bbd..b91c162 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -198,7 +198,8 @@ static inline void mdc_clear_replay_flag(struct ptlrpc_request *req, int rc)
 		spin_unlock(&req->rq_lock);
 	}
 	if (rc && req->rq_transno != 0) {
-		DEBUG_REQ(D_ERROR, req, "transno returned on error rc %d", rc);
+		DEBUG_REQ(D_ERROR, req, "transno returned on error: rc = %d",
+			  rc);
 		LBUG();
 	}
 }
@@ -710,7 +711,7 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 	    (!it_disposition(it, DISP_OPEN_OPEN) || it->it_status != 0))
 		mdc_clear_replay_flag(req, it->it_status);
 
-	DEBUG_REQ(D_RPCTRACE, req, "op: %x disposition: %x, status: %d",
+	DEBUG_REQ(D_RPCTRACE, req, "op=%x disposition=%x, status=%d",
 		  it->it_op, it->it_disposition, it->it_status);
 
 	/* We know what to expect, so we do any byte flipping required here */
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 162ace7..34cf177 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -450,6 +450,7 @@ static int mdc_getxattr(struct obd_export *exp, const struct lu_fid *fid,
 	LASSERT(obd_md_valid == OBD_MD_FLXATTR ||
 		obd_md_valid == OBD_MD_FLXATTRLS);
 
+	/* The below message is checked in sanity-selinux.sh test_20d */
 	CDEBUG(D_INFO, "%s: get xattr '%s' for " DFID "\n",
 	       exp->exp_obd->obd_name, name, PFID(fid));
 	rc = mdc_xattr_common(exp, &RQF_MDS_GETXATTR, fid, MDS_GETXATTR,
@@ -695,7 +696,7 @@ void mdc_replay_open(struct ptlrpc_request *req)
 
 	if (!mod) {
 		DEBUG_REQ(D_ERROR, req,
-			  "Can't properly replay without open data.");
+			  "cannot properly replay without open data");
 		return;
 	}
 
@@ -794,7 +795,7 @@ int mdc_set_open_replay_data(struct obd_export *exp,
 		mod = obd_mod_alloc();
 		if (!mod) {
 			DEBUG_REQ(D_ERROR, open_req,
-				  "Can't allocate md_open_data");
+				  "cannot allocate md_open_data");
 			return 0;
 		}
 
@@ -848,7 +849,7 @@ static void mdc_free_open(struct md_open_data *mod)
 	 * The worst thing is eviction if the client gets open lock
 	 */
 	DEBUG_REQ(D_RPCTRACE, mod->mod_open_req,
-		  "free open request rq_replay = %d\n",
+		  "free open request, rq_replay=%d\n",
 		   mod->mod_open_req->rq_replay);
 
 	ptlrpc_request_committed(mod->mod_open_req, committed);
@@ -993,7 +994,7 @@ static int mdc_close(struct obd_export *exp, struct md_op_data *op_data,
 	mdc_put_mod_rpc_slot(req, NULL);
 
 	if (!req->rq_repmsg) {
-		CDEBUG(D_RPCTRACE, "request failed to send: %p, %d\n", req,
+		CDEBUG(D_RPCTRACE, "request %p failed to send: rc = %d\n", req,
 		       req->rq_status);
 		if (rc == 0)
 			rc = req->rq_status ?: -EIO;
@@ -1003,7 +1004,7 @@ static int mdc_close(struct obd_export *exp, struct md_op_data *op_data,
 		rc = lustre_msg_get_status(req->rq_repmsg);
 		if (lustre_msg_get_type(req->rq_repmsg) == PTL_RPC_MSG_ERR) {
 			DEBUG_REQ(D_ERROR, req,
-				  "type == PTL_RPC_MSG_ERR, err = %d", rc);
+				  "type = PTL_RPC_MSG_ERR: rc = %d", rc);
 			if (rc > 0)
 				rc = -rc;
 		}
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 6b066e5..75e0823 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1735,14 +1735,14 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 	u32 client_cksum = 0;
 
 	if (rc < 0 && rc != -EDQUOT) {
-		DEBUG_REQ(D_INFO, req, "Failed request with rc = %d\n", rc);
+		DEBUG_REQ(D_INFO, req, "Failed request: rc = %d", rc);
 		return rc;
 	}
 
 	LASSERTF(req->rq_repmsg, "rc = %d\n", rc);
 	body = req_capsule_server_get(&req->rq_pill, &RMF_OST_BODY);
 	if (!body) {
-		DEBUG_REQ(D_INFO, req, "Can't unpack body\n");
+		DEBUG_REQ(D_INFO, req, "cannot unpack body");
 		return -EPROTO;
 	}
 
@@ -1770,7 +1770,8 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 
 	if (lustre_msg_get_opc(req->rq_reqmsg) == OST_WRITE) {
 		if (rc > 0) {
-			CERROR("Unexpected +ve rc %d\n", rc);
+			CERROR("%s: unexpected positive size %d\n",
+			       obd_name, rc);
 			return -EPROTO;
 		}
 
@@ -1805,13 +1806,13 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 	}
 
 	if (rc > aa->aa_requested_nob) {
-		CERROR("Unexpected rc %d (%d requested)\n", rc,
-		       aa->aa_requested_nob);
+		CERROR("%s: unexpected size %d, requested %d\n", obd_name,
+		       rc, aa->aa_requested_nob);
 		return -EPROTO;
 	}
 
 	if (req->rq_bulk && rc != req->rq_bulk->bd_nob_transferred) {
-		CERROR("Unexpected rc %d (%d transferred)\n",
+		CERROR("%s: unexpected size %d, transferred %d\n", obd_name,
 		       rc, req->rq_bulk->bd_nob_transferred);
 		return -EPROTO;
 	}
@@ -1916,8 +1917,9 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 
 		cksum_missed++;
 		if ((cksum_missed & (-cksum_missed)) == cksum_missed)
-			CERROR("Checksum %u requested from %s but not sent\n",
-			       cksum_missed, libcfs_nid2str(peer->nid));
+			CERROR("%s: checksum %u requested from %s but not sent\n",
+			       obd_name, cksum_missed,
+			       libcfs_nid2str(peer->nid));
 	} else {
 		rc = 0;
 	}
@@ -1936,6 +1938,7 @@ static int osc_brw_redo_request(struct ptlrpc_request *request,
 	struct osc_brw_async_args *new_aa;
 	struct osc_async_page *oap;
 
+	/* The below message is checked in replay-ost-single.sh test_8ae*/
 	DEBUG_REQ(rc == -EINPROGRESS ? D_RPCTRACE : D_ERROR, request,
 		  "redo for recoverable error %d", rc);
 
@@ -2346,7 +2349,7 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	}
 	spin_unlock(&cli->cl_loi_list_lock);
 
-	DEBUG_REQ(D_INODE, req, "%d pages, aa %p. now %ur/%dw in flight",
+	DEBUG_REQ(D_INODE, req, "%d pages, aa %p, now %ur/%dw in flight",
 		  page_count, aa, cli->cl_r_in_flight,
 		  cli->cl_w_in_flight);
 	OBD_FAIL_TIMEOUT(OBD_FAIL_OSC_DELAY_IO, cfs_fail_val);
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index c750a4e..d2e5e04 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -424,14 +424,16 @@ static int unpack_reply(struct ptlrpc_request *req)
 	if (SPTLRPC_FLVR_POLICY(req->rq_flvr.sf_rpc) != SPTLRPC_POLICY_NULL) {
 		rc = ptlrpc_unpack_rep_msg(req, req->rq_replen);
 		if (rc) {
-			DEBUG_REQ(D_ERROR, req, "unpack_rep failed: %d", rc);
+			DEBUG_REQ(D_ERROR, req, "unpack_rep failed: rc = %d",
+				  rc);
 			return -EPROTO;
 		}
 	}
 
 	rc = lustre_unpack_rep_ptlrpc_body(req, MSG_PTLRPC_BODY_OFF);
 	if (rc) {
-		DEBUG_REQ(D_ERROR, req, "unpack ptlrpc body failed: %d", rc);
+		DEBUG_REQ(D_ERROR, req, "unpack ptlrpc body failed: rc = %d",
+			  rc);
 		return -EPROTO;
 	}
 	return 0;
@@ -491,6 +493,8 @@ static int ptlrpc_at_recv_early_reply(struct ptlrpc_request *req)
 	req->rq_deadline = req->rq_sent + req->rq_timeout +
 			   ptlrpc_at_get_net_latency(req);
 
+	/* The below message is checked in replay-single.sh test_65{a,b} */
+	/* The below message is checked in sanity-{gss,krb5} test_8 */
 	DEBUG_REQ(D_ADAPTTO, req,
 		  "Early reply #%d, new deadline in %lds (%lds)",
 		  req->rq_early_count,
@@ -1163,18 +1167,18 @@ static int ptlrpc_import_delay_req(struct obd_import *imp,
 	if (req->rq_ctx_init || req->rq_ctx_fini) {
 		/* always allow ctx init/fini rpc go through */
 	} else if (imp->imp_state == LUSTRE_IMP_NEW) {
-		DEBUG_REQ(D_ERROR, req, "Uninitialized import.");
+		DEBUG_REQ(D_ERROR, req, "Uninitialized import");
 		*status = -EIO;
 	} else if (imp->imp_state == LUSTRE_IMP_CLOSED) {
 		/* pings may safely race with umount */
 		DEBUG_REQ(lustre_msg_get_opc(req->rq_reqmsg) == OBD_PING ?
-			  D_HA : D_ERROR, req, "IMP_CLOSED ");
+			  D_HA : D_ERROR, req, "IMP_CLOSED");
 		*status = -EIO;
 	} else if (ptlrpc_send_limit_expired(req)) {
 		/* probably doesn't need to be a D_ERROR after initial
 		 * testing
 		 */
-		DEBUG_REQ(D_HA, req, "send limit expired ");
+		DEBUG_REQ(D_HA, req, "send limit expired");
 		*status = -ETIMEDOUT;
 	} else if (req->rq_send_state == LUSTRE_IMP_CONNECTING &&
 		   imp->imp_state == LUSTRE_IMP_CONNECTING) {
@@ -1204,7 +1208,7 @@ static int ptlrpc_import_delay_req(struct obd_import *imp,
 			   imp->imp_state == LUSTRE_IMP_REPLAY_LOCKS ||
 			   imp->imp_state == LUSTRE_IMP_REPLAY_WAIT ||
 			   imp->imp_state == LUSTRE_IMP_RECOVER)) {
-			DEBUG_REQ(D_HA, req, "allow during recovery.\n");
+			DEBUG_REQ(D_HA, req, "allow during recovery");
 		} else {
 			delay = 1;
 		}
@@ -1258,9 +1262,9 @@ static bool ptlrpc_console_allow(struct ptlrpc_request *req)
  */
 static int ptlrpc_check_status(struct ptlrpc_request *req)
 {
-	int err;
+	int rc;
 
-	err = lustre_msg_get_status(req->rq_repmsg);
+	rc = lustre_msg_get_status(req->rq_repmsg);
 	if (lustre_msg_get_type(req->rq_repmsg) == PTL_RPC_MSG_ERR) {
 		struct obd_import *imp = req->rq_import;
 		lnet_nid_t nid = imp->imp_connection->c_peer.nid;
@@ -1268,22 +1272,19 @@ static int ptlrpc_check_status(struct ptlrpc_request *req)
 
 		/* -EAGAIN is normal when using POSIX flocks */
 		if (ptlrpc_console_allow(req) &&
-		    !(opc == LDLM_ENQUEUE && err == -EAGAIN))
+		    !(opc == LDLM_ENQUEUE && rc == -EAGAIN))
 			LCONSOLE_ERROR_MSG(0x011,
 					   "%s: operation %s to node %s failed: rc = %d\n",
 					   imp->imp_obd->obd_name,
 					   ll_opcode2str(opc),
-					   libcfs_nid2str(nid), err);
-		return err < 0 ? err : -EINVAL;
+					   libcfs_nid2str(nid), rc);
+		return rc < 0 ? rc : -EINVAL;
 	}
 
-	if (err < 0)
-		DEBUG_REQ(D_INFO, req, "status is %d", err);
-	else if (err > 0)
-		/* XXX: translate this error from net to host */
-		DEBUG_REQ(D_INFO, req, "status is %d", err);
+	if (rc)
+		DEBUG_REQ(D_INFO, req, "check status: rc = %d", rc);
 
-	return err;
+	return rc;
 }
 
 /**
@@ -1347,7 +1348,7 @@ static int after_reply(struct ptlrpc_request *req)
 	if (req->rq_reply_truncated) {
 		if (ptlrpc_no_resend(req)) {
 			DEBUG_REQ(D_ERROR, req,
-				  "reply buffer overflow, expected: %d, actual size: %d",
+				  "reply buffer overflow, expected=%d, actual size=%d",
 				  req->rq_nob_received, req->rq_repbuf_len);
 			return -EOVERFLOW;
 		}
@@ -1375,7 +1376,7 @@ static int after_reply(struct ptlrpc_request *req)
 	 */
 	rc = sptlrpc_cli_unwrap_reply(req);
 	if (rc) {
-		DEBUG_REQ(D_ERROR, req, "unwrap reply failed (%d):", rc);
+		DEBUG_REQ(D_ERROR, req, "unwrap reply failed: rc = %d", rc);
 		return rc;
 	}
 
@@ -1392,7 +1393,8 @@ static int after_reply(struct ptlrpc_request *req)
 	    ptlrpc_no_resend(req) == 0 && !req->rq_no_retry_einprogress) {
 		time64_t now = ktime_get_real_seconds();
 
-		DEBUG_REQ(D_RPCTRACE, req, "Resending request on EINPROGRESS");
+		DEBUG_REQ((req->rq_nr_resend % 8 == 1 ? D_WARNING : 0) |
+			  D_RPCTRACE, req, "resending request on EINPROGRESS");
 		spin_lock(&req->rq_lock);
 		req->rq_resend = 1;
 		spin_unlock(&req->rq_lock);
@@ -1634,7 +1636,8 @@ static int ptlrpc_send_new_req(struct ptlrpc_request *req)
 		return rc;
 	}
 	if (rc) {
-		DEBUG_REQ(D_HA, req, "send failed (%d); expect timeout", rc);
+		DEBUG_REQ(D_HA, req, "send failed, expect timeout: rc = %d",
+			  rc);
 		spin_lock(&req->rq_lock);
 		req->rq_net_err = 1;
 		spin_unlock(&req->rq_lock);
@@ -2875,7 +2878,7 @@ static int ptlrpc_replay_interpret(const struct lu_env *env,
 	if (!ptlrpc_client_replied(req) ||
 	    (req->rq_bulk &&
 	     lustre_msg_get_status(req->rq_repmsg) == -ETIMEDOUT)) {
-		DEBUG_REQ(D_ERROR, req, "request replay timed out.\n");
+		DEBUG_REQ(D_ERROR, req, "request replay timed out");
 		rc = -ETIMEDOUT;
 		goto out;
 	}
@@ -2890,7 +2893,7 @@ static int ptlrpc_replay_interpret(const struct lu_env *env,
 	/** VBR: check version failure */
 	if (lustre_msg_get_status(req->rq_repmsg) == -EOVERFLOW) {
 		/** replay was failed due to version mismatch */
-		DEBUG_REQ(D_WARNING, req, "Version mismatch during replay\n");
+		DEBUG_REQ(D_WARNING, req, "Version mismatch during replay");
 		spin_lock(&imp->imp_lock);
 		imp->imp_vbr_failed = 1;
 		spin_unlock(&imp->imp_lock);
@@ -2913,14 +2916,14 @@ static int ptlrpc_replay_interpret(const struct lu_env *env,
 	/* transaction number shouldn't be bigger than the latest replayed */
 	if (req->rq_transno > lustre_msg_get_transno(req->rq_reqmsg)) {
 		DEBUG_REQ(D_ERROR, req,
-			  "Reported transno %llu is bigger than the replayed one: %llu",
+			  "Reported transno=%llu is bigger than replayed=%llu",
 			  req->rq_transno,
 			  lustre_msg_get_transno(req->rq_reqmsg));
 		rc = -EINVAL;
 		goto out;
 	}
 
-	DEBUG_REQ(D_HA, req, "got rep");
+	DEBUG_REQ(D_HA, req, "got reply");
 
 	/* let the callback do fixups, possibly including in the request */
 	if (req->rq_replay_cb)
diff --git a/fs/lustre/ptlrpc/events.c b/fs/lustre/ptlrpc/events.c
index 87c0ab7..e6a49db 100644
--- a/fs/lustre/ptlrpc/events.c
+++ b/fs/lustre/ptlrpc/events.c
@@ -132,7 +132,7 @@ void reply_in_callback(struct lnet_event *ev)
 	    ((lustre_msghdr_get_flags(req->rq_reqmsg) & MSGHDR_AT_SUPPORT))) {
 		/* Early reply */
 		DEBUG_REQ(D_ADAPTTO, req,
-			  "Early reply received: mlen=%u offset=%d replen=%d replied=%d unlinked=%d",
+			  "Early reply received, mlen=%u offset=%d replen=%d replied=%d unlinked=%d",
 			  ev->mlength, ev->offset,
 			  req->rq_replen, req->rq_replied, ev->unlinked);
 
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index a6d0b32..ff1b810 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -567,6 +567,7 @@ static int import_select_connection(struct obd_import *imp)
 		imp->imp_conn_current = imp_conn;
 	}
 
+	/* The below message is checked in conf-sanity.sh test_35[ab] */
 	CDEBUG(D_HA, "%s: import %p using connection %s/%s\n",
 	       imp->imp_obd->obd_name, imp, imp_conn->oic_uuid.uuid,
 	       libcfs_nid2str(imp_conn->oic_conn->c_peer.nid));
@@ -1221,10 +1222,18 @@ static int ptlrpc_connect_interpret(const struct lu_env *env,
 
 	if (lustre_msg_get_last_committed(request->rq_repmsg) > 0 &&
 	    lustre_msg_get_last_committed(request->rq_repmsg) <
-	    aa->pcaa_peer_committed)
-		CERROR("%s went back in time (transno %lld was previously committed, server now claims %lld)!  See https://bugzilla.lustre.org/show_bug.cgi?id=9646\n",
+	    aa->pcaa_peer_committed) {
+		static bool printed;
+
+		/* The below message is checked in recovery-small.sh test_54 */
+		CERROR("%s: went back in time (transno %lld was previously committed, server now claims %lld)!\n",
 		       obd2cli_tgt(imp->imp_obd), aa->pcaa_peer_committed,
 		       lustre_msg_get_last_committed(request->rq_repmsg));
+		if (!printed) {
+			CERROR("For further information, see http://doc.lustre.org/lustre_manual.xhtml#went_back_in_time\n");
+			printed = true;
+		}
+	}
 
 finish:
 	ptlrpc_prepare_replay(imp);
@@ -1668,7 +1677,7 @@ static int ptlrpc_disconnect_idle_interpret(const struct lu_env *env,
 	struct obd_import *imp = req->rq_import;
 	int connect = 0;
 
-	DEBUG_REQ(D_HA, req, "inflight=%d, refcount=%d: rc = %d ",
+	DEBUG_REQ(D_HA, req, "inflight=%d, refcount=%d: rc = %d",
 		  atomic_read(&imp->imp_inflight),
 		  atomic_read(&imp->imp_refcount), rc);
 
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index fb60558..67a7cd5 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -1825,7 +1825,7 @@ int req_capsule_server_pack(struct req_capsule *pill)
 			       pill->rc_area[RCL_SERVER], NULL);
 	if (rc != 0) {
 		DEBUG_REQ(D_ERROR, pill->rc_req,
-			  "Cannot pack %d fields in format `%s': ",
+			  "Cannot pack %d fields in format '%s'",
 			  count, fmt->rf_name);
 	}
 	return rc;
@@ -1988,7 +1988,7 @@ static void *__req_capsule_get(struct req_capsule *pill,
 
 	if (!value) {
 		DEBUG_REQ(D_ERROR, pill->rc_req,
-			  "Wrong buffer for field `%s' (%u of %u) in format `%s': %u vs. %u (%s)\n",
+			  "Wrong buffer for field '%s' (%u of %u) in format '%s', %u vs. %u (%s)",
 			  field->rmf_name, offset, lustre_msg_bufcount(msg),
 			  fmt->rf_name, lustre_msg_buflen(msg, offset), len,
 			  rcl_names[loc]);
diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index 9d9e94c..12a9a5e 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -540,7 +540,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 
 		lustre_msg_set_last_xid(request->rq_reqmsg, min_xid);
 		DEBUG_REQ(D_RPCTRACE, request,
-			  "Allocating new xid for resend on EINPROGRESS");
+			  "Allocating new XID for resend on EINPROGRESS");
 	}
 
 	if (request->rq_bulk) {
@@ -551,7 +551,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	if (list_empty(&request->rq_unreplied_list) ||
 	    request->rq_xid <= imp->imp_known_replied_xid) {
 		DEBUG_REQ(D_ERROR, request,
-			  "xid: %llu, replied: %llu, list_empty:%d\n",
+			  "xid=%llu, replied=%llu, list_empty=%d",
 			  request->rq_xid, imp->imp_known_replied_xid,
 			  list_empty(&request->rq_unreplied_list));
 		LBUG();
@@ -689,7 +689,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 
 	ptlrpc_pinger_sending_on_import(imp);
 
-	DEBUG_REQ(D_INFO, request, "send flg=%x",
+	DEBUG_REQ(D_INFO, request, "send flags=%x",
 		  lustre_msg_get_flags(request->rq_reqmsg));
 	rc = ptl_send_buf(&request->rq_req_md_h,
 			  request->rq_reqbuf, request->rq_reqdata_len,
diff --git a/fs/lustre/ptlrpc/ptlrpcd.c b/fs/lustre/ptlrpc/ptlrpcd.c
index bcf1e46..1a1fa05 100644
--- a/fs/lustre/ptlrpc/ptlrpcd.c
+++ b/fs/lustre/ptlrpc/ptlrpcd.c
@@ -256,7 +256,7 @@ void ptlrpcd_add_req(struct ptlrpc_request *req)
 
 	pc = ptlrpcd_select_pc(req);
 
-	DEBUG_REQ(D_INFO, req, "add req [%p] to pc [%s:%d]",
+	DEBUG_REQ(D_INFO, req, "add req [%p] to pc [%s+%d]",
 		  req, pc->pc_name, pc->pc_index);
 
 	ptlrpc_set_add_new_req(pc, req);
diff --git a/fs/lustre/ptlrpc/recover.c b/fs/lustre/ptlrpc/recover.c
index e6e6661..09ea3b3 100644
--- a/fs/lustre/ptlrpc/recover.c
+++ b/fs/lustre/ptlrpc/recover.c
@@ -143,7 +143,7 @@ int ptlrpc_replay_next(struct obd_import *imp, int *inflight)
 	 * unreplied list.
 	 */
 	if (req && list_empty(&req->rq_unreplied_list)) {
-		DEBUG_REQ(D_HA, req, "resend_replay: %d, last_transno: %llu\n",
+		DEBUG_REQ(D_HA, req, "resend_replay=%d, last_transno=%llu",
 			  imp->imp_resend_replay, last_transno);
 		ptlrpc_add_unreplied(req);
 		imp->imp_known_replied_xid = ptlrpc_known_replied_xid(imp);
diff --git a/fs/lustre/ptlrpc/sec.c b/fs/lustre/ptlrpc/sec.c
index d82809f..15667454 100644
--- a/fs/lustre/ptlrpc/sec.c
+++ b/fs/lustre/ptlrpc/sec.c
@@ -1151,7 +1151,7 @@ int sptlrpc_cli_unwrap_early_reply(struct ptlrpc_request *req,
 	rc = do_cli_unwrap_reply(early_req);
 	if (rc) {
 		DEBUG_REQ(D_ADAPTTO, early_req,
-			  "error %d unwrap early reply", rc);
+			  "unwrap early reply: rc = %d", rc);
 		goto err_ctx;
 	}
 
@@ -2037,18 +2037,21 @@ static int sptlrpc_svc_check_from(struct ptlrpc_request *req, int svc_rc)
 	switch (req->rq_sp_from) {
 	case LUSTRE_SP_CLI:
 		if (req->rq_auth_usr_mdt || req->rq_auth_usr_ost) {
+			/* The below message is checked in sanity-sec test_33 */
 			DEBUG_REQ(D_ERROR, req, "faked source CLI");
 			svc_rc = SECSVC_DROP;
 		}
 		break;
 	case LUSTRE_SP_MDT:
 		if (!req->rq_auth_usr_mdt) {
+			/* The below message is checked in sanity-sec test_33 */
 			DEBUG_REQ(D_ERROR, req, "faked source MDT");
 			svc_rc = SECSVC_DROP;
 		}
 		break;
 	case LUSTRE_SP_OST:
 		if (!req->rq_auth_usr_ost) {
+			/* The below message is checked in sanity-sec test_33 */
 			DEBUG_REQ(D_ERROR, req, "faked source OST");
 			svc_rc = SECSVC_DROP;
 		}
@@ -2057,6 +2060,7 @@ static int sptlrpc_svc_check_from(struct ptlrpc_request *req, int svc_rc)
 	case LUSTRE_SP_MGC:
 		if (!req->rq_auth_usr_root && !req->rq_auth_usr_mdt &&
 		    !req->rq_auth_usr_ost) {
+			/* The below message is checked in sanity-sec test_33 */
 			DEBUG_REQ(D_ERROR, req, "faked source MGC/MGS");
 			svc_rc = SECSVC_DROP;
 		}
diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index f40cb8d..c66c690 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -1072,6 +1072,7 @@ static int ptlrpc_at_send_early_reply(struct ptlrpc_request *req)
 		return 0;
 
 	if (olddl < 0) {
+		/* below message is checked in replay-ost-single.sh test_9 */
 		DEBUG_REQ(D_WARNING, req,
 			  "Already past deadline (%+llds), not sending early reply. Consider increasing at_early_margin (%d)?",
 			  (s64)olddl, at_early_margin);
@@ -1104,7 +1105,8 @@ static int ptlrpc_at_send_early_reply(struct ptlrpc_request *req)
 	 * we may be past adaptive_max
 	 */
 	if (req->rq_deadline >= newdl) {
-		DEBUG_REQ(D_WARNING, req, "Couldn't add any time (%ld/%lld), not sending early reply\n",
+		DEBUG_REQ(D_WARNING, req,
+			  "Could not add any time (%ld/%lld), not sending early reply",
 			  olddl, newdl - ktime_get_real_seconds());
 		return -ETIMEDOUT;
 	}
@@ -1140,10 +1142,10 @@ static int ptlrpc_at_send_early_reply(struct ptlrpc_request *req)
 	}
 
 	LASSERT(atomic_read(&req->rq_refcount));
-	/** if it is last refcount then early reply isn't needed */
+	/* if it is last refcount then early reply isn't needed */
 	if (atomic_read(&req->rq_refcount) == 1) {
 		DEBUG_REQ(D_ADAPTTO, reqcopy,
-			  "Normal reply already sent out, abort sending early reply\n");
+			  "Normal reply already sent, abort early reply");
 		rc = -EINVAL;
 		goto out;
 	}
@@ -1174,7 +1176,7 @@ static int ptlrpc_at_send_early_reply(struct ptlrpc_request *req)
 		req->rq_deadline = newdl;
 		req->rq_early_count++; /* number sent, server side */
 	} else {
-		DEBUG_REQ(D_ERROR, req, "Early reply send failed %d", rc);
+		DEBUG_REQ(D_ERROR, req, "Early reply send failed: rc = %d", rc);
 	}
 
 	/*
@@ -1628,7 +1630,7 @@ static int ptlrpc_server_handle_req_in(struct ptlrpc_service_part *svcpt,
 			rc = sptlrpc_target_export_check(req->rq_export, req);
 			if (rc)
 				DEBUG_REQ(D_ERROR, req,
-					  "DROPPING req with illegal security flavor,");
+					  "DROPPING req with illegal security flavor");
 		}
 
 		if (rc)
@@ -1747,7 +1749,7 @@ static int ptlrpc_server_handle_request(struct ptlrpc_service_part *svcpt,
 	 */
 	if (ktime_get_real_seconds() > request->rq_deadline) {
 		DEBUG_REQ(D_ERROR, request,
-			  "Dropping timed-out request from %s: deadline %lld:%llds ago\n",
+			  "Dropping timed-out request from %s: deadline %lld/%llds ago",
 			  libcfs_id2str(request->rq_peer),
 			  request->rq_deadline -
 			  request->rq_arrival_time.tv_sec,
@@ -1787,7 +1789,7 @@ static int ptlrpc_server_handle_request(struct ptlrpc_service_part *svcpt,
 put_conn:
 	if (unlikely(ktime_get_real_seconds() > request->rq_deadline)) {
 		DEBUG_REQ(D_WARNING, request,
-			  "Request took longer than estimated (%lld:%llds); client may timeout.",
+			  "Request took longer than estimated (%lld/%llds); client may timeout",
 			  (s64)request->rq_deadline -
 			       request->rq_arrival_time.tv_sec,
 			  (s64)ktime_get_real_seconds() - request->rq_deadline);
@@ -2061,12 +2063,14 @@ static void ptlrpc_watchdog_fire(struct work_struct *w)
 	u32 ms_frac = do_div(ms_lapse, MSEC_PER_SEC);
 
 	if (!__ratelimit(&watchdog_limit)) {
+		/* below message is checked in sanity-quota.sh test_6,18 */
 		LCONSOLE_WARN("%s: service thread pid %u was inactive for %llu.%.03u seconds. The thread might be hung, or it might only be slow and will resume later. Dumping the stack trace for debugging purposes:\n",
 			      thread->t_task->comm, thread->t_task->pid,
 			      ms_lapse, ms_frac);
 
 		libcfs_debug_dumpstack(thread->t_task);
 	} else {
+		/* below message is checked in sanity-quota.sh test_6,18 */
 		LCONSOLE_WARN("%s: service thread pid %u was inactive for %llu.%.03u seconds. Watchdog stack traces are limited to 3 per %u seconds, skipping this one.\n",
 			      thread->t_task->comm, thread->t_task->pid,
 			      ms_lapse, ms_frac, libcfs_watchdog_ratelimit);
diff --git a/net/lnet/libcfs/module.c b/net/lnet/libcfs/module.c
index 2e803d6..20d4302 100644
--- a/net/lnet/libcfs/module.c
+++ b/net/lnet/libcfs/module.c
@@ -791,6 +791,7 @@ static void libcfs_exit(void)
 
 	cfs_cpu_fini();
 
+	/* the below message is checked in test-framework.sh check_mem_leak() */
 	rc = libcfs_debug_cleanup();
 	if (rc)
 		pr_err("LustreError: libcfs_debug_cleanup: %d\n", rc);
-- 
1.8.3.1
