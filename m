From: Shivani Bhardwaj <shivanib134@gmail.com>
Date: Wed, 11 Nov 2015 14:29:07 +0530
Subject: [lustre-devel] [PATCH] staging: lustre: cl_io: Remove
	cl_lock_descr_fid wrapper
Message-ID: <1447232347-35621-1-git-send-email-shivanib134@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Remove unnecessary wrapper function cl_lock_descr_fid() and replace all
its calls with the function it wrapped.

Signed-off-by: Shivani Bhardwaj <shivanib134@gmail.com>
---
 drivers/staging/lustre/lustre/obdclass/cl_io.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index e67cea7..37c449b 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -236,16 +236,11 @@ int cl_io_rw_init(const struct lu_env *env, struct cl_io *io,
 }
 EXPORT_SYMBOL(cl_io_rw_init);
 
-static inline const struct lu_fid *
-cl_lock_descr_fid(const struct cl_lock_descr *descr)
-{
-	return lu_object_fid(&descr->cld_obj->co_lu);
-}
-
 static int cl_lock_descr_sort(const struct cl_lock_descr *d0,
 			      const struct cl_lock_descr *d1)
 {
-	return lu_fid_cmp(cl_lock_descr_fid(d0), cl_lock_descr_fid(d1)) ?:
+	return lu_fid_cmp(lu_object_fid(&d0->cld_obj->co_lu),
+			  lu_object_fid(&d1->cld_obj->co_lu)) ?:
 		__diff_normalize(d0->cld_start, d1->cld_start);
 }
 
@@ -254,7 +249,8 @@ static int cl_lock_descr_cmp(const struct cl_lock_descr *d0,
 {
 	int ret;
 
-	ret = lu_fid_cmp(cl_lock_descr_fid(d0), cl_lock_descr_fid(d1));
+	ret = lu_fid_cmp(lu_object_fid(&d0->cld_obj->co_lu),
+			 lu_object_fid(&d1->cld_obj->co_lu));
 	if (ret)
 		return ret;
 	if (d0->cld_end < d1->cld_start)
-- 
2.1.0
