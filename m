From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Apr 2018 00:09:55 -0400
Subject: [lustre-devel] [PATCH 13/25] staging: lustre: libcfs: use int type
 for CPT identification.
In-Reply-To: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
References: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1523851807-16573-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Dmitry Eremin <dmitry.eremin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Use int type for CPT identification to match the linux kernel
CPU identification.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8703
Reviewed-on: https://review.whamcloud.com/23304
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h   |  2 +-
 .../staging/lustre/include/linux/libcfs/linux/linux-cpu.h  |  6 +++---
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c            |  2 +-
 drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c       | 14 +++++++-------
 4 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
index bda81ab..19a3489 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_cpu.h
@@ -108,7 +108,7 @@ static inline int cfs_cpt_table_print(struct cfs_cpt_table *cptab, char *buf,
 /**
  * create a cfs_cpt_table with \a ncpt number of partitions
  */
-struct cfs_cpt_table *cfs_cpt_table_alloc(unsigned int ncpt);
+struct cfs_cpt_table *cfs_cpt_table_alloc(int ncpt);
 /**
  * print distance information of cpt-table
  */
diff --git a/drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h b/drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h
index 4ac1670..b3bc4e7 100644
--- a/drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h
+++ b/drivers/staging/lustre/include/linux/libcfs/linux/linux-cpu.h
@@ -55,17 +55,17 @@ struct cfs_cpu_partition {
 	/* NUMA distance between CPTs */
 	unsigned int			*cpt_distance;
 	/* spread rotor for NUMA allocator */
-	unsigned int			cpt_spread_rotor;
+	int				 cpt_spread_rotor;
 };
 
 /** descriptor for CPU partitions */
 struct cfs_cpt_table {
 	/* spread rotor for NUMA allocator */
-	unsigned int			ctb_spread_rotor;
+	int				ctb_spread_rotor;
 	/* maximum NUMA distance between all nodes in table */
 	unsigned int			ctb_distance;
 	/* # of CPU partitions */
-	unsigned int			ctb_nparts;
+	int				ctb_nparts;
 	/* partitions tables */
 	struct cfs_cpu_partition	*ctb_parts;
 	/* shadow HW CPU to CPU partition ID */
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index f9fcbb1..5d7d44d 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -43,7 +43,7 @@
 
 #define CFS_CPT_DISTANCE	1	/* Arbitrary positive value */
 
-struct cfs_cpt_table *cfs_cpt_table_alloc(unsigned int ncpt)
+struct cfs_cpt_table *cfs_cpt_table_alloc(int ncpt)
 {
 	struct cfs_cpt_table *cptab;
 
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
index 5c9cdf4..1669669 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
@@ -88,7 +88,7 @@ void cfs_cpt_table_free(struct cfs_cpt_table *cptab)
 }
 EXPORT_SYMBOL(cfs_cpt_table_free);
 
-struct cfs_cpt_table *cfs_cpt_table_alloc(unsigned int ncpt)
+struct cfs_cpt_table *cfs_cpt_table_alloc(int ncpt)
 {
 	struct cfs_cpt_table *cptab;
 	int i;
@@ -759,13 +759,13 @@ static int cfs_cpt_choose_ncpus(struct cfs_cpt_table *cptab, int cpt,
 	return rc;
 }
 
-#define CPT_WEIGHT_MIN  4u
+#define CPT_WEIGHT_MIN 4
 
-static unsigned int cfs_cpt_num_estimate(void)
+static int cfs_cpt_num_estimate(void)
 {
-	unsigned int nnode = num_online_nodes();
-	unsigned int ncpu = num_online_cpus();
-	unsigned int ncpt;
+	int nnode = num_online_nodes();
+	int ncpu = num_online_cpus();
+	int ncpt;
 
 	if (ncpu <= CPT_WEIGHT_MIN) {
 		ncpt = 1;
@@ -795,7 +795,7 @@ static unsigned int cfs_cpt_num_estimate(void)
 	/* config many CPU partitions on 32-bit system could consume
 	 * too much memory
 	 */
-	ncpt = min(2U, ncpt);
+	ncpt = min(2, ncpt);
 #endif
 	while (ncpu % ncpt)
 		ncpt--; /* worst case is 1 */
-- 
1.8.3.1
