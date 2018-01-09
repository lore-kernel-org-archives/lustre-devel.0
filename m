From: NeilBrown <neilb@suse.com>
Date: Tue, 09 Jan 2018 12:19:38 +1100
Subject: [lustre-devel] [PATCH 14/14] staging: lustre: remove LIBCFS_ALLOC,
 LIBCFS_FREE and related macros.
In-Reply-To: <151546052331.9776.7408338350463291753.stgit@noble>
References: <151546052331.9776.7408338350463291753.stgit@noble>
Message-ID: <151546077867.9776.6765866963367159386.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

LIBCFS_ALLOC
LIBCFS_ALLOC_ATOMIC
LIBCFS_ALLOC_POST
LIBCFS_CPT_ALLOC
LIBCFS_FREE

are no longer used, and so are removed.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/include/linux/libcfs/libcfs_private.h   |   51 --------------------
 1 file changed, 51 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
index 50a600564fb2..491d5971d199 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
@@ -75,57 +75,6 @@ do {								    \
 	lbug_with_loc(&msgdata);					\
 } while (0)
 
-#define LIBCFS_ALLOC_POST(ptr, size)					    \
-do {									    \
-	if (unlikely(!(ptr))) {						    \
-		CERROR("LNET: out of memory at %s:%d (tried to alloc '"	    \
-		       #ptr "' = %d)\n", __FILE__, __LINE__, (int)(size));  \
-	} else {							    \
-		memset((ptr), 0, (size));				    \
-	}								    \
-} while (0)
-
-/**
- * default allocator
- */
-#define LIBCFS_ALLOC(ptr, size)						    \
-do {									    \
-	LASSERT(!in_interrupt());					    \
-	(ptr) = kvmalloc((size), GFP_NOFS);				    \
-	LIBCFS_ALLOC_POST((ptr), (size));				    \
-} while (0)
-
-/**
- * non-sleeping allocator
- */
-#define LIBCFS_ALLOC_ATOMIC(ptr, size)					\
-do {									\
-	(ptr) = kmalloc((size), GFP_ATOMIC);				\
-	LIBCFS_ALLOC_POST(ptr, size);					\
-} while (0)
-
-/**
- * allocate memory for specified CPU partition
- *   \a cptab != NULL, \a cpt is CPU partition id of \a cptab
- *   \a cptab == NULL, \a cpt is HW NUMA node id
- */
-#define LIBCFS_CPT_ALLOC(ptr, cptab, cpt, size)				    \
-do {									    \
-	LASSERT(!in_interrupt());					    \
-	(ptr) = kvmalloc_node((size), GFP_NOFS, cfs_cpt_spread_node(cptab, cpt)); \
-	LIBCFS_ALLOC_POST((ptr), (size));				    \
-} while (0)
-
-#define LIBCFS_FREE(ptr, size)					  \
-do {								    \
-	if (unlikely(!(ptr))) {						\
-		CERROR("LIBCFS: free NULL '" #ptr "' (%d bytes) at "    \
-		       "%s:%d\n", (int)(size), __FILE__, __LINE__);	\
-		break;						  \
-	}							       \
-	kvfree(ptr);					  \
-} while (0)
-
 /*
  * Use #define rather than inline, as lnet_cpt_table() might
  * not be defined yet
