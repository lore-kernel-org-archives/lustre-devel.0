From: James Simmons <jsimmons@infradead.org>
Date: Sun,  8 Nov 2015 11:34:55 -0500
Subject: [lustre-devel] [PATCH] staging: lustre: Handle nodemask on UMP
	machines
In-Reply-To: <1447000500-29427-1-git-send-email-jsimmons@infradead.org>
References: <1447000500-29427-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1447000500-29427-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

For UMP and SMP machines the struct cfs_cpt_table are
defined differently. In the case handled by this patch
nodemask is defined as a integer for the UMP case and
as a pointer for the SMP case. This will cause a problem
for ost_setup which reads the nodemask directly. Instead
we create a UMP version of cfs_cpt_nodemask and use that
in ost_setup.

Signed-off-by: James Simmons <uja.ornl@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4199
Reviewed-on: http://review.whamcloud.com/9219
Reviewed-by: Liang Zhen <liang.zhen@intel.com>
Reviewed-by: Li Xi <pkuelelixi@gmail.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

Starting in 3.14 kernels nodemask_t was changed from a
a unsigned long to a linux bitmap so more than 32 cores
could be supported. Using set_bit in cfs_cpt_table_alloc
no longer compiles so this patch backports bits of the
node management function that use a linux bitmap back
end. Cleaned up libcfs bitmap.h to use the libcfs layers
memory allocation function. This was pulling in lustre
related code that was not defined.

Signed-off-by: James Simmons <uja.ornl@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4993
Reviewed-on: http://review.whamcloud.com/10332
Reviewed-by: Liang Zhen <liang.zhen@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lustre/libcfs/libcfs_cpu.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lustre/libcfs/libcfs_cpu.c
index 933525c..ba97c79 100644
--- a/drivers/staging/lustre/lustre/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lustre/libcfs/libcfs_cpu.c
@@ -58,6 +58,7 @@ cfs_cpt_table_alloc(unsigned int ncpt)
 	LIBCFS_ALLOC(cptab, sizeof(*cptab));
 	if (cptab != NULL) {
 		cptab->ctb_version = CFS_CPU_VERSION_MAGIC;
+		node_set(0, cptab->ctb_nodemask);
 		cptab->ctb_nparts  = ncpt;
 	}
 
@@ -111,6 +112,13 @@ cfs_cpt_online(struct cfs_cpt_table *cptab, int cpt)
 }
 EXPORT_SYMBOL(cfs_cpt_online);
 
+nodemask_t *
+cfs_cpt_nodemask(struct cfs_cpt_table *cptab, int cpt)
+{
+	return &cptab->ctb_nodemask;
+}
+EXPORT_SYMBOL(cfs_cpt_cpumask);
+
 int
 cfs_cpt_set_cpu(struct cfs_cpt_table *cptab, int cpt, int cpu)
 {
-- 
1.7.1
