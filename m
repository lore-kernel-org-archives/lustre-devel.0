From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Jan 2017 16:30:32 -0500
Subject: [lustre-devel] [PATCH 29/34] staging: lustre: lnet: change
	lstio_test_args_t to proper structure
In-Reply-To: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
References: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1484602237-30867-30-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lstio_test_args_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6142
Reviewed-on: https://review.whamcloud.com/24188
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/lnetst.h | 4 ++--
 drivers/staging/lustre/lnet/selftest/conctl.c      | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lnetst.h b/drivers/staging/lustre/include/linux/lnet/lnetst.h
index 495cc01..fdab4b6 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -442,7 +442,7 @@ enum lst_test_type {
 /* create a test in a batch */
 #define LST_MAX_CONCUR	1024	/* Max concurrency of test */
 
-typedef struct {
+struct lstio_test_args {
 	int		  lstio_tes_key;	/* IN: session key */
 	int		  lstio_tes_bat_nmlen;	/* IN: batch name len */
 	char __user	 *lstio_tes_bat_name;	/* IN: batch name */
@@ -472,7 +472,7 @@ enum lst_test_type {
 							value */
 	struct list_head __user *lstio_tes_resultp;/* OUT: list head of
 							result buffer */
-} lstio_test_args_t;
+};
 
 typedef enum {
 	LST_BRW_READ	= 1,
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index 9039f9f..6ca7192 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -707,7 +707,7 @@
 	return rc;
 }
 
-static int lst_test_add_ioctl(lstio_test_args_t *args)
+static int lst_test_add_ioctl(struct lstio_test_args *args)
 {
 	char *batch_name;
 	char *src_name = NULL;
@@ -903,7 +903,7 @@ static int lst_test_add_ioctl(lstio_test_args_t *args)
 		rc = lst_batch_info_ioctl((struct lstio_batch_info_args *)buf);
 		break;
 	case LSTIO_TEST_ADD:
-		rc = lst_test_add_ioctl((lstio_test_args_t *)buf);
+		rc = lst_test_add_ioctl((struct lstio_test_args *)buf);
 		break;
 	case LSTIO_STAT_QUERY:
 		rc = lst_stat_query_ioctl((struct lstio_stat_args *)buf);
-- 
1.8.3.1
