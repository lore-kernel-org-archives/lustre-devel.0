From: James Simmons <jsimmons@infradead.org>
Date: Tue, 15 May 2018 01:37:07 +0100 (BST)
Subject: [lustre-devel] [PATCH 4/4] staging: lustre: obdclass: change
 object lookup to no wait mode
In-Reply-To: <876044fcgg.fsf@notabene.neil.brown.name>
References: <1525285308-15347-1-git-send-email-jsimmons@infradead.org>
 <1525285308-15347-5-git-send-email-jsimmons@infradead.org>
 <876044fcgg.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1805150133430.576@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, Lai Siyao <lai.siyao@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>


> On Wed, May 02 2018, James Simmons wrote:
> 
> > From: Lai Siyao <lai.siyao@intel.com>
> >
> > Currently we set LU_OBJECT_HEARD_BANSHEE on object when we want
> > to remove object from cache, but this may lead to deadlock, because
> > when other process lookup such object, it needs to wait for this
> > object until release (done at last refcount put), while that process
> > maybe already hold an LDLM lock.
> >
> > Now that current code can handle dying object correctly, we can just
> > return such object in lookup, thus the above deadlock can be avoided.
> 
> I think one of the reasons that I didn't apply this to mainline myself
> is that "Now that" comment.  When is the "now" that it is referring to?
> Are were sure that all code in mainline "can handle dying objects
> correctly"??

So I talked to Lai and he posted the LU-9049 ticket what patches need to
land before this one. Only one patch is of concern and its for LU-9203
which doesn't apply to the staging tree since we don't have the LNet SMP
updates in our tree. I saved notes about making sure LU-9203 lands 
together with the future LNet SMP changes. As it stands it is safe to
land to staging.
 
> > Signed-off-by: Lai Siyao <lai.siyao@intel.com>
> > Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-9049
> > Reviewed-on: https://review.whamcloud.com/26965
> > Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
> > Tested-by: Cliff White <cliff.white@intel.com>
> > Reviewed-by: Fan Yong <fan.yong@intel.com>
> > Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> > Signed-off-by: James Simmons <jsimmons@infradead.org>
> > ---
> >  drivers/staging/lustre/lustre/include/lu_object.h  |  2 +-
> >  drivers/staging/lustre/lustre/obdclass/lu_object.c | 82 +++++++++-------------
> >  2 files changed, 36 insertions(+), 48 deletions(-)
> >
> > diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
> > index f29bbca..232063a 100644
> > --- a/drivers/staging/lustre/lustre/include/lu_object.h
> > +++ b/drivers/staging/lustre/lustre/include/lu_object.h
> > @@ -673,7 +673,7 @@ static inline void lu_object_get(struct lu_object *o)
> >  }
> >  
> >  /**
> > - * Return true of object will not be cached after last reference to it is
> > + * Return true if object will not be cached after last reference to it is
> >   * released.
> >   */
> >  static inline int lu_object_is_dying(const struct lu_object_header *h)
> > diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
> > index 8b507f1..9311703 100644
> > --- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
> > +++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
> > @@ -589,19 +589,13 @@ static struct lu_object *htable_lookup(struct lu_site *s,
> >  				       const struct lu_fid *f,
> >  				       __u64 *version)
> >  {
> > -	struct cfs_hash		*hs = s->ls_obj_hash;
> >  	struct lu_site_bkt_data *bkt;
> >  	struct lu_object_header *h;
> >  	struct hlist_node	*hnode;
> > -	__u64 ver;
> > -	wait_queue_entry_t waiter;
> > +	u64 ver = cfs_hash_bd_version_get(bd);
> >  
> > -retry:
> > -	ver = cfs_hash_bd_version_get(bd);
> > -
> > -	if (*version == ver) {
> > +	if (*version == ver)
> >  		return ERR_PTR(-ENOENT);
> > -	}
> >  
> >  	*version = ver;
> >  	bkt = cfs_hash_bd_extra_get(s->ls_obj_hash, bd);
> > @@ -615,31 +609,13 @@ static struct lu_object *htable_lookup(struct lu_site *s,
> >  	}
> >  
> >  	h = container_of(hnode, struct lu_object_header, loh_hash);
> > -	if (likely(!lu_object_is_dying(h))) {
> > -		cfs_hash_get(s->ls_obj_hash, hnode);
> > -		lprocfs_counter_incr(s->ls_stats, LU_SS_CACHE_HIT);
> > -		if (!list_empty(&h->loh_lru)) {
> > -			list_del_init(&h->loh_lru);
> > -			percpu_counter_dec(&s->ls_lru_len_counter);
> > -		}
> > -		return lu_object_top(h);
> > +	cfs_hash_get(s->ls_obj_hash, hnode);
> > +	lprocfs_counter_incr(s->ls_stats, LU_SS_CACHE_HIT);
> > +	if (!list_empty(&h->loh_lru)) {
> > +		list_del_init(&h->loh_lru);
> > +		percpu_counter_dec(&s->ls_lru_len_counter);
> >  	}
> > -
> > -	/*
> > -	 * Lookup found an object being destroyed this object cannot be
> > -	 * returned (to assure that references to dying objects are eventually
> > -	 * drained), and moreover, lookup has to wait until object is freed.
> > -	 */
> > -
> > -	init_waitqueue_entry(&waiter, current);
> > -	add_wait_queue(&bkt->lsb_marche_funebre, &waiter);
> > -	set_current_state(TASK_UNINTERRUPTIBLE);
> > -	lprocfs_counter_incr(s->ls_stats, LU_SS_CACHE_DEATH_RACE);
> > -	cfs_hash_bd_unlock(hs, bd, 1);
> > -	schedule();
> > -	remove_wait_queue(&bkt->lsb_marche_funebre, &waiter);
> > -	cfs_hash_bd_lock(hs, bd, 1);
> > -	goto retry;
> > +	return lu_object_top(h);
> >  }
> >  
> >  /**
> > @@ -680,6 +656,8 @@ static void lu_object_limit(const struct lu_env *env, struct lu_device *dev)
> >  }
> >  
> >  /**
> > + * Core logic of lu_object_find*() functions.
> > + *
> >   * Much like lu_object_find(), but top level device of object is specifically
> >   * \a dev rather than top level device of the site. This interface allows
> >   * objects of different "stacking" to be created within the same site.
> > @@ -713,36 +691,46 @@ struct lu_object *lu_object_find_at(const struct lu_env *env,
> >  	 * It is unnecessary to perform lookup-alloc-lookup-insert, instead,
> >  	 * just alloc and insert directly.
> >  	 *
> > +	 * If dying object is found during index search, add @waiter to the
> > +	 * site wait-queue and return ERR_PTR(-EAGAIN).
> 
> It seems odd to add this comment here, when it seems to describe code
> that is being removed.
> I can see that this comment is added by the upstream patch
> Commit: fa14bdf6b648 ("LU-9049 obdclass: change object lookup to no wait mode")
> but I cannot see what it refers to.
> 
> Otherwise that patch looks good.
> 
> Thanks,
> NeilBrown
> 
