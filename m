From: James Simmons <jsimmons@infradead.org>
Date: Mon, 11 Feb 2019 00:34:45 +0000 (GMT)
Subject: [lustre-devel] [PATCH 02/21] lustre: obd_class: remove
 csi_barrier from struct cl_sync_io
In-Reply-To: <154949781242.10620.4427066512247634121.stgit@noble.brown>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
 <154949781242.10620.4427066512247634121.stgit@noble.brown>
Message-ID: <alpine.LFD.2.21.1902110026180.24975@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> This flag is used to ensure that structure isn't freed before
> the wakeup completes.  The same can be achieved using the
> csi_waitq.lock and calling wake_up_all_locked().
>

Reviewed-by: James Simmons <jsimmons@infradead.org>

> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lustre/include/cl_object.h |    2 --
>  drivers/staging/lustre/lustre/obdclass/cl_io.c    |   16 +++++++---------
>  2 files changed, 7 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
> index 71ba73cdbb5e..13d79810dd39 100644
> --- a/drivers/staging/lustre/lustre/include/cl_object.h
> +++ b/drivers/staging/lustre/lustre/include/cl_object.h
> @@ -2391,8 +2391,6 @@ struct cl_sync_io {
>  	atomic_t		csi_sync_nr;
>  	/** error code. */
>  	int			csi_sync_rc;
> -	/** barrier of destroy this structure */
> -	atomic_t		csi_barrier;
>  	/** completion to be signaled when transfer is complete. */
>  	wait_queue_head_t	csi_waitq;
>  };
> diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
> index e9ad055f84b8..beac7e8bc92a 100644
> --- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
> +++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
> @@ -1047,7 +1047,6 @@ void cl_sync_io_init(struct cl_sync_io *anchor, int nr)
>  	memset(anchor, 0, sizeof(*anchor));
>  	init_waitqueue_head(&anchor->csi_waitq);
>  	atomic_set(&anchor->csi_sync_nr, nr);
> -	atomic_set(&anchor->csi_barrier, nr > 0);
>  	anchor->csi_sync_rc = 0;
>  }
>  EXPORT_SYMBOL(cl_sync_io_init);
> @@ -1080,11 +1079,10 @@ int cl_sync_io_wait(const struct lu_env *env, struct cl_sync_io *anchor,
>  	} else {
>  		rc = anchor->csi_sync_rc;
>  	}
> +	/* We take the lock to ensure that cl_sync_io_note() has finished */
> +	spin_lock(&anchor->csi_waitq.lock);

I don't think I every seen any use the internal lock for the wait_queue
in such a method. Most creative approach.

>  	LASSERT(atomic_read(&anchor->csi_sync_nr) == 0);
> -
> -	/* wait until cl_sync_io_note() has done wakeup */
> -	while (unlikely(atomic_read(&anchor->csi_barrier) != 0))
> -		cpu_relax();
> +	spin_unlock(&anchor->csi_waitq.lock);
>  
>  	return rc;
>  }
> @@ -1104,11 +1102,11 @@ void cl_sync_io_note(const struct lu_env *env, struct cl_sync_io *anchor,
>  	 * IO.
>  	 */
>  	LASSERT(atomic_read(&anchor->csi_sync_nr) > 0);
> -	if (atomic_dec_and_test(&anchor->csi_sync_nr)) {
> +	if (atomic_dec_and_lock(&anchor->csi_sync_nr,
> +				&anchor->csi_waitq.lock)) {
>  
> -		wake_up_all(&anchor->csi_waitq);
> -		/* it's safe to nuke or reuse anchor now */
> -		atomic_set(&anchor->csi_barrier, 0);
> +		wake_up_all_locked(&anchor->csi_waitq);
> +		spin_unlock(&anchor->csi_waitq.lock);
>  
>  		/* Can't access anchor any more */
>  	}
> 
> 
> 
