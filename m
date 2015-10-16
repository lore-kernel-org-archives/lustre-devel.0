From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
Date: Sat, 17 Oct 2015 00:06:28 +0200
Subject: [lustre-devel] [PATCH 2/4] staging: lustre: hash.c: replace IS_PO2
	by is_power_of_2
In-Reply-To: <cover.1445032901.git.mahfouz.saif.elyazal@gmail.com>
References: <cover.1445032901.git.mahfouz.saif.elyazal@gmail.com>
Message-ID: <798c319bad7c0c621b608f499860eaaa1c78d03d.1445032901.git.mahfouz.saif.elyazal@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Replaces IS_PO2 by is_power_of_2. IS_PO2 is used with several debug
macros. In this case, it is CDEBUG. Note that the replacement changes
the types involved, because the parameter of IS_PO2 is of type long long
and the return type is int, while the parameter of is_power_of_2 is of
type long and the return type is bool. This, however, has no impact,
because the actual argument is always of type int, and the return value
is always used as a boolean.

Signed-off-by: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
---
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
