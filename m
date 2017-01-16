From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Jan 2017 16:30:33 -0500
Subject: [lustre-devel] [PATCH 30/34] staging: lustre: lnet: change
	lst_brw_[type|flags]_t to proper enum
In-Reply-To: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
References: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1484602237-30867-31-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lst_brw_[type|flags]_t from typedef to proper enum.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6142
Reviewed-on: https://review.whamcloud.com/24188
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/lnetst.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lnetst.h b/drivers/staging/lustre/include/linux/lnet/lnetst.h
index fdab4b6..0279e09 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -474,16 +474,16 @@ struct lstio_test_args {
 							result buffer */
 };
 
-typedef enum {
+enum lst_brw_type {
 	LST_BRW_READ	= 1,
 	LST_BRW_WRITE	= 2
-} lst_brw_type_t;
+};
 
-typedef enum {
+enum lst_brw_flags {
 	LST_BRW_CHECK_NONE	= 1,
 	LST_BRW_CHECK_SIMPLE	= 2,
 	LST_BRW_CHECK_FULL	= 3
-} lst_brw_flags_t;
+};
 
 typedef struct {
 	int	blk_opc;	/* bulk operation code */
-- 
1.8.3.1
