From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:48 -0400
Subject: [lustre-devel] [PATCH 049/124] staging: lustre: lmv: move some
	inline functions to lustre_lmv.h
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-50-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Fan Yong <fan.yong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Fan Yong <fan.yong@intel.com>

Move some inline code out of lmv core into lustre_lmv.h.
This is to prepare for use outside of the lmv layer in
the future of these functions. Change from passing in
struct lmv_stripe_md to just int for lmv_is_known_hash_type.

Signed-off-by: Fan Yong <fan.yong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5519
Reviewed-on: http://review.whamcloud.com/11845
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Lai Siyao <lai.siyao@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_lmv.h |   63 ++++++++++++++++++++
 drivers/staging/lustre/lustre/lmv/lmv_intent.c     |    2 +-
 drivers/staging/lustre/lustre/lmv/lmv_internal.h   |    8 +--
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |   59 +------------------
 4 files changed, 66 insertions(+), 66 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_lmv.h b/drivers/staging/lustre/lustre/include/lustre_lmv.h
index 388161e..d7f7afa 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lmv.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lmv.h
@@ -118,4 +118,67 @@ static inline void lmv_le_to_cpu(union lmv_mds_md *lmv_dst,
 	}
 }
 
+/* This hash is only for testing purpose */
+static inline unsigned int
+lmv_hash_all_chars(unsigned int count, const char *name, int namelen)
+{
+	const unsigned char *p = (const unsigned char *)name;
+	unsigned int c = 0;
+
+	while (--namelen >= 0)
+		c += p[namelen];
+
+	c = c % count;
+
+	return c;
+}
+
+static inline unsigned int
+lmv_hash_fnv1a(unsigned int count, const char *name, int namelen)
+{
+	__u64 hash;
+
+	hash = lustre_hash_fnv_1a_64(name, namelen);
+
+	return do_div(hash, count);
+}
+
+static inline int lmv_name_to_stripe_index(__u32 lmv_hash_type,
+					   unsigned int stripe_count,
+					   const char *name, int namelen)
+{
+	__u32 hash_type = lmv_hash_type & LMV_HASH_TYPE_MASK;
+	int idx;
+
+	LASSERT(namelen > 0);
+	if (stripe_count <= 1)
+		return 0;
+
+	/* for migrating object, always start from 0 stripe */
+	if (lmv_hash_type & LMV_HASH_FLAG_MIGRATION)
+		return 0;
+
+	switch (hash_type) {
+	case LMV_HASH_TYPE_ALL_CHARS:
+		idx = lmv_hash_all_chars(stripe_count, name, namelen);
+		break;
+	case LMV_HASH_TYPE_FNV_1A_64:
+		idx = lmv_hash_fnv1a(stripe_count, name, namelen);
+		break;
+	default:
+		idx = -EBADFD;
+		break;
+	}
+	CDEBUG(D_INFO, "name %.*s hash_type %d idx %d\n", namelen, name,
+	       hash_type, idx);
+
+	return idx;
+}
+
+static inline bool lmv_is_known_hash_type(__u32 type)
+{
+	return (type & LMV_HASH_TYPE_MASK) == LMV_HASH_TYPE_FNV_1A_64 ||
+	       (type & LMV_HASH_TYPE_MASK) == LMV_HASH_TYPE_ALL_CHARS;
+}
+
 #endif
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index 1952454..94577f3 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -414,7 +414,7 @@ static int lmv_intent_lookup(struct obd_export *exp,
 	 * Both migrating dir and unknown hash dir need to try
 	 * all of sub-stripes
 	 */
-	if (lsm && !lmv_is_known_hash_type(lsm)) {
+	if (lsm && !lmv_is_known_hash_type(lsm->lsm_md_hash_type)) {
 		struct lmv_oinfo *oinfo = &lsm->lsm_md_oinfo[0];
 
 		op_data->op_fid1 = oinfo->lmo_fid;
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_internal.h b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
index 4a5e385..8f703ea 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_internal.h
+++ b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
@@ -151,15 +151,9 @@ lsm_name_to_stripe_info(const struct lmv_stripe_md *lsm, const char *name,
 	return &lsm->lsm_md_oinfo[stripe_index];
 }
 
-static inline bool lmv_is_known_hash_type(const struct lmv_stripe_md *lsm)
-{
-	return lsm->lsm_md_hash_type == LMV_HASH_TYPE_FNV_1A_64 ||
-	       lsm->lsm_md_hash_type == LMV_HASH_TYPE_ALL_CHARS;
-}
-
 static inline bool lmv_need_try_all_stripes(const struct lmv_stripe_md *lsm)
 {
-	return !lmv_is_known_hash_type(lsm) ||
+	return !lmv_is_known_hash_type(lsm->lsm_md_hash_type) ||
 	       lsm->lsm_md_hash_type & LMV_HASH_FLAG_MIGRATION;
 }
 
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 8033ae2..d9f8003 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -53,63 +53,6 @@
 #include "../include/lustre_kernelcomm.h"
 #include "lmv_internal.h"
 
-/* This hash is only for testing purpose */
-static inline unsigned int
-lmv_hash_all_chars(unsigned int count, const char *name, int namelen)
-{
-	const unsigned char *p = (const unsigned char *)name;
-	unsigned int c = 0;
-
-	while (--namelen >= 0)
-		c += p[namelen];
-
-	c = c % count;
-
-	return c;
-}
-
-static inline unsigned int
-lmv_hash_fnv1a(unsigned int count, const char *name, int namelen)
-{
-	__u64 hash;
-
-	hash = lustre_hash_fnv_1a_64(name, namelen);
-
-	return do_div(hash, count);
-}
-
-int lmv_name_to_stripe_index(__u32 lmv_hash_type, unsigned int stripe_count,
-			     const char *name, int namelen)
-{
-	__u32 hash_type = lmv_hash_type & LMV_HASH_TYPE_MASK;
-	int idx;
-
-	LASSERT(namelen > 0);
-	if (stripe_count <= 1)
-		return 0;
-
-	/* for migrating object, always start from 0 stripe */
-	if (lmv_hash_type & LMV_HASH_FLAG_MIGRATION)
-		return 0;
-
-	switch (hash_type) {
-	case LMV_HASH_TYPE_ALL_CHARS:
-		idx = lmv_hash_all_chars(stripe_count, name, namelen);
-		break;
-	case LMV_HASH_TYPE_FNV_1A_64:
-		idx = lmv_hash_fnv1a(stripe_count, name, namelen);
-		break;
-	default:
-		idx = -EBADFD;
-		break;
-	}
-
-	CDEBUG(D_INFO, "name %.*s hash_type %d idx %d\n", namelen, name,
-	       hash_type, idx);
-
-	return idx;
-}
-
 static void lmv_activate_target(struct lmv_obd *lmv,
 				struct lmv_tgt_desc *tgt,
 				int activate)
@@ -2531,7 +2474,7 @@ retry_unlink:
 		 * inside lmv_locate_target_for_name(), so we only check
 		 * unknown hash type directory here
 		 */
-		if (!lmv_is_known_hash_type(lsm)) {
+		if (!lmv_is_known_hash_type(lsm->lsm_md_hash_type)) {
 			struct lmv_oinfo *oinfo;
 
 			oinfo = &lsm->lsm_md_oinfo[stripe_index];
-- 
1.7.1
