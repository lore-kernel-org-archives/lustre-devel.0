From: James Simmons <jsimmons@infradead.org>
Date: Sun, 24 Jun 2018 17:20:30 -0400
Subject: [lustre-devel] [PATCH v3 06/26] staging: lustre: libcfs: replace
 num_possible_cpus() with nr_cpu_ids
In-Reply-To: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
References: <1529875250-11531-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1529875250-11531-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

Move from num_possible_cpus() to nr_cpu_ids.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-7734
Reviewed-on: http://review.whamcloud.com/18916
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index 680a2b1..33294da 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -93,14 +93,14 @@ struct cfs_cpt_table *
 	if (!cptab->ctb_nodemask)
 		goto failed_alloc_nodemask;
 
-	cptab->ctb_cpu2cpt = kvmalloc_array(num_possible_cpus(),
+	cptab->ctb_cpu2cpt = kvmalloc_array(nr_cpu_ids,
 					    sizeof(cptab->ctb_cpu2cpt[0]),
 					    GFP_KERNEL);
 	if (!cptab->ctb_cpu2cpt)
 		goto failed_alloc_cpu2cpt;
 
 	memset(cptab->ctb_cpu2cpt, -1,
-	       num_possible_cpus() * sizeof(cptab->ctb_cpu2cpt[0]));
+	       nr_cpu_ids * sizeof(cptab->ctb_cpu2cpt[0]));
 
 	cptab->ctb_parts = kvmalloc_array(ncpt, sizeof(cptab->ctb_parts[0]),
 					  GFP_KERNEL);
-- 
1.8.3.1
