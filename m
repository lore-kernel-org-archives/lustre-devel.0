From: James Simmons <jsimmons@infradead.org>
Date: Sun,  2 Oct 2016 22:28:06 -0400
Subject: [lustre-devel] [PATCH 10/41] staging: lustre: libcfs: shortcut to
	create CPT from NUMA topology
In-Reply-To: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
References: <1475461717-21631-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1475461717-21631-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Liang Zhen <liang.zhen@intel.com>, James Simmons <jsimmons@infradead.org>

From: Liang Zhen <liang.zhen@intel.com>

If user wants to create CPT table that can match numa topology,
she has to query cpu & numa topology, then provide a pattern
string to describe the topology, this is inconvenient.

To improve it, this patch can support shortcut expression "N" or "n"
to create CPT table from NUMA & CPU topology

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6325
Reviewed-on: http://review.whamcloud.com/14049
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/libcfs/linux/linux-cpu.c   |   48 ++++++++++++++++---
 1 files changed, 40 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
index e8b1a61..464b279 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
@@ -55,6 +55,8 @@ MODULE_PARM_DESC(cpu_npartitions, "# of CPU partitions");
  * i.e: "N 0[0,1] 1[2,3]" the first character 'N' means numbers in bracket
  *       are NUMA node ID, number before bracket is CPU partition ID.
  *
+ * i.e: "N", shortcut expression to create CPT from NUMA & CPU topology
+ *
  * NB: If user specified cpu_pattern, cpu_npartitions will be ignored
  */
 static char	*cpu_pattern = "";
@@ -818,11 +820,14 @@ static struct cfs_cpt_table *
 cfs_cpt_table_create_pattern(char *pattern)
 {
 	struct cfs_cpt_table	*cptab;
-	char			*str	= pattern;
+	char *str;
 	int			node	= 0;
 	int			high;
-	int			ncpt;
+	int ncpt = 0;
+	int cpt;
+	int rc;
 	int			c;
+	int i;
 
 	for (ncpt = 0;; ncpt++) { /* quick scan bracket */
 		str = strchr(str, '[');
@@ -834,7 +839,20 @@ cfs_cpt_table_create_pattern(char *pattern)
 	str = cfs_trimwhite(pattern);
 	if (*str == 'n' || *str == 'N') {
 		pattern = str + 1;
-		node = 1;
+		if (*pattern != '\0') {
+			node = 1;
+		} else { /* shortcut to create CPT from NUMA & CPU topology */
+			node = -1;
+			ncpt = num_online_nodes();
+		}
+	}
+
+	if (!ncpt) { /* scanning bracket which is mark of partition */
+		for (str = pattern;; str++, ncpt++) {
+			str = strchr(str, '[');
+			if (!str)
+				break;
+		}
 	}
 
 	if (ncpt == 0 ||
@@ -845,21 +863,35 @@ cfs_cpt_table_create_pattern(char *pattern)
 		return NULL;
 	}
 
-	high = node ? MAX_NUMNODES - 1 : nr_cpu_ids - 1;
-
 	cptab = cfs_cpt_table_alloc(ncpt);
 	if (!cptab) {
 		CERROR("Failed to allocate cpu partition table\n");
 		return NULL;
 	}
 
+	if (node < 0) { /* shortcut to create CPT from NUMA & CPU topology */
+		cpt = 0;
+
+		for_each_online_node(i) {
+			if (cpt >= ncpt) {
+				CERROR("CPU changed while setting CPU partition table, %d/%d\n",
+				       cpt, ncpt);
+				goto failed;
+			}
+
+			rc = cfs_cpt_set_node(cptab, cpt++, i);
+			if (!rc)
+				goto failed;
+		}
+		return cptab;
+	}
+
+	high = node ? MAX_NUMNODES - 1 : nr_cpu_ids - 1;
+
 	for (str = cfs_trimwhite(pattern), c = 0;; c++) {
 		struct cfs_range_expr	*range;
 		struct cfs_expr_list	*el;
 		char			*bracket = strchr(str, '[');
-		int			cpt;
-		int			rc;
-		int			i;
 		int			n;
 
 		if (!bracket) {
-- 
1.7.1
