From: Robert Latham <robl@mcs.anl.gov>
Date: Mon, 16 Mar 2009 17:13:18 -0500
Subject: [Lustre-devel] protocol backofs
In-Reply-To: <49BEB984.5030206@lbl.gov>
References: <49BEA192.2050701@lbl.gov> <029901c9a66b$d7107020$85315060$@com>
	<49BEB984.5030206@lbl.gov>
Message-ID: <20090316221316.GM1408@mcs.anl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Mar 16, 2009 at 01:41:40PM -0700, Andrew C. Uselton wrote:
> Howdy Isaac,
>    Nice to meet you.  As Eric suggested I am also cc:ing Nick Henke, 
> since he might find this an interesting discussion.  For all you 
> lustre-devel dwellers out there, feel free to chime in.

Hi Andrew.  Yes, there is no way to avoid me...  I don't have too much
information about Lustre but I can tell you a bit about Madbench and
MPI-IO.

> b)  Why is the contention introduced only in the MPI-I/O test and not in 
> the POSIX test?  Does the MPI-I/O from Cray's xt-mpt/3.1.0 divert I/O to 
> a subset of nodes so that all the I/O is going through a smaller section 
> of the torus?

Cray's MPI-IO is old enough that it's doing "generic unix" file system
operations.  (I've committed the optimized Lustre driver, but it will
take some time for it to end up on a Cray). 

Madbench is doing independent I/O, though, so optimized or no, there
is no "aggregation" -- it's a shame, too, as it sounds like
aggregation would at least rule out your contention theory.  

You've essentially written this up on your website already, but for
the wider lustre-devel audience, The MPI-IO in Madbench is dead
simple: 

MPI_File_seek
MPI_File_read or MPI_File_write (or the nonblocking versions)
MPI_Barrier

This is *almost* an exact correspondance to the POSIX case:

fseeko64
fread or fwrite
fclose

Did you see the difference?  I know you did because you wrote
http://www.nersc.gov/~uselton/sf-mpi.html

How big is an individual madbench I/O operation for you?  We ran some
I/O tests with madbench on our bluegene that showed about 20 MB per
operation -- large enough that i'd be surprised if the libc buffering
was having much effect.

So, off the top of my head I don't have too many ideas from an MPI-IO
perspective.  Your graphs suggest irregular performance on franklin
for both reads and writes
(http://www.nersc.gov/~uselton/frank_jag/20090215183709/rate.png), so
that kind of rules out interference from the lock manager.

to me, your contention idea is still in play.

==rob

-- 
Rob Latham
Mathematics and Computer Science Division    A215 0178 EA2D B059 8CDF
Argonne National Lab, IL USA                 B29D F333 664A 4280 315B
