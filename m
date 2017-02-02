From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Thu, 2 Feb 2017 11:16:25 +0000
Subject: [lustre-devel] [PATCH v3 0/2] iov_iter: allow
 iov_iter_get_pages_alloc to allocate more pages per call
In-Reply-To: <20170202105651.GA32111@infradead.org>
References: <20170124212327.14517-1-jlayton@redhat.com>
	<20170125133205.21704-1-jlayton@redhat.com>
	<20170202095125.GF27291@ZenIV.linux.org.uk>
	<20170202105651.GA32111@infradead.org>
Message-ID: <20170202111625.GG27291@ZenIV.linux.org.uk>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org, v9fs-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Chris Wilson <chris-Y6uKTt2uX1cEflXRtASbqLVCufUGDwFn@public.gmane.org>, "Kirill A. Shutemov" <kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>

On Thu, Feb 02, 2017 at 02:56:51AM -0800, Christoph Hellwig wrote:
> > I really wonder if this is the right approach.  Most of the users of
> > iov_iter_get_pages()/iov_iter_get_pages_alloc() look like they want
> > something like
> > 	iov_iter_for_each_page(iter, size, f, data)
> > with int (*f)(struct page *page, size_t from, size_t size, void *data)
> > passed as callback.  Not everything fits that model, but there's a whole
> > lot of things that do.
> 
> I was planning to do that, mostly because of the iomap dio code that
> would not only get a lot cleaner with this, but also support multi-page
> bvecs that we hope to have in the block layer soon.  The issue with it
> is that we need to touch all the arch get_user_pages_fast
> implementations, so it's going to be a relatively invasive change that I
> didn't want to fix with just introducing the new direct I/O code.

I'm not sure we need to touch any get_user_pages_fast() at all; let it
fill a medium-sized array and use that as a buffer.  In particular,
I *really* don't like the idea of having the callbacks done in an
inconsistent locking environment - sometimes under ->mmap_sem, sometimes
not.

I played with "let it fill bio_vec array", but it doesn't really fit the
users; variant with callbacks is cleaner, IMO.
