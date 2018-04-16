From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Apr 2018 00:10:00 -0400
Subject: [lustre-devel] [PATCH 18/25] staging: lustre: libcfs: clear up
 failure patch in cfs_cpt_*_print
In-Reply-To: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
References: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1523851807-16573-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Dmitry Eremin <dmitry.eremin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Currently both cfs_cpt_table_print() and cfs_cpt_distance_print()
handle the error path in a confusing way. Simplify it so it just
returns E2BIG on failure instead of testing rc value before
exiting.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8703
Reviewed-on: https://review.whamcloud.com/23222
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c | 19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
index 435ee8e..c4f53ab 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
@@ -155,7 +155,7 @@ struct cfs_cpt_table *cfs_cpt_table_alloc(int ncpt)
 int cfs_cpt_table_print(struct cfs_cpt_table *cptab, char *buf, int len)
 {
 	char *tmp = buf;
-	int rc = -EFBIG;
+	int rc;
 	int i;
 	int j;
 
@@ -183,19 +183,17 @@ int cfs_cpt_table_print(struct cfs_cpt_table *cptab, char *buf, int len)
 		len--;
 	}
 
-	rc = 0;
-err:
-	if (rc < 0)
-		return rc;
-
 	return tmp - buf;
+
+err:
+	return -E2BIG;
 }
 EXPORT_SYMBOL(cfs_cpt_table_print);
 
 int cfs_cpt_distance_print(struct cfs_cpt_table *cptab, char *buf, int len)
 {
 	char *tmp = buf;
-	int rc = -EFBIG;
+	int rc;
 	int i;
 	int j;
 
@@ -223,12 +221,11 @@ int cfs_cpt_distance_print(struct cfs_cpt_table *cptab, char *buf, int len)
 		tmp++;
 		len--;
 	}
-	rc = 0;
-err:
-	if (rc < 0)
-		return rc;
 
 	return tmp - buf;
+
+err:
+	return -E2BIG;
 }
 EXPORT_SYMBOL(cfs_cpt_distance_print);
 
-- 
1.8.3.1
