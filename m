From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Jan 2017 16:30:16 -0500
Subject: [lustre-devel] [PATCH 13/34] staging: lustre: lnet: change
	lstio_debug_args_t to proper structure
In-Reply-To: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
References: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1484602237-30867-14-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lstio_debug_args_t from typedef to proper structure.

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
index dbcfc1f..03ebdc3 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -272,7 +272,7 @@ struct lstio_session_end_args {
 #define LST_OPC_BATCHCLI	4
 #define LST_OPC_BATCHSRV	5
 
-typedef struct {
+struct lstio_debug_args {
 	int			 lstio_dbg_key;		/* IN: session key */
 	int			 lstio_dbg_type;	/* IN: debug
 								session|batch|
@@ -291,7 +291,7 @@ struct lstio_session_end_args {
 							       nodes */
 	struct list_head __user	*lstio_dbg_resultp;	/* OUT: list head of
 								result buffer */
-} lstio_debug_args_t;
+};
 
 typedef struct {
 	int		 lstio_grp_key;		/* IN: session key */
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index 3217447..e143e52 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -109,7 +109,7 @@
 }
 
 static int
-lst_debug_ioctl(lstio_debug_args_t *args)
+lst_debug_ioctl(struct lstio_debug_args *args)
 {
 	char *name = NULL;
 	int client = 1;
@@ -864,7 +864,7 @@ static int lst_test_add_ioctl(lstio_test_args_t *args)
 		rc = lst_session_info_ioctl((struct lstio_session_info_args *)buf);
 		break;
 	case LSTIO_DEBUG:
-		rc = lst_debug_ioctl((lstio_debug_args_t *)buf);
+		rc = lst_debug_ioctl((struct lstio_debug_args *)buf);
 		break;
 	case LSTIO_GROUP_ADD:
 		rc = lst_group_add_ioctl((lstio_group_add_args_t *)buf);
-- 
1.8.3.1
