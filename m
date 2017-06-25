From: Denis Petrovic <denis.petrovic@edu.ece.fr>
Date: Sun, 25 Jun 2017 14:52:48 +0200
Subject: [lustre-devel] [PATCH] staging: lustre: replace kmalloc with
	kmalloc_array
Message-ID: <20170625125248.936-1-denis.petrovic@edu.ece.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Denis Petrovic <denis.petrovic@edu.ece.fr>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

This patch fixes the following checkpatch.pl warning:

WARNING: Prefer kmalloc_array over kmalloc with multiply

Signed-off-by: Denis Petrovic <denis.petrovic@edu.ece.fr>
---
 drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c
index 75eb84e7f0f8..a5a94788f11f 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-tracefile.c
@@ -57,8 +57,9 @@ int cfs_tracefile_init_arch(void)
 	memset(cfs_trace_data, 0, sizeof(cfs_trace_data));
 	for (i = 0; i < CFS_TCD_TYPE_MAX; i++) {
 		cfs_trace_data[i] =
-			kmalloc(sizeof(union cfs_trace_data_union) *
-				num_possible_cpus(), GFP_KERNEL);
+			kmalloc_array(num_possible_cpus(),
+				      sizeof(union cfs_trace_data_union),
+				      GFP_KERNEL);
 		if (!cfs_trace_data[i])
 			goto out;
 	}
-- 
2.11.0
