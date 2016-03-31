From: James Simmons <jsimmons@infradead.org>
Date: Thu, 31 Mar 2016 10:18:39 -0400
Subject: [lustre-devel] [PATCH 5/6] staging: lustre: libcfs: move
	NUM_CACHEPAGES to libcfs_prim.h
In-Reply-To: <1459433920-23644-1-git-send-email-jsimmons@infradead.org>
References: <1459433920-23644-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459433920-23644-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@gmail.com>

We don't really need linux specific headers anymore so move
NUM_CACHEPAGES macro to libcfs_prim.h.

Signed-off-by: James Simmons <uja.ornl@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/13841
Reviewed-by: frank zago <fzago@cray.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/include/linux/libcfs/libcfs_prim.h      |    8 ++++++++
 .../lustre/include/linux/libcfs/linux/linux-mem.h  |    8 --------
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_prim.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_prim.h
index d97060b..6f7a276 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_prim.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_prim.h
@@ -43,6 +43,14 @@
 /*
  * Memory
  */
+#if BITS_PER_LONG == 32
+/* limit to lowmem on 32-bit systems */
+#define NUM_CACHEPAGES \
+	min(totalram_pages, 1UL << (30 - PAGE_CACHE_SHIFT) * 3 / 4)
+#else
+#define NUM_CACHEPAGES totalram_pages
+#endif
+
 static inline unsigned int memory_pressure_get(void)
 {
 	return current->flags & PF_MEMALLOC;
diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/linux-mem.h b/drivers/staging/lustre/include/linux/libcfs/linux/linux-mem.h
index c4b4284..9285fef 100644
--- a/drivers/staging/lustre/include/linux/libcfs/linux/linux-mem.h
+++ b/drivers/staging/lustre/include/linux/libcfs/linux/linux-mem.h
@@ -57,12 +57,4 @@
 #include "../libcfs_cpu.h"
 #endif
 
-#if BITS_PER_LONG == 32
-/* limit to lowmem on 32-bit systems */
-#define NUM_CACHEPAGES \
-	min(totalram_pages, 1UL << (30 - PAGE_CACHE_SHIFT) * 3 / 4)
-#else
-#define NUM_CACHEPAGES totalram_pages
-#endif
-
 #endif /* __LINUX_CFS_MEM_H__ */
-- 
1.7.1
