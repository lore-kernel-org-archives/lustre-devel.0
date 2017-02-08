From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Wed, 8 Feb 2017 05:54:32 +0000
Subject: [lustre-devel] [PATCH v3 0/2] iov_iter: allow
 iov_iter_get_pages_alloc to allocate more pages per call
In-Reply-To: <20170207113554.GA30656@veci.piliscsaba.szeredi.hu>
References: <CAJfpegv=r9J8Mqax_ZAB2h5QbRgJMHwyVMENTpYZ8u3_pqNfJw@mail.gmail.com>
	<20170205210151.GD13195@ZenIV.linux.org.uk>
	<CAJfpeguzOgX9d+5XCNJcmXW5KkrGbnWB5aZSP1-0q3a6i6uk2w@mail.gmail.com>
	<20170205220445.GE13195@ZenIV.linux.org.uk>
	<20170206030532.GF13195@ZenIV.linux.org.uk>
	<CAJfpegv5ZGd2gzSbQvgk4uX5q06AijY+TNg2jdrPBSjbFoXMfg@mail.gmail.com>
	<20170206095706.GG13195@ZenIV.linux.org.uk>
	<CAJfpegv-ePQE9pNwZe6O+0LjJdq2aVk3bnhxeZ=y7P+iFq72XA@mail.gmail.com>
	<20170207071909.GI13195@ZenIV.linux.org.uk>
	<20170207113554.GA30656@veci.piliscsaba.szeredi.hu>
Message-ID: <20170208055431.GJ13195@ZenIV.linux.org.uk>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux NFS list <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org, v9fs-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Chris Wilson <chris-Y6uKTt2uX1cEflXRtASbqLVCufUGDwFn@public.gmane.org>, "Kirill A. Shutemov" <kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

On Tue, Feb 07, 2017 at 12:35:54PM +0100, Miklos Szeredi wrote:
> > Another thing: what guarantees that places in writepages-related paths
> > where we store a reference into req->ff won't hit a request with already
> > non-NULL ->ff?
> 
> Well, it is set before being sent (queued onto queued_writes or queued on the
> fuse device), but not when queued as secondary request onto an already in-flight
> one.  It looks okay to me.

>  void fuse_sync_release(struct fuse_file *ff, int flags)
>  {
> -	WARN_ON(atomic_read(&ff->count) > 1);
> +	WARN_ON(atomic_read(&ff->count) != 1);
>  	fuse_prepare_release(ff, flags, FUSE_RELEASE);
> -	__set_bit(FR_FORCE, &ff->reserved_req->flags);
> -	__clear_bit(FR_BACKGROUND, &ff->reserved_req->flags);
> -	fuse_request_send(ff->fc, ff->reserved_req);
> -	fuse_put_request(ff->fc, ff->reserved_req);
> -	kfree(ff);
> +	fuse_file_put(ff, true);

Umm...  At the very least, that deserves a comment re "iput(NULL) is a no-op
and since the refcount is 1 and everything's synchronous, we are fine with
not doing igrab/iput here".  There's enough mysteries in that code as it is...

	Speaking of mysteries - how can ->private_data ever be NULL in
fuse_release_common()?  AFAICS, it's only called from ->release() instances
and those are only called after ->open() or ->atomic_open() on that struct file
has returned 0.  On the ->open() side, it means fuse_do_open() having returned
0; on ->atomic_open() one - fuse_create_open() having done the same.  Neither
is possible with ->private_data remaining NULL, and I don't see any places
that would modify it afterwards...

	Another thing: am I right assuming that ff->nodeid will be the same
for all ff over given inode (== get_node_id(inode))?  What about ff->fh?
Is that a per-open thing, or will it be identical for all opens of the same
inode?
