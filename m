From: greg at kroah.com <greg@kroah.com>
Date: Sat, 15 Apr 2017 13:48:51 +0200
Subject: [lustre-devel] [Patch v2 1/2] lustre: Parantheses added for
 Macro argument to avoid precedence issues
In-Reply-To: <VI1PR0901MB1616DC70D6D5F1A84A43C5D9A4040@VI1PR0901MB1616.eurprd09.prod.outlook.com>
References: <a2e734ab4562ded68cb7e7b8d55f51f757189fcd.1492252523>
	<VI1PR0901MB1616DC70D6D5F1A84A43C5D9A4040@VI1PR0901MB1616.eurprd09.prod.outlook.com>
Message-ID: <20170415114851.GA24035@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rishiraj Manwatkar <manwatkar@outlook.com>
Cc: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "andreas.dilger@intel.com" <andreas.dilger@intel.com>, "oleg.drokin@intel.com" <oleg.drokin@intel.com>

On Sat, Apr 15, 2017 at 11:25:00AM +0000, Rishiraj Manwatkar wrote:
> From: RishirajAM <manwatkar@outlook.com>
> 
> Parantheses are added for Macro argument, to avoid precedence issues.
> 
> Signed-off-by: Rishiraj Manwatkar <manwatkar@outlook.com>
> ---
>  drivers/staging/lustre/lustre/obdclass/cl_io.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

What changed from v1?  Always put that below the --- line.

And your From: line doesn't match your signed-off-by name, that's not
ok.

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

What 'precidence' issue is this fixing?  How could that ever be
incorrect?

Really, this macro just needs to go away and be used "as is" anyway...

thanks,

greg k-h
