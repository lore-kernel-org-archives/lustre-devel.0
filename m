From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 19:44:57 +0000 (GMT)
Subject: [lustre-devel] [patch] staging: lustre: lov: crash in error
	handling
In-Reply-To: <20161110194105.GB18347@mwanda>
References: <20161110194105.GB18347@mwanda>
Message-ID: <alpine.LFD.2.20.1611101944280.31600@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, "John L. Hammond" <john.hammond@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Amitoj Kaur Chawla <amitoj1606@gmail.com>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org


> We accidentally made this unsigned so now the error handling will loop
> until it crashes.
> 
> Fixes: 55051039fdad ('staging: lustre: lov: remove LSM from struct lustre_md')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Yep. I just sent a patch to fix that. 

> diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
> index 53db170..2e2abed 100644
> --- a/drivers/staging/lustre/lustre/lov/lov_ea.c
> +++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
> @@ -81,7 +81,7 @@ struct lov_stripe_md *lsm_alloc_plain(u16 stripe_count)
>  	size_t oinfo_ptrs_size, lsm_size;
>  	struct lov_stripe_md *lsm;
>  	struct lov_oinfo     *loi;
> -	unsigned int i;
> +	int i;
>  
>  	LASSERT(stripe_count <= LOV_MAX_STRIPE_COUNT);
>  
> 
