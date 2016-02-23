From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 22 Feb 2016 21:54:28 -0500
Subject: [lustre-devel] [PATCH 50/56] staging/lustre/mdc: Adjust comments to
	better conform to coding style
In-Reply-To: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
References: <1456196074-754064-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1456196074-754064-51-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This patch fixes "Block comments use a trailing */ on a separate line"
warnings from checkpatch

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/mdc/mdc_lib.c     |  3 +-
 drivers/staging/lustre/lustre/mdc/mdc_locks.c   | 87 ++++++++++++++++---------
 drivers/staging/lustre/lustre/mdc/mdc_reint.c   | 12 ++--
 drivers/staging/lustre/lustre/mdc/mdc_request.c | 27 +++++---
 4 files changed, 84 insertions(+), 45 deletions(-)

diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
index ea2ab23..b3bfdcb 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
@@ -489,7 +489,8 @@ static int mdc_req_avail(struct client_obd *cli, struct mdc_cache_waiter *mcw)
 
 /* We record requests in flight in cli->cl_r_in_flight here.
  * There is only one write rpc possible in mdc anyway. If this to change
- * in the future - the code may need to be revisited. */
+ * in the future - the code may need to be revisited.
+ */
 int mdc_enter_request(struct client_obd *cli)
 {
 	int rc = 0;
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index ae648d0..6dae574 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -210,7 +210,8 @@ int mdc_null_inode(struct obd_export *exp,
 /* find any ldlm lock of the inode in mdc
  * return 0    not find
  *	1    find one
- *      < 0    error */
+ *      < 0    error
+ */
 int mdc_find_cbdata(struct obd_export *exp,
 		    const struct lu_fid *fid,
 		    ldlm_iterator_t it, void *data)
@@ -252,7 +253,8 @@ static inline void mdc_clear_replay_flag(struct ptlrpc_request *req, int rc)
  * OOM here may cause recovery failure if lmm is needed (only for the
  * original open if the MDS crashed just when this client also OOM'd)
  * but this is incredibly unlikely, and questionable whether the client
- * could do MDS recovery under OOM anyways... */
+ * could do MDS recovery under OOM anyways...
+ */
 static void mdc_realloc_openmsg(struct ptlrpc_request *req,
 				struct mdt_body *body)
 {
@@ -514,7 +516,8 @@ static struct ptlrpc_request *mdc_intent_layout_pack(struct obd_export *exp,
 	/* pack the layout intent request */
 	layout = req_capsule_client_get(&req->rq_pill, &RMF_LAYOUT_INTENT);
 	/* LAYOUT_INTENT_ACCESS is generic, specific operation will be
-	 * set for replication */
+	 * set for replication
+	 */
 	layout->li_opc = LAYOUT_INTENT_ACCESS;
 
 	req_capsule_set_size(&req->rq_pill, &RMF_DLM_LVB, RCL_SERVER,
@@ -561,7 +564,8 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 
 	LASSERT(rc >= 0);
 	/* Similarly, if we're going to replay this request, we don't want to
-	 * actually get a lock, just perform the intent. */
+	 * actually get a lock, just perform the intent.
+	 */
 	if (req->rq_transno || req->rq_replay) {
 		lockreq = req_capsule_client_get(pill, &RMF_DLM_REQ);
 		lockreq->lock_flags |= ldlm_flags_to_wire(LDLM_FL_INTENT_ONLY);
@@ -575,7 +579,8 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 		lock = ldlm_handle2lock(lockh);
 
 		/* If the server gave us back a different lock mode, we should
-		 * fix up our variables. */
+		 * fix up our variables.
+		 */
 		if (lock->l_req_mode != einfo->ei_mode) {
 			ldlm_lock_addref(lockh, lock->l_req_mode);
 			ldlm_lock_decref(lockh, einfo->ei_mode);
@@ -593,7 +598,8 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 	intent->it_data = req;
 
 	/* Technically speaking rq_transno must already be zero if
-	 * it_status is in error, so the check is a bit redundant */
+	 * it_status is in error, so the check is a bit redundant
+	 */
 	if ((!req->rq_transno || intent->it_status < 0) && req->rq_replay)
 		mdc_clear_replay_flag(req, intent->it_status);
 
@@ -603,7 +609,8 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 	 *
 	 * It's important that we do this first!  Otherwise we might exit the
 	 * function without doing so, and try to replay a failed create
-	 * (bug 3440) */
+	 * (bug 3440)
+	 */
 	if (it->it_op & IT_OPEN && req->rq_replay &&
 	    (!it_disposition(it, DISP_OPEN_OPEN) || intent->it_status != 0))
 		mdc_clear_replay_flag(req, intent->it_status);
@@ -647,7 +654,8 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 				return -EPROTO;
 
 			/* save lvb data and length in case this is for layout
-			 * lock */
+			 * lock
+			 */
 			lvb_data = eadata;
 			lvb_len = body->eadatasize;
 
@@ -693,7 +701,8 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 		}
 	} else if (it->it_op & IT_LAYOUT) {
 		/* maybe the lock was granted right away and layout
-		 * is packed into RMF_DLM_LVB of req */
+		 * is packed into RMF_DLM_LVB of req
+		 */
 		lvb_len = req_capsule_get_size(pill, &RMF_DLM_LVB, RCL_SERVER);
 		if (lvb_len > 0) {
 			lvb_data = req_capsule_server_sized_get(pill,
@@ -737,7 +746,8 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 }
 
 /* We always reserve enough space in the reply packet for a stripe MD, because
- * we don't know in advance the file type. */
+ * we don't know in advance the file type.
+ */
 int mdc_enqueue(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 		struct lookup_intent *it, struct md_op_data *op_data,
 		struct lustre_handle *lockh, void *lmm, int lmmsize,
@@ -787,7 +797,8 @@ resend:
 	flags = saved_flags;
 	if (!it) {
 		/* The only way right now is FLOCK, in this case we hide flock
-		   policy as lmm, but lmmsize is 0 */
+		 * policy as lmm, but lmmsize is 0
+		 */
 		LASSERT(lmm && lmmsize == 0);
 		LASSERTF(einfo->ei_type == LDLM_FLOCK, "lock type %d\n",
 			 einfo->ei_type);
@@ -823,7 +834,8 @@ resend:
 
 	if (req && it && it->it_op & IT_CREAT)
 		/* ask ptlrpc not to resend on EINPROGRESS since we have our own
-		 * retry logic */
+		 * retry logic
+		 */
 		req->rq_no_retry_einprogress = 1;
 
 	if (resends) {
@@ -834,7 +846,8 @@ resend:
 
 	/* It is important to obtain rpc_lock first (if applicable), so that
 	 * threads that are serialised with rpc_lock are not polluting our
-	 * rpcs in flight counter. We do not do flock request limiting, though*/
+	 * rpcs in flight counter. We do not do flock request limiting, though
+	 */
 	if (it) {
 		mdc_get_rpc_lock(obddev->u.cli.cl_rpc_lock, it);
 		rc = mdc_enter_request(&obddev->u.cli);
@@ -850,13 +863,14 @@ resend:
 			      0, lvb_type, lockh, 0);
 	if (!it) {
 		/* For flock requests we immediately return without further
-		   delay and let caller deal with the rest, since rest of
-		   this function metadata processing makes no sense for flock
-		   requests anyway. But in case of problem during comms with
-		   Server (ETIMEDOUT) or any signal/kill attempt (EINTR), we
-		   can not rely on caller and this mainly for F_UNLCKs
-		   (explicits or automatically generated by Kernel to clean
-		   current FLocks upon exit) that can't be trashed */
+		 * delay and let caller deal with the rest, since rest of
+		 * this function metadata processing makes no sense for flock
+		 * requests anyway. But in case of problem during comms with
+		 * Server (ETIMEDOUT) or any signal/kill attempt (EINTR), we
+		 * can not rely on caller and this mainly for F_UNLCKs
+		 * (explicits or automatically generated by Kernel to clean
+		 * current FLocks upon exit) that can't be trashed
+		 */
 		if ((rc == -EINTR) || (rc == -ETIMEDOUT))
 			goto resend;
 		return rc;
@@ -881,7 +895,8 @@ resend:
 		ptlrpc_status_ntoh(lockrep->lock_policy_res2);
 
 	/* Retry the create infinitely when we get -EINPROGRESS from
-	 * server. This is required by the new quota design. */
+	 * server. This is required by the new quota design.
+	 */
 	if (it->it_op & IT_CREAT &&
 	    (int)lockrep->lock_policy_res2 == -EINPROGRESS) {
 		mdc_clear_replay_flag(req, rc);
@@ -932,7 +947,8 @@ static int mdc_finish_intent_lock(struct obd_export *exp,
 
 	if (!it_disposition(it, DISP_IT_EXECD)) {
 		/* The server failed before it even started executing the
-		 * intent, i.e. because it couldn't unpack the request. */
+		 * intent, i.e. because it couldn't unpack the request.
+		 */
 		LASSERT(it->d.lustre.it_status != 0);
 		return it->d.lustre.it_status;
 	}
@@ -944,7 +960,8 @@ static int mdc_finish_intent_lock(struct obd_export *exp,
 	LASSERT(mdt_body);      /* mdc_enqueue checked */
 
 	/* If we were revalidating a fid/name pair, mark the intent in
-	 * case we fail and get called again from lookup */
+	 * case we fail and get called again from lookup
+	 */
 	if (fid_is_sane(&op_data->op_fid2) &&
 	    it->it_create_mode & M_CHECK_STALE &&
 	    it->it_op != IT_GETATTR) {
@@ -953,7 +970,8 @@ static int mdc_finish_intent_lock(struct obd_export *exp,
 		/* sever can return one of two fids:
 		 * op_fid2 - new allocated fid - if file is created.
 		 * op_fid3 - existent fid - if file only open.
-		 * op_fid3 is saved in lmv_intent_open */
+		 * op_fid3 is saved in lmv_intent_open
+		 */
 		if ((!lu_fid_eq(&op_data->op_fid2, &mdt_body->fid1)) &&
 		    (!lu_fid_eq(&op_data->op_fid3, &mdt_body->fid1))) {
 			CDEBUG(D_DENTRY, "Found stale data "DFID"("DFID")/"DFID
@@ -997,7 +1015,8 @@ static int mdc_finish_intent_lock(struct obd_export *exp,
 	 * one.  We have to set the data here instead of in
 	 * mdc_enqueue, because we need to use the child's inode as
 	 * the l_ast_data to match, and that's not available until
-	 * intent_finish has performed the iget().) */
+	 * intent_finish has performed the iget().)
+	 */
 	lock = ldlm_handle2lock(lockh);
 	if (lock) {
 		ldlm_policy_data_t policy = lock->l_policy_data;
@@ -1032,7 +1051,8 @@ int mdc_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
 {
 	/* We could just return 1 immediately, but since we should only
 	 * be called in revalidate_it if we already have a lock, let's
-	 * verify that. */
+	 * verify that.
+	 */
 	struct ldlm_res_id res_id;
 	struct lustre_handle lockh;
 	ldlm_policy_data_t policy;
@@ -1055,10 +1075,12 @@ int mdc_revalidate_lock(struct obd_export *exp, struct lookup_intent *it,
 			 * Unfortunately, if the bits are split across multiple
 			 * locks, there's no easy way to match all of them here,
 			 * so an extra RPC would be performed to fetch all
-			 * of those bits at once for now. */
+			 * of those bits at once for now.
+			 */
 			/* For new MDTs(> 2.4), UPDATE|PERM should be enough,
 			 * but for old MDTs (< 2.4), permission is covered
-			 * by LOOKUP lock, so it needs to match all bits here.*/
+			 * by LOOKUP lock, so it needs to match all bits here.
+			 */
 			policy.l_inodebits.bits = MDS_INODELOCK_UPDATE |
 						  MDS_INODELOCK_LOOKUP |
 						  MDS_INODELOCK_PERM;
@@ -1143,11 +1165,13 @@ int mdc_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
 	    (it->it_op & (IT_LOOKUP | IT_GETATTR))) {
 		/* We could just return 1 immediately, but since we should only
 		 * be called in revalidate_it if we already have a lock, let's
-		 * verify that. */
+		 * verify that.
+		 */
 		it->d.lustre.it_lock_handle = 0;
 		rc = mdc_revalidate_lock(exp, it, &op_data->op_fid2, NULL);
 		/* Only return failure if it was not GETATTR by cfid
-		   (from inode_revalidate) */
+		 * (from inode_revalidate)
+		 */
 		if (rc || op_data->op_namelen != 0)
 			return rc;
 	}
@@ -1230,7 +1254,8 @@ int mdc_intent_getattr_async(struct obd_export *exp,
 	struct ldlm_res_id       res_id;
 	/*XXX: Both MDS_INODELOCK_LOOKUP and MDS_INODELOCK_UPDATE are needed
 	 *     for statahead currently. Consider CMD in future, such two bits
-	 *     maybe managed by different MDS, should be adjusted then. */
+	 *     maybe managed by different MDS, should be adjusted then.
+	 */
 	ldlm_policy_data_t       policy = {
 					.l_inodebits = { MDS_INODELOCK_LOOKUP |
 							 MDS_INODELOCK_UPDATE }
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_reint.c b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
index dd87914..019b237 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_reint.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_reint.c
@@ -65,7 +65,8 @@ static int mdc_reint(struct ptlrpc_request *request,
 
 /* Find and cancel locally locks matched by inode @bits & @mode in the resource
  * found by @fid. Found locks are added into @cancel list. Returns the amount of
- * locks added to @cancels list. */
+ * locks added to @cancels list.
+ */
 int mdc_resource_get_unused(struct obd_export *exp, const struct lu_fid *fid,
 			    struct list_head *cancels, enum ldlm_mode mode,
 			    __u64 bits)
@@ -81,7 +82,8 @@ int mdc_resource_get_unused(struct obd_export *exp, const struct lu_fid *fid,
 	 *
 	 * This distinguishes from a case when ELC is not supported originally,
 	 * when we still want to cancel locks in advance and just cancel them
-	 * locally, without sending any RPC. */
+	 * locally, without sending any RPC.
+	 */
 	if (exp_connect_cancelset(exp) && !ns_connect_cancelset(ns))
 		return 0;
 
@@ -258,7 +260,8 @@ rebuild:
 	ptlrpc_request_set_replen(req);
 
 	/* ask ptlrpc not to resend on EINPROGRESS since we have our own retry
-	 * logic here */
+	 * logic here
+	 */
 	req->rq_no_retry_einprogress = 1;
 
 	if (resends) {
@@ -276,7 +279,8 @@ rebuild:
 		goto resend;
 	} else if (rc == -EINPROGRESS) {
 		/* Retry create infinitely until succeed or get other
-		 * error code. */
+		 * error code.
+		 */
 		ptlrpc_req_finished(req);
 		resends++;
 
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 9f27ac1..c7a0fa1 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -63,7 +63,8 @@ static inline int mdc_queue_wait(struct ptlrpc_request *req)
 
 	/* mdc_enter_request() ensures that this client has no more
 	 * than cl_max_rpcs_in_flight RPCs simultaneously inf light
-	 * against an MDT. */
+	 * against an MDT.
+	 */
 	rc = mdc_enter_request(cli);
 	if (rc != 0)
 		return rc;
@@ -813,7 +814,8 @@ static int mdc_close(struct obd_export *exp, struct md_op_data *op_data,
 
 	/* To avoid a livelock (bug 7034), we need to send CLOSE RPCs to a
 	 * portal whose threads are not taking any DLM locks and are therefore
-	 * always progressing */
+	 * always progressing
+	 */
 	req->rq_request_portal = MDS_READPAGE_PORTAL;
 	ptlrpc_at_set_req_timeout(req);
 
@@ -827,7 +829,8 @@ static int mdc_close(struct obd_export *exp, struct md_op_data *op_data,
 
 		DEBUG_REQ(D_HA, mod->mod_open_req, "matched open");
 		/* We no longer want to preserve this open for replay even
-		 * though the open was committed. b=3632, b=3633 */
+		 * though the open was committed. b=3632, b=3633
+		 */
 		spin_lock(&mod->mod_open_req->rq_lock);
 		mod->mod_open_req->rq_replay = 0;
 		spin_unlock(&mod->mod_open_req->rq_lock);
@@ -884,7 +887,8 @@ static int mdc_close(struct obd_export *exp, struct md_op_data *op_data,
 		if (rc != 0)
 			mod->mod_close_req = NULL;
 		/* Since now, mod is accessed through open_req only,
-		 * thus close req does not keep a reference on mod anymore. */
+		 * thus close req does not keep a reference on mod anymore.
+		 */
 		obd_mod_put(mod);
 	}
 	*request = req;
@@ -918,7 +922,8 @@ static int mdc_done_writing(struct obd_export *exp, struct md_op_data *op_data,
 		mod->mod_close_req = req;
 		DEBUG_REQ(D_HA, mod->mod_open_req, "matched setattr");
 		/* We no longer want to preserve this setattr for replay even
-		 * though the open was committed. b=3632, b=3633 */
+		 * though the open was committed. b=3632, b=3633
+		 */
 		spin_lock(&mod->mod_open_req->rq_lock);
 		mod->mod_open_req->rq_replay = 0;
 		spin_unlock(&mod->mod_open_req->rq_lock);
@@ -950,7 +955,8 @@ static int mdc_done_writing(struct obd_export *exp, struct md_op_data *op_data,
 		mdc_free_open(mod);
 
 		/* Since now, mod is accessed through setattr req only,
-		 * thus DW req does not keep a reference on mod anymore. */
+		 * thus DW req does not keep a reference on mod anymore.
+		 */
 		obd_mod_put(mod);
 	}
 
@@ -1608,7 +1614,8 @@ static int mdc_quotacheck(struct obd_device *unused, struct obd_export *exp,
 	ptlrpc_request_set_replen(req);
 
 	/* the next poll will find -ENODATA, that means quotacheck is
-	 * going on */
+	 * going on
+	 */
 	cli->cl_qchk_stat = -ENODATA;
 	rc = ptlrpc_queue_wait(req);
 	if (rc)
@@ -1908,7 +1915,8 @@ static int mdc_get_info_rpc(struct obd_export *exp,
 
 	rc = ptlrpc_queue_wait(req);
 	/* -EREMOTE means the get_info result is partial, and it needs to
-	 * continue on another MDT, see fid2path part in lmv_iocontrol */
+	 * continue on another MDT, see fid2path part in lmv_iocontrol
+	 */
 	if (rc == 0 || rc == -EREMOTE) {
 		tmp = req_capsule_server_get(&req->rq_pill, &RMF_GETINFO_VAL);
 		memcpy(val, tmp, vallen);
@@ -2247,7 +2255,8 @@ static int mdc_cancel_for_recovery(struct ldlm_lock *lock)
 
 	/* FIXME: if we ever get into a situation where there are too many
 	 * opened files with open locks on a single node, then we really
-	 * should replay these open locks to reget it */
+	 * should replay these open locks to reget it
+	 */
 	if (lock->l_policy_data.l_inodebits.bits & MDS_INODELOCK_OPEN)
 		return 0;
 
-- 
2.1.0
