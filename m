From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:26 -0500
Subject: [lustre-devel] [PATCH 278/622] lustre: lov: new foreign LOV format
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-279-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Bruno Faccini <bruno.faccini@intel.com>

This patch introduces a new layout/LOV format in order to
allow to specify an arbitrary external reference for a file
in Lustre namespace.
The new LOV format is made of {newmagic, length, type, flags,
string[length]} to be as flexible as possible.
Foreign file can be created by using the open(O_LOV_DELAY_CREATE) +
ioctl(LL_IOC_LOV_SETSTRIPE) operations and it can only be and remain
an empty file until removed.
A new API method llapi_file_create_foreign() has been introduced
and "lfs [[get,set]stripe,find" modified to understand new layout.
The idea behind this is to provide Lustre namespace support and
layout prefetch/caching under layout protection, for user/external
usage.

Code has been added for lfsck to handle foreign files, and
a new sub-test has been added in sanity-lfsck in order to verify
if does not break foreign file and that reverse is also true.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11376
Lustre-commit: 6a20bdcc608b ("LU-11376 lov: new foreign LOV format")
Signed-off-by: Bruno Faccini <bruno.faccini@intel.com>
Reviewed-on: https://review.whamcloud.com/33755
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c                  | 12 ++++++-
 fs/lustre/llite/llite_internal.h        |  2 ++
 fs/lustre/llite/vvp_io.c                |  2 +-
 fs/lustre/llite/xattr.c                 |  4 ++-
 fs/lustre/lov/lov_cl_internal.h         |  6 ++++
 fs/lustre/lov/lov_ea.c                  | 63 ++++++++++++++++++++++++++++++---
 fs/lustre/lov/lov_internal.h            | 19 +++++++---
 fs/lustre/lov/lov_object.c              | 49 ++++++++++++++++++++++++-
 fs/lustre/lov/lov_pack.c                | 44 ++++++++++++++++++++---
 fs/lustre/lov/lov_page.c                |  7 ++++
 include/uapi/linux/lustre/lustre_idl.h  |  1 +
 include/uapi/linux/lustre/lustre_user.h | 31 ++++++++++++++++
 12 files changed, 222 insertions(+), 18 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index d059ac7..0d7d566 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1827,7 +1827,8 @@ int ll_lov_getstripe_ea_info(struct inode *inode, const char *filename,
 
 	if (lmm->lmm_magic != cpu_to_le32(LOV_MAGIC_V1) &&
 	    lmm->lmm_magic != cpu_to_le32(LOV_MAGIC_V3) &&
-	    lmm->lmm_magic != cpu_to_le32(LOV_MAGIC_COMP_V1)) {
+	    lmm->lmm_magic != cpu_to_le32(LOV_MAGIC_COMP_V1) &&
+	    lmm->lmm_magic != cpu_to_le32(LOV_MAGIC_FOREIGN)) {
 		rc = -EPROTO;
 		goto out;
 	}
@@ -1863,6 +1864,15 @@ int ll_lov_getstripe_ea_info(struct inode *inode, const char *filename,
 								stripe_count);
 		} else if (lmm->lmm_magic == cpu_to_le32(LOV_MAGIC_COMP_V1)) {
 			lustre_swab_lov_comp_md_v1((struct lov_comp_md_v1 *)lmm);
+		} else if (lmm->lmm_magic ==
+			   cpu_to_le32(LOV_MAGIC_FOREIGN)) {
+			struct lov_foreign_md *lfm;
+
+			lfm = (struct lov_foreign_md *)lmm;
+			__swab32s(&lfm->lfm_magic);
+			__swab32s(&lfm->lfm_length);
+			__swab32s(&lfm->lfm_type);
+			__swab32s(&lfm->lfm_flags);
 		}
 	}
 
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index b9478f4d..9d7345a 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -962,6 +962,8 @@ static inline ssize_t ll_lov_user_md_size(const struct lov_user_md *lum)
 					LOV_USER_MAGIC_SPECIFIC);
 	case LOV_USER_MAGIC_COMP_V1:
 		return ((struct lov_comp_md_v1 *)lum)->lcm_size;
+	case LOV_USER_MAGIC_FOREIGN:
+		return foreign_size(lum);
 	}
 	return -EINVAL;
 }
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index 1f82fe6..ee44a18 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -165,7 +165,7 @@ static int vvp_prep_size(const struct lu_env *env, struct cl_object *obj,
 				 * --bug 17336
 				 */
 				loff_t size = i_size_read(inode);
-				loff_t cur_index = start >> PAGE_SHIFT;
+				unsigned long cur_index = start >> PAGE_SHIFT;
 				loff_t size_index = (size - 1) >> PAGE_SHIFT;
 
 				if ((size == 0 && cur_index != 0) ||
diff --git a/fs/lustre/llite/xattr.c b/fs/lustre/llite/xattr.c
index aa61a5a..9707e78 100644
--- a/fs/lustre/llite/xattr.c
+++ b/fs/lustre/llite/xattr.c
@@ -453,6 +453,7 @@ static ssize_t ll_getxattr_lov(struct inode *inode, void *buf, size_t buf_size)
 		};
 		struct lu_env *env;
 		u16 refcheck;
+		u32 magic;
 
 		if (!obj)
 			return -ENODATA;
@@ -483,7 +484,8 @@ static ssize_t ll_getxattr_lov(struct inode *inode, void *buf, size_t buf_size)
 		 * recognizing layout gen as stripe offset when the
 		 * file is restored. See LU-2809.
 		 */
-		if (((struct lov_mds_md *)buf)->lmm_magic == LOV_MAGIC_COMP_V1)
+		magic = ((struct lov_mds_md *)buf)->lmm_magic;
+		if (magic == LOV_MAGIC_COMP_V1 || magic == LOV_MAGIC_FOREIGN)
 			goto out_env;
 
 		((struct lov_mds_md *)buf)->lmm_layout_gen = 0;
diff --git a/fs/lustre/lov/lov_cl_internal.h b/fs/lustre/lov/lov_cl_internal.h
index e14567d..7b95a00 100644
--- a/fs/lustre/lov/lov_cl_internal.h
+++ b/fs/lustre/lov/lov_cl_internal.h
@@ -122,6 +122,7 @@ enum lov_layout_type {
 	LLT_EMPTY,	/** empty file without body (mknod + truncate) */
 	LLT_RELEASED,	/** file with no objects (data in HSM) */
 	LLT_COMP,	/** support composite layout */
+	LLT_FOREIGN,	/** foreign layout */
 	LLT_NR
 };
 
@@ -134,6 +135,8 @@ static inline char *llt2str(enum lov_layout_type llt)
 		return "RELEASED";
 	case LLT_COMP:
 		return "COMPOSITE";
+	case LLT_FOREIGN:
+		return "FOREIGN";
 	case LLT_NR:
 		LBUG();
 	}
@@ -626,9 +629,12 @@ int lov_page_init_empty(const struct lu_env *env, struct cl_object *obj,
 			struct cl_page *page, pgoff_t index);
 int lov_page_init_composite(const struct lu_env *env, struct cl_object *obj,
 			    struct cl_page *page, pgoff_t index);
+int lov_page_init_foreign(const struct lu_env *env, struct cl_object *obj,
+			   struct cl_page *page, pgoff_t index);
 struct lu_object *lov_object_alloc(const struct lu_env *env,
 				   const struct lu_object_header *hdr,
 				   struct lu_device *dev);
+
 struct lu_object *lovsub_object_alloc(const struct lu_env *env,
 				      const struct lu_object_header *hdr,
 				      struct lu_device *dev);
diff --git a/fs/lustre/lov/lov_ea.c b/fs/lustre/lov/lov_ea.c
index 31a18d0..b7a6d91 100644
--- a/fs/lustre/lov/lov_ea.c
+++ b/fs/lustre/lov/lov_ea.c
@@ -134,8 +134,12 @@ void lsm_free(struct lov_stripe_md *lsm)
 	unsigned int entry_count = lsm->lsm_entry_count;
 	unsigned int i;
 
-	for (i = 0; i < entry_count; i++)
-		lsme_free(lsm->lsm_entries[i]);
+	if (lsm->lsm_magic == LOV_MAGIC_FOREIGN) {
+		kvfree(lsm_foreign(lsm));
+	} else {
+		for (i = 0; i < entry_count; i++)
+			lsme_free(lsm->lsm_entries[i]);
+	}
 
 	kfree(lsm);
 }
@@ -513,6 +517,44 @@ static int lsm_verify_comp_md_v1(struct lov_comp_md_v1 *lcm,
 	.lsm_unpackmd		= lsm_unpackmd_comp_md_v1,
 };
 
+static struct
+lov_stripe_md *lsm_unpackmd_foreign(struct lov_obd *lov, void *buf,
+				    size_t buf_size)
+{
+	struct lov_foreign_md *lfm = buf;
+	struct lov_stripe_md *lsm;
+	size_t lsm_size;
+	struct lov_stripe_md_entry *lsme;
+
+	lsm_size = offsetof(typeof(*lsm), lsm_entries[1]);
+	lsm = kzalloc(lsm_size, GFP_NOFS);
+	if (!lsm)
+		return ERR_PTR(-ENOMEM);
+
+	atomic_set(&lsm->lsm_refc, 1);
+	spin_lock_init(&lsm->lsm_lock);
+	lsm->lsm_magic = le32_to_cpu(lfm->lfm_magic);
+	lsm->lsm_foreign_size = foreign_size_le(lfm);
+
+	/* alloc for full foreign EA including format fields */
+	lsme = kvzalloc(lsm->lsm_foreign_size, GFP_NOFS);
+	if (!lsme) {
+		kfree(lsm);
+		return ERR_PTR(-ENOMEM);
+	}
+
+	/* copy full foreign EA including format fields */
+	memcpy(lsme, buf, lsm->lsm_foreign_size);
+
+	lsm_foreign(lsm) = lsme;
+
+	return lsm;
+}
+
+const struct lsm_operations lsm_foreign_ops = {
+	.lsm_unpackmd         = lsm_unpackmd_foreign,
+};
+
 const struct lsm_operations *lsm_op_find(int magic)
 {
 	const struct lsm_operations *lsm = NULL;
@@ -527,6 +569,9 @@ const struct lsm_operations *lsm_op_find(int magic)
 	case LOV_MAGIC_COMP_V1:
 		lsm = &lsm_comp_md_v1_ops;
 		break;
+	case LOV_MAGIC_FOREIGN:
+		lsm = &lsm_foreign_ops;
+		break;
 	default:
 		CERROR("unrecognized lsm_magic %08x\n", magic);
 		break;
@@ -539,12 +584,22 @@ void dump_lsm(unsigned int level, const struct lov_stripe_md *lsm)
 {
 	int i, j;
 
-	CDEBUG(level,
-	       "lsm %p, objid " DOSTID ", maxbytes %#llx, magic 0x%08X, refc: %d, entry: %u, layout_gen %u\n",
+	CDEBUG_LIMIT(level,
+		     "lsm %p, objid " DOSTID ", maxbytes %#llx, magic 0x%08X, refc: %d, entry: %u, layout_gen %u\n",
 	       lsm, POSTID(&lsm->lsm_oi), lsm->lsm_maxbytes, lsm->lsm_magic,
 	       atomic_read(&lsm->lsm_refc), lsm->lsm_entry_count,
 	       lsm->lsm_layout_gen);
 
+	if (lsm->lsm_magic == LOV_MAGIC_FOREIGN) {
+		struct lov_foreign_md *lfm = (void *)lsm_foreign(lsm);
+
+		CDEBUG_LIMIT(level,
+			     "foreign LOV EA, magic %x, length %u, type %x, flags %x, value '%.*s'\n",
+		       lfm->lfm_magic, lfm->lfm_length, lfm->lfm_type,
+		       lfm->lfm_flags, lfm->lfm_length, lfm->lfm_value);
+		return;
+	}
+
 	for (i = 0; i < lsm->lsm_entry_count; i++) {
 		struct lov_stripe_md_entry *lse = lsm->lsm_entries[i];
 
diff --git a/fs/lustre/lov/lov_internal.h b/fs/lustre/lov/lov_internal.h
index 36586b3..d235abe 100644
--- a/fs/lustre/lov/lov_internal.h
+++ b/fs/lustre/lov/lov_internal.h
@@ -79,11 +79,15 @@ struct lov_stripe_md {
 	spinlock_t	lsm_lock;
 	pid_t		lsm_lock_owner; /* debugging */
 
-	/*
-	 * maximum possible file size, might change as OSTs status changes,
-	 * e.g. disconnected, deactivated
-	 */
-	loff_t		lsm_maxbytes;
+	union {
+		/*
+		 * maximum possible file size, might change as OSTs status
+		 * changes, e.g. disconnected, deactivated
+		 */
+		loff_t          lsm_maxbytes;
+		/* size of full foreign LOV */
+		size_t          lsm_foreign_size;
+	};
 	struct ost_id	lsm_oi;
 	u32		lsm_magic;
 	u32		lsm_layout_gen;
@@ -94,6 +98,8 @@ struct lov_stripe_md {
 	struct lov_stripe_md_entry *lsm_entries[];
 };
 
+#define lsm_foreign(lsm) (lsm->lsm_entries[0])
+
 static inline bool lsme_inited(const struct lov_stripe_md_entry *lsme)
 {
 	return lsme->lsme_flags & LCME_FL_INIT;
@@ -119,6 +125,9 @@ static inline size_t lov_comp_md_size(const struct lov_stripe_md *lsm)
 		return lov_mds_md_size(lsm->lsm_entries[0]->lsme_stripe_count,
 				       lsm->lsm_entries[0]->lsme_magic);
 
+	if (lsm->lsm_magic == LOV_MAGIC_FOREIGN)
+		return lsm->lsm_foreign_size;
+
 	LASSERT(lsm->lsm_magic == LOV_MAGIC_COMP_V1);
 
 	size = sizeof(struct lov_comp_md_v1);
diff --git a/fs/lustre/lov/lov_object.c b/fs/lustre/lov/lov_object.c
index c04b2ae..7543ef2 100644
--- a/fs/lustre/lov/lov_object.c
+++ b/fs/lustre/lov/lov_object.c
@@ -810,10 +810,25 @@ static int lov_init_released(const struct lu_env *env,
 	return 0;
 }
 
+static int lov_init_foreign(const struct lu_env *env,
+			    struct lov_device *dev, struct lov_object *lov,
+			    struct lov_stripe_md *lsm,
+			    const struct cl_object_conf *conf,
+			    union lov_layout_state *state)
+{
+	LASSERT(lsm);
+	LASSERT(lov->lo_type == LLT_FOREIGN);
+	LASSERT(!lov->lo_lsm);
+
+	lov->lo_lsm = lsm_addref(lsm);
+	return 0;
+}
+
 static int lov_delete_empty(const struct lu_env *env, struct lov_object *lov,
 			    union lov_layout_state *state)
 {
-	LASSERT(lov->lo_type == LLT_EMPTY || lov->lo_type == LLT_RELEASED);
+	LASSERT(lov->lo_type == LLT_EMPTY || lov->lo_type == LLT_RELEASED ||
+		lov->lo_type == LLT_FOREIGN);
 
 	lov_layout_wait(env, lov);
 	return 0;
@@ -923,6 +938,23 @@ static int lov_print_released(const struct lu_env *env, void *cookie,
 	return 0;
 }
 
+static int lov_print_foreign(const struct lu_env *env, void *cookie,
+				lu_printer_t p, const struct lu_object *o)
+{
+	struct lov_object	*lov = lu2lov(o);
+	struct lov_stripe_md	*lsm = lov->lo_lsm;
+
+	(*p)(env, cookie,
+		"foreign: %s, lsm{%p 0x%08X %d %u}:\n",
+		lov->lo_layout_invalid ? "invalid" : "valid", lsm,
+		lsm->lsm_magic, atomic_read(&lsm->lsm_refc),
+		lsm->lsm_layout_gen);
+	(*p)(env, cookie,
+		"raw_ea_content '%.*s'\n",
+		(int)lsm->lsm_foreign_size, (char *)lsm_foreign(lsm));
+	return 0;
+}
+
 /**
  * Implements cl_object_operations::coo_attr_get() method for an object
  * without stripes (LLT_EMPTY layout type).
@@ -1020,6 +1052,16 @@ static int lov_attr_get_composite(const struct lu_env *env,
 		.llo_io_init	= lov_io_init_composite,
 		.llo_getattr	= lov_attr_get_composite,
 	},
+	[LLT_FOREIGN] = {
+		.llo_init      = lov_init_foreign,
+		.llo_delete    = lov_delete_empty,
+		.llo_fini      = lov_fini_released,
+		.llo_print     = lov_print_foreign,
+		.llo_page_init = lov_page_init_foreign,
+		.llo_lock_init = lov_lock_init_empty,
+		.llo_io_init   = lov_io_init_empty,
+		.llo_getattr   = lov_attr_get_empty,
+	},
 };
 
 /**
@@ -1051,6 +1093,9 @@ static enum lov_layout_type lov_type(struct lov_stripe_md *lsm)
 	    lsm->lsm_magic == LOV_MAGIC_COMP_V1)
 		return LLT_COMP;
 
+	if (lsm->lsm_magic == LOV_MAGIC_FOREIGN)
+		return LLT_FOREIGN;
+
 	return LLT_EMPTY;
 }
 
@@ -2141,6 +2186,8 @@ int lov_read_and_clear_async_rc(struct cl_object *clob)
 		}
 		case LLT_RELEASED:
 		case LLT_EMPTY:
+			/* fall through */
+		case LLT_FOREIGN:
 			break;
 		default:
 			LBUG();
diff --git a/fs/lustre/lov/lov_pack.c b/fs/lustre/lov/lov_pack.c
index c6dec2d..2b348d3 100644
--- a/fs/lustre/lov/lov_pack.c
+++ b/fs/lustre/lov/lov_pack.c
@@ -162,6 +162,28 @@ ssize_t lov_lsm_pack_v1v3(const struct lov_stripe_md *lsm, void *buf,
 	return lmm_size;
 }
 
+ssize_t lov_lsm_pack_foreign(const struct lov_stripe_md *lsm, void *buf,
+			     size_t buf_size)
+{
+	struct lov_foreign_md *lfm = buf;
+	size_t lfm_size;
+
+	lfm_size = lsm->lsm_foreign_size;
+
+	if (buf_size == 0)
+		return lfm_size;
+
+	if (buf_size < lfm_size)
+		return -ERANGE;
+
+	/* full foreign LOV is already avail in its cache
+	 * no need to translate format fields to little-endian
+	 */
+	memcpy(lfm, lsm_foreign(lsm), lsm->lsm_foreign_size);
+
+	return lfm_size;
+}
+
 ssize_t lov_lsm_pack(const struct lov_stripe_md *lsm, void *buf,
 		     size_t buf_size)
 {
@@ -177,6 +199,9 @@ ssize_t lov_lsm_pack(const struct lov_stripe_md *lsm, void *buf,
 	if (lsm->lsm_magic == LOV_MAGIC_V1 || lsm->lsm_magic == LOV_MAGIC_V3)
 		return lov_lsm_pack_v1v3(lsm, buf, buf_size);
 
+	if (lsm->lsm_magic == LOV_MAGIC_FOREIGN)
+		return lov_lsm_pack_foreign(lsm, buf, buf_size);
+
 	lmm_size = lov_comp_md_size(lsm);
 	if (buf_size == 0)
 		return lmm_size;
@@ -331,6 +356,7 @@ int lov_getstripe(const struct lu_env *env, struct lov_object *obj,
 {
 	/* we use lov_user_md_v3 because it is larger than lov_user_md_v1 */
 	struct lov_mds_md *lmmk, *lmm;
+	struct lov_foreign_md *lfm;
 	struct lov_user_md_v1 lum;
 	ssize_t lmm_size, lum_size = 0;
 	static bool printed;
@@ -338,7 +364,8 @@ int lov_getstripe(const struct lu_env *env, struct lov_object *obj,
 	int rc = 0;
 
 	if (lsm->lsm_magic != LOV_MAGIC_V1 && lsm->lsm_magic != LOV_MAGIC_V3 &&
-	    lsm->lsm_magic != LOV_MAGIC_COMP_V1) {
+	    lsm->lsm_magic != LOV_MAGIC_COMP_V1 &&
+	    lsm->lsm_magic != LOV_MAGIC_FOREIGN) {
 		CERROR("bad LSM MAGIC: 0x%08X != 0x%08X nor 0x%08X\n",
 		       lsm->lsm_magic, LOV_MAGIC_V1, LOV_MAGIC_V3);
 		rc = -EIO;
@@ -374,16 +401,23 @@ int lov_getstripe(const struct lu_env *env, struct lov_object *obj,
 				lmmk->lmm_stripe_count);
 		} else if (lmmk->lmm_magic == cpu_to_le32(LOV_MAGIC_COMP_V1)) {
 			lustre_swab_lov_comp_md_v1((struct lov_comp_md_v1 *)lmmk);
+		} else if (lmmk->lmm_magic == cpu_to_le32(LOV_MAGIC_FOREIGN)) {
+			lfm = (struct lov_foreign_md *)lmmk;
+			__swab32s(&lfm->lfm_magic);
+			__swab32s(&lfm->lfm_length);
+			__swab32s(&lfm->lfm_type);
+			__swab32s(&lfm->lfm_flags);
 		}
 	}
 
 	/* Legacy appication passes limited buffer, we need to figure out
 	 * the user buffer size by the passed in lmm_stripe_count.
 	 */
-	if (copy_from_user(&lum, lump, sizeof(struct lov_user_md_v1))) {
-		rc = -EFAULT;
-		goto out_free;
-	}
+	if (lsm->lsm_magic != LOV_MAGIC_FOREIGN)
+		if (copy_from_user(&lum, lump, sizeof(struct lov_user_md_v1))) {
+			rc = -EFAULT;
+			goto out_free;
+		}
 
 	if (lum.lmm_magic == LOV_USER_MAGIC_V1 ||
 	    lum.lmm_magic == LOV_USER_MAGIC_V3)
diff --git a/fs/lustre/lov/lov_page.c b/fs/lustre/lov/lov_page.c
index 3f08da7..c3337706 100644
--- a/fs/lustre/lov/lov_page.c
+++ b/fs/lustre/lov/lov_page.c
@@ -145,6 +145,13 @@ int lov_page_init_empty(const struct lu_env *env, struct cl_object *obj,
 	return 0;
 }
 
+int lov_page_init_foreign(const struct lu_env *env, struct cl_object *obj,
+			struct cl_page *page, pgoff_t index)
+{
+	CDEBUG(D_PAGE, DFID" has no data\n", PFID(lu_object_fid(&obj->co_lu)));
+	return -ENODATA;
+}
+
 bool lov_page_is_empty(const struct cl_page *page)
 {
 	const struct cl_page_slice *slice = cl_page_at(page, &lov_device_type);
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index bba3a77..fd35023 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -1022,6 +1022,7 @@ enum obdo_flags {
 #define LOV_MAGIC_SPECIFIC	(0x0BD50000 | LOV_MAGIC_MAGIC)
 #define LOV_MAGIC		LOV_MAGIC_V1
 #define LOV_MAGIC_COMP_V1	(0x0BD60000 | LOV_MAGIC_MAGIC)
+#define LOV_MAGIC_FOREIGN	(0x0BD70000 | LOV_MAGIC_MAGIC)
 
 /*
  * magic for fully defined striping
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 3901eb2..ad5d446 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -56,6 +56,7 @@
 # include <limits.h>
 # include <stdbool.h>
 # include <stdio.h> /* snprintf() */
+# include <stdint.h>
 # include <string.h>
 # include <sys/stat.h>
 #endif /* __KERNEL__ */
@@ -388,6 +389,7 @@ struct ll_ioc_lease_id {
 /* 0x0BD40BD0 is occupied by LOV_MAGIC_MIGRATE */
 #define LOV_USER_MAGIC_SPECIFIC	0x0BD50BD0	/* for specific OSTs */
 #define LOV_USER_MAGIC_COMP_V1	0x0BD60BD0
+#define LOV_USER_MAGIC_FOREIGN	0x0BD70BD0
 
 #define LMV_USER_MAGIC		0x0CD30CD0	/*default lmv magic*/
 #define LMV_USER_MAGIC_SPECIFIC	0x0CD40CD0
@@ -469,6 +471,21 @@ struct lov_user_md_v3 {		/* LOV EA user data (host-endian) */
 	struct lov_user_ost_data_v1 lmm_objects[0]; /* per-stripe data */
 } __packed;
 
+struct lov_foreign_md {
+	__u32 lfm_magic;	/* magic number = LOV_MAGIC_FOREIGN */
+	__u32 lfm_length;	/* length of lfm_value */
+	__u32 lfm_type;		/* type, see LOV_FOREIGN_TYPE_ */
+	__u32 lfm_flags;	/* flags, type specific */
+	char lfm_value[];
+};
+
+#define foreign_size(lfm) (((struct lov_foreign_md *)lfm)->lfm_length + \
+			   offsetof(struct lov_foreign_md, lfm_value))
+
+#define foreign_size_le(lfm) \
+	(le32_to_cpu(((struct lov_foreign_md *)lfm)->lfm_length) + \
+	offsetof(struct lov_foreign_md, lfm_value))
+
 struct lu_extent {
 	__u64	e_start;
 	__u64	e_end;
@@ -628,6 +645,20 @@ enum lmv_hash_type {
 #define LMV_HASH_NAME_ALL_CHARS		"all_char"
 #define LMV_HASH_NAME_FNV_1A_64		"fnv_1a_64"
 
+/**
+ * LOV foreign types
+ **/
+#define LOV_FOREIGN_TYPE_NONE 0
+#define LOV_FOREIGN_TYPE_DAOS 0xda05
+#define LOV_FOREIGN_TYPE_UNKNOWN UINT32_MAX
+
+struct lustre_foreign_type {
+	uint32_t lft_type;
+	const char *lft_name;
+};
+
+extern struct lustre_foreign_type lov_foreign_type[];
+
 /*
  * Got this according to how get LOV_MAX_STRIPE_COUNT, see above,
  * (max buffer size - lmv+rpc header) / sizeof(struct lmv_user_mds_data)
-- 
1.8.3.1
