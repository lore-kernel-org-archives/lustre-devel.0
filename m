From: Eric Barton <eeb@sun.com>
Date: Fri, 06 Mar 2009 13:25:49 +0000
Subject: [Lustre-devel] create performance
In-Reply-To: <20090305214620.GJ3199@webber.adilger.int>
References: <49AEE953.2030401@sun.com> <m3ocwg61jc.fsf@bzzz.home.net>
	<49B00E4D.2080806@sun.com> <20090305214620.GJ3199@webber.adilger.int>
Message-ID: <049301c99e5f$10ee3c60$32cab520$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Moving this discussion to lustre-devel...

OST object placement is a hard problem with conflicting requirements
including...

1. Even server space balance
2. Even server load balance
3. Minimal network congestion
4. Scalable ultra-wide file layout descriptor
5. Scalable placement algorithm

Implementing a placement algorithm with a centralized server clearly
isn't scalable and will have to be reworked for CMD.  A starting
point might be to explore how to ensure CROW goes some way to
satisfy requirements 1-3 above.

BTW, I've long believed that it's a mistake not to give Lustre any
inkling that all the creates done by a FPP parallel application are
somehow related - e.g. via a cluster-wide job identifier.  Surely
file-per-process placement is very close to shared file placement
(minus extent locking conflicts :)?  I recognize that fixing this
still leaves the problem of how to get best F/S utilization when
different applications share a cluster - but I don't think they are
necessarily the same problem and trying to address them both with the
same solution seems wrong.

    Cheers,
              Eric

> -----Original Message-----
> From: Andreas.Dilger at Sun.COM [mailto:Andreas.Dilger at Sun.COM] On Behalf Of Andreas Dilger
> Sent: 05 March 2009 9:46 PM
> To: Nathaniel Rutman
> Cc: lustre-tech-leads at sun.com
> Subject: Re: create performance
> 
> On Mar 05, 2009  09:39 -0800, Nathaniel Rutman wrote:
> > Alex Zhuravlav wrote:
> >>>>>>> Nathaniel Rutman (NR) writes:
> >>  NR> What about preallocating objects per client, on the clients?
> >>  NR> Client still needs to get a namespace entry from MDT, but could then
> >>  NR> hold a write layout lock
> >>  NR> and do it's own round-robin allocation.  For clients with subtree
> >>  NR> locks this could avoid any need to talk to the MDT and wouldn't need
> >>  NR> the writeback cache.
> >>
> >> I thought "avoid any need to talk to MDT" implies "writeback cache"
> >
> > Hmm, well, maybe you consider this a limited version of writeback cache?
> > It would be kind of a notification of "here is the layout/objects of my
> > new file, with my new fid."  Fid ranges and object numbers would be
> > granted to clients for their own use, and the MDT would only have to do
> > the namespace entry, asynchronously.  I suppose there's recovery issues
> > we have to worry about then.
> >
> > What I was really trying to get at was to avoid the two step process of
> > client -> MDT -> OST stripe allocation, which includes an extra network
> > hop in some precreation starvation cases, and always includes some (a
> > little?) cpu on the MDT:
> > 1. clients get object grants for every OST.
> > 2. clients assign objects to new files and send in reqs to MDT, which
> > just records the objects in the LOV EA
> > 3. MDT batches up the assigned objects and sends to OSTs for orphan
> > cleanup llog.
> 
> The main problem with having many clients do precreation themselves is
> that this will invariably cause load imbalance on the OSTs, which will
> cause long-term file IO performance problems (much in excess of the
> performance problems hit during precreate).
> 
> Cray recently filed a bug on the read performance of files being noticably
> hurt by QOS object allocation due to space imbalance, even thoguh the MDS
> is trying to balance across OSTs locally, but is using random numbers to
> do this and is not selecting OSTs evenly.
> 
> In a file-per-process checkpoint (say 100 processes/files on 100 OSTs)
> the MDS round-robin will allocate 1 object per OST evenly across all
> OSTs (excluding the case where an OSC is out of preallocated objects).
> If clients are doing the allocation (or in the past when the MDS did
> "random" OST selection) then the chance of all 100 clients allocating
> on 100 OSTs is vanishingly small.  Instead it is likely that some OSTs
> will have no objects used, and some will have 2 or 3 or 4, and the
> aggregate write performance will FOREVER be 50% or 33% or 25% of the
> MDS-round-robin allocated objects for that set of files.  That is far
> worse than waiting 1s for the MDS to allocate the objects.
> 
> IMHO, if we are doing WBC on the client, then there is no _requirement_
> that the client has to allocate objects for the files at all, and any
> write data could just be in the client page cache.  Until the new file
> is visible on the MDS to another client nobody can even try to access
> the data.  Once the WBC cache is flushed to the MDS then objects can
> be allocated by the MDS evenly (granting an exclusive layout lock to the
> client in the process) until the cached client data is either flushed to
> disk or at least protected by extent locks and can be partially flushed
> as needed.
> 
> Note that I don't totally object to WBC clients doing object allocations
> if they are creating a large number of files, in essence becoming an
> MDS that is tracking the load on the OSTs and balancing object creation
> appropriately.  What I object to is the more common case where each
> client is creating a single file for a large FPP checkpoint, and the
> clients all selecting the OSTs separately.
> 
> Cheers, Andreas
> --
> Andreas Dilger
> Sr. Staff Engineer, Lustre Group
> Sun Microsystems of Canada, Inc.
