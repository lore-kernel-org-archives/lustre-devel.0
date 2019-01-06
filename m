From: James Simmons <jsimmons@infradead.org>
Date: Sun,  6 Jan 2019 17:14:12 -0500
Subject: [lustre-devel] [PATCH v2 17/33] lustre: clio: getstripe support
 comp layout
In-Reply-To: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
References: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1546812868-11794-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Niu Yawei <yawei.niu@intel.com>

{get/set}stripe support composite layout

Signed-off-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: Niu Yawei <yawei.niu@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8998
Reviewed-on: https://review.whamcloud.com/24851
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@gmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dir.c          |  33 +++-
 drivers/staging/lustre/lustre/llite/file.c         |  25 ++-
 .../staging/lustre/lustre/llite/llite_internal.h   |   2 +
 drivers/staging/lustre/lustre/llite/xattr.c        |  70 +++++----
 drivers/staging/lustre/lustre/lov/lov_internal.h   |  24 +++
 drivers/staging/lustre/lustre/lov/lov_object.c     |   3 +-
 drivers/staging/lustre/lustre/lov/lov_pack.c       | 172 ++++++++++++---------
 7 files changed, 203 insertions(+), 126 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 0a7330d..57acb7b 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -522,6 +522,15 @@ int ll_dir_setstripe(struct inode *inode, struct lov_user_md *lump,
 			lum_size = sizeof(struct lov_user_md_v3);
 			break;
 		}
+		case LOV_USER_MAGIC_COMP_V1: {
+			if (lump->lmm_magic !=
+			    cpu_to_le32(LOV_USER_MAGIC_COMP_V1))
+				lustre_swab_lov_comp_md_v1(
+					(struct lov_comp_md_v1 *)lump);
+			lum_size = le32_to_cpu(
+				((struct lov_comp_md_v1 *)lump)->lcm_size);
+			break;
+		}
 		case LMV_USER_MAGIC: {
 			if (lump->lmm_magic != cpu_to_le32(LMV_USER_MAGIC))
 				lustre_swab_lmv_user_md(
@@ -562,7 +571,9 @@ int ll_dir_setstripe(struct inode *inode, struct lov_user_md *lump,
 	 * LOV_USER_MAGIC_V3 have the same initial fields so we do not
 	 * need to make the distinction between the 2 versions
 	 */
-	if (set_default && mgc->u.cli.cl_mgc_mgsexp) {
+	if (set_default && mgc->u.cli.cl_mgc_mgsexp &&
+	    (!lump || le32_to_cpu(lump->lmm_magic) == LOV_USER_MAGIC_V1 ||
+	     le32_to_cpu(lump->lmm_magic) == LOV_USER_MAGIC_V3)) {
 		char *param = NULL;
 		char *buf;
 
@@ -577,23 +588,23 @@ int ll_dir_setstripe(struct inode *inode, struct lov_user_md *lump,
 		buf += strlen(buf);
 
 		/* Set root stripesize */
-		sprintf(buf, ".stripesize=%u",
-			lump ? le32_to_cpu(lump->lmm_stripe_size) : 0);
+		snprintf(buf, MGS_PARAM_MAXLEN, ".stripesize=%u",
+			 lump ? le32_to_cpu(lump->lmm_stripe_size) : 0);
 		rc = ll_send_mgc_param(mgc->u.cli.cl_mgc_mgsexp, param);
 		if (rc)
 			goto end;
 
 		/* Set root stripecount */
-		sprintf(buf, ".stripecount=%hd",
-			lump ? le16_to_cpu(lump->lmm_stripe_count) : 0);
+		snprintf(buf, MGS_PARAM_MAXLEN, ".stripecount=%hd",
+			 lump ? le16_to_cpu(lump->lmm_stripe_count) : 0);
 		rc = ll_send_mgc_param(mgc->u.cli.cl_mgc_mgsexp, param);
 		if (rc)
 			goto end;
 
 		/* Set root stripeoffset */
-		sprintf(buf, ".stripeoffset=%hd",
-			lump ? le16_to_cpu(lump->lmm_stripe_offset) :
-			(typeof(lump->lmm_stripe_offset))(-1));
+		snprintf(buf, MGS_PARAM_MAXLEN, ".stripeoffset=%hd",
+			 lump ? le16_to_cpu(lump->lmm_stripe_offset) :
+				(typeof(lump->lmm_stripe_offset))(-1));
 		rc = ll_send_mgc_param(mgc->u.cli.cl_mgc_mgsexp, param);
 
 end:
@@ -669,6 +680,10 @@ int ll_dir_getstripe(struct inode *inode, void **plmm, int *plmm_size,
 		if (cpu_to_le32(LOV_MAGIC) != LOV_MAGIC)
 			lustre_swab_lov_user_md_v3((struct lov_user_md_v3 *)lmm);
 		break;
+	case LOV_MAGIC_COMP_V1:
+		if (cpu_to_le32(LOV_MAGIC) != LOV_MAGIC)
+			lustre_swab_lov_comp_md_v1((struct lov_comp_md_v1 *)lmm);
+		break;
 	case LMV_MAGIC_V1:
 		if (cpu_to_le32(LMV_MAGIC) != LMV_MAGIC)
 			lustre_swab_lmv_mds_md((union lmv_mds_md *)lmm);
@@ -1217,6 +1232,8 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 
 		int set_default = 0;
 
+		BUILD_BUG_ON(sizeof(struct lov_user_md_v3) <=
+			     sizeof(struct lov_comp_md_v1));
 		LASSERT(sizeof(lumv3) == sizeof(*lumv3p));
 		LASSERT(sizeof(lumv3.lmm_objects[0]) ==
 			sizeof(lumv3p->lmm_objects[0]));
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index fae0111..24a0948 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -1430,8 +1430,9 @@ int ll_lov_getstripe_ea_info(struct inode *inode, const char *filename,
 
 	lmm = req_capsule_server_sized_get(&req->rq_pill, &RMF_MDT_MD, lmmsize);
 
-	if ((lmm->lmm_magic != cpu_to_le32(LOV_MAGIC_V1)) &&
-	    (lmm->lmm_magic != cpu_to_le32(LOV_MAGIC_V3))) {
+	if (lmm->lmm_magic != cpu_to_le32(LOV_MAGIC_V1) &&
+	    lmm->lmm_magic != cpu_to_le32(LOV_MAGIC_V3) &&
+	    lmm->lmm_magic != cpu_to_le32(LOV_MAGIC_COMP_V1)) {
 		rc = -EPROTO;
 		goto out;
 	}
@@ -1444,9 +1445,13 @@ int ll_lov_getstripe_ea_info(struct inode *inode, const char *filename,
 	if (cpu_to_le32(LOV_MAGIC) != LOV_MAGIC) {
 		int stripe_count;
 
-		stripe_count = le16_to_cpu(lmm->lmm_stripe_count);
-		if (le32_to_cpu(lmm->lmm_pattern) & LOV_PATTERN_F_RELEASED)
-			stripe_count = 0;
+		if (lmm->lmm_magic == cpu_to_le32(LOV_MAGIC_V1) ||
+		    lmm->lmm_magic == cpu_to_le32(LOV_MAGIC_V3)) {
+			stripe_count = le16_to_cpu(lmm->lmm_stripe_count);
+			if (le32_to_cpu(lmm->lmm_pattern) &
+			    LOV_PATTERN_F_RELEASED)
+				stripe_count = 0;
+		}
 
 		/* if function called for directory - we should
 		 * avoid swab not existent lsm objects
@@ -1463,6 +1468,8 @@ int ll_lov_getstripe_ea_info(struct inode *inode, const char *filename,
 				lustre_swab_lov_user_md_objects(
 				 ((struct lov_user_md_v3 *)lmm)->lmm_objects,
 				 stripe_count);
+		} else if (lmm->lmm_magic == cpu_to_le32(LOV_MAGIC_COMP_V1)) {
+			lustre_swab_lov_comp_md_v1((struct lov_comp_md_v1 *)lmm);
 		}
 	}
 
@@ -1534,14 +1541,6 @@ static int ll_lov_setstripe(struct inode *inode, struct file *file,
 	rc = ll_lov_setstripe_ea_info(inode, file->f_path.dentry, flags, klum,
 				      lum_size);
 	cl_lov_delay_create_clear(&file->f_flags);
-	if (rc == 0) {
-		__u32 gen;
-
-		put_user(0, &lum->lmm_stripe_count);
-
-		ll_layout_refresh(inode, &gen);
-		rc = ll_file_getstripe(inode, (struct lov_user_md __user *)arg);
-	}
 
 	kfree(klum);
 	return rc;
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 48424a4..e3f5450 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -927,6 +927,8 @@ static inline ssize_t ll_lov_user_md_size(const struct lov_user_md *lum)
 
 		return lov_user_md_size(lum->lmm_stripe_count,
 					LOV_USER_MAGIC_SPECIFIC);
+	case LOV_USER_MAGIC_COMP_V1:
+		return ((struct lov_comp_md_v1 *)lum)->lcm_size;
 	}
 	return -EINVAL;
 }
diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index aeaa04a..0670ed3 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -194,40 +194,53 @@ static int get_hsm_state(struct inode *inode, u32 *hus_states)
 
 static int ll_adjust_lum(struct inode *inode, struct lov_user_md *lump)
 {
+	struct lov_comp_md_v1 *comp_v1 = (struct lov_comp_md_v1 *)lump;
+	struct lov_user_md *v1 = lump;
+	bool need_clear_release = false;
+	bool release_checked = false;
+	bool is_composite = false;
+	u16 entry_count = 1;
 	int rc = 0;
+	int i;
 
 	if (!lump)
 		return 0;
 
-	/* Attributes that are saved via getxattr will always have
-	 * the stripe_offset as 0.  Instead, the MDS should be
-	 * allowed to pick the starting OST index.   b=17846
-	 */
-	if (lump->lmm_stripe_offset == 0)
-		lump->lmm_stripe_offset = -1;
+	if (lump->lmm_magic == LOV_USER_MAGIC_COMP_V1) {
+		entry_count = comp_v1->lcm_entry_count;
+		is_composite = true;
+        }
+
+	for (i = 0; i < entry_count; i++) {
+		if (lump->lmm_magic == LOV_USER_MAGIC_COMP_V1) {
+			void *ptr = comp_v1;
 
-	/* Avoid anyone directly setting the RELEASED flag. */
-	if (lump->lmm_pattern & LOV_PATTERN_F_RELEASED) {
-		/* Only if we have a released flag check if the file
-		 * was indeed archived.
+			ptr += comp_v1->lcm_entries[i].lcme_offset;
+			v1 = (struct lov_user_md *)ptr;
+		}
+
+		/* Attributes that are saved via getxattr will always have
+		 * the stripe_offset as 0.  Instead, the MDS should be
+		 * allowed to pick the starting OST index.   b=17846
 		 */
-		u32 state = HS_NONE;
-
-		rc = get_hsm_state(inode, &state);
-		if (rc)
-			return rc;
-
-		if (!(state & HS_ARCHIVED)) {
-			CDEBUG(D_VFSTRACE,
-			       "hus_states state = %x, pattern = %x\n",
-				state, lump->lmm_pattern);
-			/*
-			 * Here the state is: real file is not
-			 * archived but user is requesting to set
-			 * the RELEASED flag so we mask off the
-			 * released flag from the request
-			 */
-			lump->lmm_pattern ^= LOV_PATTERN_F_RELEASED;
+		if (!is_composite && v1->lmm_stripe_offset == 0)
+			v1->lmm_stripe_offset = -1;
+
+		/* Avoid anyone directly setting the RELEASED flag. */
+		if (v1->lmm_pattern & LOV_PATTERN_F_RELEASED) {
+			if (!release_checked) {
+				u32 state = HS_NONE;
+
+				rc = get_hsm_state(inode, &state);
+				if (rc)
+					return rc;
+
+				if (!(state & HS_ARCHIVED))
+					need_clear_release = true;
+				release_checked = true;
+			}
+			if (need_clear_release)
+				v1->lmm_pattern ^= LOV_PATTERN_F_RELEASED;
 		}
 	}
 
@@ -495,6 +508,9 @@ static ssize_t ll_getxattr_lov(struct inode *inode, void *buf, size_t buf_size)
 		 * recognizing layout gen as stripe offset when the
 		 * file is restored. See LU-2809.
 		 */
+		if (((struct lov_mds_md *)buf)->lmm_magic == LOV_MAGIC_COMP_V1)
+			goto out_env;
+
 		((struct lov_mds_md *)buf)->lmm_layout_gen = 0;
 out_env:
 		cl_env_put(env, &refcheck);
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index 29325ff..9c0a4f7 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -74,6 +74,30 @@ struct lov_stripe_md {
 	struct lov_stripe_md_entry *lsm_entries[];
 };
 
+static inline size_t lov_comp_md_size(const struct lov_stripe_md *lsm)
+{
+	struct lov_stripe_md_entry *lsme;
+	size_t size;
+	int entry;
+
+	if (lsm->lsm_magic == LOV_MAGIC_V1 || lsm->lsm_magic == LOV_MAGIC_V3)
+		return lov_mds_md_size(lsm->lsm_entries[0]->lsme_stripe_count,
+				       lsm->lsm_entries[0]->lsme_magic);
+
+	LASSERT(lsm->lsm_magic == LOV_MAGIC_COMP_V1);
+
+	size = sizeof(struct lov_comp_md_v1);
+	for (entry = 0; entry < lsm->lsm_entry_count; entry++) {
+		lsme = lsm->lsm_entries[entry];
+
+		size += sizeof(*lsme);
+		size += lov_mds_md_size(lsme->lsme_stripe_count,
+					lsme->lsme_magic);
+	}
+
+	return size;
+}
+
 static inline bool lsm_has_objects(struct lov_stripe_md *lsm)
 {
 	return lsm && !lsm->lsm_is_released;
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index a7d3068..8596c2f 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -1641,8 +1641,7 @@ static int lov_object_layout_get(const struct lu_env *env,
 		return 0;
 	}
 
-	cl->cl_size = lov_mds_md_size(lsm->lsm_entries[0]->lsme_stripe_count,
-				      lsm->lsm_magic);
+	cl->cl_size = lov_comp_md_size(lsm);
 	cl->cl_layout_gen = lsm->lsm_layout_gen;
 
 	rc = lov_lsm_pack(lsm, buf->lb_buf, buf->lb_len);
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index ba7c488..79d8a32 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -107,8 +107,8 @@ void lov_dump_lmm_v3(int level, struct lov_mds_md_v3 *lmm)
  * then return the size needed. If \a buf_size is too small then
  * return -ERANGE. Otherwise return the size of the result.
  */
-ssize_t lov_lsm_pack(const struct lov_stripe_md *lsm, void *buf,
-		     size_t buf_size)
+ssize_t lov_lsm_pack_v1v3(const struct lov_stripe_md *lsm, void *buf,
+			  size_t buf_size)
 {
 	struct lov_ost_data_v1 *lmm_objects;
 	struct lov_mds_md_v1 *lmmv1 = buf;
@@ -157,6 +157,88 @@ ssize_t lov_lsm_pack(const struct lov_stripe_md *lsm, void *buf,
 	return lmm_size;
 }
 
+ssize_t lov_lsm_pack(const struct lov_stripe_md *lsm, void *buf,
+		     size_t buf_size)
+{
+	struct lov_comp_md_v1 *lcmv1 = buf;
+	struct lov_comp_md_entry_v1 *lcme;
+	struct lov_ost_data_v1 *lmm_objects;
+	unsigned int offset;
+	unsigned int entry;
+	unsigned int size;
+	unsigned int i;
+	size_t lmm_size;
+
+	if (lsm->lsm_magic == LOV_MAGIC_V1 || lsm->lsm_magic == LOV_MAGIC_V3)
+		return lov_lsm_pack_v1v3(lsm, buf, buf_size);
+
+	lmm_size = lov_comp_md_size(lsm);
+	if (buf_size == 0)
+		return lmm_size;
+
+	if (buf_size < lmm_size)
+		return -ERANGE;
+
+	lcmv1->lcm_magic = cpu_to_le32(lsm->lsm_magic);
+	lcmv1->lcm_size = cpu_to_le32(lmm_size);
+	lcmv1->lcm_layout_gen = cpu_to_le32(lsm->lsm_layout_gen);
+	lcmv1->lcm_entry_count = cpu_to_le16(lsm->lsm_entry_count);
+
+	offset = sizeof(*lcmv1) + sizeof(*lcme) * lsm->lsm_entry_count;
+
+	for (entry = 0; entry < lsm->lsm_entry_count; entry++) {
+		struct lov_stripe_md_entry *lsme;
+		struct lov_mds_md *lmm;
+
+		lsme = lsm->lsm_entries[entry];
+		lcme = &lcmv1->lcm_entries[entry];
+
+		lcme->lcme_id = cpu_to_le32(lsme->lsme_id);
+		lcme->lcme_extent.e_start =
+			cpu_to_le64(lsme->lsme_extent.e_start);
+		lcme->lcme_extent.e_end =
+			cpu_to_le64(lsme->lsme_extent.e_end);
+		lcme->lcme_offset = cpu_to_le32(offset);
+
+		lmm = (struct lov_mds_md *)((char *)lcmv1 + offset);
+		lmm->lmm_magic = cpu_to_le32(lsme->lsme_magic);
+		/* lmm->lmm_oi not set */
+		lmm->lmm_pattern = cpu_to_le32(lsme->lsme_pattern);
+		lmm->lmm_stripe_size = cpu_to_le32(lsme->lsme_stripe_size);
+		lmm->lmm_stripe_count = cpu_to_le16(lsme->lsme_stripe_count);
+		lmm->lmm_layout_gen = cpu_to_le16(lsme->lsme_layout_gen);
+
+		if (lsme->lsme_magic == LOV_MAGIC_V3) {
+			struct lov_mds_md_v3 *lmmv3;
+
+			lmmv3 = (struct lov_mds_md_v3 *)lmm;
+
+			strlcpy(lmmv3->lmm_pool_name, lsme->lsme_pool_name,
+				sizeof(lmmv3->lmm_pool_name));
+			lmm_objects = lmmv3->lmm_objects;
+		} else {
+			lmm_objects = ((struct lov_mds_md_v1 *)lmm)->lmm_objects;
+		}
+
+		for (i = 0; i < lsme->lsme_stripe_count; i++) {
+			struct lov_oinfo *loi = lsme->lsme_oinfo[i];
+
+			ostid_cpu_to_le(&loi->loi_oi, &lmm_objects[i].l_ost_oi);
+			lmm_objects[i].l_ost_gen =
+				cpu_to_le32(loi->loi_ost_gen);
+			lmm_objects[i].l_ost_idx =
+				cpu_to_le32(loi->loi_ost_idx);
+		}
+
+		size = lov_mds_md_size(lsme->lsme_stripe_count,
+				       lsme->lsme_magic);
+		lcme->lcme_size = cpu_to_le32(size);
+		offset += size;
+	} /* for each layout component */
+
+	return lmm_size;
+}
+
 /* Find the max stripecount we should use */
 __u16 lov_get_stripecnt(struct lov_obd *lov, __u32 magic, __u16 stripe_count)
 {
@@ -227,53 +309,23 @@ int lov_getstripe(struct lov_object *obj, struct lov_stripe_md *lsm,
 		  struct lov_user_md __user *lump)
 {
 	/* we use lov_user_md_v3 because it is larger than lov_user_md_v1 */
-	struct lov_user_md_v3 lum;
 	struct lov_mds_md *lmmk;
-	u32 stripe_count;
 	ssize_t lmm_size;
 	size_t lmmk_size;
-	size_t lum_size;
-	int rc;
+	int rc = 0;
 
 	if (!lsm)
 		return -ENODATA;
 
-	if (lsm->lsm_magic != LOV_MAGIC_V1 && lsm->lsm_magic != LOV_MAGIC_V3) {
+	if (lsm->lsm_magic != LOV_MAGIC_V1 && lsm->lsm_magic != LOV_MAGIC_V3 &&
+	    lsm->lsm_magic != LOV_MAGIC_COMP_V1) {
 		CERROR("bad LSM MAGIC: 0x%08X != 0x%08X nor 0x%08X\n",
 		       lsm->lsm_magic, LOV_MAGIC_V1, LOV_MAGIC_V3);
 		rc = -EIO;
 		goto out;
 	}
 
-	if (!lsm->lsm_is_released)
-		stripe_count = lsm->lsm_entries[0]->lsme_stripe_count;
-	else
-		stripe_count = 0;
-
-	/* we only need the header part from user space to get lmm_magic and
-	 * lmm_stripe_count, (the header part is common to v1 and v3)
-	 */
-	lum_size = sizeof(struct lov_user_md_v1);
-	if (copy_from_user(&lum, lump, lum_size)) {
-		rc = -EFAULT;
-		goto out;
-	}
-	if (lum.lmm_magic != LOV_USER_MAGIC_V1 &&
-	    lum.lmm_magic != LOV_USER_MAGIC_V3 &&
-	    lum.lmm_magic != LOV_USER_MAGIC_SPECIFIC) {
-		rc = -EINVAL;
-		goto out;
-	}
-
-	if (lum.lmm_stripe_count && lum.lmm_stripe_count < stripe_count) {
-		/* Return right size of stripe to user */
-		lum.lmm_stripe_count = stripe_count;
-		rc = copy_to_user(lump, &lum, lum_size);
-		rc = -EOVERFLOW;
-		goto out;
-	}
-
-	lmmk_size = lov_mds_md_size(stripe_count, lsm->lsm_magic);
+	lmmk_size = lov_comp_md_size(lsm);
 	lmmk = kvzalloc(lmmk_size, GFP_KERNEL);
 	if (!lmmk) {
 		rc = -ENOMEM;
@@ -286,54 +338,22 @@ int lov_getstripe(struct lov_object *obj, struct lov_stripe_md *lsm,
 		goto out_free;
 	}
 
-	/* FIXME: Bug 1185 - copy fields properly when structs change */
-	/* struct lov_user_md_v3 and struct lov_mds_md_v3 must be the same */
-	BUILD_BUG_ON(sizeof(lum) != sizeof(struct lov_mds_md_v3));
-	BUILD_BUG_ON(sizeof(lum.lmm_objects[0]) != sizeof(lmmk->lmm_objects[0]));
-
-	if (cpu_to_le32(LOV_MAGIC) != LOV_MAGIC &&
-	    (lmmk->lmm_magic == cpu_to_le32(LOV_MAGIC_V1) ||
-	     lmmk->lmm_magic == cpu_to_le32(LOV_MAGIC_V3))) {
-		lustre_swab_lov_mds_md(lmmk);
-		lustre_swab_lov_user_md_objects(
+	if (cpu_to_le32(LOV_MAGIC) != LOV_MAGIC) {
+		if (lmmk->lmm_magic == cpu_to_le32(LOV_MAGIC_V1) ||
+		    lmmk->lmm_magic == cpu_to_le32(LOV_MAGIC_V3)) {
+			lustre_swab_lov_mds_md(lmmk);
+			lustre_swab_lov_user_md_objects(
 				(struct lov_user_ost_data *)lmmk->lmm_objects,
 				lmmk->lmm_stripe_count);
-	}
-
-	if (lum.lmm_magic == LOV_USER_MAGIC) {
-		/* User request for v1, we need skip lmm_pool_name */
-		if (lmmk->lmm_magic == LOV_MAGIC_V3) {
-			memmove(((struct lov_mds_md_v1 *)lmmk)->lmm_objects,
-				((struct lov_mds_md_v3 *)lmmk)->lmm_objects,
-				lmmk->lmm_stripe_count *
-				sizeof(struct lov_ost_data_v1));
-			lmm_size -= LOV_MAXPOOLNAME;
+		} else if (lmmk->lmm_magic == cpu_to_le32(LOV_MAGIC_COMP_V1)) {
+			lustre_swab_lov_comp_md_v1((struct lov_comp_md_v1 *)lmmk);
 		}
-	} else {
-		/* if v3 we just have to update the lum_size */
-		lum_size = sizeof(struct lov_user_md_v3);
 	}
 
-	/* User wasn't expecting this many OST entries */
-	if (lum.lmm_stripe_count == 0) {
-		lmm_size = lum_size;
-	} else if (lum.lmm_stripe_count < lmmk->lmm_stripe_count) {
-		rc = -EOVERFLOW;
-		goto out_free;
-	}
-	/*
-	 * Have a difference between lov_mds_md & lov_user_md.
-	 * So we have to re-order the data before copy to user.
-	 */
-	lum.lmm_stripe_count = lmmk->lmm_stripe_count;
-	lum.lmm_layout_gen = lmmk->lmm_layout_gen;
-	((struct lov_user_md *)lmmk)->lmm_layout_gen = lum.lmm_layout_gen;
-	((struct lov_user_md *)lmmk)->lmm_stripe_count = lum.lmm_stripe_count;
-	if (copy_to_user(lump, lmmk, lmm_size))
+	if (copy_to_user(lump, lmmk, lmmk_size))
 		rc = -EFAULT;
 	else
 		rc = 0;
-
 out_free:
 	kvfree(lmmk);
 out:
-- 
1.8.3.1
