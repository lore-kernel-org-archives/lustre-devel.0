From: James Simmons <jsimmons@infradead.org>
Date: Mon,  2 Nov 2015 12:22:09 -0500
Subject: [lustre-devel] [PATCH v2 3/7] staging: lustre: move linux hash.h
	header to start of libcfs_hash.h
In-Reply-To: <1446484933-23571-1-git-send-email-jsimmons@infradead.org>
References: <1446484933-23571-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1446484933-23571-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Minor style cleanup to put hash.h header to the top of the
libcfs_hash.h file.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_hash.h      |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
index 4a78e6d..2e0c892 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
@@ -41,6 +41,9 @@
 
 #ifndef __LIBCFS_HASH_H__
 #define __LIBCFS_HASH_H__
+
+#include <linux/hash.h>
+
 /*
  * Knuth recommends primes in approximately golden ratio to the maximum
  * integer representable by a machine word for multiplicative hashing.
@@ -56,8 +59,6 @@
 /*  2^63 + 2^61 - 2^57 + 2^54 - 2^51 - 2^18 + 1 */
 #define CFS_GOLDEN_RATIO_PRIME_64 0x9e37fffffffc0001ULL
 
-#include <linux/hash.h>
-
 /** disable debug */
 #define CFS_HASH_DEBUG_NONE	0
 /** record hash depth and output to console when it's too deep,
-- 
1.7.1
