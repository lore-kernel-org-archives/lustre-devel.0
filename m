From: NeilBrown <neilb@suse.com>
Date: Tue, 26 Feb 2019 09:27:34 +1100
Subject: [lustre-devel] [PATCH 02/37] lustre: llite: don't use
 class_setup_tunables()
In-Reply-To: <alpine.LFD.2.21.1902241533350.15750@casper.infradead.org>
References: <155053473693.24125.6976971762921761309.stgit@noble.brown>
 <155053494490.24125.1514109985903155907.stgit@noble.brown>
 <alpine.LFD.2.21.1902241533350.15750@casper.infradead.org>
Message-ID: <874l8rv6zt.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Feb 24 2019, James Simmons wrote:

> y
>> llite_kobj does not benefit from being in the
>> lustre_kset kset (though it does need lustre_kset
>> as a parent)
>
> Nak.
>
> Yes llite does benefit from being in the kset. On large clusters you
> can end up with 1000s of clients so keeping the sysfs files setting 
> in sync needs to be done in mass. The way Lustre does this is by 
> running on the MGS server 'lctl conf_param $FSNAME.llite.lazystats=1'
> or with the newer 'lctl set_param -P llite.$FSNAME-*.lazystats=1' as
> an example. When this is done on the MGS that new value is first
> persistently stored and then transmitted to the target nodes.
>   
> The magic behind this is with class_process_config(). In the code
> path LCFG_PARAM, which handles the conf_param case' the main function
> is class_modify_config() which is used by both llite and the obd
> devices. This function first attempts to find the sysfs attribute
> from the kobject and call lustre_attr_store() directly to set it.
> If it can't find the attribute, which means its a debugfs file
> most likely, then a uevent is created and sent off. The udev rule
> then exexcutes some application to handle the debugfs settings.
> For uevents to work the kobject (llite) must belong to a kset.
>
> With LCFG_SET_PARAM, which handles the 'set_param -P' case the
> master function is process_param2_config(). For this case we
> always send attribute changes with uevents. Besides the requirement
> of the kobject belonging to the kset this function uses 
> kset_find_object() directly which if llite is not in the kset
> will never be found.

Thanks a lot for the explanation - there are definitely things I missed
there.
I'll drop this patch, and keep class_setup_tunables() in the later patch
that removed it.

Thanks,
NeilBrown


>
>> It also does not need the class_ktype type, as dynamic_kobj_ktype
>> is sufficient.
>> 
>> So use the simple kobject_create_and_add() to initialize it.
>> 
>> This provides flexibility for making changes to
>> class_setup_tunables().
>> 
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>  drivers/staging/lustre/lustre/llite/lproc_llite.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/drivers/staging/lustre/lustre/llite/lproc_llite.c b/drivers/staging/lustre/lustre/llite/lproc_llite.c
>> index 8215296dc15d..78ec0fa65c58 100644
>> --- a/drivers/staging/lustre/lustre/llite/lproc_llite.c
>> +++ b/drivers/staging/lustre/lustre/llite/lproc_llite.c
>> @@ -46,7 +46,7 @@ int llite_tunables_register(void)
>>  {
>>  	int rc = 0;
>>  
>> -	llite_kobj = class_setup_tunables("llite");
>> +	llite_kobj = kobject_create_and_add("llite", &lustre_kset->kobj);
>>  	if (IS_ERR(llite_kobj))
>>  		return PTR_ERR(llite_kobj);
>>  
>
>         llite_kobj->kset = kset_get(&lustre_kset);
>> 
>
> In llite_tunables_unregister() the call for kobject_put()
> should really be replaced with kobject_del(). This is a bug
> in my original work. 
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190226/d5010829/attachment.sig>
