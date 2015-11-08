From: kbuild test robot <lkp@intel.com>
Date: Mon, 9 Nov 2015 01:19:18 +0800
Subject: [lustre-devel] [PATCH] staging: lustre: lproc_mgc: Remove
 unused function mgc_ir_state_seq_show
In-Reply-To: <1447002226-4462-1-git-send-email-shivanib134@gmail.com>
Message-ID: <201511090116.LH4z1Lh1%fengguang.wu@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Shivani,

[auto build test ERROR on: staging/staging-testing]
[also build test ERROR on: next-20151106]
[cannot apply to: v4.3]

url:    https://github.com/0day-ci/linux/commits/Shivani-Bhardwaj/staging-lustre-lproc_mgc-Remove-unused-function-mgc_ir_state_seq_show/20151109-010718
config: x86_64-allyesconfig (attached as .config)
reproduce:
        # save the attached .config to linux build tree
        make ARCH=x86_64 

All error/warnings (new ones prefixed by >>):

   In file included from drivers/staging/lustre/lustre/mgc/../include/obd_support.h:43:0,
                    from drivers/staging/lustre/lustre/mgc/../include/obd_class.h:39,
                    from drivers/staging/lustre/lustre/mgc/lproc_mgc.c:39:
   drivers/staging/lustre/lustre/mgc/lproc_mgc.c: In function 'mgc_ir_state_single_open':
>> drivers/staging/lustre/lustre/mgc/lproc_mgc.c:51:19: error: 'mgc_ir_state_seq_show' undeclared (first use in this function)
    LPROC_SEQ_FOPS_RO(mgc_ir_state);
                      ^
   drivers/staging/lustre/lustre/mgc/../include/lprocfs_status.h:634:27: note: in definition of macro '__LPROC_SEQ_FOPS'
     return single_open(file, name##_seq_show, inode->i_private); \
                              ^
>> drivers/staging/lustre/lustre/mgc/lproc_mgc.c:51:1: note: in expansion of macro 'LPROC_SEQ_FOPS_RO'
    LPROC_SEQ_FOPS_RO(mgc_ir_state);
    ^
   drivers/staging/lustre/lustre/mgc/lproc_mgc.c:51:19: note: each undeclared identifier is reported only once for each function it appears in
    LPROC_SEQ_FOPS_RO(mgc_ir_state);
                      ^
   drivers/staging/lustre/lustre/mgc/../include/lprocfs_status.h:634:27: note: in definition of macro '__LPROC_SEQ_FOPS'
     return single_open(file, name##_seq_show, inode->i_private); \
                              ^
>> drivers/staging/lustre/lustre/mgc/lproc_mgc.c:51:1: note: in expansion of macro 'LPROC_SEQ_FOPS_RO'
    LPROC_SEQ_FOPS_RO(mgc_ir_state);
    ^
>> drivers/staging/lustre/lustre/mgc/../include/lprocfs_status.h:632:59: warning: control reaches end of non-void function [-Wreturn-type]
    static int name##_single_open(struct inode *inode, struct file *file) \
                                                              ^
>> drivers/staging/lustre/lustre/mgc/../include/lprocfs_status.h:645:34: note: in expansion of macro '__LPROC_SEQ_FOPS'
    #define LPROC_SEQ_FOPS_RO(name)  __LPROC_SEQ_FOPS(name, NULL)
                                     ^
>> drivers/staging/lustre/lustre/mgc/lproc_mgc.c:51:1: note: in expansion of macro 'LPROC_SEQ_FOPS_RO'
    LPROC_SEQ_FOPS_RO(mgc_ir_state);
    ^

vim +/mgc_ir_state_seq_show +51 drivers/staging/lustre/lustre/mgc/lproc_mgc.c

d7e09d039 Peng Tao           2013-05-02  33   * This file is part of Lustre, http://www.lustre.org/
d7e09d039 Peng Tao           2013-05-02  34   * Lustre is a trademark of Sun Microsystems, Inc.
d7e09d039 Peng Tao           2013-05-02  35   */
d7e09d039 Peng Tao           2013-05-02  36  #define DEBUG_SUBSYSTEM S_CLASS
d7e09d039 Peng Tao           2013-05-02  37  
d7e09d039 Peng Tao           2013-05-02  38  #include <linux/vfs.h>
73060ed93 Greg Kroah-Hartman 2014-07-11 @39  #include "../include/obd_class.h"
73060ed93 Greg Kroah-Hartman 2014-07-11  40  #include "../include/lprocfs_status.h"
d7e09d039 Peng Tao           2013-05-02  41  #include "mgc_internal.h"
d7e09d039 Peng Tao           2013-05-02  42  
73bb1da69 Peng Tao           2013-05-29  43  LPROC_SEQ_FOPS_RO_TYPE(mgc, connect_flags);
73bb1da69 Peng Tao           2013-05-29  44  LPROC_SEQ_FOPS_RO_TYPE(mgc, server_uuid);
73bb1da69 Peng Tao           2013-05-29  45  LPROC_SEQ_FOPS_RO_TYPE(mgc, conn_uuid);
73bb1da69 Peng Tao           2013-05-29  46  LPROC_SEQ_FOPS_RO_TYPE(mgc, import);
73bb1da69 Peng Tao           2013-05-29  47  LPROC_SEQ_FOPS_RO_TYPE(mgc, state);
73bb1da69 Peng Tao           2013-05-29  48  
73bb1da69 Peng Tao           2013-05-29  49  LPROC_SEQ_FOPS_WR_ONLY(mgc, ping);
73bb1da69 Peng Tao           2013-05-29  50  
73bb1da69 Peng Tao           2013-05-29 @51  LPROC_SEQ_FOPS_RO(mgc_ir_state);
73bb1da69 Peng Tao           2013-05-29  52  
d7e09d039 Peng Tao           2013-05-02  53  static struct lprocfs_vars lprocfs_mgc_obd_vars[] = {
35b8dfd41 Greg DeAngelis     2014-05-23  54  	{ "ping",	     &mgc_ping_fops,      NULL, 0222 },

:::::: The code at line 51 was first introduced by commit
:::::: 73bb1da692d0dc3e93b9c9e29084d6a5dcbc37a6 staging/lustre: adapt proc_dir_entry change

:::::: TO: Peng Tao <bergwolf@gmail.com>
:::::: CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
-------------- next part --------------
A non-text attachment was scrubbed...
Name: .config.gz
Type: application/octet-stream
Size: 51270 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20151109/0f8cb5da/attachment-0001.obj>
