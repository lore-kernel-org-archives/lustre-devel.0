From: James Simmons <jsimmons@infradead.org>
Date: Mon,  2 Jul 2018 19:24:52 -0400
Subject: [lustre-devel] [PATCH 08/10] lustre: libcfs: test if table is NULL
 for lnet_insert_debugfs
In-Reply-To: <1530573894-20592-1-git-send-email-jsimmons@infradead.org>
References: <1530573894-20592-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1530573894-20592-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

It is possible to call lnet_insert_debugfs() with table being NULL.
We can avoid a potential oops by adding a test to see if table is
not NULL.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Reviewed-on: https://review.whamcloud.com/24688
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/module.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 2c4268b..0d36121 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -659,7 +659,7 @@ void lnet_insert_debugfs(struct ctl_table *table)
 	 * We don't save the dentry returned because we don't call
 	 * debugfs_remove() but rather remove_recursive()
 	 */
-	for (; table->procname; table++)
+	for (; table && table->procname; table++)
 		debugfs_create_file(table->procname, table->mode,
 				    lnet_debugfs_root, table,
 				    lnet_debugfs_fops_select(table->mode));
-- 
1.8.3.1
