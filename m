From: Andreas Dilger <adilger@sun.com>
Date: Tue, 31 Mar 2009 12:51:11 -0600
Subject: [Lustre-devel] Oleg/Mike Work on Apps Metrics - FW: Mike
	Booth	week ending 2009.03.15
In-Reply-To: <5CE22E46-771C-47EE-9CAC-26A37C87C466@sun.com>
References: <D691F7E6-6030-4EB9-896C-77201445D865@Sun.COM>
	<C5E2A328.36EE0%Daniel.Ferber@Sun.Com>
	<015c01c9a5a7$cb2f83a0$618e8ae0$@com>
	<52E982EB-3ADE-46FA-A7BC-D1645961DF0B@Sun.COM>
	<018101c9a5b6$25dbc300$71934900$@com>
	<48A6CF99-F630-4581-9FFC-05E3AFF66FA0@Sun.COM>
	<023201c9a636$a987e4b0$fc97ae10$@com>
	<5CE22E46-771C-47EE-9CAC-26A37C87C466@sun.com>
Message-ID: <20090331185111.GL3199@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mar 18, 2009  16:31 -0400, Oleg Drokin wrote:
> On Mar 16, 2009, at 8:56 AM, Eric Barton wrote:
> > I _do_ agree that for some apps, if there was sufficient memory on the
> > app node to buffer the local component of a checkpoint and let it
> > "dribble" out to disk would achieve better utilization of the compute
> > resource.  However parallel apps can be very sensitive to "noise" on
> > the network they're using for inter- process communication - i.e. the
> > checkpoint data has either to be written all the way to disk, or at
> > least buffered somewhere so that moving it to disk will not interfere
> > with the app's own communications.
> > This latter concept is the basis for the "flash cache" concept.
> > Actually, I think it's worth exploring the economics of it in more
> > detail.
> 
> This turns out to be a very true assertion. We (I) do see a huge delay
> in e.g. MPI barriers done immediately after write.

While this is true, I still believe that the amount of delay seen by
the application cannot possibly be worse than waiting for all of the
IO to complete.  Also, the question is whether you are measuring the
FIRST MPI barrier after the write, vs e.g. the SECOND MPI barrier
after the write?  Since Lustre is currently aggressively flushing the
write cache then the first MPI barrier is essentially waiting for all
of the IO to complete, which is of course very slow.  The real item
of interest is how long the SECOND MPI barrier takes, which is what
the overhead of Lustre IO is on the network performance.


It is impossible that Lustre IO completely saturates the entire
cross-sectional bandwidth of the system OR the client CPUs, so having
some amount of computation for "free" during IO is still better than
waiting for the IO to complete.

For example, we have 1000 processes each doing a 1GB write to their own
file, and the aggregate IO bandwidth is 10GB/s the IO will take about 100s
to write if (as we currently do) limit the amount of dirty data on each
client to avoid interfering with the application, and no computation can
be done during this time.  If we allowed clients to cache that 1GB of
IO it might only take 1s to complete the "write" and then 99s to flush
the IO to the OSTs.

If each compute timestep takes 0.1s during IO vs 0.01s without IO and
you would get 990 timesteps during the write flush in the second case
until the cache was cleared, vs. none in the first case.  I suspect
that the overhead of the MPI communication on the Lustre IO is small,
since the IO will be limited by the OST network and disk bandwidth,
which is generally a small fraction of the cross-sectional bandwidth.

This could be tested fairly easily with a real application that is
doing computation between IO, instead of a benchmark that is only doing
IO or only sleeping between IO, simply by increasing the per-OSC write
cache limit from 32MB to e.g. 1GB in the above case (or 2GB to avoid the
case where 2 processes on the same node are writing to the same OST).
Then, measure the time taken for the application to do, say, 1M timesteps
and 100 checkpoints with the 32MB and the 2GB write cache sizes.

> > The variables are aggregate network bandwidth into the distributed
> > checkpoint cache, which determines the checkpoint time, and aggregate
> > path-minimum bandwidth (i.e. lesser of network and disk bandwidth)
> > from the cache to disk, which determines how soon the cache can be
> > ready for the next checkpoint.  The cache could be dedicated nodes and
> > storage (e.g. flash) or additional storage on the OSSes, or any
> > combination of either.  And the interesting relationship is how
> > compute cluster utilisation varies with the cost of the server and
> > cache subsystems.
> 
> The thing is, if we can just flush out data from the cache at the moment
> when there is no network-latency critical activity on the app side  
> (somehow signaled by the app), why would we need the flash storage at
> all? We can write nice sequential chunks to normal disks just as fast,
> I presume.

Actually, an idea I had for clusters that are running many jobs at once
was essentially having the apps poll for IO capacity when doing a
checkpoint, so that they can avoid contending with other jobs that are
doing checkpoints at the same time.  That way, an app might skip an
occasional checkpoint if the filesystem is busy, and instead compute
until the filesystem is less busy.

This would be equivalent to the client node being able to cache all of
the write data and flushing it out in the background, so long as the
time to flush a single checkpoint never took longer than the time
between checkpoints.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
