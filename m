From: kbuild test robot <lkp@intel.com>
Date: Fri, 23 Oct 2015 00:36:55 +0800
Subject: [lustre-devel] [PATCH 3/3] locks: cleanup posix_lock_inode_wait
 and flock_lock_inode_wait
In-Reply-To: <ded792d8fdcba562a1c74fd14fefcb387debc4b1.1445524157.git.bcodding@redhat.com>
Message-ID: <201510230020.vZvDxsE7%fengguang.wu@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Benjamin,

[auto build test WARNING on jlayton/linux-next -- if it's inappropriate base, please suggest rules for selecting the more suitable base]

url:    https://github.com/0day-ci/linux/commits/Benjamin-Coddington/locks-introduce-locks_lock_inode_wait/20151022-233848
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> fs/locks.c:1176:5: sparse: symbol 'posix_lock_inode_wait' was not declared. Should it be static?
>> fs/locks.c:1863:5: sparse: symbol 'flock_lock_inode_wait' was not declared. Should it be static?

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
