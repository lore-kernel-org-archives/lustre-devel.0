From: Lee Ward <lee@sandia.gov>
Date: Fri, 04 Jan 2008 17:36:01 -0700
Subject: [Lustre-devel] 2 primitives for the NRS
In-Reply-To: <000e01c84f00$cadfd480$0281a8c0@ebpc>
References: <00d501c84ed6$e4fb2010$0281a8c0@ebpc>
	<1199468417.3722.522.camel@wheel> <000e01c84f00$cadfd480$0281a8c0@ebpc>
Message-ID: <1199493361.3722.559.camel@wheel>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Eric,

Your machine must be faster than mine :) I could never get your heapnd.c
program to demonstrate rates below 2 usec.

I used your test harness as it was easier to mod than mine. Also, I got
better times with your harness exercising the splay tree. Think this is
because my test harness destroys the TLB cache; I build the tree from
scratch, empty it, rebuild it... Just a lousy harness. Yours is much
closer to my use-case, anyway. Don't know why I did that.

The splay tree implementation turned out to be faster when I finally got
an apples-to-apples comparison using your harness. It used about 20%
more memory though. Classic time/space trade-off I guess. My app is not
particularly sensitive to memory usage. Thanks for letting me try out
your code.

Anyway, I owe you the results since you were so kind as to send your
code:

Script started on Fri 04 Jan 2008 05:14:40 PM MST
lee at wheel:/tmp$ cc heapnd.c
lee at wheel:/tmp$ ./a.out 1000000 1000000
Size 1000000: 4.266uS
>>cat /proc/21262/statm: 10420 9894 101 2 0 9823 0
lee at wheel:/tmp$ cc treend.c
lee at wheel:/tmp$ !./a
./a.out 1000000 1000000
Size 1000000: 1.620uS
>>cat /proc/21277/statm: 12375 11839 100 2 0 11778 0
lee at wheel:/tmp$ cc -O3 heapnd.c
lee at wheel:/tmp$ !./
./a.out 1000000 1000000
Size 1000000: 2.455uS
>>cat /proc/21289/statm: 10420 9893 100 2 0 9823 0
lee at wheel:/tmp$ cc -O3 treend.c
lee at wheel:/tmp$ !./
./a.out 1000000 1000000
Size 1000000: 0.969uS
>>cat /proc/21304/statm: 12376 11838 99 3 0 11778 0
lee at wheel:/tmp$ exit

Script done on Fri 04 Jan 2008 05:15:54 PM MST

		--Lee


On Fri, 2008-01-04 at 11:36 -0700, Eric Barton wrote:
> Oops, I forgot the copyright boilerplate...
> 
>     Cheers,
>               Eric
> 
> 
> > -----Original Message-----
> > From: Lee Ward [mailto:lee at sandia.gov]
> > Sent: 04 January 2008 5:40 PM
> > To: Eric Barton
> > Cc: lustre-devel at clusterfs.com
> > Subject: Re: [Lustre-devel] 2 primitives for the NRS
> >
> > Hi Eric,
> >
> > Wow! That is good. I had a similar need for another project and solved
> > it using a splay tree. Overhead is ~2.5 usec/op for random
> > inserts with
> > unique keys and ~.04 usec/op for the ordered remove, at 1M records.
> > Where might I get your implementation? Would like to see if I
> > can adapt
> > it for my project.
> >
> >       --Lee
> >
> > On Fri, 2008-01-04 at 06:37 -0700, Eric Barton wrote:
> > > What the NRS (network request scheduler) really needs is something
> > > that can order 10**[4-6] RPC requests incredibly efficiently - any
> > > overhead just eats into server efficiency and we already swamp a
> > > server with simple pings at ~30-40,000 RPCs per second.  I've
> > > implemented a heap which is already looking good at managing
> > > collections of 1,000,000+ objects with nearly sub-microsecond
> > > insert+ordered_remove overhead.
> > >
> > > Here is the API, which also introduces a sparse 1D array
> > suitable for
> > > use in the kernel.  The binary heap uses it as space and cache
> > > efficient means of tree walking.
> > >
> > > Any suggestions for improving the API appreciated...
> > >
> > > #ifndef __LIBCFS_BHEAP_H__
> > > #define __LIBCFS_BHEAP_H__
> > >
> > > /* Auto-array
> > >  * A sparse 1D contiguous array of pointers which uses
> > single, double and
> > >  * triple indirection maps and avoids allocating large
> > contiguous memory.
> > >  *
> > >  * FIXME: CAA_SHIFT should be defined automatically so that
> > >  * (CAA_SIZE == CFS_PAGE_SIZE/sizeof(void *))
> > >  */
> > >
> > > #define CAA_SHIFT  10
> > > #define CAA_SIZE   (1 << CAA_SHIFT)             /* # ptrs
> > per level */
> > > #define CAA_MASK   (CAA_SIZE - 1)
> > > #define CAA_NOB    (CAA_SIZE * sizeof(void *))
> > >
> > > typedef struct
> > > {
> > >         void         ****aa_3d;                 /* Triple
> > indirect */
> > >         void          ***aa_2d;                 /* double
> > indirect */
> > >         void           **aa_1d;                 /* single
> > indirect */
> > > } cfs_autoarray_t;
> > >
> > > void   cfs_aa_init(cfs_autoarray_t *aa);         /* setup */
> > > void   cfs_aa_fini(cfs_autoarray_t *aa);         /* free
> > all allocated mem */
> > >
> > > /* effectively &aa[idx] but you MUST know &aa[idx] exists */
> > > void **cfs_aa_index(cfs_autoarray_t *aa, unsigned int idx);
> > >
> > > /* effectively &aa[idx] - return NULL if &aa[idx] doesn't
> > exist and 'grow' is
> > >  * FALSE */
> > > void **cfs_aa_lookup(cfs_autoarray_t *aa, unsigned int idx,
> > int grow);
> > >
> > >
> > > /* Binary heap
> > >  *
> > >  * Supports insertion and ordered removal of members sorted
> > by the given total
> > >  * order ('compare')
> > >  */
> > >
> > > typedef struct
> > > {
> > >         cfs_autoarray_t  cbh_members;
> > >         unsigned int     cbh_size;
> > >         unsigned int     cbh_maxsize;
> > >         int            (*cbh_compare)(void *a, void *b);
> > > } cfs_binheap_t;
> > >
> > > void  cfs_binheap_init(cfs_binheap_t *h, int
> > (*compare)(void *a, void *b));
> > > void  cfs_binheap_fini(cfs_binheap_t *h);
> > > int   cfs_binheap_size(cfs_binheap_t *h);
> > > int   cfs_binheap_insert(cfs_binheap_t *h, void *e);
> > > void *cfs_binheap_remove_root(cfs_binheap_t *h);
> > >
> > > #endif /* __LIBCFS_BHEAP_H__ */
> > >
> > > _______________________________________________
> > > Lustre-devel mailing list
> > > Lustre-devel at clusterfs.com
> > > https://mail.clusterfs.com/mailman/listinfo/lustre-devel
> > >
> >
> >
> >
