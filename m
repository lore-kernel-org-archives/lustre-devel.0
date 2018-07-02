From: James Simmons <jsimmons@infradead.org>
Date: Mon,  2 Jul 2018 19:24:47 -0400
Subject: [lustre-devel] [PATCH 03/10] lustre: libcfs: make
 lnet_debugfs_symlink_def fields const
In-Reply-To: <1530573894-20592-1-git-send-email-jsimmons@infradead.org>
References: <1530573894-20592-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1530573894-20592-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Change the fields in struct lnet_debubfs_symlink_def to
const char *.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-8066
Reviewed-on: https://review.whamcloud.com/24688
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/module.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/module.c b/drivers/staging/lustre/lnet/libcfs/module.c
index 522650b..f25270a 100644
--- a/drivers/staging/lustre/lnet/libcfs/module.c
+++ b/drivers/staging/lustre/lnet/libcfs/module.c
@@ -60,8 +60,8 @@
 #include "tracefile.h"
 
 struct lnet_debugfs_symlink_def {
-	char *name;
-	char *target;
+	const char *name;
+	const char *target;
 };
 
 static struct dentry *lnet_debugfs_root;
-- 
1.8.3.1
