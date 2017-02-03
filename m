From: Jan Kara <jack@suse.cz>
Date: Fri, 3 Feb 2017 15:47:56 +0100
Subject: [lustre-devel] [PATCH v3 0/2] iov_iter: allow
 iov_iter_get_pages_alloc to allocate more pages per call
In-Reply-To: <20170202182802.GH27291@ZenIV.linux.org.uk>
References: <20170124212327.14517-1-jlayton@redhat.com>
	<20170125133205.21704-1-jlayton@redhat.com>
	<20170202095125.GF27291@ZenIV.linux.org.uk>
	<20170202144817.GB15545@quack2.suse.cz>
	<20170202182802.GH27291@ZenIV.linux.org.uk>
Message-ID: <20170203144756.GC5844@quack2.suse.cz>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org, v9fs-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Chris Wilson <chris-Y6uKTt2uX1cEflXRtASbqLVCufUGDwFn@public.gmane.org>, "Kirill A. Shutemov" <kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>

On Thu 02-02-17 18:28:02, Al Viro wrote:
> On Thu, Feb 02, 2017 at 03:48:17PM +0100, Jan Kara wrote:
> 
> > > 	* ->page_mkwrite() instances sometimes return VM_FAULT_RETRY; AFAICS,
> > > it's only (ab)used there as 'not zero, but doesn't contain any error bits';
> > > VM_FAULT_RETRY from that source does *not* reach handle_mm_fault() callers,
> > > right?
> > 
> > I can see only Lustre doing it and IMHO it is abuse. VM_FAULT_RETRY is used
> > for mmap_sem latency reduction when paging in pages and so not everybody
> > handles it. If a handler wants to simply retry the fault, returning
> > VM_FAULT_NOPAGE is a more common way to do that...
> 
> /* Convert errno to return value from ->page_mkwrite() call */
> static inline int block_page_mkwrite_return(int err)
> {
>         if (err == 0)
>                 return VM_FAULT_LOCKED;
>         if (err == -EFAULT)
>                 return VM_FAULT_NOPAGE;
>         if (err == -ENOMEM)
>                 return VM_FAULT_OOM;
>         if (err == -EAGAIN)
>                 return VM_FAULT_RETRY;
>         /* -ENOSPC, -EDQUOT, -EIO ... */
>         return VM_FAULT_SIGBUS;
> }
> 
> and a bunch of ->page_mkwrite() instances using that.  However, the only
> callers of ->page_mkwrite() are wp_page_shared()->do_page_mkwrite() and
> do_shared_fault()->do_page_mkwrite().  do_page_mkwrite() treates
> VM_FAULT_RETRY as "lock page and return VM_FAULT_RETRY|VM_FAULT_LOCKED".
> Both callers do the same check -
>                 if (unlikely(!tmp || (tmp &
>                                       (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))) {
> and the return value if that predicate is false.  FWIW, use of VM_FAULT_RETRY
> comes from your patch back in 2011 and AFAICS the same analysis used to
> apply back then, except for the open-coded method calls where we use
> do_page_mkwrite() these days...

Yeah, back then I was not aware of VM_FAULT_RETRY limitations and your
analysis above just shows that its handling from do_page_mkwrite() is
simply broken (or better non-existent). Actually that VM_FAULT_RETRY
return was added by fs freeze handling patch. The freeze handling was
later changed but that change to block_page_mkwrite_return() remained.
I'll send a patch to remove it. Thanks for spotting this.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
