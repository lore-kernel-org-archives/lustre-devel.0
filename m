From: James Simmons <jsimmons@infradead.org>
Date: Mon,  7 Mar 2016 18:10:24 -0500
Subject: [lustre-devel] [PATCH v2 9/9] staging: lustre: make LNet use
	lprocfs_call_handler
In-Reply-To: <1457392224-2592-1-git-send-email-jsimmons@infradead.org>
References: <1457392224-2592-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1457392224-2592-10-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Sometime ago a patch was submitted to duplicate the
proc_call_handler code in the LNet layer. This was
due to the thinking libcfs was not used by the LNet
layer. This was a wrong assumption so lets make LNet
use the lprocfs_call_handler from the libcfs layer.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |    4 ++
 drivers/staging/lustre/lnet/lnet/router_proc.c     |   32 ++++----------------
 drivers/staging/lustre/lustre/libcfs/module.c      |    9 +++--
 3 files changed, 15 insertions(+), 30 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 1eab0eb..7d63620 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -154,5 +154,9 @@ struct lnet_debugfs_symlink_def {
 
 void lustre_insert_debugfs(struct ctl_table *table,
 			   const struct lnet_debugfs_symlink_def *symlinks);
+int lprocfs_call_handler(void *data, int write, loff_t *ppos,
+			  void __user *buffer, size_t *lenp,
+			  int (*handler)(void *data, int write,
+			  loff_t pos, void __user *buffer, int len));
 
 #endif /* _LIBCFS_H */
diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
index ce4331e..65f65a3 100644
--- a/drivers/staging/lustre/lnet/lnet/router_proc.c
+++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
@@ -73,26 +73,6 @@
 
 #define LNET_PROC_VERSION(v)	((unsigned int)((v) & LNET_PROC_VER_MASK))
 
-static int proc_call_handler(void *data, int write, loff_t *ppos,
-			     void __user *buffer, size_t *lenp,
-			     int (*handler)(void *data, int write,
-					    loff_t pos, void __user *buffer,
-					    int len))
-{
-	int rc = handler(data, write, *ppos, buffer, *lenp);
-
-	if (rc < 0)
-		return rc;
-
-	if (write) {
-		*ppos += *lenp;
-	} else {
-		*lenp = rc;
-		*ppos += rc;
-	}
-	return 0;
-}
-
 static int __proc_lnet_stats(void *data, int write,
 			     loff_t pos, void __user *buffer, int nob)
 {
@@ -144,8 +124,8 @@ static int __proc_lnet_stats(void *data, int write,
 static int proc_lnet_stats(struct ctl_table *table, int write,
 			   void __user *buffer, size_t *lenp, loff_t *ppos)
 {
-	return proc_call_handler(table->data, write, ppos, buffer, lenp,
-				 __proc_lnet_stats);
+	return lprocfs_call_handler(table->data, write, ppos, buffer, lenp,
+				    __proc_lnet_stats);
 }
 
 static int proc_lnet_routes(struct ctl_table *table, int write,
@@ -640,8 +620,8 @@ static int __proc_lnet_buffers(void *data, int write,
 static int proc_lnet_buffers(struct ctl_table *table, int write,
 			     void __user *buffer, size_t *lenp, loff_t *ppos)
 {
-	return proc_call_handler(table->data, write, ppos, buffer, lenp,
-				 __proc_lnet_buffers);
+	return lprocfs_call_handler(table->data, write, ppos, buffer, lenp,
+				    __proc_lnet_buffers);
 }
 
 static int proc_lnet_nis(struct ctl_table *table, int write,
@@ -865,8 +845,8 @@ static int proc_lnet_portal_rotor(struct ctl_table *table, int write,
 				  void __user *buffer, size_t *lenp,
 				  loff_t *ppos)
 {
-	return proc_call_handler(table->data, write, ppos, buffer, lenp,
-				 __proc_lnet_portal_rotor);
+	return lprocfs_call_handler(table->data, write, ppos, buffer, lenp,
+				    __proc_lnet_portal_rotor);
 }
 
 static struct ctl_table lnet_table[] = {
diff --git a/drivers/staging/lustre/lustre/libcfs/module.c b/drivers/staging/lustre/lustre/libcfs/module.c
index a7e06ec..cdc640b 100644
--- a/drivers/staging/lustre/lustre/libcfs/module.c
+++ b/drivers/staging/lustre/lustre/libcfs/module.c
@@ -217,10 +217,10 @@ struct cfs_psdev_ops libcfs_psdev_ops = {
 	libcfs_ioctl
 };
 
-static int lprocfs_call_handler(void *data, int write, loff_t *ppos,
-			     void __user *buffer, size_t *lenp,
-			     int (*handler)(void *data, int write, loff_t pos,
-					    void __user *buffer, int len))
+int lprocfs_call_handler(void *data, int write, loff_t *ppos,
+			 void __user *buffer, size_t *lenp,
+			 int (*handler)(void *data, int write, loff_t pos,
+					void __user *buffer, int len))
 {
 	int rc = handler(data, write, *ppos, buffer, *lenp);
 
@@ -235,6 +235,7 @@ static int lprocfs_call_handler(void *data, int write, loff_t *ppos,
 	}
 	return 0;
 }
+EXPORT_SYMBOL(lprocfs_call_handler);
 
 static int __proc_dobitmasks(void *data, int write,
 			     loff_t pos, void __user *buffer, int nob)
-- 
1.7.1
