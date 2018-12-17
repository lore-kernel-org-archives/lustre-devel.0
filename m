From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Dec 2018 11:29:35 -0500
Subject: [lustre-devel] [PATCH 01/28] lustre: pfl: Basic data structures for
 composite layout
In-Reply-To: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
References: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1545064202-22483-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Niu Yawei <yawei.niu@intel.com>

Added basic structures and magic numbers for composite layout.

Signed-off-by: Niu Yawei <yawei.niu@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8998
Reviewed-on: https://review.whamcloud.com/24822
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/uapi/linux/lustre/lustre_idl.h  |  1 +
 .../lustre/include/uapi/linux/lustre/lustre_user.h | 54 ++++++++++++++++
 .../staging/lustre/lustre/include/lustre_swab.h    |  1 +
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    | 71 ++++++++++++++++++++++
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    | 67 ++++++++++++++++++++
 5 files changed, 194 insertions(+)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
index 26646f9..e47eb52 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
@@ -960,6 +960,7 @@ enum obdo_flags {
 /* reserved for specifying OSTs */
 #define LOV_MAGIC_SPECIFIC	(0x0BD50000 | LOV_MAGIC_MAGIC)
 #define LOV_MAGIC		LOV_MAGIC_V1
+#define LOV_MAGIC_COMP_V1	(0x0BD60000 | LOV_MAGIC_MAGIC)
 
 /*
  * magic for fully defined striping
diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
index 9d553ce6..3751b22 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
@@ -317,6 +317,7 @@ enum ll_lease_type {
 #define LOV_USER_MAGIC_V3	0x0BD30BD0
 /* 0x0BD40BD0 is occupied by LOV_MAGIC_MIGRATE */
 #define LOV_USER_MAGIC_SPECIFIC	0x0BD50BD0	/* for specific OSTs */
+#define LOV_USER_MAGIC_COMP_V1	0x0BD60BD0
 
 #define LMV_USER_MAGIC    0x0CD30CD0    /*default lmv magic*/
 
@@ -395,6 +396,59 @@ struct lov_user_md_v3 {	   /* LOV EA user data (host-endian) */
 	struct lov_user_ost_data_v1 lmm_objects[0]; /* per-stripe data */
 } __packed;
 
+struct lu_extent {
+	__u64	e_start;
+	__u64	e_end;
+};
+
+enum lov_comp_md_entry_flags {
+	LCME_FL_PRIMARY		= 0x00000001,   /* Not used */
+	LCME_FL_STALE		= 0x00000002,   /* Not used */
+	LCME_FL_OFFLINE		= 0x00000004,   /* Not used */
+	LCME_FL_PREFERRED	= 0x00000008,	/* Not used */
+	LCME_FL_INIT		= 0x00000010,	/* instantiated */
+};
+
+#define LCME_KNOWN_FLAGS	LCME_FL_INIT
+
+/* lcme_id can be specified as certain flags, and the the first
+ * bit of lcme_id is used to indicate that the ID is representing
+ * certain LCME_FL_* but not a real ID. Which implies we can have
+ * at most 31 flags (see LCME_FL_XXX).
+ */
+enum lcme_id {
+	LCME_ID_INVAL	= 0x0,
+	LCME_ID_MAX	= 0x7FFFFFFF,
+	LCME_ID_ALL	= 0xFFFFFFFF,
+	LCME_ID_NONE	= 0x80000000
+};
+
+#define LCME_ID_MASK	LCME_ID_MAX
+
+struct lov_comp_md_entry_v1 {
+	__u32			lcme_id;	/* unique id of component */
+	__u32			lcme_flags;	/* LCME_FL_XXX */
+	struct lu_extent	lcme_extent;	/* file extent for component */
+	__u32			lcme_offset;	/* offset of component blob,
+						 * start from lov_comp_md_v1
+						 */
+	__u32			lcme_size;	/* size of component blob */
+	__u64			lcme_padding[2];
+} __packed;
+
+enum lov_comp_md_flags;
+
+struct lov_comp_md_v1 {
+	__u32	lcm_magic;	/* LOV_USER_MAGIC_COMP_V1 */
+	__u32	lcm_size;	/* overall size including this struct */
+	__u32	lcm_layout_gen;
+	__u16	lcm_flags;
+	__u16	lcm_entry_count;
+	__u64	lcm_padding1;
+	__u64	lcm_padding2;
+	struct lov_comp_md_entry_v1 lcm_entries[0];
+} __packed;
+
 static inline __u32 lov_user_md_size(__u16 stripes, __u32 lmm_magic)
 {
 	if (lmm_magic == LOV_USER_MAGIC_V1)
diff --git a/drivers/staging/lustre/lustre/include/lustre_swab.h b/drivers/staging/lustre/lustre/include/lustre_swab.h
index e09a3dc..6939ac1 100644
--- a/drivers/staging/lustre/lustre/include/lustre_swab.h
+++ b/drivers/staging/lustre/lustre/include/lustre_swab.h
@@ -83,6 +83,7 @@
 void lustre_swab_fiemap(struct fiemap *fiemap);
 void lustre_swab_lov_user_md_v1(struct lov_user_md_v1 *lum);
 void lustre_swab_lov_user_md_v3(struct lov_user_md_v3 *lum);
+void lustre_swab_lov_comp_md_v1(struct lov_comp_md_v1 *lum);
 void lustre_swab_lov_user_md_objects(struct lov_user_ost_data *lod,
 				     int stripe_count);
 void lustre_swab_lov_mds_md(struct lov_mds_md *lmm);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 951bb92..9c5be30 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -1990,6 +1990,77 @@ void lustre_swab_lov_user_md_v3(struct lov_user_md_v3 *lum)
 }
 EXPORT_SYMBOL(lustre_swab_lov_user_md_v3);
 
+void lustre_swab_lov_comp_md_v1(struct lov_comp_md_v1 *lum)
+{
+	struct lov_comp_md_entry_v1 *ent;
+	bool cpu_endian;
+	u16 ent_count;
+	int i;
+
+	cpu_endian = lum->lcm_magic == LOV_USER_MAGIC_COMP_V1;
+	ent_count = lum->lcm_entry_count;
+	if (!cpu_endian)
+		__swab16s(&ent_count);
+
+	CDEBUG(D_IOCTL, "swabbing lov_user_comp_md v1\n");
+	__swab32s(&lum->lcm_magic);
+	__swab32s(&lum->lcm_size);
+	__swab32s(&lum->lcm_layout_gen);
+	__swab16s(&lum->lcm_flags);
+	__swab16s(&lum->lcm_entry_count);
+	BUILD_BUG_ON(offsetof(typeof(*lum), lcm_padding1) == 0);
+	BUILD_BUG_ON(offsetof(typeof(*lum), lcm_padding2) == 0);
+
+	for (i = 0; i < ent_count; i++) {
+		struct lov_user_md_v1 *v1;
+		u16 stripe_count;
+		u32 off, size;
+
+		ent = &lum->lcm_entries[i];
+		off = ent->lcme_offset;
+		size = ent->lcme_size;
+
+		if (!cpu_endian) {
+			__swab32s(&off);
+			__swab32s(&size);
+		}
+		__swab32s(&ent->lcme_id);
+		__swab32s(&ent->lcme_flags);
+		__swab64s(&ent->lcme_extent.e_start);
+		__swab64s(&ent->lcme_extent.e_end);
+		__swab32s(&ent->lcme_offset);
+		__swab32s(&ent->lcme_size);
+		BUILD_BUG_ON(offsetof(typeof(*ent), lcme_padding) == 0);
+
+		v1 = (struct lov_user_md_v1 *)((char *)lum + off);
+		stripe_count = v1->lmm_stripe_count;
+		if (!cpu_endian)
+			__swab16s(&stripe_count);
+
+		if (v1->lmm_magic == __swab32(LOV_USER_MAGIC_V1) ||
+		    v1->lmm_magic == LOV_USER_MAGIC_V1) {
+			lustre_swab_lov_user_md_v1(v1);
+			if (size > sizeof(*v1))
+				lustre_swab_lov_user_md_objects(v1->lmm_objects,
+								stripe_count);
+		} else if (v1->lmm_magic == __swab32(LOV_USER_MAGIC_V3) ||
+			   v1->lmm_magic == LOV_USER_MAGIC_V3 ||
+			   v1->lmm_magic == __swab32(LOV_USER_MAGIC_SPECIFIC) ||
+			   v1->lmm_magic == LOV_USER_MAGIC_SPECIFIC) {
+			struct lov_user_md_v3 *v3;
+
+			v3 = (struct lov_user_md_v3 *)v1;
+			lustre_swab_lov_user_md_v3(v3);
+			if (size > sizeof(*v3))
+				lustre_swab_lov_user_md_objects(v3->lmm_objects,
+								stripe_count);
+		} else {
+			CERROR("Invalid magic %#x\n", v1->lmm_magic);
+		}
+	}
+}
+EXPORT_SYMBOL(lustre_swab_lov_comp_md_v1);
+
 void lustre_swab_lov_mds_md(struct lov_mds_md *lmm)
 {
 	CDEBUG(D_IOCTL, "swabbing lov_mds_md\n");
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index 3aaaebb..90e6b8c 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -1450,6 +1450,73 @@ void lustre_assert_wire_constants(void)
 	LASSERTF(LOV_PATTERN_CMOBD == 0x00000200UL, "found 0x%.8xUL\n",
 		 (unsigned int)LOV_PATTERN_CMOBD);
 
+	/* Checks for struct lov_comp_md_entry_v1 */
+	LASSERTF((int)sizeof(struct lov_comp_md_entry_v1) == 48, "found %lld\n",
+		 (long long)(int)sizeof(struct lov_comp_md_entry_v1));
+	LASSERTF((int)offsetof(struct lov_comp_md_entry_v1, lcme_id) == 0, "found %lld\n",
+		 (long long)(int)offsetof(struct lov_comp_md_entry_v1, lcme_id));
+	LASSERTF((int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_id) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_id));
+	LASSERTF((int)offsetof(struct lov_comp_md_entry_v1, lcme_flags) == 4, "found %lld\n",
+		 (long long)(int)offsetof(struct lov_comp_md_entry_v1, lcme_flags));
+	LASSERTF((int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_flags) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_flags));
+	LASSERTF((int)offsetof(struct lov_comp_md_entry_v1, lcme_extent) == 8, "found %lld\n",
+		 (long long)(int)offsetof(struct lov_comp_md_entry_v1, lcme_extent));
+	LASSERTF((int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_extent) == 16, "found %lld\n",
+		 (long long)(int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_extent));
+	LASSERTF((int)offsetof(struct lov_comp_md_entry_v1, lcme_offset) == 24, "found %lld\n",
+		 (long long)(int)offsetof(struct lov_comp_md_entry_v1, lcme_offset));
+	LASSERTF((int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_offset) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_offset));
+	LASSERTF((int)offsetof(struct lov_comp_md_entry_v1, lcme_size) == 28, "found %lld\n",
+		 (long long)(int)offsetof(struct lov_comp_md_entry_v1, lcme_size));
+	LASSERTF((int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_size) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_size));
+	LASSERTF((int)offsetof(struct lov_comp_md_entry_v1, lcme_padding) == 32, "found %lld\n",
+		 (long long)(int)offsetof(struct lov_comp_md_entry_v1, lcme_padding));
+	LASSERTF((int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_padding) == 16, "found %lld\n",
+		 (long long)(int)sizeof(((struct lov_comp_md_entry_v1 *)0)->lcme_padding));
+	LASSERTF(LCME_FL_INIT == 0x00000010UL, "found 0x%.8xUL\n",
+	         (unsigned int)LCME_FL_INIT);
+
+	/* Checks for struct lov_comp_md_v1 */
+	LASSERTF((int)sizeof(struct lov_comp_md_v1) == 32, "found %lld\n",
+		 (long long)(int)sizeof(struct lov_comp_md_v1));
+	LASSERTF((int)offsetof(struct lov_comp_md_v1, lcm_magic) == 0, "found %lld\n",
+		 (long long)(int)offsetof(struct lov_comp_md_v1, lcm_magic));
+	LASSERTF((int)sizeof(((struct lov_comp_md_v1 *)0)->lcm_magic) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct lov_comp_md_v1 *)0)->lcm_magic));
+	LASSERTF((int)offsetof(struct lov_comp_md_v1, lcm_size) == 4, "found %lld\n",
+		 (long long)(int)offsetof(struct lov_comp_md_v1, lcm_size));
+	LASSERTF((int)sizeof(((struct lov_comp_md_v1 *)0)->lcm_size) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct lov_comp_md_v1 *)0)->lcm_size));
+	LASSERTF((int)offsetof(struct lov_comp_md_v1, lcm_layout_gen) == 8, "found %lld\n",
+		 (long long)(int)offsetof(struct lov_comp_md_v1, lcm_layout_gen));
+	LASSERTF((int)sizeof(((struct lov_comp_md_v1 *)0)->lcm_layout_gen) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct lov_comp_md_v1 *)0)->lcm_layout_gen));
+	LASSERTF((int)offsetof(struct lov_comp_md_v1, lcm_flags) == 12, "found %lld\n",
+		 (long long)(int)offsetof(struct lov_comp_md_v1, lcm_flags));
+	LASSERTF((int)sizeof(((struct lov_comp_md_v1 *)0)->lcm_flags) == 2, "found %lld\n",
+		 (long long)(int)sizeof(((struct lov_comp_md_v1 *)0)->lcm_flags));
+	LASSERTF((int)offsetof(struct lov_comp_md_v1, lcm_entry_count) == 14, "found %lld\n",
+		 (long long)(int)offsetof(struct lov_comp_md_v1, lcm_entry_count));
+	LASSERTF((int)sizeof(((struct lov_comp_md_v1 *)0)->lcm_entry_count) == 2, "found %lld\n",
+		 (long long)(int)sizeof(((struct lov_comp_md_v1 *)0)->lcm_entry_count));
+	LASSERTF((int)offsetof(struct lov_comp_md_v1, lcm_padding1) == 16, "found %lld\n",
+		 (long long)(int)offsetof(struct lov_comp_md_v1, lcm_padding1));
+	LASSERTF((int)sizeof(((struct lov_comp_md_v1 *)0)->lcm_padding1) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct lov_comp_md_v1 *)0)->lcm_padding1));
+	LASSERTF((int)offsetof(struct lov_comp_md_v1, lcm_padding2) == 24, "found %lld\n",
+		 (long long)(int)offsetof(struct lov_comp_md_v1, lcm_padding2));
+	LASSERTF((int)sizeof(((struct lov_comp_md_v1 *)0)->lcm_padding2) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct lov_comp_md_v1 *)0)->lcm_padding2));
+	LASSERTF((int)offsetof(struct lov_comp_md_v1, lcm_entries[0]) == 32, "found %lld\n",
+		 (long long)(int)offsetof(struct lov_comp_md_v1, lcm_entries[0]));
+	LASSERTF((int)sizeof(((struct lov_comp_md_v1 *)0)->lcm_entries[0]) == 48, "found %lld\n",
+		 (long long)(int)sizeof(((struct lov_comp_md_v1 *)0)->lcm_entries[0]));
+	BUILD_BUG_ON(LOV_MAGIC_COMP_V1 != (0x0BD60000 | 0x0BD0));
+
 	/* Checks for struct lmv_mds_md_v1 */
 	LASSERTF((int)sizeof(struct lmv_mds_md_v1) == 56, "found %lld\n",
 		 (long long)(int)sizeof(struct lmv_mds_md_v1));
-- 
1.8.3.1
