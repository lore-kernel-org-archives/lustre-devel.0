From: NeilBrown <neilb@suse.com>
Date: Sun, 13 May 2018 07:31:45 +1000
Subject: [lustre-devel] [PATCH] staging: lustre: Use 'kvfree()' for
 memory allocated by 'kvzalloc()'
In-Reply-To: <20180512121426.22988-1-christophe.jaillet@wanadoo.fr>
References: <20180512121426.22988-1-christophe.jaillet@wanadoo.fr>
Message-ID: <87y3go8sse.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>, oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, gregkh@linuxfoundation.org, aastha.gupta4104@gmail.com
Cc: devel@driverdev.osuosl.org, kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

On Sat, May 12 2018, Christophe JAILLET wrote:

> 'buf' is allocated with 'kvzalloc()'. 'kvfree()' must be used to free it.
>
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>

Reviewed-by: NeilBrown <neilb@suse.com>

Thanks.
We could possible add:
Fixes: 11c647caf74b ("staging: lustre: obdclass: variable llog chunk size")

just for completeness.

NeilBrown

> ---
>  drivers/staging/lustre/lustre/obdclass/llog.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
> index 693e1129f1f9..5e04d133b596 100644
> --- a/drivers/staging/lustre/lustre/obdclass/llog.c
> +++ b/drivers/staging/lustre/lustre/obdclass/llog.c
> @@ -385,7 +385,7 @@ static int llog_process_thread(void *arg)
>  	if (cd)
>  		cd->lpcd_last_idx = last_called_index;
>  
> -	kfree(buf);
> +	kvfree(buf);
>  	lpi->lpi_rc = rc;
>  	return 0;
>  }
> -- 
> 2.17.0
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180513/23c837bd/attachment.sig>
