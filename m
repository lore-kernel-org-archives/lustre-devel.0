From: NeilBrown <neilb@suse.com>
Date: Wed, 24 Apr 2019 12:17:26 +1000
Subject: [lustre-devel] [PATCH 4/4] lustre: don't define VM_FAULT_RETRY or
 FMODE_EXEC
In-Reply-To: <155607223991.16863.3231709121984405156.stgit@noble.brown>
References: <155607223991.16863.3231709121984405156.stgit@noble.brown>
Message-ID: <155607224624.16863.16858452975028857034.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

These defines were added long ago for back compatibility and we
largely harmless until
 Commit 3d3539018d2c ("mm: create the new vm_fault_t type")

which changed VM_FAULT_RETRY from a #define to an enum value.
Now "#ifndef VM_FAULT_RETRY" always finds the name isn't defined,
so it gets redefined to 0, with unfortunate results.

So remove the legacy code.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lustre/llite/llite_internal.h   |    8 --------
 1 file changed, 8 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index c8860904bdd4..9da59b1ac1c6 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -50,14 +50,6 @@
 #include "vvp_internal.h"
 #include "range_lock.h"
 
-#ifndef FMODE_EXEC
-#define FMODE_EXEC 0
-#endif
-
-#ifndef VM_FAULT_RETRY
-#define VM_FAULT_RETRY 0
-#endif
-
 /** Only used on client-side for indicating the tail of dir hash/offset. */
 #define LL_DIR_END_OFF	  0x7fffffffffffffffULL
 #define LL_DIR_END_OFF_32BIT    0x7fffffffUL
