From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 6 Dec 2016 14:02:59 +0300
Subject: [lustre-devel] [bug report] staging: add Lustre file system
 client support
In-Reply-To: <C7AE2AE0-89E7-49F6-B7C8-8BCF0F957045@intel.com>
References: <20161123122959.GA17323@mwanda>
	<C7AE2AE0-89E7-49F6-B7C8-8BCF0F957045@intel.com>
Message-ID: <20161206110259.GG8244@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Dec 05, 2016 at 06:43:37PM -0500, Oleg Drokin wrote:
> 
> On Nov 23, 2016, at 7:29 AM, Dan Carpenter wrote:
> 
> > Hi Lustre Devs,
> > 
> > The patch d7e09d0397e8: "staging: add Lustre file system client
> > support" from May 2, 2013, leads to the following static checker
> > warning:
> > 
> > 	drivers/staging/lustre/lnet/selftest/console.c:1336 lstcon_test_add()
> > 	error: 'paramlen' from user is not capped properly
> > 
> > The story here, is that "paramlen" is capped but only if "param" is
> > non-NULL.  This causes a problem.
> > 
> > drivers/staging/lustre/lnet/selftest/console.c
> >  1311  
> >  1312          LIBCFS_ALLOC(test, offsetof(struct lstcon_test, tes_param[paramlen]));
> > 
> > We don't know that paramlen is non-NULL here.  Because of integer
> > overflows we could end up allocating less than intended.
> 
> I think this must be a false positive in this case?
> 
> Before calling this function we do:
>                 LIBCFS_ALLOC(param, args->lstio_tes_param_len);
> 
> in lst_test_add_ioctl(), so it's not any bigger than 128k (or kmalloc will fail).
> Even if kmalloc would allow more than 128k allocations,
> offsetof(struct lstcon_test, tes_param[0]) is bound to be a lot smaller than
> the baseline allocation address for kmalloc, and therefore integer overflow
> cannot happen at all.
> 

I explained badly, and I typed the wrong variable names by mistake...
Here is the relevant code from the caller:

drivers/staging/lustre/lnet/selftest/conctl.c
   710  static int lst_test_add_ioctl(lstio_test_args_t *args)
   711  {
   712          char *batch_name;
   713          char *src_name = NULL;
   714          char *dst_name = NULL;
   715          void *param = NULL;
   716          int ret = 0;
   717          int rc = -ENOMEM;
   718  
   719          if (!args->lstio_tes_resultp ||
   720              !args->lstio_tes_retp ||
   721              !args->lstio_tes_bat_name ||        /* no specified batch */
   722              args->lstio_tes_bat_nmlen <= 0 ||
   723              args->lstio_tes_bat_nmlen > LST_NAME_SIZE ||
   724              !args->lstio_tes_sgrp_name ||       /* no source group */
   725              args->lstio_tes_sgrp_nmlen <= 0 ||
   726              args->lstio_tes_sgrp_nmlen > LST_NAME_SIZE ||
   727              !args->lstio_tes_dgrp_name ||       /* no target group */
   728              args->lstio_tes_dgrp_nmlen <= 0 ||
   729              args->lstio_tes_dgrp_nmlen > LST_NAME_SIZE)
   730                  return -EINVAL;
   731  
   732          if (!args->lstio_tes_loop ||            /* negative is infinite */
   733              args->lstio_tes_concur <= 0 ||
   734              args->lstio_tes_dist <= 0 ||
   735              args->lstio_tes_span <= 0)
   736                  return -EINVAL;
   737  
   738          /* have parameter, check if parameter length is valid */
   739          if (args->lstio_tes_param &&
   740              (args->lstio_tes_param_len <= 0 ||
   741               args->lstio_tes_param_len >
   742               PAGE_SIZE - sizeof(struct lstcon_test)))
   743                  return -EINVAL;

If we don't have a parameter then we don't check ->lstio_tes_param_len.

   744  
   745          LIBCFS_ALLOC(batch_name, args->lstio_tes_bat_nmlen + 1);
   746          if (!batch_name)
   747                  return rc;
   748  
   749          LIBCFS_ALLOC(src_name, args->lstio_tes_sgrp_nmlen + 1);
   750          if (!src_name)
   751                  goto out;
   752  
   753          LIBCFS_ALLOC(dst_name, args->lstio_tes_dgrp_nmlen + 1);
   754          if (!dst_name)
   755                  goto out;
   756  
   757          if (args->lstio_tes_param) {
   758                  LIBCFS_ALLOC(param, args->lstio_tes_param_len);
   759                  if (!param)
   760                          goto out;
   761                  if (copy_from_user(param, args->lstio_tes_param,
   762                                     args->lstio_tes_param_len)) {
   763                          rc = -EFAULT;
   764                          goto out;
   765                  }
   766          }

This is the code that you mentioned.  But we don't have a parameter so
it's not invoked.

   767  
   768          rc = -EFAULT;
   769          if (copy_from_user(batch_name, args->lstio_tes_bat_name,
   770                             args->lstio_tes_bat_nmlen) ||
   771              copy_from_user(src_name, args->lstio_tes_sgrp_name,
   772                             args->lstio_tes_sgrp_nmlen) ||
   773              copy_from_user(dst_name, args->lstio_tes_dgrp_name,
   774                             args->lstio_tes_dgrp_nmlen))
   775                  goto out;
   776  
   777          rc = lstcon_test_add(batch_name, args->lstio_tes_type,
   778                               args->lstio_tes_loop, args->lstio_tes_concur,
   779                               args->lstio_tes_dist, args->lstio_tes_span,
   780                               src_name, dst_name, param,
   781                               args->lstio_tes_param_len,
   782                               &ret, args->lstio_tes_resultp);

Here we are using "args->lstio_tes_param_len" which could be any integer
value.  "param" is NULL.

   783  
   784          if (ret)
   785                  rc = (copy_to_user(args->lstio_tes_retp, &ret,
   786                                     sizeof(ret))) ? -EFAULT : 0;

Now here is the code again from lstcon_test_add():

drivers/staging/lustre/lnet/selftest/console.c
  1279  int
  1280  lstcon_test_add(char *batch_name, int type, int loop,
  1281                  int concur, int dist, int span,
  1282                  char *src_name, char *dst_name,
  1283                  void *param, int paramlen, int *retp,

"param" is NULL and "paramlen" is any integer value.

  1284                  struct list_head __user *result_up)
  1285  {
  1286          struct lstcon_test *test = NULL;
  1287          int rc;
  1288          struct lstcon_group *src_grp = NULL;
  1289          struct lstcon_group *dst_grp = NULL;
  1290          struct lstcon_batch *batch = NULL;
  1291  
  1292          /*
  1293           * verify that a batch of the given name exists, and the groups
  1294           * that will be part of the batch exist and have at least one
  1295           * active node
  1296           */
  1297          rc = lstcon_verify_batch(batch_name, &batch);
  1298          if (rc)
  1299                  goto out;
  1300  
  1301          rc = lstcon_verify_group(src_name, &src_grp);
  1302          if (rc)
  1303                  goto out;
  1304  
  1305          rc = lstcon_verify_group(dst_name, &dst_grp);
  1306          if (rc)
  1307                  goto out;
  1308  
  1309          if (dst_grp->grp_userland)
  1310                  *retp = 1;
  1311  
  1312          LIBCFS_ALLOC(test, offsetof(struct lstcon_test, tes_param[paramlen]));


If you pass "paramlen" as -4 then it will corrupt four bytes beyond the
end of what we allocated.  We could pass paramlen = -108 and it would
return ZERO_SIZE_PTR (0x16) and oops.

  1313          if (!test) {
  1314                  CERROR("Can't allocate test descriptor\n");
  1315                  rc = -ENOMEM;
  1316  
  1317                  goto out;
  1318          }
  1319  
  1320          test->tes_hdr.tsb_id = batch->bat_hdr.tsb_id;
  1321          test->tes_batch = batch;
  1322          test->tes_type = type;
  1323          test->tes_oneside = 0; /* TODO */
  1324          test->tes_loop = loop;
  1325          test->tes_concur = concur;
  1326          test->tes_stop_onerr = 1; /* TODO */
  1327          test->tes_span = span;
  1328          test->tes_dist = dist;
  1329          test->tes_cliidx = 0; /* just used for creating RPC */
  1330          test->tes_src_grp = src_grp;
  1331          test->tes_dst_grp = dst_grp;
  1332          INIT_LIST_HEAD(&test->tes_trans_list);
  1333  

regards,
dan carpenter
