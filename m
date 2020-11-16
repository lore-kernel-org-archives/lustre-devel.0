From: James Simmons <jsimmons@infradead.org>
Date: Sun, 15 Nov 2020 19:59:37 -0500
Subject: [lustre-devel] [PATCH 04/28] lustre: llite: ASSERTION(
 last_oap_count > 0 ) failed
In-Reply-To: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
References: <1605488401-981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1605488401-981-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andriy Skulysh <c17819@cray.com>

Punch uses o_blocks to send end of a region. So it
can be mixed with real blocks count on error.

Update blocks count only on success.

HPE-bug-id: LUS-7407
WC-bug-id: https://jira.whamcloud.com/browse/LU-13992
Lustre-commit: a56fefc535677b ("LU-13992 llite: ASSERTION( last_oap_count > 0 ) failed")
Signed-off-by: Andriy Skulysh <c17819@cray.com>
Reviewed-by: Andrew Perepechko <c17827@cray.com>
Reviewed-by: Alexander Boyko <c17825@cray.com>
Reviewed-on: https://review.whamcloud.com/40050
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_io.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index 7ec059a..6121f39 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -691,14 +691,16 @@ void osc_io_setattr_end(const struct lu_env *env,
 	if (cl_io_is_trunc(io)) {
 		u64 size = io->u.ci_setattr.sa_attr.lvb_size;
 
-		cl_object_attr_lock(obj);
-		if (oa->o_valid & OBD_MD_FLBLOCKS) {
-			attr->cat_blocks = oa->o_blocks;
-			cl_valid |= CAT_BLOCKS;
-		}
+		if (result == 0) {
+			cl_object_attr_lock(obj);
+			if (oa->o_valid & OBD_MD_FLBLOCKS) {
+				attr->cat_blocks = oa->o_blocks;
+				cl_valid |= CAT_BLOCKS;
+			}
 
-		cl_object_attr_update(env, obj, attr, cl_valid);
-		cl_object_attr_unlock(obj);
+			cl_object_attr_update(env, obj, attr, cl_valid);
+			cl_object_attr_unlock(obj);
+		}
 		osc_trunc_check(env, io, oio, size);
 		osc_cache_truncate_end(env, oio->oi_trunc);
 		oio->oi_trunc = NULL;
-- 
1.8.3.1
