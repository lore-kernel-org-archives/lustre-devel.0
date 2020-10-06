From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:06:08 -0400
Subject: [lustre-devel] [PATCH 29/42] lustre: lov: discard unused
 lov_dump_lmm* functions
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-30-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

lov_dump_lmm_v3() is never used, so remove it.

So mark lov_lsm_pack_v1v3() and lov_lsm_pack_foreign() as static.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6142
Lustre-commit: c7d0d63b5191c6 ("LU-6142 lov: discard unused lov_dump_lmm* functions")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39378
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_internal.h |  1 -
 fs/lustre/lov/lov_pack.c     | 17 ++++-------------
 2 files changed, 4 insertions(+), 14 deletions(-)

diff --git a/fs/lustre/lov/lov_internal.h b/fs/lustre/lov/lov_internal.h
index 5f5f98e..202e4b5 100644
--- a/fs/lustre/lov/lov_internal.h
+++ b/fs/lustre/lov/lov_internal.h
@@ -308,7 +308,6 @@ struct lov_stripe_md *lov_unpackmd(struct lov_obd *lov, void *buf,
 int lov_free_memmd(struct lov_stripe_md **lsmp);
 
 void lov_dump_lmm_v1(int level, struct lov_mds_md_v1 *lmm);
-void lov_dump_lmm_v3(int level, struct lov_mds_md_v3 *lmm);
 void lov_dump_lmm_common(int level, void *lmmp);
 
 /* lov_ea.c */
diff --git a/fs/lustre/lov/lov_pack.c b/fs/lustre/lov/lov_pack.c
index a6a68b7..d200a62 100644
--- a/fs/lustre/lov/lov_pack.c
+++ b/fs/lustre/lov/lov_pack.c
@@ -92,15 +92,6 @@ void lov_dump_lmm_v1(int level, struct lov_mds_md_v1 *lmm)
 			     le16_to_cpu(lmm->lmm_stripe_count));
 }
 
-void lov_dump_lmm_v3(int level, struct lov_mds_md_v3 *lmm)
-{
-	lov_dump_lmm_common(level, lmm);
-	CDEBUG_LIMIT(level, "pool_name " LOV_POOLNAMEF "\n",
-		     lmm->lmm_pool_name);
-	lov_dump_lmm_objects(level, lmm->lmm_objects,
-			     le16_to_cpu(lmm->lmm_stripe_count));
-}
-
 /**
  * Pack LOV striping metadata for disk storage format (in little
  * endian byte order).
@@ -109,8 +100,8 @@ void lov_dump_lmm_v3(int level, struct lov_mds_md_v3 *lmm)
  * then return the size needed. If @buf_size is too small then
  * return -ERANGE. Otherwise return the size of the result.
  */
-ssize_t lov_lsm_pack_v1v3(const struct lov_stripe_md *lsm, void *buf,
-			  size_t buf_size)
+static ssize_t lov_lsm_pack_v1v3(const struct lov_stripe_md *lsm, void *buf,
+				 size_t buf_size)
 {
 	struct lov_ost_data_v1 *lmm_objects;
 	struct lov_mds_md_v1 *lmmv1 = buf;
@@ -162,8 +153,8 @@ ssize_t lov_lsm_pack_v1v3(const struct lov_stripe_md *lsm, void *buf,
 	return lmm_size;
 }
 
-ssize_t lov_lsm_pack_foreign(const struct lov_stripe_md *lsm, void *buf,
-			     size_t buf_size)
+static ssize_t lov_lsm_pack_foreign(const struct lov_stripe_md *lsm, void *buf,
+				    size_t buf_size)
 {
 	struct lov_foreign_md *lfm = buf;
 	size_t lfm_size;
-- 
1.8.3.1
