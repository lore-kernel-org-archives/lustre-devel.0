From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Jan 2017 16:30:17 -0500
Subject: [lustre-devel] [PATCH 14/34] staging: lustre: lnet: change
	lstio_group_add_args_t to proper structure
In-Reply-To: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
References: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1484602237-30867-15-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lstio_group_add_args_t from typedef to proper structure.

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
index 03ebdc3..7194552 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -293,11 +293,11 @@ struct lstio_debug_args {
 								result buffer */
 };
 
-typedef struct {
+struct lstio_group_add_args {
 	int		 lstio_grp_key;		/* IN: session key */
 	int		 lstio_grp_nmlen;	/* IN: name length */
 	char __user	*lstio_grp_namep;	/* IN: group name */
-} lstio_group_add_args_t;
+};
 
 typedef struct {
 	int		 lstio_grp_key;		/* IN: session key */
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index e143e52..c3435b4 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -190,7 +190,7 @@
 }
 
 static int
-lst_group_add_ioctl(lstio_group_add_args_t *args)
+lst_group_add_ioctl(struct lstio_group_add_args *args)
 {
 	char *name;
 	int rc;
@@ -867,7 +867,7 @@ static int lst_test_add_ioctl(lstio_test_args_t *args)
 		rc = lst_debug_ioctl((struct lstio_debug_args *)buf);
 		break;
 	case LSTIO_GROUP_ADD:
-		rc = lst_group_add_ioctl((lstio_group_add_args_t *)buf);
+		rc = lst_group_add_ioctl((struct lstio_group_add_args *)buf);
 		break;
 	case LSTIO_GROUP_DEL:
 		rc = lst_group_del_ioctl((lstio_group_del_args_t *)buf);
-- 
1.8.3.1
