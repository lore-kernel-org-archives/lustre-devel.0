From: James Simmons <jsimmons@infradead.org>
Date: Sun, 24 Feb 2019 17:02:04 +0000 (GMT)
Subject: [lustre-devel] [PATCH 07/37] lustre: obd_type: discard
 obd_type_lock
In-Reply-To: <155053494523.24125.14949515989661790146.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
 <155053494523.24125.14949515989661790146.stgit@noble.brown>
Message-ID: <alpine.LFD.2.21.1902241701300.22752@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> This lock is only used to protect typ_refcnt, so change
> that to a refcount_t and discard the lock.
> 
> The lock also covers calls to try_module_get and module_put,
> but this serves no purpose as it does not prevent the module
> from being unloaded.
> 
> Finally, the return value for the call to try_module_get is
> ignored, which is not safe.

Looks good. I do need to test this work tho.
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lustre/include/obd.h        |    3 +-
>  drivers/staging/lustre/lustre/mdc/mdc_request.c    |    2 +
>  drivers/staging/lustre/lustre/mgc/mgc_request.c    |    2 +
>  drivers/staging/lustre/lustre/obdclass/genops.c    |   30 +++++++++-----------
>  drivers/staging/lustre/lustre/obdclass/lu_object.c |    2 +
>  5 files changed, 18 insertions(+), 21 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
> index 50f33f400075..a67eb9a14879 100644
> --- a/drivers/staging/lustre/lustre/include/obd.h
> +++ b/drivers/staging/lustre/lustre/include/obd.h
> @@ -102,9 +102,8 @@ struct obd_type {
>  	struct obd_ops		*typ_dt_ops;
>  	struct md_ops		*typ_md_ops;
>  	struct dentry		*typ_debugfs_entry;
> -	int			 typ_refcnt;
> +	refcount_t		 typ_refcnt;
>  	struct lu_device_type	*typ_lu;
> -	spinlock_t		 obd_type_lock;
>  	struct kobject		 typ_kobj;
>  };
>  #define typ_name typ_kobj.name
> diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
> index 3eb89ec80b7e..db2c045aa1cd 100644
> --- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
> +++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
> @@ -2540,7 +2540,7 @@ static int mdc_init_ea_size(struct obd_export *exp, u32 easize, u32 def_easize)
>  static int mdc_precleanup(struct obd_device *obd)
>  {
>  	/* Failsafe, ok if racy */
> -	if (obd->obd_type->typ_refcnt <= 1)
> +	if (refcount_read(&obd->obd_type->typ_refcnt) <= 1)
>  		libcfs_kkuc_group_rem(0, KUC_GRP_HSM);
>  
>  	mdc_changelog_cdev_finish(obd);
> diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
> index a4dfdc08cc48..a6ee715921b8 100644
> --- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
> +++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
> @@ -715,7 +715,7 @@ static int mgc_cleanup(struct obd_device *obd)
>  	/* COMPAT_146 - old config logs may have added profiles we don't
>  	 * know about
>  	 */
> -	if (obd->obd_type->typ_refcnt <= 1)
> +	if (refcount_read(&obd->obd_type->typ_refcnt) <= 1)
>  		/* Only for the last mgc */
>  		class_del_profiles();
>  
> diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
> index 775e4fa4f6a8..a3437c2d07bb 100644
> --- a/drivers/staging/lustre/lustre/obdclass/genops.c
> +++ b/drivers/staging/lustre/lustre/obdclass/genops.c
> @@ -112,15 +112,17 @@ static struct obd_type *class_get_type(const char *name)
>  		}
>  	}
>  	if (type) {
> -		spin_lock(&type->obd_type_lock);
> -		type->typ_refcnt++;
> -		try_module_get(type->typ_dt_ops->owner);
> -		spin_unlock(&type->obd_type_lock);
> -		/* class_search_type() returned a counted reference,
> -		 * but we don't need that count any more as
> -		 * we have one through typ_refcnt.
> -		 */
> -		kobject_put(&type->typ_kobj);
> +		if (try_module_get(type->typ_dt_ops->owner)) {
> +			refcount_inc(&type->typ_refcnt);
> +			/* class_search_type() returned a counted reference,
> +			 * but we don't need that count any more as
> +			 * we have one through typ_refcnt.
> +			 */
> +			kobject_put(&type->typ_kobj);
> +		} else {
> +			kobject_put(&type->typ_kobj);
> +			type = NULL;
> +		}
>  	}
>  	return type;
>  }
> @@ -128,10 +130,7 @@ static struct obd_type *class_get_type(const char *name)
>  void class_put_type(struct obd_type *type)
>  {
>  	LASSERT(type);
> -	spin_lock(&type->obd_type_lock);
> -	type->typ_refcnt--;
> -	module_put(type->typ_dt_ops->owner);
> -	spin_unlock(&type->obd_type_lock);
> +	refcount_dec(&type->typ_refcnt);
>  }
>  
>  static void class_sysfs_release(struct kobject *kobj)
> @@ -191,7 +190,6 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
>  	/* md_ops is optional */
>  	if (md_ops)
>  		*type->typ_md_ops = *md_ops;
> -	spin_lock_init(&type->obd_type_lock);
>  
>  	rc = kobject_add(&type->typ_kobj, &lustre_kset->kobj, "%s", name);
>  	if (rc)
> @@ -225,8 +223,8 @@ int class_unregister_type(const char *name)
>  		return -EINVAL;
>  	}
>  
> -	if (type->typ_refcnt) {
> -		CERROR("type %s has refcount (%d)\n", name, type->typ_refcnt);
> +	if (refcount_read(&type->typ_refcnt)) {
> +		CERROR("type %s has refcount (%d)\n", name, refcount_read(&type->typ_refcnt));
>  		/* This is a bad situation, let's make the best of it */
>  		/* Remove ops, but leave the name for debugging */
>  		kfree(type->typ_dt_ops);
> diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
> index 639c298b6a90..69a56cca99f2 100644
> --- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
> +++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
> @@ -1267,7 +1267,7 @@ void lu_stack_fini(const struct lu_env *env, struct lu_device *top)
>  		next = ldt->ldt_ops->ldto_device_free(env, scan);
>  		type = ldt->ldt_obd_type;
>  		if (type) {
> -			type->typ_refcnt--;
> +			refcount_dec(&type->typ_refcnt);
>  			class_put_type(type);
>  		}
>  	}
> 
> 
> 
