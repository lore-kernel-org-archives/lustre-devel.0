From: James Simmons <jsimmons@infradead.org>
Date: Sun,  6 Jan 2019 16:36:40 -0500
Subject: [lustre-devel] [PATCH 07/14] lustre: uapi: final fixes for UAPI
 support.
In-Reply-To: <1546810607-6348-1-git-send-email-jsimmons@infradead.org>
References: <1546810607-6348-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1546810607-6348-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Two problems exist that can prevent lustre UAPI headers from
installing properly into /usr/include/linux/lustre. The first
problem is bvec.h is only for kernel space. So make lib-types.h
include bvec.h instead of the UAPI header lnet-types.h. Last
problem was having __uXX inside a comment for lustre_idl.h
confused make install.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/lib-types.h         | 1 +
 drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h   | 1 -
 drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h | 2 +-
 3 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 8951a53..3a54e06 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -36,6 +36,7 @@
 #ifndef __LNET_LIB_TYPES_H__
 #define __LNET_LIB_TYPES_H__
 
+#include <linux/bvec.h>
 #include <linux/kthread.h>
 #include <linux/net.h>
 #include <linux/uio.h>
diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
index e440100..4fcc533 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
@@ -34,7 +34,6 @@
 #define __LNET_TYPES_H__
 
 #include <linux/types.h>
-#include <linux/bvec.h>
 
 /** \addtogroup lnet
  * @{
diff --git a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
index a42ce9d..1d6faf5 100644
--- a/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lustre/lustre_idl.h
@@ -40,7 +40,7 @@
  * that are used in interfaces with userspace should go in lustre_user.h.
  *
  * All structs being declared here should be built from simple fixed-size
- * types (__u8, __u16, __u32, __u64) or be built from other types or
+ * types defined in linux/types.h or be built from other types or
  * structs also declared in this file.  Similarly, all flags and magic
  * values in those structs should also be declared here.  This ensures
  * that the Lustre wire protocol is not influenced by external dependencies.
-- 
1.8.3.1
