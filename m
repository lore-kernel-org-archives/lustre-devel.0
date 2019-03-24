From: NeilBrown <neilb@suse.com>
Date: Mon, 25 Mar 2019 10:37:10 +1100
Subject: [lustre-devel] [PATCH 05/28] lustre: obd_type: discard
 obd_type_lock
In-Reply-To: <alpine.LFD.2.21.1903220349550.32231@casper.infradead.org>
References: <155168107971.31333.14345309795939467246.stgit@noble.brown>
 <155168109825.31333.15239500185325332009.stgit@noble.brown>
 <alpine.LFD.2.21.1903220349550.32231@casper.infradead.org>
Message-ID: <87va074zfd.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Fri, Mar 22 2019, James Simmons wrote:

>> This lock is only used to protect typ_refcnt, so change
>> that to an atomic_t and discard the lock.
>> 
>> The lock also covers calls to try_module_get and module_put,
>> but this serves no purpose as it does not prevent the module
>> from being unloaded.
>> 
>> Finally, the return value for the call to try_module_get is
>> ignored, which is not safe.
>
> Nak. Looking at the code we can easily use the kref of the
> kobject instead. The two special cases for the ref_count
> can be removed. The one for mdc_request was removed in
> patch https://review.whamcloud.com/30419. The other refcount
> use in mgc looks like its for supporting lustre 1.4 version
> logs. I bet that can be removed. Andreas can state if it 
> is still need.

Hi James,
 I think what you mean by "NAK" here is that you like the patch and that
 it improves the code, but there are even more improvements that can be
 made.
 Would that be correct?  In that case I'd rather leave the further
 improvements to a separate patch - especially if it needs confirmation
 from Andreas.

 Though I just noticed there is a bug in the patch - I dropped the
 module_put() from class_put_type() without any justification.  Oops.

Thanks,
NeilBrown

 

>
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>  drivers/staging/lustre/lustre/include/obd.h        |    3 +-
>>  drivers/staging/lustre/lustre/mdc/mdc_request.c    |    2 +
>>  drivers/staging/lustre/lustre/mgc/mgc_request.c    |    2 +
>>  drivers/staging/lustre/lustre/obdclass/genops.c    |   30 +++++++++-----------
>>  drivers/staging/lustre/lustre/obdclass/lu_object.c |    2 +
>>  5 files changed, 18 insertions(+), 21 deletions(-)
>> 
>> diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
>> index 4c58b916e0a3..61fb8159af20 100644
>> --- a/drivers/staging/lustre/lustre/include/obd.h
>> +++ b/drivers/staging/lustre/lustre/include/obd.h
>> @@ -102,9 +102,8 @@ struct obd_type {
>>  	struct obd_ops		*typ_dt_ops;
>>  	struct md_ops		*typ_md_ops;
>>  	struct dentry		*typ_debugfs_entry;
>> -	int			 typ_refcnt;
>> +	atomic_t		 typ_refcnt;
>>  	struct lu_device_type	*typ_lu;
>> -	spinlock_t		 obd_type_lock;
>>  	struct kobject		 typ_kobj;
>>  };
>>  #define typ_name typ_kobj.name
>> diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
>> index bc764f9dd102..705a4e3b518a 100644
>> --- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
>> +++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
>> @@ -2542,7 +2542,7 @@ static int mdc_init_ea_size(struct obd_export *exp, u32 easize, u32 def_easize)
>>  static int mdc_precleanup(struct obd_device *obd)
>>  {
>>  	/* Failsafe, ok if racy */
>> -	if (obd->obd_type->typ_refcnt <= 1)
>> +	if (atomic_read(&obd->obd_type->typ_refcnt) <= 1)
>>  		libcfs_kkuc_group_rem(0, KUC_GRP_HSM);
>>  
>>  	mdc_changelog_cdev_finish(obd);
>> diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
>> index 84ba6d0e3493..0580afa2755d 100644
>> --- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
>> +++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
>> @@ -715,7 +715,7 @@ static int mgc_cleanup(struct obd_device *obd)
>>  	/* COMPAT_146 - old config logs may have added profiles we don't
>>  	 * know about
>>  	 */
>> -	if (obd->obd_type->typ_refcnt <= 1)
>> +	if (atomic_read(&obd->obd_type->typ_refcnt) <= 1)
>>  		/* Only for the last mgc */
>>  		class_del_profiles();
>>  
>> diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
>> index 74195de639e4..02d829617519 100644
>> --- a/drivers/staging/lustre/lustre/obdclass/genops.c
>> +++ b/drivers/staging/lustre/lustre/obdclass/genops.c
>> @@ -113,15 +113,17 @@ static struct obd_type *class_get_type(const char *name)
>>  		}
>>  	}
>>  	if (type) {
>> -		spin_lock(&type->obd_type_lock);
>> -		type->typ_refcnt++;
>> -		try_module_get(type->typ_dt_ops->owner);
>> -		spin_unlock(&type->obd_type_lock);
>> -		/* class_search_type() returned a counted reference,
>> -		 * but we don't need that count any more as
>> -		 * we have one through typ_refcnt.
>> -		 */
>> -		kobject_put(&type->typ_kobj);
>> +		if (try_module_get(type->typ_dt_ops->owner)) {
>> +			atomic_inc(&type->typ_refcnt);
>> +			/* class_search_type() returned a counted reference,
>> +			 * but we don't need that count any more as
>> +			 * we have one through typ_refcnt.
>> +			 */
>> +			kobject_put(&type->typ_kobj);
>> +		} else {
>> +			kobject_put(&type->typ_kobj);
>> +			type = NULL;
>> +		}
>>  	}
>>  	return type;
>>  }
>> @@ -129,10 +131,7 @@ static struct obd_type *class_get_type(const char *name)
>>  void class_put_type(struct obd_type *type)
>>  {
>>  	LASSERT(type);
>> -	spin_lock(&type->obd_type_lock);
>> -	type->typ_refcnt--;
>> -	module_put(type->typ_dt_ops->owner);
>> -	spin_unlock(&type->obd_type_lock);
>> +	atomic_dec(&type->typ_refcnt);
>>  }
>>  
>>  static void simple_class_release(struct kobject *kobj)
>> @@ -222,7 +221,6 @@ int class_register_type(struct obd_ops *dt_ops, struct md_ops *md_ops,
>>  	/* md_ops is optional */
>>  	if (md_ops)
>>  		*type->typ_md_ops = *md_ops;
>> -	spin_lock_init(&type->obd_type_lock);
>>  
>>  	rc = kobject_add(&type->typ_kobj, &lustre_kset->kobj, "%s", name);
>>  	if (rc)
>> @@ -256,8 +254,8 @@ int class_unregister_type(const char *name)
>>  		return -EINVAL;
>>  	}
>>  
>> -	if (type->typ_refcnt) {
>> -		CERROR("type %s has refcount (%d)\n", name, type->typ_refcnt);
>> +	if (atomic_read(&type->typ_refcnt)) {
>> +		CERROR("type %s has refcount (%d)\n", name, atomic_read(&type->typ_refcnt));
>>  		/* This is a bad situation, let's make the best of it */
>>  		/* Remove ops, but leave the name for debugging */
>>  		kfree(type->typ_dt_ops);
>> diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
>> index 9c872db21040..770cc1b9e40b 100644
>> --- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
>> +++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
>> @@ -1267,7 +1267,7 @@ void lu_stack_fini(const struct lu_env *env, struct lu_device *top)
>>  		next = ldt->ldt_ops->ldto_device_free(env, scan);
>>  		type = ldt->ldt_obd_type;
>>  		if (type) {
>> -			type->typ_refcnt--;
>> +			atomic_dec(&type->typ_refcnt);
>>  			class_put_type(type);
>>  		}
>>  	}
>> 
>> 
>> 
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190325/12b61df9/attachment.sig>
