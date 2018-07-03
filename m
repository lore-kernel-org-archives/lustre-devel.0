From: NeilBrown <neilb@suse.com>
Date: Tue, 03 Jul 2018 13:32:45 +1000
Subject: [lustre-devel] [PATCH 02/18] lustre: ladvise: Add feature of
 giving file access advices
In-Reply-To: <1530573875-20465-3-git-send-email-jsimmons@infradead.org>
References: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
 <1530573875-20465-3-git-send-email-jsimmons@infradead.org>
Message-ID: <8736x12duq.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Jul 02 2018, James Simmons wrote:

> From: Li Xi <lixi@ddn.com>
>
> The fadvise() system call provided by Linux kernel enables
> applications to give advices or hints about how a file will be
> accessed. However, It is only a client side mechanism which is
> not enough for distributed file systems like Lustre, because in
> order to tune system-wide cache or read-ahead policies, servers
> need to understand the advices too.
>
> This patch adds a new feature named ladvise which provides new
> APIs and utils to give advices about the access pattern of Lustre
> files with the purpose of performance improvement. It is similar
> to Linux fadvise() system call, except it forwards the advices
> directly from Lustre client to server. The server side codes will
> apply appropriate read-ahead and caching techniques for the
> corresponding files.
>
> A typical workload for ladvise is e.g. a bunch of different
> clients are doing small random reads of a file, so prefetching
> pages into OSS cache with big linear reads before the random IO
> is a net benefit. Fetching all that data into each client cache
> with fadvise() may not be, due to much more data being sent to
> the client.
>
...
> +	case LL_IOC_LADVISE: {
> +		struct ladvise_hdr *ladvise_hdr;
> +		int alloc_size = sizeof(*ladvise_hdr);
> +		int num_advise;
> +		int i;
> +
> +		rc = 0;
> +		ladvise_hdr = kzalloc(alloc_size, GFP_NOFS);

Lustre really needs to get more sensible about when to use GFP_NOFS and
when to use GFP_KERNEL.
NOFS is only needed when the allocation cannot wait while reclaim enters
the filesystem, due to possible deadlock.  So if you are holding a lock
or some other resource that writeout might need, use NOFS.
In this case, there is no possible conflict with writeout, so GFP_KERNEL
should be used.

In this case, alloc_size is 32, so I wonder why it is allocating memory
at all rather than just using the stack.

Below the memory is freed and allocated again (why not realloc?) so an
allocation is justified there.  That should be GFP_KERNEL as well.

Later in osc_io_ladvise_start() there is a kvzalloc() with GFP_NOFS.
I suspect that should be GFP_KERNEL as well, especially as vmalloc
doesn't properly support GFP_NOFS and never has.


Again, I'll probably apply this anyway...

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180703/1f610b00/attachment.sig>
