From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 11:47:25 -0400
Subject: [lustre-devel] [PATCH 57/64] staging: lustre: lustre: cleanup paths
	for lustre UAPI headers
In-Reply-To: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
References: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502725652-26280-58-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Rationalize include paths for the lustre uapi headers

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/uapi/linux/lustre/lustre_cfg.h   | 2 +-
 drivers/staging/lustre/include/uapi/linux/lustre/lustre_fid.h   | 2 +-
 drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h   | 6 +++---
 drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h | 2 +-
 drivers/staging/lustre/include/uapi/linux/lustre/lustre_ostid.h | 2 +-
 drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h  | 2 +-
 6 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_cfg.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_cfg.h
index 2b7deaa..11b51d9 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_cfg.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_cfg.h
@@ -35,7 +35,7 @@
 
 #include <linux/errno.h>
 #include <linux/kernel.h>
-#include "../../../uapi/linux/lustre/lustre_user.h"
+#include <uapi/linux/lustre/lustre_user.h>
 
 /** \defgroup cfg cfg
  *
diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_fid.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_fid.h
index dd3785a..2e7a8d1 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_fid.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_fid.h
@@ -37,7 +37,7 @@
 #ifndef _UAPI_LUSTRE_FID_H_
 #define _UAPI_LUSTRE_FID_H_
 
-#include "../../../uapi/linux/lustre/lustre_idl.h"
+#include <uapi/linux/lustre/lustre_idl.h>
 
 /** returns fid object sequence */
 static inline __u64 fid_seq(const struct lu_fid *fid)
diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
index cc59c1a..aac98db 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
@@ -70,10 +70,10 @@
 #include <asm/byteorder.h>
 #include <linux/types.h>
 
-#include "../lnet/lnet-types.h"
+#include <uapi/linux/lnet/lnet-types.h>
 /* Defn's shared with user-space. */
-#include "lustre_user.h"
-#include "lustre_ver.h"
+#include <uapi/linux/lustre/lustre_user.h>
+#include <uapi/linux/lustre/lustre_ver.h>
 
 /*
  *  GENERAL STUFF
diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h
index 1f52477..9590864 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ioctl.h
@@ -31,7 +31,7 @@
 #include <linux/ioctl.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
-#include "../../../uapi/linux/lustre/lustre_idl.h"
+#include <uapi/linux/lustre/lustre_idl.h>
 
 #if !defined(__KERNEL__) && !defined(LUSTRE_UTILS)
 # error This file is for Lustre internal use only.
diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ostid.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ostid.h
index 167d482..552b2fc 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ostid.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ostid.h
@@ -34,7 +34,7 @@
 #ifndef _UAPI_LUSTRE_OSTID_H_
 #define _UAPI_LUSTRE_OSTID_H_
 
-#include "lustre_fid.h"
+#include <uapi/linux/lustre/lustre_fid.h>
 
 static inline __u64 lmm_oi_id(const struct ost_id *oi)
 {
diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
index 2fcfe2b..5e332e3 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_user.h
@@ -55,7 +55,7 @@
 # include <sys/quota.h>
 # include <sys/stat.h>
 #endif /* __KERNEL__ */
-#include "lustre_fiemap.h"
+#include <uapi/linux/lustre/lustre_fiemap.h>
 
 /*
  * We need to always use 64bit version because the structure
-- 
1.8.3.1
