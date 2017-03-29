From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Wed, 29 Mar 2017 05:05:07 +0000
Subject: [lustre-devel] [PATCH] Remove sparse warnings in mdc_request.c
In-Reply-To: <58d9f73a.09c3620a.d471b.d171@mx.google.com>
References: <58d9f73a.09c3620a.d471b.d171@mx.google.com>
Message-ID: <1592C3AC-DE8B-4A11-8053-02B82A61E1B3@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mar 27, 2017, at 23:40, Skanda Guruanand <skanda.kashyap@gmail.com> wrote:
> 
> I have tried to fix the endian issues in the mdc_request.c in the
> lustre file system drivers in the staging area. Your feedback is
> welcome.

Sorry, but this patch is totally wrong.  This would break the handling of this structure
on big-endian systems.

The right fix would be to change the declaration of ldp_hash_start and ldp_hash_end from
__u64 to __le64, along with ldp_flags and ldp_pad0 (though it should be unused).

Cheers, Andreas

> CHECK   drivers/staging/lustre/lustre/mdc/mdc_request.c
> drivers/staging/lustre/lustre/mdc/mdc_request.c:958:42: warning: cast
> to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:959:42: warning: cast
> to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:962:42: warning: cast
> to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:963:42: warning: cast
> to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:985:50: warning: cast
> to restricted __le32
> drivers/staging/lustre/lustre/mdc/mdc_request.c:1193:24: warning: cast
> to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:1328:25: warning: cast
> to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:1329:23: warning: cast
> to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:1332:25: warning: cast
> to restricted __le64
> drivers/staging/lustre/lustre/mdc/mdc_request.c:1333:23: warning: cast
> to restricted __le64
> 
> ---
> drivers/staging/lustre/lustre/mdc/mdc_request.c | 20 ++++++++++----------
> 1 file changed, 10 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
> index 6bc2fb8..aa8837c 100644
> --- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
> +++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
> @@ -955,12 +955,12 @@ static struct page *mdc_page_locate(struct address_space *mapping, __u64 *hash,
> 		if (PageUptodate(page)) {
> 			dp = kmap(page);
> 			if (BITS_PER_LONG == 32 && hash64) {
> -				*start = le64_to_cpu(dp->ldp_hash_start) >> 32;
> -				*end   = le64_to_cpu(dp->ldp_hash_end) >> 32;
> +				*start = dp->ldp_hash_start >> 32;
> +				*end   = dp->ldp_hash_end >> 32;
> 				*hash  = *hash >> 32;
> 			} else {
> -				*start = le64_to_cpu(dp->ldp_hash_start);
> -				*end   = le64_to_cpu(dp->ldp_hash_end);
> +				*start = dp->ldp_hash_start;
> +				*end   = dp->ldp_hash_end;
> 			}
> 			if (unlikely(*start == 1 && *hash == 0))
> 				*hash = *start;
> @@ -982,7 +982,7 @@ static struct page *mdc_page_locate(struct address_space *mapping, __u64 *hash,
> 				 */
> 				kunmap(page);
> 				mdc_release_page(page,
> -						 le32_to_cpu(dp->ldp_flags) & LDF_COLLIDE);
> +						 dp->ldp_flags & LDF_COLLIDE);

Note that it would also be acceptable to use "cpu_to_le32(LDF_COLLIDE)" here, since swabbing
a constant is a compile-time operation, while swabbing a variable adds runtime overhead on
big-endian systems.

> 				page = NULL;
> 			}
> 		} else {
> @@ -1190,7 +1190,7 @@ static int mdc_read_page_remote(void *data, struct page *page0)
> 		SetPageUptodate(page);
> 
> 		dp = kmap(page);
> -		hash = le64_to_cpu(dp->ldp_hash_start);
> +		hash = dp->ldp_hash_start;
> 		kunmap(page);
> 
> 		offset = hash_x_index(hash, rp->rp_hash64);
> @@ -1325,12 +1325,12 @@ static int mdc_read_page(struct obd_export *exp, struct md_op_data *op_data,
> hash_collision:
> 	dp = page_address(page);
> 	if (BITS_PER_LONG == 32 && rp_param.rp_hash64) {
> -		start = le64_to_cpu(dp->ldp_hash_start) >> 32;
> -		end = le64_to_cpu(dp->ldp_hash_end) >> 32;
> +		start = dp->ldp_hash_start >> 32;
> +		end = dp->ldp_hash_end >> 32;
> 		rp_param.rp_off = hash_offset >> 32;
> 	} else {
> -		start = le64_to_cpu(dp->ldp_hash_start);
> -		end = le64_to_cpu(dp->ldp_hash_end);
> +		start = dp->ldp_hash_start;
> +		end = dp->ldp_hash_end;
> 		rp_param.rp_off = hash_offset;
> 	}
> 	if (end == start) {
> -- 
> 1.9.1
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
