From: Oleg Drokin <oleg.drokin@intel.com>
Date: Mon, 5 Dec 2016 17:44:09 -0500
Subject: [lustre-devel] [PATCH 1/1] staging: lustre: lnet: fix improper
	return value
In-Reply-To: <1480769575-6074-1-git-send-email-bianpan201602@163.com>
References: <1480769575-6074-1-git-send-email-bianpan201602@163.com>
Message-ID: <2DA842C3-D6EF-472B-9187-A6C681ACD863@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Pan Bian <bianpan201602@163.com>
Cc: Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org SUBSYSTEM" <devel@driverdev.osuosl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Pan Bian <bianpan2016@163.com>


On Dec 3, 2016, at 7:52 AM, Pan Bian wrote:

> From: Pan Bian <bianpan2016@163.com>
> 
> At the end of function lstcon_group_info(), "return 0" seems improper.
> It may be better to return the value of rc.
> 
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=188811
> 
> Signed-off-by: Pan Bian <bianpan2016@163.com>

Acked-by: Oleg Drokin <oleg.drokin@intel.com>

> ---
> drivers/staging/lustre/lnet/selftest/console.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
> index a0fcbf3..9a7c41a 100644
> --- a/drivers/staging/lustre/lnet/selftest/console.c
> +++ b/drivers/staging/lustre/lnet/selftest/console.c
> @@ -820,7 +820,7 @@
> 
> 	lstcon_group_decref(grp);
> 
> -	return 0;
> +	return rc;
> }
> 
> static int
> -- 
> 1.9.1
> 
