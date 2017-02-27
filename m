From: Julia Lawall <julia.lawall@lip6.fr>
Date: Mon, 27 Feb 2017 22:15:38 +0100 (CET)
Subject: [lustre-devel] [Outreachy kernel] [PATCH 4/5] staging: sm750fb:
 Remove unnecessary else after return
In-Reply-To: <1488219268-3006-4-git-send-email-singhalsimran0@gmail.com>
References: <1488219268-3006-1-git-send-email-singhalsimran0@gmail.com>
	<1488219268-3006-4-git-send-email-singhalsimran0@gmail.com>
Message-ID: <alpine.DEB.2.20.1702272214410.2127@hadrien>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: simran singhal <singhalsimran0@gmail.com>
Cc: gregkh@linuxfoundation.org, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-fbdev@vger.kernel.org, outreachy-kernel@googlegroups.com



On Mon, 27 Feb 2017, simran singhal wrote:

> This patch fixes the checkpatch warning that else is not generally
> useful after a break or return.
>
> This was done using Coccinelle:
> @@
> expression e2;
> statement s1;
> @@
> if(e2) { ... return ...; }
> -else
>          s1
>
> Signed-off-by: simran singhal <singhalsimran0@gmail.com>
> ---
>  drivers/staging/sm750fb/ddk750_sii164.c | 6 ++----
>  drivers/staging/sm750fb/ddk750_swi2c.c  | 6 ++----
>  2 files changed, 4 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/staging/sm750fb/ddk750_sii164.c b/drivers/staging/sm750fb/ddk750_sii164.c
> index 259006a..6906598 100644
> --- a/drivers/staging/sm750fb/ddk750_sii164.c
> +++ b/drivers/staging/sm750fb/ddk750_sii164.c
> @@ -368,8 +368,7 @@ unsigned char sii164IsConnected(void)
>  	hotPlugValue = i2cReadReg(SII164_I2C_ADDRESS, SII164_DETECT) & SII164_DETECT_HOT_PLUG_STATUS_MASK;
>  	if (hotPlugValue == SII164_DETECT_HOT_PLUG_STATUS_ON)
>  		return 1;
> -	else
> -		return 0;
> +	return 0;


Totally unrelated to what you are doing, but I wonder if these return
values should be true and false?  Perhaps it would help to see how the
return values are used at the calling context.

julia

>  }
>
>  /*
> @@ -387,8 +386,7 @@ unsigned char sii164CheckInterrupt(void)
>  	detectReg = i2cReadReg(SII164_I2C_ADDRESS, SII164_DETECT) & SII164_DETECT_MONITOR_STATE_MASK;
>  	if (detectReg == SII164_DETECT_MONITOR_STATE_CHANGE)
>  		return 1;
> -	else
> -		return 0;
> +	return 0;
>  }
>
>  /*
> diff --git a/drivers/staging/sm750fb/ddk750_swi2c.c b/drivers/staging/sm750fb/ddk750_swi2c.c
> index a4ac07c..5997349 100644
> --- a/drivers/staging/sm750fb/ddk750_swi2c.c
> +++ b/drivers/staging/sm750fb/ddk750_swi2c.c
> @@ -199,8 +199,7 @@ static unsigned char sw_i2c_read_sda(void)
>  	gpio_data = peek32(sw_i2c_data_gpio_data_reg);
>  	if (gpio_data & (1 << sw_i2c_data_gpio))
>  		return 1;
> -	else
> -		return 0;
> +	return 0;
>  }
>
>  /*
> @@ -295,8 +294,7 @@ static long sw_i2c_write_byte(unsigned char data)
>
>  	if (i < 0xff)
>  		return 0;
> -	else
> -		return -1;
> +	return -1;
>  }
>
>  /*
> --
> 2.7.4
>
> --
> You received this message because you are subscribed to the Google Groups "outreachy-kernel" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to outreachy-kernel+unsubscribe at googlegroups.com.
> To post to this group, send email to outreachy-kernel at googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/outreachy-kernel/1488219268-3006-4-git-send-email-singhalsimran0%40gmail.com.
> For more options, visit https://groups.google.com/d/optout.
>
