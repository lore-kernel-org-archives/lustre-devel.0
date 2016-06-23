From: Lidza Louina <lidza.louina@oracle.com>
Date: Thu, 23 Jun 2016 11:30:44 -0700 (PDT)
Subject: [lustre-devel] [PATCH] staging/lustre/lnet: correctly casts
 value for arithmetic
Message-ID: <18d59750-e77c-4443-bdb5-d48066a4303a@default>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


----- Original Message -----
From: oleg.drokin@intel.com
To: lidza.louina at oracle.com
Cc: devel at driverdev.osuosl.org, andreas.dilger at intel.com, lustre-devel at lists.lustre.org, gregkh at linuxfoundation.org
Sent: Thursday, June 23, 2016 11:11:06 AM GMT -08:00 US/Canada Pacific
Subject: Re: [lustre-devel] [PATCH] staging/lustre/lnet: correctly casts value for arithmetic


On Jun 23, 2016, at 2:07 PM, Lidza Louina wrote:

> The smatch warning was "drivers/staging/lustre/lnet/lnet/api-ni.c:516 
> lnet_res_lh_initialize() warn: should '1 << ibits' be a 64 bit type?"

I think you misinterpreted it, it has nothing to do with the addition.

What it actually means is:
1 is a 32bit integer, you do a right shift by some variable number
of bits. So please check if there's risk to overflow the 32 bits
unexpectedly.
The way to fix this warning is to replace 1 with 1ULL (unsigned long long)
and that is fine to do as a way of future proofing this stuff even if it's
not yet broken yet, I guess.

Ahh, okay, I see what you're saying and I see what I did wrong.

I'm going to update the patch to:

-        rec->rec_lh_cookie += 1 << ibits;
+        rec->rec_lh_cookie += (1ULL << ibits);

Lidza

> 
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
