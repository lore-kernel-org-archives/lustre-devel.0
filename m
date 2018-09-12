From: NeilBrown <neilb@suse.com>
Date: Wed, 12 Sep 2018 14:25:00 +1000
Subject: [lustre-devel] [PATCH 18/34] lnet: add ni_state
In-Reply-To: <0DD49EFB-412D-4C87-8FC8-3F0C93D2E98A@cray.com>
References: <153628058697.8267.6056114844033479774.stgit@noble>
 <153628137195.8267.16400748098054215181.stgit@noble>
 <0DD49EFB-412D-4C87-8FC8-3F0C93D2E98A@cray.com>
Message-ID: <877ejrqr4z.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Sep 12 2018, Doug Oucharek wrote:

> I believe the introduction of this state machine is to help us understand how healthy an NI is so we can avoid if it is not healthy and we have other paths which are still ok.
>
> Reviewed-by: Doug Oucharek <dougso@me.com>

Thanks.  Now reads:

-----------
lnet: add ni_state

This will be used more in later patches to track how healthy an NI is,
so we can avoid one if it isn't healthy and we have other paths which
are still OK.

Reviewed-by: Doug Oucharek <dougso@me.com>
Signed-off-by: NeilBrown <neilb@suse.com>
------------

I noticed that it was used more in later patches, which is why I didn't
discard the patch.  The original has a "net_state" in lnet_net - I
haven't included that change as net_state is still unused.

Thanks,
NeilBrown


>
> Doug
>
> ?On 9/6/18, 5:54 PM, "NeilBrown" <neilb@suse.com> wrote:
>
>     This is barely used.
>     
>     This is part of
>         8cbb8cd3e771e7f7e0f99cafc19fad32770dc015
>            LU-7734 lnet: Multi-Rail local NI split
>     
>     Signed-off-by: NeilBrown <neilb@suse.com>
>     ---
>      .../staging/lustre/include/linux/lnet/lib-lnet.h   |    1 +
>      .../staging/lustre/include/linux/lnet/lib-types.h  |   16 ++++++++++++++++
>      drivers/staging/lustre/lnet/lnet/api-ni.c          |   16 ++++++++++++++++
>      drivers/staging/lustre/lnet/lnet/config.c          |    1 +
>      4 files changed, 34 insertions(+)
>     
>     diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
>     index faa3f19dd844..54a93235834c 100644
>     --- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
>     +++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
>     @@ -400,6 +400,7 @@ int lnet_cpt_of_nid(lnet_nid_t nid, struct lnet_ni *ni);
>      struct lnet_ni *lnet_nid2ni_locked(lnet_nid_t nid, int cpt);
>      struct lnet_ni *lnet_net2ni_locked(__u32 net, int cpt);
>      struct lnet_ni *lnet_net2ni(__u32 net);
>     +bool lnet_is_ni_healthy_locked(struct lnet_ni *ni);
>      
>      extern int portal_rotor;
>      
>     diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
>     index 1d372672e2de..6c34ecf22021 100644
>     --- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
>     +++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
>     @@ -256,6 +256,19 @@ struct lnet_tx_queue {
>      	struct list_head	tq_delayed;	/* delayed TXs */
>      };
>      
>     +enum lnet_ni_state {
>     +	/* set when NI block is allocated */
>     +	LNET_NI_STATE_INIT = 0,
>     +	/* set when NI is started successfully */
>     +	LNET_NI_STATE_ACTIVE,
>     +	/* set when LND notifies NI failed */
>     +	LNET_NI_STATE_FAILED,
>     +	/* set when LND notifies NI degraded */
>     +	LNET_NI_STATE_DEGRADED,
>     +	/* set when shuttding down NI */
>     +	LNET_NI_STATE_DELETING
>     +};
>     +
>      struct lnet_net {
>      	/* chain on the ln_nets */
>      	struct list_head	net_list;
>     @@ -324,6 +337,9 @@ struct lnet_ni {
>      	/* my health status */
>      	struct lnet_ni_status	*ni_status;
>      
>     +	/* NI FSM */
>     +	enum lnet_ni_state	ni_state;
>     +
>      	/* per NI LND tunables */
>      	struct lnet_lnd_tunables ni_lnd_tunables;
>      
>     diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
>     index 46c5ca71bc07..618fdf8141f0 100644
>     --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
>     +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
>     @@ -780,6 +780,16 @@ lnet_islocalnet(__u32 net)
>      	return !!ni;
>      }
>      
>     +bool
>     +lnet_is_ni_healthy_locked(struct lnet_ni *ni)
>     +{
>     +	if (ni->ni_state == LNET_NI_STATE_ACTIVE ||
>     +	    ni->ni_state == LNET_NI_STATE_DEGRADED)
>     +		return true;
>     +
>     +	return false;
>     +}
>     +
>      struct lnet_ni  *
>      lnet_nid2ni_locked(lnet_nid_t nid, int cpt)
>      {
>     @@ -1117,6 +1127,9 @@ lnet_clear_zombies_nis_locked(struct lnet_net *net)
>      		ni = list_entry(zombie_list->next,
>      				struct lnet_ni, ni_netlist);
>      		list_del_init(&ni->ni_netlist);
>     +		/* the ni should be in deleting state. If it's not it's
>     +		 * a bug */
>     +		LASSERT(ni->ni_state == LNET_NI_STATE_DELETING);
>      		cfs_percpt_for_each(ref, j, ni->ni_refs) {
>      			if (!*ref)
>      				continue;
>     @@ -1163,6 +1176,7 @@ lnet_shutdown_lndni(struct lnet_ni *ni)
>      	struct lnet_net *net = ni->ni_net;
>      
>      	lnet_net_lock(LNET_LOCK_EX);
>     +	ni->ni_state = LNET_NI_STATE_DELETING;
>      	lnet_ni_unlink_locked(ni);
>      	lnet_net_unlock(LNET_LOCK_EX);
>      
>     @@ -1291,6 +1305,8 @@ lnet_startup_lndni(struct lnet_ni *ni, struct lnet_lnd_tunables *tun)
>      
>      	lnet_net_unlock(LNET_LOCK_EX);
>      
>     +	ni->ni_state = LNET_NI_STATE_ACTIVE;
>     +
>      	if (net->net_lnd->lnd_type == LOLND) {
>      		lnet_ni_addref(ni);
>      		LASSERT(!the_lnet.ln_loni);
>     diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
>     index 2588d67fea1b..081812e19b13 100644
>     --- a/drivers/staging/lustre/lnet/lnet/config.c
>     +++ b/drivers/staging/lustre/lnet/lnet/config.c
>     @@ -393,6 +393,7 @@ lnet_ni_alloc(struct lnet_net *net, struct cfs_expr_list *el, char *iface)
>      		ni->ni_net_ns = NULL;
>      
>      	ni->ni_last_alive = ktime_get_real_seconds();
>     +	ni->ni_state = LNET_NI_STATE_INIT;
>      	rc = lnet_net_append_cpts(ni->ni_cpts, ni->ni_ncpts, net);
>      	if (rc != 0)
>      		goto failed;
>     
>     
>     
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180912/d908d434/attachment.sig>
