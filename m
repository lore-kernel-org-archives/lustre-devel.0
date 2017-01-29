From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:05:17 -0500
Subject: [lustre-devel] [PATCH 49/60] staging: lustre: socklnd: remove
	socklnd_init_msg
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-50-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Remove the inline function socklnd_init_msg.
Its only used by the kernel code so no point
keeping it in an UAPI header.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6142
Reviewed-on: https://review.whamcloud.com/18506
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/socklnd.h    | 9 ---------
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c | 9 +++++++--
 2 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/socklnd.h b/drivers/staging/lustre/include/linux/lnet/socklnd.h
index 7d24a91..acf20ce 100644
--- a/drivers/staging/lustre/include/linux/lnet/socklnd.h
+++ b/drivers/staging/lustre/include/linux/lnet/socklnd.h
@@ -80,15 +80,6 @@
 	} WIRE_ATTR ksm_u;
 } WIRE_ATTR ksock_msg_t;
 
-static inline void
-socklnd_init_msg(ksock_msg_t *msg, int type)
-{
-	msg->ksm_csum = 0;
-	msg->ksm_type = type;
-	msg->ksm_zc_cookies[0] = 0;
-	msg->ksm_zc_cookies[1] = 0;
-}
-
 #define KSOCK_MSG_NOOP	0xC0	/* ksm_u empty */
 #define KSOCK_MSG_LNET	0xC1	/* lnet msg */
 
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index b7043e2..b161c2b 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -80,7 +80,9 @@ struct ksock_tx *
 	tx->tx_niov    = 1;
 	tx->tx_nonblk  = nonblk;
 
-	socklnd_init_msg(&tx->tx_msg, KSOCK_MSG_NOOP);
+	tx->tx_msg.ksm_csum = 0;
+	tx->tx_msg.ksm_type = KSOCK_MSG_NOOP;
+	tx->tx_msg.ksm_zc_cookies[0] = 0;
 	tx->tx_msg.ksm_zc_cookies[1] = cookie;
 
 	return tx;
@@ -1004,7 +1006,10 @@ struct ksock_route *
 			tx->tx_zc_capable = 1;
 	}
 
-	socklnd_init_msg(&tx->tx_msg, KSOCK_MSG_LNET);
+	tx->tx_msg.ksm_csum = 0;
+	tx->tx_msg.ksm_type = KSOCK_MSG_LNET;
+	tx->tx_msg.ksm_zc_cookies[0] = 0;
+	tx->tx_msg.ksm_zc_cookies[1] = 0;
 
 	/* The first fragment will be set later in pro_pack */
 	rc = ksocknal_launch_packet(ni, tx, target);
-- 
1.8.3.1
