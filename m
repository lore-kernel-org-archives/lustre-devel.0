From: James Simmons <jsimmons@infradead.org>
Date: Sun, 21 Jul 2019 21:23:34 -0400
Subject: [lustre-devel] [PATCH 05/22] ext4: various misc changes
In-Reply-To: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
References: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1563758631-29550-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Mostly exporting symbols for osd-ldiskfs.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/ext4/balloc.c    |  1 +
 fs/ext4/ext4.h      | 26 +++++++++++++++++++++++++-
 fs/ext4/ext4_jbd2.c |  4 ++++
 fs/ext4/hash.c      |  1 +
 fs/ext4/ialloc.c    |  3 ++-
 fs/ext4/inode.c     |  6 ++++++
 fs/ext4/namei.c     | 13 +++++++------
 fs/ext4/super.c     |  9 +++------
 8 files changed, 49 insertions(+), 14 deletions(-)

diff --git a/fs/ext4/balloc.c b/fs/ext4/balloc.c
index e5d6ee6..bca75c1 100644
--- a/fs/ext4/balloc.c
+++ b/fs/ext4/balloc.c
@@ -294,6 +294,7 @@ struct ext4_group_desc * ext4_get_group_desc(struct super_block *sb,
 		*bh = sbi->s_group_desc[group_desc];
 	return desc;
 }
+EXPORT_SYMBOL(ext4_get_group_desc);
 
 /*
  * Return the block number which was discovered to be invalid, or 0 if
diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index 50f0c50..eb2d124 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -1617,6 +1617,8 @@ static inline void ext4_clear_state_flags(struct ext4_inode_info *ei)
 
 #define NEXT_ORPHAN(inode) EXT4_I(inode)->i_dtime
 
+#define JOURNAL_START_HAS_3ARGS	1
+
 /*
  * Codes for operating systems
  */
@@ -1839,7 +1841,24 @@ static inline void ext4_clear_state_flags(struct ext4_inode_info *ei)
 
 EXTN_FEATURE_FUNCS(2)
 EXTN_FEATURE_FUNCS(3)
-EXTN_FEATURE_FUNCS(4)
+
+static inline bool ext4_has_unknown_ext4_compat_features(struct super_block *sb)
+{
+	return ((EXT4_SB(sb)->s_es->s_feature_compat &
+		cpu_to_le32(~EXT4_FEATURE_COMPAT_SUPP)) != 0);
+}
+
+static inline bool ext4_has_unknown_ext4_ro_compat_features(struct super_block *sb)
+{
+	return ((EXT4_SB(sb)->s_es->s_feature_ro_compat &
+		cpu_to_le32(~EXT4_FEATURE_RO_COMPAT_SUPP)) != 0);
+}
+
+static inline bool ext4_has_unknown_ext4_incompat_features(struct super_block *sb)
+{
+	return ((EXT4_SB(sb)->s_es->s_feature_incompat &
+		cpu_to_le32(~EXT4_FEATURE_INCOMPAT_SUPP)) != 0);
+}
 
 static inline bool ext4_has_compat_features(struct super_block *sb)
 {
@@ -3192,6 +3211,11 @@ extern int ext4_check_blockref(const char *, unsigned int,
 
 extern int ext4_ext_tree_init(handle_t *handle, struct inode *);
 extern int ext4_ext_writepage_trans_blocks(struct inode *, int);
+extern struct buffer_head *ext4_read_inode_bitmap(struct super_block *sb,
+						  ext4_group_t block_group);
+extern struct buffer_head *ext4_append(handle_t *handle,
+				       struct inode *inode,
+				       ext4_lblk_t *block);
 extern int ext4_ext_index_trans_blocks(struct inode *inode, int extents);
 extern int ext4_ext_map_blocks(handle_t *handle, struct inode *inode,
 			       struct ext4_map_blocks *map, int flags);
diff --git a/fs/ext4/ext4_jbd2.c b/fs/ext4/ext4_jbd2.c
index 7c70b08..fcec082 100644
--- a/fs/ext4/ext4_jbd2.c
+++ b/fs/ext4/ext4_jbd2.c
@@ -81,6 +81,7 @@ handle_t *__ext4_journal_start_sb(struct super_block *sb, unsigned int line,
 	return jbd2__journal_start(journal, blocks, rsv_blocks, GFP_NOFS,
 				   type, line);
 }
+EXPORT_SYMBOL(__ext4_journal_start_sb);
 
 int __ext4_journal_stop(const char *where, unsigned int line, handle_t *handle)
 {
@@ -108,6 +109,7 @@ int __ext4_journal_stop(const char *where, unsigned int line, handle_t *handle)
 		__ext4_std_error(sb, where, line, err);
 	return err;
 }
+EXPORT_SYMBOL(__ext4_journal_stop);
 
 handle_t *__ext4_journal_start_reserved(handle_t *handle, unsigned int line,
 					int type)
@@ -173,6 +175,7 @@ int __ext4_journal_get_write_access(const char *where, unsigned int line,
 	}
 	return err;
 }
+EXPORT_SYMBOL(__ext4_journal_get_write_access);
 
 /*
  * The ext4 forget function must perform a revoke if we are freeing data
@@ -313,6 +316,7 @@ int __ext4_handle_dirty_metadata(const char *where, unsigned int line,
 	}
 	return err;
 }
+EXPORT_SYMBOL(__ext4_handle_dirty_metadata);
 
 int __ext4_handle_dirty_super(const char *where, unsigned int line,
 			      handle_t *handle, struct super_block *sb)
diff --git a/fs/ext4/hash.c b/fs/ext4/hash.c
index d358bfc..4648a8f 100644
--- a/fs/ext4/hash.c
+++ b/fs/ext4/hash.c
@@ -300,3 +300,4 @@ int ext4fs_dirhash(const struct inode *dir, const char *name, int len,
 #endif
 	return __ext4fs_dirhash(name, len, hinfo);
 }
+EXPORT_SYMBOL(ext4fs_dirhash);
diff --git a/fs/ext4/ialloc.c b/fs/ext4/ialloc.c
index 09ae4a4..68d41e6 100644
--- a/fs/ext4/ialloc.c
+++ b/fs/ext4/ialloc.c
@@ -114,7 +114,7 @@ static int ext4_validate_inode_bitmap(struct super_block *sb,
  *
  * Return buffer_head of bitmap on success or NULL.
  */
-static struct buffer_head *
+struct buffer_head *
 ext4_read_inode_bitmap(struct super_block *sb, ext4_group_t block_group)
 {
 	struct ext4_group_desc *desc;
@@ -211,6 +211,7 @@ static int ext4_validate_inode_bitmap(struct super_block *sb,
 	put_bh(bh);
 	return ERR_PTR(err);
 }
+EXPORT_SYMBOL(ext4_read_inode_bitmap);
 
 /*
  * NOTE! When we get the inode, we're the only people
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index c37418a..5561351 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -741,6 +741,7 @@ int ext4_map_blocks(handle_t *handle, struct inode *inode,
 	}
 	return retval;
 }
+EXPORT_SYMBOL(ext4_map_blocks);
 
 /*
  * Update EXT4_MAP_FLAGS in bh->b_state. For buffer heads attached to pages
@@ -1027,6 +1028,7 @@ struct buffer_head *ext4_bread(handle_t *handle, struct inode *inode,
 	put_bh(bh);
 	return ERR_PTR(-EIO);
 }
+EXPORT_SYMBOL(ext4_bread);
 
 /* Read a contiguous batch of blocks. */
 int ext4_bread_batch(struct inode *inode, ext4_lblk_t block, int bh_count,
@@ -4559,6 +4561,7 @@ int ext4_truncate(struct inode *inode)
 	trace_ext4_truncate_exit(inode);
 	return err;
 }
+EXPORT_SYMBOL(ext4_truncate);
 
 /*
  * ext4_get_inode_loc returns with an extra refcount against the inode's
@@ -4710,6 +4713,7 @@ int ext4_get_inode_loc(struct inode *inode, struct ext4_iloc *iloc)
 	return __ext4_get_inode_loc(inode, iloc,
 		!ext4_test_inode_state(inode, EXT4_STATE_XATTR));
 }
+EXPORT_SYMBOL(ext4_get_inode_loc);
 
 static bool ext4_should_use_dax(struct inode *inode)
 {
@@ -5113,6 +5117,7 @@ struct inode *__ext4_iget(struct super_block *sb, unsigned long ino,
 	iget_failed(inode);
 	return ERR_PTR(ret);
 }
+EXPORT_SYMBOL(__ext4_iget);
 
 static int ext4_inode_blocks_set(handle_t *handle,
 				struct ext4_inode *raw_inode,
@@ -6050,6 +6055,7 @@ int ext4_mark_inode_dirty(handle_t *handle, struct inode *inode)
 
 	return ext4_mark_iloc_dirty(handle, inode, &iloc);
 }
+EXPORT_SYMBOL(ext4_mark_inode_dirty);
 
 /*
  * ext4_dirty_inode() is called from __mark_inode_dirty()
diff --git a/fs/ext4/namei.c b/fs/ext4/namei.c
index a42a2db..91fc7fe 100644
--- a/fs/ext4/namei.c
+++ b/fs/ext4/namei.c
@@ -50,9 +50,9 @@
 #define NAMEI_RA_BLOCKS  4
 #define NAMEI_RA_SIZE	     (NAMEI_RA_CHUNKS * NAMEI_RA_BLOCKS)
 
-static struct buffer_head *ext4_append(handle_t *handle,
-					struct inode *inode,
-					ext4_lblk_t *block)
+struct buffer_head *ext4_append(handle_t *handle,
+				struct inode *inode,
+				ext4_lblk_t *block)
 {
 	struct buffer_head *bh;
 	int err;
@@ -2511,24 +2511,25 @@ int ext4_delete_entry(handle_t *handle, struct inode *dir,
  * for checking S_ISDIR(inode) (since the INODE_INDEX feature will not be set
  * on regular files) and to avoid creating huge/slow non-HTREE directories.
  */
-static void ext4_inc_count(handle_t *handle, struct inode *inode)
+void ext4_inc_count(handle_t *handle, struct inode *inode)
 {
 	inc_nlink(inode);
 	if (is_dx(inode) &&
 	    (inode->i_nlink > EXT4_LINK_MAX || inode->i_nlink == 2))
 		set_nlink(inode, 1);
 }
+EXPORT_SYMBOL(ext4_inc_count);
 
 /*
  * If a directory had nlink == 1, then we should let it be 1. This indicates
  * directory has >EXT4_LINK_MAX subdirs.
  */
-static void ext4_dec_count(handle_t *handle, struct inode *inode)
+void ext4_dec_count(handle_t *handle, struct inode *inode)
 {
 	if (!S_ISDIR(inode->i_mode) || inode->i_nlink > 2)
 		drop_nlink(inode);
 }
-
+EXPORT_SYMBOL(ext4_dec_count);
 
 static int ext4_add_nondir(handle_t *handle,
 		struct dentry *dentry, struct inode *inode)
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 4079605..d15c26c 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -279,6 +279,7 @@ __u32 ext4_itable_unused_count(struct super_block *sb,
 		(EXT4_DESC_SIZE(sb) >= EXT4_MIN_DESC_SIZE_64BIT ?
 		 (__u32)le16_to_cpu(bg->bg_itable_unused_hi) << 16 : 0);
 }
+EXPORT_SYMBOL(ext4_itable_unused_count);
 
 void ext4_block_bitmap_set(struct super_block *sb,
 			   struct ext4_group_desc *bg, ext4_fsblk_t blk)
@@ -658,6 +659,7 @@ void __ext4_std_error(struct super_block *sb, const char *function,
 	save_error_info(sb, function, line);
 	ext4_handle_error(sb);
 }
+EXPORT_SYMBOL(__ext4_std_error);
 
 /*
  * ext4_abort is a much stronger failure handler than ext4_error.  The
@@ -5101,6 +5103,7 @@ int ext4_force_commit(struct super_block *sb)
 	journal = EXT4_SB(sb)->s_journal;
 	return ext4_journal_force_commit(journal);
 }
+EXPORT_SYMBOL(ext4_force_commit);
 
 static int ext4_sync_fs(struct super_block *sb, int wait)
 {
@@ -6115,16 +6118,12 @@ static int __init ext4_init_fs(void)
 	err = init_inodecache();
 	if (err)
 		goto out1;
-	register_as_ext3();
-	register_as_ext2();
 	err = register_filesystem(&ext4_fs_type);
 	if (err)
 		goto out;
 
 	return 0;
 out:
-	unregister_as_ext2();
-	unregister_as_ext3();
 	destroy_inodecache();
 out1:
 	ext4_exit_mballoc();
@@ -6145,8 +6144,6 @@ static int __init ext4_init_fs(void)
 static void __exit ext4_exit_fs(void)
 {
 	ext4_destroy_lazyinit_thread();
-	unregister_as_ext2();
-	unregister_as_ext3();
 	unregister_filesystem(&ext4_fs_type);
 	destroy_inodecache();
 	ext4_exit_mballoc();
-- 
1.8.3.1
