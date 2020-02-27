From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:10:57 -0500
Subject: [lustre-devel] [PATCH 189/622] lustre: lov: quiet lov_dump_lmm_
 console messages
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-190-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Limit messages in lov_dump_lmm_objects() and lov_dump_lmm_common()
printing to the console repeatedly when D_ERROR is used.  Change
CDEBUG() to CDEBUG_LIMIT() so that rate-limiting is applied.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11579
Lustre-commit: d9ef75eb8226 ("LU-11579 lov: quiet lov_dump_lmm_ console messages")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33513
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_pack.c | 26 ++++++++++++++------------
 1 file changed, 14 insertions(+), 12 deletions(-)

diff --git a/fs/lustre/lov/lov_pack.c b/fs/lustre/lov/lov_pack.c
index 5f8b281..c6dec2d 100644
--- a/fs/lustre/lov/lov_pack.c
+++ b/fs/lustre/lov/lov_pack.c
@@ -55,13 +55,13 @@ void lov_dump_lmm_common(int level, void *lmmp)
 	struct ost_id oi;
 
 	lmm_oi_le_to_cpu(&oi, &lmm->lmm_oi);
-	CDEBUG(level, "objid " DOSTID ", magic 0x%08x, pattern %#x\n",
-	       POSTID(&oi), le32_to_cpu(lmm->lmm_magic),
-	       le32_to_cpu(lmm->lmm_pattern));
-	CDEBUG(level, "stripe_size %u, stripe_count %u, layout_gen %u\n",
-	       le32_to_cpu(lmm->lmm_stripe_size),
-	       le16_to_cpu(lmm->lmm_stripe_count),
-	       le16_to_cpu(lmm->lmm_layout_gen));
+	CDEBUG_LIMIT(level, "objid " DOSTID ", magic 0x%08x, pattern %#x\n",
+		     POSTID(&oi), le32_to_cpu(lmm->lmm_magic),
+		     le32_to_cpu(lmm->lmm_pattern));
+	CDEBUG_LIMIT(level, "stripe_size %u, stripe_count %u, layout_gen %u\n",
+		     le32_to_cpu(lmm->lmm_stripe_size),
+		     le16_to_cpu(lmm->lmm_stripe_count),
+		     le16_to_cpu(lmm->lmm_layout_gen));
 }
 
 static void lov_dump_lmm_objects(int level, struct lov_ost_data *lod,
@@ -70,8 +70,9 @@ static void lov_dump_lmm_objects(int level, struct lov_ost_data *lod,
 	int i;
 
 	if (stripe_count > LOV_V1_INSANE_STRIPE_COUNT) {
-		CDEBUG(level, "bad stripe_count %u > max_stripe_count %u\n",
-		       stripe_count, LOV_V1_INSANE_STRIPE_COUNT);
+		CDEBUG_LIMIT(level,
+			     "bad stripe_count %u > max_stripe_count %u\n",
+			     stripe_count, LOV_V1_INSANE_STRIPE_COUNT);
 		return;
 	}
 
@@ -79,8 +80,8 @@ static void lov_dump_lmm_objects(int level, struct lov_ost_data *lod,
 		struct ost_id oi;
 
 		ostid_le_to_cpu(&lod->l_ost_oi, &oi);
-		CDEBUG(level, "stripe %u idx %u subobj " DOSTID "\n", i,
-		       le32_to_cpu(lod->l_ost_idx), POSTID(&oi));
+		CDEBUG_LIMIT(level, "stripe %u idx %u subobj " DOSTID "\n", i,
+			     le32_to_cpu(lod->l_ost_idx), POSTID(&oi));
 	}
 }
 
@@ -94,7 +95,8 @@ void lov_dump_lmm_v1(int level, struct lov_mds_md_v1 *lmm)
 void lov_dump_lmm_v3(int level, struct lov_mds_md_v3 *lmm)
 {
 	lov_dump_lmm_common(level, lmm);
-	CDEBUG(level, "pool_name " LOV_POOLNAMEF "\n", lmm->lmm_pool_name);
+	CDEBUG_LIMIT(level, "pool_name " LOV_POOLNAMEF "\n",
+		     lmm->lmm_pool_name);
 	lov_dump_lmm_objects(level, lmm->lmm_objects,
 			     le16_to_cpu(lmm->lmm_stripe_count));
 }
-- 
1.8.3.1
