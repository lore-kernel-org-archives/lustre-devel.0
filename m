From: Christoph Hellwig <hch@lst.de>
Date: Wed, 16 May 2018 07:43:48 +0200
Subject: [lustre-devel] [PATCH 14/14] mm: turn on vm_fault_t type checking
In-Reply-To: <20180516054348.15950-1-hch@lst.de>
References: <20180516054348.15950-1-hch@lst.de>
Message-ID: <20180516054348.15950-15-hch@lst.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Souptick Joarder <jrdr.linux@gmail.com>, Matthew Wilcox <willy@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@lists.orangefs.org, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mtd@lists.infradead.org, dri-devel@lists.freedesktop.org, lustre-devel@lists.lustre.org, linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org

Switch vm_fault_t to point to an unsigned int with __b?twise annotations.
This both catches any old ->fault or ->page_mkwrite instance with plain
compiler type checking, as well as finding more intricate problems with
sparse.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/alpha/mm/fault.c                     |  2 +-
 arch/arc/mm/fault.c                       |  3 +-
 arch/arm/mm/fault.c                       |  5 +-
 arch/arm64/mm/fault.c                     |  7 +-
 arch/hexagon/mm/vm_fault.c                |  2 +-
 arch/ia64/mm/fault.c                      |  2 +-
 arch/m68k/mm/fault.c                      |  2 +-
 arch/microblaze/mm/fault.c                |  2 +-
 arch/mips/mm/fault.c                      |  2 +-
 arch/nds32/mm/fault.c                     |  2 +-
 arch/nios2/mm/fault.c                     |  2 +-
 arch/openrisc/mm/fault.c                  |  2 +-
 arch/parisc/mm/fault.c                    |  2 +-
 arch/powerpc/include/asm/copro.h          |  2 +-
 arch/powerpc/mm/copro_fault.c             |  2 +-
 arch/powerpc/mm/fault.c                   | 10 +--
 arch/powerpc/platforms/cell/spufs/fault.c |  2 +-
 arch/riscv/mm/fault.c                     |  3 +-
 arch/s390/kernel/vdso.c                   |  2 +-
 arch/s390/mm/fault.c                      |  2 +-
 arch/sh/mm/fault.c                        |  2 +-
 arch/sparc/mm/fault_32.c                  |  4 +-
 arch/sparc/mm/fault_64.c                  |  3 +-
 arch/um/kernel/trap.c                     |  2 +-
 arch/unicore32/mm/fault.c                 | 10 +--
 arch/x86/entry/vdso/vma.c                 |  4 +-
 arch/x86/mm/fault.c                       | 11 +--
 arch/xtensa/mm/fault.c                    |  2 +-
 drivers/dax/device.c                      | 21 +++---
 drivers/gpu/drm/drm_vm.c                  | 10 +--
 drivers/gpu/drm/etnaviv/etnaviv_drv.h     |  2 +-
 drivers/gpu/drm/etnaviv/etnaviv_gem.c     |  2 +-
 drivers/gpu/drm/exynos/exynos_drm_gem.c   |  2 +-
 drivers/gpu/drm/exynos/exynos_drm_gem.h   |  2 +-
 drivers/gpu/drm/gma500/framebuffer.c      |  6 +-
 drivers/gpu/drm/gma500/gem.c              |  2 +-
 drivers/gpu/drm/gma500/psb_drv.h          |  2 +-
 drivers/gpu/drm/i915/i915_drv.h           |  2 +-
 drivers/gpu/drm/i915/i915_gem.c           | 21 ++----
 drivers/gpu/drm/msm/msm_drv.h             |  2 +-
 drivers/gpu/drm/msm/msm_gem.c             |  2 +-
 drivers/gpu/drm/qxl/qxl_ttm.c             |  4 +-
 drivers/gpu/drm/radeon/radeon_ttm.c       |  2 +-
 drivers/gpu/drm/udl/udl_drv.h             |  2 +-
 drivers/gpu/drm/udl/udl_gem.c             |  2 +-
 drivers/gpu/drm/vc4/vc4_bo.c              |  2 +-
 drivers/gpu/drm/vc4/vc4_drv.h             |  2 +-
 drivers/hwtracing/intel_th/msu.c          |  2 +-
 drivers/iommu/amd_iommu_v2.c              |  2 +-
 drivers/iommu/intel-svm.c                 |  3 +-
 drivers/misc/cxl/fault.c                  |  2 +-
 drivers/misc/ocxl/context.c               |  6 +-
 drivers/misc/ocxl/link.c                  |  2 +-
 drivers/misc/ocxl/sysfs.c                 |  2 +-
 drivers/scsi/cxlflash/superpipe.c         |  4 +-
 drivers/staging/ncpfs/mmap.c              |  2 +-
 drivers/xen/privcmd.c                     |  2 +-
 fs/9p/vfs_file.c                          |  2 +-
 fs/afs/internal.h                         |  2 +-
 fs/afs/write.c                            |  2 +-
 fs/f2fs/file.c                            | 10 +--
 fs/fuse/file.c                            |  2 +-
 fs/gfs2/file.c                            |  2 +-
 fs/iomap.c                                |  2 +-
 fs/nfs/file.c                             |  4 +-
 fs/nilfs2/file.c                          |  2 +-
 fs/proc/vmcore.c                          |  2 +-
 fs/userfaultfd.c                          |  4 +-
 fs/xfs/xfs_file.c                         | 12 ++--
 include/linux/huge_mm.h                   | 13 ++--
 include/linux/hugetlb.h                   |  2 +-
 include/linux/iomap.h                     |  4 +-
 include/linux/mm.h                        | 67 +++++++++--------
 include/linux/mm_types.h                  |  5 +-
 include/linux/oom.h                       |  2 +-
 include/linux/swapops.h                   |  4 +-
 include/linux/userfaultfd_k.h             |  5 +-
 ipc/shm.c                                 |  2 +-
 kernel/events/core.c                      |  4 +-
 mm/gup.c                                  |  7 +-
 mm/hmm.c                                  |  2 +-
 mm/huge_memory.c                          | 29 ++++----
 mm/hugetlb.c                              | 25 +++----
 mm/internal.h                             |  2 +-
 mm/khugepaged.c                           |  3 +-
 mm/ksm.c                                  |  2 +-
 mm/memory.c                               | 88 ++++++++++++-----------
 mm/mmap.c                                 |  4 +-
 mm/shmem.c                                |  9 +--
 samples/vfio-mdev/mbochs.c                |  4 +-
 virt/kvm/kvm_main.c                       |  2 +-
 91 files changed, 285 insertions(+), 259 deletions(-)

diff --git a/arch/alpha/mm/fault.c b/arch/alpha/mm/fault.c
index de2bd217adad..e313430fe9b4 100644
--- a/arch/alpha/mm/fault.c
+++ b/arch/alpha/mm/fault.c
@@ -88,7 +88,7 @@ do_page_fault(unsigned long address, unsigned long mmcsr,
 	struct mm_struct *mm = current->mm;
 	const struct exception_table_entry *fixup;
 	int fault, si_code = SEGV_MAPERR;
-	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
+	vm_fault_t flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
 	/* As of EV6, a load into $31/$f31 is a prefetch, and never faults
 	   (or is suppressed by the PALcode).  Support that for older CPUs
diff --git a/arch/arc/mm/fault.c b/arch/arc/mm/fault.c
index b884bbd6f354..fe495df421a4 100644
--- a/arch/arc/mm/fault.c
+++ b/arch/arc/mm/fault.c
@@ -66,7 +66,8 @@ void do_page_fault(unsigned long address, struct pt_regs *regs)
 	struct task_struct *tsk = current;
 	struct mm_struct *mm = tsk->mm;
 	siginfo_t info;
-	int fault, ret;
+	vm_fault_t fault;
+	int ret;
 	int write = regs->ecr_cause & ECR_C_PROTV_STORE;  /* ST/EX */
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
diff --git a/arch/arm/mm/fault.c b/arch/arm/mm/fault.c
index b696eabccf60..9f32a6518db3 100644
--- a/arch/arm/mm/fault.c
+++ b/arch/arm/mm/fault.c
@@ -218,7 +218,7 @@ static inline bool access_error(unsigned int fsr, struct vm_area_struct *vma)
 	return vma->vm_flags & mask ? false : true;
 }
 
-static int __kprobes
+static vm_fault_t __kprobes
 __do_page_fault(struct mm_struct *mm, unsigned long addr, unsigned int fsr,
 		unsigned int flags, struct task_struct *tsk)
 {
@@ -258,7 +258,8 @@ do_page_fault(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 {
 	struct task_struct *tsk;
 	struct mm_struct *mm;
-	int fault, sig, code;
+	vm_fault_t fault;
+	int sig, code;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
 	if (notify_page_fault(regs, fsr))
diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
index 3d0b1f8eacce..e6fb6a8c655d 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -318,7 +318,7 @@ static void do_bad_area(unsigned long addr, unsigned int esr, struct pt_regs *re
 	}
 }
 
-static int __do_page_fault(struct mm_struct *mm, unsigned long addr,
+static vm_fault_t __do_page_fault(struct mm_struct *mm, unsigned long addr,
 			   unsigned int mm_flags, unsigned long vm_flags,
 			   struct task_struct *tsk)
 {
@@ -366,7 +366,8 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
 	struct task_struct *tsk;
 	struct mm_struct *mm;
 	struct siginfo si;
-	int fault, major = 0;
+	vm_fault_t fault;
+	int major = 0;
 	unsigned long vm_flags = VM_READ | VM_WRITE;
 	unsigned int mm_flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
@@ -430,7 +431,7 @@ static int __kprobes do_page_fault(unsigned long addr, unsigned int esr,
 	}
 
 	fault = __do_page_fault(mm, addr, mm_flags, vm_flags, tsk);
-	major |= fault & VM_FAULT_MAJOR;
+	major |= !!(fault & VM_FAULT_MAJOR);
 
 	if (fault & VM_FAULT_RETRY) {
 		/*
diff --git a/arch/hexagon/mm/vm_fault.c b/arch/hexagon/mm/vm_fault.c
index 933bbcef5363..eb263e61daf4 100644
--- a/arch/hexagon/mm/vm_fault.c
+++ b/arch/hexagon/mm/vm_fault.c
@@ -52,7 +52,7 @@ void do_page_fault(unsigned long address, long cause, struct pt_regs *regs)
 	struct mm_struct *mm = current->mm;
 	int si_signo;
 	int si_code = SEGV_MAPERR;
-	int fault;
+	vm_fault_t fault;
 	const struct exception_table_entry *fixup;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
diff --git a/arch/ia64/mm/fault.c b/arch/ia64/mm/fault.c
index 817fa120645f..a9d55ad8d67b 100644
--- a/arch/ia64/mm/fault.c
+++ b/arch/ia64/mm/fault.c
@@ -86,7 +86,7 @@ ia64_do_page_fault (unsigned long address, unsigned long isr, struct pt_regs *re
 	struct vm_area_struct *vma, *prev_vma;
 	struct mm_struct *mm = current->mm;
 	unsigned long mask;
-	int fault;
+	vm_fault_t fault;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
 	mask = ((((isr >> IA64_ISR_X_BIT) & 1UL) << VM_EXEC_BIT)
diff --git a/arch/m68k/mm/fault.c b/arch/m68k/mm/fault.c
index f2ff3779875a..4ceb14b3b4de 100644
--- a/arch/m68k/mm/fault.c
+++ b/arch/m68k/mm/fault.c
@@ -70,7 +70,7 @@ int do_page_fault(struct pt_regs *regs, unsigned long address,
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct * vma;
-	int fault;
+	vm_fault_t fault;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
 	pr_debug("do page fault:\nregs->sr=%#x, regs->pc=%#lx, address=%#lx, %ld, %p\n",
diff --git a/arch/microblaze/mm/fault.c b/arch/microblaze/mm/fault.c
index af607447c683..202ad6a494f5 100644
--- a/arch/microblaze/mm/fault.c
+++ b/arch/microblaze/mm/fault.c
@@ -90,7 +90,7 @@ void do_page_fault(struct pt_regs *regs, unsigned long address,
 	struct mm_struct *mm = current->mm;
 	int code = SEGV_MAPERR;
 	int is_write = error_code & ESR_S;
-	int fault;
+	vm_fault_t fault;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
 	regs->ear = address;
diff --git a/arch/mips/mm/fault.c b/arch/mips/mm/fault.c
index 5f71f2b903b7..73d8a0f0b810 100644
--- a/arch/mips/mm/fault.c
+++ b/arch/mips/mm/fault.c
@@ -43,7 +43,7 @@ static void __kprobes __do_page_fault(struct pt_regs *regs, unsigned long write,
 	struct mm_struct *mm = tsk->mm;
 	const int field = sizeof(unsigned long) * 2;
 	int si_code;
-	int fault;
+	vm_fault_t fault;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
 	static DEFINE_RATELIMIT_STATE(ratelimit_state, 5 * HZ, 10);
diff --git a/arch/nds32/mm/fault.c b/arch/nds32/mm/fault.c
index 9bdb7c3ecbb6..b740534b152c 100644
--- a/arch/nds32/mm/fault.c
+++ b/arch/nds32/mm/fault.c
@@ -73,7 +73,7 @@ void do_page_fault(unsigned long entry, unsigned long addr,
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
 	int si_code;
-	int fault;
+	vm_fault_t fault;
 	unsigned int mask = VM_READ | VM_WRITE | VM_EXEC;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
diff --git a/arch/nios2/mm/fault.c b/arch/nios2/mm/fault.c
index b804dd06ea1c..24fd84cf6006 100644
--- a/arch/nios2/mm/fault.c
+++ b/arch/nios2/mm/fault.c
@@ -47,7 +47,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long cause,
 	struct task_struct *tsk = current;
 	struct mm_struct *mm = tsk->mm;
 	int code = SEGV_MAPERR;
-	int fault;
+	vm_fault_t fault;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
 	cause >>= 2;
diff --git a/arch/openrisc/mm/fault.c b/arch/openrisc/mm/fault.c
index 9f011d16cc46..dc4dbafc1d83 100644
--- a/arch/openrisc/mm/fault.c
+++ b/arch/openrisc/mm/fault.c
@@ -53,7 +53,7 @@ asmlinkage void do_page_fault(struct pt_regs *regs, unsigned long address,
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
 	int si_code;
-	int fault;
+	vm_fault_t fault;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
 	tsk = current;
diff --git a/arch/parisc/mm/fault.c b/arch/parisc/mm/fault.c
index a80117980fc2..c8e8b7c05558 100644
--- a/arch/parisc/mm/fault.c
+++ b/arch/parisc/mm/fault.c
@@ -262,7 +262,7 @@ void do_page_fault(struct pt_regs *regs, unsigned long code,
 	struct task_struct *tsk;
 	struct mm_struct *mm;
 	unsigned long acc_type;
-	int fault = 0;
+	vm_fault_t fault = 0;
 	unsigned int flags;
 
 	if (faulthandler_disabled())
diff --git a/arch/powerpc/include/asm/copro.h b/arch/powerpc/include/asm/copro.h
index ce216df31381..fac150839ef6 100644
--- a/arch/powerpc/include/asm/copro.h
+++ b/arch/powerpc/include/asm/copro.h
@@ -16,7 +16,7 @@ struct copro_slb
 };
 
 int copro_handle_mm_fault(struct mm_struct *mm, unsigned long ea,
-			  unsigned long dsisr, unsigned *flt);
+			  unsigned long dsisr, vm_fault_t *flt);
 
 int copro_calculate_slb(struct mm_struct *mm, u64 ea, struct copro_slb *slb);
 
diff --git a/arch/powerpc/mm/copro_fault.c b/arch/powerpc/mm/copro_fault.c
index 7d0945bd3a61..c8da352e8686 100644
--- a/arch/powerpc/mm/copro_fault.c
+++ b/arch/powerpc/mm/copro_fault.c
@@ -34,7 +34,7 @@
  * to handle fortunately.
  */
 int copro_handle_mm_fault(struct mm_struct *mm, unsigned long ea,
-		unsigned long dsisr, unsigned *flt)
+		unsigned long dsisr, vm_fault_t *flt)
 {
 	struct vm_area_struct *vma;
 	unsigned long is_write;
diff --git a/arch/powerpc/mm/fault.c b/arch/powerpc/mm/fault.c
index ef268d5d9db7..2b4096cb1b46 100644
--- a/arch/powerpc/mm/fault.c
+++ b/arch/powerpc/mm/fault.c
@@ -159,7 +159,7 @@ static noinline int bad_access(struct pt_regs *regs, unsigned long address)
 }
 
 static int do_sigbus(struct pt_regs *regs, unsigned long address,
-		     unsigned int fault)
+		     vm_fault_t fault)
 {
 	siginfo_t info;
 	unsigned int lsb = 0;
@@ -190,7 +190,8 @@ static int do_sigbus(struct pt_regs *regs, unsigned long address,
 	return 0;
 }
 
-static int mm_fault_error(struct pt_regs *regs, unsigned long addr, int fault)
+static int mm_fault_error(struct pt_regs *regs, unsigned long addr,
+		vm_fault_t fault)
 {
 	/*
 	 * Kernel page fault interrupted by SIGKILL. We have no reason to
@@ -403,7 +404,8 @@ static int __do_page_fault(struct pt_regs *regs, unsigned long address,
  	int is_exec = TRAP(regs) == 0x400;
 	int is_user = user_mode(regs);
 	int is_write = page_fault_is_write(error_code);
-	int fault, major = 0;
+	vm_fault_t fault;
+	int major = 0;
 	bool store_update_sp = false;
 
 	if (notify_page_fault(regs))
@@ -537,7 +539,7 @@ static int __do_page_fault(struct pt_regs *regs, unsigned long address,
 	}
 #endif /* CONFIG_PPC_MEM_KEYS */
 
-	major |= fault & VM_FAULT_MAJOR;
+	major |= !!(fault & VM_FAULT_MAJOR);
 
 	/*
 	 * Handle the retry right now, the mmap_sem has been released in that
diff --git a/arch/powerpc/platforms/cell/spufs/fault.c b/arch/powerpc/platforms/cell/spufs/fault.c
index 1e002e94d0f6..83cf58daaa79 100644
--- a/arch/powerpc/platforms/cell/spufs/fault.c
+++ b/arch/powerpc/platforms/cell/spufs/fault.c
@@ -111,7 +111,7 @@ int spufs_handle_class1(struct spu_context *ctx)
 {
 	u64 ea, dsisr, access;
 	unsigned long flags;
-	unsigned flt = 0;
+	vm_fault_t flt = 0;
 	int ret;
 
 	/*
diff --git a/arch/riscv/mm/fault.c b/arch/riscv/mm/fault.c
index 148c98ca9b45..88401d5125bc 100644
--- a/arch/riscv/mm/fault.c
+++ b/arch/riscv/mm/fault.c
@@ -41,7 +41,8 @@ asmlinkage void do_page_fault(struct pt_regs *regs)
 	struct mm_struct *mm;
 	unsigned long addr, cause;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
-	int fault, code = SEGV_MAPERR;
+	int code = SEGV_MAPERR;
+	vm_fault_t fault;
 
 	cause = regs->scause;
 	addr = regs->sbadaddr;
diff --git a/arch/s390/kernel/vdso.c b/arch/s390/kernel/vdso.c
index f3a1c7c6824e..8da00ed2eb12 100644
--- a/arch/s390/kernel/vdso.c
+++ b/arch/s390/kernel/vdso.c
@@ -47,7 +47,7 @@ static struct page **vdso64_pagelist;
  */
 unsigned int __read_mostly vdso_enabled = 1;
 
-static int vdso_fault(const struct vm_special_mapping *sm,
+static vm_fault_t vdso_fault(const struct vm_special_mapping *sm,
 		      struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct page **vdso_pagelist;
diff --git a/arch/s390/mm/fault.c b/arch/s390/mm/fault.c
index 48c781ae25d0..8af651ed108b 100644
--- a/arch/s390/mm/fault.c
+++ b/arch/s390/mm/fault.c
@@ -405,7 +405,7 @@ static inline int do_exception(struct pt_regs *regs, int access)
 	unsigned long trans_exc_code;
 	unsigned long address;
 	unsigned int flags;
-	int fault;
+	vm_fault_t fault;
 
 	tsk = current;
 	/*
diff --git a/arch/sh/mm/fault.c b/arch/sh/mm/fault.c
index b8e7bb84b6b1..c4c074251b02 100644
--- a/arch/sh/mm/fault.c
+++ b/arch/sh/mm/fault.c
@@ -396,7 +396,7 @@ asmlinkage void __kprobes do_page_fault(struct pt_regs *regs,
 	struct task_struct *tsk;
 	struct mm_struct *mm;
 	struct vm_area_struct * vma;
-	int fault;
+	vm_fault_t fault;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
 	tsk = current;
diff --git a/arch/sparc/mm/fault_32.c b/arch/sparc/mm/fault_32.c
index 9f75b6444bf1..34fb0d2d9998 100644
--- a/arch/sparc/mm/fault_32.c
+++ b/arch/sparc/mm/fault_32.c
@@ -165,8 +165,8 @@ asmlinkage void do_sparc_fault(struct pt_regs *regs, int text_fault, int write,
 	struct mm_struct *mm = tsk->mm;
 	unsigned int fixup;
 	unsigned long g2;
-	int from_user = !(regs->psr & PSR_PS);
-	int fault, code;
+	int from_user = !(regs->psr & PSR_PS), code;
+	vm_fault_t fault;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
 	if (text_fault)
diff --git a/arch/sparc/mm/fault_64.c b/arch/sparc/mm/fault_64.c
index 63166fcf9e25..8f8a604c1300 100644
--- a/arch/sparc/mm/fault_64.c
+++ b/arch/sparc/mm/fault_64.c
@@ -278,7 +278,8 @@ asmlinkage void __kprobes do_sparc64_fault(struct pt_regs *regs)
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 	unsigned int insn = 0;
-	int si_code, fault_code, fault;
+	int si_code, fault_code;
+	vm_fault_t fault;
 	unsigned long address, mm_rss;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
diff --git a/arch/um/kernel/trap.c b/arch/um/kernel/trap.c
index ec9a42c14c56..cced82946042 100644
--- a/arch/um/kernel/trap.c
+++ b/arch/um/kernel/trap.c
@@ -72,7 +72,7 @@ int handle_page_fault(unsigned long address, unsigned long ip,
 	}
 
 	do {
-		int fault;
+		vm_fault_t fault;
 
 		fault = handle_mm_fault(vma, address, flags);
 
diff --git a/arch/unicore32/mm/fault.c b/arch/unicore32/mm/fault.c
index 6c3c1a82925f..c4b477cea5bf 100644
--- a/arch/unicore32/mm/fault.c
+++ b/arch/unicore32/mm/fault.c
@@ -165,8 +165,8 @@ static inline bool access_error(unsigned int fsr, struct vm_area_struct *vma)
 	return vma->vm_flags & mask ? false : true;
 }
 
-static int __do_pf(struct mm_struct *mm, unsigned long addr, unsigned int fsr,
-		unsigned int flags, struct task_struct *tsk)
+static vm_fault_t __do_pf(struct mm_struct *mm, unsigned long addr,
+		unsigned int fsr, unsigned int flags, struct task_struct *tsk)
 {
 	struct vm_area_struct *vma;
 	int fault;
@@ -192,8 +192,7 @@ static int __do_pf(struct mm_struct *mm, unsigned long addr, unsigned int fsr,
 	 * If for any reason at all we couldn't handle the fault, make
 	 * sure we exit gracefully rather than endlessly redo the fault.
 	 */
-	fault = handle_mm_fault(vma, addr & PAGE_MASK, flags);
-	return fault;
+	return handle_mm_fault(vma, addr & PAGE_MASK, flags);
 
 check_stack:
 	if (vma->vm_flags & VM_GROWSDOWN && !expand_stack(vma, addr))
@@ -206,7 +205,8 @@ static int do_pf(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 {
 	struct task_struct *tsk;
 	struct mm_struct *mm;
-	int fault, sig, code;
+	int sig, code;
+	vm_fault_t fault;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
 	tsk = current;
diff --git a/arch/x86/entry/vdso/vma.c b/arch/x86/entry/vdso/vma.c
index 5b8b556dbb12..c575eec31507 100644
--- a/arch/x86/entry/vdso/vma.c
+++ b/arch/x86/entry/vdso/vma.c
@@ -39,7 +39,7 @@ void __init init_vdso_image(const struct vdso_image *image)
 
 struct linux_binprm;
 
-static int vdso_fault(const struct vm_special_mapping *sm,
+static vm_fault_t vdso_fault(const struct vm_special_mapping *sm,
 		      struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	const struct vdso_image *image = vma->vm_mm->context.vdso_image;
@@ -84,7 +84,7 @@ static int vdso_mremap(const struct vm_special_mapping *sm,
 	return 0;
 }
 
-static int vvar_fault(const struct vm_special_mapping *sm,
+static vm_fault_t vvar_fault(const struct vm_special_mapping *sm,
 		      struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	const struct vdso_image *image = vma->vm_mm->context.vdso_image;
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index fd84edf82252..5d820b88a129 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -204,7 +204,7 @@ static void fill_sig_info_pkey(int si_signo, int si_code, siginfo_t *info,
 
 static void
 force_sig_info_fault(int si_signo, int si_code, unsigned long address,
-		     struct task_struct *tsk, u32 *pkey, int fault)
+		     struct task_struct *tsk, u32 *pkey, vm_fault_t fault)
 {
 	unsigned lsb = 0;
 	siginfo_t info;
@@ -976,7 +976,7 @@ bad_area_access_error(struct pt_regs *regs, unsigned long error_code,
 
 static void
 do_sigbus(struct pt_regs *regs, unsigned long error_code, unsigned long address,
-	  u32 *pkey, unsigned int fault)
+	  u32 *pkey, vm_fault_t fault)
 {
 	struct task_struct *tsk = current;
 	int code = BUS_ADRERR;
@@ -1008,7 +1008,7 @@ do_sigbus(struct pt_regs *regs, unsigned long error_code, unsigned long address,
 
 static noinline void
 mm_fault_error(struct pt_regs *regs, unsigned long error_code,
-	       unsigned long address, u32 *pkey, unsigned int fault)
+	       unsigned long address, u32 *pkey, vm_fault_t fault)
 {
 	if (fatal_signal_pending(current) && !(error_code & X86_PF_USER)) {
 		no_context(regs, error_code, address, 0, 0);
@@ -1222,7 +1222,8 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	struct vm_area_struct *vma;
 	struct task_struct *tsk;
 	struct mm_struct *mm;
-	int fault, major = 0;
+	int major = 0;
+	vm_fault_t fault;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 	u32 pkey;
 
@@ -1401,7 +1402,7 @@ __do_page_fault(struct pt_regs *regs, unsigned long error_code,
 	 */
 	pkey = vma_pkey(vma);
 	fault = handle_mm_fault(vma, address, flags);
-	major |= fault & VM_FAULT_MAJOR;
+	major |= !!(fault & VM_FAULT_MAJOR);
 
 	/*
 	 * If we need to retry the mmap_sem has already been released,
diff --git a/arch/xtensa/mm/fault.c b/arch/xtensa/mm/fault.c
index c111a833205a..2ab0e0dcd166 100644
--- a/arch/xtensa/mm/fault.c
+++ b/arch/xtensa/mm/fault.c
@@ -42,7 +42,7 @@ void do_page_fault(struct pt_regs *regs)
 	int code;
 
 	int is_write, is_exec;
-	int fault;
+	vm_fault_t fault;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
 	code = SEGV_MAPERR;
diff --git a/drivers/dax/device.c b/drivers/dax/device.c
index aff2c1594220..bf88e5df0cdb 100644
--- a/drivers/dax/device.c
+++ b/drivers/dax/device.c
@@ -244,11 +244,12 @@ __weak phys_addr_t dax_pgoff_to_phys(struct dev_dax *dev_dax, pgoff_t pgoff,
 	return -1;
 }
 
-static int __dev_dax_pte_fault(struct dev_dax *dev_dax, struct vm_fault *vmf)
+static vm_fault_t __dev_dax_pte_fault(struct dev_dax *dev_dax,
+		struct vm_fault *vmf)
 {
 	struct device *dev = &dev_dax->dev;
 	struct dax_region *dax_region;
-	int rc = VM_FAULT_SIGBUS;
+	vm_fault_t rc = VM_FAULT_SIGBUS;
 	phys_addr_t phys;
 	pfn_t pfn;
 	unsigned int fault_size = PAGE_SIZE;
@@ -284,7 +285,8 @@ static int __dev_dax_pte_fault(struct dev_dax *dev_dax, struct vm_fault *vmf)
 	return VM_FAULT_NOPAGE;
 }
 
-static int __dev_dax_pmd_fault(struct dev_dax *dev_dax, struct vm_fault *vmf)
+static vm_fault_t __dev_dax_pmd_fault(struct dev_dax *dev_dax,
+		struct vm_fault *vmf)
 {
 	unsigned long pmd_addr = vmf->address & PMD_MASK;
 	struct device *dev = &dev_dax->dev;
@@ -334,7 +336,8 @@ static int __dev_dax_pmd_fault(struct dev_dax *dev_dax, struct vm_fault *vmf)
 }
 
 #ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
-static int __dev_dax_pud_fault(struct dev_dax *dev_dax, struct vm_fault *vmf)
+static vm_fault_t __dev_dax_pud_fault(struct dev_dax *dev_dax,
+		struct vm_fault *vmf)
 {
 	unsigned long pud_addr = vmf->address & PUD_MASK;
 	struct device *dev = &dev_dax->dev;
@@ -384,16 +387,18 @@ static int __dev_dax_pud_fault(struct dev_dax *dev_dax, struct vm_fault *vmf)
 			vmf->flags & FAULT_FLAG_WRITE);
 }
 #else
-static int __dev_dax_pud_fault(struct dev_dax *dev_dax, struct vm_fault *vmf)
+static vm_fault_t __dev_dax_pud_fault(struct dev_dax *dev_dax,
+		struct vm_fault *vmf)
 {
 	return VM_FAULT_FALLBACK;
 }
 #endif /* !CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD */
 
-static int dev_dax_huge_fault(struct vm_fault *vmf,
+static vm_fault_t dev_dax_huge_fault(struct vm_fault *vmf,
 		enum page_entry_size pe_size)
 {
-	int rc, id;
+	vm_fault_t rc;
+	int id;
 	struct file *filp = vmf->vma->vm_file;
 	struct dev_dax *dev_dax = filp->private_data;
 
@@ -420,7 +425,7 @@ static int dev_dax_huge_fault(struct vm_fault *vmf,
 	return rc;
 }
 
-static int dev_dax_fault(struct vm_fault *vmf)
+static vm_fault_t dev_dax_fault(struct vm_fault *vmf)
 {
 	return dev_dax_huge_fault(vmf, PE_SIZE_PTE);
 }
diff --git a/drivers/gpu/drm/drm_vm.c b/drivers/gpu/drm/drm_vm.c
index 2660543ad86a..c3301046dfaa 100644
--- a/drivers/gpu/drm/drm_vm.c
+++ b/drivers/gpu/drm/drm_vm.c
@@ -100,7 +100,7 @@ static pgprot_t drm_dma_prot(uint32_t map_type, struct vm_area_struct *vma)
  * map, get the page, increment the use count and return it.
  */
 #if IS_ENABLED(CONFIG_AGP)
-static int drm_vm_fault(struct vm_fault *vmf)
+static vm_fault_t drm_vm_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct drm_file *priv = vma->vm_file->private_data;
@@ -173,7 +173,7 @@ static int drm_vm_fault(struct vm_fault *vmf)
 	return VM_FAULT_SIGBUS;	/* Disallow mremap */
 }
 #else
-static int drm_vm_fault(struct vm_fault *vmf)
+static vm_fault_t drm_vm_fault(struct vm_fault *vmf)
 {
 	return VM_FAULT_SIGBUS;
 }
@@ -189,7 +189,7 @@ static int drm_vm_fault(struct vm_fault *vmf)
  * Get the mapping, find the real physical page to map, get the page, and
  * return it.
  */
-static int drm_vm_shm_fault(struct vm_fault *vmf)
+static vm_fault_t drm_vm_shm_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct drm_local_map *map = vma->vm_private_data;
@@ -291,7 +291,7 @@ static void drm_vm_shm_close(struct vm_area_struct *vma)
  *
  * Determine the page number from the page offset and get it from drm_device_dma::pagelist.
  */
-static int drm_vm_dma_fault(struct vm_fault *vmf)
+static vm_fault_t drm_vm_dma_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct drm_file *priv = vma->vm_file->private_data;
@@ -326,7 +326,7 @@ static int drm_vm_dma_fault(struct vm_fault *vmf)
  *
  * Determine the map offset from the page offset and get it from drm_sg_mem::pagelist.
  */
-static int drm_vm_sg_fault(struct vm_fault *vmf)
+static vm_fault_t drm_vm_sg_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct drm_local_map *map = vma->vm_private_data;
diff --git a/drivers/gpu/drm/etnaviv/etnaviv_drv.h b/drivers/gpu/drm/etnaviv/etnaviv_drv.h
index 763cf5bf8eae..54183c1d3fef 100644
--- a/drivers/gpu/drm/etnaviv/etnaviv_drv.h
+++ b/drivers/gpu/drm/etnaviv/etnaviv_drv.h
@@ -64,7 +64,7 @@ int etnaviv_ioctl_gem_submit(struct drm_device *dev, void *data,
 		struct drm_file *file);
 
 int etnaviv_gem_mmap(struct file *filp, struct vm_area_struct *vma);
-int etnaviv_gem_fault(struct vm_fault *vmf);
+vm_fault_t etnaviv_gem_fault(struct vm_fault *vmf);
 int etnaviv_gem_mmap_offset(struct drm_gem_object *obj, u64 *offset);
 struct sg_table *etnaviv_gem_prime_get_sg_table(struct drm_gem_object *obj);
 void *etnaviv_gem_prime_vmap(struct drm_gem_object *obj);
diff --git a/drivers/gpu/drm/etnaviv/etnaviv_gem.c b/drivers/gpu/drm/etnaviv/etnaviv_gem.c
index fcc969fa0e69..8eead441f710 100644
--- a/drivers/gpu/drm/etnaviv/etnaviv_gem.c
+++ b/drivers/gpu/drm/etnaviv/etnaviv_gem.c
@@ -180,7 +180,7 @@ int etnaviv_gem_mmap(struct file *filp, struct vm_area_struct *vma)
 	return obj->ops->mmap(obj, vma);
 }
 
-int etnaviv_gem_fault(struct vm_fault *vmf)
+vm_fault_t etnaviv_gem_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct drm_gem_object *obj = vma->vm_private_data;
diff --git a/drivers/gpu/drm/exynos/exynos_drm_gem.c b/drivers/gpu/drm/exynos/exynos_drm_gem.c
index 11cc01b47bc0..d3e4566e27bc 100644
--- a/drivers/gpu/drm/exynos/exynos_drm_gem.c
+++ b/drivers/gpu/drm/exynos/exynos_drm_gem.c
@@ -431,7 +431,7 @@ int exynos_drm_gem_dumb_create(struct drm_file *file_priv,
 	return 0;
 }
 
-int exynos_drm_gem_fault(struct vm_fault *vmf)
+vm_fault_t exynos_drm_gem_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct drm_gem_object *obj = vma->vm_private_data;
diff --git a/drivers/gpu/drm/exynos/exynos_drm_gem.h b/drivers/gpu/drm/exynos/exynos_drm_gem.h
index 5a4c7de80f65..6c40b975d909 100644
--- a/drivers/gpu/drm/exynos/exynos_drm_gem.h
+++ b/drivers/gpu/drm/exynos/exynos_drm_gem.h
@@ -111,7 +111,7 @@ int exynos_drm_gem_dumb_create(struct drm_file *file_priv,
 			       struct drm_mode_create_dumb *args);
 
 /* page fault handler and mmap fault address(virtual) to physical memory. */
-int exynos_drm_gem_fault(struct vm_fault *vmf);
+vm_fault_t exynos_drm_gem_fault(struct vm_fault *vmf);
 
 /* set vm_flags and we can change the vm attribute to other one at here. */
 int exynos_drm_gem_mmap(struct file *filp, struct vm_area_struct *vma);
diff --git a/drivers/gpu/drm/gma500/framebuffer.c b/drivers/gpu/drm/gma500/framebuffer.c
index cb0a2ae916e0..d76275a0daac 100644
--- a/drivers/gpu/drm/gma500/framebuffer.c
+++ b/drivers/gpu/drm/gma500/framebuffer.c
@@ -111,7 +111,7 @@ static int psbfb_pan(struct fb_var_screeninfo *var, struct fb_info *info)
         return 0;
 }
 
-static int psbfb_vm_fault(struct vm_fault *vmf)
+static vm_fault_t psbfb_vm_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct psb_framebuffer *psbfb = vma->vm_private_data;
@@ -138,8 +138,8 @@ static int psbfb_vm_fault(struct vm_fault *vmf)
 		if (unlikely((ret == -EBUSY) || (ret != 0 && i > 0)))
 			break;
 		else if (unlikely(ret != 0)) {
-			ret = (ret == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS;
-			return ret;
+			return (ret == -ENOMEM) ?
+				VM_FAULT_OOM : VM_FAULT_SIGBUS;
 		}
 		address += PAGE_SIZE;
 		phys_addr += PAGE_SIZE;
diff --git a/drivers/gpu/drm/gma500/gem.c b/drivers/gpu/drm/gma500/gem.c
index 131239759a75..2b7a394fc9b3 100644
--- a/drivers/gpu/drm/gma500/gem.c
+++ b/drivers/gpu/drm/gma500/gem.c
@@ -134,7 +134,7 @@ int psb_gem_dumb_create(struct drm_file *file, struct drm_device *dev,
  *	vma->vm_private_data points to the GEM object that is backing this
  *	mapping.
  */
-int psb_gem_fault(struct vm_fault *vmf)
+vm_fault_t psb_gem_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct drm_gem_object *obj;
diff --git a/drivers/gpu/drm/gma500/psb_drv.h b/drivers/gpu/drm/gma500/psb_drv.h
index e8300f509023..48ab91e59e1e 100644
--- a/drivers/gpu/drm/gma500/psb_drv.h
+++ b/drivers/gpu/drm/gma500/psb_drv.h
@@ -749,7 +749,7 @@ extern int psb_gem_get_aperture(struct drm_device *dev, void *data,
 			struct drm_file *file);
 extern int psb_gem_dumb_create(struct drm_file *file, struct drm_device *dev,
 			struct drm_mode_create_dumb *args);
-extern int psb_gem_fault(struct vm_fault *vmf);
+extern vm_fault_t psb_gem_fault(struct vm_fault *vmf);
 
 /* psb_device.c */
 extern const struct psb_ops psb_chip_ops;
diff --git a/drivers/gpu/drm/i915/i915_drv.h b/drivers/gpu/drm/i915/i915_drv.h
index 34c125e2d90c..1830d96a16e4 100644
--- a/drivers/gpu/drm/i915/i915_drv.h
+++ b/drivers/gpu/drm/i915/i915_drv.h
@@ -3169,7 +3169,7 @@ int i915_gem_wait_for_idle(struct drm_i915_private *dev_priv,
 			   unsigned int flags);
 int __must_check i915_gem_suspend(struct drm_i915_private *dev_priv);
 void i915_gem_resume(struct drm_i915_private *dev_priv);
-int i915_gem_fault(struct vm_fault *vmf);
+vm_fault_t i915_gem_fault(struct vm_fault *vmf);
 int i915_gem_object_wait(struct drm_i915_gem_object *obj,
 			 unsigned int flags,
 			 long timeout,
diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index 0a2070112b66..1231bdd52b7f 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -1991,7 +1991,7 @@ compute_partial_view(struct drm_i915_gem_object *obj,
  * The current feature set supported by i915_gem_fault() and thus GTT mmaps
  * is exposed via I915_PARAM_MMAP_GTT_VERSION (see i915_gem_mmap_gtt_version).
  */
-int i915_gem_fault(struct vm_fault *vmf)
+vm_fault_t i915_gem_fault(struct vm_fault *vmf)
 {
 #define MIN_CHUNK_PAGES ((1 << 20) >> PAGE_SHIFT) /* 1 MiB */
 	struct vm_area_struct *area = vmf->vma;
@@ -2108,10 +2108,8 @@ int i915_gem_fault(struct vm_fault *vmf)
 		 * fail). But any other -EIO isn't ours (e.g. swap in failure)
 		 * and so needs to be reported.
 		 */
-		if (!i915_terminally_wedged(&dev_priv->gpu_error)) {
-			ret = VM_FAULT_SIGBUS;
-			break;
-		}
+		if (!i915_terminally_wedged(&dev_priv->gpu_error))
+			return VM_FAULT_SIGBUS;
 	case -EAGAIN:
 		/*
 		 * EAGAIN means the gpu is hung and we'll wait for the error
@@ -2126,21 +2124,16 @@ int i915_gem_fault(struct vm_fault *vmf)
 		 * EBUSY is ok: this just means that another thread
 		 * already did the job.
 		 */
-		ret = VM_FAULT_NOPAGE;
-		break;
+		return VM_FAULT_NOPAGE;
 	case -ENOMEM:
-		ret = VM_FAULT_OOM;
-		break;
+		return VM_FAULT_OOM;
 	case -ENOSPC:
 	case -EFAULT:
-		ret = VM_FAULT_SIGBUS;
-		break;
+		return VM_FAULT_SIGBUS;
 	default:
 		WARN_ONCE(ret, "unhandled error in i915_gem_fault: %i\n", ret);
-		ret = VM_FAULT_SIGBUS;
-		break;
+		return VM_FAULT_SIGBUS;
 	}
-	return ret;
 }
 
 static void __i915_gem_object_release_mmap(struct drm_i915_gem_object *obj)
diff --git a/drivers/gpu/drm/msm/msm_drv.h b/drivers/gpu/drm/msm/msm_drv.h
index b2da1fbf81e0..a92de7bc7722 100644
--- a/drivers/gpu/drm/msm/msm_drv.h
+++ b/drivers/gpu/drm/msm/msm_drv.h
@@ -184,7 +184,7 @@ void msm_gem_shrinker_cleanup(struct drm_device *dev);
 int msm_gem_mmap_obj(struct drm_gem_object *obj,
 			struct vm_area_struct *vma);
 int msm_gem_mmap(struct file *filp, struct vm_area_struct *vma);
-int msm_gem_fault(struct vm_fault *vmf);
+vm_fault_t msm_gem_fault(struct vm_fault *vmf);
 uint64_t msm_gem_mmap_offset(struct drm_gem_object *obj);
 int msm_gem_get_iova(struct drm_gem_object *obj,
 		struct msm_gem_address_space *aspace, uint64_t *iova);
diff --git a/drivers/gpu/drm/msm/msm_gem.c b/drivers/gpu/drm/msm/msm_gem.c
index f583bb4222f9..27e55d19b3de 100644
--- a/drivers/gpu/drm/msm/msm_gem.c
+++ b/drivers/gpu/drm/msm/msm_gem.c
@@ -219,7 +219,7 @@ int msm_gem_mmap(struct file *filp, struct vm_area_struct *vma)
 	return msm_gem_mmap_obj(vma->vm_private_data, vma);
 }
 
-int msm_gem_fault(struct vm_fault *vmf)
+vm_fault_t msm_gem_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct drm_gem_object *obj = vma->vm_private_data;
diff --git a/drivers/gpu/drm/qxl/qxl_ttm.c b/drivers/gpu/drm/qxl/qxl_ttm.c
index ee2340e31f06..4a7d76d7cc70 100644
--- a/drivers/gpu/drm/qxl/qxl_ttm.c
+++ b/drivers/gpu/drm/qxl/qxl_ttm.c
@@ -105,10 +105,10 @@ static void qxl_ttm_global_fini(struct qxl_device *qdev)
 static struct vm_operations_struct qxl_ttm_vm_ops;
 static const struct vm_operations_struct *ttm_vm_ops;
 
-static int qxl_ttm_fault(struct vm_fault *vmf)
+static vm_fault_t qxl_ttm_fault(struct vm_fault *vmf)
 {
 	struct ttm_buffer_object *bo;
-	int r;
+	vm_fault_t r;
 
 	bo = (struct ttm_buffer_object *)vmf->vma->vm_private_data;
 	if (bo == NULL)
diff --git a/drivers/gpu/drm/radeon/radeon_ttm.c b/drivers/gpu/drm/radeon/radeon_ttm.c
index 8689fcca051c..7d3bf1e2ac83 100644
--- a/drivers/gpu/drm/radeon/radeon_ttm.c
+++ b/drivers/gpu/drm/radeon/radeon_ttm.c
@@ -947,7 +947,7 @@ void radeon_ttm_set_active_vram_size(struct radeon_device *rdev, u64 size)
 static struct vm_operations_struct radeon_ttm_vm_ops;
 static const struct vm_operations_struct *ttm_vm_ops = NULL;
 
-static int radeon_ttm_fault(struct vm_fault *vmf)
+static vm_fault_t radeon_ttm_fault(struct vm_fault *vmf)
 {
 	struct ttm_buffer_object *bo;
 	struct radeon_device *rdev;
diff --git a/drivers/gpu/drm/udl/udl_drv.h b/drivers/gpu/drm/udl/udl_drv.h
index 55c0cc309198..4151c5bc031d 100644
--- a/drivers/gpu/drm/udl/udl_drv.h
+++ b/drivers/gpu/drm/udl/udl_drv.h
@@ -136,7 +136,7 @@ void udl_gem_put_pages(struct udl_gem_object *obj);
 int udl_gem_vmap(struct udl_gem_object *obj);
 void udl_gem_vunmap(struct udl_gem_object *obj);
 int udl_drm_gem_mmap(struct file *filp, struct vm_area_struct *vma);
-int udl_gem_fault(struct vm_fault *vmf);
+vm_fault_t udl_gem_fault(struct vm_fault *vmf);
 
 int udl_handle_damage(struct udl_framebuffer *fb, int x, int y,
 		      int width, int height);
diff --git a/drivers/gpu/drm/udl/udl_gem.c b/drivers/gpu/drm/udl/udl_gem.c
index 9a15cce22cce..9bac8de2e826 100644
--- a/drivers/gpu/drm/udl/udl_gem.c
+++ b/drivers/gpu/drm/udl/udl_gem.c
@@ -100,7 +100,7 @@ int udl_drm_gem_mmap(struct file *filp, struct vm_area_struct *vma)
 	return ret;
 }
 
-int udl_gem_fault(struct vm_fault *vmf)
+vm_fault_t udl_gem_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct udl_gem_object *obj = to_udl_bo(vma->vm_private_data);
diff --git a/drivers/gpu/drm/vc4/vc4_bo.c b/drivers/gpu/drm/vc4/vc4_bo.c
index add9cc97a3b6..8dcce7182bb7 100644
--- a/drivers/gpu/drm/vc4/vc4_bo.c
+++ b/drivers/gpu/drm/vc4/vc4_bo.c
@@ -721,7 +721,7 @@ vc4_prime_export(struct drm_device *dev, struct drm_gem_object *obj, int flags)
 	return dmabuf;
 }
 
-int vc4_fault(struct vm_fault *vmf)
+vm_fault_t vc4_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct drm_gem_object *obj = vma->vm_private_data;
diff --git a/drivers/gpu/drm/vc4/vc4_drv.h b/drivers/gpu/drm/vc4/vc4_drv.h
index 22589d39083c..dfda2b2aa3a2 100644
--- a/drivers/gpu/drm/vc4/vc4_drv.h
+++ b/drivers/gpu/drm/vc4/vc4_drv.h
@@ -673,7 +673,7 @@ int vc4_get_hang_state_ioctl(struct drm_device *dev, void *data,
 			     struct drm_file *file_priv);
 int vc4_label_bo_ioctl(struct drm_device *dev, void *data,
 		       struct drm_file *file_priv);
-int vc4_fault(struct vm_fault *vmf);
+vm_fault_t vc4_fault(struct vm_fault *vmf);
 int vc4_mmap(struct file *filp, struct vm_area_struct *vma);
 struct reservation_object *vc4_prime_res_obj(struct drm_gem_object *obj);
 int vc4_prime_mmap(struct drm_gem_object *obj, struct vm_area_struct *vma);
diff --git a/drivers/hwtracing/intel_th/msu.c b/drivers/hwtracing/intel_th/msu.c
index ede388309376..d08b7988e963 100644
--- a/drivers/hwtracing/intel_th/msu.c
+++ b/drivers/hwtracing/intel_th/msu.c
@@ -1182,7 +1182,7 @@ static void msc_mmap_close(struct vm_area_struct *vma)
 	mutex_unlock(&msc->buf_mutex);
 }
 
-static int msc_mmap_fault(struct vm_fault *vmf)
+static vm_fault_t msc_mmap_fault(struct vm_fault *vmf)
 {
 	struct msc_iter *iter = vmf->vma->vm_file->private_data;
 	struct msc *msc = iter->msc;
diff --git a/drivers/iommu/amd_iommu_v2.c b/drivers/iommu/amd_iommu_v2.c
index 1d0b53a04a08..58da65df03f5 100644
--- a/drivers/iommu/amd_iommu_v2.c
+++ b/drivers/iommu/amd_iommu_v2.c
@@ -508,7 +508,7 @@ static void do_fault(struct work_struct *work)
 {
 	struct fault *fault = container_of(work, struct fault, work);
 	struct vm_area_struct *vma;
-	int ret = VM_FAULT_ERROR;
+	vm_fault_t ret = VM_FAULT_ERROR;
 	unsigned int flags = 0;
 	struct mm_struct *mm;
 	u64 address;
diff --git a/drivers/iommu/intel-svm.c b/drivers/iommu/intel-svm.c
index e8cd984cf9c8..a65c87546560 100644
--- a/drivers/iommu/intel-svm.c
+++ b/drivers/iommu/intel-svm.c
@@ -594,7 +594,8 @@ static irqreturn_t prq_event_thread(int irq, void *d)
 		struct vm_area_struct *vma;
 		struct page_req_dsc *req;
 		struct qi_desc resp;
-		int ret, result;
+		int result;
+		vm_fault_t ret;
 		u64 address;
 
 		handled = 1;
diff --git a/drivers/misc/cxl/fault.c b/drivers/misc/cxl/fault.c
index 70dbb6de102c..93ecc67a0f3b 100644
--- a/drivers/misc/cxl/fault.c
+++ b/drivers/misc/cxl/fault.c
@@ -134,7 +134,7 @@ static int cxl_handle_segment_miss(struct cxl_context *ctx,
 
 int cxl_handle_mm_fault(struct mm_struct *mm, u64 dsisr, u64 dar)
 {
-	unsigned flt = 0;
+	vm_fault_t flt = 0;
 	int result;
 	unsigned long access, flags, inv_flags = 0;
 
diff --git a/drivers/misc/ocxl/context.c b/drivers/misc/ocxl/context.c
index 909e8807824a..16c5157e570e 100644
--- a/drivers/misc/ocxl/context.c
+++ b/drivers/misc/ocxl/context.c
@@ -83,7 +83,7 @@ int ocxl_context_attach(struct ocxl_context *ctx, u64 amr)
 	return rc;
 }
 
-static int map_afu_irq(struct vm_area_struct *vma, unsigned long address,
+static vm_fault_t map_afu_irq(struct vm_area_struct *vma, unsigned long address,
 		u64 offset, struct ocxl_context *ctx)
 {
 	u64 trigger_addr;
@@ -96,7 +96,7 @@ static int map_afu_irq(struct vm_area_struct *vma, unsigned long address,
 	return VM_FAULT_NOPAGE;
 }
 
-static int map_pp_mmio(struct vm_area_struct *vma, unsigned long address,
+static vm_fault_t map_pp_mmio(struct vm_area_struct *vma, unsigned long address,
 		u64 offset, struct ocxl_context *ctx)
 {
 	u64 pp_mmio_addr;
@@ -123,7 +123,7 @@ static int map_pp_mmio(struct vm_area_struct *vma, unsigned long address,
 	return VM_FAULT_NOPAGE;
 }
 
-static int ocxl_mmap_fault(struct vm_fault *vmf)
+static vm_fault_t ocxl_mmap_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct ocxl_context *ctx = vma->vm_file->private_data;
diff --git a/drivers/misc/ocxl/link.c b/drivers/misc/ocxl/link.c
index f30790582dc0..9e159c9971f3 100644
--- a/drivers/misc/ocxl/link.c
+++ b/drivers/misc/ocxl/link.c
@@ -126,7 +126,7 @@ static void ack_irq(struct spa *spa, enum xsl_response r)
 
 static void xsl_fault_handler_bh(struct work_struct *fault_work)
 {
-	unsigned int flt = 0;
+	vm_fault_t flt = 0;
 	unsigned long access, flags, inv_flags = 0;
 	enum xsl_response r;
 	struct xsl_fault *fault = container_of(fault_work, struct xsl_fault,
diff --git a/drivers/misc/ocxl/sysfs.c b/drivers/misc/ocxl/sysfs.c
index d9753a1db14b..c92a2100dcdd 100644
--- a/drivers/misc/ocxl/sysfs.c
+++ b/drivers/misc/ocxl/sysfs.c
@@ -64,7 +64,7 @@ static ssize_t global_mmio_read(struct file *filp, struct kobject *kobj,
 	return count;
 }
 
-static int global_mmio_fault(struct vm_fault *vmf)
+static vm_fault_t global_mmio_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct ocxl_afu *afu = vma->vm_private_data;
diff --git a/drivers/scsi/cxlflash/superpipe.c b/drivers/scsi/cxlflash/superpipe.c
index 04a3bf9dc85f..9d663b5793d6 100644
--- a/drivers/scsi/cxlflash/superpipe.c
+++ b/drivers/scsi/cxlflash/superpipe.c
@@ -1101,7 +1101,7 @@ static struct page *get_err_page(struct cxlflash_cfg *cfg)
  *
  * Return: 0 on success, VM_FAULT_SIGBUS on failure
  */
-static int cxlflash_mmap_fault(struct vm_fault *vmf)
+static vm_fault_t cxlflash_mmap_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct file *file = vma->vm_file;
@@ -1112,7 +1112,7 @@ static int cxlflash_mmap_fault(struct vm_fault *vmf)
 	struct ctx_info *ctxi = NULL;
 	struct page *err_page = NULL;
 	enum ctx_ctrl ctrl = CTX_CTRL_ERR_FALLBACK | CTX_CTRL_FILE;
-	int rc = 0;
+	vm_fault_t rc = 0;
 	int ctxid;
 
 	ctxid = cfg->ops->process_element(ctx);
diff --git a/drivers/staging/ncpfs/mmap.c b/drivers/staging/ncpfs/mmap.c
index a5c5cf2ff007..d2182dd67403 100644
--- a/drivers/staging/ncpfs/mmap.c
+++ b/drivers/staging/ncpfs/mmap.c
@@ -28,7 +28,7 @@
  * XXX: how are we excluding truncate/invalidate here? Maybe need to lock
  * page?
  */
-static int ncp_file_mmap_fault(struct vm_fault *vmf)
+static vm_fault_t ncp_file_mmap_fault(struct vm_fault *vmf)
 {
 	struct inode *inode = file_inode(vmf->vma->vm_file);
 	char *pg_addr;
diff --git a/drivers/xen/privcmd.c b/drivers/xen/privcmd.c
index 1c909183c42a..0a778d30d333 100644
--- a/drivers/xen/privcmd.c
+++ b/drivers/xen/privcmd.c
@@ -801,7 +801,7 @@ static void privcmd_close(struct vm_area_struct *vma)
 	kfree(pages);
 }
 
-static int privcmd_fault(struct vm_fault *vmf)
+static vm_fault_t privcmd_fault(struct vm_fault *vmf)
 {
 	printk(KERN_DEBUG "privcmd_fault: vma=%p %lx-%lx, pgoff=%lx, uv=%p\n",
 	       vmf->vma, vmf->vma->vm_start, vmf->vma->vm_end,
diff --git a/fs/9p/vfs_file.c b/fs/9p/vfs_file.c
index 03c9e325bfbc..5f2e48d41d72 100644
--- a/fs/9p/vfs_file.c
+++ b/fs/9p/vfs_file.c
@@ -533,7 +533,7 @@ v9fs_mmap_file_mmap(struct file *filp, struct vm_area_struct *vma)
 	return retval;
 }
 
-static int
+static vm_fault_t
 v9fs_vm_page_mkwrite(struct vm_fault *vmf)
 {
 	struct v9fs_inode *v9inode;
diff --git a/fs/afs/internal.h b/fs/afs/internal.h
index f8086ec95e24..eca8ab11c165 100644
--- a/fs/afs/internal.h
+++ b/fs/afs/internal.h
@@ -1028,7 +1028,7 @@ extern int afs_writepages(struct address_space *, struct writeback_control *);
 extern void afs_pages_written_back(struct afs_vnode *, struct afs_call *);
 extern ssize_t afs_file_write(struct kiocb *, struct iov_iter *);
 extern int afs_fsync(struct file *, loff_t, loff_t, int);
-extern int afs_page_mkwrite(struct vm_fault *);
+extern vm_fault_t afs_page_mkwrite(struct vm_fault *);
 extern void afs_prune_wb_keys(struct afs_vnode *);
 extern int afs_launder_page(struct page *);
 
diff --git a/fs/afs/write.c b/fs/afs/write.c
index c164698dc304..f5ae8c6ded00 100644
--- a/fs/afs/write.c
+++ b/fs/afs/write.c
@@ -753,7 +753,7 @@ int afs_fsync(struct file *file, loff_t start, loff_t end, int datasync)
  * notification that a previously read-only page is about to become writable
  * - if it returns an error, the caller will deliver a bus error signal
  */
-int afs_page_mkwrite(struct vm_fault *vmf)
+vm_fault_t afs_page_mkwrite(struct vm_fault *vmf)
 {
 	struct file *file = vmf->vma->vm_file;
 	struct inode *inode = file_inode(file);
diff --git a/fs/f2fs/file.c b/fs/f2fs/file.c
index cc08956334a0..2d7347ddedde 100644
--- a/fs/f2fs/file.c
+++ b/fs/f2fs/file.c
@@ -33,19 +33,19 @@
 #include "trace.h"
 #include <trace/events/f2fs.h>
 
-static int f2fs_filemap_fault(struct vm_fault *vmf)
+static vm_fault_t f2fs_filemap_fault(struct vm_fault *vmf)
 {
 	struct inode *inode = file_inode(vmf->vma->vm_file);
-	int err;
+	vm_fault_t ret;
 
 	down_read(&F2FS_I(inode)->i_mmap_sem);
-	err = filemap_fault(vmf);
+	ret = filemap_fault(vmf);
 	up_read(&F2FS_I(inode)->i_mmap_sem);
 
-	return err;
+	return ret;
 }
 
-static int f2fs_vm_page_mkwrite(struct vm_fault *vmf)
+static vm_fault_t f2fs_vm_page_mkwrite(struct vm_fault *vmf)
 {
 	struct page *page = vmf->page;
 	struct inode *inode = file_inode(vmf->vma->vm_file);
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index a201fb0ac64f..67648ccbdd43 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -2048,7 +2048,7 @@ static void fuse_vma_close(struct vm_area_struct *vma)
  * - sync(2)
  * - try_to_free_pages() with order > PAGE_ALLOC_COSTLY_ORDER
  */
-static int fuse_page_mkwrite(struct vm_fault *vmf)
+static vm_fault_t fuse_page_mkwrite(struct vm_fault *vmf)
 {
 	struct page *page = vmf->page;
 	struct inode *inode = file_inode(vmf->vma->vm_file);
diff --git a/fs/gfs2/file.c b/fs/gfs2/file.c
index 4b71f021a9e2..789f2e210177 100644
--- a/fs/gfs2/file.c
+++ b/fs/gfs2/file.c
@@ -387,7 +387,7 @@ static int gfs2_allocate_page_backing(struct page *page)
  * blocks allocated on disk to back that page.
  */
 
-static int gfs2_page_mkwrite(struct vm_fault *vmf)
+static vm_fault_t gfs2_page_mkwrite(struct vm_fault *vmf)
 {
 	struct page *page = vmf->page;
 	struct inode *inode = file_inode(vmf->vma->vm_file);
diff --git a/fs/iomap.c b/fs/iomap.c
index d193390a1c20..24aa0cb3d1aa 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -444,7 +444,7 @@ iomap_page_mkwrite_actor(struct inode *inode, loff_t pos, loff_t length,
 	return length;
 }
 
-int iomap_page_mkwrite(struct vm_fault *vmf, const struct iomap_ops *ops)
+vm_fault_t iomap_page_mkwrite(struct vm_fault *vmf, const struct iomap_ops *ops)
 {
 	struct page *page = vmf->page;
 	struct inode *inode = file_inode(vmf->vma->vm_file);
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 81cca49a8375..29553fdba8af 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -532,13 +532,13 @@ const struct address_space_operations nfs_file_aops = {
  * writable, implying that someone is about to modify the page through a
  * shared-writable mapping
  */
-static int nfs_vm_page_mkwrite(struct vm_fault *vmf)
+static vm_fault_t nfs_vm_page_mkwrite(struct vm_fault *vmf)
 {
 	struct page *page = vmf->page;
 	struct file *filp = vmf->vma->vm_file;
 	struct inode *inode = file_inode(filp);
 	unsigned pagelen;
-	int ret = VM_FAULT_NOPAGE;
+	vm_fault_t ret = VM_FAULT_NOPAGE;
 	struct address_space *mapping;
 
 	dfprintk(PAGECACHE, "NFS: vm_page_mkwrite(%pD2(%lu), offset %lld)\n",
diff --git a/fs/nilfs2/file.c b/fs/nilfs2/file.c
index c5fa3dee72fc..7da0fac71dc2 100644
--- a/fs/nilfs2/file.c
+++ b/fs/nilfs2/file.c
@@ -51,7 +51,7 @@ int nilfs_sync_file(struct file *file, loff_t start, loff_t end, int datasync)
 	return err;
 }
 
-static int nilfs_page_mkwrite(struct vm_fault *vmf)
+static vm_fault_t nilfs_page_mkwrite(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct page *page = vmf->page;
diff --git a/fs/proc/vmcore.c b/fs/proc/vmcore.c
index 247c3499e5bd..ef08a35f6a8c 100644
--- a/fs/proc/vmcore.c
+++ b/fs/proc/vmcore.c
@@ -379,7 +379,7 @@ static ssize_t read_vmcore(struct file *file, char __user *buffer,
  * On s390 the fault handler is used for memory regions that can't be mapped
  * directly with remap_pfn_range().
  */
-static int mmap_vmcore_fault(struct vm_fault *vmf)
+static vm_fault_t mmap_vmcore_fault(struct vm_fault *vmf)
 {
 #ifdef CONFIG_S390
 	struct address_space *mapping = vmf->vma->vm_file->f_mapping;
diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index cec550c8468f..302522375dbb 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -336,12 +336,12 @@ static inline bool userfaultfd_must_wait(struct userfaultfd_ctx *ctx,
  * fatal_signal_pending()s, and the mmap_sem must be released before
  * returning it.
  */
-int handle_userfault(struct vm_fault *vmf, unsigned long reason)
+vm_fault_t handle_userfault(struct vm_fault *vmf, unsigned long reason)
 {
 	struct mm_struct *mm = vmf->vma->vm_mm;
 	struct userfaultfd_ctx *ctx;
 	struct userfaultfd_wait_queue uwq;
-	int ret;
+	vm_fault_t ret;
 	bool must_wait, return_to_userland;
 	long blocking_state;
 
diff --git a/fs/xfs/xfs_file.c b/fs/xfs/xfs_file.c
index 521272201fb7..bed07dfbb85e 100644
--- a/fs/xfs/xfs_file.c
+++ b/fs/xfs/xfs_file.c
@@ -1080,7 +1080,7 @@ xfs_file_llseek(
  *       page_lock (MM)
  *         i_lock (XFS - extent map serialisation)
  */
-static int
+static vm_fault_t
 __xfs_filemap_fault(
 	struct vm_fault		*vmf,
 	enum page_entry_size	pe_size,
@@ -1088,7 +1088,7 @@ __xfs_filemap_fault(
 {
 	struct inode		*inode = file_inode(vmf->vma->vm_file);
 	struct xfs_inode	*ip = XFS_I(inode);
-	int			ret;
+	vm_fault_t		ret;
 
 	trace_xfs_filemap_fault(ip, pe_size, write_fault);
 
@@ -1117,7 +1117,7 @@ __xfs_filemap_fault(
 	return ret;
 }
 
-static int
+static vm_fault_t
 xfs_filemap_fault(
 	struct vm_fault		*vmf)
 {
@@ -1127,7 +1127,7 @@ xfs_filemap_fault(
 			(vmf->flags & FAULT_FLAG_WRITE));
 }
 
-static int
+static vm_fault_t
 xfs_filemap_huge_fault(
 	struct vm_fault		*vmf,
 	enum page_entry_size	pe_size)
@@ -1140,7 +1140,7 @@ xfs_filemap_huge_fault(
 			(vmf->flags & FAULT_FLAG_WRITE));
 }
 
-static int
+static vm_fault_t
 xfs_filemap_page_mkwrite(
 	struct vm_fault		*vmf)
 {
@@ -1152,7 +1152,7 @@ xfs_filemap_page_mkwrite(
  * on write faults. In reality, it needs to serialise against truncate and
  * prepare memory for writing so handle is as standard write fault.
  */
-static int
+static vm_fault_t
 xfs_filemap_pfn_mkwrite(
 	struct vm_fault		*vmf)
 {
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index a8a126259bc4..f598a826f0ac 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -6,7 +6,7 @@
 
 #include <linux/fs.h> /* only for vma_is_dax() */
 
-extern int do_huge_pmd_anonymous_page(struct vm_fault *vmf);
+extern vm_fault_t do_huge_pmd_anonymous_page(struct vm_fault *vmf);
 extern int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 			 pmd_t *dst_pmd, pmd_t *src_pmd, unsigned long addr,
 			 struct vm_area_struct *vma);
@@ -23,7 +23,7 @@ static inline void huge_pud_set_accessed(struct vm_fault *vmf, pud_t orig_pud)
 }
 #endif
 
-extern int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd);
+extern vm_fault_t do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd);
 extern struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 					  unsigned long addr,
 					  pmd_t *pmd,
@@ -46,9 +46,9 @@ extern bool move_huge_pmd(struct vm_area_struct *vma, unsigned long old_addr,
 extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			unsigned long addr, pgprot_t newprot,
 			int prot_numa);
-int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
+vm_fault_t vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 			pmd_t *pmd, pfn_t pfn, bool write);
-int vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
+vm_fault_t vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
 			pud_t *pud, pfn_t pfn, bool write);
 enum transparent_hugepage_flag {
 	TRANSPARENT_HUGEPAGE_FLAG,
@@ -216,7 +216,7 @@ struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
 struct page *follow_devmap_pud(struct vm_area_struct *vma, unsigned long addr,
 		pud_t *pud, int flags);
 
-extern int do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t orig_pmd);
+extern vm_fault_t do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t orig_pmd);
 
 extern struct page *huge_zero_page;
 
@@ -321,7 +321,8 @@ static inline spinlock_t *pud_trans_huge_lock(pud_t *pud,
 	return NULL;
 }
 
-static inline int do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t orig_pmd)
+static inline vm_fault_t do_huge_pmd_numa_page(struct vm_fault *vmf,
+		pmd_t orig_pmd)
 {
 	return 0;
 }
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 36fa6a2a82e3..c779b2ffcd8a 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -105,7 +105,7 @@ void hugetlb_report_meminfo(struct seq_file *);
 int hugetlb_report_node_meminfo(int, char *);
 void hugetlb_show_meminfo(void);
 unsigned long hugetlb_total_pages(void);
-int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
+vm_fault_t hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, unsigned int flags);
 int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm, pte_t *dst_pte,
 				struct vm_area_struct *dst_vma,
diff --git a/include/linux/iomap.h b/include/linux/iomap.h
index 4bd87294219a..5423400f6f82 100644
--- a/include/linux/iomap.h
+++ b/include/linux/iomap.h
@@ -3,6 +3,7 @@
 #define LINUX_IOMAP_H 1
 
 #include <linux/types.h>
+#include <linux/mm_types.h>
 
 struct fiemap_extent_info;
 struct inode;
@@ -88,7 +89,8 @@ int iomap_zero_range(struct inode *inode, loff_t pos, loff_t len,
 		bool *did_zero, const struct iomap_ops *ops);
 int iomap_truncate_page(struct inode *inode, loff_t pos, bool *did_zero,
 		const struct iomap_ops *ops);
-int iomap_page_mkwrite(struct vm_fault *vmf, const struct iomap_ops *ops);
+vm_fault_t iomap_page_mkwrite(struct vm_fault *vmf,
+		const struct iomap_ops *ops);
 int iomap_fiemap(struct inode *inode, struct fiemap_extent_info *fieinfo,
 		loff_t start, loff_t len, const struct iomap_ops *ops);
 loff_t iomap_seek_hole(struct inode *inode, loff_t offset,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 64d09e3afc24..574df95dfa5d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -700,10 +700,10 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
 	return pte;
 }
 
-int alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
+vm_fault_t alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
 		struct page *page);
-int finish_fault(struct vm_fault *vmf);
-int finish_mkwrite_fault(struct vm_fault *vmf);
+vm_fault_t finish_fault(struct vm_fault *vmf);
+vm_fault_t finish_mkwrite_fault(struct vm_fault *vmf);
 #endif
 
 /*
@@ -1233,29 +1233,36 @@ static inline void clear_page_pfmemalloc(struct page *page)
  * just gets major/minor fault counters bumped up.
  */
 
-#define VM_FAULT_OOM	0x0001
-#define VM_FAULT_SIGBUS	0x0002
-#define VM_FAULT_MAJOR	0x0004
-#define VM_FAULT_WRITE	0x0008	/* Special case for get_user_pages */
-#define VM_FAULT_HWPOISON 0x0010	/* Hit poisoned small page */
-#define VM_FAULT_HWPOISON_LARGE 0x0020  /* Hit poisoned large page. Index encoded in upper bits */
-#define VM_FAULT_SIGSEGV 0x0040
-
-#define VM_FAULT_NOPAGE	0x0100	/* ->fault installed the pte, not return page */
-#define VM_FAULT_LOCKED	0x0200	/* ->fault locked the returned page */
-#define VM_FAULT_RETRY	0x0400	/* ->fault blocked, must retry */
-#define VM_FAULT_FALLBACK 0x0800	/* huge page fault failed, fall back to small */
-#define VM_FAULT_DONE_COW   0x1000	/* ->fault has fully handled COW */
-#define VM_FAULT_NEEDDSYNC  0x2000	/* ->fault did not modify page tables
-					 * and needs fsync() to complete (for
-					 * synchronous page faults in DAX) */
+#define VM_FAULT_OOM		((__force vm_fault_t)0x0001)
+#define VM_FAULT_SIGBUS		((__force vm_fault_t)0x0002)
+#define VM_FAULT_MAJOR		((__force vm_fault_t)0x0004)
+/* Special case for get_user_pages */
+#define VM_FAULT_WRITE		((__force vm_fault_t)0x0008)
+/* Hit poisoned small page */
+#define VM_FAULT_HWPOISON	((__force vm_fault_t)0x0010)
+ /* Hit poisoned large page. Index encoded in upper bits */
+#define VM_FAULT_HWPOISON_LARGE ((__force vm_fault_t)0x0020)
+#define VM_FAULT_SIGSEGV	((__force vm_fault_t)0x0040)
+/* ->fault installed the pte, not return page */
+#define VM_FAULT_NOPAGE		((__force vm_fault_t)0x0100)
+/* ->fault locked the returned page */
+#define VM_FAULT_LOCKED		((__force vm_fault_t)0x0200)
+/* ->fault blocked, must retry */
+#define VM_FAULT_RETRY		((__force vm_fault_t)0x0400)
+/* huge page fault failed, fall back to small */
+#define VM_FAULT_FALLBACK	((__force vm_fault_t)0x0800)
+/* ->fault has fully handled COW */
+#define VM_FAULT_DONE_COW	((__force vm_fault_t)0x1000)
+/* ->fault did not modify page tables and needs fsync() to complete
+ * (for synchronous page faults in DAX) */
+#define VM_FAULT_NEEDDSYNC	((__force vm_fault_t)0x2000)
 
 /* Only for use in architecture specific page fault handling: */
-#define VM_FAULT_BADMAP		0x010000
-#define VM_FAULT_BADACCESS	0x020000
-#define VM_FAULT_BADCONTEXT	0x040000
-#define VM_FAULT_SIGNAL		0x080000
-#define VM_FAULT_PFAULT		0x100000
+#define VM_FAULT_BADMAP		((__force vm_fault_t)0x010000)
+#define VM_FAULT_BADACCESS	((__force vm_fault_t)0x020000)
+#define VM_FAULT_BADCONTEXT	((__force vm_fault_t)0x040000)
+#define VM_FAULT_SIGNAL		((__force vm_fault_t)0x080000)
+#define VM_FAULT_PFAULT		((__force vm_fault_t)0x100000)
 
 #define VM_FAULT_ERROR	(VM_FAULT_OOM | VM_FAULT_SIGBUS | VM_FAULT_SIGSEGV | \
 			 VM_FAULT_HWPOISON | VM_FAULT_HWPOISON_LARGE | \
@@ -1277,8 +1284,8 @@ static inline void clear_page_pfmemalloc(struct page *page)
 	{ VM_FAULT_NEEDDSYNC,		"NEEDDSYNC" }
 
 /* Encode hstate index for a hwpoisoned large page */
-#define VM_FAULT_SET_HINDEX(x) ((x) << 12)
-#define VM_FAULT_GET_HINDEX(x) (((x) >> 12) & 0xf)
+#define VM_FAULT_SET_HINDEX(x) ((__force vm_fault_t)((x) << 12))
+#define VM_FAULT_GET_HINDEX(x) ((((__force unsigned int)(x) >> 12) & 0xf))
 
 /*
  * Can be called by the pagefault handler when it gets a VM_FAULT_OOM.
@@ -1391,8 +1398,8 @@ int generic_error_remove_page(struct address_space *mapping, struct page *page);
 int invalidate_inode_page(struct page *page);
 
 #ifdef CONFIG_MMU
-extern int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
-		unsigned int flags);
+extern vm_fault_t handle_mm_fault(struct vm_area_struct *vma,
+		unsigned long address, unsigned int flags);
 extern int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 			    unsigned long address, unsigned int fault_flags,
 			    bool *unlocked);
@@ -1401,7 +1408,7 @@ void unmap_mapping_pages(struct address_space *mapping,
 void unmap_mapping_range(struct address_space *mapping,
 		loff_t const holebegin, loff_t const holelen, int even_cows);
 #else
-static inline int handle_mm_fault(struct vm_area_struct *vma,
+static inline vm_fault_t handle_mm_fault(struct vm_area_struct *vma,
 		unsigned long address, unsigned int flags)
 {
 	/* should never happen if there's no MMU */
@@ -2555,7 +2562,7 @@ static inline struct page *follow_page(struct vm_area_struct *vma,
 #define FOLL_REMOTE	0x2000	/* we are working on non-current tsk/mm */
 #define FOLL_COW	0x4000	/* internal GUP flag */
 
-static inline int vm_fault_to_errno(int vm_fault, int foll_flags)
+static inline int vm_fault_to_errno(vm_fault_t vm_fault, int foll_flags)
 {
 	if (vm_fault & VM_FAULT_OOM)
 		return -ENOMEM;
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 54f1e05ecf3e..da2b77a19911 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -22,7 +22,8 @@
 #endif
 #define AT_VECTOR_SIZE (2*(AT_VECTOR_SIZE_ARCH + AT_VECTOR_SIZE_BASE + 1))
 
-typedef int vm_fault_t;
+typedef unsigned __bitwise vm_fault_t;
+
 
 struct address_space;
 struct mem_cgroup;
@@ -619,7 +620,7 @@ struct vm_special_mapping {
 	 * If non-NULL, then this is called to resolve page faults
 	 * on the special mapping.  If used, .pages is not checked.
 	 */
-	int (*fault)(const struct vm_special_mapping *sm,
+	vm_fault_t (*fault)(const struct vm_special_mapping *sm,
 		     struct vm_area_struct *vma,
 		     struct vm_fault *vmf);
 
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 553eb37def7e..80c56be07f74 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -96,7 +96,7 @@ static inline bool mm_is_oom_victim(struct mm_struct *mm)
  *
  * Return 0 when the PF is safe VM_FAULT_SIGBUS otherwise.
  */
-static inline int check_stable_address_space(struct mm_struct *mm)
+static inline vm_fault_t check_stable_address_space(struct mm_struct *mm)
 {
 	if (unlikely(test_bit(MMF_UNSTABLE, &mm->flags)))
 		return VM_FAULT_SIGBUS;
diff --git a/include/linux/swapops.h b/include/linux/swapops.h
index 1d3877c39a00..e9a3d88e058f 100644
--- a/include/linux/swapops.h
+++ b/include/linux/swapops.h
@@ -134,7 +134,7 @@ static inline struct page *device_private_entry_to_page(swp_entry_t entry)
 	return pfn_to_page(swp_offset(entry));
 }
 
-int device_private_entry_fault(struct vm_area_struct *vma,
+vm_fault_t device_private_entry_fault(struct vm_area_struct *vma,
 		       unsigned long addr,
 		       swp_entry_t entry,
 		       unsigned int flags,
@@ -169,7 +169,7 @@ static inline struct page *device_private_entry_to_page(swp_entry_t entry)
 	return NULL;
 }
 
-static inline int device_private_entry_fault(struct vm_area_struct *vma,
+static inline vm_fault_t device_private_entry_fault(struct vm_area_struct *vma,
 				     unsigned long addr,
 				     swp_entry_t entry,
 				     unsigned int flags,
diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
index f2f3b68ba910..e8d47a9a2450 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -28,7 +28,7 @@
 #define UFFD_SHARED_FCNTL_FLAGS (O_CLOEXEC | O_NONBLOCK)
 #define UFFD_FLAGS_SET (EFD_SHARED_FCNTL_FLAGS)
 
-extern int handle_userfault(struct vm_fault *vmf, unsigned long reason);
+extern vm_fault_t handle_userfault(struct vm_fault *vmf, unsigned long reason);
 
 extern ssize_t mcopy_atomic(struct mm_struct *dst_mm, unsigned long dst_start,
 			    unsigned long src_start, unsigned long len);
@@ -75,7 +75,8 @@ extern void userfaultfd_unmap_complete(struct mm_struct *mm,
 #else /* CONFIG_USERFAULTFD */
 
 /* mm helpers */
-static inline int handle_userfault(struct vm_fault *vmf, unsigned long reason)
+static inline vm_fault_t handle_userfault(struct vm_fault *vmf,
+		unsigned long reason)
 {
 	return VM_FAULT_SIGBUS;
 }
diff --git a/ipc/shm.c b/ipc/shm.c
index 29978ee76c2e..051a3e1fb8df 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -408,7 +408,7 @@ void exit_shm(struct task_struct *task)
 	up_write(&shm_ids(ns).rwsem);
 }
 
-static int shm_fault(struct vm_fault *vmf)
+static vm_fault_t shm_fault(struct vm_fault *vmf)
 {
 	struct file *file = vmf->vma->vm_file;
 	struct shm_file_data *sfd = shm_file_data(file);
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 67612ce359ad..a535e09f0b0c 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -5271,11 +5271,11 @@ void perf_event_update_userpage(struct perf_event *event)
 }
 EXPORT_SYMBOL_GPL(perf_event_update_userpage);
 
-static int perf_mmap_fault(struct vm_fault *vmf)
+static vm_fault_t perf_mmap_fault(struct vm_fault *vmf)
 {
 	struct perf_event *event = vmf->vma->vm_file->private_data;
 	struct ring_buffer *rb;
-	int ret = VM_FAULT_SIGBUS;
+	vm_fault_t ret = VM_FAULT_SIGBUS;
 
 	if (vmf->flags & FAULT_FLAG_MKWRITE) {
 		if (vmf->pgoff == 0)
diff --git a/mm/gup.c b/mm/gup.c
index 6c7c85e5d9c4..e8348a5de3b5 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -497,7 +497,7 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 		unsigned long address, unsigned int *flags, int *nonblocking)
 {
 	unsigned int fault_flags = 0;
-	int ret;
+	vm_fault_t ret;
 
 	/* mlock all present pages, but do not fault in new pages */
 	if ((*flags & (FOLL_POPULATE | FOLL_MLOCK)) == FOLL_MLOCK)
@@ -815,7 +815,8 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 		     bool *unlocked)
 {
 	struct vm_area_struct *vma;
-	int ret, major = 0;
+	int major = 0;
+	vm_fault_t ret;
 
 	if (unlocked)
 		fault_flags |= FAULT_FLAG_ALLOW_RETRY;
@@ -829,7 +830,7 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 		return -EFAULT;
 
 	ret = handle_mm_fault(vma, address, fault_flags);
-	major |= ret & VM_FAULT_MAJOR;
+	major |= !!(ret & VM_FAULT_MAJOR);
 	if (ret & VM_FAULT_ERROR) {
 		int err = vm_fault_to_errno(ret, 0);
 
diff --git a/mm/hmm.c b/mm/hmm.c
index de7b6bf77201..5a568b75f7a4 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -299,7 +299,7 @@ static int hmm_vma_do_fault(struct mm_walk *walk, unsigned long addr,
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
 	struct vm_area_struct *vma = walk->vma;
-	int r;
+	vm_fault_t r;
 
 	flags |= hmm_vma_walk->block ? 0 : FAULT_FLAG_ALLOW_RETRY;
 	flags |= write_fault ? FAULT_FLAG_WRITE : 0;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 323acdd14e6e..5bc71dc19a4e 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -544,14 +544,14 @@ unsigned long thp_get_unmapped_area(struct file *filp, unsigned long addr,
 }
 EXPORT_SYMBOL_GPL(thp_get_unmapped_area);
 
-static int __do_huge_pmd_anonymous_page(struct vm_fault *vmf, struct page *page,
-		gfp_t gfp)
+static vm_fault_t __do_huge_pmd_anonymous_page(struct vm_fault *vmf,
+		struct page *page, gfp_t gfp)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct mem_cgroup *memcg;
 	pgtable_t pgtable;
 	unsigned long haddr = vmf->address & HPAGE_PMD_MASK;
-	int ret = 0;
+	vm_fault_t ret = 0;
 
 	VM_BUG_ON_PAGE(!PageCompound(page), page);
 
@@ -587,7 +587,7 @@ static int __do_huge_pmd_anonymous_page(struct vm_fault *vmf, struct page *page,
 
 		/* Deliver the page fault to userland */
 		if (userfaultfd_missing(vma)) {
-			int ret;
+			vm_fault_t ret;
 
 			spin_unlock(vmf->ptl);
 			mem_cgroup_cancel_charge(page, memcg, true);
@@ -666,7 +666,7 @@ static bool set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
 	return true;
 }
 
-int do_huge_pmd_anonymous_page(struct vm_fault *vmf)
+vm_fault_t do_huge_pmd_anonymous_page(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	gfp_t gfp;
@@ -685,7 +685,7 @@ int do_huge_pmd_anonymous_page(struct vm_fault *vmf)
 		pgtable_t pgtable;
 		struct page *zero_page;
 		bool set;
-		int ret;
+		vm_fault_t ret;
 		pgtable = pte_alloc_one(vma->vm_mm, haddr);
 		if (unlikely(!pgtable))
 			return VM_FAULT_OOM;
@@ -755,7 +755,7 @@ static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 	spin_unlock(ptl);
 }
 
-int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
+vm_fault_t vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 			pmd_t *pmd, pfn_t pfn, bool write)
 {
 	pgprot_t pgprot = vma->vm_page_prot;
@@ -815,7 +815,7 @@ static void insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
 	spin_unlock(ptl);
 }
 
-int vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
+vm_fault_t vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
 			pud_t *pud, pfn_t pfn, bool write)
 {
 	pgprot_t pgprot = vma->vm_page_prot;
@@ -1121,15 +1121,16 @@ void huge_pmd_set_accessed(struct vm_fault *vmf, pmd_t orig_pmd)
 	spin_unlock(vmf->ptl);
 }
 
-static int do_huge_pmd_wp_page_fallback(struct vm_fault *vmf, pmd_t orig_pmd,
-		struct page *page)
+static vm_fault_t do_huge_pmd_wp_page_fallback(struct vm_fault *vmf,
+		pmd_t orig_pmd, struct page *page)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	unsigned long haddr = vmf->address & HPAGE_PMD_MASK;
 	struct mem_cgroup *memcg;
 	pgtable_t pgtable;
 	pmd_t _pmd;
-	int ret = 0, i;
+	vm_fault_t ret = 0;
+	int i;
 	struct page **pages;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
@@ -1239,7 +1240,7 @@ static int do_huge_pmd_wp_page_fallback(struct vm_fault *vmf, pmd_t orig_pmd,
 	goto out;
 }
 
-int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
+vm_fault_t do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct page *page = NULL, *new_page;
@@ -1248,7 +1249,7 @@ int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
 	gfp_t huge_gfp;			/* for allocation and charge */
-	int ret = 0;
+	vm_fault_t ret = 0;
 
 	vmf->ptl = pmd_lockptr(vma->vm_mm, vmf->pmd);
 	VM_BUG_ON_VMA(!vma->anon_vma, vma);
@@ -1459,7 +1460,7 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 }
 
 /* NUMA hinting page fault entry point for trans huge pmds */
-int do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
+vm_fault_t do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct anon_vma *anon_vma = NULL;
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 129088710510..8809aaff4add 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3159,7 +3159,7 @@ static unsigned long hugetlb_vm_op_pagesize(struct vm_area_struct *vma)
  * hugegpage VMA.  do_page_fault() is supposed to trap this, so BUG is we get
  * this far.
  */
-static int hugetlb_vm_op_fault(struct vm_fault *vmf)
+static vm_fault_t hugetlb_vm_op_fault(struct vm_fault *vmf)
 {
 	BUG();
 	return 0;
@@ -3499,16 +3499,17 @@ static void unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
  * cannot race with other handlers or page migration.
  * Keep the pte_same checks anyway to make transition from the mutex easier.
  */
-static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
+static vm_fault_t hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 		       unsigned long address, pte_t *ptep,
 		       struct page *pagecache_page, spinlock_t *ptl)
 {
 	pte_t pte;
 	struct hstate *h = hstate_vma(vma);
 	struct page *old_page, *new_page;
-	int ret = 0, outside_reserve = 0;
+	int outside_reserve = 0;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
+	vm_fault_t ret = 0;
 
 	pte = huge_ptep_get(ptep);
 	old_page = pte_page(pte);
@@ -3675,12 +3676,13 @@ int huge_add_to_page_cache(struct page *page, struct address_space *mapping,
 	return 0;
 }
 
-static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
-			   struct address_space *mapping, pgoff_t idx,
-			   unsigned long address, pte_t *ptep, unsigned int flags)
+static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
+		struct vm_area_struct *vma, struct address_space *mapping,
+		pgoff_t idx, unsigned long address, pte_t *ptep,
+		unsigned int flags)
 {
 	struct hstate *h = hstate_vma(vma);
-	int ret = VM_FAULT_SIGBUS;
+	vm_fault_t ret = VM_FAULT_SIGBUS;
 	int anon_rmap = 0;
 	unsigned long size;
 	struct page *page;
@@ -3742,8 +3744,7 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 		page = alloc_huge_page(vma, address, 0);
 		if (IS_ERR(page)) {
-			ret = PTR_ERR(page);
-			if (ret == -ENOMEM)
+			if (PTR_ERR(page) == -ENOMEM)
 				ret = VM_FAULT_OOM;
 			else
 				ret = VM_FAULT_SIGBUS;
@@ -3870,12 +3871,12 @@ u32 hugetlb_fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
 }
 #endif
 
-int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
+vm_fault_t hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, unsigned int flags)
 {
 	pte_t *ptep, entry;
 	spinlock_t *ptl;
-	int ret;
+	vm_fault_t ret;
 	u32 hash;
 	pgoff_t idx;
 	struct page *page = NULL;
@@ -4206,7 +4207,7 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		if (absent || is_swap_pte(huge_ptep_get(pte)) ||
 		    ((flags & FOLL_WRITE) &&
 		      !huge_pte_write(huge_ptep_get(pte)))) {
-			int ret;
+			vm_fault_t ret;
 			unsigned int fault_flags = 0;
 
 			if (pte)
diff --git a/mm/internal.h b/mm/internal.h
index 62d8c34e63d5..e12210f07393 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -38,7 +38,7 @@
 
 void page_writeback_init(void);
 
-int do_swap_page(struct vm_fault *vmf);
+vm_fault_t do_swap_page(struct vm_fault *vmf);
 
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index d7b2a4bf8671..778fd407ae93 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -880,7 +880,8 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 					unsigned long address, pmd_t *pmd,
 					int referenced)
 {
-	int swapped_in = 0, ret = 0;
+	int swapped_in = 0;
+	vm_fault_t ret = 0;
 	struct vm_fault vmf = {
 		.vma = vma,
 		.address = address,
diff --git a/mm/ksm.c b/mm/ksm.c
index a6d43cf9a982..4be259489409 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -470,7 +470,7 @@ static inline bool ksm_test_exit(struct mm_struct *mm)
 static int break_ksm(struct vm_area_struct *vma, unsigned long addr)
 {
 	struct page *page;
-	int ret = 0;
+	vm_fault_t ret = 0;
 
 	do {
 		cond_resched();
diff --git a/mm/memory.c b/mm/memory.c
index 14578158ed20..3634a012c388 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2370,9 +2370,9 @@ static gfp_t __get_fault_gfp_mask(struct vm_area_struct *vma)
  *
  * We do this without the lock held, so that it can sleep if it needs to.
  */
-static int do_page_mkwrite(struct vm_fault *vmf)
+static vm_fault_t do_page_mkwrite(struct vm_fault *vmf)
 {
-	int ret;
+	vm_fault_t ret;
 	struct page *page = vmf->page;
 	unsigned int old_flags = vmf->flags;
 
@@ -2476,7 +2476,7 @@ static inline void wp_page_reuse(struct vm_fault *vmf)
  *   held to the old page, as well as updating the rmap.
  * - In any case, unlock the PTL and drop the reference we took to the old page.
  */
-static int wp_page_copy(struct vm_fault *vmf)
+static vm_fault_t wp_page_copy(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct mm_struct *mm = vma->vm_mm;
@@ -2624,7 +2624,7 @@ static int wp_page_copy(struct vm_fault *vmf)
  * The function expects the page to be locked or other protection against
  * concurrent faults / writeback (such as DAX radix tree locks).
  */
-int finish_mkwrite_fault(struct vm_fault *vmf)
+vm_fault_t finish_mkwrite_fault(struct vm_fault *vmf)
 {
 	WARN_ON_ONCE(!(vmf->vma->vm_flags & VM_SHARED));
 	vmf->pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd, vmf->address,
@@ -2645,12 +2645,12 @@ int finish_mkwrite_fault(struct vm_fault *vmf)
  * Handle write page faults for VM_MIXEDMAP or VM_PFNMAP for a VM_SHARED
  * mapping
  */
-static int wp_pfn_shared(struct vm_fault *vmf)
+static vm_fault_t wp_pfn_shared(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 
 	if (vma->vm_ops && vma->vm_ops->pfn_mkwrite) {
-		int ret;
+		vm_fault_t ret;
 
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
 		vmf->flags |= FAULT_FLAG_MKWRITE;
@@ -2663,7 +2663,7 @@ static int wp_pfn_shared(struct vm_fault *vmf)
 	return VM_FAULT_WRITE;
 }
 
-static int wp_page_shared(struct vm_fault *vmf)
+static vm_fault_t wp_page_shared(struct vm_fault *vmf)
 	__releases(vmf->ptl)
 {
 	struct vm_area_struct *vma = vmf->vma;
@@ -2671,7 +2671,7 @@ static int wp_page_shared(struct vm_fault *vmf)
 	get_page(vmf->page);
 
 	if (vma->vm_ops && vma->vm_ops->page_mkwrite) {
-		int tmp;
+		vm_fault_t tmp;
 
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
 		tmp = do_page_mkwrite(vmf);
@@ -2714,7 +2714,7 @@ static int wp_page_shared(struct vm_fault *vmf)
  * but allow concurrent faults), with pte both mapped and locked.
  * We return with mmap_sem still held, but pte unmapped and unlocked.
  */
-static int do_wp_page(struct vm_fault *vmf)
+static vm_fault_t do_wp_page(struct vm_fault *vmf)
 	__releases(vmf->ptl)
 {
 	struct vm_area_struct *vma = vmf->vma;
@@ -2890,7 +2890,7 @@ EXPORT_SYMBOL(unmap_mapping_range);
  * We return with the mmap_sem locked or unlocked in the same cases
  * as does filemap_fault().
  */
-int do_swap_page(struct vm_fault *vmf)
+vm_fault_t do_swap_page(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct page *page = NULL, *swapcache;
@@ -2899,7 +2899,7 @@ int do_swap_page(struct vm_fault *vmf)
 	pte_t pte;
 	int locked;
 	int exclusive = 0;
-	int ret = 0;
+	vm_fault_t ret = 0;
 
 	if (!pte_unmap_same(vma->vm_mm, vmf->pmd, vmf->pte, vmf->orig_pte))
 		goto out;
@@ -3110,12 +3110,12 @@ int do_swap_page(struct vm_fault *vmf)
  * but allow concurrent faults), and pte mapped but not yet locked.
  * We return with mmap_sem still held, but pte unmapped and unlocked.
  */
-static int do_anonymous_page(struct vm_fault *vmf)
+static vm_fault_t do_anonymous_page(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct mem_cgroup *memcg;
 	struct page *page;
-	int ret = 0;
+	vm_fault_t ret = 0;
 	pte_t entry;
 
 	/* File mapping without ->vm_ops ? */
@@ -3224,10 +3224,10 @@ static int do_anonymous_page(struct vm_fault *vmf)
  * released depending on flags and vma->vm_ops->fault() return value.
  * See filemap_fault() and __lock_page_retry().
  */
-static int __do_fault(struct vm_fault *vmf)
+static vm_fault_t __do_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
-	int ret;
+	vm_fault_t ret;
 
 	ret = vma->vm_ops->fault(vmf);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY |
@@ -3261,7 +3261,7 @@ static int pmd_devmap_trans_unstable(pmd_t *pmd)
 	return pmd_devmap(*pmd) || pmd_trans_unstable(pmd);
 }
 
-static int pte_alloc_one_map(struct vm_fault *vmf)
+static vm_fault_t pte_alloc_one_map(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 
@@ -3337,13 +3337,14 @@ static void deposit_prealloc_pte(struct vm_fault *vmf)
 	vmf->prealloc_pte = NULL;
 }
 
-static int do_set_pmd(struct vm_fault *vmf, struct page *page)
+static vm_fault_t do_set_pmd(struct vm_fault *vmf, struct page *page)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	bool write = vmf->flags & FAULT_FLAG_WRITE;
 	unsigned long haddr = vmf->address & HPAGE_PMD_MASK;
 	pmd_t entry;
-	int i, ret;
+	vm_fault_t ret;
+	int i;
 
 	if (!transhuge_vma_suitable(vma, haddr))
 		return VM_FAULT_FALLBACK;
@@ -3414,13 +3415,13 @@ static int do_set_pmd(struct vm_fault *vmf, struct page *page)
  * Target users are page handler itself and implementations of
  * vm_ops->map_pages.
  */
-int alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
+vm_fault_t alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
 		struct page *page)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	bool write = vmf->flags & FAULT_FLAG_WRITE;
 	pte_t entry;
-	int ret;
+	vm_fault_t ret;
 
 	if (pmd_none(*vmf->pmd) && PageTransCompound(page) &&
 			IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE)) {
@@ -3479,10 +3480,10 @@ int alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
  * The function expects the page to be locked and on success it consumes a
  * reference of a page being mapped (for the PTE which maps it).
  */
-int finish_fault(struct vm_fault *vmf)
+vm_fault_t finish_fault(struct vm_fault *vmf)
 {
 	struct page *page;
-	int ret = 0;
+	vm_fault_t ret = 0;
 
 	/* Did we COW the page? */
 	if ((vmf->flags & FAULT_FLAG_WRITE) &&
@@ -3568,12 +3569,13 @@ late_initcall(fault_around_debugfs);
  * (and therefore to page order).  This way it's easier to guarantee
  * that we don't cross page table boundaries.
  */
-static int do_fault_around(struct vm_fault *vmf)
+static vm_fault_t do_fault_around(struct vm_fault *vmf)
 {
 	unsigned long address = vmf->address, nr_pages, mask;
 	pgoff_t start_pgoff = vmf->pgoff;
 	pgoff_t end_pgoff;
-	int off, ret = 0;
+	vm_fault_t ret = 0;
+	int off;
 
 	nr_pages = READ_ONCE(fault_around_bytes) >> PAGE_SHIFT;
 	mask = ~(nr_pages * PAGE_SIZE - 1) & PAGE_MASK;
@@ -3623,10 +3625,10 @@ static int do_fault_around(struct vm_fault *vmf)
 	return ret;
 }
 
-static int do_read_fault(struct vm_fault *vmf)
+static vm_fault_t do_read_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
-	int ret = 0;
+	vm_fault_t ret = 0;
 
 	/*
 	 * Let's call ->map_pages() first and use ->fault() as fallback
@@ -3650,10 +3652,10 @@ static int do_read_fault(struct vm_fault *vmf)
 	return ret;
 }
 
-static int do_cow_fault(struct vm_fault *vmf)
+static vm_fault_t do_cow_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
-	int ret;
+	vm_fault_t ret;
 
 	if (unlikely(anon_vma_prepare(vma)))
 		return VM_FAULT_OOM;
@@ -3689,10 +3691,10 @@ static int do_cow_fault(struct vm_fault *vmf)
 	return ret;
 }
 
-static int do_shared_fault(struct vm_fault *vmf)
+static vm_fault_t do_shared_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
-	int ret, tmp;
+	vm_fault_t ret, tmp;
 
 	ret = __do_fault(vmf);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
@@ -3730,10 +3732,10 @@ static int do_shared_fault(struct vm_fault *vmf)
  * The mmap_sem may have been released depending on flags and our
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
-static int do_fault(struct vm_fault *vmf)
+static vm_fault_t do_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
-	int ret;
+	vm_fault_t ret;
 
 	/* The VMA was not fully populated on mmap() or missing VM_DONTEXPAND */
 	if (!vma->vm_ops->fault)
@@ -3768,7 +3770,7 @@ static int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
 	return mpol_misplaced(page, vma, addr);
 }
 
-static int do_numa_page(struct vm_fault *vmf)
+static vm_fault_t do_numa_page(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct page *page = NULL;
@@ -3858,7 +3860,7 @@ static int do_numa_page(struct vm_fault *vmf)
 	return 0;
 }
 
-static inline int create_huge_pmd(struct vm_fault *vmf)
+static inline vm_fault_t create_huge_pmd(struct vm_fault *vmf)
 {
 	if (vma_is_anonymous(vmf->vma))
 		return do_huge_pmd_anonymous_page(vmf);
@@ -3868,7 +3870,7 @@ static inline int create_huge_pmd(struct vm_fault *vmf)
 }
 
 /* `inline' is required to avoid gcc 4.1.2 build error */
-static inline int wp_huge_pmd(struct vm_fault *vmf, pmd_t orig_pmd)
+static inline vm_fault_t wp_huge_pmd(struct vm_fault *vmf, pmd_t orig_pmd)
 {
 	if (vma_is_anonymous(vmf->vma))
 		return do_huge_pmd_wp_page(vmf, orig_pmd);
@@ -3887,7 +3889,7 @@ static inline bool vma_is_accessible(struct vm_area_struct *vma)
 	return vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE);
 }
 
-static int create_huge_pud(struct vm_fault *vmf)
+static vm_fault_t create_huge_pud(struct vm_fault *vmf)
 {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	/* No support for anonymous transparent PUD pages yet */
@@ -3899,7 +3901,7 @@ static int create_huge_pud(struct vm_fault *vmf)
 	return VM_FAULT_FALLBACK;
 }
 
-static int wp_huge_pud(struct vm_fault *vmf, pud_t orig_pud)
+static vm_fault_t wp_huge_pud(struct vm_fault *vmf, pud_t orig_pud)
 {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	/* No support for anonymous transparent PUD pages yet */
@@ -3926,7 +3928,7 @@ static int wp_huge_pud(struct vm_fault *vmf, pud_t orig_pud)
  * The mmap_sem may have been released depending on flags and our return value.
  * See filemap_fault() and __lock_page_or_retry().
  */
-static int handle_pte_fault(struct vm_fault *vmf)
+static vm_fault_t handle_pte_fault(struct vm_fault *vmf)
 {
 	pte_t entry;
 
@@ -4014,8 +4016,8 @@ static int handle_pte_fault(struct vm_fault *vmf)
  * The mmap_sem may have been released depending on flags and our
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
-static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
-		unsigned int flags)
+static vm_fault_t __handle_mm_fault(struct vm_area_struct *vma,
+		unsigned long address, unsigned int flags)
 {
 	struct vm_fault vmf = {
 		.vma = vma,
@@ -4028,7 +4030,7 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 	struct mm_struct *mm = vma->vm_mm;
 	pgd_t *pgd;
 	p4d_t *p4d;
-	int ret;
+	vm_fault_t ret;
 
 	pgd = pgd_offset(mm, address);
 	p4d = p4d_alloc(mm, pgd, address);
@@ -4103,10 +4105,10 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
  * The mmap_sem may have been released depending on flags and our
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
-int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
+vm_fault_t handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 		unsigned int flags)
 {
-	int ret;
+	vm_fault_t ret;
 
 	__set_current_state(TASK_RUNNING);
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 135b1d36da17..d28db0b62601 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3277,7 +3277,7 @@ void vm_stat_account(struct mm_struct *mm, vm_flags_t flags, long npages)
 		mm->data_vm += npages;
 }
 
-static int special_mapping_fault(struct vm_fault *vmf);
+static vm_fault_t special_mapping_fault(struct vm_fault *vmf);
 
 /*
  * Having a close hook prevents vma merging regardless of flags.
@@ -3316,7 +3316,7 @@ static const struct vm_operations_struct legacy_special_mapping_vmops = {
 	.fault = special_mapping_fault,
 };
 
-static int special_mapping_fault(struct vm_fault *vmf)
+static vm_fault_t special_mapping_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	pgoff_t pgoff;
diff --git a/mm/shmem.c b/mm/shmem.c
index 4d8a6f8e571f..49f447d32f8f 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -123,7 +123,7 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
 static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 		struct page **pagep, enum sgp_type sgp,
 		gfp_t gfp, struct vm_area_struct *vma,
-		struct vm_fault *vmf, int *fault_type);
+		struct vm_fault *vmf, vm_fault_t *fault_type);
 
 int shmem_getpage(struct inode *inode, pgoff_t index,
 		struct page **pagep, enum sgp_type sgp)
@@ -1620,7 +1620,8 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
  */
 static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 	struct page **pagep, enum sgp_type sgp, gfp_t gfp,
-	struct vm_area_struct *vma, struct vm_fault *vmf, int *fault_type)
+	struct vm_area_struct *vma, struct vm_fault *vmf,
+	vm_fault_t *fault_type)
 {
 	struct address_space *mapping = inode->i_mapping;
 	struct shmem_inode_info *info = SHMEM_I(inode);
@@ -1947,14 +1948,14 @@ static int synchronous_wake_function(wait_queue_entry_t *wait, unsigned mode, in
 	return ret;
 }
 
-static int shmem_fault(struct vm_fault *vmf)
+static vm_fault_t shmem_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct inode *inode = file_inode(vma->vm_file);
 	gfp_t gfp = mapping_gfp_mask(inode->i_mapping);
 	enum sgp_type sgp;
 	int error;
-	int ret = VM_FAULT_LOCKED;
+	vm_fault_t ret = VM_FAULT_LOCKED;
 
 	/*
 	 * Trinity finds that probing a hole which tmpfs is punching can
diff --git a/samples/vfio-mdev/mbochs.c b/samples/vfio-mdev/mbochs.c
index 2960e26c6ea4..7743fbc6ad58 100644
--- a/samples/vfio-mdev/mbochs.c
+++ b/samples/vfio-mdev/mbochs.c
@@ -657,7 +657,7 @@ static void mbochs_put_pages(struct mdev_state *mdev_state)
 	dev_dbg(dev, "%s: %d pages released\n", __func__, count);
 }
 
-static int mbochs_region_vm_fault(struct vm_fault *vmf)
+static vm_fault_t mbochs_region_vm_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct mdev_state *mdev_state = vma->vm_private_data;
@@ -695,7 +695,7 @@ static int mbochs_mmap(struct mdev_device *mdev, struct vm_area_struct *vma)
 	return 0;
 }
 
-static int mbochs_dmabuf_vm_fault(struct vm_fault *vmf)
+static vm_fault_t mbochs_dmabuf_vm_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct mbochs_dmabuf *dmabuf = vma->vm_private_data;
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index c7b2e927f699..3da1ad291d34 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -2340,7 +2340,7 @@ void kvm_vcpu_on_spin(struct kvm_vcpu *me, bool yield_to_kernel_mode)
 }
 EXPORT_SYMBOL_GPL(kvm_vcpu_on_spin);
 
-static int kvm_vcpu_fault(struct vm_fault *vmf)
+static vm_fault_t kvm_vcpu_fault(struct vm_fault *vmf)
 {
 	struct kvm_vcpu *vcpu = vmf->vma->vm_file->private_data;
 	struct page *page;
-- 
2.17.0
