From: Oleg Drokin <oleg.drokin@intel.com>
Date: Tue, 6 Dec 2016 10:44:54 -0500
Subject: [lustre-devel] [bug report] staging: add Lustre file system
	client support
In-Reply-To: <20161206110259.GG8244@mwanda>
References: <20161123122959.GA17323@mwanda>
	<C7AE2AE0-89E7-49F6-B7C8-8BCF0F957045@intel.com>
	<20161206110259.GG8244@mwanda>
Message-ID: <44BA9680-2A0D-49E2-B073-1AA664E8328C@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Dec 6, 2016, at 6:02 AM, Dan Carpenter wrote:

> On Mon, Dec 05, 2016 at 06:43:37PM -0500, Oleg Drokin wrote:
>> 
>> On Nov 23, 2016, at 7:29 AM, Dan Carpenter wrote:
>> 
>>> Hi Lustre Devs,
>>> 
>>> The patch d7e09d0397e8: "staging: add Lustre file system client
>>> support" from May 2, 2013, leads to the following static checker
>>> warning:
>>> 
>>> 	drivers/staging/lustre/lnet/selftest/console.c:1336 lstcon_test_add()
>>> 	error: 'paramlen' from user is not capped properly
>>> 
>>> The story here, is that "paramlen" is capped but only if "param" is
>>> non-NULL.  This causes a problem.
>>> 
>>> drivers/staging/lustre/lnet/selftest/console.c
>>> 1311  
>>> 1312          LIBCFS_ALLOC(test, offsetof(struct lstcon_test, tes_param[paramlen]));
>>> 
>>> We don't know that paramlen is non-NULL here.  Because of integer
>>> overflows we could end up allocating less than intended.
>> 
>> I think this must be a false positive in this case?
>> 
>> Before calling this function we do:
>>                LIBCFS_ALLOC(param, args->lstio_tes_param_len);
>> 
>> in lst_test_add_ioctl(), so it's not any bigger than 128k (or kmalloc will fail).
>> Even if kmalloc would allow more than 128k allocations,
>> offsetof(struct lstcon_test, tes_param[0]) is bound to be a lot smaller than
>> the baseline allocation address for kmalloc, and therefore integer overflow
>> cannot happen at all.
>> 
> 
> I explained badly, and I typed the wrong variable names by mistake...
> Here is the relevant code from the caller:
> 
> drivers/staging/lustre/lnet/selftest/conctl.c
>   710  static int lst_test_add_ioctl(lstio_test_args_t *args)
>   711  {
>   712          char *batch_name;
>   713          char *src_name = NULL;
>   714          char *dst_name = NULL;
>   715          void *param = NULL;
>   716          int ret = 0;
>   717          int rc = -ENOMEM;
>   718  
>   719          if (!args->lstio_tes_resultp ||
>   720              !args->lstio_tes_retp ||
>   721              !args->lstio_tes_bat_name ||        /* no specified batch */
>   722              args->lstio_tes_bat_nmlen <= 0 ||
>   723              args->lstio_tes_bat_nmlen > LST_NAME_SIZE ||
>   724              !args->lstio_tes_sgrp_name ||       /* no source group */
>   725              args->lstio_tes_sgrp_nmlen <= 0 ||
>   726              args->lstio_tes_sgrp_nmlen > LST_NAME_SIZE ||
>   727              !args->lstio_tes_dgrp_name ||       /* no target group */
>   728              args->lstio_tes_dgrp_nmlen <= 0 ||
>   729              args->lstio_tes_dgrp_nmlen > LST_NAME_SIZE)
>   730                  return -EINVAL;
>   731  
>   732          if (!args->lstio_tes_loop ||            /* negative is infinite */
>   733              args->lstio_tes_concur <= 0 ||
>   734              args->lstio_tes_dist <= 0 ||
>   735              args->lstio_tes_span <= 0)
>   736                  return -EINVAL;
>   737  
>   738          /* have parameter, check if parameter length is valid */
>   739          if (args->lstio_tes_param &&
>   740              (args->lstio_tes_param_len <= 0 ||
>   741               args->lstio_tes_param_len >
>   742               PAGE_SIZE - sizeof(struct lstcon_test)))
>   743                  return -EINVAL;
> 
> If we don't have a parameter then we don't check ->lstio_tes_param_len.

I see, indeed, it all makes sense now.
So basically if we unconditionally check for the size to be > 0, we should be
fine then, I imagine.
On the other hand there's probably no se for no param and nonzero param len,
so it's probably even better to enforce size as zero when no param.

Thank you.
