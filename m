From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Jan 2017 16:30:31 -0500
Subject: [lustre-devel] [PATCH 28/34] staging: lustre: lnet: change
	lst_test_type_t to proper enum
In-Reply-To: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
References: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1484602237-30867-29-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lst_test_type_t from typedef to proper enum.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6142
Reviewed-on: https://review.whamcloud.com/24188
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/lnetst.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lnetst.h b/drivers/staging/lustre/include/linux/lnet/lnetst.h
index 27b2bde..495cc01 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -434,10 +434,10 @@ struct lstio_stat_args {
 								result buffer */
 };
 
-typedef enum {
+enum lst_test_type {
 	LST_TEST_BULK	= 1,
 	LST_TEST_PING	= 2
-} lst_test_type_t;
+};
 
 /* create a test in a batch */
 #define LST_MAX_CONCUR	1024	/* Max concurrency of test */
-- 
1.8.3.1
