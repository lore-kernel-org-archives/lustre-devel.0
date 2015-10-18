From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
Date: Sun, 18 Oct 2015 13:14:56 +0200
Subject: [lustre-devel] [PATCH v2 2/5] staging: lustre: hash.c: Replace
 IS_PO2 by is_power_of_2
In-Reply-To: <cover.1445166429.git.mahfouz.saif.elyazal@gmail.com>
References: <cover.1445166429.git.mahfouz.saif.elyazal@gmail.com>
Message-ID: <3b5f88331856582fe517be9d55f3ddded80e6c88.1445166429.git.mahfouz.saif.elyazal@gmail.com>
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

 drivers/staging/lustre/lustre/libcfs/hash.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/libcfs/hash.c b/drivers/staging/lustre/lustre/libcfs/hash.c
index 6f4c7d4..4b5e79a 100644
--- a/drivers/staging/lustre/lustre/libcfs/hash.c
+++ b/drivers/staging/lustre/lustre/libcfs/hash.c
@@ -109,6 +109,8 @@
 
 #include "../../include/linux/libcfs/libcfs.h"
 #include <linux/seq_file.h>
+#include <linux/log2.h>
+
 
 #if CFS_HASH_DEBUG_LEVEL >= CFS_HASH_DEBUG_1
 static unsigned int warn_on_depth = 8;
@@ -1785,7 +1787,7 @@ cfs_hash_rehash_cancel_locked(struct cfs_hash *hs)
 	for (i = 2; cfs_hash_is_rehashing(hs); i++) {
 		cfs_hash_unlock(hs, 1);
 		/* raise console warning while waiting too long */
-		CDEBUG(IS_PO2(i >> 3) ? D_WARNING : D_INFO,
+		CDEBUG(is_power_of_2(i >> 3) ? D_WARNING : D_INFO,
 		       "hash %s is still rehashing, rescheded %d\n",
 		       hs->hs_name, i - 1);
 		cond_resched();
-- 
2.4.2


-- 
Kind Regards,
Aya Saif El-yazal Mahfouz
