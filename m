From: James Simmons <jsimmons@infradead.org>
Date: Thu, 28 Apr 2016 12:07:33 -0400
Subject: [lustre-devel] [PATCH 3/8] staging: lustre: brw: added OBDO short
	io flag
In-Reply-To: <1461859658-22200-1-git-send-email-jsimmons@infradead.org>
References: <1461859658-22200-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1461859658-22200-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Alexander Boyko <alexander_boyko@xyratex.com>, James Simmons <jsimmons@infradead.org>

From: Alexander Boyko <alexander_boyko@xyratex.com>

To prevent collisions with any future flags needed in features written
against this branch.

Signed-off-by: Alexander Boyko <alexander_boyko@xyratex.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-1757
Xyratex-bug-id: MRP-1460
Reviewed-on: http://review.whamcloud.com/8182
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Vitaly Fertman <vitaly_fertman@xyratex.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre/lustre_idl.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 0ef540a..9185ed2 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1433,6 +1433,7 @@ enum obdo_flags {
 	OBD_FL_RECOV_RESEND = 0x00080000, /* recoverable resent */
 	OBD_FL_NOSPC_BLK    = 0x00100000, /* no more block space on OST */
 	OBD_FL_FLUSH	    = 0x00200000, /* flush pages on the OST */
+	OBD_FL_SHORT_IO	    = 0x00400000, /* short io request */
 
 	/* Note that while these checksum values are currently separate bits,
 	 * in 2.x we can actually allow all values from 1-31 if we wanted.
-- 
2.7.4
