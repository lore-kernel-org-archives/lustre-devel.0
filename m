From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Apr 2018 00:10:03 -0400
Subject: [lustre-devel] [PATCH 21/25] staging: lustre: libcfs: report NUMA
 node instead of just node
In-Reply-To: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
References: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1523851807-16573-22-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>
Cc: Dmitry Eremin <dmitry.eremin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

From: Dmitry Eremin <dmitry.eremin@intel.com>

Reporting "HW nodes" is too generic. It really is reporting
"HW NUMA nodes". Update the debug message.

Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8703
Reviewed-on: https://review.whamcloud.com/23306
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Patrick Farrell <paf@cray.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
index 80db008..28b2acb 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
@@ -1108,7 +1108,7 @@ int cfs_cpu_init(void)
 
 	put_online_cpus();
 
-	LCONSOLE(0, "HW nodes: %d, HW CPU cores: %d, npartitions: %d\n",
+	LCONSOLE(0, "HW NUMA nodes: %d, HW CPU cores: %d, npartitions: %d\n",
 		 num_online_nodes(), num_online_cpus(),
 		 cfs_cpt_number(cfs_cpt_table));
 	return 0;
-- 
1.8.3.1
