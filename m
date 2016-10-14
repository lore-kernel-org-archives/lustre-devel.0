From: Martin Hecht <hecht@hlrs.de>
Date: Fri, 14 Oct 2016 12:36:25 +0200
Subject: [lustre-devel] [patch] Staging: lustre: indent an if statement
In-Reply-To: <alpine.LFD.2.20.1610132338200.18218@casper.infradead.org>
References: <20161013085202.GE16198@mwanda>
	<alpine.LFD.2.20.1610132338200.18218@casper.infradead.org>
Message-ID: <3ea7f15f-4f53-c303-3c38-064432cb599c@hlrs.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 10/14/2016 12:38 AM, James Simmons wrote:
>> This if statement wasn't intended.
just to be sure: in conjunction with the subject of the mail this should
read "indented" instead of "intended", right?
- otherwise this would result in a slightly different patch...


> Acked-by: James Simmons <jsimmons@infradead.org>
>  
>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>>
>> diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
>> index 3199dd4..a102c36 100644
>> --- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
>> +++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
>> @@ -335,7 +335,7 @@ int cl_object_getstripe(const struct lu_env *env, struct cl_object *obj,
>>  		if (obj->co_ops->coo_getstripe) {
>>  			result = obj->co_ops->coo_getstripe(env, obj, uarg);
>>  			if (result)
>> -			break;
>> +				break;
>>  		}
>>  	}
>>  	return result;
>>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org


-------------- next part --------------
A non-text attachment was scrubbed...
Name: smime.p7s
Type: application/pkcs7-signature
Size: 2252 bytes
Desc: S/MIME Cryptographic Signature
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20161014/2f94191f/attachment.bin>
