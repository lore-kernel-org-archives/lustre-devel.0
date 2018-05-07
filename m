From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Sun, 6 May 2018 18:42:51 -0700
Subject: [lustre-devel] [PATCH 02/10] staging: lustre: make struct
 lu_site_bkt_data private
In-Reply-To: <87muxgfgx3.fsf@notabene.neil.brown.name>
References: <152514658325.17843.11455067361317157487.stgit@noble>
 <152514675889.17843.8198702967686860985.stgit@noble>
 <alpine.LFD.2.21.1805020400400.2551@casper.infradead.org>
 <87muxgfgx3.fsf@notabene.neil.brown.name>
Message-ID: <20180507014251.GB29421@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: James Simmons <jsimmons@infradead.org>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Fri, May 04, 2018 at 09:39:04AM +1000, NeilBrown wrote:
> On Wed, May 02 2018, James Simmons wrote:
> 
> >> This data structure only needs to be public so that
> >> various modules can access a wait queue to wait for object
> >> destruction.
> >> If we provide a function to get the wait queue, rather than the
> >> whole bucket, the structure can be made private.
> >> 
> >> Signed-off-by: NeilBrown <neilb@suse.com>
> >> ---
> >>  drivers/staging/lustre/lustre/include/lu_object.h  |   36 +-------------
> >>  drivers/staging/lustre/lustre/llite/lcommon_cl.c   |    8 ++-
> >>  drivers/staging/lustre/lustre/lov/lov_object.c     |    8 ++-
> >>  drivers/staging/lustre/lustre/obdclass/lu_object.c |   50 +++++++++++++++++---
> >>  4 files changed, 54 insertions(+), 48 deletions(-)
> >> 
> >> diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
> >> index c3b0ed518819..f29bbca5af65 100644
> >> --- a/drivers/staging/lustre/lustre/include/lu_object.h
> >> +++ b/drivers/staging/lustre/lustre/include/lu_object.h
> >> @@ -549,31 +549,7 @@ struct lu_object_header {
> >>  };
> >>  
> >>  struct fld;
> >> -
> >> -struct lu_site_bkt_data {
> >> -	/**
> >> -	 * number of object in this bucket on the lsb_lru list.
> >> -	 */
> >> -	long			lsb_lru_len;
> >> -	/**
> >> -	 * LRU list, updated on each access to object. Protected by
> >> -	 * bucket lock of lu_site::ls_obj_hash.
> >> -	 *
> >> -	 * "Cold" end of LRU is lu_site::ls_lru.next. Accessed object are
> >> -	 * moved to the lu_site::ls_lru.prev (this is due to the non-existence
> >> -	 * of list_for_each_entry_safe_reverse()).
> >> -	 */
> >> -	struct list_head		lsb_lru;
> >> -	/**
> >> -	 * Wait-queue signaled when an object in this site is ultimately
> >> -	 * destroyed (lu_object_free()). It is used by lu_object_find() to
> >> -	 * wait before re-trying when object in the process of destruction is
> >> -	 * found in the hash table.
> >> -	 *
> >> -	 * \see htable_lookup().
> >> -	 */
> >> -	wait_queue_head_t	       lsb_marche_funebre;
> >> -};
> >> +struct lu_site_bkt_data;
> >>  
> >>  enum {
> >>  	LU_SS_CREATED	 = 0,
> >> @@ -642,14 +618,8 @@ struct lu_site {
> >>  	struct percpu_counter	 ls_lru_len_counter;
> >>  };
> >>  
> >> -static inline struct lu_site_bkt_data *
> >> -lu_site_bkt_from_fid(struct lu_site *site, struct lu_fid *fid)
> >> -{
> >> -	struct cfs_hash_bd bd;
> >> -
> >> -	cfs_hash_bd_get(site->ls_obj_hash, fid, &bd);
> >> -	return cfs_hash_bd_extra_get(site->ls_obj_hash, &bd);
> >> -}
> >> +wait_queue_head_t *
> >> +lu_site_wq_from_fid(struct lu_site *site, struct lu_fid *fid);
> >>  
> >>  static inline struct seq_server_site *lu_site2seq(const struct lu_site *s)
> >>  {
> >> diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
> >> index df5c0c0ae703..d5b42fb1d601 100644
> >> --- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
> >> +++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
> >> @@ -211,12 +211,12 @@ static void cl_object_put_last(struct lu_env *env, struct cl_object *obj)
> >>  
> >>  	if (unlikely(atomic_read(&header->loh_ref) != 1)) {
> >>  		struct lu_site *site = obj->co_lu.lo_dev->ld_site;
> >> -		struct lu_site_bkt_data *bkt;
> >> +		wait_queue_head_t *wq;
> >>  
> >> -		bkt = lu_site_bkt_from_fid(site, &header->loh_fid);
> >> +		wq = lu_site_wq_from_fid(site, &header->loh_fid);
> >>  
> >>  		init_waitqueue_entry(&waiter, current);
> >> -		add_wait_queue(&bkt->lsb_marche_funebre, &waiter);
> >> +		add_wait_queue(wq, &waiter);
> >>  
> >>  		while (1) {
> >>  			set_current_state(TASK_UNINTERRUPTIBLE);
> >> @@ -226,7 +226,7 @@ static void cl_object_put_last(struct lu_env *env, struct cl_object *obj)
> >>  		}
> >>  
> >>  		set_current_state(TASK_RUNNING);
> >> -		remove_wait_queue(&bkt->lsb_marche_funebre, &waiter);
> >> +		remove_wait_queue(wq, &waiter);
> >>  	}
> >>  
> >>  	cl_object_put(env, obj);
> >> diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
> >> index f7c69680cb7d..adc90f310fd7 100644
> >> --- a/drivers/staging/lustre/lustre/lov/lov_object.c
> >> +++ b/drivers/staging/lustre/lustre/lov/lov_object.c
> >> @@ -370,7 +370,7 @@ static void lov_subobject_kill(const struct lu_env *env, struct lov_object *lov,
> >>  	struct cl_object	*sub;
> >>  	struct lov_layout_raid0 *r0;
> >>  	struct lu_site	  *site;
> >> -	struct lu_site_bkt_data *bkt;
> >> +	wait_queue_head_t *wq;
> >>  	wait_queue_entry_t	  *waiter;
> >>  
> >>  	r0  = &lov->u.raid0;
> >> @@ -378,7 +378,7 @@ static void lov_subobject_kill(const struct lu_env *env, struct lov_object *lov,
> >>  
> >>  	sub  = lovsub2cl(los);
> >>  	site = sub->co_lu.lo_dev->ld_site;
> >> -	bkt  = lu_site_bkt_from_fid(site, &sub->co_lu.lo_header->loh_fid);
> >> +	wq   = lu_site_wq_from_fid(site, &sub->co_lu.lo_header->loh_fid);
> >>  
> >>  	cl_object_kill(env, sub);
> >>  	/* release a reference to the sub-object and ... */
> >> @@ -391,7 +391,7 @@ static void lov_subobject_kill(const struct lu_env *env, struct lov_object *lov,
> >>  	if (r0->lo_sub[idx] == los) {
> >>  		waiter = &lov_env_info(env)->lti_waiter;
> >>  		init_waitqueue_entry(waiter, current);
> >> -		add_wait_queue(&bkt->lsb_marche_funebre, waiter);
> >> +		add_wait_queue(wq, waiter);
> >>  		set_current_state(TASK_UNINTERRUPTIBLE);
> >>  		while (1) {
> >>  			/* this wait-queue is signaled at the end of
> >> @@ -408,7 +408,7 @@ static void lov_subobject_kill(const struct lu_env *env, struct lov_object *lov,
> >>  				break;
> >>  			}
> >>  		}
> >> -		remove_wait_queue(&bkt->lsb_marche_funebre, waiter);
> >> +		remove_wait_queue(wq, waiter);
> >>  	}
> >>  	LASSERT(!r0->lo_sub[idx]);
> >>  }
> >> diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
> >> index 3de7dc0497c4..2a8a25d6edb5 100644
> >> --- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
> >> +++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
> >> @@ -56,6 +56,31 @@
> >>  #include <lu_ref.h>
> >>  #include <linux/list.h>
> >>  
> >> +struct lu_site_bkt_data {
> >> +	/**
> >> +	 * number of object in this bucket on the lsb_lru list.
> >> +	 */
> >> +	long			lsb_lru_len;
> >> +	/**
> >> +	 * LRU list, updated on each access to object. Protected by
> >> +	 * bucket lock of lu_site::ls_obj_hash.
> >> +	 *
> >> +	 * "Cold" end of LRU is lu_site::ls_lru.next. Accessed object are
> >> +	 * moved to the lu_site::ls_lru.prev (this is due to the non-existence
> >> +	 * of list_for_each_entry_safe_reverse()).
> >> +	 */
> >> +	struct list_head		lsb_lru;
> >> +	/**
> >> +	 * Wait-queue signaled when an object in this site is ultimately
> >> +	 * destroyed (lu_object_free()). It is used by lu_object_find() to
> >> +	 * wait before re-trying when object in the process of destruction is
> >> +	 * found in the hash table.
> >> +	 *
> >> +	 * \see htable_lookup().
> >> +	 */
> >> +	wait_queue_head_t	       lsb_marche_funebre;
> >> +};
> >> +
> >>  enum {
> >>  	LU_CACHE_PERCENT_MAX	 = 50,
> >>  	LU_CACHE_PERCENT_DEFAULT = 20
> >> @@ -88,6 +113,17 @@ MODULE_PARM_DESC(lu_cache_nr, "Maximum number of objects in lu_object cache");
> >>  static void lu_object_free(const struct lu_env *env, struct lu_object *o);
> >>  static __u32 ls_stats_read(struct lprocfs_stats *stats, int idx);
> >>  
> >> +wait_queue_head_t *
> >> +lu_site_wq_from_fid(struct lu_site *site, struct lu_fid *fid)
> >> +{
> >> +	struct cfs_hash_bd bd;
> >> +	struct lu_site_bkt_data *bkt;
> >> +
> >> +	cfs_hash_bd_get(site->ls_obj_hash, fid, &bd);
> >> +	bkt = cfs_hash_bd_extra_get(site->ls_obj_hash, &bd);
> >> +	return &bkt->lsb_marche_funebre;
> >> +}
> >> +
> >
> > Nak. You forgot the EXPORT_SYMBOL for this. Once I added the export symbol
> > it seems to work so far in my testing.
> 
> Thanks!  I'll try to remember the occasional build-test with modules.

'make allmodconfig' is your friend :)

I'm dropping this series, I'm guessing you will send a v2 for the whole
set.

thanks,

greg k-h
