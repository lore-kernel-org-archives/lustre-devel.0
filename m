From: James Simmons <jsimmons@infradead.org>
Date: Tue, 26 Jun 2018 01:42:20 +0100 (BST)
Subject: [lustre-devel] [PATCH v3 13/26] staging: lustre: libcfs: use
 int type for CPT identification.
In-Reply-To: <871scvadj6.fsf@notabene.neil.brown.name>
References: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
 <1529875250-11531-14-git-send-email-jsimmons@infradead.org>
 <871scvadj6.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1806260140480.31196@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> > From: Dmitry Eremin <dmitry.eremin@intel.com>
> >
> > Use int type for CPT identification to match the linux kernel
> > CPU identification.
> 
> Can someone site evidence for "int" being the dominant choice for CPU
> identification in the kernel?
> I looked in cpumask.h and found plenty of "unsigned int".
> I also found
> 
> Commit: 9b130ad5bb82 ("treewide: make "nr_cpu_ids" unsigned")
> 
> which makes nr_cpu_ids unsigned.
> 
> So I'm dropping this patch for now as the justification is not
> convincing.
> 
> If there is a real case to be made, please resubmit.

Honestly using int doesn't make sense to me but Dmitry got the
impresssion that using int was more correct. Dmitry where did
you get that information about using int from?

> > Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
> > WC-bug-id: https://jira.whamcloud.com/browse/LU-8703
> > Reviewed-on: https://review.whamcloud.com/23304
> > Reviewed-by: James Simmons <uja.ornl@yahoo.com>
> > Reviewed-by: Doug Oucharek <dougso@me.com>
> > Reviewed-by: Oleg Drokin <green@whamcloud.com>
> > Signed-off-by: James Simmons <jsimmons@infradead.org>
> > ---
> >  drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h |  8 ++++----
> >  drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c          | 14 +++++++-------
> >  2 files changed, 11 insertions(+), 11 deletions(-)
> >
> > diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
> > index 9dbb0b1..2bb2140 100644
> > --- a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
> > +++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
> > @@ -89,18 +89,18 @@ struct cfs_cpu_partition {
> >  	/* NUMA distance between CPTs */
> >  	unsigned int			*cpt_distance;
> >  	/* spread rotor for NUMA allocator */
> > -	unsigned int			cpt_spread_rotor;
> > +	int				cpt_spread_rotor;
> >  };
> >  
> >  
> >  /** descriptor for CPU partitions */
> >  struct cfs_cpt_table {
> >  	/* spread rotor for NUMA allocator */
> > -	unsigned int			ctb_spread_rotor;
> > +	int				ctb_spread_rotor;
> >  	/* maximum NUMA distance between all nodes in table */
> >  	unsigned int			ctb_distance;
> >  	/* # of CPU partitions */
> > -	unsigned int			ctb_nparts;
> > +	int				ctb_nparts;
> >  	/* partitions tables */
> >  	struct cfs_cpu_partition	*ctb_parts;
> >  	/* shadow HW CPU to CPU partition ID */
> > @@ -355,7 +355,7 @@ static inline void cfs_cpu_fini(void)
> >  /**
> >   * create a cfs_cpt_table with \a ncpt number of partitions
> >   */
> > -struct cfs_cpt_table *cfs_cpt_table_alloc(unsigned int ncpt);
> > +struct cfs_cpt_table *cfs_cpt_table_alloc(int ncpt);
> >  
> >  /*
> >   * allocate per-cpu-partition data, returned value is an array of pointers,
> > diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
> > index aaab7cb..8f7de59 100644
> > --- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
> > +++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
> > @@ -73,7 +73,7 @@
> >  module_param(cpu_pattern, charp, 0444);
> >  MODULE_PARM_DESC(cpu_pattern, "CPU partitions pattern");
> >  
> > -struct cfs_cpt_table *cfs_cpt_table_alloc(unsigned int ncpt)
> > +struct cfs_cpt_table *cfs_cpt_table_alloc(int ncpt)
> >  {
> >  	struct cfs_cpt_table *cptab;
> >  	int i;
> > @@ -788,13 +788,13 @@ static int cfs_cpt_choose_ncpus(struct cfs_cpt_table *cptab, int cpt,
> >  	return rc;
> >  }
> >  
> > -#define CPT_WEIGHT_MIN  4u
> > +#define CPT_WEIGHT_MIN 4
> >  
> > -static unsigned int cfs_cpt_num_estimate(void)
> > +static int cfs_cpt_num_estimate(void)
> >  {
> > -	unsigned int nnode = num_online_nodes();
> > -	unsigned int ncpu = num_online_cpus();
> > -	unsigned int ncpt;
> > +	int nnode = num_online_nodes();
> > +	int ncpu = num_online_cpus();
> > +	int ncpt;
> >  
> >  	if (ncpu <= CPT_WEIGHT_MIN) {
> >  		ncpt = 1;
> > @@ -824,7 +824,7 @@ static unsigned int cfs_cpt_num_estimate(void)
> >  	/* config many CPU partitions on 32-bit system could consume
> >  	 * too much memory
> >  	 */
> > -	ncpt = min(2U, ncpt);
> > +	ncpt = min(2, ncpt);
> >  #endif
> >  	while (ncpu % ncpt)
> >  		ncpt--; /* worst case is 1 */
> > -- 
> > 1.8.3.1
> 
