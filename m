From: David Laight <David.Laight@ACULAB.COM>
Date: Wed, 13 Jun 2018 10:53:07 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: add error handling for
 try_module_get
In-Reply-To: <1528778968-42225-1-git-send-email-jiazhouyang09@gmail.com>
References: <1528778968-42225-1-git-send-email-jiazhouyang09@gmail.com>
Message-ID: <ed5d91f54b5a4776a66df87b645b0ee9@AcuMS.aculab.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Zhouyang Jia' <jiazhouyang09@gmail.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, NeilBrown <neilb@suse.com>, Haneen Mohammed <hamohammed.sa@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, "Gustavo A. R. Silva" <garsilva@embeddedor.com>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

From: Zhouyang Jia
> Sent: 12 June 2018 05:49
> 
> When try_module_get fails, the lack of error-handling code may
> cause unexpected results.
> 
> This patch adds error-handling code after calling try_module_get.
...
> +++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> @@ -2422,7 +2422,10 @@ ksocknal_base_startup(void)
> 
>  	/* flag lists/ptrs/locks initialised */
>  	ksocknal_data.ksnd_init = SOCKNAL_INIT_DATA;
> -	try_module_get(THIS_MODULE);
> +	if (!try_module_get(THIS_MODULE)) {
> +		CERROR("%s: cannot get module\n", __func__);
> +		goto failed;
> +	}


Can try_module_get(THIS_MODULE) ever fail?
Since you are running code in 'THIS_MODULE' the caller must have a
reference that can't go away.
So try_module_get() just increments the count that is already greater
than zero.

Similarly module_put(THIS_MODULE) must never be able to release the
last reference.
Any such calls that aren't in error paths after try_module_get() are
probably buggy.

	David
