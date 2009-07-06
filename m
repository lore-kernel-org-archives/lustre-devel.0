From: Nicolas Williams <Nicolas.Williams@sun.com>
Date: Mon, 6 Jul 2009 12:34:41 -0500
Subject: [Lustre-devel] Recovering opens by reconstruction
In-Reply-To: <op.uwi7j3uaatmt0c@garden>
References: <20090702223944.GR15302@Sun.COM> <op.uwh9t2mnatmt0c@garden>
	<20090703215528.GY15302@Sun.COM> <op.uwi7j3uaatmt0c@garden>
Message-ID: <20090706173441.GL15302@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sat, Jul 04, 2009 at 11:10:41AM +0400, Mikhail Pershin wrote:
> On Sat, 04 Jul 2009 01:55:28 +0400, Nicolas Williams  
> <Nicolas.Williams@sun.com> wrote:
> 
> OK, so it is not about fake/malformed client only, that is interesting, is  
> there any preliminary arch/hld document describing that? I am interesting  
> in more backgrounds if any

See bug #18657.

> >In my proposal open state recovery for opens associated with completed
> >transactions would always be done by generating new anonymous open by
> >FID RPCs (not replayed ones).
> 
> Well, I see no difference yet. Currently all open 'replays' are passed  
> right to open_by_fid(), open file and create mfd structure for it, so it  
> is the same on server side at least. Did I miss something?

The difference is on the wire.

Currently open state recovery replays RPCs.  This has a very specific
meaning: the original RPC is sent again with a bit set in the ptlrpc
header to indicate that it is a replay.

When the transaction had already been committed this replay is processed
on the server side as an anonymous open by FID, but on the wire the open
may have been something other than an anon open by FID.

In my proposal what would happen is that opens would only be recovered
by _replay_ when the transaction had not yet been committed, otherwise
the opens will be recovered by making a _new_ (non-replay) open RPC.

> >>>Open recovery must precede uncommitted transaction recovery so as to
> >>>ensure that open state is re-established before unlinks can be replayed
> >>>that would cause the file to be destroyed.
> >>
> >>That requires the server shouldn't start replays from all clients until
> >>'open recovery' is finished from all of them. In fact there is another
> >
> >Correct.
> 
> That is more regression than benefit, having such kind of 'barrier' during  
> recovery leads to longer recovery with not balanced server load. There are  
> couple improvements on the way already to make recovery of each client  
> more independent from others if possible, e.g. the transaction-based  
> recovery can be replaced with version-based only. So adding new barriers  
> is not good case in this terms

I'm not sure why a new stage would necessarily slow recovery in a
significant way.  The new stage would not involve any writes to disk
(though it would involve reads, reads which could then be cached and
benefit the transaction recovery phase).

There is an alternative: recover opens during transaction recovery in
trasaction order, but for committed opens (or opens that had not
filesystem transaction to commit, i.e., opens without O_CREAT) use new
RPCs instead of replay RPCs.  The amount of work should be the same as
with the proposed solution, but with better cache locality of reference.

Also, recovering opens before transactions would bind us to always
having capabilities enabled (see my other post just now).  Whereas the
above alternative would not.

> >>solution for open-unlink problem that was implemented in 1.8. During
> >>recovery the unlink replay doesn't delete file but makes it orphan even  
> >>if
> >>open count is 0. After recovery orphans are cleaned up already, so open
> >>replay after unlink will find orphan and open it.
> >
> >That idea did cross my mind.  The MDS would have to keep a list of such
> >unlinks so it can drop their open count if they truly aren't open.  That
> >seems like a extra work that the MDS shouldn't have to do.
> 
> There is already such mechanism on MDS to handle open-unlink cases. MDS  
> keeps orphaned files while they are opened and deletes all non-reopened  
> after recovery. We can just use this mechanism during recovery moving  
> unlinked files to orphans. It work so already in 1.8 and should be even  
> simpler in 2.0 due to FIDs. There are extra checks only, no need to keep  
> extra list or so. I think this is preferable way to go because we avoid  
> 'barriers' in recovery mentioned above

Suppose we recovered opens after transactions: we'd still have
additional costs for last unlinks since we'd have to put the object on
an on-disk queue of orpahsn until all open state is recovered.  See
above.

Nico
-- 
