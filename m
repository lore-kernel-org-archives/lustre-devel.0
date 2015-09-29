From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 28 Sep 2015 23:44:04 -0400
Subject: [lustre-devel] [PATCH 21/29] staging/lustre/fid:
	seq_client_init/fini don't need to be exported
In-Reply-To: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
References: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443498252-1974801-22-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

In fact they could be static as they are only used inside
this file, so remove EXPORT_SYMBOL and declarations.
Also seq_client_init is always called with srv = NULL, so just
drop this argument.

Signed-off-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lustre/fid/fid_request.c    | 39 ++++++++++------------
 drivers/staging/lustre/lustre/include/lustre_fid.h |  8 -----
 2 files changed, 18 insertions(+), 29 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fid/fid_request.c b/drivers/staging/lustre/lustre/fid/fid_request.c
index a16d577..16264bc 100644
--- a/drivers/staging/lustre/lustre/fid/fid_request.c
+++ b/drivers/staging/lustre/lustre/fid/fid_request.c
@@ -438,18 +438,29 @@ out_cleanup:
 	return rc;
 }
 
-int seq_client_init(struct lu_client_seq *seq,
-		    struct obd_export *exp,
-		    enum lu_cli_type type,
-		    const char *prefix,
-		    struct lu_server_seq *srv)
+static void seq_client_fini(struct lu_client_seq *seq)
+{
+	seq_client_debugfs_fini(seq);
+
+	if (seq->lcs_exp) {
+		class_export_put(seq->lcs_exp);
+		seq->lcs_exp = NULL;
+	}
+
+	seq->lcs_srv = NULL;
+}
+
+static int seq_client_init(struct lu_client_seq *seq,
+			   struct obd_export *exp,
+			   enum lu_cli_type type,
+			   const char *prefix)
 {
 	int rc;
 
 	LASSERT(seq != NULL);
 	LASSERT(prefix != NULL);
 
-	seq->lcs_srv = srv;
+	seq->lcs_srv = NULL;
 	seq->lcs_type = type;
 
 	mutex_init(&seq->lcs_mutex);
@@ -475,20 +486,6 @@ int seq_client_init(struct lu_client_seq *seq,
 		seq_client_fini(seq);
 	return rc;
 }
-EXPORT_SYMBOL(seq_client_init);
-
-void seq_client_fini(struct lu_client_seq *seq)
-{
-	seq_client_debugfs_fini(seq);
-
-	if (seq->lcs_exp != NULL) {
-		class_export_put(seq->lcs_exp);
-		seq->lcs_exp = NULL;
-	}
-
-	seq->lcs_srv = NULL;
-}
-EXPORT_SYMBOL(seq_client_fini);
 
 int client_fid_init(struct obd_device *obd,
 		    struct obd_export *exp, enum lu_cli_type type)
@@ -510,7 +507,7 @@ int client_fid_init(struct obd_device *obd,
 	snprintf(prefix, MAX_OBD_NAME + 5, "cli-%s", obd->obd_name);
 
 	/* Init client side sequence-manager */
-	rc = seq_client_init(cli->cl_seq, exp, type, prefix, NULL);
+	rc = seq_client_init(cli->cl_seq, exp, type, prefix);
 	kfree(prefix);
 	if (rc)
 		goto out_free_seq;
diff --git a/drivers/staging/lustre/lustre/include/lustre_fid.h b/drivers/staging/lustre/lustre/include/lustre_fid.h
index 1b50e66..f60c20a 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fid.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fid.h
@@ -426,14 +426,6 @@ struct lu_server_seq {
 };
 
 /* Client methods */
-int seq_client_init(struct lu_client_seq *seq,
-		    struct obd_export *exp,
-		    enum lu_cli_type type,
-		    const char *prefix,
-		    struct lu_server_seq *srv);
-
-void seq_client_fini(struct lu_client_seq *seq);
-
 void seq_client_flush(struct lu_client_seq *seq);
 
 int seq_client_alloc_fid(const struct lu_env *env, struct lu_client_seq *seq,
-- 
2.1.0
