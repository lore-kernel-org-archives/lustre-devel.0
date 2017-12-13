From: NeilBrown <neilb@suse.com>
Date: Wed, 13 Dec 2017 14:15:55 +1100
Subject: [lustre-devel] [PATCH 08/12] staging: lustre: libcfs: remove unused
 rounding functions.
In-Reply-To: <151313493380.27582.16490205348451477393.stgit@noble>
References: <151313493380.27582.16490205348451477393.stgit@noble>
Message-ID: <151313495500.27582.9454376337100991831.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

These are all unused except cfs_size_round().
So discard the others, and use the kernel-standard round_up()
function to implement cfs_size_round().

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/include/linux/libcfs/libcfs_private.h   |   29 +-------------------
 1 file changed, 1 insertion(+), 28 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
index c874f9d15c72..dee5f650197f 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
@@ -243,40 +243,13 @@ do {							    \
 
 #define MKSTR(ptr) ((ptr)) ? (ptr) : ""
 
-static inline size_t cfs_size_round4(int val)
-{
-	return (val + 3) & (~0x3);
-}
-
 #ifndef HAVE_CFS_SIZE_ROUND
 static inline size_t cfs_size_round(int val)
 {
-	return (val + 7) & (~0x7);
+	return round_up(val, 8);
 }
 
 #define HAVE_CFS_SIZE_ROUND
 #endif
 
-static inline size_t cfs_size_round16(int val)
-{
-	return (val + 0xf) & (~0xf);
-}
-
-static inline size_t cfs_size_round32(int val)
-{
-	return (val + 0x1f) & (~0x1f);
-}
-
-static inline size_t cfs_size_round0(int val)
-{
-	if (!val)
-		return 0;
-	return (val + 1 + 7) & (~0x7);
-}
-
-static inline size_t cfs_round_strlen(char *fset)
-{
-	return cfs_size_round((int)strlen(fset) + 1);
-}
-
 #endif
