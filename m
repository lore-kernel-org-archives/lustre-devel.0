From: Peter Braam <Peter.Braam@Sun.COM>
Date: Tue, 10 Jun 2008 15:24:23 -0600
Subject: [Lustre-devel] some thoughts on COS
In-Reply-To: <200806102250.32908.alexander.zarochentsev@sun.com>
Message-ID: <C4744D27.5A50%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org




On 6/10/08 12:50 PM, "Alexander Zarochentsev"
<Alexander.Zarochentsev@Sun.COM> wrote:

> hello Alex,
> 
> On 5 June 2008 16:27:27 Alex Zhuravlev wrote:
>> Hi,
>> 
>> I think it could be great if we can use LDLM for COS. at the very
>> first view it looks possible:
>> 1) each server lock is tagged with client unique id (uuid/export
>> addr/etc) 2) mds registers own blocking AST function
>> 3) locks to be used rep-ack's aren't released upon ACK, only upon
>> commit 4) whenever conflict is observed by LDLM at enqueue time,
>> MDS's blocking AST function is called and depending on whetner
>> conflicting locks are taken on behalf same or different clients, the
>> function issues sync causing commit and old lock to be released later
> 
> There could be dependency between operations and no lock conflicts at
> all, just because the PW lock is released already but the changes are
> not yet committed. Then we have no blocking AST and no commit.

This makes no sense, the idea is to keep a lock until commit.

Peter

> 
> It is why LDLM seems not a good place to do COS, LDLM deals with locks
> and their conflicts but the COS deals with dependency info their
> conflicts?) which has lifecycle and semantics different from LDLM
> locks.
> 
>> but one use case isn't that obvious. it's OK when first lock L1 was
>> from client C1 with PW mode and new lock is also from C1/PW. but then
>> we have a situation with same client, but locks are PW then PR:
>> 1) we wouldn't want to sync just because client does mkdir a; touch a
>> 2) thus we have to grant PR lock (so, first problem - sometimes PW
>> and PR doesn't conflict?)
>> 3) if we cancel PW to grant PR, then we'd have to make this PR
>> conflicting with any PR coming from different client?
>> 4) changing PR to PW in order to inherit state? (client side doesn't
>> expect such locks_
> 
> we just don't expect the lock to exist as long as the changes stay not
> committed, so LDLM can't catch the dependency between the operations.
> 
>> all of this doesn't sound like a good solution, IMHO. at least it'd
>> require serious changes in LDLM while we're talking about 1.6/1.8 ...
>> so we need another way.
>> 
>> probably we could re-use VBR as each inode change goes with new
>> persistent version and version is numerically equal to transno,
>> comparing inode's version with last committed transno we can learn
>> whether the inode is committed?
>> 
>> next problem is to learn source of change, i.e. client. in the worst
>> case all changes are from different clients, thus every change means
>> sync. but if we *cache* source information we probably can avoid
>> majority of syncs. IOW, we don't need to track source all the time,
>> it should be enough if we have this information most of time. so,
>> storing it in in-core inode is good enough probably. following this
>> way we don't need to care about inode's lifetime.
>> 
>> thanks, Alex
>> 
>> _______________________________________________
>> Lustre-devel mailing list
>> Lustre-devel at lists.lustre.org
>> http://lists.lustre.org/mailman/listinfo/lustre-devel
> 
> Thanks,
