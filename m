From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
Date: Tue, 27 Oct 2015 19:44:28 +0200
Subject: [lustre-devel] [RESEND PATCH v2 3/5] staging: lustre: workitem.c:
 replace IS_PO2 by is_power_of_2
In-Reply-To: <cover.1445967419.git.mahfouz.saif.elyazal@gmail.com>
References: <cover.1445967419.git.mahfouz.saif.elyazal@gmail.com>
Message-ID: <95a2cc9e085f09d4a4abe39b71eae7b77300beed.1445967419.git.mahfouz.saif.elyazal@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Replaces IS_PO2 by is_power_of_2. It is more accurate to use
is_power_of_2 since it returns 1 for numbers that are powers
of 2 only whereas IS_PO2 returns 1 for 0 and numbers that are
powers of 2.

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
---
v2:
        -changed commit message
        -added Andreas Reviewed by tag

 drivers/staging/lustre/lustre/libcfs/workitem.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/workitem.c b/drivers/staging/lustre/lustre/libcfs/workitem.c
index e1143a5..377e1ea 100644
--- a/drivers/staging/lustre/lustre/libcfs/workitem.c
+++ b/drivers/staging/lustre/lustre/libcfs/workitem.c
@@ -41,6 +41,8 @@
 
 #define DEBUG_SUBSYSTEM S_LNET
 
+#include <linux/log2.h>
+
 #include "../../include/linux/libcfs/libcfs.h"
 
 #define CFS_WS_NAME_LEN	 16
@@ -325,7 +327,7 @@ cfs_wi_sched_destroy(struct cfs_wi_sched *sched)
 
 	spin_lock(&cfs_wi_data.wi_glock);
 	while (sched->ws_nthreads > 0) {
-		CDEBUG(IS_PO2(++i) ? D_WARNING : D_NET,
+		CDEBUG(is_power_of_2(++i) ? D_WARNING : D_NET,
 		       "waiting for %d threads of WI sched[%s] to terminate\n",
 		       sched->ws_nthreads, sched->ws_name);
 
-- 
2.4.2


-- 
Kind Regards,
Aya Saif El-yazal Mahfouz
