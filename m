From: Artem Blagodarenko <c17828@cray.com>
Date: Mon, 5 Aug 2019 07:07:36 +0000
Subject: [lustre-devel] [PATCH 03/22] ext4: prealloc table optimization
In-Reply-To: <1563758631-29550-4-git-send-email-jsimmons@infradead.org>
References: <1563758631-29550-1-git-send-email-jsimmons@infradead.org>
 <1563758631-29550-4-git-send-email-jsimmons@infradead.org>
Message-ID: <D8A862EE-DC9A-4342-A20D-C1DE3C29CA88@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,

I am glad to see LU-12335 patch is integrated here.

Reviewed-by:  Artem Blagodarenko <c17828@cray.com>

Best regards,
Artem Blagodarenko.


?On 22/07/2019, 04:24, "James Simmons" <jsimmons@infradead.org> wrote:

    Optimize prealloc table
    
    Signed-off-by: James Simmons <jsimmons@infradead.org>
    ---
     fs/ext4/ext4.h    |   7 +-
     fs/ext4/inode.c   |   3 +
     fs/ext4/mballoc.c | 221 +++++++++++++++++++++++++++++++++++++++++-------------
     fs/ext4/namei.c   |   4 +-
     fs/ext4/sysfs.c   |   8 +-
     5 files changed, 186 insertions(+), 57 deletions(-)
    
    diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
    index 8abbcab..423ab4d 100644
    --- a/fs/ext4/ext4.h
    +++ b/fs/ext4/ext4.h
    @@ -1190,6 +1190,8 @@ struct ext4_inode_info {
     /* Metadata checksum algorithm codes */
     #define EXT4_CRC32C_CHKSUM		1
     
    +#define EXT4_MAX_PREALLOC_TABLE		64
    +
     /*
      * Structure of the super block
      */
    @@ -1447,12 +1449,14 @@ struct ext4_sb_info {
     
     	/* tunables */
     	unsigned long s_stripe;
    -	unsigned int s_mb_stream_request;
    +	unsigned long s_mb_small_req;
    +	unsigned long s_mb_large_req;
     	unsigned int s_mb_max_to_scan;
     	unsigned int s_mb_min_to_scan;
     	unsigned int s_mb_stats;
     	unsigned int s_mb_order2_reqs;
     	unsigned int s_mb_group_prealloc;
    +	unsigned long *s_mb_prealloc_table;
     	unsigned int s_max_dir_size_kb;
     	/* where last allocation was done - for stream allocation */
     	unsigned long s_mb_last_group;
    @@ -2457,6 +2461,7 @@ extern int ext4_init_inode_table(struct super_block *sb,
     extern void ext4_end_bitmap_read(struct buffer_head *bh, int uptodate);
     
     /* mballoc.c */
    +extern const struct file_operations ext4_seq_prealloc_table_fops;
     extern const struct seq_operations ext4_mb_seq_groups_ops;
     extern long ext4_mb_stats;
     extern long ext4_mb_max_to_scan;
    diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
    index 6e66175..c37418a 100644
    --- a/fs/ext4/inode.c
    +++ b/fs/ext4/inode.c
    @@ -2796,6 +2796,9 @@ static int ext4_writepages(struct address_space *mapping,
     		ext4_journal_stop(handle);
     	}
     
    +	if (wbc->nr_to_write < sbi->s_mb_small_req)
    +		wbc->nr_to_write = sbi->s_mb_small_req;
    +
     	if (wbc->range_start == 0 && wbc->range_end == LLONG_MAX)
     		range_whole = 1;
     
    diff --git a/fs/ext4/mballoc.c b/fs/ext4/mballoc.c
    index 99ba720..3be3bef 100644
    --- a/fs/ext4/mballoc.c
    +++ b/fs/ext4/mballoc.c
    @@ -2339,6 +2339,101 @@ static void ext4_mb_seq_groups_stop(struct seq_file *seq, void *v)
     	.show   = ext4_mb_seq_groups_show,
     };
     
    +static int ext4_mb_check_and_update_prealloc(struct ext4_sb_info *sbi,
    +					     char *str, size_t cnt,
    +					     int update)
    +{
    +	unsigned long value;
    +	unsigned long prev = 0;
    +	char *cur;
    +	char *next;
    +	char *end;
    +	int num = 0;
    +
    +	cur = str;
    +	end = str + cnt;
    +	while (cur < end) {
    +		while ((cur < end) && (*cur == ' ')) cur++;
    +		/* Yuck - simple_strtol */
    +		value = simple_strtol(cur, &next, 0);
    +		if (value == 0)
    +			break;
    +		if (cur == next)
    +			return -EINVAL;
    +
    +		cur = next;
    +
    +		if (value > (sbi->s_blocks_per_group - 1 - 1 - sbi->s_itb_per_group))
    +			return -EINVAL;
    +
    +		/* they should add values in order */
    +		if (value <= prev)
    +			return -EINVAL;
    +
    +		if (update)
    +			sbi->s_mb_prealloc_table[num] = value;
    +
    +		prev = value;
    +		num++;
    +	}
    +
    +	if (num > EXT4_MAX_PREALLOC_TABLE - 1)
    +		return -EOVERFLOW;
    +
    +	if (update)
    +		sbi->s_mb_prealloc_table[num] = 0;
    +
    +	return 0;
    +}
    +
    +static ssize_t ext4_mb_prealloc_table_proc_write(struct file *file,
    +						 const char __user *buf,
    +						 size_t cnt, loff_t *pos)
    +{
    +	struct ext4_sb_info *sbi = EXT4_SB(PDE_DATA(file_inode(file)));
    +	char str[128];
    +	int rc;
    +
    +	if (cnt >= sizeof(str))
    +		return -EINVAL;
    +	if (copy_from_user(str, buf, cnt))
    +		return -EFAULT;
    +
    +	rc = ext4_mb_check_and_update_prealloc(sbi, str, cnt, 0);
    +	if (rc)
    +		return rc;
    +
    +	rc = ext4_mb_check_and_update_prealloc(sbi, str, cnt, 1);
    +	return rc ? rc : cnt;
    +}
    +
    +static int mb_prealloc_table_seq_show(struct seq_file *m, void *v)
    +{
    +	struct ext4_sb_info *sbi = EXT4_SB(m->private);
    +	int i;
    +
    +	for (i = 0; i < EXT4_MAX_PREALLOC_TABLE &&
    +			sbi->s_mb_prealloc_table[i] != 0; i++)
    +		seq_printf(m, "%ld ", sbi->s_mb_prealloc_table[i]);
    +	seq_printf(m, "\n");
    +
    +	return 0;
    +}
    +
    +static int mb_prealloc_table_seq_open(struct inode *inode, struct file *file)
    +{
    +	return single_open(file, mb_prealloc_table_seq_show, PDE_DATA(inode));
    +}
    +
    +const struct file_operations ext4_seq_prealloc_table_fops = {
    +	.owner	 = THIS_MODULE,
    +	.open	 = mb_prealloc_table_seq_open,
    +	.read	 = seq_read,
    +	.llseek	 = seq_lseek,
    +	.release = single_release,
    +	.write	 = ext4_mb_prealloc_table_proc_write,
    +};
    +
     static struct kmem_cache *get_groupinfo_cache(int blocksize_bits)
     {
     	int cache_index = blocksize_bits - EXT4_MIN_BLOCK_LOG_SIZE;
    @@ -2567,7 +2662,7 @@ static int ext4_groupinfo_create_slab(size_t size)
     int ext4_mb_init(struct super_block *sb)
     {
     	struct ext4_sb_info *sbi = EXT4_SB(sb);
    -	unsigned i, j;
    +	unsigned i, j, k, l;
     	unsigned offset, offset_incr;
     	unsigned max;
     	int ret;
    @@ -2616,7 +2711,6 @@ int ext4_mb_init(struct super_block *sb)
     	sbi->s_mb_max_to_scan = MB_DEFAULT_MAX_TO_SCAN;
     	sbi->s_mb_min_to_scan = MB_DEFAULT_MIN_TO_SCAN;
     	sbi->s_mb_stats = MB_DEFAULT_STATS;
    -	sbi->s_mb_stream_request = MB_DEFAULT_STREAM_THRESHOLD;
     	sbi->s_mb_order2_reqs = MB_DEFAULT_ORDER2_REQS;
     	/*
     	 * The default group preallocation is 512, which for 4k block
    @@ -2640,9 +2734,28 @@ int ext4_mb_init(struct super_block *sb)
     	 * RAID stripe size so that preallocations don't fragment
     	 * the stripes.
     	 */
    -	if (sbi->s_stripe > 1) {
    -		sbi->s_mb_group_prealloc = roundup(
    -			sbi->s_mb_group_prealloc, sbi->s_stripe);
    +	/* Allocate table once */
    +	sbi->s_mb_prealloc_table = kzalloc(
    +		EXT4_MAX_PREALLOC_TABLE * sizeof(unsigned long), GFP_NOFS);
    +	if (!sbi->s_mb_prealloc_table) {
    +		ret = -ENOMEM;
    +		goto out;
    +	}
    +
    +	if (sbi->s_stripe == 0) {
    +		for (k = 0, l = 4; k <= 9; ++k, l *= 2)
    +			sbi->s_mb_prealloc_table[k] = l;
    +
    +		sbi->s_mb_small_req = 256;
    +		sbi->s_mb_large_req = 1024;
    +		sbi->s_mb_group_prealloc = 512;
    +	} else {
    +		for (k = 0, l = sbi->s_stripe; k <= 2; ++k, l *= 2)
    +			sbi->s_mb_prealloc_table[k] = l;
    +
    +		sbi->s_mb_small_req = sbi->s_stripe;
    +		sbi->s_mb_large_req = sbi->s_stripe * 8;
    +		sbi->s_mb_group_prealloc = sbi->s_stripe * 4;
     	}
     
     	sbi->s_locality_groups = alloc_percpu(struct ext4_locality_group);
    @@ -2670,6 +2783,7 @@ int ext4_mb_init(struct super_block *sb)
     	free_percpu(sbi->s_locality_groups);
     	sbi->s_locality_groups = NULL;
     out:
    +	kfree(sbi->s_mb_prealloc_table);
     	kfree(sbi->s_mb_offsets);
     	sbi->s_mb_offsets = NULL;
     	kfree(sbi->s_mb_maxs);
    @@ -2932,7 +3046,6 @@ void ext4_exit_mballoc(void)
     	int err, len;
     
     	BUG_ON(ac->ac_status != AC_STATUS_FOUND);
    -	BUG_ON(ac->ac_b_ex.fe_len <= 0);
     
     	sb = ac->ac_sb;
     	sbi = EXT4_SB(sb);
    @@ -3062,13 +3175,14 @@ static void ext4_mb_normalize_group_request(struct ext4_allocation_context *ac)
     				struct ext4_allocation_request *ar)
     {
     	struct ext4_sb_info *sbi = EXT4_SB(ac->ac_sb);
    -	int bsbits, max;
    +	int bsbits, i, wind;
     	ext4_lblk_t end;
    -	loff_t size, start_off;
    +	loff_t size;
     	loff_t orig_size __maybe_unused;
     	ext4_lblk_t start;
     	struct ext4_inode_info *ei = EXT4_I(ac->ac_inode);
     	struct ext4_prealloc_space *pa;
    +	unsigned long value, last_non_zero;
     
     	/* do normalize only data requests, metadata requests
     	   do not need preallocation */
    @@ -3097,51 +3211,47 @@ static void ext4_mb_normalize_group_request(struct ext4_allocation_context *ac)
     	size = size << bsbits;
     	if (size < i_size_read(ac->ac_inode))
     		size = i_size_read(ac->ac_inode);
    -	orig_size = size;
    +	size = (size + ac->ac_sb->s_blocksize - 1) >> bsbits;
     
    -	/* max size of free chunks */
    -	max = 2 << bsbits;
    -
    -#define NRL_CHECK_SIZE(req, size, max, chunk_size)	\
    -		(req <= (size) || max <= (chunk_size))
    -
    -	/* first, try to predict filesize */
    -	/* XXX: should this table be tunable? */
    -	start_off = 0;
    -	if (size <= 16 * 1024) {
    -		size = 16 * 1024;
    -	} else if (size <= 32 * 1024) {
    -		size = 32 * 1024;
    -	} else if (size <= 64 * 1024) {
    -		size = 64 * 1024;
    -	} else if (size <= 128 * 1024) {
    -		size = 128 * 1024;
    -	} else if (size <= 256 * 1024) {
    -		size = 256 * 1024;
    -	} else if (size <= 512 * 1024) {
    -		size = 512 * 1024;
    -	} else if (size <= 1024 * 1024) {
    -		size = 1024 * 1024;
    -	} else if (NRL_CHECK_SIZE(size, 4 * 1024 * 1024, max, 2 * 1024)) {
    -		start_off = ((loff_t)ac->ac_o_ex.fe_logical >>
    -						(21 - bsbits)) << 21;
    -		size = 2 * 1024 * 1024;
    -	} else if (NRL_CHECK_SIZE(size, 8 * 1024 * 1024, max, 4 * 1024)) {
    -		start_off = ((loff_t)ac->ac_o_ex.fe_logical >>
    -							(22 - bsbits)) << 22;
    -		size = 4 * 1024 * 1024;
    -	} else if (NRL_CHECK_SIZE(ac->ac_o_ex.fe_len,
    -					(8<<20)>>bsbits, max, 8 * 1024)) {
    -		start_off = ((loff_t)ac->ac_o_ex.fe_logical >>
    -							(23 - bsbits)) << 23;
    -		size = 8 * 1024 * 1024;
    +	start = wind = 0;
    +	value = last_non_zero = 0;
    +
    +	/* let's choose preallocation window depending on file size */
    +	for (i = 0; i < EXT4_MAX_PREALLOC_TABLE; i++) {
    +		value = sbi->s_mb_prealloc_table[i];
    +		if (value == 0)
    +			break;
    +		else
    +			last_non_zero = value;
    +
    +		if (size <= value) {
    +			wind = value;
    +			break;
    +		}
    +	}
    +
    +	if (wind == 0) {
    +		if (last_non_zero != 0) {
    +			u64 tstart, tend;
    +
    +			/* file is quite large, we now preallocate with
    +			 * the biggest configured window with regart to
    +			 * logical offset
    +			 */
    +			wind = last_non_zero;
    +			tstart = ac->ac_o_ex.fe_logical;
    +			do_div(tstart, wind);
    +			start = tstart * wind;
    +			tend = ac->ac_o_ex.fe_logical + ac->ac_o_ex.fe_len - 1;
    +			do_div(tend, wind);
    +			tend = tend * wind + wind;
    +			size = tend - start;
    +		}
     	} else {
    -		start_off = (loff_t) ac->ac_o_ex.fe_logical << bsbits;
    -		size	  = (loff_t) EXT4_C2B(EXT4_SB(ac->ac_sb),
    -					      ac->ac_o_ex.fe_len) << bsbits;
    +		size = wind;
     	}
    -	size = size >> bsbits;
    -	start = start_off >> bsbits;
    +
    +	orig_size = size;
     
     	/* don't cover already allocated blocks in selected range */
     	if (ar->pleft && start <= ar->lleft) {
    @@ -3223,7 +3333,6 @@ static void ext4_mb_normalize_group_request(struct ext4_allocation_context *ac)
     			 (unsigned long) ac->ac_o_ex.fe_logical);
     		BUG();
     	}
    -	BUG_ON(size <= 0 || size > EXT4_BLOCKS_PER_GROUP(ac->ac_sb));
     
     	/* now prepare goal request */
     
    @@ -4191,11 +4300,19 @@ static void ext4_mb_group_or_file(struct ext4_allocation_context *ac)
     
     	/* don't use group allocation for large files */
     	size = max(size, isize);
    -	if (size > sbi->s_mb_stream_request) {
    +	if ((ac->ac_o_ex.fe_len >= sbi->s_mb_small_req) ||
    +	    (size >= sbi->s_mb_large_req)) {
     		ac->ac_flags |= EXT4_MB_STREAM_ALLOC;
     		return;
     	}
     
    +	/*
    +	 * request is so large that we don't care about
    +	 * streaming - it overweights any possible seek
    +	 */
    +	if (ac->ac_o_ex.fe_len >= sbi->s_mb_large_req)
    +		return;
    +
     	BUG_ON(ac->ac_lg != NULL);
     	/*
     	 * locality group prealloc space are per cpu. The reason for having
    diff --git a/fs/ext4/namei.c b/fs/ext4/namei.c
    index a616f58..a52b311 100644
    --- a/fs/ext4/namei.c
    +++ b/fs/ext4/namei.c
    @@ -752,8 +752,8 @@ struct stats dx_show_entries(struct dx_hash_info *hinfo, struct inode *dir,
     	if (root->info.hash_version != DX_HASH_TEA &&
     	    root->info.hash_version != DX_HASH_HALF_MD4 &&
     	    root->info.hash_version != DX_HASH_LEGACY) {
    -		ext4_warning_inode(dir, "Unrecognised inode hash code %u",
    -				   root->info.hash_version);
    +		ext4_warning_inode(dir, "Unrecognised inode hash code %u for directory %lu",
    +				   root->info.hash_version, dir->i_ino);
     		goto fail;
     	}
     	if (fname)
    diff --git a/fs/ext4/sysfs.c b/fs/ext4/sysfs.c
    index 04b4f53..1375815 100644
    --- a/fs/ext4/sysfs.c
    +++ b/fs/ext4/sysfs.c
    @@ -184,7 +184,8 @@ static ssize_t journal_task_show(struct ext4_sb_info *sbi, char *buf)
     EXT4_RW_ATTR_SBI_UI(mb_max_to_scan, s_mb_max_to_scan);
     EXT4_RW_ATTR_SBI_UI(mb_min_to_scan, s_mb_min_to_scan);
     EXT4_RW_ATTR_SBI_UI(mb_order2_req, s_mb_order2_reqs);
    -EXT4_RW_ATTR_SBI_UI(mb_stream_req, s_mb_stream_request);
    +EXT4_RW_ATTR_SBI_UI(mb_small_req, s_mb_small_req);
    +EXT4_RW_ATTR_SBI_UI(mb_large_req, s_mb_large_req);
     EXT4_RW_ATTR_SBI_UI(mb_group_prealloc, s_mb_group_prealloc);
     EXT4_RW_ATTR_SBI_UI(extent_max_zeroout_kb, s_extent_max_zeroout_kb);
     EXT4_ATTR(trigger_fs_error, 0200, trigger_test_error);
    @@ -213,7 +214,8 @@ static ssize_t journal_task_show(struct ext4_sb_info *sbi, char *buf)
     	ATTR_LIST(mb_max_to_scan),
     	ATTR_LIST(mb_min_to_scan),
     	ATTR_LIST(mb_order2_req),
    -	ATTR_LIST(mb_stream_req),
    +	ATTR_LIST(mb_small_req),
    +	ATTR_LIST(mb_large_req),
     	ATTR_LIST(mb_group_prealloc),
     	ATTR_LIST(max_writeback_mb_bump),
     	ATTR_LIST(extent_max_zeroout_kb),
    @@ -413,6 +415,8 @@ int ext4_register_sysfs(struct super_block *sb)
     				sb);
     		proc_create_seq_data("mb_groups", S_IRUGO, sbi->s_proc,
     				&ext4_mb_seq_groups_ops, sb);
    +		proc_create_data("prealloc_table", S_IRUGO, sbi->s_proc,
    +				 &ext4_seq_prealloc_table_fops, sb);
     	}
     	return 0;
     }
    -- 
    1.8.3.1
    
    
