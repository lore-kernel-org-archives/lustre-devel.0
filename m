From: NeilBrown <neilb@suse.com>
Date: Wed, 01 Aug 2018 08:32:49 +1000
Subject: [lustre-devel] [PATCH 07/31] lustre: lnet: change positional
 struct initializers to C99
In-Reply-To: <1533003983-29311-8-git-send-email-jsimmons@infradead.org>
References: <1533003983-29311-1-git-send-email-jsimmons@infradead.org>
 <1533003983-29311-8-git-send-email-jsimmons@infradead.org>
Message-ID: <87a7q7rq7i.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Jul 30 2018, James Simmons wrote:
> --- a/drivers/staging/lustre/lnet/lnet/lo.c
> +++ b/drivers/staging/lustre/lnet/lnet/lo.c
> @@ -91,15 +91,13 @@
>  }
>  
>  struct lnet_lnd the_lolnd = {
> -	/* .lnd_list       = */ {&the_lolnd.lnd_list, &the_lolnd.lnd_list},
> -	/* .lnd_refcount   = */ 0,
> -	/* .lnd_type       = */ LOLND,
> -	/* .lnd_startup    = */ lolnd_startup,
> -	/* .lnd_shutdown   = */ lolnd_shutdown,
> -	/* .lnt_ctl        = */ NULL,
> -	/* .lnd_send       = */ lolnd_send,
> -	/* .lnd_recv       = */ lolnd_recv,
> -	/* .lnd_eager_recv = */ NULL,
> -	/* .lnd_notify     = */ NULL,
> -	/* .lnd_accept     = */ NULL
> +	.lnd_list	= {
> +				.next	= &the_lolnd.lnd_list,
> +				.prev	= &the_lolnd.lnd_list
> +			},

That would be better as
        .lnd_list       = LIST_HEAD_INIT(the_lolnd.lnd_list),

I'll queue a patch to make that change.

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180801/c1dc9566/attachment.sig>
