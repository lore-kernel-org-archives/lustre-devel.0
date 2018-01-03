From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Wed, 3 Jan 2018 03:30:55 +0000
Subject: [lustre-devel] [PATCH] drivers: lustre: obdclass: simplify
 unregister_shrinker() usage
In-Reply-To: <20171223111316.3386-1-akaraliou.dev@gmail.com>
References: <20171223111316.3386-1-akaraliou.dev@gmail.com>
Message-ID: <F5FF4C71-7866-4EDF-8BA7-1D9B8C3FC7A5@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Dec 23, 2017, at 04:13, Aliaksei Karaliou <akaraliou.dev@gmail.com> wrote:
> 
> lu_global_fini() explicitly uses knowledge about shrinker's
> internals to make decision about calling of unregister_shrinker().
> Now this check was integrated into unregister_shrinker(),
> so it is safe to call it against unregistered shrinker.
> 
> Signed-off-by: Aliaksei Karaliou <akaraliou.dev@gmail.com>

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

> ---
> drivers/staging/lustre/lustre/obdclass/lu_object.c | 3 +--
> 1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
> index 8e2e6b89e494..2719abbff85f 100644
> --- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
> +++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
> @@ -1977,8 +1977,7 @@ int lu_global_init(void)
>  */
> void lu_global_fini(void)
> {
> -	if (lu_site_shrinker.nr_deferred)
> -		unregister_shrinker(&lu_site_shrinker);
> +	unregister_shrinker(&lu_site_shrinker);
> 	lu_context_key_degister(&lu_global_key);
> 
> 	/*
> -- 
> 2.11.0
> 

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
