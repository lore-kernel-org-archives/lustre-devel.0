From: James Simmons <jsimmons@infradead.org>
Date: Mon,  2 Nov 2015 12:22:08 -0500
Subject: [lustre-devel] [PATCH v2 2/7] staging: lustre: remove obsolete
	comment in libcfs_hash.h
In-Reply-To: <1446484933-23571-1-git-send-email-jsimmons@infradead.org>
References: <1446484933-23571-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1446484933-23571-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Remove comment hash_long which was removed long ago.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_hash.h      |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
index 4d73f8a..4a78e6d 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
@@ -56,13 +56,6 @@
 /*  2^63 + 2^61 - 2^57 + 2^54 - 2^51 - 2^18 + 1 */
 #define CFS_GOLDEN_RATIO_PRIME_64 0x9e37fffffffc0001ULL
 
-/*
- * Ideally we would use HAVE_HASH_LONG for this, but on linux we configure
- * the linux kernel and user space at the same time, so we need to differentiate
- * between them explicitly. If this is not needed on other architectures, then
- * we'll need to move the functions to architecture specific headers.
- */
-
 #include <linux/hash.h>
 
 /** disable debug */
-- 
1.7.1
