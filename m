From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:08:41 -0500
Subject: [lustre-devel] [PATCH 053/622] lustre: osc: truncate does not
 update blocks count on client
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-54-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Arshad Hussain <arshad.super@gmail.com>

'truncate' call correctly updates the server side with
correct size and blocks count. However, on the client
side all the metadata are correctly updated except the
blocks count, which still reflects the old count prior
to truncate call. This patch fixes this issue on the
client by modifying osc_io_setattr_end() to update
attr with the updated block count.

New test case under sanity is added to verify the that
the blocks counts are correctly updated after truncate call

Co-authored-by: Abrarahmed Momin <abrar.momin@gmail.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-10370
Lustre-commit: 6115eb7fd55a ("LU-10370 ofd: truncate does not update blocks count on client")
Signed-off-by: Abrarahmed Momin <abrar.momin@gmail.com>
Signed-off-by: Arshad Hussain <arshad.super@gmail.com>
Reviewed-on: https://review.whamcloud.com/31073
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_io.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index 970e8a7..1485962 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -588,6 +588,9 @@ void osc_io_setattr_end(const struct lu_env *env,
 	struct osc_io *oio = cl2osc_io(env, slice);
 	struct cl_object *obj = slice->cis_obj;
 	struct osc_async_cbargs *cbargs = &oio->oi_cbarg;
+	struct cl_attr  *attr = &osc_env_info(env)->oti_attr;
+	struct obdo *oa = &oio->oi_oa;
+	unsigned int cl_valid = 0;
 	int result = 0;
 
 	if (cbargs->opc_rpc_sent) {
@@ -609,6 +612,14 @@ void osc_io_setattr_end(const struct lu_env *env,
 	if (cl_io_is_trunc(io)) {
 		u64 size = io->u.ci_setattr.sa_attr.lvb_size;
 
+		cl_object_attr_lock(obj);
+		if (oa->o_valid & OBD_MD_FLBLOCKS) {
+			attr->cat_blocks = oa->o_blocks;
+			cl_valid |= CAT_BLOCKS;
+		}
+
+		cl_object_attr_update(env, obj, attr, cl_valid);
+		cl_object_attr_unlock(obj);
 		osc_trunc_check(env, io, oio, size);
 		osc_cache_truncate_end(env, oio->oi_trunc);
 		oio->oi_trunc = NULL;
-- 
1.8.3.1
