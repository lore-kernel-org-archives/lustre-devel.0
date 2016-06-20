From: Oleg Drokin <green@linuxhacker.ru>
Date: Sun, 19 Jun 2016 22:07:32 -0400
Subject: [lustre-devel] [PATCH 17/28] staging/lustre/llite: change it_data
	to it_request
In-Reply-To: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
References: <1466388463-1817551-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1466388463-1817551-18-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: "John L. Hammond" <john.hammond@intel.com>

Change the void *it_data member of struct lookup_intent to struct
ptlrpc_request *it_request.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Reviewed-on: http://review.whamcloud.com/17070
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7403
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_intent.h |  2 +-
 drivers/staging/lustre/lustre/llite/dcache.c          |  6 +++---
 drivers/staging/lustre/lustre/llite/dir.c             |  2 +-
 drivers/staging/lustre/lustre/llite/file.c            | 17 ++++++++---------
 drivers/staging/lustre/lustre/llite/namei.c           |  2 +-
 drivers/staging/lustre/lustre/llite/xattr_cache.c     |  2 +-
 drivers/staging/lustre/lustre/lmv/lmv_intent.c        |  2 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c           |  4 ++--
 drivers/staging/lustre/lustre/mdc/mdc_locks.c         |  6 +++---
 drivers/staging/lustre/lustre/mdc/mdc_request.c       |  2 +-
 10 files changed, 22 insertions(+), 23 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_intent.h b/drivers/staging/lustre/lustre/include/lustre_intent.h
index 3aed810..ed2b6c6 100644
--- a/drivers/staging/lustre/lustre/include/lustre_intent.h
+++ b/drivers/staging/lustre/lustre/include/lustre_intent.h
@@ -46,7 +46,7 @@ struct lookup_intent {
 	int		it_lock_mode;
 	int		it_remote_lock_mode;
 	__u64	   it_remote_lock_handle;
-	void	   *it_data;
+	struct ptlrpc_request *it_request;
 	unsigned int    it_lock_set:1;
 };
 
diff --git a/drivers/staging/lustre/lustre/llite/dcache.c b/drivers/staging/lustre/lustre/llite/dcache.c
index c5789f7..d964f4f 100644
--- a/drivers/staging/lustre/lustre/llite/dcache.c
+++ b/drivers/staging/lustre/lustre/llite/dcache.c
@@ -233,13 +233,13 @@ void ll_intent_release(struct lookup_intent *it)
 	ll_intent_drop_lock(it);
 	/* We are still holding extra reference on a request, need to free it */
 	if (it_disposition(it, DISP_ENQ_OPEN_REF))
-		ptlrpc_req_finished(it->it_data); /* ll_file_open */
+		ptlrpc_req_finished(it->it_request); /* ll_file_open */
 
 	if (it_disposition(it, DISP_ENQ_CREATE_REF)) /* create rec */
-		ptlrpc_req_finished(it->it_data);
+		ptlrpc_req_finished(it->it_request);
 
 	it->it_disposition = 0;
-	it->it_data = NULL;
+	it->it_request = NULL;
 }
 
 void ll_invalidate_aliases(struct inode *inode)
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index a62df87..f0eb64b 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -362,7 +362,7 @@ struct page *ll_get_dir_page(struct inode *dir, __u64 hash,
 
 		ll_finish_md_op_data(op_data);
 
-		request = (struct ptlrpc_request *)it.it_data;
+		request = (struct ptlrpc_request *)it.it_request;
 		if (request)
 			ptlrpc_req_finished(request);
 		if (rc < 0) {
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 92fab63..a188366 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -476,10 +476,9 @@ void ll_ioepoch_open(struct ll_inode_info *lli, __u64 ioepoch)
 static int ll_och_fill(struct obd_export *md_exp, struct lookup_intent *it,
 		       struct obd_client_handle *och)
 {
-	struct ptlrpc_request *req = it->it_data;
 	struct mdt_body *body;
 
-	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
+	body = req_capsule_server_get(&it->it_request->rq_pill, &RMF_MDT_BODY);
 	och->och_fh = body->handle;
 	och->och_fid = body->fid1;
 	och->och_lease_handle.cookie = it->it_lock_handle;
@@ -500,7 +499,6 @@ static int ll_local_open(struct file *file, struct lookup_intent *it,
 	LASSERT(fd);
 
 	if (och) {
-		struct ptlrpc_request *req = it->it_data;
 		struct mdt_body *body;
 		int rc;
 
@@ -508,7 +506,8 @@ static int ll_local_open(struct file *file, struct lookup_intent *it,
 		if (rc != 0)
 			return rc;
 
-		body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
+		body = req_capsule_server_get(&it->it_request->rq_pill,
+					      &RMF_MDT_BODY);
 		ll_ioepoch_open(lli, body->ioepoch);
 	}
 
@@ -725,7 +724,7 @@ out_openerr:
 	}
 
 	if (it && it_disposition(it, DISP_ENQ_OPEN_REF)) {
-		ptlrpc_req_finished(it->it_data);
+		ptlrpc_req_finished(it->it_request);
 		it_clear_disposition(it, DISP_ENQ_OPEN_REF);
 	}
 
@@ -1413,7 +1412,7 @@ out_unlock:
 out:
 	return rc;
 out_req_free:
-	ptlrpc_req_finished((struct ptlrpc_request *)oit.it_data);
+	ptlrpc_req_finished((struct ptlrpc_request *)oit.it_request);
 	goto out;
 }
 
@@ -1701,7 +1700,7 @@ int ll_release_openhandle(struct inode *inode, struct lookup_intent *it)
 out:
 	/* this one is in place of ll_file_open */
 	if (it_disposition(it, DISP_ENQ_OPEN_REF)) {
-		ptlrpc_req_finished(it->it_data);
+		ptlrpc_req_finished(it->it_request);
 		it_clear_disposition(it, DISP_ENQ_OPEN_REF);
 	}
 	return rc;
@@ -3610,8 +3609,8 @@ again:
 
 	rc = md_enqueue(sbi->ll_md_exp, &einfo, &it, op_data, &lockh,
 			NULL, 0, NULL, 0);
-	ptlrpc_req_finished(it.it_data);
-	it.it_data = NULL;
+	ptlrpc_req_finished(it.it_request);
+	it.it_request = NULL;
 
 	ll_finish_md_op_data(op_data);
 
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 7a6da02..3664bfd 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -659,7 +659,7 @@ static struct inode *ll_create_node(struct inode *dir, struct lookup_intent *it)
 	LASSERT(it && it->it_disposition);
 
 	LASSERT(it_disposition(it, DISP_ENQ_CREATE_REF));
-	request = it->it_data;
+	request = it->it_request;
 	it_clear_disposition(it, DISP_ENQ_CREATE_REF);
 	rc = ll_prep_inode(&inode, request, dir->i_sb, it);
 	if (rc) {
diff --git a/drivers/staging/lustre/lustre/llite/xattr_cache.c b/drivers/staging/lustre/lustre/llite/xattr_cache.c
index 0d19645..8089da8 100644
--- a/drivers/staging/lustre/lustre/llite/xattr_cache.c
+++ b/drivers/staging/lustre/lustre/llite/xattr_cache.c
@@ -315,7 +315,7 @@ static int ll_xattr_find_get_lock(struct inode *inode,
 		return rc;
 	}
 
-	*req = (struct ptlrpc_request *)oit->it_data;
+	*req = oit->it_request;
 out:
 	down_write(&lli->lli_xattrs_list_rwsem);
 	mutex_unlock(&lli->lli_xattrs_enq_lock);
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index b3cff23..2f58fda 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -84,7 +84,7 @@ static int lmv_intent_remote(struct obd_export *exp, void *lmm,
 	if (pmode) {
 		plock.cookie = it->it_lock_handle;
 		it->it_lock_mode = 0;
-		it->it_data = NULL;
+		it->it_request = NULL;
 	}
 
 	LASSERT(fid_is_sane(&body->fid1));
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index eb675fa..210ed1e 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1679,7 +1679,7 @@ lmv_enqueue_remote(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 		   struct lustre_handle *lockh, void *lmm, int lmmsize,
 		   __u64 extra_lock_flags)
 {
-	struct ptlrpc_request      *req = it->it_data;
+	struct ptlrpc_request      *req = it->it_request;
 	struct obd_device	  *obd = exp->exp_obd;
 	struct lmv_obd	     *lmv = &obd->u.lmv;
 	struct lustre_handle	plock;
@@ -1705,7 +1705,7 @@ lmv_enqueue_remote(struct obd_export *exp, struct ldlm_enqueue_info *einfo,
 	LASSERT(pmode != 0);
 	memcpy(&plock, lockh, sizeof(plock));
 	it->it_lock_mode = 0;
-	it->it_data = NULL;
+	it->it_request = NULL;
 	fid1 = body->fid1;
 
 	ptlrpc_req_finished(req);
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_locks.c b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
index c43b3a2..c1f8da6 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_locks.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_locks.c
@@ -570,7 +570,7 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 	it->it_status = (int)lockrep->lock_policy_res2;
 	it->it_lock_mode = einfo->ei_mode;
 	it->it_lock_handle = lockh->cookie;
-	it->it_data = req;
+	it->it_request = req;
 
 	/* Technically speaking rq_transno must already be zero if
 	 * it_status is in error, so the check is a bit redundant
@@ -902,7 +902,7 @@ resend:
 
 		it->it_lock_handle = 0;
 		it->it_lock_mode = 0;
-		it->it_data = NULL;
+		it->it_request = NULL;
 	}
 
 	return rc;
@@ -1165,7 +1165,7 @@ int mdc_intent_lock(struct obd_export *exp, struct md_op_data *op_data,
 	if (rc < 0)
 		return rc;
 
-	*reqp = it->it_data;
+	*reqp = it->it_request;
 	rc = mdc_finish_intent_lock(exp, *reqp, op_data, it, &lockh);
 	return rc;
 }
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 7f5dfb0..2622eb3 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -661,7 +661,7 @@ int mdc_set_open_replay_data(struct obd_export *exp,
 	struct md_open_data   *mod;
 	struct mdt_rec_create *rec;
 	struct mdt_body       *body;
-	struct ptlrpc_request *open_req = it->it_data;
+	struct ptlrpc_request *open_req = it->it_request;
 	struct obd_import     *imp = open_req->rq_import;
 
 	if (!open_req->rq_replay)
-- 
2.7.4
