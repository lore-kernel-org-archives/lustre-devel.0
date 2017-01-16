From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Jan 2017 16:30:25 -0500
Subject: [lustre-devel] [PATCH 22/34] staging: lustre: lnet: change
	lstio_batch_run_args_t to proper structure
In-Reply-To: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
References: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1484602237-30867-23-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lstio_batch_run_args_t from typedef to proper structure.

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
index c01931c..2c80c34 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -366,7 +366,7 @@ struct lstio_batch_del_args {
 	char __user *lstio_bat_namep;	/* IN: batch name */
 };
 
-typedef struct {
+struct lstio_batch_run_args {
 	int			 lstio_bat_key;		/* IN: session key */
 	int			 lstio_bat_timeout;	/* IN: timeout for
 							       the batch */
@@ -374,7 +374,7 @@ struct lstio_batch_del_args {
 	char __user		*lstio_bat_namep;	/* IN: batch name */
 	struct list_head __user	*lstio_bat_resultp;	/* OUT: list head of
 								result buffer */
-} lstio_batch_run_args_t;
+};
 
 typedef struct {
 	int			 lstio_bat_key;		/* IN: session key */
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index 0ed59be..6631824 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -471,7 +471,7 @@
 }
 
 static int
-lst_batch_run_ioctl(lstio_batch_run_args_t *args)
+lst_batch_run_ioctl(struct lstio_batch_run_args *args)
 {
 	int rc;
 	char *name;
@@ -888,7 +888,7 @@ static int lst_test_add_ioctl(lstio_test_args_t *args)
 		rc = lst_batch_add_ioctl((struct lstio_batch_add_args *)buf);
 		break;
 	case LSTIO_BATCH_START:
-		rc = lst_batch_run_ioctl((lstio_batch_run_args_t *)buf);
+		rc = lst_batch_run_ioctl((struct lstio_batch_run_args *)buf);
 		break;
 	case LSTIO_BATCH_STOP:
 		rc = lst_batch_stop_ioctl((lstio_batch_stop_args_t *)buf);
-- 
1.8.3.1
