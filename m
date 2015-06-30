From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Tue, 30 Jun 2015 21:26:43 +0000
Subject: [lustre-devel] LIBCFS_ALLOC
In-Reply-To: <alpine.DEB.2.02.1506280844460.2103@localhost6.localdomain6>
References: <1434819550-3193-1-git-send-email-Julia.Lawall@lip6.fr>
	<1434819550-3193-2-git-send-email-Julia.Lawall@lip6.fr>
	<D1AECA61.F8DE5%andreas.dilger@intel.com>
	<alpine.DEB.2.02.1506280844460.2103@localhost6.localdomain6>
Message-ID: <D1B863B8.FA7C0%andreas.dilger@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2015/06/28, 12:52 AM, "Julia Lawall" <julia.lawall@lip6.fr> wrote:

>It is not clear that all of the uses of LIBCFS_ALLOC really risk needing
>vmalloc.  For example:
>
>lnet/klnds/socklnd/socklnd.c, function ksocknal_accept:
>
>ksock_connreq_t *cr;
>...
>LIBCFS_ALLOC(cr, sizeof(*cr));
>
>The definition of ksock_connreq_t is:
>
>typedef struct ksock_connreq {
>        struct list_head ksncr_list;  /* stash on ksnd_connd_connreqs */
>        lnet_ni_t        *ksncr_ni;   /* chosen NI */
>        struct socket    *ksncr_sock; /* accepted socket */
>} ksock_connreq_t;
>
>This looks like a very small structure.
>
>LIBCFS_ALLOC relies on a test on the size, which should be able to be
>compiled away.  libcfs_kvzalloc on the other hand relies on the failure
>of 
>kmalloc and so the test for that won't be compiled away.

There are probably only a handful of places where trying vmalloc() even
makes sense.  In most cases, LIBCFS_ALLOC() can be replaced by a straight
call to kmalloc() because the allocation size is small enough, and only a
few need to use libcfs_kvzalloc().  Anything at PAGE_SIZE or less will
either work with kmalloc() or it won't work at all.

I do agree with James' comments that vmalloc() was needed for both very
large allocations that can't be satisfied by kmalloc() at all, as well as
smaller allocations (anything over a couple of pages) due to fragmentation
of free pages after running for a long time.  I think libcfs_kvzalloc() is
at least as good as the size-based threshold used previously, since using
kmalloc() is going to be faster than vmalloc() and would work better on
32-bit platforms with limited vmalloc() size.

Cheers, Andreas
-- 
Andreas Dilger

Lustre Software Architect
Intel High Performance Data Division
