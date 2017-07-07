From: Craig Inches <Craig@craiginches.com>
Date: Fri, 07 Jul 2017 01:47:20 +0000 (UTC)
Subject: [lustre-devel] [PATCH 4/4] Staging: Lustre Fix block statement
	style issue
In-Reply-To: <cover.1499388016.git.Craig@craiginches.com>
References: <cover.1499388016.git.Craig@craiginches.com>
Message-ID: <62fcfe7c2367fb58e4ef0c8d5963739bf4c48a58.1499388016.git.Craig@craiginches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

This fixes a block statement which didnt end with */

Signed-off-by: Craig Inches <Craig@craiginches.com>
---
 drivers/staging/lustre/include/linux/lnet/socklnd.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/socklnd.h b/drivers/staging/lustre/include/linux/lnet/socklnd.h
index dd5bc0e46560..a1ae66ede7a8 100644
--- a/drivers/staging/lustre/include/linux/lnet/socklnd.h
+++ b/drivers/staging/lustre/include/linux/lnet/socklnd.h
@@ -76,7 +76,8 @@ struct ksock_msg {
 	__u64	ksm_zc_cookies[2];	/* Zero-Copy request/ACK cookie */
 	union {
 		struct ksock_lnet_msg lnetmsg; /* lnet message, it's empty if
-					  * it's NOOP */
+						* it's NOOP
+						*/
 	} WIRE_ATTR ksm_u;
 } WIRE_ATTR;
 
-- 
2.13.0
