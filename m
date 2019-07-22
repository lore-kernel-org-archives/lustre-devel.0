From: James Simmons <jsimmons@infradead.org>
Date: Sun, 21 Jul 2019 21:23:33 -0400
Subject: [lustre-devel] [PATCH 04/22] ext4: export inode management
In-Reply-To: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
References: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1563758631-29550-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Make ext4_delete_entry() exportable for osd-ldiskfs. Also add
exportable ext4_create_inode().

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/ext4/ext4.h  |  6 ++++++
 fs/ext4/namei.c | 30 ++++++++++++++++++++++++++----
 2 files changed, 32 insertions(+), 4 deletions(-)

diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index 423ab4d..50f0c50 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -2579,6 +2579,12 @@ extern int ext4_dirent_csum_verify(struct inode *inode,
 				   struct ext4_dir_entry *dirent);
 extern int ext4_orphan_add(handle_t *, struct inode *);
 extern int ext4_orphan_del(handle_t *, struct inode *);
+extern struct inode *ext4_create_inode(handle_t *handle,
+				       struct inode *dir, int mode,
+				       uid_t *owner);
+extern int ext4_delete_entry(handle_t *handle, struct inode * dir,
+			     struct ext4_dir_entry_2 *de_del,
+			     struct buffer_head *bh);
 extern int ext4_htree_fill_tree(struct file *dir_file, __u32 start_hash,
 				__u32 start_minor_hash, __u32 *next_hash);
 extern int ext4_search_dir(struct buffer_head *bh,
diff --git a/fs/ext4/namei.c b/fs/ext4/namei.c
index a52b311..a42a2db 100644
--- a/fs/ext4/namei.c
+++ b/fs/ext4/namei.c
@@ -2459,10 +2459,9 @@ int ext4_generic_delete_entry(handle_t *handle,
 	return -ENOENT;
 }
 
-static int ext4_delete_entry(handle_t *handle,
-			     struct inode *dir,
-			     struct ext4_dir_entry_2 *de_del,
-			     struct buffer_head *bh)
+int ext4_delete_entry(handle_t *handle, struct inode *dir,
+		      struct ext4_dir_entry_2 *de_del,
+		      struct buffer_head *bh)
 {
 	int err, csum_size = 0;
 
@@ -2499,6 +2498,7 @@ static int ext4_delete_entry(handle_t *handle,
 		ext4_std_error(dir->i_sb, err);
 	return err;
 }
+EXPORT_SYMBOL(ext4_delete_entry);
 
 /*
  * Set directory link count to 1 if nlinks > EXT4_LINK_MAX, or if nlinks == 2
@@ -2545,6 +2545,28 @@ static int ext4_add_nondir(handle_t *handle,
 	return err;
 }
 
+/* Return locked inode, then the caller can modify the inode's states/flags
+ * before others finding it. The caller should unlock the inode by itself.
+ */
+struct inode *ext4_create_inode(handle_t *handle, struct inode *dir, int mode,
+				uid_t *owner)
+{
+	struct inode *inode;
+
+	inode = ext4_new_inode(handle, dir, mode, NULL, 0, owner, 0);
+	if (!IS_ERR(inode)) {
+		if (S_ISCHR(mode) || S_ISBLK(mode) || S_ISFIFO(mode)) {
+			inode->i_op = &ext4_special_inode_operations;
+		} else {
+			inode->i_op = &ext4_file_inode_operations;
+			inode->i_fop = &ext4_file_operations;
+			ext4_set_aops(inode);
+		}
+	}
+	return inode;
+}
+EXPORT_SYMBOL(ext4_create_inode);
+
 /*
  * By the time this is called, we already have created
  * the directory cache entry for the new file, but it
-- 
1.8.3.1
