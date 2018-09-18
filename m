From: NeilBrown <neilb@suse.com>
Date: Tue, 18 Sep 2018 23:14:43 +1000
Subject: [lustre-devel] [PATCH 11/30] lustre: mdc: allow setting readdir
 RPC size parameter
In-Reply-To: <1537205440-6656-12-git-send-email-jsimmons@infradead.org>
References: <1537205440-6656-1-git-send-email-jsimmons@infradead.org>
 <1537205440-6656-12-git-send-email-jsimmons@infradead.org>
Message-ID: <8736u76j7g.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Sep 17 2018, James Simmons wrote:

> From: Andreas Dilger <adilger@whamcloud.com>
>
> Allow the mdc.*.max_pages_per_rpc tunable to set the MDS bulk
> readdir RPC size, rather than always using the default 1MB RPC
> size. The tunable is set in the MDC, as it should be, rather
> than in the llite superblock, which requires extra code just to
> get it up from the MDC's connect_data only to send it back down.
> The RPC size could be tuned independently if different types of
> MDSes are used (e.g. local vs. remote).
>
> Remove the md_op_data.op_max_pages and ll_sb_info.ll_md_brw_pages
> fields that previously were used to pass the readdir size from
> llite to mdc_read_page(). Reorder some 32-bit fields in md_op_data
> to avoid struct holes.
>
> Move osc's max_pages_per_rpc_store() to obdclass along with
> max_pages_per_rpc_show().
>
> Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
> WC-bug-id: https://jira.whamcloud.com/browse/LU-3308
> Reviewed-on: https://review.whamcloud.com/26088
> Reviewed-by: Niu Yawei <yawei.niu@intel.com>
> Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
> Reviewed-by: Oleg Drokin <green@whamcloud.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  .../staging/lustre/lustre/include/lprocfs_status.h |  5 ++
>  drivers/staging/lustre/lustre/include/lustre_net.h |  8 ++--
>  drivers/staging/lustre/lustre/include/obd.h        |  5 +-
>  drivers/staging/lustre/lustre/llite/dir.c          | 12 +----
>  drivers/staging/lustre/lustre/llite/lcommon_cl.c   | 19 +++-----
>  .../staging/lustre/lustre/llite/llite_internal.h   |  2 -
>  drivers/staging/lustre/lustre/llite/llite_lib.c    |  5 --
>  drivers/staging/lustre/lustre/llite/llite_nfs.c    |  1 -
>  drivers/staging/lustre/lustre/llite/statahead.c    |  4 --
>  drivers/staging/lustre/lustre/mdc/lproc_mdc.c      | 20 +-------
>  drivers/staging/lustre/lustre/mdc/mdc_request.c    | 13 +++---
>  .../lustre/lustre/obdclass/lprocfs_status.c        | 54 ++++++++++++++++++++++
>  drivers/staging/lustre/lustre/osc/lproc_osc.c      | 46 ------------------
>  drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |  2 +-
>  14 files changed, 82 insertions(+), 114 deletions(-)
>
> diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
> index c841aba..5da26e3 100644
> --- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
> +++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
> @@ -584,6 +584,11 @@ ssize_t lustre_attr_store(struct kobject *kobj, struct attribute *attr,
>  
>  extern const struct sysfs_ops lustre_sysfs_ops;
>  
> +ssize_t max_pages_per_rpc_show(struct kobject *kobj, struct attribute *attr,
> +			       char *buf);
> +ssize_t max_pages_per_rpc_store(struct kobject *kobj, struct attribute *attr,
> +				const char *buffer, size_t count);
> +
>  struct root_squash_info;
>  int lprocfs_wr_root_squash(const char __user *buffer, unsigned long count,
>  			   struct root_squash_info *squash, char *name);
> diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
> index 2dbd208..cf630db 100644
> --- a/drivers/staging/lustre/lustre/include/lustre_net.h
> +++ b/drivers/staging/lustre/lustre/include/lustre_net.h
> @@ -104,15 +104,15 @@
>   * currently supported maximum between peers at connect via ocd_brw_size.
>   */
>  #define PTLRPC_MAX_BRW_BITS	(LNET_MTU_BITS + PTLRPC_BULK_OPS_BITS)
> -#define PTLRPC_MAX_BRW_SIZE	(1 << PTLRPC_MAX_BRW_BITS)
> +#define PTLRPC_MAX_BRW_SIZE	BIT(PTLRPC_MAX_BRW_BITS)
>  #define PTLRPC_MAX_BRW_PAGES	(PTLRPC_MAX_BRW_SIZE >> PAGE_SHIFT)
>  
> -#define ONE_MB_BRW_SIZE		(1 << LNET_MTU_BITS)
> -#define MD_MAX_BRW_SIZE		(1 << LNET_MTU_BITS)
> +#define ONE_MB_BRW_SIZE		BIT(LNET_MTU_BITS)
> +#define MD_MAX_BRW_SIZE		BIT(LNET_MTU_BITS)
>  #define MD_MAX_BRW_PAGES	(MD_MAX_BRW_SIZE >> PAGE_SHIFT)
>  #define DT_MAX_BRW_SIZE		PTLRPC_MAX_BRW_SIZE
>  #define DT_MAX_BRW_PAGES	(DT_MAX_BRW_SIZE >> PAGE_SHIFT)
> -#define OFD_MAX_BRW_SIZE	(1 << LNET_MTU_BITS)
> +#define OFD_MAX_BRW_SIZE	BIT(LNET_MTU_BITS)

Argg!!  No!!  Names are important.
"SIZE" means the value is a size, a number.  The bit-representation is
largely irrelevant, it is the number that is important.
BIT(x) returns a single bit - lots of zeros and just one '1' bit.  This
is not a number, it is a bit pattern.

So settings FOO_SIZE to BIT(bar) is wrong.  It is a type error.  It uses
a bit pattern when a number is expected.  The C compiler won't notice, but I will.

When I apply this (which probably won't be until next week), I'll just
remove this section of the patch.


>  
>  /* When PAGE_SIZE is a constant, we can check our arithmetic here with cpp! */
>  # if ((PTLRPC_MAX_BRW_PAGES & (PTLRPC_MAX_BRW_PAGES - 1)) != 0)
> diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
> index 329bae9..50e97b4 100644
> --- a/drivers/staging/lustre/lustre/include/obd.h
> +++ b/drivers/staging/lustre/lustre/include/obd.h
> @@ -717,11 +717,11 @@ struct md_op_data {
>  	struct lu_fid	   op_fid3; /* 2 extra fids to find conflicting */
>  	struct lu_fid	   op_fid4; /* to the operation locks. */
>  	u32			op_mds;  /* what mds server open will go to */
> +	u32			op_mode;
>  	struct lustre_handle    op_handle;
>  	s64			op_mod_time;
>  	const char	     *op_name;
>  	size_t			op_namelen;
> -	__u32		   op_mode;
>  	struct lmv_stripe_md   *op_mea1;
>  	struct lmv_stripe_md   *op_mea2;
>  	__u32		   op_suppgids[2];
> @@ -746,9 +746,6 @@ struct md_op_data {
>  	/* Used by readdir */
>  	__u64		   op_offset;
>  
> -	/* Used by readdir */
> -	__u32			op_max_pages;
> -
>  	/* used to transfer info between the stacks of MD client
>  	 * see enum op_cli_flags
>  	 */
> diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
> index f352fab..26b0c2d 100644
> --- a/drivers/staging/lustre/lustre/llite/dir.c
> +++ b/drivers/staging/lustre/lustre/llite/dir.c
> @@ -231,18 +231,11 @@ int ll_dir_read(struct inode *inode, __u64 *ppos, struct md_op_data *op_data,
>  			__u64	  ino;
>  
>  			hash = le64_to_cpu(ent->lde_hash);
> -			if (hash < pos)
> -				/*
> -				 * Skip until we find target hash
> -				 * value.
> -				 */
> +			if (hash < pos) /* Skip until we find target hash */
>  				continue;

If these comments are really needed (i++; /* increment i  */), then
they should be:
 if (hash < pos)
       /* skip until we find target hash */
       continue;


>  
>  			namelen = le16_to_cpu(ent->lde_namelen);
> -			if (namelen == 0)
> -				/*
> -				 * Skip dummy record.
> -				 */
> +			if (namelen == 0) /* Skip dummy record. */
>  				continue;
>  
>  			if (is_api32 && is_hash64)
> @@ -351,7 +344,6 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
>  			}
>  		}
>  	}
> -	op_data->op_max_pages = sbi->ll_md_brw_pages;
>  	ctx->pos = pos;
>  	rc = ll_dir_read(inode, &pos, op_data, ctx);
>  	pos = ctx->pos;
> diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
> index 6c9fe49..d3b0445 100644
> --- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
> +++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
> @@ -267,27 +267,22 @@ void cl_inode_fini(struct inode *inode)
>  /**
>   * build inode number from passed @fid
>   */
> -__u64 cl_fid_build_ino(const struct lu_fid *fid, int api32)
> +u64 cl_fid_build_ino(const struct lu_fid *fid, int api32)
>  {
>  	if (BITS_PER_LONG == 32 || api32)
>  		return fid_flatten32(fid);
> -	else
> -		return fid_flatten(fid);
> +
> +	return fid_flatten(fid);

I preferred that as it was - it makes the either/or nature more obvious.

NeilBrown


>  }
>  
>  /**
>   * build inode generation from passed @fid.  If our FID overflows the 32-bit
>   * inode number then return a non-zero generation to distinguish them.
>   */
> -__u32 cl_fid_build_gen(const struct lu_fid *fid)
> +u32 cl_fid_build_gen(const struct lu_fid *fid)
>  {
> -	__u32 gen;
> -
> -	if (fid_is_igif(fid)) {
> -		gen = lu_igif_gen(fid);
> -		return gen;
> -	}
> +	if (fid_is_igif(fid))
> +		return lu_igif_gen(fid);
>  
> -	gen = fid_flatten(fid) >> 32;
> -	return gen;
> +	return fid_flatten(fid) >> 32;
>  }
> diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
> index bf679c9..9d9f623 100644
> --- a/drivers/staging/lustre/lustre/llite/llite_internal.h
> +++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
> @@ -490,8 +490,6 @@ struct ll_sb_info {
>  	unsigned int	      ll_namelen;
>  	const struct file_operations	*ll_fop;
>  
> -	unsigned int		  ll_md_brw_pages; /* readdir pages per RPC */
> -
>  	struct lu_site	   *ll_site;
>  	struct cl_device	 *ll_cl;
>  	/* Statistics */
> diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
> index f0fe21f..b5bafc4 100644
> --- a/drivers/staging/lustre/lustre/llite/llite_lib.c
> +++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
> @@ -343,11 +343,6 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
>  	if (data->ocd_connect_flags & OBD_CONNECT_64BITHASH)
>  		sbi->ll_flags |= LL_SBI_64BIT_HASH;
>  
> -	if (data->ocd_connect_flags & OBD_CONNECT_BRW_SIZE)
> -		sbi->ll_md_brw_pages = data->ocd_brw_size >> PAGE_SHIFT;
> -	else
> -		sbi->ll_md_brw_pages = 1;
> -
>  	if (data->ocd_connect_flags & OBD_CONNECT_LAYOUTLOCK)
>  		sbi->ll_flags |= LL_SBI_LAYOUT_LOCK;
>  
> diff --git a/drivers/staging/lustre/lustre/llite/llite_nfs.c b/drivers/staging/lustre/lustre/llite/llite_nfs.c
> index 9efb20e..c66072a 100644
> --- a/drivers/staging/lustre/lustre/llite/llite_nfs.c
> +++ b/drivers/staging/lustre/lustre/llite/llite_nfs.c
> @@ -261,7 +261,6 @@ static int ll_get_name(struct dentry *dentry, char *name,
>  		goto out;
>  	}
>  
> -	op_data->op_max_pages = ll_i2sbi(dir)->ll_md_brw_pages;
>  	inode_lock(dir);
>  	rc = ll_dir_read(dir, &pos, op_data, &lgd.ctx);
>  	inode_unlock(dir);
> diff --git a/drivers/staging/lustre/lustre/llite/statahead.c b/drivers/staging/lustre/lustre/llite/statahead.c
> index ea2a002..1ad308c 100644
> --- a/drivers/staging/lustre/lustre/llite/statahead.c
> +++ b/drivers/staging/lustre/lustre/llite/statahead.c
> @@ -961,8 +961,6 @@ static int ll_statahead_thread(void *arg)
>  		goto out;
>  	}
>  
> -	op_data->op_max_pages = ll_i2sbi(dir)->ll_md_brw_pages;
> -
>  	while (pos != MDS_DIR_END_OFF && sai->sai_task) {
>  		struct lu_dirpage *dp;
>  		struct lu_dirent  *ent;
> @@ -1215,8 +1213,6 @@ static int is_first_dirent(struct inode *dir, struct dentry *dentry)
>  	/**
>  	 * FIXME choose the start offset of the readdir
>  	 */
> -	op_data->op_max_pages = ll_i2sbi(dir)->ll_md_brw_pages;
> -
>  	page = ll_get_dir_page(dir, op_data, pos);
>  
>  	while (1) {
> diff --git a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
> index 3bff8b5..a205c61 100644
> --- a/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
> +++ b/drivers/staging/lustre/lustre/mdc/lproc_mdc.c
> @@ -134,6 +134,8 @@ static ssize_t max_mod_rpcs_in_flight_store(struct kobject *kobj,
>  }
>  LUSTRE_RW_ATTR(max_mod_rpcs_in_flight);
>  
> +LUSTRE_RW_ATTR(max_pages_per_rpc);
> +
>  #define mdc_conn_uuid_show conn_uuid_show
>  LUSTRE_RO_ATTR(mdc_conn_uuid);
>  
> @@ -165,24 +167,6 @@ static ssize_t mdc_rpc_stats_seq_write(struct file *file,
>  LPROC_SEQ_FOPS_RO_TYPE(mdc, timeouts);
>  LPROC_SEQ_FOPS_RO_TYPE(mdc, state);
>  
> -/*
> - * Note: below sysfs entry is provided, but not currently in use, instead
> - * sbi->sb_md_brw_size is used, the per obd variable should be used
> - * when DNE is enabled, and dir pages are managed in MDC layer.
> - * Don't forget to enable sysfs store function then.
> - */
> -static ssize_t max_pages_per_rpc_show(struct kobject *kobj,
> -				      struct attribute *attr,
> -				      char *buf)
> -{
> -	struct obd_device *dev = container_of(kobj, struct obd_device,
> -					      obd_kset.kobj);
> -	struct client_obd *cli = &dev->u.cli;
> -
> -	return sprintf(buf, "%d\n", cli->cl_max_pages_per_rpc);
> -}
> -LUSTRE_RO_ATTR(max_pages_per_rpc);
> -
>  LPROC_SEQ_FOPS_RW_TYPE(mdc, import);
>  LPROC_SEQ_FOPS_RW_TYPE(mdc, pinger_recov);
>  
> diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
> index 116e973..37bf486 100644
> --- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
> +++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
> @@ -1166,17 +1166,17 @@ static int mdc_read_page_remote(void *data, struct page *page0)
>  	struct page **page_pool;
>  	struct page *page;
>  	struct lu_dirpage *dp;
> -	int rd_pgs = 0; /* number of pages read actually */
> -	int npages;
>  	struct md_op_data *op_data = rp->rp_mod;
>  	struct ptlrpc_request *req;
> -	int max_pages = op_data->op_max_pages;
>  	struct inode *inode;
>  	struct lu_fid *fid;
> -	int i;
> +	int rd_pgs = 0; /* number of pages read actually */
> +	int max_pages;
> +	int npages;
>  	int rc;
> +	int i;
>  
> -	LASSERT(max_pages > 0 && max_pages <= PTLRPC_MAX_BRW_PAGES);
> +	max_pages = rp->rp_exp->exp_obd->u.cli.cl_max_pages_per_rpc;
>  	inode = op_data->op_data;
>  	fid = &op_data->op_fid1;
>  	LASSERT(inode);
> @@ -1200,8 +1200,7 @@ static int mdc_read_page_remote(void *data, struct page *page0)
>  	if (!rc) {
>  		int lu_pgs = req->rq_bulk->bd_nob_transferred;
>  
> -		rd_pgs = (req->rq_bulk->bd_nob_transferred +
> -			  PAGE_SIZE - 1) >> PAGE_SHIFT;
> +		rd_pgs = (lu_pgs + PAGE_SIZE - 1) >> PAGE_SHIFT;
>  		lu_pgs >>= LU_PAGE_SHIFT;
>  		LASSERT(!(req->rq_bulk->bd_nob_transferred & ~LU_PAGE_MASK));
>  
> diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
> index 84e5a8c..a540abb 100644
> --- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
> +++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
> @@ -1785,3 +1785,57 @@ ssize_t lustre_attr_store(struct kobject *kobj, struct attribute *attr,
>  	.store = lustre_attr_store,
>  };
>  EXPORT_SYMBOL_GPL(lustre_sysfs_ops);
> +
> +ssize_t max_pages_per_rpc_show(struct kobject *kobj, struct attribute *attr,
> +			       char *buf)
> +{
> +	struct obd_device *dev = container_of(kobj, struct obd_device,
> +					      obd_kset.kobj);
> +	struct client_obd *cli = &dev->u.cli;
> +
> +	return sprintf(buf, "%d\n", cli->cl_max_pages_per_rpc);
> +}
> +EXPORT_SYMBOL(max_pages_per_rpc_show);
> +
> +ssize_t max_pages_per_rpc_store(struct kobject *kobj, struct attribute *attr,
> +				const char *buffer, size_t count)
> +{
> +	struct obd_device *dev = container_of(kobj, struct obd_device,
> +					      obd_kset.kobj);
> +	struct client_obd *cli = &dev->u.cli;
> +	struct obd_connect_data *ocd;
> +	unsigned long long val;
> +	int chunk_mask;
> +	int rc;
> +
> +	rc = kstrtoull(buffer, 10, &val);
> +	if (rc)
> +		return rc;
> +
> +	/* if the max_pages is specified in bytes, convert to pages */
> +	if (val >= ONE_MB_BRW_SIZE)
> +		val >>= PAGE_SHIFT;
> +
> +	rc = lprocfs_climp_check(dev);
> +	if (rc)
> +		return rc;
> +
> +	ocd = &cli->cl_import->imp_connect_data;
> +	chunk_mask = ~((1 << (cli->cl_chunkbits - PAGE_SHIFT)) - 1);
> +	/* max_pages_per_rpc must be chunk aligned */
> +	val = (val + ~chunk_mask) & chunk_mask;
> +	if (!val || (ocd->ocd_brw_size &&
> +		     val > ocd->ocd_brw_size >> PAGE_SHIFT)) {
> +		up_read(&dev->u.cli.cl_sem);
> +		return -ERANGE;
> +	}
> +
> +	spin_lock(&cli->cl_loi_list_lock);
> +	cli->cl_max_pages_per_rpc = val;
> +	client_adjust_max_dirty(cli);
> +	spin_unlock(&cli->cl_loi_list_lock);
> +
> +	up_read(&dev->u.cli.cl_sem);
> +	return count;
> +}
> +EXPORT_SYMBOL(max_pages_per_rpc_store);
> diff --git a/drivers/staging/lustre/lustre/osc/lproc_osc.c b/drivers/staging/lustre/lustre/osc/lproc_osc.c
> index cd28295..bf576f1 100644
> --- a/drivers/staging/lustre/lustre/osc/lproc_osc.c
> +++ b/drivers/staging/lustre/lustre/osc/lproc_osc.c
> @@ -570,52 +570,6 @@ static ssize_t destroys_in_flight_show(struct kobject *kobj,
>  		       atomic_read(&obd->u.cli.cl_destroy_in_flight));
>  }
>  LUSTRE_RO_ATTR(destroys_in_flight);
> -
> -static ssize_t max_pages_per_rpc_show(struct kobject *kobj,
> -				      struct attribute *attr,
> -				      char *buf)
> -{
> -	struct obd_device *dev = container_of(kobj, struct obd_device,
> -					      obd_kset.kobj);
> -	struct client_obd *cli = &dev->u.cli;
> -
> -	return sprintf(buf, "%d\n", cli->cl_max_pages_per_rpc);
> -}
> -
> -static ssize_t max_pages_per_rpc_store(struct kobject *kobj,
> -				       struct attribute *attr,
> -				       const char *buffer,
> -				       size_t count)
> -{
> -	struct obd_device *dev = container_of(kobj, struct obd_device,
> -					      obd_kset.kobj);
> -	struct client_obd *cli = &dev->u.cli;
> -	struct obd_connect_data *ocd = &cli->cl_import->imp_connect_data;
> -	int chunk_mask, rc;
> -	unsigned long long val;
> -
> -	rc = kstrtoull(buffer, 10, &val);
> -	if (rc)
> -		return rc;
> -
> -	/* if the max_pages is specified in bytes, convert to pages */
> -	if (val >= ONE_MB_BRW_SIZE)
> -		val >>= PAGE_SHIFT;
> -
> -	chunk_mask = ~((1 << (cli->cl_chunkbits - PAGE_SHIFT)) - 1);
> -	/* max_pages_per_rpc must be chunk aligned */
> -	val = (val + ~chunk_mask) & chunk_mask;
> -	if (!val || (ocd->ocd_brw_size &&
> -		     val > ocd->ocd_brw_size >> PAGE_SHIFT)) {
> -		return -ERANGE;
> -	}
> -	spin_lock(&cli->cl_loi_list_lock);
> -	cli->cl_max_pages_per_rpc = val;
> -	client_adjust_max_dirty(cli);
> -	spin_unlock(&cli->cl_loi_list_lock);
> -
> -	return count;
> -}
>  LUSTRE_RW_ATTR(max_pages_per_rpc);
>  
>  static int osc_unstable_stats_seq_show(struct seq_file *m, void *v)
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
> index 625b952..3d336d9 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
> @@ -232,7 +232,7 @@ static unsigned long enc_pools_shrink_count(struct shrinker *s,
>  	}
>  
>  	LASSERT(page_pools.epp_idle_idx <= IDLE_IDX_MAX);
> -	return max((int)page_pools.epp_free_pages - PTLRPC_MAX_BRW_PAGES, 0) *
> +	return max(page_pools.epp_free_pages - PTLRPC_MAX_BRW_PAGES, 0UL) *
>  		(IDLE_IDX_MAX - page_pools.epp_idle_idx) / IDLE_IDX_MAX;
>  }
>  
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180918/eb49df23/attachment.sig>
