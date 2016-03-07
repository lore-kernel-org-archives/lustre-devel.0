From: James Simmons <jsimmons@infradead.org>
Date: Mon,  7 Mar 2016 18:10:23 -0500
Subject: [lustre-devel] [PATCH v2 8/9] staging: lustre: rename
	proc_call_handler to lprocfs_call_handler
In-Reply-To: <1457392224-2592-1-git-send-email-jsimmons@infradead.org>
References: <1457392224-2592-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1457392224-2592-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Using proc_call_handler as a function name is way too generic.
Rename to lprocfs_call_handler to avoid possible collisions.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/libcfs/module.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/module.c b/drivers/staging/lustre/lustre/libcfs/module.c
index 2a62331..a7e06ec 100644
--- a/drivers/staging/lustre/lustre/libcfs/module.c
+++ b/drivers/staging/lustre/lustre/libcfs/module.c
@@ -217,7 +217,7 @@ struct cfs_psdev_ops libcfs_psdev_ops = {
 	libcfs_ioctl
 };
 
-static int proc_call_handler(void *data, int write, loff_t *ppos,
+static int lprocfs_call_handler(void *data, int write, loff_t *ppos,
 			     void __user *buffer, size_t *lenp,
 			     int (*handler)(void *data, int write, loff_t pos,
 					    void __user *buffer, int len))
@@ -280,8 +280,8 @@ static int __proc_dobitmasks(void *data, int write,
 static int proc_dobitmasks(struct ctl_table *table, int write,
 			   void __user *buffer, size_t *lenp, loff_t *ppos)
 {
-	return proc_call_handler(table->data, write, ppos, buffer, lenp,
-				 __proc_dobitmasks);
+	return lprocfs_call_handler(table->data, write, ppos, buffer, lenp,
+				    __proc_dobitmasks);
 }
 
 static int __proc_dump_kernel(void *data, int write,
@@ -296,8 +296,8 @@ static int __proc_dump_kernel(void *data, int write,
 static int proc_dump_kernel(struct ctl_table *table, int write,
 			    void __user *buffer, size_t *lenp, loff_t *ppos)
 {
-	return proc_call_handler(table->data, write, ppos, buffer, lenp,
-				 __proc_dump_kernel);
+	return lprocfs_call_handler(table->data, write, ppos, buffer, lenp,
+				    __proc_dump_kernel);
 }
 
 static int __proc_daemon_file(void *data, int write,
@@ -319,8 +319,8 @@ static int __proc_daemon_file(void *data, int write,
 static int proc_daemon_file(struct ctl_table *table, int write,
 			    void __user *buffer, size_t *lenp, loff_t *ppos)
 {
-	return proc_call_handler(table->data, write, ppos, buffer, lenp,
-				 __proc_daemon_file);
+	return lprocfs_call_handler(table->data, write, ppos, buffer, lenp,
+				    __proc_daemon_file);
 }
 
 static int libcfs_force_lbug(struct ctl_table *table, int write,
@@ -389,8 +389,8 @@ static int __proc_cpt_table(void *data, int write,
 static int proc_cpt_table(struct ctl_table *table, int write,
 			  void __user *buffer, size_t *lenp, loff_t *ppos)
 {
-	return proc_call_handler(table->data, write, ppos, buffer, lenp,
-				 __proc_cpt_table);
+	return lprocfs_call_handler(table->data, write, ppos, buffer, lenp,
+				    __proc_cpt_table);
 }
 
 static struct ctl_table lnet_table[] = {
-- 
1.7.1
