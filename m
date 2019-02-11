From: NeilBrown <neilb@suse.com>
Date: Mon, 11 Feb 2019 14:14:15 +1100
Subject: [lustre-devel] [PATCH 04/21] lustre: use list*entry macros in
 place of container_of()
In-Reply-To: <alpine.LFD.2.21.1902110057200.24975@casper.infradead.org>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
 <154949781267.10620.8365663638954760207.stgit@noble.brown>
 <alpine.LFD.2.21.1902110057200.24975@casper.infradead.org>
Message-ID: <8736ovggoo.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Feb 11 2019, James Simmons wrote:

>> There are a number of places that use container_of() but where
>> list_first_entry(), or list_last_entry() make the meaning more clear.
>> So change them over.
>
> I have to say normally the patches you see genernally use the basic
> functionality of the linux list implementation. I wonder if a deep
> dive on LUG's developers day would be a good idea.

It is possible to take the "new macro for subtly different case"
exercise too far, though in this particular case, I think using
replacing container_of with list_entry is a clear win.

Maybe a broader discussion would help

>
> Reviewed-by: James Simmons <jsimmons@infradead.org>

Thanks,
NeilBrown

>  
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>  drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |    4 ++--
>>  drivers/staging/lustre/lustre/obdclass/cl_io.c     |    4 ++--
>>  drivers/staging/lustre/lustre/obdclass/cl_object.c |   13 ++++++++-----
>>  drivers/staging/lustre/lustre/obdclass/cl_page.c   |    4 ++--
>>  drivers/staging/lustre/lustre/obdclass/lu_object.c |    7 +++----
>>  5 files changed, 17 insertions(+), 15 deletions(-)
>> 
>> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
>> index 85c5047f4ba2..74c7644d6ef8 100644
>> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
>> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
>> @@ -987,8 +987,8 @@ struct ldlm_namespace *ldlm_namespace_first_locked(enum ldlm_side client)
>>  {
>>  	LASSERT(mutex_is_locked(ldlm_namespace_lock(client)));
>>  	LASSERT(!list_empty(ldlm_namespace_list(client)));
>> -	return container_of(ldlm_namespace_list(client)->next,
>> -		struct ldlm_namespace, ns_list_chain);
>> +	return list_first_entry(ldlm_namespace_list(client),
>> +				struct ldlm_namespace, ns_list_chain);
>>  }
>>  
>>  /** Create and initialize new resource. */
>> diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
>> index 7bf02350f19d..34b4e63e7d1a 100644
>> --- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
>> +++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
>> @@ -93,8 +93,8 @@ void cl_io_fini(const struct lu_env *env, struct cl_io *io)
>>  	LINVRNT(cl_io_invariant(io));
>>  
>>  	while (!list_empty(&io->ci_layers)) {
>> -		slice = container_of(io->ci_layers.prev, struct cl_io_slice,
>> -				     cis_linkage);
>> +		slice = list_last_entry(&io->ci_layers, struct cl_io_slice,
>> +					cis_linkage);
>>  		list_del_init(&slice->cis_linkage);
>>  		if (slice->cis_iop->op[io->ci_type].cio_fini)
>>  			slice->cis_iop->op[io->ci_type].cio_fini(env, slice);
>> diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
>> index 05d784ae7a6c..f724b2d62df1 100644
>> --- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
>> +++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
>> @@ -649,8 +649,8 @@ static struct lu_env *cl_env_obtain(void *debug)
>>  	if (cl_envs[cpu].cec_count > 0) {
>>  		int rc;
>>  
>> -		cle = container_of(cl_envs[cpu].cec_envs.next, struct cl_env,
>> -				   ce_linkage);
>> +		cle = list_first_entry(&cl_envs[cpu].cec_envs, struct cl_env,
>> +				       ce_linkage);
>>  		list_del_init(&cle->ce_linkage);
>>  		cl_envs[cpu].cec_count--;
>>  		read_unlock(&cl_envs[cpu].cec_guard);
>> @@ -748,9 +748,12 @@ unsigned int cl_env_cache_purge(unsigned int nr)
>>  
>>  	for_each_possible_cpu(i) {
>>  		write_lock(&cl_envs[i].cec_guard);
>> -		for (; !list_empty(&cl_envs[i].cec_envs) && nr > 0; --nr) {
>> -			cle = container_of(cl_envs[i].cec_envs.next,
>> -					   struct cl_env, ce_linkage);
>> +		for (; nr >0 &&
>> +			     (cle = list_first_entry_or_null(
>> +				     &cl_envs[i].cec_envs,
>> +				     struct cl_env,
>> +				     ce_linkage)) != NULL;
>> +		     --nr) {
>>  			list_del_init(&cle->ce_linkage);
>>  			LASSERT(cl_envs[i].cec_count > 0);
>>  			cl_envs[i].cec_count--;
>> diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
>> index b1b4dc7ea22f..d025ea55818f 100644
>> --- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
>> +++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
>> @@ -690,8 +690,8 @@ int cl_page_is_vmlocked(const struct lu_env *env, const struct cl_page *pg)
>>  	const struct cl_page_slice *slice;
>>  	int result;
>>  
>> -	slice = container_of(pg->cp_layers.next,
>> -			     const struct cl_page_slice, cpl_linkage);
>> +	slice = list_first_entry(&pg->cp_layers,
>> +				 const struct cl_page_slice, cpl_linkage);
>>  	PASSERT(env, pg, slice->cpl_ops->cpo_is_vmlocked);
>>  	/*
>>  	 * Call ->cpo_is_vmlocked() directly instead of going through
>> diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
>> index 3bd48748f46c..639c298b6a90 100644
>> --- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
>> +++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
>> @@ -349,7 +349,7 @@ static void lu_object_free(const struct lu_env *env, struct lu_object *o)
>>  		 * lives as long as possible and ->loo_object_free() methods
>>  		 * can look at its contents.
>>  		 */
>> -		o = container_of(splice.prev, struct lu_object, lo_linkage);
>> +		o = list_last_entry(&splice, struct lu_object, lo_linkage);
>>  		list_del_init(&o->lo_linkage);
>>  		o->lo_ops->loo_object_free(env, o);
>>  	}
>> @@ -432,9 +432,8 @@ int lu_site_purge_objects(const struct lu_env *env, struct lu_site *s,
>>  		 * Free everything on the dispose list. This is safe against
>>  		 * races due to the reasons described in lu_object_put().
>>  		 */
>> -		while (!list_empty(&dispose)) {
>> -			h = container_of(dispose.next,
>> -					 struct lu_object_header, loh_lru);
>> +		while ((h = list_first_entry_or_null(
>> +				&dispose, struct lu_object_header, loh_lru)) != NULL) {
>>  			list_del_init(&h->loh_lru);
>>  			lu_object_free(env, lu_object_top(h));
>>  			lprocfs_counter_incr(s->ls_stats, LU_SS_LRU_PURGED);
>> 
>> 
>> 
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190211/b5cb43a0/attachment.sig>
