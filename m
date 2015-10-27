From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
Date: Tue, 27 Oct 2015 19:45:22 +0200
Subject: [lustre-devel] [RESEND PATCH v2 4/5] staging: lustre: selftest.h:
 replace IS_PO2 by is_power_of_2
In-Reply-To: <cover.1445967419.git.mahfouz.saif.elyazal@gmail.com>
References: <cover.1445967419.git.mahfouz.saif.elyazal@gmail.com>
Message-ID: <6424e67b55e713cc71a479e1dc19325ca7f5934f.1445967419.git.mahfouz.saif.elyazal@gmail.com>
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
        -added new patch in patch set for selftest.h

 drivers/staging/lustre/lnet/selftest/selftest.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 8a77d3f..2846f26 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -43,6 +43,8 @@
 
 #define LNET_ONLY
 
+#include <linux/log2.h>
+
 #include "../../include/linux/libcfs/libcfs.h"
 #include "../../include/linux/lnet/lnet.h"
 #include "../../include/linux/lnet/lib-lnet.h"
@@ -585,7 +587,7 @@ swi_state2str (int state)
 do {									\
 	int __I = 2;							\
 	while (!(cond)) {						\
-		CDEBUG(IS_PO2(++__I) ? D_WARNING : D_NET,		\
+		CDEBUG(is_power_of_2(++__I) ? D_WARNING : D_NET,		\
 		       fmt, ## __VA_ARGS__);				\
 		spin_unlock(&(lock));					\
 									\
-- 
2.4.2


-- 
Kind Regards,
Aya Saif El-yazal Mahfouz
