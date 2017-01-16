From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Jan 2017 16:30:29 -0500
Subject: [lustre-devel] [PATCH 26/34] staging: lustre: lnet: change
	lstio_batch_info_args_t to proper structure
In-Reply-To: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
References: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1484602237-30867-27-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lstio_batch_info_args_t from typedef to proper structure.

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
index 5e594f6..3427512 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -406,7 +406,7 @@ struct lstio_batch_list_args {
 	char __user *lstio_bat_namep;	/* IN: batch name */
 };
 
-typedef struct {
+struct lstio_batch_info_args {
 	int			 lstio_bat_key;		/* IN: session key */
 	int			 lstio_bat_nmlen;	/* IN: name length */
 	char __user		*lstio_bat_namep;	/* IN: name */
@@ -418,7 +418,7 @@ struct lstio_batch_list_args {
 	int __user		*lstio_bat_idxp;	/* IN/OUT: index of node */
 	int __user		*lstio_bat_ndentp;	/* IN/OUT: # of nodent */
 	struct lstcon_node_ent __user *lstio_bat_dentsp;/* array of nodent */
-} lstio_batch_info_args_t;
+};
 
 /* add stat in session */
 typedef struct {
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index fd5eb7b..b76b62e 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -598,7 +598,7 @@
 }
 
 static int
-lst_batch_info_ioctl(lstio_batch_info_args_t *args)
+lst_batch_info_ioctl(struct lstio_batch_info_args *args)
 {
 	char *name;
 	int rc;
@@ -900,7 +900,7 @@ static int lst_test_add_ioctl(lstio_test_args_t *args)
 		rc = lst_batch_list_ioctl((struct lstio_batch_list_args *)buf);
 		break;
 	case LSTIO_BATCH_INFO:
-		rc = lst_batch_info_ioctl((lstio_batch_info_args_t *)buf);
+		rc = lst_batch_info_ioctl((struct lstio_batch_info_args *)buf);
 		break;
 	case LSTIO_TEST_ADD:
 		rc = lst_test_add_ioctl((lstio_test_args_t *)buf);
-- 
1.8.3.1
