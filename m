From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Jul 2018 19:16:34 -0400
Subject: [lustre-devel] [PATCH 3/3] lustre: llite: simplify
 lustre_fill_super()
In-Reply-To: <1532992594-2576-1-git-send-email-jsimmons@infradead.org>
References: <1532992594-2576-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1532992594-2576-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

With lustre_fill_super() being client specific we can easily
simplify the code.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/super25.c | 51 ++++++++++-----------------
 1 file changed, 19 insertions(+), 32 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/super25.c b/drivers/staging/lustre/lustre/llite/super25.c
index ac8f6f1..1ada5a7 100644
--- a/drivers/staging/lustre/lustre/llite/super25.c
+++ b/drivers/staging/lustre/lustre/llite/super25.c
@@ -113,42 +113,29 @@ int lustre_fill_super(struct super_block *sb, void *lmd2_data, int silent)
 
 	/* Figure out the lmd from the mount options */
 	if (lmd_parse(lmd2_data, lmd)) {
+		lustre_put_lsi(sb);
 		rc = -EINVAL;
-		goto out_put_lsi;
+		goto out;
 	}
 
-	if (lmd_is_client(lmd)) {
-		CDEBUG(D_SUPER | D_CONFIG, "Mounting client %s\n",
-		       lmd->lmd_profile);
-		rc = ptlrpc_inc_ref();
-		if (rc)
-			goto out_put_lsi;
-
-		rc = lustre_start_mgc(sb);
-		if (rc) {
-			/* This will put_lsi and ptlrpc_dec_ref() */
-			lustre_common_put_super(sb);
-			ptlrpc_dec_ref();
-			goto out;
-		}
-
-		/* Connect and start */
-		rc = ll_fill_super(sb);
-
-		/*
-		 * c_f_s will call lustre_common_put_super on failure, otherwise
-		 * c_f_s will have taken another reference to the module
-		 */
-	} else {
-		CERROR("This is client-side-only module, cannot handle server mount.\n");
-		rc = -EINVAL;
+	CDEBUG(D_SUPER | D_CONFIG, "Mounting client %s\n",
+	       lmd->lmd_profile);
+	rc = ptlrpc_inc_ref();
+	if (rc) {
+		lustre_put_lsi(sb);
+		goto out;
 	}
-	/* If error happens in fill_super() call, @lsi will be killed there.
-	 * This is why we do not put it here.
-	 */
-	goto out;
-out_put_lsi:
-	lustre_put_lsi(sb);
+
+	rc = lustre_start_mgc(sb);
+	if (rc) {
+		/* This will put_lsi and ptlrpc_dec_ref() */
+		lustre_common_put_super(sb);
+		ptlrpc_dec_ref();
+		goto out;
+	}
+
+	/* Connect and start. If error happens, @lsi will be killed there */
+	rc = ll_fill_super(sb);
 out:
 	if (rc) {
 		CERROR("Unable to mount %s (%d)\n",
-- 
1.8.3.1
