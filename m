From: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
Date: Wed, 14 Oct 2015 00:24:53 +0200
Subject: [lustre-devel] [PATCH 7/7] staging: lustre: remove container_of0
	and __container_of
In-Reply-To: <cover.1444774232.git.mahfouz.saif.elyazal@gmail.com>
References: <cover.1444774232.git.mahfouz.saif.elyazal@gmail.com>
Message-ID: <78ef63421d4d50eb583b22944816720eda8d4717.1444774232.git.mahfouz.saif.elyazal@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

All uses of container_of0 have been replaced by container_of.
container_of0 and __container_of can be safely removed.

Signed-off-by: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
---
 drivers/staging/lustre/include/linux/libcfs/libcfs.h | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 385ced1..e4a0c40 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -128,17 +128,6 @@ void cfs_get_random_bytes(void *buf, int size);
 #include "libcfs_fail.h"
 #include "libcfs_crypto.h"
 
-/* container_of depends on "likely" which is defined in libcfs_private.h */
-static inline void *__container_of(void *ptr, unsigned long shift)
-{
-	if (IS_ERR_OR_NULL(ptr))
-		return ptr;
-	return (char *)ptr - shift;
-}
-
-#define container_of0(ptr, type, member) \
-	((type *)__container_of((void *)(ptr), offsetof(type, member)))
-
 #define _LIBCFS_H
 
 void *libcfs_kvzalloc(size_t size, gfp_t flags);
-- 
2.4.2


-- 
Kind Regards,
Aya Saif El-yazal Mahfouz
