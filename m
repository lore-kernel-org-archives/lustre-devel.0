From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 31 Jan 2017 11:53:24 +0300
Subject: [lustre-devel] [PATCH 14/60] staging: lustre: lov: Ensure
 correct operation for large object sizes
In-Reply-To: <1485648328-2141-15-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
	<1485648328-2141-15-git-send-email-jsimmons@infradead.org>
Message-ID: <20170131085324.GG6881@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Nathaniel Clark <nathaniel.l.clark@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Sat, Jan 28, 2017 at 07:04:42PM -0500, James Simmons wrote:
> From: Nathaniel Clark <nathaniel.l.clark@intel.com>
> 
> If a backing filesystem (ZFS) returns that it supports very large
> (LLONG_MAX) object sizes, that should be correctly supported.  This
> fixes the check for unitialized stripe_maxbytes in
> lsm_unpackmd_common(), so that ZFS can return LLONG_MAX and it will be
> okay. This issue is excersized by writing to or past the 2TB boundary
> of a singly stripped file.
> 
> Signed-off-by: Nathaniel Clark <nathaniel.l.clark@intel.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7890
> Reviewed-on: http://review.whamcloud.com/19066
> Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
> Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>
> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  drivers/staging/lustre/lustre/lov/lov_ea.c | 22 ++++++++++++----------
>  1 file changed, 12 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
> index ac0bf64..07dee87 100644
> --- a/drivers/staging/lustre/lustre/lov/lov_ea.c
> +++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
> @@ -150,7 +150,7 @@ static int lsm_unpackmd_common(struct lov_obd *lov,
>  			       struct lov_mds_md *lmm,
>  			       struct lov_ost_data_v1 *objects)
>  {
> -	loff_t stripe_maxbytes = LLONG_MAX;
> +	loff_t min_stripe_maxbytes = 0, lov_bytes;


I've seen this thing in sevaral patches and I haven't commented on it
but please don't do this.

	unsigned long foo = 0, bar;

It took my a long time to find the lov_bytes declaration hiding off the
end here.  We haven't made checkpatch.pl complain about it yet but it's
not kernel style.  One declaration per line and especially if they
aren't closely related like "int left, right;" and doubly especially if
there is an initialization involved.

>  	unsigned int stripe_count;
>  	struct lov_oinfo *loi;
>  	unsigned int i;
> @@ -168,8 +168,6 @@ static int lsm_unpackmd_common(struct lov_obd *lov,
>  	stripe_count = lsm_is_released(lsm) ? 0 : lsm->lsm_stripe_count;
>  
>  	for (i = 0; i < stripe_count; i++) {
> -		loff_t tgt_bytes;
> -
>  		loi = lsm->lsm_oinfo[i];
>  		ostid_le_to_cpu(&objects[i].l_ost_oi, &loi->loi_oi);
>  		loi->loi_ost_idx = le32_to_cpu(objects[i].l_ost_idx);
> @@ -194,17 +192,21 @@ static int lsm_unpackmd_common(struct lov_obd *lov,
>  			continue;
>  		}
>  
> -		tgt_bytes = lov_tgt_maxbytes(lov->lov_tgts[loi->loi_ost_idx]);
> -		stripe_maxbytes = min_t(loff_t, stripe_maxbytes, tgt_bytes);
> +		lov_bytes = lov_tgt_maxbytes(lov->lov_tgts[loi->loi_ost_idx]);
> +		if (min_stripe_maxbytes == 0 || lov_bytes < min_stripe_maxbytes)
> +			min_stripe_maxbytes = lov_bytes;
>  	}
>  
> -	if (stripe_maxbytes == LLONG_MAX)
> -		stripe_maxbytes = LUSTRE_EXT3_STRIPE_MAXBYTES;
> +	if (min_stripe_maxbytes == 0)
> +		min_stripe_maxbytes = LUSTRE_EXT3_STRIPE_MAXBYTES;
> +
> +	stripe_count = lsm->lsm_stripe_count ?: lov->desc.ld_tgt_count;
> +	lov_bytes = min_stripe_maxbytes * stripe_count;
>  
> -	if (!lsm->lsm_stripe_count)
> -		lsm->lsm_maxbytes = stripe_maxbytes * lov->desc.ld_tgt_count;
> +	if (lov_bytes < min_stripe_maxbytes) /* handle overflow */

Signed overflows are undefined.  I think we use GCC options so that the
compiler does not remove these checks but I also know that I have been
wrong before about GCC options and undefined behavior.

regards,
dan carpenter
