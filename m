From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:55:09 -0400
Subject: [lustre-devel] [PATCH 050/151] lustre: lov: add Data-on-MDT tests
 and fixes
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-51-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mikhal Pershin <mpershin@whamcloud.com>

- fixes for DoM code for issues revealed by tests.

WC-bug-id: https://jira.whamcloud.com/browse/LU-3285
Lustre-commit: a7625cd2f37a ("LU-3285 test: add Data-on-MDT tests and fixes")
Signed-off-by: Mikhal Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/28020
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/lov/lov_object.c | 29 +++++++++++++++++------------
 1 file changed, 17 insertions(+), 12 deletions(-)

diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index 186b875..34575dc 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -431,8 +431,17 @@ static int lov_attr_get_dom(const struct lu_env *env, struct lov_object *lov,
 		return OST_LVB_GET_ERR(loi->loi_lvb.lvb_blocks);
 
 	cl_lvb2attr(attr, &loi->loi_lvb);
-	attr->cat_kms = attr->cat_size > loi->loi_kms ? attr->cat_size :
-							loi->loi_kms;
+
+	/* DoM component size can be bigger than stripe size after
+	 * client's setattr RPC, so do not count anything beyound
+	 * component end. Alternatively, check that limit on server
+	 * and do not allow size overflow there.
+	 */
+	if (attr->cat_size > lle->lle_extent.e_end)
+		attr->cat_size = lle->lle_extent.e_end;
+
+	attr->cat_kms = attr->cat_size;
+
 	dom->lo_dom_r0.lo_attr_valid = 1;
 	*lov_attr = attr;
 
@@ -508,7 +517,6 @@ static int lov_init_dom(const struct lu_env *env, struct lov_device *dev,
 	struct cl_device *mdcdev;
 	struct lov_oinfo *loi = NULL;
 	struct cl_object_conf *sconf = &lti->lti_stripe_conf;
-	struct inode *inode = conf->coc_inode;
 	u32 idx = 0;
 	int rc;
 
@@ -538,15 +546,6 @@ static int lov_init_dom(const struct lu_env *env, struct lov_device *dev,
 		return -ENOMEM;
 
 	fid_to_ostid(lu_object_fid(lov2lu(lov)), &loi->loi_oi);
-	/* Initialize lvb structure */
-	loi->loi_lvb.lvb_mtime = inode->i_mtime.tv_sec;
-	loi->loi_lvb.lvb_atime = inode->i_atime.tv_sec;
-	loi->loi_lvb.lvb_ctime = inode->i_ctime.tv_sec;
-	loi->loi_lvb.lvb_blocks = inode->i_blocks;
-	loi->loi_lvb.lvb_size = i_size_read(inode);
-	if (loi->loi_lvb.lvb_size > lsme->lsme_stripe_size)
-		loi->loi_lvb.lvb_size = lsme->lsme_stripe_size;
-	loi_kms_set(loi, loi->loi_lvb.lvb_size);
 
 	sconf->u.coc_oinfo = loi;
 again:
@@ -843,6 +842,12 @@ static int lov_attr_get_composite(const struct lu_env *env,
 		if (!lov_attr)
 			continue;
 
+		CDEBUG(D_INODE,
+		       "COMP ID #%i: s=%llu m=%llu a=%llu c=%llu b=%llu\n",
+		       index - 1, lov_attr->cat_size,
+		       lov_attr->cat_mtime, lov_attr->cat_atime,
+		       lov_attr->cat_ctime, lov_attr->cat_blocks);
+
 		/* merge results */
 		attr->cat_blocks += lov_attr->cat_blocks;
 		if (attr->cat_size < lov_attr->cat_size)
-- 
1.8.3.1
