From: NeilBrown <neilb@suse.com>
Date: Wed, 22 May 2019 15:20:02 +1000
Subject: [lustre-devel] [PATCH v2 06/29] lustre: embed typ_kobj in
 obd_type
In-Reply-To: <1558356671-29599-7-git-send-email-jsimmons@infradead.org>
References: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
 <1558356671-29599-7-git-send-email-jsimmons@infradead.org>
Message-ID: <875zq3vzel.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, May 20 2019, James Simmons wrote:

> From: NeilBrown <neilb@suse.com>
>
> As there is a 1-1 mapping between obd_types and their ->typ_kobj, it
> is simple and more normal to embed the kobj in the obd_type, rather
> than allocate it separately.
>
> This requires calling "kobject_init_and_add()" earlier, so we
> open-code relevant part of class_setup_tunables() in
> class_register_type(). Now class_setup_tunables() is needed only
> for server side code.
>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  fs/lustre/include/obd.h             |  2 +-
>  fs/lustre/include/obd_class.h       |  1 -
>  fs/lustre/obdclass/genops.c         | 56 +++++++++++--------------------------
>  fs/lustre/obdclass/lprocfs_status.c |  2 +-
>  4 files changed, 19 insertions(+), 42 deletions(-)
>
> diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
> index f626695..f20c246 100644
> --- a/fs/lustre/include/obd.h
> +++ b/fs/lustre/include/obd.h
> @@ -107,7 +107,7 @@ struct obd_type {
>  	int			 typ_refcnt;
>  	struct lu_device_type	*typ_lu;
>  	spinlock_t		 obd_type_lock;
> -	struct kobject		*typ_kobj;
> +	struct kobject		 typ_kobj;
>  };
>  
>  struct brw_page {
> diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
> index e4cde19..1729865 100644
> --- a/fs/lustre/include/obd_class.h
> +++ b/fs/lustre/include/obd_class.h
> @@ -60,7 +60,6 @@
>  
>  /* genops.c */
>  struct obd_export *class_conn2export(struct lustre_handle *conn);
> -struct kobject *class_setup_tunables(const char *name);
>  int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
>  			const char *name, struct lu_device_type *ldt);
>  int class_unregister_type(const char *name);
> diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
> index bc1f979..ccd8a42 100644
> --- a/fs/lustre/obdclass/genops.c
> +++ b/fs/lustre/obdclass/genops.c
> @@ -136,7 +136,9 @@ void class_put_type(struct obd_type *type)
>  
>  static void class_sysfs_release(struct kobject *kobj)
>  {
> -	kfree(kobj);
> +	struct obd_type *type = container_of(kobj, struct obd_type, typ_kobj);
> +
> +	kfree(type);
>  }
>  
>  static struct kobj_type class_ktype = {
> @@ -144,26 +146,6 @@ static void class_sysfs_release(struct kobject *kobj)
>  	.release	= class_sysfs_release,
>  };
>  
> -struct kobject *class_setup_tunables(const char *name)
> -{
> -	struct kobject *kobj;
> -	int rc;
> -
> -	kobj = kzalloc(sizeof(*kobj), GFP_KERNEL);
> -	if (!kobj)
> -		return ERR_PTR(-ENOMEM);
> -
> -	kobj->kset = lustre_kset;
> -	kobject_init(kobj, &class_ktype);
> -	rc = kobject_add(kobj, &lustre_kset->kobj, "%s", name);
> -	if (rc) {
> -		kobject_put(kobj);
> -		return ERR_PTR(rc);
> -	}
> -	return kobj;
> -}
> -EXPORT_SYMBOL(class_setup_tunables);
> -
>  #define CLASS_MAX_NAME 1024
>  
>  int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
> @@ -181,10 +163,17 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
>  		return -EEXIST;
>  	}
>  
> -	rc = -ENOMEM;
>  	type = kzalloc(sizeof(*type), GFP_NOFS);
>  	if (!type)
> -		return rc;
> +		return -ENOMEM;
> +
> +	type->typ_kobj.kset = lustre_kset;
> +	rc = kobject_init_and_add(&type->typ_kobj, &class_ktype,
> +				  &lustre_kset->kobj, "%s", name);

I don't know that I would actually cause a problem, but I don't like
"add"ing and object (above) before fully initializing it (below).  So
I've kept the split from my version where kobject_init() happens early
and kobject_add() happens later.
I've included the other changes that you made.

Thanks,
NeilBrown


> +	if (rc)
> +		goto failed;
> +
> +	type->typ_debugfs_entry = debugfs_create_dir(name, debugfs_lustre_root);
>  
>  	type->typ_dt_ops = kzalloc(sizeof(*type->typ_dt_ops), GFP_NOFS);
>  	type->typ_md_ops = kzalloc(sizeof(*type->typ_md_ops), GFP_NOFS);
> @@ -202,22 +191,11 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
>  	strcpy(type->typ_name, name);
>  	spin_lock_init(&type->obd_type_lock);
>  
> -	type->typ_debugfs_entry = debugfs_create_dir(type->typ_name,
> -						     debugfs_lustre_root);
> -
> -	type->typ_kobj = class_setup_tunables(type->typ_name);
> -	if (IS_ERR(type->typ_kobj)) {
> -		rc = PTR_ERR(type->typ_kobj);
> -		goto failed;
> -	}
> -
>  	if (ldt) {
>  		type->typ_lu = ldt;
>  		rc = lu_device_type_init(ldt);
> -		if (rc != 0) {
> -			kobject_put(type->typ_kobj);
> +		if (rc != 0)
>  			goto failed;
> -		}
>  	}
>  
>  	spin_lock(&obd_types_lock);
> @@ -230,7 +208,8 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
>  	kfree(type->typ_name);
>  	kfree(type->typ_md_ops);
>  	kfree(type->typ_dt_ops);
> -	kfree(type);
> +	kobject_put(&type->typ_kobj);
> +
>  	return rc;
>  }
>  EXPORT_SYMBOL(class_register_type);
> @@ -253,8 +232,6 @@ int class_unregister_type(const char *name)
>  		return -EBUSY;
>  	}
>  
> -	kobject_put(type->typ_kobj);
> -
>  	debugfs_remove_recursive(type->typ_debugfs_entry);
>  
>  	if (type->typ_lu)
> @@ -266,7 +243,8 @@ int class_unregister_type(const char *name)
>  	kfree(type->typ_name);
>  	kfree(type->typ_dt_ops);
>  	kfree(type->typ_md_ops);
> -	kfree(type);
> +	kobject_put(&type->typ_kobj);
> +
>  	return 0;
>  } /* class_unregister_type */
>  EXPORT_SYMBOL(class_unregister_type);
> diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
> index 11fddc8..71bf409 100644
> --- a/fs/lustre/obdclass/lprocfs_status.c
> +++ b/fs/lustre/obdclass/lprocfs_status.c
> @@ -1036,7 +1036,7 @@ int lprocfs_obd_setup(struct obd_device *obd, bool uuid_only)
>  	obd->obd_ktype.sysfs_ops = &lustre_sysfs_ops;
>  	obd->obd_ktype.release = obd_sysfs_release;
>  
> -	obd->obd_kset.kobj.parent = obd->obd_type->typ_kobj;
> +	obd->obd_kset.kobj.parent = &obd->obd_type->typ_kobj;
>  	obd->obd_kset.kobj.ktype = &obd->obd_ktype;
>  	init_completion(&obd->obd_kobj_unregister);
>  	rc = kset_register(&obd->obd_kset);
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190522/9687968e/attachment.sig>
