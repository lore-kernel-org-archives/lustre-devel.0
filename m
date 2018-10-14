From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 20:58:21 +0100 (BST)
Subject: [lustre-devel] [PATCH 09/24] lustre: lnet: refactor
 lnet_del_peer_ni()
In-Reply-To: <153895437789.16383.3567353433359493775.stgit@noble>
References: <153895417139.16383.3791701638653772865.stgit@noble>
 <153895437789.16383.3567353433359493775.stgit@noble>
Message-ID: <alpine.LFD.2.21.1810142057540.9543@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> From: Olaf Weber <olaf@sgi.com>
> 
> Refactor lnet_del_peer_ni(). In particular break out the code
> that removes an lnet_peer_ni from an lnet_peer and put it into
> a separate function, lnet_peer_del_nid().

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> WC-bug-id: https://jira.whamcloud.com/browse/LU-9480
> Signed-off-by: Olaf Weber <olaf@sgi.com>
> Reviewed-on: https://review.whamcloud.com/25779
> Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
> Reviewed-by: Amir Shehata <amir.shehata@intel.com>
> Tested-by: Amir Shehata <amir.shehata@intel.com>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lnet/lnet/peer.c |   96 +++++++++++++++++++++++--------
>  1 file changed, 71 insertions(+), 25 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
> index bbf07008dbb0..30a2486712e4 100644
> --- a/drivers/staging/lustre/lnet/lnet/peer.c
> +++ b/drivers/staging/lustre/lnet/lnet/peer.c
> @@ -254,7 +254,7 @@ lnet_peer_ni_del_locked(struct lnet_peer_ni *lpni)
>  	 *
>  	 * The last reference may be lost in a place where the
>  	 * lnet_net_lock locks only a single cpt, and that cpt may not
> -	 * be lpni->lpni_cpt. So the zombie list of this peer_table
> +	 * be lpni->lpni_cpt. So the zombie list of lnet_peer_table
>  	 * has its own lock.
>  	 */
>  	spin_lock(&ptable->pt_zombie_lock);
> @@ -340,6 +340,61 @@ lnet_peer_del_locked(struct lnet_peer *peer)
>  	return rc2;
>  }
>  
> +static int
> +lnet_peer_del(struct lnet_peer *peer)
> +{
> +	lnet_net_lock(LNET_LOCK_EX);
> +	lnet_peer_del_locked(peer);
> +	lnet_net_unlock(LNET_LOCK_EX);
> +
> +	return 0;
> +}
> +
> +/*
> + * Delete a NID from a peer.
> + * Implements a few sanity checks.
> + * Call with ln_api_mutex held.
> + */
> +static int
> +lnet_peer_del_nid(struct lnet_peer *lp, lnet_nid_t nid)
> +{
> +	struct lnet_peer *lp2;
> +	struct lnet_peer_ni *lpni;
> +
> +	lpni = lnet_find_peer_ni_locked(nid);
> +	if (!lpni) {
> +		CERROR("Cannot remove unknown nid %s from peer %s\n",
> +		       libcfs_nid2str(nid),
> +		       libcfs_nid2str(lp->lp_primary_nid));
> +		return -ENOENT;
> +	}
> +	lnet_peer_ni_decref_locked(lpni);
> +	lp2 = lpni->lpni_peer_net->lpn_peer;
> +	if (lp2 != lp) {
> +		CERROR("Nid %s is attached to peer %s, not peer %s\n",
> +		       libcfs_nid2str(nid),
> +		       libcfs_nid2str(lp2->lp_primary_nid),
> +		       libcfs_nid2str(lp->lp_primary_nid));
> +		return -EINVAL;
> +	}
> +
> +	/*
> +	 * This function only allows deletion of the primary NID if it
> +	 * is the only NID.
> +	 */
> +	if (nid == lp->lp_primary_nid && lnet_get_num_peer_nis(lp) != 1) {
> +		CERROR("Cannot delete primary NID %s from multi-NID peer\n",
> +		       libcfs_nid2str(nid));
> +		return -EINVAL;
> +	}
> +
> +	lnet_net_lock(LNET_LOCK_EX);
> +	lnet_peer_ni_del_locked(lpni);
> +	lnet_net_unlock(LNET_LOCK_EX);
> +
> +	return 0;
> +}
> +
>  static void
>  lnet_peer_table_cleanup_locked(struct lnet_net *net,
>  			       struct lnet_peer_table *ptable)
> @@ -938,45 +993,36 @@ lnet_add_peer_ni(lnet_nid_t prim_nid, lnet_nid_t nid, bool mr)
>   *   Delete a NI from a peer if both prim_nid and nid are provided.
>   *   Delete a peer if only prim_nid is provided.
>   *   Delete a peer if its primary nid is provided.
> + *
> + * The caller must hold ln_api_mutex. This prevents the peer from
> + * being modified/deleted by a different thread.
>   */
>  int
>  lnet_del_peer_ni(lnet_nid_t prim_nid, lnet_nid_t nid)
>  {
> -	lnet_nid_t local_nid;
> -	struct lnet_peer *peer;
> +	struct lnet_peer *lp;
>  	struct lnet_peer_ni *lpni;
> -	int rc;
>  
>  	if (prim_nid == LNET_NID_ANY)
>  		return -EINVAL;
>  
> -	local_nid = (nid != LNET_NID_ANY) ? nid : prim_nid;
> -
> -	lpni = lnet_find_peer_ni_locked(local_nid);
> +	lpni = lnet_find_peer_ni_locked(prim_nid);
>  	if (!lpni)
> -		return -EINVAL;
> +		return -ENOENT;
>  	lnet_peer_ni_decref_locked(lpni);
> +	lp = lpni->lpni_peer_net->lpn_peer;
>  
> -	peer = lpni->lpni_peer_net->lpn_peer;
> -	LASSERT(peer);
> -
> -	if (peer->lp_primary_nid == lpni->lpni_nid) {
> -		/*
> -		 * deleting the primary ni is equivalent to deleting the
> -		 * entire peer
> -		 */
> -		lnet_net_lock(LNET_LOCK_EX);
> -		rc = lnet_peer_del_locked(peer);
> -		lnet_net_unlock(LNET_LOCK_EX);
> -
> -		return rc;
> +	if (prim_nid != lp->lp_primary_nid) {
> +		CDEBUG(D_NET, "prim_nid %s is not primary for peer %s\n",
> +		       libcfs_nid2str(prim_nid),
> +		       libcfs_nid2str(lp->lp_primary_nid));
> +		return -ENODEV;
>  	}
>  
> -	lnet_net_lock(LNET_LOCK_EX);
> -	rc = lnet_peer_ni_del_locked(lpni);
> -	lnet_net_unlock(LNET_LOCK_EX);
> +	if (nid == LNET_NID_ANY || nid == lp->lp_primary_nid)
> +		return lnet_peer_del(lp);
>  
> -	return rc;
> +	return lnet_peer_del_nid(lp, nid);
>  }
>  
>  void
> 
> 
> 
