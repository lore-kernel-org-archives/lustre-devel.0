From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Wed, 18 Mar 2009 16:31:50 -0400
Subject: [Lustre-devel] Oleg/Mike Work on Apps Metrics - FW: Mike Booth
 week ending 2009.03.15
In-Reply-To: <023201c9a636$a987e4b0$fc97ae10$@com>
References: <D691F7E6-6030-4EB9-896C-77201445D865@Sun.COM>
	<C5E2A328.36EE0%Daniel.Ferber@Sun.Com>
	<015c01c9a5a7$cb2f83a0$618e8ae0$@com>
	<52E982EB-3ADE-46FA-A7BC-D1645961DF0B@Sun.COM>
	<018101c9a5b6$25dbc300$71934900$@com>
	<48A6CF99-F630-4581-9FFC-05E3AFF66FA0@Sun.COM>
	<023201c9a636$a987e4b0$fc97ae10$@com>
Message-ID: <5CE22E46-771C-47EE-9CAC-26A37C87C466@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Mar 16, 2009, at 8:56 AM, Eric Barton wrote:
> I _do_ agree that for some apps, if there was sufficient memory on the
> app node to buffer the local component of a checkpoint and let it
> "dribble" out to disk would achieve better utilization of the compute
> resource.  However parallel apps can be very sensitive to "noise" on
> the network they're using for inter- process communication - i.e. the
> checkpoint data has either to be written all the way to disk, or at
> least buffered somewhere so that moving it to disk will not interfere
> with the app's own communications.
> This latter concept is the basis for the "flash cache" concept.
> Actually, I think it's worth exploring the economics of it in more
> detail.

This turns out to be a very true assertion. We (I) do see a huge delay
in e.g. MPI barriers done immediately after write.

> The variables are aggregate network bandwidth into the distributed
> checkpoint cache, which determines the checkpoint time, and aggregate
> path-minimum bandwidth (i.e. lesser of network and disk bandwidth)
> from the cache to disk, which determines how soon the cache can be
> ready for the next checkpoint.  The cache could be dedicated nodes and
> storage (e.g. flash) or additional storage on the OSSes, or any
> combination of either.  And the interesting relationship is how
> compute cluster utilisation varies with the cost of the server and
> cache subsystems.

The thing is, if we can just flush out data from the cache at the moment
when there is no network-latency critical activity on the app side  
(somehow
signaled by the app), why would we need the flash storage at all? We can
write nice sequential chunks to normal disks just as fast, I presume.
It is the random i/o patterns that make flash shine.

Bye,
     Oleg
