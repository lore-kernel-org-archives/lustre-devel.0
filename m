From: NeilBrown <neilb@suse.com>
Date: Tue, 15 May 2018 13:40:27 +1000
Subject: [lustre-devel] [PATCH v2] staging: lustre: obdclass: change
 object lookup to no wait mode
In-Reply-To: <1526350548-4402-1-git-send-email-jsimmons@infradead.org>
References: <1526350548-4402-1-git-send-email-jsimmons@infradead.org>
Message-ID: <87bmdh7fis.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Lai Siyao <lai.siyao@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mon, May 14 2018, James Simmons wrote:

> From: Lai Siyao <lai.siyao@intel.com>
>
> Currently we set LU_OBJECT_HEARD_BANSHEE on object when we want
> to remove object from cache, but this may lead to deadlock, because
> when other process lookup such object, it needs to wait for this
> object until release (done at last refcount put), while that process
> maybe already hold an LDLM lock.
>
> Now that current code can handle dying object correctly, we can just
> return such object in lookup, thus the above deadlock can be avoided.
>
> Signed-off-by: Lai Siyao <lai.siyao@intel.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-9049
> Reviewed-on: https://review.whamcloud.com/26965
> Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
> Tested-by: Cliff White <cliff.white@intel.com>
> Reviewed-by: Fan Yong <fan.yong@intel.com>
> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>

Reviewed-by: NeilBrown <neilb@suse.com>

Thanks :-)

NeilBrown

> ---
> Changelog:
>
> v1) Initial patch that didn't apply to staging-testing branch
> v2) Rebased after Neil's patches landed. Remove unlikely() test
>     as requested by Dan Carpenter
>
>  drivers/staging/lustre/lustre/obdclass/lu_object.c | 39 +++++-----------------
>  1 file changed, 9 insertions(+), 30 deletions(-)
>
> diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
> index f14e350..e0abd4f 100644
> --- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
> +++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
> @@ -593,15 +593,10 @@ static struct lu_object *htable_lookup(struct lu_site *s,
>  				       const struct lu_fid *f,
>  				       __u64 *version)
>  {
> -	struct cfs_hash		*hs = s->ls_obj_hash;
>  	struct lu_site_bkt_data *bkt;
>  	struct lu_object_header *h;
>  	struct hlist_node	*hnode;
> -	__u64 ver;
> -	wait_queue_entry_t waiter;
> -
> -retry:
> -	ver = cfs_hash_bd_version_get(bd);
> +	u64 ver = cfs_hash_bd_version_get(bd);
>  
>  	if (*version == ver)
>  		return ERR_PTR(-ENOENT);
> @@ -618,31 +613,13 @@ static struct lu_object *htable_lookup(struct lu_site *s,
>  	}
>  
>  	h = container_of(hnode, struct lu_object_header, loh_hash);
> -	if (likely(!lu_object_is_dying(h))) {
> -		cfs_hash_get(s->ls_obj_hash, hnode);
> -		lprocfs_counter_incr(s->ls_stats, LU_SS_CACHE_HIT);
> -		if (!list_empty(&h->loh_lru)) {
> -			list_del_init(&h->loh_lru);
> -			percpu_counter_dec(&s->ls_lru_len_counter);
> -		}
> -		return lu_object_top(h);
> +	cfs_hash_get(s->ls_obj_hash, hnode);
> +	lprocfs_counter_incr(s->ls_stats, LU_SS_CACHE_HIT);
> +	if (!list_empty(&h->loh_lru)) {
> +		list_del_init(&h->loh_lru);
> +		percpu_counter_dec(&s->ls_lru_len_counter);
>  	}
> -
> -	/*
> -	 * Lookup found an object being destroyed this object cannot be
> -	 * returned (to assure that references to dying objects are eventually
> -	 * drained), and moreover, lookup has to wait until object is freed.
> -	 */
> -
> -	init_waitqueue_entry(&waiter, current);
> -	add_wait_queue(&bkt->lsb_marche_funebre, &waiter);
> -	set_current_state(TASK_UNINTERRUPTIBLE);
> -	lprocfs_counter_incr(s->ls_stats, LU_SS_CACHE_DEATH_RACE);
> -	cfs_hash_bd_unlock(hs, bd, 1);
> -	schedule();
> -	remove_wait_queue(&bkt->lsb_marche_funebre, &waiter);
> -	cfs_hash_bd_lock(hs, bd, 1);
> -	goto retry;
> +	return lu_object_top(h);
>  }
>  
>  /**
> @@ -683,6 +660,8 @@ static void lu_object_limit(const struct lu_env *env, struct lu_device *dev)
>  }
>  
>  /**
> + * Core logic of lu_object_find*() functions.
> + *
>   * Much like lu_object_find(), but top level device of object is specifically
>   * \a dev rather than top level device of the site. This interface allows
>   * objects of different "stacking" to be created within the same site.
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180515/e67df5b9/attachment.sig>
