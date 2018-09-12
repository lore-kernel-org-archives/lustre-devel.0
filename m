From: NeilBrown <neilb@suse.com>
Date: Wed, 12 Sep 2018 14:10:46 +1000
Subject: [lustre-devel] [PATCH 15/34] lnet: extend zombie handling to
 nets and nis
In-Reply-To: <384BF908-3F8C-477C-800E-8ECCE708EC6F@cray.com>
References: <153628058697.8267.6056114844033479774.stgit@noble>
 <153628137183.8267.14166864803956204561.stgit@noble>
 <384BF908-3F8C-477C-800E-8ECCE708EC6F@cray.com>
Message-ID: <87a7onqrsp.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Sep 12 2018, Doug Oucharek wrote:

> Which refcount line are you referring to?  The call to
> lnet_ni_unlink_locked()?

Line 1141 = in lnet_clear_zombies_nis_locked().

>     -		ni->ni_net->net_lnd->lnd_refcount--;

Thanks,
NeilBrown

>
> Reviewed-by: Doug Oucharek <dougso@me.com>
>
> Doug
>
> ?On 9/6/18, 5:53 PM, "NeilBrown" <neilb@suse.com> wrote:
>
>     A zombie lnet_ni is now attached to the lnet_net rather than the
>     global the_lnet.  The zombie lnet_net are attached to the_lnet.
>     
>     For some reason, we don't drop the refcount on the lnd before shutting
>     it down now.
>     
>     This is part of
>         8cbb8cd3e771e7f7e0f99cafc19fad32770dc015
>            LU-7734 lnet: Multi-Rail local NI split
>     
>     Signed-off-by: NeilBrown <neilb@suse.com>
>     ---
>      .../staging/lustre/include/linux/lnet/lib-types.h  |    9 ++-
>      drivers/staging/lustre/lnet/lnet/api-ni.c          |   65 ++++++++++----------
>      drivers/staging/lustre/lnet/lnet/config.c          |    3 +
>      3 files changed, 42 insertions(+), 35 deletions(-)
>     
>     diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
>     index 22957d142cc0..1d372672e2de 100644
>     --- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
>     +++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
>     @@ -284,6 +284,9 @@ struct lnet_net {
>      	struct lnet_lnd		*net_lnd;
>      	/* list of NIs on this net */
>      	struct list_head	net_ni_list;
>     +
>     +	/* dying LND instances */
>     +	struct list_head	net_ni_zombie;
>      };
>      
>      struct lnet_ni {
>     @@ -653,11 +656,11 @@ struct lnet {
>      	/* LND instances */
>      	struct list_head		ln_nets;
>      	/* NIs bond on specific CPT(s) */
>     -	struct list_head		  ln_nis_cpt;
>     -	/* dying LND instances */
>     -	struct list_head		  ln_nis_zombie;
>     +	struct list_head		ln_nis_cpt;
>      	/* the loopback NI */
>      	struct lnet_ni			*ln_loni;
>     +	/* network zombie list */
>     +	struct list_head		ln_net_zombie;
>      
>      	/* remote networks with routes to them */
>      	struct list_head		 *ln_remote_nets_hash;
>     diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
>     index c3c568e63342..18d111cb826b 100644
>     --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
>     +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
>     @@ -539,7 +539,6 @@ lnet_prepare(lnet_pid_t requested_pid)
>      	INIT_LIST_HEAD(&the_lnet.ln_test_peers);
>      	INIT_LIST_HEAD(&the_lnet.ln_nets);
>      	INIT_LIST_HEAD(&the_lnet.ln_nis_cpt);
>     -	INIT_LIST_HEAD(&the_lnet.ln_nis_zombie);
>      	INIT_LIST_HEAD(&the_lnet.ln_routers);
>      	INIT_LIST_HEAD(&the_lnet.ln_drop_rules);
>      	INIT_LIST_HEAD(&the_lnet.ln_delay_rules);
>     @@ -618,7 +617,6 @@ lnet_unprepare(void)
>      	LASSERT(list_empty(&the_lnet.ln_test_peers));
>      	LASSERT(list_empty(&the_lnet.ln_nets));
>      	LASSERT(list_empty(&the_lnet.ln_nis_cpt));
>     -	LASSERT(list_empty(&the_lnet.ln_nis_zombie));
>      
>      	lnet_portals_destroy();
>      
>     @@ -1095,34 +1093,35 @@ lnet_ni_unlink_locked(struct lnet_ni *ni)
>      
>      	/* move it to zombie list and nobody can find it anymore */
>      	LASSERT(!list_empty(&ni->ni_netlist));
>     -	list_move(&ni->ni_netlist, &the_lnet.ln_nis_zombie);
>     +	list_move(&ni->ni_netlist, &ni->ni_net->net_ni_zombie);
>      	lnet_ni_decref_locked(ni, 0);
>      }
>      
>      static void
>     -lnet_clear_zombies_nis_locked(void)
>     +lnet_clear_zombies_nis_locked(struct lnet_net *net)
>      {
>      	int i;
>      	int islo;
>      	struct lnet_ni *ni;
>     +	struct list_head *zombie_list = &net->net_ni_zombie;
>      
>      	/*
>     -	 * Now wait for the NI's I just nuked to show up on ln_zombie_nis
>     -	 * and shut them down in guaranteed thread context
>     +	 * Now wait for the NIs I just nuked to show up on the zombie
>     +	 * list and shut them down in guaranteed thread context
>      	 */
>      	i = 2;
>     -	while (!list_empty(&the_lnet.ln_nis_zombie)) {
>     +	while (!list_empty(zombie_list)) {
>      		int *ref;
>      		int j;
>      
>     -		ni = list_entry(the_lnet.ln_nis_zombie.next,
>     +		ni = list_entry(zombie_list->next,
>      				struct lnet_ni, ni_netlist);
>      		list_del_init(&ni->ni_netlist);
>      		cfs_percpt_for_each(ref, j, ni->ni_refs) {
>      			if (!*ref)
>      				continue;
>      			/* still busy, add it back to zombie list */
>     -			list_add(&ni->ni_netlist, &the_lnet.ln_nis_zombie);
>     +			list_add(&ni->ni_netlist, zombie_list);
>      			break;
>      		}
>      
>     @@ -1138,18 +1137,13 @@ lnet_clear_zombies_nis_locked(void)
>      			continue;
>      		}
>      
>     -		ni->ni_net->net_lnd->lnd_refcount--;
>      		lnet_net_unlock(LNET_LOCK_EX);
>      
>      		islo = ni->ni_net->net_lnd->lnd_type == LOLND;
>      
>      		LASSERT(!in_interrupt());
>     -		ni->ni_net->net_lnd->lnd_shutdown(ni);
>     +		net->net_lnd->lnd_shutdown(ni);
>      
>     -		/*
>     -		 * can't deref lnd anymore now; it might have unregistered
>     -		 * itself...
>     -		 */
>      		if (!islo)
>      			CDEBUG(D_LNI, "Removed LNI %s\n",
>      			       libcfs_nid2str(ni->ni_nid));
>     @@ -1162,9 +1156,11 @@ lnet_clear_zombies_nis_locked(void)
>      }
>      
>      static void
>     -lnet_shutdown_lndnis(void)
>     +lnet_shutdown_lndnet(struct lnet_net *net);
>     +
>     +static void
>     +lnet_shutdown_lndnets(void)
>      {
>     -	struct lnet_ni *ni;
>      	int i;
>      	struct lnet_net *net;
>      
>     @@ -1173,30 +1169,35 @@ lnet_shutdown_lndnis(void)
>      	/* All quiet on the API front */
>      	LASSERT(!the_lnet.ln_shutdown);
>      	LASSERT(!the_lnet.ln_refcount);
>     -	LASSERT(list_empty(&the_lnet.ln_nis_zombie));
>      
>      	lnet_net_lock(LNET_LOCK_EX);
>      	the_lnet.ln_shutdown = 1;	/* flag shutdown */
>      
>     -	/* Unlink NIs from the global table */
>      	while (!list_empty(&the_lnet.ln_nets)) {
>     +		/*
>     +		 * move the nets to the zombie list to avoid them being
>     +		 * picked up for new work. LONET is also included in the
>     +		 * Nets that will be moved to the zombie list
>     +		 */
>      		net = list_entry(the_lnet.ln_nets.next,
>      				 struct lnet_net, net_list);
>     -		while (!list_empty(&net->net_ni_list)) {
>     -			ni = list_entry(net->net_ni_list.next,
>     -					struct lnet_ni, ni_netlist);
>     -			lnet_ni_unlink_locked(ni);
>     -		}
>     +		list_move(&net->net_list, &the_lnet.ln_net_zombie);
>      	}
>      
>     -	/* Drop the cached loopback NI. */
>     +	/* Drop the cached loopback Net. */
>      	if (the_lnet.ln_loni) {
>      		lnet_ni_decref_locked(the_lnet.ln_loni, 0);
>      		the_lnet.ln_loni = NULL;
>      	}
>     -
>      	lnet_net_unlock(LNET_LOCK_EX);
>      
>     +	/* iterate through the net zombie list and delete each net */
>     +	while (!list_empty(&the_lnet.ln_net_zombie)) {
>     +		net = list_entry(the_lnet.ln_net_zombie.next,
>     +				 struct lnet_net, net_list);
>     +		lnet_shutdown_lndnet(net);
>     +	}
>     +
>      	/*
>      	 * Clear lazy portals and drop delayed messages which hold refs
>      	 * on their lnet_msg::msg_rxpeer
>     @@ -1211,8 +1212,6 @@ lnet_shutdown_lndnis(void)
>      	lnet_peer_tables_cleanup(NULL);
>      
>      	lnet_net_lock(LNET_LOCK_EX);
>     -
>     -	lnet_clear_zombies_nis_locked();
>      	the_lnet.ln_shutdown = 0;
>      	lnet_net_unlock(LNET_LOCK_EX);
>      }
>     @@ -1222,6 +1221,7 @@ static void
>      lnet_shutdown_lndni(struct lnet_ni *ni)
>      {
>      	int i;
>     +	struct lnet_net *net = ni->ni_net;
>      
>      	lnet_net_lock(LNET_LOCK_EX);
>      	lnet_ni_unlink_locked(ni);
>     @@ -1235,7 +1235,7 @@ lnet_shutdown_lndni(struct lnet_ni *ni)
>      	lnet_peer_tables_cleanup(ni);
>      
>      	lnet_net_lock(LNET_LOCK_EX);
>     -	lnet_clear_zombies_nis_locked();
>     +	lnet_clear_zombies_nis_locked(net);
>      	lnet_net_unlock(LNET_LOCK_EX);
>      }
>      
>     @@ -1445,7 +1445,7 @@ lnet_startup_lndnets(struct list_head *netlist)
>      
>      	return ni_count;
>      failed:
>     -	lnet_shutdown_lndnis();
>     +	lnet_shutdown_lndnets();
>      
>      	return rc;
>      }
>     @@ -1492,6 +1492,7 @@ int lnet_lib_init(void)
>      	the_lnet.ln_refcount = 0;
>      	LNetInvalidateEQHandle(&the_lnet.ln_rc_eqh);
>      	INIT_LIST_HEAD(&the_lnet.ln_lnds);
>     +	INIT_LIST_HEAD(&the_lnet.ln_net_zombie);
>      	INIT_LIST_HEAD(&the_lnet.ln_rcd_zombie);
>      	INIT_LIST_HEAD(&the_lnet.ln_rcd_deathrow);
>      
>     @@ -1656,7 +1657,7 @@ LNetNIInit(lnet_pid_t requested_pid)
>      	if (!the_lnet.ln_nis_from_mod_params)
>      		lnet_destroy_routes();
>      err_shutdown_lndnis:
>     -	lnet_shutdown_lndnis();
>     +	lnet_shutdown_lndnets();
>      err_empty_list:
>      	lnet_unprepare();
>      	LASSERT(rc < 0);
>     @@ -1703,7 +1704,7 @@ LNetNIFini(void)
>      
>      		lnet_acceptor_stop();
>      		lnet_destroy_routes();
>     -		lnet_shutdown_lndnis();
>     +		lnet_shutdown_lndnets();
>      		lnet_unprepare();
>      	}
>      
>     diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
>     index 380a3fb1caba..2588d67fea1b 100644
>     --- a/drivers/staging/lustre/lnet/lnet/config.c
>     +++ b/drivers/staging/lustre/lnet/lnet/config.c
>     @@ -279,6 +279,8 @@ lnet_net_free(struct lnet_net *net)
>      	struct list_head *tmp, *tmp2;
>      	struct lnet_ni *ni;
>      
>     +	LASSERT(list_empty(&net->net_ni_zombie));
>     +
>      	/* delete any nis which have been started. */
>      	list_for_each_safe(tmp, tmp2, &net->net_ni_list) {
>      		ni = list_entry(tmp, struct lnet_ni, ni_netlist);
>     @@ -312,6 +314,7 @@ lnet_net_alloc(__u32 net_id, struct list_head *net_list)
>      
>      	INIT_LIST_HEAD(&net->net_list);
>      	INIT_LIST_HEAD(&net->net_ni_list);
>     +	INIT_LIST_HEAD(&net->net_ni_zombie);
>      
>      	net->net_id = net_id;
>      
>     
>     
>     
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180912/56aabeb8/attachment-0001.sig>
