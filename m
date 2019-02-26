From: James Simmons <jsimmons@infradead.org>
Date: Tue, 26 Feb 2019 20:55:49 +0000 (GMT)
Subject: [lustre-devel] [PATCH 22/37] lustre: lprocfs: use log2.h macros
 instead of shift loop.
In-Reply-To: <155053494599.24125.1795878344125234751.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
 <155053494599.24125.1795878344125234751.stgit@noble.brown>
Message-ID: <alpine.LFD.2.21.1902241806550.22752@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> These shift loops seem to be trying to avoid doing a
> multiplication.
> We same effect can be achieved more transparently using
> rounddown_pow_of_two().  Even though there is a multiplication
> in the C code, the resulting machine code just does a single shift.

Be aware rounddown_pow_of_two(n) is undefined when "n == 0". 
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../lustre/lustre/obdclass/lprocfs_status.c        |   10 +++-------
>  1 file changed, 3 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
> index a179b0d6979e..637aaca96888 100644
> --- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
> +++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
> @@ -341,9 +341,7 @@ static ssize_t kbytestotal_show(struct kobject *kobj, struct attribute *attr,
>  		u32 blk_size = osfs.os_bsize >> 10;
>  		u64 result = osfs.os_blocks;
>  
> -		while (blk_size >>= 1)
> -			result <<= 1;
> -
> +		result *= rounddown_pow_of_two(blk_size);
>  		return sprintf(buf, "%llu\n", result);
>  	}
>  
> @@ -364,8 +362,7 @@ static ssize_t kbytesfree_show(struct kobject *kobj, struct attribute *attr,
>  		u32 blk_size = osfs.os_bsize >> 10;
>  		u64 result = osfs.os_bfree;
>  
> -		while (blk_size >>= 1)
> -			result <<= 1;
> +		result *= rounddown_pow_of_two(blk_size);
>  
>  		return sprintf(buf, "%llu\n", result);
>  	}
> @@ -387,8 +384,7 @@ static ssize_t kbytesavail_show(struct kobject *kobj, struct attribute *attr,
>  		u32 blk_size = osfs.os_bsize >> 10;
>  		u64 result = osfs.os_bavail;
>  
> -		while (blk_size >>= 1)
> -			result <<= 1;
> +		result *= rounddown_pow_of_two(blk_size);
>  
>  		return sprintf(buf, "%llu\n", result);
>  	}
> 
> 
> 
