From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jun 2018 02:38:28 +0100 (BST)
Subject: [lustre-devel] [PATCH 24/24] lustre: discard TCD_MAX_TYPES
In-Reply-To: <152904669094.10587.17019477478226952858.stgit@noble>
References: <152904663333.10587.10934053155404014785.stgit@noble>
 <152904669094.10587.17019477478226952858.stgit@noble>
Message-ID: <alpine.LFD.2.21.1806210237500.3886@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> As well as CFS_TCD_TYPE_CNT we have TCD_MAX_TYPES which has a larger
> value but a similar meaning.  Discard it and just use
> CFS_TCD_TYPE_CNT.
> 
> Two places relied on the fact that TCD_MAX_TYPES was larger and so
> there would be NULLs at the end of the array.  Change
> them to check the array size properly.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

Nak: This one really makes my nodes go up in flames when I mount a
file system.

> ---
>  drivers/staging/lustre/lnet/libcfs/tracefile.c |    8 ++++----
>  drivers/staging/lustre/lnet/libcfs/tracefile.h |    3 +--
>  2 files changed, 5 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.c b/drivers/staging/lustre/lnet/libcfs/tracefile.c
> index cdef67391a72..555ade0ddafb 100644
> --- a/drivers/staging/lustre/lnet/libcfs/tracefile.c
> +++ b/drivers/staging/lustre/lnet/libcfs/tracefile.c
> @@ -50,7 +50,7 @@
>  #include "tracefile.h"
>  
>  /* XXX move things up to the top, comment */
> -union cfs_trace_data_union (*cfs_trace_data[TCD_MAX_TYPES])[NR_CPUS] __cacheline_aligned;
> +union cfs_trace_data_union (*cfs_trace_data[CFS_TCD_TYPE_CNT])[NR_CPUS] __cacheline_aligned;
>  
>  char cfs_tracefile[TRACEFILE_NAME_SIZE];
>  long long cfs_tracefile_size = CFS_TRACEFILE_SIZE;
> @@ -145,8 +145,8 @@ void cfs_trace_unlock_tcd(struct cfs_trace_cpu_data *tcd, int walking)
>  		spin_unlock(&tcd->tcd_lock);
>  }
>  
> -#define cfs_tcd_for_each_type_lock(tcd, i, cpu)			   \
> -	for (i = 0; cfs_trace_data[i] &&				\
> +#define cfs_tcd_for_each_type_lock(tcd, i, cpu)				\
> +	for (i = 0; i < CFS_TCD_TYPE_CNT && cfs_trace_data[i] &&	\
>  	     (tcd = &(*cfs_trace_data[i])[cpu].tcd) &&			\
>  	     cfs_trace_lock_tcd(tcd, 1); cfs_trace_unlock_tcd(tcd, 1), i++)
>  
> @@ -1381,7 +1381,7 @@ static void cfs_trace_cleanup(void)
>  			cfs_trace_console_buffers[i][j] = NULL;
>  		}
>  
> -	for (i = 0; cfs_trace_data[i]; i++) {
> +	for (i = 0; cfs_trace_data[i] && i < CFS_TCD_TYPE_CNT; i++) {
>  		kfree(cfs_trace_data[i]);
>  		cfs_trace_data[i] = NULL;
>  	}
> diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.h b/drivers/staging/lustre/lnet/libcfs/tracefile.h
> index 23faecf886c1..a09d5b9349f0 100644
> --- a/drivers/staging/lustre/lnet/libcfs/tracefile.h
> +++ b/drivers/staging/lustre/lnet/libcfs/tracefile.h
> @@ -184,8 +184,7 @@ union cfs_trace_data_union {
>  	char __pad[L1_CACHE_ALIGN(sizeof(struct cfs_trace_cpu_data))];
>  };
>  
> -#define TCD_MAX_TYPES      8
> -extern union cfs_trace_data_union (*cfs_trace_data[TCD_MAX_TYPES])[NR_CPUS];
> +extern union cfs_trace_data_union (*cfs_trace_data[CFS_TCD_TYPE_CNT])[NR_CPUS];
>  
>  #define cfs_tcd_for_each(tcd, i, j)				       \
>  	for (i = 0; cfs_trace_data[i]; i++)				\
> 
> 
> 
