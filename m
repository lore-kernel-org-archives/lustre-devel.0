From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Sun, 5 Feb 2017 01:51:49 +0000
Subject: [lustre-devel] [PATCH v3 0/2] iov_iter: allow
 iov_iter_get_pages_alloc to allocate more pages per call
In-Reply-To: <CAJfpegtVb8PKNnKe5wGMd0u0WzgLpjpVtVpqDScbrBJShLAfGw@mail.gmail.com>
References: <20170124212327.14517-1-jlayton@redhat.com>
	<20170125133205.21704-1-jlayton@redhat.com>
	<20170202095125.GF27291@ZenIV.linux.org.uk>
	<20170204030842.GL27291@ZenIV.linux.org.uk>
	<CAJfpegtVb8PKNnKe5wGMd0u0WzgLpjpVtVpqDScbrBJShLAfGw@mail.gmail.com>
Message-ID: <20170205015145.GB13195@ZenIV.linux.org.uk>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Cc: Linux NFS list <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Chris Wilson <chris-Y6uKTt2uX1cEflXRtASbqLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, v9fs-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "Kirill A. Shutemov" <kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org

On Sat, Feb 04, 2017 at 11:11:27PM +0100, Miklos Szeredi wrote:

> Well, it's not historical; at least not yet.  The deadlock is there
> alright: mmap fuse file to addr; read byte from mapped page -> page
> locked; this triggeres read request served in same process but
> separate thread; write addr-headerlen to fuse dev; trying to lock same
> page -> deadlock.

Let me see if I got it straight - you have the same fuse file mmapped
in two processes, one of them being fuse server (either sharing the
entire address space, or the same area mapped in both).  Another process
faults the sucker in; filemap_fault() locks the page and goes
fuse_readpage() -> fuse_do_readpage() -> fuse_send_read() ->
-> fuse_request_send() -> __fuse_request_send() which puts request into
queue and goes to sleep in request_wait_answer().  Eventually, read()
on /dev/fuse (or splice(), whatever) by server picks that request and reply
is formed and fed back into /dev/fuse.  There we (in fuse_do_dev_write())
call copy_out_args(), which tries to copy into our (still locked) page
a piece of data coming from server-supplied iovec.  As it is, you
are calling get_user_pages_fast(), triggering handle_mm_fault().  Since that
malicous FPOS of a server tried to feed you the _same_ mmapped file, you
hit a deadlock.  In server's context.  Correct?

Convoluted, but possible.  But.  Why the hell do we care whether that deadlock
hits in get_user_pages_fast() or in copy_from_user()?  Put it another way,
what difference does it make whether we take that fault with or without
FR_LOCKED in req->flags?

> The deadlock can be broken by aborting or force unmounting: return
> error for original read request; page unlocked; device write can get
> page lock and return.
> 
> The reason we need to prohibit pagefault while copying is that when
> request is aborted and the caller returns the memory in the request
> may become invalid (e.g. data from stack).

???

IDGI.  Your request is marked aborted and should presumably fail, so
that when request_wait_answer() wakes up and finds it screwed, fuse_readpage()
would just return an error and filemap_fault() will return VM_FAULT_SIGBUS,
with page left not uptodate and _not_ inserted into page tables.  What's
leaking where?
