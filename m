From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:05:43 -0400
Subject: [lustre-devel] [PATCH 04/42] lustre: mdc: fix lovea for replay
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Alexander Zarochentsev <alexander.zarochentsev@hpe.com>

lmm->lmm_stripe_offset gets overwritten by
layout generation at server reply,
so MDT does not recognize such LOVEA as
a valid striping at open request replay.
This patch extendes LU-7008 fix by supporting
of PFL layout.

HPE-bug-id: LUS-8820
WC-bug-id: https://jira.whamcloud.com/browse/LU-13809
Lustre-commit: 72d45e1d344c5 ("LU-13809 mdc: fix lovea for replay")
Signed-off-by: Alexander Zarochentsev <alexander.zarochentsev@hpe.com>
Reviewed-on: https://review.whamcloud.com/39468
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Vladimir Saveliev <c17830@cray.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd.h     |  2 ++
 fs/lustre/lov/lov_ea.c      | 31 +++++++++++++++++++++++++++++++
 fs/lustre/mdc/mdc_locks.c   | 32 ++++++++++++++------------------
 fs/lustre/mdc/mdc_request.c |  6 ++++++
 4 files changed, 53 insertions(+), 18 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index c73aebe..083884c9f 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -71,6 +71,8 @@ struct lov_oinfo {				/* per-stripe data structure */
 	struct osc_async_rc	loi_ar;
 };
 
+void lov_fix_ea_for_replay(void *lovea);
+
 static inline void loi_kms_set(struct lov_oinfo *oinfo, u64 kms)
 {
 	oinfo->loi_kms = kms;
diff --git a/fs/lustre/lov/lov_ea.c b/fs/lustre/lov/lov_ea.c
index e198536..1d105c0 100644
--- a/fs/lustre/lov/lov_ea.c
+++ b/fs/lustre/lov/lov_ea.c
@@ -656,3 +656,34 @@ int lov_lsm_entry(const struct lov_stripe_md *lsm, u64 offset)
 
 	return -1;
 }
+
+/**
+ * lmm_layout_gen overlaps stripe_offset field, it needs to be reset back when
+ * sending to MDT for passing striping checks
+ */
+void lov_fix_ea_for_replay(void *lovea)
+{
+	struct lov_user_md *lmm = lovea;
+	struct lov_comp_md_v1 *c1;
+	int i;
+
+	switch (le32_to_cpu(lmm->lmm_magic)) {
+	case LOV_USER_MAGIC_V1:
+	case LOV_USER_MAGIC_V3:
+		lmm->lmm_stripe_offset = LOV_OFFSET_DEFAULT;
+		break;
+
+	case LOV_USER_MAGIC_COMP_V1:
+		c1 = (void *)lmm;
+		for (i = 0; i < le16_to_cpu(c1->lcm_entry_count); i++) {
+			struct lov_comp_md_entry_v1 *ent = &c1->lcm_entries[i];
+
+			if (le32_to_cpu(ent->lcme_flags) & LCME_FL_INIT) {
+				lmm = (void *)((char *)c1 +
+				      le32_to_cpu(ent->lcme_offset));
+				lmm->lmm_stripe_offset = LOV_OFFSET_DEFAULT;
+			}
+		}
+	}
+}
+EXPORT_SYMBOL(lov_fix_ea_for_replay);
diff --git a/fs/lustre/mdc/mdc_locks.c b/fs/lustre/mdc/mdc_locks.c
index ea78415..2d623ff 100644
--- a/fs/lustre/mdc/mdc_locks.c
+++ b/fs/lustre/mdc/mdc_locks.c
@@ -205,7 +205,8 @@ static inline void mdc_clear_replay_flag(struct ptlrpc_request *req, int rc)
 	}
 }
 
-/* Save a large LOV EA into the request buffer so that it is available
+/**
+ * Save a large LOV EA into the request buffer so that it is available
  * for replay. We don't do this in the initial request because the
  * original request doesn't need this buffer (at most it sends just the
  * lov_mds_md) and it is a waste of RAM/bandwidth to send the empty
@@ -217,16 +218,14 @@ static inline void mdc_clear_replay_flag(struct ptlrpc_request *req, int rc)
  * but this is incredibly unlikely, and questionable whether the client
  * could do MDS recovery under OOM anyways...
  */
-static int mdc_save_lovea(struct ptlrpc_request *req,
-			  const struct req_msg_field *field, void *data,
-			  u32 size)
+static int mdc_save_lovea(struct ptlrpc_request *req, void *data, u32 size)
 {
 	struct req_capsule *pill = &req->rq_pill;
-	struct lov_user_md *lmm;
+	void *lovea;
 	int rc = 0;
 
-	if (req_capsule_get_size(pill, field, RCL_CLIENT) < size) {
-		rc = sptlrpc_cli_enlarge_reqbuf(req, field, size);
+	if (req_capsule_get_size(pill, &RMF_EADATA, RCL_CLIENT) < size) {
+		rc = sptlrpc_cli_enlarge_reqbuf(req, &RMF_EADATA, size);
 		if (rc) {
 			CERROR("%s: Can't enlarge ea size to %d: rc = %d\n",
 			       req->rq_export->exp_obd->obd_name,
@@ -234,16 +233,14 @@ static int mdc_save_lovea(struct ptlrpc_request *req,
 			return rc;
 		}
 	} else {
-		req_capsule_shrink(pill, field, size, RCL_CLIENT);
+		req_capsule_shrink(pill, &RMF_EADATA, size, RCL_CLIENT);
 	}
 
-	req_capsule_set_size(pill, field, RCL_CLIENT, size);
-	lmm = req_capsule_client_get(pill, field);
-	if (lmm) {
-		memcpy(lmm, data, size);
-		/* overwrite layout generation returned from the MDS */
-		lmm->lmm_stripe_offset =
-		  (typeof(lmm->lmm_stripe_offset))LOV_OFFSET_DEFAULT;
+	req_capsule_set_size(pill, &RMF_EADATA, RCL_CLIENT, size);
+	lovea = req_capsule_client_get(pill, &RMF_EADATA);
+	if (lovea) {
+		memcpy(lovea, data, size);
+		lov_fix_ea_for_replay(lovea);
 	}
 
 	return rc;
@@ -788,7 +785,7 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 			 * (for example error one).
 			 */
 			if ((it->it_op & IT_OPEN) && req->rq_replay) {
-				rc = mdc_save_lovea(req, &RMF_EADATA, eadata,
+				rc = mdc_save_lovea(req, eadata,
 						    body->mbo_eadatasize);
 				if (rc) {
 					body->mbo_valid &= ~OBD_MD_FLEASIZE;
@@ -817,8 +814,7 @@ static int mdc_finish_enqueue(struct obd_export *exp,
 			 * another set of OST objects).
 			 */
 			if (req->rq_transno)
-				(void)mdc_save_lovea(req, &RMF_EADATA, lvb_data,
-						     lvb_len);
+				(void)mdc_save_lovea(req, lvb_data, lvb_len);
 		}
 	}
 
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 40670cb..a146af8 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -646,6 +646,7 @@ void mdc_replay_open(struct ptlrpc_request *req)
 	struct obd_client_handle *och;
 	struct lustre_handle old_open_handle = { };
 	struct mdt_body *body;
+	struct ldlm_reply *rep;
 
 	if (!mod) {
 		DEBUG_REQ(D_ERROR, req,
@@ -655,6 +656,11 @@ void mdc_replay_open(struct ptlrpc_request *req)
 
 	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
 
+	rep = req_capsule_server_get(&req->rq_pill, &RMF_DLM_REP);
+	if (rep && rep->lock_policy_res2 != 0)
+		DEBUG_REQ(D_ERROR, req, "Open request replay failed with %ld ",
+			  (long)rep->lock_policy_res2);
+
 	spin_lock(&req->rq_lock);
 	och = mod->mod_och;
 	if (och && och->och_open_handle.cookie)
-- 
1.8.3.1
