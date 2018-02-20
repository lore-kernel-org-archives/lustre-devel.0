From: Eremin, Dmitry <dmitry.eremin@intel.com>
Date: Tue, 20 Feb 2018 08:07:36 +0000
Subject: [lustre-devel] [PATCH 14/21] staging: lustre: fix assorted
 checkpatch errors
In-Reply-To: <151909341801.25814.16760126077741712102.stgit@noble>
References: <151909308778.25814.9912662268627044409.stgit@noble>
 <151909341801.25814.16760126077741712102.stgit@noble>
Message-ID: <9FC73D3DBECE0941BD2ED069D26863425CE8FF1E@irsmsx110.ger.corp.intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>, "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, "Dilger, Andreas" <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

Hello Neil,

> diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c
> b/drivers/staging/lustre/lustre/mdc/mdc_request.c
> index ab48746ce433..bde27acb0dd3 100644
> --- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
> +++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
> @@ -1060,8 +1060,10 @@ static void mdc_adjust_dirpages(struct page
> **pages, int cfs_pgs, int lu_pgs)
> 
>  		while (--lu_pgs > 0) {
>  			ent = lu_dirent_start(dp);
> -			for (end_dirent = ent; ent;
> -			     end_dirent = ent, ent = lu_dirent_next(ent));
> +			while (ent) {
> +				end_dirent = ent;
> +				ent = lu_dirent_next(ent);
> +			}
> 
>  			/* Advance dp to next lu_dirpage. */
>  			dp = (struct lu_dirpage *)((char *)dp + LU_PAGE_SIZE);

I doubt this is correct replacement. In original code end_dirent is set always in the begin of outer loop (while (--lu_pgs > 0)). But in new code this is missed. Therefore in case of second iteration and (ent = lu_dirent_start(dp)) == NULL the end_dirent will contain a value from previous iteration which is not correct.

Dmitry.

--------------------------------------------------------------------
Joint Stock Company Intel A/O
Registered legal address: Krylatsky Hills Business Park,
17 Krylatskaya Str., Bldg 4, Moscow 121614,
Russian Federation

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.
