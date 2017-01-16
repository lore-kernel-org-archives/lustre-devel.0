From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Jan 2017 16:30:21 -0500
Subject: [lustre-devel] [PATCH 18/34] staging: lustre: lnet: change
	lstio_group_list_args_t to proper structure
In-Reply-To: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
References: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1484602237-30867-19-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lstio_group_list_args_t from typedef to proper structure.

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
index bee55a0..12aa7b6 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -334,12 +334,12 @@ struct lstio_group_nodes_args {
 								result buffer */
 };
 
-typedef struct {
+struct lstio_group_list_args {
 	int	 lstio_grp_key;		/* IN: session key */
 	int	 lstio_grp_idx;		/* IN: group idx */
 	int	 lstio_grp_nmlen;	/* IN: name len */
 	char __user *lstio_grp_namep;	/* OUT: name */
-} lstio_group_list_args_t;
+};
 
 typedef struct {
 	int			 lstio_grp_key;		/* IN: session key */
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index fe42e63..a2513d8 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -358,7 +358,7 @@
 }
 
 static int
-lst_group_list_ioctl(lstio_group_list_args_t *args)
+lst_group_list_ioctl(struct lstio_group_list_args *args)
 {
 	if (args->lstio_grp_key != console_session.ses_key)
 		return -EACCES;
@@ -879,7 +879,7 @@ static int lst_test_add_ioctl(lstio_test_args_t *args)
 		rc = lst_nodes_add_ioctl((struct lstio_group_nodes_args *)buf);
 		break;
 	case LSTIO_GROUP_LIST:
-		rc = lst_group_list_ioctl((lstio_group_list_args_t *)buf);
+		rc = lst_group_list_ioctl((struct lstio_group_list_args *)buf);
 		break;
 	case LSTIO_GROUP_INFO:
 		rc = lst_group_info_ioctl((lstio_group_info_args_t *)buf);
-- 
1.8.3.1
