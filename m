From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Apr 2018 00:10:01 -0400
Subject: [lustre-devel] [PATCH 19/25] staging: lustre: libcfs: update debug
 messages
In-Reply-To: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
References: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1523851807-16573-20-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Dmitry Eremin <dmitry.eremin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

For cfs_cpt_bind() change the CERROR to CDEBUG. Make the debug
message in cfs_cpt_table_create_pattern() more understandable.
Report rc value for when cfs_cpt_create_table() fails.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8703
Reviewed-on: https://review.whamcloud.com/23222
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
index c4f53ab..32ebd0f 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
@@ -655,7 +655,8 @@ int cfs_cpt_bind(struct cfs_cpt_table *cptab, int cpt)
 	}
 
 	if (cpumask_any_and(*cpumask, cpu_online_mask) >= nr_cpu_ids) {
-		CERROR("No online CPU found in CPU partition %d, did someone do CPU hotplug on system? You might need to reload Lustre modules to keep system working well.\n",
+		CDEBUG(D_INFO,
+		       "No online CPU found in CPU partition %d, did someone do CPU hotplug on system? You might need to reload Lustre modules to keep system working well.\n",
 		       cpt);
 		return -EINVAL;
 	}
@@ -886,8 +887,8 @@ static struct cfs_cpt_table *cfs_cpt_table_create(int ncpt)
 failed_mask:
 	free_cpumask_var(node_mask);
 failed:
-	CERROR("Failed to setup CPU-partition-table with %d CPU-partitions, online HW nodes: %d, HW cpus: %d.\n",
-	       ncpt, num_online_nodes(), num_online_cpus());
+	CERROR("Failed (rc = %d) to setup CPU partition table with %d partitions, online HW NUMA nodes: %d, HW CPU cores: %d.\n",
+	       rc, ncpt, num_online_nodes(), num_online_cpus());
 
 	if (cptab)
 		cfs_cpt_table_free(cptab);
@@ -1002,7 +1003,7 @@ static struct cfs_cpt_table *cfs_cpt_table_create_pattern(char *pattern)
 
 		bracket = strchr(str, ']');
 		if (!bracket) {
-			CERROR("missing right bracket for cpt %d, %s\n",
+			CERROR("Missing right bracket for partition %d, %s\n",
 			       cpt, str);
 			goto failed;
 		}
-- 
1.8.3.1
