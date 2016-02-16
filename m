From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:47:12 -0500
Subject: [lustre-devel] [PATCH 40/45] staging/lustre: Get rid of
	cfs_trace_buf_type_t typedef
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-41-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Replace it with enum cfs_trace_buf_type

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c | 2 +-
 drivers/staging/lustre/lustre/libcfs/tracefile.h             | 6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c
index eccf048..809ea50 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c
+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c
@@ -130,7 +130,7 @@ void cfs_tracefile_write_unlock(void)
 	up_write(&cfs_tracefile_sem);
 }
 
-cfs_trace_buf_type_t cfs_trace_buf_idx_get(void)
+enum cfs_trace_buf_type cfs_trace_buf_idx_get(void)
 {
 	if (in_irq())
 		return CFS_TCD_TYPE_IRQ;
diff --git a/drivers/staging/lustre/lustre/libcfs/tracefile.h b/drivers/staging/lustre/lustre/libcfs/tracefile.h
index dffe07f..4c77f90 100644
--- a/drivers/staging/lustre/lustre/libcfs/tracefile.h
+++ b/drivers/staging/lustre/lustre/libcfs/tracefile.h
@@ -39,12 +39,12 @@
 
 #include "../../include/linux/libcfs/libcfs.h"
 
-typedef enum {
+enum cfs_trace_buf_type {
 	CFS_TCD_TYPE_PROC = 0,
 	CFS_TCD_TYPE_SOFTIRQ,
 	CFS_TCD_TYPE_IRQ,
 	CFS_TCD_TYPE_MAX
-} cfs_trace_buf_type_t;
+};
 
 /* trace file lock routines */
 
@@ -208,7 +208,7 @@ int cfs_trace_lock_tcd(struct cfs_trace_cpu_data *tcd, int walking);
 void cfs_trace_unlock_tcd(struct cfs_trace_cpu_data *tcd, int walking);
 
 extern char *cfs_trace_console_buffers[NR_CPUS][CFS_TCD_TYPE_MAX];
-cfs_trace_buf_type_t cfs_trace_buf_idx_get(void);
+enum cfs_trace_buf_type cfs_trace_buf_idx_get(void);
 
 static inline char *
 cfs_trace_get_console_buffer(void)
-- 
2.1.0
