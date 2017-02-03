From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Fri, 3 Feb 2017 19:08:17 +0000
Subject: [lustre-devel] [PATCH v3 0/2] iov_iter: allow
 iov_iter_get_pages_alloc to allocate more pages per call
In-Reply-To: <CA+55aFx=NPESJv9RjCNRKFH_rk9uVMov0UtFbpZH-xBsgK2h-w@mail.gmail.com>
References: <20170124212327.14517-1-jlayton@redhat.com>
	<20170125133205.21704-1-jlayton@redhat.com>
	<20170202095125.GF27291@ZenIV.linux.org.uk>
	<20170202105651.GA32111@infradead.org>
	<20170202111625.GG27291@ZenIV.linux.org.uk>
	<1486040452.2812.6.camel@redhat.com>
	<20170203072952.GI27291@ZenIV.linux.org.uk>
	<CA+55aFx=NPESJv9RjCNRKFH_rk9uVMov0UtFbpZH-xBsgK2h-w@mail.gmail.com>
Message-ID: <20170203190816.GK27291@ZenIV.linux.org.uk>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux NFS Mailing List <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, ceph-devel <ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org, V9FS Developers <v9fs-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Chris Wilson <chris-Y6uKTt2uX1cEflXRtASbqLVCufUGDwFn@public.gmane.org>, "Kirill A. Shutemov" <kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>

On Fri, Feb 03, 2017 at 10:29:23AM -0800, Linus Torvalds wrote:
> On Thu, Feb 2, 2017 at 11:29 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> >
> > get_user_pages() relies upon find_extend_vma() to reject kernel
> > addresses; the fast side of get_user_pages_fast() doesn't have anything
> > of that sort
> 
> It is *supposed* to have it.
> 
> See pte_allows_gup(), for example. In particular, it requires the
> _PAGE_USER bit in the PTE (and the devpte case should require
> _PAGE_BIT_DEVMAP).

On x86 it does.  I don't see anything equivalent in mm/gup.c one, and the
only kinda-sorta similar thing (access_ok() in __get_user_pages_fast()
there) is vulnerable to e.g. access via kernel_write().  The comment in
there
 * Before activating this code, please be aware that the following assumptions
 * are currently made:
 *
 *  *) HAVE_RCU_TABLE_FREE is enabled, and tlb_remove_table is used to free
 *      pages containing page tables.
 *
 *  *) ptes can be read atomically by the architecture.
 *
 *  *) access_ok is sufficient to validate userspace address ranges.
 *
 * The last two assumptions can be relaxed by the addition of helper functions.

doesn't look promising - access_ok() is never sufficient.  Something like
_PAGE_USER tests in x86 one solves that problem, but if anything similar
works for HAVE_GENERIC_RCU_GUP I don't see it.  Thus the question re
what am I missing here...
