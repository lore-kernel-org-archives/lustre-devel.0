From: James Simmons <jsimmons@infradead.org>
Date: Sun, 21 Jul 2019 21:23:35 -0400
Subject: [lustre-devel] [PATCH 06/22] ext4: add extra checks for mballoc
In-Reply-To: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
References: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1563758631-29550-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Handle mballoc corruptions.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/ext4/ext4.h    |   1 +
 fs/ext4/mballoc.c | 110 +++++++++++++++++++++++++++++++++++++++++++++---------
 fs/ext4/mballoc.h |   2 +-
 3 files changed, 94 insertions(+), 19 deletions(-)

diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index eb2d124..e321286 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -2957,6 +2957,7 @@ struct ext4_group_info {
 	ext4_grpblk_t	bb_fragments;	/* nr of freespace fragments */
 	ext4_grpblk_t	bb_largest_free_order;/* order of largest frag in BG */
 	struct          list_head bb_prealloc_list;
+	unsigned long	bb_prealloc_nr;
 #ifdef DOUBLE_CHECK
 	void            *bb_bitmap;
 #endif
diff --git a/fs/ext4/mballoc.c b/fs/ext4/mballoc.c
index 3be3bef..483fc0f 100644
--- a/fs/ext4/mballoc.c
+++ b/fs/ext4/mballoc.c
@@ -352,8 +352,8 @@
 	"ext4_groupinfo_64k", "ext4_groupinfo_128k"
 };
 
-static void ext4_mb_generate_from_pa(struct super_block *sb, void *bitmap,
-					ext4_group_t group);
+static int ext4_mb_generate_from_pa(struct super_block *sb, void *bitmap,
+				    ext4_group_t group);
 static void ext4_mb_generate_from_freelist(struct super_block *sb, void *bitmap,
 						ext4_group_t group);
 
@@ -708,8 +708,8 @@ static void ext4_mb_mark_free_simple(struct super_block *sb,
 }
 
 static noinline_for_stack
-void ext4_mb_generate_buddy(struct super_block *sb,
-				void *buddy, void *bitmap, ext4_group_t group)
+int ext4_mb_generate_buddy(struct super_block *sb,
+			   void *buddy, void *bitmap, ext4_group_t group)
 {
 	struct ext4_group_info *grp = ext4_get_group_info(sb, group);
 	struct ext4_sb_info *sbi = EXT4_SB(sb);
@@ -752,6 +752,7 @@ void ext4_mb_generate_buddy(struct super_block *sb,
 		grp->bb_free = free;
 		ext4_mark_group_bitmap_corrupted(sb, group,
 					EXT4_GROUP_INFO_BBITMAP_CORRUPT);
+		return -EIO;
 	}
 	mb_set_largest_free_order(sb, grp);
 
@@ -762,6 +763,8 @@ void ext4_mb_generate_buddy(struct super_block *sb,
 	sbi->s_mb_buddies_generated++;
 	sbi->s_mb_generation_time += period;
 	spin_unlock(&sbi->s_bal_lock);
+
+	return 0;
 }
 
 static void mb_regenerate_buddy(struct ext4_buddy *e4b)
@@ -882,7 +885,7 @@ static int ext4_mb_init_cache(struct page *page, char *incore, gfp_t gfp)
 	}
 
 	first_block = page->index * blocks_per_page;
-	for (i = 0; i < blocks_per_page; i++) {
+	for (i = 0; i < blocks_per_page && err == 0; i++) {
 		group = (first_block + i) >> 1;
 		if (group >= ngroups)
 			break;
@@ -926,7 +929,7 @@ static int ext4_mb_init_cache(struct page *page, char *incore, gfp_t gfp)
 			ext4_lock_group(sb, group);
 			/* init the buddy */
 			memset(data, 0xff, blocksize);
-			ext4_mb_generate_buddy(sb, data, incore, group);
+			err = ext4_mb_generate_buddy(sb, data, incore, group);
 			ext4_unlock_group(sb, group);
 			incore = NULL;
 		} else {
@@ -941,7 +944,7 @@ static int ext4_mb_init_cache(struct page *page, char *incore, gfp_t gfp)
 			memcpy(data, bitmap, blocksize);
 
 			/* mark all preallocated blks used in in-core bitmap */
-			ext4_mb_generate_from_pa(sb, data, group);
+			err = ext4_mb_generate_from_pa(sb, data, group);
 			ext4_mb_generate_from_freelist(sb, data, group);
 			ext4_unlock_group(sb, group);
 
@@ -951,8 +954,8 @@ static int ext4_mb_init_cache(struct page *page, char *incore, gfp_t gfp)
 			incore = data;
 		}
 	}
-	SetPageUptodate(page);
-
+	if (likely(err == 0))
+		SetPageUptodate(page);
 out:
 	if (bh) {
 		for (i = 0; i < groups_per_page; i++)
@@ -2281,7 +2284,8 @@ static int ext4_mb_seq_groups_show(struct seq_file *seq, void *v)
 {
 	struct super_block *sb = PDE_DATA(file_inode(seq->file));
 	ext4_group_t group = (ext4_group_t) ((unsigned long) v);
-	int i;
+	struct ext4_group_desc *gdp;
+	int free = 0, i;
 	int err, buddy_loaded = 0;
 	struct ext4_buddy e4b;
 	struct ext4_group_info *grinfo;
@@ -2295,7 +2299,7 @@ static int ext4_mb_seq_groups_show(struct seq_file *seq, void *v)
 
 	group--;
 	if (group == 0)
-		seq_puts(seq, "#group: free  frags first ["
+		seq_puts(seq, "#group: bfree  gfree  free  frags first ["
 			      " 2^0   2^1   2^2   2^3   2^4   2^5   2^6  "
 			      " 2^7   2^8   2^9   2^10  2^11  2^12  2^13  ]\n");
 
@@ -2313,13 +2317,19 @@ static int ext4_mb_seq_groups_show(struct seq_file *seq, void *v)
 		buddy_loaded = 1;
 	}
 
+	gdp = ext4_get_group_desc(sb, group, NULL);
+	if (gdp)
+		free = ext4_free_group_clusters(sb, gdp);
+
 	memcpy(&sg, ext4_get_group_info(sb, group), i);
 
 	if (buddy_loaded)
 		ext4_mb_unload_buddy(&e4b);
 
-	seq_printf(seq, "#%-5u: %-5u %-5u %-5u [", group, sg.info.bb_free,
-			sg.info.bb_fragments, sg.info.bb_first_free);
+	seq_printf(seq, "#%-5lu: %-5u %-5u %-5u %-5u %-5lu [",
+		   (long unsigned int)group, sg.info.bb_free, free,
+		   sg.info.bb_fragments, sg.info.bb_first_free,
+		   sg.info.bb_prealloc_nr);
 	for (i = 0; i <= 13; i++)
 		seq_printf(seq, " %-5u", i <= blocksize_bits + 1 ?
 				sg.info.bb_counters[i] : 0);
@@ -3593,6 +3603,42 @@ static void ext4_mb_use_group_pa(struct ext4_allocation_context *ac,
 }
 
 /*
+ * check free blocks in bitmap match free block in group descriptor
+ * do this before taking preallocated blocks into account to be able
+ * to detect on-disk corruptions. The group lock should be hold by the
+ * caller.
+ */
+int ext4_mb_check_ondisk_bitmap(struct super_block *sb, void *bitmap,
+				struct ext4_group_desc *gdp, int group)
+{
+	unsigned short max = EXT4_CLUSTERS_PER_GROUP(sb);
+	unsigned short i, first, free = 0;
+	unsigned short free_in_gdp = ext4_free_group_clusters(sb, gdp);
+
+	if (free_in_gdp == 0 && gdp->bg_flags & cpu_to_le16(EXT4_BG_BLOCK_UNINIT))
+		return 0;
+
+	i = mb_find_next_zero_bit(bitmap, max, 0);
+
+	while (i < max) {
+		first = i;
+		i = mb_find_next_bit(bitmap, max, i);
+		if (i > max)
+			i = max;
+		free += i - first;
+		if (i < max)
+			i = mb_find_next_zero_bit(bitmap, max, i);
+	}
+
+	if (free != free_in_gdp) {
+		ext4_error(sb, "on-disk bitmap for group %d corrupted: %u blocks free in bitmap, %u - in gd\n",
+			   group, free, free_in_gdp);
+		return -EIO;
+	}
+	return 0;
+}
+
+/*
  * the function goes through all block freed in the group
  * but not yet committed and marks them used in in-core bitmap.
  * buddy must be generated from this bitmap
@@ -3622,16 +3668,27 @@ static void ext4_mb_generate_from_freelist(struct super_block *sb, void *bitmap,
  * Need to be called with ext4 group lock held
  */
 static noinline_for_stack
-void ext4_mb_generate_from_pa(struct super_block *sb, void *bitmap,
-					ext4_group_t group)
+int ext4_mb_generate_from_pa(struct super_block *sb, void *bitmap,
+			     ext4_group_t group)
 {
 	struct ext4_group_info *grp = ext4_get_group_info(sb, group);
 	struct ext4_prealloc_space *pa;
+	struct ext4_group_desc *gdp;
 	struct list_head *cur;
 	ext4_group_t groupnr;
 	ext4_grpblk_t start;
 	int preallocated = 0;
-	int len;
+	int skip = 0, count = 0;
+	int err, len;
+
+	gdp = ext4_get_group_desc(sb, group, NULL);
+	if (!gdp)
+		return -EIO;
+
+	/* before applying preallocations, check bitmap consistency */
+	err = ext4_mb_check_ondisk_bitmap(sb, bitmap, gdp, group);
+	if (err)
+		return err;
 
 	/* all form of preallocation discards first load group,
 	 * so the only competing code is preallocation use.
@@ -3648,13 +3705,22 @@ void ext4_mb_generate_from_pa(struct super_block *sb, void *bitmap,
 					     &groupnr, &start);
 		len = pa->pa_len;
 		spin_unlock(&pa->pa_lock);
-		if (unlikely(len == 0))
+		if (unlikely(len == 0)) {
+			skip++;
 			continue;
+		}
 		BUG_ON(groupnr != group);
 		ext4_set_bits(bitmap, start, len);
 		preallocated += len;
+		count++;
+	}
+	if (count + skip != grp->bb_prealloc_nr) {
+		ext4_error(sb, "lost preallocations: count %d, bb_prealloc_nr %lu, skip %d\n",
+			   count, grp->bb_prealloc_nr, skip);
+		return -EIO;
 	}
 	mb_debug(1, "preallocated %u for group %u\n", preallocated, group);
+	return 0;
 }
 
 static void ext4_mb_pa_callback(struct rcu_head *head)
@@ -3718,6 +3784,7 @@ static void ext4_mb_put_pa(struct ext4_allocation_context *ac,
 	 */
 	ext4_lock_group(sb, grp);
 	list_del(&pa->pa_group_list);
+	ext4_get_group_info(sb, grp)->bb_prealloc_nr--;
 	ext4_unlock_group(sb, grp);
 
 	spin_lock(pa->pa_obj_lock);
@@ -3812,6 +3879,7 @@ static void ext4_mb_put_pa(struct ext4_allocation_context *ac,
 
 	ext4_lock_group(sb, ac->ac_b_ex.fe_group);
 	list_add(&pa->pa_group_list, &grp->bb_prealloc_list);
+	grp->bb_prealloc_nr++;
 	ext4_unlock_group(sb, ac->ac_b_ex.fe_group);
 
 	spin_lock(pa->pa_obj_lock);
@@ -3873,6 +3941,7 @@ static void ext4_mb_put_pa(struct ext4_allocation_context *ac,
 
 	ext4_lock_group(sb, ac->ac_b_ex.fe_group);
 	list_add(&pa->pa_group_list, &grp->bb_prealloc_list);
+	grp->bb_prealloc_nr++;
 	ext4_unlock_group(sb, ac->ac_b_ex.fe_group);
 
 	/*
@@ -4044,6 +4113,8 @@ static int ext4_mb_new_preallocation(struct ext4_allocation_context *ac)
 
 		spin_unlock(&pa->pa_lock);
 
+		BUG_ON(grp->bb_prealloc_nr == 0);
+		grp->bb_prealloc_nr--;
 		list_del(&pa->pa_group_list);
 		list_add(&pa->u.pa_tmp_list, &list);
 	}
@@ -4174,7 +4245,7 @@ void ext4_discard_preallocations(struct inode *inode)
 		if (err) {
 			ext4_error(sb, "Error %d loading buddy information for %u",
 				   err, group);
-			continue;
+			return;
 		}
 
 		bitmap_bh = ext4_read_block_bitmap(sb, group);
@@ -4187,6 +4258,8 @@ void ext4_discard_preallocations(struct inode *inode)
 		}
 
 		ext4_lock_group(sb, group);
+		BUG_ON(e4b.bd_info->bb_prealloc_nr == 0);
+		e4b.bd_info->bb_prealloc_nr--;
 		list_del(&pa->pa_group_list);
 		ext4_mb_release_inode_pa(&e4b, bitmap_bh, pa);
 		ext4_unlock_group(sb, group);
@@ -4448,6 +4521,7 @@ static void ext4_mb_group_or_file(struct ext4_allocation_context *ac)
 		}
 		ext4_lock_group(sb, group);
 		list_del(&pa->pa_group_list);
+		ext4_get_group_info(sb, group)->bb_prealloc_nr--;
 		ext4_mb_release_group_pa(&e4b, pa);
 		ext4_unlock_group(sb, group);
 
diff --git a/fs/ext4/mballoc.h b/fs/ext4/mballoc.h
index 88c98f1..8325ad9 100644
--- a/fs/ext4/mballoc.h
+++ b/fs/ext4/mballoc.h
@@ -70,7 +70,7 @@
 /*
  * for which requests use 2^N search using buddies
  */
-#define MB_DEFAULT_ORDER2_REQS		2
+#define MB_DEFAULT_ORDER2_REQS		8
 
 /*
  * default group prealloc size 512 blocks
-- 
1.8.3.1
