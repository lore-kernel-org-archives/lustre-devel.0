From: James Simmons <jsimmons@infradead.org>
Date: Mon,  2 Nov 2015 12:22:11 -0500
Subject: [lustre-devel] [PATCH v2 5/7] staging: lustre: handle NULL
	comparisons correctly for libcfs_hash.h
In-Reply-To: <1446484933-23571-1-git-send-email-jsimmons@infradead.org>
References: <1446484933-23571-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1446484933-23571-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Remove all direct NULL comparisons in libcfs_hash.h.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_hash.h      |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
index 87dee16..6bd2012 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
@@ -827,7 +827,7 @@ cfs_hash_djb2_hash(const void *key, size_t size, unsigned mask)
 {
 	unsigned i, hash = 5381;
 
-	LASSERT(key != NULL);
+	LASSERT(key);
 
 	for (i = 0; i < size; i++)
 		hash = hash * 33 + ((char *)key)[i];
@@ -855,7 +855,7 @@ cfs_hash_u64_hash(const __u64 key, unsigned mask)
 
 /** iterate over all buckets in @bds (array of struct cfs_hash_bd) */
 #define cfs_hash_for_each_bd(bds, n, i)	\
-	for (i = 0; i < n && (bds)[i].bd_bucket != NULL; i++)
+	for (i = 0; i < n && (bds)[i].bd_bucket; i++)
 
 /** iterate over all buckets of @hs */
 #define cfs_hash_for_each_bucket(hs, bd, pos)			\
-- 
1.7.1
