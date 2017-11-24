From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 24 Nov 2017 16:42:47 +0100
Subject: [lustre-devel] [PATCH 3/4] staging: lustre: fixed signedness of
 lov
In-Reply-To: <20171122193831.11801-4-stefano.manni@gmail.com>
References: <20171122193831.11801-1-stefano.manni@gmail.com>
 <20171122193831.11801-4-stefano.manni@gmail.com>
Message-ID: <20171124154247.GA15000@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stefano Manni <stefano.manni@gmail.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On Wed, Nov 22, 2017 at 08:38:30PM +0100, Stefano Manni wrote:
> sparse warning on lov_obd.c:
> warning: incorrect type in argument 3 (different signedness)
> expected int *res
> got unsigned int [usertype] *i
> 
> sparse warning on lov_offset.c:
> warning: incorrect type in argument 4 (different signedness)
> expected long long [usertype] *<noident>
> got unsigned long long *<noident>

Can you not line-wrap these sparse warning lines, it makes them hard to
read.  It's ok to leave them as very long lines in the changelog.

> 
> Signed-off-by: Stefano Manni <stefano.manni@gmail.com>
> ---
>  drivers/staging/lustre/lustre/lov/lov_obd.c    |  2 +-
>  drivers/staging/lustre/lustre/lov/lov_offset.c | 11 +++++++----
>  2 files changed, 8 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
> index 7ce0102..3cccd79 100644
> --- a/drivers/staging/lustre/lustre/lov/lov_obd.c
> +++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
> @@ -899,7 +899,7 @@ int lov_process_config_base(struct obd_device *obd, struct lustre_cfg *lcfg,
>  
>  		obd_str2uuid(&obd_uuid,  lustre_cfg_buf(lcfg, 1));
>  
> -		rc = kstrtoint(lustre_cfg_buf(lcfg, 2), 10, indexp);
> +		rc = kstrtouint(lustre_cfg_buf(lcfg, 2), 10, indexp);
>  		if (rc < 0)
>  			goto out;
>  		rc = kstrtoint(lustre_cfg_buf(lcfg, 3), 10, genp);
> diff --git a/drivers/staging/lustre/lustre/lov/lov_offset.c b/drivers/staging/lustre/lustre/lov/lov_offset.c
> index 3e16e64..954a01b 100644
> --- a/drivers/staging/lustre/lustre/lov/lov_offset.c
> +++ b/drivers/staging/lustre/lustre/lov/lov_offset.c
> @@ -44,7 +44,7 @@ u64 lov_stripe_size(struct lov_stripe_md *lsm, u64 ost_size, int stripeno)
>  {
>  	unsigned long ssize = lsm->lsm_stripe_size;
>  	unsigned long stripe_size;
> -	u64 swidth;
> +	long long swidth;

This feels wrong, u64 should be used instead, can the code be fixed up
to use that type properly?  Don't rely on long long anywhere, it's hard
to always know what it should be on all arches...

Please fix up and resend this series based on the reviews you've gotten
so far.

thanks,

greg k-h
