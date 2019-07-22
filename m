From: NeilBrown <neilb@suse.com>
Date: Mon, 22 Jul 2019 15:18:38 +1000
Subject: [lustre-devel] [PATCH 15/22] ext4: remove bitmap corruption
 warnings
In-Reply-To: <1563758631-29550-16-git-send-email-jsimmons@infradead.org>
References: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
 <1563758631-29550-16-git-send-email-jsimmons@infradead.org>
Message-ID: <87y30qode9.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Jul 21 2019, James Simmons wrote:

> Since we could skip corrupt block groups, this patch
> use ext4_warning() intead of ext4_error() to make FS not
> mount RO in default.

Does this related to the previous patch:
  ext4: add extra checks for mballoc

??
If so, it seems like a good idea, but the two patches should be
consecutive.
The description could read "Now that we skip corrupt ....".

NeilBrown


>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  fs/ext4/balloc.c  | 10 ++++-----
>  fs/ext4/ialloc.c  |  6 ++---
>  fs/ext4/mballoc.c | 66 +++++++++++++++++++++++--------------------------------
>  3 files changed, 35 insertions(+), 47 deletions(-)
>
> diff --git a/fs/ext4/balloc.c b/fs/ext4/balloc.c
> index bca75c1..aff3981 100644
> --- a/fs/ext4/balloc.c
> +++ b/fs/ext4/balloc.c
> @@ -374,7 +374,7 @@ static int ext4_validate_block_bitmap(struct super_block *sb,
>  	if (unlikely(!ext4_block_bitmap_csum_verify(sb, block_group,
>  			desc, bh))) {
>  		ext4_unlock_group(sb, block_group);
> -		ext4_error(sb, "bg %u: bad block bitmap checksum", block_group);
> +		ext4_warning(sb, "bg %u: bad block bitmap checksum", block_group);
>  		ext4_mark_group_bitmap_corrupted(sb, block_group,
>  					EXT4_GROUP_INFO_BBITMAP_CORRUPT);
>  		return -EFSBADCRC;
> @@ -382,8 +382,8 @@ static int ext4_validate_block_bitmap(struct super_block *sb,
>  	blk = ext4_valid_block_bitmap(sb, desc, block_group, bh);
>  	if (unlikely(blk != 0)) {
>  		ext4_unlock_group(sb, block_group);
> -		ext4_error(sb, "bg %u: block %llu: invalid block bitmap",
> -			   block_group, blk);
> +		ext4_warning(sb, "bg %u: block %llu: invalid block bitmap",
> +			     block_group, blk);
>  		ext4_mark_group_bitmap_corrupted(sb, block_group,
>  					EXT4_GROUP_INFO_BBITMAP_CORRUPT);
>  		return -EFSCORRUPTED;
> @@ -459,8 +459,8 @@ struct buffer_head *
>  		ext4_unlock_group(sb, block_group);
>  		unlock_buffer(bh);
>  		if (err) {
> -			ext4_error(sb, "Failed to init block bitmap for group "
> -				   "%u: %d", block_group, err);
> +			ext4_warning(sb, "Failed to init block bitmap for group "
> +				     "%u: %d", block_group, err);
>  			goto out;
>  		}
>  		goto verify;
> diff --git a/fs/ext4/ialloc.c b/fs/ext4/ialloc.c
> index 68d41e6..a72fe63 100644
> --- a/fs/ext4/ialloc.c
> +++ b/fs/ext4/ialloc.c
> @@ -96,8 +96,8 @@ static int ext4_validate_inode_bitmap(struct super_block *sb,
>  	if (!ext4_inode_bitmap_csum_verify(sb, block_group, desc, bh,
>  					   EXT4_INODES_PER_GROUP(sb) / 8)) {
>  		ext4_unlock_group(sb, block_group);
> -		ext4_error(sb, "Corrupt inode bitmap - block_group = %u, "
> -			   "inode_bitmap = %llu", block_group, blk);
> +		ext4_warning(sb, "Corrupt inode bitmap - block_group = %u, "
> +			     "inode_bitmap = %llu", block_group, blk);
>  		ext4_mark_group_bitmap_corrupted(sb, block_group,
>  					EXT4_GROUP_INFO_IBITMAP_CORRUPT);
>  		return -EFSBADCRC;
> @@ -346,7 +346,7 @@ void ext4_free_inode(handle_t *handle, struct inode *inode)
>  		if (!fatal)
>  			fatal = err;
>  	} else {
> -		ext4_error(sb, "bit already cleared for inode %lu", ino);
> +		ext4_warning(sb, "bit already cleared for inode %lu", ino);
>  		ext4_mark_group_bitmap_corrupted(sb, block_group,
>  					EXT4_GROUP_INFO_IBITMAP_CORRUPT);
>  	}
> diff --git a/fs/ext4/mballoc.c b/fs/ext4/mballoc.c
> index 463fba6..82398b0 100644
> --- a/fs/ext4/mballoc.c
> +++ b/fs/ext4/mballoc.c
> @@ -741,10 +741,15 @@ int ext4_mb_generate_buddy(struct super_block *sb,
>  	grp->bb_fragments = fragments;
>  
>  	if (free != grp->bb_free) {
> -		ext4_grp_locked_error(sb, group, 0, 0,
> -				      "block bitmap and bg descriptor "
> -				      "inconsistent: %u vs %u free clusters",
> -				      free, grp->bb_free);
> +		struct ext4_group_desc *gdp;
> +
> +		gdp = ext4_get_group_desc(sb, group, NULL);
> +		ext4_warning(sb, "group %lu: block bitmap and bg descriptor "
> +			     "inconsistent: %u vs %u free clusters "
> +			     "%u in gd, %lu pa's",
> +			     (long unsigned int)group, free, grp->bb_free,
> +			     ext4_free_group_clusters(sb, gdp),
> +			     grp->bb_prealloc_nr);
>  		/*
>  		 * If we intend to continue, we consider group descriptor
>  		 * corrupt and update bb_free using bitmap value
> @@ -1106,7 +1111,7 @@ int ext4_mb_init_group(struct super_block *sb, ext4_group_t group, gfp_t gfp)
>  	int block;
>  	int pnum;
>  	int poff;
> -	struct page *page;
> +	struct page *page = NULL;
>  	int ret;
>  	struct ext4_group_info *grp;
>  	struct ext4_sb_info *sbi = EXT4_SB(sb);
> @@ -1132,7 +1137,7 @@ int ext4_mb_init_group(struct super_block *sb, ext4_group_t group, gfp_t gfp)
>  		 */
>  		ret = ext4_mb_init_group(sb, group, gfp);
>  		if (ret)
> -			return ret;
> +			goto err;
>  	}
>  
>  	/*
> @@ -1235,6 +1240,7 @@ int ext4_mb_init_group(struct super_block *sb, ext4_group_t group, gfp_t gfp)
>  		put_page(e4b->bd_buddy_page);
>  	e4b->bd_buddy = NULL;
>  	e4b->bd_bitmap = NULL;
> +	ext4_warning(sb, "Error loading buddy information for %u", group);
>  	return ret;
>  }
>  
> @@ -3631,8 +3637,10 @@ int ext4_mb_check_ondisk_bitmap(struct super_block *sb, void *bitmap,
>  	}
>  
>  	if (free != free_in_gdp) {
> -		ext4_error(sb, "on-disk bitmap for group %d corrupted: %u blocks free in bitmap, %u - in gd\n",
> -			   group, free, free_in_gdp);
> +		ext4_warning(sb, "on-disk bitmap for group %d corrupted: %u blocks free in bitmap, %u - in gd\n",
> +			     group, free, free_in_gdp);
> +		ext4_mark_group_bitmap_corrupted(sb, group,
> +						 EXT4_GROUP_INFO_BBITMAP_CORRUPT);
>  		return -EIO;
>  	}
>  	return 0;
> @@ -4015,14 +4023,6 @@ static int ext4_mb_new_preallocation(struct ext4_allocation_context *ac)
>  	 * otherwise maybe leave some free blocks unavailable, no need to BUG.
>  	 */
>  	if ((free > pa->pa_free && !pa->pa_error) || (free < pa->pa_free)) {
> -		ext4_error(sb, "pa free mismatch: [pa %p] "
> -				"[phy %lu] [logic %lu] [len %u] [free %u] "
> -				"[error %u] [inode %lu] [freed %u]", pa,
> -				(unsigned long)pa->pa_pstart,
> -				(unsigned long)pa->pa_lstart,
> -				(unsigned)pa->pa_len, (unsigned)pa->pa_free,
> -				(unsigned)pa->pa_error, pa->pa_inode->i_ino,
> -				free);
>  		ext4_grp_locked_error(sb, group, 0, 0, "free %u, pa_free %u",
>  					free, pa->pa_free);
>  		/*
> @@ -4086,15 +4086,11 @@ static int ext4_mb_new_preallocation(struct ext4_allocation_context *ac)
>  	bitmap_bh = ext4_read_block_bitmap(sb, group);
>  	if (IS_ERR(bitmap_bh)) {
>  		err = PTR_ERR(bitmap_bh);
> -		ext4_error(sb, "Error %d reading block bitmap for %u",
> -			   err, group);
>  		return 0;
>  	}
>  
>  	err = ext4_mb_load_buddy(sb, group, &e4b);
>  	if (err) {
> -		ext4_warning(sb, "Error %d loading buddy information for %u",
> -			     err, group);
>  		put_bh(bitmap_bh);
>  		return 0;
>  	}
> @@ -4255,17 +4251,12 @@ void ext4_discard_preallocations(struct inode *inode)
>  
>  		err = ext4_mb_load_buddy_gfp(sb, group, &e4b,
>  					     GFP_NOFS|__GFP_NOFAIL);
> -		if (err) {
> -			ext4_error(sb, "Error %d loading buddy information for %u",
> -				   err, group);
> +		if (err)
>  			return;
> -		}
>  
>  		bitmap_bh = ext4_read_block_bitmap(sb, group);
>  		if (IS_ERR(bitmap_bh)) {
>  			err = PTR_ERR(bitmap_bh);
> -			ext4_error(sb, "Error %d reading block bitmap for %u",
> -					err, group);
>  			ext4_mb_unload_buddy(&e4b);
>  			continue;
>  		}
> @@ -4527,11 +4518,8 @@ static void ext4_mb_group_or_file(struct ext4_allocation_context *ac)
>  		group = ext4_get_group_number(sb, pa->pa_pstart);
>  		err = ext4_mb_load_buddy_gfp(sb, group, &e4b,
>  					     GFP_NOFS|__GFP_NOFAIL);
> -		if (err) {
> -			ext4_error(sb, "Error %d loading buddy information for %u",
> -				   err, group);
> +		if (err)
>  			continue;
> -		}
>  		ext4_lock_group(sb, group);
>  		list_del(&pa->pa_group_list);
>  		ext4_get_group_info(sb, group)->bb_prealloc_nr--;
> @@ -4785,7 +4773,7 @@ ext4_fsblk_t ext4_mb_new_blocks(handle_t *handle,
>  			 * not revert pa_free back, just mark pa_error
>  			 */
>  			pa->pa_error++;
> -			ext4_error(sb,
> +			ext4_warning(sb,
>  				   "Updating bitmap error: [err %d] "
>  				   "[pa %p] [phy %lu] [logic %lu] "
>  				   "[len %u] [free %u] [error %u] "
> @@ -4796,6 +4784,7 @@ ext4_fsblk_t ext4_mb_new_blocks(handle_t *handle,
>  				   (unsigned)pa->pa_free,
>  				   (unsigned)pa->pa_error,
>  				   pa->pa_inode ? pa->pa_inode->i_ino : 0);
> +			ext4_mark_group_bitmap_corrupted(sb, 0, 0);
>  		}
>  	}
>  	ext4_mb_release_context(ac);
> @@ -5081,7 +5070,7 @@ void ext4_free_blocks(handle_t *handle, struct inode *inode,
>  	err = ext4_mb_load_buddy_gfp(sb, block_group, &e4b,
>  				     GFP_NOFS|__GFP_NOFAIL);
>  	if (err)
> -		goto error_return;
> +		goto error_brelse;
>  
>  	/*
>  	 * We need to make sure we don't reuse the freed block until after the
> @@ -5171,8 +5160,9 @@ void ext4_free_blocks(handle_t *handle, struct inode *inode,
>  		goto do_more;
>  	}
>  error_return:
> -	brelse(bitmap_bh);
>  	ext4_std_error(sb, err);
> +error_brelse:
> +	brelse(bitmap_bh);
>  	return;
>  }
>  
> @@ -5272,7 +5262,7 @@ int ext4_group_add_blocks(handle_t *handle, struct super_block *sb,
>  
>  	err = ext4_mb_load_buddy(sb, block_group, &e4b);
>  	if (err)
> -		goto error_return;
> +		goto error_brelse;
>  
>  	/*
>  	 * need to update group_info->bb_free and bitmap
> @@ -5310,8 +5300,9 @@ int ext4_group_add_blocks(handle_t *handle, struct super_block *sb,
>  		err = ret;
>  
>  error_return:
> -	brelse(bitmap_bh);
>  	ext4_std_error(sb, err);
> +error_brelse:
> +	brelse(bitmap_bh);
>  	return err;
>  }
>  
> @@ -5386,11 +5377,8 @@ static int ext4_trim_extent(struct super_block *sb, int start, int count,
>  	trace_ext4_trim_all_free(sb, group, start, max);
>  
>  	ret = ext4_mb_load_buddy(sb, group, &e4b);
> -	if (ret) {
> -		ext4_warning(sb, "Error %d loading buddy information for %u",
> -			     ret, group);
> +	if (ret)
>  		return ret;
> -	}
>  	bitmap = e4b.bd_bitmap;
>  
>  	ext4_lock_group(sb, group);
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190722/2a84fac1/attachment.sig>
