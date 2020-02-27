From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:58 -0500
Subject: [lustre-devel] [PATCH 070/622] lustre: lfsck: layout LFSCK for
 mirrored file
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-71-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Fan Yong <fan.yong@intel.com>

This patch makes the layout LFSCK to support mirrored file
as following:

1. Verify mirrored file's LOV EA and PFID EA, including all
   kinds of inconsistencies as non-mirrored file may hit.

2. Rebuild mirrored file's LOV EA from orphan OST-objects,
   recover the component's status/flags before the crash:
   init, stale, and so on.

3. For the mirrored file with dangling reference (OST object),
   it does NOT rebuild the lost OST-object from other replica,
   instead, it either reports the curruption or re-create empty
   OST-object that follows the same rules as non-mirrored case.

Some code cleanup and new test cases for LFSCK against mirrored file.

For the linux client we want to keep the wire protocol in sync.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10288
Lustre-commit: 36ba989752c6 ("LU-10288 lfsck: layout LFSCK for mirrored file")
Signed-off-by: Fan Yong <fan.yong@intel.com>
Reviewed-on: https://review.whamcloud.com/32705
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/pack_generic.c         |  4 +++-
 fs/lustre/ptlrpc/wiretest.c             | 16 ++++++++++++----
 include/uapi/linux/lustre/lustre_user.h |  4 +++-
 3 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index 9cea826..d09cf3f 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -2066,7 +2066,9 @@ void lustre_swab_lov_comp_md_v1(struct lov_comp_md_v1 *lum)
 		__swab64s(&ent->lcme_extent.e_end);
 		__swab32s(&ent->lcme_offset);
 		__swab32s(&ent->lcme_size);
-		BUILD_BUG_ON(offsetof(typeof(*ent), lcme_padding) == 0);
+		__swab32s(&ent->lcme_layout_gen);
+		BUILD_BUG_ON(offsetof(typeof(*ent), lcme_padding_1) == 0);
+		BUILD_BUG_ON(offsetof(typeof(*ent), lcme_padding_2) == 0);
 
 		v1 = (struct lov_user_md_v1 *)((char *)lum + off);
 		stripe_count = v1->lmm_stripe_count;
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index b4bb30d..e22f8f8 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1536,10 +1536,18 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct lov_comp_md_entry_v1, lcme_size));
 	LASSERTF((int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_size) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_size));
-	LASSERTF((int)offsetof(struct lov_comp_md_entry_v1, lcme_padding) == 32, "found %lld\n",
-		 (long long)(int)offsetof(struct lov_comp_md_entry_v1, lcme_padding));
-	LASSERTF((int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_padding) == 16, "found %lld\n",
-		 (long long)(int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_padding));
+	LASSERTF((int)offsetof(struct lov_comp_md_entry_v1, lcme_layout_gen) == 32, "found %lld\n",
+		 (long long)(int)offsetof(struct lov_comp_md_entry_v1, lcme_layout_gen));
+	LASSERTF((int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_layout_gen) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_layout_gen));
+	LASSERTF((int)offsetof(struct lov_comp_md_entry_v1, lcme_padding_1) == 36, "found %lld\n",
+		 (long long)(int)offsetof(struct lov_comp_md_entry_v1, lcme_padding_1));
+	LASSERTF((int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_padding_1) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_padding_1));
+	LASSERTF((int)offsetof(struct lov_comp_md_entry_v1, lcme_padding_2) == 40, "found %lld\n",
+		 (long long)(int)offsetof(struct lov_comp_md_entry_v1, lcme_padding_2));
+	LASSERTF((int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_padding_2) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_padding_2));
 	LASSERTF(LCME_FL_INIT == 0x00000010UL, "found 0x%.8xUL\n",
 		 (unsigned int)LCME_FL_INIT);
 	LASSERTF(LCME_FL_NEG == 0x80000000UL, "found 0x%.8xUL\n",
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index b2f5b57..8fd5b26 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -517,7 +517,9 @@ struct lov_comp_md_entry_v1 {
 						 * start from lov_comp_md_v1
 						 */
 	__u32			lcme_size;	/* size of component blob */
-	__u64			lcme_padding[2];
+	__u32			lcme_layout_gen;
+	__u32			lcme_padding_1;
+	__u64			lcme_padding_2;
 } __packed;
 
 #define SEQ_ID_MAX		0x0000FFFF
-- 
1.8.3.1
