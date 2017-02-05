From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Sun, 5 Feb 2017 22:04:45 +0000
Subject: [lustre-devel] [PATCH v3 0/2] iov_iter: allow
 iov_iter_get_pages_alloc to allocate more pages per call
In-Reply-To: <CAJfpeguzOgX9d+5XCNJcmXW5KkrGbnWB5aZSP1-0q3a6i6uk2w@mail.gmail.com>
References: <20170124212327.14517-1-jlayton@redhat.com>
	<20170125133205.21704-1-jlayton@redhat.com>
	<20170202095125.GF27291@ZenIV.linux.org.uk>
	<20170204030842.GL27291@ZenIV.linux.org.uk>
	<CAJfpegtVb8PKNnKe5wGMd0u0WzgLpjpVtVpqDScbrBJShLAfGw@mail.gmail.com>
	<20170205015145.GB13195@ZenIV.linux.org.uk>
	<CAJfpegv=r9J8Mqax_ZAB2h5QbRgJMHwyVMENTpYZ8u3_pqNfJw@mail.gmail.com>
	<20170205210151.GD13195@ZenIV.linux.org.uk>
	<CAJfpeguzOgX9d+5XCNJcmXW5KkrGbnWB5aZSP1-0q3a6i6uk2w@mail.gmail.com>
Message-ID: <20170205220445.GE13195@ZenIV.linux.org.uk>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux NFS list <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org, v9fs-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Chris Wilson <chris-Y6uKTt2uX1cEflXRtASbqLVCufUGDwFn@public.gmane.org>, "Kirill A. Shutemov" <kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

On Sun, Feb 05, 2017 at 10:19:20PM +0100, Miklos Szeredi wrote:

> Then we can't break out of that deadlock: we wait until
> fuse_dev_do_write() is done until calling request_end() which
> ultimately results in unlocking page.  But fuse_dev_do_write() won't
> complete until the page is unlocked.

Wait a sec.  What happens if

process A: fuse_lookup()
		struct fuse_entry_out outarg on stack
		...
		fuse_request_send() with req->out.args[0].value = &outarg
			sleep in request_wait_answer() on req->waitq
server: read the request, write reply
	fuse_dev_do_write()
		copy_out_args()
			fuse_copy_args()
				fuse_copy_one()
					FR_LOCKED is guaranteed to be set
					fuse_copy_do()
process C on another CPU: umount -f
	fuse_conn_abort()
		end_requests()
			request_end()
				set FR_FINISHED
				wake A up (via?req->waitq)
process A: regain CPU
	bugger off from request_wait_answer(), through __fuse_request_send(),
	fuse_request_send(), fuse_simple_request(), fuse_lookup_name(),
	fuse_lookup() and out of fuse_lookup().

In the meanwhile, server in fuse_copy_do() does memcpy() to what used to
be outarg, corrupting the stack of process A.

Sure, you need to hit a fairly narrow window, especially if you are to
cause damage in A, but AFAICS it's not impossible.  Consider e.g. the
situation when you lose CPU on preempt on the way to memcpy(); in that
case server might come back when A has incremented its stack footprint
again.  Or A might end up taking a hardware interrupt and handling it
on the normal kernel stack, etc.

Looks like *any* scenario where fuse_conn_abort() manages to run during
that memcpy() has potential for that kind of trouble; any SMP box appears
to be vulnerable, along with preempt UP...

Am I missing something that prevents that kind of problem?

> The only way out that I see is to have a refcount on all pages in
> args.  Which means copying everything not already in refcountable page
> (i.e. args on stack) to a page array.   It's definitely doable, but
> needs time to sort out, and I'm definitely lacking that (overlayfs
> currently trumps fuse).

Hrm...  Then maybe I'll have to try and cook something along those lines;
AFAICS the current mainline is vulnerable...
