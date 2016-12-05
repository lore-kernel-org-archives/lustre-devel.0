From: Oleg Drokin <oleg.drokin@intel.com>
Date: Mon, 5 Dec 2016 18:43:37 -0500
Subject: [lustre-devel] [bug report] staging: add Lustre file system
	client support
In-Reply-To: <20161123122959.GA17323@mwanda>
References: <20161123122959.GA17323@mwanda>
Message-ID: <C7AE2AE0-89E7-49F6-B7C8-8BCF0F957045@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Nov 23, 2016, at 7:29 AM, Dan Carpenter wrote:

> Hi Lustre Devs,
> 
> The patch d7e09d0397e8: "staging: add Lustre file system client
> support" from May 2, 2013, leads to the following static checker
> warning:
> 
> 	drivers/staging/lustre/lnet/selftest/console.c:1336 lstcon_test_add()
> 	error: 'paramlen' from user is not capped properly
> 
> The story here, is that "paramlen" is capped but only if "param" is
> non-NULL.  This causes a problem.
> 
> drivers/staging/lustre/lnet/selftest/console.c
>  1311  
>  1312          LIBCFS_ALLOC(test, offsetof(struct lstcon_test, tes_param[paramlen]));
> 
> We don't know that paramlen is non-NULL here.  Because of integer
> overflows we could end up allocating less than intended.

I think this must be a false positive in this case?

Before calling this function we do:
                LIBCFS_ALLOC(param, args->lstio_tes_param_len);

in lst_test_add_ioctl(), so it's not any bigger than 128k (or kmalloc will fail).
Even if kmalloc would allow more than 128k allocations,
offsetof(struct lstcon_test, tes_param[0]) is bound to be a lot smaller than
the baseline allocation address for kmalloc, and therefore integer overflow
cannot happen at all.

> 
>  1313          if (!test) {
>  1314                  CERROR("Can't allocate test descriptor\n");
>  1315                  rc = -ENOMEM;
>  1316  
>  1317                  goto out;
>  1318          }
>  1319  
>  1320          test->tes_hdr.tsb_id = batch->bat_hdr.tsb_id;
> 
> Which will lead to memory corruption when we use "test".
> 
>  1321          test->tes_batch = batch;
>  1322          test->tes_type = type;
>  1323          test->tes_oneside = 0; /* TODO */
>  1324          test->tes_loop = loop;
>  1325          test->tes_concur = concur;
>  1326          test->tes_stop_onerr = 1; /* TODO */
>  1327          test->tes_span = span;
>  1328          test->tes_dist = dist;
>  1329          test->tes_cliidx = 0; /* just used for creating RPC */
>  1330          test->tes_src_grp = src_grp;
>  1331          test->tes_dst_grp = dst_grp;
>  1332          INIT_LIST_HEAD(&test->tes_trans_list);
>  1333  
>  1334          if (param) {
> 
> Smatch is not smart enough to trace the implication that "'param' is
> non-NULL, means that 'paramlen' has been verified" across a function
> boundary.  Storing that sort of information would really increase the
> hardware requirements for running Smatch so it's not something I have
> planned currently.
> 
>  1335                  test->tes_paramlen = paramlen;
>  1336                  memcpy(&test->tes_param[0], param, paramlen);
>  1337          }
>  1338  
> 
> regards,
> dan carpenter
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
