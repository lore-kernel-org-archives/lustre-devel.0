From: James Simmons <jsimmons@infradead.org>
Date: Thu, 31 Mar 2016 10:18:35 -0400
Subject: [lustre-devel] [PATCH 1/6] staging: lustre: libcfs: move
	add_wait_queue_exclusive_head to lustre layer
In-Reply-To: <1459433920-23644-1-git-send-email-jsimmons@infradead.org>
References: <1459433920-23644-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459433920-23644-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@gmail.com>

Only lustre client uses add_wait_queue_exclusive_head() so move
it from libcfs layer to lustre_lib.h where it is needed.

Signed-off-by: James Simmons <uja.ornl@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/13874
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/include/linux/libcfs/libcfs_prim.h      |    2 -
 .../staging/lustre/lnet/libcfs/linux/linux-prim.c  |   24 --------------------
 drivers/staging/lustre/lustre/include/lustre_lib.h |   22 ++++++++++++++++++
 3 files changed, 22 insertions(+), 26 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_prim.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_prim.h
index 082fe6d..d7846e8 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_prim.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_prim.h
@@ -40,8 +40,6 @@
 #ifndef __LIBCFS_PRIM_H__
 #define __LIBCFS_PRIM_H__
 
-void add_wait_queue_exclusive_head(wait_queue_head_t *, wait_queue_t *);
-
 /*
  * Memory
  */
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c
index 7e5ef0a..bbe19a6 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-prim.c
@@ -46,30 +46,6 @@
 #include <linux/kgdb.h>
 #endif
 
-/**
- * wait_queue_t of Linux (version < 2.6.34) is a FIFO list for exclusively
- * waiting threads, which is not always desirable because all threads will
- * be waken up again and again, even user only needs a few of them to be
- * active most time. This is not good for performance because cache can
- * be polluted by different threads.
- *
- * LIFO list can resolve this problem because we always wakeup the most
- * recent active thread by default.
- *
- * NB: please don't call non-exclusive & exclusive wait on the same
- * waitq if add_wait_queue_exclusive_head is used.
- */
-void
-add_wait_queue_exclusive_head(wait_queue_head_t *waitq, wait_queue_t *link)
-{
-	unsigned long flags;
-
-	spin_lock_irqsave(&waitq->lock, flags);
-	__add_wait_queue_exclusive(waitq, link);
-	spin_unlock_irqrestore(&waitq->lock, flags);
-}
-EXPORT_SYMBOL(add_wait_queue_exclusive_head);
-
 sigset_t
 cfs_block_allsigs(void)
 {
diff --git a/drivers/staging/lustre/lustre/include/lustre_lib.h b/drivers/staging/lustre/lustre/include/lustre_lib.h
index 2e66b27..00b9767 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lib.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lib.h
@@ -522,6 +522,28 @@ struct l_wait_info {
 			   sigmask(SIGTERM) | sigmask(SIGQUIT) |	\
 			   sigmask(SIGALRM))
 
+/**
+ * wait_queue_t of Linux (version < 2.6.34) is a FIFO list for exclusively
+ * waiting threads, which is not always desirable because all threads will
+ * be waken up again and again, even user only needs a few of them to be
+ * active most time. This is not good for performance because cache can
+ * be polluted by different threads.
+ *
+ * LIFO list can resolve this problem because we always wakeup the most
+ * recent active thread by default.
+ *
+ * NB: please don't call non-exclusive & exclusive wait on the same
+ * waitq if add_wait_queue_exclusive_head is used.
+ */
+#define add_wait_queue_exclusive_head(waitq, link)		\
+{								\
+	unsigned long flags;					\
+								\
+	spin_lock_irqsave(&((waitq)->lock), flags);		\
+	__add_wait_queue_exclusive(waitq, link);		\
+	spin_unlock_irqrestore(&((waitq)->lock), flags);	\
+}
+
 /*
  * wait for @condition to become true, but no longer than timeout, specified
  * by @info.
-- 
1.7.1
