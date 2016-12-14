From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Wed, 14 Dec 2016 21:27:49 +0000
Subject: [lustre-devel] [PATCH] staging : osc : coding style fix
In-Reply-To: <1481749884-25674-1-git-send-email-khan.tabrez21@gmail.com>
References: <1481749884-25674-1-git-send-email-khan.tabrez21@gmail.com>
Message-ID: <96EAFB90-2162-4155-950D-F586EE1DAF87@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tabrez khan <khan.tabrez21@gmail.com>
Cc: "jsimmons@infradead.org" <jsimmons@infradead.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Dec 14, 2016, at 14:11, Tabrez khan <khan.tabrez21@gmail.com> wrote:
> 
> Subject: [PATCH] staging : osc : coding style fix

Thanks for sumbitting your patch.

As a general rule, the patch summary line should try to describe
(as best as possible in a single line) what the patch is actually
fixing.  It is true this is a "coding style fix" but there are
many possible style fixes and it is better to be as specific as
space allows.  Something like:

    staging/lustre/osc: remove unnecessary braces

or
    staging/lustre/osc: remove braces from single-line body

or
    staging/lustre/osc: remove braces in osc_release_write_grant()

would be more specific.  This is doubly important if you are
making a large number of similar patches, since it is desirable
to have a (relatively) unique summary line for each patch to
avoid confusion.

> Remove unnecessary braces {} for single if statement block.
> This warning is found using checkpatch.pl.

The commit body is good.

Please resubmit with a new summary line, then you can include:

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

Cheers, Andreas

> Signed-off-by: Tabrez khan <khan.tabrez21@gmail.com>
> ---
> drivers/staging/lustre/lustre/osc/osc_cache.c | 4 +---
> 1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
> index 4bbe219..5ded31a 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_cache.c
> +++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
> @@ -1420,10 +1420,8 @@ static void osc_release_write_grant(struct client_obd *cli,
> 				    struct brw_page *pga)
> {
> 	assert_spin_locked(&cli->cl_loi_list_lock);
> -	if (!(pga->flag & OBD_BRW_FROM_GRANT)) {
> +	if (!(pga->flag & OBD_BRW_FROM_GRANT))
> 		return;
> -	}
> -
> 	pga->flag &= ~OBD_BRW_FROM_GRANT;
> 	atomic_long_dec(&obd_dirty_pages);
> 	cli->cl_dirty_pages--;
> -- 
> 2.7.4
> 
