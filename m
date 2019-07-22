From: James Simmons <jsimmons@infradead.org>
Date: Sun, 21 Jul 2019 21:23:45 -0400
Subject: [lustre-devel] [PATCH 16/22] ext4: add warning for directory htree
 growth
In-Reply-To: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
References: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1563758631-29550-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/ext4/ext4.h  |  1 +
 fs/ext4/namei.c | 69 +++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 fs/ext4/super.c |  2 ++
 fs/ext4/sysfs.c |  2 ++
 4 files changed, 72 insertions(+), 2 deletions(-)

diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index bf74c7c..5f73e19 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -1472,6 +1472,7 @@ struct ext4_sb_info {
 	unsigned int s_mb_group_prealloc;
 	unsigned long *s_mb_prealloc_table;
 	unsigned int s_max_dir_size_kb;
+	unsigned long s_warning_dir_size;
 	/* where last allocation was done - for stream allocation */
 	unsigned long s_mb_last_group;
 	unsigned long s_mb_last_start;
diff --git a/fs/ext4/namei.c b/fs/ext4/namei.c
index 1b6d22a..9b30cc6 100644
--- a/fs/ext4/namei.c
+++ b/fs/ext4/namei.c
@@ -757,12 +757,20 @@ struct ext4_dir_lock_data {
 #define ext4_htree_lock_data(l)	((struct ext4_dir_lock_data *)(l)->lk_private)
 #define ext4_find_entry(dir, name, dirent, inline) \
 			ext4_find_entry_locked(dir, name, dirent, inline, NULL)
-#define ext4_add_entry(handle, dentry, inode) \
-		       ext4_add_entry_locked(handle, dentry, inode, NULL)
 
 /* NB: ext4_lblk_t is 32 bits so we use high bits to identify invalid blk */
 #define EXT4_HTREE_NODE_CHANGED		(0xcafeULL << 32)
 
+inline int ext4_add_entry(handle_t *handle, struct dentry *dentry,
+			  struct inode *inode)
+{
+	int ret = ext4_add_entry_locked(handle, dentry, inode, NULL);
+
+	if (ret == -ENOBUFS)
+		ret = 0;
+	return ret;
+}
+
 static void ext4_htree_event_cb(void *target, void *event)
 {
 	u64 *block = (u64 *)target;
@@ -2612,6 +2620,55 @@ static int ext4_update_dotdot(handle_t *handle, struct dentry *dentry,
 	return err;
 }
 
+static unsigned long __ext4_max_dir_size(struct dx_frame *frames,
+					 struct dx_frame *frame,
+					 struct inode *dir)
+{
+	unsigned long max_dir_size;
+
+	if (EXT4_SB(dir->i_sb)->s_max_dir_size_kb) {
+		max_dir_size = EXT4_SB(dir->i_sb)->s_max_dir_size_kb << 10;
+	} else {
+		max_dir_size = EXT4_BLOCK_SIZE(dir->i_sb);
+		while (frame >= frames) {
+			max_dir_size *= dx_get_limit(frame->entries);
+			if (frame == frames)
+				break;
+			frame--;
+		}
+		/* use 75% of max dir size in average */
+		max_dir_size = max_dir_size / 4 * 3;
+	}
+	return max_dir_size;
+}
+
+/*
+ * With hash tree growing, it is easy to hit ENOSPC, but it is hard
+ * to predict when it will happen. let's give administrators warning
+ * when reaching 3/5 and 2/3 of limit
+ */
+static inline bool dir_size_in_warning_range(struct dx_frame *frames,
+					     struct dx_frame *frame,
+					     struct inode *dir)
+{
+	struct super_block *sb = dir->i_sb;
+	unsigned long size1, size2;
+
+	if (unlikely(!EXT4_SB(sb)->s_warning_dir_size))
+		EXT4_SB(sb)->s_warning_dir_size =
+			__ext4_max_dir_size(frames, frame, dir);
+
+	size1 = EXT4_SB(sb)->s_warning_dir_size / 16 * 10;
+	size1 = size1 & ~(EXT4_BLOCK_SIZE(sb) - 1);
+	size2 = EXT4_SB(sb)->s_warning_dir_size / 16 * 11;
+	size2 = size2 & ~(EXT4_BLOCK_SIZE(sb) - 1);
+	if (in_range(dir->i_size, size1, EXT4_BLOCK_SIZE(sb)) ||
+	    in_range(dir->i_size, size2, EXT4_BLOCK_SIZE(sb)))
+		return true;
+
+	return false;
+}
+
 /*
  *	ext4_add_entry()
  *
@@ -2739,6 +2796,7 @@ static int ext4_dx_add_entry(handle_t *handle, struct ext4_filename *fname,
 	struct buffer_head *bh;
 	struct super_block *sb = dir->i_sb;
 	struct ext4_dir_entry_2 *de;
+	bool ret_warn = false;
 	int restart;
 	int err;
 
@@ -2769,6 +2827,11 @@ static int ext4_dx_add_entry(handle_t *handle, struct ext4_filename *fname,
 	/* Block full, should compress but for now just split */
 	dxtrace(printk(KERN_DEBUG "using %u of %u node entries\n",
 		       dx_get_count(entries), dx_get_limit(entries)));
+
+	if (frame - frames + 1 >= ext4_dir_htree_level(sb) ||
+	    EXT4_SB(sb)->s_warning_dir_size)
+		ret_warn = dir_size_in_warning_range(frames, frame, dir);
+
 	/* Need to split index? */
 	if (dx_get_count(entries) == dx_get_limit(entries)) {
 		ext4_lblk_t newblock;
@@ -2935,6 +2998,8 @@ static int ext4_dx_add_entry(handle_t *handle, struct ext4_filename *fname,
 	 */
 	if (restart && err == 0)
 		goto again;
+	if (err == 0 && ret_warn)
+		err = -ENOBUFS;
 	return err;
 }
 
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 07242d7..a3179b2 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1901,6 +1901,8 @@ static int handle_mount_opt(struct super_block *sb, char *opt, int token,
 		sbi->s_li_wait_mult = arg;
 	} else if (token == Opt_max_dir_size_kb) {
 		sbi->s_max_dir_size_kb = arg;
+		/* reset s_warning_dir_size and make it re-calculated */
+		sbi->s_warning_dir_size = 0;
 	} else if (token == Opt_stripe) {
 		sbi->s_stripe = arg;
 	} else if (token == Opt_resuid) {
diff --git a/fs/ext4/sysfs.c b/fs/ext4/sysfs.c
index 3a71a16..575f318 100644
--- a/fs/ext4/sysfs.c
+++ b/fs/ext4/sysfs.c
@@ -182,6 +182,7 @@ static ssize_t journal_task_show(struct ext4_sb_info *sbi, char *buf)
 EXT4_RW_ATTR_SBI_UI(inode_goal, s_inode_goal);
 EXT4_RW_ATTR_SBI_UI(max_dir_size, s_max_dir_size_kb);
 EXT4_RW_ATTR_SBI_UI(max_dir_size_kb, s_max_dir_size_kb);
+EXT4_RW_ATTR_SBI_UI(warning_dir_size, s_warning_dir_size);
 EXT4_RW_ATTR_SBI_UI(mb_stats, s_mb_stats);
 EXT4_RW_ATTR_SBI_UI(mb_max_to_scan, s_mb_max_to_scan);
 EXT4_RW_ATTR_SBI_UI(mb_min_to_scan, s_mb_min_to_scan);
@@ -214,6 +215,7 @@ static ssize_t journal_task_show(struct ext4_sb_info *sbi, char *buf)
 	ATTR_LIST(inode_goal),
 	ATTR_LIST(max_dir_size),
 	ATTR_LIST(max_dir_size_kb),
+	ATTR_LIST(warning_dir_size),
 	ATTR_LIST(mb_stats),
 	ATTR_LIST(mb_max_to_scan),
 	ATTR_LIST(mb_min_to_scan),
-- 
1.8.3.1
