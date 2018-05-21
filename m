From: NeilBrown <neilb@suse.com>
Date: Mon, 21 May 2018 14:35:12 +1000
Subject: [lustre-devel] [PATCH 16/30] staging: lustre: move
 lnet_debug_log_upcall declaration to tracefile.h
In-Reply-To: <152687724799.24196.7718555295926047576.stgit@noble>
References: <152687724799.24196.7718555295926047576.stgit@noble>
Message-ID: <152687731293.24196.2556065807350573775.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Both files that use this variable include tracefile.h, and it
seems a more suitable home for the declaration.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |    5 -----
 drivers/staging/lustre/lnet/libcfs/tracefile.h     |    5 +++++
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 947fba9445dc..c7d025cccb40 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -103,11 +103,6 @@ static inline int notifier_from_ioctl_errno(int err)
 
 int libcfs_setup(void);
 
-/**
- * The path of debug log dump upcall script.
- */
-extern char lnet_debug_log_upcall[1024];
-
 extern struct workqueue_struct *cfs_rehash_wq;
 
 void lustre_insert_debugfs(struct ctl_table *table);
diff --git a/drivers/staging/lustre/lnet/libcfs/tracefile.h b/drivers/staging/lustre/lnet/libcfs/tracefile.h
index a29d6eb3a785..b1c7a98ea192 100644
--- a/drivers/staging/lustre/lnet/libcfs/tracefile.h
+++ b/drivers/staging/lustre/lnet/libcfs/tracefile.h
@@ -49,6 +49,11 @@ enum cfs_trace_buf_type {
 extern char cfs_tracefile[TRACEFILE_NAME_SIZE];
 extern long long cfs_tracefile_size;
 
+/**
+ * The path of debug log dump upcall script.
+ */
+extern char lnet_debug_log_upcall[1024];
+
 void libcfs_run_debug_log_upcall(char *file);
 
 int  cfs_tracefile_init_arch(void);
