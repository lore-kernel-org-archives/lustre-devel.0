From: kbuild test robot <lkp@intel.com>
Date: Sat, 17 Oct 2015 12:53:03 +0800
Subject: [lustre-devel] [PATCH 4/4] staging: lustre: remove IS_PO2 and
	__is_po2
In-Reply-To: <97ba103dc2a11e23fd4a384eb041c273b67a9aee.1445032901.git.mahfouz.saif.elyazal@gmail.com>
Message-ID: <201510171217.WfggLgqH%fengguang.wu@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Aya,

[auto build test ERROR on staging/staging-next -- if it's inappropriate base, please suggest rules for selecting the more suitable base]

url:    https://github.com/0day-ci/linux/commits/Aya-Mahfouz/Remove-uses-and-definition-of-IS_PO2/20151017-060923
config: s390-allmodconfig (attached as .config)
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=s390 

All errors (new ones prefixed by >>):

   In file included from drivers/staging/lustre/lnet/selftest/../../include/linux/libcfs/libcfs.h:111:0,
                    from drivers/staging/lustre/lnet/selftest/conrpc.c:43:
   drivers/staging/lustre/lnet/selftest/conrpc.c: In function 'lstcon_rpc_cleanup_wait':
>> drivers/staging/lustre/lnet/selftest/../../include/linux/libcfs/libcfs_debug.h:212:16: error: implicit declaration of function 'IS_PO2' [-Werror=implicit-function-declaration]
     static struct libcfs_debug_msg_data msgdata;   \
                   ^
   drivers/staging/lustre/lnet/selftest/../../include/linux/libcfs/libcfs_debug.h:222:35: note: in expansion of macro '__CDEBUG'
    #define CDEBUG(mask, format, ...) __CDEBUG(NULL, mask, format, ## __VA_ARGS__)
                                      ^
   drivers/staging/lustre/lnet/selftest/selftest.h:588:3: note: in expansion of macro 'CDEBUG'
      CDEBUG(IS_PO2(++__I) ? D_WARNING : D_NET,  \
      ^
   drivers/staging/lustre/lnet/selftest/conrpc.c:1359:2: note: in expansion of macro 'lst_wait_until'
     lst_wait_until((atomic_read(&console_session.ses_rpc_counter) == 0),
     ^
   cc1: some warnings being treated as errors
--
   In file included from drivers/staging/lustre/lnet/selftest/../../include/linux/libcfs/libcfs.h:111:0,
                    from drivers/staging/lustre/lnet/selftest/selftest.h:46,
                    from drivers/staging/lustre/lnet/selftest/framework.c:44:
   drivers/staging/lustre/lnet/selftest/framework.c: In function 'sfw_shutdown':
>> drivers/staging/lustre/lnet/selftest/../../include/linux/libcfs/libcfs_debug.h:212:16: error: implicit declaration of function 'IS_PO2' [-Werror=implicit-function-declaration]
     static struct libcfs_debug_msg_data msgdata;   \
                   ^
   drivers/staging/lustre/lnet/selftest/../../include/linux/libcfs/libcfs_debug.h:222:35: note: in expansion of macro '__CDEBUG'
    #define CDEBUG(mask, format, ...) __CDEBUG(NULL, mask, format, ## __VA_ARGS__)
                                      ^
   drivers/staging/lustre/lnet/selftest/selftest.h:588:3: note: in expansion of macro 'CDEBUG'
      CDEBUG(IS_PO2(++__I) ? D_WARNING : D_NET,  \
      ^
   drivers/staging/lustre/lnet/selftest/framework.c:1741:2: note: in expansion of macro 'lst_wait_until'
     lst_wait_until(sfw_data.fw_active_srpc == NULL, sfw_data.fw_lock,
     ^
   cc1: some warnings being treated as errors
--
   In file included from drivers/staging/lustre/lnet/selftest/../../include/linux/libcfs/libcfs.h:111:0,
                    from drivers/staging/lustre/lnet/selftest/selftest.h:46,
                    from drivers/staging/lustre/lnet/selftest/timer.c:43:
   drivers/staging/lustre/lnet/selftest/timer.c: In function 'stt_shutdown':
>> drivers/staging/lustre/lnet/selftest/../../include/linux/libcfs/libcfs_debug.h:212:16: error: implicit declaration of function 'IS_PO2' [-Werror=implicit-function-declaration]
     static struct libcfs_debug_msg_data msgdata;   \
                   ^
   drivers/staging/lustre/lnet/selftest/../../include/linux/libcfs/libcfs_debug.h:222:35: note: in expansion of macro '__CDEBUG'
    #define CDEBUG(mask, format, ...) __CDEBUG(NULL, mask, format, ## __VA_ARGS__)
                                      ^
   drivers/staging/lustre/lnet/selftest/selftest.h:588:3: note: in expansion of macro 'CDEBUG'
      CDEBUG(IS_PO2(++__I) ? D_WARNING : D_NET,  \
      ^
   drivers/staging/lustre/lnet/selftest/timer.c:240:2: note: in expansion of macro 'lst_wait_until'
     lst_wait_until(stt_data.stt_nthreads == 0, stt_data.stt_lock,
     ^
   cc1: some warnings being treated as errors
--
   In file included from drivers/staging/lustre/lnet/selftest/../../include/linux/libcfs/libcfs.h:111:0,
                    from drivers/staging/lustre/lnet/selftest/selftest.h:46,
                    from drivers/staging/lustre/lnet/selftest/rpc.c:47:
   drivers/staging/lustre/lnet/selftest/rpc.c: In function 'srpc_service_add_buffers':
>> drivers/staging/lustre/lnet/selftest/../../include/linux/libcfs/libcfs_debug.h:212:16: error: implicit declaration of function 'IS_PO2' [-Werror=implicit-function-declaration]
     static struct libcfs_debug_msg_data msgdata;   \
                   ^
   drivers/staging/lustre/lnet/selftest/../../include/linux/libcfs/libcfs_debug.h:222:35: note: in expansion of macro '__CDEBUG'
    #define CDEBUG(mask, format, ...) __CDEBUG(NULL, mask, format, ## __VA_ARGS__)
                                      ^
   drivers/staging/lustre/lnet/selftest/selftest.h:588:3: note: in expansion of macro 'CDEBUG'
      CDEBUG(IS_PO2(++__I) ? D_WARNING : D_NET,  \
      ^
   drivers/staging/lustre/lnet/selftest/rpc.c:619:3: note: in expansion of macro 'lst_wait_until'
      lst_wait_until(scd->scd_buf_err != 0 ||
      ^
   cc1: some warnings being treated as errors

vim +/IS_PO2 +212 drivers/staging/lustre/lnet/selftest/../../include/linux/libcfs/libcfs_debug.h

d7e09d039 Peng Tao 2013-05-02  206  	return mask & D_CANTMASK ||
d7e09d039 Peng Tao 2013-05-02  207  		((libcfs_debug & mask) && (libcfs_subsystem_debug & subsystem));
d7e09d039 Peng Tao 2013-05-02  208  }
d7e09d039 Peng Tao 2013-05-02  209  
d7e09d039 Peng Tao 2013-05-02  210  #define __CDEBUG(cdls, mask, format, ...)				\
d7e09d039 Peng Tao 2013-05-02  211  do {									\
d7e09d039 Peng Tao 2013-05-02 @212  	static struct libcfs_debug_msg_data msgdata;			\
d7e09d039 Peng Tao 2013-05-02  213  									\
d7e09d039 Peng Tao 2013-05-02  214  	CFS_CHECK_STACK(&msgdata, mask, cdls);				\
d7e09d039 Peng Tao 2013-05-02  215  									\

:::::: The code at line 212 was first introduced by commit
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
Size: 38548 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20151017/ed392ff4/attachment-0001.obj>
