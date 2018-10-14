From: James Simmons <jsimmons@infradead.org>
Date: Mon, 15 Oct 2018 00:38:52 +0100 (BST)
Subject: [lustre-devel] [PATCH 19/24] lustre: lnet: add "lnetctl peer
 list"
In-Reply-To: <153895437828.16383.14376327105039832285.stgit@noble>
References: <153895417139.16383.3791701638653772865.stgit@noble>
 <153895437828.16383.14376327105039832285.stgit@noble>
Message-ID: <alpine.LFD.2.21.1810150038290.9543@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> From: Olaf Weber <olaf@sgi.com>
> 
> Add IOC_LIBCFS_GET_PEER_LIST to obtain a list of the primary
> NIDs of all peers known to the system. The list is written
> into a userspace buffer by the kernel. The typical usage is
> to make a first call to determine the required buffer size,
> then a second call to obtain the list.
> 
> Extend the "lnetctl peer" set of commands with a "list"
> subcommand that uses this interface.
> 
> Modify the IOC_LIBCFS_GET_PEER_NI ioctl (which is new in the
> Multi-Rail code) to use a NID to indicate the peer to look
> up, and then pass out the data for all NIDs of that peer.
> 
> Re-implement "lnetctl peer show" to obtain the list of NIDs
> using IOC_LIBCFS_GET_PEER_LIST followed by one or more
> IOC_LIBCFS_GET_PEER_NI calls to get information for each
> peer.
> 
> Make sure to copy the structure from kernel space to
> user space even if the ioctl handler returns an error.
> This is needed because if the buffer passed in by the
> user space is not big enough to copy the data, we want
> to pass the requested size to user space in the structure
> passed in. The return code in this case is -E2BIG.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> WC-bug-id: https://jira.whamcloud.com/browse/LU-9480
> Signed-off-by: Olaf Weber <olaf@sgi.com>
> Reviewed-on: https://review.whamcloud.com/25790
> Reviewed-by: Amir Shehata <amir.shehata@intel.com>
> Tested-by: Amir Shehata <amir.shehata@intel.com>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/include/linux/lnet/lib-lnet.h   |    9 -
>  .../staging/lustre/include/linux/lnet/lib-types.h  |    3 
>  .../lustre/include/uapi/linux/lnet/libcfs_ioctl.h  |    3 
>  drivers/staging/lustre/lnet/lnet/api-ni.c          |   30 ++-
>  drivers/staging/lustre/lnet/lnet/peer.c            |  222 +++++++++++++-------
>  5 files changed, 169 insertions(+), 98 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> index f82a699371f2..58e3a9c4e39f 100644
> --- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> +++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> @@ -462,6 +462,8 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg);
>  struct lnet_ni *lnet_get_next_ni_locked(struct lnet_net *mynet,
>  					struct lnet_ni *prev);
>  struct lnet_ni *lnet_get_ni_idx_locked(int idx);
> +int lnet_get_peer_list(__u32 *countp, __u32 *sizep,
> +		       struct lnet_process_id __user *ids);
>  
>  void lnet_router_debugfs_init(void);
>  void lnet_router_debugfs_fini(void);
> @@ -730,10 +732,9 @@ bool lnet_peer_is_pref_nid_locked(struct lnet_peer_ni *lpni, lnet_nid_t nid);
>  int lnet_peer_ni_set_non_mr_pref_nid(struct lnet_peer_ni *lpni, lnet_nid_t nid);
>  int lnet_add_peer_ni(lnet_nid_t key_nid, lnet_nid_t nid, bool mr);
>  int lnet_del_peer_ni(lnet_nid_t key_nid, lnet_nid_t nid);
> -int lnet_get_peer_info(__u32 idx, lnet_nid_t *primary_nid, lnet_nid_t *nid,
> -		       bool *mr,
> -		       struct lnet_peer_ni_credit_info __user *peer_ni_info,
> -		       struct lnet_ioctl_element_stats __user *peer_ni_stats);
> +int lnet_get_peer_info(lnet_nid_t *primary_nid, lnet_nid_t *nid,
> +		       __u32 *nnis, bool *mr, __u32 *sizep,
> +		       void __user *bulk);
>  int lnet_get_peer_ni_info(__u32 peer_index, __u64 *nid,
>  			  char alivness[LNET_MAX_STR_LEN],
>  			  __u32 *cpt_iter, __u32 *refcount,
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> index 07baa86e61ab..8543a67420d7 100644
> --- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
> +++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> @@ -651,7 +651,6 @@ struct lnet_peer_net {
>   *    pt_hash[...]
>   *    pt_peer_list
>   *    pt_peers
> - *    pt_peer_nnids
>   * protected by pt_zombie_lock:
>   *    pt_zombie_list
>   *    pt_zombies
> @@ -667,8 +666,6 @@ struct lnet_peer_table {
>  	struct list_head	pt_peer_list;
>  	/* # peers */
>  	int			pt_peers;
> -	/* # NIDS on listed peers */
> -	int			pt_peer_nnids;
>  	/* # zombies to go to deathrow (and not there yet) */
>  	int			 pt_zombies;
>  	/* zombie peers_ni */
> diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h b/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h
> index 2a9beed23985..2607620e8ef8 100644
> --- a/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h
> +++ b/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_ioctl.h
> @@ -144,6 +144,7 @@ struct libcfs_debug_ioctl_data {
>  #define IOC_LIBCFS_GET_LOCAL_NI		_IOWR(IOC_LIBCFS_TYPE, 97, IOCTL_CONFIG_SIZE)
>  #define IOC_LIBCFS_SET_NUMA_RANGE	_IOWR(IOC_LIBCFS_TYPE, 98, IOCTL_CONFIG_SIZE)
>  #define IOC_LIBCFS_GET_NUMA_RANGE	_IOWR(IOC_LIBCFS_TYPE, 99, IOCTL_CONFIG_SIZE)
> -#define IOC_LIBCFS_MAX_NR		99
> +#define IOC_LIBCFS_GET_PEER_LIST	_IOWR(IOC_LIBCFS_TYPE, 100, IOCTL_CONFIG_SIZE)
> +#define IOC_LIBCFS_MAX_NR		100
>  
>  #endif /* __LIBCFS_IOCTL_H__ */
> diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
> index 955d1711eda4..f624abe7db80 100644
> --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
> +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
> @@ -3117,21 +3117,31 @@ LNetCtl(unsigned int cmd, void *arg)
>  
>  	case IOC_LIBCFS_GET_PEER_NI: {
>  		struct lnet_ioctl_peer_cfg *cfg = arg;
> -		struct lnet_peer_ni_credit_info __user *lpni_cri;
> -		struct lnet_ioctl_element_stats __user *lpni_stats;
> -		size_t usr_size = sizeof(*lpni_cri) + sizeof(*lpni_stats);
>  
> -		if ((cfg->prcfg_hdr.ioc_len != sizeof(*cfg)) ||
> -		    (cfg->prcfg_size != usr_size))
> +		if (cfg->prcfg_hdr.ioc_len < sizeof(*cfg))
>  			return -EINVAL;
>  
> -		lpni_cri = cfg->prcfg_bulk;
> -		lpni_stats = cfg->prcfg_bulk + sizeof(*lpni_cri);
> +		mutex_lock(&the_lnet.ln_api_mutex);
> +		rc = lnet_get_peer_info(&cfg->prcfg_prim_nid,
> +					&cfg->prcfg_cfg_nid,
> +					&cfg->prcfg_count,
> +					&cfg->prcfg_mr,
> +					&cfg->prcfg_size,
> +					(void __user *)cfg->prcfg_bulk);
> +		mutex_unlock(&the_lnet.ln_api_mutex);
> +		return rc;
> +	}
> +
> +	case IOC_LIBCFS_GET_PEER_LIST: {
> +		struct lnet_ioctl_peer_cfg *cfg = arg;
> +
> +		if (cfg->prcfg_hdr.ioc_len < sizeof(*cfg))
> +			return -EINVAL;
>  
>  		mutex_lock(&the_lnet.ln_api_mutex);
> -		rc = lnet_get_peer_info(cfg->prcfg_count, &cfg->prcfg_prim_nid,
> -					&cfg->prcfg_cfg_nid, &cfg->prcfg_mr,
> -					lpni_cri, lpni_stats);
> +		rc = lnet_get_peer_list(&cfg->prcfg_count, &cfg->prcfg_size,
> +					(struct lnet_process_id __user *)
> +					cfg->prcfg_bulk);
>  		mutex_unlock(&the_lnet.ln_api_mutex);
>  		return rc;
>  	}
> diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
> index 1ef4a44e752e..8dff3b767577 100644
> --- a/drivers/staging/lustre/lnet/lnet/peer.c
> +++ b/drivers/staging/lustre/lnet/lnet/peer.c
> @@ -263,9 +263,7 @@ lnet_peer_detach_peer_ni_locked(struct lnet_peer_ni *lpni)
>  
>  	/* Update peer NID count. */
>  	lp = lpn->lpn_peer;
> -	ptable = the_lnet.ln_peer_tables[lp->lp_cpt];
>  	lp->lp_nnis--;
> -	ptable->pt_peer_nnids--;
>  
>  	/*
>  	 * If there are no more peer nets, make the peer unfindable
> @@ -277,6 +275,7 @@ lnet_peer_detach_peer_ni_locked(struct lnet_peer_ni *lpni)
>  	 */
>  	if (list_empty(&lp->lp_peer_nets)) {
>  		list_del_init(&lp->lp_peer_list);
> +		ptable = the_lnet.ln_peer_tables[lp->lp_cpt];
>  		ptable->pt_peers--;
>  	} else if (the_lnet.ln_dc_state != LNET_DC_STATE_RUNNING) {
>  		/* Discovery isn't running, nothing to do here. */
> @@ -637,44 +636,6 @@ lnet_find_peer(lnet_nid_t nid)
>  	return lp;
>  }
>  
> -struct lnet_peer_ni *
> -lnet_get_peer_ni_idx_locked(int idx, struct lnet_peer_net **lpn,
> -			    struct lnet_peer **lp)
> -{
> -	struct lnet_peer_table	*ptable;
> -	struct lnet_peer_ni	*lpni;
> -	int			lncpt;
> -	int			cpt;
> -
> -	lncpt = cfs_percpt_number(the_lnet.ln_peer_tables);
> -
> -	for (cpt = 0; cpt < lncpt; cpt++) {
> -		ptable = the_lnet.ln_peer_tables[cpt];
> -		if (ptable->pt_peer_nnids > idx)
> -			break;
> -		idx -= ptable->pt_peer_nnids;
> -	}
> -	if (cpt >= lncpt)
> -		return NULL;
> -
> -	list_for_each_entry((*lp), &ptable->pt_peer_list, lp_peer_list) {
> -		if ((*lp)->lp_nnis <= idx) {
> -			idx -= (*lp)->lp_nnis;
> -			continue;
> -		}
> -		list_for_each_entry((*lpn), &((*lp)->lp_peer_nets),
> -				    lpn_peer_nets) {
> -			list_for_each_entry(lpni, &((*lpn)->lpn_peer_nis),
> -					    lpni_peer_nis) {
> -				if (idx-- == 0)
> -					return lpni;
> -			}
> -		}
> -	}
> -
> -	return NULL;
> -}
> -
>  struct lnet_peer_ni *
>  lnet_get_next_peer_ni_locked(struct lnet_peer *peer,
>  			     struct lnet_peer_net *peer_net,
> @@ -734,6 +695,69 @@ lnet_get_next_peer_ni_locked(struct lnet_peer *peer,
>  	return lpni;
>  }
>  
> +/* Call with the ln_api_mutex held */
> +int
> +lnet_get_peer_list(__u32 *countp, __u32 *sizep,
> +		   struct lnet_process_id __user *ids)
> +{
> +	struct lnet_process_id id;
> +	struct lnet_peer_table *ptable;
> +	struct lnet_peer *lp;
> +	__u32 count = 0;
> +	__u32 size = 0;
> +	int lncpt;
> +	int cpt;
> +	__u32 i;
> +	int rc;
> +
> +	rc = -ESHUTDOWN;
> +	if (the_lnet.ln_state == LNET_STATE_SHUTDOWN)
> +		goto done;
> +
> +	lncpt = cfs_percpt_number(the_lnet.ln_peer_tables);
> +
> +	/*
> +	 * Count the number of peers, and return E2BIG if the buffer
> +	 * is too small. We'll also return the desired size.
> +	 */
> +	rc = -E2BIG;
> +	for (cpt = 0; cpt < lncpt; cpt++) {
> +		ptable = the_lnet.ln_peer_tables[cpt];
> +		count += ptable->pt_peers;
> +	}
> +	size = count * sizeof(*ids);
> +	if (size > *sizep)
> +		goto done;
> +
> +	/*
> +	 * Walk the peer lists and copy out the primary nids.
> +	 * This is safe because the peer lists are only modified
> +	 * while the ln_api_mutex is held. So we don't need to
> +	 * hold the lnet_net_lock as well, and can therefore
> +	 * directly call copy_to_user().
> +	 */
> +	rc = -EFAULT;
> +	memset(&id, 0, sizeof(id));
> +	id.pid = LNET_PID_LUSTRE;
> +	i = 0;
> +	for (cpt = 0; cpt < lncpt; cpt++) {
> +		ptable = the_lnet.ln_peer_tables[cpt];
> +		list_for_each_entry(lp, &ptable->pt_peer_list, lp_peer_list) {
> +			if (i >= count)
> +				goto done;
> +			id.nid = lp->lp_primary_nid;
> +			if (copy_to_user(&ids[i], &id, sizeof(id)))
> +				goto done;
> +			i++;
> +		}
> +	}
> +	rc = 0;
> +done:
> +	*countp = count;
> +	*sizep = size;
> +	return rc;
> +}
> +
>  /*
>   * Start pushes to peers that need to be updated for a configuration
>   * change on this node.
> @@ -1128,7 +1152,6 @@ lnet_peer_attach_peer_ni(struct lnet_peer *lp,
>  	spin_unlock(&lp->lp_lock);
>  
>  	lp->lp_nnis++;
> -	the_lnet.ln_peer_tables[lp->lp_cpt]->pt_peer_nnids++;
>  	lnet_net_unlock(LNET_LOCK_EX);
>  
>  	CDEBUG(D_NET, "peer %s NID %s flags %#x\n",
> @@ -3273,55 +3296,94 @@ lnet_get_peer_ni_info(__u32 peer_index, __u64 *nid,
>  }
>  
>  /* ln_api_mutex is held, which keeps the peer list stable */
> -int lnet_get_peer_info(__u32 idx, lnet_nid_t *primary_nid, lnet_nid_t *nid,
> -		       bool *mr,
> -		       struct lnet_peer_ni_credit_info __user *peer_ni_info,
> -		       struct lnet_ioctl_element_stats __user *peer_ni_stats)
> +int lnet_get_peer_info(lnet_nid_t *primary_nid, lnet_nid_t *nidp,
> +		       __u32 *nnis, bool *mr, __u32 *sizep,
> +		       void __user *bulk)
>  {
> -	struct lnet_ioctl_element_stats ni_stats;
> -	struct lnet_peer_ni_credit_info ni_info;
> -	struct lnet_peer_ni *lpni = NULL;
> -	struct lnet_peer_net *lpn = NULL;
> -	struct lnet_peer *lp = NULL;
> +	struct lnet_ioctl_element_stats *lpni_stats;
> +	struct lnet_peer_ni_credit_info *lpni_info;
> +	struct lnet_peer_ni *lpni;
> +	struct lnet_peer *lp;
> +	lnet_nid_t nid;
> +	__u32 size;
>  	int rc;
>  
> -	lpni = lnet_get_peer_ni_idx_locked(idx, &lpn, &lp);
> +	lp = lnet_find_peer(*primary_nid);
>  
> -	if (!lpni)
> -		return -ENOENT;
> +	if (!lp) {
> +		rc = -ENOENT;
> +		goto out;
> +	}
> +
> +	size = sizeof(nid) + sizeof(*lpni_info) + sizeof(*lpni_stats);
> +	size *= lp->lp_nnis;
> +	if (size > *sizep) {
> +		*sizep = size;
> +		rc = -E2BIG;
> +		goto out_lp_decref;
> +	}
>  
>  	*primary_nid = lp->lp_primary_nid;
>  	*mr = lnet_peer_is_multi_rail(lp);
> -	*nid = lpni->lpni_nid;
> -	snprintf(ni_info.cr_aliveness, LNET_MAX_STR_LEN, "NA");
> -	if (lnet_isrouter(lpni) ||
> -	    lnet_peer_aliveness_enabled(lpni))
> -		snprintf(ni_info.cr_aliveness, LNET_MAX_STR_LEN,
> -			 lpni->lpni_alive ? "up" : "down");
> -
> -	ni_info.cr_refcount = atomic_read(&lpni->lpni_refcount);
> -	ni_info.cr_ni_peer_tx_credits = lpni->lpni_net ?
> -		lpni->lpni_net->net_tunables.lct_peer_tx_credits : 0;
> -	ni_info.cr_peer_tx_credits = lpni->lpni_txcredits;
> -	ni_info.cr_peer_rtr_credits = lpni->lpni_rtrcredits;
> -	ni_info.cr_peer_min_rtr_credits = lpni->lpni_minrtrcredits;
> -	ni_info.cr_peer_min_tx_credits = lpni->lpni_mintxcredits;
> -	ni_info.cr_peer_tx_qnob = lpni->lpni_txqnob;
> -
> -	ni_stats.iel_send_count = atomic_read(&lpni->lpni_stats.send_count);
> -	ni_stats.iel_recv_count = atomic_read(&lpni->lpni_stats.recv_count);
> -	ni_stats.iel_drop_count = atomic_read(&lpni->lpni_stats.drop_count);
> -
> -	/* If copy_to_user fails */
> -	rc = -EFAULT;
> -	if (copy_to_user(peer_ni_info, &ni_info, sizeof(ni_info)))
> -		goto copy_failed;
> +	*nidp = lp->lp_primary_nid;
> +	*nnis = lp->lp_nnis;
> +	*sizep = size;
>  
> -	if (copy_to_user(peer_ni_stats, &ni_stats, sizeof(ni_stats)))
> -		goto copy_failed;
> +	/* Allocate helper buffers. */
> +	rc = -ENOMEM;
> +	lpni_info = kzalloc(sizeof(*lpni_info), GFP_KERNEL);
> +	if (!lpni_info)
> +		goto out_lp_decref;
> +	lpni_stats = kzalloc(sizeof(*lpni_stats), GFP_KERNEL);
> +	if (!lpni_stats)
> +		goto out_free_info;
>  
> +	lpni = NULL;
> +	rc = -EFAULT;
> +	while ((lpni = lnet_get_next_peer_ni_locked(lp, NULL, lpni)) != NULL) {
> +		nid = lpni->lpni_nid;
> +		if (copy_to_user(bulk, &nid, sizeof(nid)))
> +			goto out_free_stats;
> +		bulk += sizeof(nid);
> +
> +		memset(lpni_info, 0, sizeof(*lpni_info));
> +		snprintf(lpni_info->cr_aliveness, LNET_MAX_STR_LEN, "NA");
> +		if (lnet_isrouter(lpni) ||
> +		    lnet_peer_aliveness_enabled(lpni))
> +			snprintf(lpni_info->cr_aliveness, LNET_MAX_STR_LEN,
> +				 lpni->lpni_alive ? "up" : "down");
> +
> +		lpni_info->cr_refcount = atomic_read(&lpni->lpni_refcount);
> +		lpni_info->cr_ni_peer_tx_credits = lpni->lpni_net ?
> +			lpni->lpni_net->net_tunables.lct_peer_tx_credits : 0;
> +		lpni_info->cr_peer_tx_credits = lpni->lpni_txcredits;
> +		lpni_info->cr_peer_rtr_credits = lpni->lpni_rtrcredits;
> +		lpni_info->cr_peer_min_rtr_credits = lpni->lpni_minrtrcredits;
> +		lpni_info->cr_peer_min_tx_credits = lpni->lpni_mintxcredits;
> +		lpni_info->cr_peer_tx_qnob = lpni->lpni_txqnob;
> +		if (copy_to_user(bulk, lpni_info, sizeof(*lpni_info)))
> +			goto out_free_stats;
> +		bulk += sizeof(*lpni_info);
> +
> +		memset(lpni_stats, 0, sizeof(*lpni_stats));
> +		lpni_stats->iel_send_count =
> +			atomic_read(&lpni->lpni_stats.send_count);
> +		lpni_stats->iel_recv_count =
> +			atomic_read(&lpni->lpni_stats.recv_count);
> +		lpni_stats->iel_drop_count =
> +			atomic_read(&lpni->lpni_stats.drop_count);
> +		if (copy_to_user(bulk, lpni_stats, sizeof(*lpni_stats)))
> +			goto out_free_stats;
> +		bulk += sizeof(*lpni_stats);
> +	}
>  	rc = 0;
>  
> -copy_failed:
> +out_free_stats:
> +	kfree(lpni_stats);
> +out_free_info:
> +	kfree(lpni_info);
> +out_lp_decref:
> +	lnet_peer_decref_locked(lp);
> +out:
>  	return rc;
>  }
> 
> 
> 
