From: kbuild test robot <lkp@intel.com>
Date: Sat, 17 Oct 2015 09:55:01 +0800
Subject: [lustre-devel] [PATCH 4/4] staging: lustre: remove IS_PO2 and
	__is_po2
In-Reply-To: <97ba103dc2a11e23fd4a384eb041c273b67a9aee.1445032901.git.mahfouz.saif.elyazal@gmail.com>
Message-ID: <201510170920.6EL2elzP%fengguang.wu@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Aya,

[auto build test ERROR on staging/staging-next -- if it's inappropriate base, please suggest rules for selecting the more suitable base]

url:    https://github.com/0day-ci/linux/commits/Aya-Mahfouz/Remove-uses-and-definition-of-IS_PO2/20151017-060923
config: i386-allyesconfig (attached as .config)
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

All errors (new ones prefixed by >>):

   drivers/staging/lustre/lnet/selftest/conrpc.c: In function 'lstcon_rpc_cleanup_wait':
>> drivers/staging/lustre/lnet/selftest/conrpc.c:1359:386: error: implicit declaration of function 'IS_PO2' [-Werror=implicit-function-declaration]
   cc1: some warnings being treated as errors
--
   drivers/staging/lustre/lnet/selftest/framework.c: In function 'sfw_shutdown':
>> drivers/staging/lustre/lnet/selftest/framework.c:1741:386: error: implicit declaration of function 'IS_PO2' [-Werror=implicit-function-declaration]
   cc1: some warnings being treated as errors
--
   drivers/staging/lustre/lnet/selftest/timer.c: In function 'stt_shutdown':
>> drivers/staging/lustre/lnet/selftest/timer.c:240:386: error: implicit declaration of function 'IS_PO2' [-Werror=implicit-function-declaration]
   cc1: some warnings being treated as errors
--
   drivers/staging/lustre/lnet/selftest/rpc.c: In function 'srpc_service_add_buffers':
>> drivers/staging/lustre/lnet/selftest/rpc.c:619:387: error: implicit declaration of function 'IS_PO2' [-Werror=implicit-function-declaration]
   cc1: some warnings being treated as errors

vim +/IS_PO2 +1359 drivers/staging/lustre/lnet/selftest/conrpc.c

d7e09d039 Peng Tao       2013-05-02  1353  
d7e09d039 Peng Tao       2013-05-02  1354  		mutex_lock(&console_session.ses_mutex);
d7e09d039 Peng Tao       2013-05-02  1355  	}
d7e09d039 Peng Tao       2013-05-02  1356  
d7e09d039 Peng Tao       2013-05-02  1357  	spin_lock(&console_session.ses_rpc_lock);
d7e09d039 Peng Tao       2013-05-02  1358  
d7e09d039 Peng Tao       2013-05-02 @1359  	lst_wait_until((atomic_read(&console_session.ses_rpc_counter) == 0),
d7e09d039 Peng Tao       2013-05-02  1360  		       console_session.ses_rpc_lock,
eac2e8c6f Rashika Kheria 2013-10-17  1361  		       "Network is not accessible or target is down, waiting for %d console RPCs to being recycled\n",
d7e09d039 Peng Tao       2013-05-02  1362  		       atomic_read(&console_session.ses_rpc_counter));

:::::: The code at line 1359 was first introduced by commit
:::::: d7e09d0397e84eefbabfd9cb353221f3c6448d83 staging: add Lustre file system client support

:::::: TO: Peng Tao <bergwolf@gmail.com>
:::::: CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
-------------- next part --------------
A non-text attachment was scrubbed...
Name: .config.gz
Type: application/octet-stream
Size: 51116 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20151017/f53c46c0/attachment-0001.obj>
