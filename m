From: NeilBrown <neilb@suse.com>
Date: Tue, 20 Feb 2018 13:23:37 +1100
Subject: [lustre-devel] [PATCH 06/21] staging: lustre: simplify linux-prim.c
In-Reply-To: <151909308778.25814.9912662268627044409.stgit@noble>
References: <151909308778.25814.9912662268627044409.stgit@noble>
Message-ID: <151909341773.25814.3960998744576050714.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

cfs_block_sigs() is never used.
cfs_clear_sigpending() is never used.
cfs_block_allsigs() is no longer used.

So those three functions can go.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |    3 -
 .../staging/lustre/lnet/libcfs/linux/linux-prim.c  |   41 --------------------
 2 files changed, 44 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index ca3472cc952f..7f06b0118154 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -67,11 +67,8 @@
 /*
  * Defined by platform
  */
-sigset_t cfs_block_allsigs(void);
-sigset_t cfs_block_sigs(unsigned long sigs);
 sigset_t cfs_block_sigsinv(unsigned long sigs);
 void cfs_restore_sigs(sigset_t sigset);
-void cfs_clear_sigpending(void);
 
 struct libcfs_ioctl_handler {
 	struct list_head item;
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c
index 6f92ea272186..6b73b9845e3f 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c
@@ -43,36 +43,6 @@
 #include <linux/kgdb.h>
 #endif
 
-sigset_t
-cfs_block_allsigs(void)
-{
-	unsigned long flags;
-	sigset_t old;
-
-	spin_lock_irqsave(&current->sighand->siglock, flags);
-	old = current->blocked;
-	sigfillset(&current->blocked);
-	recalc_sigpending();
-	spin_unlock_irqrestore(&current->sighand->siglock, flags);
-
-	return old;
-}
-EXPORT_SYMBOL(cfs_block_allsigs);
-
-sigset_t cfs_block_sigs(unsigned long sigs)
-{
-	unsigned long flags;
-	sigset_t old;
-
-	spin_lock_irqsave(&current->sighand->siglock, flags);
-	old = current->blocked;
-	sigaddsetmask(&current->blocked, sigs);
-	recalc_sigpending();
-	spin_unlock_irqrestore(&current->sighand->siglock, flags);
-	return old;
-}
-EXPORT_SYMBOL(cfs_block_sigs);
-
 /* Block all signals except for the @sigs */
 sigset_t cfs_block_sigsinv(unsigned long sigs)
 {
@@ -100,14 +70,3 @@ cfs_restore_sigs(sigset_t old)
 	spin_unlock_irqrestore(&current->sighand->siglock, flags);
 }
 EXPORT_SYMBOL(cfs_restore_sigs);
-
-void
-cfs_clear_sigpending(void)
-{
-	unsigned long flags;
-
-	spin_lock_irqsave(&current->sighand->siglock, flags);
-	clear_tsk_thread_flag(current, TIF_SIGPENDING);
-	spin_unlock_irqrestore(&current->sighand->siglock, flags);
-}
-EXPORT_SYMBOL(cfs_clear_sigpending);
