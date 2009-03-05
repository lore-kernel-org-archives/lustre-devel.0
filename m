From: Andreas Dilger <adilger@sun.com>
Date: Thu, 05 Mar 2009 14:27:00 -0700
Subject: [Lustre-devel] LustreFS performance
In-Reply-To: <49AEBA28.5050700@sicortex.com>
References: <3376C558-E29A-4BB5-8C4C-3E8F4537A195@sun.com>
	<02FEAA2B-8D98-4C2D-9CE8-FF6E1EB135A2@sun.com>
	<8AD540D2-0B50-4630-B794-E65443352696@Sun.COM>
	<20090302204501.GQ3199@webber.adilger.int>
	<5BC7F78A-7FD4-4F54-A1C9-F7A632EA7200@sun.com>
	<49AEBA28.5050700@sicortex.com>
Message-ID: <20090305212700.GI3199@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mar 04, 2009  12:28 -0500, Jeff Darcy wrote:
> Oleg Drokin wrote:
>> On Mar 2, 2009, at 3:45 PM, Andreas Dilger wrote:
>>> Note that strictly speaking we need to use ldiskfs on a ramdisk, not
>>> tmpfs, because we don't have an fsfilt_tmpfs.
>>
>> The idea was loop device on tmpfs, I think.
>
> FYI, this is exactly what we do with our FabriCache feature - i.e. both  
> MDT and OSTs are actually loopback files on tmpfs.

The problem with using a loop device instead of a ramdisk is that you now
have 2 layers of indirection - MDS->ldiskfs->loop->tmpfs->RAM instead of
MDS->ldiskfs->RAM.  The drawback (or possibly benefit) is that ramdisks
consume a fixed amount of RAM and are not "sparse" (AFAIK, that may have
changed since I last looked into this).  That said, once a block is written
to by mke2fs or by ldiskfs in the loop->tmpfs case it will also never be
freed again, so you only get some marginal benefit.

> Modulo a few issues  
> with preallocated write space eating all storage leaving none for actual  
> data, it works rather well producing high performance numbers and giving  
> LNDs a good workout.  BTW, the loopback driver does copies and is  
> disturbingly single-threaded, which can create a bottleneck.  This can  
> be worked around with multiple instances per node, though.

Even better, if you have some development skills, would be to implement
(or possibly resurrect) an fsfilt-tmpfs layer.  Since tmpfs isn't going
to be recoverable anyways (I assume you just reformat from scratch when
there is a crash), then you can make all of the transaction handling
as no-ops, and just implement the minimal interfaces needed to work.
That would allow unlinked files to release space from tmpfs, and also
avoid the fixed allocation overhead and journaling of ldiskfs, probably
saving you 5% of RAM (more on the MDS) and a LOT of memcpy() overhead.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
