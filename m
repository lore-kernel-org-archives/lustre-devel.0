From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:07:38 -0400
Subject: [lustre-devel] [PATCH 01/45] lustre: fid: revert seq_client_rpc
 patch.
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.de>

This reverts commit 5955572b19f6 ("staging: lustre: fid: perform sanity
checks before committing").  The patch isn't really needed, and
keeping it caused unnecessary differences from out-of-free
lustre.

Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/lustre/fid/fid_request.c    | 10 +++++-----
 fs/lustre/include/lustre_lmv.h |  2 +-
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/fid/fid_request.c b/fs/lustre/fid/fid_request.c
index 6cede30..a1c3bd9 100644
--- a/fs/lustre/fid/fid_request.c
+++ b/fs/lustre/fid/fid_request.c
@@ -118,22 +118,22 @@ static int seq_client_rpc(struct lu_client_seq *seq,
 		goto out_req;
 
 	out = req_capsule_server_get(&req->rq_pill, &RMF_SEQ_RANGE);
+	*output = *out;
 
-	if (!lu_seq_range_is_sane(out)) {
+	if (!lu_seq_range_is_sane(output)) {
 		CERROR("%s: Invalid range received from server: "
-		       DRANGE "\n", seq->lcs_name, PRANGE(out));
+		       DRANGE "\n", seq->lcs_name, PRANGE(output));
 		rc = -EINVAL;
 		goto out_req;
 	}
 
-	if (lu_seq_range_is_exhausted(out)) {
+	if (lu_seq_range_is_exhausted(output)) {
 		CERROR("%s: Range received from server is exhausted: "
-		       DRANGE "]\n", seq->lcs_name, PRANGE(out));
+		       DRANGE "]\n", seq->lcs_name, PRANGE(output));
 		rc = -EINVAL;
 		goto out_req;
 	}
 
-	*output = *out;
 	CDEBUG_LIMIT(debug_mask, "%s: Allocated %s-sequence " DRANGE "]\n",
 		     seq->lcs_name, opcname, PRANGE(output));
 
diff --git a/fs/lustre/include/lustre_lmv.h b/fs/lustre/include/lustre_lmv.h
index 305b56d..8780480 100644
--- a/fs/lustre/include/lustre_lmv.h
+++ b/fs/lustre/include/lustre_lmv.h
@@ -68,7 +68,7 @@ static inline bool lmv_dir_foreign(const struct lmv_stripe_md *lsm)
 static inline bool lmv_dir_layout_changing(const struct lmv_stripe_md *lsm)
 {
 	return lmv_dir_striped(lsm) &&
-	       (lsm->lsm_md_hash_type & LMV_HASH_FLAG_MIGRATION);
+	       (lsm->lsm_md_hash_type & LMV_HASH_FLAG_LAYOUT_CHANGE);
 }
 
 static inline bool lmv_dir_bad_hash(const struct lmv_stripe_md *lsm)
-- 
1.8.3.1
