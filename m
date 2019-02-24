From: James Simmons <jsimmons@infradead.org>
Date: Sun, 24 Feb 2019 16:54:49 +0000 (GMT)
Subject: [lustre-devel] [PATCH 04/37] lustre: collect all resource
 releasing for obj_type.
In-Reply-To: <155053494500.24125.3045348327157278994.stgit@noble.brown>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
 <155053494500.24125.3045348327157278994.stgit@noble.brown>
Message-ID: <alpine.LFD.2.21.1902241653500.22752@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> Now that obj_type is managed as a kobject, move all
> the freeing and deregistering into class_sysfs_release().

This is a really nice change. I would have never considered that.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lustre/obdclass/genops.c |   27 +++++++++++------------
>  1 file changed, 13 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
> index 2bd72f8a38eb..4c0dc2098823 100644
> --- a/drivers/staging/lustre/lustre/obdclass/genops.c
> +++ b/drivers/staging/lustre/lustre/obdclass/genops.c
> @@ -138,6 +138,18 @@ static void class_sysfs_release(struct kobject *kobj)
>  {
>  	struct obd_type *type = container_of(kobj, struct obd_type, typ_kobj);
>  
> +	debugfs_remove_recursive(type->typ_debugfs_entry);
> +
> +	if (type->typ_lu)
> +		lu_device_type_fini(type->typ_lu);
> +
> +	spin_lock(&obd_types_lock);
> +	list_del(&type->typ_chain);
> +	spin_unlock(&obd_types_lock);
> +
> +	kfree(type->typ_name);
> +	kfree(type->typ_md_ops);
> +	kfree(type->typ_dt_ops);
>  	kfree(type);
>  }
>  
> @@ -170,6 +182,7 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
>  
>  	type->typ_kobj.kset = lustre_kset;
>  	kobject_init(&type->typ_kobj, &class_ktype);
> +	INIT_LIST_HEAD(&type->typ_chain);
>  
>  	type->typ_dt_ops = kzalloc(sizeof(*type->typ_dt_ops), GFP_NOFS);
>  	type->typ_md_ops = kzalloc(sizeof(*type->typ_md_ops), GFP_NOFS);
> @@ -209,9 +222,6 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
>  	return 0;
>  
>  failed:
> -	kfree(type->typ_name);
> -	kfree(type->typ_md_ops);
> -	kfree(type->typ_dt_ops);
>  	kobject_put(&type->typ_kobj);
>  
>  	return rc;
> @@ -236,17 +246,6 @@ int class_unregister_type(const char *name)
>  		return -EBUSY;
>  	}
>  
> -	debugfs_remove_recursive(type->typ_debugfs_entry);
> -
> -	if (type->typ_lu)
> -		lu_device_type_fini(type->typ_lu);
> -
> -	spin_lock(&obd_types_lock);
> -	list_del(&type->typ_chain);
> -	spin_unlock(&obd_types_lock);
> -	kfree(type->typ_name);
> -	kfree(type->typ_dt_ops);
> -	kfree(type->typ_md_ops);
>  	kobject_put(&type->typ_kobj);
>  
>  	return 0;
> 
> 
> 
