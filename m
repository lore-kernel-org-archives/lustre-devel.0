From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:14 -0500
Subject: [lustre-devel] [PATCH 506/622] lustre: ptlrpc: Properly swab
 ll_fiemap_info_key
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-507-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@whamcloud.com>

It was using lustre_swab_fiemap which is incorrect since the
structures don't match.

Added lustre_swab_fiemap_info_key that swabs embedded
obdo and ll_fiemap_info_key structures.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11997
Lustre-commit: 2b905746ee3b ("LU-11997 ptlrpc: Properly swab ll_fiemap_info_key")
Signed-off-by: Oleg Drokin <green@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/36308
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_swab.h |  1 +
 fs/lustre/ptlrpc/layout.c       |  4 ++--
 fs/lustre/ptlrpc/pack_generic.c | 17 ++++++++++++++---
 3 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/fs/lustre/include/lustre_swab.h b/fs/lustre/include/lustre_swab.h
index dd3c50c..a5c1de5 100644
--- a/fs/lustre/include/lustre_swab.h
+++ b/fs/lustre/include/lustre_swab.h
@@ -81,6 +81,7 @@
 void lustre_swab_ost_body(struct ost_body *b);
 void lustre_swab_ost_last_id(u64 *id);
 void lustre_swab_fiemap(struct fiemap *fiemap);
+void lustre_swab_fiemap_info_key(struct ll_fiemap_info_key *fiemap_info);
 void lustre_swab_lov_user_md_v1(struct lov_user_md_v1 *lum);
 void lustre_swab_lov_user_md_v3(struct lov_user_md_v3 *lum);
 void lustre_swab_lov_comp_md_v1(struct lov_comp_md_v1 *lum);
diff --git a/fs/lustre/ptlrpc/layout.c b/fs/lustre/ptlrpc/layout.c
index dd04eee..06db86d 100644
--- a/fs/lustre/ptlrpc/layout.c
+++ b/fs/lustre/ptlrpc/layout.c
@@ -1134,8 +1134,8 @@ struct req_msg_field RMF_OST_ID =
 EXPORT_SYMBOL(RMF_OST_ID);
 
 struct req_msg_field RMF_FIEMAP_KEY =
-	DEFINE_MSGF("fiemap", 0, sizeof(struct ll_fiemap_info_key),
-		    lustre_swab_fiemap, NULL);
+	DEFINE_MSGF("fiemap_key", 0, sizeof(struct ll_fiemap_info_key),
+		    lustre_swab_fiemap_info_key, NULL);
 EXPORT_SYMBOL(RMF_FIEMAP_KEY);
 
 struct req_msg_field RMF_FIEMAP_VAL =
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index 9b28624..b569d57 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -1913,21 +1913,32 @@ static void lustre_swab_fiemap_extent(struct fiemap_extent *fm_extent)
 	__swab32s(&fm_extent->fe_device);
 }
 
-void lustre_swab_fiemap(struct fiemap *fiemap)
+static void lustre_swab_fiemap_hdr(struct fiemap *fiemap)
 {
-	u32 i;
-
 	__swab64s(&fiemap->fm_start);
 	__swab64s(&fiemap->fm_length);
 	__swab32s(&fiemap->fm_flags);
 	__swab32s(&fiemap->fm_mapped_extents);
 	__swab32s(&fiemap->fm_extent_count);
 	__swab32s(&fiemap->fm_reserved);
+}
+
+void lustre_swab_fiemap(struct fiemap *fiemap)
+{
+	u32 i;
+
+	lustre_swab_fiemap_hdr(fiemap);
 
 	for (i = 0; i < fiemap->fm_mapped_extents; i++)
 		lustre_swab_fiemap_extent(&fiemap->fm_extents[i]);
 }
 
+void lustre_swab_fiemap_info_key(struct ll_fiemap_info_key *fiemap_info)
+{
+	lustre_swab_obdo(&fiemap_info->lfik_oa);
+	lustre_swab_fiemap_hdr(&fiemap_info->lfik_fiemap);
+}
+
 void lustre_swab_mdt_rec_reint (struct mdt_rec_reint *rr)
 {
 	__swab32s(&rr->rr_opcode);
-- 
1.8.3.1
