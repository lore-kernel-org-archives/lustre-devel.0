From: James Simmons <jsimmons@infradead.org>
Date: Sun, 21 Jul 2019 21:23:39 -0400
Subject: [lustre-devel] [PATCH 10/22] ext4: add data in dentry feature
In-Reply-To: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
References: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1563758631-29550-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Lustre likes to stuff extra data into dentrys.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/ext4/dir.c    |  14 ++--
 fs/ext4/ext4.h   |  92 +++++++++++++++++++++--
 fs/ext4/inline.c |  16 ++--
 fs/ext4/namei.c  | 217 +++++++++++++++++++++++++++++++++++++++++++------------
 fs/ext4/super.c  |   4 +-
 5 files changed, 278 insertions(+), 65 deletions(-)

diff --git a/fs/ext4/dir.c b/fs/ext4/dir.c
index c7843b1..20e0d32 100644
--- a/fs/ext4/dir.c
+++ b/fs/ext4/dir.c
@@ -70,11 +70,11 @@ int __ext4_check_dir_entry(const char *function, unsigned int line,
 	const int rlen = ext4_rec_len_from_disk(de->rec_len,
 						dir->i_sb->s_blocksize);
 
-	if (unlikely(rlen < EXT4_DIR_REC_LEN(1)))
+	if (unlikely(rlen < __EXT4_DIR_REC_LEN(1)))
 		error_msg = "rec_len is smaller than minimal";
 	else if (unlikely(rlen % 4 != 0))
 		error_msg = "rec_len % 4 != 0";
-	else if (unlikely(rlen < EXT4_DIR_REC_LEN(de->name_len)))
+	else if (unlikely(rlen < __EXT4_DIR_REC_LEN(de->name_len)))
 		error_msg = "rec_len is too small for name_len";
 	else if (unlikely(((char *) de - buf) + rlen > size))
 		error_msg = "directory entry overrun";
@@ -219,7 +219,7 @@ static int ext4_readdir(struct file *file, struct dir_context *ctx)
 				 * failure will be detected in the
 				 * dirent test below. */
 				if (ext4_rec_len_from_disk(de->rec_len,
-					sb->s_blocksize) < EXT4_DIR_REC_LEN(1))
+					sb->s_blocksize) < __EXT4_DIR_REC_LEN(1))
 					break;
 				i += ext4_rec_len_from_disk(de->rec_len,
 							    sb->s_blocksize);
@@ -441,13 +441,17 @@ int ext4_htree_store_dirent(struct file *dir_file, __u32 hash,
 	struct rb_node **p, *parent = NULL;
 	struct fname *fname, *new_fn;
 	struct dir_private_info *info;
+	int extra_data = 0;
 	int len;
 
 	info = dir_file->private_data;
 	p = &info->root.rb_node;
 
 	/* Create and allocate the fname structure */
-	len = sizeof(struct fname) + ent_name->len + 1;
+	if (dirent->file_type & EXT4_DIRENT_LUFID)
+		extra_data = ext4_get_dirent_data_len(dirent);
+
+	len = sizeof(struct fname) + ent_name->len + extra_data + 1;
 	new_fn = kzalloc(len, GFP_KERNEL);
 	if (!new_fn)
 		return -ENOMEM;
@@ -456,7 +460,7 @@ int ext4_htree_store_dirent(struct file *dir_file, __u32 hash,
 	new_fn->inode = le32_to_cpu(dirent->inode);
 	new_fn->name_len = ent_name->len;
 	new_fn->file_type = dirent->file_type;
-	memcpy(new_fn->name, ent_name->name, ent_name->len);
+	memcpy(new_fn->name, ent_name->name, ent_name->len + extra_data);
 	new_fn->name[ent_name->len] = 0;
 
 	while (*p) {
diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index e321286..51b6159 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -1069,6 +1069,7 @@ struct ext4_inode_info {
 	__u32 i_csum_seed;
 
 	kprojid_t i_projid;
+	void *i_dirdata;
 };
 
 /*
@@ -1112,6 +1113,7 @@ struct ext4_inode_info {
 #define EXT4_MOUNT_POSIX_ACL		0x08000	/* POSIX Access Control Lists */
 #define EXT4_MOUNT_NO_AUTO_DA_ALLOC	0x10000	/* No auto delalloc mapping */
 #define EXT4_MOUNT_BARRIER		0x20000 /* Use block barriers */
+#define EXT4_MOUNT_DIRDATA		0x40000 /* Data in directory entries */
 #define EXT4_MOUNT_QUOTA		0x40000 /* Some quota option set */
 #define EXT4_MOUNT_USRQUOTA		0x80000 /* "old" user quota,
 						 * enable enforcement for hidden
@@ -1805,6 +1807,7 @@ static inline void ext4_clear_state_flags(struct ext4_inode_info *ei)
 					 EXT4_FEATURE_INCOMPAT_FLEX_BG| \
 					 EXT4_FEATURE_INCOMPAT_EA_INODE| \
 					 EXT4_FEATURE_INCOMPAT_MMP | \
+					 EXT4_FEATURE_INCOMPAT_DIRDATA | \
 					 EXT4_FEATURE_INCOMPAT_INLINE_DATA | \
 					 EXT4_FEATURE_INCOMPAT_ENCRYPT | \
 					 EXT4_FEATURE_INCOMPAT_CASEFOLD | \
@@ -1984,6 +1987,43 @@ struct ext4_dir_entry_tail {
 #define EXT4_FT_SYMLINK		7
 
 #define EXT4_FT_MAX		8
+#define EXT4_FT_MASK           0xf
+
+#if EXT4_FT_MAX > EXT4_FT_MASK
+#error "conflicting EXT4_FT_MAX and EXT4_FT_MASK"
+#endif
+
+/*
+ * d_type has 4 unused bits, so it can hold four types data. these different
+ * type of data (e.g. lustre data, high 32 bits of 64-bit inode number) can be
+ * stored, in flag order, after file-name in ext4 dirent.
+*/
+/*
+ * this flag is added to d_type if ext4 dirent has extra data after
+ * filename. this data length is variable and length is stored in first byte
+ * of data. data start after filename NUL byte.
+ * This is used by Lustre FS.
+ */
+#define EXT4_DIRENT_LUFID	0x10
+
+#define EXT4_LUFID_MAGIC	0xAD200907UL
+struct ext4_dentry_param {
+	__u32  edp_magic;	/* EXT4_LUFID_MAGIC */
+	char   edp_len;		/* size of edp_data in bytes */
+	char   edp_data[0];	/* packed array of data */
+} __packed;
+
+static inline unsigned char *ext4_dentry_get_data(struct super_block *sb,
+						  struct ext4_dentry_param *p)
+{
+	if (!ext4_has_feature_dirdata(sb))
+		return NULL;
+
+	if (p && p->edp_magic == EXT4_LUFID_MAGIC)
+		return &p->edp_len;
+	else
+		return NULL;
+}
 
 #define EXT4_FT_DIR_CSUM	0xDE
 
@@ -1994,8 +2034,11 @@ struct ext4_dir_entry_tail {
  */
 #define EXT4_DIR_PAD			4
 #define EXT4_DIR_ROUND			(EXT4_DIR_PAD - 1)
-#define EXT4_DIR_REC_LEN(name_len)	(((name_len) + 8 + EXT4_DIR_ROUND) & \
+#define __EXT4_DIR_REC_LEN(name_len)	(((name_len) + 8 + EXT4_DIR_ROUND) & \
 					 ~EXT4_DIR_ROUND)
+#define EXT4_DIR_REC_LEN(de)		(__EXT4_DIR_REC_LEN((de)->name_len +\
+					 ext4_get_dirent_data_len(de)))
+
 #define EXT4_MAX_REC_LEN		((1<<16)-1)
 
 /*
@@ -2422,11 +2465,11 @@ extern int ext4_find_dest_de(struct inode *dir, struct inode *inode,
 			     struct buffer_head *bh,
 			     void *buf, int buf_size,
 			     struct ext4_filename *fname,
-			     struct ext4_dir_entry_2 **dest_de);
+			     struct ext4_dir_entry_2 **dest_de, int *dlen);
 void ext4_insert_dentry(struct inode *inode,
 			struct ext4_dir_entry_2 *de,
 			int buf_size,
-			struct ext4_filename *fname);
+			struct ext4_filename *fname, void *data);
 static inline void ext4_update_dx_flag(struct inode *inode)
 {
 	if (!ext4_has_feature_dir_index(inode->i_sb))
@@ -2438,11 +2481,18 @@ static inline void ext4_update_dx_flag(struct inode *inode)
 
 static inline  unsigned char get_dtype(struct super_block *sb, int filetype)
 {
-	if (!ext4_has_feature_filetype(sb) || filetype >= EXT4_FT_MAX)
+	int fl_index = filetype & EXT4_FT_MASK;
+
+	if (!ext4_has_feature_filetype(sb) || fl_index >= EXT4_FT_MAX)
 		return DT_UNKNOWN;
 
-	return ext4_filetype_table[filetype];
+	if (!test_opt(sb, DIRDATA))
+		return ext4_filetype_table[fl_index];
+
+	return (ext4_filetype_table[fl_index]) |
+		(filetype & EXT4_DIRENT_LUFID);
 }
+
 extern int ext4_check_all_de(struct inode *dir, struct buffer_head *bh,
 			     void *buf, int buf_size);
 
@@ -2604,6 +2654,8 @@ extern struct inode *ext4_create_inode(handle_t *handle,
 extern int ext4_delete_entry(handle_t *handle, struct inode * dir,
 			     struct ext4_dir_entry_2 *de_del,
 			     struct buffer_head *bh);
+extern int ext4_add_dot_dotdot(handle_t *handle, struct inode *dir,
+			       struct inode *inode, const void *, const void *);
 extern int ext4_htree_fill_tree(struct file *dir_file, __u32 start_hash,
 				__u32 start_minor_hash, __u32 *next_hash);
 extern int ext4_search_dir(struct buffer_head *bh,
@@ -3339,6 +3391,36 @@ static inline void ext4_clear_io_unwritten_flag(ext4_io_end_t *io_end)
 
 extern const struct iomap_ops ext4_iomap_ops;
 
+/*
+ * Compute the total directory entry data length.
+ * This includes the filename and an implicit NUL terminator (always present),
+ * and optional extensions.  Each extension has a bit set in the high 4 bits of
+ * de->file_type, and the extension length is the first byte in each entry.
+ */
+static inline int ext4_get_dirent_data_len(struct ext4_dir_entry_2 *de)
+{
+	char *len = de->name + de->name_len + 1 /* NUL terminator */;
+	int dlen = 0;
+	u8 extra_data_flags = (de->file_type & ~EXT4_FT_MASK) >> 4;
+	struct ext4_dir_entry_tail *t = (struct ext4_dir_entry_tail *)de;
+
+	if (!t->det_reserved_zero1 &&
+	    le16_to_cpu(t->det_rec_len) ==
+		sizeof(struct ext4_dir_entry_tail) &&
+	    !t->det_reserved_zero2 &&
+	    t->det_reserved_ft == EXT4_FT_DIR_CSUM)
+		return 0;
+
+	while (extra_data_flags) {
+		if (extra_data_flags & 1) {
+			dlen += *len + (dlen == 0);
+			len += *len;
+		}
+		extra_data_flags >>= 1;
+	}
+	return dlen;
+}
+
 #endif	/* __KERNEL__ */
 
 #define EFSBADCRC	EBADMSG		/* Bad CRC detected */
diff --git a/fs/ext4/inline.c b/fs/ext4/inline.c
index f73bc39..7610cfe 100644
--- a/fs/ext4/inline.c
+++ b/fs/ext4/inline.c
@@ -1023,7 +1023,7 @@ static int ext4_add_dirent_to_inline(handle_t *handle,
 	struct ext4_dir_entry_2 *de;
 
 	err = ext4_find_dest_de(dir, inode, iloc->bh, inline_start,
-				inline_size, fname, &de);
+				inline_size, fname, &de, NULL);
 	if (err)
 		return err;
 
@@ -1031,7 +1031,7 @@ static int ext4_add_dirent_to_inline(handle_t *handle,
 	err = ext4_journal_get_write_access(handle, iloc->bh);
 	if (err)
 		return err;
-	ext4_insert_dentry(inode, de, inline_size, fname);
+	ext4_insert_dentry(inode, de, inline_size, fname, NULL);
 
 	ext4_show_inline_dir(dir, iloc->bh, inline_start, inline_size);
 
@@ -1100,7 +1100,7 @@ static int ext4_update_inline_dir(handle_t *handle, struct inode *dir,
 	int old_size = EXT4_I(dir)->i_inline_size - EXT4_MIN_INLINE_DATA_SIZE;
 	int new_size = get_max_inline_xattr_value_size(dir, iloc);
 
-	if (new_size - old_size <= EXT4_DIR_REC_LEN(1))
+	if (new_size - old_size <= __EXT4_DIR_REC_LEN(1))
 		return -ENOSPC;
 
 	ret = ext4_update_inline_data(handle, dir,
@@ -1381,7 +1381,7 @@ int htree_inlinedir_to_tree(struct file *dir_file,
 			fake.name_len = 1;
 			strcpy(fake.name, ".");
 			fake.rec_len = ext4_rec_len_to_disk(
-						EXT4_DIR_REC_LEN(fake.name_len),
+						EXT4_DIR_REC_LEN(&fake),
 						inline_size);
 			ext4_set_de_type(inode->i_sb, &fake, S_IFDIR);
 			de = &fake;
@@ -1391,7 +1391,7 @@ int htree_inlinedir_to_tree(struct file *dir_file,
 			fake.name_len = 2;
 			strcpy(fake.name, "..");
 			fake.rec_len = ext4_rec_len_to_disk(
-						EXT4_DIR_REC_LEN(fake.name_len),
+						EXT4_DIR_REC_LEN(&fake),
 						inline_size);
 			ext4_set_de_type(inode->i_sb, &fake, S_IFDIR);
 			de = &fake;
@@ -1489,8 +1489,8 @@ int ext4_read_inline_dir(struct file *file,
 	 * So we will use extra_offset and extra_size to indicate them
 	 * during the inline dir iteration.
 	 */
-	dotdot_offset = EXT4_DIR_REC_LEN(1);
-	dotdot_size = dotdot_offset + EXT4_DIR_REC_LEN(2);
+	dotdot_offset = __EXT4_DIR_REC_LEN(1);
+	dotdot_size = dotdot_offset + __EXT4_DIR_REC_LEN(2);
 	extra_offset = dotdot_size - EXT4_INLINE_DOTDOT_SIZE;
 	extra_size = extra_offset + inline_size;
 
@@ -1525,7 +1525,7 @@ int ext4_read_inline_dir(struct file *file,
 			 * failure will be detected in the
 			 * dirent test below. */
 			if (ext4_rec_len_from_disk(de->rec_len, extra_size)
-				< EXT4_DIR_REC_LEN(1))
+				< __EXT4_DIR_REC_LEN(1))
 				break;
 			i += ext4_rec_len_from_disk(de->rec_len,
 						    extra_size);
diff --git a/fs/ext4/namei.c b/fs/ext4/namei.c
index 4c45570..9cb86e4 100644
--- a/fs/ext4/namei.c
+++ b/fs/ext4/namei.c
@@ -243,7 +243,9 @@ struct dx_tail {
 static unsigned dx_get_limit(struct dx_entry *entries);
 static void dx_set_count(struct dx_entry *entries, unsigned value);
 static void dx_set_limit(struct dx_entry *entries, unsigned value);
-static unsigned dx_root_limit(struct inode *dir, unsigned infosize);
+static unsigned int inline dx_root_limit(struct inode *dir,
+					 struct ext4_dir_entry_2 *dot_de,
+					 unsigned int infosize);
 static unsigned dx_node_limit(struct inode *dir);
 static struct dx_frame *dx_probe(struct ext4_filename *fname,
 				 struct inode *dir,
@@ -384,24 +386,26 @@ static struct dx_countlimit *get_dx_countlimit(struct inode *inode,
 					       struct ext4_dir_entry *dirent,
 					       int *offset)
 {
+	int dot_rec_len, dotdot_rec_len;
 	struct ext4_dir_entry *dp;
 	struct dx_root_info *root;
 	int count_offset;
 
 	if (le16_to_cpu(dirent->rec_len) == EXT4_BLOCK_SIZE(inode->i_sb))
 		count_offset = 8;
-	else if (le16_to_cpu(dirent->rec_len) == 12) {
-		dp = (struct ext4_dir_entry *)(((void *)dirent) + 12);
+	else {
+		dot_rec_len = le16_to_cpu(dirent->rec_len);
+		dp = (struct ext4_dir_entry *)(((void *)dirent) + dot_rec_len);
 		if (le16_to_cpu(dp->rec_len) !=
-		    EXT4_BLOCK_SIZE(inode->i_sb) - 12)
+		    EXT4_BLOCK_SIZE(inode->i_sb) - dot_rec_len)
 			return NULL;
-		root = (struct dx_root_info *)(((void *)dp + 12));
+		dotdot_rec_len = EXT4_DIR_REC_LEN((struct ext4_dir_entry_2 *)dp);
+		root = (struct dx_root_info *)(((void *)dp + dotdot_rec_len));
 		if (root->reserved_zero ||
 		    root->info_length != sizeof(struct dx_root_info))
 			return NULL;
-		count_offset = 32;
-	} else
-		return NULL;
+		count_offset = 8 + dot_rec_len + dotdot_rec_len;
+	}
 
 	if (offset)
 		*offset = count_offset;
@@ -507,10 +511,10 @@ static inline int ext4_handle_dirty_dx_node(handle_t *handle,
 struct dx_root_info *dx_get_dx_info(struct ext4_dir_entry_2 *de)
 {
 	/* get dotdot first */
-	de = (struct ext4_dir_entry_2 *)((char *)de + EXT4_DIR_REC_LEN(1));
+	de = (struct ext4_dir_entry_2 *)((char *)de + EXT4_DIR_REC_LEN(de));
 
 	/* dx root info is after dotdot entry */
-	de = (struct ext4_dir_entry_2 *)((char *)de + EXT4_DIR_REC_LEN(2));
+	de = (struct ext4_dir_entry_2 *)((char *)de + EXT4_DIR_REC_LEN(de));
 
 	return (struct dx_root_info *)de;
 }
@@ -555,10 +559,17 @@ static inline void dx_set_limit(struct dx_entry *entries, unsigned value)
 	((struct dx_countlimit *) entries)->limit = cpu_to_le16(value);
 }
 
-static inline unsigned dx_root_limit(struct inode *dir, unsigned infosize)
+static inline unsigned int dx_root_limit(struct inode *dir,
+					 struct ext4_dir_entry_2 *dot_de,
+					 unsigned int infosize)
 {
-	unsigned entry_space = dir->i_sb->s_blocksize - EXT4_DIR_REC_LEN(1) -
-		EXT4_DIR_REC_LEN(2) - infosize;
+	struct ext4_dir_entry_2 *dotdot_de;
+	unsigned int entry_space;
+
+	BUG_ON(dot_de->name_len != 1);
+	dotdot_de = ext4_next_entry(dot_de, dir->i_sb->s_blocksize);
+	entry_space = dir->i_sb->s_blocksize - EXT4_DIR_REC_LEN(dot_de) -
+		      EXT4_DIR_REC_LEN(dotdot_de) - infosize;
 
 	if (ext4_has_metadata_csum(dir->i_sb))
 		entry_space -= sizeof(struct dx_tail);
@@ -567,7 +578,7 @@ static inline unsigned dx_root_limit(struct inode *dir, unsigned infosize)
 
 static inline unsigned dx_node_limit(struct inode *dir)
 {
-	unsigned entry_space = dir->i_sb->s_blocksize - EXT4_DIR_REC_LEN(0);
+	unsigned entry_space = dir->i_sb->s_blocksize - __EXT4_DIR_REC_LEN(0);
 
 	if (ext4_has_metadata_csum(dir->i_sb))
 		entry_space -= sizeof(struct dx_tail);
@@ -679,7 +690,7 @@ static struct stats dx_show_leaf(struct inode *dir,
 				       (unsigned) ((char *) de - base));
 #endif
 			}
-			space += EXT4_DIR_REC_LEN(de->name_len);
+			space += EXT4_DIR_REC_LEN(de);
 			names++;
 		}
 		de = ext4_next_entry(de, size);
@@ -787,11 +798,14 @@ struct stats dx_show_entries(struct dx_hash_info *hinfo, struct inode *dir,
 
 	entries = (struct dx_entry *)(((char *)info) + info->info_length);
 
-	if (dx_get_limit(entries) != dx_root_limit(dir,
-						   info->info_length)) {
+	if (dx_get_limit(entries) !=
+	    dx_root_limit(dir, (struct ext4_dir_entry_2 *)frame->bh->b_data,
+			  info->info_length)) {
 		ext4_warning_inode(dir, "dx entry: limit %u != root limit %u",
 				   dx_get_limit(entries),
-				   dx_root_limit(dir, info->info_length));
+				   dx_root_limit(dir,
+						 (struct ext4_dir_entry_2 *)frame->bh->b_data,
+						 info->info_length));
 		goto fail;
 	}
 
@@ -986,7 +1000,7 @@ static int htree_dirblock_to_tree(struct file *dir_file,
 	de = (struct ext4_dir_entry_2 *) bh->b_data;
 	top = (struct ext4_dir_entry_2 *) ((char *) de +
 					   dir->i_sb->s_blocksize -
-					   EXT4_DIR_REC_LEN(0));
+					   __EXT4_DIR_REC_LEN(0));
 #ifdef CONFIG_FS_ENCRYPTION
 	/* Check if the directory is encrypted */
 	if (IS_ENCRYPTED(dir)) {
@@ -1743,7 +1757,7 @@ struct dentry *ext4_get_parent(struct dentry *child)
 	while (count--) {
 		struct ext4_dir_entry_2 *de = (struct ext4_dir_entry_2 *)
 						(from + (map->offs<<2));
-		rec_len = EXT4_DIR_REC_LEN(de->name_len);
+		rec_len = EXT4_DIR_REC_LEN(de);
 		memcpy (to, de, rec_len);
 		((struct ext4_dir_entry_2 *) to)->rec_len =
 				ext4_rec_len_to_disk(rec_len, blocksize);
@@ -1767,7 +1781,7 @@ static struct ext4_dir_entry_2* dx_pack_dirents(char *base, unsigned blocksize)
 	while ((char*)de < base + blocksize) {
 		next = ext4_next_entry(de, blocksize);
 		if (de->inode && de->name_len) {
-			rec_len = EXT4_DIR_REC_LEN(de->name_len);
+			rec_len = EXT4_DIR_REC_LEN(de);
 			if (de > to)
 				memmove(to, de, rec_len);
 			to->rec_len = ext4_rec_len_to_disk(rec_len, blocksize);
@@ -1898,14 +1912,16 @@ int ext4_find_dest_de(struct inode *dir, struct inode *inode,
 		      struct buffer_head *bh,
 		      void *buf, int buf_size,
 		      struct ext4_filename *fname,
-		      struct ext4_dir_entry_2 **dest_de)
+		      struct ext4_dir_entry_2 **dest_de, int *dlen)
 {
 	struct ext4_dir_entry_2 *de;
-	unsigned short reclen = EXT4_DIR_REC_LEN(fname_len(fname));
+	unsigned short reclen = __EXT4_DIR_REC_LEN(fname_len(fname)) +
+						   (dlen ? *dlen : 0);
 	int nlen, rlen;
 	unsigned int offset = 0;
 	char *top;
 
+	dlen ? *dlen = 0 : 0; /* default set to 0 */
 	de = (struct ext4_dir_entry_2 *)buf;
 	top = buf + buf_size - reclen;
 	while ((char *) de <= top) {
@@ -1914,10 +1930,29 @@ int ext4_find_dest_de(struct inode *dir, struct inode *inode,
 			return -EFSCORRUPTED;
 		if (ext4_match(dir, fname, de))
 			return -EEXIST;
-		nlen = EXT4_DIR_REC_LEN(de->name_len);
+		nlen = EXT4_DIR_REC_LEN(de);
 		rlen = ext4_rec_len_from_disk(de->rec_len, buf_size);
 		if ((de->inode ? rlen - nlen : rlen) >= reclen)
 			break;
+		/* Then for dotdot entries, check for the smaller space
+		 * required for just the entry, no FID
+		 */
+		if (fname_len(fname) == 2 && memcmp(fname_name(fname), "..", 2) == 0) {
+			if ((de->inode ? rlen - nlen : rlen) >=
+			    __EXT4_DIR_REC_LEN(fname_len(fname))) {
+				/* set dlen=1 to indicate not
+				 * enough space store fid
+				 */
+				dlen ? *dlen = 1 : 0;
+				break;
+			}
+			/* The new ".." entry must be written over the
+			 * previous ".." entry, which is the first
+			 * entry traversed by this scan. If it doesn't
+			 * fit, something is badly wrong, so -EIO.
+			 */
+			return -EIO;
+		}
 		de = (struct ext4_dir_entry_2 *)((char *)de + rlen);
 		offset += rlen;
 	}
@@ -1931,12 +1966,12 @@ int ext4_find_dest_de(struct inode *dir, struct inode *inode,
 void ext4_insert_dentry(struct inode *inode,
 			struct ext4_dir_entry_2 *de,
 			int buf_size,
-			struct ext4_filename *fname)
+			struct ext4_filename *fname, void *data )
 {
 
 	int nlen, rlen;
 
-	nlen = EXT4_DIR_REC_LEN(de->name_len);
+	nlen = EXT4_DIR_REC_LEN(de);
 	rlen = ext4_rec_len_from_disk(de->rec_len, buf_size);
 	if (de->inode) {
 		struct ext4_dir_entry_2 *de1 =
@@ -1950,6 +1985,11 @@ void ext4_insert_dentry(struct inode *inode,
 	ext4_set_de_type(inode->i_sb, de, inode->i_mode);
 	de->name_len = fname_len(fname);
 	memcpy(de->name, fname_name(fname), fname_len(fname));
+	if (data) {
+		de->name[fname_len(fname)] = 0;
+		memcpy(&de->name[fname_len(fname) + 1], data, *(char *)data);
+		de->file_type |= EXT4_DIRENT_LUFID;
+	}
 }
 
 /*
@@ -1966,15 +2006,21 @@ static int add_dirent_to_buf(handle_t *handle, struct ext4_filename *fname,
 			     struct buffer_head *bh)
 {
 	unsigned int	blocksize = dir->i_sb->s_blocksize;
+	unsigned char *data;
 	int		csum_size = 0;
+	int dlen = 0;
 	int		err;
 
+	data = ext4_dentry_get_data(inode->i_sb,
+				    (struct ext4_dentry_param *)EXT4_I(inode)->i_dirdata);
 	if (ext4_has_metadata_csum(inode->i_sb))
 		csum_size = sizeof(struct ext4_dir_entry_tail);
 
 	if (!de) {
+		if (data)
+			dlen = (*data) + 1;
 		err = ext4_find_dest_de(dir, inode, bh, bh->b_data,
-					blocksize - csum_size, fname, &de);
+					blocksize - csum_size, fname, &de, &dlen);
 		if (err)
 			return err;
 	}
@@ -1986,7 +2032,10 @@ static int add_dirent_to_buf(handle_t *handle, struct ext4_filename *fname,
 	}
 
 	/* By now the buffer is marked for journaling */
-	ext4_insert_dentry(inode, de, blocksize, fname);
+	/* If writing the short form of "dotdot", don't add the data section */
+	if (dlen == 1)
+		data = NULL;
+	ext4_insert_dentry(inode, de, blocksize, fname, data);
 
 	/*
 	 * XXX shouldn't update any times until successful
@@ -2095,7 +2144,8 @@ static int make_indexed_dir(handle_t *handle, struct ext4_filename *fname,
 
 	dx_set_block(entries, 1);
 	dx_set_count(entries, 1);
-	dx_set_limit(entries, dx_root_limit(dir, sizeof(*dx_info)));
+	dx_set_limit(entries, dx_root_limit(dir, dot_de,
+					    sizeof(*dx_info)));
 
 	/* Initialize as for dx_probe */
 	fname->hinfo.hash_version = dx_info->hash_version;
@@ -2145,6 +2195,8 @@ static int ext4_update_dotdot(handle_t *handle, struct dentry *dentry,
 	struct buffer_head *dir_block;
 	struct ext4_dir_entry_2 *de;
 	int len, journal = 0, err = 0;
+	int dlen = 0;
+	char *data;
 
 	if (IS_ERR(handle))
 		return PTR_ERR(handle);
@@ -2162,19 +2214,24 @@ static int ext4_update_dotdot(handle_t *handle, struct dentry *dentry,
 	/* the first item must be "." */
 	assert(de->name_len == 1 && de->name[0] == '.');
 	len = le16_to_cpu(de->rec_len);
-	assert(len >= EXT4_DIR_REC_LEN(1));
-	if (len > EXT4_DIR_REC_LEN(1)) {
+	assert(len >= __EXT4_DIR_REC_LEN(1));
+	if (len > __EXT4_DIR_REC_LEN(1)) {
 		BUFFER_TRACE(dir_block, "get_write_access");
 		err = ext4_journal_get_write_access(handle, dir_block);
 		if (err)
 			goto out_journal;
 
 		journal = 1;
-		de->rec_len = cpu_to_le16(EXT4_DIR_REC_LEN(1));
+		de->rec_len = cpu_to_le16(EXT4_DIR_REC_LEN(de));
 	}
 
-	len -= EXT4_DIR_REC_LEN(1);
-	assert(len == 0 || len >= EXT4_DIR_REC_LEN(2));
+	len -= EXT4_DIR_REC_LEN(de);
+	data = ext4_dentry_get_data(dir->i_sb,
+			(struct ext4_dentry_param *)dentry->d_fsdata);
+	if (data)
+		dlen = *data + 1;
+	assert(len == 0 || len >= __EXT4_DIR_REC_LEN(2 + dlen));
+
 	de = (struct ext4_dir_entry_2 *)
 		((char *) de + le16_to_cpu(de->rec_len));
 	if (!journal) {
@@ -2188,10 +2245,15 @@ static int ext4_update_dotdot(handle_t *handle, struct dentry *dentry,
 	if (len > 0)
 		de->rec_len = cpu_to_le16(len);
 	else
-		assert(le16_to_cpu(de->rec_len) >= EXT4_DIR_REC_LEN(2));
+		assert(le16_to_cpu(de->rec_len) >= __EXT4_DIR_REC_LEN(2));
 	de->name_len = 2;
 	strcpy(de->name, "..");
-	ext4_set_de_type(dir->i_sb, de, S_IFDIR);
+	if (data && ext4_get_dirent_data_len(de) >= dlen) {
+		de->name[2] = 0;
+		memcpy(&de->name[2 + 1], data, *data);
+		ext4_set_de_type(dir->i_sb, de, S_IFDIR);
+		de->file_type |= EXT4_DIRENT_LUFID;
+	}
 
 out_journal:
 	if (journal) {
@@ -2230,6 +2292,7 @@ static int ext4_add_entry(handle_t *handle, struct dentry *dentry,
 	ext4_lblk_t block, blocks;
 	int	csum_size = 0;
 
+	EXT4_I(inode)->i_dirdata = dentry->d_fsdata;
 	if (ext4_has_metadata_csum(inode->i_sb))
 		csum_size = sizeof(struct ext4_dir_entry_tail);
 
@@ -2757,37 +2820,71 @@ static int ext4_tmpfile(struct inode *dir, struct dentry *dentry, umode_t mode)
 	return err;
 }
 
+struct tp_block {
+	struct inode	*inode;
+	void		*data1;
+	void		*data2;
+};
+
 struct ext4_dir_entry_2 *ext4_init_dot_dotdot(struct inode *inode,
 			  struct ext4_dir_entry_2 *de,
 			  int blocksize, int csum_size,
 			  unsigned int parent_ino, int dotdot_real_len)
 {
+	void *data1 = NULL, *data2 = NULL;
+	int dot_reclen = 0;
+
+	if (dotdot_real_len == 10) {
+		struct tp_block *tpb = (struct tp_block *)inode;
+
+		data1 = tpb->data1;
+		data2 = tpb->data2;
+		inode = tpb->inode;
+		dotdot_real_len = 0;
+	}
 	de->inode = cpu_to_le32(inode->i_ino);
 	de->name_len = 1;
-	de->rec_len = ext4_rec_len_to_disk(EXT4_DIR_REC_LEN(de->name_len),
-					   blocksize);
 	strcpy(de->name, ".");
 	ext4_set_de_type(inode->i_sb, de, S_IFDIR);
 
+	/* get packed fid data*/
+	data1 = ext4_dentry_get_data(inode->i_sb,
+			(struct ext4_dentry_param *) data1);
+	if (data1) {
+		de->name[1] = 0;
+		memcpy(&de->name[2], data1, *(char *) data1);
+		de->file_type |= EXT4_DIRENT_LUFID;
+	}
+	de->rec_len = cpu_to_le16(EXT4_DIR_REC_LEN(de));
+	dot_reclen = cpu_to_le16(de->rec_len);
 	de = ext4_next_entry(de, blocksize);
 	de->inode = cpu_to_le32(parent_ino);
 	de->name_len = 2;
+	strcpy(de->name, "..");
+	ext4_set_de_type(inode->i_sb, de, S_IFDIR);
+	data2 = ext4_dentry_get_data(inode->i_sb,
+			(struct ext4_dentry_param *) data2);
+	if (data2) {
+		de->name[2] = 0;
+		memcpy(&de->name[3], data2, *(char *) data2);
+		de->file_type |= EXT4_DIRENT_LUFID;
+	}
 	if (!dotdot_real_len)
 		de->rec_len = ext4_rec_len_to_disk(blocksize -
-					(csum_size + EXT4_DIR_REC_LEN(1)),
+					(csum_size + dot_reclen),
 					blocksize);
 	else
 		de->rec_len = ext4_rec_len_to_disk(
-				EXT4_DIR_REC_LEN(de->name_len), blocksize);
-	strcpy(de->name, "..");
-	ext4_set_de_type(inode->i_sb, de, S_IFDIR);
+				EXT4_DIR_REC_LEN(de), blocksize);
 
 	return ext4_next_entry(de, blocksize);
 }
 
 static int ext4_init_new_dir(handle_t *handle, struct inode *dir,
-			     struct inode *inode)
+			     struct inode *inode,
+			     const void *data1, const void *data2)
 {
+	struct tp_block param;
 	struct buffer_head *dir_block = NULL;
 	struct ext4_dir_entry_2 *de;
 	struct ext4_dir_entry_tail *t;
@@ -2812,7 +2909,11 @@ static int ext4_init_new_dir(handle_t *handle, struct inode *dir,
 	if (IS_ERR(dir_block))
 		return PTR_ERR(dir_block);
 	de = (struct ext4_dir_entry_2 *)dir_block->b_data;
-	ext4_init_dot_dotdot(inode, de, blocksize, csum_size, dir->i_ino, 0);
+	param.inode = inode;
+	param.data1 = (void *)data1;
+	param.data2 = (void *)data2;
+	ext4_init_dot_dotdot((struct inode *)(&param), de, blocksize,
+			     csum_size, dir->i_ino, 10);
 	set_nlink(inode, 2);
 	if (csum_size) {
 		t = EXT4_DIRENT_TAIL(dir_block->b_data, blocksize);
@@ -2829,6 +2930,30 @@ static int ext4_init_new_dir(handle_t *handle, struct inode *dir,
 	return err;
 }
 
+/* Initialize @inode as a subdirectory of @dir, and add the
+ * "." and ".." entries into the first directory block.
+ */
+int ext4_add_dot_dotdot(handle_t *handle, struct inode *dir,
+			struct inode *inode,
+			const void *data1, const void *data2)
+{
+	int rc;
+
+	if (IS_ERR(handle))
+		return PTR_ERR(handle);
+
+	if (IS_DIRSYNC(dir))
+		ext4_handle_sync(handle);
+
+	inode->i_op = &ext4_dir_inode_operations;
+	inode->i_fop = &ext4_dir_operations;
+	rc = ext4_init_new_dir(handle, dir, inode, data1, data2);
+	if (!rc)
+		rc = ext4_mark_inode_dirty(handle, inode);
+	return rc;
+}
+EXPORT_SYMBOL(ext4_add_dot_dotdot);
+
 static int ext4_mkdir(struct inode *dir, struct dentry *dentry, umode_t mode)
 {
 	handle_t *handle;
@@ -2855,7 +2980,7 @@ static int ext4_mkdir(struct inode *dir, struct dentry *dentry, umode_t mode)
 
 	inode->i_op = &ext4_dir_inode_operations;
 	inode->i_fop = &ext4_dir_operations;
-	err = ext4_init_new_dir(handle, dir, inode);
+	err = ext4_init_new_dir(handle, dir, inode, NULL, NULL);
 	if (err)
 		goto out_clear_inode;
 	err = ext4_mark_inode_dirty(handle, inode);
@@ -2906,7 +3031,7 @@ bool ext4_empty_dir(struct inode *inode)
 	}
 
 	sb = inode->i_sb;
-	if (inode->i_size < EXT4_DIR_REC_LEN(1) + EXT4_DIR_REC_LEN(2)) {
+	if (inode->i_size < __EXT4_DIR_REC_LEN(1) + __EXT4_DIR_REC_LEN(2)) {
 		EXT4_ERROR_INODE(inode, "invalid size");
 		return true;
 	}
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index d15c26c..564eb35 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1447,7 +1447,7 @@ enum {
 	Opt_data_err_abort, Opt_data_err_ignore, Opt_test_dummy_encryption,
 	Opt_usrjquota, Opt_grpjquota, Opt_offusrjquota, Opt_offgrpjquota,
 	Opt_jqfmt_vfsold, Opt_jqfmt_vfsv0, Opt_jqfmt_vfsv1, Opt_quota,
-	Opt_noquota, Opt_barrier, Opt_nobarrier, Opt_err,
+	Opt_noquota, Opt_barrier, Opt_nobarrier, Opt_err, Opt_dirdata,
 	Opt_usrquota, Opt_grpquota, Opt_prjquota, Opt_i_version, Opt_dax,
 	Opt_stripe, Opt_delalloc, Opt_nodelalloc, Opt_warn_on_error,
 	Opt_nowarn_on_error, Opt_mblk_io_submit,
@@ -1474,6 +1474,7 @@ enum {
 	{Opt_err_ro, "errors=remount-ro"},
 	{Opt_nouid32, "nouid32"},
 	{Opt_debug, "debug"},
+	{Opt_dirdata, "dirdata"},
 	{Opt_removed, "oldalloc"},
 	{Opt_removed, "orlov"},
 	{Opt_user_xattr, "user_xattr"},
@@ -1747,6 +1748,7 @@ static int clear_qf_name(struct super_block *sb, int qtype)
 	{Opt_grpjquota, 0, MOPT_Q},
 	{Opt_offusrjquota, 0, MOPT_Q},
 	{Opt_offgrpjquota, 0, MOPT_Q},
+	{Opt_dirdata, EXT4_MOUNT_DIRDATA, MOPT_SET},
 	{Opt_jqfmt_vfsold, QFMT_VFS_OLD, MOPT_QFMT},
 	{Opt_jqfmt_vfsv0, QFMT_VFS_V0, MOPT_QFMT},
 	{Opt_jqfmt_vfsv1, QFMT_VFS_V1, MOPT_QFMT},
-- 
1.8.3.1
