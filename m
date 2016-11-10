From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Thu, 10 Nov 2016 22:31:08 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: lov: Fix signed wrap
 around when decrementing index 'i'
In-Reply-To: <20161110141910.25095-1-colin.king@canonical.com>
References: <20161110141910.25095-1-colin.king@canonical.com>
Message-ID: <1E6549EE-799C-45ED-A9FA-B9B362F51351@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Colin King <colin.king@canonical.com>
Cc: James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Hammond, John" <john.hammond@intel.com>, Amitoj Kaur Chawla <amitoj1606@gmail.com>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Nov 10, 2016, at 07:19, Colin King <colin.king@canonical.com> wrote:
> 
> From: Colin Ian King <colin.king@canonical.com>
> 
> Change predecrement compare to post decrement compare to avoid an
> unsigned integer wrap-around comparisomn when decrementing in the while
> loop.
> 
> Issue found with static analysis with CoverityScan, CID 1375917

Thanks for the patch.  Seems this change has gotten a lot of attention,
this is the third patch to the list to fix it.  My preference is to
undo the int->unsigned declaration change, for which James has already
submitted a patch.

Cheers, Andreas

> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
> drivers/staging/lustre/lustre/lov/lov_ea.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
> index 53db170..399298c 100644
> --- a/drivers/staging/lustre/lustre/lov/lov_ea.c
> +++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
> @@ -102,7 +102,7 @@ struct lov_stripe_md *lsm_alloc_plain(u16 stripe_count)
> 	return lsm;
> 
> err:
> -	while (--i >= 0)
> +	while (i-- > 0)
> 		kmem_cache_free(lov_oinfo_slab, lsm->lsm_oinfo[i]);
> 	kvfree(lsm);
> 	return NULL;
> -- 
> 2.10.2
> 
