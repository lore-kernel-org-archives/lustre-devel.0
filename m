From: NeilBrown <neilb@suse.com>
Date: Tue, 27 Nov 2018 13:32:48 +1100
Subject: [lustre-devel] [PATCH 6/9] lustre: obdclass: health_check to
 report unhealthy upon LBUG
In-Reply-To: <alpine.LFD.2.21.1811260146120.32255@casper.infradead.org>
References: <154295730810.2850.961218355189474016.stgit@noble>
 <154295732803.2850.16198081335816276527.stgit@noble>
 <alpine.LFD.2.21.1811260146120.32255@casper.infradead.org>
Message-ID: <878t1fqmgf.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Nov 26 2018, James Simmons wrote:

>> From: Bruno Faccini <bruno.faccini@intel.com>
>> 
>> When a LBUG has occurred, without panic_on_lbug being set, health_check
>> /proc file must return an unhealthy state.
>
> I pushed this one to Greg which was disliked since it breaks the one item 
> per sysfs rule. See 
>
> https://lore.kernel.org/patchwork/patch/755571
>
> I did start a proper port to sysfs at 
> https://review.whamcloud.com/#/c/25631
>
> but it needs to be updated. I do like Andreas idea of a sysfs and debugfs
> file since lctl get_param will return the results from both together.
> We could land it as is and update the sysfs handling at a latter date 
> (shouldn't be too far down the road). Here is my review in case you want
> to land it.
>
> Reviewed-by: James Simmons <jsimmons@infradead.org>
>

Thanks, but the patch as it stands it totally broken - I add code
immediately after a 'return'. :-(

I'll just discard this patch.

Thanks,
NeilBrown


>> Signed-off-by: Bruno Faccini <bruno.faccini@intel.com>
>> WC-bug-id: https://jira.whamcloud.com/browse/LU-7486
>> Reviewed-on: http://review.whamcloud.com/17981
>> Reviewed-by: Bobi Jam <bobijam@hotmail.com>
>> Reviewed-by: Niu Yawei <yawei.niu@intel.com>
>> Reviewed-by: James Simmons <uja.ornl@yahoo.com>
>> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>  drivers/staging/lustre/lustre/obdclass/obd_sysfs.c |    4 +++-
>>  1 file changed, 3 insertions(+), 1 deletion(-)
>> 
>> diff --git a/drivers/staging/lustre/lustre/obdclass/obd_sysfs.c b/drivers/staging/lustre/lustre/obdclass/obd_sysfs.c
>> index 6669c235dd51..5fd30a8e2b44 100644
>> --- a/drivers/staging/lustre/lustre/obdclass/obd_sysfs.c
>> +++ b/drivers/staging/lustre/lustre/obdclass/obd_sysfs.c
>> @@ -173,8 +173,10 @@ health_check_show(struct kobject *kobj, struct attribute *attr, char *buf)
>>  	int i;
>>  	size_t len = 0;
>>  
>> -	if (libcfs_catastrophe)
>> +	if (libcfs_catastrophe) {
>>  		return sprintf(buf, "LBUG\n");
>> +		healthy = false;
>> +	}
>>  
>>  	read_lock(&obd_dev_lock);
>>  	for (i = 0; i < class_devno_max(); i++) {
>> 
>> 
>> 
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181127/a713a21f/attachment.sig>
