From: James Simmons <jsimmons@infradead.org>
Date: Sun, 10 Apr 2016 09:13:35 -0400
Subject: [lustre-devel] [PATCH 12/17] staging: lustre: lprocfs: implement
	log2 using bitops
In-Reply-To: <1460294020-2111-1-git-send-email-jsimmons@infradead.org>
References: <1460294020-2111-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1460294020-2111-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Andrew Perepechko <andrew_perepechko@xyratex.com>, James Simmons <jsimmons@infradead.org>

From: Andrew Perepechko <andrew_perepechko@xyratex.com>

This patch implements log2 using fls.

Signed-off-by: Andrew Perepechko <andrew_perepechko@xyratex.com>
Reviewed-by: Alexander Boyko <Alexander_Boyko@xyratex.com>
Reviewed-by: alexander_zarochentsev at xyratex.com
Reviewed-by: Vitaly Fertman <Vitaly_Fertman@xyratex.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3496
Xyratex-bug-id: MRP-999
Reviewed-on: http://review.whamcloud.com/6757
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/obdclass/lprocfs_status.c        |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index d93f42f..172fc91 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -1471,10 +1471,10 @@ EXPORT_SYMBOL(lprocfs_oh_tally);
 
 void lprocfs_oh_tally_log2(struct obd_histogram *oh, unsigned int value)
 {
-	unsigned int val;
+	unsigned int val = 0;
 
-	for (val = 0; ((1 << val) < value) && (val <= OBD_HIST_MAX); val++)
-		;
+	if (likely(value != 0))
+		val = min(fls(value - 1), OBD_HIST_MAX);
 
 	lprocfs_oh_tally(oh, val);
 }
-- 
1.7.1
