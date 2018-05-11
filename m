From: NeilBrown <neilb@suse.com>
Date: Fri, 11 May 2018 10:53:19 +1000
Subject: [lustre-devel] [PATCH] staging: lustre: o2iblnd: Fix crash in
 kiblnd_handle_early_rxs()
In-Reply-To: <1525930679-15227-1-git-send-email-dougso@me.com>
References: <1525930679-15227-1-git-send-email-dougso@me.com>
Message-ID: <87a7t79fnk.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Doug Oucharek <dougso@me.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Wed, May 09 2018, Doug Oucharek wrote:

> Under upstream staging commit 5a2ca43fa54f561c252c2, the list handling
> code in kiblnd_handle_early_rxs() got changed to list_for_each_safe().
> That protects against the current thread from deleting the current entry
> it is looking at. It does not protect against another thread from deleting
> the next item in the list (which the tmp variable points to). The way this
> routine holds then releases a lock opens the door to other threads doing
> just that.
>
> This patch reverts this commit on this routine.
>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-9886
> Signed-off-by: Doug Oucharek <dougso@me.com>
> ---
>  drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> index 32fa8ca..6148fbb 100644
> --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> @@ -1965,13 +1965,14 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
>  {
>  	unsigned long flags;
>  	struct kib_rx *rx;
> -	struct kib_rx *tmp;
>  
>  	LASSERT(!in_interrupt());
>  	LASSERT(conn->ibc_state >= IBLND_CONN_ESTABLISHED);
>  
>  	write_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
> -	list_for_each_entry_safe(rx, tmp, &conn->ibc_early_rxs, rx_list) {
> +	while (!list_empty(&conn->ibc_early_rxs)) {
> +		rx = list_entry(conn->ibc_early_rxs.next,
> +				kib_rx_t, rx_list);
Should be:
                         struct kib_tx

Otherwise,
 Reviewed-by: NeilBrown <neilb@suse.com>

Those "convert lots of list_for_each" things really do need
careful review, don't they :-(

Thanks,
NeilBrown

>  		list_del(&rx->rx_list);
>  		write_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
>  
> -- 
> 1.8.3.1
>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180511/db75784b/attachment.sig>
