From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Jan 2017 16:30:27 -0500
Subject: [lustre-devel] [PATCH 24/34] staging: lustre: lnet: change
	lstio_batch_query_args_t to proper structure
In-Reply-To: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
References: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1484602237-30867-25-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lstio_batch_query_args_t from typedef to proper structure.

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
index 9e90be1..a65309c 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -386,7 +386,7 @@ struct lstio_batch_stop_args {
 								result buffer */
 };
 
-typedef struct {
+struct lstio_batch_query_args {
 	int			 lstio_bat_key;		/* IN: session key */
 	int			 lstio_bat_testidx;	/* IN: test index */
 	int			 lstio_bat_client;	/* IN: we testing
@@ -397,7 +397,7 @@ struct lstio_batch_stop_args {
 	char __user		*lstio_bat_namep;	/* IN: batch name */
 	struct list_head __user	*lstio_bat_resultp;	/* OUT: list head of
 								result buffer */
-} lstio_batch_query_args_t;
+};
 
 typedef struct {
 	int	 lstio_bat_key;		/* IN: session key */
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index 78dbfa2..353008e 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -540,7 +540,7 @@
 }
 
 static int
-lst_batch_query_ioctl(lstio_batch_query_args_t *args)
+lst_batch_query_ioctl(struct lstio_batch_query_args *args)
 {
 	char *name;
 	int rc;
@@ -894,7 +894,7 @@ static int lst_test_add_ioctl(lstio_test_args_t *args)
 		rc = lst_batch_stop_ioctl((struct lstio_batch_stop_args *)buf);
 		break;
 	case LSTIO_BATCH_QUERY:
-		rc = lst_batch_query_ioctl((lstio_batch_query_args_t *)buf);
+		rc = lst_batch_query_ioctl((struct lstio_batch_query_args *)buf);
 		break;
 	case LSTIO_BATCH_LIST:
 		rc = lst_batch_list_ioctl((lstio_batch_list_args_t *)buf);
-- 
1.8.3.1
