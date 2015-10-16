From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
Date: Sat, 17 Oct 2015 00:05:44 +0200
Subject: [lustre-devel] [PATCH 1/4] staging: lustre: ldlm_extent.c: replace
 IS_PO2 by is_power_of_2
In-Reply-To: <cover.1445032901.git.mahfouz.saif.elyazal@gmail.com>
References: <cover.1445032901.git.mahfouz.saif.elyazal@gmail.com>
Message-ID: <ea0e738a41b54bc91dadc33d6d35a678174a9233.1445032901.git.mahfouz.saif.elyazal@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Replaces IS_PO2 by is_power_of_2. IS_PO2 is used with several debug
macros. In this case, it is LASSERT. Note that the replacement changes
the types involved, because the parameter of IS_PO2 is of type long
long and the return type is int, while the parameter of is_power_of_2
is of type long and the return type is bool. This, however, has no
impact, because the actual argument is always of type int, and the
return value is always used as a boolean.

Signed-off-by: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
---
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
index 57b997d..3e7e97e 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
@@ -50,6 +50,9 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LDLM
+
+#include <linux/log2.h>
+
 #include "../../include/linux/libcfs/libcfs.h"
 #include "../include/lustre_dlm.h"
 #include "../include/obd_support.h"
@@ -149,7 +152,7 @@ static inline int lock_mode_to_index(ldlm_mode_t mode)
 	int index;
 
 	LASSERT(mode != 0);
-	LASSERT(IS_PO2(mode));
+	LASSERT(is_power_of_2(mode));
 	for (index = -1; mode; index++)
 		mode >>= 1;
 	LASSERT(index < LCK_MODE_NUM);
-- 
2.4.2


-- 
Kind Regards,
Aya Saif El-yazal Mahfouz
