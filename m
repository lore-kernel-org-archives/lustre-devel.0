From: Eric Barton <eeb@sun.com>
Date: Fri, 04 Jan 2008 18:36:59 +0000
Subject: [Lustre-devel] 2 primitives for the NRS
In-Reply-To: <1199468417.3722.522.camel@wheel>
References: <00d501c84ed6$e4fb2010$0281a8c0@ebpc>
	<1199468417.3722.522.camel@wheel>
Message-ID: <000e01c84f00$cadfd480$0281a8c0@ebpc>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Oops, I forgot the copyright boilerplate...

    Cheers,
              Eric
 

> -----Original Message-----
> From: Lee Ward [mailto:lee at sandia.gov] 
> Sent: 04 January 2008 5:40 PM
> To: Eric Barton
> Cc: lustre-devel at clusterfs.com
> Subject: Re: [Lustre-devel] 2 primitives for the NRS
> 
> Hi Eric,
> 
> Wow! That is good. I had a similar need for another project and solved
> it using a splay tree. Overhead is ~2.5 usec/op for random 
> inserts with
> unique keys and ~.04 usec/op for the ordered remove, at 1M records.
> Where might I get your implementation? Would like to see if I 
> can adapt
> it for my project.
> 
> 	--Lee
> 
> On Fri, 2008-01-04 at 06:37 -0700, Eric Barton wrote:
> > What the NRS (network request scheduler) really needs is something
> > that can order 10**[4-6] RPC requests incredibly efficiently - any
> > overhead just eats into server efficiency and we already swamp a
> > server with simple pings at ~30-40,000 RPCs per second.  I've
> > implemented a heap which is already looking good at managing
> > collections of 1,000,000+ objects with nearly sub-microsecond
> > insert+ordered_remove overhead.
> > 
> > Here is the API, which also introduces a sparse 1D array 
> suitable for
> > use in the kernel.  The binary heap uses it as space and cache
> > efficient means of tree walking.
> > 
> > Any suggestions for improving the API appreciated...
> > 
> > #ifndef __LIBCFS_BHEAP_H__
> > #define __LIBCFS_BHEAP_H__
> > 
> > /* Auto-array
> >  * A sparse 1D contiguous array of pointers which uses 
> single, double and
> >  * triple indirection maps and avoids allocating large 
> contiguous memory.
> >  *
> >  * FIXME: CAA_SHIFT should be defined automatically so that
> >  * (CAA_SIZE == CFS_PAGE_SIZE/sizeof(void *))
> >  */
> > 
> > #define CAA_SHIFT  10
> > #define CAA_SIZE   (1 << CAA_SHIFT)             /* # ptrs 
> per level */
> > #define CAA_MASK   (CAA_SIZE - 1)
> > #define CAA_NOB    (CAA_SIZE * sizeof(void *))
> > 
> > typedef struct
> > {
> >         void         ****aa_3d;                 /* Triple 
> indirect */
> >         void          ***aa_2d;                 /* double 
> indirect */
> >         void           **aa_1d;                 /* single 
> indirect */
> > } cfs_autoarray_t;
> > 
> > void   cfs_aa_init(cfs_autoarray_t *aa);         /* setup */
> > void   cfs_aa_fini(cfs_autoarray_t *aa);         /* free 
> all allocated mem */
> > 
> > /* effectively &aa[idx] but you MUST know &aa[idx] exists */
> > void **cfs_aa_index(cfs_autoarray_t *aa, unsigned int idx);
> > 
> > /* effectively &aa[idx] - return NULL if &aa[idx] doesn't 
> exist and 'grow' is
> >  * FALSE */
> > void **cfs_aa_lookup(cfs_autoarray_t *aa, unsigned int idx, 
> int grow);
> > 
> > 
> > /* Binary heap
> >  *
> >  * Supports insertion and ordered removal of members sorted 
> by the given total
> >  * order ('compare')
> >  */
> > 
> > typedef struct
> > {
> >         cfs_autoarray_t  cbh_members;
> >         unsigned int     cbh_size;
> >         unsigned int     cbh_maxsize;
> >         int            (*cbh_compare)(void *a, void *b);
> > } cfs_binheap_t;
> > 
> > void  cfs_binheap_init(cfs_binheap_t *h, int 
> (*compare)(void *a, void *b));
> > void  cfs_binheap_fini(cfs_binheap_t *h);
> > int   cfs_binheap_size(cfs_binheap_t *h);
> > int   cfs_binheap_insert(cfs_binheap_t *h, void *e);
> > void *cfs_binheap_remove_root(cfs_binheap_t *h);
> > 
> > #endif /* __LIBCFS_BHEAP_H__ */
> > 
> > _______________________________________________
> > Lustre-devel mailing list
> > Lustre-devel at clusterfs.com
> > https://mail.clusterfs.com/mailman/listinfo/lustre-devel
> > 
> 
> 
> 
-------------- next part --------------
A non-text attachment was scrubbed...
Name: heapnd.c
Type: application/octet-stream
Size: 12237 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20080104/0a654b9a/attachment.obj>
