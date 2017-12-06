From: gregkh at linuxfoundation.org <gregkh@linuxfoundation.org>
Date: Wed, 6 Dec 2017 09:53:03 +0100
Subject: [lustre-devel] [PATCH] staging: lustre: Fix sparse,
 using plain integer as NULL pointer in lov_object_fiemap()
In-Reply-To: <bc91bfe5-0d5d-7c93-957a-dce82a236b6f@mail.ru>
References: <e5107da2-a834-e1fd-03b8-01f60e4e19f4@mail.ru>
 <7A48E652-421B-464B-AD2A-C3D5613B48E5@intel.com>
 <bc91bfe5-0d5d-7c93-957a-dce82a236b6f@mail.ru>
Message-ID: <20171206085303.GA18289@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrii Vladyka <tulup@mail.ru>
Cc: "Dilger, Andreas" <andreas.dilger@intel.com>, "Drokin, Oleg" <oleg.drokin@intel.com>, "jsimmons@infradead.org" <jsimmons@infradead.org>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Dec 04, 2017 at 12:44:32PM +0200, Andrii Vladyka wrote:
> Change 0 to NULL in lov_object_fiemap() in order to fix warning produced by
> sparse
> 
> Signed-off-by: Andrii Vladyka <tulup@mail.ru>
> Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
> ---
> 
> diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
> index 105b707..897cf2c 100644
> --- a/drivers/staging/lustre/lustre/lov/lov_object.c
> +++ b/drivers/staging/lustre/lustre/lov/lov_object.c
> @@ -1335,7 +1335,7 @@ static int lov_object_fiemap(const struct lu_env *env, struct cl_object *obj,
>  	int rc = 0;
>  	int cur_stripe;
>  	int stripe_count;
> -	struct fiemap_state fs = { 0 };
> +	struct fiemap_state fs = { NULL };
>  	lsm = lov_lsm_addref(cl2lov(obj));
>  	if (!lsm)

Patch is corrupted, and can not apply, please fix up your email client
and try it again.

greg k-h
