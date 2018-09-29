From: James Simmons <jsimmons@infradead.org>
Date: Sat, 29 Sep 2018 23:47:58 +0100 (BST)
Subject: [lustre-devel] [PATCH 04/34] lnet: change some function names -
 add 'ni'.
In-Reply-To: <153783763501.32103.12514510583840060159.stgit@noble>
References: <153783752960.32103.8394391715843917125.stgit@noble>
 <153783763501.32103.12514510583840060159.stgit@noble>
Message-ID: <alpine.LFD.2.21.1809292347470.25547@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> sed -i 's/lnet_peer_addref_locked/lnet_peer_ni_addref_locked/g' `git grep -l lnet_peer_addref_locked lnet/`
> sed -i 's/lnet_destroy_peer_locked/lnet_destroy_peer_ni_locked/g' `git grep -l lnet_destroy_peer_locked lnet/`
> sed -i 's/lnet_peer_decref_locked/lnet_peer_ni_decref_locked/g' `git grep -l lnet_peer_decref_locked lnet/`
> sed -i 's/lnet_nid2peer_locked/lnet_nid2peerni_locked/g' `git grep -l lnet_nid2peer_locked lnet/`
> 
> This is part of
>     Commit: 58091af960fe ("LU-7734 lnet: Multi-Rail peer split")
> from upstream lustre, where it is marked:
>     Signed-off-by: Amir Shehata <amir.shehata@intel.com>
>     WC-bug-id: https://jira.whamcloud.com/browse/LU-7734
>     Reviewed-on: http://review.whamcloud.com/18293
>     Reviewed-by: Olaf Weber <olaf@sgi.com>
>     Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/include/linux/lnet/lib-lnet.h   |   10 ++++----
>  drivers/staging/lustre/lnet/lnet/lib-move.c        |   10 ++++----
>  drivers/staging/lustre/lnet/lnet/peer.c            |   12 +++++-----
>  drivers/staging/lustre/lnet/lnet/router.c          |   24 ++++++++++----------
>  4 files changed, 28 insertions(+), 28 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> index 88e010aa3f68..a1c581069eb1 100644
> --- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> +++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> @@ -311,21 +311,21 @@ lnet_handle2me(struct lnet_handle_me *handle)
>  }
>  
>  static inline void
> -lnet_peer_addref_locked(struct lnet_peer_ni *lp)
> +lnet_peer_ni_addref_locked(struct lnet_peer_ni *lp)
>  {
>  	LASSERT(atomic_read(&lp->lpni_refcount) > 0);
>  	atomic_inc(&lp->lpni_refcount);
>  }
>  
> -void lnet_destroy_peer_locked(struct lnet_peer_ni *lp);
> +void lnet_destroy_peer_ni_locked(struct lnet_peer_ni *lp);
>  
>  static inline void
> -lnet_peer_decref_locked(struct lnet_peer_ni *lp)
> +lnet_peer_ni_decref_locked(struct lnet_peer_ni *lp)
>  {
>  	LASSERT(atomic_read(&lp->lpni_refcount) > 0);
>  	atomic_dec(&lp->lpni_refcount);
>  	if (atomic_read(&lp->lpni_refcount) == 0)
> -		lnet_destroy_peer_locked(lp);
> +		lnet_destroy_peer_ni_locked(lp);
>  }
>  
>  static inline int
> @@ -635,7 +635,7 @@ bool lnet_net_unique(__u32 net_id, struct list_head *nilist,
>  		     struct lnet_net **net);
>  bool lnet_ni_unique_net(struct list_head *nilist, char *iface);
>  
> -int lnet_nid2peer_locked(struct lnet_peer_ni **lpp, lnet_nid_t nid, int cpt);
> +int lnet_nid2peerni_locked(struct lnet_peer_ni **lpp, lnet_nid_t nid, int cpt);
>  struct lnet_peer_ni *lnet_find_peer_locked(struct lnet_peer_table *ptable,
>  					   lnet_nid_t nid);
>  void lnet_peer_tables_cleanup(struct lnet_ni *ni);
> diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
> index 4425406e441b..edbec7e9ed7e 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-move.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
> @@ -837,7 +837,7 @@ lnet_return_tx_credits_locked(struct lnet_msg *msg)
>  
>  	if (txpeer) {
>  		msg->msg_txpeer = NULL;
> -		lnet_peer_decref_locked(txpeer);
> +		lnet_peer_ni_decref_locked(txpeer);
>  	}
>  }
>  
> @@ -964,7 +964,7 @@ lnet_return_rx_credits_locked(struct lnet_msg *msg)
>  	}
>  	if (rxpeer) {
>  		msg->msg_rxpeer = NULL;
> -		lnet_peer_decref_locked(rxpeer);
> +		lnet_peer_ni_decref_locked(rxpeer);
>  	}
>  }
>  
> @@ -1148,7 +1148,7 @@ lnet_send(lnet_nid_t src_nid, struct lnet_msg *msg, lnet_nid_t rtr_nid)
>  			return 0;
>  		}
>  
> -		rc = lnet_nid2peer_locked(&lp, dst_nid, cpt);
> +		rc = lnet_nid2peerni_locked(&lp, dst_nid, cpt);
>  		if (rc) {
>  			lnet_net_unlock(cpt);
>  			LCONSOLE_WARN("Error %d finding peer %s\n", rc,
> @@ -1199,7 +1199,7 @@ lnet_send(lnet_nid_t src_nid, struct lnet_msg *msg, lnet_nid_t rtr_nid)
>  			LASSERT(src_ni->ni_net == lp->lpni_net);
>  		}
>  
> -		lnet_peer_addref_locked(lp);
> +		lnet_peer_ni_addref_locked(lp);
>  
>  		LASSERT(src_nid != LNET_NID_ANY);
>  		lnet_msg_commit(msg, cpt);
> @@ -1810,7 +1810,7 @@ lnet_parse(struct lnet_ni *ni, struct lnet_hdr *hdr, lnet_nid_t from_nid,
>  	}
>  
>  	lnet_net_lock(cpt);
> -	rc = lnet_nid2peer_locked(&msg->msg_rxpeer, from_nid, cpt);
> +	rc = lnet_nid2peerni_locked(&msg->msg_rxpeer, from_nid, cpt);
>  	if (rc) {
>  		lnet_net_unlock(cpt);
>  		CERROR("%s, src %s: Dropping %s (error %d looking up sender)\n",
> diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
> index 7475678ea184..fcfad77b9f2c 100644
> --- a/drivers/staging/lustre/lnet/lnet/peer.c
> +++ b/drivers/staging/lustre/lnet/lnet/peer.c
> @@ -117,7 +117,7 @@ lnet_peer_table_cleanup_locked(struct lnet_ni *ni,
>  			list_del_init(&lp->lpni_hashlist);
>  			/* Lose hash table's ref */
>  			ptable->pt_zombies++;
> -			lnet_peer_decref_locked(lp);
> +			lnet_peer_ni_decref_locked(lp);
>  		}
>  	}
>  }
> @@ -217,7 +217,7 @@ lnet_peer_tables_cleanup(struct lnet_ni *ni)
>  }
>  
>  void
> -lnet_destroy_peer_locked(struct lnet_peer_ni *lp)
> +lnet_destroy_peer_ni_locked(struct lnet_peer_ni *lp)
>  {
>  	struct lnet_peer_table *ptable;
>  
> @@ -249,7 +249,7 @@ lnet_find_peer_locked(struct lnet_peer_table *ptable, lnet_nid_t nid)
>  	peers = &ptable->pt_hash[lnet_nid2peerhash(nid)];
>  	list_for_each_entry(lp, peers, lpni_hashlist) {
>  		if (lp->lpni_nid == nid) {
> -			lnet_peer_addref_locked(lp);
> +			lnet_peer_ni_addref_locked(lp);
>  			return lp;
>  		}
>  	}
> @@ -258,7 +258,7 @@ lnet_find_peer_locked(struct lnet_peer_table *ptable, lnet_nid_t nid)
>  }
>  
>  int
> -lnet_nid2peer_locked(struct lnet_peer_ni **lpp, lnet_nid_t nid, int cpt)
> +lnet_nid2peerni_locked(struct lnet_peer_ni **lpp, lnet_nid_t nid, int cpt)
>  {
>  	struct lnet_peer_table *ptable;
>  	struct lnet_peer_ni *lp = NULL;
> @@ -367,7 +367,7 @@ lnet_debug_peer(lnet_nid_t nid)
>  	cpt = lnet_cpt_of_nid(nid, NULL);
>  	lnet_net_lock(cpt);
>  
> -	rc = lnet_nid2peer_locked(&lp, nid, cpt);
> +	rc = lnet_nid2peerni_locked(&lp, nid, cpt);
>  	if (rc) {
>  		lnet_net_unlock(cpt);
>  		CDEBUG(D_WARNING, "No peer %s\n", libcfs_nid2str(nid));
> @@ -383,7 +383,7 @@ lnet_debug_peer(lnet_nid_t nid)
>  	       lp->lpni_rtrcredits, lp->lpni_minrtrcredits,
>  	       lp->lpni_txcredits, lp->lpni_mintxcredits, lp->lpni_txqnob);
>  
> -	lnet_peer_decref_locked(lp);
> +	lnet_peer_ni_decref_locked(lp);
>  
>  	lnet_net_unlock(cpt);
>  }
> diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
> index bfd4b22cc28a..ba2b2b930576 100644
> --- a/drivers/staging/lustre/lnet/lnet/router.c
> +++ b/drivers/staging/lustre/lnet/lnet/router.c
> @@ -192,7 +192,7 @@ lnet_rtr_addref_locked(struct lnet_peer_ni *lp)
>  
>  		list_add(&lp->lpni_rtr_list, pos);
>  		/* addref for the_lnet.ln_routers */
> -		lnet_peer_addref_locked(lp);
> +		lnet_peer_ni_addref_locked(lp);
>  		the_lnet.ln_routers_version++;
>  	}
>  }
> @@ -216,7 +216,7 @@ lnet_rtr_decref_locked(struct lnet_peer_ni *lp)
>  
>  		list_del(&lp->lpni_rtr_list);
>  		/* decref for the_lnet.ln_routers */
> -		lnet_peer_decref_locked(lp);
> +		lnet_peer_ni_decref_locked(lp);
>  		the_lnet.ln_routers_version++;
>  	}
>  }
> @@ -332,7 +332,7 @@ lnet_add_route(__u32 net, __u32 hops, lnet_nid_t gateway,
>  
>  	lnet_net_lock(LNET_LOCK_EX);
>  
> -	rc = lnet_nid2peer_locked(&route->lr_gateway, gateway, LNET_LOCK_EX);
> +	rc = lnet_nid2peerni_locked(&route->lr_gateway, gateway, LNET_LOCK_EX);
>  	if (rc) {
>  		lnet_net_unlock(LNET_LOCK_EX);
>  
> @@ -370,7 +370,7 @@ lnet_add_route(__u32 net, __u32 hops, lnet_nid_t gateway,
>  	}
>  
>  	if (add_route) {
> -		lnet_peer_addref_locked(route->lr_gateway); /* +1 for notify */
> +		lnet_peer_ni_addref_locked(route->lr_gateway); /* +1 for notify */
>  		lnet_add_route_to_rnet(rnet2, route);
>  
>  		ni = lnet_get_next_ni_locked(route->lr_gateway->lpni_net, NULL);
> @@ -384,7 +384,7 @@ lnet_add_route(__u32 net, __u32 hops, lnet_nid_t gateway,
>  	}
>  
>  	/* -1 for notify or !add_route */
> -	lnet_peer_decref_locked(route->lr_gateway);
> +	lnet_peer_ni_decref_locked(route->lr_gateway);
>  	lnet_net_unlock(LNET_LOCK_EX);
>  	rc = 0;
>  
> @@ -496,7 +496,7 @@ lnet_del_route(__u32 net, lnet_nid_t gw_nid)
>  				rnet = NULL;
>  
>  			lnet_rtr_decref_locked(gateway);
> -			lnet_peer_decref_locked(gateway);
> +			lnet_peer_ni_decref_locked(gateway);
>  
>  			lnet_net_unlock(LNET_LOCK_EX);
>  
> @@ -854,7 +854,7 @@ lnet_destroy_rc_data(struct lnet_rc_data *rcd)
>  		int cpt = rcd->rcd_gateway->lpni_cpt;
>  
>  		lnet_net_lock(cpt);
> -		lnet_peer_decref_locked(rcd->rcd_gateway);
> +		lnet_peer_ni_decref_locked(rcd->rcd_gateway);
>  		lnet_net_unlock(cpt);
>  	}
>  
> @@ -913,7 +913,7 @@ lnet_create_rc_data_locked(struct lnet_peer_ni *gateway)
>  		goto out;
>  	}
>  
> -	lnet_peer_addref_locked(gateway);
> +	lnet_peer_ni_addref_locked(gateway);
>  	rcd->rcd_gateway = gateway;
>  	gateway->lpni_rcd = rcd;
>  	gateway->lpni_ping_notsent = 0;
> @@ -954,7 +954,7 @@ lnet_ping_router_locked(struct lnet_peer_ni *rtr)
>  	time64_t secs;
>  	struct lnet_ni *ni;
>  
> -	lnet_peer_addref_locked(rtr);
> +	lnet_peer_ni_addref_locked(rtr);
>  
>  	if (rtr->lpni_ping_deadline && /* ping timed out? */
>  	    now > rtr->lpni_ping_deadline)
> @@ -967,7 +967,7 @@ lnet_ping_router_locked(struct lnet_peer_ni *rtr)
>  	if (!lnet_isrouter(rtr) ||
>  	    the_lnet.ln_rc_state != LNET_RC_STATE_RUNNING) {
>  		/* router table changed or router checker is shutting down */
> -		lnet_peer_decref_locked(rtr);
> +		lnet_peer_ni_decref_locked(rtr);
>  		return;
>  	}
>  
> @@ -1016,7 +1016,7 @@ lnet_ping_router_locked(struct lnet_peer_ni *rtr)
>  			rtr->lpni_ping_notsent = 0; /* no event pending */
>  	}
>  
> -	lnet_peer_decref_locked(rtr);
> +	lnet_peer_ni_decref_locked(rtr);
>  }
>  
>  int
> @@ -1756,7 +1756,7 @@ lnet_notify(struct lnet_ni *ni, lnet_nid_t nid, int alive, time64_t when)
>  	if (ni)
>  		lnet_ni_notify_locked(ni, lp);
>  
> -	lnet_peer_decref_locked(lp);
> +	lnet_peer_ni_decref_locked(lp);
>  
>  	lnet_net_unlock(cpt);
>  	return 0;
> 
> 
> 
