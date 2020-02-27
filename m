From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:56 -0500
Subject: [lustre-devel] [PATCH 128/622] lustre: flr: add 'nosync' flag for
 FLR mirrors
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-129-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@whamcloud.com>

This patch allows 'nosync' flag to be set for FLR mirror components,
which makes lfs mirror resync skip on mirrors with this flag unless
mirror resync explicitly requested those mirrors to be resync.

This flag can be cleared by set '^nosync' on any component of the
mirror.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11400
Lustre-commit: 8a0554450eaa ("LU-11400 flr: add 'nosync' flag for FLR mirrors")
Signed-off-by: Bobi Jam <bobijam@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33205
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_ea.c                  |  3 +++
 fs/lustre/lov/lov_internal.h            |  1 +
 fs/lustre/lov/lov_pack.c                |  3 +++
 fs/lustre/ptlrpc/pack_generic.c         |  2 +-
 fs/lustre/ptlrpc/wiretest.c             | 18 +++++++++++++-----
 include/uapi/linux/lustre/lustre_user.h |  8 ++++++--
 6 files changed, 27 insertions(+), 8 deletions(-)

diff --git a/fs/lustre/lov/lov_ea.c b/fs/lustre/lov/lov_ea.c
index edca3b0..31a18d0 100644
--- a/fs/lustre/lov/lov_ea.c
+++ b/fs/lustre/lov/lov_ea.c
@@ -478,6 +478,9 @@ static int lsm_verify_comp_md_v1(struct lov_comp_md_v1 *lcm,
 		lsm->lsm_entries[i] = lsme;
 		lsme->lsme_id = le32_to_cpu(lcme->lcme_id);
 		lsme->lsme_flags = le32_to_cpu(lcme->lcme_flags);
+		if (lsme->lsme_flags & LCME_FL_NOSYNC)
+			lsme->lsme_timestamp =
+				le64_to_cpu(lcme->lcme_timestamp);
 		lu_extent_le_to_cpu(&lsme->lsme_extent, &lcme->lcme_extent);
 
 		if (i == entry_count - 1) {
diff --git a/fs/lustre/lov/lov_internal.h b/fs/lustre/lov/lov_internal.h
index 5dba8d3..376ac52 100644
--- a/fs/lustre/lov/lov_internal.h
+++ b/fs/lustre/lov/lov_internal.h
@@ -50,6 +50,7 @@ struct lov_stripe_md_entry {
 	u32			lsme_magic;
 	u32			lsme_flags;
 	u32			lsme_pattern;
+	u64			lsme_timestamp;
 	u32			lsme_stripe_size;
 	u16			lsme_stripe_count;
 	u16			lsme_layout_gen;
diff --git a/fs/lustre/lov/lov_pack.c b/fs/lustre/lov/lov_pack.c
index 3dbc6aa..5f8b281 100644
--- a/fs/lustre/lov/lov_pack.c
+++ b/fs/lustre/lov/lov_pack.c
@@ -201,6 +201,9 @@ ssize_t lov_lsm_pack(const struct lov_stripe_md *lsm, void *buf,
 
 		lcme->lcme_id = cpu_to_le32(lsme->lsme_id);
 		lcme->lcme_flags = cpu_to_le32(lsme->lsme_flags);
+		if (lsme->lsme_flags & LCME_FL_NOSYNC)
+			lcme->lcme_timestamp =
+				cpu_to_le64(lsme->lsme_timestamp);
 		lcme->lcme_extent.e_start =
 			cpu_to_le64(lsme->lsme_extent.e_start);
 		lcme->lcme_extent.e_end =
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index 6da9aca..d93dbe1 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -2062,13 +2062,13 @@ void lustre_swab_lov_comp_md_v1(struct lov_comp_md_v1 *lum)
 		}
 		__swab32s(&ent->lcme_id);
 		__swab32s(&ent->lcme_flags);
+		__swab64s(&ent->lcme_timestamp);
 		__swab64s(&ent->lcme_extent.e_start);
 		__swab64s(&ent->lcme_extent.e_end);
 		__swab32s(&ent->lcme_offset);
 		__swab32s(&ent->lcme_size);
 		__swab32s(&ent->lcme_layout_gen);
 		BUILD_BUG_ON(offsetof(typeof(*ent), lcme_padding_1) == 0);
-		BUILD_BUG_ON(offsetof(typeof(*ent), lcme_padding_2) == 0);
 
 		v1 = (struct lov_user_md_v1 *)((char *)lum + off);
 		stripe_count = v1->lmm_stripe_count;
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 42af0b8..c6dd256 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1532,14 +1532,14 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct lov_comp_md_entry_v1, lcme_layout_gen));
 	LASSERTF((int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_layout_gen) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_layout_gen));
-	LASSERTF((int)offsetof(struct lov_comp_md_entry_v1, lcme_padding_1) == 36, "found %lld\n",
+	LASSERTF((int)offsetof(struct lov_comp_md_entry_v1, lcme_timestamp) == 36, "found %lld\n",
+		 (long long)(int)offsetof(struct lov_comp_md_entry_v1, lcme_timestamp));
+	LASSERTF((int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_timestamp) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_timestamp));
+	LASSERTF((int)offsetof(struct lov_comp_md_entry_v1, lcme_padding_1) == 44, "found %lld\n",
 		 (long long)(int)offsetof(struct lov_comp_md_entry_v1, lcme_padding_1));
 	LASSERTF((int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_padding_1) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_padding_1));
-	LASSERTF((int)offsetof(struct lov_comp_md_entry_v1, lcme_padding_2) == 40, "found %lld\n",
-		 (long long)(int)offsetof(struct lov_comp_md_entry_v1, lcme_padding_2));
-	LASSERTF((int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_padding_2) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_padding_2));
 	LASSERTF(LCME_FL_INIT == 0x00000010UL, "found 0x%.8xUL\n",
 		 (unsigned int)LCME_FL_INIT);
 	LASSERTF(LCME_FL_NEG == 0x80000000UL, "found 0x%.8xUL\n",
@@ -1666,6 +1666,10 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct obd_statfs, os_bavail));
 	LASSERTF((int)sizeof(((struct obd_statfs *)0)->os_bavail) == 8, "found %lld\n",
 		 (long long)(int)sizeof(((struct obd_statfs *)0)->os_bavail));
+	LASSERTF((int)offsetof(struct obd_statfs, os_files) == 32, "found %lld\n",
+		 (long long)(int)offsetof(struct obd_statfs, os_files));
+	LASSERTF((int)sizeof(((struct obd_statfs *)0)->os_files) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct obd_statfs *)0)->os_files));
 	LASSERTF((int)offsetof(struct obd_statfs, os_ffree) == 40, "found %lld\n",
 		 (long long)(int)offsetof(struct obd_statfs, os_ffree));
 	LASSERTF((int)sizeof(((struct obd_statfs *)0)->os_ffree) == 8, "found %lld\n",
@@ -1682,6 +1686,10 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct obd_statfs, os_namelen));
 	LASSERTF((int)sizeof(((struct obd_statfs *)0)->os_namelen) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct obd_statfs *)0)->os_namelen));
+	LASSERTF((int)offsetof(struct obd_statfs, os_maxbytes) == 96, "found %lld\n",
+		 (long long)(int)offsetof(struct obd_statfs, os_maxbytes));
+	LASSERTF((int)sizeof(((struct obd_statfs *)0)->os_maxbytes) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct obd_statfs *)0)->os_maxbytes));
 	LASSERTF((int)offsetof(struct obd_statfs, os_state) == 104, "found %lld\n",
 		 (long long)(int)offsetof(struct obd_statfs, os_state));
 	LASSERTF((int)sizeof(((struct obd_statfs *)0)->os_state) == 4, "found %lld\n",
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index f25bb9b..bff6f76 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -483,16 +483,20 @@ enum lov_comp_md_entry_flags {
 	LCME_FL_PREF_RW		= LCME_FL_PREF_RD | LCME_FL_PREF_WR,
 	LCME_FL_OFFLINE		= 0x00000008,	/* Not used */
 	LCME_FL_INIT		= 0x00000010,	/* instantiated */
+	LCME_FL_NOSYNC		= 0x00000020,	/* FLR: no sync for the mirror */
 	LCME_FL_NEG		= 0x80000000,	/* used to indicate a negative
 						 * flag, won't be stored on disk
 						 */
 };
 
 #define LCME_KNOWN_FLAGS	(LCME_FL_NEG | LCME_FL_INIT | LCME_FL_STALE | \
-				 LCME_FL_PREF_RW)
+				 LCME_FL_PREF_RW | LCME_FL_NOSYNC)
 /* The flags can be set by users at mirror creation time. */
 #define LCME_USER_FLAGS		(LCME_FL_PREF_RW)
 
+/* The flags are for mirrors */
+#define LCME_MIRROR_FLAGS	(LCME_FL_NOSYNC)
+
 /* the highest bit in obdo::o_layout_version is used to mark if the file is
  * being resynced.
  */
@@ -519,8 +523,8 @@ struct lov_comp_md_entry_v1 {
 						 */
 	__u32			lcme_size;	/* size of component blob */
 	__u32			lcme_layout_gen;
+	__u64			lcme_timestamp;	/* snapshot time if applicable*/
 	__u32			lcme_padding_1;
-	__u64			lcme_padding_2;
 } __packed;
 
 #define SEQ_ID_MAX		0x0000FFFF
-- 
1.8.3.1
