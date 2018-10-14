From: James Simmons <jsimmons@infradead.org>
Date: Sun, 14 Oct 2018 14:55:32 -0400
Subject: [lustre-devel] [PATCH 10/10] lustre: lnet: make LNET_MAX_IOV
 dependent on page size
In-Reply-To: <1539543332-28679-1-git-send-email-jsimmons@infradead.org>
References: <1539543332-28679-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1539543332-28679-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The default behavior of LNet is to always use 256 pages which is
LNET_MAX_IOV and that LNET_MAX_PAYLOAD is always one megabyte.
This assumes pages are always 4K in size which is not the case.
This cause bulk I/O errors when using platforms like PowerPC or
ARM which tend to use 64K pages. This is resolved by first making
LNET_MAX_PAYLOAD always one megabyte since this is what the
configuring sets it too by default and no one ever changes it.
In theory it could set it to as high as 16MB but that will cause
the I/O errors since the ptlrpc layer expects the packets to be
always 1 megabyte in size. Also it would be better to make the
maximum payload a per network setup configurations instead of for
everything. Second we make LNET_MAX_IOV equal to LNET_MAX_PAYLOAD
divided by the PAGE_SIZE. This way packets will always be the
LNET_MAX_PAYLOAD in size but the number of pages used,
LNET_MAX_IOV will vary depending on the platform it is creating
packets on.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-10157
Reviewed-on: https://review.whamcloud.com/31559
Reviewed-by: Wang Shilong <wshilong@ddn.com>
Reviewed-by: Ruth Klundt <rklundt@sandia.gov>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/lib-types.h       | 10 ++++------
 drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h |  3 ---
 drivers/staging/lustre/lnet/Kconfig                         | 10 ----------
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c         |  4 ++--
 drivers/staging/lustre/lustre/include/lustre_net.h          |  1 +
 5 files changed, 7 insertions(+), 21 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 19f7b11..8951a53 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -37,6 +37,7 @@
 #define __LNET_LIB_TYPES_H__
 
 #include <linux/kthread.h>
+#include <linux/net.h>
 #include <linux/uio.h>
 #include <linux/types.h>
 #include <linux/completion.h>
@@ -46,12 +47,9 @@
 #include <uapi/linux/lnet/lnet-dlc.h>
 
 /* Max payload size */
-#define LNET_MAX_PAYLOAD      CONFIG_LNET_MAX_PAYLOAD
-#if (LNET_MAX_PAYLOAD < LNET_MTU)
-# error "LNET_MAX_PAYLOAD too small - error in configure --with-max-payload-mb"
-#elif (LNET_MAX_PAYLOAD > (PAGE_SIZE * LNET_MAX_IOV))
-# error "LNET_MAX_PAYLOAD too large - error in configure --with-max-payload-mb"
-#endif
+#define LNET_MAX_PAYLOAD	LNET_MTU
+
+#define LNET_MAX_IOV		(LNET_MAX_PAYLOAD >> PAGE_SHIFT)
 
 /* forward refs */
 struct lnet_libmd;
diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
index 1ecf18e..e440100 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
@@ -522,9 +522,6 @@ struct lnet_md {
 #define LNET_MTU_BITS	20
 #define LNET_MTU	(1 << LNET_MTU_BITS)
 
-/** limit on the number of fragments in discontiguous MDs */
-#define LNET_MAX_IOV	256
-
 /**
  * Options for the MD structure. See lnet_md::options.
  */
diff --git a/drivers/staging/lustre/lnet/Kconfig b/drivers/staging/lustre/lnet/Kconfig
index ad049e6..6062a82 100644
--- a/drivers/staging/lustre/lnet/Kconfig
+++ b/drivers/staging/lustre/lnet/Kconfig
@@ -8,16 +8,6 @@ config LNET
 	  case of Lustre routers only the LNet layer is required. Lately other
 	  projects are also looking into using LNet as their networking API as well.
 
-config LNET_MAX_PAYLOAD
-	int "Lustre lnet max transfer payload (default 1MB)"
-	depends on LNET
-	default "1048576"
-	help
-	  This option defines the maximum size of payload in bytes that lnet
-	  can put into its transport.
-
-	  If unsure, use default.
-
 config LNET_SELFTEST
 	tristate "Lustre networking self testing"
 	depends on LNET
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 66aa45f..68a8963 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1414,7 +1414,7 @@ static void kiblnd_destroy_fmr_pool_list(struct list_head *head)
 static int kiblnd_alloc_fmr_pool(struct kib_fmr_poolset *fps, struct kib_fmr_pool *fpo)
 {
 	struct ib_fmr_pool_param param = {
-		.max_pages_per_fmr = LNET_MAX_PAYLOAD / PAGE_SIZE,
+		.max_pages_per_fmr = LNET_MAX_IOV,
 		.page_shift        = PAGE_SHIFT,
 		.access            = (IB_ACCESS_LOCAL_WRITE |
 				      IB_ACCESS_REMOTE_WRITE),
@@ -1474,7 +1474,7 @@ static int kiblnd_alloc_freg_pool(struct kib_fmr_poolset *fps,
 		frd->frd_mr = ib_alloc_mr(fpo->fpo_hdev->ibh_pd,
 					  fastreg_gaps ? IB_MR_TYPE_SG_GAPS :
 							 IB_MR_TYPE_MEM_REG,
-					  LNET_MAX_PAYLOAD / PAGE_SIZE);
+					  LNET_MAX_IOV);
 		if (IS_ERR(frd->frd_mr)) {
 			rc = PTR_ERR(frd->frd_mr);
 			CERROR("Failed to allocate ib_alloc_mr: %d\n", rc);
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 2df72c7..ce7e98c 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -56,6 +56,7 @@
 #include <linux/libcfs/libcfs.h>
 #include <uapi/linux/lnet/nidstr.h>
 #include <linux/lnet/api.h>
+#include <linux/lnet/lib-types.h>
 #include <uapi/linux/lustre/lustre_idl.h>
 #include <lustre_errno.h>
 #include <lustre_ha.h>
-- 
1.8.3.1
