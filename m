From: James Simmons <jsimmons@infradead.org>
Date: Mon, 11 Feb 2019 01:57:32 +0000 (GMT)
Subject: [lustre-devel] [PATCH 10/21] lustre: obdclass: use
 cl_object_for_each where appropriate
In-Reply-To: <154949781310.10620.8883358407999258821.stgit@noble.brown>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
 <154949781310.10620.8883358407999258821.stgit@noble.brown>
Message-ID: <alpine.LFD.2.21.1902110155130.24975@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> There are various places which have a list_for_each_entry()
> where cl_object_for_each (or .._reverse) is more appropriate.
> 
> Several of these re-use the 'obj' function parameter as a loop
> iterator, which is a little confusing.
> 
> Change these to use cl_object_for_each{_reverse}, and where needed,
> introduce a new iterator variable 'o'.

Surprised the reverse wasn't done in that the cl_* macro was
removed :-) 

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lustre/lov/lov_page.c       |    3 -
>  drivers/staging/lustre/lustre/obdclass/cl_lock.c   |    3 -
>  drivers/staging/lustre/lustre/obdclass/cl_object.c |   82 +++++++++-----------
>  drivers/staging/lustre/lustre/obdclass/cl_page.c   |   11 +--
>  4 files changed, 44 insertions(+), 55 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/lov/lov_page.c b/drivers/staging/lustre/lustre/lov/lov_page.c
> index 08485a95ec01..e64b350601d2 100644
> --- a/drivers/staging/lustre/lustre/lov/lov_page.c
> +++ b/drivers/staging/lustre/lustre/lov/lov_page.c
> @@ -103,8 +103,7 @@ int lov_page_init_composite(const struct lu_env *env, struct cl_object *obj,
>  		return PTR_ERR(sub);
>  
>  	subobj = lovsub2cl(r0->lo_sub[stripe]);
> -	list_for_each_entry(o, &subobj->co_lu.lo_header->loh_layers,
> -			    co_lu.lo_linkage) {
> +	cl_object_for_each(o, subobj) {
>  		if (o->co_ops->coo_page_init) {
>  			rc = o->co_ops->coo_page_init(sub->sub_env, o, page,
>  						      cl_index(subobj, suboff));
> diff --git a/drivers/staging/lustre/lustre/obdclass/cl_lock.c b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
> index 8133d992cc73..fc5976d8b37b 100644
> --- a/drivers/staging/lustre/lustre/obdclass/cl_lock.c
> +++ b/drivers/staging/lustre/lustre/obdclass/cl_lock.c
> @@ -103,8 +103,7 @@ int cl_lock_init(const struct lu_env *env, struct cl_lock *lock,
>  	LASSERT(obj);
>  
>  	INIT_LIST_HEAD(&lock->cll_layers);
> -	list_for_each_entry(scan, &obj->co_lu.lo_header->loh_layers,
> -			    co_lu.lo_linkage) {
> +	cl_object_for_each(scan, obj) {
>  		result = scan->co_ops->coo_lock_init(env, scan, lock, io);
>  		if (result != 0) {
>  			cl_lock_fini(env, lock);
> diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
> index f724b2d62df1..d71a680660da 100644
> --- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
> +++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
> @@ -190,16 +190,15 @@ EXPORT_SYMBOL(cl_object_attr_unlock);
>  int cl_object_attr_get(const struct lu_env *env, struct cl_object *obj,
>  		       struct cl_attr *attr)
>  {
> -	struct lu_object_header *top;
> +	struct cl_object *o;
>  	int result;
>  
>  	assert_spin_locked(cl_object_attr_guard(obj));
>  
> -	top = obj->co_lu.lo_header;
>  	result = 0;
> -	list_for_each_entry(obj, &top->loh_layers, co_lu.lo_linkage) {
> -		if (obj->co_ops->coo_attr_get) {
> -			result = obj->co_ops->coo_attr_get(env, obj, attr);
> +	cl_object_for_each(o, obj) {
> +		if (o->co_ops->coo_attr_get) {
> +			result = o->co_ops->coo_attr_get(env, o, attr);
>  			if (result != 0) {
>  				if (result > 0)
>  					result = 0;
> @@ -221,17 +220,16 @@ EXPORT_SYMBOL(cl_object_attr_get);
>  int cl_object_attr_update(const struct lu_env *env, struct cl_object *obj,
>  			  const struct cl_attr *attr, unsigned int v)
>  {
> -	struct lu_object_header *top;
> +	struct cl_object *o;
>  	int result;
>  
>  	assert_spin_locked(cl_object_attr_guard(obj));
>  
> -	top = obj->co_lu.lo_header;
>  	result = 0;
> -	list_for_each_entry_reverse(obj, &top->loh_layers, co_lu.lo_linkage) {
> -		if (obj->co_ops->coo_attr_update) {
> -			result = obj->co_ops->coo_attr_update(env, obj, attr,
> -							      v);
> +	cl_object_for_each_reverse(o, obj) {
> +		if (o->co_ops->coo_attr_update) {
> +			result = o->co_ops->coo_attr_update(env, o, attr,
> +							    v);
>  			if (result != 0) {
>  				if (result > 0)
>  					result = 0;
> @@ -254,19 +252,18 @@ EXPORT_SYMBOL(cl_object_attr_update);
>  int cl_object_glimpse(const struct lu_env *env, struct cl_object *obj,
>  		      struct ost_lvb *lvb)
>  {
> -	struct lu_object_header *top;
> +	struct cl_object *o;
>  	int result;
>  
> -	top = obj->co_lu.lo_header;
>  	result = 0;
> -	list_for_each_entry_reverse(obj, &top->loh_layers, co_lu.lo_linkage) {
> -		if (obj->co_ops->coo_glimpse) {
> -			result = obj->co_ops->coo_glimpse(env, obj, lvb);
> +	cl_object_for_each_reverse(o, obj) {
> +		if (o->co_ops->coo_glimpse) {
> +			result = o->co_ops->coo_glimpse(env, o, lvb);
>  			if (result != 0)
>  				break;
>  		}
>  	}
> -	LU_OBJECT_HEADER(D_DLMTRACE, env, lu_object_top(top),
> +	LU_OBJECT_HEADER(D_DLMTRACE, env, lu_object_top(obj->co_lu.lo_header),
>  			 "size: %llu mtime: %llu atime: %llu ctime: %llu blocks: %llu\n",
>  			 lvb->lvb_size, lvb->lvb_mtime, lvb->lvb_atime,
>  			 lvb->lvb_ctime, lvb->lvb_blocks);
> @@ -280,14 +277,13 @@ EXPORT_SYMBOL(cl_object_glimpse);
>  int cl_conf_set(const struct lu_env *env, struct cl_object *obj,
>  		const struct cl_object_conf *conf)
>  {
> -	struct lu_object_header *top;
> +	struct cl_object *o;
>  	int result;
>  
> -	top = obj->co_lu.lo_header;
>  	result = 0;
> -	list_for_each_entry(obj, &top->loh_layers, co_lu.lo_linkage) {
> -		if (obj->co_ops->coo_conf_set) {
> -			result = obj->co_ops->coo_conf_set(env, obj, conf);
> +	cl_object_for_each(o, obj) {
> +		if (o->co_ops->coo_conf_set) {
> +			result = o->co_ops->coo_conf_set(env, o, conf);
>  			if (result != 0)
>  				break;
>  		}
> @@ -301,13 +297,11 @@ EXPORT_SYMBOL(cl_conf_set);
>   */
>  int cl_object_prune(const struct lu_env *env, struct cl_object *obj)
>  {
> -	struct lu_object_header *top;
>  	struct cl_object *o;
>  	int result;
>  
> -	top = obj->co_lu.lo_header;
>  	result = 0;
> -	list_for_each_entry(o, &top->loh_layers, co_lu.lo_linkage) {
> +	cl_object_for_each(o, obj) {
>  		if (o->co_ops->coo_prune) {
>  			result = o->co_ops->coo_prune(env, o);
>  			if (result != 0)
> @@ -325,14 +319,13 @@ EXPORT_SYMBOL(cl_object_prune);
>  int cl_object_getstripe(const struct lu_env *env, struct cl_object *obj,
>  			struct lov_user_md __user *uarg, size_t size)
>  {
> -	struct lu_object_header *top;
> +	struct cl_object *o;
>  	int result = 0;
>  
> -	top = obj->co_lu.lo_header;
> -	list_for_each_entry(obj, &top->loh_layers, co_lu.lo_linkage) {
> -		if (obj->co_ops->coo_getstripe) {
> -			result = obj->co_ops->coo_getstripe(env, obj, uarg,
> -							    size);
> +	cl_object_for_each(o, obj) {
> +		if (o->co_ops->coo_getstripe) {
> +			result = o->co_ops->coo_getstripe(env, o, uarg,
> +							  size);
>  			if (result)
>  				break;
>  		}
> @@ -357,14 +350,13 @@ int cl_object_fiemap(const struct lu_env *env, struct cl_object *obj,
>  		     struct ll_fiemap_info_key *key,
>  		     struct fiemap *fiemap, size_t *buflen)
>  {
> -	struct lu_object_header *top;
> +	struct cl_object *o;
>  	int result = 0;
>  
> -	top = obj->co_lu.lo_header;
> -	list_for_each_entry(obj, &top->loh_layers, co_lu.lo_linkage) {
> -		if (obj->co_ops->coo_fiemap) {
> -			result = obj->co_ops->coo_fiemap(env, obj, key, fiemap,
> -							 buflen);
> +	cl_object_for_each(o, obj) {
> +		if (o->co_ops->coo_fiemap) {
> +			result = o->co_ops->coo_fiemap(env, o, key, fiemap,
> +						       buflen);
>  			if (result)
>  				break;
>  		}
> @@ -376,11 +368,11 @@ EXPORT_SYMBOL(cl_object_fiemap);
>  int cl_object_layout_get(const struct lu_env *env, struct cl_object *obj,
>  			 struct cl_layout *cl)
>  {
> -	struct lu_object_header *top = obj->co_lu.lo_header;
> +	struct cl_object *o;
>  
> -	list_for_each_entry(obj, &top->loh_layers, co_lu.lo_linkage) {
> -		if (obj->co_ops->coo_layout_get)
> -			return obj->co_ops->coo_layout_get(env, obj, cl);
> +	cl_object_for_each(o, obj) {
> +		if (o->co_ops->coo_layout_get)
> +			return o->co_ops->coo_layout_get(env, o, cl);
>  	}
>  
>  	return -EOPNOTSUPP;
> @@ -389,12 +381,12 @@ EXPORT_SYMBOL(cl_object_layout_get);
>  
>  loff_t cl_object_maxbytes(struct cl_object *obj)
>  {
> -	struct lu_object_header *top = obj->co_lu.lo_header;
> +	struct cl_object *o;
>  	loff_t maxbytes = LLONG_MAX;
>  
> -	list_for_each_entry(obj, &top->loh_layers, co_lu.lo_linkage) {
> -		if (obj->co_ops->coo_maxbytes)
> -			maxbytes = min_t(loff_t, obj->co_ops->coo_maxbytes(obj),
> +	cl_object_for_each(o, obj) {
> +		if (o->co_ops->coo_maxbytes)
> +			maxbytes = min_t(loff_t, o->co_ops->coo_maxbytes(o),
>  					 maxbytes);
>  	}
>  
> diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
> index 057318deaa4e..7d00a9233a3b 100644
> --- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
> +++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
> @@ -132,7 +132,7 @@ struct cl_page *cl_page_alloc(const struct lu_env *env,
>  			      enum cl_page_type type)
>  {
>  	struct cl_page *page;
> -	struct lu_object_header *head;
> +	struct cl_object *o2;
>  
>  	page = kzalloc(cl_object_header(o)->coh_page_bufsize, GFP_NOFS);
>  	if (page) {
> @@ -149,11 +149,10 @@ struct cl_page *cl_page_alloc(const struct lu_env *env,
>  		INIT_LIST_HEAD(&page->cp_layers);
>  		INIT_LIST_HEAD(&page->cp_batch);
>  		lu_ref_init(&page->cp_reference);
> -		head = o->co_lu.lo_header;
> -		list_for_each_entry(o, &head->loh_layers, co_lu.lo_linkage) {
> -			if (o->co_ops->coo_page_init) {
> -				result = o->co_ops->coo_page_init(env, o, page,
> -								  ind);
> +		cl_object_for_each(o2, o) {
> +			if (o2->co_ops->coo_page_init) {
> +				result = o2->co_ops->coo_page_init(env, o2, page,
> +								   ind);
>  				if (result != 0) {
>  					__cl_page_delete(env, page);
>  					cl_page_free(env, page);
> 
> 
> 
