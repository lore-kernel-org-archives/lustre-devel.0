From: James Simmons <jsimmons@infradead.org>
Date: Tue, 12 Feb 2019 05:03:43 +0000 (GMT)
Subject: [lustre-devel] [PATCH 19/21] lustre: obdclass: avoid races in
 class_register_type()
In-Reply-To: <154949781342.10620.11880180011933935219.stgit@noble.brown>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
 <154949781342.10620.11880180011933935219.stgit@noble.brown>
Message-ID: <alpine.LFD.2.21.1902120435450.3631@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> If there are two parallel attempts to register the
> same class name, it could get registered twice.
> So re-check after allocation to make sure the name is
> still unique.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  drivers/staging/lustre/lustre/obdclass/genops.c |   29 +++++++++++++++--------
>  1 file changed, 19 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
> index 382eaf519a79..a174f538dd0d 100644
> --- a/drivers/staging/lustre/lustre/obdclass/genops.c
> +++ b/drivers/staging/lustre/lustre/obdclass/genops.c
> @@ -86,17 +86,23 @@ static void obd_device_free(struct obd_device *obd)
>  	kmem_cache_free(obd_device_cachep, obd);
>  }
>  
> -static struct obd_type *class_search_type(const char *name)
> +static struct obd_type *__class_search_type(const char *name)
>  {
>  	struct obd_type *type;
>  
> -	spin_lock(&obd_types_lock);
>  	list_for_each_entry(type, &obd_types, typ_chain) {

This change is fine but we really don't need typ_chain anymore.
We have a list of obd_types already due to the power of kobjects!!!!

We can do an

static struct obd_type *class_search_type(const char *name)
{
	struct kobject *kobj;
	struct obd_type *type;

	kobj = kset_find_obj(lustre_kset, name);

	return "some_mapping from kobj to type"

Hmm. This kobj is not embedded in struct obd_types. Might need more
surgery to make that work.

> -		if (strcmp(type->typ_name, name) == 0) {
> -			spin_unlock(&obd_types_lock);
> +		if (strcmp(type->typ_name, name) == 0)
>  			return type;
> -		}
>  	}
> +	return NULL;
> +}
> +
> +static struct obd_type *class_search_type(const char *name)
> +{
> +	struct obd_type *type;
> +
> +	spin_lock(&obd_types_lock);
> +	type = __class_search_type(name);
>  	spin_unlock(&obd_types_lock);
>  	return NULL;
>  }
> @@ -214,19 +220,22 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
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
> +	INIT_LIST_HEAD(&type->typ_chain);
>  	spin_lock(&obd_types_lock);
> -	list_add(&type->typ_chain, &obd_types);
> +	if (__class_search_type(name) == NULL)
> +		list_add(&type->typ_chain, &obd_types);
>  	spin_unlock(&obd_types_lock);
>  
> -	return 0;
> +	if (!list_empty(&type->typ_chain))
> +		return 0;
>  
>  failed:
> +	if (!IS_ERR_OR_NULL(type->typ_kobj))
> +		kobject_put(type->typ_kobj);
>  	kfree(type->typ_name);
>  	kfree(type->typ_md_ops);
>  	kfree(type->typ_dt_ops);
> 
> 
> 
