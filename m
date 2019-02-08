From: Andreas Dilger <adilger@whamcloud.com>
Date: Fri, 8 Feb 2019 00:13:50 +0000
Subject: [lustre-devel] [PATCH 03/21] lustre: obdclass: use list_sort()
 to sort a list.
In-Reply-To: <154949781252.10620.13626213918115345779.stgit@noble.brown>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
 <154949781252.10620.13626213918115345779.stgit@noble.brown>
Message-ID: <A53C0515-BF90-446D-BB4E-040B8BD1FB87@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Feb 6, 2019, at 17:03, NeilBrown <neilb@suse.com> wrote:
> 
> Rather than a bespoke bubble-sort, use list_sort() to
> sort this linked list.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

Probably a performance win as well, since it looks like list_sort() uses merge sort
instead of bubble sort.

Reviewed-by: Andreas Dilger <adilger@whamcloud.com>

> ---
> drivers/staging/lustre/lustre/obdclass/cl_io.c |   51 +++++-------------------
> 1 file changed, 10 insertions(+), 41 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
> index beac7e8bc92a..7bf02350f19d 100644
> --- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
> +++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
> @@ -42,6 +42,7 @@
> #include <obd_support.h>
> #include <lustre_fid.h>
> #include <linux/list.h>
> +#include <linux/list_sort.h>
> #include <linux/sched.h>
> #include <cl_object.h>
> #include "cl_internal.h"
> @@ -213,9 +214,15 @@ int cl_io_rw_init(const struct lu_env *env, struct cl_io *io,
> }
> EXPORT_SYMBOL(cl_io_rw_init);
> 
> -static int cl_lock_descr_sort(const struct cl_lock_descr *d0,
> -			      const struct cl_lock_descr *d1)
> +static int cl_lock_descr_cmp(void *priv,
> +			     struct list_head *a, struct list_head *b)
> {
> +	const struct cl_io_lock_link *l0 = list_entry(a, struct cl_io_lock_link, cill_linkage);
> +	const struct cl_io_lock_link *l1 = list_entry(b, struct cl_io_lock_link, cill_linkage);
> +
> +	const struct cl_lock_descr *d0 = &l0->cill_descr;
> +	const struct cl_lock_descr *d1 = &l1->cill_descr;
> +
> 	return lu_fid_cmp(lu_object_fid(&d0->cld_obj->co_lu),
> 			  lu_object_fid(&d1->cld_obj->co_lu));
> }
> @@ -225,45 +232,7 @@ static int cl_lock_descr_sort(const struct cl_lock_descr *d0,
>  */
> static void cl_io_locks_sort(struct cl_io *io)
> {
> -	int done = 0;
> -
> -	/* hidden treasure: bubble sort for now. */
> -	do {
> -		struct cl_io_lock_link *curr;
> -		struct cl_io_lock_link *prev;
> -		struct cl_io_lock_link *temp;
> -
> -		done = 1;
> -		prev = NULL;
> -
> -		list_for_each_entry_safe(curr, temp,
> -					 &io->ci_lockset.cls_todo,
> -					 cill_linkage) {
> -			if (prev) {
> -				switch (cl_lock_descr_sort(&prev->cill_descr,
> -							   &curr->cill_descr)) {
> -				case 0:
> -					/*
> -					 * IMPOSSIBLE: Identical locks are
> -					 *	     already removed at
> -					 *	     this point.
> -					 */
> -				default:
> -					LBUG();
> -				case 1:
> -					list_move_tail(&curr->cill_linkage,
> -						       &prev->cill_linkage);
> -					done = 0;
> -					continue; /* don't change prev: it's
> -						   * still "previous"
> -						   */
> -				case -1: /* already in order */
> -					break;
> -				}
> -			}
> -			prev = curr;
> -		}
> -	} while (!done);
> +	list_sort(NULL, &io->ci_lockset.cls_todo, cl_lock_descr_cmp);
> }
> 
> static void cl_lock_descr_merge(struct cl_lock_descr *d0,
> 
> 

Cheers, Andreas
---
Andreas Dilger
Principal Lustre Architect
Whamcloud
