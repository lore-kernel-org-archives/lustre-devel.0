From: Peter Braam <Peter.Braam@Sun.COM>
Date: Sun, 01 Jun 2008 13:00:52 +0800
Subject: [Lustre-devel] Commit on share
In-Reply-To: <op.ubtknjyjatmt0c@goga>
Message-ID: <C4684E04.5626%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org




On 5/27/08 11:43 PM, "Mikhail Pershin" <Mikhail.Pershin@Sun.COM> wrote:

> Hello Peter,
> 
> Thanks for review. Alexander is on vacation so I will answer as co-author.
> 
> On Tue, 27 May 2008 14:44:18 +0400, Peter Braam <Peter.Braam@Sun.COM>
> wrote:
> 
>> This HLD is definitely not ready at all.  It is very short, lacks
>> interaction diagrams and the arguments made are not sufficiently
>> detailed.
>> 
>> * the second sentence is not right.  Commit should happen before
>> un-committed data coming from a client is shared with a 2nd client.
> 
> Can you provide any issues with that? Committing data after but not before
> current operation has following benefits:

The document is written without any mention of read only interaction with
the file system.  On top of that the language was insufficiently clear,
meaning that I only understood what you wanted to do several pages further.
That means other people will encounter the same difficulty.


> 1) no need in starting/commiting separate transaction, simple code due to
> that
> 2) less syncs. E.g. if we are committing current operation too then we
> resolve possible share case related to current operation and later commit
> will not needed. Therefore we will have less synced operations.
> E.g. the worst case for COS is:
> client1 operation
> client2 operation -> sync
> client1 op -> sync
> client2 op -> sync
> ...
> COS will do commit for each operation if they are on the same object and
> sync is happened before current operation.
> But including the current operation in commit will reduce number of
> commits in twice:
> client1 operation
> client2 op -> sync (including this op)
> client1 op - no sync because no uncommitted shared data
> client2 op -> sync
> ...
> 

This may not be a worthwhile optimization, although it seems correct.
Please provide detailed use cases where it provides value.

For example with 1000 clients creating each one file in a directory, what is
the quantative benefit?

With one client creating a file and 999 clients doing a getattr, you now
have 999 locks blocking for completion - not convincing.

>> * Is COS dependent on VBR ? no it is not, and can equally apply to normal
>> recovery
> 
> Agree, COS is like just lever to turn sync commit on/off depending on some
> conditions. These conditions maybe quite simple like now - just
> comparision of clients - or maybe more complex and include checking of
> operation types, etc.
> 
> But COS was requested initially as optional feature of VBR, so we didn't
> review COS-only configuration. Without VBR any missed client will invoke
> the eviction of all clients with replays after the gap. Therefore COS will
> not helps until we will change current recovery to don't evict clients if
> COS is enabled. But we should know actually was COS enabled before the
> server failure to be sure that the excluding gap transactions is safe. Do
> we need COS-only use-case actually?

Yes, we need COS with traditional recovery and a precise explanation why COS
with COS adds any value over COS with traditional recovery.  Again, use
numbers and exact facts.


> 
>> * Section 3.2 is wrong: the recovery process will not fail with gaps in
>> the
>> sequence when there is VBR.  It only fails if there are gaps in the
>> versions, and this is rare.
> 
> the 3.2 section is talking only about gap in versions. Maybe it is not
> correct grammatically though.
> "... Highly probably we have non-trivial gaps version in the sequence and
> the recovery process fails"
> Could you mark what is wrong with 3.2? just rewrite the sentence to make
> it more clear about what gaps we mean?

Exact detail, example use cases, no mumbling of complex ideas.

I also want to see precise flow charts of interactions upon reconnection
(this perhaps belongs in the VBR HLD), how does the system transition from
one recovery type to the next.

> 
>> * 3.3 parallel creations in one directory are protected with different,
>> independent lock resources.  Isn?t that sufficient to allow parallel
>> operations with COS?
> 
> it is HEAD feature, but this design is for 1.8 (1.6-based) Lustre with one
> dir lock. If this is not mentioned in HLD then it should be fixed.
> But the issue is not about the lock only.
> The 'simple' COS checks only clients nids to determine the dependency.
> Therefore if two clients are creating objects in the same directory then
> we will have frequent syncs due to COS (operations from different nids)
> although there is no need for sync at all becase the operations are not
> dependent.

If they are not dependent then there should be no commits.  But, you have
not defined dependency in a precise way, so the HLD is hand-waving instead
of designing.

In any case I absolutely don't want the hash.  This has to be done with
commit callbacks unless the reasons not to do so become one order of
magnitude clearer.

> The same will be with parallel locking if we will not check type of
> operation to determine the dependency.
> 
>> * 3.6 provide a detailed explanation please
> "When enabled, COS makes REP-ACK not needed."
> Basically the COS is about two things:
> 1) dependency tracking. This functionality which try to determine is
> current operation depending on some other uncommitted one.

"try to?" - so it sometimes fails?

> It may be  
> simple 

What kind of language is this?

>and check only nids of clients, maybe more sophisticated and
> include type of operation checking or any other additional data.

Without a definition of dependency, you can see why I have completely
rejected the HLD, and I will continue to do so.

> 2) COS itself, the doing sync commit of current operation if there is
> dependency.
> 
> So if we have 1) and 2) we have only the following cases:
> - there is dependency determined and commit is needed to remove it. No ACK
> is needed.
> - there is no dependency and we don't need no ACK and lock nor commit
> because client's replays are not dependent
> Therefore the ACK is not needed in both cases. The COS don't need to wait
> on repack lock, it determine the share case and do commit.

In the HLD state and define in 100% accurate manner why REP ACKS are needed,
and prove that with COS they are not.  This clearly depends on precise
definitions.

> 
> how ACK is related to 'simple' COS (the only client NIDs are matter):
> 1) client1 did operation and lock object until ACK from it will come to
> server
> 2) client2 is waiting for ACK or commit to access the object
> 3) if there was no commit yet, then client2 determine the sharing exists
> and force commit
> 
> The only positive effect of ACK is delay before doing sync, that give us
> the chance to wait for commit without doing force sync. But that can be
> done with timer to get the same results.

No timers - end of discussion.

> 
> In HLD we propose the following:
> 1) client1 got lock, did operation, unlock object after operation is done
> 2) client2 got lock on object and check was there the dependency
> 3) if dependency then force commit (or wait for it as alternative way)
> 4) otherwise update dependency info for next check, unlock object when
> operation is done
> 
> This is generic way and will work with any dependency tracking (on NIDs,
> on types of operations, etc.)

Two clients is not a sufficient argument possibly.


Please put explanations in the HLD and supply a new one.


> 
>> * GC thread is wrong mechanism this is what we have commit callbacks for

No GC - end of discussion.

> 
> Well, with callbacks we have to scan through all hash to find data to
> delete on each callback. As alex said there can be about 10K uncommitted
> transactions in high load easily, therefore using callback may become the
> bottlneck. There was discussion recently in devel@ about that originated
> by zam. Although I agree the HLD should be clear about why we choose that
> way and what is wrong with another.
> 
>> * Why not use the DLM, then we can simply keep the client waiting ? the
>> mechanism already exists for repack; I am not convinced at all by the
>> reasoning that rep-ack is so different ? no real facts are quoted
> 
> Let's estimate how RepACK lock is suitable as dependency tracking
> functionality.

Without better definitions, the arguments below cannot be judged.

> In fact it is more like 'possible dependency prevention'
> mechanism, and block object always because we can't predict the next
> operation, so should keep lock taken for ALL modifying operations. It is
> not 'tracking' but 'prediction' mechanism, it blocks access to the object
> until client will got reply just because the conflicting operation is
> possible but not because it really happen.
> Moreover it conflicts in general with dependency tracking we needed,
> because it will serialize operations even when they may not depend.
> 
> With RepACK lock we are entering in operation AFTER the checks and we
> don't know the result of this check - was there operation from different
> client? are changes committed? Should we do sync or not? RepACK lock
> doesn't answer this question and we can't decide about sync is needed or
> not.
> 
> For example, the client2 will wait for commit or ACK before entering in
> locked area.
> 1) ACK is got but no commit yet. So client2 enter in locked area and now
> should determine was commit done or not. How to do that? This is vital
> because if there was no commit yet then we should do it. We may use
> version of object possible and check it against last_committed, but this
> will work only with VBR.
> So we need extra data per-object like transno.
> 2) Commit was done. We should still do the same as for 1) to be sure about
> was commit done or not because it is not known why lock was unlocked - due
> to ACK or commit.
> 3) But we don't know still is there conflict or not because we should
> check client uuids, but we don't store such info anywhere and waiting on
> lock is not reflected somehow. So we need extra data (or extra information
>  from ldlm?) again to store uuid of client who did latest operation on that
> object.
> 
> The only way how dlm can work without any additional data is to unlock
> only when commit. But in that case we don't need COS at all. Each
> conflicting client will wait on lock until previous changes will be
> committed. But this may lead to huge latency for requests, comparing with
> commit interval and it is not what we need.
> 
>> * It is left completely without explanation how the hash table (which I
>> think we don?t need/want) is used
> 
> hash table store the following data per object:
> struct lu_dep_info {
>          struct ll_fid     di_object;
>          struct obd_uuid   di_client;
>          __u64             di_transno;
> };
> 
> it contains uuid of client and transno of last change from this client.
> The uuid is compared to determine is there is conflict of not, the transno
> shows was that data committed already or not. I described above why it is
> needed. It is 1.6-related issue because we have only inode of object and
> no any extra structure. The HEAD has lu_object enveloping inodes, and hash
> will not needed, the dependency info may be stored per lu_object.
> 
>> 
>> Regards,
>> 
>> Peter
> 
> 
