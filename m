From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 28 Sep 2015 23:44:05 -0400
Subject: [lustre-devel] [PATCH 22/29] staging/lustre/fid: Remove unused
	seq_client_get_seq function
In-Reply-To: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
References: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443498252-1974801-23-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

Also while we are at it, remove seq_site_fini forward declaration
as there's no such function anymore.

Signed-off-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lustre/fid/fid_request.c    | 51 ----------------------
 drivers/staging/lustre/lustre/include/lustre_fid.h |  3 --
 2 files changed, 54 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index 16264bc..ce55340 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -248,57 +248,6 @@ static void seq_fid_alloc_fini(struct lu_client_seq *seq)
 	wake_up(&seq->lcs_waitq);
 }
 
-/**
- * Allocate the whole seq to the caller.
- **/
-int seq_client_get_seq(const struct lu_env *env,
-		       struct lu_client_seq *seq, u64 *seqnr)
-{
-	wait_queue_t link;
-	int rc;
-
-	LASSERT(seqnr != NULL);
-	mutex_lock(&seq->lcs_mutex);
-	init_waitqueue_entry(&link, current);
-
-	while (1) {
-		rc = seq_fid_alloc_prep(seq, &link);
-		if (rc == 0)
-			break;
-	}
-
-	rc = seq_client_alloc_seq(env, seq, seqnr);
-	if (rc) {
-		CERROR("%s: Can't allocate new sequence, rc %d\n",
-		       seq->lcs_name, rc);
-		seq_fid_alloc_fini(seq);
-		mutex_unlock(&seq->lcs_mutex);
-		return rc;
-	}
-
-	CDEBUG(D_INFO, "%s: allocate sequence [0x%16.16Lx]\n",
-	       seq->lcs_name, *seqnr);
-
-	/* Since the caller require the whole seq,
-	 * so marked this seq to be used */
-	if (seq->lcs_type == LUSTRE_SEQ_METADATA)
-		seq->lcs_fid.f_oid = LUSTRE_METADATA_SEQ_MAX_WIDTH;
-	else
-		seq->lcs_fid.f_oid = LUSTRE_DATA_SEQ_MAX_WIDTH;
-
-	seq->lcs_fid.f_seq = *seqnr;
-	seq->lcs_fid.f_ver = 0;
-	/*
-	 * Inform caller that sequence switch is performed to allow it
-	 * to setup FLD for it.
-	 */
-	seq_fid_alloc_fini(seq);
-	mutex_unlock(&seq->lcs_mutex);
-
-	return rc;
-}
-EXPORT_SYMBOL(seq_client_get_seq);
-
 /* Allocate new fid on passed client @seq and save it to @fid. */
 int seq_client_alloc_fid(const struct lu_env *env,
 			 struct lu_client_seq *seq, struct lu_fid *fid)
diff --git a/drivers/staging/lustre/lustre/include/lustre_fid.h b/drivers/staging/lustre/lustre/include/lustre_fid.h
index f60c20a..22fc96e 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fid.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fid.h
@@ -430,9 +430,6 @@ void seq_client_flush(struct lu_client_seq *seq);
 
 int seq_client_alloc_fid(const struct lu_env *env, struct lu_client_seq *seq,
 			 struct lu_fid *fid);
-int seq_client_get_seq(const struct lu_env *env, struct lu_client_seq *seq,
-		       u64 *seqnr);
-int seq_site_fini(const struct lu_env *env, struct seq_server_site *ss);
 /* Fids common stuff */
 int fid_is_local(const struct lu_env *env,
 		 struct lu_site *site, const struct lu_fid *fid);
-- 
2.1.0
