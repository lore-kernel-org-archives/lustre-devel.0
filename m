From: NeilBrown <neilb@suse.com>
Date: Mon, 25 Jun 2018 10:48:56 +1000
Subject: [lustre-devel] [PATCH v3 08/26] staging: lustre: libcfs: add
 cpu distance handling
In-Reply-To: <1529875250-11531-9-git-send-email-jsimmons@infradead.org>
References: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
 <1529875250-11531-9-git-send-email-jsimmons@infradead.org>
Message-ID: <874lhradxj.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Jun 24 2018, James Simmons wrote:

> From: Amir Shehata <amir.shehata@intel.com>
>
> Add functionality to calculate the distance between two CPTs.
> Expose those distance in debugfs so people deploying a setup
> can debug what is being created for CPTs.

This patch doesn't expose anything in debugfs - a later patch
does that.
So I've changed the comment to "Prepare to expose those ...."

NeilBrown


>
> Signed-off-by: Amir Shehata <amir.shehata@intel.com>
> WC-bug-id: https://jira.whamcloud.com/browse/LU-7734
> Reviewed-on: http://review.whamcloud.com/18916
> Reviewed-by: Olaf Weber <olaf@sgi.com>
> Reviewed-by: Doug Oucharek <dougso@me.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  .../lustre/include/linux/libcfs/libcfs_cpu.h       | 31 +++++++++++
>  drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c    | 61 ++++++++++++++++++++++
>  2 files changed, 92 insertions(+)
>
> diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
> index ff3ecf5..a015ac1 100644
> --- a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
> +++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
> @@ -86,6 +86,8 @@ struct cfs_cpu_partition {
>  	cpumask_var_t			cpt_cpumask;
>  	/* nodes mask for this partition */
>  	nodemask_t			*cpt_nodemask;
> +	/* NUMA distance between CPTs */
> +	unsigned int			*cpt_distance;
>  	/* spread rotor for NUMA allocator */
>  	unsigned int			cpt_spread_rotor;
>  };
> @@ -95,6 +97,8 @@ struct cfs_cpu_partition {
>  struct cfs_cpt_table {
>  	/* spread rotor for NUMA allocator */
>  	unsigned int			ctb_spread_rotor;
> +	/* maximum NUMA distance between all nodes in table */
> +	unsigned int			ctb_distance;
>  	/* # of CPU partitions */
>  	unsigned int			ctb_nparts;
>  	/* partitions tables */
> @@ -120,6 +124,10 @@ struct cfs_cpt_table {
>   */
>  int cfs_cpt_table_print(struct cfs_cpt_table *cptab, char *buf, int len);
>  /**
> + * print distance information of cpt-table
> + */
> +int cfs_cpt_distance_print(struct cfs_cpt_table *cptab, char *buf, int len);
> +/**
>   * return total number of CPU partitions in \a cptab
>   */
>  int
> @@ -149,6 +157,10 @@ struct cfs_cpt_table {
>   */
>  int cfs_cpt_of_node(struct cfs_cpt_table *cptab, int node);
>  /**
> + * NUMA distance between \a cpt1 and \a cpt2 in \a cptab
> + */
> +unsigned int cfs_cpt_distance(struct cfs_cpt_table *cptab, int cpt1, int cpt2);
> +/**
>   * bind current thread on a CPU-partition \a cpt of \a cptab
>   */
>  int cfs_cpt_bind(struct cfs_cpt_table *cptab, int cpt);
> @@ -206,6 +218,19 @@ void cfs_cpt_unset_nodemask(struct cfs_cpt_table *cptab,
>  struct cfs_cpt_table;
>  #define cfs_cpt_tab ((struct cfs_cpt_table *)NULL)
>  
> +static inline int cfs_cpt_distance_print(struct cfs_cpt_table *cptab,
> +					 char *buf, int len)
> +{
> +	int rc;
> +
> +	rc = snprintf(buf, len, "0\t: 0:1\n");
> +	len -= rc;
> +	if (len <= 0)
> +		return -EFBIG;
> +
> +	return rc;
> +}
> +
>  static inline cpumask_var_t *
>  cfs_cpt_cpumask(struct cfs_cpt_table *cptab, int cpt)
>  {
> @@ -241,6 +266,12 @@ void cfs_cpt_unset_nodemask(struct cfs_cpt_table *cptab,
>  	return NULL;
>  }
>  
> +static inline unsigned int cfs_cpt_distance(struct cfs_cpt_table *cptab,
> +					    int cpt1, int cpt2)
> +{
> +	return 1;
> +}
> +
>  static inline int
>  cfs_cpt_set_cpu(struct cfs_cpt_table *cptab, int cpt, int cpu)
>  {
> diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
> index 8c5cf7b..b315fb2 100644
> --- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
> +++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
> @@ -128,6 +128,15 @@ struct cfs_cpt_table *
>  					     GFP_NOFS);
>  		if (!part->cpt_nodemask)
>  			goto failed_setting_ctb_parts;
> +
> +		part->cpt_distance = kvmalloc_array(cptab->ctb_nparts,
> +						    sizeof(part->cpt_distance[0]),
> +						    GFP_KERNEL);
> +		if (!part->cpt_distance)
> +			goto failed_setting_ctb_parts;
> +
> +		memset(part->cpt_distance, -1,
> +		       cptab->ctb_nparts * sizeof(part->cpt_distance[0]));
>  	}
>  
>  	return cptab;
> @@ -138,6 +147,7 @@ struct cfs_cpt_table *
>  
>  		kfree(part->cpt_nodemask);
>  		free_cpumask_var(part->cpt_cpumask);
> +		kvfree(part->cpt_distance);
>  	}
>  
>  	kvfree(cptab->ctb_parts);
> @@ -168,6 +178,7 @@ struct cfs_cpt_table *
>  
>  		kfree(part->cpt_nodemask);
>  		free_cpumask_var(part->cpt_cpumask);
> +		kvfree(part->cpt_distance);
>  	}
>  
>  	kvfree(cptab->ctb_parts);
> @@ -222,6 +233,44 @@ struct cfs_cpt_table *
>  }
>  EXPORT_SYMBOL(cfs_cpt_table_print);
>  
> +int cfs_cpt_distance_print(struct cfs_cpt_table *cptab, char *buf, int len)
> +{
> +	char *tmp = buf;
> +	int rc;
> +	int i;
> +	int j;
> +
> +	for (i = 0; i < cptab->ctb_nparts; i++) {
> +		if (len <= 0)
> +			goto err;
> +
> +		rc = snprintf(tmp, len, "%d\t:", i);
> +		len -= rc;
> +
> +		if (len <= 0)
> +			goto err;
> +
> +		tmp += rc;
> +		for (j = 0; j < cptab->ctb_nparts; j++) {
> +			rc = snprintf(tmp, len, " %d:%d", j,
> +				      cptab->ctb_parts[i].cpt_distance[j]);
> +			len -= rc;
> +			if (len <= 0)
> +				goto err;
> +			tmp += rc;
> +		}
> +
> +		*tmp = '\n';
> +		tmp++;
> +		len--;
> +	}
> +
> +	return tmp - buf;
> +err:
> +	return -E2BIG;
> +}
> +EXPORT_SYMBOL(cfs_cpt_distance_print);
> +
>  int
>  cfs_cpt_number(struct cfs_cpt_table *cptab)
>  {
> @@ -273,6 +322,18 @@ struct cfs_cpt_table *
>  }
>  EXPORT_SYMBOL(cfs_cpt_nodemask);
>  
> +unsigned int cfs_cpt_distance(struct cfs_cpt_table *cptab, int cpt1, int cpt2)
> +{
> +	LASSERT(cpt1 == CFS_CPT_ANY || (cpt1 >= 0 && cpt1 < cptab->ctb_nparts));
> +	LASSERT(cpt2 == CFS_CPT_ANY || (cpt2 >= 0 && cpt2 < cptab->ctb_nparts));
> +
> +	if (cpt1 == CFS_CPT_ANY || cpt2 == CFS_CPT_ANY)
> +		return cptab->ctb_distance;
> +
> +	return cptab->ctb_parts[cpt1].cpt_distance[cpt2];
> +}
> +EXPORT_SYMBOL(cfs_cpt_distance);
> +
>  int
>  cfs_cpt_set_cpu(struct cfs_cpt_table *cptab, int cpt, int cpu)
>  {
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180625/574935ba/attachment.sig>
