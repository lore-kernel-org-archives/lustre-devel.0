From: Matthew Ahrens <mahrens@delphix.com>
Date: Fri, 5 Jul 2019 11:15:01 -0700
Subject: [lustre-devel] Request arc buffer, zerocopy
In-Reply-To: <1561715412.12733.3@informatik.uni-hamburg.de>
References: <1560426887.3392.0@informatik.uni-hamburg.de>
 <1561554708.16396.0@informatik.uni-hamburg.de>
 <CAJjvXiGT_kjDAwQv8WgJY+i47itMLzpT4iBumOyxa9qGLnwTzQ@mail.gmail.com>
 <1561715412.12733.3@informatik.uni-hamburg.de>
Message-ID: <CAJjvXiG_NEnL1ZVTZ9dpjSsekOd_-S7KsNORcobJudXUoXUiTg@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Jun 28, 2019 at 2:50 AM Anna Fuchs <
anna.fuchs@informatik.uni-hamburg.de> wrote:

> Hello Matt,
>
> thanks for your reply.
>
> >
> > You can set the block size (of the first and only block) using
> > dmu_object_set_blocksize().  FYI, I think that this comment is
> > incorrect:
> >  * If the first block is allocated already, the new size must be
> > greater
> >  * than the current block size.
> >
> > You can increase or decrease the block size with this routine.
>
> This is a deeper call of Lustre's osd_grow_blocksize I mentioned
> before. If I understand it correctly, they are called in the context of
> transactions, right?
>

It is not possible to change the block size of a ZFS object outside of a
transaction.


> If so, I can not use it - I need the blocksize to be set in the buffer
> preparation stage, before comitting in a transaction.
> Lustre's original routine looks simplified as follows:
>
> osd_bufs_get_write
>         bs = dn->dn_datablksz
>         while (len > 0)
>                 if (sz_in_block == bs)          /* full block, try
> zerocopy */
>                         abuf = osd_request_arcbuf(dn, bs);
>                 else                            /* can't use zerocopy,
> allocate temp. buffers */
>                         ... alloc_page ...
>                         here going later on the dmu_write path (pagewise!)
>
> Currently, in the very first iteration this blocksize (bs) is taken
> from the dnode and is e.g. 4K.
> When writing a chunk of 16K, I get 4 arcbufs 4K each. For the next
> chunk the block size might be grown up to x (recordsize?).
> Here I need the blocksize to be set to 16K (or 128K or later some
> generic value defined by the Lustre client) before the first arcbuf is
> requested,
> because the compressed chunk sent from client is logically this size.
> At this point I don't have any dmu_tx yet to grow the blocksize saved
> in dn->dn_datablksz before the while loop.
> So I am not sure how deep to go? This min size is set on dnode creation
> by ZFS, how can I "reset" it?
>

I think that you are saying that you want to be loaned an ARC buffer of the
size provided by the client, which may be different from the object's
current blocksize.  You will later (within a transaction) change the
object's blocksize to the size specified by the client, and write the data
(using the loaned ARC buffer).  You can do exactly that using the routines
I mentioned.

In your example code above, you are providing the dnode when requesting the
arc buf, which leads to the problem you described (needing that dnode's
block size to match the size provided by the client before you change the
blocksize of the object).  However, this is an unnecessary restriction,
because arc_loan_compressed_buf() does not need to know the dnode, or its
current block size.

--matt



>
> >
> > I'd recommend that you hand the compressed data to ZFS similarly to
> > how "zfs receive" does (for compressed send streams).  It sounds like
> > the is the direction you're going, which is great.  FYI, here are
> > some of the routines you'd want to use (copied from dmu_recv.c):
> >
> >                       abuf = arc_loan_compressed_buf(
> >
> >                          dmu_objset_spa(drc->drc_os),
> >
> >                          drrw->drr_compressed_size,
> drrw->drr_logical_size,
> >
> >                          drrw->drr_compressiontype);
> >
> >
> >       dmu_assign_arcbuf(bonus, drrw->drr_offset, abuf, tx);
> >
> >  (or dmu_assign_arcbuf_dnode())
> >
> >
> >                       dmu_return_arcbuf(rrd->write_buf);
> >
>
> Yes, thanks for that. We have two paths how Lustre interacts with ZFS -
> requesting arc buffers or dmu_write.
> The common dmu_request_arcbuf goes over arc_loan_buf, so we introduced
> dmu_request_compressed_arcbuf to go over arc_loan_compressed_buf to
> reuse the receive functionality.
> We try to make as few changes as possible on Lustre's interface since
> we want mix compressed and uncompressed data chunks (and be at the same
> time compatible with ZFS' on disk format..)
> The dmu_write path will be tricky, though.
>
> Any comments are welcome.
>
> Best regards
> Anna
>
> --
>
> Anna Fuchs
> Universit?t Hamburg
>
>
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190705/da855dc7/attachment.html>
