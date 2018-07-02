From: James Simmons <jsimmons@infradead.org>
Date: Mon,  2 Jul 2018 19:24:48 -0400
Subject: [lustre-devel] [PATCH 04/10] lustre: libcfs: fix module loading and
 sysfs setting race
In-Reply-To: <1530573894-20592-1-git-send-email-jsimmons@infradead.org>
References: <1530573894-20592-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1530573894-20592-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The set method is called when a module parameter is parsed and
this happens before libcfs __init function has been called. Also
the sysfs files corresponding to libcfs module parameters are
also constructed before the __init function. Lastly the set
method can be called while the __init function does run. Add
kernel_param_[un]lock() to void stomping over the module
parameter setting.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Reviewed-on: https://review.whamcloud.com/24688
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/debug.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/debug.c b/drivers/staging/lustre/lnet/libcfs/debug.c
index f2509f4..5d93341 100644
--- a/drivers/staging/lustre/lnet/libcfs/debug.c
+++ b/drivers/staging/lustre/lnet/libcfs/debug.c
@@ -422,18 +422,22 @@ int libcfs_debug_init(unsigned long bufsize)
 	}
 
 	rc = cfs_tracefile_init(max);
-	if (!rc) {
-		libcfs_register_panic_notifier();
-		libcfs_debug_mb = cfs_trace_get_debug_mb();
-	}
+	if (rc)
+		return rc;
 
+	libcfs_register_panic_notifier();
+	kernel_param_lock(THIS_MODULE);
+	libcfs_debug_mb = cfs_trace_get_debug_mb();
+	kernel_param_unlock(THIS_MODULE);
 	return rc;
 }
 
 int libcfs_debug_cleanup(void)
 {
 	libcfs_unregister_panic_notifier();
+	kernel_param_lock(THIS_MODULE);
 	cfs_tracefile_exit();
+	kernel_param_unlock(THIS_MODULE);
 	return 0;
 }
 
-- 
1.8.3.1
