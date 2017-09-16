From: Julia Lawall <julia.lawall@lip6.fr>
Date: Sat, 16 Sep 2017 13:23:28 +0200 (CEST)
Subject: [lustre-devel] [Outreachy kernel] [PATCH] staging: lustre:
 lnet: Replace list_for_each with list_for_each_entry
In-Reply-To: <20170916004148.GA25693@Haneen>
References: <20170916004148.GA25693@Haneen>
Message-ID: <alpine.DEB.2.20.1709161320250.2943@hadrien>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Haneen Mohammed <hamohammed.sa@gmail.com>
Cc: outreachy-kernel <outreachy-kernel@googlegroups.com>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org



On Fri, 15 Sep 2017, Haneen Mohammed wrote:

> Replace use of the combination of list_for_each and list_entry
> with list_for_each_entry to simplify the code and remove variables
> that are used only in list_for_each.
> Issue found and corrected using Coccinelle script:
>
> @r@
> expression head, member, e;
> type T1, T2, T3;
> iterator name list_for_each, list_for_each_entry;
> identifier pos, var;
> @@
>
> -T1 *pos;
> ...when!=pos=e;
>
> -list_for_each(pos, head)
> +list_for_each_entry(var, head, member)
> {
> ...when!=pos=e;
>    when!=T3 *var;
> -var = list_entry(pos, T2, member);
> ...when!=pos=e;
> }
> ...when!=pos=e;

Actually, one could consider that there should be when != pos, not when !=
pos=e, because you need that there are no references at all to pos to be
able to delete it.  But it's true that if pos is not initialized then
there should be no other kinds of references either.  The other
possibility for initialization would be eg

f(...,&pos,...)

You could be suspicious of &pos in general.  But anyway there is no &pos
in this code.

julia

> Signed-off-by: Haneen Mohammed <hamohammed.sa@gmail.com>

Acked-by: Julia Lawall <julia.lawall@lip6.fr>

> ---
>  drivers/staging/lustre/lnet/lnet/router.c | 9 ++-------
>  1 file changed, 2 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
> index 3df101b..b8eba33 100644
> --- a/drivers/staging/lustre/lnet/lnet/router.c
> +++ b/drivers/staging/lustre/lnet/lnet/router.c
> @@ -222,15 +222,12 @@ struct lnet_remotenet *
>  lnet_find_net_locked(__u32 net)
>  {
>  	struct lnet_remotenet *rnet;
> -	struct list_head *tmp;
>  	struct list_head *rn_list;
>
>  	LASSERT(!the_lnet.ln_shutdown);
>
>  	rn_list = lnet_net2rnethash(net);
> -	list_for_each(tmp, rn_list) {
> -		rnet = list_entry(tmp, struct lnet_remotenet, lrn_list);
> -
> +	list_for_each_entry(rnet, rn_list, lrn_list) {
>  		if (rnet->lrn_net == net)
>  			return rnet;
>  	}
> @@ -243,7 +240,6 @@ static void lnet_shuffle_seed(void)
>  	__u32 lnd_type, seed[2];
>  	struct timespec64 ts;
>  	struct lnet_ni *ni;
> -	struct list_head *tmp;
>
>  	if (seeded)
>  		return;
> @@ -254,8 +250,7 @@ static void lnet_shuffle_seed(void)
>  	 * Nodes with small feet have little entropy
>  	 * the NID for this node gives the most entropy in the low bits
>  	 */
> -	list_for_each(tmp, &the_lnet.ln_nis) {
> -		ni = list_entry(tmp, struct lnet_ni, ni_list);
> +	list_for_each_entry(ni, &the_lnet.ln_nis, ni_list) {
>  		lnd_type = LNET_NETTYP(LNET_NIDNET(ni->ni_nid));
>
>  		if (lnd_type != LOLND)
> --
> 2.7.4
>
> --
> You received this message because you are subscribed to the Google Groups "outreachy-kernel" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to outreachy-kernel+unsubscribe at googlegroups.com.
> To post to this group, send email to outreachy-kernel at googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/outreachy-kernel/20170916004148.GA25693%40Haneen.
> For more options, visit https://groups.google.com/d/optout.
>
