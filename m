From: Liang Zhen <Zhen.Liang@Sun.COM>
Date: Fri, 15 Aug 2008 10:42:46 +0800
Subject: [Lustre-devel] Completion callbacks
In-Reply-To: <9D08414172D1491EA6948A37F3395FFE@ebpc>
References: <48A2BFD3.2070900@sun.com> <C4C8BC31.6CC1%peter.braam@sun.com>
	<9D08414172D1491EA6948A37F3395FFE@ebpc>
Message-ID: <48A4ED26.3050000@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Eric Barton ??:
>> Isaac and I discussed about this and we think:
>> 1. We can create an array of locks for each EQ (for example NCPUs
>> locks for each EQ), and hash MD (i.e, by handle cookie) to these
>> locks to get cocurrent of eq_callback without losing order of events
>> for each MD, also, upper layers wouldn't see any change.
>>     
>
> Yes, this ensures callbacks on each MD remain ordered - however the
> current code also guarantees that the callback and any MD
> auto-unlinking completes before LNetEQPoll() can return.  We have to
> verify that relaxing ordering here is OK or else do some similar
> lock-hashing, say on the EQ slot.
>   
Yes, then we will need two lock-tables just for serializing eq_callback and
LNetEQPoll, and I think this part of code will be complex but the only
benefit is concurrency of eq_callback. After think over it again, I 
perfer to
design like this:

1. Have different hash table for different LNet descriptor handles.
2. lnet_eq_lock
protects EQ-handle table, and all EQ related operations
3. lnet_portal_lock
protects ME-handle table, and all ME related operations, also,
attach/detach/match MD will need this lock too.
4. lnet_md_lock (lock-table)
each slot of the lock-table protects a MD-handle table (MDs are hashed into
different MD-tables by handle-cookie), it also protects all MD operations
in the MD-table, eq_callbacks are serialized by it as well.
5. it's legal to have lnet_md_lock then race lnet_eq_lock or 
lnet_portal_lock
6. lnet_lock
it protects rest part of LNet (peer table, router-buffer, credits...)

Now let's see some examples:
1. LNetMDBind: only needs lnet_md_lock(i) to insert to MD-table
2. LNetMDAttach: needs lnet_md_lock(i) to insert to MD-table,
then lnet_portal_lock() to attach with ME
3. LNetPut: needs lnet_md_lock(i) to find MD, then lnet_lock() for rest ops
4. lnet_parse_put: needs lnet_portal_lock() for matching
5. lnet_finalize: needs lnet_md_lock(i) (may need lnet_portal_lock for a
short while if MD is on portal) to check status of MD, serialze callback
and md_unlink, lnet_eq_lock to enqueue event, then lnet_lock to return
credits etc.
6. LNetEQPoll: needs lnet_eq_lock

Although add more new locks here, but it's natural to have different 
locks for
different objects, also, everything still follow original logic of LNet,
implementation is very straightforward, most time we just need to replace
LNET_LOCK with new lock name.

All LNet interfaces can benefity from change like this: We will not only 
have
better concurrency of eq_callback, we also have concurrency of all APIs.

(If we want, we can even have individual lock for each portal based on this
design(save portal index in ME handle), although I think it's no really
necessary...)

>
>   
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>   
