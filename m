From: NeilBrown <neilb@suse.com>
Date: Tue, 20 Feb 2018 13:23:37 +1100
Subject: [lustre-devel] [PATCH 07/21] staging: lustre: improve API and
 implementation of blocking signals.
In-Reply-To: <151909308778.25814.9912662268627044409.stgit@noble>
References: <151909308778.25814.9912662268627044409.stgit@noble>
Message-ID: <151909341776.25814.1357059430355267483.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

According to comment for set_current_blocked() in
kernel/signal.c, changing ->blocked directly is wrong.
sigprocmask() should be called instead.

So change cfs_block_sigsinv() and cfs_restore_sigs()
to use sigprocmask().
For consistency, change them to pass the sigset_t by reference
rather than by value.

Also fix cfs_block_sigsinv() so that it correctly blocks
signals above 32 on a 32bit host.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |    4 ++-
 .../staging/lustre/lnet/libcfs/linux/linux-prim.c  |   24 ++++++--------------
 drivers/staging/lustre/lustre/include/lustre_lib.h |   18 ++++++++-------
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |    8 +++----
 4 files changed, 22 insertions(+), 32 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 7f06b0118154..9dff050810c4 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -67,8 +67,8 @@
 /*
  * Defined by platform
  */
-sigset_t cfs_block_sigsinv(unsigned long sigs);
-void cfs_restore_sigs(sigset_t sigset);
+void cfs_block_sigsinv(unsigned long sigs, sigset_t *sigset);
+void cfs_restore_sigs(sigset_t *sigset);
 
 struct libcfs_ioctl_handler {
 	struct list_head item;
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c
index 6b73b9845e3f..0766659ddf70 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c
@@ -44,29 +44,19 @@
 #endif
 
 /* Block all signals except for the @sigs */
-sigset_t cfs_block_sigsinv(unsigned long sigs)
+void cfs_block_sigsinv(unsigned long sigs, sigset_t *old)
 {
-	unsigned long flags;
-	sigset_t old;
+	sigset_t new;
 
-	spin_lock_irqsave(&current->sighand->siglock, flags);
-	old = current->blocked;
-	sigaddsetmask(&current->blocked, ~sigs);
-	recalc_sigpending();
-	spin_unlock_irqrestore(&current->sighand->siglock, flags);
-
-	return old;
+	siginitsetinv(&new, sigs);
+	sigorsets(&new, &current->blocked, &new);
+	sigprocmask(SIG_BLOCK, &new, old);
 }
 EXPORT_SYMBOL(cfs_block_sigsinv);
 
 void
-cfs_restore_sigs(sigset_t old)
+cfs_restore_sigs(sigset_t *old)
 {
-	unsigned long flags;
-
-	spin_lock_irqsave(&current->sighand->siglock, flags);
-	current->blocked = old;
-	recalc_sigpending();
-	spin_unlock_irqrestore(&current->sighand->siglock, flags);
+	sigprocmask(SIG_SETMASK, old, NULL);
 }
 EXPORT_SYMBOL(cfs_restore_sigs);
diff --git a/drivers/staging/lustre/lustre/include/lustre_lib.h b/drivers/staging/lustre/lustre/include/lustre_lib.h
index 1efd86f18c1f..0053eafc1c10 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lib.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lib.h
@@ -94,31 +94,31 @@ static inline int l_fatal_signal_pending(struct task_struct *p)
  */
 #define l_wait_event_abortable(wq, condition)				\
 ({									\
-	sigset_t __blocked;						\
+	sigset_t __old_blocked;						\
 	int __ret = 0;							\
-	__blocked = cfs_block_sigsinv(LUSTRE_FATAL_SIGS);		\
+	cfs_block_sigsinv(LUSTRE_FATAL_SIGS, &__old_blocked);		\
 	__ret = wait_event_interruptible(wq, condition);		\
-	cfs_restore_sigs(__blocked);					\
+	cfs_restore_sigs(&__old_blocked);				\
 	__ret;								\
 })
 
 #define l_wait_event_abortable_timeout(wq, condition, timeout)		\
 ({									\
-	sigset_t __blocked;						\
+	sigset_t __old_blocked;						\
 	int __ret = 0;							\
-	__blocked = cfs_block_sigsinv(LUSTRE_FATAL_SIGS);		\
+	cfs_block_sigsinv(LUSTRE_FATAL_SIGS, &__old_blocked);		\
 	__ret = wait_event_interruptible_timeout(wq, condition, timeout);\
-	cfs_restore_sigs(__blocked);					\
+	cfs_restore_sigs(&__old_blocked);				\
 	__ret;								\
 })
 
 #define l_wait_event_abortable_exclusive(wq, condition)			\
 ({									\
-	sigset_t __blocked;						\
+	sigset_t __old_blocked;						\
 	int __ret = 0;							\
-	__blocked = cfs_block_sigsinv(LUSTRE_FATAL_SIGS);		\
+	cfs_block_sigsinv(LUSTRE_FATAL_SIGS, &__old_blocked);		\
 	__ret = wait_event_interruptible_exclusive(wq, condition);	\
-	cfs_restore_sigs(__blocked);					\
+	cfs_restore_sigs(&__old_blocked);				\
 	__ret;								\
 })
 #endif /* _LUSTRE_LIB_H */
diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
index c0533bd6f352..214b07554e62 100644
--- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
+++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
@@ -177,14 +177,14 @@ static int ll_page_mkwrite0(struct vm_area_struct *vma, struct page *vmpage,
 	vio->u.fault.ft_vma    = vma;
 	vio->u.fault.ft_vmpage = vmpage;
 
-	set = cfs_block_sigsinv(sigmask(SIGKILL) | sigmask(SIGTERM));
+	cfs_block_sigsinv(sigmask(SIGKILL) | sigmask(SIGTERM), &set);
 
 	inode = vvp_object_inode(io->ci_obj);
 	lli = ll_i2info(inode);
 
 	result = cl_io_loop(env, io);
 
-	cfs_restore_sigs(set);
+	cfs_restore_sigs(&set);
 
 	if (result == 0) {
 		struct inode *inode = file_inode(vma->vm_file);
@@ -334,7 +334,7 @@ static int ll_fault(struct vm_fault *vmf)
 	 * so that it can be killed by admin but not cause segfault by
 	 * other signals.
 	 */
-	set = cfs_block_sigsinv(sigmask(SIGKILL) | sigmask(SIGTERM));
+	cfs_block_sigsinv(sigmask(SIGKILL) | sigmask(SIGTERM), &set);
 
 restart:
 	result = ll_fault0(vmf->vma, vmf);
@@ -360,7 +360,7 @@ static int ll_fault(struct vm_fault *vmf)
 
 		result = VM_FAULT_LOCKED;
 	}
-	cfs_restore_sigs(set);
+	cfs_restore_sigs(&set);
 	return result;
 }
 
