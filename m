From: James Simmons <jsimmons@infradead.org>
Date: Sun, 24 Feb 2019 17:53:12 +0000 (GMT)
Subject: [lustre-devel] [PATCH 18/37] lustre: obdclass: discard
 lprocfs_single/seq_release
In-Reply-To: <155053494576.24125.8952974091192338899.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
 <155053494576.24125.8952974091192338899.stgit@noble.brown>
Message-ID: <alpine.LFD.2.21.1902241752280.22752@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> Neither lprocfs_single_release() or lprocfs_seq_release()
> add any value to single_release() or seq_release() which
> they wrap.
> So just use the base functions and discard the wrapper.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/lustre/include/lprocfs_status.h |    7 ++-----
>  drivers/staging/lustre/lustre/lov/lproc_lov.c      |    2 +-
>  .../lustre/lustre/obdclass/lprocfs_status.c        |   14 +-------------
>  .../staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c    |    2 +-
>  4 files changed, 5 insertions(+), 20 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
> index d69f395e3d52..8565c28f08ee 100644
> --- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
> +++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
> @@ -502,9 +502,6 @@ unsigned long lprocfs_oh_sum(struct obd_histogram *oh);
>  void lprocfs_stats_collect(struct lprocfs_stats *stats, int idx,
>  			   struct lprocfs_counter *cnt);
>  
> -int lprocfs_single_release(struct inode *inode, struct file *file);
> -int lprocfs_seq_release(struct inode *inode, struct file *file);
> -
>  /* write the name##_seq_show function, call LPROC_SEQ_FOPS_RO for read-only
>   * proc entries; otherwise, you will define name##_seq_write function also for
>   * a read-write proc entry, and then call LPROC_SEQ_SEQ instead. Finally,
> @@ -521,7 +518,7 @@ static const struct file_operations name##_fops = {			\
>  	.read    = seq_read,						\
>  	.write   = custom_seq_write,					\
>  	.llseek  = seq_lseek,						\
> -	.release = lprocfs_single_release,				\
> +	.release = single_release,					\
>  }
>  
>  #define LPROC_SEQ_FOPS_RO(name)	 __LPROC_SEQ_FOPS(name, NULL)
> @@ -563,7 +560,7 @@ static const struct file_operations name##_fops = {			\
>  	static const struct file_operations name##_##type##_fops = {	\
>  		.open	= name##_##type##_open,				\
>  		.write	= name##_##type##_write,			\
> -		.release = lprocfs_single_release,			\
> +		.release = single_release,				\
>  	}
>  
>  struct lustre_attr {
> diff --git a/drivers/staging/lustre/lustre/lov/lproc_lov.c b/drivers/staging/lustre/lustre/lov/lproc_lov.c
> index fc53f2386c39..cfb274498d30 100644
> --- a/drivers/staging/lustre/lustre/lov/lproc_lov.c
> +++ b/drivers/staging/lustre/lustre/lov/lproc_lov.c
> @@ -264,7 +264,7 @@ static const struct file_operations lov_debugfs_target_fops = {
>  	.open		= lov_target_seq_open,
>  	.read		= seq_read,
>  	.llseek		= seq_lseek,
> -	.release	= lprocfs_seq_release,
> +	.release	= seq_release,
>  };
>  
>  static struct attribute *lov_attrs[] = {
> diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
> index bd24e48f6145..76d298337e95 100644
> --- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
> +++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
> @@ -273,18 +273,6 @@ MODULE_PARM_DESC(lprocfs_no_percpu_stats, "Do not alloc percpu data for lprocfs
>  
>  #define MAX_STRING_SIZE 128
>  
> -int lprocfs_single_release(struct inode *inode, struct file *file)
> -{
> -	return single_release(inode, file);
> -}
> -EXPORT_SYMBOL(lprocfs_single_release);
> -
> -int lprocfs_seq_release(struct inode *inode, struct file *file)
> -{
> -	return seq_release(inode, file);
> -}
> -EXPORT_SYMBOL(lprocfs_seq_release);
> -
>  /* lprocfs API calls */
>  
>  static const struct file_operations lprocfs_generic_fops = { };
> @@ -1331,7 +1319,7 @@ const struct file_operations lprocfs_stats_seq_fops = {
>  	.read		= seq_read,
>  	.write		= lprocfs_stats_seq_write,
>  	.llseek		= seq_lseek,
> -	.release	= lprocfs_seq_release,
> +	.release	= seq_release,
>  };
>  EXPORT_SYMBOL_GPL(lprocfs_stats_seq_fops);
>  
> diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
> index 25858b8f6cbd..d09bddaf88ba 100644
> --- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
> +++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
> @@ -1093,7 +1093,7 @@ void ptlrpc_ldebugfs_register_service(struct dentry *entry,
>  		.open		= ptlrpc_lprocfs_svc_req_history_open,
>  		.read		= seq_read,
>  		.llseek		= seq_lseek,
> -		.release	= lprocfs_seq_release,
> +		.release	= seq_release,
>  	};
>  
>  	ptlrpc_ldebugfs_register(entry, svc->srv_name,
> 
> 
> 
