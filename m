From: NeilBrown <neilb@suse.com>
Date: Fri, 04 May 2018 11:30:25 +1000
Subject: [lustre-devel] [PATCH 04/10] staging: lustre: lu_object: move
 retry logic inside htable_lookup
In-Reply-To: <EFC6D018-5FB5-4902-AE7A-B91A5E0148FE@intel.com>
References: <152514658325.17843.11455067361317157487.stgit@noble>
 <152514675897.17843.15112214060540196720.stgit@noble>
 <EFC6D018-5FB5-4902-AE7A-B91A5E0148FE@intel.com>
Message-ID: <874ljofbri.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Dilger, Andreas" <andreas.dilger@intel.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Linux
 Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Tue, May 01 2018, Dilger, Andreas wrote:

> On Apr 30, 2018, at 21:52, NeilBrown <neilb@suse.com> wrote:
>> 
>> The current retry logic, to wait when a 'dying' object is found,
>> spans multiple functions.  The process is attached to a waitqueue
>> and set TASK_UNINTERRUPTIBLE in htable_lookup, and this status
>> is passed back through lu_object_find_try() to lu_object_find_at()
>> where schedule() is called and the process is removed from the queue.
>> 
>> This can be simplified by moving all the logic (including
>> hashtable locking) inside htable_lookup(), which now never returns
>> EAGAIN.
>> 
>> Note that htable_lookup() is called with the hash bucket lock
>> held, and will drop and retake it if it needs to schedule.
>> 
>> I made this a 'goto' loop rather than a 'while(1)' loop as the
>> diff is easier to read.
>> 
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>> drivers/staging/lustre/lustre/obdclass/lu_object.c |   73 +++++++-------------
>> 1 file changed, 27 insertions(+), 46 deletions(-)
>> 
>> diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
>> index 2bf089817157..93daa52e2535 100644
>> --- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
>> +++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
>> @@ -586,16 +586,21 @@ EXPORT_SYMBOL(lu_object_print);
>> static struct lu_object *htable_lookup(struct lu_site *s,
>
> It's probably a good idea to add a comment for this function that it may
> drop and re-acquire the hash bucket lock internally.

Added - thanks.

>
>> 				       struct cfs_hash_bd *bd,
>> 				       const struct lu_fid *f,
>> -				       wait_queue_entry_t *waiter,
>> 				       __u64 *version)
>> {
>> +	struct cfs_hash		*hs = s->ls_obj_hash;
>> 	struct lu_site_bkt_data *bkt;
>> 	struct lu_object_header *h;
>> 	struct hlist_node	*hnode;
>> -	__u64  ver = cfs_hash_bd_version_get(bd);
>> +	__u64 ver;
>> +	wait_queue_entry_t waiter;
>> 
>> -	if (*version == ver)
>> +retry:
>> +	ver = cfs_hash_bd_version_get(bd);
>> +
>> +	if (*version == ver) {
>> 		return ERR_PTR(-ENOENT);
>> +	}
>
> (style) we don't need the {} around a single-line if statement

Fixed.

>
>> 	*version = ver;
>> 	bkt = cfs_hash_bd_extra_get(s->ls_obj_hash, bd);
>> @@ -625,11 +630,15 @@ static struct lu_object *htable_lookup(struct lu_site *s,
>> 	 * drained), and moreover, lookup has to wait until object is freed.
>> 	 */
>> 
>> -	init_waitqueue_entry(waiter, current);
>> -	add_wait_queue(&bkt->lsb_marche_funebre, waiter);
>> +	init_waitqueue_entry(&waiter, current);
>> +	add_wait_queue(&bkt->lsb_marche_funebre, &waiter);
>> 	set_current_state(TASK_UNINTERRUPTIBLE);
>> 	lprocfs_counter_incr(s->ls_stats, LU_SS_CACHE_DEATH_RACE);
>> -	return ERR_PTR(-EAGAIN);
>> +	cfs_hash_bd_unlock(hs, bd, 1);
>
> This looks like it isn't unlocking and locking the hash bucket in the same
> manner that it was done in the caller.  Here excl = 1, but in the caller
> you changed it to excl = 0?

Don't know what happened there... though as the tables is created with
CFS_HASH_SPIN_BLKLOCK it doesn't make any behavioral difference.
I've put it back to use '1' uniformly.

>
>> +	schedule();
>> +	remove_wait_queue(&bkt->lsb_marche_funebre, &waiter);
>
> Is it worthwhile to use your new helper function here to get the wq from "s"?

I don't think so.  We already have the 'bkt' and it seems pointless to
compute the hash a second time and use it to find the bucket and then
the queue, just to use a nice wrapper function.


>
>> +	cfs_hash_bd_lock(hs, bd, 1);
>> +	goto retry;
>> }
>> 
>> /**
>> @@ -693,13 +702,14 @@ static struct lu_object *lu_object_new(const struct lu_env *env,
>> }
>> 
>> /**
>> - * Core logic of lu_object_find*() functions.
>> + * Much like lu_object_find(), but top level device of object is specifically
>> + * \a dev rather than top level device of the site. This interface allows
>> + * objects of different "stacking" to be created within the same site.
>>  */
>> -static struct lu_object *lu_object_find_try(const struct lu_env *env,
>> -					    struct lu_device *dev,
>> -					    const struct lu_fid *f,
>> -					    const struct lu_object_conf *conf,
>> -					    wait_queue_entry_t *waiter)
>> +struct lu_object *lu_object_find_at(const struct lu_env *env,
>> +				    struct lu_device *dev,
>> +				    const struct lu_fid *f,
>> +				    const struct lu_object_conf *conf)
>> {
>> 	struct lu_object      *o;
>> 	struct lu_object      *shadow;
>> @@ -725,17 +735,16 @@ static struct lu_object *lu_object_find_try(const struct lu_env *env,
>> 	 * It is unnecessary to perform lookup-alloc-lookup-insert, instead,
>> 	 * just alloc and insert directly.
>> 	 *
>> -	 * If dying object is found during index search, add @waiter to the
>> -	 * site wait-queue and return ERR_PTR(-EAGAIN).
>> 	 */
>> 	if (conf && conf->loc_flags & LOC_F_NEW)
>> 		return lu_object_new(env, dev, f, conf);
>> 
>> 	s  = dev->ld_site;
>> 	hs = s->ls_obj_hash;
>> -	cfs_hash_bd_get_and_lock(hs, (void *)f, &bd, 1);
>> -	o = htable_lookup(s, &bd, f, waiter, &version);
>> -	cfs_hash_bd_unlock(hs, &bd, 1);
>> +	cfs_hash_bd_get_and_lock(hs, (void *)f, &bd, 0);
>> +	o = htable_lookup(s, &bd, f, &version);
>> +	cfs_hash_bd_unlock(hs, &bd, 0);
>
> Here you changed the locking to a non-exclusive (read) lock instead of an
> exclusive (write) lock?  Why.

Carelessness is all.  And the fact that my thinking was focused on
rhashtable which doesn't make that distinction. Fixed.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180504/d32230aa/attachment-0001.sig>
