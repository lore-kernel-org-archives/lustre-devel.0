From: Andreas Dilger <adilger@sun.com>
Date: Fri, 30 May 2008 20:45:24 -0600
Subject: [Lustre-devel] Commit on share
In-Reply-To: <op.ubxfheh9atmt0c@goga>
References: <C4620704.5499%peter.braam@sun.com> <op.ubxfheh9atmt0c@goga>
Message-ID: <20080531024524.GB2992@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On May 29, 2008  21:42 +0400, Mike Pershin wrote:
> It seems this mail wasn't received by subscribers though it is in  
> lustre-devel archive already. I paste the original answer below.
> 
> Thanks for review. Alexander is on vacation so I will answer as co-author.

Mike, can you please also archive this discussion in the bugzilla bug,
so that it is available for future reference.

> On Tue, 27 May 2008 14:44:18 +0400, Peter Braam <Peter.Braam@Sun.COM>
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

On a related note - I just came across bug 3621 - sync outstanding
transaction instead of evicting client when a rep-ack isn't received.
Could you please address this bug at the same time as COS.  With COS
this will always happen, of course, but it should also happen without
it to avoid client eviction if possible.

> > * GC thread is wrong mechanism this is what we have commit callbacks for
> 
> Well, with callbacks we have to scan through all hash to find data to
> delete on each callback. As alex said there can be about 10K uncommitted
> transactions in high load easily, therefore using callback may become the
> bottlneck. There was discussion recently in devel@ about that originated
> by zam. Although I agree the HLD should be clear about why we choose that
> way and what is wrong with another.

Maybe I'm misunderstanding something (I didn't read HLD), but the commit
callback can be set per Lustre transaction (in fact multiple callbacks
can exist per transaction) so there should not be any need to do searching
for finding per-transaction cleanup.  What state is the GC thread supposed
to be cleaning up?  Doing GC is also searching, and that is undesirable in
any case.

> > * Why not use the DLM, then we can simply keep the client waiting ? the
> > mechanism already exists for repack; I am not convinced at all by the
> > reasoning that rep-ack is so different ? no real facts are quoted
> 
> Let's estimate how RepACK lock is suitable as dependency tracking
> functionality. In fact it is more like 'possible dependency prevention'
> mechanism, and block object always because we can't predict the next
> operation, so should keep lock taken for ALL modifying operations. It is
> not 'tracking' but 'prediction' mechanism, it blocks access to the object
> until client will got reply just because the conflicting operation is
> possible but not because it really happen.

RepACK is currently needed for recovery.  I don't think it is a false
conflict in most cases, though I agree in some cases it is.  If MDS
thread is only e.g. passing through a directory to do some operation
in a previously-existing subdirectory, or wants to stat a file that
existed before the conflicting lock was taken then this is a false
dependency.

> Moreover it conflicts in general with dependency tracking we needed,
> because it will serialize operations even when they may not depend.
> 
> With RepACK lock we are entering in operation AFTER the checks and we
> don't know the result of this check - was there operation from different
> client? are changes committed? Should we do sync or not? RepACK lock
> doesn't answer this question and we can't decide about sync is needed or
> not.

That isn't quite true - if the changes ARE already committed, then the
lock is no longer needed and dropped by the commit callback.  See
ptlrpc_commit_replies->
  schedule_difficult_replies-> (wakeup srv_waitq)
    ptlrpc_main->
      ptlrpc_server_handle_reply->
      	ldlm_lock_decref()


> For example, the client2 will wait for commit or ACK before entering in
> locked area.
> 1) ACK is got but no commit yet. So client2 enter in locked area and now
> should determine was commit done or not. How to do that? This is vital
> because if there was no commit yet then we should do it. We may use
> version of object possible and check it against last_committed, but this
> will work only with VBR. So we need extra data per-object like transno.

Yes, this is definitely most efficient with VBR.

> 2) Commit was done. We should still do the same as for 1) to be sure about
> was commit done or not because it is not known why lock was unlocked - due
> to ACK or commit.
> 3) But we don't know still is there conflict or not because we should
> check client uuids, but we don't store such info anywhere and waiting on
> lock is not reflected somehow. So we need extra data (or extra information
>   from ldlm?) again to store uuid of client who did latest operation on that
> object.

Wouldn't that be in the last_rcvd data for the current client?  If the
req->rq_export->exp_mds_data->med_mcd->mcd_last_transno is the same as
the VBR transno on object being modified then we know this client was
the last one to modify the object and there is no external dependency.

> The only way how dlm can work without any additional data is to unlock
> only when commit. But in that case we don't need COS at all. Each
> conflicting client will wait on lock until previous changes will be
> committed. But this may lead to huge latency for requests, comparing with
> commit interval and it is not what we need.
> 
> > * It is left completely without explanation how the hash table (which I
> > think we don?t need/want) is used
> 
> hash table store the following data per object:
> struct lu_dep_info {
>           struct ll_fid     di_object;
>           struct obd_uuid   di_client;
>           __u64             di_transno;
> };
> 
> it contains uuid of client and transno of last change from this client.
> The uuid is compared to determine is there is conflict of not, the transno
> shows was that data committed already or not. I described above why it is
> needed. It is 1.6-related issue because we have only inode of object and
> no any extra structure. The HEAD has lu_object enveloping inodes, and hash
> will not needed, the dependency info may be stored per lu_object.

I think the commit callbacks should be able to free this data, there
should never be any such items on an object with di_transno > last_committed.
Also, isn't it enough to store a single such item per object directly
on the object?  Once we know there is ANY such conflict that is enough
to invoke COS.  For per-object data this can be stored on 1.6 in the
i_filterdata structure that we can attach onto every server inode.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
