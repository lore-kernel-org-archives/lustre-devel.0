From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Thu,  1 Oct 2015 00:12:11 -0400
Subject: [lustre-devel] [PATCH 01/32] staging/lustre/llite: Remove unused
	ll_get_default/max_cookiesize()
In-Reply-To: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
References: <1443672762-982936-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443672762-982936-2-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

This was used for a function that's no longer important, but
is no longer used anywhere.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../staging/lustre/lustre/llite/llite_internal.h   |  2 --
 drivers/staging/lustre/lustre/llite/llite_lib.c    | 26 ----------------------
 2 files changed, 28 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index dcf7c6b..59fdbed 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -789,8 +789,6 @@ int ll_prep_inode(struct inode **inode, struct ptlrpc_request *req,
 int ll_obd_statfs(struct inode *inode, void *arg);
 int ll_get_max_mdsize(struct ll_sb_info *sbi, int *max_mdsize);
 int ll_get_default_mdsize(struct ll_sb_info *sbi, int *default_mdsize);
-int ll_get_max_cookiesize(struct ll_sb_info *sbi, int *max_cookiesize);
-int ll_get_default_cookiesize(struct ll_sb_info *sbi, int *default_cookiesize);
 int ll_process_config(struct lustre_cfg *lcfg);
 struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 				      struct inode *i1, struct inode *i2,
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index b6234b2..e1d8fb0 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -604,32 +604,6 @@ int ll_get_default_mdsize(struct ll_sb_info *sbi, int *lmmsize)
 	return rc;
 }
 
-int ll_get_max_cookiesize(struct ll_sb_info *sbi, int *lmmsize)
-{
-	int size, rc;
-
-	size = sizeof(int);
-	rc = obd_get_info(NULL, sbi->ll_md_exp, sizeof(KEY_MAX_COOKIESIZE),
-			  KEY_MAX_COOKIESIZE, &size, lmmsize, NULL);
-	if (rc)
-		CERROR("Get max cookiesize error rc %d\n", rc);
-
-	return rc;
-}
-
-int ll_get_default_cookiesize(struct ll_sb_info *sbi, int *lmmsize)
-{
-	int size, rc;
-
-	size = sizeof(int);
-	rc = obd_get_info(NULL, sbi->ll_md_exp, sizeof(KEY_DEFAULT_COOKIESIZE),
-			  KEY_DEFAULT_COOKIESIZE, &size, lmmsize, NULL);
-	if (rc)
-		CERROR("Get default cookiesize error rc %d\n", rc);
-
-	return rc;
-}
-
 static void client_common_put_super(struct super_block *sb)
 {
 	struct ll_sb_info *sbi = ll_s2sbi(sb);
-- 
2.1.0
