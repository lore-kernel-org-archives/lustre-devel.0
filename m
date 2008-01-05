From: Alex Lyashkov <Alexey.Lyashkov@Sun.COM>
Date: Sat, 05 Jan 2008 14:19:42 +0200
Subject: [Lustre-devel] 2 primitives for the NRS
In-Reply-To: <00d501c84ed6$e4fb2010$0281a8c0@ebpc>
References: <00d501c84ed6$e4fb2010$0281a8c0@ebpc>
Message-ID: <1199535582.16449.6.camel@bear.shadowland>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, 2008-01-04 at 13:37 +0000, Eric Barton wrote:

> Any suggestions for improving the API appreciated...
> 
> #ifndef __LIBCFS_BHEAP_H__
> #define __LIBCFS_BHEAP_H__
> 
> /* Auto-array 
>  * A sparse 1D contiguous array of pointers which uses single, double and
>  * triple indirection maps and avoids allocating large contiguous memory.
>  *
>  * FIXME: CAA_SHIFT should be defined automatically so that 
>  */
> 
> #define CAA_SHIFT  10
> #define CAA_SIZE   (1 << CAA_SHIFT)             /* # ptrs per level */
> #define CAA_MASK   (CAA_SIZE - 1)
> #define CAA_NOB    (CAA_SIZE * sizeof(void *))
> 
> typedef struct
> {
>         void         ****aa_3d;                 /* Triple indirect */
>         void          ***aa_2d;                 /* double indirect */
>         void           **aa_1d;                 /* single indirect */
> } cfs_autoarray_t;
> 
> void   cfs_aa_init(cfs_autoarray_t *aa);         /* setup */
> void   cfs_aa_fini(cfs_autoarray_t *aa);         /* free all allocated mem */
> 
> /* effectively &aa[idx] but you MUST know &aa[idx] exists */
> void **cfs_aa_index(cfs_autoarray_t *aa, unsigned int idx);
> 
> /* effectively &aa[idx] - return NULL if &aa[idx] doesn't exist and 'grow' is
>  * FALSE */
> void **cfs_aa_lookup(cfs_autoarray_t *aa, unsigned int idx, int grow);
> 
why not move obdclass/class_hash into libcfs and use for lnet also ?
now it really generic code and can be easy moved info libcfs.
also if lookup algorithm in class_hash not good for work with 10^6
elements, this need to be adjusted for all usages.


-- 
Alex Lyashkov <Alexey.lyashkov@sun.com>
Lustre Group, Sun Microsystems
