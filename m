From: NeilBrown <neilb@suse.com>
Date: Wed, 09 Jan 2019 17:24:02 +1100
Subject: [lustre-devel] [PATCH 28/29] lustre: osc_request: assorted
 white-space and check-patch fixes.
In-Reply-To: <154701488711.26726.17363928508883972338.stgit@noble>
References: <154701488711.26726.17363928508883972338.stgit@noble>
Message-ID: <154701504282.26726.12048576544354457365.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Just misc formatting fixes.  Some minot code change
where an 'else' after 'return' was discarded.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/osc/osc_request.c |  163 +++++++++++++----------
 1 file changed, 89 insertions(+), 74 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index ccc491efa982..c2239c99a7b2 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -63,37 +63,37 @@ static unsigned int osc_reqpool_mem_max = 5;
 module_param(osc_reqpool_mem_max, uint, 0444);
 
 struct osc_brw_async_args {
-	struct obdo       *aa_oa;
-	int		aa_requested_nob;
-	int		aa_nio_count;
-	u32		aa_page_count;
-	int		aa_resends;
-	struct brw_page  **aa_ppga;
-	struct client_obd *aa_cli;
-	struct list_head	 aa_oaps;
-	struct list_head	 aa_exts;
+	struct obdo		*aa_oa;
+	int			aa_requested_nob;
+	int			aa_nio_count;
+	u32			aa_page_count;
+	int			aa_resends;
+	struct brw_page		**aa_ppga;
+	struct client_obd	*aa_cli;
+	struct list_head	aa_oaps;
+	struct list_head	aa_exts;
 };
 
 struct osc_async_args {
-	struct obd_info   *aa_oi;
+	struct obd_info		*aa_oi;
 };
 
 struct osc_setattr_args {
-	struct obdo	 *sa_oa;
-	obd_enqueue_update_f sa_upcall;
-	void		*sa_cookie;
+	struct obdo		*sa_oa;
+	obd_enqueue_update_f	sa_upcall;
+	void			*sa_cookie;
 };
 
 struct osc_fsync_args {
 	struct osc_object	*fa_obj;
 	struct obdo		*fa_oa;
-	obd_enqueue_update_f fa_upcall;
-	void		*fa_cookie;
+	obd_enqueue_update_f	fa_upcall;
+	void			*fa_cookie;
 };
 
 struct osc_ladvise_args {
 	struct obdo		*la_oa;
-	obd_enqueue_update_f	 la_upcall;
+	obd_enqueue_update_f	la_upcall;
 	void			*la_cookie;
 };
 
@@ -101,12 +101,12 @@ struct osc_enqueue_args {
 	struct obd_export	*oa_exp;
 	enum ldlm_type		oa_type;
 	enum ldlm_mode		oa_mode;
-	__u64		    *oa_flags;
+	__u64			*oa_flags;
 	osc_enqueue_upcall_f	oa_upcall;
-	void		     *oa_cookie;
-	struct ost_lvb	   *oa_lvb;
+	void			*oa_cookie;
+	struct ost_lvb		*oa_lvb;
 	struct lustre_handle	oa_lockh;
-	unsigned int	      oa_agl:1;
+	unsigned int		oa_agl:1;
 };
 
 static void osc_release_ppga(struct brw_page **ppga, u32 count);
@@ -331,8 +331,7 @@ int osc_ladvise_base(struct obd_export *exp, struct obdo *oa,
 
 	body = req_capsule_client_get(&req->rq_pill, &RMF_OST_BODY);
 	LASSERT(body);
-	lustre_set_wire_obdo(&req->rq_import->imp_connect_data, &body->oa,
-			     oa);
+	lustre_set_wire_obdo(&req->rq_import->imp_connect_data, &body->oa, oa);
 
 	req_ladvise_hdr = req_capsule_client_get(&req->rq_pill,
 						 &RMF_OST_LADVISE_HDR);
@@ -652,8 +651,8 @@ static int osc_destroy(const struct lu_env *env, struct obd_export *exp,
 		 * Wait until the number of on-going destroy RPCs drops
 		 * under max_rpc_in_flight
 		 */
-		rc = l_wait_event_abortable_exclusive(cli->cl_destroy_waitq,
-						      osc_can_send_destroy(cli));
+		rc = l_wait_event_abortable_exclusive(
+			cli->cl_destroy_waitq, osc_can_send_destroy(cli));
 		if (rc) {
 			ptlrpc_req_finished(req);
 			return rc;
@@ -716,7 +715,8 @@ static void osc_announce_cached(struct client_obd *cli, struct obdo *oa,
 			 * take extent tax into account when asking for more
 			 * grant space
 			 */
-			nrextents = DIV_ROUND_UP(nrpages, cli->cl_max_extent_pages);
+			nrextents = DIV_ROUND_UP(nrpages,
+						 cli->cl_max_extent_pages);
 			oa->o_undirty += nrextents * cli->cl_grant_extent_tax;
 		}
 	}
@@ -930,7 +930,8 @@ static void osc_init_grant(struct client_obd *cli, struct obd_connect_data *ocd)
 		if (OCD_HAS_FLAG(ocd, GRANT_PARAM))
 			cli->cl_avail_grant -= cli->cl_dirty_grant;
 		else
-			cli->cl_avail_grant -= cli->cl_dirty_pages << PAGE_SHIFT;
+			cli->cl_avail_grant -=
+				cli->cl_dirty_pages << PAGE_SHIFT;
 	}
 
 	if (OCD_HAS_FLAG(ocd, GRANT_PARAM)) {
@@ -1181,11 +1182,12 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 	 */
 	req->rq_no_retry_einprogress = 1;
 
-	desc = ptlrpc_prep_bulk_imp(req, page_count,
+	desc = ptlrpc_prep_bulk_imp(
+		req, page_count,
 		cli->cl_import->imp_connect_data.ocd_brw_size >> LNET_MTU_BITS,
 		(opc == OST_WRITE ? PTLRPC_BULK_GET_SOURCE :
 		 PTLRPC_BULK_PUT_SINK) | PTLRPC_BULK_BUF_KIOV, OST_BULK_PORTAL,
-		 &ptlrpc_bulk_kiov_pin_ops);
+		&ptlrpc_bulk_kiov_pin_ops);
 
 	if (!desc) {
 		rc = -ENOMEM;
@@ -1252,7 +1254,8 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 		"want %p - real %p\n", req_capsule_client_get(&req->rq_pill,
 		&RMF_NIOBUF_REMOTE), (void *)(niobuf - niocount));
 
-	osc_announce_cached(cli, &body->oa, opc == OST_WRITE ? requested_nob:0);
+	osc_announce_cached(cli, &body->oa,
+			    opc == OST_WRITE ? requested_nob : 0);
 	if (resend) {
 		if ((body->oa.o_valid & OBD_MD_FLFLAGS) == 0) {
 			body->oa.o_valid |= OBD_MD_FLFLAGS;
@@ -1436,18 +1439,21 @@ static int check_write_checksum(struct obdo *oa,
 		msg = "changed in transit AND doesn't match the original - likely false positive due to mmap IO (bug 11742)"
 			;
 
-	LCONSOLE_ERROR_MSG(0x132,
-			   "%s: BAD WRITE CHECKSUM: %s: from %s inode " DFID " object " DOSTID " extent [%llu-%llu], original client csum %x (type %x), server csum %x (type %x), client csum now %x\n",
-			   aa->aa_cli->cl_import->imp_obd->obd_name,
-			   msg, libcfs_nid2str(peer->nid),
-			   oa->o_valid & OBD_MD_FLFID ? oa->o_parent_seq : (u64)0,
-			   oa->o_valid & OBD_MD_FLFID ? oa->o_parent_oid : 0,
-			   oa->o_valid & OBD_MD_FLFID ? oa->o_parent_ver : 0,
-			   POSTID(&oa->o_oi), aa->aa_ppga[0]->off,
-			   aa->aa_ppga[aa->aa_page_count - 1]->off +
-				aa->aa_ppga[aa->aa_page_count - 1]->count - 1,
-			   client_cksum, cksum_type_unpack(aa->aa_oa->o_flags),
-			   server_cksum, cksum_type, new_cksum);
+	LCONSOLE_ERROR_MSG(
+		0x132,
+		"%s: BAD WRITE CHECKSUM: %s: from %s inode " DFID
+		" object " DOSTID
+		" extent [%llu-%llu], original client csum %x (type %x), server csum %x (type %x), client csum now %x\n",
+		aa->aa_cli->cl_import->imp_obd->obd_name,
+		msg, libcfs_nid2str(peer->nid),
+		oa->o_valid & OBD_MD_FLFID ? oa->o_parent_seq : (u64)0,
+		oa->o_valid & OBD_MD_FLFID ? oa->o_parent_oid : 0,
+		oa->o_valid & OBD_MD_FLFID ? oa->o_parent_ver : 0,
+		POSTID(&oa->o_oi), aa->aa_ppga[0]->off,
+		aa->aa_ppga[aa->aa_page_count - 1]->off +
+		aa->aa_ppga[aa->aa_page_count - 1]->count - 1,
+		client_cksum, cksum_type_unpack(aa->aa_oa->o_flags),
+		server_cksum, cksum_type, new_cksum);
 
 	return 1;
 }
@@ -1480,7 +1486,8 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 		unsigned int qid[MAXQUOTAS] = { body->oa.o_uid, body->oa.o_gid,
 						body->oa.o_projid };
 
-		CDEBUG(D_QUOTA, "setdq for [%u %u %u] with valid %#llx, flags %x\n",
+		CDEBUG(D_QUOTA,
+		       "setdq for [%u %u %u] with valid %#llx, flags %x\n",
 		       body->oa.o_uid, body->oa.o_gid, body->oa.o_projid,
 		       body->oa.o_valid, body->oa.o_flags);
 		osc_quota_setdq(cli, qid, body->oa.o_valid, body->oa.o_flags);
@@ -1569,23 +1576,26 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 						    aa->aa_ppga, server_cksum,
 						    client_cksum);
 
-			LCONSOLE_ERROR_MSG(0x133,
-					   "%s: BAD READ CHECKSUM: from %s%s%s inode " DFID " object " DOSTID " extent [%llu-%llu], client %x, server %x, cksum_type %x\n",
-					   req->rq_import->imp_obd->obd_name,
-					   libcfs_nid2str(peer->nid),
-					   via, router,
-					   clbody->oa.o_valid & OBD_MD_FLFID ?
-						clbody->oa.o_parent_seq : (u64)0,
-					   clbody->oa.o_valid & OBD_MD_FLFID ?
-						clbody->oa.o_parent_oid : 0,
-					   clbody->oa.o_valid & OBD_MD_FLFID ?
-						clbody->oa.o_parent_ver : 0,
-					   POSTID(&body->oa.o_oi),
-					   aa->aa_ppga[0]->off,
-					   aa->aa_ppga[page_count - 1]->off +
-					   aa->aa_ppga[page_count - 1]->count - 1,
-					   client_cksum, server_cksum,
-					   cksum_type);
+			LCONSOLE_ERROR_MSG(
+				0x133,
+				"%s: BAD READ CHECKSUM: from %s%s%s inode " DFID
+				" object " DOSTID
+				" extent [%llu-%llu], client %x, server %x, cksum_type %x\n",
+				req->rq_import->imp_obd->obd_name,
+				libcfs_nid2str(peer->nid),
+				via, router,
+				clbody->oa.o_valid & OBD_MD_FLFID ?
+				clbody->oa.o_parent_seq : (u64)0,
+				clbody->oa.o_valid & OBD_MD_FLFID ?
+				clbody->oa.o_parent_oid : 0,
+				clbody->oa.o_valid & OBD_MD_FLFID ?
+				clbody->oa.o_parent_ver : 0,
+				POSTID(&body->oa.o_oi),
+				aa->aa_ppga[0]->off,
+				aa->aa_ppga[page_count - 1]->off +
+				aa->aa_ppga[page_count - 1]->count - 1,
+				client_cksum, server_cksum,
+				cksum_type);
 			cksum_counter = 0;
 			aa->aa_oa->o_cksum = client_cksum;
 			rc = -EAGAIN;
@@ -1622,8 +1632,8 @@ static int osc_brw_redo_request(struct ptlrpc_request *request,
 	DEBUG_REQ(rc == -EINPROGRESS ? D_RPCTRACE : D_ERROR, request,
 		  "redo for recoverable error %d", rc);
 
-	rc = osc_brw_prep_request(lustre_msg_get_opc(request->rq_reqmsg) ==
-					OST_WRITE ? OBD_BRW_WRITE : OBD_BRW_READ,
+	rc = osc_brw_prep_request((lustre_msg_get_opc(request->rq_reqmsg) ==
+				   OST_WRITE) ? OBD_BRW_WRITE : OBD_BRW_READ,
 				  aa->aa_cli, aa->aa_oa,
 				  aa->aa_page_count, aa->aa_ppga,
 				  &new_req, 0, 1);
@@ -1648,7 +1658,8 @@ static int osc_brw_redo_request(struct ptlrpc_request *request,
 	 * what ptlrpc does (see after_reply())
 	 */
 	if (aa->aa_resends > new_req->rq_timeout)
-		new_req->rq_sent = ktime_get_real_seconds() + new_req->rq_timeout;
+		new_req->rq_sent = (ktime_get_real_seconds() +
+				    new_req->rq_timeout);
 	else
 		new_req->rq_sent = ktime_get_real_seconds() + aa->aa_resends;
 	new_req->rq_generation_set = 1;
@@ -1702,7 +1713,8 @@ static void sort_brw_pages(struct brw_page **array, int num)
 		for (i = stride ; i < num ; i++) {
 			tmp = array[i];
 			j = i;
-			while (j >= stride && array[j - stride]->off > tmp->off) {
+			while (j >= stride &&
+			       array[j - stride]->off > tmp->off) {
 				array[j] = array[j - stride];
 				j -= stride;
 			}
@@ -1733,7 +1745,9 @@ static int brw_interpret(const struct lu_env *env,
 	if (osc_recoverable_error(rc)) {
 		if (req->rq_import_generation !=
 		    req->rq_import->imp_generation) {
-			CDEBUG(D_HA, "%s: resend cross eviction for object: " DOSTID ", rc = %d.\n",
+			CDEBUG(D_HA,
+			       "%s: resend cross eviction for object: " DOSTID
+			       ", rc = %d.\n",
 			       req->rq_import->imp_obd->obd_name,
 			       POSTID(&aa->aa_oa->o_oi), rc);
 		} else if (rc == -EINPROGRESS ||
@@ -2093,7 +2107,6 @@ static int osc_enqueue_interpret(const struct lu_env *env,
 	__u32 lvb_len = sizeof(*lvb);
 	__u64 flags = 0;
 
-
 	/* ldlm_cli_enqueue is holding a reference on the lock, so it must
 	 * be valid.
 	 */
@@ -2212,7 +2225,8 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 			ldlm_lock_decref(&lockh, mode);
 			LDLM_LOCK_PUT(matched);
 			return -ECANCELED;
-		} else if (osc_set_lock_data(matched, einfo->ei_cbdata)) {
+		}
+		if (osc_set_lock_data(matched, einfo->ei_cbdata)) {
 			*flags |= LDLM_FL_LVB_READY;
 			/* We already have a lock, and it's referenced. */
 			(*upcall)(cookie, &lockh, ELDLM_LOCK_MATCHED);
@@ -2220,10 +2234,9 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 			ldlm_lock_decref(&lockh, mode);
 			LDLM_LOCK_PUT(matched);
 			return ELDLM_OK;
-		} else {
-			ldlm_lock_decref(&lockh, mode);
-			LDLM_LOCK_PUT(matched);
 		}
+		ldlm_lock_decref(&lockh, mode);
+		LDLM_LOCK_PUT(matched);
 	}
 
 no_match:
@@ -2269,9 +2282,9 @@ int osc_enqueue_base(struct obd_export *exp, struct ldlm_res_id *res_id,
 				aa->oa_lvb = lvb;
 			} else {
 				/* AGL is essentially to enqueue an DLM lock
-				* in advance, so we don't care about the
-				* result of AGL enqueue.
-				*/
+				 * in advance, so we don't care about the
+				 * result of AGL enqueue.
+				 */
 				aa->oa_lvb = NULL;
 				aa->oa_flags = NULL;
 			}
@@ -2663,7 +2676,8 @@ static int osc_reconnect(const struct lu_env *env,
 		cli->cl_lost_grant = 0;
 		spin_unlock(&cli->cl_loi_list_lock);
 
-		CDEBUG(D_RPCTRACE, "ocd_connect_flags: %#llx ocd_version: %d ocd_grant: %d, lost: %ld.\n",
+		CDEBUG(D_RPCTRACE,
+		       "ocd_connect_flags: %#llx ocd_version: %d ocd_grant: %d, lost: %ld.\n",
 		       data->ocd_connect_flags,
 		       data->ocd_version, data->ocd_grant, lost_grant);
 	}
@@ -2788,7 +2802,8 @@ static int osc_import_event(struct obd_device *obd,
 
 		/* See bug 7198 */
 		if (ocd->ocd_connect_flags & OBD_CONNECT_REQPORTAL)
-			imp->imp_client->cli_request_portal = OST_REQUEST_PORTAL;
+			imp->imp_client->cli_request_portal =
+				OST_REQUEST_PORTAL;
 
 		rc = obd_notify_observer(obd, obd, OBD_NOTIFY_OCD);
 		break;
