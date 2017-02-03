From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 3 Feb 2017 03:09:30 -0800
Subject: [lustre-devel] [PATCH v3 0/2] iov_iter: allow
 iov_iter_get_pages_alloc to allocate more pages per call
In-Reply-To: <20170203085415.GJ27291@ZenIV.linux.org.uk>
References: <20170124212327.14517-1-jlayton@redhat.com>
	<20170125133205.21704-1-jlayton@redhat.com>
	<20170202095125.GF27291@ZenIV.linux.org.uk>
	<20170202105651.GA32111@infradead.org>
	<20170202111625.GG27291@ZenIV.linux.org.uk>
	<1486040452.2812.6.camel@redhat.com>
	<20170203074901.GA19808@infradead.org>
	<20170203085415.GJ27291@ZenIV.linux.org.uk>
Message-ID: <20170203110930.GA22173@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Chris Wilson <chris-Y6uKTt2uX1cEflXRtASbqLVCufUGDwFn@public.gmane.org>, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, v9fs-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "Kirill A. Shutemov" <kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org

On Fri, Feb 03, 2017 at 08:54:15AM +0000, Al Viro wrote:
> Hmm...  Reuse part is really nasty ;-/  OTOH, it might make sense to have
> a "fill bio_vec array" as separate primitive - having that sucker come
> from bio looks like an artificial restriction.

Or just the only usecase :)  But yes, it could be generalized to take a
bio_vec without too much effort.

> OK, next question, seeing that you've dealt with O_DIRECT guts more than
> I have.  When we have iov_iter_get_pages() fail on do_direct_IO() write
> with some blocks already allocated, we pick zero page as data source.
> So far, so good, but:
> 	* should we bother zeroing anything unless buffer_new() is true?

I don't think so.

> 	* why, in case of more than a page worth of pending allocated
> blocks, do we bother with calling iov_iter_get_pages() again and again?
> We *do* take care not to allocate anything else after that point, but
> dio_get_page() will be calling iov_iter_get_pages() every time in that
> case - there's only one page in queue.

There shouldn't be a need for it.

But take it with a grain of salt - fs/direct-io.c is a hairy mess,
that's one of the reasons why I replaced it with the new iomap
code instead of trying to gradually move it to iomap API.
