From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 15 Oct 2015 14:14:19 +0300
Subject: [lustre-devel] staging: add Lustre file system client support
Message-ID: <20151015111419.GA24704@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello Lustre Devs,

The patch d7e09d0397e8: "staging: add Lustre file system client
support" from May 2, 2013, leads to the following static checker
warning:

	drivers/staging/lustre/lnet/selftest/console.c:1330 lstcon_test_add()
	error: 'paramlen' from user is not capped properly

drivers/staging/lustre/lnet/selftest/console.c
  1273  int
  1274  lstcon_test_add(char *batch_name, int type, int loop,
  1275                  int concur, int dist, int span,
  1276                  char *src_name, char *dst_name,
  1277                  void *param, int paramlen, int *retp,
  1278                  struct list_head *result_up)
  1279  {
  1280          lstcon_test_t    *test   = NULL;
  1281          int              rc;
  1282          lstcon_group_t   *src_grp = NULL;
  1283          lstcon_group_t   *dst_grp = NULL;
  1284          lstcon_batch_t   *batch = NULL;
  1285  
  1286          /*
  1287           * verify that a batch of the given name exists, and the groups
  1288           * that will be part of the batch exist and have at least one
  1289           * active node
  1290           */
  1291          rc = lstcon_verify_batch(batch_name, &batch);
  1292          if (rc != 0)
  1293                  goto out;
  1294  
  1295          rc = lstcon_verify_group(src_name, &src_grp);
  1296          if (rc != 0)
  1297                  goto out;
  1298  
  1299          rc = lstcon_verify_group(dst_name, &dst_grp);
  1300          if (rc != 0)
  1301                  goto out;
  1302  
  1303          if (dst_grp->grp_userland)
  1304                  *retp = 1;
  1305  
  1306          LIBCFS_ALLOC(test, offsetof(lstcon_test_t, tes_param[paramlen]));

There is an underflow and integer overflow bug here.

  1307          if (!test) {
  1308                  CERROR("Can't allocate test descriptor\n");
  1309                  rc = -ENOMEM;
  1310  
  1311                  goto out;
  1312          }
  1313  
  1314          test->tes_hdr.tsb_id    = batch->bat_hdr.tsb_id;
  1315          test->tes_batch         = batch;
  1316          test->tes_type          = type;
  1317          test->tes_oneside       = 0; /* TODO */
  1318          test->tes_loop          = loop;
  1319          test->tes_concur        = concur;
  1320          test->tes_stop_onerr    = 1; /* TODO */
  1321          test->tes_span          = span;
  1322          test->tes_dist          = dist;
  1323          test->tes_cliidx        = 0; /* just used for creating RPC */
  1324          test->tes_src_grp       = src_grp;
  1325          test->tes_dst_grp       = dst_grp;
  1326          INIT_LIST_HEAD(&test->tes_trans_list);
  1327  
  1328          if (param != NULL) {
  1329                  test->tes_paramlen = paramlen;
  1330                  memcpy(&test->tes_param[0], param, paramlen);
                               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This is the warning.

  1331          }

The warning here is a false positive because the caller validates
"paramlen" when "param" is non-NULL.  Unfortunately, on line 1306, we
use "paramlen" even when param is NULL.  "paramlen" is signed so this
can mean "test" is smaller than expected leading to memory corruption.

regards,
dan carpenter
