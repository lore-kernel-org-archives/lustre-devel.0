From: kbuild test robot <lkp@intel.com>
Date: Thu, 5 Nov 2015 08:46:51 +0800
Subject: [lustre-devel] [PATCH 07/10] staging: lustre: Handle nodemask
	on UMP machines
In-Reply-To: <1446662406-4590-7-git-send-email-jsimmons@infradead.org>
Message-ID: <201511050801.fy1GmLxM%fengguang.wu@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi James,

[auto build test WARNING on: staging/staging-next]
[also build test WARNING on: next-20151104]
[cannot apply to: v4.3]

url:    https://github.com/0day-ci/linux/commits/James-Simmons/staging-lustre-wrong-parameter-to-cfs_hash_keycpy/20151105-024407
config: m68k-allmodconfig (attached as .config)
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=m68k 

All warnings (new ones prefixed by >>):

   In file included from include/linux/bitops.h:36:0,
                    from drivers/staging/lustre/lustre/libcfs/../../include/linux/libcfs/linux/libcfs.h:44,
                    from drivers/staging/lustre/lustre/libcfs/../../include/linux/libcfs/libcfs.h:40,
                    from drivers/staging/lustre/lustre/libcfs/libcfs_cpu.c:38:
   drivers/staging/lustre/lustre/libcfs/libcfs_cpu.c: In function 'cfs_cpt_table_alloc':
>> arch/m68k/include/asm/bitops.h:64:5: warning: passing argument 2 of 'bset_mem_set_bit' from incompatible pointer type
        bset_mem_set_bit(nr, vaddr) : \
        ^
>> drivers/staging/lustre/lustre/libcfs/libcfs_cpu.c:61:3: note: in expansion of macro 'set_bit'
      set_bit(0, &cptab->ctb_nodemask);
      ^
   arch/m68k/include/asm/bitops.h:41:20: note: expected 'volatile long unsigned int *' but argument is of type 'struct nodemask_t *'
    static inline void bset_mem_set_bit(int nr, volatile unsigned long *vaddr)
                       ^
>> arch/m68k/include/asm/bitops.h:65:5: warning: passing argument 2 of 'bfset_mem_set_bit' from incompatible pointer type
        bfset_mem_set_bit(nr, vaddr))
        ^
>> drivers/staging/lustre/lustre/libcfs/libcfs_cpu.c:61:3: note: in expansion of macro 'set_bit'
      set_bit(0, &cptab->ctb_nodemask);
      ^
   arch/m68k/include/asm/bitops.h:50:20: note: expected 'volatile long unsigned int *' but argument is of type 'struct nodemask_t *'
    static inline void bfset_mem_set_bit(int nr, volatile unsigned long *vaddr)
                       ^

vim +/set_bit +61 drivers/staging/lustre/lustre/libcfs/libcfs_cpu.c

    32	 *
    33	 * Author: liang at whamcloud.com
    34	 */
    35	
    36	#define DEBUG_SUBSYSTEM S_LNET
    37	
  > 38	#include "../../include/linux/libcfs/libcfs.h"
    39	
    40	/** Global CPU partition table */
    41	struct cfs_cpt_table   *cfs_cpt_table __read_mostly;
    42	EXPORT_SYMBOL(cfs_cpt_table);
    43	
    44	#ifndef HAVE_LIBCFS_CPT
    45	
    46	#define CFS_CPU_VERSION_MAGIC	   0xbabecafe
    47	
    48	struct cfs_cpt_table *
    49	cfs_cpt_table_alloc(unsigned int ncpt)
    50	{
    51		struct cfs_cpt_table *cptab;
    52	
    53		if (ncpt != 1) {
    54			CERROR("Can't support cpu partition number %d\n", ncpt);
    55			return NULL;
    56		}
    57	
    58		LIBCFS_ALLOC(cptab, sizeof(*cptab));
    59		if (cptab != NULL) {
    60			cptab->ctb_version = CFS_CPU_VERSION_MAGIC;
  > 61			set_bit(0, &cptab->ctb_nodemask);
    62			cptab->ctb_nparts  = ncpt;
    63		}
    64	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
-------------- next part --------------
A non-text attachment was scrubbed...
Name: .config.gz
Type: application/octet-stream
Size: 34355 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20151105/d1c0d173/attachment-0001.obj>
