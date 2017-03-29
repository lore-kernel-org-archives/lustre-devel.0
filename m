From: Oleg Drokin <oleg.drokin@intel.com>
Date: Tue, 28 Mar 2017 23:24:14 -0400
Subject: [lustre-devel] [PATCH 1/1] Staging: lustre: lnet: libcfs: Fixed
	checkpatch.pl coding style errors
In-Reply-To: <1490695812-20475-1-git-send-email-vaibhavddit@gmail.com>
References: <1490695812-20475-1-git-send-email-vaibhavddit@gmail.com>
Message-ID: <5E15E74D-877E-4551-B9C2-57DDC77A8E26@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Mar 28, 2017, at 6:10 AM, <vaibhavddit@gmail.com> <vaibhavddit@gmail.com> wrote:

> From: Vaibhav Kothari <vaibhavddit@gmail.com>
> 
> Shifted open brace { to previous line for 8 functions as indicated by
> checkpatch.pl
> 
> Signed-off-by: Vaibhav Kothari <vaibhavddit@gmail.com>
> ---
> drivers/staging/lustre/lnet/libcfs/hash.c | 43 +++++++++++--------------------
> 1 file changed, 15 insertions(+), 28 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/libcfs/hash.c b/drivers/staging/lustre/lnet/libcfs/hash.c
> index 5c2ce2e..bb966e2 100644
> --- a/drivers/staging/lustre/lnet/libcfs/hash.c
> +++ b/drivers/staging/lustre/lnet/libcfs/hash.c
> @@ -1348,8 +1348,7 @@ void cfs_hash_putref(struct cfs_hash *hs)
> EXPORT_SYMBOL(cfs_hash_lookup);
> 
> static void
> -cfs_hash_for_each_enter(struct cfs_hash *hs)
> -{
> +cfs_hash_for_each_enter(struct cfs_hash *hs) {

Ugh, no.
This is obviously a false positive in checkpatch.


> 	LASSERT(!cfs_hash_is_exiting(hs));
> 
> 	if (!cfs_hash_with_rehash(hs))
> @@ -1375,8 +1374,7 @@ void cfs_hash_putref(struct cfs_hash *hs)
> }
> 
> static void
> -cfs_hash_for_each_exit(struct cfs_hash *hs)
> -{
> +cfs_hash_for_each_exit(struct cfs_hash *hs) {
> 	int remained;
> 	int bits;
> 
> @@ -1407,8 +1405,7 @@ void cfs_hash_putref(struct cfs_hash *hs)
>  */
> static u64
> cfs_hash_for_each_tight(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
> -			void *data, int remove_safe)
> -{
> +			void *data, int remove_safe) {
> 	struct hlist_node *hnode;
> 	struct hlist_node *pos;
> 	struct cfs_hash_bd bd;
> @@ -1465,8 +1462,7 @@ struct cfs_hash_cond_arg {
> 
> static int
> cfs_hash_cond_del_locked(struct cfs_hash *hs, struct cfs_hash_bd *bd,
> -			 struct hlist_node *hnode, void *data)
> -{
> +			 struct hlist_node *hnode, void *data) {
> 	struct cfs_hash_cond_arg *cond = data;
> 
> 	if (cond->func(cfs_hash_object(hs, hnode), cond->arg))
> @@ -1480,8 +1476,8 @@ struct cfs_hash_cond_arg {
>  * any object be reference.
>  */
> void
> -cfs_hash_cond_del(struct cfs_hash *hs, cfs_hash_cond_opt_cb_t func, void *data)
> -{
> +cfs_hash_cond_del(struct cfs_hash *hs, cfs_hash_cond_opt_cb_t func,
> +		void *data) {
> 	struct cfs_hash_cond_arg arg = {
> 		.func	= func,
> 		.arg	= data,
> @@ -1493,31 +1489,27 @@ struct cfs_hash_cond_arg {
> 
> void
> cfs_hash_for_each(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
> -		  void *data)
> -{
> +		  void *data) {
> 	cfs_hash_for_each_tight(hs, func, data, 0);
> }
> EXPORT_SYMBOL(cfs_hash_for_each);
> 
> void
> cfs_hash_for_each_safe(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
> -		       void *data)
> -{
> +		       void *data) {
> 	cfs_hash_for_each_tight(hs, func, data, 1);
> }
> EXPORT_SYMBOL(cfs_hash_for_each_safe);
> 
> static int
> cfs_hash_peek(struct cfs_hash *hs, struct cfs_hash_bd *bd,
> -	      struct hlist_node *hnode, void *data)
> -{
> +	      struct hlist_node *hnode, void *data) {
> 	*(int *)data = 0;
> 	return 1; /* return 1 to break the loop */
> }
> 
> int
> -cfs_hash_is_empty(struct cfs_hash *hs)
> -{
> +cfs_hash_is_empty(struct cfs_hash *hs) {
> 	int empty = 1;
> 
> 	cfs_hash_for_each_tight(hs, cfs_hash_peek, &empty, 0);
> @@ -1526,8 +1518,7 @@ struct cfs_hash_cond_arg {
> EXPORT_SYMBOL(cfs_hash_is_empty);
> 
> u64
> -cfs_hash_size_get(struct cfs_hash *hs)
> -{
> +cfs_hash_size_get(struct cfs_hash *hs) {
> 	return cfs_hash_with_counter(hs) ?
> 	       atomic_read(&hs->hs_count) :
> 	       cfs_hash_for_each_tight(hs, NULL, NULL, 0);
> @@ -1551,8 +1542,7 @@ struct cfs_hash_cond_arg {
>  */
> static int
> cfs_hash_for_each_relax(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
> -			void *data, int start)
> -{
> +			void *data, int start) {
> 	struct hlist_node *hnode;
> 	struct hlist_node *tmp;
> 	struct cfs_hash_bd bd;
> @@ -1629,8 +1619,7 @@ struct cfs_hash_cond_arg {
> 
> int
> cfs_hash_for_each_nolock(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
> -			 void *data, int start)
> -{
> +			 void *data, int start) {
> 	if (cfs_hash_with_no_lock(hs) ||
> 	    cfs_hash_with_rehash_key(hs) ||
> 	    !cfs_hash_with_no_itemref(hs))
> @@ -1661,8 +1650,7 @@ struct cfs_hash_cond_arg {
>  */
> int
> cfs_hash_for_each_empty(struct cfs_hash *hs, cfs_hash_for_each_cb_t func,
> -			void *data)
> -{
> +			void *data) {
> 	unsigned int i = 0;
> 
> 	if (cfs_hash_with_no_lock(hs))
> @@ -1718,8 +1706,7 @@ struct cfs_hash_cond_arg {
>  */
> void
> cfs_hash_for_each_key(struct cfs_hash *hs, const void *key,
> -		      cfs_hash_for_each_cb_t func, void *data)
> -{
> +		      cfs_hash_for_each_cb_t func, void *data) {
> 	struct hlist_node *hnode;
> 	struct cfs_hash_bd bds[2];
> 	unsigned int i;
> -- 
> 1.9.1
