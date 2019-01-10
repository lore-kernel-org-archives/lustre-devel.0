From: Andreas Dilger <adilger@whamcloud.com>
Date: Thu, 10 Jan 2019 07:28:15 +0000
Subject: [lustre-devel] [PATCH v2 33/33] lustre: update version to 2.9.99
In-Reply-To: <87muo9ibuk.fsf@notabene.neil.brown.name>
References: <1546812868-11794-1-git-send-email-jsimmons@infradead.org>
 <1546812868-11794-34-git-send-email-jsimmons@infradead.org>
 <874lakj5ck.fsf@notabene.neil.brown.name>
 <alpine.LFD.2.21.1901080352210.15230@casper.infradead.org>
 <45806D2E-8AAD-48ED-8B14-6D5CC11D824E@whamcloud.com>
 <87muo9ibuk.fsf@notabene.neil.brown.name>
Message-ID: <FE280118-B0C7-416F-8DF0-8E08432DEA23@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Jan 9, 2019, at 17:40, NeilBrown <neilb@suse.com> wrote:
> 
> On Tue, Jan 08 2019, Andreas Dilger wrote:
>> On Jan 7, 2019, at 21:26, James Simmons <jsimmons@infradead.org> wrote:
>>> 
>>>> sanity: FAIL: test_130a filefrag /mnt/lustre/f130a.sanity failed
>>>> sanity: FAIL: test_130b filefrag /mnt/lustre/f130b.sanity failed
>>>> sanity: FAIL: test_130c filefrag /mnt/lustre/f130c.sanity failed
>>>> sanity: FAIL: test_130e filefrag /mnt/lustre/f130e.sanity failed
>>>> sanity: FAIL: test_130f filefrag /mnt/lustre/f130f.sanity failed
>>> 
>>> What version of e2fsprog are you running? You need a 1.44 version and
>>> this should go away.
>> 
>> To be clear - the Lustre-patched "filefrag" at:
>> 
>> https://downloads.whamcloud.com/public/e2fsprogs/1.44.3.wc1/
> 
> I looked at Commit 41aee4226789 ("filefrag: Lustre changes to filefrag] FIEMAP handling") in the git tree instead.
> 
> This appears to add 3 features.
> 
> - It adds an optional device to struct fiemap.
>  Presumably this is always returned if available, else zero is provided
>  which means "the device".

Vanilla filefrag just returns 0 today.  For Lustre filefrag it returns
the OST index on which the blocks are located. For local filesystems
I'm expecting it to return the rdev of the block device, like 0x801 or
similar.

> - It adds a flag FIEMAP_EXTENT_NET which indicates that the device
>  number is *not*  dev_t, but is some fs-specific value

Right.

> - It allows FIEMAP_FLAG_DEVICE_ORDER to be requested.  I can't quite
>  work out what this does.

The logic makes sense once you understand it.  Consider a striped Lustre
file, or perhaps on an MD RAID device.  If you returned the blocks in
file-logical order (i.e. block 0...EOF), then the largest extent that
could be returned for the same device would be stripe_size/chunk_size.
This would be very verbose (e.g. 1TB file with 1MB stripe_size would be
1M lines of output, though still better than the 256M lines from the
old FIBMAP-based filefrag).  This would make it very hard to see if the
file allocation is contiguous or fragmented, which was our original
goal for implementing FIEMAP.

The DEVICE_ORDER flag means "return blocks in the underlying device
order".  This allows returning block extents of the maximum size for
the underlying filesystem (128MB for ext4), and much more clearly
shows whether the underlying file allocation is contiguous or fragmented.
It also simplifies the implementation at the Lustre side, because we
are essentially doing a series of per-OST FIEMAP calls until the OST
object is done, then moving on to the next object in the file.  The
alternative (which I've thought of impementing, just for compatibility
reasons) would be to interleave the FIEMAP output from each OST by the
logical file offset, but it would be ugly and not very useful, except
for tools that want to see if a file has holes or not.

$ filefrag -v /myth/tmp/4stripe 
Filesystem type is: bd00bd0
File size of /myth/tmp/4stripe is 104857600 (102400 blocks of 1024 bytes)
 ext:     device_logical:        physical_offset: length:  dev: flags:
   0:        0..   28671: 1837711360..1837740031:  28672: 0004: net
   1:        0..   24575: 1280876544..1280901119:  24576: 0000: net
   2:        0..   24575: 1535643648..1535668223:  24576: 0001: net
   3:        0..   24575: 4882608128..4882632703:  24576: 0003: last,net

>  Presumably it changes the order that entries are returned (why?) and
>  maybe returns multiple entries for a region that is mirrored ???

The multiple entries per region is needed for mirrored files.

> As you say, I can see how these might be useful to other filesystems.
> Maybe we should try upstreaming the support sooner rather than later.

I've tried a few times, but have been rebuffed because Lustre isn't
in the mainline.  Originally, BtrFS wasn't going to have multiple device
support, but that has changed since the time FIEMAP was introduced.

I'd of course be happy if it was in mainline, or at least the fields
in struct fiemap_extent reserved to avoid future conflicts.  There
was also a proposal from SuSE for BtrFS to add support for compressed
extents, but it never quite made it over the finish line:

   David Serba "fiemap: introduce EXTENT_DATA_COMPRESSED flag"

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
