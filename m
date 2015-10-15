From: Shraddha Barke <shraddha.6596@gmail.com>
Date: Fri, 16 Oct 2015 01:00:10 +0530
Subject: [lustre-devel] [PATCH] Staging: lustre: obd_support.h: Remove
	unused OBD_SLAB_FREE_RTN0
Message-ID: <1444937410-4796-1-git-send-email-shraddha.6596@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Remove macro OBD_SLAB_FREE_RTN0 since it is defined but not used

Signed-off-by: Shraddha Barke <shraddha.6596@gmail.com>
---
 drivers/staging/lustre/lustre/include/obd_support.h | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index ec14b72c..abc53f1 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -517,12 +517,6 @@ do {									      \
 /* we memset() the slab object to 0 when allocation succeeds, so DO NOT
  * HAVE A CTOR THAT DOES ANYTHING.  its work will be cleared here.  we'd
  * love to assert on that, but slab.c keeps kmem_cache_s all to itself. */
-#define OBD_SLAB_FREE_RTN0(ptr, slab)					 \
-({									    \
-	kmem_cache_free((slab), (ptr));				    \
-	(ptr) = NULL;							 \
-	0;								    \
-})
 
 #define __OBD_SLAB_ALLOC_VERBOSE(ptr, slab, cptab, cpt, size, type)	      \
 do {									      \
-- 
2.1.4
