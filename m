From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Sun, 12 Mar 2017 14:36:47 +0100
Subject: [lustre-devel] [PATCH] staging: lustre: replace simple_strtoul
	with kstrtoint
In-Reply-To: <20170309145300.GA2849@gentoo>
References: <20170309145300.GA2849@gentoo>
Message-ID: <20170312133647.GB27791@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Marcin Ciupak <marcin.s.ciupak@gmail.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, Andreas Dilger <andreas.dilger@intel.com>, lustre-devel@lists.lustre.org

On Thu, Mar 09, 2017 at 03:53:00PM +0100, Marcin Ciupak wrote:
> Replace simple_strtoul with kstrtoint.

Why?

> simple_strtoul is marked for obsoletion.
> 
> Signed-off-by: Marcin Ciupak <marcin.s.ciupak@gmail.com>
> ---
>  drivers/staging/lustre/lustre/obdclass/obd_mount.c | 20 ++++++++++++++++----
>  1 file changed, 16 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
> index 8e0d4b1d86dc..4a604e9b3e49 100644
> --- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
> +++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
> @@ -924,12 +924,24 @@ static int lmd_parse(char *options, struct lustre_mount_data *lmd)
>  			lmd->lmd_flags |= LMD_FLG_ABORT_RECOV;
>  			clear++;
>  		} else if (strncmp(s1, "recovery_time_soft=", 19) == 0) {
> -			lmd->lmd_recovery_time_soft = max_t(int,
> -				simple_strtoul(s1 + 19, NULL, 10), time_min);
> +			int res;
> +
> +			rc = kstrtoint(s1 + 19, 10, &res);
> +			if (rc)
> +				lmd->lmd_recovery_time_soft = time_min;
> +			else
> +				lmd->lmd_recovery_time_soft = max_t(int, res,
> +								    time_min);

Are you sure this is correct?  Do you really want to use max_t()?  Why
is time_min used if there is an error?  Can't this all be written a lot
simpler to actually make it semi-sane?

thanks,

greg k-h
