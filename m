From: James Simmons <jsimmons@infradead.org>
Date: Thu, 31 Mar 2016 10:18:36 -0400
Subject: [lustre-devel] [PATCH 2/6] staging: lustre: libcfs: move
	memory_pressure functions to libcfs_prim.h
In-Reply-To: <1459433920-23644-1-git-send-email-jsimmons@infradead.org>
References: <1459433920-23644-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1459433920-23644-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@gmail.com>

Long ago libcfs_prim.h was used for userland code which is why
memory_pressure_*() handling is in both libcfs_prim.h and
linux-mem.h headers. So lets just move the memory_pressure_*()
to libcfs_prim.h.

Signed-off-by: James Simmons <uja.ornl@gmail.com>
ntel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/13841
Reviewed-by: frank zago <fzago@cray.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../lustre/include/linux/libcfs/libcfs_prim.h      |   23 ++++++++++++-------
 .../lustre/include/linux/libcfs/linux/linux-mem.h  |    4 ---
 2 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_prim.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_prim.h
index d7846e8..d97060b 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_prim.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_prim.h
@@ -43,15 +43,20 @@
 /*
  * Memory
  */
-#ifndef memory_pressure_get
-#define memory_pressure_get() (0)
-#endif
-#ifndef memory_pressure_set
-#define memory_pressure_set() do {} while (0)
-#endif
-#ifndef memory_pressure_clr
-#define memory_pressure_clr() do {} while (0)
-#endif
+static inline unsigned int memory_pressure_get(void)
+{
+	return current->flags & PF_MEMALLOC;
+}
+
+static inline void memory_pressure_set(void)
+{
+	current->flags |= PF_MEMALLOC;
+}
+
+static inline void memory_pressure_clr(void)
+{
+	current->flags &= ~PF_MEMALLOC;
+}
 
 static inline int cfs_memory_pressure_get_and_set(void)
 {
diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/linux-mem.h b/drivers/staging/lustre/include/linux/libcfs/linux/linux-mem.h
index 448379b..c50ef83 100644
--- a/drivers/staging/lustre/include/linux/libcfs/linux/linux-mem.h
+++ b/drivers/staging/lustre/include/linux/libcfs/linux/linux-mem.h
@@ -59,10 +59,6 @@
 
 #define page_index(p)       ((p)->index)
 
-#define memory_pressure_get() (current->flags & PF_MEMALLOC)
-#define memory_pressure_set() do { current->flags |= PF_MEMALLOC; } while (0)
-#define memory_pressure_clr() do { current->flags &= ~PF_MEMALLOC; } while (0)
-
 #if BITS_PER_LONG == 32
 /* limit to lowmem on 32-bit systems */
 #define NUM_CACHEPAGES \
-- 
1.7.1
