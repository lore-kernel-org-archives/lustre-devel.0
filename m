From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Thu, 2 Feb 2017 09:51:25 +0000
Subject: [lustre-devel] [PATCH v3 0/2] iov_iter: allow
 iov_iter_get_pages_alloc to allocate more pages per call
In-Reply-To: <20170125133205.21704-1-jlayton@redhat.com>
References: <20170124212327.14517-1-jlayton@redhat.com>
	<20170125133205.21704-1-jlayton@redhat.com>
Message-ID: <20170202095125.GF27291@ZenIV.linux.org.uk>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Chris Wilson <chris-Y6uKTt2uX1cEflXRtASbqLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, v9fs-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "Kirill A. Shutemov" <kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org

On Wed, Jan 25, 2017 at 08:32:03AM -0500, Jeff Layton wrote:
> Small respin of the patch that I sent yesterday for the same thing.
> 
> This moves the maxsize handling into iov_iter_pvec_size, so that we don't
> end up iterating past the max size we'll use anyway when trying to
> determine the pagevec length.
> 
> Also, a respun patch to make ceph use iov_iter_get_pages_alloc instead of
> trying to do it via its own routine.
> 
> Al, if these look ok, do you want to pick these up or shall I ask
> Ilya to merge them via the ceph tree?

I'd rather have that kind of work go through the vfs tree; said that,
I really wonder if this is the right approach.  Most of the users of
iov_iter_get_pages()/iov_iter_get_pages_alloc() look like they want
something like
	iov_iter_for_each_page(iter, size, f, data)
with int (*f)(struct page *page, size_t from, size_t size, void *data)
passed as callback.  Not everything fits that model, but there's a whole
lot of things that do.

Examples:
	* fs/direct_io.c:do_direct_IO().  We loop through the pages
returned by dio_get_page().  For each of those we find the subrange
of page (from/to) and handle IO on that range.  Then we drop the reference
to page and move on to the next one.  dio_get_page() uses dio->pages and
sdio->{head,tail,from,to} to avoid calling iov_iter_get_pages() on each
page - iov_iter_get_pages() is called for bigger chunks (up to 64 pages,
AFAICS) and results are kept in dio->pages for subsequent calls of
dio_get_page().  Unconsumed references are dropped by dio_cleanup();
AFAICS, it could've been called unconditionally right after the call
of do_direct_IO() (or from it, for that matter) - all remaining references
to pages are never looked at after do_direct_IO().  As it is, we call
it immediately on failure return from do_direct_IO() and then unconditionally
after blk_finish_plug().
	That oddity aside (and AFAICS it's really pointless - all pages
we'd done something with in do_direct_IO() won't be affected by
dio_cleanup()), there's potentially more interesting issue.  If
iov_iter_get_pages() fails on write at the moment when we have pending
mapped blocks, we treat that as write from zero page.  Once that has
happened, we remember to stop mapping new blocks and arrange for having
the error eventually treated as if it had come from IO failure.  I'm not
sure if this sucker handles all cases correctly, BTW - can we end up with
a few pages worth of pending mapped blocks?
	But aside of that, it's really a "loop through all page subranges"
kind of code.  The inner loop in do_direct_IO() could be converted into
a callback quite easily

	* nfs_direct_read_schedule_iovec(): same kind of batching, only there
we have an outer loop calling iov_iter_get_pages_alloc() and then the
inner loop goes through the page subranges, with the same work done for
each.  In this case we grab a reference inside the would-be callback and
drop all references from iov_iter_get_pages_alloc() after the inner loop
is done.  Could've gotten rid of grabbing extra refs - that would mean dropping
only the unused ones if the 'callback' (== inner loop body) has told us
to bugger off early.  IMO that would be a better model.  Incidentally, we
keep allocating/freeing the array used to store page references for each batch.

	* nfs_direct_write_schedule_iovec(): very similar to the read side.

	* zerocopy_sg_from_iter(): similar loop, batch size is MAX_SKB_FRAGS
(i.e. 16 or 17, depending upon the PAGE_SIZE; unless somebody has done
a port with 2Kb pages it shouldn't be greater than 17).  Array of references
is on stack, skb_fill_page_desc(skb, frag++, page, from, size) should
become the callback.  References are consumed by it and it can't fail, so
there's nothing left to drop.

	* af_alg_make_sg().  Looks like it might be massaged to the same
model; the tricky part is af_alg_free_sg() users.  We keep references to
pages in sgl->pages[] *and* store them in sgl->sg[...] (via sg_set_page()).
af_alg_free_sg() drops them using ->pages[] instead of sg_page(...->sg + ...).
Might or might not be a problem - I'm not familiar with that code.

	* fuse_get_user_pages().  It pretty much fills an equivalent of
bio_vec array; the difference is, array of struct page * and arrays of
(start, len) pairs are kept separately.  The only benefit is using the
first array as destination of iov_iter_get_pages(); might as well work
into a separate batching array instead - copying struct page * is noise
compared to storing (and calculating) start/len pairs we have to do there.
Again, what we do there is a pure loop over page subranges.

	* fuse_copy_fill().  I'm not at all sure that iov_iter_get_pages()
is a good idea there - fuse_copy_do() could bloody well just use
copy_{to,from}_iter().

	* fs/splice.c:iter_to_pipe().  Loop over page subranges, consuming
page references.  Unused ones are dropped.

	* bio_iov_iter_get_pages().  Wants to populate bio_vec array; should've
been a loop calling iov_iter_get_pages(); gets tripped on each iovec boundary
instead.  IMO would've been better off with a loop and separate 'batching'
array; would've killed the "Deep magic" mess in there, while we are at it.

That's the majority of iov_iter_get_pages{,_alloc} callers.  There's one
I'm not sure about in lustre (looks like their O_DIRECT is complicated by
rudiments of lloop stuff), there's a mess in p9_get_mapped_pages() (with
special-casing the kvec-backed iterators using kmap_to_page() and
vmalloc_to_page(), no less), there's default_file_splice_read() and there's
ceph stuff.  Everything else is covered by the 'loop over page subranges'
stuff.

I'm massaging that code (along with a lot of RTFS); the interesting questions
related to VM side of things are
	* what are the relative costs of doing small vs. large batches?  Some
of get_user_pages_fast() instances have comments along the lines of "we ought
to limit the batch size, but then nobody's doing more than 64 pages at a time
anyway".
	* Not a question: any ->fault() that returns VM_FAULT_RETRY when
*not* passed FAULT_FLAG_ALLOW_RETRY in flags ought to be shot.  cxlflash one
sure as hell is.
	* drivers/gpu/drm/vgem/vgem_drv.c:vgem_gem_fault() is bloody odd -
shmem_read_mapping_page() can't return -EBUSY, AFAICS.  vm_insert_page()
used to (and back then vgem_gem_fault() used to be broken), but these days
it looks like dead code...
	* ->page_mkwrite() instances sometimes return VM_FAULT_RETRY; AFAICS,
it's only (ab)used there as 'not zero, but doesn't contain any error bits';
VM_FAULT_RETRY from that source does *not* reach handle_mm_fault() callers,
right?
	* get_user_pages_fast() only returns 0 on zero size.  AFAICS, that's
true and some callers seems to rely upon that.  Correct?
	* aligning the start address passed to get_user_pages_fast() et.al.
Happens in many callers, but not all of them.  Most of the instances
forcibly align it in get_user_pages_fast() itself, but... not the fallback
one.  I'm not sure if it can be used to screw the things up, but it feels
like aligning the sucker in get_user_pages...() would be safer - callers
outnumber them and they are scattered in bad places (including drivers/staging)

	Comments?
