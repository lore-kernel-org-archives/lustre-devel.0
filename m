From: James Simmons <jsimmons@infradead.org>
Date: Sat, 13 Jun 2020 12:27:06 -0400
Subject: [lustre-devel] [PATCH 10/20] lustre: dne: directory restripe and
 auto split
In-Reply-To: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
References: <1592065636-28333-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1592065636-28333-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

A specific restriper thread is created for each MDT, it does three
tasks in a loop:
1. If there is directory whose total sub-files exceeds threshold
   (50000 by default, can be changed "lctl set_param
   mdt.*.dir_split_count=N"), split this directory by adding new
   stripes (4 stripes by default, which can be adjusted by
   "lctl set_param mdt.*.dir_split_delta=N").
2. If a directory stripe LMV is marked 'MIGRATION', migrate sub file
   from current offset, and update offset to next file.
3. If a directory master LMV is marked 'RESTRIPING', check whether
   all stripe LMV 'MIGRATION' flag is cleared, if so, clear
   'RESTRIPING' flag and update directory LMV.

In last patch, the first part of manual directory stripe is
implemented, and in this patch, sub file migrations and dir layout
update is done. Directory auto-split is done in similar way, except
that the first step is done by this thread too.

Directory auto-split can be enabled/disabled by "lctl set_param
mdt.*.enable_dir_auto_split=[0|1]", it's turned on by default.

Auto split is triggered at the end of getattr(): since now the attr
contains dirent count, check whether it exceeds threshold, if so,
add this directory into mdr_auto_split list and wake up the dir
restriper thread.

Restripe migration is also triggered in getattr(): if the object is
directory stripe, and LMV 'MIGRATION' flag set, add this object into
mdr_restripe_migrate list and wake up the dir restriper thread.

Directory layout update is similar: if current directory is striped,
and LNV 'RESTRIPING' flag is set, add this directory into
mdr_restripe_update list and wake up restriper thread.

By default restripe migrate dirent only, and leave inode unchanged, it
can be adjusted by "lctl set_param mdt.*.dir_restripe_nsonly=[0|1]".

Currently DoM file inode migration is not supported, migrate dirent
only for such files to avoid leaving dir migration/restripe
unfinished.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11025
Lustre-commit: a336d7c7c1cd6 ("LU-11025 dne: directory restripe and auto split")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/37284
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_lmv.h         | 20 +++++++++++++++-----
 fs/lustre/llite/dir.c                  | 25 ++-----------------------
 include/uapi/linux/lustre/lustre_idl.h | 18 ++++++++++++++++++
 3 files changed, 35 insertions(+), 28 deletions(-)

diff --git a/fs/lustre/include/lustre_lmv.h b/fs/lustre/include/lustre_lmv.h
index 0175816..afa4d60 100644
--- a/fs/lustre/include/lustre_lmv.h
+++ b/fs/lustre/include/lustre_lmv.h
@@ -452,32 +452,42 @@ static inline bool lmv_is_sane2(const struct lmv_mds_md_v1 *lmv)
 
 static inline bool lmv_is_splitting(const struct lmv_mds_md_v1 *lmv)
 {
-	LASSERT(lmv_is_sane2(lmv));
+	if (!lmv_is_sane2(lmv))
+		return false;
+
 	return lmv_hash_is_splitting(cpu_to_le32(lmv->lmv_hash_type));
 }
 
 static inline bool lmv_is_merging(const struct lmv_mds_md_v1 *lmv)
 {
-	LASSERT(lmv_is_sane2(lmv));
+	if (!lmv_is_sane2(lmv))
+		return false;
+
 	return lmv_hash_is_merging(cpu_to_le32(lmv->lmv_hash_type));
 }
 
 static inline bool lmv_is_migrating(const struct lmv_mds_md_v1 *lmv)
 {
-	LASSERT(lmv_is_sane(lmv));
+	if (!lmv_is_sane(lmv))
+		return false;
+
 	return lmv_hash_is_migrating(cpu_to_le32(lmv->lmv_hash_type));
 }
 
 static inline bool lmv_is_restriping(const struct lmv_mds_md_v1 *lmv)
 {
-	LASSERT(lmv_is_sane2(lmv));
+	if (!lmv_is_sane2(lmv))
+		return false;
+
 	return lmv_hash_is_splitting(cpu_to_le32(lmv->lmv_hash_type)) ||
 	       lmv_hash_is_merging(cpu_to_le32(lmv->lmv_hash_type));
 }
 
 static inline bool lmv_is_layout_changing(const struct lmv_mds_md_v1 *lmv)
 {
-	LASSERT(lmv_is_sane2(lmv));
+	if (!lmv_is_sane2(lmv))
+		return false;
+
 	return lmv_hash_is_splitting(cpu_to_le32(lmv->lmv_hash_type)) ||
 	       lmv_hash_is_merging(cpu_to_le32(lmv->lmv_hash_type)) ||
 	       lmv_hash_is_migrating(cpu_to_le32(lmv->lmv_hash_type));
diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 7fd52fe..0ffe134 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -48,6 +48,7 @@
 
 #include <obd_support.h>
 #include <obd_class.h>
+#include <uapi/linux/lustre/lustre_idl.h>
 #include <uapi/linux/lustre/lustre_ioctl.h>
 #include <lustre_lib.h>
 #include <lustre_dlm.h>
@@ -174,28 +175,6 @@ void ll_release_page(struct inode *inode, struct page *page, bool remove)
 	put_page(page);
 }
 
-/**
- * return IF_* type for given lu_dirent entry.
- * IF_* flag shld be converted to particular OS file type in
- * platform llite module.
- */
-static u16 ll_dirent_type_get(struct lu_dirent *ent)
-{
-	u16 type = 0;
-	struct luda_type *lt;
-	int len = 0;
-
-	if (le32_to_cpu(ent->lde_attrs) & LUDA_TYPE) {
-		const unsigned int align = sizeof(struct luda_type) - 1;
-
-		len = le16_to_cpu(ent->lde_namelen);
-		len = (len + align) & ~align;
-		lt = (void *)ent->lde_name + len;
-		type = IFTODT(le16_to_cpu(lt->lt_type));
-	}
-	return type;
-}
-
 int ll_dir_read(struct inode *inode, u64 *ppos, struct md_op_data *op_data,
 		struct dir_context *ctx)
 {
@@ -246,7 +225,7 @@ int ll_dir_read(struct inode *inode, u64 *ppos, struct md_op_data *op_data,
 				lhash = hash;
 			fid_le_to_cpu(&fid, &ent->lde_fid);
 			ino = cl_fid_build_ino(&fid, is_api32);
-			type = ll_dirent_type_get(ent);
+			type = IFTODT(lu_dirent_type_get(ent));
 			ctx->pos = lhash;
 			/* For 'll_nfs_get_name_filldir()', it will try
 			 * to access the 'ent' through its 'lde_name',
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 800154d..d0b43c8 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -492,6 +492,24 @@ static inline __kernel_size_t lu_dirent_calc_size(size_t namelen, __u16 attr)
 	return (size + 7) & ~7;
 }
 
+static inline __u16 lu_dirent_type_get(struct lu_dirent *ent)
+{
+	__u16 type = 0;
+	struct luda_type *lt;
+	int len = 0;
+
+	if (__le32_to_cpu(ent->lde_attrs) & LUDA_TYPE) {
+		const unsigned int align = sizeof(struct luda_type) - 1;
+
+		len = __le16_to_cpu(ent->lde_namelen);
+		len = (len + align) & ~align;
+		lt = (void *)ent->lde_name + len;
+		type = __le16_to_cpu(lt->lt_type);
+	}
+
+	return type;
+}
+
 #define MDS_DIR_END_OFF 0xfffffffffffffffeULL
 
 /**
-- 
1.8.3.1
