From: greg at kroah.com <greg@kroah.com>
Date: Tue, 18 Apr 2017 17:50:19 +0200
Subject: [lustre-devel] [Patch v3 1/2] lustre: Parantheses added for
 Macro argument to avoid precedence issues
In-Reply-To: <VI1PR0901MB16166F494E9CECB93E1CD478A4040@VI1PR0901MB1616.eurprd09.prod.outlook.com>
References: <a2e734ab4562ded68cb7e7b8d55f51f757189fcd.1492255078>
	<VI1PR0901MB16166F494E9CECB93E1CD478A4040@VI1PR0901MB1616.eurprd09.prod.outlook.com>
Message-ID: <20170418155019.GA7263@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rishiraj Manwatkar <manwatkar@outlook.com>
Cc: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "andreas.dilger@intel.com" <andreas.dilger@intel.com>, "oleg.drokin@intel.com" <oleg.drokin@intel.com>

On Sat, Apr 15, 2017 at 01:50:42PM +0000, Rishiraj Manwatkar wrote:
> Parantheses are added for Macro argument, to avoid precedence issues.
> 
> Signed-off-by: Rishiraj Manwatkar <manwatkar@outlook.com>
> ---
>  v1 -> v2: Added mailing list in cc.
>  v2 -> v3: Changed From: to be same as Signed-off-by:.
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

Really?  There is no precedence issues that I can see here, sorry.

thanks,

greg k-h
