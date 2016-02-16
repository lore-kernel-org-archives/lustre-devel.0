From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Tue, 16 Feb 2016 00:47:03 -0500
Subject: [lustre-devel] [PATCH 31/45] staging/lustre/libcfs: reformat
	cfs_tcd_for_each_type_lock define
In-Reply-To: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
References: <1455601637-3847710-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1455601637-3847710-32-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

Avoid using leading spaces that make checkpatch unhappy.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/libcfs/tracefile.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/tracefile.h b/drivers/staging/lustre/lustre/libcfs/tracefile.h
index 67a701f..92a00ed 100644
--- a/drivers/staging/lustre/lustre/libcfs/tracefile.h
+++ b/drivers/staging/lustre/lustre/libcfs/tracefile.h
@@ -191,9 +191,9 @@ extern union cfs_trace_data_union (*cfs_trace_data[TCD_MAX_TYPES])[NR_CPUS];
 		     j++, (tcd) = &(*cfs_trace_data[i])[j].tcd)
 
 #define cfs_tcd_for_each_type_lock(tcd, i, cpu)			   \
-    for (i = 0; cfs_trace_data[i] &&				      \
-	 (tcd = &(*cfs_trace_data[i])[cpu].tcd) &&			\
-	 cfs_trace_lock_tcd(tcd, 1); cfs_trace_unlock_tcd(tcd, 1), i++)
+	for (i = 0; cfs_trace_data[i] &&				\
+	     (tcd = &(*cfs_trace_data[i])[cpu].tcd) &&			\
+	     cfs_trace_lock_tcd(tcd, 1); cfs_trace_unlock_tcd(tcd, 1), i++)
 
 /* XXX nikita: this declaration is internal to tracefile.c and should probably
  * be moved there */
-- 
2.1.0
