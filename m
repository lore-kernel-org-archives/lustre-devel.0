From: Andreas Dilger <adilger@whamcloud.com>
Date: Wed, 21 Nov 2018 23:53:03 +0000
Subject: [lustre-devel] Compact layouts
In-Reply-To: <3600968B-94D3-4C3F-857A-D00A5C3BC601@cray.com>
References: <3600968B-94D3-4C3F-857A-D00A5C3BC601@cray.com>
Message-ID: <E2B38E8A-55A5-481D-AF44-FF0B4CD8472E@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

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
