From: James Simmons <jsimmons@infradead.org>
Date: Thu, 2 Aug 2018 04:47:38 +0100 (BST)
Subject: [lustre-devel] [PATCH 6/7] lustre: lnet: convert ni_refs to
 percpu_refcount.
In-Reply-To: <153292257300.26496.12952743323721291033.stgit@noble>
References: <153292249340.26496.13985174182824912332.stgit@noble>
 <153292257300.26496.12952743323721291033.stgit@noble>
Message-ID: <alpine.LFD.2.21.1808020447280.5677@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> ni_refs is a per-cpt refcount.
> Linux already has a per-cpu refcount implementation
> which doesn't require anylocking.
> 
> So convert ni_refs to percpu_refcount.
> As a bonus, we can get a wake-up when the refcount
> reaches zero, rather than having to wait a full second.
> The waiting in lnet_clear_zombies_nis_locked() is
> modified so that instead of waiting one second each
> time, and printing a warning on power-of-two seconds,
> we wait an increasing power-of-two seconds and print
> a warning if the wait ever timed out.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/include/linux/lnet/lib-lnet.h   |   11 +-----
>  .../staging/lustre/include/linux/lnet/lib-types.h  |    2 +
>  drivers/staging/lustre/lnet/lnet/api-ni.c          |   34 +++++++++-----------
>  drivers/staging/lustre/lnet/lnet/config.c          |   13 +++++---
>  drivers/staging/lustre/lnet/lnet/router_proc.c     |    2 +
>  5 files changed, 28 insertions(+), 34 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> index 0fecf0d32c58..371002825a7d 100644
> --- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> +++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> @@ -338,34 +338,27 @@ static inline void
>  lnet_ni_addref_locked(struct lnet_ni *ni, int cpt)
>  {
>  	LASSERT(cpt >= 0 && cpt < LNET_CPT_NUMBER);
> -	LASSERT(*ni->ni_refs[cpt] >= 0);
> -
> -	(*ni->ni_refs[cpt])++;
> +	percpu_ref_get(&ni->ni_refs);
>  }
>  
>  static inline void
>  lnet_ni_addref(struct lnet_ni *ni)
>  {
> -	lnet_net_lock(0);
>  	lnet_ni_addref_locked(ni, 0);
> -	lnet_net_unlock(0);
>  }
>  
>  static inline void
>  lnet_ni_decref_locked(struct lnet_ni *ni, int cpt)
>  {
>  	LASSERT(cpt >= 0 && cpt < LNET_CPT_NUMBER);
> -	LASSERT(*ni->ni_refs[cpt] > 0);
>  
> -	(*ni->ni_refs[cpt])--;
> +	percpu_ref_put(&ni->ni_refs);
>  }
>  
>  static inline void
>  lnet_ni_decref(struct lnet_ni *ni)
>  {
> -	lnet_net_lock(0);
>  	lnet_ni_decref_locked(ni, 0);
> -	lnet_net_unlock(0);
>  }
>  
>  void lnet_ni_free(struct lnet_ni *ni);
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> index 6d4106fd9039..7527fef90cac 100644
> --- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
> +++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> @@ -269,7 +269,7 @@ struct lnet_ni {
>  	void			 *ni_data;	/* instance-specific data */
>  	struct lnet_lnd		 *ni_lnd;	/* procedural interface */
>  	struct lnet_tx_queue	**ni_tx_queues;	/* percpt TX queues */
> -	int			**ni_refs;	/* percpt reference count */
> +	struct percpu_ref	  ni_refs;
>  	time64_t		  ni_last_alive;/* when I was last alive */
>  	struct lnet_ni_status	 *ni_status;	/* my health status */
>  	/* per NI LND tunables */
> diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
> index cdbbe9cc8d95..fea03737439a 100644
> --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
> +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
> @@ -1055,7 +1055,7 @@ lnet_ni_unlink_locked(struct lnet_ni *ni)
>  	/* move it to zombie list and nobody can find it anymore */
>  	LASSERT(!list_empty(&ni->ni_list));
>  	list_move(&ni->ni_list, &the_lnet.ln_nis_zombie);
> -	lnet_ni_decref_locked(ni, 0);	/* drop ln_nis' ref */
> +	percpu_ref_kill_and_confirm(&ni->ni_refs, NULL);	/* drop ln_nis' ref */
>  }
>  
>  static void
> @@ -1069,34 +1069,32 @@ lnet_clear_zombies_nis_locked(void)
>  	 * Now wait for the NI's I just nuked to show up on ln_zombie_nis
>  	 * and shut them down in guaranteed thread context
>  	 */
> -	i = 2;
> +	i = 1;
>  	while (!list_empty(&the_lnet.ln_nis_zombie)) {
> -		int *ref;
> -		int j;
>  
>  		ni = list_entry(the_lnet.ln_nis_zombie.next,
>  				struct lnet_ni, ni_list);
> -		list_del_init(&ni->ni_list);
> -		cfs_percpt_for_each(ref, j, ni->ni_refs) {
> -			if (!*ref)
> -				continue;
> -			/* still busy, add it back to zombie list */
> -			list_add(&ni->ni_list, &the_lnet.ln_nis_zombie);
> -			break;
> -		}
>  
> -		if (!list_empty(&ni->ni_list)) {
> +		if (!percpu_ref_is_zero(&ni->ni_refs)) {
> +			/* still busy, wait a while */
> +
>  			lnet_net_unlock(LNET_LOCK_EX);
>  			++i;
> -			if ((i & (-i)) == i) {
> +
> +			if (wait_var_event_timeout(
> +				    &ni->ni_refs,
> +				    percpu_ref_is_zero(&ni->ni_refs),
> +				    HZ << i) == 0)
>  				CDEBUG(D_WARNING, "Waiting for zombie LNI %s\n",
>  				       libcfs_nid2str(ni->ni_nid));
> -			}
> +
>  			schedule_timeout_uninterruptible(HZ);
>  			lnet_net_lock(LNET_LOCK_EX);
>  			continue;
>  		}
>  
> +		list_del_init(&ni->ni_list);
> +
>  		ni->ni_lnd->lnd_refcount--;
>  		lnet_net_unlock(LNET_LOCK_EX);
>  
> @@ -1114,7 +1112,7 @@ lnet_clear_zombies_nis_locked(void)
>  			       libcfs_nid2str(ni->ni_nid));
>  
>  		lnet_ni_free(ni);
> -		i = 2;
> +		i = 1;
>  
>  		lnet_net_lock(LNET_LOCK_EX);
>  	}
> @@ -1305,8 +1303,8 @@ lnet_startup_lndni(struct lnet_ni *ni, struct lnet_ioctl_config_data *conf)
>  	LASSERT(ni->ni_peertimeout <= 0 || lnd->lnd_query);
>  
>  	lnet_net_lock(LNET_LOCK_EX);
> -	/* refcount for ln_nis */
> -	lnet_ni_addref_locked(ni, 0);
> +	/* Initialise refcount for ln_nis to 1 */
> +	percpu_ref_reinit(&ni->ni_refs);
>  	list_add_tail(&ni->ni_list, &the_lnet.ln_nis);
>  	if (ni->ni_cpts) {
>  		lnet_ni_addref_locked(ni, 0);
> diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
> index 091c4f714e84..4145c7431576 100644
> --- a/drivers/staging/lustre/lnet/lnet/config.c
> +++ b/drivers/staging/lustre/lnet/lnet/config.c
> @@ -96,8 +96,7 @@ lnet_ni_free(struct lnet_ni *ni)
>  {
>  	int i;
>  
> -	if (ni->ni_refs)
> -		cfs_percpt_free(ni->ni_refs);
> +	percpu_ref_exit(&ni->ni_refs);
>  
>  	if (ni->ni_tx_queues)
>  		cfs_percpt_free(ni->ni_tx_queues);
> @@ -117,6 +116,11 @@ lnet_ni_free(struct lnet_ni *ni)
>  	kfree(ni);
>  }
>  
> +static void ref_release(struct percpu_ref *ref)
> +{
> +	wake_up_var(ref);
> +}
> +
>  struct lnet_ni *
>  lnet_ni_alloc(__u32 net, struct cfs_expr_list *el, struct list_head *nilist)
>  {
> @@ -140,9 +144,8 @@ lnet_ni_alloc(__u32 net, struct cfs_expr_list *el, struct list_head *nilist)
>  
>  	spin_lock_init(&ni->ni_lock);
>  	INIT_LIST_HEAD(&ni->ni_cptlist);
> -	ni->ni_refs = cfs_percpt_alloc(lnet_cpt_table(),
> -				       sizeof(*ni->ni_refs[0]));
> -	if (!ni->ni_refs)
> +	if (percpu_ref_init(&ni->ni_refs, ref_release,
> +			    PERCPU_REF_INIT_DEAD, GFP_KERNEL) < 0)
>  		goto failed;
>  
>  	ni->ni_tx_queues = cfs_percpt_alloc(lnet_cpt_table(),
> diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
> index d779445fefb5..8856798d263f 100644
> --- a/drivers/staging/lustre/lnet/lnet/router_proc.c
> +++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
> @@ -703,7 +703,7 @@ static int proc_lnet_nis(struct ctl_table *table, int write,
>  				s += snprintf(s, tmpstr + tmpsiz - s,
>  					      "%-24s %6s %5lld %4d %4d %4d %5d %5d %5d\n",
>  					      libcfs_nid2str(ni->ni_nid), stat,
> -					      last_alive, *ni->ni_refs[i],
> +					      last_alive, 0/* No per-cpt refcount */,
>  					      ni->ni_peertxcredits,
>  					      ni->ni_peerrtrcredits,
>  					      tq->tq_credits_max,
> 
> 
> 
