From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Jan 2017 16:30:14 -0500
Subject: [lustre-devel] [PATCH 11/34] staging: lustre: lnet: change
	lstio_session_info_args_t to proper structure
In-Reply-To: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
References: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1484602237-30867-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lstio_session_info_args_t from typedef to proper structure.

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
index 079644e..6dfccc5 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -251,7 +251,7 @@ struct lstio_session_new_args {
 };
 
 /* query current session */
-typedef struct {
+struct lstio_session_info_args {
 	struct lst_sid __user	*lstio_ses_idp;		/* OUT: session id */
 	int __user		*lstio_ses_keyp;	/* OUT: local key */
 	/** OUT: session features */
@@ -259,7 +259,7 @@ struct lstio_session_new_args {
 	struct lstcon_ndlist_ent __user *lstio_ses_ndinfo;/* OUT: */
 	int			 lstio_ses_nmlen;	/* IN: name length */
 	char __user		*lstio_ses_namep;	/* OUT: session name */
-} lstio_session_info_args_t;
+};
 
 /* delete a session */
 typedef struct {
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index 9007ebf..b360310 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -87,7 +87,7 @@
 }
 
 static int
-lst_session_info_ioctl(lstio_session_info_args_t *args)
+lst_session_info_ioctl(struct lstio_session_info_args *args)
 {
 	/* no checking of key */
 
@@ -861,7 +861,7 @@ static int lst_test_add_ioctl(lstio_test_args_t *args)
 		rc = lst_session_end_ioctl((lstio_session_end_args_t *)buf);
 		break;
 	case LSTIO_SESSION_INFO:
-		rc = lst_session_info_ioctl((lstio_session_info_args_t *)buf);
+		rc = lst_session_info_ioctl((struct lstio_session_info_args *)buf);
 		break;
 	case LSTIO_DEBUG:
 		rc = lst_debug_ioctl((lstio_debug_args_t *)buf);
-- 
1.8.3.1
