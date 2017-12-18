From: NeilBrown <neilb@suse.com>
Date: Mon, 18 Dec 2017 11:46:30 +1100
Subject: [lustre-devel] [PATCH 15/15] staging: lustre: remove LIBCFS_ALLOC
 and LIBCFS_ALLOC_ATOMIC
In-Reply-To: <151355781721.6200.2136335532722530242.stgit@noble>
References: <151355781721.6200.2136335532722530242.stgit@noble>
Message-ID: <151355799074.6200.8015775299754662811.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

These are no longer used.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/include/linux/libcfs/libcfs_private.h   |   19 -------------------
 1 file changed, 19 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
index d230c7f7cced..35ed07ff7c71 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
@@ -85,25 +85,6 @@ do {									    \
 	}								    \
 } while (0)
 
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
 /**
  * allocate memory for specified CPU partition
  *   \a cptab != NULL, \a cpt is CPU partition id of \a cptab
