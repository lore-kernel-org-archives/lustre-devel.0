From: James Simmons <jsimmons@infradead.org>
Date: Mon, 14 Aug 2017 11:47:07 -0400
Subject: [lustre-devel] [PATCH 39/64] staging: lustre: lnet: remove BIT
	macro from lnetctl.h
In-Reply-To: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
References: <1502725652-26280-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1502725652-26280-40-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

Now that lnetctl.h is a UAPI header the BIT macro has to be
removed.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/uapi/linux/lnet/lnetctl.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnetctl.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnetctl.h
index 65b2bf8..f7ffc53 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/lnetctl.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnetctl.h
@@ -32,10 +32,10 @@ enum {
 	LNET_CTL_DELAY_LIST,
 };
 
-#define LNET_ACK_BIT		BIT(0)
-#define LNET_PUT_BIT		BIT(1)
-#define LNET_GET_BIT		BIT(2)
-#define LNET_REPLY_BIT		BIT(3)
+#define LNET_ACK_BIT		(1 << 0)
+#define LNET_PUT_BIT		(1 << 1)
+#define LNET_GET_BIT		(1 << 2)
+#define LNET_REPLY_BIT		(1 << 3)
 
 /** ioctl parameter for LNet fault simulation */
 struct lnet_fault_attr {
-- 
1.8.3.1
