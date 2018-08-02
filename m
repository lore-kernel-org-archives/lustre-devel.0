From: James Simmons <jsimmons@infradead.org>
Date: Thu, 2 Aug 2018 04:10:15 +0100 (BST)
Subject: [lustre-devel] [PATCH 21/22] lustre: ldlm_request: convert
 list_for_each_entry_safe() to while(!list_empty())
In-Reply-To: <153292186147.13840.314584204805282590.stgit@noble>
References: <153292153459.13840.17465048403476297915.stgit@noble>
 <153292186147.13840.314584204805282590.stgit@noble>
Message-ID: <alpine.LFD.2.21.1808020410070.5677@casper.infradead.org>
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
>  drivers/staging/lustre/lustre/ldlm/ldlm_request.c |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
> index cdc52eed6d85..80260b07f0f0 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
> @@ -2000,7 +2000,7 @@ int ldlm_replay_locks(struct obd_import *imp)
>  {
>  	struct ldlm_namespace *ns = imp->imp_obd->obd_namespace;
>  	LIST_HEAD(list);
> -	struct ldlm_lock *lock, *next;
> +	struct ldlm_lock *lock;
>  	int rc = 0;
>  
>  	LASSERT(atomic_read(&imp->imp_replay_inflight) == 0);
> @@ -2017,7 +2017,9 @@ int ldlm_replay_locks(struct obd_import *imp)
>  
>  	ldlm_namespace_foreach(ns, ldlm_chain_lock_for_replay, &list);
>  
> -	list_for_each_entry_safe(lock, next, &list, l_pending_chain) {
> +	while (!list_empty(&list)) {
> +		lock = list_first_entry(&list, struct ldlm_lock,
> +					l_pending_chain);
>  		list_del_init(&lock->l_pending_chain);
>  		if (rc) {
>  			LDLM_LOCK_RELEASE(lock);
> 
> 
> 
