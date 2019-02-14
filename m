From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Feb 2019 14:43:52 +1100
Subject: [lustre-devel] [PATCH 19/21] lustre: obdclass: avoid races in
 class_register_type()
In-Reply-To: <alpine.LFD.2.21.1902120435450.3631@casper.infradead.org>
References: <154949776249.10620.1215070753973826063.stgit@noble.brown>
 <154949781342.10620.11880180011933935219.stgit@noble.brown>
 <alpine.LFD.2.21.1902120435450.3631@casper.infradead.org>
Message-ID: <87y36jdog7.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Feb 12 2019, James Simmons wrote:

>> If there are two parallel attempts to register the
>> same class name, it could get registered twice.
>> So re-check after allocation to make sure the name is
>> still unique.
>> 
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>  drivers/staging/lustre/lustre/obdclass/genops.c |   29 +++++++++++++++--------
>>  1 file changed, 19 insertions(+), 10 deletions(-)
>> 
>> diff --git a/drivers/staging/lustre/lustre/obdclass/genops.c b/drivers/staging/lustre/lustre/obdclass/genops.c
>> index 382eaf519a79..a174f538dd0d 100644
>> --- a/drivers/staging/lustre/lustre/obdclass/genops.c
>> +++ b/drivers/staging/lustre/lustre/obdclass/genops.c
>> @@ -86,17 +86,23 @@ static void obd_device_free(struct obd_device *obd)
>>  	kmem_cache_free(obd_device_cachep, obd);
>>  }
>>  
>> -static struct obd_type *class_search_type(const char *name)
>> +static struct obd_type *__class_search_type(const char *name)
>>  {
>>  	struct obd_type *type;
>>  
>> -	spin_lock(&obd_types_lock);
>>  	list_for_each_entry(type, &obd_types, typ_chain) {
>
> This change is fine but we really don't need typ_chain anymore.
> We have a list of obd_types already due to the power of kobjects!!!!
>
> We can do an
>
> static struct obd_type *class_search_type(const char *name)
> {
> 	struct kobject *kobj;
> 	struct obd_type *type;
>
> 	kobj = kset_find_obj(lustre_kset, name);
>
> 	return "some_mapping from kobj to type"
>
> Hmm. This kobj is not embedded in struct obd_types. Might need more
> surgery to make that work.
>

Well.... that was a fun rabbit-hole to fall down.
I now have 8 patches where before I had two - definitely a better
result. typ_chain and several other fields are gone.

I'll post them in my next series which will probably go out tomorrow.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190214/1bf34af3/attachment.sig>
