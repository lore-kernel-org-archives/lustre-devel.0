From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:18 -0400
Subject: [lustre-devel] [PATCH 119/151] lustre: uapi: rename LCM_FL_NOT_FLR
 to LCM_FL_NONE
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-120-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Having "lfs getstripe" print out "lcm_flags: not_flr" is not very
useful, as the composite files may not relate to FLR (e.g. PFL).
Rename "LCM_FL_NOT_FLR" to "LCM_FL_NONE" so it is more clear there
are no composite flags on the layout.

Print out "0" for flags if no flags are set, to match old behaviour.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9771
Lustre-commit: fa15e5347c2e ("LU-9771 util: rename LCM_FL_NOT_FLR to LCM_FL_NONE")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/31047
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_cl_internal.h         | 4 ++--
 fs/lustre/lov/lov_object.c              | 4 ++--
 fs/lustre/ptlrpc/wiretest.c             | 4 ++--
 include/uapi/linux/lustre/lustre_user.h | 2 +-
 4 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/lustre/lov/lov_cl_internal.h b/fs/lustre/lov/lov_cl_internal.h
index 4ab8fba..875af37 100644
--- a/fs/lustre/lov/lov_cl_internal.h
+++ b/fs/lustre/lov/lov_cl_internal.h
@@ -354,14 +354,14 @@ static inline struct lov_stripe_md_entry *lov_lse(struct lov_object *lov, int i)
 static inline unsigned int lov_flr_state(const struct lov_object *lov)
 {
 	if (lov->lo_type != LLT_COMP)
-		return LCM_FL_NOT_FLR;
+		return LCM_FL_NONE;
 
 	return lov->u.composite.lo_flags & LCM_FL_FLR_MASK;
 }
 
 static inline bool lov_is_flr(const struct lov_object *lov)
 {
-	return lov_flr_state(lov) != LCM_FL_NOT_FLR;
+	return lov_flr_state(lov) != LCM_FL_NONE;
 }
 
 static inline struct lov_layout_entry *lov_entry(struct lov_object *lov, int i)
diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index 51b95f2..6ba821b 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -629,7 +629,7 @@ static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
 	comp->lo_entry_count = lsm->lsm_entry_count;
 	comp->lo_preferred_mirror = -1;
 
-	if (equi(flr_state == LCM_FL_NOT_FLR, comp->lo_mirror_count > 1))
+	if (equi(flr_state == LCM_FL_NONE, comp->lo_mirror_count > 1))
 		return -EINVAL;
 
 	comp->lo_mirrors = kcalloc(comp->lo_mirror_count,
@@ -669,7 +669,7 @@ static int lov_init_composite(const struct lu_env *env, struct lov_device *dev,
 		lle->lle_extent = &lle->lle_lsme->lsme_extent;
 		lle->lle_valid = !(lle->lle_lsme->lsme_flags & LCME_FL_STALE);
 
-		if (flr_state != LCM_FL_NOT_FLR)
+		if (flr_state != LCM_FL_NONE)
 			mirror_id = mirror_id_of(lle->lle_lsme->lsme_id);
 
 		lre = &comp->lo_mirrors[j];
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index e161fe6..70ed2cd 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -1542,8 +1542,8 @@ void lustre_assert_wire_constants(void)
 	LASSERTF((int)sizeof(((struct lov_comp_md_v1 *)0)->lcm_entries[0]) == 48, "found %lld\n",
 		 (long long)(int)sizeof(((struct lov_comp_md_v1 *)0)->lcm_entries[0]));
 	BUILD_BUG_ON(LOV_MAGIC_COMP_V1 != (0x0BD60000 | 0x0BD0));
-	LASSERTF(LCM_FL_NOT_FLR == 0, "found %lld\n",
-		 (long long)LCM_FL_NOT_FLR);
+	LASSERTF(LCM_FL_NONE == 0, "found %lld\n",
+		 (long long)LCM_FL_NONE);
 	LASSERTF(LCM_FL_RDONLY == 1, "found %lld\n",
 		 (long long)LCM_FL_RDONLY);
 	LASSERTF(LCM_FL_WRITE_PENDING == 2, "found %lld\n",
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index cea7d13..4e673cd 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -530,7 +530,7 @@ static inline __u16 mirror_id_of(__u32 id)
  */
 enum lov_comp_md_flags {
 	/* the least 2 bits are used by FLR to record file state */
-	LCM_FL_NOT_FLR          = 0,
+	LCM_FL_NONE             = 0,
 	LCM_FL_RDONLY           = 1,
 	LCM_FL_WRITE_PENDING    = 2,
 	LCM_FL_SYNC_PENDING     = 3,
-- 
1.8.3.1
