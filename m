From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:07:53 -0500
Subject: [lustre-devel] [PATCH 005/622] lustre: llite: return compatible
 fsid for statfs
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Fan Yong <fan.yong@intel.com>

Lustre uses 64-bits inode number to identify object on client side.
When re-export Lustre via NFS, NFS will detect whether support fsid
via statfs(). For the non-support case, it will only recognizes and
packs low 32-bits inode number in nfs handle. Such handle cannot be
used to locate the object properly.
To avoid patch linux kernel, Lustre client should generate fsid and
return it via statfs() to up layer.

To be compatible with old Lustre client (NFS server), the fsid will
be generated from super_block::s_dev.

WC-bug-id: https://jira.whamcloud.com/browse/LU-2904
Lustre-commit: abe4d83fab00 ("LU-2904 llite: return compatible fsid for statfs")
Signed-off-by: Fan Yong <fan.yong@intel.com>
Reviewed-on: http://review.whamcloud.com/7434
Reviewed-by: Bobi Jam <bobijam@whamcloud.com>
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_internal.h |  3 ---
 fs/lustre/llite/llite_lib.c      |  8 ++++----
 fs/lustre/llite/llite_nfs.c      | 16 ----------------
 3 files changed, 4 insertions(+), 23 deletions(-)

diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index f0a50fc..3192340 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -538,8 +538,6 @@ struct ll_sb_info {
 	/* st_blksize returned by stat(2), when non-zero */
 	unsigned int		 ll_stat_blksize;
 
-	__kernel_fsid_t		 ll_fsid;
-
 	struct kset		ll_kset;	/* sysfs object */
 	struct completion	 ll_kobj_unregister;
 };
@@ -941,7 +939,6 @@ static inline ssize_t ll_lov_user_md_size(const struct lov_user_md *lum)
 /* llite/llite_nfs.c */
 extern const struct export_operations lustre_export_operations;
 u32 get_uuid2int(const char *name, int len);
-void get_uuid2fsid(const char *name, int len, __kernel_fsid_t *fsid);
 struct inode *search_inode_for_lustre(struct super_block *sb,
 				      const struct lu_fid *fid);
 int ll_dir_get_parent_fid(struct inode *dir, struct lu_fid *parent_fid);
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index a48d753..e1932ae 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -591,10 +591,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	 * only a node-local comparison.
 	 */
 	uuid = obd_get_uuid(sbi->ll_md_exp);
-	if (uuid) {
+	if (uuid)
 		sb->s_dev = get_uuid2int(uuid->uuid, strlen(uuid->uuid));
-		get_uuid2fsid(uuid->uuid, strlen(uuid->uuid), &sbi->ll_fsid);
-	}
 
 	kfree(data);
 	kfree(osfs);
@@ -1775,6 +1773,7 @@ int ll_statfs(struct dentry *de, struct kstatfs *sfs)
 {
 	struct super_block *sb = de->d_sb;
 	struct obd_statfs osfs;
+	u64 fsid = huge_encode_dev(sb->s_dev);
 	int rc;
 
 	CDEBUG(D_VFSTRACE, "VFS Op: at %llu jiffies\n", get_jiffies_64());
@@ -1805,7 +1804,8 @@ int ll_statfs(struct dentry *de, struct kstatfs *sfs)
 	sfs->f_blocks = osfs.os_blocks;
 	sfs->f_bfree = osfs.os_bfree;
 	sfs->f_bavail = osfs.os_bavail;
-	sfs->f_fsid = ll_s2sbi(sb)->ll_fsid;
+	sfs->f_fsid.val[0] = (u32)fsid;
+	sfs->f_fsid.val[1] = (u32)(fsid >> 32);
 	return 0;
 }
 
diff --git a/fs/lustre/llite/llite_nfs.c b/fs/lustre/llite/llite_nfs.c
index d6643d0..434f92b 100644
--- a/fs/lustre/llite/llite_nfs.c
+++ b/fs/lustre/llite/llite_nfs.c
@@ -57,22 +57,6 @@ u32 get_uuid2int(const char *name, int len)
 	return (key0 << 1);
 }
 
-void get_uuid2fsid(const char *name, int len, __kernel_fsid_t *fsid)
-{
-	u64 key = 0, key0 = 0x12a3fe2d, key1 = 0x37abe8f9;
-
-	while (len--) {
-		key = key1 + (key0 ^ (*name++ * 7152373));
-		if (key & 0x8000000000000000ULL)
-			key -= 0x7fffffffffffffffULL;
-		key1 = key0;
-		key0 = key;
-	}
-
-	fsid->val[0] = key;
-	fsid->val[1] = key >> 32;
-}
-
 struct inode *search_inode_for_lustre(struct super_block *sb,
 				      const struct lu_fid *fid)
 {
-- 
1.8.3.1
