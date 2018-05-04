From: NeilBrown <neilb@suse.com>
Date: Fri, 04 May 2018 10:30:33 +1000
Subject: [lustre-devel] [PATCH 04/10] staging: lustre: lu_object: move
 retry logic inside htable_lookup
In-Reply-To: <alpine.LFD.2.21.1805021914550.24633@casper.infradead.org>
References: <152514658325.17843.11455067361317157487.stgit@noble>
 <152514675897.17843.15112214060540196720.stgit@noble>
 <EFC6D018-5FB5-4902-AE7A-B91A5E0148FE@intel.com>
 <alpine.LFD.2.21.1805021914550.24633@casper.infradead.org>
Message-ID: <87fu38feja.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>, "Dilger, Andreas" <andreas.dilger@intel.com>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Wed, May 02 2018, James Simmons wrote:

>> On Apr 30, 2018, at 21:52, NeilBrown <neilb@suse.com> wrote:
>> > 
>> > The current retry logic, to wait when a 'dying' object is found,
>> > spans multiple functions.  The process is attached to a waitqueue
>> > and set TASK_UNINTERRUPTIBLE in htable_lookup, and this status
>> > is passed back through lu_object_find_try() to lu_object_find_at()
>> > where schedule() is called and the process is removed from the queue.
>> > 
>> > This can be simplified by moving all the logic (including
>> > hashtable locking) inside htable_lookup(), which now never returns
>> > EAGAIN.
>> > 
>> > Note that htable_lookup() is called with the hash bucket lock
>> > held, and will drop and retake it if it needs to schedule.
>> > 
>> > I made this a 'goto' loop rather than a 'while(1)' loop as the
>> > diff is easier to read.
>> > 
>> > Signed-off-by: NeilBrown <neilb@suse.com>
>> > ---
>> > drivers/staging/lustre/lustre/obdclass/lu_object.c |   73 +++++++-------------
>> > 1 file changed, 27 insertions(+), 46 deletions(-)
>> > 
>> > diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
>> > index 2bf089817157..93daa52e2535 100644
>> > --- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
>> > +++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
>> > @@ -586,16 +586,21 @@ EXPORT_SYMBOL(lu_object_print);
>> > static struct lu_object *htable_lookup(struct lu_site *s,
>> 
>> It's probably a good idea to add a comment for this function that it may
>> drop and re-acquire the hash bucket lock internally.
>> 
>> > 				       struct cfs_hash_bd *bd,
>> > 				       const struct lu_fid *f,
>> > -				       wait_queue_entry_t *waiter,
>> > 				       __u64 *version)
>> > {
>> > +	struct cfs_hash		*hs = s->ls_obj_hash;
>> > 	struct lu_site_bkt_data *bkt;
>> > 	struct lu_object_header *h;
>> > 	struct hlist_node	*hnode;
>> > -	__u64  ver = cfs_hash_bd_version_get(bd);
>> > +	__u64 ver;
>> > +	wait_queue_entry_t waiter;
>> > 
>> > -	if (*version == ver)
>> > +retry:
>> > +	ver = cfs_hash_bd_version_get(bd);
>> > +
>> > +	if (*version == ver) {
>> > 		return ERR_PTR(-ENOENT);
>> > +	}
>> 
>> (style) we don't need the {} around a single-line if statement
>
> I hate to be that guy but could you run checkpatch on your patches.
>  

Someone's got to be "that guy" - thanks.
I have (at last) modified my patch-preparation script to run checkpatch
and show me all the errors that I'm about to post.


>> > 	*version = ver;
>> > 	bkt = cfs_hash_bd_extra_get(s->ls_obj_hash, bd);
>> > @@ -625,11 +630,15 @@ static struct lu_object *htable_lookup(struct lu_site *s,
>> > 	 * drained), and moreover, lookup has to wait until object is freed.
>> > 	 */
>> > 
>> > -	init_waitqueue_entry(waiter, current);
>> > -	add_wait_queue(&bkt->lsb_marche_funebre, waiter);
>> > +	init_waitqueue_entry(&waiter, current);
>> > +	add_wait_queue(&bkt->lsb_marche_funebre, &waiter);
>> > 	set_current_state(TASK_UNINTERRUPTIBLE);
>> > 	lprocfs_counter_incr(s->ls_stats, LU_SS_CACHE_DEATH_RACE);
>> > -	return ERR_PTR(-EAGAIN);
>> > +	cfs_hash_bd_unlock(hs, bd, 1);
>> 
>> This looks like it isn't unlocking and locking the hash bucket in the same
>> manner that it was done in the caller.  Here excl = 1, but in the caller
>> you changed it to excl = 0?
>
> This is very much like the work done by Lai. The difference is Lai remove 
> the work queue handling complete in htable_lookup(). You can see the 
> details at https://jira.hpdd.intel.com/browse/LU-9049. I will push the 
> missing lu_object fixes including LU-9049 on top of your patch set so you
> can see the approach Lai did. Form their we can figure out merge the 
> lu_object work and fixing the issues Andreas and I pointed out.

I think I did see that before but didn't feel I understood it enough to
do anything with, so I deferred it.  Having the patches that you
provided, I think it is starting the make more sense.  Once I resubmit
this current series I'll have a closer look.  Probably we can just
apply the series you sent on top of mine - I might even combine the two
- and the think about whatever else needs doing.

Thanks,
NeilBrown

-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180504/a1a8b1a4/attachment.sig>
