From: James Simmons <jsimmons@infradead.org>
Date: Wed, 27 Apr 2016 21:37:16 -0400
Subject: [lustre-devel] [PATCH 07/12] staging: lustre: libcfs: Fix NUMA
	emulated mode
In-Reply-To: <1461807441-3210-1-git-send-email-jsimmons@infradead.org>
References: <1461807441-3210-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1461807441-3210-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Andriy Skulysh <Andriy_Skulysh@xyratex.com>, James Simmons <jsimmons@infradead.org>

From: Andriy Skulysh <Andriy_Skulysh@xyratex.com>

Kernel commit c1c3443c9c5e9be92641029ed229a41563e44506
assigns all allowed cpus to emulated node.

End cpt initialization loop when all CPUs are assigned.

Signed-off-by: Andriy Skulysh <Andriy_Skulysh@xyratex.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3992
Reviewed-on: http://review.whamcloud.com/7724
Reviewed-by: Liang Zhen <liang.zhen@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
index 389fb9e..b52518c5 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
@@ -755,8 +755,13 @@ cfs_cpt_table_create(int ncpt)
 			struct cfs_cpu_partition *part;
 			int    n;
 
-			if (cpt >= ncpt)
-				goto failed;
+			/*
+			 * Each emulated NUMA node has all allowed CPUs in
+			 * the mask.
+			 * End loop when all partitions have assigned CPUs.
+			 */
+			if (cpt == ncpt)
+				break;
 
 			part = &cptab->ctb_parts[cpt];
 
-- 
2.7.4
