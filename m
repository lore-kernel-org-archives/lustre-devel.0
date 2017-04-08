From: Deepa Dinamani <deepa.kernel@gmail.com>
Date: Fri,  7 Apr 2017 17:57:06 -0700
Subject: [lustre-devel] [PATCH 08/12] fs: ubifs: Replace CURRENT_TIME_SEC
	with current_time
In-Reply-To: <1491613030-11599-1-git-send-email-deepa.kernel@gmail.com>
References: <1491613030-11599-1-git-send-email-deepa.kernel@gmail.com>
Message-ID: <1491613030-11599-9-git-send-email-deepa.kernel@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Cc: bfields@fieldses.org, clm@fb.com, linux-mtd@lists.infradead.org, dushistov@mail.ru, jlayton@poochiereds.net, tglx@linutronix.de, devel@driverdev.osuosl.org, linux-cifs@vger.kernel.org, paul@paul-moore.com, y2038@lists.linaro.org, mingo@redhat.com, jsimmons@infradead.org, arnd@arndb.de, rostedt@goodmis.org, oleg.drokin@intel.com, john.stultz@linaro.org, viro@zeniv.linux.org.uk, dsterba@suse.com, jaegeuk@kernel.org, ceph-devel@vger.kernel.org, andreas.dilger@intel.com, jbacik@fb.com, gregkh@linuxfoundation.org, samba-technical@lists.samba.org, eparis@redhat.com, linux-f2fs-devel@lists.sourceforge.net, linux-security-module@vger.kernel.org, linux-audit@redhat.com, netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org, davem@davemloft.net, linux-btrfs@vger.kernel.org, lustre-devel@lists.lustre.org

CURRENT_TIME_SEC is not y2038 safe. current_time() will
be transitioned to use 64 bit time along with vfs in a
separate patch.
There is no plan to transition CURRENT_TIME_SEC to use
y2038 safe time interfaces.

current_time() returns timestamps according to the
granularities set in the inode's super_block.
The granularity check to call current_fs_time() or
CURRENT_TIME_SEC is not required.

Use current_time() directly to update inode timestamp.
Use timespec_trunc during file system creation, before
the first inode is created.

Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
Reviewed-by: Arnd Bergmann <arnd@arndb.de>
---
 fs/ubifs/dir.c   | 12 ++++++------
 fs/ubifs/file.c  | 12 ++++++------
 fs/ubifs/ioctl.c |  2 +-
 fs/ubifs/misc.h  | 10 ----------
 fs/ubifs/sb.c    | 14 ++++++++++----
 fs/ubifs/xattr.c |  6 +++---
 6 files changed, 26 insertions(+), 30 deletions(-)

diff --git a/fs/ubifs/dir.c b/fs/ubifs/dir.c
index 30825d88..8510d79 100644
--- a/fs/ubifs/dir.c
+++ b/fs/ubifs/dir.c
@@ -121,7 +121,7 @@ struct inode *ubifs_new_inode(struct ubifs_info *c, struct inode *dir,
 
 	inode_init_owner(inode, dir, mode);
 	inode->i_mtime = inode->i_atime = inode->i_ctime =
-			 ubifs_current_time(inode);
+			 current_time(inode);
 	inode->i_mapping->nrpages = 0;
 
 	switch (mode & S_IFMT) {
@@ -750,7 +750,7 @@ static int ubifs_link(struct dentry *old_dentry, struct inode *dir,
 	lock_2_inodes(dir, inode);
 	inc_nlink(inode);
 	ihold(inode);
-	inode->i_ctime = ubifs_current_time(inode);
+	inode->i_ctime = current_time(inode);
 	dir->i_size += sz_change;
 	dir_ui->ui_size = dir->i_size;
 	dir->i_mtime = dir->i_ctime = inode->i_ctime;
@@ -823,7 +823,7 @@ static int ubifs_unlink(struct inode *dir, struct dentry *dentry)
 	}
 
 	lock_2_inodes(dir, inode);
-	inode->i_ctime = ubifs_current_time(dir);
+	inode->i_ctime = current_time(dir);
 	drop_nlink(inode);
 	dir->i_size -= sz_change;
 	dir_ui->ui_size = dir->i_size;
@@ -927,7 +927,7 @@ static int ubifs_rmdir(struct inode *dir, struct dentry *dentry)
 	}
 
 	lock_2_inodes(dir, inode);
-	inode->i_ctime = ubifs_current_time(dir);
+	inode->i_ctime = current_time(dir);
 	clear_nlink(inode);
 	drop_nlink(dir);
 	dir->i_size -= sz_change;
@@ -1405,7 +1405,7 @@ static int do_rename(struct inode *old_dir, struct dentry *old_dentry,
 	 * Like most other Unix systems, set the @i_ctime for inodes on a
 	 * rename.
 	 */
-	time = ubifs_current_time(old_dir);
+	time = current_time(old_dir);
 	old_inode->i_ctime = time;
 
 	/* We must adjust parent link count when renaming directories */
@@ -1578,7 +1578,7 @@ static int ubifs_xrename(struct inode *old_dir, struct dentry *old_dentry,
 
 	lock_4_inodes(old_dir, new_dir, NULL, NULL);
 
-	time = ubifs_current_time(old_dir);
+	time = current_time(old_dir);
 	fst_inode->i_ctime = time;
 	snd_inode->i_ctime = time;
 	old_dir->i_mtime = old_dir->i_ctime = time;
diff --git a/fs/ubifs/file.c b/fs/ubifs/file.c
index d9ae86f..2cda3d6 100644
--- a/fs/ubifs/file.c
+++ b/fs/ubifs/file.c
@@ -1196,7 +1196,7 @@ static int do_truncation(struct ubifs_info *c, struct inode *inode,
 	mutex_lock(&ui->ui_mutex);
 	ui->ui_size = inode->i_size;
 	/* Truncation changes inode [mc]time */
-	inode->i_mtime = inode->i_ctime = ubifs_current_time(inode);
+	inode->i_mtime = inode->i_ctime = current_time(inode);
 	/* Other attributes may be changed at the same time as well */
 	do_attr_changes(inode, attr);
 	err = ubifs_jnl_truncate(c, inode, old_size, new_size);
@@ -1243,7 +1243,7 @@ static int do_setattr(struct ubifs_info *c, struct inode *inode,
 	mutex_lock(&ui->ui_mutex);
 	if (attr->ia_valid & ATTR_SIZE) {
 		/* Truncation changes inode [mc]time */
-		inode->i_mtime = inode->i_ctime = ubifs_current_time(inode);
+		inode->i_mtime = inode->i_ctime = current_time(inode);
 		/* 'truncate_setsize()' changed @i_size, update @ui_size */
 		ui->ui_size = inode->i_size;
 	}
@@ -1420,7 +1420,7 @@ int ubifs_update_time(struct inode *inode, struct timespec *time,
  */
 static int update_mctime(struct inode *inode)
 {
-	struct timespec now = ubifs_current_time(inode);
+	struct timespec now = current_time(inode);
 	struct ubifs_inode *ui = ubifs_inode(inode);
 	struct ubifs_info *c = inode->i_sb->s_fs_info;
 
@@ -1434,7 +1434,7 @@ static int update_mctime(struct inode *inode)
 			return err;
 
 		mutex_lock(&ui->ui_mutex);
-		inode->i_mtime = inode->i_ctime = ubifs_current_time(inode);
+		inode->i_mtime = inode->i_ctime = current_time(inode);
 		release = ui->dirty;
 		mark_inode_dirty_sync(inode);
 		mutex_unlock(&ui->ui_mutex);
@@ -1511,7 +1511,7 @@ static int ubifs_vm_page_mkwrite(struct vm_fault *vmf)
 	struct page *page = vmf->page;
 	struct inode *inode = file_inode(vmf->vma->vm_file);
 	struct ubifs_info *c = inode->i_sb->s_fs_info;
-	struct timespec now = ubifs_current_time(inode);
+	struct timespec now = current_time(inode);
 	struct ubifs_budget_req req = { .new_page = 1 };
 	int err, update_time;
 
@@ -1579,7 +1579,7 @@ static int ubifs_vm_page_mkwrite(struct vm_fault *vmf)
 		struct ubifs_inode *ui = ubifs_inode(inode);
 
 		mutex_lock(&ui->ui_mutex);
-		inode->i_mtime = inode->i_ctime = ubifs_current_time(inode);
+		inode->i_mtime = inode->i_ctime = current_time(inode);
 		release = ui->dirty;
 		mark_inode_dirty_sync(inode);
 		mutex_unlock(&ui->ui_mutex);
diff --git a/fs/ubifs/ioctl.c b/fs/ubifs/ioctl.c
index da519ba..12b9eb50 100644
--- a/fs/ubifs/ioctl.c
+++ b/fs/ubifs/ioctl.c
@@ -126,7 +126,7 @@ static int setflags(struct inode *inode, int flags)
 
 	ui->flags = ioctl2ubifs(flags);
 	ubifs_set_inode_flags(inode);
-	inode->i_ctime = ubifs_current_time(inode);
+	inode->i_ctime = current_time(inode);
 	release = ui->dirty;
 	mark_inode_dirty_sync(inode);
 	mutex_unlock(&ui->ui_mutex);
diff --git a/fs/ubifs/misc.h b/fs/ubifs/misc.h
index 8ece6ca..caf83d6 100644
--- a/fs/ubifs/misc.h
+++ b/fs/ubifs/misc.h
@@ -225,16 +225,6 @@ static inline void *ubifs_idx_key(const struct ubifs_info *c,
 }
 
 /**
- * ubifs_current_time - round current time to time granularity.
- * @inode: inode
- */
-static inline struct timespec ubifs_current_time(struct inode *inode)
-{
-	return (inode->i_sb->s_time_gran < NSEC_PER_SEC) ?
-		current_fs_time(inode->i_sb) : CURRENT_TIME_SEC;
-}
-
-/**
  * ubifs_tnc_lookup - look up a file-system node.
  * @c: UBIFS file-system description object
  * @key: node key to lookup
diff --git a/fs/ubifs/sb.c b/fs/ubifs/sb.c
index 7f1ead2..8c25081 100644
--- a/fs/ubifs/sb.c
+++ b/fs/ubifs/sb.c
@@ -84,6 +84,8 @@ static int create_default_filesystem(struct ubifs_info *c)
 	int min_leb_cnt = UBIFS_MIN_LEB_CNT;
 	long long tmp64, main_bytes;
 	__le64 tmp_le64;
+	__le32 tmp_le32;
+	struct timespec ts;
 
 	/* Some functions called from here depend on the @c->key_len filed */
 	c->key_len = UBIFS_SK_LEN;
@@ -298,13 +300,17 @@ static int create_default_filesystem(struct ubifs_info *c)
 	ino->ch.node_type = UBIFS_INO_NODE;
 	ino->creat_sqnum = cpu_to_le64(++c->max_sqnum);
 	ino->nlink = cpu_to_le32(2);
-	tmp_le64 = cpu_to_le64(CURRENT_TIME_SEC.tv_sec);
+
+	ktime_get_real_ts(&ts);
+	ts = timespec_trunc(ts, DEFAULT_TIME_GRAN);
+	tmp_le64 = cpu_to_le64(ts.tv_sec);
 	ino->atime_sec   = tmp_le64;
 	ino->ctime_sec   = tmp_le64;
 	ino->mtime_sec   = tmp_le64;
-	ino->atime_nsec  = 0;
-	ino->ctime_nsec  = 0;
-	ino->mtime_nsec  = 0;
+	tmp_le32 = cpu_to_le32(ts.tv_nsec);
+	ino->atime_nsec  = tmp_le32;
+	ino->ctime_nsec  = tmp_le32;
+	ino->mtime_nsec  = tmp_le32;
 	ino->mode = cpu_to_le32(S_IFDIR | S_IRUGO | S_IWUSR | S_IXUGO);
 	ino->size = cpu_to_le64(UBIFS_INO_NODE_SZ);
 
diff --git a/fs/ubifs/xattr.c b/fs/ubifs/xattr.c
index efe00fc..3e53fdb 100644
--- a/fs/ubifs/xattr.c
+++ b/fs/ubifs/xattr.c
@@ -152,7 +152,7 @@ static int create_xattr(struct ubifs_info *c, struct inode *host,
 	ui->data_len = size;
 
 	mutex_lock(&host_ui->ui_mutex);
-	host->i_ctime = ubifs_current_time(host);
+	host->i_ctime = current_time(host);
 	host_ui->xattr_cnt += 1;
 	host_ui->xattr_size += CALC_DENT_SIZE(fname_len(nm));
 	host_ui->xattr_size += CALC_XATTR_BYTES(size);
@@ -234,7 +234,7 @@ static int change_xattr(struct ubifs_info *c, struct inode *host,
 	mutex_unlock(&ui->ui_mutex);
 
 	mutex_lock(&host_ui->ui_mutex);
-	host->i_ctime = ubifs_current_time(host);
+	host->i_ctime = current_time(host);
 	host_ui->xattr_size -= CALC_XATTR_BYTES(old_size);
 	host_ui->xattr_size += CALC_XATTR_BYTES(size);
 
@@ -488,7 +488,7 @@ static int remove_xattr(struct ubifs_info *c, struct inode *host,
 		return err;
 
 	mutex_lock(&host_ui->ui_mutex);
-	host->i_ctime = ubifs_current_time(host);
+	host->i_ctime = current_time(host);
 	host_ui->xattr_cnt -= 1;
 	host_ui->xattr_size -= CALC_DENT_SIZE(fname_len(nm));
 	host_ui->xattr_size -= CALC_XATTR_BYTES(ui->data_len);
-- 
2.7.4
