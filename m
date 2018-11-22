From: George Melikov <mail@gmelikov.ru>
Date: Thu, 22 Nov 2018 09:53:22 +0300
Subject: [lustre-devel] Compact layouts
In-Reply-To: <9E901853-E6EA-4CFF-825F-21275488E3FC@whamcloud.com>
References: <3600968B-94D3-4C3F-857A-D00A5C3BC601@cray.com>
 <E2B38E8A-55A5-481D-AF44-FF0B4CD8472E@whamcloud.com>
 <MWHPR11MB1488BCF770411CE094423321CBDB0@MWHPR11MB1488.namprd11.prod.outlook.com>
 <9E901853-E6EA-4CFF-825F-21275488E3FC@whamcloud.com>
Message-ID: <5929481542869602@myt3-964eae3a5b05.qloud-c.yandex.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org



22.11.2018, 06:29, "Andreas Dilger" <adilger@whamcloud.com>:
> On Nov 21, 2018, at 19:27, Patrick Farrell <paf@cray.com> wrote:
>> ?Andreas,
>>
>> ?Thanks for the informative reply.
>>
>> ?You raise an interesting and nasty point about breaking the compact layout with movement. It's not possible today to move an individual OST object/stripe, though it's certainly something I've heard people ask for. So it wouldn't be an issue if all such operations must address whole components, as is required today.
>
> Yes, the ability to replace a single stripe of a file (e.g. in case of OST failure) is needed to make resync more efficient. I agree that the current migration/resync implementation doesn't allow this, but it would be unfortunate to limit it as it is a feature that some users have already asked for.
>
>> ?If we did add the ability to switch out an individual OST object/stripe (which would be pretty easy to implement - data copy, layout swap, rm now-unused object), we could add those modifications as additional "traditional" layout info "atop" the compact layout. So just the usual layout format, with OST IDs, and where present, it supersedes the relevant part of the compact layout. This implicitly assumes we don't do a ton of this to a particular layout.
>
> Sure.
>
>> ?But as to reasons, it's a few things.
>>
>> ?The primary concern is improving the open performance of very widely striped files, which means your second case - reduce the xattr and rpc size.
>
> I was thinking that a better approach would be to implement open-by-handle, so that e.g. MPI rank 0 can open the file by path, generate a short-lived file handle to send to the other ranks, and they open by handle (the kernel interface is limited to root-only, but we could add our own user interface if we had secure handles that were resistent to guessing). However, I don't think that helps for your case because the other clients still need to have a local copy of the layout in order to do IO properly. Passing in the file layout from userspace doesn't reduce the overall network traffic, and opens the window to severe data integrity issues.
>
>> ?The same things that motivate this would also motivate raising the count limit, but my understanding from comments in the code is that 2000 is arbitrary, and the actual max could be quite a bit higher. The first limit I'm aware of - I'm not sure if this is right? - is 1 MiB of extended attribute. That's a little over 5000 stripes. (Obviously, 1 MiB of layout is probably a non-starter...)
>
> For a 1MB layout, this would be over 43k stripes (not sure where you got 5000 stripes from, as we have 2000 stripes in about 48KB). The basic layout format has each stripe using 24 bytes to hold struct lov_ost_data_v1. We could make that more compact these days by only storing the 16-byte object FID, since that also contains the OST index (directly in an IDIF FID, or indirectly via FLDB for a normal FID). That would get us up to 64k stripes, and since we are adding a new layout type we should strongly consider this.
>
> Note that the 1MB layout size limit on disk is also arbitrary. There would be a larger issue with the kernel xattr interface, since that is currently limited to 64KB in size (about 4k stripes if we stored only the 16-byte FID).
>
> The bigger problem than the xattr disk size is the network transfer and in-kernel memory needed to handle such a large layout. We would likely need to go to a separate RDMA transfer for the layout to avoid bloating the reply buffer for the common (small layout) case.
>
>> ?Your suggestion of gzip is very intriguing. Ideally, I'd pick something available in kernel and with good performance. A bit of experimentation is probably in order if we go that route. Thanks for the pointer there. I'd probably start with extracting the binary xattr and seeing how it compresses.
>
> I believe gzip is available for both compression and decompression in the kernel, and even has hardware acceleration (QAT) available from Intel. It has the best compression ratio, though the performance is lower. I think we'd prefer a higher compression ratio since this isn't a huge volume of data we are working with.

ZSTD with dictionary may be very interesting specially for this case https://facebook.github.io/zstd/#small-data

It's better than gzip in compression and speed, and it's included in kernel since 4.14 (but you may want not to use it, see discussion in ZFSonLinux ZSTD integration https://github.com/zfsonlinux/zfs/pull/8044 )

>
> Cheers, Andreas
>
>> ?From: Andreas Dilger <adilger@whamcloud.com>
>> ?Sent: Wednesday, November 21, 2018 5:53:03 PM
>> ?To: Patrick Farrell
>> ?Cc: Lustre Developement
>> ?Subject: Re: [lustre-devel] Compact layouts
>>
>> ?On Nov 16, 2018, at 11:06, Patrick Farrell <paf@cray.com> wrote:
>> ?>
>> ?> All,
>> ?>
>> ?> There is an old idea for reducing the data required to describe file striping by using a bitmap to record which OSTs are in use. As best I can tell, this was most recently described here:
>> ?> http://wiki.lustre.org/Layout_Enhancement_Solution_Architecture#Compact_Layouts_2
>> ?>
>> ?> I?m curious if this has been pursued any further, if there?s a JIRA or other place that might have more info or be tracking the idea. I poked around and didn?t find anything.
>> ?>
>> ?> In particular, this comment:
>> ?> ?with enough data that for each OST index set in the bitmap, a corresponding OST object FID may be computed?
>> ?> Points at the difficult part of implementing this.
>> ?>
>> ?> So, before I get too far considering this problem - Is there more out there somewhere? Hoping to avoid duplicating work!
>>
>> ?Patrick,
>> ?as you mention above, the tricky part is that there would need to be sequential FID sequence allocation across all of the OSTs. Then, each of the compact files would allocate/reserve the same OID in each of the sequences so that the mapping could be compact. I don't think that is insurmountable - we already have a good mechanism for allocating FID sequences to different targets, but it would need to be extended so that compact layouts would allocate sequences from a different range of values from regular layouts.
>>
>> ?It would also likely need to implement "OST object create on write" so that there aren't large numbers of unused objects on each OST (one for each OID that isn't used on a particular file).
>>
>> ?The other issue is that anything like migrating any single object to another OST (e.g. for mirror resync, tiering, etc) would potentially break the compact layout.
>>
>> ?I guess the question is what the need for compact layouts is? To handle more than 2000 stripes, to reduce the xattr size/RPC size, to allow more complex PFL layouts to fit into the layout size limit?
>>
>> ?In the past we discussed compressing the layout with gzip, which might be quite effective since large parts of it are zero-filled and repetitive. This would help the xattr/RPC size, and I think even with compact layouts that they would still be expanded in RAM to allow easier processing.
>>
>> ?Cheers, Andreas
>> ?---
>> ?Andreas Dilger
>> ?Principal Lustre Architect
>> ?Whamcloud
>
> Cheers, Andreas
> ---
> Andreas Dilger
> CTO Whamcloud
>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

____________________________________
Sincerely,
George Melikov
