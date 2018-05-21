From: NeilBrown <neilb@suse.com>
Date: Mon, 21 May 2018 14:35:13 +1000
Subject: [lustre-devel] [PATCH 24/30] staging: lustre: remove libcfs_all.h
 from lustre/include/*.h
In-Reply-To: <152687724799.24196.7718555295926047576.stgit@noble>
References: <152687724799.24196.7718555295926047576.stgit@noble>
Message-ID: <152687731327.24196.12789862567600316175.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Instead of the catch-all libcfs_all.h, just include the
files actually needed in different places.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../lustre/include/linux/libcfs/libcfs_crypto.h    |    3 +++
 .../staging/lustre/lustre/include/lprocfs_status.h |    2 +-
 drivers/staging/lustre/lustre/include/lu_object.h  |    2 +-
 .../staging/lustre/lustre/include/lustre_compat.h  |    1 +
 .../staging/lustre/lustre/include/lustre_disk.h    |    1 -
 drivers/staging/lustre/lustre/include/lustre_fid.h |    2 +-
 drivers/staging/lustre/lustre/include/lustre_fld.h |    1 -
 .../staging/lustre/lustre/include/lustre_handles.h |    2 --
 .../staging/lustre/lustre/include/lustre_import.h  |    1 +
 drivers/staging/lustre/lustre/include/lustre_lib.h |    1 -
 drivers/staging/lustre/lustre/include/lustre_mdc.h |    2 +-
 drivers/staging/lustre/lustre/include/lustre_mds.h |    1 -
 drivers/staging/lustre/lustre/include/lustre_net.h |    2 +-
 .../lustre/include/lustre_patchless_compat.h       |    1 +
 drivers/staging/lustre/lustre/include/lustre_sec.h |    2 ++
 drivers/staging/lustre/lustre/include/obd_cksum.h  |    2 +-
 .../staging/lustre/lustre/include/obd_support.h    |    1 -
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c  |    1 +
 drivers/staging/lustre/lustre/ldlm/ldlm_resource.c |    1 +
 drivers/staging/lustre/lustre/lmv/lmv_obd.c        |    2 ++
 drivers/staging/lustre/lustre/mdc/mdc_request.c    |    2 ++
 drivers/staging/lustre/lustre/obdclass/class_obd.c |    2 ++
 .../staging/lustre/lustre/obdclass/kernelcomm.c    |    2 ++
 drivers/staging/lustre/lustre/obdclass/llog.c      |    1 +
 .../lustre/lustre/obdclass/lprocfs_counters.c      |    1 +
 .../lustre/lustre/obdclass/lustre_handles.c        |    1 +
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |    1 +
 drivers/staging/lustre/lustre/ptlrpc/client.c      |    2 ++
 drivers/staging/lustre/lustre/ptlrpc/import.c      |    1 +
 drivers/staging/lustre/lustre/ptlrpc/service.c     |    3 +++
 30 files changed, 34 insertions(+), 13 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h b/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
index 3a72117140ed..176fae7319e3 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs_crypto.h
@@ -29,6 +29,9 @@
 #ifndef _LIBCFS_CRYPTO_H
 #define _LIBCFS_CRYPTO_H
 
+#include <linux/string.h>
+struct page;
+
 struct cfs_crypto_hash_type {
 	char		*cht_name;      /*< hash algorithm name, equal to
 					 * format name for crypto api
diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index 07b632dce2e3..1322ecffda13 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -43,8 +43,8 @@
 #include <linux/seq_file.h>
 #include <linux/spinlock.h>
 #include <linux/types.h>
+#include <linux/device.h>
 
-#include <linux/libcfs/libcfs_all.h>
 #include <uapi/linux/lustre/lustre_cfg.h>
 #include <uapi/linux/lustre/lustre_idl.h>
 
diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index a1a75e026053..4153db762518 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -36,7 +36,7 @@
 
 #include <stdarg.h>
 #include <linux/percpu_counter.h>
-#include <linux/libcfs/libcfs_all.h>
+#include <linux/libcfs/libcfs.h>
 #include <uapi/linux/lustre/lustre_idl.h>
 #include <lu_ref.h>
 
diff --git a/drivers/staging/lustre/lustre/include/lustre_compat.h b/drivers/staging/lustre/lustre/include/lustre_compat.h
index 9f488e605083..3c6db0d632dc 100644
--- a/drivers/staging/lustre/lustre/include/lustre_compat.h
+++ b/drivers/staging/lustre/lustre/include/lustre_compat.h
@@ -37,6 +37,7 @@
 #include <linux/fs_struct.h>
 #include <linux/namei.h>
 #include <linux/cred.h>
+#include <linux/module.h>
 
 #include <lustre_patchless_compat.h>
 
diff --git a/drivers/staging/lustre/lustre/include/lustre_disk.h b/drivers/staging/lustre/lustre/include/lustre_disk.h
index c66c1b19f661..886e817644d6 100644
--- a/drivers/staging/lustre/lustre/include/lustre_disk.h
+++ b/drivers/staging/lustre/lustre/include/lustre_disk.h
@@ -48,7 +48,6 @@
 #include <asm/byteorder.h>
 #include <linux/types.h>
 #include <linux/backing-dev.h>
-#include <linux/libcfs/libcfs_all.h>
 
 /****************** persistent mount data *********************/
 
diff --git a/drivers/staging/lustre/lustre/include/lustre_fid.h b/drivers/staging/lustre/lustre/include/lustre_fid.h
index 9c4e14d88c46..094ad282de2c 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fid.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fid.h
@@ -149,7 +149,7 @@
  *  Even so, the MDT and OST resources are also in different LDLM namespaces.
  */
 
-#include <linux/libcfs/libcfs_all.h>
+#include <linux/libcfs/libcfs.h>
 #include <uapi/linux/lustre/lustre_fid.h>
 #include <uapi/linux/lustre/lustre_idl.h>
 #include <uapi/linux/lustre/lustre_ostid.h>
diff --git a/drivers/staging/lustre/lustre/include/lustre_fld.h b/drivers/staging/lustre/lustre/include/lustre_fld.h
index e90fd323db4a..f42122a4dfaa 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fld.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fld.h
@@ -40,7 +40,6 @@
  */
 
 #include <uapi/linux/lustre/lustre_idl.h>
-#include <linux/libcfs/libcfs_all.h>
 #include <seq_range.h>
 
 struct lu_client_fld;
diff --git a/drivers/staging/lustre/lustre/include/lustre_handles.h b/drivers/staging/lustre/lustre/include/lustre_handles.h
index 79e10a1b53f2..3556ce8d94e8 100644
--- a/drivers/staging/lustre/lustre/include/lustre_handles.h
+++ b/drivers/staging/lustre/lustre/include/lustre_handles.h
@@ -45,8 +45,6 @@
 #include <linux/spinlock.h>
 #include <linux/types.h>
 
-#include <linux/libcfs/libcfs_all.h>
-
 struct portals_handle_ops {
 	void (*hop_addref)(void *object);
 	void (*hop_free)(void *object, int size);
diff --git a/drivers/staging/lustre/lustre/include/lustre_import.h b/drivers/staging/lustre/lustre/include/lustre_import.h
index 1731048f1ff2..ac3805ead620 100644
--- a/drivers/staging/lustre/lustre/include/lustre_import.h
+++ b/drivers/staging/lustre/lustre/include/lustre_import.h
@@ -44,6 +44,7 @@
  * @{
  */
 
+#include <linux/libcfs/libcfs.h>
 #include <lustre_handles.h>
 #include <uapi/linux/lustre/lustre_idl.h>
 
diff --git a/drivers/staging/lustre/lustre/include/lustre_lib.h b/drivers/staging/lustre/lustre/include/lustre_lib.h
index 296c7e4ee107..87748e9902a7 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lib.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lib.h
@@ -46,7 +46,6 @@
 #include <linux/sched/signal.h>
 #include <linux/signal.h>
 #include <linux/types.h>
-#include <linux/libcfs/libcfs_all.h>
 #include <uapi/linux/lustre/lustre_idl.h>
 #include <uapi/linux/lustre/lustre_ver.h>
 #include <uapi/linux/lustre/lustre_cfg.h>
diff --git a/drivers/staging/lustre/lustre/include/lustre_mdc.h b/drivers/staging/lustre/lustre/include/lustre_mdc.h
index 018aaea6a1b8..a9c9992a2502 100644
--- a/drivers/staging/lustre/lustre/include/lustre_mdc.h
+++ b/drivers/staging/lustre/lustre/include/lustre_mdc.h
@@ -49,7 +49,7 @@
 #include <linux/dcache.h>
 #include <lustre_intent.h>
 #include <lustre_handles.h>
-#include <linux/libcfs/libcfs_all.h>
+#include <linux/libcfs/libcfs.h>
 #include <obd_class.h>
 #include <lustre_lib.h>
 #include <lustre_dlm.h>
diff --git a/drivers/staging/lustre/lustre/include/lustre_mds.h b/drivers/staging/lustre/lustre/include/lustre_mds.h
index 910adfd88e0a..f665556556ec 100644
--- a/drivers/staging/lustre/lustre/include/lustre_mds.h
+++ b/drivers/staging/lustre/lustre/include/lustre_mds.h
@@ -45,7 +45,6 @@
  */
 
 #include <lustre_handles.h>
-#include <linux/libcfs/libcfs_all.h>
 #include <lustre_lib.h>
 #include <lustre_dlm.h>
 #include <lustre_export.h>
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index f772d33ebbc7..35b43a77eb18 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -52,7 +52,7 @@
  */
 
 #include <linux/uio.h>
-#include <linux/libcfs/libcfs_all.h>
+#include <linux/libcfs/libcfs.h>
 #include <uapi/linux/lnet/nidstr.h>
 #include <linux/lnet/api.h>
 #include <uapi/linux/lustre/lustre_idl.h>
diff --git a/drivers/staging/lustre/lustre/include/lustre_patchless_compat.h b/drivers/staging/lustre/lustre/include/lustre_patchless_compat.h
index ce28ed5c1ef8..298476ea7557 100644
--- a/drivers/staging/lustre/lustre/include/lustre_patchless_compat.h
+++ b/drivers/staging/lustre/lustre/include/lustre_patchless_compat.h
@@ -39,6 +39,7 @@
 #include <linux/list.h>
 #include <linux/mm.h>
 #include <linux/hash.h>
+#include <linux/pagemap.h>
 
 #define ll_delete_from_page_cache(page) delete_from_page_cache(page)
 
diff --git a/drivers/staging/lustre/lustre/include/lustre_sec.h b/drivers/staging/lustre/lustre/include/lustre_sec.h
index c5cb07acd0da..d35bcbc98831 100644
--- a/drivers/staging/lustre/lustre/include/lustre_sec.h
+++ b/drivers/staging/lustre/lustre/include/lustre_sec.h
@@ -34,6 +34,8 @@
 #ifndef _LUSTRE_SEC_H_
 #define _LUSTRE_SEC_H_
 
+#include <linux/module.h>
+
 /** \defgroup sptlrpc sptlrpc
  *
  * @{
diff --git a/drivers/staging/lustre/lustre/include/obd_cksum.h b/drivers/staging/lustre/lustre/include/obd_cksum.h
index 397100f8f9a0..e5f7bb20415d 100644
--- a/drivers/staging/lustre/lustre/include/obd_cksum.h
+++ b/drivers/staging/lustre/lustre/include/obd_cksum.h
@@ -31,7 +31,7 @@
 
 #ifndef __OBD_CKSUM
 #define __OBD_CKSUM
-#include <linux/libcfs/libcfs_all.h>
+#include <linux/libcfs/libcfs.h>
 #include <linux/libcfs/libcfs_crypto.h>
 #include <uapi/linux/lustre/lustre_idl.h>
 
diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index 099b30359c26..9e41633823f7 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -37,7 +37,6 @@
 #include <linux/slab.h>
 #include <linux/sched/signal.h>
 
-#include <linux/libcfs/libcfs_all.h>
 #include <lustre_compat.h>
 #include <lprocfs_status.h>
 
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index f573de9cf45d..cdc52eed6d85 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -62,6 +62,7 @@
 #include <lustre_dlm.h>
 #include <obd_class.h>
 #include <obd.h>
+#include <linux/libcfs/libcfs_hash.h>
 
 #include "ldlm_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
index 43bbc5fd94cc..28cd8398d4ce 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_resource.c
@@ -41,6 +41,7 @@
 #include <lustre_fid.h>
 #include <obd_class.h>
 #include "ldlm_internal.h"
+#include <linux/libcfs/libcfs_hash.h>
 
 struct kmem_cache *ldlm_resource_slab, *ldlm_lock_slab;
 
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 6ab9cdb6f9d1..60cdba99e4a4 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -37,11 +37,13 @@
 #include <linux/init.h>
 #include <linux/pagemap.h>
 #include <linux/mm.h>
+#include <linux/file.h>
 #include <asm/div64.h>
 #include <linux/seq_file.h>
 #include <linux/namei.h>
 #include <linux/uaccess.h>
 
+#include <linux/libcfs/libcfs.h>
 #include <obd_support.h>
 #include <lustre_net.h>
 #include <obd_class.h>
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 1aee9691b513..e2f386c86cc6 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -38,6 +38,8 @@
 # include <linux/miscdevice.h>
 # include <linux/init.h>
 # include <linux/utsname.h>
+# include <linux/file.h>
+# include <linux/kthread.h>
 
 #include <lustre_errno.h>
 #include <cl_object.h>
diff --git a/drivers/staging/lustre/lustre/obdclass/class_obd.c b/drivers/staging/lustre/lustre/obdclass/class_obd.c
index bc5e7f560b71..d6c46858941b 100644
--- a/drivers/staging/lustre/lustre/obdclass/class_obd.c
+++ b/drivers/staging/lustre/lustre/obdclass/class_obd.c
@@ -35,6 +35,7 @@
 
 #include <linux/atomic.h>
 #include <linux/miscdevice.h>
+#include <linux/libcfs/libcfs.h>
 
 #include <obd_support.h>
 #include <obd_class.h>
@@ -44,6 +45,7 @@
 #include <linux/list.h>
 #include <cl_object.h>
 #include <uapi/linux/lustre/lustre_ioctl.h>
+#include <uapi/linux/lnet/libcfs_ioctl.h>
 #include "llog_internal.h"
 
 struct obd_device *obd_devs[MAX_OBD_DEVICES];
diff --git a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
index b9bf81607bbf..63067a7f1e19 100644
--- a/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
+++ b/drivers/staging/lustre/lustre/obdclass/kernelcomm.c
@@ -39,6 +39,8 @@
 #define DEBUG_SUBSYSTEM S_CLASS
 #define D_KUC D_OTHER
 
+#include <linux/file.h>
+#include <linux/libcfs/libcfs.h>
 #include <obd_support.h>
 #include <lustre_kernelcomm.h>
 
diff --git a/drivers/staging/lustre/lustre/obdclass/llog.c b/drivers/staging/lustre/lustre/obdclass/llog.c
index 693e1129f1f9..b7e3299784b6 100644
--- a/drivers/staging/lustre/lustre/obdclass/llog.c
+++ b/drivers/staging/lustre/lustre/obdclass/llog.c
@@ -44,6 +44,7 @@
 
 #define DEBUG_SUBSYSTEM S_LOG
 
+#include <linux/kthread.h>
 #include <llog_swab.h>
 #include <lustre_log.h>
 #include <obd_class.h>
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_counters.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_counters.c
index c83b7d7f8e72..85f09aff6e83 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_counters.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_counters.c
@@ -41,6 +41,7 @@
 #include <linux/module.h>
 #include <lprocfs_status.h>
 #include <obd_support.h>
+#include <linux/libcfs/libcfs.h>
 
 void lprocfs_counter_add(struct lprocfs_stats *stats, int idx, long amount)
 {
diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
index f53b1a3c342e..cdc8dc10690d 100644
--- a/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
+++ b/drivers/staging/lustre/lustre/obdclass/lustre_handles.c
@@ -37,6 +37,7 @@
 
 #define DEBUG_SUBSYSTEM S_CLASS
 
+#include <linux/random.h>
 #include <obd_support.h>
 #include <lustre_handles.h>
 #include <lustre_lib.h>
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index f5e8214ac37b..06c38fdef7ba 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -41,6 +41,7 @@
 #define D_MOUNT (D_SUPER | D_CONFIG/*|D_WARNING */)
 #define PRINT_CMD CDEBUG
 
+#include <linux/random.h>
 #include <obd.h>
 #include <lustre_compat.h>
 #include <obd_class.h>
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index dd71eefe8452..47c77cd9767a 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -35,6 +35,8 @@
 
 #define DEBUG_SUBSYSTEM S_RPC
 
+#include <linux/libcfs/libcfs_cpu.h>
+#include <linux/random.h>
 #include <obd_support.h>
 #include <obd_class.h>
 #include <lustre_lib.h>
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index f704f8746f2c..1a0f35dfab97 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -37,6 +37,7 @@
 
 #define DEBUG_SUBSYSTEM S_RPC
 
+#include <linux/kthread.h>
 #include <obd_support.h>
 #include <lustre_ha.h>
 #include <lustre_net.h>
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index f1de9dd551cd..3fd8c746f460 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -33,12 +33,15 @@
 
 #define DEBUG_SUBSYSTEM S_RPC
 
+#include <linux/kthread.h>
 #include <obd_support.h>
 #include <obd_class.h>
 #include <lustre_net.h>
 #include <lu_object.h>
 #include <uapi/linux/lnet/lnet-types.h>
 #include "ptlrpc_internal.h"
+#include <linux/libcfs/libcfs_cpu.h>
+#include <linux/libcfs/libcfs_string.h>
 
 /* The following are visible and mutable through /sys/module/ptlrpc */
 int test_req_buffer_pressure;
