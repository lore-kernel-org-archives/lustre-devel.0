From: Austin S. Hemmelgarn <ahferroin7@gmail.com>
Date: Thu, 10 Nov 2016 12:25:37 -0000
Subject: [lustre-devel] [PATCH] f2fs: support multiple devices
In-Reply-To: <4ec4d8f2-da23-762d-ba81-12e76ed09793@cn.fujitsu.com>
References: <20161109205653.70061-1-jaegeuk@kernel.org>
	<0D1876A8-BB77-4C1A-BE4F-B4A0E81DD4EA@dilger.ca>
	<4ec4d8f2-da23-762d-ba81-12e76ed09793@cn.fujitsu.com>
Message-ID: <749156c9-2b3e-4210-a89b-2d664f9d2fc2@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Qu Wenruo <quwenruo@cn.fujitsu.com>, Andreas Dilger <adilger@dilger.ca>, Jaegeuk Kim <jaegeuk@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Lustre Development <lustre-devel@lists.lustre.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-f2fs-devel@lists.sourceforge.net, linux-btrfs <linux-btrfs@vger.kernel.org>, "Darrick J. Wong" <darrick.wong@oracle.com>

On 2016-11-09 21:29, Qu Wenruo wrote:
>
>
> At 11/10/2016 06:57 AM, Andreas Dilger wrote:
>> On Nov 9, 2016, at 1:56 PM, Jaegeuk Kim <jaegeuk@kernel.org> wrote:
>>>
>>> This patch implements multiple devices support for f2fs.
>>> Given multiple devices by mkfs.f2fs, f2fs shows them entirely as one big
>>> volume under one f2fs instance.
>>>
>>> Internal block management is very simple, but we will modify block
>>> allocation and background GC policy to boost IO speed by exploiting them
>>> accoording to each device speed.
>>
>> How will you integrate this into FIEMAP, since it is now possible if a
>> file is split across multiple devices then it will return ambiguous block
>> numbers for a file.  I've been meaning to merge the FIEMAP handling in
>> Lustre to support multiple devices in a single filesystem, so that this
>> can be detected in userspace.
>>
>> struct ll_fiemap_extent {
>>         __u64 fe_logical;  /* logical offset in bytes for the start of
>>                             * the extent from the beginning of the file
>>                             */
>>         __u64 fe_physical; /* physical offset in bytes for the start
>>                             * of the extent from the beginning of the
>> disk
>>                             */
>>         __u64 fe_length;   /* length in bytes for this extent */
>>         __u64 fe_reserved64[2];
>>         __u32 fe_flags;    /* FIEMAP_EXTENT_* flags for this extent */
>>         __u32 fe_device;   /* device number for this extent */
>>         __u32 fe_reserved[2];
>> };
>
> Btrfs introduce a new layer for multi-device (even for single device).
>
> So fiemap returned by btrfs is never real device bytenr, but logical
> address in btrfs logical address space.
> Much like traditional soft RAID.
This is a really important point.  BTRFS does a good job of segregating 
the layers here, so the file-level allocator really has very limited 
knowledge of the underlying storage, which in turn means that adding 
this to BTRFS would likely be a pretty invasive change for the FIEMAP 
implementation.
>
>>
>> This adds the 32-bit "fe_device" field, which would optionally be filled
>> in by the filesystem (zero otherwise).  It would return the kernel device
>> number (i.e. st_dev), or for network filesystem (with FIEMAP_EXTENT_NET
>> set) this could just return an integer device number since the device
>> number is meaningless (and may conflict) on a remote system.
>>
>> Since AFAIK Btrfs also has multiple device support there are an
>> increasing
>> number of places where this would be useful.
>
> AFAIK, btrfs multi-device is here due to scrub with its data/meta csum.
It's also here for an attempt at parity with ZFS.
>
> Unlike device-mapper based multi-device, btrfs has csum so it can detect
> which mirror is correct.
> This makes btrfs scrub a little better than soft raid.
> For example, for RAID1 if two mirror differs from each other, btrfs can
> find the correct one and rewrite it into the other mirror.
>
> And further more, btrfs supports snapshot and is faster than
> device-mapper based snapshot(LVM).
> This makes it a little more worthy to implement multi-device support in
> btrfs.
>
>
> But for f2fs, no data csum, no snapshot.
> I don't really see the point to use so many codes to implement it,
> especially we can use mdadm or LVM to implement it.
I'd tend to agree on this, if it weren't for the fact that this looks to 
me like preparation for implementing storage tiering, which neither LVM 
nor MD have a good implementation of.  Whether or not such functionality 
is worthwhile for the embedded systems that F2FS typically targets is 
another story of course.
>
>
> Not to mention btrfs multi-device support still has quite a lot of bugs,
> like scrub can corrupt correct data stripes.
This sounds like you're lumping raid5/6 code in with the general 
multi-device code, which is not a good way of describing things for 
multiple reasons.  Pretty much, if you're using just raid1 mode, without 
compression, on reasonable storage devices, things are rock-solid 
relative to the rest of BTRFS.

Yes, there is a bug with compression and multiple copies of things, but 
that requires a pretty spectacular device failure to manifest, and it 
impacts single device mode too (it happens in dup profiles as well as 
raid1).  As far as the raid5/6 stuff, that shouldn't have been merged in 
the state it was in when it got merged, and should probably just be 
rewritten from the ground up.
>
> Personally speaking, I am not a fan of btrfs multi-device management,
> despite the above advantage.
> As the complexity is really not worthy.
> (So I think XFS with LVM is much better than Btrfs considering the
> stability)
