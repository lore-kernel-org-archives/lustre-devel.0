From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:00 -0400
Subject: [lustre-devel] [PATCH 101/151] lustre: flr: comp-flags support when
 creating mirrors
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-102-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Jinshan Xiong <jinshan.xiong@gmail.com>

This patch will allow flags to be set when creating mirrors.
The flags are set to individual components therefore it would be
flexible to flags based on the location of components. Also, 'stale'
and 'prefer' flags are allowed to set to individual components later
on.

This patch also revises component flags matching rules to allow
flags and inverted flags to be set at the same time in the command
lfs-find(1) and lfs-getstripe(1).

WC-bug-id: https://jira.whamcloud.com/browse/LU-10282
Lustre-commit: aa1646a8a1c2 ("LU-10282 flr: comp-flags support when creating mirrors")
Signed-off-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-on: https://review.whamcloud.com/30360
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_object.c              | 44 +++++++++++----------------------
 include/uapi/linux/lustre/lustre_user.h | 19 +++++++-------
 2 files changed, 24 insertions(+), 39 deletions(-)

diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index a73f2ac..d3ed5fc 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -611,6 +611,7 @@ static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
 	unsigned int psz = 0;
 	unsigned int mirror_count;
 	int result = 0;
+	unsigned int seq;
 	int i, j;
 
 	LASSERT(lsm->lsm_entry_count > 0);
@@ -694,8 +695,8 @@ static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
 		/* entries must be sorted by mirrors */
 		lre->lre_mirror_id = mirror_id;
 		lre->lre_start = lre->lre_end = i;
-		lre->lre_preferred = (lle->lle_lsme->lsme_flags &
-					LCME_FL_PREFERRED);
+		lre->lre_preferred = !!(lle->lle_lsme->lsme_flags &
+					LCME_FL_PREF_RD);
 		lre->lre_valid = lle->lle_valid;
 		lre->lre_stale = !lle->lle_valid;
 	}
@@ -734,45 +735,30 @@ static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
 	if (psz > 0)
 		cl_object_header(&lov->lo_cl)->coh_page_bufsize += psz;
 
-	/* decide the preferred mirror */
+	/*
+	 * Decide the preferred mirror. It uses the hash value of lov_object
+	 * so that different clients would use different mirrors for read.
+	 */
 	mirror_count = 0;
-	i = 0;
-	lov_foreach_mirror_entry(lov, lre) {
-		i++;
+	seq = hash_long((unsigned long)lov, 8);
+	for (i = 0; i < comp->lo_mirror_count; i++) {
+		unsigned int idx = (i + seq) % comp->lo_mirror_count;
+
+		lre = lov_mirror_entry(lov, idx);
 		if (lre->lre_stale)
 			continue;
 
 		mirror_count++; /* valid mirror */
 
 		if (lre->lre_preferred || comp->lo_preferred_mirror < 0)
-			comp->lo_preferred_mirror = i - 1;
+			comp->lo_preferred_mirror = idx;
 	}
-	if (mirror_count == 0) {
+	if (!mirror_count) {
 		CDEBUG(D_INODE, DFID
 		       " doesn't have any valid mirrors\n",
 		       PFID(lu_object_fid(lov2lu(lov))));
 
-		result = -EINVAL;
-		goto out;
-	}
-
-	if (OBD_FAIL_CHECK(OBD_FAIL_FLR_RANDOM_PICK_MIRROR)) {
-		unsigned int seq;
-
-		get_random_bytes(&seq, sizeof(seq));
-		seq %= mirror_count;
-
-		i = 0;
-		lov_foreach_mirror_entry(lov, lre) {
-			i++;
-			if (lre->lre_stale)
-				continue;
-
-			if (!seq--) {
-				comp->lo_preferred_mirror = i - 1;
-				break;
-			}
-		}
+		comp->lo_preferred_mirror = 0;
 	}
 
 	LASSERT(comp->lo_preferred_mirror >= 0);
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 3f29093..21dc1e9 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -463,17 +463,21 @@ static inline bool lu_extent_is_whole(struct lu_extent *e)
 }
 
 enum lov_comp_md_entry_flags {
-	LCME_FL_PRIMARY		= 0x00000001,	/* Not used */
-	LCME_FL_STALE		= 0x00000002,	/* Not used */
-	LCME_FL_OFFLINE		= 0x00000004,	/* Not used */
-	LCME_FL_PREFERRED	= 0x00000008,	/* Not used */
+	LCME_FL_STALE		= 0x00000001,	/* FLR: stale data */
+	LCME_FL_PREF_RD		= 0x00000002,	/* FLR: preferred for reading */
+	LCME_FL_PREF_WR		= 0x00000004,	/* FLR: preferred for writing */
+	LCME_FL_PREF_RW		= LCME_FL_PREF_RD | LCME_FL_PREF_WR,
+	LCME_FL_OFFLINE		= 0x00000008,	/* Not used */
 	LCME_FL_INIT		= 0x00000010,	/* instantiated */
 	LCME_FL_NEG		= 0x80000000,	/* used to indicate a negative
 						 * flag, won't be stored on disk
 						 */
 };
 
-#define LCME_KNOWN_FLAGS	(LCME_FL_NEG | LCME_FL_INIT)
+#define LCME_KNOWN_FLAGS	(LCME_FL_NEG | LCME_FL_INIT | LCME_FL_STALE | \
+				 LCME_FL_PREF_RW)
+/* The flags can be set by users at mirror creation time. */
+#define LCME_USER_FLAGS		(LCME_FL_PREF_RW)
 
 /* the highest bit in obdo::o_layout_version is used to mark if the file is
  * being resynced.
@@ -546,11 +550,6 @@ struct lov_comp_md_v1 {
 	struct lov_comp_md_entry_v1 lcm_entries[0];
 } __packed;
 
-/*
- * Maximum number of mirrors Lustre can support.
- */
-#define LUSTRE_MIRROR_COUNT_MAX		16
-
 static inline __u32 lov_user_md_size(__u16 stripes, __u32 lmm_magic)
 {
 	if (stripes == (__u16)-1)
-- 
1.8.3.1
