From: James Simmons <jsimmons@infradead.org>
Date: Sun, 24 Jun 2018 17:20:29 -0400
Subject: [lustre-devel] [PATCH v3 05/26] staging: lustre: libcfs: remove
 excess space
In-Reply-To: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
References: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1529875250-11531-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

The function cfs_cpt_table_print() was adding two spaces
to the string buffer. Just add it once.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-7734
Reviewed-on: http://review.whamcloud.com/18916
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index ea8d55c..680a2b1 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -177,7 +177,7 @@ struct cfs_cpt_table *
 
 	for (i = 0; i < cptab->ctb_nparts; i++) {
 		if (len > 0) {
-			rc = snprintf(tmp, len, "%d\t: ", i);
+			rc = snprintf(tmp, len, "%d\t:", i);
 			len -= rc;
 		}
 
-- 
1.8.3.1
