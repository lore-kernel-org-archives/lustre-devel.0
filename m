From: Andrew C. Uselton <acuselton@lbl.gov>
Date: Mon, 16 Mar 2009 15:41:44 -0700
Subject: [Lustre-devel] protocol backofs
In-Reply-To: <20090316221316.GM1408@mcs.anl.gov>
References: <49BEA192.2050701@lbl.gov> <029901c9a66b$d7107020$85315060$@com>
	<49BEB984.5030206@lbl.gov> <20090316221316.GM1408@mcs.anl.gov>
Message-ID: <49BED5A8.4060703@lbl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Robert Latham wrote:
> On Mon, Mar 16, 2009 at 01:41:40PM -0700, Andrew C. Uselton wrote:
>> Howdy Isaac,
...
> 
> Hi Andrew.  Yes, there is no way to avoid me...  I don't have too much
> information about Lustre but I can tell you a bit about Madbench and
> MPI-IO.
> 
Glad to hear from you :)
...
> Cray's MPI-IO is old enough that it's doing "generic unix" file system
> operations.  (I've committed the optimized Lustre driver, but it will
> take some time for it to end up on a Cray). 
> 
I am looking over David Knaak's shoulder even as we speak (electron?).

> Madbench is doing independent I/O, though, so optimized or no, there
> is no "aggregation" -- it's a shame, too, as it sounds like
> aggregation would at least rule out your contention theory.  

When you say "independent" you mean it isn't using MPI "collective" I/O, 
yes?  That is true, just making sure I understand your comment.

> 
> How big is an individual madbench I/O operation for you?  We ran some

I usually run madbench "as large as possible".  That ends up with the 
target buffer for I/O in the 300 MB range.

> 
> So, off the top of my head I don't have too many ideas from an MPI-IO
> perspective.  Your graphs suggest irregular performance on franklin
> for both reads and writes
> (http://www.nersc.gov/~uselton/frank_jag/20090215183709/rate.png), so
> that kind of rules out interference from the lock manager.

There is some variability in the writes (and reads in other tests), but 
the MPI-I/O, middle-phase reads seem to be a special case.  Those delays 
are an order of magnitude higher and do not seem to correspond to any 
I/O activity.  That's why I'm hoping for a protocol backoff induced by 
congestion.  Also note that in that phase, and only in that phase, each 
node has been given 1.2 GB to send to the file and immediately asked to 
read that much back in from a different offset.  I've looked quite 
carefully and none of the I/O is outside its locked range as established 
in the first "writes" phase, so there should be no lock traffic during 
this phase.  So in this middle phase there may be extra resource 
contention in kernel space on each node.  So an alternative might be a 
low-probability near-deadlock on those resources where writes are still 
being drained but reads are already demanding attention.

> 
> to me, your contention idea is still in play.
> 
> ==rob
> 

I think I forgot to mention:  NERSC is soon planning to extend the 
Franklin I/O resources so they look a lot more like Jaguar's.  When they 
do we'll be able to "do the experiment", in that if the delay disappears 
that argues for contention in the torus getting to the OSSs or in the 
OSSs themselves.  I'm still stumped for why it would only happen in the 
MPI-I/O case, though.
Cheers,
Andrew
