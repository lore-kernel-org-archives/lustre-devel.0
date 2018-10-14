From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 14:58:09 -0400
Subject: [lustre-devel] [PATCH 19/28] lustre: uapi: add missing headers in
 lustre UAPI headers
In-Reply-To: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543498-29105-20-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

A test move was done in the linux kernel that moved the UAPI headers
to their proper place. Errors were reported mainly due to
linux/types.h being missing. Add in linux/types.h to prepare for the
move out of staging.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/
Reviewed-on: https://review.whamcloud.com/31737
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Nunez <jnunez@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/uapi/linux/lnet/libcfs_debug.h    | 2 ++
 drivers/staging/lustre/include/uapi/linux/lnet/lnetctl.h         | 1 +
 drivers/staging/lustre/include/uapi/linux/lnet/nidstr.h          | 1 +
 drivers/staging/lustre/include/uapi/linux/lustre/lustre_cfg.h    | 1 +
 drivers/staging/lustre/include/uapi/linux/lustre/lustre_fid.h    | 1 +
 drivers/staging/lustre/include/uapi/linux/lustre/lustre_fiemap.h | 1 +
 drivers/staging/lustre/include/uapi/linux/lustre/lustre_ostid.h  | 1 +
 7 files changed, 8 insertions(+)

diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_debug.h b/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_debug.h
index c4d9472..2672fe7 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_debug.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/libcfs_debug.h
@@ -38,6 +38,8 @@
 #ifndef __UAPI_LIBCFS_DEBUG_H__
 #define __UAPI_LIBCFS_DEBUG_H__
 
+#include <linux/types.h>
+
 /**
  * Format for debug message headers
  */
diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnetctl.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnetctl.h
index cccb32d..9d53c51 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/lnetctl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnetctl.h
@@ -15,6 +15,7 @@
 #ifndef _LNETCTL_H_
 #define _LNETCTL_H_
 
+#include <linux/types.h>
 #include <uapi/linux/lnet/lnet-types.h>
 
 /** \addtogroup lnet_fault_simulation
diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/nidstr.h b/drivers/staging/lustre/include/uapi/linux/lnet/nidstr.h
index 3354e5a..3c5901d 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/nidstr.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/nidstr.h
@@ -28,6 +28,7 @@
 #ifndef _LNET_NIDSTRINGS_H
 #define _LNET_NIDSTRINGS_H
 
+#include <linux/types.h>
 #include <uapi/linux/lnet/lnet-types.h>
 
 /**
diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_cfg.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_cfg.h
index 11b51d9..0620e49 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_cfg.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_cfg.h
@@ -35,6 +35,7 @@
 
 #include <linux/errno.h>
 #include <linux/kernel.h>
+#include <linux/types.h>
 #include <uapi/linux/lustre/lustre_user.h>
 
 /** \defgroup cfg cfg
diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_fid.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_fid.h
index 2e7a8d1..746bf7a 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_fid.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_fid.h
@@ -37,6 +37,7 @@
 #ifndef _UAPI_LUSTRE_FID_H_
 #define _UAPI_LUSTRE_FID_H_
 
+#include <linux/types.h>
 #include <uapi/linux/lustre/lustre_idl.h>
 
 /** returns fid object sequence */
diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_fiemap.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_fiemap.h
index d375a47..d24a93e 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_fiemap.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_fiemap.h
@@ -41,6 +41,7 @@
 
 #include <stddef.h>
 #include <linux/fiemap.h>
+#include <linux/types.h>
 
 /* XXX: We use fiemap_extent::fe_reserved[0] */
 #define fe_device	fe_reserved[0]
diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ostid.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ostid.h
index 3343b60..4b5f110 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ostid.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_ostid.h
@@ -35,6 +35,7 @@
 #define _UAPI_LUSTRE_OSTID_H_
 
 #include <linux/errno.h>
+#include <linux/types.h>
 #include <uapi/linux/lustre/lustre_fid.h>
 
 static inline __u64 lmm_oi_id(const struct ost_id *oi)
-- 
1.8.3.1
