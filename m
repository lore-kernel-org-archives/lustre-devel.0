From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Sat, 4 Feb 2017 19:26:55 +0000
Subject: [lustre-devel] [PATCH v3 0/2] iov_iter: allow
 iov_iter_get_pages_alloc to allocate more pages per call
In-Reply-To: <20170204030842.GL27291@ZenIV.linux.org.uk>
References: <20170124212327.14517-1-jlayton@redhat.com>
	<20170125133205.21704-1-jlayton@redhat.com>
	<20170202095125.GF27291@ZenIV.linux.org.uk>
	<20170204030842.GL27291@ZenIV.linux.org.uk>
Message-ID: <20170204192655.GA13195@ZenIV.linux.org.uk>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Chris Wilson <chris-Y6uKTt2uX1cEflXRtASbqLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, v9fs-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "Kirill A. Shutemov" <kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org

On Sat, Feb 04, 2017 at 03:08:42AM +0000, Al Viro wrote:
> On Thu, Feb 02, 2017 at 09:51:25AM +0000, Al Viro wrote:
> 
> > 	* fuse_copy_fill().  I'm not at all sure that iov_iter_get_pages()
> > is a good idea there - fuse_copy_do() could bloody well just use
> > copy_{to,from}_iter().
> 
> Miklos, could you explain why does lock_request() prohibit page faults until
> the matching unlock_request()?  All it does is setting FR_LOCKED on
> our request and the only thing that even looks at that is fuse_abort_conn(),
> which doesn't (AFAICS) wait for anything.
> 
> Where does the deadlock come from, and if it's not a deadlock - what is
> it?  Or is that comment stale since "fuse: simplify request abort"?

While we are at it...  How can fuse_copy_page() ever get called with
*pagep == NULL?  AFAICS, for that to happen you need either
	i < req->num_pages && req->pages[i] == NULL  
or in fuse_notify_store() have
                err = fuse_copy_page(cs, &page, offset, this_num, 0);
reached with page == NULL.  The latter is flat-out impossible - we have
                if (!page)
                        goto out_iput;

                this_num = min_t(unsigned, num, PAGE_SIZE - offset);
immediately before the call in question.  As for the former...  I don't see
any place where we would increase ->num_pages without having all additional
->pages[] elements guaranteed to be non-NULL.  Stores to ->num_pages are

in cuse_send_init():
	req->num_pages = 1;
with
        req->pages[0] = page;
shortly before that and
        if (!page)
                goto err_put_req;
earlier.

In fuse_retrieve():
                if (!page)
                        break;

                this_num = min_t(unsigned, num, PAGE_SIZE - offset);
                req->pages[req->num_pages] = page;
                req->page_descs[req->num_pages].length = this_num;
                req->num_pages++;

In fuse_readdir():
        req->num_pages = 1;
        req->pages[0] = page;
with
        if (!page) {
                fuse_put_request(fc, req);
                return -ENOMEM;
        }
several lines above.

In fuse_do_readpage():
        req->num_pages = 1;
        req->pages[0] = page;
with page dereferenced earlier.

In fuse_fill_write_pages():
                req->pages[req->num_pages] = page;
                req->page_descs[req->num_pages].length = tmp;
                req->num_pages++;
with
                if (!page)
                        break;
earlier.

In fuse_get_user_pages():
                ret = iov_iter_get_pages(ii, &req->pages[req->num_pages],
                                        *nbytesp - nbytes, 
                                        req->max_pages - req->num_pages,
                                        &start);
                if (ret < 0)
                        break;

                iov_iter_advance(ii, ret);
                nbytes += ret;

                ret += start;
                npages = (ret + PAGE_SIZE - 1) / PAGE_SIZE;

                req->page_descs[req->num_pages].offset = start;
                fuse_page_descs_length_init(req, req->num_pages, npages);

                req->num_pages += npages;
which also shouldn't leave any NULLs in the area in question.

In fuse_writepage_locked():
        req->num_pages = 1;
        req->pages[0] = tmp_page;
with
        if (!tmp_page)
                goto err_free;
done earlier.

In fuse_writepage_in_flight():
	req->num_pages = 1;
with
        BUG_ON(new_req->num_pages != 0);
earlier and
        req->pages[req->num_pages] = tmp_page;
done in the caller (which passes req as new_req).  Earlier in the caller
we have
        if (!tmp_page)
                goto out_unlock;

In fuse_writepages_fill():
		req->num_pages = 0;
is obviously OK and
        req->num_pages++;
in the end of the same function is preceded by the same
        req->pages[req->num_pages] = tmp_page;
(fuse_writepages_fill() is the caller of fuse_writepage_in_flight();
reassignment in fuse_writepage_in_flight() happens only in case when
it returns 1 and in that case we don't reach the increment in
fuse_writepages_fill() at all).

In fuse_do_ioctl():
        memcpy(req->pages, pages, sizeof(req->pages[0]) * num_pages);
        req->num_pages = num_pages;
and all increments of num_pages in there are
                pages[num_pages] = alloc_page(GFP_KERNEL | __GFP_HIGHMEM);
                if (!pages[num_pages])
                        goto out;
                num_pages++;
so the array we copy into req->pages has the same property wrt num_pages.

req->pages is assigned only in fuse_request_init(); that gets called
in two places - one is at request allocation time, another (from
put_reserved_req()) passes the current req->pages value, so that leaves it
unchanged.  The contents of req->pages[] is changed only in the aforementioned
places + fuse_request_init(), which zeros ->num_pages + fuse_copy_page()
called from fuse_copy_pages() with &req->pages[i] as argument.  The last
one can modify the damn thing, but only if it hits
                                err = fuse_try_move_page(cs, pagep);
and that sucker never stores a NULL in there -
                *pagep = newpage;
with get_page(newpage) upstream from that point.

What am I missing here?  Looks like those checks in fuse_copy_page() are
dead code...  They had been there since the initial merge, but AFAICS
they were just as useless in 2.6.14.  Rudiments of some prehistorical stuff
that never had been cleaned out, perhaps?
