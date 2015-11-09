From: James Simmons <jsimmons@infradead.org>
Date: Sun,  8 Nov 2015 23:27:16 -0500
Subject: [lustre-devel] [PATCH] staging: lustre: remove obsolete comment in
	tracefile.h
In-Reply-To: <1447043236-30519-1-git-send-email-jsimmons@infradead.org>
References: <1447043236-30519-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1447043236-30519-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: John L. Hammond <john.hammond@intel.com>

Remove comment about tracefile handling for user land
version of libcfs that no longer exist. Broken out of
patch http://review.whamcloud.com/11983.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2675
Reviewed-on: http://review.whamcloud.com/11983
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lustre/libcfs/tracefile.h |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/tracefile.h b/drivers/staging/lustre/lustre/libcfs/tracefile.h
index 6b37798..fd8086b 100644
--- a/drivers/staging/lustre/lustre/libcfs/tracefile.h
+++ b/drivers/staging/lustre/lustre/libcfs/tracefile.h
@@ -251,13 +251,6 @@ void cfs_print_to_console(struct ptldebug_header *hdr, int mask,
 int cfs_trace_lock_tcd(struct cfs_trace_cpu_data *tcd, int walking);
 void cfs_trace_unlock_tcd(struct cfs_trace_cpu_data *tcd, int walking);
 
-/**
- * trace_buf_type_t, trace_buf_idx_get() and trace_console_buffers[][]
- * are not public libcfs API; they should be defined in
- * platform-specific tracefile include files
- * (see, for example, linux-tracefile.h).
- */
-
 extern char *cfs_trace_console_buffers[NR_CPUS][CFS_TCD_TYPE_MAX];
 cfs_trace_buf_type_t cfs_trace_buf_idx_get(void);
 
-- 
1.7.1
