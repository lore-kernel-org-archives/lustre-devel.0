From: James Simmons <jsimmons@infradead.org>
Date: Mon,  4 Apr 2016 21:37:01 -0400
Subject: [lustre-devel] [PATCH 16/18] staging: lustre: hsm: Add support to
	drop all pages for ll_data_version
In-Reply-To: <1459820223-24754-1-git-send-email-jsimmons@infradead.org>
References: <1459820223-24754-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459820223-24754-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

This will be used by HSM release to get data version and drop all
caching pages from all clients, before sending IT_RELEASE close
REQ to MDT.

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3647
Reviewed-on: http://review.whamcloud.com/6794
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Aurelien Degremont <aurelien.degremont@cea.fr>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |    1 +
 .../lustre/lustre/include/lustre/lustre_user.h     |    5 +--
 drivers/staging/lustre/lustre/llite/dir.c          |    5 +--
 drivers/staging/lustre/lustre/llite/file.c         |   35 ++++++++++++--------
 .../staging/lustre/lustre/llite/llite_internal.h   |    2 +-
 drivers/staging/lustre/lustre/lov/lov_merge.c      |   11 ++++++
 6 files changed, 38 insertions(+), 21 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 12e6718..fa4cbbe 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1428,6 +1428,7 @@ enum obdo_flags {
 					   */
 	OBD_FL_RECOV_RESEND = 0x00080000, /* recoverable resent */
 	OBD_FL_NOSPC_BLK    = 0x00100000, /* no more block space on OST */
+	OBD_FL_FLUSH	    = 0x00200000, /* flush pages on the OST */
 
 	/* Note that while these checksum values are currently separate bits,
 	 * in 2.x we can actually allow all values from 1-31 if we wanted.
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index e4e42e1..59ba48a 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -838,9 +838,8 @@ struct ioc_data_version {
 	__u64 idv_flags;     /* See LL_DV_xxx */
 };
 
-#define LL_DV_NOFLUSH 0x01   /* Do not take READ EXTENT LOCK before sampling
-			      * version. Dirty caches are left unchanged.
-			      */
+#define LL_DV_RD_FLUSH	BIT(0)	/* Flush dirty pages from clients */
+#define LL_DV_WR_FLUSH	BIT(1)	/* Flush all caching pages from clients */
 
 #ifndef offsetof
 # define offsetof(typ, memb)     ((unsigned long)((char *)&(((typ *)0)->memb)))
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 7251bef..45bdf8f 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -941,7 +941,7 @@ static int ll_ioc_copy_start(struct super_block *sb, struct hsm_copy *copy)
 		}
 
 		/* Read current file data version */
-		rc = ll_data_version(inode, &data_version, 1);
+		rc = ll_data_version(inode, &data_version, LL_DV_RD_FLUSH);
 		iput(inode);
 		if (rc != 0) {
 			CDEBUG(D_HSM, "Could not read file data version of "
@@ -1025,8 +1025,7 @@ static int ll_ioc_copy_end(struct super_block *sb, struct hsm_copy *copy)
 			goto progress;
 		}
 
-		rc = ll_data_version(inode, &data_version,
-				     copy->hc_hai.hai_action == HSMA_ARCHIVE);
+		rc = ll_data_version(inode, &data_version, LL_DV_RD_FLUSH);
 		iput(inode);
 		if (rc) {
 			CDEBUG(D_HSM, "Could not read file data version. Request could not be confirmed.\n");
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index ac17360..9b553d2 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -929,7 +929,7 @@ static int ll_lease_close(struct obd_client_handle *och, struct inode *inode,
 
 /* Fills the obdo with the attributes for the lsm */
 static int ll_lsm_getattr(struct lov_stripe_md *lsm, struct obd_export *exp,
-			  struct obdo *obdo, __u64 ioepoch, int sync)
+			  struct obdo *obdo, __u64 ioepoch, int dv_flags)
 {
 	struct ptlrpc_request_set *set;
 	struct obd_info	    oinfo = { };
@@ -948,9 +948,11 @@ static int ll_lsm_getattr(struct lov_stripe_md *lsm, struct obd_export *exp,
 			       OBD_MD_FLMTIME | OBD_MD_FLCTIME |
 			       OBD_MD_FLGROUP | OBD_MD_FLEPOCH |
 			       OBD_MD_FLDATAVERSION;
-	if (sync) {
+	if (dv_flags & (LL_DV_WR_FLUSH | LL_DV_RD_FLUSH)) {
 		oinfo.oi_oa->o_valid |= OBD_MD_FLFLAGS;
 		oinfo.oi_oa->o_flags |= OBD_FL_SRVLOCK;
+		if (dv_flags & LL_DV_WR_FLUSH)
+			oinfo.oi_oa->o_flags |= OBD_FL_FLUSH;
 	}
 
 	set = ptlrpc_prep_set();
@@ -963,11 +965,16 @@ static int ll_lsm_getattr(struct lov_stripe_md *lsm, struct obd_export *exp,
 			rc = ptlrpc_set_wait(set);
 		ptlrpc_set_destroy(set);
 	}
-	if (rc == 0)
+	if (rc == 0) {
 		oinfo.oi_oa->o_valid &= (OBD_MD_FLBLOCKS | OBD_MD_FLBLKSZ |
 					 OBD_MD_FLATIME | OBD_MD_FLMTIME |
 					 OBD_MD_FLCTIME | OBD_MD_FLSIZE |
-					 OBD_MD_FLDATAVERSION);
+					 OBD_MD_FLDATAVERSION | OBD_MD_FLFLAGS);
+		if (dv_flags & LL_DV_WR_FLUSH &&
+		    !(oinfo.oi_oa->o_valid & OBD_MD_FLFLAGS &&
+		      oinfo.oi_oa->o_flags & OBD_FL_FLUSH))
+			return -ENOTSUPP;
+	}
 	return rc;
 }
 
@@ -983,7 +990,7 @@ int ll_inode_getattr(struct inode *inode, struct obdo *obdo,
 
 	lsm = ccc_inode_lsm_get(inode);
 	rc = ll_lsm_getattr(lsm, ll_i2dtexp(inode),
-			    obdo, ioepoch, sync);
+			    obdo, ioepoch, sync ? LL_DV_RD_FLUSH : 0);
 	if (rc == 0) {
 		struct ost_id *oi = lsm ? &lsm->lsm_oi : &obdo->o_oi;
 
@@ -1874,11 +1881,12 @@ error:
  * This value is computed using stripe object version on OST.
  * Version is computed using server side locking.
  *
- * @param extent_lock  Take extent lock. Not needed if a process is already
- *		       holding the OST object group locks.
+ * @param sync  if do sync on the OST side;
+ *		0: no sync
+ *		LL_DV_RD_FLUSH: flush dirty pages, LCK_PR on OSTs
+ *		LL_DV_WR_FLUSH: drop all caching pages, LCK_PW on OSTs
  */
-int ll_data_version(struct inode *inode, __u64 *data_version,
-		    int extent_lock)
+int ll_data_version(struct inode *inode, __u64 *data_version, int flags)
 {
 	struct lov_stripe_md	*lsm = NULL;
 	struct ll_sb_info	*sbi = ll_i2sbi(inode);
@@ -1900,7 +1908,7 @@ int ll_data_version(struct inode *inode, __u64 *data_version,
 		goto out;
 	}
 
-	rc = ll_lsm_getattr(lsm, sbi->ll_dt_exp, obdo, 0, extent_lock);
+	rc = ll_lsm_getattr(lsm, sbi->ll_dt_exp, obdo, 0, flags);
 	if (rc == 0) {
 		if (!(obdo->o_valid & OBD_MD_FLDATAVERSION))
 			rc = -EOPNOTSUPP;
@@ -1936,7 +1944,7 @@ int ll_hsm_release(struct inode *inode)
 	}
 
 	/* Grab latest data_version and [am]time values */
-	rc = ll_data_version(inode, &data_version, 1);
+	rc = ll_data_version(inode, &data_version, LL_DV_WR_FLUSH);
 	if (rc != 0)
 		goto out;
 
@@ -2344,9 +2352,8 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		if (copy_from_user(&idv, (char __user *)arg, sizeof(idv)))
 			return -EFAULT;
 
-		rc = ll_data_version(inode, &idv.idv_version,
-				     !(idv.idv_flags & LL_DV_NOFLUSH));
-
+		idv.idv_flags &= LL_DV_RD_FLUSH | LL_DV_WR_FLUSH;
+		rc = ll_data_version(inode, &idv.idv_version, idv.idv_flags);
 		if (rc == 0 && copy_to_user((char __user *)arg, &idv,
 					    sizeof(idv)))
 			return -EFAULT;
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index ccbb9be..d67c8c0 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -757,7 +757,7 @@ int ll_dir_getstripe(struct inode *inode, struct lov_mds_md **lmmp,
 int ll_fsync(struct file *file, loff_t start, loff_t end, int data);
 int ll_merge_attr(const struct lu_env *env, struct inode *inode);
 int ll_fid2path(struct inode *inode, void __user *arg);
-int ll_data_version(struct inode *inode, __u64 *data_version, int extent_lock);
+int ll_data_version(struct inode *inode, __u64 *data_version, int flags);
 int ll_hsm_release(struct inode *inode);
 
 /* llite/dcache.c */
diff --git a/drivers/staging/lustre/lustre/lov/lov_merge.c b/drivers/staging/lustre/lustre/lov/lov_merge.c
index 029cd4d..56ef41d 100644
--- a/drivers/staging/lustre/lustre/lov/lov_merge.c
+++ b/drivers/staging/lustre/lustre/lov/lov_merge.c
@@ -154,6 +154,7 @@ void lov_merge_attrs(struct obdo *tgt, struct obdo *src, u64 valid,
 	valid &= src->o_valid;
 
 	if (*set) {
+		tgt->o_valid &= valid;
 		if (valid & OBD_MD_FLSIZE) {
 			/* this handles sparse files properly */
 			u64 lov_size;
@@ -172,12 +173,22 @@ void lov_merge_attrs(struct obdo *tgt, struct obdo *src, u64 valid,
 			tgt->o_mtime = src->o_mtime;
 		if (valid & OBD_MD_FLDATAVERSION)
 			tgt->o_data_version += src->o_data_version;
+
+		/* handle flags */
+		if (valid & OBD_MD_FLFLAGS)
+			tgt->o_flags &= src->o_flags;
+		else
+			tgt->o_flags = 0;
 	} else {
 		memcpy(tgt, src, sizeof(*tgt));
 		tgt->o_oi = lsm->lsm_oi;
+		tgt->o_valid = valid;
 		if (valid & OBD_MD_FLSIZE)
 			tgt->o_size = lov_stripe_size(lsm, src->o_size,
 						      stripeno);
+		tgt->o_flags = 0;
+		if (valid & OBD_MD_FLFLAGS)
+			tgt->o_flags = src->o_flags;
 	}
 
 	/* data_version needs to be valid on all stripes to be correct! */
-- 
1.7.1
