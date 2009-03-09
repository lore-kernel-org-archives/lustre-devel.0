From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Sun, 08 Mar 2009 22:50:10 -0400
Subject: [Lustre-devel] LustreFS performance
In-Reply-To: <20090305212700.GI3199@webber.adilger.int>
References: <3376C558-E29A-4BB5-8C4C-3E8F4537A195@sun.com>
	<02FEAA2B-8D98-4C2D-9CE8-FF6E1EB135A2@sun.com>
	<8AD540D2-0B50-4630-B794-E65443352696@Sun.COM>
	<20090302204501.GQ3199@webber.adilger.int>
	<5BC7F78A-7FD4-4F54-A1C9-F7A632EA7200@sun.com>
	<49AEBA28.5050700@sicortex.com>
	<20090305212700.GI3199@webber.adilger.int>
Message-ID: <80354020-87CB-4704-8020-D775AEE09A6D@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Mar 5, 2009, at 4:27 PM, Andreas Dilger wrote:
> Even better, if you have some development skills, would be to  
> implement
> (or possibly resurrect) an fsfilt-tmpfs layer.  Since tmpfs isn't  
> going
> to be recoverable anyways (I assume you just reformat from scratch  
> when
> there is a crash), then you can make all of the transaction handling
> as no-ops, and just implement the minimal interfaces needed to work.
> That would allow unlinked files to release space from tmpfs, and also
> avoid the fixed allocation overhead and journaling of ldiskfs,  
> probably
> saving you 5% of RAM (more on the MDS) and a LOT of memcpy() overhead.

This is exactly what I was trying to avoid.
I tried to measure things as if I had an infinitely fast disk only,  
and I
still needed all the journal/blockdevice and other such things to take
the CPU they would normally take.
After all we cannot expect people to actually run real MDSes on tmpfs
unless they have some means to replicate that MDS somewhere else.

Bye,
     Oleg
