From: Andreas Dilger <adilger@whamcloud.com>
Date: Wed, 3 Apr 2019 19:45:21 +0000
Subject: [lustre-devel] [PATCH 11/28] lustre: handles: discard h_owner
 in favour of h_ops
In-Reply-To: <155168109847.31333.10992261955260144819.stgit@noble.brown>
References: <155168107971.31333.14345309795939467246.stgit@noble.brown>
 <155168109847.31333.10992261955260144819.stgit@noble.brown>
Message-ID: <DD40EE3E-859B-4842-85C8-D6DA4721D624@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mar 3, 2019, at 23:31, NeilBrown <neilb@suse.com> wrote:
> 
> lustre_handles  assigned a  64bit  unique identifier  (a 'cookie')  to
> objects of  various types and  stored them  in a hash  table, allowing
> them to be accessed by the cookie.
> 
> The is a facility for type checking by recording an 'owner' for each
> object, and checking the owner on lookup.  Unfortunately this is not
> used - owner is always zero.
> 
> Eahc object also contains an h_ops pointer which can be used to
> reliably identify an owner.
> 
> So discard h_owner, pass and 'ops' pointer to class_handle2object(),
> and only return objects for which the h_ops matches.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>

Probably a bit late to the party here, but it would be useful to add a
portability note here, that the pointer to "struct mdt_export_data"
that is currently stored in h_owner should move to "struct mdt_file_data"
in the server code.

Reviewed-by: Andreas Dilger <adilger@whamcloud.com>

> ---
> .../staging/lustre/lustre/include/lustre_handles.h |    7 +++----
> drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |    2 +-
> drivers/staging/lustre/lustre/obdclass/genops.c    |    3 ++-
> .../lustre/lustre/obdclass/lustre_handles.c        |    6 +++---
> 4 files changed, 9 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/include/lustre_handles.h b/drivers/staging/lustre/lustre/include/lustre_handles.h
> index 683680891e4c..9a4b1a821e7b 100644
> --- a/drivers/staging/lustre/lustre/include/lustre_handles.h
> +++ b/drivers/staging/lustre/lustre/include/lustre_handles.h
> @@ -65,8 +65,7 @@ struct portals_handle_ops {
> struct portals_handle {
> 	struct list_head		h_link;
> 	u64				h_cookie;
> -	const void			*h_owner;
> -	struct portals_handle_ops	*h_ops;
> +	const struct portals_handle_ops	*h_ops;
> 
> 	/* newly added fields to handle the RCU issue. -jxiong */
> 	struct rcu_head			h_rcu;
> @@ -79,9 +78,9 @@ struct portals_handle {
> 
> /* Add a handle to the hash table */
> void class_handle_hash(struct portals_handle *,
> -		       struct portals_handle_ops *ops);
> +		       const struct portals_handle_ops *ops);
> void class_handle_unhash(struct portals_handle *);
> -void *class_handle2object(u64 cookie, const void *owner);
> +void *class_handle2object(u64 cookie, const struct portals_handle_ops *ops);
> void class_handle_free_cb(struct rcu_head *rcu);
> int class_handle_init(void);
> void class_handle_cleanup(void);
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
> index 7ec5fc900da8..768cccc1fa82 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
> @@ -515,7 +515,7 @@ struct ldlm_lock *__ldlm_handle2lock(const struct lustre_handle *handle,
> 
> 	LASSERT(handle);
> 
> -	lock = class_handle2object(handle->cookie, NULL);
> +	lock = class_handle2object(handle->cookie, &lock_handle_ops);
> 	if (!lock)
> 		return NULL;
> 
> diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
> index e206bb401fe3..42859fbca330 100644
> --- a/drivers/staging/lustre/lustre/obdclass/genops.c
> +++ b/drivers/staging/lustre/lustre/obdclass/genops.c
> @@ -708,6 +708,7 @@ int obd_init_caches(void)
> 	return -ENOMEM;
> }
> 
> +static struct portals_handle_ops export_handle_ops;
> /* map connection to client */
> struct obd_export *class_conn2export(struct lustre_handle *conn)
> {
> @@ -724,7 +725,7 @@ struct obd_export *class_conn2export(struct lustre_handle *conn)
> 	}
> 
> 	CDEBUG(D_INFO, "looking for export cookie %#llx\n", conn->cookie);
> -	export = class_handle2object(conn->cookie, NULL);
> +	export = class_handle2object(conn->cookie, &export_handle_ops);
> 	return export;
> }
> EXPORT_SYMBOL(class_conn2export);
> diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
> index 0674afb0059f..32b70d613f71 100644
> --- a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
> +++ b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
> @@ -59,7 +59,7 @@ static struct handle_bucket {
>  * global (per-node) hash-table.
>  */
> void class_handle_hash(struct portals_handle *h,
> -		       struct portals_handle_ops *ops)
> +		       const struct portals_handle_ops *ops)
> {
> 	struct handle_bucket *bucket;
> 
> @@ -132,7 +132,7 @@ void class_handle_unhash(struct portals_handle *h)
> }
> EXPORT_SYMBOL(class_handle_unhash);
> 
> -void *class_handle2object(u64 cookie, const void *owner)
> +void *class_handle2object(u64 cookie, const struct portals_handle_ops *ops)
> {
> 	struct handle_bucket *bucket;
> 	struct portals_handle *h;
> @@ -147,7 +147,7 @@ void *class_handle2object(u64 cookie, const void *owner)
> 
> 	rcu_read_lock();
> 	list_for_each_entry_rcu(h, &bucket->head, h_link) {
> -		if (h->h_cookie != cookie || h->h_owner != owner)
> +		if (h->h_cookie != cookie || h->h_ops != ops)
> 			continue;
> 
> 		spin_lock(&h->h_lock);
> 
> 

Cheers, Andreas
---
Andreas Dilger
CTO Whamcloud
