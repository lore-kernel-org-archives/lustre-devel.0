From: Christoph Hellwig <hch@lst.de>
Date: Wed, 16 May 2018 07:43:47 +0200
Subject: [lustre-devel] [PATCH 13/14] mm: move arch specific VM_FAULT_*
 flags to mm.h
In-Reply-To: <20180516054348.15950-1-hch@lst.de>
References: <20180516054348.15950-1-hch@lst.de>
Message-ID: <20180516054348.15950-14-hch@lst.de>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Souptick Joarder <jrdr.linux@gmail.com>, Matthew Wilcox <willy@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@lists.orangefs.org, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mtd@lists.infradead.org, dri-devel@lists.freedesktop.org, lustre-devel@lists.lustre.org, linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org

Various architectures define their own internal flags.  Not sure a public
header like mm.h is a good place, but keeping them inside the arch code
with possible conflicts also seems like a bad idea.  Maybe we just need
to stop overloading the value instead.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/arm/mm/fault.c       | 3 ---
 arch/arm64/mm/fault.c     | 3 ---
 arch/s390/mm/fault.c      | 6 ------
 arch/unicore32/mm/fault.c | 3 ---
 include/linux/mm.h        | 7 +++++++
 5 files changed, 7 insertions(+), 15 deletions(-)

diff --git a/arch/arm/mm/fault.c b/arch/arm/mm/fault.c
index 32034543f49c..b696eabccf60 100644
--- a/arch/arm/mm/fault.c
+++ b/arch/arm/mm/fault.c
@@ -201,9 +201,6 @@ void do_bad_area(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 }
 
 #ifdef CONFIG_MMU
-#define VM_FAULT_BADMAP		0x010000
-#define VM_FAULT_BADACCESS	0x020000
-
 /*
  * Check that the permissions on the VMA allow for the fault which occurred.
  * If we encountered a write fault, we must have write permission, otherwise
diff --git a/arch/arm64/mm/fault.c b/arch/arm64/mm/fault.c
index 91c53a7d2575..3d0b1f8eacce 100644
--- a/arch/arm64/mm/fault.c
+++ b/arch/arm64/mm/fault.c
@@ -318,9 +318,6 @@ static void do_bad_area(unsigned long addr, unsigned int esr, struct pt_regs *re
 	}
 }
 
-#define VM_FAULT_BADMAP		0x010000
-#define VM_FAULT_BADACCESS	0x020000
-
 static int __do_page_fault(struct mm_struct *mm, unsigned long addr,
 			   unsigned int mm_flags, unsigned long vm_flags,
 			   struct task_struct *tsk)
diff --git a/arch/s390/mm/fault.c b/arch/s390/mm/fault.c
index e074480d3598..48c781ae25d0 100644
--- a/arch/s390/mm/fault.c
+++ b/arch/s390/mm/fault.c
@@ -44,12 +44,6 @@
 #define __SUBCODE_MASK 0x0600
 #define __PF_RES_FIELD 0x8000000000000000ULL
 
-#define VM_FAULT_BADCONTEXT	0x010000
-#define VM_FAULT_BADMAP		0x020000
-#define VM_FAULT_BADACCESS	0x040000
-#define VM_FAULT_SIGNAL		0x080000
-#define VM_FAULT_PFAULT		0x100000
-
 enum fault_type {
 	KERNEL_FAULT,
 	USER_FAULT,
diff --git a/arch/unicore32/mm/fault.c b/arch/unicore32/mm/fault.c
index 381473412937..6c3c1a82925f 100644
--- a/arch/unicore32/mm/fault.c
+++ b/arch/unicore32/mm/fault.c
@@ -148,9 +148,6 @@ void do_bad_area(unsigned long addr, unsigned int fsr, struct pt_regs *regs)
 		__do_kernel_fault(mm, addr, fsr, regs);
 }
 
-#define VM_FAULT_BADMAP		0x010000
-#define VM_FAULT_BADACCESS	0x020000
-
 /*
  * Check that the permissions on the VMA allow for the fault which occurred.
  * If we encountered a write fault, we must have write permission, otherwise
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 338b8a1afb02..64d09e3afc24 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1250,6 +1250,13 @@ static inline void clear_page_pfmemalloc(struct page *page)
 					 * and needs fsync() to complete (for
 					 * synchronous page faults in DAX) */
 
+/* Only for use in architecture specific page fault handling: */
+#define VM_FAULT_BADMAP		0x010000
+#define VM_FAULT_BADACCESS	0x020000
+#define VM_FAULT_BADCONTEXT	0x040000
+#define VM_FAULT_SIGNAL		0x080000
+#define VM_FAULT_PFAULT		0x100000
+
 #define VM_FAULT_ERROR	(VM_FAULT_OOM | VM_FAULT_SIGBUS | VM_FAULT_SIGSEGV | \
 			 VM_FAULT_HWPOISON | VM_FAULT_HWPOISON_LARGE | \
 			 VM_FAULT_FALLBACK)
-- 
2.17.0
