From: NeilBrown <neilb@suse.com>
Date: Mon, 21 May 2018 14:35:13 +1000
Subject: [lustre-devel] [PATCH 28/30] staging: lustre: remove remaining
 libcfs_all.h includes from lustre/lustre
In-Reply-To: <152687724799.24196.7718555295926047576.stgit@noble>
References: <152687724799.24196.7718555295926047576.stgit@noble>
Message-ID: <152687731343.24196.4772952915845005954.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Most of these aren't needed, a few can be simplified.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lustre/include/lustre_intent.h  |    2 ++
 drivers/staging/lustre/lustre/ldlm/l_lock.c        |    1 -
 drivers/staging/lustre/lustre/ldlm/ldlm_extent.c   |    1 -
 drivers/staging/lustre/lustre/ldlm/ldlm_lib.c      |    1 -
 drivers/staging/lustre/lustre/ldlm/ldlm_lock.c     |    1 -
 drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c    |    2 +-
 drivers/staging/lustre/lustre/llite/glimpse.c      |    1 -
 drivers/staging/lustre/lustre/llite/lcommon_cl.c   |    1 -
 drivers/staging/lustre/lustre/llite/vvp_object.c   |    2 --
 drivers/staging/lustre/lustre/lov/lov_ea.c         |    1 -
 drivers/staging/lustre/lustre/lov/lov_merge.c      |    2 --
 drivers/staging/lustre/lustre/lov/lov_obd.c        |    1 -
 drivers/staging/lustre/lustre/lov/lov_offset.c     |    2 --
 drivers/staging/lustre/lustre/lov/lov_pool.c       |    2 --
 drivers/staging/lustre/lustre/lov/lov_request.c    |    2 --
 .../staging/lustre/lustre/obdecho/echo_client.c    |    1 -
 drivers/staging/lustre/lustre/osc/osc_lock.c       |    1 -
 drivers/staging/lustre/lustre/osc/osc_request.c    |    2 +-
 18 files changed, 4 insertions(+), 22 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_intent.h b/drivers/staging/lustre/lustre/include/lustre_intent.h
index 519e94fc089d..51e5c0e03872 100644
--- a/drivers/staging/lustre/lustre/include/lustre_intent.h
+++ b/drivers/staging/lustre/lustre/include/lustre_intent.h
@@ -34,6 +34,8 @@
 #ifndef LUSTRE_INTENT_H
 #define LUSTRE_INTENT_H
 
+#include <linux/types.h>
+
 /* intent IT_XXX are defined in lustre/include/obd.h */
 
 struct lookup_intent {
diff --git a/drivers/staging/lustre/lustre/ldlm/l_lock.c b/drivers/staging/lustre/lustre/ldlm/l_lock.c
index fbeec219a75b..296259aa51e6 100644
--- a/drivers/staging/lustre/lustre/ldlm/l_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/l_lock.c
@@ -32,7 +32,6 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LDLM
-#include <linux/libcfs/libcfs_all.h>
 
 #include <lustre_dlm.h>
 #include <lustre_lib.h>
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
index a6435cf8924a..4da23ade2bb3 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_extent.c
@@ -47,7 +47,6 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LDLM
-#include <linux/libcfs/libcfs_all.h>
 #include <lustre_dlm.h>
 #include <obd_support.h>
 #include <obd.h>
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
index d8db751cf5a7..0aa4f234a4f4 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lib.c
@@ -40,7 +40,6 @@
 
 #define DEBUG_SUBSYSTEM S_LDLM
 
-#include <linux/libcfs/libcfs_all.h>
 #include <obd.h>
 #include <obd_class.h>
 #include <lustre_dlm.h>
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
index 66702428a914..a644d133063b 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lock.c
@@ -38,7 +38,6 @@
 
 #define DEBUG_SUBSYSTEM S_LDLM
 
-#include <linux/libcfs/libcfs_all.h>
 #include <lustre_intent.h>
 #include <lustre_swab.h>
 #include <obd_class.h>
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
index 7a1d18176032..b0a29f50c7d6 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_lockd.c
@@ -38,7 +38,7 @@
 
 #define DEBUG_SUBSYSTEM S_LDLM
 
-#include <linux/libcfs/libcfs_all.h>
+#include <linux/kthread.h>
 #include <linux/sched/mm.h>
 #include <lustre_dlm.h>
 #include <obd_class.h>
diff --git a/drivers/staging/lustre/lustre/llite/glimpse.c b/drivers/staging/lustre/lustre/llite/glimpse.c
index eddab7d2887b..ce0d51767da3 100644
--- a/drivers/staging/lustre/lustre/llite/glimpse.c
+++ b/drivers/staging/lustre/lustre/llite/glimpse.c
@@ -37,7 +37,6 @@
  *   Author: Oleg Drokin <oleg.drokin@sun.com>
  */
 
-#include <linux/libcfs/libcfs_all.h>
 #include <obd_class.h>
 #include <obd_support.h>
 #include <obd.h>
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index de1de3b2dded..d7ea39ce0cb2 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -38,7 +38,6 @@
 
 #define DEBUG_SUBSYSTEM S_LLITE
 
-#include <linux/libcfs/libcfs_all.h>
 #include <linux/fs.h>
 #include <linux/sched.h>
 #include <linux/mm.h>
diff --git a/drivers/staging/lustre/lustre/llite/vvp_object.c b/drivers/staging/lustre/lustre/llite/vvp_object.c
index 5aedbdbc75b7..b2cb51c8f7f4 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_object.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_object.c
@@ -37,8 +37,6 @@
 
 #define DEBUG_SUBSYSTEM S_LLITE
 
-#include <linux/libcfs/libcfs_all.h>
-
 #include <obd.h>
 
 #include "llite_internal.h"
diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
index 223fb76c13aa..c80320ab0858 100644
--- a/drivers/staging/lustre/lustre/lov/lov_ea.c
+++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
@@ -38,7 +38,6 @@
 #define DEBUG_SUBSYSTEM S_LOV
 
 #include <asm/div64.h>
-#include <linux/libcfs/libcfs_all.h>
 
 #include <obd_class.h>
 #include <uapi/linux/lustre/lustre_idl.h>
diff --git a/drivers/staging/lustre/lustre/lov/lov_merge.c b/drivers/staging/lustre/lustre/lov/lov_merge.c
index 8889ea37df18..006717cf7a41 100644
--- a/drivers/staging/lustre/lustre/lov/lov_merge.c
+++ b/drivers/staging/lustre/lustre/lov/lov_merge.c
@@ -33,8 +33,6 @@
 
 #define DEBUG_SUBSYSTEM S_LOV
 
-#include <linux/libcfs/libcfs_all.h>
-
 #include <obd_class.h>
 #include "lov_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index ad150f07ea19..7123972d4d5b 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -39,7 +39,6 @@
  */
 
 #define DEBUG_SUBSYSTEM S_LOV
-#include <linux/libcfs/libcfs_all.h>
 
 #include <uapi/linux/lustre/lustre_idl.h>
 #include <uapi/linux/lustre/lustre_ioctl.h>
diff --git a/drivers/staging/lustre/lustre/lov/lov_offset.c b/drivers/staging/lustre/lustre/lov/lov_offset.c
index ba070a6ef607..a5f00f6ec347 100644
--- a/drivers/staging/lustre/lustre/lov/lov_offset.c
+++ b/drivers/staging/lustre/lustre/lov/lov_offset.c
@@ -33,8 +33,6 @@
 
 #define DEBUG_SUBSYSTEM S_LOV
 
-#include <linux/libcfs/libcfs_all.h>
-
 #include <obd_class.h>
 
 #include "lov_internal.h"
diff --git a/drivers/staging/lustre/lustre/lov/lov_pool.c b/drivers/staging/lustre/lustre/lov/lov_pool.c
index f00df5e24db2..6d2dec9266b6 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pool.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pool.c
@@ -41,8 +41,6 @@
 
 #define DEBUG_SUBSYSTEM S_LOV
 
-#include <linux/libcfs/libcfs_all.h>
-
 #include <obd.h>
 #include "lov_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_request.c b/drivers/staging/lustre/lustre/lov/lov_request.c
index 6bc2896876db..cb8567f20ea7 100644
--- a/drivers/staging/lustre/lustre/lov/lov_request.c
+++ b/drivers/staging/lustre/lustre/lov/lov_request.c
@@ -33,8 +33,6 @@
 
 #define DEBUG_SUBSYSTEM S_LOV
 
-#include <linux/libcfs/libcfs_all.h>
-
 #include <obd_class.h>
 #include <uapi/linux/lustre/lustre_idl.h>
 #include "lov_internal.h"
diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index c417a0cd1c16..b692e76e7108 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -32,7 +32,6 @@
  */
 
 #define DEBUG_SUBSYSTEM S_ECHO
-#include <linux/libcfs/libcfs_all.h>
 
 #include <obd.h>
 #include <obd_support.h>
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index 388eb97e1548..d93d33dc8dc4 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -38,7 +38,6 @@
 
 #define DEBUG_SUBSYSTEM S_OSC
 
-#include <linux/libcfs/libcfs_all.h>
 /* fid_build_reg_res_name() */
 #include <lustre_fid.h>
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 72d27856f355..61ef6c8d7a12 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -33,7 +33,7 @@
 
 #define DEBUG_SUBSYSTEM S_OSC
 
-#include <linux/libcfs/libcfs_all.h>
+#include <linux/libcfs/libcfs_hash.h>
 #include <linux/sched/mm.h>
 
 #include <lustre_dlm.h>
