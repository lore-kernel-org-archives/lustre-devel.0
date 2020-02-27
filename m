From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:17:53 -0500
Subject: [lustre-devel] [PATCH 605/622] lnet: me: discard struct
 lnet_handle_me
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-606-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

The Portals API uses a cookie 'handle' to identify an ME.  This is
appropriate for a user-space API for objects maintained by the
kernel, but it brings no value when the API client and
implementation are both in the kernel, as is the case with Lustre
and LNet.

Instead of using a 'handle', a pointer to the 'struct lnet_me' can
be used.  This object is not reference counted and is always freed
correctly, so there can be no case where the cookie becomes invalid
while it is still held - as can be seen by the fact that the return
value from LNetMEUnlink() is never used except to assert that it is
zero.

So use 'struct lnet_me *' directly instead of having indirection
through a 'struct lnet_handle_me'.

Also:
  - change LNetMEUnlink() to return void as it cannot fail now.
  - have LNetMEAttach() return the pointer, using ERR_PTR() to return
    errors.
  - discard ln_me_containers and don't store the me there-in.
  - store an explicit 'cpt' in each me, we no longer store one
    implicitly via the cookie.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12678
Lustre-commit: ceeeae4271fd ("LU-12678 lnet: me: discard struct lnet_handle_me")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/36859
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/niobuf.c            | 45 ++++++++++++++++-----------------
 include/linux/lnet/api.h             | 20 +++++++--------
 include/linux/lnet/lib-lnet.h        | 22 -----------------
 include/linux/lnet/lib-types.h       |  4 +--
 include/uapi/linux/lnet/lnet-types.h |  4 ---
 net/lnet/lnet/api-ni.c               | 46 ++++++++++++----------------------
 net/lnet/lnet/lib-md.c               | 16 +++++-------
 net/lnet/lnet/lib-me.c               | 48 +++++++++++-------------------------
 net/lnet/selftest/rpc.c              | 14 +++++------
 9 files changed, 76 insertions(+), 143 deletions(-)

diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index fcf7bfa..26a1f97 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -118,11 +118,10 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 	struct ptlrpc_bulk_desc *desc = req->rq_bulk;
 	struct lnet_process_id peer;
 	int rc = 0;
-	int rc2;
 	int posted_md;
 	int total_md;
 	u64 mbits;
-	struct lnet_handle_me me_h;
+	struct lnet_me *me;
 	struct lnet_md md;
 
 	if (OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_BULK_GET_NET))
@@ -183,8 +182,9 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 		    OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_BULK_ATTACH)) {
 			rc = -ENOMEM;
 		} else {
-			rc = LNetMEAttach(desc->bd_portal, peer, mbits, 0,
-					  LNET_UNLINK, LNET_INS_AFTER, &me_h);
+			me = LNetMEAttach(desc->bd_portal, peer, mbits, 0,
+					  LNET_UNLINK, LNET_INS_AFTER);
+			rc = PTR_ERR_OR_ZERO(me);
 		}
 		if (rc != 0) {
 			CERROR("%s: LNetMEAttach failed x%llu/%d: rc = %d\n",
@@ -194,14 +194,13 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 		}
 
 		/* About to let the network at it... */
-		rc = LNetMDAttach(me_h, md, LNET_UNLINK,
+		rc = LNetMDAttach(me, md, LNET_UNLINK,
 				  &desc->bd_mds[posted_md]);
 		if (rc != 0) {
 			CERROR("%s: LNetMDAttach failed x%llu/%d: rc = %d\n",
 			       desc->bd_import->imp_obd->obd_name, mbits,
 			       posted_md, rc);
-			rc2 = LNetMEUnlink(me_h);
-			LASSERT(rc2 == 0);
+			LNetMEUnlink(me);
 			break;
 		}
 	}
@@ -479,11 +478,10 @@ int ptlrpc_error(struct ptlrpc_request *req)
 int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 {
 	int rc;
-	int rc2;
 	unsigned int mpflag = 0;
 	struct lnet_handle_md bulk_cookie;
 	struct ptlrpc_connection *connection;
-	struct lnet_handle_me reply_me_h;
+	struct lnet_me *reply_me;
 	struct lnet_md reply_md;
 	struct obd_import *imp = request->rq_import;
 	struct obd_device *obd = imp->imp_obd;
@@ -611,10 +609,11 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 			request->rq_repmsg = NULL;
 		}
 
-		rc = LNetMEAttach(request->rq_reply_portal,/*XXX FIXME bug 249*/
-				  connection->c_peer, request->rq_xid, 0,
-				  LNET_UNLINK, LNET_INS_AFTER, &reply_me_h);
-		if (rc != 0) {
+		reply_me = LNetMEAttach(request->rq_reply_portal,
+					connection->c_peer, request->rq_xid, 0,
+					LNET_UNLINK, LNET_INS_AFTER);
+		if (IS_ERR(reply_me)) {
+			rc = PTR_ERR(reply_me);
 			CERROR("LNetMEAttach failed: %d\n", rc);
 			LASSERT(rc == -ENOMEM);
 			rc = -ENOMEM;
@@ -652,7 +651,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 		/* We must see the unlink callback to set rq_reply_unlinked,
 		 * so we can't auto-unlink
 		 */
-		rc = LNetMDAttach(reply_me_h, reply_md, LNET_RETAIN,
+		rc = LNetMDAttach(reply_me, reply_md, LNET_RETAIN,
 				  &request->rq_reply_md_h);
 		if (rc != 0) {
 			CERROR("LNetMDAttach failed: %d\n", rc);
@@ -710,8 +709,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	 * nobody apart from the PUT's target has the right nid+XID to
 	 * access the reply buffer.
 	 */
-	rc2 = LNetMEUnlink(reply_me_h);
-	LASSERT(rc2 == 0);
+	LNetMEUnlink(reply_me);
 	/* UNLINKED callback called synchronously */
 	LASSERT(!request->rq_receiving_reply);
 
@@ -750,7 +748,7 @@ int ptlrpc_register_rqbd(struct ptlrpc_request_buffer_desc *rqbd)
 	};
 	int rc;
 	struct lnet_md md;
-	struct lnet_handle_me me_h;
+	struct lnet_me *me;
 
 	CDEBUG(D_NET, "LNetMEAttach: portal %d\n",
 	       service->srv_req_portal);
@@ -762,12 +760,12 @@ int ptlrpc_register_rqbd(struct ptlrpc_request_buffer_desc *rqbd)
 	 * which means buffer can only be attached on local CPT, and LND
 	 * threads can find it by grabbing a local lock
 	 */
-	rc = LNetMEAttach(service->srv_req_portal,
+	me = LNetMEAttach(service->srv_req_portal,
 			  match_id, 0, ~0, LNET_UNLINK,
 			  rqbd->rqbd_svcpt->scp_cpt >= 0 ?
-			  LNET_INS_LOCAL : LNET_INS_AFTER, &me_h);
-	if (rc != 0) {
-		CERROR("LNetMEAttach failed: %d\n", rc);
+			  LNET_INS_LOCAL : LNET_INS_AFTER);
+	if (IS_ERR(me)) {
+		CERROR("LNetMEAttach failed: %ld\n", PTR_ERR(me));
 		return -ENOMEM;
 	}
 
@@ -782,14 +780,13 @@ int ptlrpc_register_rqbd(struct ptlrpc_request_buffer_desc *rqbd)
 	md.user_ptr = &rqbd->rqbd_cbid;
 	md.eq_handle = ptlrpc_eq_h;
 
-	rc = LNetMDAttach(me_h, md, LNET_UNLINK, &rqbd->rqbd_md_h);
+	rc = LNetMDAttach(me, md, LNET_UNLINK, &rqbd->rqbd_md_h);
 	if (rc == 0)
 		return 0;
 
 	CERROR("LNetMDAttach failed: %d;\n", rc);
 	LASSERT(rc == -ENOMEM);
-	rc = LNetMEUnlink(me_h);
-	LASSERT(rc == 0);
+	LNetMEUnlink(me);
 	rqbd->rqbd_refcount = 0;
 
 	return -ENOMEM;
diff --git a/include/linux/lnet/api.h b/include/linux/lnet/api.h
index ac602fc..f9f6860 100644
--- a/include/linux/lnet/api.h
+++ b/include/linux/lnet/api.h
@@ -94,15 +94,15 @@
  * and removed from its list by LNetMEUnlink().
  * @{
  */
-int LNetMEAttach(unsigned int portal,
-		 struct lnet_process_id match_id_in,
-		 u64 match_bits_in,
-		 u64 ignore_bits_in,
-		 enum lnet_unlink unlink_in,
-		 enum lnet_ins_pos pos_in,
-		 struct lnet_handle_me *handle_out);
-
-int LNetMEUnlink(struct lnet_handle_me current_in);
+struct lnet_me *
+LNetMEAttach(unsigned int portal,
+	     struct lnet_process_id match_id_in,
+	     u64 match_bits_in,
+	     u64 ignore_bits_in,
+	     enum lnet_unlink unlink_in,
+	     enum lnet_ins_pos pos_in);
+
+void LNetMEUnlink(struct lnet_me *current_in);
 /** @} lnet_me */
 
 /** \defgroup lnet_md Memory descriptors
@@ -118,7 +118,7 @@ int LNetMEAttach(unsigned int portal,
  * associated with a MD: LNetMDUnlink().
  * @{
  */
-int LNetMDAttach(struct lnet_handle_me current_in,
+int LNetMDAttach(struct lnet_me *current_in,
 		 struct lnet_md md_in,
 		 enum lnet_unlink unlink_in,
 		 struct lnet_handle_md *md_handle_out);
diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index bf357b0..a8051fe 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -326,28 +326,6 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 }
 
 static inline void
-lnet_me2handle(struct lnet_handle_me *handle, struct lnet_me *me)
-{
-	handle->cookie = me->me_lh.lh_cookie;
-}
-
-static inline struct lnet_me *
-lnet_handle2me(struct lnet_handle_me *handle)
-{
-	/* ALWAYS called with resource lock held */
-	struct lnet_libhandle *lh;
-	int cpt;
-
-	cpt = lnet_cpt_of_cookie(handle->cookie);
-	lh = lnet_res_lh_lookup(the_lnet.ln_me_containers[cpt],
-				handle->cookie);
-	if (!lh)
-		return NULL;
-
-	return lh_entry(lh, struct lnet_me, me_lh);
-}
-
-static inline void
 lnet_peer_net_addref_locked(struct lnet_peer_net *lpn)
 {
 	atomic_inc(&lpn->lpn_refcount);
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 9055da9..3345940 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -192,7 +192,7 @@ struct lnet_eq {
 
 struct lnet_me {
 	struct list_head	 me_list;
-	struct lnet_libhandle	 me_lh;
+	int			 me_cpt;
 	struct lnet_process_id	 me_match_id;
 	unsigned int		 me_portal;
 	unsigned int		 me_pos;	/* hash offset in mt_hash */
@@ -1027,8 +1027,6 @@ struct lnet {
 	int				ln_nportals;
 	/* the vector of portals */
 	struct lnet_portal	      **ln_portals;
-	/* percpt ME containers */
-	struct lnet_res_container     **ln_me_containers;
 	/* percpt MD container */
 	struct lnet_res_container     **ln_md_containers;
 
diff --git a/include/uapi/linux/lnet/lnet-types.h b/include/uapi/linux/lnet/lnet-types.h
index cf263b9..118340f 100644
--- a/include/uapi/linux/lnet/lnet-types.h
+++ b/include/uapi/linux/lnet/lnet-types.h
@@ -374,10 +374,6 @@ static inline int LNetMDHandleIsInvalid(struct lnet_handle_md h)
 	return (LNET_WIRE_HANDLE_COOKIE_NONE == h.cookie);
 }
 
-struct lnet_handle_me {
-	u64	cookie;
-};
-
 /**
  * Global process ID.
  */
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 5df39aa..852bb0c 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -1115,14 +1115,6 @@ struct list_head **
 	if (rc)
 		goto failed;
 
-	recs = lnet_res_containers_create(LNET_COOKIE_TYPE_ME);
-	if (!recs) {
-		rc = -ENOMEM;
-		goto failed;
-	}
-
-	the_lnet.ln_me_containers = recs;
-
 	recs = lnet_res_containers_create(LNET_COOKIE_TYPE_MD);
 	if (!recs) {
 		rc = -ENOMEM;
@@ -1185,11 +1177,6 @@ struct list_head **
 		the_lnet.ln_md_containers = NULL;
 	}
 
-	if (the_lnet.ln_me_containers) {
-		lnet_res_containers_destroy(the_lnet.ln_me_containers);
-		the_lnet.ln_me_containers = NULL;
-	}
-
 	lnet_res_container_cleanup(&the_lnet.ln_eq_container);
 
 	lnet_msg_containers_destroy();
@@ -1594,7 +1581,7 @@ struct lnet_ping_buffer *
 		.nid = LNET_NID_ANY,
 		.pid = LNET_PID_ANY
 	};
-	struct lnet_handle_me me_handle;
+	struct lnet_me *me;
 	struct lnet_md md = { NULL };
 	int rc, rc2;
 
@@ -1614,11 +1601,11 @@ struct lnet_ping_buffer *
 	}
 
 	/* Ping target ME/MD */
-	rc = LNetMEAttach(LNET_RESERVED_PORTAL, id,
+	me = LNetMEAttach(LNET_RESERVED_PORTAL, id,
 			  LNET_PROTO_PING_MATCHBITS, 0,
-			  LNET_UNLINK, LNET_INS_AFTER,
-			  &me_handle);
-	if (rc) {
+			  LNET_UNLINK, LNET_INS_AFTER);
+	if (IS_ERR(me)) {
+		rc = PTR_ERR(me);
 		CERROR("Can't create ping target ME: %d\n", rc);
 		goto fail_decref_ping_buffer;
 	}
@@ -1633,7 +1620,7 @@ struct lnet_ping_buffer *
 	md.eq_handle = the_lnet.ln_ping_target_eq;
 	md.user_ptr = *ppbuf;
 
-	rc = LNetMDAttach(me_handle, md, LNET_RETAIN, ping_mdh);
+	rc = LNetMDAttach(me, md, LNET_RETAIN, ping_mdh);
 	if (rc) {
 		CERROR("Can't attach ping target MD: %d\n", rc);
 		goto fail_unlink_ping_me;
@@ -1643,8 +1630,7 @@ struct lnet_ping_buffer *
 	return 0;
 
 fail_unlink_ping_me:
-	rc2 = LNetMEUnlink(me_handle);
-	LASSERT(!rc2);
+	LNetMEUnlink(me);
 fail_decref_ping_buffer:
 	LASSERT(lnet_ping_buffer_numref(*ppbuf) == 1);
 	lnet_ping_buffer_decref(*ppbuf);
@@ -1773,7 +1759,7 @@ int lnet_push_target_resize(void)
 		.pid	= LNET_PID_ANY
 	};
 	struct lnet_md md = { NULL };
-	struct lnet_handle_me meh;
+	struct lnet_me *me;
 	struct lnet_handle_md mdh;
 	struct lnet_handle_md old_mdh;
 	struct lnet_ping_buffer *pbuf;
@@ -1792,11 +1778,11 @@ int lnet_push_target_resize(void)
 		goto fail_return;
 	}
 
-	rc = LNetMEAttach(LNET_RESERVED_PORTAL, id,
+	me = LNetMEAttach(LNET_RESERVED_PORTAL, id,
 			  LNET_PROTO_PING_MATCHBITS, 0,
-			  LNET_UNLINK, LNET_INS_AFTER,
-			  &meh);
-	if (rc) {
+			  LNET_UNLINK, LNET_INS_AFTER);
+	if (IS_ERR(me)) {
+		rc = PTR_ERR(me);
 		CERROR("Can't create push target ME: %d\n", rc);
 		goto fail_decref_pbuf;
 	}
@@ -1811,10 +1797,10 @@ int lnet_push_target_resize(void)
 	md.user_ptr = pbuf;
 	md.eq_handle = the_lnet.ln_push_target_eq;
 
-	rc = LNetMDAttach(meh, md, LNET_RETAIN, &mdh);
+	rc = LNetMDAttach(me, md, LNET_RETAIN, &mdh);
 	if (rc) {
 		CERROR("Can't attach push MD: %d\n", rc);
-		goto fail_unlink_meh;
+		goto fail_unlink_me;
 	}
 	lnet_ping_buffer_addref(pbuf);
 
@@ -1837,8 +1823,8 @@ int lnet_push_target_resize(void)
 
 	return 0;
 
-fail_unlink_meh:
-	LNetMEUnlink(meh);
+fail_unlink_me:
+	LNetMEUnlink(me);
 fail_decref_pbuf:
 	lnet_ping_buffer_decref(pbuf);
 fail_return:
diff --git a/net/lnet/lnet/lib-md.c b/net/lnet/lnet/lib-md.c
index 5ee43c2..4dae58f 100644
--- a/net/lnet/lnet/lib-md.c
+++ b/net/lnet/lnet/lib-md.c
@@ -337,7 +337,7 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 /**
  * Create a memory descriptor and attach it to a ME
  *
- * @meh		A handle for a ME to associate the new MD with.
+ * @me		An ME to associate the new MD with.
  * @umd		Provides initial values for the user-visible parts of a MD.
  *		Other than its use for initialization, there is no linkage
  *		between this structure and the MD maintained by the LNet.
@@ -354,19 +354,18 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
  * Return:	0 on success.
  *		-EINVAL If @umd is not valid.
  *		-ENOMEM If new MD cannot be allocated.
- *		-ENOENT Either @meh or @umd.eq_handle does not point to a
+ *		-ENOENT Either @me or @umd.eq_handle does not point to a
  *		valid object. Note that it's OK to supply a NULL @umd.eq_handle
  *		by calling LNetInvalidateHandle() on it.
- *		-EBUSY if the ME pointed to by @meh is already associated with
+ *		-EBUSY if the ME pointed to by @me is already associated with
  *		a MD.
  */
 int
-LNetMDAttach(struct lnet_handle_me meh, struct lnet_md umd,
+LNetMDAttach(struct lnet_me *me, struct lnet_md umd,
 	     enum lnet_unlink unlink, struct lnet_handle_md *handle)
 {
 	LIST_HEAD(matches);
 	LIST_HEAD(drops);
-	struct lnet_me *me;
 	struct lnet_libmd *md;
 	int cpt;
 	int rc;
@@ -389,14 +388,11 @@ int lnet_cpt_of_md(struct lnet_libmd *md, unsigned int offset)
 	if (rc)
 		goto out_free;
 
-	cpt = lnet_cpt_of_cookie(meh.cookie);
+	cpt = me->me_cpt;
 
 	lnet_res_lock(cpt);
 
-	me = lnet_handle2me(&meh);
-	if (!me)
-		rc = -ENOENT;
-	else if (me->me_md)
+	if (me->me_md)
 		rc = -EBUSY;
 	else
 		rc = lnet_md_link(md, umd.eq_handle, cpt);
diff --git a/net/lnet/lnet/lib-me.c b/net/lnet/lnet/lib-me.c
index 47cf498..d17f41d 100644
--- a/net/lnet/lnet/lib-me.c
+++ b/net/lnet/lnet/lib-me.c
@@ -62,20 +62,16 @@
  * @pos		Indicates whether the new ME should be prepended or
  *		appended to the match list. Allowed constants: LNET_INS_BEFORE,
  *		LNET_INS_AFTER.
- * @handle	On successful returns, a handle to the newly created ME object
- *		is saved here. This handle can be used later in LNetMEUnlink(),
- *		or LNetMDAttach() functions.
  *
- * Return:	0 On success.
- *		-EINVAL If @portal is invalid.
- *		-ENOMEM If new ME object cannot be allocated.
+ * Return:	0 On success. handle to the newly created ME is returned on success
+ *		ERR_PTR(-EINVAL) If \a portal is invalid.
+ *		ERR_PTR(-ENOMEM) If new ME object cannot be allocated.
  */
-int
+struct lnet_me *
 LNetMEAttach(unsigned int portal,
 	     struct lnet_process_id match_id,
 	     u64 match_bits, u64 ignore_bits,
-	     enum lnet_unlink unlink, enum lnet_ins_pos pos,
-	     struct lnet_handle_me *handle)
+	     enum lnet_unlink unlink, enum lnet_ins_pos pos)
 {
 	struct lnet_match_table *mtable;
 	struct lnet_me *me;
@@ -84,16 +80,16 @@
 	LASSERT(the_lnet.ln_refcount > 0);
 
 	if ((int)portal >= the_lnet.ln_nportals)
-		return -EINVAL;
+		return ERR_PTR(-EINVAL);
 
 	mtable = lnet_mt_of_attach(portal, match_id,
 				   match_bits, ignore_bits, pos);
 	if (!mtable) /* can't match portal type */
-		return -EPERM;
+		return ERR_PTR(-EPERM);
 
 	me = kmem_cache_alloc(lnet_mes_cachep, GFP_NOFS | __GFP_ZERO);
 	if (!me)
-		return -ENOMEM;
+		return ERR_PTR(-ENOMEM);
 
 	lnet_res_lock(mtable->mt_cpt);
 
@@ -104,8 +100,8 @@
 	me->me_unlink = unlink;
 	me->me_md = NULL;
 
-	lnet_res_lh_initialize(the_lnet.ln_me_containers[mtable->mt_cpt],
-			       &me->me_lh);
+	me->me_cpt = mtable->mt_cpt;
+
 	if (ignore_bits)
 		head = &mtable->mt_mhash[LNET_MT_HASH_IGNORE];
 	else
@@ -117,10 +113,8 @@
 	else
 		list_add(&me->me_list, head);
 
-	lnet_me2handle(handle, me);
-
 	lnet_res_unlock(mtable->mt_cpt);
-	return 0;
+	return me;
 }
 EXPORT_SYMBOL(LNetMEAttach);
 
@@ -132,32 +126,22 @@
  * and an unlink event will be generated. It is an error to use the ME handle
  * after calling LNetMEUnlink().
  *
- * @meh		A handle for the ME to be unlinked.
- *
- * Return	0 On success.
- *		-ENOENT If @meh does not point to a valid ME.
+ * @me		The ME to be unlinked.
  *
  * \see LNetMDUnlink() for the discussion on delivering unlink event.
  */
-int
-LNetMEUnlink(struct lnet_handle_me meh)
+void
+LNetMEUnlink(struct lnet_me *me)
 {
-	struct lnet_me *me;
 	struct lnet_libmd *md;
 	struct lnet_event ev;
 	int cpt;
 
 	LASSERT(the_lnet.ln_refcount > 0);
 
-	cpt = lnet_cpt_of_cookie(meh.cookie);
+	cpt = me->me_cpt;
 	lnet_res_lock(cpt);
 
-	me = lnet_handle2me(&meh);
-	if (!me) {
-		lnet_res_unlock(cpt);
-		return -ENOENT;
-	}
-
 	md = me->me_md;
 	if (md) {
 		md->md_flags |= LNET_MD_FLAG_ABORTED;
@@ -170,7 +154,6 @@
 	lnet_me_unlink(me);
 
 	lnet_res_unlock(cpt);
-	return 0;
 }
 EXPORT_SYMBOL(LNetMEUnlink);
 
@@ -188,6 +171,5 @@
 		lnet_md_unlink(md);
 	}
 
-	lnet_res_lh_invalidate(&me->me_lh);
 	kfree(me);
 }
diff --git a/net/lnet/selftest/rpc.c b/net/lnet/selftest/rpc.c
index 7a8226c..531377d 100644
--- a/net/lnet/selftest/rpc.c
+++ b/net/lnet/selftest/rpc.c
@@ -360,11 +360,12 @@ struct srpc_bulk *
 {
 	int rc;
 	struct lnet_md md;
-	struct lnet_handle_me meh;
+	struct lnet_me *me;
 
-	rc = LNetMEAttach(portal, peer, matchbits, 0, LNET_UNLINK,
-			  local ? LNET_INS_LOCAL : LNET_INS_AFTER, &meh);
-	if (rc) {
+	me = LNetMEAttach(portal, peer, matchbits, 0, LNET_UNLINK,
+			  local ? LNET_INS_LOCAL : LNET_INS_AFTER);
+	if (IS_ERR(me)) {
+		rc = PTR_ERR(me);
 		CERROR("LNetMEAttach failed: %d\n", rc);
 		LASSERT(rc == -ENOMEM);
 		return -ENOMEM;
@@ -377,13 +378,12 @@ struct srpc_bulk *
 	md.options = options;
 	md.eq_handle = srpc_data.rpc_lnet_eq;
 
-	rc = LNetMDAttach(meh, md, LNET_UNLINK, mdh);
+	rc = LNetMDAttach(me, md, LNET_UNLINK, mdh);
 	if (rc) {
 		CERROR("LNetMDAttach failed: %d\n", rc);
 		LASSERT(rc == -ENOMEM);
 
-		rc = LNetMEUnlink(meh);
-		LASSERT(!rc);
+		LNetMEUnlink(me);
 		return -ENOMEM;
 	}
 
-- 
1.8.3.1
