From: James Simmons <jsimmons@infradead.org>
Date: Fri,  4 Mar 2016 21:09:46 -0500
Subject: [lustre-devel] [PATCH 06/10] staging: lustre: Correct missing
	newline
In-Reply-To: <1457143790-19422-1-git-send-email-jsimmons@infradead.org>
References: <1457143790-19422-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1457143790-19422-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Nunez <james.a.nunez@intel.com>

From: James Nunez <james.a.nunez@intel.com>

Several error messages are missing newline characters
at the end of the message. Newlines are added where
necessary and other minor corrections; no punctuation
at the end of an error message, add a return code to
the end of error messages, device name at the beginning,
etc.

There are just a couple of places where newlines are
removed and this is only in LDLM_DEBUG_NOLOCK. The definition
of LDLM_DEBUG_NOLOCK already has a newline in it and
resulted in double newlines printed.

Signed-off-by: James Nunez <james.a.nunez@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4871
Reviewed-on: http://review.whamcloud.com/10000
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Cliff White <cliff.white@intel.com>
---
 drivers/staging/lustre/lnet/selftest/framework.c   |    6 +++---
 drivers/staging/lustre/lnet/selftest/rpc.c         |    2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |    2 +-
 drivers/staging/lustre/lustre/llite/file.c         |    8 ++++----
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |    2 +-
 drivers/staging/lustre/lustre/lov/lov_lock.c       |    2 +-
 drivers/staging/lustre/lustre/lov/lov_obd.c        |    2 +-
 drivers/staging/lustre/lustre/lov/lov_pool.c       |    4 ++--
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    3 ++-
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |    3 ++-
 drivers/staging/lustre/lustre/obdclass/cl_lock.c   |    2 +-
 .../lustre/lustre/obdclass/lprocfs_status.c        |    2 +-
 drivers/staging/lustre/lustre/obdclass/lu_object.c |    2 +-
 .../staging/lustre/lustre/obdecho/echo_client.c    |    8 ++++++--
 drivers/staging/lustre/lustre/osc/osc_cache.c      |    9 +++++----
 drivers/staging/lustre/lustre/osc/osc_lock.c       |    2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |    3 ++-
 drivers/staging/lustre/lustre/ptlrpc/client.c      |    6 +++---
 drivers/staging/lustre/lustre/ptlrpc/sec.c         |    4 ++--
 19 files changed, 40 insertions(+), 32 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 5c7cafa..a2f94fa 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -453,7 +453,7 @@ sfw_make_session(srpc_mksn_reqst_t *request, srpc_mksn_reply_t *reply)
 	/* brand new or create by force */
 	LIBCFS_ALLOC(sn, sizeof(sfw_session_t));
 	if (!sn) {
-		CERROR("Dropping RPC (mksn) under memory pressure.\n");
+		CERROR("dropping RPC mksn under memory pressure\n");
 		return -ENOMEM;
 	}
 
@@ -1155,7 +1155,7 @@ sfw_add_test(struct srpc_server_rpc *rpc)
 
 	bat = sfw_bid2batch(request->tsr_bid);
 	if (!bat) {
-		CERROR("Dropping RPC (%s) from %s under memory pressure.\n",
+		CERROR("dropping RPC %s from %s under memory pressure\n",
 		       rpc->srpc_scd->scd_svc->sv_name,
 		       libcfs_id2str(rpc->srpc_peer));
 		return -ENOMEM;
@@ -1367,7 +1367,7 @@ sfw_bulk_ready(struct srpc_server_rpc *rpc, int status)
 	}
 
 	if (sfw_del_session_timer()) {
-		CERROR("Dropping RPC (%s) from %s: racing with expiry timer",
+		CERROR("dropping RPC %s from %s: racing with expiry timer\n",
 		       sv->sv_name, libcfs_id2str(rpc->srpc_peer));
 		spin_unlock(&sfw_data.fw_lock);
 		return -EAGAIN;
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index 129fa02..5eb4232 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -667,7 +667,7 @@ srpc_finish_service(struct srpc_service *sv)
 		}
 
 		if (scd->scd_buf_nposted > 0) {
-			CDEBUG(D_NET, "waiting for %d posted buffers to unlink",
+			CDEBUG(D_NET, "waiting for %d posted buffers to unlink\n",
 			       scd->scd_buf_nposted);
 			spin_unlock(&scd->scd_lock);
 			return 0;
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index 6f0761c..c7904a9 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -1041,7 +1041,7 @@ int ldlm_cli_cancel(struct lustre_handle *lockh,
 	/* concurrent cancels on the same handle can happen */
 	lock = ldlm_handle2lock_long(lockh, LDLM_FL_CANCELING);
 	if (!lock) {
-		LDLM_DEBUG_NOLOCK("lock is already being destroyed\n");
+		LDLM_DEBUG_NOLOCK("lock is already being destroyed");
 		return 0;
 	}
 
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index d3ed905..cf619af 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -952,7 +952,7 @@ static int ll_lsm_getattr(struct lov_stripe_md *lsm, struct obd_export *exp,
 
 	set = ptlrpc_prep_set();
 	if (!set) {
-		CERROR("can't allocate ptlrpc set\n");
+		CERROR("cannot allocate ptlrpc set: rc = %d\n", -ENOMEM);
 		rc = -ENOMEM;
 	} else {
 		rc = obd_getattr_async(exp, &oinfo, set);
@@ -1180,7 +1180,7 @@ out:
 		CDEBUG(D_VFSTRACE, "Restart %s on %pD from %lld, count:%zd\n",
 		       iot == CIT_READ ? "read" : "write",
 		       file, *ppos, count);
-		LASSERTF(io->ci_nob == 0, "%zd", io->ci_nob);
+		LASSERTF(io->ci_nob == 0, "%zd\n", io->ci_nob);
 		goto restart;
 	}
 
@@ -3415,7 +3415,7 @@ static int ll_layout_lock_set(struct lustre_handle *lockh, enum ldlm_mode mode,
 	LASSERT(lock);
 	LASSERT(ldlm_has_layout(lock));
 
-	LDLM_DEBUG(lock, "File %p/"DFID" being reconfigured: %d.\n",
+	LDLM_DEBUG(lock, "File %p/"DFID" being reconfigured: %d",
 		   inode, PFID(&lli->lli_fid), reconf);
 
 	/* in case this is a caching lock and reinstate with new inode */
@@ -3571,7 +3571,7 @@ again:
 	it.it_op = IT_LAYOUT;
 	lockh.cookie = 0ULL;
 
-	LDLM_DEBUG_NOLOCK("%s: requeue layout lock for file %p/" DFID ".\n",
+	LDLM_DEBUG_NOLOCK("%s: requeue layout lock for file %p/" DFID "",
 			  ll_get_fsname(inode->i_sb, NULL, 0), inode,
 			PFID(&lli->lli_fid));
 
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 267f001..0f776cf 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -311,7 +311,7 @@ static int lmv_init_ea_size(struct obd_export *exp, int easize,
 		rc = md_init_ea_size(lmv->tgts[i]->ltd_exp, easize, def_easize,
 				     cookiesize, def_cookiesize);
 		if (rc) {
-			CERROR("%s: obd_init_ea_size() failed on MDT target %d: rc = %d.\n",
+			CERROR("%s: obd_init_ea_size() failed on MDT target %d: rc = %d\n",
 			       obd->obd_name, i, rc);
 			break;
 		}
diff --git a/drivers/staging/lustre/lustre/lov/lov_lock.c b/drivers/staging/lustre/lustre/lov/lov_lock.c
index 1169a80..ae854bc 100644
--- a/drivers/staging/lustre/lustre/lov/lov_lock.c
+++ b/drivers/staging/lustre/lustre/lov/lov_lock.c
@@ -264,7 +264,7 @@ static int lov_subresult(int result, int rc)
 	int rc_rank;
 
 	LASSERTF(result <= 0 || result == CLO_REPEAT || result == CLO_WAIT,
-		 "result = %d", result);
+		 "result = %d\n", result);
 	LASSERTF(rc <= 0 || rc == CLO_REPEAT || rc == CLO_WAIT,
 		 "rc = %d\n", rc);
 	CLASSERT(CLO_WAIT < CLO_REPEAT);
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index a86c1c4..5daa7fa 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -2199,7 +2199,7 @@ static int lov_quotactl(struct obd_device *obd, struct obd_export *exp,
 	    oqctl->qc_cmd != Q_INITQUOTA &&
 	    oqctl->qc_cmd != LUSTRE_Q_SETQUOTA &&
 	    oqctl->qc_cmd != Q_FINVALIDATE) {
-		CERROR("bad quota opc %x for lov obd", oqctl->qc_cmd);
+		CERROR("bad quota opc %x for lov obd\n", oqctl->qc_cmd);
 		return -EFAULT;
 	}
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_pool.c b/drivers/staging/lustre/lustre/lov/lov_pool.c
index be95dd7..9ae1d6f 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pool.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pool.c
@@ -173,7 +173,7 @@ static void *pool_proc_next(struct seq_file *s, void *v, loff_t *pos)
 	struct pool_iterator *iter = (struct pool_iterator *)s->private;
 	int prev_idx;
 
-	LASSERTF(iter->magic == POOL_IT_MAGIC, "%08X", iter->magic);
+	LASSERTF(iter->magic == POOL_IT_MAGIC, "%08X\n", iter->magic);
 
 	/* test if end of file */
 	if (*pos >= pool_tgt_count(iter->pool))
@@ -257,7 +257,7 @@ static int pool_proc_show(struct seq_file *s, void *v)
 	struct pool_iterator *iter = (struct pool_iterator *)v;
 	struct lov_tgt_desc *tgt;
 
-	LASSERTF(iter->magic == POOL_IT_MAGIC, "%08X", iter->magic);
+	LASSERTF(iter->magic == POOL_IT_MAGIC, "%08X\n", iter->magic);
 	LASSERT(iter->pool);
 	LASSERT(iter->idx <= pool_tgt_count(iter->pool));
 
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index a4f3e70..55dd8ef 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -1739,7 +1739,8 @@ static int mdc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 	int rc;
 
 	if (!try_module_get(THIS_MODULE)) {
-		CERROR("Can't get module. Is it alive?");
+		CERROR("%s: cannot get module '%s'\n", obd->obd_name,
+		       module_name(THIS_MODULE));
 		return -EINVAL;
 	}
 	switch (cmd) {
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index bc49633..2dc5e57 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -349,7 +349,8 @@ static int config_log_add(struct obd_device *obd, char *logname,
 		if (ptr != NULL) {
 			*ptr = 0;
 		} else {
-			CERROR("sptlrpc log name not correct: %s", seclogname);
+			CERROR("%s: sptlrpc log name not correct, %s: rc = %d\n",
+			       obd->obd_name, seclogname, -EINVAL);
 			config_log_put(cld);
 			return -EINVAL;
 		}
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_lock.c b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
index f40a2ec..aec644e 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_lock.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
@@ -97,7 +97,7 @@ static int cl_lock_invariant(const struct lu_env *env,
 	result = atomic_read(&lock->cll_ref) > 0 &&
 		cl_lock_invariant_trusted(env, lock);
 	if (!result && env)
-		CL_LOCK_DEBUG(D_ERROR, env, lock, "invariant broken");
+		CL_LOCK_DEBUG(D_ERROR, env, lock, "invariant broken\n");
 	return result;
 }
 
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index 1ea1578..5f52eab 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -256,7 +256,7 @@ struct dentry *ldebugfs_add_simple(struct dentry *root,
 		mode |= 0200;
 	entry = debugfs_create_file(name, mode, root, data, fops);
 	if (IS_ERR_OR_NULL(entry)) {
-		CERROR("LprocFS: No memory to create <debugfs> entry %s", name);
+		CERROR("LprocFS: No memory to create <debugfs> entry %s\n", name);
 		return entry ?: ERR_PTR(-ENOMEM);
 	}
 	return entry;
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index cefd39e..65a4746 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -459,7 +459,7 @@ int lu_cdebug_printer(const struct lu_env *env,
 		  ARRAY_SIZE(key->lck_area) - used, format, args);
 	if (complete) {
 		if (cfs_cdebug_show(msgdata->msg_mask, msgdata->msg_subsys))
-			libcfs_debug_msg(msgdata, "%s", key->lck_area);
+			libcfs_debug_msg(msgdata, "%s\n", key->lck_area);
 		key->lck_area[0] = 0;
 	}
 	va_end(args);
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index 3edd7c8..64ffe24 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -1293,8 +1293,12 @@ static int echo_get_object(struct echo_object **ecop, struct echo_device *ed,
 
 static void echo_put_object(struct echo_object *eco)
 {
-	if (cl_echo_object_put(eco))
-		CERROR("echo client: drop an object failed");
+	int rc;
+
+	rc = cl_echo_object_put(eco);
+	if (rc)
+		CERROR("%s: echo client drop an object failed: rc = %d\n",
+		       eco->eo_dev->ed_ec->ec_exp->exp_obd->obd_name, rc);
 }
 
 static void
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 6243aac..2e45255 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -464,7 +464,7 @@ static void osc_extent_insert(struct osc_object *obj, struct osc_extent *ext)
 		else if (ext->oe_start > tmp->oe_end)
 			n = &(*n)->rb_right;
 		else
-			EASSERTF(0, tmp, EXTSTR, EXTPARA(ext));
+			EASSERTF(0, tmp, EXTSTR"\n", EXTPARA(ext));
 	}
 	rb_link_node(&ext->oe_node, parent, n);
 	rb_insert_color(&ext->oe_node, &obj->oo_root);
@@ -674,7 +674,8 @@ static struct osc_extent *osc_extent_find(const struct lu_env *env,
 	/* grants has been allocated by caller */
 	LASSERTF(*grants >= chunksize + cli->cl_extent_tax,
 		 "%u/%u/%u.\n", *grants, chunksize, cli->cl_extent_tax);
-	LASSERTF((max_end - cur->oe_start) < max_pages, EXTSTR, EXTPARA(cur));
+	LASSERTF((max_end - cur->oe_start) < max_pages, EXTSTR"\n",
+		 EXTPARA(cur));
 
 restart:
 	osc_object_lock(obj);
@@ -692,7 +693,7 @@ restart:
 		/* if covering by different locks, no chance to match */
 		if (lock != ext->oe_osclock) {
 			EASSERTF(!overlapped(ext, cur), ext,
-				 EXTSTR, EXTPARA(cur));
+				 EXTSTR"\n", EXTPARA(cur));
 
 			ext = next_extent(ext);
 			continue;
@@ -715,7 +716,7 @@ restart:
 			 */
 			EASSERTF((ext->oe_start <= cur->oe_start &&
 				  ext->oe_end >= cur->oe_end),
-				 ext, EXTSTR, EXTPARA(cur));
+				 ext, EXTSTR"\n", EXTPARA(cur));
 
 			if (ext->oe_state > OES_CACHE || ext->oe_fsync_wait) {
 				/* for simplicity, we wait for this extent to
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index 8a3e872..013df97 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -1590,7 +1590,7 @@ int osc_lock_init(const struct lu_env *env,
 		if (clk->ols_locklessable && !(enqflags & CEF_DISCARD_DATA))
 			clk->ols_flags |= LDLM_FL_DENY_ON_CONTENTION;
 
-		LDLM_DEBUG_NOLOCK("lock %p, osc lock %p, flags %llx\n",
+		LDLM_DEBUG_NOLOCK("lock %p, osc lock %p, flags %llx",
 				  lock, clk, clk->ols_flags);
 
 		result = 0;
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 2238f92..74805f1 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2639,7 +2639,8 @@ static int osc_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 	int err = 0;
 
 	if (!try_module_get(THIS_MODULE)) {
-		CERROR("Can't get module. Is it alive?");
+		CERROR("%s: cannot get module '%s'\n", obd->obd_name,
+		       module_name(THIS_MODULE));
 		return -EINVAL;
 	}
 	switch (cmd) {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 9f65a10..1b7673e 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -722,9 +722,9 @@ struct ptlrpc_request *__ptlrpc_request_alloc(struct obd_import *imp,
 		request = ptlrpc_prep_req_from_pool(pool);
 
 	if (request) {
-		LASSERTF((unsigned long)imp > 0x1000, "%p", imp);
+		LASSERTF((unsigned long)imp > 0x1000, "%p\n", imp);
 		LASSERT(imp != LP_POISON);
-		LASSERTF((unsigned long)imp->imp_client > 0x1000, "%p",
+		LASSERTF((unsigned long)imp->imp_client > 0x1000, "%p\n",
 			 imp->imp_client);
 		LASSERT(imp->imp_client != LP_POISON);
 
@@ -2602,7 +2602,7 @@ int ptlrpc_queue_wait(struct ptlrpc_request *req)
 
 	set = ptlrpc_prep_set();
 	if (!set) {
-		CERROR("Unable to allocate ptlrpc set.");
+		CERROR("cannot allocate ptlrpc set: rc = %d\n", -ENOMEM);
 		return -ENOMEM;
 	}
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec.c b/drivers/staging/lustre/lustre/ptlrpc/sec.c
index 14d0fc7..187fd1d 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec.c
@@ -1995,7 +1995,7 @@ int sptlrpc_svc_alloc_rs(struct ptlrpc_request *req, int msglen)
 		if (svcpt->scp_service->srv_max_reply_size <
 		   msglen + sizeof(struct ptlrpc_reply_state)) {
 			/* Just return failure if the size is too big */
-			CERROR("size of message is too big (%zd), %d allowed",
+			CERROR("size of message is too big (%zd), %d allowed\n",
 			       msglen + sizeof(struct ptlrpc_reply_state),
 			       svcpt->scp_service->srv_max_reply_size);
 			return -ENOMEM;
@@ -2165,7 +2165,7 @@ int sptlrpc_cli_unwrap_bulk_write(struct ptlrpc_request *req,
 	 * in case of privacy mode, nob_transferred needs to be adjusted.
 	 */
 	if (desc->bd_nob != desc->bd_nob_transferred) {
-		CERROR("nob %d doesn't match transferred nob %d",
+		CERROR("nob %d doesn't match transferred nob %d\n",
 		       desc->bd_nob, desc->bd_nob_transferred);
 		return -EPROTO;
 	}
-- 
1.7.1
