From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Mon, 6 Feb 2017 09:57:07 +0000
Subject: [lustre-devel] [PATCH v3 0/2] iov_iter: allow
 iov_iter_get_pages_alloc to allocate more pages per call
In-Reply-To: <CAJfpegv5ZGd2gzSbQvgk4uX5q06AijY+TNg2jdrPBSjbFoXMfg@mail.gmail.com>
References: <20170202095125.GF27291@ZenIV.linux.org.uk>
	<20170204030842.GL27291@ZenIV.linux.org.uk>
	<CAJfpegtVb8PKNnKe5wGMd0u0WzgLpjpVtVpqDScbrBJShLAfGw@mail.gmail.com>
	<20170205015145.GB13195@ZenIV.linux.org.uk>
	<CAJfpegv=r9J8Mqax_ZAB2h5QbRgJMHwyVMENTpYZ8u3_pqNfJw@mail.gmail.com>
	<20170205210151.GD13195@ZenIV.linux.org.uk>
	<CAJfpeguzOgX9d+5XCNJcmXW5KkrGbnWB5aZSP1-0q3a6i6uk2w@mail.gmail.com>
	<20170205220445.GE13195@ZenIV.linux.org.uk>
	<20170206030532.GF13195@ZenIV.linux.org.uk>
	<CAJfpegv5ZGd2gzSbQvgk4uX5q06AijY+TNg2jdrPBSjbFoXMfg@mail.gmail.com>
Message-ID: <20170206095706.GG13195@ZenIV.linux.org.uk>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Cc: Linux NFS list <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Chris Wilson <chris-Y6uKTt2uX1cEflXRtASbqLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, v9fs-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "Kirill A. Shutemov" <kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org

On Mon, Feb 06, 2017 at 10:08:06AM +0100, Miklos Szeredi wrote:

> Yes, I think only page lock can be used to deadlock inside
> fuse_dev_read/write().  So requests that don't have locked pages
> should be okay  with just waiting until copy_to/from_user() finishes
> and only then proceeding with the abort.

Actually, looking at that some more, this might be not true.  Anything
that takes ->mmap_sem exclusive and *not* killable makes for another
source of deadlock.

Initial page fault takes ->mmap_sem shared.  OK, request sent to
server and server tries to read() it.  In the meanwhile, something
has closed userfaultfd for the same mm_struct.  We have userfaultfd_release()
block on attempt to take ->mmap_sem exclusive and from now on any attempt
to grab ->mmap_sem shared will deadlock.  And get_user_pages(), as well
as copy_to_user(), etc. can end up doing just that.  It doesn't have to
be an mmap of the same file, BTW - any page fault would do.

All you really need is to have server sharing address space with the
process that steps into original page fault, plus an evicted page
of any nature (anon mmap, whatever) being used as a destination of
read() in server.

down_read() inside down_read() is fine, unless there had been down_write()
in between.  And there are unkillable down_write() on ->mmap_sem -
userfaultfd_release() being one example of such.  Many of those can and
probably should become down_write_killable(), but this one can't - there
might be nothing to deliver the signal to, if the final close() happens
e.g. from exit(2).

Warning: the above might be completely bogus - I'm on way too large
uptime at the moment and most of the last day had been spent digging
through various convoluted code, so take the above with a cartload of
salt.  _If_ it's true, that kind of deadlock won't be possible to
break with killing anything or doing umount -f, though.

> 
> Those that have locked pages must be able to be aborted during
> copy_to/from_user() because the copy itself may try to acquire the
> page lock.
> 
> So yes, if we want to switch to copy_to/from_user(), then we can just
> fix the page refcounting for read and write requests and handle the
> two cases differently.
> 
> >         So how about this:
> >
> > * explicit FR_END_IMMEDIATELY on read/write-related requests
> > * no FR_LOCKED flipping in lock_request()/unlock_request()
> > * modifying the call of end_requests() in fuse_abort_conn() so that it
> > would skip request_end() for everything that isn't marked FR_END_IMMEDIATELY
> > * make fuse_copy_pages() grab page references around the actual
> > fuse_copy_page() - grab req->waitq.lock, check FR_ABORTED, grab a page
> > reference in case it's not, drop req->waitq.lock and bugger off if FR_ABORTED
> > was set.  Adjust fuse_try_move_page() accordingly.
> >
> > Do you see any problems with that approach for minimal fix?  If all requests
> > in need of FR_END_IMMEDIATELY turn out to have non-page part of args already
> > embedded into req->misc, it looks like this ought to suffice.  I probably
> > could post something along those lines tomorrow, if you see any serious
> > problems with that - please yell...
> 
> See previous mail, I don't think there's an issue with the current
> code.  Other than being convoluted as hell.

OK - I'm an idiot and I've managed to misread fuse_abort_conn() despite having
reread it many times last couple of days.  And yes, state transitions of
requests are convoluted as hell ;-/

Anyway, bedtime for me.  With any luck the scare above re ->mmap_sem *is*
bogus and I'll find "Al, you are an idiot - deadlock on ->mmap_sem can't
happen for <reasons>" from somebody in the mailbox when I get up...
