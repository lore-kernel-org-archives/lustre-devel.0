From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Mon, 3 Oct 2016 05:20:38 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: ko2iblbd:
	handle	ib_dereg_mr removal
In-Reply-To: <1475461351-21495-1-git-send-email-jsimmons@infradead.org>
References: <1475461351-21495-1-git-send-email-jsimmons@infradead.org>
Message-ID: <811D0FBE-A65A-4810-BD82-F6284254676F@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Oct 2, 2016, at 20:22, James Simmons <jsimmons@infradead.org> wrote:
> 
> In the rdma-next tree to be merged for 4.9-rc1 removes
> the IB core function ib_get_dma_mr. This patch migrates
> us way from this former function.
> 
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
> .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   19 ++++++++++++-------
> .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |    5 +++++
> 2 files changed, 17 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> index c7a5d49..4010591 100644
> --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> @@ -1316,7 +1316,7 @@ static void kiblnd_destroy_fmr_pool(struct kib_fmr_pool *fpo)
> 		list_for_each_entry_safe(frd, tmp, &fpo->fast_reg.fpo_pool_list,
> 					 frd_list) {
> 			list_del(&frd->frd_list);
> -			ib_dereg_mr(frd->frd_mr);
> +			kib_dereg_mr(fpo->fpo_hdev, frd->frd_mr);
> 			LIBCFS_FREE(frd, sizeof(*frd));
> 			i++;
> 		}
> @@ -1422,14 +1422,14 @@ static int kiblnd_alloc_freg_pool(struct kib_fmr_poolset *fps, struct kib_fmr_po
> 
> out_middle:
> 	if (frd->frd_mr)
> -		ib_dereg_mr(frd->frd_mr);
> +		kib_dereg_mr(fpo->fpo_hdev, frd->frd_mr);
> 	LIBCFS_FREE(frd, sizeof(*frd));
> 
> out:
> 	list_for_each_entry_safe(frd, tmp, &fpo->fast_reg.fpo_pool_list,
> 				 frd_list) {
> 		list_del(&frd->frd_list);
> -		ib_dereg_mr(frd->frd_mr);
> +		kib_dereg_mr(fpo->fpo_hdev, frd->frd_mr);
> 		LIBCFS_FREE(frd, sizeof(*frd));
> 	}
> 
> @@ -2288,8 +2288,8 @@ static void kiblnd_hdev_cleanup_mrs(struct kib_hca_dev *hdev)
> 	if (!hdev->ibh_mrs)
> 		return;
> 
> -	ib_dereg_mr(hdev->ibh_mrs);
> -
> +	kib_dereg_mr(hdev, hdev->ibh_mrs);
> +	hdev->ibh_pd->device->dereg_mr(hdev->ibh_mrs);

This should only call one of kib_dereg_mr() or hdev->...->dereg_mr() ?

> 	hdev->ibh_mrs = NULL;
> }
> 
> @@ -2316,13 +2316,18 @@ static int kiblnd_hdev_setup_mrs(struct kib_hca_dev *hdev)
> 	if (rc)
> 		return rc;
> 
> -	mr = ib_get_dma_mr(hdev->ibh_pd, acflags);
> +	mr = hdev->ibh_pd->device->get_dma_mr(hdev->ibh_pd, acflags);

Should we make a similar wrapper function kib_get_dma_mr()?

Cheers, Andreas

> 	if (IS_ERR(mr)) {
> -		CERROR("Failed ib_get_dma_mr : %ld\n", PTR_ERR(mr));
> +		CERROR("Failed device get_dma_mr : %ld\n", PTR_ERR(mr));
> 		kiblnd_hdev_cleanup_mrs(hdev);
> 		return PTR_ERR(mr);
> 	}
> 
> +	mr->device = hdev->ibh_pd->device;
> +	mr->pd = hdev->ibh_pd;
> +	mr->uobject = NULL;
> +	mr->need_inval = false;
> +
> 	hdev->ibh_mrs = mr;
> 
> 	return 0;
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
> index 1457697..f8b49c5 100644
> --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
> +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
> @@ -178,6 +178,11 @@ struct kib_hca_dev {
> 	atomic_t           ibh_ref;             /* refcount */
> };
> 
> +static inline void kib_dereg_mr(struct kib_hca_dev *hdev, struct ib_mr *mr)
> +{
> +	hdev->ibh_pd->device->dereg_mr(mr);
> +}
> +
> /** # of seconds to keep pool alive */
> #define IBLND_POOL_DEADLINE     300
> /** # of seconds to retry if allocation failed */
> -- 
> 1.7.1
> 
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
