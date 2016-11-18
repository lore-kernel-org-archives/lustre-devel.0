From: James Simmons <jsimmons@infradead.org>
Date: Fri, 18 Nov 2016 11:48:42 -0500
Subject: [lustre-devel] [PATCH 08/10] staging: lustre: libcfs: remove NULL
	comparisons in headers
In-Reply-To: <1479487724-20386-1-git-send-email-jsimmons@infradead.org>
References: <1479487724-20386-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1479487724-20386-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Remove the NULL comparisions in the libcfs headers.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/linux/libcfs/libcfs_hash.h      |    2 +-
 .../lustre/include/linux/libcfs/libcfs_private.h   |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
index 85661b3..d0ba3e0 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
@@ -818,7 +818,7 @@ static inline int __cfs_hash_theta(struct cfs_hash *hs)
 {
 	unsigned int i, hash = 5381;
 
-	LASSERT(key != NULL);
+	LASSERT(key);
 
 	for (i = 0; i < size; i++)
 		hash = hash * 33 + ((char *)key)[i];
diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
index 93bff1b..fc180b8 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
@@ -96,7 +96,7 @@
 
 #define LIBCFS_ALLOC_POST(ptr, size)					    \
 do {									    \
-	if (unlikely((ptr) == NULL)) {					    \
+	if (!unlikely((ptr))) {						    \
 		CERROR("LNET: out of memory at %s:%d (tried to alloc '"	    \
 		       #ptr "' = %d)\n", __FILE__, __LINE__, (int)(size));  \
 	} else {							    \
@@ -147,7 +147,7 @@
 
 #define LIBCFS_FREE(ptr, size)					  \
 do {								    \
-	if (unlikely((ptr) == NULL)) {				  \
+	if (!unlikely((ptr))) {						\
 		CERROR("LIBCFS: free NULL '" #ptr "' (%d bytes)@"    \
 		       "%s:%d\n", (int)(size), __FILE__, __LINE__);	\
 		break;						  \
-- 
1.7.1
