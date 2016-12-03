From: James Simmons <jsimmons@infradead.org>
Date: Fri,  2 Dec 2016 19:53:22 -0500
Subject: [lustre-devel] [PATCH 15/22] staging: lustre: rpc: increase bulk
	size
In-Reply-To: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
References: <1480726409-20350-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1480726409-20350-16-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>, Gu Zheng <gzheng@ddn.com>, James Simmons <jsimmons@infradead.org>

From: Jinshan Xiong <jinshan.xiong@intel.com>

To make the ptlrpc be able to size 16MB IO

Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
Signed-off-by: Gu Zheng <gzheng@ddn.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7990
Reviewed-on: http://review.whamcloud.com/19366
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |    6 +++++-
 drivers/staging/lustre/lustre/include/lustre_net.h |    8 ++++++--
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |    2 ++
 3 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index b9f333b..20f55b7 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1683,8 +1683,12 @@ struct obd_ioobj {
 	__u32		ioo_bufcnt;	/* number of niobufs for this object */
 };
 
+/*
+ * NOTE: IOOBJ_MAX_BRW_BITS defines the _offset_ of the max_brw field in
+ * ioo_max_brw, NOT the maximum number of bits in PTLRPC_BULK_OPS_BITS.
+ * That said, ioo_max_brw is a 32-bit field so the limit is also 16 bits.
+ */
 #define IOOBJ_MAX_BRW_BITS	16
-#define IOOBJ_TYPE_MASK		((1U << IOOBJ_MAX_BRW_BITS) - 1)
 #define ioobj_max_brw_get(ioo)	(((ioo)->ioo_max_brw >> IOOBJ_MAX_BRW_BITS) + 1)
 #define ioobj_max_brw_set(ioo, num)					\
 do { (ioo)->ioo_max_brw = ((num) - 1) << IOOBJ_MAX_BRW_BITS; } while (0)
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 2be135d..411eb0d 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -69,13 +69,17 @@
 #define PTLRPC_MD_OPTIONS  0
 
 /**
- * Max # of bulk operations in one request.
+ * log2 max # of bulk operations in one request: 2=4MB/RPC, 5=32MB/RPC, ...
  * In order for the client and server to properly negotiate the maximum
  * possible transfer size, PTLRPC_BULK_OPS_COUNT must be a power-of-two
  * value.  The client is free to limit the actual RPC size for any bulk
  * transfer via cl_max_pages_per_rpc to some non-power-of-two value.
+ * NOTE: This is limited to 16 (=64GB RPCs) by IOOBJ_MAX_BRW_BITS.
  */
-#define PTLRPC_BULK_OPS_BITS	2
+#define PTLRPC_BULK_OPS_BITS	4
+#if PTLRPC_BULK_OPS_BITS > 16
+#error "More than 65536 BRW RPCs not allowed by IOOBJ_MAX_BRW_BITS."
+#endif
 #define PTLRPC_BULK_OPS_COUNT	(1U << PTLRPC_BULK_OPS_BITS)
 /**
  * PTLRPC_BULK_OPS_MASK is for the convenience of the client only, and
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index f50f487..e12eb83 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -1576,6 +1576,8 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct obd_ioobj, ioo_bufcnt));
 	LASSERTF((int)sizeof(((struct obd_ioobj *)0)->ioo_bufcnt) == 4, "found %lld\n",
 		 (long long)(int)sizeof(((struct obd_ioobj *)0)->ioo_bufcnt));
+	LASSERTF(IOOBJ_MAX_BRW_BITS == 16, "found %lld\n",
+		 (long long)IOOBJ_MAX_BRW_BITS);
 
 	/* Checks for union lquota_id */
 	LASSERTF((int)sizeof(union lquota_id) == 16, "found %lld\n",
-- 
1.7.1
