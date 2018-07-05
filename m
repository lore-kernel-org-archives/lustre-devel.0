From: James Simmons <jsimmons@infradead.org>
Date: Thu, 5 Jul 2018 23:01:52 +0100 (BST)
Subject: [lustre-devel] [PATCH 02/18] lustre: ladvise: Add feature of
 giving file access advices
In-Reply-To: <8736x12duq.fsf@notabene.neil.brown.name>
References: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
 <1530573875-20465-3-git-send-email-jsimmons@infradead.org>
 <8736x12duq.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1807052211530.12665@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> > +	case LL_IOC_LADVISE: {
> > +		struct ladvise_hdr *ladvise_hdr;
> > +		int alloc_size = sizeof(*ladvise_hdr);
> > +		int num_advise;
> > +		int i;
> > +
> > +		rc = 0;
> > +		ladvise_hdr = kzalloc(alloc_size, GFP_NOFS);
> 
> Lustre really needs to get more sensible about when to use GFP_NOFS and
> when to use GFP_KERNEL.
> NOFS is only needed when the allocation cannot wait while reclaim enters
> the filesystem, due to possible deadlock.  So if you are holding a lock
> or some other resource that writeout might need, use NOFS.
> In this case, there is no possible conflict with writeout, so GFP_KERNEL
> should be used.
> 
> In this case, alloc_size is 32, so I wonder why it is allocating memory
> at all rather than just using the stack.
> 
> Below the memory is freed and allocated again (why not realloc?) so an
> allocation is justified there.  That should be GFP_KERNEL as well.
> 
> Later in osc_io_ladvise_start() there is a kvzalloc() with GFP_NOFS.
> I suspect that should be GFP_KERNEL as well, especially as vmalloc
> doesn't properly support GFP_NOFS and never has.

This is the result of the porting from the OpenSFS tree. So in the
OpenSFS branch it still does all memory allocations using its OBD_ALLOC*
wrappers. Unfolding those wrappers you will see its mostly kmallocs done
with the GFP_NOFS flag. This is the same reason lustre avoids using the
kasprintf() and related functions as well. Those wrappers were developed
to be used to locate memory leaks which was done long before KASAN and
trace events was created. Looking at __OBD_VMALLOC_VERBOSE() you will
see its using GFP_NOFS which appears to not to be even supported.
Oh fun!!!

Since we are on this topic it might be good idea to discuss getting onto
0day and work to get KASAN going with the linux lustre client branch. The
directions are not very clear on how to set it up. Have you ever worked
with zero day? As for KASAN that can be done locally but sadly you need
at least gcc 4.9.2 which in my setup I don't have. I did notice a lustre
instance exist on 0day but it doesn't look alive in any way.

As a side note I did apply for lustre-devel to be include on 
patchworks.linux.org. They are currently in the process to upgrade to
a newer software stack so it will another week or so for it to be visible.
