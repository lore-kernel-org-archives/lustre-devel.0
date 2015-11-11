From: kbuild test robot <lkp@intel.com>
Date: Wed, 11 Nov 2015 18:54:41 +0800
Subject: [lustre-devel] [PATCH] staging: lustre: cl_lock: Remove
 cl_lock_lockdep_init wrapper
In-Reply-To: <1447237306-46901-1-git-send-email-shivanib134@gmail.com>
Message-ID: <201511111859.mIw4mICa%fengguang.wu@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Shivani,

[auto build test ERROR on staging/staging-testing]
[also build test ERROR on v4.3 next-20151111]

url:    https://github.com/0day-ci/linux/commits/Shivani-Bhardwaj/staging-lustre-cl_lock-Remove-cl_lock_lockdep_init-wrapper/20151111-182452
config: m68k-allyesconfig (attached as .config)
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=m68k 

All errors (new ones prefixed by >>):

   In file included from include/linux/spinlock_types.h:18:0,
                    from include/linux/spinlock.h:81,
                    from include/linux/mmzone.h:7,
                    from include/linux/gfp.h:5,
                    from include/linux/slab.h:14,
                    from drivers/staging/lustre/lustre/obdclass/../include/obd_support.h:40,
                    from drivers/staging/lustre/lustre/obdclass/../include/obd_class.h:39,
                    from drivers/staging/lustre/lustre/obdclass/cl_lock.c:43:
   drivers/staging/lustre/lustre/obdclass/cl_lock.c: In function 'cl_lock_alloc':
>> drivers/staging/lustre/lustre/obdclass/cl_lock.c:379:37: error: 'cl_lock_key' undeclared (first use in this function)
      lockdep_set_class_and_name(lock, &cl_lock_key, "EXT");
                                        ^
   include/linux/lockdep.h:401:15: note: in definition of macro 'lockdep_set_class_and_name'
      do { (void)(key); (void)(name); } while (0)
                  ^
   drivers/staging/lustre/lustre/obdclass/cl_lock.c:379:37: note: each undeclared identifier is reported only once for each function it appears in
      lockdep_set_class_and_name(lock, &cl_lock_key, "EXT");
                                        ^
   include/linux/lockdep.h:401:15: note: in definition of macro 'lockdep_set_class_and_name'
      do { (void)(key); (void)(name); } while (0)
                  ^
   drivers/staging/lustre/lustre/obdclass/cl_lock.c: At top level:
   drivers/staging/lustre/lustre/obdclass/cl_lock.c:166:13: warning: 'cl_lock_lockdep_init' defined but not used [-Wunused-function]
    static void cl_lock_lockdep_init(struct cl_lock *lock)
                ^

vim +/cl_lock_key +379 drivers/staging/lustre/lustre/obdclass/cl_lock.c

   373			lockdep_set_class(&lock->cll_guard, &cl_lock_guard_class);
   374			init_waitqueue_head(&lock->cll_wq);
   375			head = obj->co_lu.lo_header;
   376			CS_LOCKSTATE_INC(obj, CLS_NEW);
   377			CS_LOCK_INC(obj, total);
   378			CS_LOCK_INC(obj, create);
 > 379			lockdep_set_class_and_name(lock, &cl_lock_key, "EXT");
   380			list_for_each_entry(obj, &head->loh_layers,
   381						co_lu.lo_linkage) {
   382				int err;

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
-------------- next part --------------
A non-text attachment was scrubbed...
Name: .config.gz
Type: application/octet-stream
Size: 35206 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20151111/aa4213dd/attachment-0001.obj>
