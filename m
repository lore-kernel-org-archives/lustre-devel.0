From: kbuild test robot <lkp@intel.com>
Date: Thu, 5 Nov 2015 06:06:17 +0800
Subject: [lustre-devel] [PATCH 07/10] staging: lustre: Handle nodemask
	on UMP machines
In-Reply-To: <1446662406-4590-7-git-send-email-jsimmons@infradead.org>
Message-ID: <201511050650.viTvMDVn%fengguang.wu@intel.com>
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
config: i386-randconfig-b0-11050505 (attached as .config)
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

All warnings (new ones prefixed by >>):

   drivers/staging/lustre/lustre/libcfs/libcfs_cpu.c: In function 'cfs_cpt_table_alloc':
>> drivers/staging/lustre/lustre/libcfs/libcfs_cpu.c:61:14: warning: passing argument 2 of 'set_bit' from incompatible pointer type [-Wincompatible-pointer-types]
      set_bit(0, &cptab->ctb_nodemask);
                 ^
   In file included from include/linux/bitops.h:36:0,
                    from drivers/staging/lustre/lustre/libcfs/../../include/linux/libcfs/linux/libcfs.h:44,
                    from drivers/staging/lustre/lustre/libcfs/../../include/linux/libcfs/libcfs.h:40,
                    from drivers/staging/lustre/lustre/libcfs/libcfs_cpu.c:38:
   arch/x86/include/asm/bitops.h:72:1: note: expected 'volatile long unsigned int *' but argument is of type 'nodemask_t * {aka struct <anonymous> *}'
    set_bit(long nr, volatile unsigned long *addr)
    ^

vim +/set_bit +61 drivers/staging/lustre/lustre/libcfs/libcfs_cpu.c

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
    65		return cptab;
    66	}
    67	EXPORT_SYMBOL(cfs_cpt_table_alloc);
    68	
    69	void

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
-------------- next part --------------
A non-text attachment was scrubbed...
Name: .config.gz
Type: application/octet-stream
Size: 30157 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20151105/d888a414/attachment-0001.obj>
