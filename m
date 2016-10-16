From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Sun, 16 Oct 2016 17:14:46 +0200
Subject: [lustre-devel] [PATCH 57/80] staging: lustre: osc: revise
 unstable pages accounting
In-Reply-To: <1471378773-24590-58-git-send-email-jsimmons@infradead.org>
References: <1471378773-24590-1-git-send-email-jsimmons@infradead.org>
	<1471378773-24590-58-git-send-email-jsimmons@infradead.org>
Message-ID: <20161016151446.GA7740@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jinshan Xiong <jinshan.xiong@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

Digging up an old email...

On Tue, Aug 16, 2016 at 04:19:10PM -0400, James Simmons wrote:
> From: Jinshan Xiong <jinshan.xiong@intel.com>
> 
> A few changes are made in this patch for unstable pages tracking:
> 
> 1. Remove kernel NFS unstable pages tracking because it killed
>    performance
> 2. Track unstable pages as part of LRU cache. Otherwise Lustre
>    can use much more memory than max_cached_mb
> 3. Remove obd_unstable_pages tracking to avoid using global
>    atomic counter
> 4. Make unstable pages track optional. Tracking unstable pages is
>    turned off by default, and can be controlled by
>    llite.*.unstable_stats.
> 
> Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4841
> Reviewed-on: http://review.whamcloud.com/10003
> Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
> Reviewed-by: Lai Siyao <lai.siyao@intel.com>
> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  drivers/staging/lustre/lustre/include/cl_object.h  |   35 +++-
>  .../staging/lustre/lustre/include/obd_support.h    |    1 -
>  drivers/staging/lustre/lustre/llite/lproc_llite.c  |   41 ++++-
>  drivers/staging/lustre/lustre/obdclass/class_obd.c |    2 -
>  drivers/staging/lustre/lustre/osc/osc_cache.c      |   96 +---------
>  drivers/staging/lustre/lustre/osc/osc_internal.h   |    2 +-
>  drivers/staging/lustre/lustre/osc/osc_page.c       |  208 +++++++++++++++++---
>  drivers/staging/lustre/lustre/osc/osc_request.c    |   13 +-
>  8 files changed, 253 insertions(+), 145 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
> index d269b32..ec6cf7c 100644
> --- a/drivers/staging/lustre/lustre/include/cl_object.h
> +++ b/drivers/staging/lustre/lustre/include/cl_object.h
> @@ -1039,23 +1039,32 @@ do {									  \
>  	}								     \
>  } while (0)
>  
> -static inline int __page_in_use(const struct cl_page *page, int refc)
> -{
> -	if (page->cp_type == CPT_CACHEABLE)
> -		++refc;
> -	LASSERT(atomic_read(&page->cp_ref) > 0);
> -	return (atomic_read(&page->cp_ref) > refc);
> -}
> -
> -#define cl_page_in_use(pg)       __page_in_use(pg, 1)
> -#define cl_page_in_use_noref(pg) __page_in_use(pg, 0)
> -
>  static inline struct page *cl_page_vmpage(struct cl_page *page)
>  {
>  	LASSERT(page->cp_vmpage);
>  	return page->cp_vmpage;
>  }
>  
> +/**
> + * Check if a cl_page is in use.
> + *
> + * Client cache holds a refcount, this refcount will be dropped when
> + * the page is taken out of cache, see vvp_page_delete().
> + */
> +static inline bool __page_in_use(const struct cl_page *page, int refc)
> +{
> +	return (atomic_read(&page->cp_ref) > refc + 1);
> +}
> +
> +/**
> + * Caller itself holds a refcount of cl_page.
> + */
> +#define cl_page_in_use(pg)	 __page_in_use(pg, 1)
> +/**
> + * Caller doesn't hold a refcount.
> + */
> +#define cl_page_in_use_noref(pg) __page_in_use(pg, 0)
> +
>  /** @} cl_page */
>  
>  /** \addtogroup cl_lock cl_lock
> @@ -2331,6 +2340,10 @@ struct cl_client_cache {
>  	 */
>  	spinlock_t		ccc_lru_lock;
>  	/**
> +	 * Set if unstable check is enabled
> +	 */
> +	unsigned int		ccc_unstable_check:1;
> +	/**
>  	 * # of unstable pages for this mount point
>  	 */
>  	atomic_t		ccc_unstable_nr;
> diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
> index 26fdff6..a11fff1 100644
> --- a/drivers/staging/lustre/lustre/include/obd_support.h
> +++ b/drivers/staging/lustre/lustre/include/obd_support.h
> @@ -54,7 +54,6 @@ extern int at_early_margin;
>  extern int at_extra;
>  extern unsigned int obd_sync_filter;
>  extern unsigned int obd_max_dirty_pages;
> -extern atomic_t obd_unstable_pages;
>  extern atomic_t obd_dirty_pages;
>  extern atomic_t obd_dirty_transit_pages;
>  extern char obd_jobid_var[];
> diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
> index 2f1f389..5f8e78d 100644
> --- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
> +++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
> @@ -828,10 +828,45 @@ static ssize_t unstable_stats_show(struct kobject *kobj,
>  	pages = atomic_read(&cache->ccc_unstable_nr);
>  	mb = (pages * PAGE_SIZE) >> 20;
>  
> -	return sprintf(buf, "unstable_pages: %8d\n"
> -			    "unstable_mb:    %8d\n", pages, mb);
> +	return sprintf(buf, "unstable_check: %8d\n"
> +			    "unstable_pages: %8d\n"
> +			    "unstable_mb:    %8d\n",
> +			    cache->ccc_unstable_check, pages, mb);
>  }
> -LUSTRE_RO_ATTR(unstable_stats);
> +
> +static ssize_t unstable_stats_store(struct kobject *kobj,
> +				    struct attribute *attr,
> +				    const char *buffer,
> +				    size_t count)
> +{
> +	struct ll_sb_info *sbi = container_of(kobj, struct ll_sb_info,
> +					      ll_kobj);
> +	char kernbuf[128];
> +	int val, rc;
> +
> +	if (!count)
> +		return 0;
> +	if (count < 0 || count >= sizeof(kernbuf))
> +		return -EINVAL;
> +
> +	if (copy_from_user(kernbuf, buffer, count))
> +		return -EFAULT;

It was just pointed out to me that this code has obviously never been
tested at all.

Sorry for missing this before, do you want me to revert this?  Or will
you send me a fix?

And I think I'm going to have to be stricter now, this patch did way too
much all at once.  When you have to list the different things a patch
does, that means it needs to be broken up.  This wasn't a simple one to
review, as is obvious with everyone who missed this basic issue (myself
include.)

Also, go fix your test harness, it's not being used, or is totally buggy :)

thanks,

greg k-h
