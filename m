From: NeilBrown <neilb@suse.com>
Date: Thu, 21 Feb 2019 13:25:42 +1100
Subject: [lustre-devel] Lustre interval tree problems
In-Reply-To: <alpine.LFD.2.21.1902201738170.6267@casper.infradead.org>
References: <alpine.LFD.2.21.1902201738170.6267@casper.infradead.org>
Message-ID: <87y369c1y1.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Feb 20 2019, James Simmons wrote:

> With the port of the interval tree work to the OpenSFS branch several 
> problems have been pointed out in the implementation which impacts
> performance and the memory footprint in some cases.

Porting to OpenSFS will have to address one issue that I could skip
over.

hsm_update_work() in mtd_hsm_cdt_requests.c deliberately doesn't want
duplicates - it is the only place in all of lustre which really doesn't
want duplicates, and it is server side so I don't have to address it.

I wold probably change the code to do a lookup first, then insert only
if the lookup failed.

>
> The biggest issues is the ability to add duplicate locks. The reason
> the original implementation avoided adding duplicate locks was to
> avoid the extra compares being done with the same type of locks.
> Especially in the case of the range lock where you can end up with
> many duplicate read locks [0-EOF]. Comparing with 1000s of identical
> read locks will have an impact. Their is teh question of the memory
> foot print in this case as well. I believe this is the case with the
> ldlm locks as well since the ability to skip large lock amounts if
> not matching has been lost.

The interval tree stores entries in an rb-tree, which is a
nearly-balanced binary tree.  This provides O(ln n) lookup.
If there are 1000s of identical read locks, then a lookup will have 10s
of extra compares.  Even with 1,000,000 locks, that would be at most 40
compares.
The code simplification could well make up for some of these extra
compares by reducing i-cache pressure, though that would be hard to
measure.

Is there any empirical evidence of a slow-down?  Does 10s of compares
really seem like a big cost?

I cannot see the memory foot print issue that you mention.
All locks are added to the data structure even if they aren't in the
interval tree directly.  There is a linked-list of locks that all have
the same start/end, so keeping duplicates doesn't mean that more memory
is used, it just means that it is linked together differently.

So it isn't yet clear to me what the problem is here.
I'd be have to have it explained to me in more detail.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190221/454cd5af/attachment.sig>
