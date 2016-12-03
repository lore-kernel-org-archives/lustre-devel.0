From: kbuild test robot <lkp@intel.com>
Date: Sat, 3 Dec 2016 21:27:31 +0800
Subject: [lustre-devel] [PATCH 3/6] staging: lustre: obdclass: Create a
 header for obdo related functions
In-Reply-To: <1480707650-24089-4-git-send-email-jsimmons@infradead.org>
Message-ID: <201612032108.E93gbaZn%fengguang.wu@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Ben,

[auto build test ERROR on staging/staging-testing]
[also build test ERROR on next-20161202]
[cannot apply to v4.9-rc7]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/James-Simmons/Fix-ups-to-make-lustre_idl-h-a-proper-UAPI-header/20161203-112301
config: s390-allmodconfig (attached as .config)
compiler: s390x-linux-gnu-gcc (Debian 6.1.1-9) 6.1.1 20160705
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=s390 

Note: the linux-review/James-Simmons/Fix-ups-to-make-lustre_idl-h-a-proper-UAPI-header/20161203-112301 HEAD c2346c2b941862f21c17e2c11dfd2ed0e66f72ea builds fine.
      It only hurts bisectibility.

All errors (new ones prefixed by >>):

   drivers/staging/lustre/lustre/osc/osc_request.c: In function 'osc_pack_req_body':
>> drivers/staging/lustre/lustre/osc/osc_request.c:114:2: error: implicit declaration of function 'lustre_set_wire_obdo' [-Werror=implicit-function-declaration]
     lustre_set_wire_obdo(&req->rq_import->imp_connect_data, &body->oa, oa);
     ^~~~~~~~~~~~~~~~~~~~
   drivers/staging/lustre/lustre/osc/osc_request.c: In function 'osc_getattr':
>> drivers/staging/lustre/lustre/osc/osc_request.c:149:2: error: implicit declaration of function 'lustre_get_wire_obdo' [-Werror=implicit-function-declaration]
     lustre_get_wire_obdo(&req->rq_import->imp_connect_data, oa,
     ^~~~~~~~~~~~~~~~~~~~
   cc1: some warnings being treated as errors

vim +/lustre_set_wire_obdo +114 drivers/staging/lustre/lustre/osc/osc_request.c

d7e09d039 Peng Tao           2013-05-02  108  {
d7e09d039 Peng Tao           2013-05-02  109  	struct ost_body *body;
d7e09d039 Peng Tao           2013-05-02  110  
d7e09d039 Peng Tao           2013-05-02  111  	body = req_capsule_client_get(&req->rq_pill, &RMF_OST_BODY);
d7e09d039 Peng Tao           2013-05-02  112  	LASSERT(body);
d7e09d039 Peng Tao           2013-05-02  113  
48a2a12af John L. Hammond    2016-10-02 @114  	lustre_set_wire_obdo(&req->rq_import->imp_connect_data, &body->oa, oa);
d7e09d039 Peng Tao           2013-05-02  115  }
d7e09d039 Peng Tao           2013-05-02  116  
d7e09d039 Peng Tao           2013-05-02  117  static int osc_getattr(const struct lu_env *env, struct obd_export *exp,
48a2a12af John L. Hammond    2016-10-02  118  		       struct obdo *oa)
d7e09d039 Peng Tao           2013-05-02  119  {
d7e09d039 Peng Tao           2013-05-02  120  	struct ptlrpc_request *req;
d7e09d039 Peng Tao           2013-05-02  121  	struct ost_body *body;
d7e09d039 Peng Tao           2013-05-02  122  	int rc;
d7e09d039 Peng Tao           2013-05-02  123  
d7e09d039 Peng Tao           2013-05-02  124  	req = ptlrpc_request_alloc(class_exp2cliimp(exp), &RQF_OST_GETATTR);
7f1ae4c06 Oleg Drokin        2016-02-16  125  	if (!req)
0a3bdb007 Greg Kroah-Hartman 2013-08-03  126  		return -ENOMEM;
d7e09d039 Peng Tao           2013-05-02  127  
d7e09d039 Peng Tao           2013-05-02  128  	rc = ptlrpc_request_pack(req, LUSTRE_OST_VERSION, OST_GETATTR);
d7e09d039 Peng Tao           2013-05-02  129  	if (rc) {
d7e09d039 Peng Tao           2013-05-02  130  		ptlrpc_request_free(req);
0a3bdb007 Greg Kroah-Hartman 2013-08-03  131  		return rc;
d7e09d039 Peng Tao           2013-05-02  132  	}
d7e09d039 Peng Tao           2013-05-02  133  
48a2a12af John L. Hammond    2016-10-02  134  	osc_pack_req_body(req, oa);
d7e09d039 Peng Tao           2013-05-02  135  
d7e09d039 Peng Tao           2013-05-02  136  	ptlrpc_request_set_replen(req);
d7e09d039 Peng Tao           2013-05-02  137  
d7e09d039 Peng Tao           2013-05-02  138  	rc = ptlrpc_queue_wait(req);
d7e09d039 Peng Tao           2013-05-02  139  	if (rc)
26c4ea46a Tina Johnson       2014-09-21  140  		goto out;
d7e09d039 Peng Tao           2013-05-02  141  
d7e09d039 Peng Tao           2013-05-02  142  	body = req_capsule_server_get(&req->rq_pill, &RMF_OST_BODY);
7f1ae4c06 Oleg Drokin        2016-02-16  143  	if (!body) {
26c4ea46a Tina Johnson       2014-09-21  144  		rc = -EPROTO;
26c4ea46a Tina Johnson       2014-09-21  145  		goto out;
26c4ea46a Tina Johnson       2014-09-21  146  	}
d7e09d039 Peng Tao           2013-05-02  147  
d7e09d039 Peng Tao           2013-05-02  148  	CDEBUG(D_INODE, "mode: %o\n", body->oa.o_mode);
48a2a12af John L. Hammond    2016-10-02 @149  	lustre_get_wire_obdo(&req->rq_import->imp_connect_data, oa,
3b2f75fd5 wang di            2013-06-03  150  			     &body->oa);
d7e09d039 Peng Tao           2013-05-02  151  
48a2a12af John L. Hammond    2016-10-02  152  	oa->o_blksize = cli_brw_size(exp->exp_obd);

:::::: The code at line 114 was first introduced by commit
:::::: 48a2a12afc54aa1ebfdb1e821fc3dc7893816986 staging: lustre: osc: remove remaining bits for capa support

:::::: TO: John L. Hammond <john.hammond@intel.com>
:::::: CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
-------------- next part --------------
A non-text attachment was scrubbed...
Name: .config.gz
Type: application/gzip
Size: 43289 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20161203/a4be8ad5/attachment-0001.bin>
