From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 28 Jul 2017 10:23:21 -0400
Subject: [lustre-devel] [PATCH] fs: convert a pile of fsync routines to
	errseq_t based reporting
Message-ID: <20170728142321.11492-1-jlayton@kernel.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>, jack@suse.cz, viro@zeniv.linux.org.uk
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-fbdev@vger.kernel.org, v9fs-developer@lists.sourceforge.net, linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org, linux-cifs@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, user-mode-linux-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org, jfs-discussion@lists.sourceforge.net, linux-ntfs-dev@lists.sourceforge.net, ocfs2-devel@oss.oracle.com, reiserfs-devel@vger.kernel.org, akpm@linux-foundation.org

From: Jeff Layton <jlayton@redhat.com>

This patch converts most of the in-kernel filesystems that do writeback
out of the pagecache to report errors using the errseq_t-based
infrastructure that was recently added. This allows them to report
errors once for each open file description.

Most filesystems have a fairly straightforward fsync operation. They
call filemap_write_and_wait_range to write back all of the data and
wait on it, and then (sometimes) sync out the metadata.

For those filesystems this is a straightforward conversion from calling
filemap_write_and_wait_range in their fsync operation to calling
file_write_and_wait_range.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 arch/powerpc/platforms/cell/spufs/file.c   | 2 +-
 drivers/staging/lustre/lustre/llite/file.c | 2 +-
 drivers/video/fbdev/core/fb_defio.c        | 2 +-
 fs/9p/vfs_file.c                           | 4 ++--
 fs/affs/file.c                             | 2 +-
 fs/afs/write.c                             | 2 +-
 fs/cifs/file.c                             | 4 ++--
 fs/exofs/file.c                            | 2 +-
 fs/f2fs/file.c                             | 2 +-
 fs/hfs/inode.c                             | 2 +-
 fs/hfsplus/inode.c                         | 2 +-
 fs/hostfs/hostfs_kern.c                    | 2 +-
 fs/hpfs/file.c                             | 2 +-
 fs/jffs2/file.c                            | 2 +-
 fs/jfs/file.c                              | 2 +-
 fs/ncpfs/file.c                            | 2 +-
 fs/ntfs/dir.c                              | 2 +-
 fs/ntfs/file.c                             | 2 +-
 fs/ocfs2/file.c                            | 2 +-
 fs/reiserfs/dir.c                          | 2 +-
 fs/reiserfs/file.c                         | 2 +-
 fs/ubifs/file.c                            | 2 +-
 22 files changed, 24 insertions(+), 24 deletions(-)

Rolling up all of these conversions into a single patch, as Christoph
Hellwig suggested. Most of these are not tested, but the conversion
here is fairly straightforward.

Any maintainers who object, please let me know and I'll yank that
part out of this patch.

diff --git a/arch/powerpc/platforms/cell/spufs/file.c b/arch/powerpc/platforms/cell/spufs/file.c
index ae2f740a82f1..5ffcdeb1eb17 100644
--- a/arch/powerpc/platforms/cell/spufs/file.c
+++ b/arch/powerpc/platforms/cell/spufs/file.c
@@ -1749,7 +1749,7 @@ static int spufs_mfc_flush(struct file *file, fl_owner_t id)
 static int spufs_mfc_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 {
 	struct inode *inode = file_inode(file);
-	int err = filemap_write_and_wait_range(inode->i_mapping, start, end);
+	int err = file_write_and_wait_range(file, start, end);
 	if (!err) {
 		inode_lock(inode);
 		err = spufs_mfc_flush(file, NULL);
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index ab1c85c1ed38..f7d07735ac66 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -2364,7 +2364,7 @@ int ll_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 	       PFID(ll_inode2fid(inode)), inode);
 	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_FSYNC, 1);
 
-	rc = filemap_write_and_wait_range(inode->i_mapping, start, end);
+	rc = file_write_and_wait_range(file, start, end);
 	inode_lock(inode);
 
 	/* catch async errors that were recorded back when async writeback
diff --git a/drivers/video/fbdev/core/fb_defio.c b/drivers/video/fbdev/core/fb_defio.c
index 37f69c061210..487d5e336e1b 100644
--- a/drivers/video/fbdev/core/fb_defio.c
+++ b/drivers/video/fbdev/core/fb_defio.c
@@ -69,7 +69,7 @@ int fb_deferred_io_fsync(struct file *file, loff_t start, loff_t end, int datasy
 {
 	struct fb_info *info = file->private_data;
 	struct inode *inode = file_inode(file);
-	int err = filemap_write_and_wait_range(inode->i_mapping, start, end);
+	int err = file_write_and_wait_range(file, start, end);
 	if (err)
 		return err;
 
diff --git a/fs/9p/vfs_file.c b/fs/9p/vfs_file.c
index 3de3b4a89d89..4802d75b3cf7 100644
--- a/fs/9p/vfs_file.c
+++ b/fs/9p/vfs_file.c
@@ -445,7 +445,7 @@ static int v9fs_file_fsync(struct file *filp, loff_t start, loff_t end,
 	struct p9_wstat wstat;
 	int retval;
 
-	retval = filemap_write_and_wait_range(inode->i_mapping, start, end);
+	retval = file_write_and_wait_range(filp, start, end);
 	if (retval)
 		return retval;
 
@@ -468,7 +468,7 @@ int v9fs_file_fsync_dotl(struct file *filp, loff_t start, loff_t end,
 	struct inode *inode = filp->f_mapping->host;
 	int retval;
 
-	retval = filemap_write_and_wait_range(inode->i_mapping, start, end);
+	retval = file_write_and_wait_range(filp, start, end);
 	if (retval)
 		return retval;
 
diff --git a/fs/affs/file.c b/fs/affs/file.c
index 196ee7f6fdc4..00331810f690 100644
--- a/fs/affs/file.c
+++ b/fs/affs/file.c
@@ -954,7 +954,7 @@ int affs_file_fsync(struct file *filp, loff_t start, loff_t end, int datasync)
 	struct inode *inode = filp->f_mapping->host;
 	int ret, err;
 
-	err = filemap_write_and_wait_range(inode->i_mapping, start, end);
+	err = file_write_and_wait_range(filp, start, end);
 	if (err)
 		return err;
 
diff --git a/fs/afs/write.c b/fs/afs/write.c
index 2d2fccd5044b..106e43db1115 100644
--- a/fs/afs/write.c
+++ b/fs/afs/write.c
@@ -714,7 +714,7 @@ int afs_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 	       vnode->fid.vid, vnode->fid.vnode, file,
 	       datasync);
 
-	ret = filemap_write_and_wait_range(inode->i_mapping, start, end);
+	ret = file_write_and_wait_range(file, start, end);
 	if (ret)
 		return ret;
 	inode_lock(inode);
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index bc09df6b473a..0786f19d288f 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -2329,7 +2329,7 @@ int cifs_strict_fsync(struct file *file, loff_t start, loff_t end,
 	struct inode *inode = file_inode(file);
 	struct cifs_sb_info *cifs_sb = CIFS_SB(inode->i_sb);
 
-	rc = filemap_write_and_wait_range(inode->i_mapping, start, end);
+	rc = file_write_and_wait_range(file, start, end);
 	if (rc)
 		return rc;
 	inode_lock(inode);
@@ -2371,7 +2371,7 @@ int cifs_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 	struct cifs_sb_info *cifs_sb = CIFS_FILE_SB(file);
 	struct inode *inode = file->f_mapping->host;
 
-	rc = filemap_write_and_wait_range(inode->i_mapping, start, end);
+	rc = file_write_and_wait_range(file, start, end);
 	if (rc)
 		return rc;
 	inode_lock(inode);
diff --git a/fs/exofs/file.c b/fs/exofs/file.c
index 28645f0640f7..a94594ea2aa3 100644
--- a/fs/exofs/file.c
+++ b/fs/exofs/file.c
@@ -48,7 +48,7 @@ static int exofs_file_fsync(struct file *filp, loff_t start, loff_t end,
 	struct inode *inode = filp->f_mapping->host;
 	int ret;
 
-	ret = filemap_write_and_wait_range(inode->i_mapping, start, end);
+	ret = file_write_and_wait_range(filp, start, end);
 	if (ret)
 		return ret;
 
diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
index a0e6d2c65a9e..40fb3d4bb9c2 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -206,7 +206,7 @@ static int f2fs_do_sync_file(struct file *file, loff_t start, loff_t end,
 	/* if fdatasync is triggered, let's do in-place-update */
 	if (datasync || get_dirty_pages(inode) <= SM_I(sbi)->min_fsync_blocks)
 		set_inode_flag(inode, FI_NEED_IPU);
-	ret = filemap_write_and_wait_range(inode->i_mapping, start, end);
+	ret = file_write_and_wait_range(file, start, end);
 	clear_inode_flag(inode, FI_NEED_IPU);
 
 	if (ret) {
diff --git a/fs/hfs/inode.c b/fs/hfs/inode.c
index bfbba799430f..2538b49cc349 100644
--- a/fs/hfs/inode.c
+++ b/fs/hfs/inode.c
@@ -656,7 +656,7 @@ static int hfs_file_fsync(struct file *filp, loff_t start, loff_t end,
 	struct super_block * sb;
 	int ret, err;
 
-	ret = filemap_write_and_wait_range(inode->i_mapping, start, end);
+	ret = file_write_and_wait_range(filp, start, end);
 	if (ret)
 		return ret;
 	inode_lock(inode);
diff --git a/fs/hfsplus/inode.c b/fs/hfsplus/inode.c
index e8638d528195..4f26b6877130 100644
--- a/fs/hfsplus/inode.c
+++ b/fs/hfsplus/inode.c
@@ -283,7 +283,7 @@ int hfsplus_file_fsync(struct file *file, loff_t start, loff_t end,
 	struct hfsplus_sb_info *sbi = HFSPLUS_SB(inode->i_sb);
 	int error = 0, error2;
 
-	error = filemap_write_and_wait_range(inode->i_mapping, start, end);
+	error = file_write_and_wait_range(file, start, end);
 	if (error)
 		return error;
 	inode_lock(inode);
diff --git a/fs/hostfs/hostfs_kern.c b/fs/hostfs/hostfs_kern.c
index e61261a7417e..c148e7f4f451 100644
--- a/fs/hostfs/hostfs_kern.c
+++ b/fs/hostfs/hostfs_kern.c
@@ -374,7 +374,7 @@ static int hostfs_fsync(struct file *file, loff_t start, loff_t end,
 	struct inode *inode = file->f_mapping->host;
 	int ret;
 
-	ret = filemap_write_and_wait_range(inode->i_mapping, start, end);
+	ret = file_write_and_wait_range(file, start, end);
 	if (ret)
 		return ret;
 
diff --git a/fs/hpfs/file.c b/fs/hpfs/file.c
index b3be1b5a62e2..f26138425b16 100644
--- a/fs/hpfs/file.c
+++ b/fs/hpfs/file.c
@@ -24,7 +24,7 @@ int hpfs_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 	struct inode *inode = file->f_mapping->host;
 	int ret;
 
-	ret = filemap_write_and_wait_range(file->f_mapping, start, end);
+	ret = file_write_and_wait_range(file, start, end);
 	if (ret)
 		return ret;
 	return sync_blockdev(inode->i_sb->s_bdev);
diff --git a/fs/jffs2/file.c b/fs/jffs2/file.c
index c12476e309c6..bd0428bebe9b 100644
--- a/fs/jffs2/file.c
+++ b/fs/jffs2/file.c
@@ -35,7 +35,7 @@ int jffs2_fsync(struct file *filp, loff_t start, loff_t end, int datasync)
 	struct jffs2_sb_info *c = JFFS2_SB_INFO(inode->i_sb);
 	int ret;
 
-	ret = filemap_write_and_wait_range(inode->i_mapping, start, end);
+	ret = file_write_and_wait_range(filp, start, end);
 	if (ret)
 		return ret;
 
diff --git a/fs/jfs/file.c b/fs/jfs/file.c
index 739492c7a3fd..36665fd37095 100644
--- a/fs/jfs/file.c
+++ b/fs/jfs/file.c
@@ -34,7 +34,7 @@ int jfs_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 	struct inode *inode = file->f_mapping->host;
 	int rc = 0;
 
-	rc = filemap_write_and_wait_range(inode->i_mapping, start, end);
+	rc = file_write_and_wait_range(file, start, end);
 	if (rc)
 		return rc;
 
diff --git a/fs/ncpfs/file.c b/fs/ncpfs/file.c
index 76965e772264..a06c07619ee6 100644
--- a/fs/ncpfs/file.c
+++ b/fs/ncpfs/file.c
@@ -23,7 +23,7 @@
 
 static int ncp_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 {
-	return filemap_write_and_wait_range(file->f_mapping, start, end);
+	return file_write_and_wait_range(file, start, end);
 }
 
 /*
diff --git a/fs/ntfs/dir.c b/fs/ntfs/dir.c
index 0ee19ecc982d..1a24be9e8405 100644
--- a/fs/ntfs/dir.c
+++ b/fs/ntfs/dir.c
@@ -1506,7 +1506,7 @@ static int ntfs_dir_fsync(struct file *filp, loff_t start, loff_t end,
 
 	ntfs_debug("Entering for inode 0x%lx.", vi->i_ino);
 
-	err = filemap_write_and_wait_range(vi->i_mapping, start, end);
+	err = file_write_and_wait_range(filp, start, end);
 	if (err)
 		return err;
 	inode_lock(vi);
diff --git a/fs/ntfs/file.c b/fs/ntfs/file.c
index c4f68c338735..331910fa8442 100644
--- a/fs/ntfs/file.c
+++ b/fs/ntfs/file.c
@@ -1989,7 +1989,7 @@ static int ntfs_file_fsync(struct file *filp, loff_t start, loff_t end,
 
 	ntfs_debug("Entering for inode 0x%lx.", vi->i_ino);
 
-	err = filemap_write_and_wait_range(vi->i_mapping, start, end);
+	err = file_write_and_wait_range(filp, start, end);
 	if (err)
 		return err;
 	inode_lock(vi);
diff --git a/fs/ocfs2/file.c b/fs/ocfs2/file.c
index bfeb647459d9..66e59d3163ea 100644
--- a/fs/ocfs2/file.c
+++ b/fs/ocfs2/file.c
@@ -196,7 +196,7 @@ static int ocfs2_sync_file(struct file *file, loff_t start, loff_t end,
 	if (ocfs2_is_hard_readonly(osb) || ocfs2_is_soft_readonly(osb))
 		return -EROFS;
 
-	err = filemap_write_and_wait_range(inode->i_mapping, start, end);
+	err = file_write_and_wait_range(file, start, end);
 	if (err)
 		return err;
 
diff --git a/fs/reiserfs/dir.c b/fs/reiserfs/dir.c
index 45aa05e2232f..5b50689d8539 100644
--- a/fs/reiserfs/dir.c
+++ b/fs/reiserfs/dir.c
@@ -34,7 +34,7 @@ static int reiserfs_dir_fsync(struct file *filp, loff_t start, loff_t end,
 	struct inode *inode = filp->f_mapping->host;
 	int err;
 
-	err = filemap_write_and_wait_range(inode->i_mapping, start, end);
+	err = file_write_and_wait_range(filp, start, end);
 	if (err)
 		return err;
 
diff --git a/fs/reiserfs/file.c b/fs/reiserfs/file.c
index b396eb09f288..843aadcc123c 100644
--- a/fs/reiserfs/file.c
+++ b/fs/reiserfs/file.c
@@ -154,7 +154,7 @@ static int reiserfs_sync_file(struct file *filp, loff_t start, loff_t end,
 	int err;
 	int barrier_done;
 
-	err = filemap_write_and_wait_range(inode->i_mapping, start, end);
+	err = file_write_and_wait_range(filp, start, end);
 	if (err)
 		return err;
 
diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index 8cad0b19b404..f90a466ea5db 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -1337,7 +1337,7 @@ int ubifs_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 		 */
 		return 0;
 
-	err = filemap_write_and_wait_range(inode->i_mapping, start, end);
+	err = file_write_and_wait_range(file, start, end);
 	if (err)
 		return err;
 	inode_lock(inode);
-- 
2.13.3
