From: Simmons, James A. <simmonsja@ornl.gov>
Date: Fri, 6 Nov 2015 22:18:17 +0000
Subject: [lustre-devel] [PATCH 07/10] staging: lustre: Handle
 nodemask	on UMP machines
In-Reply-To: <201511050801.fy1GmLxM%fengguang.wu@intel.com>
References: <1446662406-4590-7-git-send-email-jsimmons@infradead.org>
	<201511050801.fy1GmLxM%fengguang.wu@intel.com>
Message-ID: <cafafd1c8db141899d9c9757422451dd@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>All warnings (new ones prefixed by >>):
>
>   In file included from include/linux/bitops.h:36:0,
>                    from drivers/staging/lustre/lustre/libcfs/../../include/linux/libcfs/linux/libcfs.h:44,
>                    from drivers/staging/lustre/lustre/libcfs/../../include/linux/libcfs/libcfs.h:40,
>                    from drivers/staging/lustre/lustre/libcfs/libcfs_cpu.c:38:
>   drivers/staging/lustre/lustre/libcfs/libcfs_cpu.c: In function 'cfs_cpt_table_alloc':
>>> arch/m68k/include/asm/bitops.h:64:5: warning: passing argument 2 of 'bset_mem_set_bit' from incompatible pointer type
>        bset_mem_set_bit(nr, vaddr) : \
>        ^
>>> drivers/staging/lustre/lustre/libcfs/libcfs_cpu.c:61:3: note: in expansion of macro 'set_bit'
>      set_bit(0, &cptab->ctb_nodemask);

Yep and additional patch exist to fix this. Should I just push the fix for this or drop this patch and create
a new patch that is combo of both fixes.

BTW Greg this new batch of patches are order independent. Sorry for not pointing that out. The rest of the
patch appear to be okay.
