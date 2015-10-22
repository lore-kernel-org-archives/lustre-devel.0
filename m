From: kbuild test robot <lkp@intel.com>
Date: Thu, 22 Oct 2015 23:59:12 +0800
Subject: [lustre-devel] [PATCH 1/3] locks: introduce
	locks_lock_inode_wait()
In-Reply-To: <daf0d3941f34438c1fbdc94a5f3a47c2b22f3ee8.1445524157.git.bcodding@redhat.com>
Message-ID: <201510222318.nNtSfkKO%fengguang.wu@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Benjamin,

[auto build test ERROR on jlayton/linux-next -- if it's inappropriate base, please suggest rules for selecting the more suitable base]

url:    https://github.com/0day-ci/linux/commits/Benjamin-Coddington/locks-introduce-locks_lock_inode_wait/20151022-233848
config: x86_64-allnoconfig (attached as .config)
reproduce:
        # save the attached .config to linux build tree
        make ARCH=x86_64 

All errors (new ones prefixed by >>):

   In file included from include/linux/cgroup.h:17:0,
                    from include/linux/memcontrol.h:22,
                    from include/linux/swap.h:8,
                    from include/linux/suspend.h:4,
                    from arch/x86/kernel/asm-offsets.c:12:
>> include/linux/fs.h:1234:19: error: redefinition of 'locks_lock_file_wait'
    static inline int locks_lock_file_wait(struct file *filp, struct file_lock *fl)
                      ^
   include/linux/fs.h:1181:19: note: previous definition of 'locks_lock_file_wait' was here
    static inline int locks_lock_file_wait(struct file *filp, struct file_lock *fl)
                      ^
   include/linux/fs.h: In function 'locks_lock_file_wait':
>> include/linux/fs.h:1236:9: error: implicit declaration of function 'locks_lock_inode_wait' [-Werror=implicit-function-declaration]
     return locks_lock_inode_wait(file_inode(filp), fl);
            ^
   cc1: some warnings being treated as errors
   make[2]: *** [arch/x86/kernel/asm-offsets.s] Error 1
   make[2]: Target '__build' not remade because of errors.
   make[1]: *** [prepare0] Error 2
   make[1]: Target 'prepare' not remade because of errors.
   make: *** [sub-make] Error 2

vim +/locks_lock_file_wait +1234 include/linux/fs.h

  1228	
  1229	static inline int flock_lock_file_wait(struct file *filp, struct file_lock *fl)
  1230	{
  1231		return flock_lock_inode_wait(file_inode(filp), fl);
  1232	}
  1233	
> 1234	static inline int locks_lock_file_wait(struct file *filp, struct file_lock *fl)
  1235	{
> 1236		return locks_lock_inode_wait(file_inode(filp), fl);
  1237	}
  1238	
  1239	struct fasync_struct {

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
-------------- next part --------------
A non-text attachment was scrubbed...
Name: .config.gz
Type: application/octet-stream
Size: 6030 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20151022/dabc38ad/attachment.obj>
