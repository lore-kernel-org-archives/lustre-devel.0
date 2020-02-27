From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:57 -0500
Subject: [lustre-devel] [PATCH 309/622] lustre: lov: fix wrong calculated
 length for fiemap
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-310-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Wang Shilong <wshilong@ddn.com>

lov_stripe_intersects() will return a closed interval
[@obd_start, @obd_end], so to calcuate length of interval we need

 @obd_end - @obd_start + 1

rather than

 @obd_end - @obd_start

Wrong extent length will make us return wrong fiemap information.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12361
Lustre-commit: 225e7b8c70fb ("LU-12361 lov: fix wrong calculated length for fiemap")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/34998
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Gu Zheng <gzheng@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_object.c | 4 ++--
 fs/lustre/lov/lov_offset.c | 2 ++
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index 7543ef2..27e0ca5 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -1677,7 +1677,7 @@ static int fiemap_for_stripe(const struct lu_env *env, struct cl_object *obj,
 	if (lun_start == lun_end)
 		return 0;
 
-	req_fm_len = obd_object_end - lun_start;
+	req_fm_len = obd_object_end - lun_start + 1;
 	fs->fs_fm->fm_length = 0;
 	len_mapped_single_call = 0;
 
@@ -1723,7 +1723,7 @@ static int fiemap_for_stripe(const struct lu_env *env, struct cl_object *obj,
 			fs->fs_fm->fm_mapped_extents = 1;
 
 			fm_ext[0].fe_logical = lun_start;
-			fm_ext[0].fe_length = obd_object_end - lun_start;
+			fm_ext[0].fe_length = obd_object_end - lun_start + 1;
 			fm_ext[0].fe_flags |= FIEMAP_EXTENT_UNKNOWN;
 
 			goto inactive_tgt;
diff --git a/fs/lustre/lov/lov_offset.c b/fs/lustre/lov/lov_offset.c
index bb67d82..b53ce43 100644
--- a/fs/lustre/lov/lov_offset.c
+++ b/fs/lustre/lov/lov_offset.c
@@ -226,6 +226,8 @@ u64 lov_size_to_stripe(struct lov_stripe_md *lsm, int index, u64 file_size,
 /* given an extent in an lov and a stripe, calculate the extent of the stripe
  * that is contained within the lov extent.  this returns true if the given
  * stripe does intersect with the lov extent.
+ *
+ * Closed interval [@obd_start, @obd_end] will be returned.
  */
 int lov_stripe_intersects(struct lov_stripe_md *lsm, int index, int stripeno,
 			  struct lu_extent *ext, u64 *obd_start, u64 *obd_end)
-- 
1.8.3.1
