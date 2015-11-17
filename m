From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
Date: Tue, 17 Nov 2015 22:06:40 +0200
Subject: [lustre-devel] [PATCH 1/2] staging: lustre: hash.c: Replace IS_PO2
	by is_power_of_2
In-Reply-To: <cover.1447790571.git.mahfouz.saif.elyazal@gmail.com>
References: <cover.1447790571.git.mahfouz.saif.elyazal@gmail.com>
Message-ID: <9633b23fe9bf0cb2948d462376209573df73d5e2.1447790571.git.mahfouz.saif.elyazal@gmail.com>
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
 drivers/staging/lustre/lustre/libcfs/hash.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/hash.c b/drivers/staging/lustre/lustre/libcfs/hash.c
index d285117..4d50510 100644
--- a/drivers/staging/lustre/lustre/libcfs/hash.c
+++ b/drivers/staging/lustre/lustre/libcfs/hash.c
@@ -107,6 +107,7 @@
  *   table. Also, user can break the iteration by return 1 in callback.
  */
 #include <linux/seq_file.h>
+#include <linux/log2.h>
 
 #include "../../include/linux/libcfs/libcfs.h"
 
@@ -1777,7 +1778,7 @@ cfs_hash_rehash_cancel_locked(struct cfs_hash *hs)
 	for (i = 2; cfs_hash_is_rehashing(hs); i++) {
 		cfs_hash_unlock(hs, 1);
 		/* raise console warning while waiting too long */
-		CDEBUG(IS_PO2(i >> 3) ? D_WARNING : D_INFO,
+		CDEBUG(is_power_of_2(i >> 3) ? D_WARNING : D_INFO,
 		       "hash %s is still rehashing, rescheded %d\n",
 		       hs->hs_name, i - 1);
 		cond_resched();
-- 
2.4.3


-- 
Kind Regards,
Aya Saif El-yazal Mahfouz
