From: James Simmons <jsimmons@infradead.org>
Date: Tue, 11 Sep 2018 02:02:58 +0100 (BST)
Subject: [lustre-devel] [PATCH 09/34] lnet: add list of cpts to lnet_net.
In-Reply-To: <153628137159.8267.921309094971745898.stgit@noble>
References: <153628058697.8267.6056114844033479774.stgit@noble>
 <153628137159.8267.921309094971745898.stgit@noble>
Message-ID: <alpine.LFD.2.21.1809110202160.29662@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> struct lnet_net now has a list of cpts, which is the union
> of the cpts for each lnet_ni.

Reviewed-by: James Simmons <jsimmons@infradead.org>
The below needs fixing based on response to cover letter.
 
> This is part of
>     8cbb8cd3e771e7f7e0f99cafc19fad32770dc015
>        LU-7734 lnet: Multi-Rail local NI split
>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/include/linux/lnet/lib-types.h  |    6 +
>  drivers/staging/lustre/lnet/lnet/config.c          |  164 ++++++++++++++++++++
>  2 files changed, 170 insertions(+)
> 
> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> index 2d2c066a11ba..22957d142cc0 100644
> --- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
> +++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
> @@ -266,6 +266,12 @@ struct lnet_net {
>  	 * lnet/include/lnet/nidstr.h */
>  	__u32			net_id;
>  
> +	/* total number of CPTs in the array */
> +	__u32			net_ncpts;
> +
> +	/* cumulative CPTs of all NIs in this net */
> +	__u32			*net_cpts;
> +
>  	/* network tunables */
>  	struct lnet_ioctl_config_lnd_cmn_tunables net_tunables;
>  
> diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
> index e83bdbec11e3..380a3fb1caba 100644
> --- a/drivers/staging/lustre/lnet/lnet/config.c
> +++ b/drivers/staging/lustre/lnet/lnet/config.c
> @@ -91,11 +91,169 @@ lnet_net_unique(__u32 net, struct list_head *netlist)
>  	return true;
>  }
>  
> +static bool
> +in_array(__u32 *array, __u32 size, __u32 value)
> +{
> +	int i;
> +
> +	for (i = 0; i < size; i++) {
> +		if (array[i] == value)
> +			return false;
> +	}
> +
> +	return true;
> +}
> +
> +static int
> +lnet_net_append_cpts(__u32 *cpts, __u32 ncpts, struct lnet_net *net)
> +{
> +	__u32 *added_cpts = NULL;
> +	int i, j = 0, rc = 0;
> +
> +	/*
> +	 * no need to go futher since a subset of the NIs already exist on
> +	 * all CPTs
> +	 */
> +	if (net->net_ncpts == LNET_CPT_NUMBER)
> +		return 0;
> +
> +	if (cpts == NULL) {
> +		/* there is an NI which will exist on all CPTs */
> +		if (net->net_cpts != NULL)
> +			kvfree(net->net_cpts);
> +		net->net_cpts = NULL;
> +		net->net_ncpts = LNET_CPT_NUMBER;
> +		return 0;
> +	}
> +
> +	if (net->net_cpts == NULL) {
> +		net->net_cpts = kmalloc_array(ncpts, sizeof(net->net_cpts),
> +					      GFP_KERNEL);
> +		if (net->net_cpts == NULL)
> +			return -ENOMEM;
> +		memcpy(net->net_cpts, cpts, ncpts);
> +		return 0;
> +	}
> +
> +	added_cpts = kmalloc_array(LNET_CPT_NUMBER, sizeof(*added_cpts),
> +				   GFP_KERNEL);
> +	if (added_cpts == NULL)
> +		return -ENOMEM;
> +
> +	for (i = 0; i < ncpts; i++) {
> +		if (!in_array(net->net_cpts, net->net_ncpts, cpts[i])) {
> +			added_cpts[j] = cpts[i];
> +			j++;
> +		}
> +	}
> +
> +	/* append the new cpts if any to the list of cpts in the net */
> +	if (j > 0) {
> +		__u32 *array = NULL, *loc;
> +		__u32 total_entries = j + net->net_ncpts;
> +
> +		array = kmalloc_array(total_entries, sizeof(*net->net_cpts),
> +				      GFP_KERNEL);
> +		if (array == NULL) {
> +			rc = -ENOMEM;
> +			goto failed;
> +		}
> +
> +		memcpy(array, net->net_cpts,
> +		       net->net_ncpts * sizeof(*net->net_cpts));
> +		loc = array + net->net_ncpts;
> +		memcpy(loc, added_cpts, j * sizeof(*net->net_cpts));
> +
> +		kfree(net->net_cpts);
> +		net->net_ncpts = total_entries;
> +		net->net_cpts = array;
> +	}
> +
> +failed:
> +	kfree(added_cpts);
> +
> +	return rc;
> +}
> +
> +static void
> +lnet_net_remove_cpts(__u32 *cpts, __u32 ncpts, struct lnet_net *net)
> +{
> +	struct lnet_ni *ni;
> +	int rc;
> +
> +	/*
> +	 * Operation Assumption:
> +	 *	This function is called after an NI has been removed from
> +	 *	its parent net.
> +	 *
> +	 * if we're removing an NI which exists on all CPTs then
> +	 * we have to check if any of the other NIs on this net also
> +	 * exists on all CPTs. If none, then we need to build our Net CPT
> +	 * list based on the remaining NIs.
> +	 *
> +	 * If the NI being removed exist on a subset of the CPTs then we
> +	 * alo rebuild the Net CPT list based on the remaining NIs, which
> +	 * should resutl in the expected Net CPT list.
> +	 */
> +
> +	/*
> +	 * sometimes this function can be called due to some failure
> +	 * creating an NI, before any of the cpts are allocated, so check
> +	 * for that case and don't do anything
> +	 */
> +	if (ncpts == 0)
> +		return;
> +
> +	if (ncpts == LNET_CPT_NUMBER) {
> +		/*
> +		 * first iteration through the NI list in the net to see
> +		 * if any of the NIs exist on all the CPTs. If one is
> +		 * found then our job is done.
> +		 */
> +		list_for_each_entry(ni, &net->net_ni_list, ni_netlist) {
> +			if (ni->ni_ncpts == LNET_CPT_NUMBER)
> +				return;
> +		}
> +	}
> +
> +	/*
> +	 * Rebuild the Net CPT list again, thereby only including only the
> +	 * CPTs which the remaining NIs are associated with.
> +	 */
> +	if (net->net_cpts != NULL) {
> +		kfree(net->net_cpts);
> +		net->net_cpts = NULL;
> +	}
> +
> +	list_for_each_entry(ni, &net->net_ni_list, ni_netlist) {
> +		rc = lnet_net_append_cpts(ni->ni_cpts, ni->ni_ncpts,
> +					  net);
> +		if (rc != 0) {
> +			CERROR("Out of Memory\n");
> +			/*
> +			 * do our best to keep on going. Delete
> +			 * the net cpts and set it to NULL. This
> +			 * way we can keep on going but less
> +			 * efficiently, since memory accesses might be
> +			 * accross CPT lines.
> +			 */
> +			if (net->net_cpts != NULL) {
> +				kfree(net->net_cpts);
> +				net->net_cpts = NULL;
> +				net->net_ncpts = LNET_CPT_NUMBER;
> +			}
> +			return;
> +		}
> +	}
> +}
> +
>  void
>  lnet_ni_free(struct lnet_ni *ni)
>  {
>  	int i;
>  
> +	lnet_net_remove_cpts(ni->ni_cpts, ni->ni_ncpts, ni->ni_net);
> +
>  	if (ni->ni_refs)
>  		cfs_percpt_free(ni->ni_refs);
>  
> @@ -128,6 +286,9 @@ lnet_net_free(struct lnet_net *net)
>  		lnet_ni_free(ni);
>  	}
>  
> +	if (net->net_cpts != NULL)
> +		kfree(net->net_cpts);
> +
>  	kfree(net);
>  }
>  
> @@ -229,6 +390,9 @@ lnet_ni_alloc(struct lnet_net *net, struct cfs_expr_list *el, char *iface)
>  		ni->ni_net_ns = NULL;
>  
>  	ni->ni_last_alive = ktime_get_real_seconds();
> +	rc = lnet_net_append_cpts(ni->ni_cpts, ni->ni_ncpts, net);
> +	if (rc != 0)
> +		goto failed;
>  	list_add_tail(&ni->ni_netlist, &net->net_ni_list);
>  
>  	return ni;
> 
> 
> 
