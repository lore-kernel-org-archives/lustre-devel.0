From: NeilBrown <neilb@suse.com>
Date: Thu, 27 Sep 2018 09:59:59 +1000
Subject: [lustre-devel] [PATCH 02/25] lustre: lnet: Allow min stats to
 be reset in peers and nis
In-Reply-To: <1537930097-11624-3-git-send-email-jsimmons@infradead.org>
References: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
 <1537930097-11624-3-git-send-email-jsimmons@infradead.org>
Message-ID: <8736tvizcw.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Sep 25 2018, James Simmons wrote:

> From: Doug Oucharek <dougso@me.com>
>
> Allow writes to the peers and nis LNet procfs files to
> reset the mininum stat columns.
>
> Signed-off-by: Doug Oucharek <dougso@me.com>
> WC-bug-id: https://jira.whamcloud.com/browse/LU-7214
> Reviewed-on: https://review.whamcloud.com/20470
> Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
> Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
> Reviewed-by: Oleg Drokin <green@whamcloud.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  drivers/staging/lustre/lnet/lnet/router_proc.c | 69 +++++++++++++++++++++++---
>  1 file changed, 62 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
> index a887ca4..4ddd35b 100644
> --- a/drivers/staging/lustre/lnet/lnet/router_proc.c
> +++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
> @@ -393,7 +393,7 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
>  {
>  	const int tmpsiz  = 256;
>  	struct lnet_peer_table *ptable;
> -	char *tmpstr;
> +	char *tmpstr = NULL;
>  	char *s;
>  	int cpt  = LNET_PROC_CPT_GET(*ppos);
>  	int ver  = LNET_PROC_VER_GET(*ppos);
> @@ -402,12 +402,33 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
>  	int rc = 0;
>  	int len;
>  
> -	BUILD_BUG_ON(LNET_PROC_HASH_BITS < LNET_PEER_HASH_BITS);
> -	LASSERT(!write);
> +	if (write) {
> +		struct lnet_peer_ni *peer;
> +		int i;
> +
> +		cfs_percpt_for_each(ptable, i, the_lnet.ln_peer_tables) {
> +			lnet_net_lock(i);
> +			for (hash = 0; hash < LNET_PEER_HASH_SIZE; hash++) {
> +				list_for_each_entry(peer,
> +						    &ptable->pt_hash[hash],
> +						    lpni_hashlist) {
> +					peer->lpni_mintxcredits =
> +						peer->lpni_txcredits;
> +					peer->lpni_minrtrcredits =
> +						peer->lpni_rtrcredits;
> +				}
> +			}
> +			lnet_net_unlock(i);
> +		}
> +		*ppos += *lenp;
> +		return 0;
> +	}
>  
>  	if (!*lenp)
>  		return 0;
>  
> +	BUILD_BUG_ON(LNET_PROC_HASH_BITS < LNET_PEER_HASH_BITS);
> +
>  	if (cpt >= LNET_CPT_NUMBER) {
>  		*lenp = 0;
>  		return 0;
> @@ -627,11 +648,45 @@ static int proc_lnet_nis(struct ctl_table *table, int write,
>  	char *s;
>  	int len;
>  
> -	LASSERT(!write);
> -
>  	if (!*lenp)
>  		return 0;
>  
> +	if (write) {
> +		/* Just reset the min stat. */
> +		struct lnet_net *net;
> +		struct lnet_ni *ni;
> +
> +		lnet_net_lock(0);

Presumably we hold lnet_net_lock(0) across the whole process to stop an
EXCLUSIVE lock from being taken while the update progresses. That makes
sense.

So why doesn't proc_lnet_peers() above do the same thing?
Is it OK if I add that to the patch?

NeilBrown


> +
> +		list_for_each_entry(net, &the_lnet.ln_nets, net_list) {
> +			list_for_each_entry(ni, &net->net_ni_list, ni_netlist) {
> +				struct lnet_tx_queue *tq;
> +				int i;
> +				int j;
> +
> +				cfs_percpt_for_each(tq, i, ni->ni_tx_queues) {
> +					for (j = 0; ni->ni_cpts &&
> +					     j < ni->ni_ncpts; j++) {
> +						if (i == ni->ni_cpts[j])
> +							break;
> +					}
> +
> +					if (j == ni->ni_ncpts)
> +						continue;
> +
> +					if (i != 0)
> +						lnet_net_lock(i);
> +					tq->tq_credits_min = tq->tq_credits;
> +					if (i != 0)
> +						lnet_net_unlock(i);
> +				}
> +			}
> +		}
> +		lnet_net_unlock(0);
> +		*ppos += *lenp;
> +		return 0;
> +	}
> +
>  	tmpstr = kvmalloc(tmpsiz, GFP_KERNEL);
>  	if (!tmpstr)
>  		return -ENOMEM;
> @@ -847,7 +902,7 @@ static int proc_lnet_portal_rotor(struct ctl_table *table, int write,
>  	},
>  	{
>  		.procname     = "peers",
> -		.mode         = 0444,
> +		.mode         = 0644,
>  		.proc_handler = &proc_lnet_peers,
>  	},
>  	{
> @@ -857,7 +912,7 @@ static int proc_lnet_portal_rotor(struct ctl_table *table, int write,
>  	},
>  	{
>  		.procname     = "nis",
> -		.mode         = 0444,
> +		.mode         = 0644,
>  		.proc_handler = &proc_lnet_nis,
>  	},
>  	{
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180927/8674b8f0/attachment.sig>
