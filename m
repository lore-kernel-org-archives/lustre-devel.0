From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Mon, 6 Feb 2017 03:05:32 +0000
Subject: [lustre-devel] [PATCH v3 0/2] iov_iter: allow
 iov_iter_get_pages_alloc to allocate more pages per call
In-Reply-To: <20170205220445.GE13195@ZenIV.linux.org.uk>
References: <20170124212327.14517-1-jlayton@redhat.com>
	<20170125133205.21704-1-jlayton@redhat.com>
	<20170202095125.GF27291@ZenIV.linux.org.uk>
	<20170204030842.GL27291@ZenIV.linux.org.uk>
	<CAJfpegtVb8PKNnKe5wGMd0u0WzgLpjpVtVpqDScbrBJShLAfGw@mail.gmail.com>
	<20170205015145.GB13195@ZenIV.linux.org.uk>
	<CAJfpegv=r9J8Mqax_ZAB2h5QbRgJMHwyVMENTpYZ8u3_pqNfJw@mail.gmail.com>
	<20170205210151.GD13195@ZenIV.linux.org.uk>
	<CAJfpeguzOgX9d+5XCNJcmXW5KkrGbnWB5aZSP1-0q3a6i6uk2w@mail.gmail.com>
	<20170205220445.GE13195@ZenIV.linux.org.uk>
Message-ID: <20170206030532.GF13195@ZenIV.linux.org.uk>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Cc: Linux NFS list <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Chris Wilson <chris-Y6uKTt2uX1cEflXRtASbqLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, v9fs-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "Kirill A. Shutemov" <kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org

On Sun, Feb 05, 2017 at 10:04:45PM +0000, Al Viro wrote:

> Sure, you need to hit a fairly narrow window, especially if you are to
> cause damage in A, but AFAICS it's not impossible.  Consider e.g. the
> situation when you lose CPU on preempt on the way to memcpy(); in that
> case server might come back when A has incremented its stack footprint
> again.  Or A might end up taking a hardware interrupt and handling it
> on the normal kernel stack, etc.
> 
> Looks like *any* scenario where fuse_conn_abort() manages to run during
> that memcpy() has potential for that kind of trouble; any SMP box appears
> to be vulnerable, along with preempt UP...
> 
> Am I missing something that prevents that kind of problem?

For that matter, it doesn't have to be on-stack - e.g. fuse_get_link()
has kmalloc'ed buffer for destination, kfree'd upon failure.  Have the
damn thing lose the timeslice in fuse_copy_do() and you might very well
end up spraying user-supplied data over whatever ends up picking your
kfreed buffer.  That one could be reasonably dealt with if we switched
to page_alloc() and stuffed it into the ->pages[] instead...

Some observations regarding the arguments:
	* stack footprint is atrocious.  Consider e.g. fuse_mknod() - you
get 16 bytes of fuse_mknod_in + 120 bytes of struct fuse_args + 128 bytes
of fuse_entry_out.  All on stack, and that's on top of whatever the
callchain already has eaten, which might include e.g. nfsd stuff or
ecryptfs, etc.  Or fuse_get_parent(), for that matter, with 128 bytes of
fuse_entry_out + 120 bytes of fuse_args, both on stack.  This one is
guaranteed to have a nasty call chain - fuse_get_parent() <- reconnect_one()
<- reconnect_path() <- exportfs_decode_fh() (itself with a 256-byte array of
char on stack) <- nfsd_set_fh_dentry() <- fh_verify() <- a bunch of call
chains in nfsd.
	* "out" args (i.e. reply) are probably best dealt with by having
coallocated with request itself - some already are and the sizes tend
to be fixed and not too large (->get_link() is an exception, and it's
probably better handled as mentioned above).
	* "in" args (request) are in some cases easily dealt with by
coallocating with request, but there's a large class of situations where
we are passing dentry->d_name.name and then there's fuse_symlink().
The last one is ugly - potentially up to a page worth of data, coming
straight from method caller; usually it's a part of getname() result,
but e.g. ecryptfs might have it kmalloc'ed, nfsd - picked from sunrpc
request payload, etc.

	AFAICS, your argument applies to the requests that have
some page(s) locked until the request completion (unlock_page() either
by ->end() callback or in the originator of request).  If so, I would
rather mark those as "call request_end() early"; they seem to have
the non-page parts of args hosted in req->misc, so for them it's not
a problem.

	So how about this:

* explicit FR_END_IMMEDIATELY on read/write-related requests
* no FR_LOCKED flipping in lock_request()/unlock_request()
* modifying the call of end_requests() in fuse_abort_conn() so that it
would skip request_end() for everything that isn't marked FR_END_IMMEDIATELY
* make fuse_copy_pages() grab page references around the actual
fuse_copy_page() - grab req->waitq.lock, check FR_ABORTED, grab a page
reference in case it's not, drop req->waitq.lock and bugger off if FR_ABORTED
was set.  Adjust fuse_try_move_page() accordingly.

Do you see any problems with that approach for minimal fix?  If all requests
in need of FR_END_IMMEDIATELY turn out to have non-page part of args already
embedded into req->misc, it looks like this ought to suffice.  I probably
could post something along those lines tomorrow, if you see any serious
problems with that - please yell...
