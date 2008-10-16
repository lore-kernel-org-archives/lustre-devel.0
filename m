From: Eric Barton <eeb@sun.com>
Date: Thu, 16 Oct 2008 22:56:34 +0100
Subject: [Lustre-devel] "Simple" HSM straw man
In-Reply-To: <48F4F5DA.7090000@sun.com>
References: <48EE87A1.7000003@sun.com> <48F379B4.6040209@cea.fr>
	<48F4F5DA.7090000@sun.com>
Message-ID: <CE2BF0610E4C4692A3DDDD842249AAE2@ebpc>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nathan,

> True, but I don't really see a large market for partially purged files, 
> so I don't really believe that it is worth the effort.  One of the 
> important points here is that we are deleting stripes off the OSTs, 
> freeing up space, and we won't necessarily restore to those same OSTs.  
> As soon as we have partially purged files that's no longer the case, and 
> I think complicates things too much.

Partially purged files is a requirement to allow graphical file browsers
to retrieve icons from within the file.  It's OK to miss this out in the
first version, but it has to be there for the full product.

> >> Algorithms
> >> 1. copyout
> >>     a. Policy engine decides to copy a file to HSM, executes 
> >>        HSMCopyOut ioctl on file
> >>     b. ioctl handled by MDT, which passes request to Coordinator
> >>     c. coordinator dispatches request to mover.  request should 
> >>        include file extents (for future purposes)
> >>     d. normal extents read lock is taken by mover running on client
> >>     e. mover sets "copyout_begin" bit and clears "hsm_dirty" bit in EA.
> >>     f. any writes to the file set the "hsm_dirty" bit (may be 
> >>        lazy/delayed with mtime or filesize change updates on MDT).  Note 
> >>        that file writes need not cancel copyout; for a fs with a single big 
> >>        file, we don't want to keep interrupting copyout or it will never 
> >>        finish. 
> >
> > Is it interesting to have a file that is outdated and possibly 
> > uncoherent?
> It is probably useful in some cases -- simulation checkpoints maybe.

A corrupt simulation checkpoint is useless.  We _must_ provide a way to
ensure the HSM copy of a file is a known good snapshot.  We don't necessarily
have to abort the copyout if there is an update that could mean the
HSM copy would be corrupt since we can always just copy it out again,
but it doesn't seem hugely complicated to notify the backend, if not
the agent and let it decide.

> > Are you sure you want to remove those objects if we will need them 
> > later, in "complex" HSM?
> > As this mecanism will need to change a lot when we will implement the 
> > restore-in-place feature, i'm not sure this is the best idea.
> Ah, I think it is important that we do NOT restore in place to the old 
> OST objects.  The OSTs may now be full, or indeed not exist anymore.  
> The restore in place for complex HSM is at the file level; the objects 
> may move around.  "Complex" in this case just means that clients will 
> have access to partially restored files.

Can't the "complex" HSM restore to new objects?  It just depends on when
the new-being-restored objects become the new contents of the file doesn't it?

> > Copy-out
> > - Mover take a specific lock on range (0-EOF for the moment)
> > - On this range, reads pass, writes raise a callback on the mover.
> > - Receiving this callback, if the mover release its lock, the copyout 
> > is cancelled, if not, the write i/o is blocked 
> I don't think we want to block the write just because the HSM copy isn't 
> done yet.  If the data is changing, then the policy engine shouldn't 
> have started a copyout process in the first place. 

Indeed.

> If the customer's 
> goal is to do a coherent checkpoint, then it should explicitly wait for 
> the copyout to be done.  

Disagree - the customer doesn't have to know a copyout is in progress.
The HSM should abort the copyout or mark the copy corrupt.

> If it's just the policy engine that got it 
> wrong, it doesn't matter if it finishes or not; the file will be marked 
> "hsm_dirty", and so the policy engine should re-queue it for copyout 
> again later, and it can't be purged in the meantime since the dirty bit 
> is set.

Indeed.


    Cheers,
              Eric
