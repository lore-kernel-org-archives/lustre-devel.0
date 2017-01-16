From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Jan 2017 16:30:15 -0500
Subject: [lustre-devel] [PATCH 12/34] staging: lustre: lnet: change
	lstio_session_end_args_t to proper structure
In-Reply-To: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
References: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1484602237-30867-13-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lstio_session_end_args_t from typedef to proper structure.

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
index 6dfccc5..dbcfc1f 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -262,9 +262,9 @@ struct lstio_session_info_args {
 };
 
 /* delete a session */
-typedef struct {
+struct lstio_session_end_args {
 	int			lstio_ses_key;	/* IN: session key */
-} lstio_session_end_args_t;
+};
 
 #define LST_OPC_SESSION		1
 #define LST_OPC_GROUP		2
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index b360310..3217447 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -78,7 +78,7 @@
 }
 
 static int
-lst_session_end_ioctl(lstio_session_end_args_t *args)
+lst_session_end_ioctl(struct lstio_session_end_args *args)
 {
 	if (args->lstio_ses_key != console_session.ses_key)
 		return -EACCES;
@@ -858,7 +858,7 @@ static int lst_test_add_ioctl(lstio_test_args_t *args)
 		rc = lst_session_new_ioctl((struct lstio_session_new_args *)buf);
 		break;
 	case LSTIO_SESSION_END:
-		rc = lst_session_end_ioctl((lstio_session_end_args_t *)buf);
+		rc = lst_session_end_ioctl((struct lstio_session_end_args *)buf);
 		break;
 	case LSTIO_SESSION_INFO:
 		rc = lst_session_info_ioctl((struct lstio_session_info_args *)buf);
-- 
1.8.3.1
