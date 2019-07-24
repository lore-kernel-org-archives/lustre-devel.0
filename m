From: James Simmons <jsimmons@infradead.org>
Date: Wed, 24 Jul 2019 04:37:00 +0100 (BST)
Subject: [lustre-devel] [PATCH 10/11] lustre: ldlm: checkpatch cleanup
In-Reply-To: <87tvbdjwa7.fsf@notabene.neil.brown.name>
References: <1563760338-806-1-git-send-email-jsimmons@infradead.org>
 <1563760338-806-11-git-send-email-jsimmons@infradead.org>
 <87tvbdjwa7.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1907240433050.12135@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> > @@ -286,7 +286,7 @@ static void ldlm_handle_gl_callback(struct ptlrpc_request *req,
> >  				    struct ldlm_request *dlm_req,
> >  				    struct ldlm_lock *lock)
> >  {
> > -	int rc = -ENOSYS;
> > +	int rc = -ENXIO;
> 
> Is this really a checkpatch warning?
> Is it safe?
> Is there a visible behaviour change here, or is the error status only
> used internally?
> 
> There seem to be a few others ... maybe checkpatch doesn't like ENOSYS -
> probably reasonable.
> 
> Everything else looks OK.
> 
> Thanks for these!

From checkpatch - "ENOSYS means 'invalid syscall nr' and nothing else"
So using ENOSYS is no no. We get away with this because people rarely
actually handle each error code individually. Only the MDT coordinator
really looks to see if the errno code is ENOSYS.
 
> NeilBrown
> 
> 
> >  
> >  	LDLM_DEBUG(lock, "client glimpse AST callback handler");
> >  
> > @@ -396,8 +396,10 @@ static int ldlm_bl_to_thread(struct ldlm_namespace *ns,
> >  			     struct list_head *cancels, int count,
> >  			     enum ldlm_cancel_flags cancel_flags)
> >  {
> > +	int rc = 0;
> > +
> >  	if (cancels && count == 0)
> > -		return 0;
> > +		return rc;
> >  
> >  	if (cancel_flags & LCF_ASYNC) {
> >  		struct ldlm_bl_work_item *blwi;
> > @@ -407,7 +409,7 @@ static int ldlm_bl_to_thread(struct ldlm_namespace *ns,
> >  			return -ENOMEM;
> >  		init_blwi(blwi, ns, ld, cancels, count, lock, cancel_flags);
> >  
> > -		return __ldlm_bl_to_thread(blwi, cancel_flags);
> > +		rc = __ldlm_bl_to_thread(blwi, cancel_flags);
> >  	} else {
> >  		/* if it is synchronous call do minimum mem alloc, as it could
> >  		 * be triggered from kernel shrinker
> > @@ -416,8 +418,9 @@ static int ldlm_bl_to_thread(struct ldlm_namespace *ns,
> >  
> >  		memset(&blwi, 0, sizeof(blwi));
> >  		init_blwi(&blwi, ns, ld, cancels, count, lock, cancel_flags);
> > -		return __ldlm_bl_to_thread(&blwi, cancel_flags);
> > +		rc = __ldlm_bl_to_thread(&blwi, cancel_flags);
> >  	}
> > +	return rc;
> >  }
> >  
> >  int ldlm_bl_to_thread_lock(struct ldlm_namespace *ns, struct ldlm_lock_desc *ld,
> > @@ -446,7 +449,7 @@ static int ldlm_handle_setinfo(struct ptlrpc_request *req)
> >  	char *key;
> >  	void *val;
> >  	int keylen, vallen;
> > -	int rc = -ENOSYS;
> > +	int rc = -ENXIO;
> >  
> >  	DEBUG_REQ(D_HSM, req, "%s: handle setinfo\n", obd->obd_name);
> >  
> > @@ -875,6 +878,7 @@ int ldlm_get_ref(void)
> >  void ldlm_put_ref(void)
> >  {
> >  	int rc = 0;
> > +
> >  	mutex_lock(&ldlm_ref_mutex);
> >  	if (ldlm_refcount == 1) {
> >  		rc = ldlm_cleanup();
> > diff --git a/fs/lustre/ldlm/ldlm_pool.c b/fs/lustre/ldlm/ldlm_pool.c
> > index 1f81795..6714c30 100644
> > --- a/fs/lustre/ldlm/ldlm_pool.c
> > +++ b/fs/lustre/ldlm/ldlm_pool.c
> > @@ -360,7 +360,8 @@ static int ldlm_pool_recalc(struct ldlm_pool *pl)
> >  	recalc_interval_sec = ktime_get_real_seconds() - pl->pl_recalc_time;
> >  	if (recalc_interval_sec > 0) {
> >  		spin_lock(&pl->pl_lock);
> > -		recalc_interval_sec = ktime_get_real_seconds() - pl->pl_recalc_time;
> > +		recalc_interval_sec = ktime_get_real_seconds() -
> > +				      pl->pl_recalc_time;
> >  
> >  		if (recalc_interval_sec > 0) {
> >  			/*
> > diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
> > index a614d74..b7dcfda 100644
> > --- a/fs/lustre/ldlm/ldlm_request.c
> > +++ b/fs/lustre/ldlm/ldlm_request.c
> > @@ -438,7 +438,7 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
> >  			       PLDLMRES(lock->l_resource));
> >  
> >  			rc = ldlm_lock_change_resource(ns, lock,
> > -					&reply->lock_desc.l_resource.lr_name);
> > +						       &reply->lock_desc.l_resource.lr_name);
> >  			if (rc || !lock->l_resource) {
> >  				rc = -ENOMEM;
> >  				goto cleanup;
> > @@ -450,9 +450,9 @@ int ldlm_cli_enqueue_fini(struct obd_export *exp, struct ptlrpc_request *req,
> >  			      !(exp_connect_flags(exp) & OBD_CONNECT_IBITS)))
> >  				/* We assume lock type cannot change on server*/
> >  				ldlm_convert_policy_to_local(exp,
> > -						lock->l_resource->lr_type,
> > -						&reply->lock_desc.l_policy_data,
> > -						&lock->l_policy_data);
> > +							     lock->l_resource->lr_type,
> > +							     &reply->lock_desc.l_policy_data,
> > +							     &lock->l_policy_data);
> >  		if (type != LDLM_PLAIN)
> >  			LDLM_DEBUG(lock,
> >  				   "client-side enqueue, new policy data");
> > @@ -927,8 +927,7 @@ static int ldlm_cli_cancel_req(struct obd_export *exp,
> >  		if (rc == LUSTRE_ESTALE) {
> >  			CDEBUG(D_DLMTRACE,
> >  			       "client/server (nid %s) out of sync -- not fatal\n",
> > -			       libcfs_nid2str(req->rq_import->
> > -					      imp_connection->c_peer.nid));
> > +			       libcfs_nid2str(req->rq_import->imp_connection->c_peer.nid));
> >  			rc = 0;
> >  		} else if (rc == -ETIMEDOUT && /* check there was no reconnect*/
> >  			   req->rq_import_generation == imp->imp_generation) {
> > @@ -1290,10 +1289,9 @@ static enum ldlm_policy_res ldlm_cancel_aged_policy(struct ldlm_namespace *ns,
> >  		LDLM_POLICY_KEEP_LOCK : LDLM_POLICY_CANCEL_LOCK;
> >  }
> >  
> > -typedef enum ldlm_policy_res (*ldlm_cancel_lru_policy_t)(
> > -						      struct ldlm_namespace *,
> > -						      struct ldlm_lock *, int,
> > -						      int, int);
> > +typedef enum ldlm_policy_res (*ldlm_cancel_lru_policy_t)(struct ldlm_namespace *,
> > +							 struct ldlm_lock *,
> > +							 int, int, int);
> >  
> >  static ldlm_cancel_lru_policy_t
> >  ldlm_cancel_lru_policy(struct ldlm_namespace *ns, int lru_flags)
> > -- 
> > 1.8.3.1
> 
