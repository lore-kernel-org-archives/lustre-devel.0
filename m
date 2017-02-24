From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 24 Feb 2017 17:58:29 +0100
Subject: [lustre-devel] [PATCH 12/14] staging: lustre: llog: change
	lgh_hdr_lock to mutex
In-Reply-To: <1487454435-4895-13-git-send-email-jsimmons@infradead.org>
References: <1487454435-4895-1-git-send-email-jsimmons@infradead.org>
	<1487454435-4895-13-git-send-email-jsimmons@infradead.org>
Message-ID: <20170224165829.GA9990@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, wang di <di.wang@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Sat, Feb 18, 2017 at 04:47:13PM -0500, James Simmons wrote:
> From: wang di <di.wang@intel.com>
> 
> Change lgh_hdr_lock from spinlock to mutex because if
> the llog object is a remote object it can be stalled
> while being fetched.

but this lock is never even used!  Why have it at all?

> 
> Signed-off-by: wang di <di.wang@intel.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6602
> Reviewed-on: http://review.whamcloud.com/15274
> Reviewed-by: James Simmons <uja.ornl@yahoo.com>
> Reviewed-by: Lai Siyao <lai.siyao@intel.com>
> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  drivers/staging/lustre/lustre/include/lustre_log.h | 2 +-
>  drivers/staging/lustre/lustre/obdclass/llog.c      | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/include/lustre_log.h b/drivers/staging/lustre/lustre/include/lustre_log.h
> index 35e37eb..33f56ff 100644
> --- a/drivers/staging/lustre/lustre/include/lustre_log.h
> +++ b/drivers/staging/lustre/lustre/include/lustre_log.h
> @@ -211,7 +211,7 @@ struct llog_operations {
>  /* In-memory descriptor for a log object or log catalog */
>  struct llog_handle {
>  	struct rw_semaphore	 lgh_lock;
> -	spinlock_t		 lgh_hdr_lock; /* protect lgh_hdr data */
> +	struct mutex		 lgh_hdr_mutex; /* protect lgh_hdr data */
>  	struct llog_logid	 lgh_id; /* id of this log */
>  	struct llog_log_hdr	*lgh_hdr;
>  	size_t			 lgh_hdr_size;
> diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
> index 736ea10..83c5b62 100644
> --- a/drivers/staging/lustre/lustre/obdclass/llog.c
> +++ b/drivers/staging/lustre/lustre/obdclass/llog.c
> @@ -61,7 +61,7 @@ static struct llog_handle *llog_alloc_handle(void)
>  		return NULL;
>  
>  	init_rwsem(&loghandle->lgh_lock);
> -	spin_lock_init(&loghandle->lgh_hdr_lock);
> +	mutex_init(&loghandle->lgh_hdr_mutex);

Can't we delete it?

thanks,

greg k-h
