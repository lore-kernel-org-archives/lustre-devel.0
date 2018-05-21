From: NeilBrown <neilb@suse.com>
Date: Mon, 21 May 2018 14:35:13 +1000
Subject: [lustre-devel] [PATCH 25/30] staging: lustre: remove libcfs_all.h
 from remaining .h files.
In-Reply-To: <152687724799.24196.7718555295926047576.stgit@noble>
References: <152687724799.24196.7718555295926047576.stgit@noble>
Message-ID: <152687731332.24196.2883662038109425292.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Now no *.h files include libcfs_all.h - only *.c files.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/include/linux/libcfs/libcfs_hash.h      |    3 +++
 drivers/staging/lustre/lustre/fid/fid_internal.h   |    1 -
 drivers/staging/lustre/lustre/fld/fld_internal.h   |    1 -
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    1 +
 drivers/staging/lustre/lustre/llite/range_lock.c   |    1 +
 drivers/staging/lustre/lustre/llite/range_lock.h   |    2 +-
 drivers/staging/lustre/lustre/llite/vvp_dev.c      |    1 +
 .../staging/lustre/lustre/lov/lov_cl_internal.h    |    2 --
 drivers/staging/lustre/lustre/mgc/mgc_internal.h   |    1 -
 drivers/staging/lustre/lustre/mgc/mgc_request.c    |    1 +
 .../staging/lustre/lustre/osc/osc_cl_internal.h    |    2 --
 11 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
index 0506f1d45757..be315958a4b3 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_hash.h
@@ -40,6 +40,9 @@
 #define __LIBCFS_HASH_H__
 
 #include <linux/hash.h>
+#include <linux/spinlock.h>
+#include <linux/workqueue.h>
+#include <linux/libcfs/libcfs.h>
 
 /*
  * Knuth recommends primes in approximately golden ratio to the maximum
diff --git a/drivers/staging/lustre/lustre/fid/fid_internal.h b/drivers/staging/lustre/lustre/fid/fid_internal.h
index 3d0003b2fb4b..14569e969a31 100644
--- a/drivers/staging/lustre/lustre/fid/fid_internal.h
+++ b/drivers/staging/lustre/lustre/fid/fid_internal.h
@@ -38,7 +38,6 @@
 #define __FID_INTERNAL_H
 
 #include <uapi/linux/lustre/lustre_idl.h>
-#include <linux/libcfs/libcfs_all.h>
 
 /* Functions used internally in module. */
 
diff --git a/drivers/staging/lustre/lustre/fld/fld_internal.h b/drivers/staging/lustre/lustre/fld/fld_internal.h
index 9485c3d31559..e1d6aaa5c2b4 100644
--- a/drivers/staging/lustre/lustre/fld/fld_internal.h
+++ b/drivers/staging/lustre/lustre/fld/fld_internal.h
@@ -59,7 +59,6 @@
 
 #include <uapi/linux/lustre/lustre_idl.h>
 
-#include <linux/libcfs/libcfs_all.h>
 #include <lustre_req_layout.h>
 #include <lustre_fld.h>
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index bdb53ab77e58..7097361b3a1a 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -41,6 +41,7 @@
 #include <linux/statfs.h>
 #include <linux/types.h>
 #include <linux/mm.h>
+#include <linux/random.h>
 
 #include <uapi/linux/lustre/lustre_ioctl.h>
 #include <lustre_ha.h>
diff --git a/drivers/staging/lustre/lustre/llite/range_lock.c b/drivers/staging/lustre/lustre/llite/range_lock.c
index cc9565f6bfe2..008a8874118d 100644
--- a/drivers/staging/lustre/lustre/llite/range_lock.c
+++ b/drivers/staging/lustre/lustre/llite/range_lock.c
@@ -36,6 +36,7 @@
  */
 #include "range_lock.h"
 #include <uapi/linux/lustre/lustre_idl.h>
+#include <linux/libcfs/libcfs.h>
 
 /**
  * Initialize a range lock tree
diff --git a/drivers/staging/lustre/lustre/llite/range_lock.h b/drivers/staging/lustre/lustre/llite/range_lock.h
index 4af8781c71d7..9ebac09160f2 100644
--- a/drivers/staging/lustre/lustre/llite/range_lock.h
+++ b/drivers/staging/lustre/lustre/llite/range_lock.h
@@ -37,7 +37,7 @@
 #ifndef _RANGE_LOCK_H
 #define _RANGE_LOCK_H
 
-#include <linux/libcfs/libcfs_all.h>
+#include <linux/spinlock.h>
 #include <interval_tree.h>
 
 struct range_lock {
diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index 8bda51fd97a2..31dc3c0ade01 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -38,6 +38,7 @@
 
 #define DEBUG_SUBSYSTEM S_LLITE
 
+#include <linux/libcfs/libcfs_hash.h>
 #include <obd.h>
 #include "llite_internal.h"
 #include "vvp_internal.h"
diff --git a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
index d5849051319b..e4f762137a4a 100644
--- a/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_cl_internal.h
@@ -43,8 +43,6 @@
 #ifndef LOV_CL_INTERNAL_H
 #define LOV_CL_INTERNAL_H
 
-#include <linux/libcfs/libcfs_all.h>
-
 #include <obd.h>
 #include <cl_object.h>
 #include "lov_internal.h"
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_internal.h b/drivers/staging/lustre/lustre/mgc/mgc_internal.h
index e402898cb28b..9541892b67c7 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_internal.h
+++ b/drivers/staging/lustre/lustre/mgc/mgc_internal.h
@@ -34,7 +34,6 @@
 #ifndef _MGC_INTERNAL_H
 #define _MGC_INTERNAL_H
 
-#include <linux/libcfs/libcfs_all.h>
 #include <lustre_lib.h>
 #include <lustre_dlm.h>
 #include <lustre_log.h>
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index 36c3f13ab9f4..32df804614d3 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -39,6 +39,7 @@
 #define D_MGC D_CONFIG /*|D_WARNING*/
 
 #include <linux/module.h>
+#include <linux/random.h>
 
 #include <lprocfs_status.h>
 #include <lustre_dlm.h>
diff --git a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
index 29f318403328..2d3cba16ef34 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_cl_internal.h
@@ -43,8 +43,6 @@
 #ifndef OSC_CL_INTERNAL_H
 #define OSC_CL_INTERNAL_H
 
-#include <linux/libcfs/libcfs_all.h>
-
 #include <obd.h>
 /* osc_build_res_name() */
 #include <cl_object.h>
