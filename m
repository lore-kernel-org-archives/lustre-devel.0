From: Andreas Dilger <adilger@sun.com>
Date: Mon, 11 Feb 2008 20:55:57 -0700
Subject: [Lustre-devel] Lustre HSM HLD draft
In-Reply-To: <47B0B0FF.7060805@sun.com>
References: <47AAE307.9040305@cea.fr> <47ACC71C.7050808@sun.com>
	<47B062BA.1070809@cea.fr> <47B0B0FF.7060805@sun.com>
Message-ID: <20080212035557.GP3029@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Feb 11, 2008  12:33 -0800, Nathaniel Rutman wrote:
> Aurelien Degremont wrote:
> > Nathaniel Rutman a ?crit :
> >> IV2 - why not multiple purged windows?  Seems like if you're going to 
> >> purge 1 object out of a file, you might want to purge more.
> >> Specifically, it will probably be a common case to purge every object of 
> >> a file from a particular OST.  This is not contiguous in a
> >> striped file.
> >> I don't see any reason to purge anything smaller than an entire object 
> >> on an OST - is there good reason for this? 
> >
> > Multiple purged window is subtle. If you permit this feature, you could 
> > technically have, in the worst case, one purged window per byte, and 
> > this could be very huge to store. Do you think you will do several holes 
> > in the same file? In which cases?

One issue is that if you are purging individual objects from a file your
windows will be quite disjoint at the file level.  That may not be a serious
problem for applications that only look at the first and last chunks of a
file.

I can imagine use cases for extremely large files and limited-sized caches
where there is a need to access only subsets of the file (i.e. the entire
file cannot be resident at one time).  That said, it may be this is too
complex for the initial implementation.

> Like I said, I don't see any reason to purge anything smaller than a 
> full object; I would in fact disallow purging of an arbitrary byte range,
> and only allow purging on full-object boundaries.

That is impractical, for the reasons that Aurelien mentioned - we want to
avoid file re-staging for tools like "file" and GUIs that read the start/end
of files to determine file type and icons.

> > In fact, the more common case is to totally purge a file which have been 
> > migrated on HSM, and it is only an optimisation to keep the start and 
> > the end of the file on disk, to avoid triggering tons of cache misses 
> > with commands like "file foo/*" or a tool like Nautilus or Windows 
> > Explorer browsing the directory.
>
> Again, since Lustre is optimized to work with 1MB chunks anyhow, I don't 
> think it helps much to keep less than that in the beginning / end objects,
> so I would say just keep the first and last blocks instead.

What if file is N*1MB + 1 byte?  We need to be able to keep something like
64kB for a windows icon, so having some arbitrary byte range seems reasonable.

> > The purged window is stored by per object, OST object and MDT object.
> > So, if several objects are purged, each object will store its own purged 
> > window. But the MDT object describing this file will store a special 
> > purged window which starts at the smallest unavailable bytes and ends at 
> > the first available one.

I think this should read "ends at the highest range contiguous to the end
of the file" or similar, or it will be misleading in the multi-object case.

> >> the OST must keep track of purged objects, not ranges within an existing 
> >> object.
> >
> > Objects are not removed, only their datas. All metadata are kept.

The one drawback with this approach is that it is not possible to HSM
copy-in objects to a different OST than where they were originally stored.
BUT... in conjunction with the migration tool it should be able to migrate
an (empty) object from one OST to another before the copy-in from HSM,
so long as there is no OST-specific data in the HSM identifier (i.e. the
HSM label is truely opaque).

> >> If the MDT is tracking purged areas also, then there's a good potential 
> >> synergy here with a missing OST --
> >> If the missing OST's objects are marked as purged, then we can 
> >> potentially recover them automatically from
> >> HSM...
> >
> > What do you call a "missing OST" ? A corrupt one ? A offline one? 
> > Unavailable?
>
> Yes.  All of the above. Obviously we need to distinguish between 
> "permanently gone" and "temporarily gone".

I suppose this leads to a requirement to store the object in HSM so
that it can be accessed just by the object FID+version.  That would allow
the OST to be restored from HSM even if the entire OST filesystem is lost,
potentially modifying the FLDB to relocate the FID to a different OST.

> > Where will you copy back the object data ? On another OST object ?
> 
> Yes.  Some kind of recovery will take place to generate a new object on 
> a different OST and we can restore the data there.
> > With the purged window on each OST object and MDT and the file stripping 
> > info, we could easily restore the missing parts.
> 
> Exactly.  This is why I say we should think about this now, to allow for 
> this possibility.

Right.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
