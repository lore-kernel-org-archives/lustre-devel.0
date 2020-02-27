From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:43 -0500
Subject: [lustre-devel] [PATCH 535/622] lustre: osc: allow increasing
 osc.*.short_io_bytes
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-536-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

The osc.*.short_io_bytes parameter was mixing up the default and
maximum parameter values, and did not allow increasing the parameter
beyond the default.

Allow it to be increased to the maximum value, which depends on the
client PAGE_SIZE, and the amount of free space in the maximally-sized
OST RPC.  Since the maximum size is system dependent, allow some
grace when setting the parameter, so that a single tunable parameter
can work on a variety of different systems.

However, if it is larger than the maximum RDMA size (which is already
too large) return an error, as it means something is wrong.

Add a test case to exercise the osc.*.short_io_bytes parameter.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12910
Lustre-commit: cedc7f361a6e ("LU-12910 osc: allow increasing osc.*.short_io_bytes")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/36587
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Olaf Faaland-LLNL <faaland1@llnl.gov>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h      | 25 ++++++++++++++-----------
 fs/lustre/ldlm/ldlm_lib.c           |  2 +-
 fs/lustre/obdclass/lprocfs_status.c | 20 ++++++++++++--------
 3 files changed, 27 insertions(+), 20 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index 40c1ae8..87e1d60 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -306,17 +306,19 @@
  *	DT_MAX_BRW_PAGES * niobuf_remote
  *
  * - single object with 16 pages is 512 bytes
- * - OST_IO_MAXREQSIZE must be at least 1 page of cookies plus some spillover
+ * - OST_IO_MAXREQSIZE must be at least 1 niobuf per page of data
  * - Must be a multiple of 1024
+ * - should allow a reasonably large SHORT_IO_BYTES size (64KB)
  */
 #define _OST_MAXREQSIZE_BASE ((unsigned long)(sizeof(struct lustre_msg) + \
-				 sizeof(struct ptlrpc_body) + \
-				 sizeof(struct obdo) + \
-				 sizeof(struct obd_ioobj) + \
-				 sizeof(struct niobuf_remote)))
-#define _OST_MAXREQSIZE_SUM ((unsigned long)(_OST_MAXREQSIZE_BASE + \
-				 sizeof(struct niobuf_remote) * \
-				 (DT_MAX_BRW_PAGES - 1)))
+			     /* lm_buflens */ sizeof(u32) * 4 +		  \
+					      sizeof(struct ptlrpc_body) +\
+					      sizeof(struct obdo) +	  \
+					      sizeof(struct obd_ioobj) +  \
+					      sizeof(struct niobuf_remote)))
+#define _OST_MAXREQSIZE_SUM ((unsigned long)(_OST_MAXREQSIZE_BASE +	    \
+					     sizeof(struct niobuf_remote) * \
+					     DT_MAX_BRW_PAGES))
 
 /**
  * MDS incoming request with LOV EA
@@ -335,14 +337,15 @@
 /* Safe estimate of free space in standard RPC, provides upper limit for # of
  * bytes of i/o to pack in RPC (skipping bulk transfer).
  */
-#define OST_SHORT_IO_SPACE	(OST_IO_MAXREQSIZE - _OST_MAXREQSIZE_BASE)
+#define OST_MAX_SHORT_IO_BYTES	((OST_IO_MAXREQSIZE - _OST_MAXREQSIZE_BASE) & \
+				 PAGE_MASK)
 
 /* Actual size used for short i/o buffer.  Calculation means this:
  * At least one page (for large PAGE_SIZE), or 16 KiB, but not more
  * than the available space aligned to a page boundary.
  */
-#define OBD_MAX_SHORT_IO_BYTES	(min(max(PAGE_SIZE, 16UL * 1024UL), \
-					 OST_SHORT_IO_SPACE & PAGE_MASK))
+#define OBD_DEF_SHORT_IO_BYTES	min(max(PAGE_SIZE, 16UL * 1024UL), \
+					OST_MAX_SHORT_IO_BYTES)
 
 /* Macro to hide a typecast and BUILD_BUG. */
 #define ptlrpc_req_async_args(_var, req) ({				\
diff --git a/fs/lustre/ldlm/ldlm_lib.c b/fs/lustre/ldlm/ldlm_lib.c
index 127ed32..58919d3 100644
--- a/fs/lustre/ldlm/ldlm_lib.c
+++ b/fs/lustre/ldlm/ldlm_lib.c
@@ -381,7 +381,7 @@ int client_obd_setup(struct obd_device *obddev, struct lustre_cfg *lcfg)
 	 */
 	cli->cl_max_pages_per_rpc = PTLRPC_MAX_BRW_PAGES;
 
-	cli->cl_max_short_io_bytes = OBD_MAX_SHORT_IO_BYTES;
+	cli->cl_max_short_io_bytes = OBD_DEF_SHORT_IO_BYTES;
 
 	/*
 	 * set cl_chunkbits default value to PAGE_CACHE_SHIFT,
diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index 98d1e3b..806d6517 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -1894,18 +1894,24 @@ ssize_t short_io_bytes_store(struct kobject *kobj, struct attribute *attr,
 	struct obd_device *dev = container_of(kobj, struct obd_device,
 					      obd_kset.kobj);
 	struct client_obd *cli = &dev->u.cli;
-	u32 val;
+	unsigned long long val;
+	char *endp;
 	int rc;
 
 	rc = lprocfs_climp_check(dev);
 	if (rc)
 		return rc;
 
-	rc = kstrtouint(buffer, 0, &val);
-	if (rc)
+	val = memparse(buffer, &endp);
+	if (*endp) {
+		rc = -EINVAL;
 		goto out;
+	}
+
+	if (val == -1)
+		val = OBD_DEF_SHORT_IO_BYTES;
 
-	if (val && (val < MIN_SHORT_IO_BYTES || val > OBD_MAX_SHORT_IO_BYTES)) {
+	if (val && (val < MIN_SHORT_IO_BYTES || val > LNET_MTU)) {
 		rc = -ERANGE;
 		goto out;
 	}
@@ -1913,10 +1919,8 @@ ssize_t short_io_bytes_store(struct kobject *kobj, struct attribute *attr,
 	rc = count;
 
 	spin_lock(&cli->cl_loi_list_lock);
-	if (val > (cli->cl_max_pages_per_rpc << PAGE_SHIFT))
-		rc = -ERANGE;
-	else
-		cli->cl_max_short_io_bytes = val;
+	cli->cl_max_short_io_bytes = min_t(unsigned long long,
+					   val, OST_MAX_SHORT_IO_BYTES);
 	spin_unlock(&cli->cl_loi_list_lock);
 
 out:
-- 
1.8.3.1
