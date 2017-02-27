From: Joe Perches <joe@perches.com>
Date: Mon, 27 Feb 2017 11:31:08 -0800
Subject: [lustre-devel] [PATCH 4/5] staging: sm750fb: Remove unnecessary
 else after return
In-Reply-To: <1488219268-3006-4-git-send-email-singhalsimran0@gmail.com>
References: <1488219268-3006-1-git-send-email-singhalsimran0@gmail.com>
	<1488219268-3006-4-git-send-email-singhalsimran0@gmail.com>
Message-ID: <1488223868.25838.10.camel@perches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: simran singhal <singhalsimran0@gmail.com>, gregkh@linuxfoundation.org
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-fbdev@vger.kernel.org, outreachy-kernel@googlegroups.com

On Mon, 2017-02-27 at 23:44 +0530, simran singhal wrote:
> This patch fixes the checkpatch warning that else is not generally
> useful after a break or return.
[]
> diff --git a/drivers/staging/sm750fb/ddk750_swi2c.c b/drivers/staging/sm750fb/ddk750_swi2c.c
[]
> @@ -295,8 +294,7 @@ static long sw_i2c_write_byte(unsigned char data)
>  
>  	if (i < 0xff)
>  		return 0;
> -	else
> -		return -1;
> +	return -1;

Assuming -1 is some sort of error,
it'd be a more common style to use

	if (i >= 0xff)
		return -1;

	return 0;

Looking at the code, it might make
sense to use something like:

	/* SDA still != 0 */
	if (i >= 0xff)
		return -1;

	return 0;
}
