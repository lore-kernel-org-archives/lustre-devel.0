From: Andreas Dilger <adilger@sun.com>
Date: Tue, 07 Jul 2009 09:21:05 -0600
Subject: [Lustre-devel] Recovering opens by reconstruction
In-Reply-To: <op.uwpaclw3atmt0c@garden>
References: <20090702223944.GR15302@Sun.COM> <op.uwh9t2mnatmt0c@garden>
	<20090703215528.GY15302@Sun.COM> <op.uwi7j3uaatmt0c@garden>
	<20090706173441.GL15302@Sun.COM> <op.uwpaclw3atmt0c@garden>
Message-ID: <20090707152105.GM5073@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jul 07, 2009  17:56 +0400, Mike Pershin wrote:
> On Mon, 06 Jul 2009 21:34:41 +0400, Nicolas Williams  
> <Nicolas.Williams@sun.com> wrote:
> > In my proposal what would happen is that opens would only be recovered
> > by _replay_ when the transaction had not yet been committed, otherwise
> > the opens will be recovered by making a _new_ (non-replay) open RPC.
> 
> Yes, I understood that and agree that this looks like more clean  
> implementation but I see the following problems so far:
>   - two kinds of client - new and old that should be handled somehow
>   - client code should be changed a lot
>   - server need to understand and handle this too
> 
> What will we get for this? Sorry for my annoyance, but it looks for me  
> that it can be solved in simpler ways. E.g. you can add MGS_OPEN_REPLAY  
> flag to such requests, so it will be also different in wire from  
> transaction replays. Or we could re-use lock replay functionality somehow.  
> The locks are not kept as saved RPC too but enqueued as new requests. The  
> open is very close to this, I agree with idea that open handle has all  
> needed info and no need to keep original RPC in this case.

There are actually multiple benefits from this change:
- we can remove the awkward handling of open RPCs that are saved even
  after they have been committed to disk.  That code has had so many
  bugs in it (and probably still has some) I will be happy when it is gone.
- we don't have RPCs saved for replay that cannot be flushed during
  a server upgrade.  For the Simplified Interoperability feature we
  need to be able to clear all of the saved RPCs from memory so that
  it is possible to change the RPC format over an upgrade.  Regenerating
  the _new_ RPCs from the open file handles allows this to happen.

> I mean that proposed solution looks overcomplicated just to solve  
> signature problem though it makes sense in general. If we are going to  
> re-organize open recovery and have time for this it would be better to  
> move it from context of replay signature to separate task as it is quite  
> complex.

To my thinking, I don't know that we need to introduce a new RPC _type_
for the open, AFAIK the old open replay RPC will already do open-by-FID.
What is the core change here is that the open RPCs will be newly generated
at recovery time instead of being kept in memory.

This actually has a second benefit in that we don't have to keep huge
lists of open RPCs in the replay list that will be skipped each time we
are trying to cancel committed RPCs.  For HPCS we need to handle 100k
opens on a single client, and cancelling RPCs from the replay list is
an O(n^2) operation since it does a list walk to find just-committed RPCs.

> > I'm not sure why a new stage would necessarily slow recovery in a
> > significant way.  The new stage would not involve any writes to disk
> > (though it would involve reads, reads which could then be cached and
> > benefit the transaction recovery phase).
> 
> Not necessarily, but it can. It is not about open stage only, it is about  
> the whole approach to do recovery by stages when all clients must wait for  
> any other at each stage before they can continue recovery. We have already  
> this in HEAD and it extends recovery window. Lustre 1.8 had only single  
> timer for recovery, Lustre 2.0 has 3 stages and timer should be re-set  
> after each one.

Actually, the need to have separate recovery stages in HEAD is no longer
needed.  The addition of extra replay stages was a result of fixing a bug
in recovery where open file handles were not being replayed before another
client unlinked the file.  However, this has to be fixed for VBR delayed
recovery anyways, so we may as well fix this with a single mechanism
instead of adding a separate recovery stage that requires waiting for
all clients to join or be evicted before any recovery can start.

[details for the above]

INITIAL ORDER
=============
client 1			client 2		MDS
--------			--------		---
open A  (transno N)
{use A}							***commit >= N***
				unlink A (transno X)
{continue to use A}
							***crash***

REPLAY ORDER
============
client 1			client 2		MDS
--------			--------		---
{slow reconnect}					***last committed < X***
				unlink A (transno X)
open A (transno N) = -ENOENT
{A can no longer be used}


The proper solution, as also needed by delayed recovery, is to move A
to the PENDING list during replay and remove it at the end of replay.
With 1.x we would have to also remove the inode from PENDING if some
other node reuses that inode number, but since this extra recovery
stage is only present in 2.0 and we will not implement delayed recovery
for 1.x we can simply remove all unreferenced inodes from PENDING at
the end of recovery (until delayed recovery is completed).

It would be possible to flag the unlink RPCs with a special flag (maybe
just OBD_MD_FLEASIZE/OBD_MD_FLCOOKIE) to distinguish between unlinks
that also destroy the objects, and unlinks that cause open-unlinked files.
For replayed unlinks that cause objects to be destroyed we know that
there are no other clients holding the file open after that point and
we don't have to put the inode into PENDING@all.

> If all clients are alive than the recovery time will be  
> mostly the same, but if clients may gone during recovery then lustre 2.0  
> recovery time can be three times longer already. Just imagine that at each  
> stage one client is gone, then at each stage all clients will wait until  
> timer expiration. And the bigger cluster we have the more clients can be  
> lost during recovery so recovery time may differ significantly.
> Also this means that server load is not well distributed over recovery  
> time. It waits then start doing all requests at once then waits again on  
> other stage, etc.
> 
> Another point here is the possible using the version recovery instead of  
> transaction-based recovery. This will makes recovery based on versions of  
> object and it makes just no sense to wait all clients at each recovery  
> stage, because all dependencies should be clear from versions and clients  
> may finish recovery independently. Currently the requests can be recovered  
> by versions and there is work on lock replays using versions too.

I fully agree - it would be ideal if recovery started immediately without
any waiting for other clients.

> > Suppose we recovered opens after transactions: we'd still have
> > additional costs for last unlinks since we'd have to put the object on
> > an on-disk queue of orpahsn until all open state is recovered.  See
> > above.
> 
> There is no additional cost for pair of open-unlink because orphan is  
> needed anyway after unlink. The only exception is replay of pure unlink.  
> But we need to keep orphans after unlinks for other cases anyway, e.g.  
> delayed recovery and such overhead is nothing compared with time that can  
> be lost on waiting for everyone as described above.

Agreed.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
