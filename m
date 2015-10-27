From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
Date: Tue, 27 Oct 2015 19:42:08 +0200
Subject: [lustre-devel] [RESEND PATCH v2 1/5] staging: lustre:
 ldlm_extent.c: replace IS_PO2 by is_power_of_2
In-Reply-To: <cover.1445967419.git.mahfouz.saif.elyazal@gmail.com>
References: <cover.1445967419.git.mahfouz.saif.elyazal@gmail.com>
Message-ID: <8231e028c575cc4ab2e34601b92d3a66f11559ff.1445967419.git.mahfouz.saif.elyazal@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Replaces IS_PO2 by is_power_of_2. It is more accurate to use
is_power_of_2 since it returns 1 for numbers that are powers
of 2 only whereas IS_PO2 returns 1 for 0 and numbers that are
powers of 2.

Signed-off-by: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
---
v2:
        -changed commit message

 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
index c787888..d994ce0 100644
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
