From: NeilBrown <neilb@suse.com>
Date: Wed, 22 May 2019 16:49:31 +1000
Subject: [lustre-devel] [PATCH v2 07/29] lustre: obd: collect all
 resource releasing for obj_type.
In-Reply-To: <1558356671-29599-8-git-send-email-jsimmons@infradead.org>
References: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
 <1558356671-29599-8-git-send-email-jsimmons@infradead.org>
Message-ID: <8736l7vv9g.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, May 20 2019, James Simmons wrote:

> From: NeilBrown <neilb@suse.com>
>
> Now that obj_type is managed as a kobject, move all
> the freeing and deregistering into class_sysfs_release().
> Only leave type->typ_lu handling since unloading obdecho
> can trigger an assert.
>
> lu_context_key_degister()) ASSERTION( atomic_read(&key->lct_used) >= 1 ) failed:
> lu_context_key_degister()) LBUG
> kernel: Pid: 10642, comm: rmmod
> Call Trace:
> [<ffffffffc096e7cc>] libcfs_call_trace+0x8c/0xc0 [libcfs]
> [<ffffffffc096e87c>] lbug_with_loc+0x4c/0xa0 [libcfs]
> [<ffffffffc0f9761c>] lu_context_key_degister+0x14c/0x160 [obdclass]
> [<ffffffffc0f977d2>] lu_context_key_degister_many+0x72/0xb0 [obdclass]
> [<ffffffffc13e7130>] echo_type_fini+0x20/0x30 [obdecho]
> [<ffffffffc0f9618b>] lu_device_type_fini+0x1b/0x20 [obdclass]
> [<ffffffffc0f67fce>] class_sysfs_release+0x3e/0x6b0 [obdclass]
> [<ffffffffb85782a1>] kobject_release+0x81/0x1b0
> [<ffffffffb8578138>] kobject_put+0x28/0x60
> [<ffffffffc0f6940c>] class_unregister_type+0x23c/0x550 [obdclass]
> [<ffffffffc13f9636>] obdecho_exit+0x10/0x9da [obdecho]

I cannot reproduce this, and the change you suggest to fix is seems only
tangentially related to the symptom.

So I'm going to keep the lu_device_type_fini call in
class_sysfs_release().

If it happens again, I'd love to hear of it - even more so if you can
reproduce.

The most likely cause of the assertion failure is that  echo_type_fini
gets called twice.

Prior to
  Commit ef84c0736421 ("staging: lustre: use wait_event_var() in lu_context_key_degister()")

this would not have been fatal.  Now it is.  Maybe that is the cause of
this failed assertion.

Thanks,
NeilBrown


>
> Reviewed-by: James Simmons <jsimmons@infradead.org>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  fs/lustre/obdclass/genops.c | 21 ++++++++++-----------
>  1 file changed, 10 insertions(+), 11 deletions(-)
>
> diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
> index ccd8a42..2a5ec93 100644
> --- a/fs/lustre/obdclass/genops.c
> +++ b/fs/lustre/obdclass/genops.c
> @@ -138,6 +138,15 @@ static void class_sysfs_release(struct kobject *kobj)
>  {
>  	struct obd_type *type = container_of(kobj, struct obd_type, typ_kobj);
>  
> +	debugfs_remove_recursive(type->typ_debugfs_entry);
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
> @@ -167,6 +176,7 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
>  	if (!type)
>  		return -ENOMEM;
>  
> +	INIT_LIST_HEAD(&type->typ_chain);
>  	type->typ_kobj.kset = lustre_kset;
>  	rc = kobject_init_and_add(&type->typ_kobj, &class_ktype,
>  				  &lustre_kset->kobj, "%s", name);
> @@ -205,9 +215,6 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
>  	return 0;
>  
>  failed:
> -	kfree(type->typ_name);
> -	kfree(type->typ_md_ops);
> -	kfree(type->typ_dt_ops);
>  	kobject_put(&type->typ_kobj);
>  
>  	return rc;
> @@ -232,17 +239,9 @@ int class_unregister_type(const char *name)
>  		return -EBUSY;
>  	}
>  
> -	debugfs_remove_recursive(type->typ_debugfs_entry);
> -
>  	if (type->typ_lu)
>  		lu_device_type_fini(type->typ_lu);
>  
> -	spin_lock(&obd_types_lock);
> -	list_del(&type->typ_chain);
> -	spin_unlock(&obd_types_lock);
> -	kfree(type->typ_name);
> -	kfree(type->typ_dt_ops);
> -	kfree(type->typ_md_ops);
>  	kobject_put(&type->typ_kobj);
>  
>  	return 0;
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190522/9ca714c5/attachment.sig>
