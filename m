From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:47:06 -0500
Subject: [lustre-devel] [PATCH 34/45] staging/lustre/libcfs: Remove unused
	cfs_tcd_owns_tage() function
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-35-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Does not appear to be used anywhere.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c | 10 ----------
 drivers/staging/lustre/lustre/libcfs/tracefile.h             |  3 ---
 2 files changed, 13 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c
index 5e3c400..6cff79d 100644
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c
+++ b/drivers/staging/lustre/lustre/libcfs/linux/linux-tracefile.c
@@ -176,16 +176,6 @@ void cfs_trace_unlock_tcd(struct cfs_trace_cpu_data *tcd, int walking)
 		spin_unlock(&tcd->tcd_lock);
 }
 
-int cfs_tcd_owns_tage(struct cfs_trace_cpu_data *tcd,
-		      struct cfs_trace_page *tage)
-{
-	/*
-	 * XXX nikita: do NOT call portals_debug_msg() (CDEBUG/ENTRY/EXIT)
-	 * from here: this will lead to infinite recursion.
-	 */
-	return tcd->tcd_cpu == tage->cpu;
-}
-
 void
 cfs_set_ptldebug_header(struct ptldebug_header *header,
 			struct libcfs_debug_msg_data *msgdata,
diff --git a/drivers/staging/lustre/lustre/libcfs/tracefile.h b/drivers/staging/lustre/lustre/libcfs/tracefile.h
index 2285744..0995da1 100644
--- a/drivers/staging/lustre/lustre/libcfs/tracefile.h
+++ b/drivers/staging/lustre/lustre/libcfs/tracefile.h
@@ -289,9 +289,6 @@ static inline void cfs_trace_put_tcd(struct cfs_trace_cpu_data *tcd)
 int cfs_trace_refill_stock(struct cfs_trace_cpu_data *tcd, gfp_t gfp,
 			   struct list_head *stock);
 
-int cfs_tcd_owns_tage(struct cfs_trace_cpu_data *tcd,
-		      struct cfs_trace_page *tage);
-
 void cfs_trace_assertion_failed(const char *str,
 				struct libcfs_debug_msg_data *m);
 
-- 
2.1.0
