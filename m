From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Fri, 3 Feb 2017 07:29:52 +0000
Subject: [lustre-devel] [PATCH v3 0/2] iov_iter: allow
 iov_iter_get_pages_alloc to allocate more pages per call
In-Reply-To: <1486040452.2812.6.camel@redhat.com>
References: <20170124212327.14517-1-jlayton@redhat.com>
	<20170125133205.21704-1-jlayton@redhat.com>
	<20170202095125.GF27291@ZenIV.linux.org.uk>
	<20170202105651.GA32111@infradead.org>
	<20170202111625.GG27291@ZenIV.linux.org.uk>
	<1486040452.2812.6.camel@redhat.com>
Message-ID: <20170203072952.GI27291@ZenIV.linux.org.uk>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Chris Wilson <chris-Y6uKTt2uX1cEflXRtASbqLVCufUGDwFn@public.gmane.org>, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, v9fs-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "Kirill A. Shutemov" <kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org

On Thu, Feb 02, 2017 at 08:00:52AM -0500, Jeff Layton wrote:
> > I'm not sure we need to touch any get_user_pages_fast() at all; let it
> > fill a medium-sized array and use that as a buffer.  In particular,
> > I *really* don't like the idea of having the callbacks done in an
> > inconsistent locking environment - sometimes under ->mmap_sem, sometimes
> > not.
> > 
> 
> Yeah, that might work. You could kmalloc the buffer array according to
> the maxsize value. For small ones we could even consider using an on-
> stack buffer.

Yes.  FWIW, I'm not proposing to kill iov_iter_get_pages{,_alloc}()
immediately - the new primitive would initially use the damn thing.
That can be backported without any problems, and conversions would be
one-by-one.  If/when we get to the point where most of the users have
been switched to the new helper, we could try and see if what remains
could be dealt with; if that works, it might be possible to fold
iov_iter_get_pages() into it.  In particular, for ITER_BVEC and
ITER_PIPE we don't need to bother with any intermediate arrays at all, etc.
But that's only after several cycles when everyone is asked to try and use
the new primitive instead of iov_iter_get_pages().

The calling conventions of iov_iter_get_pages() are ugly and I would love to
get rid of them, but doing that in a flagday conversion is a lot of PITA
for no good reason.

Speaking of get_user_pages() and conversions:

get_user_pages() relies upon find_extend_vma() to reject kernel
addresses; the fast side of get_user_pages_fast() doesn't have anything
of that sort in case e.g. HAVE_GENERIC_RCU_GUP.  Sure, usually we have
that verified and rejected earlier anyway, but it's a fairly subtle difference
that doesn't seem to be documented anywhere.

For example, /dev/st* reads and writes (st_read()/st_write()) feed the
address of buffer to get_user_pages_unlocked().  If somebody replaced
those with get_user_pages_fast(), we'd be in trouble as soon as
some code got tricked into using kernel_write() on /dev/st*.

access_ok() in HAVE_GENERIC_RCU_GUP {__,}get_user_pages_fast() obviously
doesn't help in that scenario.  What am I missing here?
