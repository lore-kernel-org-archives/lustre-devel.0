From: NeilBrown <neilb@suse.com>
Date: Tue, 12 Jun 2018 15:26:38 +1000
Subject: [lustre-devel] [PATCH] staging: lustre: add error handling for
 try_module_get
In-Reply-To: <1528778968-42225-1-git-send-email-jiazhouyang09@gmail.com>
References: <1528778968-42225-1-git-send-email-jiazhouyang09@gmail.com>
Message-ID: <87y3fkinht.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zhouyang Jia <jiazhouyang09@gmail.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Haneen Mohammed <hamohammed.sa@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, "Gustavo A. R. Silva" <garsilva@embeddedor.com>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On Tue, Jun 12 2018, Zhouyang Jia wrote:

> When try_module_get fails, the lack of error-handling code may
> cause unexpected results.
>
> This patch adds error-handling code after calling try_module_get.
>
> Signed-off-by: Zhouyang Jia <jiazhouyang09@gmail.com>
> ---
>  drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
> index 7086678..72a42bd 100644
> --- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
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
>  
>  	ksocknal_data.ksnd_sched_info = cfs_percpt_alloc(lnet_cpt_table(),
>  							 sizeof(*info));

Thanks for the patch....
I agree that this is probably a bug, but the code is still buggy after
you patch, just in a different way.
Try following through the code and see what happens when you 'goto
failed'.

NeilBrown


-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180612/9407950d/attachment.sig>
