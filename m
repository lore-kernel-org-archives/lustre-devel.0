From: James Simmons <jsimmons@infradead.org>
Date: Mon, 11 Feb 2019 02:04:29 +0000 (GMT)
Subject: [lustre-devel] [PATCH 11/21] lustre: cl_object: remove
 vestigial debugging.
In-Reply-To: <154949781313.10620.6363156783936746853.stgit@noble.brown>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
 <154949781313.10620.6363156783936746853.stgit@noble.brown>
Message-ID: <alpine.LFD.2.21.1902110157410.24975@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> cl_env_inc() and cl_env_dec() don't do anything,
> so discard them.

I don't know about this one. I saw Andreas response as well. 
So this was apart of "LU-744 obdclass: revise stats for cl_object cache"
In the end it was turned off by default in the OpenSFS branch since it
made performance take a hit. To enable in OpenSFS branch you have to run
./configure --enable-pgstate-track. We have a few like this for Lustre so
I was going to bring this up. Do we want to remove this work for both the
upstream client as well as OpenSFS tree or properly implement this by
making it a Kconfig option when CONFIG_LUSTRE_DEBUG_EXPENSIVE_CHECK is
enabled? Its just a matter of porting OpenSFS commit 
5cae09a2409dcd396a1ee7be1eca7d3bbf77365e

What do you think?

> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lustre/obdclass/cl_object.c |   15 ---------------
>  1 file changed, 15 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
> index d71a680660da..1e704078664e 100644
> --- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
> +++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
> @@ -565,14 +565,6 @@ struct cl_env {
>  	void		       *ce_debug;
>  };
>  
> -static void cl_env_inc(enum cache_stats_item item)
> -{
> -}
> -
> -static void cl_env_dec(enum cache_stats_item item)
> -{
> -}
> -
>  static void cl_env_init0(struct cl_env *cle, void *debug)
>  {
>  	LASSERT(cle->ce_ref == 0);
> @@ -581,7 +573,6 @@ static void cl_env_init0(struct cl_env *cle, void *debug)
>  
>  	cle->ce_ref = 1;
>  	cle->ce_debug = debug;
> -	cl_env_inc(CS_busy);
>  }
>  
>  static struct lu_env *cl_env_new(u32 ctx_tags, u32 ses_tags, void *debug)
> @@ -611,9 +602,6 @@ static struct lu_env *cl_env_new(u32 ctx_tags, u32 ses_tags, void *debug)
>  		if (rc != 0) {
>  			kmem_cache_free(cl_env_kmem, cle);
>  			env = ERR_PTR(rc);
> -		} else {
> -			cl_env_inc(CS_create);
> -			cl_env_inc(CS_total);
>  		}
>  	} else {
>  		env = ERR_PTR(-ENOMEM);
> @@ -623,7 +611,6 @@ static struct lu_env *cl_env_new(u32 ctx_tags, u32 ses_tags, void *debug)
>  
>  static void cl_env_fini(struct cl_env *cle)
>  {
> -	cl_env_dec(CS_total);
>  	lu_context_fini(&cle->ce_lu.le_ctx);
>  	lu_context_fini(&cle->ce_ses);
>  	kmem_cache_free(cl_env_kmem, cle);
> @@ -782,7 +769,6 @@ void cl_env_put(struct lu_env *env, u16 *refcheck)
>  	if (--cle->ce_ref == 0) {
>  		int cpu = get_cpu();
>  
> -		cl_env_dec(CS_busy);
>  		cle->ce_debug = NULL;
>  		cl_env_exit(cle);
>  		/*
> @@ -903,7 +889,6 @@ void cl_env_percpu_put(struct lu_env *env)
>  	cle->ce_ref--;
>  	LASSERT(cle->ce_ref == 0);
>  
> -	cl_env_dec(CS_busy);
>  	cle->ce_debug = NULL;
>  
>  	put_cpu();
> 
> 
> 
