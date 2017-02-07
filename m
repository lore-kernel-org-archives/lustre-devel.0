From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 7 Feb 2017 15:22:44 +0300
Subject: [lustre-devel] [bug report] staging: lustre: lmv: Error not handled
 for lmv_find_target
Message-ID: <20170207122243.GA23469@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello Ulka Vaze,

You didn't introduce this warning but you were fixing nearby code so you
might know the answer.

	drivers/staging/lustre/lustre/lmv/lmv_obd.c:1069 lmv_iocontrol()
	warn: check 'reqlen' for integer overflows 'obd_iocontrol()'

drivers/staging/lustre/lustre/lmv/lmv_obd.c
  1056  
  1057                                  /* build a request with fids for this MDS */
  1058                                  reqlen = offsetof(typeof(*hur),
  1059                                                    hur_user_item[nr])
  1060                                           + hur->hur_request.hr_data_len;

It looks like this addition can have an integer overflow bug.

  1061                                  req = libcfs_kvzalloc(reqlen, GFP_NOFS);

Leading to a req that is smaller than necessary.

  1062                                  if (!req)
  1063                                          return -ENOMEM;
  1064  
  1065                                  rc1 = lmv_hsm_req_build(lmv, hur, tgt, req);

Which could be a problem in here.

  1066                                  if (rc1 < 0)
  1067                                          goto hsm_req_err;
  1068  
  1069                                  rc1 = obd_iocontrol(cmd, tgt->ltd_exp, reqlen,
  1070                                                      req, uarg);
  1071  hsm_req_err:
  1072                                  if (rc1 != 0 && rc == 0)
  1073                                          rc = rc1;
  1074                                  kvfree(req);

regards,
dan carpenter
