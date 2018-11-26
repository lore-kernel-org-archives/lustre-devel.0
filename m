From: James Simmons <jsimmons@infradead.org>
Date: Sun, 25 Nov 2018 21:48:17 -0500
Subject: [lustre-devel] [PATCH 01/12] lustre: llite: move CONFIG_SECURITY
 handling to llite_internal.h
In-Reply-To: <1543200508-6838-1-git-send-email-jsimmons@infradead.org>
References: <1543200508-6838-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1543200508-6838-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

For the linux kernel its recommended to keep CONFIG_* wrapped code
in a header file instead of the source files to avoid making the
code more difficulty to read. Move CONFIG_SECURITY wrapped code
to llite_internal.h in this case.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Reviewed-on: https://review.whamcloud.com/33410
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/llite_internal.h | 17 +++++++++++++++++
 drivers/staging/lustre/lustre/llite/llite_lib.c      | 11 ++---------
 2 files changed, 19 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index a55b568..8c703e6 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -269,6 +269,23 @@ static inline void ll_layout_version_set(struct ll_inode_info *lli, __u32 gen)
 int ll_xattr_cache_get(struct inode *inode, const char *name,
 		       char *buffer, size_t size, __u64 valid);
 
+static inline bool obd_connect_has_secctx(struct obd_connect_data *data)
+{
+#ifdef CONFIG_SECURITY
+	return data->ocd_connect_flags & OBD_CONNECT_FLAGS2 &&
+	       data->ocd_connect_flags2 & OBD_CONNECT2_FILE_SECCTX;
+#else
+       return false;
+#endif
+}
+
+static inline void obd_connect_set_secctx(struct obd_connect_data *data)
+{
+#ifdef CONFIG_SECURITY
+	data->ocd_connect_flags2 |= OBD_CONNECT2_FILE_SECCTX;
+#endif
+}
+
 int ll_dentry_init_security(struct dentry *dentry, int mode, struct qstr *name,
 			    const char **secctx_name, void **secctx,
 			    u32 *secctx_size);
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index fac6584..2dfeab4 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -148,12 +148,6 @@ static void ll_free_sbi(struct super_block *sb)
 	kfree(sbi);
 }
 
-static inline int obd_connect_has_secctx(struct obd_connect_data *data)
-{
-	return data->ocd_connect_flags & OBD_CONNECT_FLAGS2 &&
-	       data->ocd_connect_flags2 & OBD_CONNECT2_FILE_SECCTX;
-}
-
 static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 {
 	struct inode *root = NULL;
@@ -244,9 +238,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	if (sbi->ll_flags & LL_SBI_ALWAYS_PING)
 		data->ocd_connect_flags &= ~OBD_CONNECT_PINGLESS;
 
-#ifdef CONFIG_SECURITY
-	data->ocd_connect_flags2 |= OBD_CONNECT2_FILE_SECCTX;
-#endif
+	obd_connect_set_secctx(data);
+
 	data->ocd_brw_size = MD_MAX_BRW_SIZE;
 
 	err = obd_connect(NULL, &sbi->ll_md_exp, sbi->ll_md_obd,
-- 
1.8.3.1
