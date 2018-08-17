From: NeilBrown <neilb@suse.com>
Date: Fri, 17 Aug 2018 16:32:20 +1000
Subject: [lustre-devel] [PATCH 14/38] lustre: llite: don't handle
 success case for kbyte* sysfs code
In-Reply-To: <1534475441-15543-15-git-send-email-jsimmons@infradead.org>
References: <1534475441-15543-1-git-send-email-jsimmons@infradead.org>
 <1534475441-15543-15-git-send-email-jsimmons@infradead.org>
Message-ID: <87y3d5qz9n.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Aug 16 2018, James Simmons wrote:

> The proper thing to due is return on failure so reverse the logic
> to conform to kernel standards.
>
> Signed-off-by: James Simmons <uja.ornl@yahoo.com>
> WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
> Reviewed-on: https://review.whamcloud.com/32497
> Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
> Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
> Reviewed-by: Oleg Drokin <green@whamcloud.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  drivers/staging/lustre/lustre/llite/lproc_llite.c | 51 ++++++++++++-----------
>  1 file changed, 27 insertions(+), 24 deletions(-)
>
> diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
> index 7bd557b..72a8f8d 100644
> --- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
> +++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
> @@ -154,22 +154,23 @@ static ssize_t kbytestotal_show(struct kobject *kobj, struct attribute *attr,
>  	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
>  					      ll_kset.kobj);
>  	struct obd_statfs osfs;
> +	u32 blk_size;
> +	u64 result;
>  	int rc;
>  
>  	rc = ll_statfs_internal(sbi, &osfs,
>  				get_jiffies_64() - OBD_STATFS_CACHE_SECONDS * HZ,
>  				OBD_STATFS_NODELAY);
> -	if (!rc) {
> -		__u32 blk_size = osfs.os_bsize >> 10;
> -		__u64 result = osfs.os_blocks;
> +	if (rc)
> +		return rc;
>  
> -		while (blk_size >>= 1)
> -			result <<= 1;
> +	blk_size = osfs.os_bsize >> 10;
> +	result = osfs.os_blocks;
>  
> -		rc = sprintf(buf, "%llu\n", result);
> -	}
> +	while (blk_size >>= 1)
> +		result <<= 1;

I had to think 2 or 3 times to be sure this code was correct.
I think it is, but it is odd.
I assume blk_size is always a power of 2?
So why not
   result *= blk_size;
??
It is obvious what that does.
This is for printing out a sysfs file, so speed does not trump
readability.
If it might not be a power of 2, then
   result <<= log2(blk_size);

it fairly obvious..

(I know you didn't introduce this strange code, I just felt the need to
comment)

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180817/33aed3a6/attachment.sig>
