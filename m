From: NeilBrown <neilb@suse.com>
Date: Mon, 21 May 2018 14:35:12 +1000
Subject: [lustre-devel] [PATCH 12/30] staging: lustre: discard
 cfs_block_sigsinv()
In-Reply-To: <152687724799.24196.7718555295926047576.stgit@noble>
References: <152687724799.24196.7718555295926047576.stgit@noble>
Message-ID: <152687731280.24196.2550193187633714376.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

cfs_block_sigsinv() and cfs_restore_sigs() are simple
wrappers which save a couple of line of code and
hurt readability for people not familiar with them.
They aren't used often enough to be worthwhile,
so discard them and open-code the functionality.

The sigorsets() call isn't needed as or-ing with current->blocked is
exactly what sigprocmask(SIG_BLOCK) does.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |   16 ---------------
 drivers/staging/lustre/lustre/include/lustre_lib.h |   21 +++++++++++---------
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |   14 ++++++++-----
 3 files changed, 20 insertions(+), 31 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index be40cf4fb44a..d9002e7424d4 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -93,22 +93,6 @@
 #define LNET_ACCEPTOR_MIN_RESERVED_PORT    512
 #define LNET_ACCEPTOR_MAX_RESERVED_PORT    1023
 
-/* Block all signals except for the @sigs */
-static inline void cfs_block_sigsinv(unsigned long sigs, sigset_t *old)
-{
-	sigset_t new;
-
-	siginitsetinv(&new, sigs);
-	sigorsets(&new, &current->blocked, &new);
-	sigprocmask(SIG_BLOCK, &new, old);
-}
-
-static inline void
-cfs_restore_sigs(sigset_t *old)
-{
-	sigprocmask(SIG_SETMASK, old, NULL);
-}
-
 struct libcfs_ioctl_handler {
 	struct list_head item;
 	int (*handle_ioctl)(unsigned int cmd, struct libcfs_ioctl_hdr *hdr);
diff --git a/drivers/staging/lustre/lustre/include/lustre_lib.h b/drivers/staging/lustre/lustre/include/lustre_lib.h
index 0053eafc1c10..eec10827f51f 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lib.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lib.h
@@ -94,31 +94,34 @@ static inline int l_fatal_signal_pending(struct task_struct *p)
  */
 #define l_wait_event_abortable(wq, condition)				\
 ({									\
-	sigset_t __old_blocked;						\
+	sigset_t __new_blocked, __old_blocked;				\
 	int __ret = 0;							\
-	cfs_block_sigsinv(LUSTRE_FATAL_SIGS, &__old_blocked);		\
+	siginitset(&__new_blocked, LUSTRE_FATAL_SIGS);			\
+	sigprocmask(SIG_BLOCK, &__new_blocked, &__old_blocked);		\
 	__ret = wait_event_interruptible(wq, condition);		\
-	cfs_restore_sigs(&__old_blocked);				\
+	sigprocmask(SIG_SETMASK, &__old_blocked, NULL);			\
 	__ret;								\
 })
 
 #define l_wait_event_abortable_timeout(wq, condition, timeout)		\
 ({									\
-	sigset_t __old_blocked;						\
+	sigset_t __new_blocked, __old_blocked;				\
 	int __ret = 0;							\
-	cfs_block_sigsinv(LUSTRE_FATAL_SIGS, &__old_blocked);		\
+	siginitset(&__new_blocked, LUSTRE_FATAL_SIGS);			\
+	sigprocmask(SIG_BLOCK, &__new_blocked, &__old_blocked);		\
 	__ret = wait_event_interruptible_timeout(wq, condition, timeout);\
-	cfs_restore_sigs(&__old_blocked);				\
+	sigprocmask(SIG_SETMASK, &__old_blocked, NULL);			\
 	__ret;								\
 })
 
 #define l_wait_event_abortable_exclusive(wq, condition)			\
 ({									\
-	sigset_t __old_blocked;						\
+	sigset_t __new_blocked, __old_blocked;				\
 	int __ret = 0;							\
-	cfs_block_sigsinv(LUSTRE_FATAL_SIGS, &__old_blocked);		\
+	siginitset(&__new_blocked, LUSTRE_FATAL_SIGS);			\
+	sigprocmask(SIG_BLOCK, &__new_blocked, &__old_blocked);		\
 	__ret = wait_event_interruptible_exclusive(wq, condition);	\
-	cfs_restore_sigs(&__old_blocked);				\
+	sigprocmask(SIG_SETMASK, &__old_blocked, NULL);			\
 	__ret;								\
 })
 #endif /* _LUSTRE_LIB_H */
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index 214b07554e62..d7fb5533f707 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -152,7 +152,7 @@ static int ll_page_mkwrite0(struct vm_area_struct *vma, struct page *vmpage,
 	struct vvp_io	   *vio;
 	int		      result;
 	u16 refcheck;
-	sigset_t	     set;
+	sigset_t	     old, new;
 	struct inode	     *inode;
 	struct ll_inode_info     *lli;
 
@@ -177,14 +177,15 @@ static int ll_page_mkwrite0(struct vm_area_struct *vma, struct page *vmpage,
 	vio->u.fault.ft_vma    = vma;
 	vio->u.fault.ft_vmpage = vmpage;
 
-	cfs_block_sigsinv(sigmask(SIGKILL) | sigmask(SIGTERM), &set);
+	siginitsetinv(&new, sigmask(SIGKILL) | sigmask(SIGTERM));
+	sigprocmask(SIG_BLOCK, &new, &old);
 
 	inode = vvp_object_inode(io->ci_obj);
 	lli = ll_i2info(inode);
 
 	result = cl_io_loop(env, io);
 
-	cfs_restore_sigs(&set);
+	sigprocmask(SIG_SETMASK, &old, NULL);
 
 	if (result == 0) {
 		struct inode *inode = file_inode(vma->vm_file);
@@ -328,13 +329,14 @@ static int ll_fault(struct vm_fault *vmf)
 	int count = 0;
 	bool printed = false;
 	int result;
-	sigset_t set;
+	sigset_t old, new;
 
 	/* Only SIGKILL and SIGTERM are allowed for fault/nopage/mkwrite
 	 * so that it can be killed by admin but not cause segfault by
 	 * other signals.
 	 */
-	cfs_block_sigsinv(sigmask(SIGKILL) | sigmask(SIGTERM), &set);
+	siginitsetinv(&new, sigmask(SIGKILL) | sigmask(SIGTERM));
+	sigprocmask(SIG_BLOCK, &new, &old);
 
 restart:
 	result = ll_fault0(vmf->vma, vmf);
@@ -360,7 +362,7 @@ static int ll_fault(struct vm_fault *vmf)
 
 		result = VM_FAULT_LOCKED;
 	}
-	cfs_restore_sigs(&set);
+	sigprocmask(SIG_SETMASK, &old, NULL);
 	return result;
 }
 
