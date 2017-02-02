From: Jan Kara <jack@suse.cz>
Date: Thu, 2 Feb 2017 15:48:17 +0100
Subject: [lustre-devel] [PATCH v3 0/2] iov_iter: allow
 iov_iter_get_pages_alloc to allocate more pages per call
In-Reply-To: <20170202095125.GF27291@ZenIV.linux.org.uk>
References: <20170124212327.14517-1-jlayton@redhat.com>
	<20170125133205.21704-1-jlayton@redhat.com>
	<20170202095125.GF27291@ZenIV.linux.org.uk>
Message-ID: <20170202144817.GB15545@quack2.suse.cz>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Chris Wilson <chris-Y6uKTt2uX1cEflXRtASbqLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, v9fs-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "Kirill A. Shutemov" <kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org

On Thu 02-02-17 09:51:25, Al Viro wrote:
> I'm massaging that code (along with a lot of RTFS); the interesting questions
> related to VM side of things are
> 	* what are the relative costs of doing small vs. large batches?  Some
> of get_user_pages_fast() instances have comments along the lines of "we ought
> to limit the batch size, but then nobody's doing more than 64 pages at a time
> anyway".

Well, I believe it's only about the cost of setting up page table walk and
walking down those several levels of page tables. It is cheaper to copy
several PTE entries from the leaf level than doing the full walk every
time. But I didn't ever profile it to get actual numbers.

Large batches are only a problem because of possible soft-lockups and irq
latencies AFAIK. So the batch just should not be insanely large...

> 	* Not a question: any ->fault() that returns VM_FAULT_RETRY when
> *not* passed FAULT_FLAG_ALLOW_RETRY in flags ought to be shot.  cxlflash one
> sure as hell is.

Yep.

> 	* drivers/gpu/drm/vgem/vgem_drv.c:vgem_gem_fault() is bloody odd -
> shmem_read_mapping_page() can't return -EBUSY, AFAICS.  vm_insert_page()
> used to (and back then vgem_gem_fault() used to be broken), but these days
> it looks like dead code...

Looks like that.

> 	* ->page_mkwrite() instances sometimes return VM_FAULT_RETRY; AFAICS,
> it's only (ab)used there as 'not zero, but doesn't contain any error bits';
> VM_FAULT_RETRY from that source does *not* reach handle_mm_fault() callers,
> right?

I can see only Lustre doing it and IMHO it is abuse. VM_FAULT_RETRY is used
for mmap_sem latency reduction when paging in pages and so not everybody
handles it. If a handler wants to simply retry the fault, returning
VM_FAULT_NOPAGE is a more common way to do that...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
