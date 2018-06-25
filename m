From: NeilBrown <neilb@suse.com>
Date: Mon, 25 Jun 2018 11:09:53 +1000
Subject: [lustre-devel] [PATCH v3 19/26] staging: lustre: libcfs: report
 NUMA node instead of just node
In-Reply-To: <1529875250-11531-20-git-send-email-jsimmons@infradead.org>
References: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
 <1529875250-11531-20-git-send-email-jsimmons@infradead.org>
Message-ID: <87y3f38ye6.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Jun 24 2018, James Simmons wrote:

> From: Dmitry Eremin <dmitry.eremin@intel.com>
>
> Reporting "HW nodes" is too generic. It really is reporting
> "HW NUMA nodes". Update the debug message.

I'm not happy with this patch description.....

>
> Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
> WC-bug-id: https://jira.whamcloud.com/browse/LU-8703
> Reviewed-on: https://review.whamcloud.com/23306
> Reviewed-by: James Simmons <uja.ornl@yahoo.com>
> Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
> Reviewed-by: Patrick Farrell <paf@cray.com>
> Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
> Reviewed-by: Oleg Drokin <green@whamcloud.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h | 2 ++
>  drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c          | 2 +-
>  drivers/staging/lustre/lnet/lnet/lib-msg.c               | 2 ++
>  3 files changed, 5 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
> index 2bb2140..29c5071 100644
> --- a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
> +++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
> @@ -90,6 +90,8 @@ struct cfs_cpu_partition {
>  	unsigned int			*cpt_distance;
>  	/* spread rotor for NUMA allocator */
>  	int				cpt_spread_rotor;
> +	/* NUMA node if cpt_nodemask is empty */
> +	int				cpt_node;
>  };

It doesn't give any reason why this (unused) field was added.
So I've removed it.


>  
>  
> diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
> index 18925c7..86afa31 100644
> --- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
> +++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
> @@ -1142,7 +1142,7 @@ int cfs_cpu_init(void)
>  
>  	put_online_cpus();
>  
> -	LCONSOLE(0, "HW nodes: %d, HW CPU cores: %d, npartitions: %d\n",
> +	LCONSOLE(0, "HW NUMA nodes: %d, HW CPU cores: %d, npartitions: %d\n",
>  		 num_online_nodes(), num_online_cpus(),
>  		 cfs_cpt_number(cfs_cpt_tab));
>  	return 0;

It does explain this hunk, which is fine.


> diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
> index 0091273..27bdefa 100644
> --- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
> +++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
> @@ -568,6 +568,8 @@
>  
>  	/* number of CPUs */
>  	container->msc_nfinalizers = cfs_cpt_weight(lnet_cpt_table(), cpt);
> +	if (container->msc_nfinalizers == 0)
> +		container->msc_nfinalizers = 1;

It doesn't justify this at all.

I guess this was meant to be in the previous patch, so I've moved it.

Thanks,
NeilBrown


>  
>  	container->msc_finalizers = kvzalloc_cpt(container->msc_nfinalizers *
>  						 sizeof(*container->msc_finalizers),
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180625/f1f67ad2/attachment.sig>
