From: NeilBrown <neilb@suse.com>
Date: Wed, 13 Dec 2017 14:15:55 +1100
Subject: [lustre-devel] [PATCH 10/12] staging: lustre: libcfs: discard
 MAX_NUMERIC_VALUE
In-Reply-To: <151313493380.27582.16490205348451477393.stgit@noble>
References: <151313493380.27582.16490205348451477393.stgit@noble>
Message-ID: <151313495506.27582.203930994943994556.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

This is unused.
drivers/staging/lustre/lnet/lnet/nidstrings.c does use the name,
but it includes its own local definition.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/include/linux/libcfs/libcfs_private.h   |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
index 27d40a7589d4..d32ce68e6c58 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
@@ -227,9 +227,6 @@ do {							    \
 #define CFS_ALLOC_PTR(ptr)      LIBCFS_ALLOC(ptr, sizeof(*(ptr)))
 #define CFS_FREE_PTR(ptr)       LIBCFS_FREE(ptr, sizeof(*(ptr)))
 
-/* max value for numeric network address */
-#define MAX_NUMERIC_VALUE 0xffffffff
-
 /* implication */
 #define ergo(a, b) (!(a) || (b))
 /* logical equivalence */
