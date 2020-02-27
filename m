From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:12:09 -0500
Subject: [lustre-devel] [PATCH 261/622] lnet: Avoid lnet debugfs read/write
 if ctl_table does not exist
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-262-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Sonia Sharma <sharmaso@whamcloud.com>

Running command "lctl get param -n stats" after lnet
is taken down leads to kernel panic because it
tries to read from the file which doesn't exist
anymore.

In lnet_debugfs_read() and lnet_debugfs_write(),
check if struct ctl_table is valid before trying
to read/write to it.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11986
Lustre-commit: 54ca5e471d9f ("LU-11986 lnet: Avoid lnet debugfs read/write if ctl_table does not exist")
Signed-off-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34634
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/libcfs/module.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/lnet/libcfs/module.c b/net/lnet/libcfs/module.c
index bee2581..37a3fee 100644
--- a/net/lnet/libcfs/module.c
+++ b/net/lnet/libcfs/module.c
@@ -597,9 +597,11 @@ static ssize_t lnet_debugfs_read(struct file *filp, char __user *buf,
 {
 	struct ctl_table *table = filp->private_data;
 	loff_t old_pos = *ppos;
-	ssize_t rc;
+	ssize_t rc = -EINVAL;
 
-	rc = table->proc_handler(table, 0, (void __user *)buf, &count, ppos);
+	if (table)
+		rc = table->proc_handler(table, 0, (void __user *)buf,
+					 &count, ppos);
 	/*
 	 * On success, the length read is either in error or in count.
 	 * If ppos changed, then use count, else use error
@@ -617,9 +619,11 @@ static ssize_t lnet_debugfs_write(struct file *filp, const char __user *buf,
 {
 	struct ctl_table *table = filp->private_data;
 	loff_t old_pos = *ppos;
-	ssize_t rc;
+	ssize_t rc = -EINVAL;
 
-	rc = table->proc_handler(table, 1, (void __user *)buf, &count, ppos);
+	if (table)
+		rc = table->proc_handler(table, 1, (void __user *)buf, &count,
+					 ppos);
 	if (rc)
 		return rc;
 
-- 
1.8.3.1
