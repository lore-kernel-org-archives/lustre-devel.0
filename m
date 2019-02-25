From: Andreas Dilger <adilger@whamcloud.com>
Date: Mon, 25 Feb 2019 18:16:14 +0000
Subject: [lustre-devel] [PATCH 13/37] lustre: llog: remove lgh_hdr_lock.
In-Reply-To: <155053494552.24125.3519300273247156099.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
 <155053494552.24125.3519300273247156099.stgit@noble.brown>
Message-ID: <9D202678-E403-4A3E-B3A1-D304B7DC7298@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



> On Feb 18, 2019, at 16:09, NeilBrown <neilb@suse.com> wrote:
> 
> This lock is unused on the client (and on the server,
> it has been changed to a mutex).
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

Reviewed-by: Andreas Dilger <adilger@whamcloud.com>


> ---
> drivers/staging/lustre/lustre/include/lustre_log.h |    1 -
> drivers/staging/lustre/lustre/obdclass/llog.c      |    1 -
> 2 files changed, 2 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/include/lustre_log.h b/drivers/staging/lustre/lustre/include/lustre_log.h
> index a576d40f03f7..e96bd6ab0fa4 100644
> --- a/drivers/staging/lustre/lustre/include/lustre_log.h
> +++ b/drivers/staging/lustre/lustre/include/lustre_log.h
> @@ -212,7 +212,6 @@ struct llog_operations {
> /* In-memory descriptor for a log object or log catalog */
> struct llog_handle {
> 	struct rw_semaphore	 lgh_lock;
> -	spinlock_t		 lgh_hdr_lock; /* protect lgh_hdr data */
> 	struct llog_logid	 lgh_id; /* id of this log */
> 	struct llog_log_hdr	*lgh_hdr;
> 	size_t			 lgh_hdr_size;
> diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
> index 7aa459bb444e..9d161c16c2f9 100644
> --- a/drivers/staging/lustre/lustre/obdclass/llog.c
> +++ b/drivers/staging/lustre/lustre/obdclass/llog.c
> @@ -64,7 +64,6 @@ static struct llog_handle *llog_alloc_handle(void)
> 		return NULL;
> 
> 	init_rwsem(&loghandle->lgh_lock);
> -	spin_lock_init(&loghandle->lgh_hdr_lock);
> 	INIT_LIST_HEAD(&loghandle->u.phd.phd_entry);
> 	atomic_set(&loghandle->lgh_refcount, 1);
> 
> 
> 

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
