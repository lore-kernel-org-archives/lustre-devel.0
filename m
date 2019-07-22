From: James Simmons <jsimmons@infradead.org>
Date: Sun, 21 Jul 2019 21:23:47 -0400
Subject: [lustre-devel] [PATCH 18/22] ext4: attach jinode in writepages
In-Reply-To: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
References: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1563758631-29550-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/ext4/ext4.h  | 1 +
 fs/ext4/inode.c | 7 +++++++
 2 files changed, 8 insertions(+)

diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index 5f73e19..0ee4606 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -2643,6 +2643,7 @@ extern int ext4_group_add_blocks(handle_t *handle, struct super_block *sb,
 extern void ext4_process_freed_data(struct super_block *sb, tid_t commit_tid);
 
 /* inode.c */
+#define HAVE_LDISKFS_INFO_JINODE
 int ext4_inode_is_fast_symlink(struct inode *inode);
 struct buffer_head *ext4_getblk(handle_t *, struct inode *, ext4_lblk_t, int);
 struct buffer_head *ext4_bread(handle_t *, struct inode *, ext4_lblk_t, int);
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 9296611..bf00dfc 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -731,6 +731,9 @@ int ext4_map_blocks(handle_t *handle, struct inode *inode,
 		    !(flags & EXT4_GET_BLOCKS_ZERO) &&
 		    !ext4_is_quota_file(inode) &&
 		    ext4_should_order_data(inode)) {
+			ret = ext4_inode_attach_jinode(inode);
+			if (ret)
+				return ret;
 			if (flags & EXT4_GET_BLOCKS_IO_SUBMIT)
 				ret = ext4_jbd2_inode_add_wait(handle, inode);
 			else
@@ -2815,6 +2818,9 @@ static int ext4_writepages(struct address_space *mapping,
 		mpd.last_page = wbc->range_end >> PAGE_SHIFT;
 	}
 
+	ret = ext4_inode_attach_jinode(inode);
+	if (ret)
+		return ret;
 	mpd.inode = inode;
 	mpd.wbc = wbc;
 	ext4_io_submit_init(&mpd.io_submit, wbc);
@@ -4432,6 +4438,7 @@ int ext4_inode_attach_jinode(struct inode *inode)
 		jbd2_free_inode(jinode);
 	return 0;
 }
+EXPORT_SYMBOL(ext4_inode_attach_jinode);
 
 /*
  * ext4_truncate()
-- 
1.8.3.1
