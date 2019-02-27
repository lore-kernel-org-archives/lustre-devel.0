From: Andreas Dilger <adilger@whamcloud.com>
Date: Wed, 27 Feb 2019 22:14:47 +0000
Subject: [lustre-devel] [PATCH 30/37] lustre: handle: move refcount into
 the lustre_handle.
In-Reply-To: <878sy0uclm.fsf@notabene.neil.brown.name>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
 <155053494654.24125.18407080080202016099.stgit@noble.brown>
 <BAC6F248-EB8B-42B7-B46D-FB8FEB6F359F@whamcloud.com>
 <878sy0uclm.fsf@notabene.neil.brown.name>
Message-ID: <0076CC3E-7DAF-4FEE-9EF4-B41A709D9F61@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Feb 27, 2019, at 14:48, NeilBrown <neilb@suse.com> wrote:
> 
> On Wed, Feb 27 2019, Andreas Dilger wrote:
> 
>> On Feb 18, 2019, at 17:09, NeilBrown <neilb@suse.com> wrote:
>>> 
>>> Every object with a lustre_handle has (and must have) a refcount.
>>> The lustre_handles code needs a call-out to increment this.
>>> To simplify things, move the refcount into the lustre_handle
>>> and discard the call-out.
>>> 
>>> Signed-off-by: NeilBrown <neilb@suse.com>
>> 
>> This patch reduces the debugbility of refcounting on these data
>> structures, which can be tricky to diagnose if there is a leak
>> at some point and nothing can clean up at the end because some
>> data structure is holding an extra reference (e.g. lock->exp->dev).
>> 
>>> struct obd_export *class_export_get(struct obd_export *exp)
>>> {
>>> -	refcount_inc(&exp->exp_refcount);
>>> +	refcount_inc(&exp->exp_handle.h_ref);
>>> 	CDEBUG(D_INFO, "GETting export %p : new refcount %d\n", exp,
>>> -	       refcount_read(&exp->exp_refcount));
>>> +	       refcount_read(&exp->exp_handle.h_ref));
>>> 	return exp;
>>> }
>> 
>> For example, with the existing callback mechanism, class_export_get()
>> and class_export_put() would be called for every reference added
>> and removed to this struct obd_export (e.g. when a valid lock handle
>> is looked up), so with D_INFO logging enabled we can trace all of the
>> reference counting of the data structures involved.
>> 
>>> @@ -152,7 +152,7 @@ void *class_handle2object(u64 cookie,
>>> 			const struct portals_handle_ops *ops)
>>> 
>>> 		spin_lock(&h->h_lock);
>>> 		if (likely(h->h_in != 0)) {
>>> -			h->h_ops->hop_addref(h);
>>> +			refcount_inc(&h->h_ref);
>>> 			retval = h;
>>> 		}
>>> 		spin_unlock(&h->h_lock);
>> 
>> With this change, while class_handle2object() will still reference the
>> handle correctly, it not print anything into the logs so if there is
>> something wrong it will be much more difficult to find.
> 
> To restore the debugability, would it be sufficient to add a
> CDEBUG(D_INFO) to class_handle2object() where it increments the ref?
> We could even add a type name to powers_handle_ops to make the messages
> easier to search for?

That would probably work.  We'd have the pointer+type from the initial
reference, and if the pointer+type is logged in the increment/decrement
functions then it doesn't matter that they aren't printed by the same
function.  Ideally the formatting of such messages would be consistent
to make searching easier. 

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
