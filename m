From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Jan 2017 16:30:28 -0500
Subject: [lustre-devel] [PATCH 25/34] staging: lustre: lnet: change
	lstio_batch_list_args_t to proper structure
In-Reply-To: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
References: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1484602237-30867-26-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lstio_batch_list_args_t from typedef to proper structure.

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
index a65309c..5e594f6 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -399,12 +399,12 @@ struct lstio_batch_query_args {
 								result buffer */
 };
 
-typedef struct {
+struct lstio_batch_list_args {
 	int	 lstio_bat_key;		/* IN: session key */
 	int	 lstio_bat_idx;		/* IN: index */
 	int	 lstio_bat_nmlen;	/* IN: name length */
 	char __user *lstio_bat_namep;	/* IN: batch name */
-} lstio_batch_list_args_t;
+};
 
 typedef struct {
 	int			 lstio_bat_key;		/* IN: session key */
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index 353008e..fd5eb7b 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -581,7 +581,7 @@
 }
 
 static int
-lst_batch_list_ioctl(lstio_batch_list_args_t *args)
+lst_batch_list_ioctl(struct lstio_batch_list_args *args)
 {
 	if (args->lstio_bat_key != console_session.ses_key)
 		return -EACCES;
@@ -897,7 +897,7 @@ static int lst_test_add_ioctl(lstio_test_args_t *args)
 		rc = lst_batch_query_ioctl((struct lstio_batch_query_args *)buf);
 		break;
 	case LSTIO_BATCH_LIST:
-		rc = lst_batch_list_ioctl((lstio_batch_list_args_t *)buf);
+		rc = lst_batch_list_ioctl((struct lstio_batch_list_args *)buf);
 		break;
 	case LSTIO_BATCH_INFO:
 		rc = lst_batch_info_ioctl((lstio_batch_info_args_t *)buf);
-- 
1.8.3.1
