From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 11:47:09 -0400
Subject: [lustre-devel] [PATCH 41/64] staging: lustre: uapi: migrate
	remaining uapi headers to uapi directory
In-Reply-To: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
References: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502725652-26280-42-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Move all the remaining lustre headers shared between user land
and kernel space to the uapi directory.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6401
Reviewed-on: https://review.whamcloud.com/25246
Reviewed-by: Quentin Bouget <quentin.bouget@cea.fr>
Reviewed-by: Ben Evans <bevans@cray.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/uapi/linux/lustre/lustre_cfg.h       | 2 +-
 drivers/staging/lustre/include/uapi/linux/lustre/lustre_fid.h       | 2 +-
 .../ll_fiemap.h => include/uapi/linux/lustre/lustre_fiemap.h}       | 6 +-----
 .../{lustre/include => include/uapi/linux}/lustre/lustre_idl.h      | 6 ++----
 drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h     | 2 +-
 .../uapi/linux/lustre/lustre_kernelcomm.h}                          | 6 +++---
 drivers/staging/lustre/include/uapi/linux/lustre/lustre_ostid.h     | 1 -
 .../{lustre/include => include/uapi/linux}/lustre/lustre_user.h     | 2 +-
 .../{lustre/include => include/uapi/linux/lustre}/lustre_ver.h      | 0
 drivers/staging/lustre/lustre/fid/fid_internal.h                    | 2 +-
 drivers/staging/lustre/lustre/fid/fid_lib.c                         | 1 -
 drivers/staging/lustre/lustre/fld/fld_cache.c                       | 2 +-
 drivers/staging/lustre/lustre/fld/fld_internal.h                    | 2 +-
 drivers/staging/lustre/lustre/fld/fld_request.c                     | 2 +-
 drivers/staging/lustre/lustre/include/llog_swab.h                   | 3 ++-
 drivers/staging/lustre/lustre/include/lprocfs_status.h              | 2 +-
 drivers/staging/lustre/lustre/include/lu_object.h                   | 2 +-
 drivers/staging/lustre/lustre/include/{lustre => }/lustre_errno.h   | 0
 drivers/staging/lustre/lustre/include/lustre_export.h               | 2 +-
 drivers/staging/lustre/lustre/include/lustre_fid.h                  | 2 +-
 drivers/staging/lustre/lustre/include/lustre_fld.h                  | 2 +-
 drivers/staging/lustre/lustre/include/lustre_import.h               | 2 +-
 drivers/staging/lustre/lustre/include/lustre_kernelcomm.h           | 2 +-
 drivers/staging/lustre/lustre/include/lustre_lib.h                  | 4 ++--
 drivers/staging/lustre/lustre/include/lustre_lmv.h                  | 2 +-
 drivers/staging/lustre/lustre/include/lustre_log.h                  | 2 +-
 drivers/staging/lustre/lustre/include/lustre_mdc.h                  | 1 -
 drivers/staging/lustre/lustre/include/lustre_mds.h                  | 1 -
 drivers/staging/lustre/lustre/include/lustre_net.h                  | 4 ++--
 drivers/staging/lustre/lustre/include/lustre_obdo.h                 | 2 +-
 drivers/staging/lustre/lustre/include/lustre_swab.h                 | 2 +-
 drivers/staging/lustre/lustre/include/obd.h                         | 2 +-
 drivers/staging/lustre/lustre/include/obd_cksum.h                   | 2 +-
 drivers/staging/lustre/lustre/include/obd_class.h                   | 1 -
 drivers/staging/lustre/lustre/include/seq_range.h                   | 2 +-
 drivers/staging/lustre/lustre/ldlm/ldlm_request.c                   | 3 +--
 drivers/staging/lustre/lustre/llite/dcache.c                        | 2 +-
 drivers/staging/lustre/lustre/llite/file.c                          | 2 +-
 drivers/staging/lustre/lustre/llite/lcommon_cl.c                    | 1 -
 drivers/staging/lustre/lustre/llite/llite_internal.h                | 2 +-
 drivers/staging/lustre/lustre/llite/namei.c                         | 1 -
 drivers/staging/lustre/lustre/llite/range_lock.c                    | 2 +-
 drivers/staging/lustre/lustre/llite/vvp_internal.h                  | 2 +-
 drivers/staging/lustre/lustre/llite/xattr.c                         | 1 -
 drivers/staging/lustre/lustre/llite/xattr_cache.c                   | 1 -
 drivers/staging/lustre/lustre/lmv/lmv_fld.c                         | 1 -
 drivers/staging/lustre/lustre/lmv/lmv_intent.c                      | 1 -
 drivers/staging/lustre/lustre/lmv/lmv_internal.h                    | 2 +-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c                         | 1 -
 drivers/staging/lustre/lustre/lov/lov_ea.c                          | 2 +-
 drivers/staging/lustre/lustre/lov/lov_internal.h                    | 2 +-
 drivers/staging/lustre/lustre/lov/lov_obd.c                         | 2 +-
 drivers/staging/lustre/lustre/lov/lov_pack.c                        | 3 ---
 drivers/staging/lustre/lustre/lov/lov_request.c                     | 2 +-
 drivers/staging/lustre/lustre/mdc/mdc_lib.c                         | 2 +-
 drivers/staging/lustre/lustre/mdc/mdc_request.c                     | 3 +--
 drivers/staging/lustre/lustre/mgc/mgc_internal.h                    | 1 -
 drivers/staging/lustre/lustre/obdclass/linkea.c                     | 2 +-
 drivers/staging/lustre/lustre/obdclass/linux/linux-module.c         | 2 +-
 drivers/staging/lustre/lustre/obdclass/lprocfs_status.c             | 2 +-
 drivers/staging/lustre/lustre/obdclass/obd_mount.c                  | 2 +-
 drivers/staging/lustre/lustre/obdclass/obdo.c                       | 2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c                     | 2 +-
 drivers/staging/lustre/lustre/ptlrpc/layout.c                       | 4 ++--
 drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c                 | 2 +-
 drivers/staging/lustre/lustre/ptlrpc/pack_generic.c                 | 2 +-
 66 files changed, 57 insertions(+), 80 deletions(-)
 rename drivers/staging/lustre/{lustre/include/lustre/ll_fiemap.h => include/uapi/linux/lustre/lustre_fiemap.h} (96%)
 rename drivers/staging/lustre/{lustre/include => include/uapi/linux}/lustre/lustre_idl.h (99%)
 rename drivers/staging/lustre/{lustre/include/uapi_kernelcomm.h => include/uapi/linux/lustre/lustre_kernelcomm.h} (95%)
 rename drivers/staging/lustre/{lustre/include => include/uapi/linux}/lustre/lustre_user.h (99%)
 rename drivers/staging/lustre/{lustre/include => include/uapi/linux/lustre}/lustre_ver.h (100%)
 rename drivers/staging/lustre/lustre/include/{lustre => }/lustre_errno.h (100%)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_cfg.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_cfg.h
index 1533dcb..2b7deaa 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_cfg.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_cfg.h
@@ -35,7 +35,7 @@
 
 #include <linux/errno.h>
 #include <linux/kernel.h>
-#include "../../../../lustre/include/lustre/lustre_user.h"
+#include "../../../uapi/linux/lustre/lustre_user.h"
 
 /** \defgroup cfg cfg
  *
diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_fid.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_fid.h
index 9adc106..dd3785a 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_fid.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_fid.h
@@ -37,7 +37,7 @@
 #ifndef _UAPI_LUSTRE_FID_H_
 #define _UAPI_LUSTRE_FID_H_
 
-#include "../../../../lustre/include/lustre/lustre_idl.h"
+#include "../../../uapi/linux/lustre/lustre_idl.h"
 
 /** returns fid object sequence */
 static inline __u64 fid_seq(const struct lu_fid *fid)
diff --git a/drivers/staging/lustre/lustre/include/lustre/ll_fiemap.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_fiemap.h
similarity index 96%
rename from drivers/staging/lustre/lustre/include/lustre/ll_fiemap.h
rename to drivers/staging/lustre/include/uapi/linux/lustre/lustre_fiemap.h
index b8ad555..f5214dc3 100644
--- a/drivers/staging/lustre/lustre/include/lustre/ll_fiemap.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_fiemap.h
@@ -29,8 +29,6 @@
  * This file is part of Lustre, http://www.lustre.org/
  * Lustre is a trademark of Sun Microsystems, Inc.
  *
- * lustre/include/lustre/ll_fiemap.h
- *
  * FIEMAP data structures and flags. This header file will be used until
  * fiemap.h is available in the upstream kernel.
  *
@@ -41,10 +39,8 @@
 #ifndef _LUSTRE_FIEMAP_H
 #define _LUSTRE_FIEMAP_H
 
-#ifndef __KERNEL__
 #include <stddef.h>
-#include <fiemap.h>
-#endif
+#include <linux/fiemap.h>
 
 /* XXX: We use fiemap_extent::fe_reserved[0] */
 #define fe_device	fe_reserved[0]
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
similarity index 99%
rename from drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
rename to drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
index fe443f8..b7c1a1e 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
@@ -29,8 +29,6 @@
  * This file is part of Lustre, http://www.lustre.org/
  * Lustre is a trademark of Sun Microsystems, Inc.
  *
- * lustre/include/lustre/lustre_idl.h
- *
  * Lustre wire protocol definitions.
  */
 
@@ -71,10 +69,10 @@
 
 #include <linux/types.h>
 
-#include "../../../include/uapi/linux/lnet/lnet-types.h"
+#include "../lnet/lnet-types.h"
 /* Defn's shared with user-space. */
 #include "lustre_user.h"
-#include "../lustre_ver.h"
+#include "lustre_ver.h"
 
 /*
  *  GENERAL STUFF
diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h
index c2c0b27..3060e4d 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h
@@ -31,7 +31,7 @@
 #include <linux/ioctl.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
-#include "../../../../lustre/include/lustre/lustre_idl.h"
+#include "../../../uapi/linux/lustre/lustre_idl.h"
 
 #if !defined(__KERNEL__) && !defined(LUSTRE_UTILS)
 # error This file is for Lustre internal use only.
diff --git a/drivers/staging/lustre/lustre/include/uapi_kernelcomm.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_kernelcomm.h
similarity index 95%
rename from drivers/staging/lustre/lustre/include/uapi_kernelcomm.h
rename to drivers/staging/lustre/include/uapi/linux/lustre/lustre_kernelcomm.h
index 5e99836..94dadbe 100644
--- a/drivers/staging/lustre/lustre/include/uapi_kernelcomm.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_kernelcomm.h
@@ -34,8 +34,8 @@
  * The definitions below are used in the kernel and userspace.
  */
 
-#ifndef __UAPI_KERNELCOMM_H__
-#define __UAPI_KERNELCOMM_H__
+#ifndef __UAPI_LUSTRE_KERNELCOMM_H__
+#define __UAPI_LUSTRE_KERNELCOMM_H__
 
 #include <linux/types.h>
 
@@ -91,4 +91,4 @@ struct lustre_kernelcomm {
 	__u32 lk_flags;
 } __packed;
 
-#endif	/* __UAPI_KERNELCOMM_H__ */
+#endif	/* __UAPI_LUSTRE_KERNELCOMM_H__ */
diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ostid.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ostid.h
index 19fca61..167d482 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ostid.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ostid.h
@@ -35,7 +35,6 @@
 #define _UAPI_LUSTRE_OSTID_H_
 
 #include "lustre_fid.h"
-#include "../../../../lustre/include/lustre/lustre_idl.h"
 
 static inline __u64 lmm_oi_id(const struct ost_id *oi)
 {
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
similarity index 99%
rename from drivers/staging/lustre/lustre/include/lustre/lustre_user.h
rename to drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
index bee93d0..ca720f1 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
@@ -55,7 +55,7 @@
 # include <sys/quota.h>
 # include <sys/stat.h>
 #endif /* __KERNEL__ */
-#include "ll_fiemap.h"
+#include "lustre_fiemap.h"
 
 /*
  * We need to always use 64bit version because the structure
diff --git a/drivers/staging/lustre/lustre/include/lustre_ver.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ver.h
similarity index 100%
rename from drivers/staging/lustre/lustre/include/lustre_ver.h
rename to drivers/staging/lustre/include/uapi/linux/lustre/lustre_ver.h
diff --git a/drivers/staging/lustre/lustre/fid/fid_internal.h b/drivers/staging/lustre/lustre/fid/fid_internal.h
index 5c53773..5f8d15b 100644
--- a/drivers/staging/lustre/lustre/fid/fid_internal.h
+++ b/drivers/staging/lustre/lustre/fid/fid_internal.h
@@ -36,7 +36,7 @@
 #ifndef __FID_INTERNAL_H
 #define __FID_INTERNAL_H
 
-#include "../include/lustre/lustre_idl.h"
+#include "../../include/uapi/linux/lustre/lustre_idl.h"
 #include "../../include/linux/libcfs/libcfs.h"
 
 /* Functions used internally in module. */
diff --git a/drivers/staging/lustre/lustre/fid/fid_lib.c b/drivers/staging/lustre/lustre/fid/fid_lib.c
index 9eb4059..6ab06ef 100644
--- a/drivers/staging/lustre/lustre/fid/fid_lib.c
+++ b/drivers/staging/lustre/lustre/fid/fid_lib.c
@@ -41,7 +41,6 @@
 
 #include "../../include/linux/libcfs/libcfs.h"
 #include <linux/module.h>
-#include "../include/lustre/lustre_idl.h"
 #include "../include/lustre_fid.h"
 
 /**
diff --git a/drivers/staging/lustre/lustre/fld/fld_cache.c b/drivers/staging/lustre/lustre/fld/fld_cache.c
index adaa094..68d009b 100644
--- a/drivers/staging/lustre/lustre/fld/fld_cache.c
+++ b/drivers/staging/lustre/lustre/fld/fld_cache.c
@@ -45,7 +45,7 @@
 
 #include "../include/obd.h"
 #include "../include/obd_class.h"
-#include "../include/lustre_ver.h"
+#include "../../include/uapi/linux/lustre/lustre_ver.h"
 #include "../include/obd_support.h"
 #include "../include/lprocfs_status.h"
 
diff --git a/drivers/staging/lustre/lustre/fld/fld_internal.h b/drivers/staging/lustre/lustre/fld/fld_internal.h
index 4a7f0b7..3412c90 100644
--- a/drivers/staging/lustre/lustre/fld/fld_internal.h
+++ b/drivers/staging/lustre/lustre/fld/fld_internal.h
@@ -56,7 +56,7 @@
 #ifndef __FLD_INTERNAL_H
 #define __FLD_INTERNAL_H
 
-#include "../include/lustre/lustre_idl.h"
+#include "../../include/uapi/linux/lustre/lustre_idl.h"
 
 #include "../../include/linux/libcfs/libcfs.h"
 #include "../include/lustre_req_layout.h"
diff --git a/drivers/staging/lustre/lustre/fld/fld_request.c b/drivers/staging/lustre/lustre/fld/fld_request.c
index 4cade7a..1282992 100644
--- a/drivers/staging/lustre/lustre/fld/fld_request.c
+++ b/drivers/staging/lustre/lustre/fld/fld_request.c
@@ -44,7 +44,7 @@
 
 #include "../include/obd.h"
 #include "../include/obd_class.h"
-#include "../include/lustre_ver.h"
+#include "../../include/uapi/linux/lustre/lustre_ver.h"
 #include "../include/obd_support.h"
 #include "../include/lprocfs_status.h"
 
diff --git a/drivers/staging/lustre/lustre/include/llog_swab.h b/drivers/staging/lustre/lustre/include/llog_swab.h
index fd7ffb1..25516d3 100644
--- a/drivers/staging/lustre/lustre/include/llog_swab.h
+++ b/drivers/staging/lustre/lustre/include/llog_swab.h
@@ -48,7 +48,8 @@
 #ifndef _LLOG_SWAB_H_
 #define _LLOG_SWAB_H_
 
-#include "lustre/lustre_idl.h"
+#include "../../include/uapi/linux/lustre/lustre_idl.h"
+
 struct lustre_cfg;
 
 void lustre_swab_lu_fid(struct lu_fid *fid);
diff --git a/drivers/staging/lustre/lustre/include/lprocfs_status.h b/drivers/staging/lustre/lustre/include/lprocfs_status.h
index 694062a..f5abca8 100644
--- a/drivers/staging/lustre/lustre/include/lprocfs_status.h
+++ b/drivers/staging/lustre/lustre/include/lprocfs_status.h
@@ -45,7 +45,7 @@
 
 #include "../../include/linux/libcfs/libcfs.h"
 #include "../../include/uapi/linux/lustre/lustre_cfg.h"
-#include "lustre/lustre_idl.h"
+#include "../../include/uapi/linux/lustre/lustre_idl.h"
 
 struct lprocfs_vars {
 	const char		*name;
diff --git a/drivers/staging/lustre/lustre/include/lu_object.h b/drivers/staging/lustre/lustre/include/lu_object.h
index 2e70602..ea77d9c 100644
--- a/drivers/staging/lustre/lustre/include/lu_object.h
+++ b/drivers/staging/lustre/lustre/include/lu_object.h
@@ -36,7 +36,7 @@
 #include <stdarg.h>
 #include <linux/percpu_counter.h>
 #include "../../include/linux/libcfs/libcfs.h"
-#include "lustre/lustre_idl.h"
+#include "../../include/uapi/linux/lustre/lustre_idl.h"
 #include "lu_ref.h"
 
 struct seq_file;
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_errno.h b/drivers/staging/lustre/lustre/include/lustre_errno.h
similarity index 100%
rename from drivers/staging/lustre/lustre/include/lustre/lustre_errno.h
rename to drivers/staging/lustre/lustre/include/lustre_errno.h
diff --git a/drivers/staging/lustre/lustre/include/lustre_export.h b/drivers/staging/lustre/lustre/include/lustre_export.h
index 6e7cc46..3502d15 100644
--- a/drivers/staging/lustre/lustre/include/lustre_export.h
+++ b/drivers/staging/lustre/lustre/include/lustre_export.h
@@ -43,7 +43,7 @@
  */
 
 #include "lprocfs_status.h"
-#include "lustre/lustre_idl.h"
+#include "../../include/uapi/linux/lustre/lustre_idl.h"
 #include "lustre_dlm.h"
 
 enum obd_option {
diff --git a/drivers/staging/lustre/lustre/include/lustre_fid.h b/drivers/staging/lustre/lustre/include/lustre_fid.h
index 7c51642..8998a34 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fid.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fid.h
@@ -150,7 +150,7 @@
 
 #include "../../include/linux/libcfs/libcfs.h"
 #include "../../include/uapi/linux/lustre/lustre_fid.h"
-#include "lustre/lustre_idl.h"
+#include "../../include/uapi/linux/lustre/lustre_idl.h"
 #include "../../include/uapi/linux/lustre/lustre_ostid.h"
 
 struct lu_env;
diff --git a/drivers/staging/lustre/lustre/include/lustre_fld.h b/drivers/staging/lustre/lustre/include/lustre_fld.h
index f3c61d1..e335d88 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fld.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fld.h
@@ -38,7 +38,7 @@
  * @{
  */
 
-#include "lustre/lustre_idl.h"
+#include "../../include/uapi/linux/lustre/lustre_idl.h"
 #include "../../include/linux/libcfs/libcfs.h"
 #include "seq_range.h"
 
diff --git a/drivers/staging/lustre/lustre/include/lustre_import.h b/drivers/staging/lustre/lustre/include/lustre_import.h
index f0c931c..0b54e28 100644
--- a/drivers/staging/lustre/lustre/include/lustre_import.h
+++ b/drivers/staging/lustre/lustre/include/lustre_import.h
@@ -44,7 +44,7 @@
  */
 
 #include "lustre_handles.h"
-#include "lustre/lustre_idl.h"
+#include "../../include/uapi/linux/lustre/lustre_idl.h"
 
 /**
  * Adaptive Timeout stuff
diff --git a/drivers/staging/lustre/lustre/include/lustre_kernelcomm.h b/drivers/staging/lustre/lustre/include/lustre_kernelcomm.h
index 970610b..c06648f 100644
--- a/drivers/staging/lustre/lustre/include/lustre_kernelcomm.h
+++ b/drivers/staging/lustre/lustre/include/lustre_kernelcomm.h
@@ -38,7 +38,7 @@
 #define __LUSTRE_KERNELCOMM_H__
 
 /* For declarations shared with userspace */
-#include "uapi_kernelcomm.h"
+#include "../../include/uapi/linux/lustre/lustre_kernelcomm.h"
 
 /* prototype for callback function on kuc groups */
 typedef int (*libcfs_kkuc_cb_t)(void *data, void *cb_arg);
diff --git a/drivers/staging/lustre/lustre/include/lustre_lib.h b/drivers/staging/lustre/lustre/include/lustre_lib.h
index c68dd5d..a7a184f 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lib.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lib.h
@@ -46,8 +46,8 @@
 #include <linux/signal.h>
 #include <linux/types.h>
 #include "../../include/linux/libcfs/libcfs.h"
-#include "lustre/lustre_idl.h"
-#include "lustre_ver.h"
+#include "../../include/uapi/linux/lustre/lustre_idl.h"
+#include "../../include/uapi/linux/lustre/lustre_ver.h"
 #include "../../include/uapi/linux/lustre/lustre_cfg.h"
 
 /* target.c */
diff --git a/drivers/staging/lustre/lustre/include/lustre_lmv.h b/drivers/staging/lustre/lustre/include/lustre_lmv.h
index 5aa3645..f2b8574 100644
--- a/drivers/staging/lustre/lustre/include/lustre_lmv.h
+++ b/drivers/staging/lustre/lustre/include/lustre_lmv.h
@@ -32,7 +32,7 @@
 
 #ifndef _LUSTRE_LMV_H
 #define _LUSTRE_LMV_H
-#include "lustre/lustre_idl.h"
+#include "../../include/uapi/linux/lustre/lustre_idl.h"
 
 struct lmv_oinfo {
 	struct lu_fid	lmo_fid;
diff --git a/drivers/staging/lustre/lustre/include/lustre_log.h b/drivers/staging/lustre/lustre/include/lustre_log.h
index 35e37eb..70fdc0b 100644
--- a/drivers/staging/lustre/lustre/include/lustre_log.h
+++ b/drivers/staging/lustre/lustre/include/lustre_log.h
@@ -53,7 +53,7 @@
  */
 
 #include "obd_class.h"
-#include "lustre/lustre_idl.h"
+#include "../../include/uapi/linux/lustre/lustre_idl.h"
 
 #define LOG_NAME_LIMIT(logname, name)		   \
 	snprintf(logname, sizeof(logname), "LOGS/%s", name)
diff --git a/drivers/staging/lustre/lustre/include/lustre_mdc.h b/drivers/staging/lustre/lustre/include/lustre_mdc.h
index 198ceb0..99abbde 100644
--- a/drivers/staging/lustre/lustre/include/lustre_mdc.h
+++ b/drivers/staging/lustre/lustre/include/lustre_mdc.h
@@ -50,7 +50,6 @@
 #include "lustre_handles.h"
 #include "../../include/linux/libcfs/libcfs.h"
 #include "obd_class.h"
-#include "lustre/lustre_idl.h"
 #include "lustre_lib.h"
 #include "lustre_dlm.h"
 #include "lustre_export.h"
diff --git a/drivers/staging/lustre/lustre/include/lustre_mds.h b/drivers/staging/lustre/lustre/include/lustre_mds.h
index 23a7e4f..2a552ee 100644
--- a/drivers/staging/lustre/lustre/include/lustre_mds.h
+++ b/drivers/staging/lustre/lustre/include/lustre_mds.h
@@ -45,7 +45,6 @@
 
 #include "lustre_handles.h"
 #include "../../include/linux/libcfs/libcfs.h"
-#include "lustre/lustre_idl.h"
 #include "lustre_lib.h"
 #include "lustre_dlm.h"
 #include "lustre_export.h"
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index c0b5927..1ae7e83 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -54,7 +54,7 @@
 #include "../../include/linux/libcfs/libcfs.h"
 #include "../../include/uapi/linux/lnet/nidstr.h"
 #include "../../include/linux/lnet/api.h"
-#include "lustre/lustre_idl.h"
+#include "../../include/uapi/linux/lustre/lustre_idl.h"
 #include "lustre_ha.h"
 #include "lustre_sec.h"
 #include "lustre_import.h"
@@ -63,7 +63,7 @@
 #include "lustre_req_layout.h"
 
 #include "obd_support.h"
-#include "lustre_ver.h"
+#include "../../include/uapi/linux/lustre/lustre_ver.h"
 
 /* MD flags we _always_ use */
 #define PTLRPC_MD_OPTIONS  0
diff --git a/drivers/staging/lustre/lustre/include/lustre_obdo.h b/drivers/staging/lustre/lustre/include/lustre_obdo.h
index 1e12f8c..252191d 100644
--- a/drivers/staging/lustre/lustre/include/lustre_obdo.h
+++ b/drivers/staging/lustre/lustre/include/lustre_obdo.h
@@ -35,7 +35,7 @@
 #ifndef _LUSTRE_OBDO_H_
 #define _LUSTRE_OBDO_H_
 
-#include "lustre/lustre_idl.h"
+#include "../../include/uapi/linux/lustre/lustre_idl.h"
 
 /**
  * Create an obdo to send over the wire
diff --git a/drivers/staging/lustre/lustre/include/lustre_swab.h b/drivers/staging/lustre/lustre/include/lustre_swab.h
index 5c1bdc0..9e13afd 100644
--- a/drivers/staging/lustre/lustre/include/lustre_swab.h
+++ b/drivers/staging/lustre/lustre/include/lustre_swab.h
@@ -48,7 +48,7 @@
 #ifndef _LUSTRE_SWAB_H_
 #define _LUSTRE_SWAB_H_
 
-#include "lustre/lustre_idl.h"
+#include "../../include/uapi/linux/lustre/lustre_idl.h"
 
 void lustre_swab_ptlrpc_body(struct ptlrpc_body *pb);
 void lustre_swab_connect(struct obd_connect_data *ocd);
diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 4dfc31e..aedc550 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -35,7 +35,7 @@
 
 #include <linux/spinlock.h>
 
-#include "lustre/lustre_idl.h"
+#include "../../include/uapi/linux/lustre/lustre_idl.h"
 #include "lustre_lib.h"
 #include "lu_ref.h"
 #include "lustre_export.h"
diff --git a/drivers/staging/lustre/lustre/include/obd_cksum.h b/drivers/staging/lustre/lustre/include/obd_cksum.h
index a8a81e6..54bde73 100644
--- a/drivers/staging/lustre/lustre/include/obd_cksum.h
+++ b/drivers/staging/lustre/lustre/include/obd_cksum.h
@@ -32,7 +32,7 @@
 #define __OBD_CKSUM
 #include "../../include/linux/libcfs/libcfs.h"
 #include "../../include/linux/libcfs/libcfs_crypto.h"
-#include "lustre/lustre_idl.h"
+#include "../../include/uapi/linux/lustre/lustre_idl.h"
 
 static inline unsigned char cksum_obd2cfs(enum cksum_type cksum_type)
 {
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 7d98485..6ae6479 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -37,7 +37,6 @@
 #include "lustre_net.h"
 #include "obd.h"
 #include "lustre_lib.h"
-#include "lustre/lustre_idl.h"
 #include "lprocfs_status.h"
 
 #define OBD_STATFS_NODELAY      0x0001  /* requests should be send without delay
diff --git a/drivers/staging/lustre/lustre/include/seq_range.h b/drivers/staging/lustre/lustre/include/seq_range.h
index 30c4dd6..74a9c63 100644
--- a/drivers/staging/lustre/lustre/include/seq_range.h
+++ b/drivers/staging/lustre/lustre/include/seq_range.h
@@ -34,7 +34,7 @@
 #ifndef _SEQ_RANGE_H_
 #define _SEQ_RANGE_H_
 
-#include "lustre/lustre_idl.h"
+#include "../../include/uapi/linux/lustre/lustre_idl.h"
 
 /**
  * computes the sequence range type \a range
diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
index b8002e9..5e04f05 100644
--- a/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
+++ b/drivers/staging/lustre/lustre/ldlm/ldlm_request.c
@@ -57,8 +57,7 @@
 
 #define DEBUG_SUBSYSTEM S_LDLM
 
-#include "../include/lustre/lustre_errno.h"
-
+#include "../include/lustre_errno.h"
 #include "../include/lustre_dlm.h"
 #include "../include/obd_class.h"
 #include "../include/obd.h"
diff --git a/drivers/staging/lustre/lustre/llite/dcache.c b/drivers/staging/lustre/lustre/llite/dcache.c
index d20425f..d38cb33 100644
--- a/drivers/staging/lustre/lustre/llite/dcache.c
+++ b/drivers/staging/lustre/lustre/llite/dcache.c
@@ -37,7 +37,7 @@
 #define DEBUG_SUBSYSTEM S_LLITE
 
 #include "../include/obd_support.h"
-#include "../include/lustre/lustre_idl.h"
+#include "../../include/uapi/linux/lustre/lustre_idl.h"
 #include "../include/lustre_dlm.h"
 
 #include "llite_internal.h"
diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
index 71d1878..adffc29 100644
--- a/drivers/staging/lustre/lustre/llite/file.c
+++ b/drivers/staging/lustre/lustre/llite/file.c
@@ -42,7 +42,7 @@
 #include <linux/file.h>
 #include <linux/sched.h>
 #include <linux/mount.h>
-#include "../include/lustre/ll_fiemap.h"
+#include "../../include/uapi/linux/lustre/lustre_fiemap.h"
 #include "../../include/uapi/linux/lustre/lustre_ioctl.h"
 #include "../include/lustre_swab.h"
 
diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
index 96515b8..75e4b35 100644
--- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
+++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
@@ -50,7 +50,6 @@
 #include "../include/obd_support.h"
 #include "../include/lustre_fid.h"
 #include "../include/lustre_dlm.h"
-#include "../include/lustre_ver.h"
 #include "../include/lustre_mdc.h"
 #include "../include/cl_object.h"
 
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index cd3311a..a7f0d51 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -33,7 +33,7 @@
 #ifndef LLITE_INTERNAL_H
 #define LLITE_INTERNAL_H
 #include "../include/lustre_debug.h"
-#include "../include/lustre_ver.h"
+#include "../../include/uapi/linux/lustre/lustre_ver.h"
 #include "../include/lustre_disk.h"	/* for s2sbi */
 #include "../include/lustre_linkea.h"
 
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index a208a8b..8dff523 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -43,7 +43,6 @@
 #include "../include/obd_support.h"
 #include "../include/lustre_fid.h"
 #include "../include/lustre_dlm.h"
-#include "../include/lustre_ver.h"
 #include "llite_internal.h"
 
 static int ll_create_it(struct inode *dir, struct dentry *dentry,
diff --git a/drivers/staging/lustre/lustre/llite/range_lock.c b/drivers/staging/lustre/lustre/llite/range_lock.c
index 161391b..3f232cd 100644
--- a/drivers/staging/lustre/lustre/llite/range_lock.c
+++ b/drivers/staging/lustre/lustre/llite/range_lock.c
@@ -34,7 +34,7 @@
  * Author: Bobi Jam <bobijam.xu@intel.com>
  */
 #include "range_lock.h"
-#include "../include/lustre/lustre_user.h"
+#include "../../include/uapi/linux/lustre/lustre_idl.h"
 
 /**
  * Initialize a range lock tree
diff --git a/drivers/staging/lustre/lustre/llite/vvp_internal.h b/drivers/staging/lustre/lustre/llite/vvp_internal.h
index f40fd7f..53ff46c 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_internal.h
+++ b/drivers/staging/lustre/lustre/llite/vvp_internal.h
@@ -37,7 +37,7 @@
 #ifndef VVP_INTERNAL_H
 #define VVP_INTERNAL_H
 
-#include "../include/lustre/lustre_idl.h"
+#include "../../include/uapi/linux/lustre/lustre_idl.h"
 #include "../include/cl_object.h"
 
 enum obd_notify_event;
diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index d0cad7e..48bad7d 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -40,7 +40,6 @@
 
 #include "../include/obd_support.h"
 #include "../include/lustre_dlm.h"
-#include "../include/lustre_ver.h"
 
 #include "llite_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/llite/xattr_cache.c b/drivers/staging/lustre/lustre/llite/xattr_cache.c
index 82cf421..fa11dd5 100644
--- a/drivers/staging/lustre/lustre/llite/xattr_cache.c
+++ b/drivers/staging/lustre/lustre/llite/xattr_cache.c
@@ -14,7 +14,6 @@
 #include <linux/mm.h>
 #include "../include/obd_support.h"
 #include "../include/lustre_dlm.h"
-#include "../include/lustre_ver.h"
 #include "llite_internal.h"
 
 /* If we ever have hundreds of extended attributes, we might want to consider
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_fld.c b/drivers/staging/lustre/lustre/lmv/lmv_fld.c
index 6f8070f..1a7dd15 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_fld.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_fld.c
@@ -38,7 +38,6 @@
 #include <linux/seq_file.h>
 
 #include "../include/obd_support.h"
-#include "../include/lustre/lustre_idl.h"
 #include "../include/lustre_fid.h"
 #include "../include/lustre_lib.h"
 #include "../include/lustre_net.h"
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_intent.c b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
index 5f01a0c..6b10bdd 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_intent.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_intent.c
@@ -39,7 +39,6 @@
 #include <linux/namei.h>
 #include "../include/lustre_intent.h"
 #include "../include/obd_support.h"
-#include "../include/lustre/lustre_idl.h"
 #include "../include/lustre_lib.h"
 #include "../include/lustre_net.h"
 #include "../include/lustre_dlm.h"
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_internal.h b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
index e839b83..ad109c0 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_internal.h
+++ b/drivers/staging/lustre/lustre/lmv/lmv_internal.h
@@ -33,7 +33,7 @@
 #ifndef _LMV_INTERNAL_H_
 #define _LMV_INTERNAL_H_
 
-#include "../include/lustre/lustre_idl.h"
+#include "../../include/uapi/linux/lustre/lustre_idl.h"
 #include "../include/obd.h"
 #include "../include/lustre_lmv.h"
 
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index ab77dbe..f17221f 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -41,7 +41,6 @@
 #include <linux/namei.h>
 #include <linux/uaccess.h>
 
-#include "../include/lustre/lustre_idl.h"
 #include "../include/obd_support.h"
 #include "../include/lustre_net.h"
 #include "../include/obd_class.h"
diff --git a/drivers/staging/lustre/lustre/lov/lov_ea.c b/drivers/staging/lustre/lustre/lov/lov_ea.c
index 2a8fee8..530a4e9 100644
--- a/drivers/staging/lustre/lustre/lov/lov_ea.c
+++ b/drivers/staging/lustre/lustre/lov/lov_ea.c
@@ -40,7 +40,7 @@
 #include "../../include/linux/libcfs/libcfs.h"
 
 #include "../include/obd_class.h"
-#include "../include/lustre/lustre_idl.h"
+#include "../../include/uapi/linux/lustre/lustre_idl.h"
 
 #include "lov_internal.h"
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_internal.h b/drivers/staging/lustre/lustre/lov/lov_internal.h
index 9905df2..4d9437e 100644
--- a/drivers/staging/lustre/lustre/lov/lov_internal.h
+++ b/drivers/staging/lustre/lustre/lov/lov_internal.h
@@ -34,7 +34,7 @@
 #define LOV_INTERNAL_H
 
 #include "../include/obd_class.h"
-#include "../include/lustre/lustre_user.h"
+#include "../../include/uapi/linux/lustre/lustre_idl.h"
 
 /*
  * If we are unable to get the maximum object size from the OST in
diff --git a/drivers/staging/lustre/lustre/lov/lov_obd.c b/drivers/staging/lustre/lustre/lov/lov_obd.c
index 475bf7e..953ed71 100644
--- a/drivers/staging/lustre/lustre/lov/lov_obd.c
+++ b/drivers/staging/lustre/lustre/lov/lov_obd.c
@@ -40,7 +40,7 @@
 #define DEBUG_SUBSYSTEM S_LOV
 #include "../../include/linux/libcfs/libcfs.h"
 
-#include "../include/lustre/lustre_idl.h"
+#include "../../include/uapi/linux/lustre/lustre_idl.h"
 #include "../../include/uapi/linux/lustre/lustre_ioctl.h"
 
 #include "../include/cl_object.h"
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index 638b764..fd346c5 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -38,9 +38,6 @@
 
 #define DEBUG_SUBSYSTEM S_LOV
 
-#include "../include/lustre/lustre_idl.h"
-#include "../include/lustre/lustre_user.h"
-
 #include "../include/lustre_net.h"
 #include "../include/lustre_swab.h"
 #include "../include/obd.h"
diff --git a/drivers/staging/lustre/lustre/lov/lov_request.c b/drivers/staging/lustre/lustre/lov/lov_request.c
index 70636e5..74aeb94 100644
--- a/drivers/staging/lustre/lustre/lov/lov_request.c
+++ b/drivers/staging/lustre/lustre/lov/lov_request.c
@@ -35,7 +35,7 @@
 #include "../../include/linux/libcfs/libcfs.h"
 
 #include "../include/obd_class.h"
-#include "../include/lustre/lustre_idl.h"
+#include "../../include/uapi/linux/lustre/lustre_idl.h"
 #include "lov_internal.h"
 
 static void lov_init_set(struct lov_request_set *set)
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_lib.c b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
index aabdcec..bfd8fbe 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_lib.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_lib.c
@@ -32,7 +32,7 @@
 
 #define DEBUG_SUBSYSTEM S_MDC
 #include "../include/lustre_net.h"
-#include "../include/lustre/lustre_idl.h"
+#include "../../include/uapi/linux/lustre/lustre_idl.h"
 #include "mdc_internal.h"
 
 static void set_mrc_cr_flags(struct mdt_rec_create *mrc, u64 flags)
diff --git a/drivers/staging/lustre/lustre/mdc/mdc_request.c b/drivers/staging/lustre/lustre/mdc/mdc_request.c
index 4dcf3902..3556307 100644
--- a/drivers/staging/lustre/lustre/mdc/mdc_request.c
+++ b/drivers/staging/lustre/lustre/mdc/mdc_request.c
@@ -38,8 +38,7 @@
 # include <linux/init.h>
 # include <linux/utsname.h>
 
-#include "../include/lustre/lustre_errno.h"
-
+#include "../include/lustre_errno.h"
 #include "../include/cl_object.h"
 #include "../include/llog_swab.h"
 #include "../include/lprocfs_status.h"
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_internal.h b/drivers/staging/lustre/lustre/mgc/mgc_internal.h
index f146f75..8cb6758 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_internal.h
+++ b/drivers/staging/lustre/lustre/mgc/mgc_internal.h
@@ -34,7 +34,6 @@
 #define _MGC_INTERNAL_H
 
 #include "../../include/linux/libcfs/libcfs.h"
-#include "../include/lustre/lustre_idl.h"
 #include "../include/lustre_lib.h"
 #include "../include/lustre_dlm.h"
 #include "../include/lustre_log.h"
diff --git a/drivers/staging/lustre/lustre/obdclass/linkea.c b/drivers/staging/lustre/lustre/obdclass/linkea.c
index cf3ad04..d3e754a 100644
--- a/drivers/staging/lustre/lustre/obdclass/linkea.c
+++ b/drivers/staging/lustre/lustre/obdclass/linkea.c
@@ -26,7 +26,7 @@
  * Author: Di Wang <di.wang@intel.com>
  */
 
-#include "../include/lustre/lustre_idl.h"
+#include "../../include/uapi/linux/lustre/lustre_idl.h"
 #include "../include/obd.h"
 #include "../include/lustre_linkea.h"
 
diff --git a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
index 1b5beea..b2f5597 100644
--- a/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
+++ b/drivers/staging/lustre/lustre/obdclass/linux/linux-module.c
@@ -66,7 +66,7 @@
 #include "../../include/obd_class.h"
 #include "../../include/lprocfs_status.h"
 #include "../../../include/uapi/linux/lustre/lustre_ioctl.h"
-#include "../../include/lustre_ver.h"
+#include "../../../include/uapi/linux/lustre/lustre_ver.h"
 
 static int obd_ioctl_is_invalid(struct obd_ioctl_data *data)
 {
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index ba41983..b56a343 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -38,7 +38,7 @@
 
 #include "../include/obd_class.h"
 #include "../include/lprocfs_status.h"
-#include "../include/lustre/lustre_idl.h"
+#include "../../include/uapi/linux/lustre/lustre_idl.h"
 #include <linux/seq_file.h>
 #include <linux/ctype.h>
 
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index 5094829..4e609b5 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -43,7 +43,7 @@
 #include "../include/obd.h"
 #include "../include/lustre_compat.h"
 #include "../include/obd_class.h"
-#include "../include/lustre/lustre_user.h"
+#include "../../include/uapi/linux/lustre/lustre_idl.h"
 #include "../include/lustre_log.h"
 #include "../include/lustre_disk.h"
 #include "../../include/uapi/linux/lustre/lustre_param.h"
diff --git a/drivers/staging/lustre/lustre/obdclass/obdo.c b/drivers/staging/lustre/lustre/obdclass/obdo.c
index b1dfa16..be61460 100644
--- a/drivers/staging/lustre/lustre/obdclass/obdo.c
+++ b/drivers/staging/lustre/lustre/obdclass/obdo.c
@@ -39,7 +39,7 @@
 #define DEBUG_SUBSYSTEM S_CLASS
 
 #include "../include/obd_class.h"
-#include "../include/lustre/lustre_idl.h"
+#include "../../include/uapi/linux/lustre/lustre_idl.h"
 #include "../include/lustre_obdo.h"
 
 void obdo_set_parent_fid(struct obdo *dst, const struct lu_fid *parent)
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 453a59a..af96ac5 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -36,7 +36,7 @@
 
 #include "../include/lustre_dlm.h"
 #include "../include/lustre_net.h"
-#include "../include/lustre/lustre_user.h"
+#include "../../include/uapi/linux/lustre/lustre_idl.h"
 #include "../include/obd_cksum.h"
 
 #include "../include/lustre_ha.h"
diff --git a/drivers/staging/lustre/lustre/ptlrpc/layout.c b/drivers/staging/lustre/lustre/ptlrpc/layout.c
index 5810bba..6624c02 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/layout.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/layout.c
@@ -46,12 +46,12 @@
 
 #include <linux/module.h>
 
-#include "../include/lustre/lustre_idl.h"
+#include "../../include/uapi/linux/lustre/lustre_idl.h"
 
 #include "../include/llog_swab.h"
 #include "../include/lustre_debug.h"
 #include "../include/lustre_swab.h"
-#include "../include/lustre_ver.h"
+#include "../../include/uapi/linux/lustre/lustre_ver.h"
 #include "../include/obd.h"
 #include "../include/obd_support.h"
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
index c429613..ad2703b 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
@@ -34,7 +34,7 @@
 #include "../include/obd_support.h"
 #include "../include/obd.h"
 #include "../include/lprocfs_status.h"
-#include "../include/lustre/lustre_idl.h"
+#include "../../include/uapi/linux/lustre/lustre_idl.h"
 #include "../include/lustre_net.h"
 #include "../include/obd_class.h"
 #include "ptlrpc_internal.h"
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index f116995..5d68fa9 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -42,7 +42,7 @@
 
 #include "../../include/linux/libcfs/libcfs.h"
 
-#include "../include/lustre/ll_fiemap.h"
+#include "../../include/uapi/linux/lustre/lustre_fiemap.h"
 
 #include "../include/llog_swab.h"
 #include "../include/lustre_net.h"
-- 
1.8.3.1
