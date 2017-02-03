From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Fri, 3 Feb 2017 08:54:15 +0000
Subject: [lustre-devel] [PATCH v3 0/2] iov_iter: allow
 iov_iter_get_pages_alloc to allocate more pages per call
In-Reply-To: <20170203074901.GA19808@infradead.org>
References: <20170124212327.14517-1-jlayton@redhat.com>
	<20170125133205.21704-1-jlayton@redhat.com>
	<20170202095125.GF27291@ZenIV.linux.org.uk>
	<20170202105651.GA32111@infradead.org>
	<20170202111625.GG27291@ZenIV.linux.org.uk>
	<1486040452.2812.6.camel@redhat.com>
	<20170203074901.GA19808@infradead.org>
Message-ID: <20170203085415.GJ27291@ZenIV.linux.org.uk>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org, v9fs-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Chris Wilson <chris-Y6uKTt2uX1cEflXRtASbqLVCufUGDwFn@public.gmane.org>, "Kirill A. Shutemov" <kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>

On Thu, Feb 02, 2017 at 11:49:01PM -0800, Christoph Hellwig wrote:
> On Thu, Feb 02, 2017 at 08:00:52AM -0500, Jeff Layton wrote:
> > Yeah, that might work. You could kmalloc the buffer array according to
> > the maxsize value. For small ones we could even consider using an on-
> > stack buffer.
> 
> For the block direct I/O code we defintively want to avoid any
> allocations for small I/O a that shows up in the performance numbers.
> And we'd like to reuse the on-stack bio_vec so that the defintion of
> a small I/O can be as big as possible without blowing up the stack.

Hmm...  Reuse part is really nasty ;-/  OTOH, it might make sense to have
a "fill bio_vec array" as separate primitive - having that sucker come
from bio looks like an artificial restriction.

OK, next question, seeing that you've dealt with O_DIRECT guts more than
I have.  When we have iov_iter_get_pages() fail on do_direct_IO() write
with some blocks already allocated, we pick zero page as data source.
So far, so good, but:
	* should we bother zeroing anything unless buffer_new() is true?
	* why, in case of more than a page worth of pending allocated
blocks, do we bother with calling iov_iter_get_pages() again and again?
We *do* take care not to allocate anything else after that point, but
dio_get_page() will be calling iov_iter_get_pages() every time in that
case - there's only one page in queue.
