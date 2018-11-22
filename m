From: Patrick Farrell <paf@cray.com>
Date: Thu, 22 Nov 2018 02:27:42 +0000
Subject: [lustre-devel] Compact layouts
In-Reply-To: <E2B38E8A-55A5-481D-AF44-FF0B4CD8472E@whamcloud.com>
References: <3600968B-94D3-4C3F-857A-D00A5C3BC601@cray.com>,
 <E2B38E8A-55A5-481D-AF44-FF0B4CD8472E@whamcloud.com>
Message-ID: <MWHPR11MB1488BCF770411CE094423321CBDB0@MWHPR11MB1488.namprd11.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas,


Thanks for the informative reply.


You raise an interesting and nasty point about breaking the compact layout with movement.  It's not possible today to move an individual OST object/stripe, though it's certainly something I've heard people ask for.  So it wouldn't be an issue if all such operations must address whole components, as is required today.


If we did add the ability to switch out an individual OST object/stripe (which would be pretty easy to implement - data copy, layout swap, rm now-unused object), we could add those modifications as additional "traditional" layout info "atop" the compact layout.  So just the usual layout format, with OST IDs, and where present, it supersedes the relevant part of the compact layout.  This implicitly assumes we don't do a ton of this to a particular layout.


But as to reasons, it's a few things.


The primary concern is improving the open performance of very widely striped files, which means your second case - reduce the xattr and rpc size.


The same things that motivate this would also motivate raising the count limit, but my understanding from comments in the code is that 2000 is arbitrary, and the actual max could be quite a bit higher.  The first limit I'm aware of - I'm not sure if this is right? - is 1 MiB of extended attribute.  That's a little over 5000 stripes.  (Obviously, 1 MiB of layout is probably a non-starter...)


Your suggestion of gzip is very intriguing.  Ideally, I'd pick something available in kernel and with good performance.  A bit of experimentation is probably in order if we go that route.  Thanks for the pointer there.  I'd probably start with extracting the binary xattr and seeing how it compresses.


- Patrick

________________________________
From: Andreas Dilger <adilger@whamcloud.com>
Sent: Wednesday, November 21, 2018 5:53:03 PM
To: Patrick Farrell
Cc: Lustre Developement
Subject: Re: [lustre-devel] Compact layouts

On Nov 16, 2018, at 11:06, Patrick Farrell <paf@cray.com> wrote:
>
> All,
>
> There is an old idea for reducing the data required to describe file striping by using a bitmap to record which OSTs are in use.  As best I can tell, this was most recently described here:
> http://wiki.lustre.org/Layout_Enhancement_Solution_Architecture#Compact_Layouts_2
>
> I?m curious if this has been pursued any further, if there?s a JIRA or other place that might have more info or be tracking the idea.  I poked around and didn?t find anything.
>
> In particular, this comment:
> ?with enough data that for each OST index set in the bitmap, a corresponding OST object FID may be computed?
> Points at the difficult part of implementing this.
>
> So, before I get too far considering this problem - Is there more out there somewhere?  Hoping to avoid duplicating work!

Patrick,
as you mention above, the tricky part is that there would need to be sequential FID sequence allocation across all of the OSTs.  Then, each of the compact files would allocate/reserve the same OID in each of the sequences so that the mapping could be compact.  I don't think that is insurmountable - we already have a good mechanism for allocating FID sequences to different targets, but it would need to be extended so that compact layouts would allocate sequences from a different range of values from regular layouts.

It would also likely need to implement "OST object create on write" so that there aren't large numbers of unused objects on each OST (one for each OID that isn't used on a particular file).

The other issue is that anything like migrating any single object to another OST (e.g. for mirror resync, tiering, etc) would potentially break the compact layout.

I guess the question is what the need for compact layouts is?  To handle more than 2000 stripes, to reduce the xattr size/RPC size, to allow more complex PFL layouts to fit into the layout size limit?

In the past we discussed compressing the layout with gzip, which might be quite effective since large parts of it are zero-filled and repetitive.  This would help the xattr/RPC size, and I think even with compact layouts that they would still be expanded in RAM to allow easier processing.

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud







-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181122/16669351/attachment.html>
