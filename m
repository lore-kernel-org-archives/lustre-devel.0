From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:17 -0400
Subject: [lustre-devel] [PATCH 118/151] lustre: llite: deny 2.10 clients to
 open mirrored files
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-119-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jinshan Xiong <jinshan.xiong@gmail.com>

2.10 clients would manipulate mirrored layout as PFL layout, which
would damage mirrored files.

This patch only allows mirrored files to be opened by clients who
understand mirror layout.

It also fixes the problem that it should check OBD_CONNECT_FLAGS2
first before checking OBD_CONNECT2_XXX flags.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10286
Lustre-commit: 21e39775a0f4 ("LU-10286 llite: deny 2.10 clients to open mirrored files")
Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-on: https://review.whamcloud.com/30957
Tested-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_export.h      | 9 ++++++++-
 fs/lustre/llite/llite_lib.c            | 2 +-
 include/uapi/linux/lustre/lustre_idl.h | 1 +
 3 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/include/lustre_export.h b/fs/lustre/include/lustre_export.h
index 544166f..de3b109 100644
--- a/fs/lustre/include/lustre_export.h
+++ b/fs/lustre/include/lustre_export.h
@@ -156,7 +156,9 @@ static inline u64 *exp_connect_flags2_ptr(struct obd_export *exp)
 
 static inline u64 exp_connect_flags2(struct obd_export *exp)
 {
-	return *exp_connect_flags2_ptr(exp);
+	if (exp_connect_flags(exp) & OBD_CONNECT_FLAGS2)
+		return *exp_connect_flags2_ptr(exp);
+	return 0;
 }
 
 static inline int exp_max_brw_size(struct obd_export *exp)
@@ -262,6 +264,11 @@ static inline int exp_connect_lockahead(struct obd_export *exp)
 	return !!(exp_connect_flags2(exp) & OBD_CONNECT2_LOCKAHEAD);
 }
 
+static inline int exp_connect_flr(struct obd_export *exp)
+{
+	return !!(exp_connect_flags2(exp) & OBD_CONNECT2_FLR);
+}
+
 struct obd_export *class_conn2export(struct lustre_handle *conn);
 
 #define KKUC_CT_DATA_MAGIC	0x092013cea
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 2a7ef64..efd1093 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -208,7 +208,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 				  OBD_CONNECT_GRANT_PARAM |
 				  OBD_CONNECT_SHORTIO | OBD_CONNECT_FLAGS2;
 
-	data->ocd_connect_flags2 = 0;
+	data->ocd_connect_flags2 = OBD_CONNECT2_FLR;
 
 	if (sbi->ll_flags & LL_SBI_LRU_RESIZE)
 		data->ocd_connect_flags |= OBD_CONNECT_LRU_RESIZE;
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 6dce6f1..6294eaa 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -791,6 +791,7 @@ struct ptlrpc_body_v2 {
 #define OBD_CONNECT2_LOCKAHEAD		0x2ULL		/* ladvise lockahead
 							 * v2
 							 */
+#define OBD_CONNECT2_FLR		0x20ULL		/* FLR support */
 
 /* XXX README XXX:
  * Please DO NOT add flag values here before first ensuring that this same
-- 
1.8.3.1
