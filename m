From: James Simmons <jsimmons@infradead.org>
Date: Wed, 27 Apr 2016 18:21:01 -0400
Subject: [lustre-devel] [PATCH 09/15] staging: lustre: llite: Replace
	printing of i_ino with ll_inode2fid()
In-Reply-To: <1461795667-29035-1-git-send-email-jsimmons@infradead.org>
References: <1461795667-29035-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1461795667-29035-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Nunez <james.a.nunez@intel.com>, James Simmons <jsimmons@infradead.org>

From: James Nunez <james.a.nunez@intel.com>

The printing of i_ino/i_generation in llite messages is not nearly so
useful as printing the full inode FID, since i_ino is a "compressed"
version of the FID and there may be duplicate values for i_ino in some
cases (especially if running on a 32-bit client).

All instances of printing i_ino/i_generation are replaced with
the FID using ll_inode2fid(). All instances, except for one, of
printing just i_ino was replaced by printing the FID. In all
CERROR lines touched by the i_ino replacements, the device name
or fsname was added at the beginning of the message if it did not
already exist.

Signed-off-by: James Nunez <james.a.nunez@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3491
Reviewed-on: http://review.whamcloud.com/6848
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/llite/dcache.c       |    8 +-
 drivers/staging/lustre/lustre/llite/dir.c          |   23 +++---
 drivers/staging/lustre/lustre/llite/file.c         |   70 +++++++++---------
 drivers/staging/lustre/lustre/llite/llite_close.c  |   40 ++++++-----
 .../staging/lustre/lustre/llite/llite_internal.h   |   10 +--
 drivers/staging/lustre/lustre/llite/llite_lib.c    |   40 ++++++-----
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |    6 +-
 drivers/staging/lustre/lustre/llite/llite_nfs.c    |   14 +++--
 drivers/staging/lustre/lustre/llite/namei.c        |   76 +++++++++-----------
 drivers/staging/lustre/lustre/llite/rw26.c         |    5 +-
 drivers/staging/lustre/lustre/llite/statahead.c    |   17 ++---
 drivers/staging/lustre/lustre/llite/symlink.c      |   10 ++-
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |    5 +-
 drivers/staging/lustre/lustre/llite/xattr.c        |   20 +++---
 14 files changed, 174 insertions(+), 170 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dcache.c b/drivers/staging/lustre/lustre/llite/dcache.c
index 5596b13..1b6f82a 100644
--- a/drivers/staging/lustre/lustre/llite/dcache.c
+++ b/drivers/staging/lustre/lustre/llite/dcache.c
@@ -250,8 +250,8 @@ void ll_invalidate_aliases(struct inode *inode)
 {
 	struct dentry *dentry;
 
-	CDEBUG(D_INODE, "marking dentries for ino %lu/%u(%p) invalid\n",
-	       inode->i_ino, inode->i_generation, inode);
+	CDEBUG(D_INODE, "marking dentries for ino "DFID"(%p) invalid\n",
+	       PFID(ll_inode2fid(inode)), inode);
 
 	ll_lock_dcache(inode);
 	hlist_for_each_entry(dentry, &inode->i_dentry, d_u.d_alias) {
@@ -286,8 +286,8 @@ void ll_lookup_finish_locks(struct lookup_intent *it, struct inode *inode)
 	if (it->d.lustre.it_lock_mode && inode) {
 		struct ll_sb_info *sbi = ll_i2sbi(inode);
 
-		CDEBUG(D_DLMTRACE, "setting l_data to inode %p (%lu/%u)\n",
-		       inode, inode->i_ino, inode->i_generation);
+		CDEBUG(D_DLMTRACE, "setting l_data to inode "DFID"(%p)\n",
+		       PFID(ll_inode2fid(inode)), inode);
 		ll_set_lock_data(sbi->ll_md_exp, inode, it, NULL);
 	}
 
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index b457c28..9463da2 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -158,8 +158,8 @@ static int ll_dir_filler(void *_hash, struct page *page0)
 	int i;
 	int rc;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode=%lu/%u(%p) hash %llu\n",
-	       inode->i_ino, inode->i_generation, inode, hash);
+	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p) hash %llu\n",
+	       PFID(ll_inode2fid(inode)), inode, hash);
 
 	LASSERT(max_pages > 0 && max_pages <= MD_MAX_BRW_PAGES);
 
@@ -372,8 +372,8 @@ struct page *ll_get_dir_page(struct inode *dir, __u64 hash,
 			return ERR_PTR(rc);
 		}
 
-		CDEBUG(D_INODE, "setting lr_lvb_inode to inode %p (%lu/%u)\n",
-		       dir, dir->i_ino, dir->i_generation);
+		CDEBUG(D_INODE, "setting lr_lvb_inode to inode "DFID"(%p)\n",
+		       PFID(ll_inode2fid(dir)), dir);
 		md_set_lock_data(ll_i2sbi(dir)->ll_md_exp,
 				 &it.d.lustre.it_lock_handle, dir, NULL);
 	} else {
@@ -616,9 +616,9 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
 	int			api32	= ll_need_32bit_api(sbi);
 	int			rc;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode=%lu/%u(%p) pos %lu/%llu 32bit_api %d\n",
-	       inode->i_ino, inode->i_generation,
-	       inode, (unsigned long)pos, i_size_read(inode), api32);
+	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p) pos %lu/%llu 32bit_api %d\n",
+	       PFID(ll_inode2fid(inode)), inode, (unsigned long)pos,
+	       i_size_read(inode), api32);
 
 	if (pos == MDS_DIR_END_OFF) {
 		/*
@@ -828,9 +828,8 @@ int ll_dir_getstripe(struct inode *inode, struct lov_mds_md **lmmp,
 	rc = md_getattr(sbi->ll_md_exp, op_data, &req);
 	ll_finish_md_op_data(op_data);
 	if (rc < 0) {
-		CDEBUG(D_INFO, "md_getattr failed on inode %lu/%u: rc %d\n",
-		       inode->i_ino,
-		       inode->i_generation, rc);
+		CDEBUG(D_INFO, "md_getattr failed on inode "DFID": rc %d\n",
+		       PFID(ll_inode2fid(inode)), rc);
 		goto out;
 	}
 
@@ -1267,8 +1266,8 @@ static long ll_dir_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	struct obd_ioctl_data *data;
 	int rc = 0;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode=%lu/%u(%p), cmd=%#x\n",
-	       inode->i_ino, inode->i_generation, inode, cmd);
+	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p), cmd=%#x\n",
+	       PFID(ll_inode2fid(inode)), inode, cmd);
 
 	/* asm-ppc{,64} declares TCGETS, et. al. as type 't' not 'T' */
 	if (_IOC_TYPE(cmd) == 'T' || _IOC_TYPE(cmd) == 't') /* tty ioctls */
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 18e0fec..a8de10e 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -170,13 +170,15 @@ static int ll_close_inode_openhandle(struct obd_export *md_exp,
 		 */
 		rc = ll_som_update(inode, op_data);
 		if (rc) {
-			CERROR("inode %lu mdc Size-on-MDS update failed: rc = %d\n",
-			       inode->i_ino, rc);
+			CERROR("%s: inode "DFID" mdc Size-on-MDS update failed: rc = %d\n",
+			       ll_i2mdexp(inode)->exp_obd->obd_name,
+			       PFID(ll_inode2fid(inode)), rc);
 			rc = 0;
 		}
 	} else if (rc) {
-		CERROR("inode %lu mdc close failed: rc = %d\n",
-		       inode->i_ino, rc);
+		CERROR("%s: inode "DFID" mdc close failed: rc = %d\n",
+		       ll_i2mdexp(inode)->exp_obd->obd_name,
+		       PFID(ll_inode2fid(inode)), rc);
 	}
 
 	/* DATA_MODIFIED flag was successfully sent on close, cancel data
@@ -343,8 +345,8 @@ int ll_file_release(struct inode *inode, struct file *file)
 	struct ll_inode_info *lli = ll_i2info(inode);
 	int rc;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode=%lu/%u(%p)\n", inode->i_ino,
-	       inode->i_generation, inode);
+	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p)\n",
+	       PFID(ll_inode2fid(inode)), inode);
 
 #ifdef CONFIG_FS_POSIX_ACL
 	if (sbi->ll_flags & LL_SBI_RMT_CLIENT && is_root_inode(inode)) {
@@ -543,8 +545,8 @@ int ll_file_open(struct inode *inode, struct file *file)
 	struct ll_file_data *fd;
 	int rc = 0, opendir_set = 0;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode=%lu/%u(%p), flags %o\n", inode->i_ino,
-	       inode->i_generation, inode, file->f_flags);
+	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p), flags %o\n",
+	       PFID(ll_inode2fid(inode)), inode, file->f_flags);
 
 	it = file->private_data; /* XXX: compat macro */
 	file->private_data = NULL; /* prevent ll_local_open assertion */
@@ -1383,8 +1385,8 @@ int ll_lov_setstripe_ea_info(struct inode *inode, struct dentry *dentry,
 	lsm = ccc_inode_lsm_get(inode);
 	if (lsm) {
 		ccc_inode_lsm_put(inode, lsm);
-		CDEBUG(D_IOCTL, "stripe already exists for ino %lu\n",
-		       inode->i_ino);
+		CDEBUG(D_IOCTL, "stripe already exists for inode "DFID"\n",
+		       PFID(ll_inode2fid(inode)));
 		rc = -EEXIST;
 		goto out;
 	}
@@ -2248,8 +2250,8 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	struct ll_file_data	*fd = LUSTRE_FPRIVATE(file);
 	int			 flags, rc;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode=%lu/%u(%p),cmd=%x\n", inode->i_ino,
-	       inode->i_generation, inode, cmd);
+	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p),cmd=%x\n",
+	       PFID(ll_inode2fid(inode)), inode, cmd);
 	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_IOCTL, 1);
 
 	/* asm-ppc{,64} declares TCGETS, et. al. as type 't' not 'T' */
@@ -2557,9 +2559,8 @@ static loff_t ll_file_seek(struct file *file, loff_t offset, int origin)
 
 	retval = offset + ((origin == SEEK_END) ? i_size_read(inode) :
 			   (origin == SEEK_CUR) ? file->f_pos : 0);
-	CDEBUG(D_VFSTRACE, "VFS Op:inode=%lu/%u(%p), to=%llu=%#llx(%d)\n",
-	       inode->i_ino, inode->i_generation, inode, retval, retval,
-	       origin);
+	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p), to=%llu=%#llx(%d)\n",
+	       PFID(ll_inode2fid(inode)), inode, retval, retval, origin);
 	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_LLSEEK, 1);
 
 	if (origin == SEEK_END || origin == SEEK_HOLE || origin == SEEK_DATA) {
@@ -2654,8 +2655,8 @@ int ll_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 	struct ptlrpc_request *req;
 	int rc, err;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode=%lu/%u(%p)\n", inode->i_ino,
-	       inode->i_generation, inode);
+	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p)\n",
+	       PFID(ll_inode2fid(inode)), inode);
 	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_FSYNC, 1);
 
 	rc = filemap_write_and_wait_range(inode->i_mapping, start, end);
@@ -2713,8 +2714,8 @@ ll_file_flock(struct file *file, int cmd, struct file_lock *file_lock)
 	int rc;
 	int rc2 = 0;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode=%lu file_lock=%p\n",
-	       inode->i_ino, file_lock);
+	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID" file_lock=%p\n",
+	       PFID(ll_inode2fid(inode)), file_lock);
 
 	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_FLOCK, 1);
 
@@ -2797,9 +2798,9 @@ ll_file_flock(struct file *file, int cmd, struct file_lock *file_lock)
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
-	CDEBUG(D_DLMTRACE, "inode=%lu, pid=%u, flags=%#llx, mode=%u, start=%llu, end=%llu\n",
-	       inode->i_ino, flock.l_flock.pid, flags, einfo.ei_mode,
-	       flock.l_flock.start, flock.l_flock.end);
+	CDEBUG(D_DLMTRACE, "inode="DFID", pid=%u, flags=%#llx, mode=%u, start=%llu, end=%llu\n",
+	       PFID(ll_inode2fid(inode)), flock.l_flock.pid, flags,
+	       einfo.ei_mode, flock.l_flock.start, flock.l_flock.end);
 
 	rc = md_enqueue(sbi->ll_md_exp, &einfo, NULL,
 			op_data, &lockh, &flock, 0, NULL /* req */, flags);
@@ -2921,8 +2922,8 @@ static int __ll_inode_revalidate(struct dentry *dentry, __u64 ibits)
 	struct obd_export *exp;
 	int rc = 0;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode=%lu/%u(%p),name=%pd\n",
-	       inode->i_ino, inode->i_generation, inode, dentry);
+	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p),name=%pd\n",
+	       PFID(ll_inode2fid(inode)), inode, dentry);
 
 	exp = ll_i2mdexp(inode);
 
@@ -3144,8 +3145,8 @@ int ll_inode_permission(struct inode *inode, int mask)
 			return rc;
 	}
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode=%lu/%u(%p), inode mode %x mask %o\n",
-	       inode->i_ino, inode->i_generation, inode, inode->i_mode, mask);
+	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p), inode mode %x mask %o\n",
+	       PFID(ll_inode2fid(inode)), inode, inode->i_mode, mask);
 
 	if (ll_i2sbi(inode)->ll_flags & LL_SBI_RMT_CLIENT)
 		return lustre_check_remote_perm(inode, mask);
@@ -3435,8 +3436,8 @@ static int ll_layout_lock_set(struct lustre_handle *lockh, enum ldlm_mode mode,
 	LASSERT(lock);
 	LASSERT(ldlm_has_layout(lock));
 
-	LDLM_DEBUG(lock, "File %p/"DFID" being reconfigured: %d",
-		   inode, PFID(&lli->lli_fid), reconf);
+	LDLM_DEBUG(lock, "File "DFID"(%p) being reconfigured: %d",
+		   PFID(&lli->lli_fid), inode, reconf);
 
 	/* in case this is a caching lock and reinstate with new inode */
 	md_set_lock_data(sbi->ll_md_exp, &lockh->cookie, inode, NULL);
@@ -3507,9 +3508,9 @@ out:
 
 	/* wait for IO to complete if it's still being used. */
 	if (wait_layout) {
-		CDEBUG(D_INODE, "%s: %p/" DFID " wait for layout reconf.\n",
+		CDEBUG(D_INODE, "%s: "DFID"(%p) wait for layout reconf\n",
 		       ll_get_fsname(inode->i_sb, NULL, 0),
-		       inode, PFID(&lli->lli_fid));
+		       PFID(&lli->lli_fid), inode);
 
 		memset(&conf, 0, sizeof(conf));
 		conf.coc_opc = OBJECT_CONF_WAIT;
@@ -3518,7 +3519,8 @@ out:
 		if (rc == 0)
 			rc = -EAGAIN;
 
-		CDEBUG(D_INODE, "file: " DFID " waiting layout return: %d.\n",
+		CDEBUG(D_INODE, "%s: file="DFID" waiting layout return: %d.\n",
+		       ll_get_fsname(inode->i_sb, NULL, 0),
 		       PFID(&lli->lli_fid), rc);
 	}
 	return rc;
@@ -3591,9 +3593,9 @@ again:
 	it.it_op = IT_LAYOUT;
 	lockh.cookie = 0ULL;
 
-	LDLM_DEBUG_NOLOCK("%s: requeue layout lock for file %p/" DFID "",
-			  ll_get_fsname(inode->i_sb, NULL, 0), inode,
-			PFID(&lli->lli_fid));
+	LDLM_DEBUG_NOLOCK("%s: requeue layout lock for file "DFID"(%p)",
+			  ll_get_fsname(inode->i_sb, NULL, 0),
+			  PFID(&lli->lli_fid), inode);
 
 	rc = md_enqueue(sbi->ll_md_exp, &einfo, &it, op_data, &lockh,
 			NULL, 0, NULL, 0);
diff --git a/drivers/staging/lustre/lustre/llite/llite_close.c b/drivers/staging/lustre/lustre/llite/llite_close.c
index 92b73ef..2df551d 100644
--- a/drivers/staging/lustre/lustre/llite/llite_close.c
+++ b/drivers/staging/lustre/lustre/llite/llite_close.c
@@ -90,15 +90,15 @@ void ll_queue_done_writing(struct inode *inode, unsigned long flags)
 		struct ll_close_queue *lcq = ll_i2sbi(inode)->ll_lcq;
 
 		if (lli->lli_flags & LLIF_MDS_SIZE_LOCK)
-			CWARN("ino %lu/%u(flags %u) som valid it just after recovery\n",
-			      inode->i_ino, inode->i_generation,
-			      lli->lli_flags);
+			CWARN("%s: file "DFID"(flags %u) Size-on-MDS valid, done writing allowed and no diry pages\n",
+			      ll_get_fsname(inode->i_sb, NULL, 0),
+			      PFID(ll_inode2fid(inode)), lli->lli_flags);
 		/* DONE_WRITING is allowed and inode has no dirty page. */
 		spin_lock(&lcq->lcq_lock);
 
 		LASSERT(list_empty(&lli->lli_close_list));
-		CDEBUG(D_INODE, "adding inode %lu/%u to close list\n",
-		       inode->i_ino, inode->i_generation);
+		CDEBUG(D_INODE, "adding inode "DFID" to close list\n",
+		       PFID(ll_inode2fid(inode)));
 		list_add_tail(&lli->lli_close_list, &lcq->lcq_head);
 
 		/* Avoid a concurrent insertion into the close thread queue:
@@ -124,9 +124,9 @@ void ll_done_writing_attr(struct inode *inode, struct md_op_data *op_data)
 	op_data->op_flags |= MF_SOM_CHANGE;
 	/* Check if Size-on-MDS attributes are valid. */
 	if (lli->lli_flags & LLIF_MDS_SIZE_LOCK)
-		CERROR("ino %lu/%u(flags %u) som valid it just after recovery\n",
-		       inode->i_ino, inode->i_generation,
-		       lli->lli_flags);
+		CERROR("%s: inode "DFID"(flags %u) MDS holds lock on Size-on-MDS attributes\n",
+		       ll_get_fsname(inode->i_sb, NULL, 0),
+		       PFID(ll_inode2fid(inode)), lli->lli_flags);
 
 	if (!cl_local_size(inode)) {
 		/* Send Size-on-MDS Attributes if valid. */
@@ -221,9 +221,9 @@ int ll_som_update(struct inode *inode, struct md_op_data *op_data)
 
 	LASSERT(op_data);
 	if (lli->lli_flags & LLIF_MDS_SIZE_LOCK)
-		CERROR("ino %lu/%u(flags %u) som valid it just after recovery\n",
-		       inode->i_ino, inode->i_generation,
-		       lli->lli_flags);
+		CERROR("%s: inode "DFID"(flags %u) MDS holds lock on Size-on-MDS attributes\n",
+		       ll_get_fsname(inode->i_sb, NULL, 0),
+		       PFID(ll_inode2fid(inode)), lli->lli_flags);
 
 	oa = kmem_cache_zalloc(obdo_cachep, GFP_NOFS);
 	if (!oa) {
@@ -241,9 +241,9 @@ int ll_som_update(struct inode *inode, struct md_op_data *op_data)
 		if (rc) {
 			oa->o_valid = 0;
 			if (rc != -ENOENT)
-				CERROR("inode_getattr failed (%d): unable to send a Size-on-MDS attribute update for inode %lu/%u\n",
-				       rc, inode->i_ino,
-				       inode->i_generation);
+				CERROR("%s: inode_getattr failed - unable to send a Size-on-MDS attribute update for inode "DFID": rc = %d\n",
+				       ll_get_fsname(inode->i_sb, NULL, 0),
+				       PFID(ll_inode2fid(inode)), rc);
 		} else {
 			CDEBUG(D_INODE, "Size-on-MDS update on "DFID"\n",
 			       PFID(&lli->lli_fid));
@@ -302,9 +302,11 @@ static void ll_done_writing(struct inode *inode)
 		 * OSTs and send setattr to back to MDS.
 		 */
 		rc = ll_som_update(inode, op_data);
-	else if (rc)
-		CERROR("inode %lu mdc done_writing failed: rc = %d\n",
-		       inode->i_ino, rc);
+	else if (rc) {
+		CERROR("%s: inode "DFID" mdc done_writing failed: rc = %d\n",
+		       ll_get_fsname(inode->i_sb, NULL, 0),
+		       PFID(ll_inode2fid(inode)), rc);
+	}
 out:
 	ll_finish_md_op_data(op_data);
 	if (och) {
@@ -349,8 +351,8 @@ static int ll_close_thread(void *arg)
 			break;
 
 		inode = ll_info2i(lli);
-		CDEBUG(D_INFO, "done_writing for inode %lu/%u\n",
-		       inode->i_ino, inode->i_generation);
+		CDEBUG(D_INFO, "done_writing for inode "DFID"\n",
+		       PFID(ll_inode2fid(inode)));
 		ll_done_writing(inode);
 		iput(inode);
 	}
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 22e9989..2c6ae05 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -1288,18 +1288,16 @@ static inline void ll_set_lock_data(struct obd_export *exp, struct inode *inode,
 		 */
 		if (it->d.lustre.it_remote_lock_mode) {
 			handle.cookie = it->d.lustre.it_remote_lock_handle;
-			CDEBUG(D_DLMTRACE, "setting l_data to inode %p(%lu/%u) for remote lock %#llx\n",
-			       inode,
-			       inode->i_ino, inode->i_generation,
+			CDEBUG(D_DLMTRACE, "setting l_data to inode "DFID"%p for remote lock %#llx\n",
+			       PFID(ll_inode2fid(inode)), inode,
 			       handle.cookie);
 			md_set_lock_data(exp, &handle.cookie, inode, NULL);
 		}
 
 		handle.cookie = it->d.lustre.it_lock_handle;
 
-		CDEBUG(D_DLMTRACE, "setting l_data to inode %p (%lu/%u) for lock %#llx\n",
-		       inode, inode->i_ino,
-		       inode->i_generation, handle.cookie);
+		CDEBUG(D_DLMTRACE, "setting l_data to inode "DFID"%p for lock %#llx\n",
+		       PFID(ll_inode2fid(inode)), inode, handle.cookie);
 
 		md_set_lock_data(exp, &handle.cookie, inode,
 				 &it->d.lustre.it_lock_bits);
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 9f338b1..55cddc7 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1033,8 +1033,8 @@ void ll_clear_inode(struct inode *inode)
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode=%lu/%u(%p)\n", inode->i_ino,
-	       inode->i_generation, inode);
+	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p)\n",
+	       PFID(ll_inode2fid(inode)), inode);
 
 	if (S_ISDIR(inode->i_mode)) {
 		/* these should have been cleared in ll_file_release */
@@ -1181,9 +1181,11 @@ static int ll_setattr_done_writing(struct inode *inode,
 		 * from OSTs and send setattr to back to MDS.
 		 */
 		rc = ll_som_update(inode, op_data);
-	else if (rc)
-		CERROR("inode %lu mdc truncate failed: rc = %d\n",
-		       inode->i_ino, rc);
+	else if (rc) {
+		CERROR("%s: inode "DFID" mdc truncate failed: rc = %d\n",
+		      ll_i2sbi(inode)->ll_md_exp->exp_obd->obd_name,
+		      PFID(ll_inode2fid(inode)), rc);
+	}
 	return rc;
 }
 
@@ -1211,12 +1213,9 @@ int ll_setattr_raw(struct dentry *dentry, struct iattr *attr, bool hsm_import)
 	bool file_is_released = false;
 	int rc = 0, rc1 = 0;
 
-	CDEBUG(D_VFSTRACE,
-	       "%s: setattr inode %p/fid:" DFID
-	       " from %llu to %llu, valid %x, hsm_import %d\n",
-	       ll_get_fsname(inode->i_sb, NULL, 0), inode,
-	       PFID(&lli->lli_fid), i_size_read(inode), attr->ia_size,
-	       attr->ia_valid, hsm_import);
+	CDEBUG(D_VFSTRACE, "%s: setattr inode "DFID"(%p) from %llu to %llu, valid %x, hsm_import %d\n",
+	       ll_get_fsname(inode->i_sb, NULL, 0), PFID(&lli->lli_fid), inode,
+	       i_size_read(inode), attr->ia_size, attr->ia_valid, hsm_import);
 
 	if (attr->ia_valid & ATTR_SIZE) {
 		/* Check new size against VFS/VM file size limit and rlimit */
@@ -1590,10 +1589,9 @@ void ll_update_inode(struct inode *inode, struct lustre_md *md)
 		/* FID shouldn't be changed! */
 		if (fid_is_sane(&lli->lli_fid)) {
 			LASSERTF(lu_fid_eq(&lli->lli_fid, &body->fid1),
-				 "Trying to change FID "DFID
-				 " to the "DFID", inode %lu/%u(%p)\n",
+				 "Trying to change FID "DFID" to the "DFID", inode "DFID"(%p)\n",
 				 PFID(&lli->lli_fid), PFID(&body->fid1),
-				 inode->i_ino, inode->i_generation, inode);
+				 PFID(ll_inode2fid(inode)), inode);
 		} else {
 			lli->lli_fid = body->fid1;
 		}
@@ -1620,8 +1618,10 @@ void ll_update_inode(struct inode *inode, struct lustre_md *md)
 				if (lli->lli_flags & (LLIF_DONE_WRITING |
 						      LLIF_EPOCH_PENDING |
 						      LLIF_SOM_DIRTY)) {
-					CERROR("ino %lu flags %u still has size authority! do not trust the size got from MDS\n",
-					       inode->i_ino, lli->lli_flags);
+					CERROR("%s: inode "DFID" flags %u still has size authority! do not trust the size got from MDS\n",
+					       sbi->ll_md_exp->exp_obd->obd_name,
+					       PFID(ll_inode2fid(inode)),
+					       lli->lli_flags);
 				} else {
 					/* Use old size assignment to avoid
 					 * deadlock bz14138 & bz14326
@@ -1713,8 +1713,8 @@ void ll_delete_inode(struct inode *inode)
 		spin_lock_irq(&inode->i_data.tree_lock);
 		spin_unlock_irq(&inode->i_data.tree_lock);
 		LASSERTF(inode->i_data.nrpages == 0,
-			 "inode=%lu/%u(%p) nrpages=%lu, see http://jira.whamcloud.com/browse/LU-118\n",
-			 inode->i_ino, inode->i_generation, inode,
+			 "inode="DFID"(%p) nrpages=%lu, see http://jira.whamcloud.com/browse/LU-118\n",
+			 PFID(ll_inode2fid(inode)), inode,
 			 inode->i_data.nrpages);
 	}
 	/* Workaround end */
@@ -1745,7 +1745,9 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 		rc = md_getattr(sbi->ll_md_exp, op_data, &req);
 		ll_finish_md_op_data(op_data);
 		if (rc) {
-			CERROR("failure %d inode %lu\n", rc, inode->i_ino);
+			CERROR("%s: failure inode "DFID": rc = %d\n",
+			       sbi->ll_md_exp->exp_obd->obd_name,
+			       PFID(ll_inode2fid(inode)), rc);
 			return -abs(rc);
 		}
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index 4f6697a..88ef1ca 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -394,9 +394,11 @@ static int ll_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 		result = ll_page_mkwrite0(vma, vmf->page, &retry);
 
 		if (!printed && ++count > 16) {
-			CWARN("app(%s): the page %lu of file %lu is under heavy contention.\n",
+			const struct dentry *de = vma->vm_file->f_path.dentry;
+
+			CWARN("app(%s): the page %lu of file "DFID" is under heavy contention\n",
 			      current->comm, vmf->pgoff,
-			      file_inode(vma->vm_file)->i_ino);
+			      PFID(ll_inode2fid(de->d_inode)));
 			printed = true;
 		}
 	} while (retry);
diff --git a/drivers/staging/lustre/lustre/llite/llite_nfs.c b/drivers/staging/lustre/lustre/llite/llite_nfs.c
index 2c26815..61cb5ff 100644
--- a/drivers/staging/lustre/lustre/llite/llite_nfs.c
+++ b/drivers/staging/lustre/lustre/llite/llite_nfs.c
@@ -191,8 +191,9 @@ static int ll_encode_fh(struct inode *inode, __u32 *fh, int *plen,
 	int fileid_len = sizeof(struct lustre_nfs_fid) / 4;
 	struct lustre_nfs_fid *nfs_fid = (void *)fh;
 
-	CDEBUG(D_INFO, "encoding for (%lu," DFID ") maxlen=%d minlen=%d\n",
-	       inode->i_ino, PFID(ll_inode2fid(inode)), *plen, fileid_len);
+	CDEBUG(D_INFO, "%s: encoding for ("DFID") maxlen=%d minlen=%d\n",
+	       ll_get_fsname(inode->i_sb, NULL, 0),
+	       PFID(ll_inode2fid(inode)), *plen, fileid_len);
 
 	if (*plen < fileid_len) {
 		*plen = fileid_len;
@@ -298,8 +299,9 @@ static struct dentry *ll_get_parent(struct dentry *dchild)
 
 	sbi = ll_s2sbi(dir->i_sb);
 
-	CDEBUG(D_INFO, "getting parent for (%lu," DFID ")\n",
-	       dir->i_ino, PFID(ll_inode2fid(dir)));
+	CDEBUG(D_INFO, "%s: getting parent for ("DFID")\n",
+	       ll_get_fsname(dir->i_sb, NULL, 0),
+	       PFID(ll_inode2fid(dir)));
 
 	rc = ll_get_default_mdsize(sbi, &lmmsize);
 	if (rc != 0)
@@ -314,7 +316,9 @@ static struct dentry *ll_get_parent(struct dentry *dchild)
 	rc = md_getattr_name(sbi->ll_md_exp, op_data, &req);
 	ll_finish_md_op_data(op_data);
 	if (rc) {
-		CERROR("failure %d inode %lu get parent\n", rc, dir->i_ino);
+		CERROR("%s: failure inode "DFID" get parent: rc = %d\n",
+		       ll_get_fsname(dir->i_sb, NULL, 0),
+		       PFID(ll_inode2fid(dir)), rc);
 		return ERR_PTR(rc);
 	}
 	body = req_capsule_server_get(&req->rq_pill, &RMF_MDT_BODY);
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index cf4ad93..5eba0eb 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -133,9 +133,9 @@ struct inode *ll_iget(struct super_block *sb, ino_t hash,
 			}
 		} else if (!(inode->i_state & (I_FREEING | I_CLEAR))) {
 			ll_update_inode(inode, md);
+			CDEBUG(D_VFSTRACE, "got inode: "DFID"(%p)\n",
+			       PFID(&md->body->fid1), inode);
 		}
-		CDEBUG(D_VFSTRACE, "got inode: %p for "DFID"\n",
-		       inode, PFID(&md->body->fid1));
 	}
 	return inode;
 }
@@ -257,8 +257,8 @@ int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
 		}
 
 		if ((bits & MDS_INODELOCK_UPDATE) && S_ISDIR(inode->i_mode)) {
-			CDEBUG(D_INODE, "invalidating inode %lu\n",
-			       inode->i_ino);
+			CDEBUG(D_INODE, "invalidating inode "DFID"\n",
+			       PFID(ll_inode2fid(inode)));
 			truncate_inode_pages(inode->i_mapping, 0);
 			ll_invalidate_negative_children(inode);
 		}
@@ -478,9 +478,8 @@ static struct dentry *ll_lookup_it(struct inode *parent, struct dentry *dentry,
 	if (dentry->d_name.len > ll_i2sbi(parent)->ll_namelen)
 		return ERR_PTR(-ENAMETOOLONG);
 
-	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd,dir=%lu/%u(%p),intent=%s\n",
-	       dentry, parent->i_ino,
-	       parent->i_generation, parent, LL_IT2STR(it));
+	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir="DFID"(%p),intent=%s\n",
+	       dentry, PFID(ll_inode2fid(parent)), parent, LL_IT2STR(it));
 
 	if (d_mountpoint(dentry))
 		CERROR("Tell Peter, lookup on mtpt, it %s\n", LL_IT2STR(it));
@@ -555,9 +554,8 @@ static struct dentry *ll_lookup_nd(struct inode *parent, struct dentry *dentry,
 	struct lookup_intent *itp, it = { .it_op = IT_GETATTR };
 	struct dentry *de;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd,dir=%lu/%u(%p),flags=%u\n",
-	       dentry, parent->i_ino,
-	       parent->i_generation, parent, flags);
+	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir="DFID"(%p),flags=%u\n",
+	       dentry, PFID(ll_inode2fid(parent)), parent, flags);
 
 	/* Optimize away (CREATE && !OPEN). Let .create handle the race. */
 	if ((flags & LOOKUP_CREATE) && !(flags & LOOKUP_OPEN))
@@ -588,10 +586,9 @@ static int ll_atomic_open(struct inode *dir, struct dentry *dentry,
 	long long lookup_flags = LOOKUP_OPEN;
 	int rc = 0;
 
-	CDEBUG(D_VFSTRACE,
-	       "VFS Op:name=%pd,dir=%lu/%u(%p),file %p,open_flags %x,mode %x opened %d\n",
-	       dentry, dir->i_ino,
-	       dir->i_generation, dir, file, open_flags, mode, *opened);
+	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir="DFID"(%p),file %p,open_flags %x,mode %x opened %d\n",
+	       dentry, PFID(ll_inode2fid(dir)), dir, file, open_flags, mode,
+	       *opened);
 
 	it = kzalloc(sizeof(*it), GFP_NOFS);
 	if (!it)
@@ -682,8 +679,8 @@ static struct inode *ll_create_node(struct inode *dir, struct lookup_intent *it)
 	 * lock on the inode.  Since we finally have an inode pointer,
 	 * stuff it in the lock.
 	 */
-	CDEBUG(D_DLMTRACE, "setting l_ast_data to inode %p (%lu/%u)\n",
-	       inode, inode->i_ino, inode->i_generation);
+	CDEBUG(D_DLMTRACE, "setting l_ast_data to inode "DFID"(%p)\n",
+	       PFID(ll_inode2fid(dir)), inode);
 	ll_set_lock_data(sbi->ll_md_exp, inode, it, NULL);
  out:
 	ptlrpc_req_finished(request);
@@ -710,9 +707,8 @@ static int ll_create_it(struct inode *dir, struct dentry *dentry, int mode,
 	struct inode *inode;
 	int rc = 0;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd,dir=%lu/%u(%p),intent=%s\n",
-	       dentry, dir->i_ino,
-	       dir->i_generation, dir, LL_IT2STR(it));
+	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir="DFID"(%p), intent=%s\n",
+	       dentry, PFID(ll_inode2fid(dir)), dir, LL_IT2STR(it));
 
 	rc = it_open_error(DISP_OPEN_CREATE, it);
 	if (rc)
@@ -735,8 +731,9 @@ static void ll_update_times(struct ptlrpc_request *request,
 	LASSERT(body);
 	if (body->valid & OBD_MD_FLMTIME &&
 	    body->mtime > LTIME_S(inode->i_mtime)) {
-		CDEBUG(D_INODE, "setting ino %lu mtime from %lu to %llu\n",
-		       inode->i_ino, LTIME_S(inode->i_mtime), body->mtime);
+		CDEBUG(D_INODE, "setting fid "DFID" mtime from %lu to %llu\n",
+		       PFID(ll_inode2fid(inode)), LTIME_S(inode->i_mtime),
+		       body->mtime);
 		LTIME_S(inode->i_mtime) = body->mtime;
 	}
 	if (body->valid & OBD_MD_FLCTIME &&
@@ -793,9 +790,9 @@ static int ll_mknod(struct inode *dir, struct dentry *dchild,
 {
 	int err;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd,dir=%lu/%u(%p) mode %o dev %x\n",
-	       dchild, dir->i_ino, dir->i_generation, dir,
-	       mode, old_encode_dev(rdev));
+	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir="DFID"(%p) mode %o dev %x\n",
+	       dchild, PFID(ll_inode2fid(dir)), dir, mode,
+	       old_encode_dev(rdev));
 
 	if (!IS_POSIXACL(dir) || !exp_connect_umask(ll_i2mdexp(dir)))
 		mode &= ~current_umask();
@@ -833,9 +830,8 @@ static int ll_create_nd(struct inode *dir, struct dentry *dentry,
 {
 	int rc;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd,dir=%lu/%u(%p),flags=%u, excl=%d\n",
-	       dentry, dir->i_ino,
-	       dir->i_generation, dir, mode, want_excl);
+	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir="DFID"(%p), flags=%u, excl=%d\n",
+	       dentry, PFID(ll_inode2fid(dir)), dir, mode, want_excl);
 
 	rc = ll_mknod(dir, dentry, mode, 0);
 
@@ -961,8 +957,8 @@ static int ll_mkdir(struct inode *dir, struct dentry *dentry, umode_t mode)
 {
 	int err;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd,dir=%lu/%u(%p)\n",
-	       dentry, dir->i_ino, dir->i_generation, dir);
+	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir"DFID"(%p)\n",
+	       dentry, PFID(ll_inode2fid(dir)), dir);
 
 	if (!IS_POSIXACL(dir) || !exp_connect_umask(ll_i2mdexp(dir)))
 		mode &= ~current_umask();
@@ -981,8 +977,8 @@ static int ll_rmdir(struct inode *dir, struct dentry *dchild)
 	struct md_op_data *op_data;
 	int rc;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd,dir=%lu/%u(%p)\n",
-	       dchild, dir->i_ino, dir->i_generation, dir);
+	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir="DFID"(%p)\n",
+	       dchild, PFID(ll_inode2fid(dir)), dir);
 
 	op_data = ll_prep_md_op_data(NULL, dir, NULL,
 				     dchild->d_name.name,
@@ -1011,9 +1007,8 @@ static int ll_symlink(struct inode *dir, struct dentry *dentry,
 {
 	int err;
 
-	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd,dir=%lu/%u(%p),target=%.*s\n",
-	       dentry, dir->i_ino, dir->i_generation,
-	       dir, 3000, oldname);
+	CDEBUG(D_VFSTRACE, "VFS Op:name=%pd, dir="DFID"(%p),target=%.*s\n",
+	       dentry, PFID(ll_inode2fid(dir)), dir, 3000, oldname);
 
 	err = ll_new_node(dir, dentry, oldname, S_IFLNK | S_IRWXUGO,
 			  0, LUSTRE_OPC_SYMLINK);
@@ -1033,10 +1028,9 @@ static int ll_link(struct dentry *old_dentry, struct inode *dir,
 	struct md_op_data *op_data;
 	int err;
 
-	CDEBUG(D_VFSTRACE,
-	       "VFS Op: inode=%lu/%u(%p), dir=%lu/%u(%p), target=%pd\n",
-	       src->i_ino, src->i_generation, src, dir->i_ino,
-	       dir->i_generation, dir, new_dentry);
+	CDEBUG(D_VFSTRACE, "VFS Op: inode="DFID"(%p), dir="DFID"(%p), target=%pd\n",
+	       PFID(ll_inode2fid(src)), src, PFID(ll_inode2fid(dir)), dir,
+	       new_dentry);
 
 	op_data = ll_prep_md_op_data(NULL, src, dir, new_dentry->d_name.name,
 				     new_dentry->d_name.len,
@@ -1065,9 +1059,9 @@ static int ll_rename(struct inode *src, struct dentry *src_dchild,
 	int err;
 
 	CDEBUG(D_VFSTRACE,
-	       "VFS Op:oldname=%pd,src_dir=%lu/%u(%p),newname=%pd,tgt_dir=%lu/%u(%p)\n",
-	       src_dchild, src->i_ino, src->i_generation, src,
-	       tgt_dchild, tgt->i_ino, tgt->i_generation, tgt);
+	       "VFS Op:oldname=%pd, src_dir="DFID"(%p), newname=%pd, tgt_dir="DFID"(%p)\n",
+	       src_dchild, PFID(ll_inode2fid(src)), src,
+	       tgt_dchild, PFID(ll_inode2fid(tgt)), tgt);
 
 	op_data = ll_prep_md_op_data(NULL, src, tgt, NULL, 0, 0,
 				     LUSTRE_OPC_ANY, NULL);
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index cad6aa9..a740c7a 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -365,9 +365,8 @@ static ssize_t ll_direct_IO_26(struct kiocb *iocb, struct iov_iter *iter,
 	if ((file_offset & ~PAGE_MASK) || (count & ~PAGE_MASK))
 		return -EINVAL;
 
-	CDEBUG(D_VFSTRACE,
-	       "VFS Op:inode=%lu/%u(%p), size=%zd (max %lu), offset=%lld=%llx, pages %zd (max %lu)\n",
-	       inode->i_ino, inode->i_generation, inode, count, MAX_DIO_SIZE,
+	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p), size=%zd (max %lu), offset=%lld=%llx, pages %zd (max %lu)\n",
+	       PFID(ll_inode2fid(inode)), inode, count, MAX_DIO_SIZE,
 	       file_offset, file_offset, count >> PAGE_SHIFT,
 	       MAX_DIO_SIZE >> PAGE_SHIFT);
 
diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
index 99ffd15..6322f88 100644
--- a/drivers/staging/lustre/lustre/llite/statahead.c
+++ b/drivers/staging/lustre/lustre/llite/statahead.c
@@ -661,8 +661,9 @@ static void ll_post_statahead(struct ll_statahead_info *sai)
 	if (rc)
 		goto out;
 
-	CDEBUG(D_DLMTRACE, "setting l_data to inode %p (%lu/%u)\n",
-	       child, child->i_ino, child->i_generation);
+	CDEBUG(D_DLMTRACE, "%s: setting l_data to inode "DFID"%p\n",
+	       ll_get_fsname(child->i_sb, NULL, 0),
+	       PFID(ll_inode2fid(child)), child);
 	ll_set_lock_data(ll_i2sbi(dir)->ll_md_exp, child, it, NULL);
 
 	entry->se_inode = child;
@@ -1591,13 +1592,11 @@ int do_statahead_enter(struct inode *dir, struct dentry **dentryp,
 					*dentryp = alias;
 				} else if (d_inode(*dentryp) != inode) {
 					/* revalidate, but inode is recreated */
-					CDEBUG(D_READA,
-					       "stale dentry %pd inode %lu/%u, statahead inode %lu/%u\n",
-					      *dentryp,
-					      d_inode(*dentryp)->i_ino,
-					      d_inode(*dentryp)->i_generation,
-					      inode->i_ino,
-					      inode->i_generation);
+					CDEBUG(D_READA, "%s: stale dentry %pd inode "DFID", statahead inode "DFID"\n",
+					       ll_get_fsname(d_inode(*dentryp)->i_sb, NULL, 0),
+					       *dentryp,
+					       PFID(ll_inode2fid(d_inode(*dentryp))),
+					       PFID(ll_inode2fid(inode)));
 					ll_sai_unplug(sai, entry);
 					return -ESTALE;
 				} else {
diff --git a/drivers/staging/lustre/lustre/llite/symlink.c b/drivers/staging/lustre/lustre/llite/symlink.c
index 46d03ea..3fc736c 100644
--- a/drivers/staging/lustre/lustre/llite/symlink.c
+++ b/drivers/staging/lustre/lustre/llite/symlink.c
@@ -77,7 +77,9 @@ static int ll_readlink_internal(struct inode *inode,
 	ll_finish_md_op_data(op_data);
 	if (rc) {
 		if (rc != -ENOENT)
-			CERROR("inode %lu: rc = %d\n", inode->i_ino, rc);
+			CERROR("%s: inode "DFID": rc = %d\n",
+			       ll_get_fsname(inode->i_sb, NULL, 0),
+			       PFID(ll_inode2fid(inode)), rc);
 		goto failed;
 	}
 
@@ -90,8 +92,10 @@ static int ll_readlink_internal(struct inode *inode,
 
 	LASSERT(symlen != 0);
 	if (body->eadatasize != symlen) {
-		CERROR("inode %lu: symlink length %d not expected %d\n",
-		       inode->i_ino, body->eadatasize - 1, symlen - 1);
+		CERROR("%s: inode "DFID": symlink length %d not expected %d\n",
+		       ll_get_fsname(inode->i_sb, NULL, 0),
+		       PFID(ll_inode2fid(inode)), body->eadatasize - 1,
+		       symlen - 1);
 		rc = -EPROTO;
 		goto failed;
 	}
diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index 644a31f..47101de 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -532,15 +532,14 @@ static void vvp_pgcache_page_show(const struct lu_env *env,
 
 	vpg = cl2vvp_page(cl_page_at(page, &vvp_device_type));
 	vmpage = vpg->vpg_page;
-	seq_printf(seq, " %5i | %p %p %s %s %s %s | %p %lu/%u(%p) %lu %u [",
+	seq_printf(seq, " %5i | %p %p %s %s %s %s | %p "DFID"(%p) %lu %u [",
 		   0 /* gen */,
 		   vpg, page,
 		   "none",
 		   vpg->vpg_write_queued ? "wq" : "- ",
 		   vpg->vpg_defer_uptodate ? "du" : "- ",
 		   PageWriteback(vmpage) ? "wb" : "-",
-		   vmpage, vmpage->mapping->host->i_ino,
-		   vmpage->mapping->host->i_generation,
+		   vmpage, PFID(ll_inode2fid(vmpage->mapping->host)),
 		   vmpage->mapping->host, vmpage->index,
 		   page_count(vmpage));
 	has_flags = 0;
diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index 43b2d08..6f2e6c3 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -219,8 +219,8 @@ int ll_setxattr(struct dentry *dentry, const char *name,
 	LASSERT(inode);
 	LASSERT(name);
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode=%lu/%u(%p), xattr %s\n",
-	       inode->i_ino, inode->i_generation, inode, name);
+	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p), xattr %s\n",
+	       PFID(ll_inode2fid(inode)), inode, name);
 
 	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_SETXATTR, 1);
 
@@ -273,8 +273,8 @@ int ll_removexattr(struct dentry *dentry, const char *name)
 	LASSERT(inode);
 	LASSERT(name);
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode=%lu/%u(%p), xattr %s\n",
-	       inode->i_ino, inode->i_generation, inode, name);
+	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p), xattr %s\n",
+	       PFID(ll_inode2fid(inode)), inode, name);
 
 	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_REMOVEXATTR, 1);
 	return ll_setxattr_common(inode, name, NULL, 0, 0,
@@ -293,8 +293,8 @@ int ll_getxattr_common(struct inode *inode, const char *name,
 	struct rmtacl_ctl_entry *rce = NULL;
 	struct ll_inode_info *lli = ll_i2info(inode);
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode=%lu/%u(%p)\n",
-	       inode->i_ino, inode->i_generation, inode);
+	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p)\n",
+	       PFID(ll_inode2fid(inode)), inode);
 
 	/* listxattr have slightly different behavior from of ext3:
 	 * without 'user_xattr' ext3 will list all xattr names but
@@ -458,8 +458,8 @@ ssize_t ll_getxattr(struct dentry *dentry, const char *name,
 	LASSERT(inode);
 	LASSERT(name);
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode=%lu/%u(%p), xattr %s\n",
-	       inode->i_ino, inode->i_generation, inode, name);
+	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p), xattr %s\n",
+	       PFID(ll_inode2fid(inode)), inode, name);
 
 	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_GETXATTR, 1);
 
@@ -553,8 +553,8 @@ ssize_t ll_listxattr(struct dentry *dentry, char *buffer, size_t size)
 
 	LASSERT(inode);
 
-	CDEBUG(D_VFSTRACE, "VFS Op:inode=%lu/%u(%p)\n",
-	       inode->i_ino, inode->i_generation, inode);
+	CDEBUG(D_VFSTRACE, "VFS Op:inode="DFID"(%p)\n",
+	       PFID(ll_inode2fid(inode)), inode);
 
 	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_LISTXATTR, 1);
 
-- 
1.7.1
