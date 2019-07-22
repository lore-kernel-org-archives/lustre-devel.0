From: NeilBrown <neilb@suse.com>
Date: Mon, 22 Jul 2019 14:56:32 +1000
Subject: [lustre-devel] [PATCH 09/22] ext4: fix mballoc pa free mismatch
In-Reply-To: <1563758631-29550-10-git-send-email-jsimmons@infradead.org>
References: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
 <1563758631-29550-10-git-send-email-jsimmons@infradead.org>
Message-ID: <87d0i2pszj.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Jul 21 2019, James Simmons wrote:

> Intoduce pa_error so we can find any mballoc pa cleanup problems.

This patch seems to make sense, though
> +	BUG_ON(atomic_read(&sb->s_active) > 0 && pa->pa_free != free);

should probably be a WARN_ON and

> +#include <linux/genhd.h>

seems un-called for.

NeilBrown


>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  fs/ext4/mballoc.c | 45 +++++++++++++++++++++++++++++++++++++++------
>  fs/ext4/mballoc.h |  2 ++
>  2 files changed, 41 insertions(+), 6 deletions(-)
>
> diff --git a/fs/ext4/mballoc.c b/fs/ext4/mballoc.c
> index 483fc0f..463fba6 100644
> --- a/fs/ext4/mballoc.c
> +++ b/fs/ext4/mballoc.c
> @@ -3863,6 +3863,7 @@ static void ext4_mb_put_pa(struct ext4_allocation_context *ac,
>  	INIT_LIST_HEAD(&pa->pa_group_list);
>  	pa->pa_deleted = 0;
>  	pa->pa_type = MB_INODE_PA;
> +	pa->pa_error = 0;
>  
>  	mb_debug(1, "new inode pa %p: %llu/%u for %u\n", pa,
>  			pa->pa_pstart, pa->pa_len, pa->pa_lstart);
> @@ -3924,6 +3925,7 @@ static void ext4_mb_put_pa(struct ext4_allocation_context *ac,
>  	INIT_LIST_HEAD(&pa->pa_group_list);
>  	pa->pa_deleted = 0;
>  	pa->pa_type = MB_GROUP_PA;
> +	pa->pa_error = 0;
>  
>  	mb_debug(1, "new group pa %p: %llu/%u for %u\n", pa,
>  			pa->pa_pstart, pa->pa_len, pa->pa_lstart);
> @@ -3983,7 +3985,9 @@ static int ext4_mb_new_preallocation(struct ext4_allocation_context *ac)
>  	unsigned long long grp_blk_start;
>  	int free = 0;
>  
> +	assert_spin_locked(ext4_group_lock_ptr(sb, e4b->bd_group));
>  	BUG_ON(pa->pa_deleted == 0);
> +	BUG_ON(pa->pa_inode == NULL);
>  	ext4_get_group_no_and_offset(sb, pa->pa_pstart, &group, &bit);
>  	grp_blk_start = pa->pa_pstart - EXT4_C2B(sbi, bit);
>  	BUG_ON(group != e4b->bd_group && pa->pa_len != 0);
> @@ -4006,12 +4010,19 @@ static int ext4_mb_new_preallocation(struct ext4_allocation_context *ac)
>  		mb_free_blocks(pa->pa_inode, e4b, bit, next - bit);
>  		bit = next + 1;
>  	}
> -	if (free != pa->pa_free) {
> -		ext4_msg(e4b->bd_sb, KERN_CRIT,
> -			 "pa %p: logic %lu, phys. %lu, len %lu",
> -			 pa, (unsigned long) pa->pa_lstart,
> -			 (unsigned long) pa->pa_pstart,
> -			 (unsigned long) pa->pa_len);
> +
> +	/* "free < pa->pa_free" means we maybe double alloc the same blocks,
> +	 * otherwise maybe leave some free blocks unavailable, no need to BUG.
> +	 */
> +	if ((free > pa->pa_free && !pa->pa_error) || (free < pa->pa_free)) {
> +		ext4_error(sb, "pa free mismatch: [pa %p] "
> +				"[phy %lu] [logic %lu] [len %u] [free %u] "
> +				"[error %u] [inode %lu] [freed %u]", pa,
> +				(unsigned long)pa->pa_pstart,
> +				(unsigned long)pa->pa_lstart,
> +				(unsigned)pa->pa_len, (unsigned)pa->pa_free,
> +				(unsigned)pa->pa_error, pa->pa_inode->i_ino,
> +				free);
>  		ext4_grp_locked_error(sb, group, 0, 0, "free %u, pa_free %u",
>  					free, pa->pa_free);
>  		/*
> @@ -4019,6 +4030,8 @@ static int ext4_mb_new_preallocation(struct ext4_allocation_context *ac)
>  		 * from the bitmap and continue.
>  		 */
>  	}
> +	/* do not verify if the file system is being umounted */
> +	BUG_ON(atomic_read(&sb->s_active) > 0 && pa->pa_free != free);
>  	atomic_add(free, &sbi->s_mb_discarded);
>  
>  	return 0;
> @@ -4764,6 +4777,26 @@ ext4_fsblk_t ext4_mb_new_blocks(handle_t *handle,
>  		ac->ac_b_ex.fe_len = 0;
>  		ar->len = 0;
>  		ext4_mb_show_ac(ac);
> +		if (ac->ac_pa) {
> +			struct ext4_prealloc_space *pa = ac->ac_pa;
> +
> +			/* We can not make sure whether the bitmap has
> +			 * been updated or not when fail case. So can
> +			 * not revert pa_free back, just mark pa_error
> +			 */
> +			pa->pa_error++;
> +			ext4_error(sb,
> +				   "Updating bitmap error: [err %d] "
> +				   "[pa %p] [phy %lu] [logic %lu] "
> +				   "[len %u] [free %u] [error %u] "
> +				   "[inode %lu]", *errp, pa,
> +				   (unsigned long)pa->pa_pstart,
> +				   (unsigned long)pa->pa_lstart,
> +				   (unsigned)pa->pa_len,
> +				   (unsigned)pa->pa_free,
> +				   (unsigned)pa->pa_error,
> +				   pa->pa_inode ? pa->pa_inode->i_ino : 0);
> +		}
>  	}
>  	ext4_mb_release_context(ac);
>  out:
> diff --git a/fs/ext4/mballoc.h b/fs/ext4/mballoc.h
> index 8325ad9..e00c3b7 100644
> --- a/fs/ext4/mballoc.h
> +++ b/fs/ext4/mballoc.h
> @@ -20,6 +20,7 @@
>  #include <linux/seq_file.h>
>  #include <linux/blkdev.h>
>  #include <linux/mutex.h>
> +#include <linux/genhd.h>
>  #include "ext4_jbd2.h"
>  #include "ext4.h"
>  
> @@ -111,6 +112,7 @@ struct ext4_prealloc_space {
>  	ext4_grpblk_t		pa_len;		/* len of preallocated chunk */
>  	ext4_grpblk_t		pa_free;	/* how many blocks are free */
>  	unsigned short		pa_type;	/* pa type. inode or group */
> +	unsigned short		pa_error;
>  	spinlock_t		*pa_obj_lock;
>  	struct inode		*pa_inode;	/* hack, for history only */
>  };
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190722/0e7781e6/attachment.sig>
