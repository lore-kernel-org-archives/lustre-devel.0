From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:19 -0400
Subject: [lustre-devel] [PATCH 120/151] lustre: flr: layout truncate
 compatibility
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-121-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bobi Jam <bobijam@hotmail.com>

In PFL design, client issues [0, size) intent to MDS to instantiate
objects in this extent. While in FLR design, the intent serves two
purposes: 1) make objects across [size, EOF) on other mirrors stale,
and 2) instantiate objects in the chosen write mirror. And original
FLR chose to use [size, EOF) as the extent of truncate write intent
request.

This patch reverts the choice, and still uses [0, size) as the
truncate write intent extent.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10438
Lustre-commit: 795ca68f1360 ("LU-10438 flr: layout truncate compatibility")
Signed-off-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-on: https://review.whamcloud.com/30786
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_io.c | 24 ++++++++++++++++--------
 1 file changed, 16 insertions(+), 8 deletions(-)

diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index 54e2d7d..5b28793 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -357,6 +357,16 @@ static int lov_io_mirror_init(struct lov_io *lio, struct lov_object *obj,
 		       PFID(lu_object_fid(lov2lu(obj))),
 		       lio->lis_pos, lio->lis_endpos);
 
+		if (cl_io_is_trunc(io)) {
+			/**
+			 * for truncate, we uses [size, EOF) to judge whether
+			 * a write intent needs to be send, but we need to
+			 * restore the write extent to [0, size).
+			 */
+			io->ci_write_intent.e_start = 0;
+			io->ci_write_intent.e_end =
+					io->u.ci_setattr.sa_attr.lvb_size;
+		}
 		/* stop cl_io_init() loop */
 		return 1;
 	}
@@ -441,7 +451,6 @@ static int lov_io_mirror_init(struct lov_io *lio, struct lov_object *obj,
 static int lov_io_slice_init(struct lov_io *lio, struct lov_object *obj,
 			     struct cl_io *io)
 {
-	struct lu_extent ext;
 	int index;
 	int result = 0;
 
@@ -538,20 +547,19 @@ static int lov_io_slice_init(struct lov_io *lio, struct lov_object *obj,
 		goto out;
 	}
 
-	io->ci_write_intent.e_start = lio->lis_pos;
-	io->ci_write_intent.e_end = lio->lis_endpos;
-
-	ext = io->ci_write_intent;
 	/* for truncate, it only needs to instantiate the components
 	 * before the truncated size.
 	 */
 	if (cl_io_is_trunc(io)) {
-		ext.e_start = 0;
-		ext.e_end = io->u.ci_setattr.sa_attr.lvb_size;
+		io->ci_write_intent.e_start = 0;
+		io->ci_write_intent.e_end = io->u.ci_setattr.sa_attr.lvb_size;
+	} else {
+		io->ci_write_intent.e_start = lio->lis_pos;
+		io->ci_write_intent.e_end = lio->lis_endpos;
 	}
 
 	index = 0;
-	lov_foreach_io_layout(index, lio, &ext) {
+	lov_foreach_io_layout(index, lio, &io->ci_write_intent) {
 		if (!lsm_entry_inited(obj->lo_lsm, index)) {
 			io->ci_need_write_intent = 1;
 			break;
-- 
1.8.3.1
