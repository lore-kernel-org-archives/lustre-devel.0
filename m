From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Jan 2017 16:30:30 -0500
Subject: [lustre-devel] [PATCH 27/34] staging: lustre: lnet: change
	lstio_stat_args_t to proper structure
In-Reply-To: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
References: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1484602237-30867-28-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lstio_stat_args_t from typedef to proper structure.

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
index 3427512..27b2bde 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -421,7 +421,7 @@ struct lstio_batch_info_args {
 };
 
 /* add stat in session */
-typedef struct {
+struct lstio_stat_args {
 	int			 lstio_sta_key;		/* IN: session key */
 	int			 lstio_sta_timeout;	/* IN: timeout for
 							       stat request */
@@ -432,7 +432,7 @@ struct lstio_batch_info_args {
 	lnet_process_id_t __user *lstio_sta_idsp;	/* IN: pid */
 	struct list_head __user	*lstio_sta_resultp;	/* OUT: list head of
 								result buffer */
-} lstio_stat_args_t;
+};
 
 typedef enum {
 	LST_TEST_BULK	= 1,
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index b76b62e..9039f9f 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -662,7 +662,7 @@
 }
 
 static int
-lst_stat_query_ioctl(lstio_stat_args_t *args)
+lst_stat_query_ioctl(struct lstio_stat_args *args)
 {
 	int rc;
 	char *name = NULL;
@@ -906,7 +906,7 @@ static int lst_test_add_ioctl(lstio_test_args_t *args)
 		rc = lst_test_add_ioctl((lstio_test_args_t *)buf);
 		break;
 	case LSTIO_STAT_QUERY:
-		rc = lst_stat_query_ioctl((lstio_stat_args_t *)buf);
+		rc = lst_stat_query_ioctl((struct lstio_stat_args *)buf);
 		break;
 	default:
 		rc = -EINVAL;
-- 
1.8.3.1
