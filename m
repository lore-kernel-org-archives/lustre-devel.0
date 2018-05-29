From: James Simmons <jsimmons@infradead.org>
Date: Tue, 29 May 2018 10:21:58 -0400
Subject: [lustre-devel] [PATCH v2 18/25] staging: lustre: libcfs: rename
 goto label in cfs_cpt_table_print
In-Reply-To: <1527603725-30560-1-git-send-email-jsimmons@infradead.org>
References: <1527603725-30560-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1527603725-30560-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <jsimmons@infradead.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Change goto label out to err.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8703
Reviewed-on: https://review.whamcloud.com/23222
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
Changelog:

v1) Initial patch
v2) Rebased patch. No changes in code from earlier patch

 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index fb27dac..e12d337 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -193,20 +193,20 @@ int cfs_cpt_table_print(struct cfs_cpt_table *cptab, char *buf, int len)
 
 	for (i = 0; i < cptab->ctb_nparts; i++) {
 		if (len <= 0)
-			goto out;
+			goto err;
 
 		rc = snprintf(tmp, len, "%d\t:", i);
 		len -= rc;
 
 		if (len <= 0)
-			goto out;
+			goto err;
 
 		tmp += rc;
 		for_each_cpu(j, cptab->ctb_parts[i].cpt_cpumask) {
 			rc = snprintf(tmp, len, "%d ", j);
 			len -= rc;
 			if (len <= 0)
-				goto out;
+				goto err;
 			tmp += rc;
 		}
 
@@ -216,7 +216,7 @@ int cfs_cpt_table_print(struct cfs_cpt_table *cptab, char *buf, int len)
 	}
 
 	return tmp - buf;
-out:
+err:
 	return -E2BIG;
 }
 EXPORT_SYMBOL(cfs_cpt_table_print);
-- 
1.8.3.1
