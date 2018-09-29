From: James Simmons <jsimmons@infradead.org>
Date: Sun, 30 Sep 2018 00:01:38 +0100 (BST)
Subject: [lustre-devel] [PATCH 08/34] LU-7734 lnet: Multi-Rail peer split
In-Reply-To: <153783763514.32103.5823547209878409504.stgit@noble>
References: <153783752960.32103.8394391715843917125.stgit@noble>
 <153783763514.32103.5823547209878409504.stgit@noble>
Message-ID: <alpine.LFD.2.21.1809292354290.25547@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, 25 Sep 2018, NeilBrown wrote:

> From: Amir Shehata <amir.shehata@intel.com>
> 
> [[Note, the preceding few patches are part of this
>   in the upstream lustre code - they were split
>   for easier merging into linux.
>   ]]
> 
> Split the peer structure into peer/peer_net/peer_ni, as
> described in the Multi-Rail HLD.
> 
> Removed deathrow list in peers, instead peers are immediately
> deleted. deathrow complicates memory management for peers to
> little gain.
> 
> Moved to LNET_LOCK_EX for any operations which will modify the
> peer tables. And CPT locks for any operatios which read the peer
> tables. Therefore there is no need to use lnet_cpt_of_nid() to
> calculate the CPT of the peer NID, instead we use lnet_nid_cpt_hash()
> to distribute peers across multiple CPTs.
> 
> It is no longe true that peers and NIs would exist on
> the same CPT. In the new design peers and NIs don't have a 1-1
> relationship. You can send to the same peer from several NIs, which
> can exist on separate CPTs
> 
> Signed-off-by: Amir Shehata <amir.shehata@intel.com>
> Change-Id: Ida41d830d38d0ab2bb551476e4a8866d52a25fe2
> Reviewed-on: http://review.whamcloud.com/18293
> Reviewed-by: Olaf Weber <olaf@sgi.com>
> Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
> Signed-off-by: NeilBrown <neilb@suse.com>

The patch is fine but the commit message needs to be properly formatted.
While patches to OpenSFS tree are titled with "LU-7743 lnet:" for the
linux client we changed that to be more inline with what the kernel does.

LU-7734 lnet: Multi-Rail peer split  --->>> lustre: lnet: Multi-Rail peer split

To the outsider reviewer LU-7734 doesn't mean much. Also please replace
Change-Id: to the URL link for the work which in turn explains LU-7734.

WC-bug-id: https://jira.whamcloud.com/browse/LU-7734

Same for the other patches this series. Seem reasonable?

> ---
>  .../staging/lustre/include/linux/lnet/lib-lnet.h   |    2 
>  .../staging/lustre/include/linux/lnet/lib-types.h  |   29 ++
>  drivers/staging/lustre/lnet/lnet/api-ni.c          |    1 
>  drivers/staging/lustre/lnet/lnet/peer.c            |  260 ++++++++++++--------
>  drivers/staging/lustre/lnet/lnet/router_proc.c     |    3 
>  5 files changed, 191 insertions(+), 104 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> index 656177b64336..bf076298de71 100644
> --- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> +++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> @@ -637,8 +637,6 @@ bool lnet_net_unique(__u32 net_id, struct list_head *nilist,
>  bool lnet_ni_unique_net(struct list_head *nilist, char *iface);
>  
>  int lnet_nid2peerni_locked(struct lnet_peer_ni **lpp, lnet_nid_t nid, int cpt);
> -struct lnet_peer_ni *lnet_find_peer_locked(struct lnet_peer_table *ptable,
> -					   lnet_nid_t nid);
>  struct lnet_peer_ni *lnet_find_peer_ni_locked(lnet_nid_t nid, int cpt);
>  void lnet_peer_tables_cleanup(struct lnet_ni *ni);
>  void lnet_peer_tables_destroy(void);
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> index 9a2cf319dba9..9f70c094cc4c 100644
> --- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
> +++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> @@ -384,6 +384,7 @@ struct lnet_rc_data {
>  };
>  
>  struct lnet_peer_ni {
> +	struct list_head	lpni_on_peer_net_list;
>  	/* chain on peer hash */
>  	struct list_head	 lpni_hashlist;
>  	/* messages blocking for tx credits */
> @@ -394,6 +395,7 @@ struct lnet_peer_ni {
>  	struct list_head	 lpni_rtr_list;
>  	/* # tx credits available */
>  	int			 lpni_txcredits;
> +	struct lnet_peer_net	*lpni_peer_net;
>  	/* low water mark */
>  	int			 lpni_mintxcredits;
>  	/* # router credits */
> @@ -442,6 +444,31 @@ struct lnet_peer_ni {
>  	struct lnet_rc_data	*lpni_rcd;
>  };
>  
> +struct lnet_peer {
> +	/* chain on global peer list */
> +	struct list_head	lp_on_lnet_peer_list;
> +
> +	/* list of peer nets */
> +	struct list_head	lp_peer_nets;
> +
> +	/* primary NID of the peer */
> +	lnet_nid_t		lp_primary_nid;
> +};
> +
> +struct lnet_peer_net {
> +	/* chain on peer block */
> +	struct list_head	lpn_on_peer_list;
> +
> +	/* list of peer_nis on this network */
> +	struct list_head	lpn_peer_nis;
> +
> +	/* pointer to the peer I'm part of */
> +	struct lnet_peer	*lpn_peer;
> +
> +	/* Net ID */
> +	__u32			lpn_net_id;
> +};
> +
>  /* peer hash size */
>  #define LNET_PEER_HASH_BITS	9
>  #define LNET_PEER_HASH_SIZE	(1 << LNET_PEER_HASH_BITS)
> @@ -686,6 +713,8 @@ struct lnet {
>  	struct lnet_msg_container	**ln_msg_containers;
>  	struct lnet_counters		**ln_counters;
>  	struct lnet_peer_table		**ln_peer_tables;
> +	/* list of configured or discovered peers */
> +	struct list_head		ln_peers;
>  	/* failure simulation */
>  	struct list_head		  ln_test_peers;
>  	struct list_head		  ln_drop_rules;
> diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
> index 20fa3fea04b9..821b030f9621 100644
> --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
> +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
> @@ -542,6 +542,7 @@ lnet_prepare(lnet_pid_t requested_pid)
>  	the_lnet.ln_pid = requested_pid;
>  
>  	INIT_LIST_HEAD(&the_lnet.ln_test_peers);
> +	INIT_LIST_HEAD(&the_lnet.ln_peers);
>  	INIT_LIST_HEAD(&the_lnet.ln_nets);
>  	INIT_LIST_HEAD(&the_lnet.ln_routers);
>  	INIT_LIST_HEAD(&the_lnet.ln_drop_rules);
> diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
> index 376e3459fa92..97ee1f5cfd2f 100644
> --- a/drivers/staging/lustre/lnet/lnet/peer.c
> +++ b/drivers/staging/lustre/lnet/lnet/peer.c
> @@ -54,8 +54,6 @@ lnet_peer_tables_create(void)
>  	}
>  
>  	cfs_percpt_for_each(ptable, i, the_lnet.ln_peer_tables) {
> -		INIT_LIST_HEAD(&ptable->pt_deathrow);
> -
>  		hash = kvmalloc_cpt(LNET_PEER_HASH_SIZE * sizeof(*hash),
>  				    GFP_KERNEL, i);
>  		if (!hash) {
> @@ -88,8 +86,6 @@ lnet_peer_tables_destroy(void)
>  		if (!hash) /* not initialized */
>  			break;
>  
> -		LASSERT(list_empty(&ptable->pt_deathrow));
> -
>  		ptable->pt_hash = NULL;
>  		for (j = 0; j < LNET_PEER_HASH_SIZE; j++)
>  			LASSERT(list_empty(&hash[j]));
> @@ -123,7 +119,7 @@ lnet_peer_table_cleanup_locked(struct lnet_ni *ni,
>  }
>  
>  static void
> -lnet_peer_table_deathrow_wait_locked(struct lnet_peer_table *ptable,
> +lnet_peer_table_finalize_wait_locked(struct lnet_peer_table *ptable,
>  				     int cpt_locked)
>  {
>  	int i;
> @@ -173,12 +169,8 @@ void
>  lnet_peer_tables_cleanup(struct lnet_ni *ni)
>  {
>  	struct lnet_peer_table *ptable;
> -	struct list_head deathrow;
> -	struct lnet_peer_ni *lp;
>  	int i;
>  
> -	INIT_LIST_HEAD(&deathrow);
> -
>  	LASSERT(the_lnet.ln_shutdown || ni);
>  	/*
>  	 * If just deleting the peers for a NI, get rid of any routes these
> @@ -191,8 +183,7 @@ lnet_peer_tables_cleanup(struct lnet_ni *ni)
>  	}
>  
>  	/*
> -	 * Start the process of moving the applicable peers to
> -	 * deathrow.
> +	 * Start the cleanup process
>  	 */
>  	cfs_percpt_for_each(ptable, i, the_lnet.ln_peer_tables) {
>  		lnet_net_lock(LNET_LOCK_EX);
> @@ -200,20 +191,12 @@ lnet_peer_tables_cleanup(struct lnet_ni *ni)
>  		lnet_net_unlock(LNET_LOCK_EX);
>  	}
>  
> -	/* Cleanup all entries on deathrow. */
> +	/* Wait until all peers have been destroyed. */
>  	cfs_percpt_for_each(ptable, i, the_lnet.ln_peer_tables) {
>  		lnet_net_lock(LNET_LOCK_EX);
> -		lnet_peer_table_deathrow_wait_locked(ptable, i);
> -		list_splice_init(&ptable->pt_deathrow, &deathrow);
> +		lnet_peer_table_finalize_wait_locked(ptable, i);
>  		lnet_net_unlock(LNET_LOCK_EX);
>  	}
> -
> -	while (!list_empty(&deathrow)) {
> -		lp = list_entry(deathrow.next, struct lnet_peer_ni,
> -				lpni_hashlist);
> -		list_del(&lp->lpni_hashlist);
> -		kfree(lp);
> -	}
>  }
>  
>  static struct lnet_peer_ni *
> @@ -247,74 +230,143 @@ lnet_find_peer_ni_locked(lnet_nid_t nid, int cpt)
>  	return lpni;
>  }
>  
> -void
> -lnet_destroy_peer_ni_locked(struct lnet_peer_ni *lp)
> +static void
> +lnet_try_destroy_peer_hierarchy_locked(struct lnet_peer_ni *lpni)
>  {
> -	struct lnet_peer_table *ptable;
> +	struct lnet_peer_net *peer_net;
> +	struct lnet_peer *peer;
>  
> -	LASSERT(atomic_read(&lp->lpni_refcount) == 0);
> -	LASSERT(!lp->lpni_rtr_refcount);
> -	LASSERT(list_empty(&lp->lpni_txq));
> -	LASSERT(list_empty(&lp->lpni_hashlist));
> -	LASSERT(!lp->lpni_txqnob);
> +	/* TODO: could the below situation happen? accessing an already
> +	 * destroyed peer?
> +	 */
> +	if (!lpni->lpni_peer_net ||
> +	    !lpni->lpni_peer_net->lpn_peer)
> +		return;
>  
> -	ptable = the_lnet.ln_peer_tables[lp->lpni_cpt];
> -	LASSERT(ptable->pt_number > 0);
> -	ptable->pt_number--;
> +	peer_net = lpni->lpni_peer_net;
> +	peer = lpni->lpni_peer_net->lpn_peer;
>  
> -	lp->lpni_net = NULL;
> +	list_del_init(&lpni->lpni_on_peer_net_list);
> +	lpni->lpni_peer_net = NULL;
>  
> -	list_add(&lp->lpni_hashlist, &ptable->pt_deathrow);
> -	LASSERT(ptable->pt_zombies > 0);
> -	ptable->pt_zombies--;
> +	/* if peer_net is empty, then remove it from the peer */
> +	if (list_empty(&peer_net->lpn_peer_nis)) {
> +		list_del_init(&peer_net->lpn_on_peer_list);
> +		peer_net->lpn_peer = NULL;
> +		kfree(peer_net);
> +
> +		/* If the peer is empty then remove it from the
> +		 * the_lnet.ln_peers
> +		 */
> +		if (list_empty(&peer->lp_peer_nets)) {
> +			list_del_init(&peer->lp_on_lnet_peer_list);
> +			kfree(peer);
> +		}
> +	}
>  }
>  
> -struct lnet_peer_ni *
> -lnet_find_peer_locked(struct lnet_peer_table *ptable, lnet_nid_t nid)
> +static int
> +lnet_build_peer_hierarchy(struct lnet_peer_ni *lpni)
>  {
> -	struct list_head *peers;
> -	struct lnet_peer_ni *lp;
> +	struct lnet_peer *peer;
> +	struct lnet_peer_net *peer_net;
> +	__u32 lpni_net = LNET_NIDNET(lpni->lpni_nid);
>  
> -	LASSERT(!the_lnet.ln_shutdown);
> +	peer = NULL;
> +	peer_net = NULL;
>  
> -	peers = &ptable->pt_hash[lnet_nid2peerhash(nid)];
> -	list_for_each_entry(lp, peers, lpni_hashlist) {
> -		if (lp->lpni_nid == nid) {
> -			lnet_peer_ni_addref_locked(lp);
> -			return lp;
> -		}
> +	peer = kzalloc(sizeof(*peer), GFP_KERNEL);
> +	if (!peer)
> +		return -ENOMEM;
> +
> +	peer_net = kzalloc(sizeof(*peer_net), GFP_KERNEL);
> +	if (!peer_net) {
> +		kfree(peer);
> +		return -ENOMEM;
>  	}
>  
> -	return NULL;
> +	INIT_LIST_HEAD(&peer->lp_on_lnet_peer_list);
> +	INIT_LIST_HEAD(&peer->lp_peer_nets);
> +	INIT_LIST_HEAD(&peer_net->lpn_on_peer_list);
> +	INIT_LIST_HEAD(&peer_net->lpn_peer_nis);
> +
> +	/* build the hierarchy */
> +	peer_net->lpn_net_id = lpni_net;
> +	peer_net->lpn_peer = peer;
> +	lpni->lpni_peer_net = peer_net;
> +	peer->lp_primary_nid = lpni->lpni_nid;
> +	list_add_tail(&peer_net->lpn_on_peer_list, &peer->lp_peer_nets);
> +	list_add_tail(&lpni->lpni_on_peer_net_list, &peer_net->lpn_peer_nis);
> +	list_add_tail(&peer->lp_on_lnet_peer_list, &the_lnet.ln_peers);
> +
> +	return 0;
> +}
> +
> +void
> +lnet_destroy_peer_ni_locked(struct lnet_peer_ni *lpni)
> +{
> +	struct lnet_peer_table *ptable;
> +
> +	LASSERT(atomic_read(&lpni->lpni_refcount) == 0);
> +	LASSERT(lpni->lpni_rtr_refcount == 0);
> +	LASSERT(list_empty(&lpni->lpni_txq));
> +	LASSERT(list_empty(&lpni->lpni_hashlist));
> +	LASSERT(lpni->lpni_txqnob == 0);
> +	LASSERT(lpni->lpni_peer_net);
> +	LASSERT(lpni->lpni_peer_net->lpn_peer);
> +
> +	ptable = the_lnet.ln_peer_tables[lpni->lpni_cpt];
> +	LASSERT(ptable->pt_number > 0);
> +	ptable->pt_number--;
> +
> +	lpni->lpni_net = NULL;
> +
> +	lnet_try_destroy_peer_hierarchy_locked(lpni);
> +
> +	kfree(lpni);
> +
> +	LASSERT(ptable->pt_zombies > 0);
> +	ptable->pt_zombies--;
>  }
>  
>  int
> -lnet_nid2peerni_locked(struct lnet_peer_ni **lpp, lnet_nid_t nid, int cpt)
> +lnet_nid2peerni_locked(struct lnet_peer_ni **lpnip, lnet_nid_t nid, int cpt)
>  {
>  	struct lnet_peer_table *ptable;
> -	struct lnet_peer_ni *lp = NULL;
> -	struct lnet_peer_ni *lp2;
> +	struct lnet_peer_ni *lpni = NULL;
> +	struct lnet_peer_ni *lpni2;
>  	int cpt2;
>  	int rc = 0;
>  
> -	*lpp = NULL;
> +	*lpnip = NULL;
>  	if (the_lnet.ln_shutdown) /* it's shutting down */
>  		return -ESHUTDOWN;
>  
> -	/* cpt can be LNET_LOCK_EX if it's called from router functions */
> -	cpt2 = cpt != LNET_LOCK_EX ? cpt : lnet_cpt_of_nid_locked(nid, NULL);
> +	/*
> +	 * calculate cpt2 with the standard hash function
> +	 * This cpt2 becomes the slot where we'll find or create the peer.
> +	 */
> +	cpt2 = lnet_nid_cpt_hash(nid, LNET_CPT_NUMBER);
>  
> -	ptable = the_lnet.ln_peer_tables[cpt2];
> -	lp = lnet_find_peer_locked(ptable, nid);
> -	if (lp) {
> -		*lpp = lp;
> -		return 0;
> +	/*
> +	 * Any changes to the peer tables happen under exclusive write
> +	 * lock. Any reads to the peer tables can be done via a standard
> +	 * CPT read lock.
> +	 */
> +	if (cpt != LNET_LOCK_EX) {
> +		lnet_net_unlock(cpt);
> +		lnet_net_lock(LNET_LOCK_EX);
>  	}
>  
> -	if (!list_empty(&ptable->pt_deathrow)) {
> -		lp = list_entry(ptable->pt_deathrow.next,
> -				struct lnet_peer_ni, lpni_hashlist);
> -		list_del(&lp->lpni_hashlist);
> +	ptable = the_lnet.ln_peer_tables[cpt2];
> +	lpni = lnet_get_peer_ni_locked(ptable, nid);
> +	if (lpni) {
> +		*lpnip = lpni;
> +		if (cpt != LNET_LOCK_EX) {
> +			lnet_net_unlock(LNET_LOCK_EX);
> +			lnet_net_lock(cpt);
> +		}
> +		return 0;
>  	}
>  
>  	/*
> @@ -322,68 +374,72 @@ lnet_nid2peerni_locked(struct lnet_peer_ni **lpp, lnet_nid_t nid, int cpt)
>  	 * and destroyed locks and peer-table before I finish the allocation
>  	 */
>  	ptable->pt_number++;
> -	lnet_net_unlock(cpt);
> +	lnet_net_unlock(LNET_LOCK_EX);
>  
> -	if (lp)
> -		memset(lp, 0, sizeof(*lp));
> -	else
> -		lp = kzalloc_cpt(sizeof(*lp), GFP_NOFS, cpt2);
> -
> -	if (!lp) {
> +	lpni = kzalloc_cpt(sizeof(*lpni), GFP_KERNEL, cpt2);
> +	if (!lpni) {
>  		rc = -ENOMEM;
>  		lnet_net_lock(cpt);
>  		goto out;
>  	}
>  
> -	INIT_LIST_HEAD(&lp->lpni_txq);
> -	INIT_LIST_HEAD(&lp->lpni_rtrq);
> -	INIT_LIST_HEAD(&lp->lpni_routes);
> -
> -	lp->lpni_notify = 0;
> -	lp->lpni_notifylnd = 0;
> -	lp->lpni_notifying = 0;
> -	lp->lpni_alive_count = 0;
> -	lp->lpni_timestamp = 0;
> -	lp->lpni_alive = !lnet_peers_start_down(); /* 1 bit!! */
> -	lp->lpni_last_alive = ktime_get_seconds(); /* assumes alive */
> -	lp->lpni_last_query = 0; /* haven't asked NI yet */
> -	lp->lpni_ping_timestamp = 0;
> -	lp->lpni_ping_feats = LNET_PING_FEAT_INVAL;
> -	lp->lpni_nid = nid;
> -	lp->lpni_cpt = cpt2;
> -	atomic_set(&lp->lpni_refcount, 2);	/* 1 for caller; 1 for hash */
> -	lp->lpni_rtr_refcount = 0;
> +	INIT_LIST_HEAD(&lpni->lpni_txq);
> +	INIT_LIST_HEAD(&lpni->lpni_rtrq);
> +	INIT_LIST_HEAD(&lpni->lpni_routes);
>  
> -	lnet_net_lock(cpt);
> +	lpni->lpni_alive = !lnet_peers_start_down(); /* 1 bit!! */
> +	lpni->lpni_last_alive = ktime_get_seconds(); /* assumes alive */
> +	lpni->lpni_ping_feats = LNET_PING_FEAT_INVAL;
> +	lpni->lpni_nid = nid;
> +	lpni->lpni_cpt = cpt2;
> +	atomic_set(&lpni->lpni_refcount, 2);	/* 1 for caller; 1 for hash */
> +
> +	rc = lnet_build_peer_hierarchy(lpni);
> +	if (rc != 0)
> +		goto out;
> +
> +	lnet_net_lock(LNET_LOCK_EX);
>  
>  	if (the_lnet.ln_shutdown) {
>  		rc = -ESHUTDOWN;
>  		goto out;
>  	}
>  
> -	lp2 = lnet_find_peer_locked(ptable, nid);
> -	if (lp2) {
> -		*lpp = lp2;
> +	lpni2 = lnet_get_peer_ni_locked(ptable, nid);
> +	if (lpni2) {
> +		*lpnip = lpni2;
>  		goto out;
>  	}
>  
> -	lp->lpni_net = lnet_get_net_locked(LNET_NIDNET(lp->lpni_nid));
> -	lp->lpni_txcredits =
> -		lp->lpni_mintxcredits =
> -		lp->lpni_net->net_tunables.lct_peer_tx_credits;
> -	lp->lpni_rtrcredits =
> -		lp->lpni_minrtrcredits = lnet_peer_buffer_credits(lp->lpni_net);
> +	lpni->lpni_net = lnet_get_net_locked(LNET_NIDNET(lpni->lpni_nid));
> +	lpni->lpni_txcredits =
> +		lpni->lpni_mintxcredits =
> +		lpni->lpni_net->net_tunables.lct_peer_tx_credits;
> +	lpni->lpni_rtrcredits =
> +		lpni->lpni_minrtrcredits =
> +		lnet_peer_buffer_credits(lpni->lpni_net);
>  
> -	list_add_tail(&lp->lpni_hashlist,
> +	list_add_tail(&lpni->lpni_hashlist,
>  		      &ptable->pt_hash[lnet_nid2peerhash(nid)]);
>  	ptable->pt_version++;
> -	*lpp = lp;
> +	*lpnip = lpni;
> +
> +	if (cpt != LNET_LOCK_EX) {
> +		lnet_net_unlock(LNET_LOCK_EX);
> +		lnet_net_lock(cpt);
> +	}
>  
>  	return 0;
>  out:
> -	if (lp)
> -		list_add(&lp->lpni_hashlist, &ptable->pt_deathrow);
> +	if (lpni) {
> +		lnet_try_destroy_peer_hierarchy_locked(lpni);
> +		kfree(lpni);
> +	}
>  	ptable->pt_number--;
> +	if (cpt != LNET_LOCK_EX) {
> +		lnet_net_unlock(LNET_LOCK_EX);
> +		lnet_net_lock(cpt);
> +	}
>  	return rc;
>  }
>  
> diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
> index 12a4b1708d3c..977a937f261c 100644
> --- a/drivers/staging/lustre/lnet/lnet/router_proc.c
> +++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
> @@ -385,6 +385,9 @@ static int proc_lnet_routers(struct ctl_table *table, int write,
>  	return rc;
>  }
>  
> +/* TODO: there should be no direct access to ptable. We should add a set
> + * of APIs that give access to the ptable and its members
> + */
>  static int proc_lnet_peers(struct ctl_table *table, int write,
>  			   void __user *buffer, size_t *lenp, loff_t *ppos)
>  {
> 
> 
> 
