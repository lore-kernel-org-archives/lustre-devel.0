From: NeilBrown <neilb@suse.com>
Date: Wed, 17 Oct 2018 16:16:51 +1100
Subject: [lustre-devel] [PATCH 14/24] lustre: lnet: reference counts on
 lnet_peer/lnet_peer_net
In-Reply-To: <alpine.LFD.2.21.1810142338510.9543@casper.infradead.org>
References: <153895417139.16383.3791701638653772865.stgit@noble>
 <153895437808.16383.1725584261522697360.stgit@noble>
 <alpine.LFD.2.21.1810142338510.9543@casper.infradead.org>
Message-ID: <87o9btduf0.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Oct 14 2018, James Simmons wrote:

>> From: Olaf Weber <olaf@sgi.com>
>> 
>> Peer discovery will be keeping track of lnet_peer structures,
>> so there will be references to an lnet_peer independent of
>> the references implied by lnet_peer_ni structures. Manage
>> this by adding explicit reference counts to lnet_peer_net and
>> lnet_peer.
>> 
>> Each lnet_peer_net has a hold on the lnet_peer it links to
>> with its lpn_peer pointer. This hold is only removed when that
>> pointer is assigned a new value or the lnet_peer_net is freed.
>> Just removing an lnet_peer_net from the lp_peer_nets list does
>> not release this hold, it just prevents new lookups of the
>> lnet_peer_net via the lnet_peer.
>> 
>> Each lnet_peer_ni has a hold on the lnet_peer_net it links to
>> with its lpni_peer_net pointer. This hold is only removed when
>> that pointer is assigned a new value or the lnet_peer_ni is
>> freed. Just removing an lnet_peer_ni from the lpn_peer_nis
>> list does not release this hold, it just prevents new lookups
>> of the lnet_peer_ni via the lnet_peer_net.
>> 
>> This ensures that given a lnet_peer_ni *lpni, we can rely on
>> lpni->lpni_peer_net->lpn_peer pointing to a valid lnet_peer.
>> 
>> Keep a count of the total number of lnet_peer_ni attached to
>> an lnet_peer in lp_nnis.
>> 
>> Split the global ln_peers list into per-lnet_peer_table lists.
>> The CPT of the peer table in which the lnet_peer is linked is
>> stored in lp_cpt.
>> 
>> WC-bug-id: https://jira.whamcloud.com/browse/LU-9480
>> Signed-off-by: Olaf Weber <olaf@sgi.com>
>> Reviewed-on: https://review.whamcloud.com/25784
>> Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
>> Reviewed-by: Amir Shehata <amir.shehata@intel.com>
>> Tested-by: Amir Shehata <amir.shehata@intel.com>
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>  .../staging/lustre/include/linux/lnet/lib-lnet.h   |   49 +++--
>>  .../staging/lustre/include/linux/lnet/lib-types.h  |   50 ++++-
>>  drivers/staging/lustre/lnet/lnet/api-ni.c          |    1 
>>  drivers/staging/lustre/lnet/lnet/lib-move.c        |    8 -
>>  drivers/staging/lustre/lnet/lnet/peer.c            |  210 ++++++++++++++------
>>  5 files changed, 227 insertions(+), 91 deletions(-)
>> 
>> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
>> index 563417510722..aad25eb0011b 100644
>> --- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
>> +++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
>> @@ -310,6 +310,36 @@ lnet_handle2me(struct lnet_handle_me *handle)
>>  	return lh_entry(lh, struct lnet_me, me_lh);
>>  }
>>  
>> +static inline void
>> +lnet_peer_net_addref_locked(struct lnet_peer_net *lpn)
>> +{
>> +	atomic_inc(&lpn->lpn_refcount);
>> +}
>> +
>> +void lnet_destroy_peer_net_locked(struct lnet_peer_net *lpn);
>> +
>> +static inline void
>> +lnet_peer_net_decref_locked(struct lnet_peer_net *lpn)
>> +{
>> +	if (atomic_dec_and_test(&lpn->lpn_refcount))
>> +		lnet_destroy_peer_net_locked(lpn);
>> +}
>> +
>> +static inline void
>> +lnet_peer_addref_locked(struct lnet_peer *lp)
>> +{
>> +	atomic_inc(&lp->lp_refcount);
>> +}
>> +
>> +void lnet_destroy_peer_locked(struct lnet_peer *lp);
>> +
>> +static inline void
>> +lnet_peer_decref_locked(struct lnet_peer *lp)
>> +{
>> +	if (atomic_dec_and_test(&lp->lp_refcount))
>> +		lnet_destroy_peer_locked(lp);
>> +}
>> +
>>  static inline void
>>  lnet_peer_ni_addref_locked(struct lnet_peer_ni *lp)
>>  {
>> @@ -695,21 +725,6 @@ int lnet_get_peer_ni_info(__u32 peer_index, __u64 *nid,
>>  			  __u32 *peer_rtr_credits, __u32 *peer_min_rtr_credtis,
>>  			  __u32 *peer_tx_qnob);
>>  
>> -static inline __u32
>> -lnet_get_num_peer_nis(struct lnet_peer *peer)
>> -{
>> -	struct lnet_peer_net *lpn;
>> -	struct lnet_peer_ni *lpni;
>> -	__u32 count = 0;
>> -
>> -	list_for_each_entry(lpn, &peer->lp_peer_nets, lpn_on_peer_list)
>> -		list_for_each_entry(lpni, &lpn->lpn_peer_nis,
>> -				    lpni_on_peer_net_list)
>> -			count++;
>> -
>> -	return count;
>> -}
>> -
>>  static inline bool
>>  lnet_is_peer_ni_healthy_locked(struct lnet_peer_ni *lpni)
>>  {
>> @@ -728,7 +743,7 @@ lnet_is_peer_net_healthy_locked(struct lnet_peer_net *peer_net)
>>  	struct lnet_peer_ni *lpni;
>>  
>>  	list_for_each_entry(lpni, &peer_net->lpn_peer_nis,
>> -			    lpni_on_peer_net_list) {
>> +			    lpni_peer_nis) {
>>  		if (lnet_is_peer_ni_healthy_locked(lpni))
>>  			return true;
>>  	}
>> @@ -741,7 +756,7 @@ lnet_is_peer_healthy_locked(struct lnet_peer *peer)
>>  {
>>  	struct lnet_peer_net *peer_net;
>>  
>> -	list_for_each_entry(peer_net, &peer->lp_peer_nets, lpn_on_peer_list) {
>> +	list_for_each_entry(peer_net, &peer->lp_peer_nets, lpn_peer_nets) {
>>  		if (lnet_is_peer_net_healthy_locked(peer_net))
>>  			return true;
>>  	}
>> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
>> index d1721fd01d93..260619e19bde 100644
>> --- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
>> +++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
>> @@ -411,7 +411,8 @@ struct lnet_rc_data {
>>  };
>>  
>>  struct lnet_peer_ni {
>> -	struct list_head	lpni_on_peer_net_list;
>> +	/* chain on lpn_peer_nis */
>> +	struct list_head	lpni_peer_nis;
>>  	/* chain on remote peer list */
>>  	struct list_head	lpni_on_remote_peer_ni_list;
>>  	/* chain on peer hash */
>> @@ -496,8 +497,8 @@ struct lnet_peer_ni {
>>  #define LNET_PEER_NI_NON_MR_PREF	BIT(0)
>>  
>>  struct lnet_peer {
>> -	/* chain on global peer list */
>> -	struct list_head	lp_on_lnet_peer_list;
>> +	/* chain on pt_peer_list */
>> +	struct list_head	lp_peer_list;
>>  
>>  	/* list of peer nets */
>>  	struct list_head	lp_peer_nets;
>> @@ -505,6 +506,15 @@ struct lnet_peer {
>>  	/* primary NID of the peer */
>>  	lnet_nid_t		lp_primary_nid;
>>  
>> +	/* CPT of peer_table */
>> +	int			lp_cpt;
>> +
>> +	/* number of NIDs on this peer */
>> +	int			lp_nnis;
>> +
>> +	/* reference count */
>> +	atomic_t		lp_refcount;
>> +
>>  	/* lock protecting peer state flags */
>>  	spinlock_t		lp_lock;
>>  
>> @@ -516,8 +526,8 @@ struct lnet_peer {
>>  #define LNET_PEER_CONFIGURED	BIT(1)
>>  
>>  struct lnet_peer_net {
>> -	/* chain on peer block */
>> -	struct list_head	lpn_on_peer_list;
>> +	/* chain on lp_peer_nets */
>> +	struct list_head	lpn_peer_nets;
>>  
>>  	/* list of peer_nis on this network */
>>  	struct list_head	lpn_peer_nis;
>> @@ -527,21 +537,45 @@ struct lnet_peer_net {
>>  
>>  	/* Net ID */
>>  	__u32			lpn_net_id;
>> +
>> +	/* reference count */
>> +	atomic_t		lpn_refcount;
>>  };
>>  
>>  /* peer hash size */
>>  #define LNET_PEER_HASH_BITS	9
>>  #define LNET_PEER_HASH_SIZE	(1 << LNET_PEER_HASH_BITS)
>>  
>> -/* peer hash table */
>> +/*
>> + * peer hash table - one per CPT
>> + *
>> + * protected by lnet_net_lock/EX for update
>> + *    pt_version
>> + *    pt_number
>> + *    pt_hash[...]
>> + *    pt_peer_list
>> + *    pt_peers
>> + *    pt_peer_nnids
>> + * protected by pt_zombie_lock:
>> + *    pt_zombie_list
>> + *    pt_zombies
>> + *
>> + * pt_zombie lock nests inside lnet_net_lock
>> + */
>>  struct lnet_peer_table {
>>  	/* /proc validity stamp */
>>  	int			 pt_version;
>>  	/* # peers extant */
>>  	atomic_t		 pt_number;
>> +	/* peers */
>> +	struct list_head	pt_peer_list;
>> +	/* # peers */
>> +	int			pt_peers;
>> +	/* # NIDS on listed peers */
>> +	int			pt_peer_nnids;
>>  	/* # zombies to go to deathrow (and not there yet) */
>>  	int			 pt_zombies;
>> -	/* zombie peers */
>> +	/* zombie peers_ni */
>>  	struct list_head	 pt_zombie_list;
>>  	/* protect list and count */
>>  	spinlock_t		 pt_zombie_lock;
>> @@ -785,8 +819,6 @@ struct lnet {
>>  	struct lnet_msg_container	**ln_msg_containers;
>>  	struct lnet_counters		**ln_counters;
>>  	struct lnet_peer_table		**ln_peer_tables;
>> -	/* list of configured or discovered peers */
>> -	struct list_head		ln_peers;
>>  	/* list of peer nis not on a local network */
>>  	struct list_head		ln_remote_peer_ni_list;
>>  	/* failure simulation */
>> diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
>> index d64ae2939abc..c48bcb8722a0 100644
>> --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
>> +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
>> @@ -625,7 +625,6 @@ lnet_prepare(lnet_pid_t requested_pid)
>>  	the_lnet.ln_pid = requested_pid;
>>  
>>  	INIT_LIST_HEAD(&the_lnet.ln_test_peers);
>> -	INIT_LIST_HEAD(&the_lnet.ln_peers);
>>  	INIT_LIST_HEAD(&the_lnet.ln_remote_peer_ni_list);
>>  	INIT_LIST_HEAD(&the_lnet.ln_nets);
>>  	INIT_LIST_HEAD(&the_lnet.ln_routers);
>> diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
>> index 99d8b22356bb..4c1eef907dc7 100644
>> --- a/drivers/staging/lustre/lnet/lnet/lib-move.c
>> +++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
>> @@ -1388,7 +1388,7 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
>>  			peer_net = lnet_peer_get_net_locked(
>>  				peer, LNET_NIDNET(best_lpni->lpni_nid));
>>  			list_for_each_entry(lpni, &peer_net->lpn_peer_nis,
>> -					    lpni_on_peer_net_list) {
>> +					    lpni_peer_nis) {
>>  				if (lpni->lpni_pref_nnids == 0)
>>  					continue;
>>  				LASSERT(lpni->lpni_pref_nnids == 1);
>> @@ -1411,7 +1411,7 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
>>  			}
>>  			lpni = list_entry(peer_net->lpn_peer_nis.next,
>>  					  struct lnet_peer_ni,
>> -					  lpni_on_peer_net_list);
>> +					  lpni_peer_nis);
>>  		}
>>  		/* Set preferred NI if necessary. */
>>  		if (lpni->lpni_pref_nnids == 0)
>> @@ -1443,7 +1443,7 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
>>  	 * then the best route is chosen. If all routes are equal then
>>  	 * they are used in round robin.
>>  	 */
>> -	list_for_each_entry(peer_net, &peer->lp_peer_nets, lpn_on_peer_list) {
>> +	list_for_each_entry(peer_net, &peer->lp_peer_nets, lpn_peer_nets) {
>>  		if (!lnet_is_peer_net_healthy_locked(peer_net))
>>  			continue;
>>  
>> @@ -1453,7 +1453,7 @@ lnet_select_pathway(lnet_nid_t src_nid, lnet_nid_t dst_nid,
>>  
>>  			lpni = list_entry(peer_net->lpn_peer_nis.next,
>>  					  struct lnet_peer_ni,
>> -					  lpni_on_peer_net_list);
>> +					  lpni_peer_nis);
>>  
>>  			net_gw = lnet_find_route_locked(NULL,
>>  							lpni->lpni_nid,
>> diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
>> index 09c1b5516f6b..d7a0a2f3bdd9 100644
>> --- a/drivers/staging/lustre/lnet/lnet/peer.c
>> +++ b/drivers/staging/lustre/lnet/lnet/peer.c
>
> INIT_LIST_HEAD(&ptable->pt_peer_list); seems to be missing from
> lnet_peer_tables_create(). This is in the patch merged into 
> lustre-testing. Other than that it looks okay.

No, it is there. It is just the the lnet_peer_tables_create() has moved,
so it isn't in the same place in the patch.

..snip..

>> @@ -319,6 +358,8 @@ lnet_peer_tables_create(void)
>>  		spin_lock_init(&ptable->pt_zombie_lock);
>>  		INIT_LIST_HEAD(&ptable->pt_zombie_list);
>>  
>> +		INIT_LIST_HEAD(&ptable->pt_peer_list);
>> +
>>  		for (j = 0; j < LNET_PEER_HASH_SIZE; j++)
>>  			INIT_LIST_HEAD(&hash[j]);
>>  		ptable->pt_hash = hash; /* sign of initialization */

here it is.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181017/8e4d4715/attachment.sig>
