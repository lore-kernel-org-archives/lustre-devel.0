From: Oleg Drokin <oleg.drokin@intel.com>
Date: Thu, 23 Jun 2016 14:10:59 -0400
Subject: [lustre-devel] [PATCH] staging/lustre/lnet: correctly casts
	value for arithmetic
In-Reply-To: <db0de3d1-1ae3-4121-9a59-36fe5619caea@default>
References: <db0de3d1-1ae3-4121-9a59-36fe5619caea@default>
Message-ID: <FA4B3E72-1FA1-43DF-B8BF-E2718B0EA3DF@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


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
