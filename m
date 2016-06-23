From: Lidza Louina <lidza.louina@oracle.com>
Date: Thu, 23 Jun 2016 14:03:51 -0700 (PDT)
Subject: [lustre-devel] [PATCH v2] staging/lustre/lnet: changes value to
 correct type for assignment
Message-ID: <d5a781a4-d91a-478a-91d3-81309f83f8a6@default>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


----- Original Message -----
From: oleg.drokin@intel.com
To: lidza.louina at oracle.com
Cc: devel at driverdev.osuosl.org, gregkh at linuxfoundation.org, lustre-devel at lists.lustre.org
Sent: Thursday, June 23, 2016 12:50:01 PM GMT -08:00 US/Canada Pacific
Subject: Re: [lustre-devel] [PATCH v2] staging/lustre/lnet: changes value to correct type for assignment


On Jun 23, 2016, at 3:27 PM, Lidza Louina wrote:

> 
> ----- Original Message -----
> From: oleg.drokin at intel.com
> To: lidza.louina at oracle.com
> Cc: gregkh at linuxfoundation.org, lustre-devel at lists.lustre.org, devel at driverdev.osuosl.org, andreas.dilger at intel.com
> Sent: Thursday, June 23, 2016 12:14:28 PM GMT -08:00 US/Canada Pacific
> Subject: Re: [lustre-devel] [PATCH v2] staging/lustre/lnet: changes value to correct type for assignment
> 
> 
> On Jun 23, 2016, at 2:56 PM, Lidza Louina wrote:
> 
>> The code attempted to add an unsigned int to a an unsigned 64-bit
>> integer. This patch makes the code use the correct type of int to
>> suppress a smatch warning.
> 
> I think you might want to update the commit message too, because
> it does not really make much sense now.
> 
> How about
> 
> "The patch changes a value's type so it can be assigned correctly. 
> This problem was caught by smatch."

I think that still does not convey the idea of teh change, also there's no
assignment going on here.
Perhaps
To make the shift safer, have it operate on a 64 bit integer instead of
default 32bit?
There's no bug yet, so this is just for future-proofing.
This potential problem was caught by smatch.

Also you'll need to update the patch subject.


I didn't want to copy you word-for-word:

[PATCH v3] staging/lustre/lnet: changes type for safer shift

The shift was potentially unsafe because of conflicting types. 

This patch changes the regular int (1) to an unsigned long long int because 
rec->rec_lh_cookie is an unsigned 64-bit value. This could be a problem down
the line. 

This was caught by smatch.


> 
>> 
>> Signed-off-by: Lidza Louina <lidza.louina@oracle.com>
>> ---
>> drivers/staging/lustre/lnet/lnet/api-ni.c | 2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
>> index 346db89..fc5b763 100644
>> --- a/drivers/staging/lustre/lnet/lnet/api-ni.c
>> +++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
>> @@ -513,7 +513,7 @@ lnet_res_lh_initialize(struct lnet_res_container *rec, lnet_libhandle_t *lh)
>> 	unsigned int hash;
>> 
>> 	lh->lh_cookie = rec->rec_lh_cookie;
>> -	rec->rec_lh_cookie += 1 << ibits;
>> +	rec->rec_lh_cookie += (1ULL << ibits);
>> 
>> 	hash = (lh->lh_cookie >> ibits) & LNET_LH_HASH_MASK;
>> 
>> -- 
>> 1.9.1
>> 
>> 
>> 
>> _______________________________________________
>> lustre-devel mailing list
>> lustre-devel at lists.lustre.org
>> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
> 
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
