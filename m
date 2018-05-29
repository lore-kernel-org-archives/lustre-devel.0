From: NeilBrown <neilb@suse.com>
Date: Wed, 30 May 2018 09:45:08 +1000
Subject: [lustre-devel] [PATCH v2 01/25] staging: lustre: libcfs:
 restore UMP handling
In-Reply-To: <1527603725-30560-2-git-send-email-jsimmons@infradead.org>
References: <1527603725-30560-1-git-send-email-jsimmons@infradead.org>
 <1527603725-30560-2-git-send-email-jsimmons@infradead.org>
Message-ID: <87muwiuiuz.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <uja.ornl@yahoo.com>, Amir Shehata <amir.shehata@intel.com>

On Tue, May 29 2018, James Simmons wrote:

> With the cleanup of the libcfs SMP handling all UMP handling
> was removed. In the process now various NULL pointers and
> empty fields are return in the UMP case which causes lustre
> to crash hard. Restore the proper UMP handling so Lustre can
> properly function.

Can't we just get lustre to handle the NULL pointer?
Is most cases, the pointer is accessed through an accessor function, and
on !CONFIG_SMP, that can be a static inline that doesn't even look at
the pointer.

I really think this is a step backwards.  If you can identify specific
problems caused by the current code, I'm sure we can fix them.

>
> Signed-off-by: James Simmons <uja.ornl@yahoo.com>
> Signed-off-by: Amir Shehata <amir.shehata@intel.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7734

This bug doesn't seem to mention this patch at all

> Reviewed-on: http://review.whamcloud.com/18916

Nor does this review.

Thanks,
NeilBrown


> Reviewed-by: Olaf Weber <olaf@sgi.com>
> Reviewed-by: Doug Oucharek <dougso@me.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
> Changelog:
>
> v1) New patch to handle the disappearence of UMP support
>
>  .../lustre/include/linux/libcfs/libcfs_cpu.h       | 87 ++++++++++++++++------
>  drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c    |  4 -
>  drivers/staging/lustre/lnet/libcfs/module.c        |  4 +
>  3 files changed, 69 insertions(+), 26 deletions(-)
>
> diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
> index 61641c4..2ad12a6 100644
> --- a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
> +++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
> @@ -74,6 +74,7 @@
>  
>  #include <linux/cpu.h>
>  #include <linux/cpuset.h>
> +#include <linux/slab.h>
>  #include <linux/topology.h>
>  
>  /* any CPU partition */
> @@ -89,10 +90,11 @@ struct cfs_cpu_partition {
>  	/* spread rotor for NUMA allocator */
>  	unsigned int			cpt_spread_rotor;
>  };
> -
> +#endif /* CONFIG_SMP */
>  
>  /** descriptor for CPU partitions */
>  struct cfs_cpt_table {
> +#ifdef CONFIG_SMP
>  	/* version, reserved for hotplug */
>  	unsigned int			ctb_version;
>  	/* spread rotor for NUMA allocator */
> @@ -103,14 +105,26 @@ struct cfs_cpt_table {
>  	struct cfs_cpu_partition	*ctb_parts;
>  	/* shadow HW CPU to CPU partition ID */
>  	int				*ctb_cpu2cpt;
> -	/* all cpus in this partition table */
> -	cpumask_var_t			ctb_cpumask;
>  	/* all nodes in this partition table */
>  	nodemask_t			*ctb_nodemask;
> +#else
> +	nodemask_t			ctb_nodemask;
> +#endif /* CONFIG_SMP */
> +	/* all cpus in this partition table */
> +	cpumask_var_t			ctb_cpumask;
>  };
>  
>  extern struct cfs_cpt_table	*cfs_cpt_tab;
>  
> +#ifdef CONFIG_SMP
> +/**
> + * destroy a CPU partition table
> + */
> +void cfs_cpt_table_free(struct cfs_cpt_table *cptab);
> +/**
> + * create a cfs_cpt_table with \a ncpt number of partitions
> + */
> +struct cfs_cpt_table *cfs_cpt_table_alloc(unsigned int ncpt);
>  /**
>   * return cpumask of CPU partition \a cpt
>   */
> @@ -208,20 +222,52 @@ void cfs_cpt_unset_nodemask(struct cfs_cpt_table *cptab,
>  void cfs_cpu_fini(void);
>  
>  #else /* !CONFIG_SMP */
> -struct cfs_cpt_table;
> -#define cfs_cpt_tab ((struct cfs_cpt_table *)NULL)
>  
> -static inline cpumask_var_t *
> -cfs_cpt_cpumask(struct cfs_cpt_table *cptab, int cpt)
> +static inline void cfs_cpt_table_free(struct cfs_cpt_table *cptab)
>  {
> -	return NULL;
> +	kfree(cptab);
>  }
>  
> -static inline int
> -cfs_cpt_table_print(struct cfs_cpt_table *cptab, char *buf, int len)
> +static inline struct cfs_cpt_table *cfs_cpt_table_alloc(int ncpt)
>  {
> -	return 0;
> +	struct cfs_cpt_table *cptab;
> +
> +	if (ncpt != 1)
> +		return NULL;
> +
> +	cptab = kzalloc(sizeof(*cptab), GFP_NOFS);
> +	if (!cptab)
> +		return NULL;
> +
> +	if (!zalloc_cpumask_var(&cptab->ctb_cpumask, GFP_NOFS)) {
> +		kfree(cptab);
> +		return NULL;
> +	}
> +	cpumask_set_cpu(0, cptab->ctb_cpumask);
> +	node_set(0, cptab->ctb_nodemask);
> +
> +	return cptab;
> +}
> +
> +static inline int cfs_cpt_table_print(struct cfs_cpt_table *cptab,
> +				      char *buf, int len)
> +{
> +	int rc;
> +
> +	rc = snprintf(buf, len, "0\t: 0\n");
> +	len -= rc;
> +	if (len <= 0)
> +		return -EFBIG;
> +
> +	return rc;
>  }
> +
> +static inline cpumask_var_t *
> +cfs_cpt_cpumask(struct cfs_cpt_table *cptab, int cpt)
> +{
> +	return &cptab->ctb_cpumask;
> +}
> +
>  static inline int
>  cfs_cpt_number(struct cfs_cpt_table *cptab)
>  {
> @@ -243,7 +289,7 @@ void cfs_cpt_unset_nodemask(struct cfs_cpt_table *cptab,
>  static inline nodemask_t *
>  cfs_cpt_nodemask(struct cfs_cpt_table *cptab, int cpt)
>  {
> -	return NULL;
> +	return &cptab->ctb_nodemask;
>  }
>  
>  static inline int
> @@ -328,24 +374,21 @@ void cfs_cpt_unset_nodemask(struct cfs_cpt_table *cptab,
>  static inline int
>  cfs_cpu_init(void)
>  {
> -	return 0;
> +	cfs_cpt_tab = cfs_cpt_table_alloc(1);
> +
> +	return cfs_cpt_tab ? 0 : -1;
>  }
>  
>  static inline void cfs_cpu_fini(void)
>  {
> +	if (cfs_cpt_tab) {
> +		cfs_cpt_table_free(cfs_cpt_tab);
> +		cfs_cpt_tab = NULL;
> +	}
>  }
>  
>  #endif /* CONFIG_SMP */
>  
> -/**
> - * destroy a CPU partition table
> - */
> -void cfs_cpt_table_free(struct cfs_cpt_table *cptab);
> -/**
> - * create a cfs_cpt_table with \a ncpt number of partitions
> - */
> -struct cfs_cpt_table *cfs_cpt_table_alloc(unsigned int ncpt);
> -
>  /*
>   * allocate per-cpu-partition data, returned value is an array of pointers,
>   * variable can be indexed by CPU ID.
> diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
> index 3d1cf45..803fc58 100644
> --- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
> +++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
> @@ -41,10 +41,6 @@
>  #include <linux/libcfs/libcfs_string.h>
>  #include <linux/libcfs/libcfs.h>
>  
> -/** Global CPU partition table */
> -struct cfs_cpt_table   *cfs_cpt_tab __read_mostly;
> -EXPORT_SYMBOL(cfs_cpt_tab);
> -
>  /**
>   * modparam for setting number of partitions
>   *
> diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
> index 5dc7de9..b438d456 100644
> --- a/drivers/staging/lustre/lnet/libcfs/module.c
> +++ b/drivers/staging/lustre/lnet/libcfs/module.c
> @@ -66,6 +66,10 @@ struct lnet_debugfs_symlink_def {
>  
>  static struct dentry *lnet_debugfs_root;
>  
> +/** Global CPU partition table */
> +struct cfs_cpt_table  *cfs_cpt_tab __read_mostly;
> +EXPORT_SYMBOL(cfs_cpt_tab);
> +
>  BLOCKING_NOTIFIER_HEAD(libcfs_ioctl_list);
>  EXPORT_SYMBOL(libcfs_ioctl_list);
>  
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180530/a5b6e092/attachment.sig>
