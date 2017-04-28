From: greg at kroah.com <greg@kroah.com>
Date: Fri, 28 Apr 2017 11:42:27 +0200
Subject: [lustre-devel] [Patch v4 1/2] staging/lustre: add parenthesis
	to macro argument
In-Reply-To: <VI1PR0901MB161661F1051BA2598CCE8DA0A4180@VI1PR0901MB1616.eurprd09.prod.outlook.com>
References: <eff7ffe99acb472d970754b6572573e36bfc8a7f.1492263580>
	<VI1PR0901MB161661F1051BA2598CCE8DA0A4180@VI1PR0901MB1616.eurprd09.prod.outlook.com>
Message-ID: <20170428094227.GA7739@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rishiraj Manwatkar <manwatkar@outlook.com>
Cc: "andreas.dilger@intel.com" <andreas.dilger@intel.com>, "oleg.drokin@intel.com" <oleg.drokin@intel.com>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Apr 19, 2017 at 03:50:05PM +0000, Rishiraj Manwatkar wrote:
> Add parenthesis to cl_io_for_each() macro to avoid potential issues with
> unexpected argument expansion in CPP.
> 
> Signed-off-by: Rishiraj Manwatkar <manwatkar@outlook.com>
> ---
>  v1 -> v2: Added mailing list in cc.
>  v2 -> v3: Changed From: to be same as Signed-off-by:.
>  v3 -> v4: Changed Subject line and patch description as suggested by andreas.dilger at intel.com
>  drivers/staging/lustre/lustre/obdclass/cl_io.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
> index ee7d677..0997254 100755
> --- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
> +++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
> @@ -52,9 +52,9 @@
>   */
>  
>  #define cl_io_for_each(slice, io) \
> -	list_for_each_entry((slice), &io->ci_layers, cis_linkage)
> +	list_for_each_entry((slice), &(io)->ci_layers, cis_linkage)
>  #define cl_io_for_each_reverse(slice, io)		 \
> -	list_for_each_entry_reverse((slice), &io->ci_layers, cis_linkage)
> +	list_for_each_entry_reverse((slice), &(io)->ci_layers, cis_linkage)

No, the original code is correct, that's going to be a variable only,
not any type of "complex argument".

thanks,

greg k-h
