From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:03 -0400
Subject: [lustre-devel] [PATCH 07/41] staging: lustre: llite: remove
	duplicate fiemap defines
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Bobi Jam <bobijam.xu@intel.com>, James Simmons <jsimmons@infradead.org>

From: Bobi Jam <bobijam.xu@intel.com>

 * replace struct ll_user_fiemap with struct fiemap
 * replace struct ll_fiemap_extent with struct fiemap_extent
 * remove kernel defined FIEMAP_EXTENT_* constants
 * remove kernel defined FIEMAP_FLAG_* flags
 * add member prefix for struct ll_fiemap_info_key

 * Add cl_object_operations::coo_fiemap().
 * Add cl_object_fiemap() to get FIEMAP mappings.

Signed-off-by: Bobi Jam <bobijam.xu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5823
Reviewed-on: http://review.whamcloud.com/12535
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6201
Reviewed-on: http://review.whamcloud.com/13608
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
Reviewed-by: Yang Sheng <yang.sheng@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |    9 +
 .../lustre/lustre/include/lustre/ll_fiemap.h       |   75 +---
 .../lustre/lustre/include/lustre/lustre_idl.h      |    8 +-
 .../lustre/lustre/include/lustre/lustre_user.h     |    1 -
 drivers/staging/lustre/lustre/llite/file.c         |  126 +----
 drivers/staging/lustre/lustre/lov/lov_obd.c        |  421 ----------------
 drivers/staging/lustre/lustre/lov/lov_object.c     |  504 +++++++++++++++++++-
 drivers/staging/lustre/lustre/obdclass/cl_object.c |   32 ++
 drivers/staging/lustre/lustre/osc/osc_object.c     |   91 ++++-
 drivers/staging/lustre/lustre/osc/osc_request.c    |   98 ----
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |    4 +-
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |  134 +++---
 12 files changed, 742 insertions(+), 761 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index bf93c1e..3af9aa3 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -400,6 +400,12 @@ struct cl_object_operations {
 	 */
 	int (*coo_getstripe)(const struct lu_env *env, struct cl_object *obj,
 			     struct lov_user_md __user *lum);
+	/**
+	 * Get FIEMAP mapping from the object.
+	 */
+	int (*coo_fiemap)(const struct lu_env *env, struct cl_object *obj,
+			  struct ll_fiemap_info_key *fmkey,
+			  struct fiemap *fiemap, size_t *buflen);
 };
 
 /**
@@ -2184,6 +2190,9 @@ int cl_object_prune(const struct lu_env *env, struct cl_object *obj);
 void cl_object_kill(const struct lu_env *env, struct cl_object *obj);
 int  cl_object_getstripe(const struct lu_env *env, struct cl_object *obj,
 			 struct lov_user_md __user *lum);
+int cl_object_fiemap(const struct lu_env *env, struct cl_object *obj,
+		     struct ll_fiemap_info_key *fmkey, struct fiemap *fiemap,
+		     size_t *buflen);
 
 /**
  * Returns true, iff \a o0 and \a o1 are slices of the same object.
diff --git a/drivers/staging/lustre/lustre/include/lustre/ll_fiemap.h b/drivers/staging/lustre/lustre/include/lustre/ll_fiemap.h
index c2340d6..b8ad555 100644
--- a/drivers/staging/lustre/lustre/include/lustre/ll_fiemap.h
+++ b/drivers/staging/lustre/lustre/include/lustre/ll_fiemap.h
@@ -41,79 +41,24 @@
 #ifndef _LUSTRE_FIEMAP_H
 #define _LUSTRE_FIEMAP_H
 
-struct ll_fiemap_extent {
-	__u64 fe_logical;  /* logical offset in bytes for the start of
-			    * the extent from the beginning of the file
-			    */
-	__u64 fe_physical; /* physical offset in bytes for the start
-			    * of the extent from the beginning of the disk
-			    */
-	__u64 fe_length;   /* length in bytes for this extent */
-	__u64 fe_reserved64[2];
-	__u32 fe_flags;    /* FIEMAP_EXTENT_* flags for this extent */
-	__u32 fe_device;   /* device number for this extent */
-	__u32 fe_reserved[2];
-};
-
-struct ll_user_fiemap {
-	__u64 fm_start;  /* logical offset (inclusive) at
-			  * which to start mapping (in)
-			  */
-	__u64 fm_length; /* logical length of mapping which
-			  * userspace wants (in)
-			  */
-	__u32 fm_flags;  /* FIEMAP_FLAG_* flags for request (in/out) */
-	__u32 fm_mapped_extents;/* number of extents that were mapped (out) */
-	__u32 fm_extent_count;  /* size of fm_extents array (in) */
-	__u32 fm_reserved;
-	struct ll_fiemap_extent fm_extents[0]; /* array of mapped extents (out) */
-};
-
-#define FIEMAP_MAX_OFFSET      (~0ULL)
+#ifndef __KERNEL__
+#include <stddef.h>
+#include <fiemap.h>
+#endif
 
-#define FIEMAP_FLAG_SYNC		0x00000001 /* sync file data before
-						    * map
-						    */
-#define FIEMAP_FLAG_XATTR		0x00000002 /* map extended attribute
-						    * tree
-						    */
-#define FIEMAP_EXTENT_LAST		0x00000001 /* Last extent in file. */
-#define FIEMAP_EXTENT_UNKNOWN		0x00000002 /* Data location unknown. */
-#define FIEMAP_EXTENT_DELALLOC		0x00000004 /* Location still pending.
-						    * Sets EXTENT_UNKNOWN.
-						    */
-#define FIEMAP_EXTENT_ENCODED		0x00000008 /* Data can not be read
-						    * while fs is unmounted
-						    */
-#define FIEMAP_EXTENT_DATA_ENCRYPTED	0x00000080 /* Data is encrypted by fs.
-						    * Sets EXTENT_NO_DIRECT.
-						    */
-#define FIEMAP_EXTENT_NOT_ALIGNED       0x00000100 /* Extent offsets may not be
-						    * block aligned.
-						    */
-#define FIEMAP_EXTENT_DATA_INLINE       0x00000200 /* Data mixed with metadata.
-						    * Sets EXTENT_NOT_ALIGNED.*/
-#define FIEMAP_EXTENT_DATA_TAIL		0x00000400 /* Multiple files in block.
-						    * Sets EXTENT_NOT_ALIGNED.
-						    */
-#define FIEMAP_EXTENT_UNWRITTEN		0x00000800 /* Space allocated, but
-						    * no data (i.e. zero).
-						    */
-#define FIEMAP_EXTENT_MERGED		0x00001000 /* File does not natively
-						    * support extents. Result
-						    * merged for efficiency.
-						    */
+/* XXX: We use fiemap_extent::fe_reserved[0] */
+#define fe_device	fe_reserved[0]
 
 static inline size_t fiemap_count_to_size(size_t extent_count)
 {
-	return (sizeof(struct ll_user_fiemap) + extent_count *
-					       sizeof(struct ll_fiemap_extent));
+	return sizeof(struct fiemap) + extent_count *
+				       sizeof(struct fiemap_extent);
 }
 
 static inline unsigned fiemap_size_to_count(size_t array_size)
 {
-	return ((array_size - sizeof(struct ll_user_fiemap)) /
-					       sizeof(struct ll_fiemap_extent));
+	return (array_size - sizeof(struct fiemap)) /
+		sizeof(struct fiemap_extent);
 }
 
 #define FIEMAP_FLAG_DEVICE_ORDER 0x40000000 /* return device ordered mapping */
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index d164545..4210716 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -3331,14 +3331,14 @@ struct ost_body {
 
 /* Key for FIEMAP to be used in get_info calls */
 struct ll_fiemap_info_key {
-	char    name[8];
-	struct  obdo oa;
-	struct  ll_user_fiemap fiemap;
+	char		lfik_name[8];
+	struct obdo	lfik_oa;
+	struct fiemap	lfik_fiemap;
 };
 
 void lustre_swab_ost_body(struct ost_body *b);
 void lustre_swab_ost_last_id(__u64 *id);
-void lustre_swab_fiemap(struct ll_user_fiemap *fiemap);
+void lustre_swab_fiemap(struct fiemap *fiemap);
 
 void lustre_swab_lov_user_md_v1(struct lov_user_md_v1 *lum);
 void lustre_swab_lov_user_md_v3(struct lov_user_md_v3 *lum);
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index 6fc9855..dced31f 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -82,7 +82,6 @@ typedef struct stat     lstat_t;
 #define FSFILT_IOC_SETVERSION	     _IOW('f', 4, long)
 #define FSFILT_IOC_GETVERSION_OLD	 _IOR('v', 1, long)
 #define FSFILT_IOC_SETVERSION_OLD	 _IOW('v', 2, long)
-#define FSFILT_IOC_FIEMAP		 _IOWR('f', 11, struct ll_user_fiemap)
 #endif
 
 /* FIEMAP flags supported by Lustre */
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index b2058c6..9ca933f 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -1545,15 +1545,17 @@ out:
 /**
  * Get size for inode for which FIEMAP mapping is requested.
  * Make the FIEMAP get_info call and returns the result.
+ *
+ * \param fiemap	kernel buffer to hold extens
+ * \param num_bytes	kernel buffer size
  */
-static int ll_do_fiemap(struct inode *inode, struct ll_user_fiemap *fiemap,
+static int ll_do_fiemap(struct inode *inode, struct fiemap *fiemap,
 			size_t num_bytes)
 {
-	struct obd_export *exp = ll_i2dtexp(inode);
-	struct lov_stripe_md *lsm = NULL;
-	struct ll_fiemap_info_key fm_key = { .name = KEY_FIEMAP, };
-	__u32 vallen = num_bytes;
-	int rc;
+	struct ll_fiemap_info_key fmkey = { .lfik_name = KEY_FIEMAP, };
+	struct lu_env *env;
+	int refcheck;
+	int rc = 0;
 
 	/* Checks for fiemap flags */
 	if (fiemap->fm_flags & ~LUSTRE_FIEMAP_FLAGS_COMPAT) {
@@ -1568,21 +1570,9 @@ static int ll_do_fiemap(struct inode *inode, struct ll_user_fiemap *fiemap,
 			return rc;
 	}
 
-	lsm = ccc_inode_lsm_get(inode);
-	if (!lsm)
-		return -ENOENT;
-
-	/* If the stripe_count > 1 and the application does not understand
-	 * DEVICE_ORDER flag, then it cannot interpret the extents correctly.
-	 */
-	if (lsm->lsm_stripe_count > 1 &&
-	    !(fiemap->fm_flags & FIEMAP_FLAG_DEVICE_ORDER)) {
-		rc = -EOPNOTSUPP;
-		goto out;
-	}
-
-	fm_key.oa.o_oi = lsm->lsm_oi;
-	fm_key.oa.o_valid = OBD_MD_FLID | OBD_MD_FLGROUP;
+	env = cl_env_get(&refcheck);
+	if (IS_ERR(env))
+		return PTR_ERR(env);
 
 	if (i_size_read(inode) == 0) {
 		rc = ll_glimpse_size(inode);
@@ -1590,24 +1580,23 @@ static int ll_do_fiemap(struct inode *inode, struct ll_user_fiemap *fiemap,
 			goto out;
 	}
 
-	obdo_from_inode(&fm_key.oa, inode, OBD_MD_FLSIZE);
-	obdo_set_parent_fid(&fm_key.oa, &ll_i2info(inode)->lli_fid);
+	fmkey.lfik_oa.o_valid = OBD_MD_FLID | OBD_MD_FLGROUP;
+	obdo_from_inode(&fmkey.lfik_oa, inode, OBD_MD_FLSIZE);
+	obdo_set_parent_fid(&fmkey.lfik_oa, &ll_i2info(inode)->lli_fid);
+
 	/* If filesize is 0, then there would be no objects for mapping */
-	if (fm_key.oa.o_size == 0) {
+	if (fmkey.lfik_oa.o_size == 0) {
 		fiemap->fm_mapped_extents = 0;
 		rc = 0;
 		goto out;
 	}
 
-	memcpy(&fm_key.fiemap, fiemap, sizeof(*fiemap));
-
-	rc = obd_get_info(NULL, exp, sizeof(fm_key), &fm_key, &vallen,
-			  fiemap, lsm);
-	if (rc)
-		CERROR("obd_get_info failed: rc = %d\n", rc);
+	memcpy(&fmkey.lfik_fiemap, fiemap, sizeof(*fiemap));
 
+	rc = cl_object_fiemap(env, ll_i2info(inode)->lli_clob,
+			      &fmkey, fiemap, &num_bytes);
 out:
-	ccc_inode_lsm_put(inode, lsm);
+	cl_env_put(env, &refcheck);
 	return rc;
 }
 
@@ -1655,68 +1644,6 @@ gf_free:
 	return rc;
 }
 
-static int ll_ioctl_fiemap(struct inode *inode, unsigned long arg)
-{
-	struct ll_user_fiemap *fiemap_s;
-	size_t num_bytes, ret_bytes;
-	unsigned int extent_count;
-	int rc = 0;
-
-	/* Get the extent count so we can calculate the size of
-	 * required fiemap buffer
-	 */
-	if (get_user(extent_count,
-		     &((struct ll_user_fiemap __user *)arg)->fm_extent_count))
-		return -EFAULT;
-
-	if (extent_count >=
-	    (SIZE_MAX - sizeof(*fiemap_s)) / sizeof(struct ll_fiemap_extent))
-		return -EINVAL;
-	num_bytes = sizeof(*fiemap_s) + (extent_count *
-					 sizeof(struct ll_fiemap_extent));
-
-	fiemap_s = libcfs_kvzalloc(num_bytes, GFP_NOFS);
-	if (!fiemap_s)
-		return -ENOMEM;
-
-	/* get the fiemap value */
-	if (copy_from_user(fiemap_s, (struct ll_user_fiemap __user *)arg,
-			   sizeof(*fiemap_s))) {
-		rc = -EFAULT;
-		goto error;
-	}
-
-	/* If fm_extent_count is non-zero, read the first extent since
-	 * it is used to calculate end_offset and device from previous
-	 * fiemap call.
-	 */
-	if (extent_count) {
-		if (copy_from_user(&fiemap_s->fm_extents[0],
-				   (char __user *)arg + sizeof(*fiemap_s),
-				   sizeof(struct ll_fiemap_extent))) {
-			rc = -EFAULT;
-			goto error;
-		}
-	}
-
-	rc = ll_do_fiemap(inode, fiemap_s, num_bytes);
-	if (rc)
-		goto error;
-
-	ret_bytes = sizeof(struct ll_user_fiemap);
-
-	if (extent_count != 0)
-		ret_bytes += (fiemap_s->fm_mapped_extents *
-				 sizeof(struct ll_fiemap_extent));
-
-	if (copy_to_user((void __user *)arg, fiemap_s, ret_bytes))
-		rc = -EFAULT;
-
-error:
-	kvfree(fiemap_s);
-	return rc;
-}
-
 /*
  * Read the data_version for inode.
  *
@@ -2158,8 +2085,6 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	case LL_IOC_LOV_GETSTRIPE:
 		return ll_file_getstripe(inode,
 					 (struct lov_user_md __user *)arg);
-	case FSFILT_IOC_FIEMAP:
-		return ll_ioctl_fiemap(inode, arg);
 	case FSFILT_IOC_GETFLAGS:
 	case FSFILT_IOC_SETFLAGS:
 		return ll_iocontrol(inode, file, cmd, arg);
@@ -3061,13 +2986,12 @@ static int ll_fiemap(struct inode *inode, struct fiemap_extent_info *fieinfo,
 {
 	int rc;
 	size_t num_bytes;
-	struct ll_user_fiemap *fiemap;
+	struct fiemap *fiemap;
 	unsigned int extent_count = fieinfo->fi_extents_max;
 
 	num_bytes = sizeof(*fiemap) + (extent_count *
-				       sizeof(struct ll_fiemap_extent));
+				       sizeof(struct fiemap_extent));
 	fiemap = libcfs_kvzalloc(num_bytes, GFP_NOFS);
-
 	if (!fiemap)
 		return -ENOMEM;
 
@@ -3075,9 +2999,10 @@ static int ll_fiemap(struct inode *inode, struct fiemap_extent_info *fieinfo,
 	fiemap->fm_extent_count = fieinfo->fi_extents_max;
 	fiemap->fm_start = start;
 	fiemap->fm_length = len;
+
 	if (extent_count > 0 &&
 	    copy_from_user(&fiemap->fm_extents[0], fieinfo->fi_extents_start,
-			   sizeof(struct ll_fiemap_extent)) != 0) {
+			   sizeof(struct fiemap_extent))) {
 		rc = -EFAULT;
 		goto out;
 	}
@@ -3089,11 +3014,10 @@ static int ll_fiemap(struct inode *inode, struct fiemap_extent_info *fieinfo,
 	if (extent_count > 0 &&
 	    copy_to_user(fieinfo->fi_extents_start, &fiemap->fm_extents[0],
 			 fiemap->fm_mapped_extents *
-			 sizeof(struct ll_fiemap_extent)) != 0) {
+			 sizeof(struct fiemap_extent))) {
 		rc = -EFAULT;
 		goto out;
 	}
-
 out:
 	kvfree(fiemap);
 	return rc;
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index b23016f..02c7087 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -51,7 +51,6 @@
 #include "../include/lprocfs_status.h"
 #include "../include/lustre_param.h"
 #include "../include/cl_object.h"
-#include "../include/lustre/ll_fiemap.h"
 #include "../include/lustre_fid.h"
 
 #include "lov_internal.h"
@@ -1391,423 +1390,6 @@ static int lov_iocontrol(unsigned int cmd, struct obd_export *exp, int len,
 	return rc;
 }
 
-#define FIEMAP_BUFFER_SIZE 4096
-
-/**
- * Non-zero fe_logical indicates that this is a continuation FIEMAP
- * call. The local end offset and the device are sent in the first
- * fm_extent. This function calculates the stripe number from the index.
- * This function returns a stripe_no on which mapping is to be restarted.
- *
- * This function returns fm_end_offset which is the in-OST offset at which
- * mapping should be restarted. If fm_end_offset=0 is returned then caller
- * will re-calculate proper offset in next stripe.
- * Note that the first extent is passed to lov_get_info via the value field.
- *
- * \param fiemap fiemap request header
- * \param lsm striping information for the file
- * \param fm_start logical start of mapping
- * \param fm_end logical end of mapping
- * \param start_stripe starting stripe will be returned in this
- */
-static u64 fiemap_calc_fm_end_offset(struct ll_user_fiemap *fiemap,
-				     struct lov_stripe_md *lsm, u64 fm_start,
-				     u64 fm_end, int *start_stripe)
-{
-	u64 local_end = fiemap->fm_extents[0].fe_logical;
-	u64 lun_start, lun_end;
-	u64 fm_end_offset;
-	int stripe_no = -1, i;
-
-	if (fiemap->fm_extent_count == 0 ||
-	    fiemap->fm_extents[0].fe_logical == 0)
-		return 0;
-
-	/* Find out stripe_no from ost_index saved in the fe_device */
-	for (i = 0; i < lsm->lsm_stripe_count; i++) {
-		struct lov_oinfo *oinfo = lsm->lsm_oinfo[i];
-
-		if (lov_oinfo_is_dummy(oinfo))
-			continue;
-
-		if (oinfo->loi_ost_idx == fiemap->fm_extents[0].fe_device) {
-			stripe_no = i;
-			break;
-		}
-	}
-	if (stripe_no == -1)
-		return -EINVAL;
-
-	/* If we have finished mapping on previous device, shift logical
-	 * offset to start of next device
-	 */
-	if ((lov_stripe_intersects(lsm, stripe_no, fm_start, fm_end,
-				   &lun_start, &lun_end)) != 0 &&
-				   local_end < lun_end) {
-		fm_end_offset = local_end;
-		*start_stripe = stripe_no;
-	} else {
-		/* This is a special value to indicate that caller should
-		 * calculate offset in next stripe.
-		 */
-		fm_end_offset = 0;
-		*start_stripe = (stripe_no + 1) % lsm->lsm_stripe_count;
-	}
-
-	return fm_end_offset;
-}
-
-/**
- * We calculate on which OST the mapping will end. If the length of mapping
- * is greater than (stripe_size * stripe_count) then the last_stripe will
- * will be one just before start_stripe. Else we check if the mapping
- * intersects each OST and find last_stripe.
- * This function returns the last_stripe and also sets the stripe_count
- * over which the mapping is spread
- *
- * \param lsm striping information for the file
- * \param fm_start logical start of mapping
- * \param fm_end logical end of mapping
- * \param start_stripe starting stripe of the mapping
- * \param stripe_count the number of stripes across which to map is returned
- *
- * \retval last_stripe return the last stripe of the mapping
- */
-static int fiemap_calc_last_stripe(struct lov_stripe_md *lsm, u64 fm_start,
-				   u64 fm_end, int start_stripe,
-				   int *stripe_count)
-{
-	int last_stripe;
-	u64 obd_start, obd_end;
-	int i, j;
-
-	if (fm_end - fm_start > lsm->lsm_stripe_size * lsm->lsm_stripe_count) {
-		last_stripe = start_stripe < 1 ? lsm->lsm_stripe_count - 1 :
-							      start_stripe - 1;
-		*stripe_count = lsm->lsm_stripe_count;
-	} else {
-		for (j = 0, i = start_stripe; j < lsm->lsm_stripe_count;
-		     i = (i + 1) % lsm->lsm_stripe_count, j++) {
-			if ((lov_stripe_intersects(lsm, i, fm_start, fm_end,
-						   &obd_start, &obd_end)) == 0)
-				break;
-		}
-		*stripe_count = j;
-		last_stripe = (start_stripe + j - 1) % lsm->lsm_stripe_count;
-	}
-
-	return last_stripe;
-}
-
-/**
- * Set fe_device and copy extents from local buffer into main return buffer.
- *
- * \param fiemap fiemap request header
- * \param lcl_fm_ext array of local fiemap extents to be copied
- * \param ost_index OST index to be written into the fm_device field for each
-		    extent
- * \param ext_count number of extents to be copied
- * \param current_extent where to start copying in main extent array
- */
-static void fiemap_prepare_and_copy_exts(struct ll_user_fiemap *fiemap,
-					 struct ll_fiemap_extent *lcl_fm_ext,
-					 int ost_index, unsigned int ext_count,
-					 int current_extent)
-{
-	char *to;
-	int ext;
-
-	for (ext = 0; ext < ext_count; ext++) {
-		lcl_fm_ext[ext].fe_device = ost_index;
-		lcl_fm_ext[ext].fe_flags |= FIEMAP_EXTENT_NET;
-	}
-
-	/* Copy fm_extent's from fm_local to return buffer */
-	to = (char *)fiemap + fiemap_count_to_size(current_extent);
-	memcpy(to, lcl_fm_ext, ext_count * sizeof(struct ll_fiemap_extent));
-}
-
-/**
- * Break down the FIEMAP request and send appropriate calls to individual OSTs.
- * This also handles the restarting of FIEMAP calls in case mapping overflows
- * the available number of extents in single call.
- */
-static int lov_fiemap(struct lov_obd *lov, __u32 keylen, void *key,
-		      __u32 *vallen, void *val, struct lov_stripe_md *lsm)
-{
-	struct ll_fiemap_info_key *fm_key = key;
-	struct ll_user_fiemap *fiemap = val;
-	struct ll_user_fiemap *fm_local = NULL;
-	struct ll_fiemap_extent *lcl_fm_ext;
-	int count_local;
-	unsigned int get_num_extents = 0;
-	int ost_index = 0, actual_start_stripe, start_stripe;
-	u64 fm_start, fm_end, fm_length, fm_end_offset;
-	u64 curr_loc;
-	int current_extent = 0, rc = 0, i;
-	/* Whether have we collected enough extents */
-	bool enough = false;
-	int ost_eof = 0; /* EOF for object */
-	int ost_done = 0; /* done with required mapping for this OST? */
-	int last_stripe;
-	int cur_stripe = 0, cur_stripe_wrap = 0, stripe_count;
-	unsigned int buffer_size = FIEMAP_BUFFER_SIZE;
-
-	if (!lsm_has_objects(lsm)) {
-		if (lsm && lsm_is_released(lsm) && (fm_key->fiemap.fm_start <
-		    fm_key->oa.o_size)) {
-			/*
-			 * released file, return a minimal FIEMAP if
-			 * request fits in file-size.
-			 */
-			fiemap->fm_mapped_extents = 1;
-			fiemap->fm_extents[0].fe_logical =
-					fm_key->fiemap.fm_start;
-			if (fm_key->fiemap.fm_start + fm_key->fiemap.fm_length <
-			    fm_key->oa.o_size) {
-				fiemap->fm_extents[0].fe_length =
-					fm_key->fiemap.fm_length;
-			} else {
-				fiemap->fm_extents[0].fe_length =
-					fm_key->oa.o_size - fm_key->fiemap.fm_start;
-				fiemap->fm_extents[0].fe_flags |=
-						(FIEMAP_EXTENT_UNKNOWN |
-						 FIEMAP_EXTENT_LAST);
-			}
-		}
-		rc = 0;
-		goto out;
-	}
-
-	if (fiemap_count_to_size(fm_key->fiemap.fm_extent_count) < buffer_size)
-		buffer_size = fiemap_count_to_size(fm_key->fiemap.fm_extent_count);
-
-	fm_local = libcfs_kvzalloc(buffer_size, GFP_NOFS);
-	if (!fm_local) {
-		rc = -ENOMEM;
-		goto out;
-	}
-	lcl_fm_ext = &fm_local->fm_extents[0];
-
-	count_local = fiemap_size_to_count(buffer_size);
-
-	memcpy(fiemap, &fm_key->fiemap, sizeof(*fiemap));
-	fm_start = fiemap->fm_start;
-	fm_length = fiemap->fm_length;
-	/* Calculate start stripe, last stripe and length of mapping */
-	start_stripe = lov_stripe_number(lsm, fm_start);
-	actual_start_stripe = start_stripe;
-	fm_end = (fm_length == ~0ULL ? fm_key->oa.o_size :
-						fm_start + fm_length - 1);
-	/* If fm_length != ~0ULL but fm_start+fm_length-1 exceeds file size */
-	if (fm_end > fm_key->oa.o_size)
-		fm_end = fm_key->oa.o_size;
-
-	last_stripe = fiemap_calc_last_stripe(lsm, fm_start, fm_end,
-					      actual_start_stripe,
-					      &stripe_count);
-
-	fm_end_offset = fiemap_calc_fm_end_offset(fiemap, lsm, fm_start,
-						  fm_end, &start_stripe);
-	if (fm_end_offset == -EINVAL) {
-		rc = -EINVAL;
-		goto out;
-	}
-
-	if (fiemap_count_to_size(fiemap->fm_extent_count) > *vallen)
-		fiemap->fm_extent_count = fiemap_size_to_count(*vallen);
-	if (fiemap->fm_extent_count == 0) {
-		get_num_extents = 1;
-		count_local = 0;
-	}
-	/* Check each stripe */
-	for (cur_stripe = start_stripe, i = 0; i < stripe_count;
-	     i++, cur_stripe = (cur_stripe + 1) % lsm->lsm_stripe_count) {
-		u64 req_fm_len; /* Stores length of required mapping */
-		u64 len_mapped_single_call;
-		u64 lun_start, lun_end, obd_object_end;
-		unsigned int ext_count;
-
-		cur_stripe_wrap = cur_stripe;
-
-		/* Find out range of mapping on this stripe */
-		if ((lov_stripe_intersects(lsm, cur_stripe, fm_start, fm_end,
-					   &lun_start, &obd_object_end)) == 0)
-			continue;
-
-		if (lov_oinfo_is_dummy(lsm->lsm_oinfo[cur_stripe])) {
-			rc = -EIO;
-			goto out;
-		}
-
-		/* If this is a continuation FIEMAP call and we are on
-		 * starting stripe then lun_start needs to be set to
-		 * fm_end_offset
-		 */
-		if (fm_end_offset != 0 && cur_stripe == start_stripe)
-			lun_start = fm_end_offset;
-
-		if (fm_length != ~0ULL) {
-			/* Handle fm_start + fm_length overflow */
-			if (fm_start + fm_length < fm_start)
-				fm_length = ~0ULL - fm_start;
-			lun_end = lov_size_to_stripe(lsm, fm_start + fm_length,
-						     cur_stripe);
-		} else {
-			lun_end = ~0ULL;
-		}
-
-		if (lun_start == lun_end)
-			continue;
-
-		req_fm_len = obd_object_end - lun_start;
-		fm_local->fm_length = 0;
-		len_mapped_single_call = 0;
-
-		/* If the output buffer is very large and the objects have many
-		 * extents we may need to loop on a single OST repeatedly
-		 */
-		ost_eof = 0;
-		ost_done = 0;
-		do {
-			if (get_num_extents == 0) {
-				/* Don't get too many extents. */
-				if (current_extent + count_local >
-				    fiemap->fm_extent_count)
-					count_local = fiemap->fm_extent_count -
-								 current_extent;
-			}
-
-			lun_start += len_mapped_single_call;
-			fm_local->fm_length = req_fm_len - len_mapped_single_call;
-			req_fm_len = fm_local->fm_length;
-			fm_local->fm_extent_count = enough ? 1 : count_local;
-			fm_local->fm_mapped_extents = 0;
-			fm_local->fm_flags = fiemap->fm_flags;
-
-			fm_key->oa.o_oi = lsm->lsm_oinfo[cur_stripe]->loi_oi;
-			ost_index = lsm->lsm_oinfo[cur_stripe]->loi_ost_idx;
-
-			if (ost_index < 0 ||
-			    ost_index >= lov->desc.ld_tgt_count) {
-				rc = -EINVAL;
-				goto out;
-			}
-
-			/* If OST is inactive, return extent with UNKNOWN flag */
-			if (!lov->lov_tgts[ost_index]->ltd_active) {
-				fm_local->fm_flags |= FIEMAP_EXTENT_LAST;
-				fm_local->fm_mapped_extents = 1;
-
-				lcl_fm_ext[0].fe_logical = lun_start;
-				lcl_fm_ext[0].fe_length = obd_object_end -
-								      lun_start;
-				lcl_fm_ext[0].fe_flags |= FIEMAP_EXTENT_UNKNOWN;
-
-				goto inactive_tgt;
-			}
-
-			fm_local->fm_start = lun_start;
-			fm_local->fm_flags &= ~FIEMAP_FLAG_DEVICE_ORDER;
-			memcpy(&fm_key->fiemap, fm_local, sizeof(*fm_local));
-			*vallen = fiemap_count_to_size(fm_local->fm_extent_count);
-			rc = obd_get_info(NULL,
-					  lov->lov_tgts[ost_index]->ltd_exp,
-					  keylen, key, vallen, fm_local, lsm);
-			if (rc != 0)
-				goto out;
-
-inactive_tgt:
-			ext_count = fm_local->fm_mapped_extents;
-			if (ext_count == 0) {
-				ost_done = 1;
-				/* If last stripe has hole at the end,
-				 * then we need to return
-				 */
-				if (cur_stripe_wrap == last_stripe) {
-					fiemap->fm_mapped_extents = 0;
-					goto finish;
-				}
-				break;
-			} else if (enough) {
-				/*
-				 * We've collected enough extents and there are
-				 * more extents after it.
-				 */
-				goto finish;
-			}
-
-			/* If we just need num of extents then go to next device */
-			if (get_num_extents) {
-				current_extent += ext_count;
-				break;
-			}
-
-			len_mapped_single_call =
-				lcl_fm_ext[ext_count - 1].fe_logical -
-				lun_start + lcl_fm_ext[ext_count - 1].fe_length;
-
-			/* Have we finished mapping on this device? */
-			if (req_fm_len <= len_mapped_single_call)
-				ost_done = 1;
-
-			/* Clear the EXTENT_LAST flag which can be present on
-			 * last extent
-			 */
-			if (lcl_fm_ext[ext_count - 1].fe_flags &
-			    FIEMAP_EXTENT_LAST)
-				lcl_fm_ext[ext_count - 1].fe_flags &=
-							    ~FIEMAP_EXTENT_LAST;
-
-			curr_loc = lov_stripe_size(lsm,
-					lcl_fm_ext[ext_count - 1].fe_logical +
-					lcl_fm_ext[ext_count - 1].fe_length,
-					cur_stripe);
-			if (curr_loc >= fm_key->oa.o_size)
-				ost_eof = 1;
-
-			fiemap_prepare_and_copy_exts(fiemap, lcl_fm_ext,
-						     ost_index, ext_count,
-						     current_extent);
-
-			current_extent += ext_count;
-
-			/* Ran out of available extents? */
-			if (current_extent >= fiemap->fm_extent_count)
-				enough = true;
-		} while (ost_done == 0 && ost_eof == 0);
-
-		if (cur_stripe_wrap == last_stripe)
-			goto finish;
-	}
-
-finish:
-	/* Indicate that we are returning device offsets unless file just has
-	 * single stripe
-	 */
-	if (lsm->lsm_stripe_count > 1)
-		fiemap->fm_flags |= FIEMAP_FLAG_DEVICE_ORDER;
-
-	if (get_num_extents)
-		goto skip_last_device_calc;
-
-	/* Check if we have reached the last stripe and whether mapping for that
-	 * stripe is done.
-	 */
-	if (cur_stripe_wrap == last_stripe) {
-		if (ost_done || ost_eof)
-			fiemap->fm_extents[current_extent - 1].fe_flags |=
-							     FIEMAP_EXTENT_LAST;
-	}
-
-skip_last_device_calc:
-	fiemap->fm_mapped_extents = current_extent;
-
-out:
-	kvfree(fm_local);
-	return rc;
-}
-
 static int lov_get_info(const struct lu_env *env, struct obd_export *exp,
 			__u32 keylen, void *key, __u32 *vallen, void *val,
 			struct lov_stripe_md *lsm)
@@ -1827,9 +1409,6 @@ static int lov_get_info(const struct lu_env *env, struct obd_export *exp,
 
 		rc = 0;
 		goto out;
-	} else if (KEY_IS(KEY_FIEMAP)) {
-		rc = lov_fiemap(lov, keylen, key, vallen, val, lsm);
-		goto out;
 	} else if (KEY_IS(KEY_TGT_COUNT)) {
 		*((int *)val) = lov->desc.ld_tgt_count;
 		rc = 0;
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 52f7363..07bef44 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -313,6 +313,40 @@ static int lov_init_released(const struct lu_env *env,
 	return 0;
 }
 
+static struct cl_object *lov_find_subobj(const struct lu_env *env,
+					 struct lov_object *lov,
+					 struct lov_stripe_md *lsm,
+					 int stripe_idx)
+{
+	struct lov_device *dev = lu2lov_dev(lov2lu(lov)->lo_dev);
+	struct lov_oinfo *oinfo = lsm->lsm_oinfo[stripe_idx];
+	struct lov_thread_info *lti = lov_env_info(env);
+	struct lu_fid *ofid = &lti->lti_fid;
+	struct cl_device *subdev;
+	struct cl_object *result;
+	int ost_idx;
+	int rc;
+
+	if (lov->lo_type != LLT_RAID0) {
+		result = NULL;
+		goto out;
+	}
+
+	ost_idx = oinfo->loi_ost_idx;
+	rc = ostid_to_fid(ofid, &oinfo->loi_oi, ost_idx);
+	if (rc) {
+		result = NULL;
+		goto out;
+	}
+
+	subdev = lovsub2cl_dev(dev->ld_target[ost_idx]);
+	result = lov_sub_find(env, subdev, ofid, NULL);
+out:
+	if (!result)
+		result = ERR_PTR(-EINVAL);
+	return result;
+}
+
 static int lov_delete_empty(const struct lu_env *env, struct lov_object *lov,
 			    union lov_layout_state *state)
 {
@@ -911,6 +945,473 @@ int lov_lock_init(const struct lu_env *env, struct cl_object *obj,
 				    io);
 }
 
+/**
+ * We calculate on which OST the mapping will end. If the length of mapping
+ * is greater than (stripe_size * stripe_count) then the last_stripe will
+ * will be one just before start_stripe. Else we check if the mapping
+ * intersects each OST and find last_stripe.
+ * This function returns the last_stripe and also sets the stripe_count
+ * over which the mapping is spread
+ *
+ * \param lsm [in]		striping information for the file
+ * \param fm_start [in]		logical start of mapping
+ * \param fm_end [in]		logical end of mapping
+ * \param start_stripe [in]	starting stripe of the mapping
+ * \param stripe_count [out]	the number of stripes across which to map is
+ *				returned
+ *
+ * \retval last_stripe		return the last stripe of the mapping
+ */
+static int fiemap_calc_last_stripe(struct lov_stripe_md *lsm,
+				   loff_t fm_start, loff_t fm_end,
+				   int start_stripe, int *stripe_count)
+{
+	int last_stripe;
+	loff_t obd_start;
+	loff_t obd_end;
+	int i, j;
+
+	if (fm_end - fm_start > lsm->lsm_stripe_size * lsm->lsm_stripe_count) {
+		last_stripe = (start_stripe < 1 ? lsm->lsm_stripe_count - 1 :
+			       start_stripe - 1);
+		*stripe_count = lsm->lsm_stripe_count;
+	} else {
+		for (j = 0, i = start_stripe; j < lsm->lsm_stripe_count;
+		     i = (i + 1) % lsm->lsm_stripe_count, j++) {
+			if (!(lov_stripe_intersects(lsm, i, fm_start, fm_end,
+						    &obd_start, &obd_end)))
+				break;
+		}
+		*stripe_count = j;
+		last_stripe = (start_stripe + j - 1) % lsm->lsm_stripe_count;
+	}
+
+	return last_stripe;
+}
+
+/**
+ * Set fe_device and copy extents from local buffer into main return buffer.
+ *
+ * \param fiemap [out]		fiemap to hold all extents
+ * \param lcl_fm_ext [in]	array of fiemap extents get from OSC layer
+ * \param ost_index [in]	OST index to be written into the fm_device
+ *				field for each extent
+ * \param ext_count [in]	number of extents to be copied
+ * \param current_extent [in]	where to start copying in the extent array
+ */
+static void fiemap_prepare_and_copy_exts(struct fiemap *fiemap,
+					 struct fiemap_extent *lcl_fm_ext,
+					 int ost_index, unsigned int ext_count,
+					 int current_extent)
+{
+	unsigned int ext;
+	char *to;
+
+	for (ext = 0; ext < ext_count; ext++) {
+		lcl_fm_ext[ext].fe_device = ost_index;
+		lcl_fm_ext[ext].fe_flags |= FIEMAP_EXTENT_NET;
+	}
+
+	/* Copy fm_extent's from fm_local to return buffer */
+	to = (char *)fiemap + fiemap_count_to_size(current_extent);
+	memcpy(to, lcl_fm_ext, ext_count * sizeof(struct fiemap_extent));
+}
+
+#define FIEMAP_BUFFER_SIZE 4096
+
+/**
+ * Non-zero fe_logical indicates that this is a continuation FIEMAP
+ * call. The local end offset and the device are sent in the first
+ * fm_extent. This function calculates the stripe number from the index.
+ * This function returns a stripe_no on which mapping is to be restarted.
+ *
+ * This function returns fm_end_offset which is the in-OST offset@which
+ * mapping should be restarted. If fm_end_offset=0 is returned then caller
+ * will re-calculate proper offset in next stripe.
+ * Note that the first extent is passed to lov_get_info via the value field.
+ *
+ * \param fiemap [in]		fiemap request header
+ * \param lsm [in]		striping information for the file
+ * \param fm_start [in]		logical start of mapping
+ * \param fm_end [in]		logical end of mapping
+ * \param start_stripe [out]	starting stripe will be returned in this
+ */
+static loff_t fiemap_calc_fm_end_offset(struct fiemap *fiemap,
+					struct lov_stripe_md *lsm,
+					loff_t fm_start, loff_t fm_end,
+					int *start_stripe)
+{
+	loff_t local_end = fiemap->fm_extents[0].fe_logical;
+	loff_t lun_start, lun_end;
+	loff_t fm_end_offset;
+	int stripe_no = -1;
+	int i;
+
+	if (!fiemap->fm_extent_count || !fiemap->fm_extents[0].fe_logical)
+		return 0;
+
+	/* Find out stripe_no from ost_index saved in the fe_device */
+	for (i = 0; i < lsm->lsm_stripe_count; i++) {
+		struct lov_oinfo *oinfo = lsm->lsm_oinfo[i];
+
+		if (lov_oinfo_is_dummy(oinfo))
+			continue;
+
+		if (oinfo->loi_ost_idx == fiemap->fm_extents[0].fe_device) {
+			stripe_no = i;
+			break;
+		}
+	}
+
+	if (stripe_no == -1)
+		return -EINVAL;
+
+	/*
+	 * If we have finished mapping on previous device, shift logical
+	 * offset to start of next device
+	 */
+	if (lov_stripe_intersects(lsm, stripe_no, fm_start, fm_end,
+				  &lun_start, &lun_end) &&
+	    local_end < lun_end) {
+		fm_end_offset = local_end;
+		*start_stripe = stripe_no;
+	} else {
+		/* This is a special value to indicate that caller should
+		 * calculate offset in next stripe.
+		 */
+		fm_end_offset = 0;
+		*start_stripe = (stripe_no + 1) % lsm->lsm_stripe_count;
+	}
+
+	return fm_end_offset;
+}
+
+/**
+ * Break down the FIEMAP request and send appropriate calls to individual OSTs.
+ * This also handles the restarting of FIEMAP calls in case mapping overflows
+ * the available number of extents in single call.
+ *
+ * \param env [in]		lustre environment
+ * \param obj [in]		file object
+ * \param fmkey [in]		fiemap request header and other info
+ * \param fiemap [out]		fiemap buffer holding retrived map extents
+ * \param buflen [in/out]	max buffer length of @fiemap, when iterate
+ *				each OST, it is used to limit max map needed
+ * \retval 0	success
+ * \retval < 0	error
+ */
+static int lov_object_fiemap(const struct lu_env *env, struct cl_object *obj,
+			     struct ll_fiemap_info_key *fmkey,
+			     struct fiemap *fiemap, size_t *buflen)
+{
+	struct lov_obd *lov = lu2lov_dev(obj->co_lu.lo_dev)->ld_lov;
+	unsigned int buffer_size = FIEMAP_BUFFER_SIZE;
+	struct fiemap_extent *lcl_fm_ext;
+	struct cl_object *subobj = NULL;
+	struct fiemap *fm_local = NULL;
+	struct lov_stripe_md *lsm;
+	loff_t fm_start;
+	loff_t fm_end;
+	loff_t fm_length;
+	loff_t fm_end_offset;
+	int count_local;
+	int ost_index = 0;
+	int start_stripe;
+	int current_extent = 0;
+	int rc = 0;
+	int last_stripe;
+	int cur_stripe = 0;
+	int cur_stripe_wrap = 0;
+	int stripe_count;
+	/* Whether have we collected enough extents */
+	bool enough = false;
+	/* EOF for object */
+	bool ost_eof = false;
+	/* done with required mapping for this OST? */
+	bool ost_done = false;
+
+	lsm = lov_lsm_addref(cl2lov(obj));
+	if (!lsm)
+		return -ENODATA;
+
+	/**
+	 * If the stripe_count > 1 and the application does not understand
+	 * DEVICE_ORDER flag, it cannot interpret the extents correctly.
+	 */
+	if (lsm->lsm_stripe_count > 1 &&
+	    !(fiemap->fm_flags & FIEMAP_FLAG_DEVICE_ORDER)) {
+		rc = -ENOTSUPP;
+		goto out;
+	}
+
+	if (lsm_is_released(lsm)) {
+		if (fiemap->fm_start < fmkey->lfik_oa.o_size) {
+			/**
+			 * released file, return a minimal FIEMAP if
+			 * request fits in file-size.
+			 */
+			fiemap->fm_mapped_extents = 1;
+			fiemap->fm_extents[0].fe_logical = fiemap->fm_start;
+			if (fiemap->fm_start + fiemap->fm_length <
+			    fmkey->lfik_oa.o_size)
+				fiemap->fm_extents[0].fe_length =
+					 fiemap->fm_length;
+			else
+				fiemap->fm_extents[0].fe_length =
+					fmkey->lfik_oa.o_size -
+					fiemap->fm_start;
+			fiemap->fm_extents[0].fe_flags |=
+				FIEMAP_EXTENT_UNKNOWN | FIEMAP_EXTENT_LAST;
+		}
+		rc = 0;
+		goto out;
+	}
+
+	if (fiemap_count_to_size(fiemap->fm_extent_count) < buffer_size)
+		buffer_size = fiemap_count_to_size(fiemap->fm_extent_count);
+
+	fm_local = libcfs_kvzalloc(buffer_size, GFP_NOFS);
+	if (!fm_local) {
+		rc = -ENOMEM;
+		goto out;
+	}
+	lcl_fm_ext = &fm_local->fm_extents[0];
+	count_local = fiemap_size_to_count(buffer_size);
+
+	fm_start = fiemap->fm_start;
+	fm_length = fiemap->fm_length;
+	/* Calculate start stripe, last stripe and length of mapping */
+	start_stripe = lov_stripe_number(lsm, fm_start);
+	fm_end = (fm_length == ~0ULL) ? fmkey->lfik_oa.o_size :
+					fm_start + fm_length - 1;
+	/* If fm_length != ~0ULL but fm_start_fm_length-1 exceeds file size */
+	if (fm_end > fmkey->lfik_oa.o_size)
+		fm_end = fmkey->lfik_oa.o_size;
+
+	last_stripe = fiemap_calc_last_stripe(lsm, fm_start, fm_end,
+					      start_stripe, &stripe_count);
+	fm_end_offset = fiemap_calc_fm_end_offset(fiemap, lsm, fm_start, fm_end,
+						  &start_stripe);
+	if (fm_end_offset == -EINVAL) {
+		rc = -EINVAL;
+		goto out;
+	}
+
+	/**
+	 * Requested extent count exceeds the fiemap buffer size, shrink our
+	 * ambition.
+	 */
+	if (fiemap_count_to_size(fiemap->fm_extent_count) > *buflen)
+		fiemap->fm_extent_count = fiemap_size_to_count(*buflen);
+	if (!fiemap->fm_extent_count)
+		count_local = 0;
+
+	/* Check each stripe */
+	for (cur_stripe = start_stripe; stripe_count > 0;
+	     --stripe_count,
+	     cur_stripe = (cur_stripe + 1) % lsm->lsm_stripe_count) {
+		loff_t req_fm_len; /* Stores length of required mapping */
+		loff_t len_mapped_single_call;
+		loff_t lun_start;
+		loff_t lun_end;
+		loff_t obd_object_end;
+		unsigned int ext_count;
+
+		cur_stripe_wrap = cur_stripe;
+
+		/* Find out range of mapping on this stripe */
+		if (!(lov_stripe_intersects(lsm, cur_stripe, fm_start, fm_end,
+					    &lun_start, &obd_object_end)))
+			continue;
+
+		if (lov_oinfo_is_dummy(lsm->lsm_oinfo[cur_stripe])) {
+			rc = -EIO;
+			goto out;
+		}
+
+		/*
+		 * If this is a continuation FIEMAP call and we are on
+		 * starting stripe then lun_start needs to be set to
+		 * fm_end_offset
+		 */
+		if (fm_end_offset && cur_stripe == start_stripe)
+			lun_start = fm_end_offset;
+
+		if (fm_length != ~0ULL) {
+			/* Handle fm_start + fm_length overflow */
+			if (fm_start + fm_length < fm_start)
+				fm_length = ~0ULL - fm_start;
+			lun_end = lov_size_to_stripe(lsm, fm_start + fm_length,
+						     cur_stripe);
+		} else {
+			lun_end = ~0ULL;
+		}
+
+		if (lun_start == lun_end)
+			continue;
+
+		req_fm_len = obd_object_end - lun_start;
+		fm_local->fm_length = 0;
+		len_mapped_single_call = 0;
+
+		/* find lobsub object */
+		subobj = lov_find_subobj(env, cl2lov(obj), lsm,
+					 cur_stripe);
+		if (IS_ERR(subobj)) {
+			rc = PTR_ERR(subobj);
+			goto out;
+		}
+		/*
+		 * If the output buffer is very large and the objects have many
+		 * extents we may need to loop on a single OST repeatedly
+		 */
+		ost_eof = false;
+		ost_done = false;
+		do {
+			if (fiemap->fm_extent_count > 0) {
+				/* Don't get too many extents. */
+				if (current_extent + count_local >
+				    fiemap->fm_extent_count)
+					count_local = fiemap->fm_extent_count -
+						      current_extent;
+			}
+
+			lun_start += len_mapped_single_call;
+			fm_local->fm_length = req_fm_len -
+					      len_mapped_single_call;
+			req_fm_len = fm_local->fm_length;
+			fm_local->fm_extent_count = enough ? 1 : count_local;
+			fm_local->fm_mapped_extents = 0;
+			fm_local->fm_flags = fiemap->fm_flags;
+
+			ost_index = lsm->lsm_oinfo[cur_stripe]->loi_ost_idx;
+
+			if (ost_index < 0 ||
+			    ost_index >= lov->desc.ld_tgt_count) {
+				rc = -EINVAL;
+				goto obj_put;
+			}
+			/*
+			 * If OST is inactive, return extent with UNKNOWN
+			 * flag.
+			 */
+			if (!lov->lov_tgts[ost_index]->ltd_active) {
+				fm_local->fm_flags |= FIEMAP_EXTENT_LAST;
+				fm_local->fm_mapped_extents = 1;
+
+				lcl_fm_ext[0].fe_logical = lun_start;
+				lcl_fm_ext[0].fe_length = obd_object_end -
+							  lun_start;
+				lcl_fm_ext[0].fe_flags |= FIEMAP_EXTENT_UNKNOWN;
+
+				goto inactive_tgt;
+			}
+
+			fm_local->fm_start = lun_start;
+			fm_local->fm_flags &= ~FIEMAP_FLAG_DEVICE_ORDER;
+			memcpy(&fmkey->lfik_fiemap, fm_local, sizeof(*fm_local));
+			*buflen = fiemap_count_to_size(fm_local->fm_extent_count);
+
+			rc = cl_object_fiemap(env, subobj, fmkey, fm_local,
+					      buflen);
+			if (rc)
+				goto obj_put;
+inactive_tgt:
+			ext_count = fm_local->fm_mapped_extents;
+			if (!ext_count) {
+				ost_done = true;
+				/*
+				 * If last stripe has hold at the end,
+				 * we need to return
+				 */
+				if (cur_stripe_wrap == last_stripe) {
+					fiemap->fm_mapped_extents = 0;
+					goto finish;
+				}
+				break;
+			} else if (enough) {
+				/*
+				 * We've collected enough extents and there are
+				 * more extents after it.
+				 */
+				goto finish;
+			}
+
+			/* If we just need num of extents, got to next device */
+			if (!fiemap->fm_extent_count) {
+				current_extent += ext_count;
+				break;
+			}
+
+			/* prepare to copy retrived map extents */
+			len_mapped_single_call =
+				lcl_fm_ext[ext_count - 1].fe_logical -
+				lun_start + lcl_fm_ext[ext_count - 1].fe_length;
+
+			/* Have we finished mapping on this device? */
+			if (req_fm_len <= len_mapped_single_call)
+				ost_done = true;
+
+			/*
+			 * Clear the EXTENT_LAST flag which can be present on
+			 * the last extent
+			 */
+			if (lcl_fm_ext[ext_count - 1].fe_flags &
+			    FIEMAP_EXTENT_LAST)
+				lcl_fm_ext[ext_count - 1].fe_flags &=
+					~FIEMAP_EXTENT_LAST;
+
+			if (lov_stripe_size(lsm,
+					    lcl_fm_ext[ext_count - 1].fe_logical +
+					    lcl_fm_ext[ext_count - 1].fe_length,
+					    cur_stripe) >= fmkey->lfik_oa.o_size)
+				ost_eof = true;
+
+			fiemap_prepare_and_copy_exts(fiemap, lcl_fm_ext,
+						     ost_index, ext_count,
+						     current_extent);
+			current_extent += ext_count;
+
+			/* Ran out of available extents? */
+			if (current_extent >= fiemap->fm_extent_count)
+				enough = true;
+		} while (!ost_done && !ost_eof);
+
+		cl_object_put(env, subobj);
+		subobj = NULL;
+
+		if (cur_stripe_wrap == last_stripe)
+			goto finish;
+	} /* for each stripe */
+finish:
+	/*
+	 * Indicate that we are returning device offsets unless file just has
+	 * single stripe
+	 */
+	if (lsm->lsm_stripe_count > 1)
+		fiemap->fm_flags |= FIEMAP_FLAG_DEVICE_ORDER;
+
+	if (!fiemap->fm_extent_count)
+		goto skip_last_device_calc;
+
+	/*
+	 * Check if we have reached the last stripe and whether mapping for that
+	 * stripe is done.
+	 */
+	if ((cur_stripe_wrap == last_stripe) && (ost_done || ost_eof))
+		fiemap->fm_extents[current_extent - 1].fe_flags |=
+							FIEMAP_EXTENT_LAST;
+skip_last_device_calc:
+	fiemap->fm_mapped_extents = current_extent;
+obj_put:
+	if (subobj)
+		cl_object_put(env, subobj);
+out:
+	kvfree(fm_local);
+	lov_lsm_put(obj, lsm);
+	return rc;
+}
+
 static int lov_object_getstripe(const struct lu_env *env, struct cl_object *obj,
 				struct lov_user_md __user *lum)
 {
@@ -934,7 +1435,8 @@ static const struct cl_object_operations lov_ops = {
 	.coo_attr_get  = lov_attr_get,
 	.coo_attr_update = lov_attr_update,
 	.coo_conf_set  = lov_conf_set,
-	.coo_getstripe = lov_object_getstripe
+	.coo_getstripe = lov_object_getstripe,
+	.coo_fiemap	 = lov_object_fiemap,
 };
 
 static const struct lu_object_operations lov_lu_obj_ops = {
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index 3199dd4..4ad2ee5 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -343,6 +343,38 @@ int cl_object_getstripe(const struct lu_env *env, struct cl_object *obj,
 EXPORT_SYMBOL(cl_object_getstripe);
 
 /**
+ * Get fiemap extents from file object.
+ *
+ * \param env [in]	lustre environment
+ * \param obj [in]	file object
+ * \param key [in]	fiemap request argument
+ * \param fiemap [out]	fiemap extents mapping retrived
+ * \param buflen [in]	max buffer length of @fiemap
+ *
+ * \retval 0	success
+ * \retval < 0	error
+ */
+int cl_object_fiemap(const struct lu_env *env, struct cl_object *obj,
+		     struct ll_fiemap_info_key *key,
+		     struct fiemap *fiemap, size_t *buflen)
+{
+	struct lu_object_header *top;
+	int result = 0;
+
+	top = obj->co_lu.lo_header;
+	list_for_each_entry(obj, &top->loh_layers, co_lu.lo_linkage) {
+		if (obj->co_ops->coo_fiemap) {
+			result = obj->co_ops->coo_fiemap(env, obj, key, fiemap,
+							 buflen);
+			if (result)
+				break;
+		}
+	}
+	return result;
+}
+EXPORT_SYMBOL(cl_object_fiemap);
+
+/**
  * Helper function removing all object locks, and marking object for
  * deletion. All object pages must have been deleted at this point.
  *
diff --git a/drivers/staging/lustre/lustre/osc/osc_object.c b/drivers/staging/lustre/lustre/osc/osc_object.c
index aae3a2d..dc0c173 100644
--- a/drivers/staging/lustre/lustre/osc/osc_object.c
+++ b/drivers/staging/lustre/lustre/osc/osc_object.c
@@ -218,6 +218,94 @@ static int osc_object_prune(const struct lu_env *env, struct cl_object *obj)
 	return 0;
 }
 
+static int osc_object_fiemap(const struct lu_env *env, struct cl_object *obj,
+			     struct ll_fiemap_info_key *fmkey,
+			     struct fiemap *fiemap, size_t *buflen)
+{
+	struct obd_export *exp = osc_export(cl2osc(obj));
+	ldlm_policy_data_t policy;
+	struct ptlrpc_request *req;
+	struct lustre_handle lockh;
+	struct ldlm_res_id resid;
+	enum ldlm_mode mode = 0;
+	struct fiemap *reply;
+	char *tmp;
+	int rc;
+
+	fmkey->lfik_oa.o_oi = cl2osc(obj)->oo_oinfo->loi_oi;
+	if (!(fmkey->lfik_fiemap.fm_flags & FIEMAP_FLAG_SYNC))
+		goto skip_locking;
+
+	policy.l_extent.start = fmkey->lfik_fiemap.fm_start & PAGE_MASK;
+
+	if (OBD_OBJECT_EOF - fmkey->lfik_fiemap.fm_length <=
+	    fmkey->lfik_fiemap.fm_start + PAGE_SIZE - 1)
+		policy.l_extent.end = OBD_OBJECT_EOF;
+	else
+		policy.l_extent.end = (fmkey->lfik_fiemap.fm_start +
+				       fmkey->lfik_fiemap.fm_length +
+				       PAGE_SIZE - 1) & PAGE_MASK;
+
+	ostid_build_res_name(&fmkey->lfik_oa.o_oi, &resid);
+	mode = ldlm_lock_match(exp->exp_obd->obd_namespace,
+			       LDLM_FL_BLOCK_GRANTED | LDLM_FL_LVB_READY,
+			       &resid, LDLM_EXTENT, &policy,
+			       LCK_PR | LCK_PW, &lockh, 0);
+	if (mode) { /* lock is cached on client */
+		if (mode != LCK_PR) {
+			ldlm_lock_addref(&lockh, LCK_PR);
+			ldlm_lock_decref(&lockh, LCK_PW);
+		}
+	} else { /* no cached lock, needs acquire lock on server side */
+		fmkey->lfik_oa.o_valid |= OBD_MD_FLFLAGS;
+		fmkey->lfik_oa.o_flags |= OBD_FL_SRVLOCK;
+	}
+
+skip_locking:
+	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
+				   &RQF_OST_GET_INFO_FIEMAP);
+	if (!req) {
+		rc = -ENOMEM;
+		goto drop_lock;
+	}
+
+	req_capsule_set_size(&req->rq_pill, &RMF_FIEMAP_KEY, RCL_CLIENT,
+			     sizeof(*fmkey));
+	req_capsule_set_size(&req->rq_pill, &RMF_FIEMAP_VAL, RCL_CLIENT,
+			     *buflen);
+	req_capsule_set_size(&req->rq_pill, &RMF_FIEMAP_VAL, RCL_SERVER,
+			     *buflen);
+
+	rc = ptlrpc_request_pack(req, LUSTRE_OST_VERSION, OST_GET_INFO);
+	if (rc) {
+		ptlrpc_request_free(req);
+		goto drop_lock;
+	}
+	tmp = req_capsule_client_get(&req->rq_pill, &RMF_FIEMAP_KEY);
+	memcpy(tmp, fmkey, sizeof(*fmkey));
+	tmp = req_capsule_client_get(&req->rq_pill, &RMF_FIEMAP_VAL);
+	memcpy(tmp, fiemap, *buflen);
+	ptlrpc_request_set_replen(req);
+
+	rc = ptlrpc_queue_wait(req);
+	if (rc)
+		goto fini_req;
+
+	reply = req_capsule_server_get(&req->rq_pill, &RMF_FIEMAP_VAL);
+	if (!reply) {
+		rc = -EPROTO;
+		goto fini_req;
+	}
+
+	memcpy(fiemap, reply, *buflen);
+fini_req:
+	ptlrpc_req_finished(req);
+drop_lock:
+	if (mode)
+		ldlm_lock_decref(&lockh, LCK_PR);
+	return rc;
+}
+
 void osc_object_set_contended(struct osc_object *obj)
 {
 	obj->oo_contention_time = cfs_time_current();
@@ -263,7 +351,8 @@ static const struct cl_object_operations osc_ops = {
 	.coo_attr_get  = osc_attr_get,
 	.coo_attr_update = osc_attr_update,
 	.coo_glimpse   = osc_object_glimpse,
-	.coo_prune     = osc_object_prune
+	.coo_prune	 = osc_object_prune,
+	.coo_fiemap	 = osc_object_fiemap,
 };
 
 static const struct lu_object_operations osc_lu_obj_ops = {
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 749781f..963a485 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -2543,103 +2543,6 @@ out:
 	return err;
 }
 
-static int osc_get_info(const struct lu_env *env, struct obd_export *exp,
-			u32 keylen, void *key, __u32 *vallen, void *val,
-			struct lov_stripe_md *lsm)
-{
-	if (!vallen || !val)
-		return -EFAULT;
-
-	if (KEY_IS(KEY_FIEMAP)) {
-		struct ll_fiemap_info_key *fm_key = key;
-		struct ldlm_res_id res_id;
-		ldlm_policy_data_t policy;
-		struct lustre_handle lockh;
-		enum ldlm_mode mode = 0;
-		struct ptlrpc_request *req;
-		struct ll_user_fiemap *reply;
-		char *tmp;
-		int rc;
-
-		if (!(fm_key->fiemap.fm_flags & FIEMAP_FLAG_SYNC))
-			goto skip_locking;
-
-		policy.l_extent.start = fm_key->fiemap.fm_start &
-						PAGE_MASK;
-
-		if (OBD_OBJECT_EOF - fm_key->fiemap.fm_length <=
-		    fm_key->fiemap.fm_start + PAGE_SIZE - 1)
-			policy.l_extent.end = OBD_OBJECT_EOF;
-		else
-			policy.l_extent.end = (fm_key->fiemap.fm_start +
-				fm_key->fiemap.fm_length +
-				PAGE_SIZE - 1) & PAGE_MASK;
-
-		ostid_build_res_name(&fm_key->oa.o_oi, &res_id);
-		mode = ldlm_lock_match(exp->exp_obd->obd_namespace,
-				       LDLM_FL_BLOCK_GRANTED |
-				       LDLM_FL_LVB_READY,
-				       &res_id, LDLM_EXTENT, &policy,
-				       LCK_PR | LCK_PW, &lockh, 0);
-		if (mode) { /* lock is cached on client */
-			if (mode != LCK_PR) {
-				ldlm_lock_addref(&lockh, LCK_PR);
-				ldlm_lock_decref(&lockh, LCK_PW);
-			}
-		} else { /* no cached lock, needs acquire lock on server side */
-			fm_key->oa.o_valid |= OBD_MD_FLFLAGS;
-			fm_key->oa.o_flags |= OBD_FL_SRVLOCK;
-		}
-
-skip_locking:
-		req = ptlrpc_request_alloc(class_exp2cliimp(exp),
-					   &RQF_OST_GET_INFO_FIEMAP);
-		if (!req) {
-			rc = -ENOMEM;
-			goto drop_lock;
-		}
-
-		req_capsule_set_size(&req->rq_pill, &RMF_FIEMAP_KEY,
-				     RCL_CLIENT, keylen);
-		req_capsule_set_size(&req->rq_pill, &RMF_FIEMAP_VAL,
-				     RCL_CLIENT, *vallen);
-		req_capsule_set_size(&req->rq_pill, &RMF_FIEMAP_VAL,
-				     RCL_SERVER, *vallen);
-
-		rc = ptlrpc_request_pack(req, LUSTRE_OST_VERSION, OST_GET_INFO);
-		if (rc) {
-			ptlrpc_request_free(req);
-			goto drop_lock;
-		}
-
-		tmp = req_capsule_client_get(&req->rq_pill, &RMF_FIEMAP_KEY);
-		memcpy(tmp, key, keylen);
-		tmp = req_capsule_client_get(&req->rq_pill, &RMF_FIEMAP_VAL);
-		memcpy(tmp, val, *vallen);
-
-		ptlrpc_request_set_replen(req);
-		rc = ptlrpc_queue_wait(req);
-		if (rc)
-			goto fini_req;
-
-		reply = req_capsule_server_get(&req->rq_pill, &RMF_FIEMAP_VAL);
-		if (!reply) {
-			rc = -EPROTO;
-			goto fini_req;
-		}
-
-		memcpy(val, reply, *vallen);
-fini_req:
-		ptlrpc_req_finished(req);
-drop_lock:
-		if (mode)
-			ldlm_lock_decref(&lockh, LCK_PR);
-		return rc;
-	}
-
-	return -EINVAL;
-}
-
 static int osc_set_info_async(const struct lu_env *env, struct obd_export *exp,
 			      u32 keylen, void *key, u32 vallen,
 			      void *val, struct ptlrpc_request_set *set)
@@ -3112,7 +3015,6 @@ static struct obd_ops osc_obd_ops = {
 	.setattr        = osc_setattr,
 	.setattr_async  = osc_setattr_async,
 	.iocontrol      = osc_iocontrol,
-	.get_info       = osc_get_info,
 	.set_info_async = osc_set_info_async,
 	.import_event   = osc_import_event,
 	.process_config = osc_process_config,
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 8717685..36b86ae 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -1772,7 +1772,7 @@ void lustre_swab_fid2path(struct getinfo_fid2path *gf)
 }
 EXPORT_SYMBOL(lustre_swab_fid2path);
 
-static void lustre_swab_fiemap_extent(struct ll_fiemap_extent *fm_extent)
+static void lustre_swab_fiemap_extent(struct fiemap_extent *fm_extent)
 {
 	__swab64s(&fm_extent->fe_logical);
 	__swab64s(&fm_extent->fe_physical);
@@ -1781,7 +1781,7 @@ static void lustre_swab_fiemap_extent(struct ll_fiemap_extent *fm_extent)
 	__swab32s(&fm_extent->fe_device);
 }
 
-void lustre_swab_fiemap(struct ll_user_fiemap *fiemap)
+void lustre_swab_fiemap(struct fiemap *fiemap)
 {
 	__u32 i;
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index e5945e2..cb89bf2 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -3520,21 +3520,21 @@ void lustre_assert_wire_constants(void)
 	LASSERTF((int)sizeof(((struct llogd_conn_body *)0)->lgdc_ctxt_idx) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct llogd_conn_body *)0)->lgdc_ctxt_idx));
 
-	/* Checks for struct ll_fiemap_info_key */
+	/* Checks for struct fiemap_info_key */
 	LASSERTF((int)sizeof(struct ll_fiemap_info_key) == 248, "found %lld\n",
 		 (long long)(int)sizeof(struct ll_fiemap_info_key));
-	LASSERTF((int)offsetof(struct ll_fiemap_info_key, name[8]) == 8, "found %lld\n",
-		 (long long)(int)offsetof(struct ll_fiemap_info_key, name[8]));
-	LASSERTF((int)sizeof(((struct ll_fiemap_info_key *)0)->name[8]) == 1, "found %lld\n",
-		 (long long)(int)sizeof(((struct ll_fiemap_info_key *)0)->name[8]));
-	LASSERTF((int)offsetof(struct ll_fiemap_info_key, oa) == 8, "found %lld\n",
-		 (long long)(int)offsetof(struct ll_fiemap_info_key, oa));
-	LASSERTF((int)sizeof(((struct ll_fiemap_info_key *)0)->oa) == 208, "found %lld\n",
-		 (long long)(int)sizeof(((struct ll_fiemap_info_key *)0)->oa));
-	LASSERTF((int)offsetof(struct ll_fiemap_info_key, fiemap) == 216, "found %lld\n",
-		 (long long)(int)offsetof(struct ll_fiemap_info_key, fiemap));
-	LASSERTF((int)sizeof(((struct ll_fiemap_info_key *)0)->fiemap) == 32, "found %lld\n",
-		 (long long)(int)sizeof(((struct ll_fiemap_info_key *)0)->fiemap));
+	LASSERTF((int)offsetof(struct ll_fiemap_info_key, lfik_name[8]) == 8, "found %lld\n",
+		 (long long)(int)offsetof(struct ll_fiemap_info_key, lfik_name[8]));
+	LASSERTF((int)sizeof(((struct ll_fiemap_info_key *)0)->lfik_name[8]) == 1, "found %lld\n",
+		 (long long)(int)sizeof(((struct ll_fiemap_info_key *)0)->lfik_name[8]));
+	LASSERTF((int)offsetof(struct ll_fiemap_info_key, lfik_oa) == 8, "found %lld\n",
+		 (long long)(int)offsetof(struct ll_fiemap_info_key, lfik_oa));
+	LASSERTF((int)sizeof(((struct ll_fiemap_info_key *)0)->lfik_oa) == 208, "found %lld\n",
+		 (long long)(int)sizeof(((struct ll_fiemap_info_key *)0)->lfik_oa));
+	LASSERTF((int)offsetof(struct ll_fiemap_info_key, lfik_fiemap) == 216, "found %lld\n",
+		 (long long)(int)offsetof(struct ll_fiemap_info_key, lfik_fiemap));
+	LASSERTF((int)sizeof(((struct ll_fiemap_info_key *)0)->lfik_fiemap) == 32, "found %lld\n",
+		 (long long)(int)sizeof(((struct ll_fiemap_info_key *)0)->lfik_fiemap));
 
 	/* Checks for struct mgs_target_info */
 	LASSERTF((int)sizeof(struct mgs_target_info) == 4544, "found %lld\n",
@@ -3670,64 +3670,64 @@ void lustre_assert_wire_constants(void)
 	LASSERTF((int)sizeof(((struct getinfo_fid2path *)0)->gf_path[0]) == 1, "found %lld\n",
 		 (long long)(int)sizeof(((struct getinfo_fid2path *)0)->gf_path[0]));
 
-	/* Checks for struct ll_user_fiemap */
-	LASSERTF((int)sizeof(struct ll_user_fiemap) == 32, "found %lld\n",
-		 (long long)(int)sizeof(struct ll_user_fiemap));
-	LASSERTF((int)offsetof(struct ll_user_fiemap, fm_start) == 0, "found %lld\n",
-		 (long long)(int)offsetof(struct ll_user_fiemap, fm_start));
-	LASSERTF((int)sizeof(((struct ll_user_fiemap *)0)->fm_start) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct ll_user_fiemap *)0)->fm_start));
-	LASSERTF((int)offsetof(struct ll_user_fiemap, fm_length) == 8, "found %lld\n",
-		 (long long)(int)offsetof(struct ll_user_fiemap, fm_length));
-	LASSERTF((int)sizeof(((struct ll_user_fiemap *)0)->fm_length) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct ll_user_fiemap *)0)->fm_length));
-	LASSERTF((int)offsetof(struct ll_user_fiemap, fm_flags) == 16, "found %lld\n",
-		 (long long)(int)offsetof(struct ll_user_fiemap, fm_flags));
-	LASSERTF((int)sizeof(((struct ll_user_fiemap *)0)->fm_flags) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct ll_user_fiemap *)0)->fm_flags));
-	LASSERTF((int)offsetof(struct ll_user_fiemap, fm_mapped_extents) == 20, "found %lld\n",
-		 (long long)(int)offsetof(struct ll_user_fiemap, fm_mapped_extents));
-	LASSERTF((int)sizeof(((struct ll_user_fiemap *)0)->fm_mapped_extents) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct ll_user_fiemap *)0)->fm_mapped_extents));
-	LASSERTF((int)offsetof(struct ll_user_fiemap, fm_extent_count) == 24, "found %lld\n",
-		 (long long)(int)offsetof(struct ll_user_fiemap, fm_extent_count));
-	LASSERTF((int)sizeof(((struct ll_user_fiemap *)0)->fm_extent_count) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct ll_user_fiemap *)0)->fm_extent_count));
-	LASSERTF((int)offsetof(struct ll_user_fiemap, fm_reserved) == 28, "found %lld\n",
-		 (long long)(int)offsetof(struct ll_user_fiemap, fm_reserved));
-	LASSERTF((int)sizeof(((struct ll_user_fiemap *)0)->fm_reserved) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct ll_user_fiemap *)0)->fm_reserved));
-	LASSERTF((int)offsetof(struct ll_user_fiemap, fm_extents) == 32, "found %lld\n",
-		 (long long)(int)offsetof(struct ll_user_fiemap, fm_extents));
-	LASSERTF((int)sizeof(((struct ll_user_fiemap *)0)->fm_extents) == 0, "found %lld\n",
-		 (long long)(int)sizeof(((struct ll_user_fiemap *)0)->fm_extents));
+	/* Checks for struct fiemap */
+	LASSERTF((int)sizeof(struct fiemap) == 32, "found %lld\n",
+		 (long long)(int)sizeof(struct fiemap));
+	LASSERTF((int)offsetof(struct fiemap, fm_start) == 0, "found %lld\n",
+		 (long long)(int)offsetof(struct fiemap, fm_start));
+	LASSERTF((int)sizeof(((struct fiemap *)0)->fm_start) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct fiemap *)0)->fm_start));
+	LASSERTF((int)offsetof(struct fiemap, fm_length) == 8, "found %lld\n",
+		 (long long)(int)offsetof(struct fiemap, fm_length));
+	LASSERTF((int)sizeof(((struct fiemap *)0)->fm_length) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct fiemap *)0)->fm_length));
+	LASSERTF((int)offsetof(struct fiemap, fm_flags) == 16, "found %lld\n",
+		 (long long)(int)offsetof(struct fiemap, fm_flags));
+	LASSERTF((int)sizeof(((struct fiemap *)0)->fm_flags) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct fiemap *)0)->fm_flags));
+	LASSERTF((int)offsetof(struct fiemap, fm_mapped_extents) == 20, "found %lld\n",
+		 (long long)(int)offsetof(struct fiemap, fm_mapped_extents));
+	LASSERTF((int)sizeof(((struct fiemap *)0)->fm_mapped_extents) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct fiemap *)0)->fm_mapped_extents));
+	LASSERTF((int)offsetof(struct fiemap, fm_extent_count) == 24, "found %lld\n",
+		 (long long)(int)offsetof(struct fiemap, fm_extent_count));
+	LASSERTF((int)sizeof(((struct fiemap *)0)->fm_extent_count) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct fiemap *)0)->fm_extent_count));
+	LASSERTF((int)offsetof(struct fiemap, fm_reserved) == 28, "found %lld\n",
+		 (long long)(int)offsetof(struct fiemap, fm_reserved));
+	LASSERTF((int)sizeof(((struct fiemap *)0)->fm_reserved) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct fiemap *)0)->fm_reserved));
+	LASSERTF((int)offsetof(struct fiemap, fm_extents) == 32, "found %lld\n",
+		 (long long)(int)offsetof(struct fiemap, fm_extents));
+	LASSERTF((int)sizeof(((struct fiemap *)0)->fm_extents) == 0, "found %lld\n",
+		 (long long)(int)sizeof(((struct fiemap *)0)->fm_extents));
 	CLASSERT(FIEMAP_FLAG_SYNC == 0x00000001);
 	CLASSERT(FIEMAP_FLAG_XATTR == 0x00000002);
 	CLASSERT(FIEMAP_FLAG_DEVICE_ORDER == 0x40000000);
 
-	/* Checks for struct ll_fiemap_extent */
-	LASSERTF((int)sizeof(struct ll_fiemap_extent) == 56, "found %lld\n",
-		 (long long)(int)sizeof(struct ll_fiemap_extent));
-	LASSERTF((int)offsetof(struct ll_fiemap_extent, fe_logical) == 0, "found %lld\n",
-		 (long long)(int)offsetof(struct ll_fiemap_extent, fe_logical));
-	LASSERTF((int)sizeof(((struct ll_fiemap_extent *)0)->fe_logical) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct ll_fiemap_extent *)0)->fe_logical));
-	LASSERTF((int)offsetof(struct ll_fiemap_extent, fe_physical) == 8, "found %lld\n",
-		 (long long)(int)offsetof(struct ll_fiemap_extent, fe_physical));
-	LASSERTF((int)sizeof(((struct ll_fiemap_extent *)0)->fe_physical) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct ll_fiemap_extent *)0)->fe_physical));
-	LASSERTF((int)offsetof(struct ll_fiemap_extent, fe_length) == 16, "found %lld\n",
-		 (long long)(int)offsetof(struct ll_fiemap_extent, fe_length));
-	LASSERTF((int)sizeof(((struct ll_fiemap_extent *)0)->fe_length) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct ll_fiemap_extent *)0)->fe_length));
-	LASSERTF((int)offsetof(struct ll_fiemap_extent, fe_flags) == 40, "found %lld\n",
-		 (long long)(int)offsetof(struct ll_fiemap_extent, fe_flags));
-	LASSERTF((int)sizeof(((struct ll_fiemap_extent *)0)->fe_flags) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct ll_fiemap_extent *)0)->fe_flags));
-	LASSERTF((int)offsetof(struct ll_fiemap_extent, fe_device) == 44, "found %lld\n",
-		 (long long)(int)offsetof(struct ll_fiemap_extent, fe_device));
-	LASSERTF((int)sizeof(((struct ll_fiemap_extent *)0)->fe_device) == 4, "found %lld\n",
-		 (long long)(int)sizeof(((struct ll_fiemap_extent *)0)->fe_device));
+	/* Checks for struct fiemap_extent */
+	LASSERTF((int)sizeof(struct fiemap_extent) == 56, "found %lld\n",
+		 (long long)(int)sizeof(struct fiemap_extent));
+	LASSERTF((int)offsetof(struct fiemap_extent, fe_logical) == 0, "found %lld\n",
+		 (long long)(int)offsetof(struct fiemap_extent, fe_logical));
+	LASSERTF((int)sizeof(((struct fiemap_extent *)0)->fe_logical) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct fiemap_extent *)0)->fe_logical));
+	LASSERTF((int)offsetof(struct fiemap_extent, fe_physical) == 8, "found %lld\n",
+		 (long long)(int)offsetof(struct fiemap_extent, fe_physical));
+	LASSERTF((int)sizeof(((struct fiemap_extent *)0)->fe_physical) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct fiemap_extent *)0)->fe_physical));
+	LASSERTF((int)offsetof(struct fiemap_extent, fe_length) == 16, "found %lld\n",
+		 (long long)(int)offsetof(struct fiemap_extent, fe_length));
+	LASSERTF((int)sizeof(((struct fiemap_extent *)0)->fe_length) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct fiemap_extent *)0)->fe_length));
+	LASSERTF((int)offsetof(struct fiemap_extent, fe_flags) == 40, "found %lld\n",
+		 (long long)(int)offsetof(struct fiemap_extent, fe_flags));
+	LASSERTF((int)sizeof(((struct fiemap_extent *)0)->fe_flags) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct fiemap_extent *)0)->fe_flags));
+	LASSERTF((int)offsetof(struct fiemap_extent, fe_reserved[0]) == 44, "found %lld\n",
+		 (long long)(int)offsetof(struct fiemap_extent, fe_reserved[0]));
+	LASSERTF((int)sizeof(((struct fiemap_extent *)0)->fe_reserved[0]) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct fiemap_extent *)0)->fe_reserved[0]));
 	CLASSERT(FIEMAP_EXTENT_LAST == 0x00000001);
 	CLASSERT(FIEMAP_EXTENT_UNKNOWN == 0x00000002);
 	CLASSERT(FIEMAP_EXTENT_DELALLOC == 0x00000004);
-- 
1.7.1
