From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Jan 2017 16:30:13 -0500
Subject: [lustre-devel] [PATCH 10/34] staging: lustre: lnet: change
	lstio_session_new_args_t to proper structure
In-Reply-To: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
References: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1484602237-30867-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lstio_session_new_args_t from typedef to proper structure.

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
index 48dc06f..079644e 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -239,7 +239,7 @@ struct lstcon_trans_stat {
 }
 
 /* create a session */
-typedef struct {
+struct lstio_session_new_args {
 	int		 lstio_ses_key;		/* IN: local key */
 	int		 lstio_ses_timeout;	/* IN: session timeout */
 	int		 lstio_ses_force;	/* IN: force create ? */
@@ -248,7 +248,7 @@ struct lstcon_trans_stat {
 	struct lst_sid __user *lstio_ses_idp;	/* OUT: session id */
 	int		 lstio_ses_nmlen;	/* IN: name length */
 	char __user	 *lstio_ses_namep;	/* IN: session name */
-} lstio_session_new_args_t;
+};
 
 /* query current session */
 typedef struct {
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index a897738..9007ebf 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -42,7 +42,7 @@
 #include "console.h"
 
 static int
-lst_session_new_ioctl(lstio_session_new_args_t *args)
+lst_session_new_ioctl(struct lstio_session_new_args *args)
 {
 	char *name;
 	int rc;
@@ -855,7 +855,7 @@ static int lst_test_add_ioctl(lstio_test_args_t *args)
 
 	switch (opc) {
 	case LSTIO_SESSION_NEW:
-		rc = lst_session_new_ioctl((lstio_session_new_args_t *)buf);
+		rc = lst_session_new_ioctl((struct lstio_session_new_args *)buf);
 		break;
 	case LSTIO_SESSION_END:
 		rc = lst_session_end_ioctl((lstio_session_end_args_t *)buf);
-- 
1.8.3.1
