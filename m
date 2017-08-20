From: James Simmons <jsimmons@infradead.org>
Date: Sat, 19 Aug 2017 22:26:50 -0400
Subject: [lustre-devel] [PATCH 56/64 v2] staging: lustre: lustre: cleanup
	paths for lustre internal headers
In-Reply-To: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
References: <1503196018-24500-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1503196018-24500-57-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Rationalize include paths for the lustre internal headers

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/cl_object.h  |  4 +--
 drivers/staging/lustre/lustre/include/llog_swab.h  |  2 +-
 .../staging/lustre/lustre/include/lprocfs_status.h |  6 ++---
 drivers/staging/lustre/lustre/include/lu_object.h  |  6 ++---
 .../staging/lustre/lustre/include/lustre_compat.h  |  2 +-
 .../staging/lustre/lustre/include/lustre_debug.h   |  4 +--
 .../staging/lustre/lustre/include/lustre_disk.h    |  4 ++-
 drivers/staging/lustre/lustre/include/lustre_dlm.h | 12 ++++-----
 .../staging/lustre/lustre/include/lustre_export.h  |  6 ++---
 drivers/staging/lustre/lustre/include/lustre_fid.h |  8 +++---
 drivers/staging/lustre/lustre/include/lustre_fld.h |  6 ++---
 .../staging/lustre/lustre/include/lustre_handles.h |  2 +-
 .../staging/lustre/lustre/include/lustre_import.h  |  4 +--
 .../lustre/lustre/include/lustre_kernelcomm.h      |  2 +-
 drivers/staging/lustre/lustre/include/lustre_lib.h | 12 ++++-----
 drivers/staging/lustre/lustre/include/lustre_lmv.h |  2 +-
 drivers/staging/lustre/lustre/include/lustre_log.h |  4 +--
 drivers/staging/lustre/lustre/include/lustre_mdc.h | 14 +++++-----
 drivers/staging/lustre/lustre/include/lustre_mds.h | 10 ++++----
 drivers/staging/lustre/lustre/include/lustre_net.h | 30 +++++++++++-----------
 drivers/staging/lustre/lustre/include/lustre_nrs.h |  2 +-
 .../staging/lustre/lustre/include/lustre_obdo.h    |  2 +-
 .../staging/lustre/lustre/include/lustre_swab.h    |  2 +-
 drivers/staging/lustre/lustre/include/obd.h        | 18 ++++++-------
 drivers/staging/lustre/lustre/include/obd_cksum.h  |  6 ++---
 drivers/staging/lustre/lustre/include/obd_class.h  | 12 ++++-----
 .../staging/lustre/lustre/include/obd_support.h    |  6 ++---
 drivers/staging/lustre/lustre/include/seq_range.h  |  2 +-
 28 files changed, 96 insertions(+), 94 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
index 6887b81..9ba184b 100644
--- a/drivers/staging/lustre/lustre/include/cl_object.h
+++ b/drivers/staging/lustre/lustre/include/cl_object.h
@@ -88,8 +88,8 @@
 /*
  * super-class definitions.
  */
-#include "lu_object.h"
-#include "lustre_compat.h"
+#include <lu_object.h>
+#include <lustre_compat.h>
 #include <linux/atomic.h>
 #include <linux/mutex.h>
 #include <linux/radix-tree.h>
diff --git a/drivers/staging/lustre/lustre/include/llog_swab.h b/drivers/staging/lustre/lustre/include/llog_swab.h
index 25516d3..925271d 100644
--- a/drivers/staging/lustre/lustre/include/llog_swab.h
+++ b/drivers/staging/lustre/lustre/include/llog_swab.h
@@ -48,7 +48,7 @@
 #ifndef _LLOG_SWAB_H_
 #define _LLOG_SWAB_H_
 
-#include "../../include/uapi/linux/lustre/lustre_idl.h"
+#include <uapi/linux/lustre/lustre_idl.h>
 
 struct lustre_cfg;
 
diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index f5abca8..98d6b13 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -43,9 +43,9 @@
 #include <linux/spinlock.h>
 #include <linux/types.h>
 
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/uapi/linux/lustre/lustre_cfg.h"
-#include "../../include/uapi/linux/lustre/lustre_idl.h"
+#include <linux/libcfs/libcfs.h>
+#include <uapi/linux/lustre/lustre_cfg.h>
+#include <uapi/linux/lustre/lustre_idl.h>
 
 struct lprocfs_vars {
 	const char		*name;
diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index ea77d9c..4f213c4 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -35,9 +35,9 @@
 
 #include <stdarg.h>
 #include <linux/percpu_counter.h>
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/uapi/linux/lustre/lustre_idl.h"
-#include "lu_ref.h"
+#include <linux/libcfs/libcfs.h>
+#include <uapi/linux/lustre/lustre_idl.h>
+#include <lu_ref.h>
 
 struct seq_file;
 struct lustre_cfg;
diff --git a/drivers/staging/lustre/lustre/include/lustre_compat.h b/drivers/staging/lustre/lustre/include/lustre_compat.h
index da9ce19..69bfd6a 100644
--- a/drivers/staging/lustre/lustre/include/lustre_compat.h
+++ b/drivers/staging/lustre/lustre/include/lustre_compat.h
@@ -37,7 +37,7 @@
 #include <linux/namei.h>
 #include <linux/cred.h>
 
-#include "lustre_patchless_compat.h"
+#include <lustre_patchless_compat.h>
 
 /*
  * set ATTR_BLOCKS to a high value to avoid any risk of collision with other
diff --git a/drivers/staging/lustre/lustre/include/lustre_debug.h b/drivers/staging/lustre/lustre/include/lustre_debug.h
index 93c1bda..0be6a53 100644
--- a/drivers/staging/lustre/lustre/include/lustre_debug.h
+++ b/drivers/staging/lustre/lustre/include/lustre_debug.h
@@ -38,8 +38,8 @@
  * @{
  */
 
-#include "lustre_net.h"
-#include "obd.h"
+#include <lustre_net.h>
+#include <obd.h>
 
 /* lib/debug.c */
 int dump_req(struct ptlrpc_request *req);
diff --git a/drivers/staging/lustre/lustre/include/lustre_disk.h b/drivers/staging/lustre/lustre/include/lustre_disk.h
index 05cdc66..2d862b3 100644
--- a/drivers/staging/lustre/lustre/include/lustre_disk.h
+++ b/drivers/staging/lustre/lustre/include/lustre_disk.h
@@ -44,8 +44,10 @@
  * @{
  */
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <asm/byteorder.h>
+#include <linux/types.h>
 #include <linux/backing-dev.h>
+#include <linux/libcfs/libcfs.h>
 
 /****************** persistent mount data *********************/
 
diff --git a/drivers/staging/lustre/lustre/include/lustre_dlm.h b/drivers/staging/lustre/lustre/include/lustre_dlm.h
index eb2de13..13c3d2f 100644
--- a/drivers/staging/lustre/lustre/include/lustre_dlm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_dlm.h
@@ -44,12 +44,12 @@
 #ifndef _LUSTRE_DLM_H__
 #define _LUSTRE_DLM_H__
 
-#include "lustre_lib.h"
-#include "lustre_net.h"
-#include "lustre_import.h"
-#include "lustre_handles.h"
-#include "interval_tree.h"	/* for interval_node{}, ldlm_extent */
-#include "lu_ref.h"
+#include <lustre_lib.h>
+#include <lustre_net.h>
+#include <lustre_import.h>
+#include <lustre_handles.h>
+#include <interval_tree.h>	/* for interval_node{}, ldlm_extent */
+#include <lu_ref.h>
 
 #include "lustre_dlm_flags.h"
 
diff --git a/drivers/staging/lustre/lustre/include/lustre_export.h b/drivers/staging/lustre/lustre/include/lustre_export.h
index 3502d15..3631a69 100644
--- a/drivers/staging/lustre/lustre/include/lustre_export.h
+++ b/drivers/staging/lustre/lustre/include/lustre_export.h
@@ -42,9 +42,9 @@
  * @{
  */
 
-#include "lprocfs_status.h"
-#include "../../include/uapi/linux/lustre/lustre_idl.h"
-#include "lustre_dlm.h"
+#include <lprocfs_status.h>
+#include <uapi/linux/lustre/lustre_idl.h>
+#include <lustre_dlm.h>
 
 enum obd_option {
 	OBD_OPT_FORCE =	 0x0001,
diff --git a/drivers/staging/lustre/lustre/include/lustre_fid.h b/drivers/staging/lustre/lustre/include/lustre_fid.h
index 8998a34..e0f2b82 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fid.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fid.h
@@ -148,10 +148,10 @@
  *  Even so, the MDT and OST resources are also in different LDLM namespaces.
  */
 
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/uapi/linux/lustre/lustre_fid.h"
-#include "../../include/uapi/linux/lustre/lustre_idl.h"
-#include "../../include/uapi/linux/lustre/lustre_ostid.h"
+#include <linux/libcfs/libcfs.h>
+#include <uapi/linux/lustre/lustre_fid.h>
+#include <uapi/linux/lustre/lustre_idl.h>
+#include <uapi/linux/lustre/lustre_ostid.h>
 
 struct lu_env;
 struct lu_site;
diff --git a/drivers/staging/lustre/lustre/include/lustre_fld.h b/drivers/staging/lustre/lustre/include/lustre_fld.h
index e335d88..6125eb0 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fld.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fld.h
@@ -38,9 +38,9 @@
  * @{
  */
 
-#include "../../include/uapi/linux/lustre/lustre_idl.h"
-#include "../../include/linux/libcfs/libcfs.h"
-#include "seq_range.h"
+#include <uapi/linux/lustre/lustre_idl.h>
+#include <linux/libcfs/libcfs.h>
+#include <seq_range.h>
 
 struct lu_client_fld;
 struct lu_server_fld;
diff --git a/drivers/staging/lustre/lustre/include/lustre_handles.h b/drivers/staging/lustre/lustre/include/lustre_handles.h
index e071bac..d499326 100644
--- a/drivers/staging/lustre/lustre/include/lustre_handles.h
+++ b/drivers/staging/lustre/lustre/include/lustre_handles.h
@@ -44,7 +44,7 @@
 #include <linux/spinlock.h>
 #include <linux/types.h>
 
-#include "../../include/linux/libcfs/libcfs.h"
+#include <linux/libcfs/libcfs.h>
 
 struct portals_handle_ops {
 	void (*hop_addref)(void *object);
diff --git a/drivers/staging/lustre/lustre/include/lustre_import.h b/drivers/staging/lustre/lustre/include/lustre_import.h
index 0b54e28..d71d047 100644
--- a/drivers/staging/lustre/lustre/include/lustre_import.h
+++ b/drivers/staging/lustre/lustre/include/lustre_import.h
@@ -43,8 +43,8 @@
  * @{
  */
 
-#include "lustre_handles.h"
-#include "../../include/uapi/linux/lustre/lustre_idl.h"
+#include <lustre_handles.h>
+#include <uapi/linux/lustre/lustre_idl.h>
 
 /**
  * Adaptive Timeout stuff
diff --git a/drivers/staging/lustre/lustre/include/lustre_kernelcomm.h b/drivers/staging/lustre/lustre/include/lustre_kernelcomm.h
index c06648f..f1899a3d 100644
--- a/drivers/staging/lustre/lustre/include/lustre_kernelcomm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_kernelcomm.h
@@ -38,7 +38,7 @@
 #define __LUSTRE_KERNELCOMM_H__
 
 /* For declarations shared with userspace */
-#include "../../include/uapi/linux/lustre/lustre_kernelcomm.h"
+#include <uapi/linux/lustre/lustre_kernelcomm.h>
 
 /* prototype for callback function on kuc groups */
 typedef int (*libcfs_kkuc_cb_t)(void *data, void *cb_arg);
diff --git a/drivers/staging/lustre/lustre/include/lustre_lib.h b/drivers/staging/lustre/lustre/include/lustre_lib.h
index a7a184f..81b9cbf 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lib.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lib.h
@@ -45,18 +45,18 @@
 #include <linux/sched/signal.h>
 #include <linux/signal.h>
 #include <linux/types.h>
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/uapi/linux/lustre/lustre_idl.h"
-#include "../../include/uapi/linux/lustre/lustre_ver.h"
-#include "../../include/uapi/linux/lustre/lustre_cfg.h"
+#include <linux/libcfs/libcfs.h>
+#include <uapi/linux/lustre/lustre_idl.h>
+#include <uapi/linux/lustre/lustre_ver.h>
+#include <uapi/linux/lustre/lustre_cfg.h>
 
 /* target.c */
 struct ptlrpc_request;
 struct obd_export;
 struct lu_target;
 struct l_wait_info;
-#include "lustre_ha.h"
-#include "lustre_net.h"
+#include <lustre_ha.h>
+#include <lustre_net.h>
 
 #define LI_POISON 0x5a5a5a5a
 #if BITS_PER_LONG > 32
diff --git a/drivers/staging/lustre/lustre/include/lustre_lmv.h b/drivers/staging/lustre/lustre/include/lustre_lmv.h
index f2b8574..98a82be2 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lmv.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lmv.h
@@ -32,7 +32,7 @@
 
 #ifndef _LUSTRE_LMV_H
 #define _LUSTRE_LMV_H
-#include "../../include/uapi/linux/lustre/lustre_idl.h"
+#include <uapi/linux/lustre/lustre_idl.h>
 
 struct lmv_oinfo {
 	struct lu_fid	lmo_fid;
diff --git a/drivers/staging/lustre/lustre/include/lustre_log.h b/drivers/staging/lustre/lustre/include/lustre_log.h
index 70fdc0b..24a7777 100644
--- a/drivers/staging/lustre/lustre/include/lustre_log.h
+++ b/drivers/staging/lustre/lustre/include/lustre_log.h
@@ -52,8 +52,8 @@
  * @{
  */
 
-#include "obd_class.h"
-#include "../../include/uapi/linux/lustre/lustre_idl.h"
+#include <obd_class.h>
+#include <uapi/linux/lustre/lustre_idl.h>
 
 #define LOG_NAME_LIMIT(logname, name)		   \
 	snprintf(logname, sizeof(logname), "LOGS/%s", name)
diff --git a/drivers/staging/lustre/lustre/include/lustre_mdc.h b/drivers/staging/lustre/lustre/include/lustre_mdc.h
index 99abbde..c0c4497 100644
--- a/drivers/staging/lustre/lustre/include/lustre_mdc.h
+++ b/drivers/staging/lustre/lustre/include/lustre_mdc.h
@@ -46,13 +46,13 @@
 
 #include <linux/fs.h>
 #include <linux/dcache.h>
-#include "lustre_intent.h"
-#include "lustre_handles.h"
-#include "../../include/linux/libcfs/libcfs.h"
-#include "obd_class.h"
-#include "lustre_lib.h"
-#include "lustre_dlm.h"
-#include "lustre_export.h"
+#include <lustre_intent.h>
+#include <lustre_handles.h>
+#include <linux/libcfs/libcfs.h>
+#include <obd_class.h>
+#include <lustre_lib.h>
+#include <lustre_dlm.h>
+#include <lustre_export.h>
 
 struct ptlrpc_client;
 struct obd_export;
diff --git a/drivers/staging/lustre/lustre/include/lustre_mds.h b/drivers/staging/lustre/lustre/include/lustre_mds.h
index 2a552ee..c424e12 100644
--- a/drivers/staging/lustre/lustre/include/lustre_mds.h
+++ b/drivers/staging/lustre/lustre/include/lustre_mds.h
@@ -43,11 +43,11 @@
  * @{
  */
 
-#include "lustre_handles.h"
-#include "../../include/linux/libcfs/libcfs.h"
-#include "lustre_lib.h"
-#include "lustre_dlm.h"
-#include "lustre_export.h"
+#include <lustre_handles.h>
+#include <linux/libcfs/libcfs.h>
+#include <lustre_lib.h>
+#include <lustre_dlm.h>
+#include <lustre_export.h>
 
 struct mds_group_info {
 	struct obd_uuid *uuid;
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index bc18131..c6d1646 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -51,20 +51,20 @@
  */
 
 #include <linux/uio.h>
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/uapi/linux/lnet/nidstr.h"
-#include "../../include/linux/lnet/api.h"
-#include "../../include/uapi/linux/lustre/lustre_idl.h"
-#include "lustre_errno.h"
-#include "lustre_ha.h"
-#include "lustre_sec.h"
-#include "lustre_import.h"
-#include "lprocfs_status.h"
-#include "lu_object.h"
-#include "lustre_req_layout.h"
-
-#include "obd_support.h"
-#include "../../include/uapi/linux/lustre/lustre_ver.h"
+#include <linux/libcfs/libcfs.h>
+#include <uapi/linux/lnet/nidstr.h>
+#include <linux/lnet/api.h>
+#include <uapi/linux/lustre/lustre_idl.h>
+#include <lustre_errno.h>
+#include <lustre_ha.h>
+#include <lustre_sec.h>
+#include <lustre_import.h>
+#include <lprocfs_status.h>
+#include <lu_object.h>
+#include <lustre_req_layout.h>
+
+#include <obd_support.h>
+#include <uapi/linux/lustre/lustre_ver.h>
 
 /* MD flags we _always_ use */
 #define PTLRPC_MD_OPTIONS  0
@@ -522,7 +522,7 @@ struct ptlrpc_request_pool {
 
 struct ldlm_lock;
 
-#include "lustre_nrs.h"
+#include <lustre_nrs.h>
 
 /**
  * Basic request prioritization operations structure.
diff --git a/drivers/staging/lustre/lustre/include/lustre_nrs.h b/drivers/staging/lustre/lustre/include/lustre_nrs.h
index a5028aa..51f45f7 100644
--- a/drivers/staging/lustre/lustre/include/lustre_nrs.h
+++ b/drivers/staging/lustre/lustre/include/lustre_nrs.h
@@ -669,7 +669,7 @@ enum {
 	NRS_RES_MAX
 };
 
-#include "lustre_nrs_fifo.h"
+#include <lustre_nrs_fifo.h>
 
 /**
  * NRS request
diff --git a/drivers/staging/lustre/lustre/include/lustre_obdo.h b/drivers/staging/lustre/lustre/include/lustre_obdo.h
index 252191d..53379f8 100644
--- a/drivers/staging/lustre/lustre/include/lustre_obdo.h
+++ b/drivers/staging/lustre/lustre/include/lustre_obdo.h
@@ -35,7 +35,7 @@
 #ifndef _LUSTRE_OBDO_H_
 #define _LUSTRE_OBDO_H_
 
-#include "../../include/uapi/linux/lustre/lustre_idl.h"
+#include <uapi/linux/lustre/lustre_idl.h>
 
 /**
  * Create an obdo to send over the wire
diff --git a/drivers/staging/lustre/lustre/include/lustre_swab.h b/drivers/staging/lustre/lustre/include/lustre_swab.h
index 9e13afd..765e923 100644
--- a/drivers/staging/lustre/lustre/include/lustre_swab.h
+++ b/drivers/staging/lustre/lustre/include/lustre_swab.h
@@ -48,7 +48,7 @@
 #ifndef _LUSTRE_SWAB_H_
 #define _LUSTRE_SWAB_H_
 
-#include "../../include/uapi/linux/lustre/lustre_idl.h"
+#include <uapi/linux/lustre/lustre_idl.h>
 
 void lustre_swab_ptlrpc_body(struct ptlrpc_body *pb);
 void lustre_swab_connect(struct obd_connect_data *ocd);
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index aedc550..a986737 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -35,15 +35,15 @@
 
 #include <linux/spinlock.h>
 
-#include "../../include/uapi/linux/lustre/lustre_idl.h"
-#include "lustre_lib.h"
-#include "lu_ref.h"
-#include "lustre_export.h"
-#include "lustre_fid.h"
-#include "lustre_fld.h"
-#include "lustre_handles.h"
-#include "lustre_intent.h"
-#include "cl_object.h"
+#include <uapi/linux/lustre/lustre_idl.h>
+#include <lustre_lib.h>
+#include <lu_ref.h>
+#include <lustre_export.h>
+#include <lustre_fid.h>
+#include <lustre_fld.h>
+#include <lustre_handles.h>
+#include <lustre_intent.h>
+#include <cl_object.h>
 
 #define MAX_OBD_DEVICES 8192
 
diff --git a/drivers/staging/lustre/lustre/include/obd_cksum.h b/drivers/staging/lustre/lustre/include/obd_cksum.h
index 54bde73..cda3d28 100644
--- a/drivers/staging/lustre/lustre/include/obd_cksum.h
+++ b/drivers/staging/lustre/lustre/include/obd_cksum.h
@@ -30,9 +30,9 @@
 
 #ifndef __OBD_CKSUM
 #define __OBD_CKSUM
-#include "../../include/linux/libcfs/libcfs.h"
-#include "../../include/linux/libcfs/libcfs_crypto.h"
-#include "../../include/uapi/linux/lustre/lustre_idl.h"
+#include <linux/libcfs/libcfs.h>
+#include <linux/libcfs/libcfs_crypto.h>
+#include <uapi/linux/lustre/lustre_idl.h>
 
 static inline unsigned char cksum_obd2cfs(enum cksum_type cksum_type)
 {
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 6ae6479..976005a 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -32,12 +32,12 @@
 #ifndef __CLASS_OBD_H
 #define __CLASS_OBD_H
 
-#include "obd_support.h"
-#include "lustre_import.h"
-#include "lustre_net.h"
-#include "obd.h"
-#include "lustre_lib.h"
-#include "lprocfs_status.h"
+#include <obd_support.h>
+#include <lustre_import.h>
+#include <lustre_net.h>
+#include <obd.h>
+#include <lustre_lib.h>
+#include <lprocfs_status.h>
 
 #define OBD_STATFS_NODELAY      0x0001  /* requests should be send without delay
 					 * and resends for avoid deadlocks
diff --git a/drivers/staging/lustre/lustre/include/obd_support.h b/drivers/staging/lustre/lustre/include/obd_support.h
index 3330404..aea193a 100644
--- a/drivers/staging/lustre/lustre/include/obd_support.h
+++ b/drivers/staging/lustre/lustre/include/obd_support.h
@@ -36,9 +36,9 @@
 #include <linux/slab.h>
 #include <linux/sched/signal.h>
 
-#include "../../include/linux/libcfs/libcfs.h"
-#include "lustre_compat.h"
-#include "lprocfs_status.h"
+#include <linux/libcfs/libcfs.h>
+#include <lustre_compat.h>
+#include <lprocfs_status.h>
 
 /* global variables */
 extern unsigned int obd_debug_peer_on_timeout;
diff --git a/drivers/staging/lustre/lustre/include/seq_range.h b/drivers/staging/lustre/lustre/include/seq_range.h
index 74a9c63..d717548 100644
--- a/drivers/staging/lustre/lustre/include/seq_range.h
+++ b/drivers/staging/lustre/lustre/include/seq_range.h
@@ -34,7 +34,7 @@
 #ifndef _SEQ_RANGE_H_
 #define _SEQ_RANGE_H_
 
-#include "../../include/uapi/linux/lustre/lustre_idl.h"
+#include <uapi/linux/lustre/lustre_idl.h>
 
 /**
  * computes the sequence range type \a range
-- 
1.8.3.1
