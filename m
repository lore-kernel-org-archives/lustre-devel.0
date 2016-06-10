From: Oleg Drokin <green@linuxhacker.ru>
Date: Thu,  9 Jun 2016 22:35:11 -0400
Subject: [lustre-devel] [PATCH 1/8] staging/lustre/osc: Fix Multiple
	Assignment Warnings
In-Reply-To: <1465526118-521053-1-git-send-email-green@linuxhacker.ru>
References: <1465526118-521053-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1465526118-521053-2-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Nathaniel Clark <nathaniel.l.clark@intel.com>, Oleg Drokin <green@linuxhacker.ru>

From: Nathaniel Clark <nathaniel.l.clark@intel.com>

Fix all multiple assignments on lustre/osc directory.

Signed-off-by: Nathaniel Clark <nathaniel.l.clark@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/osc/osc_cache.c   |  6 ++++--
 drivers/staging/lustre/lustre/osc/osc_io.c      | 12 ++++++++----
 drivers/staging/lustre/lustre/osc/osc_lock.c    |  3 ++-
 drivers/staging/lustre/lustre/osc/osc_request.c |  6 ++++--
 4 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index 5a14bea..2ca5045 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -2773,7 +2773,8 @@ int osc_queue_sync_pages(const struct lu_env *env, struct osc_object *obj,
 	ext->oe_sync = 1;
 	ext->oe_urgent = 1;
 	ext->oe_start = start;
-	ext->oe_end = ext->oe_max_end = end;
+	ext->oe_end = end;
+	ext->oe_max_end = end;
 	ext->oe_obj = obj;
 	ext->oe_srvlock = !!(brw_flags & OBD_BRW_SRVLOCK);
 	ext->oe_nr_pages = page_count;
@@ -3308,7 +3309,8 @@ int osc_lock_discard_pages(const struct lu_env *env, struct osc_object *osc,
 		goto out;
 
 	cb = mode == CLM_READ ? check_and_discard_cb : discard_cb;
-	info->oti_fn_index = info->oti_next_index = start;
+	info->oti_fn_index = start;
+	info->oti_next_index = start;
 	do {
 		res = osc_page_gang_lookup(env, io, osc,
 					   info->oti_next_index, end, cb, osc);
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index d534b0e..d3bce45 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -221,7 +221,8 @@ static void osc_page_touch_at(const struct lu_env *env,
 	       kms > loi->loi_kms ? "" : "not ", loi->loi_kms, kms,
 	       loi->loi_lvb.lvb_size);
 
-	attr->cat_mtime = attr->cat_ctime = LTIME_S(CURRENT_TIME);
+	attr->cat_ctime = LTIME_S(CURRENT_TIME);
+	attr->cat_mtime = attr->cat_ctime;
 	valid = CAT_MTIME | CAT_CTIME;
 	if (kms > loi->loi_kms) {
 		attr->cat_kms = kms;
@@ -458,7 +459,8 @@ static int osc_io_setattr_start(const struct lu_env *env,
 			unsigned int cl_valid = 0;
 
 			if (ia_valid & ATTR_SIZE) {
-				attr->cat_size = attr->cat_kms = size;
+				attr->cat_size = size;
+				attr->cat_kms = size;
 				cl_valid = CAT_SIZE | CAT_KMS;
 			}
 			if (ia_valid & ATTR_MTIME_SET) {
@@ -526,7 +528,8 @@ static void osc_io_setattr_end(const struct lu_env *env,
 
 	if (cbargs->opc_rpc_sent) {
 		wait_for_completion(&cbargs->opc_sync);
-		result = io->ci_result = cbargs->opc_rc;
+		result = cbargs->opc_rc;
+		io->ci_result = cbargs->opc_rc;
 	}
 	if (result == 0) {
 		if (oio->oi_lockless) {
@@ -575,7 +578,8 @@ static int osc_io_write_start(const struct lu_env *env,
 
 	OBD_FAIL_TIMEOUT(OBD_FAIL_OSC_DELAY_SETTIME, 1);
 	cl_object_attr_lock(obj);
-	attr->cat_mtime = attr->cat_ctime = ktime_get_real_seconds();
+	attr->cat_ctime = ktime_get_real_seconds();
+	attr->cat_mtime = attr->cat_ctime;
 	rc = cl_object_attr_set(env, obj, attr, CAT_MTIME | CAT_CTIME);
 	cl_object_attr_unlock(obj);
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index 16f9cd9..d30ed2f 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -1120,7 +1120,8 @@ static void osc_lock_set_writer(const struct lu_env *env,
 		}
 	} else {
 		LASSERT(cl_io_is_mkwrite(io));
-		io_start = io_end = io->u.ci_fault.ft_index;
+		io_start = io->u.ci_fault.ft_index;
+		io_end = io->u.ci_fault.ft_index;
 	}
 
 	if (descr->cld_mode >= CLM_WRITE &&
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 47417f8..7b1fc7e 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -474,7 +474,8 @@ static int osc_real_create(struct obd_export *exp, struct obdo *oa,
 		DEBUG_REQ(D_HA, req,
 			  "delorphan from OST integration");
 		/* Don't resend the delorphan req */
-		req->rq_no_resend = req->rq_no_delay = 1;
+		req->rq_no_resend = 1;
+		req->rq_no_delay = 1;
 	}
 
 	rc = ptlrpc_queue_wait(req);
@@ -2775,7 +2776,8 @@ static int osc_get_info(const struct lu_env *env, struct obd_export *exp,
 		tmp = req_capsule_client_get(&req->rq_pill, &RMF_SETINFO_KEY);
 		memcpy(tmp, key, keylen);
 
-		req->rq_no_delay = req->rq_no_resend = 1;
+		req->rq_no_delay = 1;
+		req->rq_no_resend = 1;
 		ptlrpc_request_set_replen(req);
 		rc = ptlrpc_queue_wait(req);
 		if (rc)
-- 
2.7.4
