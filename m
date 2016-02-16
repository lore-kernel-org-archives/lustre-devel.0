From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:46:34 -0500
Subject: [lustre-devel] [PATCH 02/45] staging/lustre/obdclass: Get rid of
	/proc references in comments.
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-3-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Now that the sysfs conversion is complete, also convert all the
remaining comments

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/cl_object.h       | 2 +-
 drivers/staging/lustre/lustre/include/lprocfs_status.h  | 2 +-
 drivers/staging/lustre/lustre/include/obd.h             | 7 ++++---
 drivers/staging/lustre/lustre/obdclass/class_obd.c      | 4 ++--
 drivers/staging/lustre/lustre/obdclass/lprocfs_status.c | 8 ++++----
 5 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index bd7acc2..c8f4569 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -2613,7 +2613,7 @@ struct cl_site {
 	 * Statistical counters. Atomics do not scale, something better like
 	 * per-cpu counters is needed.
 	 *
-	 * These are exported as /proc/fs/lustre/llite/.../site
+	 * These are exported as /sys/kernel/debug/lustre/llite/.../site
 	 *
 	 * When interpreting keep in mind that both sub-locks (and sub-pages)
 	 * and top-locks (and top-pages) are accounted here.
diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index fb13094..97c2d7e 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -54,7 +54,7 @@ struct lprocfs_vars {
 	struct file_operations	*fops;
 	void			*data;
 	/**
-	 * /proc file mode.
+	 * sysfs file mode.
 	 */
 	umode_t			proc_mode;
 };
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index f00d9a2..514e12b 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -302,7 +302,7 @@ struct client_obd {
 	struct list_head	       cl_loi_read_list;
 	int		      cl_r_in_flight;
 	int		      cl_w_in_flight;
-	/* just a sum of the loi/lop pending numbers to be exported by /proc */
+	/* just a sum of the loi/lop pending numbers to be exported by sysfs */
 	atomic_t	     cl_pending_w_pages;
 	atomic_t	     cl_pending_r_pages;
 	__u32			 cl_max_pages_per_rpc;
@@ -449,7 +449,7 @@ struct pool_desc {
 	struct lov_qos_rr     pool_rr;		/* round robin qos */
 	struct hlist_node      pool_hash;	      /* access by poolname */
 	struct list_head	    pool_list;	      /* serial access */
-	struct dentry		*pool_debugfs_entry;	/* file in /proc */
+	struct dentry		*pool_debugfs_entry;	/* file in debugfs */
 	struct obd_device    *pool_lobd;	/* obd of the lov/lod to which
 						*  this pool belongs */
 };
@@ -737,7 +737,8 @@ struct obd_device {
 		      obd_async_recov:1,   /* allow asynchronous orphan cleanup */
 		      obd_no_conn:1,       /* deny new connections */
 		      obd_inactive:1,      /* device active/inactive
-					   * (for /proc/status only!!) */
+					    * (for sysfs status only!!)
+					    */
 		      obd_no_ir:1,	 /* no imperative recovery. */
 		      obd_process_conf:1;  /* device is processing mgs config */
 	/* use separate field as it is set in interrupt to don't mess with
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index 65cf46c..84f6880 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -52,7 +52,7 @@ EXPORT_SYMBOL(obd_devs);
 struct list_head obd_types;
 DEFINE_RWLOCK(obd_dev_lock);
 
-/* The following are visible and mutable through /proc/sys/lustre/. */
+/* The following are visible and mutable through /sys/fs/lustre. */
 unsigned int obd_debug_peer_on_timeout;
 EXPORT_SYMBOL(obd_debug_peer_on_timeout);
 unsigned int obd_dump_on_timeout;
@@ -67,7 +67,7 @@ unsigned int obd_timeout = OBD_TIMEOUT_DEFAULT;   /* seconds */
 EXPORT_SYMBOL(obd_timeout);
 unsigned int obd_timeout_set;
 EXPORT_SYMBOL(obd_timeout_set);
-/* Adaptive timeout defs here instead of ptlrpc module for /proc/sys/ access */
+/* Adaptive timeout defs here instead of ptlrpc module for /sys/fs/ access */
 unsigned int at_min;
 EXPORT_SYMBOL(at_min);
 unsigned int at_max = 600;
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index eda44d8..a7e22e0 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -149,10 +149,10 @@ int lprocfs_read_frac_helper(char *buffer, unsigned long count, long val,
 		}
 		/*
 		 * Need to think these cases :
-		 *      1. #echo x.00 > /proc/xxx       output result : x
-		 *      2. #echo x.0x > /proc/xxx       output result : x.0x
-		 *      3. #echo x.x0 > /proc/xxx       output result : x.x
-		 *      4. #echo x.xx > /proc/xxx       output result : x.xx
+		 *      1. #echo x.00 > /sys/xxx       output result : x
+		 *      2. #echo x.0x > /sys/xxx       output result : x.0x
+		 *      3. #echo x.x0 > /sys/xxx       output result : x.x
+		 *      4. #echo x.xx > /sys/xxx       output result : x.xx
 		 *      Only reserved 2 bits fraction.
 		 */
 		for (i = 0; i < (5 - prtn); i++)
-- 
2.1.0
