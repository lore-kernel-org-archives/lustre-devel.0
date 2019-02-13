From: James Simmons <jsimmons@infradead.org>
Date: Wed, 13 Feb 2019 01:53:59 +0000 (GMT)
Subject: [lustre-devel] [PATCH 20/21] lustre: obdclass: fix module load
 locking.
In-Reply-To: <154949781345.10620.8278067573811049130.stgit@noble.brown>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
 <154949781345.10620.8278067573811049130.stgit@noble.brown>
Message-ID: <alpine.LFD.2.21.1902130153240.28026@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> Safe module loading requires that we try_module_get() in a context
> where the module cannot be unloaded, typically prodected by
> a spinlock that module-unload has to take.
> This doesn't currently happen in class_get_type().
> 
> There is a per-type spinlock, but it is almost entirely unused, and
> cannot be used to protect the module from being unloaded.
> 
> So discard ->obd_type_lock, and ensure that __class_search_type() and
> try_module_get() are both called while obd_types_lock is held - this
> prevent class_unregister_type() from completing (so the 'type' won't get
> freed.  That is always called from a module-unload function - if it
> has got that far, try_module_get() will fail.
> 
> So also check the return status of try_module_get().

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lustre/include/obd.h     |    1 -
>  drivers/staging/lustre/lustre/obdclass/genops.c |   24 ++++++++++++++---------
>  2 files changed, 15 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
> index 171d2c214be6..463ab680b524 100644
> --- a/drivers/staging/lustre/lustre/include/obd.h
> +++ b/drivers/staging/lustre/lustre/include/obd.h
> @@ -106,7 +106,6 @@ struct obd_type {
>  	char			*typ_name;
>  	int			 typ_refcnt;
>  	struct lu_device_type	*typ_lu;
> -	spinlock_t		 obd_type_lock;
>  	struct kobject		*typ_kobj;
>  };
>  
> diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
> index a174f538dd0d..dad21d9fa328 100644
> --- a/drivers/staging/lustre/lustre/obdclass/genops.c
> +++ b/drivers/staging/lustre/lustre/obdclass/genops.c
> @@ -109,35 +109,42 @@ static struct obd_type *class_search_type(const char *name)
>  
>  static struct obd_type *class_get_type(const char *name)
>  {
> -	struct obd_type *type = class_search_type(name);
> +	struct obd_type *type;
> +
> +	spin_lock(&obd_types_lock);
> +	type = __class_search_type(name);
>  
>  	if (!type) {
>  		const char *modname = name;
>  
> +		spin_unlock(&obd_types_lock);
>  		if (!request_module("%s", modname)) {
>  			CDEBUG(D_INFO, "Loaded module '%s'\n", modname);
> -			type = class_search_type(name);
>  		} else {
>  			LCONSOLE_ERROR_MSG(0x158, "Can't load module '%s'\n",
>  					   modname);
>  		}
> +		spin_lock(&obd_types_lock);
> +		type = __class_search_type(name);
>  	}
>  	if (type) {
> -		spin_lock(&type->obd_type_lock);
> -		type->typ_refcnt++;
> -		try_module_get(type->typ_dt_ops->owner);
> -		spin_unlock(&type->obd_type_lock);
> +		if (try_module_get(type->typ_dt_ops->owner))
> +			type->typ_refcnt++;
> +		else
> +			type = NULL;
>  	}
> +	spin_unlock(&obd_types_lock);
>  	return type;
>  }
>  
>  void class_put_type(struct obd_type *type)
>  {
>  	LASSERT(type);
> -	spin_lock(&type->obd_type_lock);
> +	spin_lock(&obd_types_lock);
> +	LASSERT(type->typ_refcnt > 0);
>  	type->typ_refcnt--;
>  	module_put(type->typ_dt_ops->owner);
> -	spin_unlock(&type->obd_type_lock);
> +	spin_unlock(&obd_types_lock);
>  }
>  
>  static void class_sysfs_release(struct kobject *kobj)
> @@ -206,7 +213,6 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
>  	if (md_ops)
>  		*type->typ_md_ops = *md_ops;
>  	strcpy(type->typ_name, name);
> -	spin_lock_init(&type->obd_type_lock);
>  
>  	type->typ_debugfs_entry = debugfs_create_dir(type->typ_name,
>  						     debugfs_lustre_root);
> 
> 
> 
