From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
Date: Tue, 17 Nov 2015 22:07:07 +0200
Subject: [lustre-devel] [PATCH 2/2] staging: lustre: libcfs.h: remove IS_PO2
	and __is_po2
In-Reply-To: <cover.1447790571.git.mahfouz.saif.elyazal@gmail.com>
References: <cover.1447790571.git.mahfouz.saif.elyazal@gmail.com>
Message-ID: <4773e080b8fdaded64596ee8b30e65cf9df7879b.1447790571.git.mahfouz.saif.elyazal@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Removes IS_PO2 and __is_po2 since the uses of IS_PO2 have
been replaced by is_power_of_2

Signed-off-by: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
---
 drivers/staging/lustre/include/linux/libcfs/libcfs.h | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 4d74e8a..7f76b20 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -42,13 +42,6 @@
 
 #include "curproc.h"
 
-static inline int __is_po2(unsigned long long val)
-{
-	return !(val & (val - 1));
-}
-
-#define IS_PO2(val) __is_po2((unsigned long long)(val))
-
 #define LOWEST_BIT_SET(x)       ((x) & ~((x) - 1))
 
 /*
-- 
2.4.3


-- 
Kind Regards,
Aya Saif El-yazal Mahfouz
