From: Eric Barton <eeb@sun.com>
Date: Wed, 24 Dec 2008 12:35:55 +0000
Subject: [Lustre-devel] global epochs [an alternative proposal,
	long and dry].
In-Reply-To: <20081223233753.GJ5000@webber.adilger.int>
References: <18767.18277.958956.959956@gargle.gargle.HOWL>
	<494F7F6B.9080509@sun.com>
	<18767.35839.133024.625896@gargle.gargle.HOWL>
	<494FA7E8.7030200@sun.com>
	<18767.52005.485425.412677@gargle.gargle.HOWL>
	<494FD020.70909@sun.com> <18767.58149.550264.505562@gargle.gargle.HOWL>
	<20081223233753.GJ5000@webber.adilger.int>
Message-ID: <017f01c965c4$2ab6fac0$8024f040$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas, Nikita, Alex,

We will go through this in detail at the tech leads meeting in Beijing.

I think I am beginning to understand Nikita's proposal and I think it helps
to adopt his use of "operation" (rename, mkdir etc) and "update" (the part
of an operation executed on a single server).

I believe it would be especially useful if we could finish working through
the previous proposal too - then we would start to understand the
similarities and differences and that in turn would allow us to make
better critical judgments overall - e.g what is the volume and pattern
of additional message passing required for distributed operations, what
are the expected sizes of undo/redo logs, how does aggregation designed
to mitigate these issues affect latency etc.

A major concern I have with whatever scheme we finally adopt, is how to
ensure the performance of synchronous metadata operations (as required by
NFS) isn't completely hosed.  With CMD, you can only be sure an operation
is stored stably when it can no longer be undone - i.e. when it and all
operations it is transitively dependent on have been committed globally.
Making this fast seems to be in direct opposition to scaling throughput,
so understanding the tradeoff precisely seems essential.

    Cheers,
              Eric

> -----Original Message-----
> From: Andreas.Dilger at Sun.COM [mailto:Andreas.Dilger at Sun.COM] On Behalf Of Andreas Dilger
> Sent: 23 December 2008 11:38 PM
> To: Nikita Danilov
> Cc: Alex Zhuravlev; lustre-tech-leads at sun.com; lustre-devel at lists.lustre.org
> Subject: Re: global epochs [an alternative proposal, long and dry].
> 
> Nikita,
> I still need more time to re-read and digest what you have written,
> but thanks in advance for taking the time to explain it clearly and
> precisely.  This algorithm does seem to be related to the one originally
> described in Peter's "Cluster Metadata Recovery" paper where the epoch
> numbers are pushed and replied by every request, but is much better
> described.
> 
> 
> I think what would help me understand it a bit easier if it could be more
> closely mapped onto a potential implementation, and the issues we may see
> there.  For example, the issue with fsync possibly involving all? nodes
> (including clients) is not obvious from your description.
> 
> Similarly, some description of the practical requirements for message
> exchange, how easy/hard it would be to e.g. "find all undo records
> related to...", and the practical bound of the number of operations that
> might have to be kept in memory and/or rolled back/forward during
> recovery would be useful.
> 
> In particular, the mention that clients need to participate to determine
> the oldest uncommitted operation seems troublesome unless the servers
> themselves can place a bound on this by the frequency of their commits.
> 
> 
> On Dec 22, 2008  21:57 +0300, Nikita Danilov wrote:
> > Any message is used as a transport for epochs, including any reply
> > from a server. So a typical scenario would be
> >
> >
> > client                server
> >    epoch = 8            epoch = 9
> >
> >    LOCK --------------->
> >         <-------------- REPLY
> >    epoch = 9
> >                         <----- other message with epoch = 10 from somewhere
> >                         epoch = 10
> >    ....
> >
> >    REINT --------------->
> >          <-------------- REPLY
> >    epoch = 10
> >
> >                         <----- other message with epoch = 11 from somewhere
> >                         epoch = 11
> >
> >    REINT --------------->
> >          <-------------- REPLY
> >    epoch = 11
> >
> > etc. Note, that nothing prevents server from increasing its local epoch
> > before replying to every reintegration (this was mentioned in the
> > original document as an "extreme case"). With this policy there is never
> > more than one reintegration on a given client in a given epoch, and we
> > can indeed implement stability algorithm without clients.
> 
> I was wondering if we could make some analogies between the current
> transno-based recovery system and your current proposal.  For example,
> in our current recovery we increment the transno on the server before
> the reply for every reintegration, and due to single-RPC-in-flight to
> the client it could be considered in a separate "epoch" for every RPC
> to match your "extreme case" above.
> 
> Similarly, I wonder if we could somehow map client (lack of) involvement
> in epochs to our current configuration, and only require "client"
> participation in the case of WBC or CMD?
> 
> 
> One thing that crossed my mind at this point is that the 1.8 servers already
> track recovery "epochs" for VBR using the transno (epoch is in high 32-bit
> word of transno, counter is in low 32-bit word).  These "recovery epochs"
> are not (currently) synchronized between servers, but that would seem to be
> possible/needed in the future.
> 
> Alternately, we might consider the VBR recovery "epochs" to be the same
> as the epochs you are proposing, and transno increment does not affect
> these epochs except to order operations within the epoch.  We would
> increment these epochs periodically (either due to too many operations,
> or time limit).
> 
> The current VBR epochs only make up 32 bits of the transno, but we might
> consider increasing the size of this epoch field to allow more epochs.
> If we need to do that it should preferrably be done ASAP before the 1.8.0
> release is made (this would be a trivial change at this stage).
> 
> 
> Cheers, Andreas
> --
> Andreas Dilger
> Sr. Staff Engineer, Lustre Group
> Sun Microsystems of Canada, Inc.
