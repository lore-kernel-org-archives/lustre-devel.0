From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 14 Apr 2017 10:16:31 +0200
Subject: [lustre-devel] [PATCH v2] staging: lustre: replace
	simple_strtoul with kstrtoint
In-Reply-To: <20170321124609.GA3896@gentoo>
References: <20170321124609.GA3896@gentoo>
Message-ID: <20170414081631.GC16598@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Marcin Ciupak <marcin.s.ciupak@gmail.com>
Cc: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, lustre-devel@lists.lustre.org

On Tue, Mar 21, 2017 at 01:46:09PM +0100, Marcin Ciupak wrote:
> Replace simple_strtoul with kstrtoint.
> simple_strtoul is marked for obsoletion as reported by checkpatch.pl
> 
> Signed-off-by: Marcin Ciupak <marcin.s.ciupak@gmail.com>
> ---
> v2:
> 	-improving kstrtoint error handling
> 	-updating commit message
> 
>  drivers/staging/lustre/lustre/obdclass/obd_mount.c | 16 ++++++++++++----
>  1 file changed, 12 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
> index 8e0d4b1d86dc..42858ee5b444 100644
> --- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
> +++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
> @@ -924,12 +924,20 @@ static int lmd_parse(char *options, struct lustre_mount_data *lmd)
>  			lmd->lmd_flags |= LMD_FLG_ABORT_RECOV;
>  			clear++;
>  		} else if (strncmp(s1, "recovery_time_soft=", 19) == 0) {
> -			lmd->lmd_recovery_time_soft = max_t(int,
> -				simple_strtoul(s1 + 19, NULL, 10), time_min);
> +			int res;
> +
> +			rc = kstrtoint(s1 + 19, 10, &res);
> +			if (rc)
> +				goto invalid;
> +			lmd->lmd_recovery_time_soft = max_t(int, res, time_min);

Are you sure max_t is still needed here?

And have you tested this change?

thanks,

greg k-h
