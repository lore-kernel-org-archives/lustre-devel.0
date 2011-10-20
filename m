From: Andreas Dilger <adilger@whamcloud.com>
Date: Thu, 20 Oct 2011 12:45:34 -0600
Subject: [Lustre-devel] Wide striping
In-Reply-To: <3EDC1D49-4A97-4F3A-A9DE-BE2C976665E4@fnal.gov>
References: <73AED5C780AE05478241DB067651A9210237883C@XYUS-EX22.xyus.xyratex.com>
	<3EDC1D49-4A97-4F3A-A9DE-BE2C976665E4@fnal.gov>
Message-ID: <AC496A61-5807-4E46-B7D9-0717E363F0BD@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2011-10-20, at 10:24 AM, Alex Kulyavtsev wrote:
> On Oct 3, 2011, at 3:15 PM, Nathan Rutman wrote:
>> We have been thinking about a different wide-striping method that doesn't have these problems. The basic idea is to create a new stripe type that encodes the list of OSTs compactly, and then using the same (or a calculable) object identifier (or FID) on all these OSTs.
>> 
>> Our version of widestriping does not involve increasing the EA size at all, but instead utilizes a new stripe pattern.  (This will not be understandable by older Lustre versions, which will generate an error locally, or potentially we can convert into the BZ-4424 form if the layout fits in that format). A bitmap will identify which OSTs hold a stripe of this file. The bitmap should probably fit into current ext4 EA size limit, giving us ~32k stripes.
>> 
>> Some OST?s may be down at file creation time, or new OSTs added later; hence there will likely be holes in the bitmap (but relatively few). 
> 
> 1) There will be holes when OST pools used: if the file can be written only to the set of OST from specific OST POOL and if by the virtue of configuration OSTs in the  pool do not represent continuous set then there will be holes in OST bit map even if all OSTs are online.

Since the membership in a pool can change after a file is allocated,
there cannot be anything in the layout that depends on the current
membership of the pool.  In this regard, the layout of a file that
is allocated in the pool should be identical to a non-pool file, with
the exception that it saves the pool name in which the file was created.
That allows future operations (migration, replication, etc) to take the
originally requested pool of the user into account.

> 2) "relatively few holes [in bitmap]" - did you consider compressing bitmap? Like BBC or WAH described at en.wikipedia.org/wiki/Bitmap_index#Compression ? Reportedly you can do bitwise operations without decompression. This way you can go up in number of stripes (well, 32k is big number). But it may help control RPC size - you may represent wide striping with few integers effectively representing continuous blocks and OST holes, the size of the descriptor is the function of # of blocks and holes and to the less extent function of number of stripes.

I think that having some kind of bitmap compression seems reasonable,
and extends the number of stripes that can be fit into a single layout
for most cases.  Originally I was thinking that in addition to saving
the starting index of the bitmap, we could also save the index at which
the bitmap wraps back to 0 (i.e. bit N = (start_idx + N) % wrap_idx),
but if there is bitmap compression then the run of zeroes between the
starting index and the (lower) ending index could be stored efficiently
as well.

> More:
> It is possible to have two bitmaps: 
> 0000000111111111000000111111 - one describing general "blocks" of OST = ((beg1,end1),(beg2,end2))
> 0000000000000010100100100000 - other describing "corrections" - drop two OST, add two OST ; here 4 bits, compressed to X bytes 
> 0000000111111101100100011111 - OST map, computed on client as bitwise XOR to uncompressed maps (1) and (2)
> Each of two maps is compressed for transfer, thus shall not take much space.

Originally, I was thinking that we don't need to do boolean operations
on the compressed bitmaps, but then I recall an idea I had many, many
years ago about clients sending the "desired" (AND "available") OSC
bitmap to the MDS.  When the MDS is allocating objects on the OSTs it
can AND the client bitmap with its allocation bitmap ("pool" bitmap AND
"available objects" bitmap) to get the subset of OSTs where objects can
be allocated.

If we can do operations directly on the compressed bitmaps, not only does
it save space, but it also saves cycles doing the operations.

> 3) If metadata file format going to be changed, is it right time to reserve descriptors to have few replicas of the file data?
>  
> In such case we need to have number of replicas, and layout descriptor for each replica. Each replica may have different number of stripes, thus you can have widely striped file replica on SAS disks (or in flash) and replicate it to slower disk storage with one or "few" stripes for further tape archival.

Right.  I've always thought that the different replicas of the file
would have completely independent layouts, to allow what you suggest.
The striping of a file would be completely different for nearline storage
and archival storage (different OST counts at each layer vs. tape drives).

>  I assume after initial writes file has more or less "stable" content. Replicas can be on different media type, like flash/ SAS/ SATA, fast / cheap disks, effectively Hierarchical Storage.
> I'm thinking about "lazy" replication as you implemented to replicate data to another file system but in this case replication is within the same lustre file system. Client became aware of multiple replicas and can chose  what file replica to use (e.g when some OSTs down). It eliminates OST as single point of failure.

Yes, my initial goal is to have background file replication as opposed
to real-time replication.  The main reason is due to the complexity of
the implementation being lower.  In fact, once we have decided on a new
layout format for RAID-1+0 files, background replication and internal
file migration can largely be implemented with the HSM code.

Cheers, Andreas
--
Andreas Dilger 
Principal Engineer
Whamcloud, Inc.
