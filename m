From: Patrick Farrell <paf@cray.com>
Date: Thu, 14 Dec 2017 03:34:37 +0000
Subject: [lustre-devel] [PATCH 07/12] staging: lustre: libcfs: simplify
 memory allocation.
In-Reply-To: <151313495497.27582.5451400666802627086.stgit@noble>
References: <151313493380.27582.16490205348451477393.stgit@noble>,
 <151313495497.27582.5451400666802627086.stgit@noble>
Message-ID: <BN6PR1101MB21322C94955D08492F1AAA36CB0A0@BN6PR1101MB2132.namprd11.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Acked-by: Patrick Farrell <paf@cray.com>
________________________________
From: lustre-devel <lustre-devel-bounces@lists.lustre.org> on behalf of NeilBrown <neilb@suse.com>
Sent: Tuesday, December 12, 2017 9:15:55 PM
To: Oleg Drokin; James Simmons; Andreas Dilger; Greg Kroah-Hartman
Cc: linux-kernel at vger.kernel.org; lustre-devel at lists.lustre.org
Subject: [lustre-devel] [PATCH 07/12] staging: lustre: libcfs: simplify memory allocation.

1/ Use kvmalloc() instead of kmalloc or vmalloc
2/ Discard the _GFP() interfaces that are never used.
  We only ever do GFP_NOFS and GFP_ATOMIC allocations,
  so support each of those explicitly.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/include/linux/libcfs/libcfs_private.h   |   42 ++++++--------------
 1 file changed, 12 insertions(+), 30 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
index 2f4ff595fac9..c874f9d15c72 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_private.h
@@ -84,14 +84,6 @@ do {                                                             \
         lbug_with_loc(&msgdata);                                        \
 } while (0)

-#ifndef LIBCFS_VMALLOC_SIZE
-#define LIBCFS_VMALLOC_SIZE    (2 << PAGE_SHIFT) /* 2 pages */
-#endif
-
-#define LIBCFS_ALLOC_PRE(size, mask)                                   \
-       LASSERT(!in_interrupt() || ((size) <= LIBCFS_VMALLOC_SIZE &&    \
-                                   !gfpflags_allow_blocking(mask)))
-
 #define LIBCFS_ALLOC_POST(ptr, size)                                        \
 do {                                                                        \
         if (unlikely(!(ptr))) {                                             \
@@ -103,46 +95,36 @@ do {                                                                           \
 } while (0)

 /**
- * allocate memory with GFP flags @mask
+ * default allocator
  */
-#define LIBCFS_ALLOC_GFP(ptr, size, mask)                                  \
+#define LIBCFS_ALLOC(ptr, size)                                                    \
 do {                                                                        \
-       LIBCFS_ALLOC_PRE((size), (mask));                                   \
-       (ptr) = (size) <= LIBCFS_VMALLOC_SIZE ?                             \
-               kmalloc((size), (mask)) : vmalloc(size);            \
+       LASSERT(!in_interrupt());                                           \
+       (ptr) = kvmalloc((size), GFP_NOFS);                                 \
         LIBCFS_ALLOC_POST((ptr), (size));                                   \
 } while (0)

-/**
- * default allocator
- */
-#define LIBCFS_ALLOC(ptr, size) \
-       LIBCFS_ALLOC_GFP(ptr, size, GFP_NOFS)
-
 /**
  * non-sleeping allocator
  */
-#define LIBCFS_ALLOC_ATOMIC(ptr, size) \
-       LIBCFS_ALLOC_GFP(ptr, size, GFP_ATOMIC)
+#define LIBCFS_ALLOC_ATOMIC(ptr, size)                                 \
+do {                                                                   \
+       (ptr) = kmalloc((size), GFP_ATOMIC);                            \
+       LIBCFS_ALLOC_POST(ptr, size);                                   \
+} while (0)

 /**
  * allocate memory for specified CPU partition
  *   \a cptab != NULL, \a cpt is CPU partition id of \a cptab
  *   \a cptab == NULL, \a cpt is HW NUMA node id
  */
-#define LIBCFS_CPT_ALLOC_GFP(ptr, cptab, cpt, size, mask)                  \
+#define LIBCFS_CPT_ALLOC(ptr, cptab, cpt, size)                                    \
 do {                                                                        \
-       LIBCFS_ALLOC_PRE((size), (mask));                                   \
-       (ptr) = (size) <= LIBCFS_VMALLOC_SIZE ?                             \
-               kmalloc_node((size), (mask), cfs_cpt_spread_node(cptab, cpt)) :\
-               vmalloc_node(size, cfs_cpt_spread_node(cptab, cpt));        \
+       LASSERT(!in_interrupt());                                           \
+       (ptr) = kvmalloc_node((size), GFP_NOFS, cfs_cpt_spread_node(cptab, cpt)); \
         LIBCFS_ALLOC_POST((ptr), (size));                                   \
 } while (0)

-/** default numa allocator */
-#define LIBCFS_CPT_ALLOC(ptr, cptab, cpt, size)                                    \
-       LIBCFS_CPT_ALLOC_GFP(ptr, cptab, cpt, size, GFP_NOFS)
-
 #define LIBCFS_FREE(ptr, size)                                    \
 do {                                                                \
         if (unlikely(!(ptr))) {                                         \


_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20171214/36814209/attachment.html>
