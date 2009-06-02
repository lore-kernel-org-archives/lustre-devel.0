From: Nicolas Williams <Nicolas.Williams@sun.com>
Date: Tue, 2 Jun 2009 14:38:43 -0500
Subject: [Lustre-devel] create performance
In-Reply-To: <20090309060534.GK3199@webber.adilger.int>
References: <49AEE953.2030401@sun.com> <m3ocwg61jc.fsf@bzzz.home.net>
	<49B00E4D.2080806@sun.com>
	<20090305214620.GJ3199@webber.adilger.int>
	<049301c99e5f$10ee3c60$32cab520$@com>
	<20090309060534.GK3199@webber.adilger.int>
Message-ID: <20090602193838.GA18161@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Mar 09, 2009 at 12:05:34AM -0600, 'Andreas Dilger' wrote:
> On Mar 06, 2009  13:25 +0000, Eric Barton wrote:
> > OST object placement is a hard problem with conflicting requirements
> > including...
> > 
> > 1. Even server space balance
> > 2. Even server load balance
> > 3. Minimal network congestion
> > 4. Scalable ultra-wide file layout descriptor
> > 5. Scalable placement algorithm
> > 
> > Implementing a placement algorithm with a centralized server clearly
> > isn't scalable and will have to be reworked for CMD.  A starting
> > point might be to explore how to ensure CROW goes some way to
> > satisfy requirements 1-3 above.

CROW should satisfy #4 easily because it would allow us to have the same
OST-side FID for all stripes of a file, which combined with a
compression of the stripe configuration of the file (the ordered list of
OSTs) should result in fixed-sized FID for all files.  (For compat,
small FIDs can be expanded when talking to old clients.)

CROW should be mostly orthogonal to #1-3 and #5 though, except that a
good compression technique for the stripe configuration might make it
easier to get even server space and load balance.  Imagine an algorithm
that takes a list of OSTs, stripe count and index as inputs and quickly
outputs an ordered list of <strip-count> OSTs, such that for each index
value you get a pseudo-random permutation of a pseudo-randomly picked
combination of <strip-count> OSTs.  Then we could monotonically
increment that index as a way to generate the next new file's placement.

For this use an LFSR would be a perfect way to get pseudo-randomness (we
don't need cryptographic strength for this purpose).  The index becomes
a seed for the LFSR.  We might need two indexes, actually, one for the
combination of OSTs and one for the permutation thereof.  With a
pseudo-random distribution of combinations and permutations we ought to
get a fair distribution of data and load.

> While CROW can help avoid latency for precreating objects (which can
> avoid some of the object allocation imbalances hit today when OSTs
> are slow precreating objects), it doesn't really fundamentally help
> to balance space and performance of the OSTs.  With any filesystem
> with more than a handful of OSTs there shouldn't be any reason why
> the OSTs precreating can't keep up with the MDS create rate.  Johann
> and I were discussing this problem and I suspect it is only a defect
> in the object precreation code and not a fundamental problem int the
> design.
> 
> I definitely agree that for CMD we will have distributed object
> allocation, but so far it isn't clear whether having more than the
> MDSes and/or WBC clients doing the allocation will improve the
> situation or make it worse.

We really should use CROW for these reasons:

 - CROW enables fixed sized FIDs no matter how large the stripe count
 - no need to go destroy unused pre-created files on MGS reboot

> > BTW, I've long believed that it's a mistake not to give Lustre any
> > inkling that all the creates done by a FPP parallel application are
> > somehow related - e.g. via a cluster-wide job identifier.  Surely
> > file-per-process placement is very close to shared file placement
> > (minus extent locking conflicts :)?
> 
> Yes, I agree.  In theory it should be possible to extract this kind
> of information from the client processes themselves, either by
> examining the process environment (some MPI job launchers store the
> MPI rank there for pre-launch shell scripts) or by comparing the
> filenames being created by the clients.  Any file-per-process job
> will invariably create filenames with the rank in the filename.

Sounds like a good idea, and configurable via regexes (ick, I know).

Even better would be a way to associate a cluster job ID with a set of
processes.  This could be done via Linux keyrings, say.

Nico
-- 
