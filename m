From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 2 Feb 2017 02:56:51 -0800
Subject: [lustre-devel] [PATCH v3 0/2] iov_iter: allow
 iov_iter_get_pages_alloc to allocate more pages per call
In-Reply-To: <20170202095125.GF27291@ZenIV.linux.org.uk>
References: <20170124212327.14517-1-jlayton@redhat.com>
	<20170125133205.21704-1-jlayton@redhat.com>
	<20170202095125.GF27291@ZenIV.linux.org.uk>
Message-ID: <20170202105651.GA32111@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org, v9fs-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Chris Wilson <chris-Y6uKTt2uX1cEflXRtASbqLVCufUGDwFn@public.gmane.org>, "Kirill A. Shutemov" <kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>

On Thu, Feb 02, 2017 at 09:51:25AM +0000, Al Viro wrote:
> On Wed, Jan 25, 2017 at 08:32:03AM -0500, Jeff Layton wrote:
> > Small respin of the patch that I sent yesterday for the same thing.
> > 
> > This moves the maxsize handling into iov_iter_pvec_size, so that we don't
> > end up iterating past the max size we'll use anyway when trying to
> > determine the pagevec length.
> > 
> > Also, a respun patch to make ceph use iov_iter_get_pages_alloc instead of
> > trying to do it via its own routine.
> > 
> > Al, if these look ok, do you want to pick these up or shall I ask
> > Ilya to merge them via the ceph tree?
> 
> I'd rather have that kind of work go through the vfs tree; said that,
> I really wonder if this is the right approach.  Most of the users of
> iov_iter_get_pages()/iov_iter_get_pages_alloc() look like they want
> something like
> 	iov_iter_for_each_page(iter, size, f, data)
> with int (*f)(struct page *page, size_t from, size_t size, void *data)
> passed as callback.  Not everything fits that model, but there's a whole
> lot of things that do.

I was planning to do that, mostly because of the iomap dio code that
would not only get a lot cleaner with this, but also support multi-page
bvecs that we hope to have in the block layer soon.  The issue with it
is that we need to touch all the arch get_user_pages_fast
implementations, so it's going to be a relatively invasive change that I
didn't want to fix with just introducing the new direct I/O code.
