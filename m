From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:54 -0400
Subject: [lustre-devel] [PATCH 055/124] staging: lustre: llite: allow
	setting stripes to specify OSTs
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-56-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, Jian Yu <jian.yu@intel.com>, James Simmons <uja.ornl@gmail.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

Extend the llite layer to support specifying individual target
OSTs. Support specifying OSTs for regular files only. Directory
support will be implemented later in a separate project. With
this a file could have for example a OST index layout of
2,4,5,9,11. In addition, duplicate indices will be eliminated
automatically. Calculate the max easize by ld_active_tgt_count
instead of ld_tgt_count. However this may introduce problems
when the OSTs are in recovery because non sufficient buffer
may be allocated to store EA.

Signed-off-by: Jian Yu <jian.yu@intel.com>
Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Signed-off-by: James Simmons <uja.ornl@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4665
Reviewed-on: http://review.whamcloud.com/9383
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |    2 +
 .../lustre/lustre/include/lustre/lustre_user.h     |   17 ++++++-----
 drivers/staging/lustre/lustre/llite/file.c         |   28 +++++++-----------
 .../staging/lustre/lustre/llite/llite_internal.h   |   20 +++++++++++++
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   30 ++++++++++++++++++++
 drivers/staging/lustre/lustre/llite/xattr.c        |    9 ++++--
 drivers/staging/lustre/lustre/lov/lov_pack.c       |   18 ++++-------
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |   14 ---------
 8 files changed, 85 insertions(+), 53 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 0cc47bc..a0ca571 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1483,6 +1483,8 @@ enum obdo_flags {
 #define LOV_MAGIC_JOIN_V1	(0x0BD20000 | LOV_MAGIC_MAGIC)
 #define LOV_MAGIC_V3		(0x0BD30000 | LOV_MAGIC_MAGIC)
 #define LOV_MAGIC_MIGRATE	(0x0BD40000 | LOV_MAGIC_MAGIC)
+/* reserved for specifying OSTs */
+#define LOV_MAGIC_SPECIFIC	(0x0BD50000 | LOV_MAGIC_MAGIC)
 #define LOV_MAGIC		LOV_MAGIC_V1
 
 /*
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index 08ac6e4..3ef5db0 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -280,10 +280,12 @@ enum ll_lease_type {
 #define LL_FILE_LOCKLESS_IO     0x00000010 /* server-side locks with cio */
 #define LL_FILE_RMTACL	  0x00000020
 
-#define LOV_USER_MAGIC_V1 0x0BD10BD0
-#define LOV_USER_MAGIC    LOV_USER_MAGIC_V1
-#define LOV_USER_MAGIC_JOIN_V1 0x0BD20BD0
-#define LOV_USER_MAGIC_V3 0x0BD30BD0
+#define LOV_USER_MAGIC_V1	0x0BD10BD0
+#define LOV_USER_MAGIC		LOV_USER_MAGIC_V1
+#define LOV_USER_MAGIC_JOIN_V1	0x0BD20BD0
+#define LOV_USER_MAGIC_V3	0x0BD30BD0
+/* 0x0BD40BD0 is occupied by LOV_MAGIC_MIGRATE */
+#define LOV_USER_MAGIC_SPECIFIC	0x0BD50BD0	/* for specific OSTs */
 
 #define LMV_USER_MAGIC    0x0CD30CD0    /*default lmv magic*/
 
@@ -361,12 +363,11 @@ struct lov_user_md_v3 {	   /* LOV EA user data (host-endian) */
 
 static inline __u32 lov_user_md_size(__u16 stripes, __u32 lmm_magic)
 {
-	if (lmm_magic == LOV_USER_MAGIC_V3)
-		return sizeof(struct lov_user_md_v3) +
-				stripes * sizeof(struct lov_user_ost_data_v1);
-	else
+	if (lmm_magic == LOV_USER_MAGIC_V1)
 		return sizeof(struct lov_user_md_v1) +
 				stripes * sizeof(struct lov_user_ost_data_v1);
+	return sizeof(struct lov_user_md_v3) +
+	       stripes * sizeof(struct lov_user_ost_data_v1);
 }
 
 /* Compile with -D_LARGEFILE64_SOURCE or -D_GNU_SOURCE (or #define) to
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 45acc5d..fc81551 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -1540,39 +1540,33 @@ static int ll_lov_setea(struct inode *inode, struct file *file,
 static int ll_lov_setstripe(struct inode *inode, struct file *file,
 			    unsigned long arg)
 {
-	struct lov_user_md_v3 lumv3;
-	struct lov_user_md_v1 *lumv1 = (struct lov_user_md_v1 *)&lumv3;
-	struct lov_user_md_v1 __user *lumv1p = (void __user *)arg;
-	struct lov_user_md_v3 __user *lumv3p = (void __user *)arg;
+	struct lov_user_md __user *lum = (struct lov_user_md __user *)arg;
+	struct lov_user_md *klum;
 	int lum_size, rc;
 	__u64 flags = FMODE_WRITE;
 
-	/* first try with v1 which is smaller than v3 */
-	lum_size = sizeof(struct lov_user_md_v1);
-	if (copy_from_user(lumv1, lumv1p, lum_size))
-		return -EFAULT;
-
-	if (lumv1->lmm_magic == LOV_USER_MAGIC_V3) {
-		lum_size = sizeof(struct lov_user_md_v3);
-		if (copy_from_user(&lumv3, lumv3p, lum_size))
-			return -EFAULT;
-	}
+	rc = ll_copy_user_md(lum, &klum);
+	if (rc < 0)
+		return rc;
 
-	rc = ll_lov_setstripe_ea_info(inode, file->f_path.dentry, flags, lumv1,
+	lum_size = rc;
+	rc = ll_lov_setstripe_ea_info(inode, file->f_path.dentry, flags, klum,
 				      lum_size);
 	cl_lov_delay_create_clear(&file->f_flags);
 	if (rc == 0) {
 		struct lov_stripe_md *lsm;
 		__u32 gen;
 
-		put_user(0, &lumv1p->lmm_stripe_count);
+		put_user(0, &lum->lmm_stripe_count);
 
 		ll_layout_refresh(inode, &gen);
 		lsm = ccc_inode_lsm_get(inode);
 		rc = obd_iocontrol(LL_IOC_LOV_GETSTRIPE, ll_i2dtexp(inode),
-				   0, lsm, (void __user *)arg);
+				   0, lsm, lum);
 		ccc_inode_lsm_put(inode, lsm);
 	}
+
+	kfree(klum);
 	return rc;
 }
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 1cc427c..9a9fefd 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -875,6 +875,26 @@ int ll_get_obd_name(struct inode *inode, unsigned int cmd, unsigned long arg);
 char *ll_get_fsname(struct super_block *sb, char *buf, int buflen);
 void ll_compute_rootsquash_state(struct ll_sb_info *sbi);
 void ll_open_cleanup(struct super_block *sb, struct ptlrpc_request *open_req);
+ssize_t ll_copy_user_md(const struct lov_user_md __user *md,
+			struct lov_user_md **kbuf);
+
+/* Compute expected user md size when passing in a md from user space */
+static inline ssize_t ll_lov_user_md_size(const struct lov_user_md *lum)
+{
+	switch (lum->lmm_magic) {
+	case LOV_USER_MAGIC_V1:
+		return sizeof(struct lov_user_md_v1);
+	case LOV_USER_MAGIC_V3:
+		return sizeof(struct lov_user_md_v3);
+	case LOV_USER_MAGIC_SPECIFIC:
+		if (lum->lmm_stripe_count > LOV_MAX_STRIPE_COUNT)
+			return -EINVAL;
+
+		return lov_user_md_size(lum->lmm_stripe_count,
+					LOV_USER_MAGIC_SPECIFIC);
+	}
+	return -EINVAL;
+}
 
 /* llite/llite_nfs.c */
 extern const struct export_operations lustre_export_operations;
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 5cbce1b..3892d06 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -2507,6 +2507,36 @@ void ll_dirty_page_discard_warn(struct page *page, int ioret)
 		free_page((unsigned long)buf);
 }
 
+ssize_t ll_copy_user_md(const struct lov_user_md __user *md,
+			struct lov_user_md **kbuf)
+{
+	struct lov_user_md lum;
+	ssize_t lum_size;
+
+	if (copy_from_user(&lum, md, sizeof(lum))) {
+		lum_size = -EFAULT;
+		goto no_kbuf;
+	}
+
+	lum_size = ll_lov_user_md_size(&lum);
+	if (lum_size < 0)
+		goto no_kbuf;
+
+	*kbuf = kzalloc(lum_size, GFP_NOFS);
+	if (!*kbuf) {
+		lum_size = -ENOMEM;
+		goto no_kbuf;
+	}
+
+	if (copy_from_user(*kbuf, md, lum_size) != 0) {
+		kfree(*kbuf);
+		*kbuf = NULL;
+		lum_size = -EFAULT;
+	}
+no_kbuf:
+	return lum_size;
+}
+
 /*
  * Compute llite root squash state after a change of root squash
  * configuration setting or add/remove of a lnet nid
diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 0e6a559..e070adb 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -189,12 +189,15 @@ static int ll_xattr_set(const struct xattr_handler *handler,
 
 		if (lump && S_ISREG(inode->i_mode)) {
 			__u64 it_flags = FMODE_WRITE;
-			int lum_size = (lump->lmm_magic == LOV_USER_MAGIC_V1) ?
-				sizeof(*lump) : sizeof(struct lov_user_md_v3);
+			int lum_size;
+
+			lum_size = ll_lov_user_md_size(lump);
+			if (lum_size < 0 || size < lum_size)
+				return 0; /* b=10667: ignore error */
 
 			rc = ll_lov_setstripe_ea_info(inode, dentry, it_flags,
 						      lump, lum_size);
-			/* b10667: rc always be 0 here for now */
+			/* b=10667: rc always be 0 here for now */
 			rc = 0;
 		} else if (S_ISDIR(inode->i_mode)) {
 			rc = ll_dir_setstripe(inode, lump, 0);
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index c654810..595cf16 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -148,16 +148,11 @@ int lov_packmd(struct obd_export *exp, struct lov_mds_md **lmmp,
 			stripe_count = 0;
 		}
 	} else {
-		/* No need to allocate more than maximum supported stripes.
-		 * Anyway, this is pretty inaccurate since ld_tgt_count now
-		 * represents max index and we should rely on the actual number
-		 * of OSTs instead
+		/*
+		 * To calculate maximum easize by active targets at present,
+		 * which is exactly the maximum easize to be seen by LOV
 		 */
-		stripe_count = lov_mds_md_max_stripe_count(
-			lov->lov_ocd.ocd_max_easize, lmm_magic);
-
-		if (stripe_count > lov->desc.ld_tgt_count)
-			stripe_count = lov->desc.ld_tgt_count;
+		stripe_count = lov->desc.ld_active_tgt_count;
 	}
 
 	/* XXX LOV STACKING call into osc for sizes */
@@ -403,8 +398,9 @@ int lov_getstripe(struct obd_export *exp, struct lov_stripe_md *lsm,
 		rc = -EFAULT;
 		goto out_set;
 	}
-	if ((lum.lmm_magic != LOV_USER_MAGIC) &&
-	    (lum.lmm_magic != LOV_USER_MAGIC_V3)) {
+	if (lum.lmm_magic != LOV_USER_MAGIC_V1 &&
+	    lum.lmm_magic != LOV_USER_MAGIC_V3 &&
+	    lum.lmm_magic != LOV_USER_MAGIC_SPECIFIC) {
 		rc = -EINVAL;
 		goto out_set;
 	}
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index e25596f..87027c5 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -1916,19 +1916,6 @@ void lustre_swab_lmv_user_md(struct lmv_user_md *lum)
 }
 EXPORT_SYMBOL(lustre_swab_lmv_user_md);
 
-static void print_lum(struct lov_user_md *lum)
-{
-	CDEBUG(D_OTHER, "lov_user_md %p:\n", lum);
-	CDEBUG(D_OTHER, "\tlmm_magic: %#x\n", lum->lmm_magic);
-	CDEBUG(D_OTHER, "\tlmm_pattern: %#x\n", lum->lmm_pattern);
-	CDEBUG(D_OTHER, "\tlmm_object_id: %llu\n", lmm_oi_id(&lum->lmm_oi));
-	CDEBUG(D_OTHER, "\tlmm_object_gr: %llu\n", lmm_oi_seq(&lum->lmm_oi));
-	CDEBUG(D_OTHER, "\tlmm_stripe_size: %#x\n", lum->lmm_stripe_size);
-	CDEBUG(D_OTHER, "\tlmm_stripe_count: %#x\n", lum->lmm_stripe_count);
-	CDEBUG(D_OTHER, "\tlmm_stripe_offset/lmm_layout_gen: %#x\n",
-	       lum->lmm_stripe_offset);
-}
-
 static void lustre_swab_lmm_oi(struct ost_id *oi)
 {
 	__swab64s(&oi->oi.oi_id);
@@ -1943,7 +1930,6 @@ static void lustre_swab_lov_user_md_common(struct lov_user_md_v1 *lum)
 	__swab32s(&lum->lmm_stripe_size);
 	__swab16s(&lum->lmm_stripe_count);
 	__swab16s(&lum->lmm_stripe_offset);
-	print_lum(lum);
 }
 
 void lustre_swab_lov_user_md_v1(struct lov_user_md_v1 *lum)
-- 
1.7.1
