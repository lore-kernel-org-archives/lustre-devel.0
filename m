From: James Simmons <jsimmons@infradead.org>
Date: Thu, 2 Aug 2018 04:09:55 +0100 (BST)
Subject: [lustre-devel] [PATCH 20/22] lustre: lov_obd: convert
 list_for_each_entry_safe() to while(!list_empty())
In-Reply-To: <153292186143.13840.16227510388221165130.stgit@noble>
References: <153292153459.13840.17465048403476297915.stgit@noble>
 <153292186143.13840.16227510388221165130.stgit@noble>
Message-ID: <alpine.LFD.2.21.1808020409470.5677@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> These loops are removing all elements from a list.
> So using while(!list_empty()) makes the intent clearer.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lustre/lov/lov_obd.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
> index ee0898cbd9c9..0dd471cfe9a1 100644
> --- a/drivers/staging/lustre/lustre/lov/lov_obd.c
> +++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
> @@ -83,7 +83,7 @@ static void lov_putref(struct obd_device *obd)
>  	if (atomic_dec_and_test(&lov->lov_refcount) && lov->lov_death_row) {
>  		LIST_HEAD(kill);
>  		int i;
> -		struct lov_tgt_desc *tgt, *n;
> +		struct lov_tgt_desc *tgt;
>  
>  		CDEBUG(D_CONFIG, "destroying %d lov targets\n",
>  		       lov->lov_death_row);
> @@ -103,7 +103,8 @@ static void lov_putref(struct obd_device *obd)
>  		}
>  		mutex_unlock(&lov->lov_lock);
>  
> -		list_for_each_entry_safe(tgt, n, &kill, ltd_kill) {
> +		while (!list_empty(&kill)) {
> +			tgt = list_first_entry(&kill, struct lov_tgt_desc, ltd_kill);
>  			list_del(&tgt->ltd_kill);
>  			/* Disconnect */
>  			__lov_del_obd(obd, tgt);
> 
> 
> 
