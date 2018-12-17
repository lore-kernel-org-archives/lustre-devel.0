From: James Simmons <jsimmons@infradead.org>
Date: Mon, 17 Dec 2018 11:30:00 -0500
Subject: [lustre-devel] [PATCH 26/28] lustre: llite: return v1/v3 layout for
 legacy app
In-Reply-To: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
References: <1545064202-22483-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1545064202-22483-27-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Niu Yawei <yawei.niu@intel.com>

Legacy app such as ADIO fetches LOVEA by ioctl LL_IOC_LOV_GETSTRIPE
and treats file layout as v1/v3 blindly, we'd return a reasonable
v1/v3 in this case.

Signed-off-by: Niu Yawei <yawei.niu@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9490
Reviewed-on: https://review.whamcloud.com/27183
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/lov/lov_object.c |  2 +-
 drivers/staging/lustre/lustre/lov/lov_pack.c   | 72 +++++++++++++++++++++++---
 2 files changed, 67 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index e2eca01..ca18c1e 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -1615,7 +1615,7 @@ static int lov_object_getstripe(const struct lu_env *env, struct cl_object *obj,
 	if (!lsm)
 		return -ENODATA;
 
-	rc = lov_getstripe(cl2lov(obj), lsm, lum);
+	rc = lov_getstripe(env, cl2lov(obj), lsm, lum);
 	lov_lsm_put(lsm);
 	return rc;
 }
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index 32e4b33..10be119 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -315,12 +315,14 @@ struct lov_stripe_md *lov_unpackmd(struct lov_obd *lov, void *buf,
  * the maximum number of OST indices which will fit in the user buffer.
  * lmm_magic must be LOV_USER_MAGIC.
  */
-int lov_getstripe(struct lov_object *obj, struct lov_stripe_md *lsm,
-		  struct lov_user_md __user *lump)
+int lov_getstripe(const struct lu_env *env, struct lov_object *obj,
+		  struct lov_stripe_md *lsm, struct lov_user_md __user *lump)
 {
 	/* we use lov_user_md_v3 because it is larger than lov_user_md_v1 */
 	struct lov_mds_md *lmmk;
-	ssize_t lmm_size;
+	struct lov_user_md_v1 lum;
+	ssize_t lmm_size, lum_size = 0;
+	static bool printed;
 	size_t lmmk_size;
 	int rc = 0;
 
@@ -332,6 +334,13 @@ int lov_getstripe(struct lov_object *obj, struct lov_stripe_md *lsm,
 		goto out;
 	}
 
+	if (!printed) {
+		LCONSOLE_WARN("%s: using old ioctl(LL_IOC_LOV_GETSTRIPE) on " DFID ", use llapi_layout_get_by_path()\n",
+			      current->comm,
+			      PFID(&obj->lo_cl.co_lu.lo_header->loh_fid));
+		printed = true;
+	}
+
 	lmmk_size = lov_comp_md_size(lsm);
 	lmmk = kvzalloc(lmmk_size, GFP_KERNEL);
 	if (!lmmk) {
@@ -357,10 +366,61 @@ int lov_getstripe(struct lov_object *obj, struct lov_stripe_md *lsm,
 		}
 	}
 
-	if (copy_to_user(lump, lmmk, lmmk_size))
+	/* Legacy appication passes limited buffer, we need to figure out
+	 * the user buffer size by the passed in lmm_stripe_count.
+	 */
+	if (copy_from_user(&lum, lump, sizeof(struct lov_user_md_v1))) {
 		rc = -EFAULT;
-	else
-		rc = 0;
+		goto out_free;
+	}
+
+	if (lum.lmm_magic == LOV_USER_MAGIC_V1 ||
+	    lum.lmm_magic == LOV_USER_MAGIC_V3)
+		lum_size = lov_user_md_size(lum.lmm_stripe_count,
+					    lum.lmm_magic);
+
+	if (lum_size != 0) {
+		struct lov_mds_md *comp_md = lmmk;
+
+		/* Legacy app (ADIO for instance) treats the layout as V1/V3
+		 * blindly, we'd return a reasonable V1/V3 for them.
+		 */
+		if (lmmk->lmm_magic == LOV_MAGIC_COMP_V1) {
+			struct lov_comp_md_v1 *comp_v1;
+			struct cl_object *cl_obj;
+			struct cl_attr attr;
+			int i;
+
+			attr.cat_size = 0;
+			cl_obj = cl_object_top(&obj->lo_cl);
+			cl_object_attr_get(env, cl_obj, &attr);
+
+			/* return the last instantiated component if file size
+			 * is non-zero, otherwise, return the last component.
+			 */
+			comp_v1 = (struct lov_comp_md_v1 *)lmmk;
+			i = attr.cat_size == 0 ? comp_v1->lcm_entry_count : 0;
+			for (; i < comp_v1->lcm_entry_count; i++) {
+				if (!(comp_v1->lcm_entries[i].lcme_flags &
+				    LCME_FL_INIT))
+					break;
+			}
+			if (i > 0)
+				i--;
+			comp_md = (struct lov_mds_md *)((char *)comp_v1 +
+					comp_v1->lcm_entries[i].lcme_offset);
+		}
+		if (copy_to_user(lump, comp_md, lum_size)) {
+			rc = -EFAULT;
+			goto out_free;
+		}
+	} else {
+		if (copy_to_user(lump, lmmk, lmmk_size)) {
+			rc = -EFAULT;
+			goto out_free;
+		}
+	}
+
 out_free:
 	kvfree(lmmk);
 out:
-- 
1.8.3.1
