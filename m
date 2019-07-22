From: James Simmons <jsimmons@infradead.org>
Date: Sun, 21 Jul 2019 21:23:42 -0400
Subject: [lustre-devel] [PATCH 13/22] ext4: Add a proc interface for
 max_dir_size.
In-Reply-To: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
References: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1563758631-29550-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/ext4/sysfs.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/ext4/sysfs.c b/fs/ext4/sysfs.c
index 1375815..3a71a16 100644
--- a/fs/ext4/sysfs.c
+++ b/fs/ext4/sysfs.c
@@ -180,6 +180,8 @@ static ssize_t journal_task_show(struct ext4_sb_info *sbi, char *buf)
 EXT4_ATTR_OFFSET(inode_readahead_blks, 0644, inode_readahead,
 		 ext4_sb_info, s_inode_readahead_blks);
 EXT4_RW_ATTR_SBI_UI(inode_goal, s_inode_goal);
+EXT4_RW_ATTR_SBI_UI(max_dir_size, s_max_dir_size_kb);
+EXT4_RW_ATTR_SBI_UI(max_dir_size_kb, s_max_dir_size_kb);
 EXT4_RW_ATTR_SBI_UI(mb_stats, s_mb_stats);
 EXT4_RW_ATTR_SBI_UI(mb_max_to_scan, s_mb_max_to_scan);
 EXT4_RW_ATTR_SBI_UI(mb_min_to_scan, s_mb_min_to_scan);
@@ -210,6 +212,8 @@ static ssize_t journal_task_show(struct ext4_sb_info *sbi, char *buf)
 	ATTR_LIST(reserved_clusters),
 	ATTR_LIST(inode_readahead_blks),
 	ATTR_LIST(inode_goal),
+	ATTR_LIST(max_dir_size),
+	ATTR_LIST(max_dir_size_kb),
 	ATTR_LIST(mb_stats),
 	ATTR_LIST(mb_max_to_scan),
 	ATTR_LIST(mb_min_to_scan),
@@ -350,6 +354,8 @@ static ssize_t ext4_attr_store(struct kobject *kobj,
 		ret = kstrtoul(skip_spaces(buf), 0, &t);
 		if (ret)
 			return ret;
+		if (strcmp("max_dir_size", a->attr.name) == 0)
+			t >>= 10;
 		if (a->attr_ptr == ptr_ext4_super_block_offset)
 			*((__le32 *) ptr) = cpu_to_le32(t);
 		else
-- 
1.8.3.1
