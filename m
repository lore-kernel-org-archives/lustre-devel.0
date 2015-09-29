From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 28 Sep 2015 23:44:06 -0400
Subject: [lustre-devel] [PATCH 23/29] staging/lustre/fid: Get rid of lcs_srv
	in lu_client_seq
In-Reply-To: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
References: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443498252-1974801-24-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

Since we know lcs_srv is always NULL, just get rid of it completely
and fix up all the code to assumee it was never there.

Signed-off-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lustre/fid/fid_request.c    | 48 ++++++++--------------
 drivers/staging/lustre/lustre/fid/lproc_fid.c      |  2 -
 drivers/staging/lustre/lustre/include/lustre_fid.h |  5 ---
 3 files changed, 17 insertions(+), 38 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index ce55340..7c45e74 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -150,19 +150,15 @@ int seq_client_alloc_super(struct lu_client_seq *seq,
 
 	mutex_lock(&seq->lcs_mutex);
 
-	if (seq->lcs_srv) {
-		rc = 0;
-	} else {
-		/* Check whether the connection to seq controller has been
-		 * setup (lcs_exp != NULL) */
-		if (seq->lcs_exp == NULL) {
-			mutex_unlock(&seq->lcs_mutex);
-			return -EINPROGRESS;
-		}
-
-		rc = seq_client_rpc(seq, &seq->lcs_space,
-				    SEQ_ALLOC_SUPER, "super");
+	/* Check whether the connection to seq controller has been
+	 * setup (lcs_exp != NULL) */
+	if (!seq->lcs_exp) {
+		mutex_unlock(&seq->lcs_mutex);
+		return -EINPROGRESS;
 	}
+
+	rc = seq_client_rpc(seq, &seq->lcs_space,
+			    SEQ_ALLOC_SUPER, "super");
 	mutex_unlock(&seq->lcs_mutex);
 	return rc;
 }
@@ -173,18 +169,14 @@ static int seq_client_alloc_meta(const struct lu_env *env,
 {
 	int rc;
 
-	if (seq->lcs_srv) {
-		rc = 0;
-	} else {
-		do {
-			/* If meta server return -EINPROGRESS or EAGAIN,
-			 * it means meta server might not be ready to
-			 * allocate super sequence from sequence controller
-			 * (MDT0)yet */
-			rc = seq_client_rpc(seq, &seq->lcs_space,
-					    SEQ_ALLOC_META, "meta");
-		} while (rc == -EINPROGRESS || rc == -EAGAIN);
-	}
+	do {
+		/* If meta server return -EINPROGRESS or EAGAIN,
+		 * it means meta server might not be ready to
+		 * allocate super sequence from sequence controller
+		 * (MDT0)yet */
+		rc = seq_client_rpc(seq, &seq->lcs_space,
+				    SEQ_ALLOC_META, "meta");
+	} while (rc == -EINPROGRESS || rc == -EAGAIN);
 
 	return rc;
 }
@@ -395,8 +387,6 @@ static void seq_client_fini(struct lu_client_seq *seq)
 		class_export_put(seq->lcs_exp);
 		seq->lcs_exp = NULL;
 	}
-
-	seq->lcs_srv = NULL;
 }
 
 static int seq_client_init(struct lu_client_seq *seq,
@@ -409,7 +399,6 @@ static int seq_client_init(struct lu_client_seq *seq,
 	LASSERT(seq != NULL);
 	LASSERT(prefix != NULL);
 
-	seq->lcs_srv = NULL;
 	seq->lcs_type = type;
 
 	mutex_init(&seq->lcs_mutex);
@@ -422,10 +411,7 @@ static int seq_client_init(struct lu_client_seq *seq,
 	/* Make sure that things are clear before work is started. */
 	seq_client_flush(seq);
 
-	if (exp != NULL)
-		seq->lcs_exp = class_export_get(exp);
-	else if (type == LUSTRE_SEQ_METADATA)
-		LASSERT(seq->lcs_srv != NULL);
+	seq->lcs_exp = class_export_get(exp);
 
 	snprintf(seq->lcs_name, sizeof(seq->lcs_name),
 		 "cli-%s", prefix);
diff --git a/drivers/staging/lustre/lustre/fid/lproc_fid.c b/drivers/staging/lustre/lustre/fid/lproc_fid.c
index bf12723..ce90c1c 100644
--- a/drivers/staging/lustre/lustre/fid/lproc_fid.c
+++ b/drivers/staging/lustre/lustre/fid/lproc_fid.c
@@ -204,8 +204,6 @@ ldebugfs_fid_server_seq_show(struct seq_file *m, void *unused)
 	if (seq->lcs_exp != NULL) {
 		cli = &seq->lcs_exp->exp_obd->u.cli;
 		seq_printf(m, "%s\n", cli->cl_target_uuid.uuid);
-	} else {
-		seq_printf(m, "%s\n", seq->lcs_srv->lss_name);
 	}
 
 	return 0;
diff --git a/drivers/staging/lustre/lustre/include/lustre_fid.h b/drivers/staging/lustre/lustre/include/lustre_fid.h
index 22fc96e..bbe3ff8 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fid.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fid.h
@@ -330,8 +330,6 @@ enum lu_mgr_type {
 	LUSTRE_SEQ_CONTROLLER
 };
 
-struct lu_server_seq;
-
 /* Client sequence manager interface. */
 struct lu_client_seq {
 	/* Sequence-controller export. */
@@ -366,9 +364,6 @@ struct lu_client_seq {
 	 */
 	__u64		   lcs_width;
 
-	/* Seq-server for direct talking */
-	struct lu_server_seq   *lcs_srv;
-
 	/* wait queue for fid allocation and update indicator */
 	wait_queue_head_t	     lcs_waitq;
 	int		     lcs_update;
-- 
2.1.0
