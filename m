From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Jan 2017 16:30:20 -0500
Subject: [lustre-devel] [PATCH 17/34] staging: lustre: lnet: change
	lstio_group_nodes_args_t to proper structure
In-Reply-To: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
References: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1484602237-30867-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lstio_group_nodes_args_t from typedef to proper structure.

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
index ff64c2f..bee55a0 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -322,7 +322,7 @@ struct lstio_group_update_args {
 								result buffer */
 };
 
-typedef struct {
+struct lstio_group_nodes_args {
 	int			 lstio_grp_key;		/* IN: session key */
 	int			 lstio_grp_nmlen;	/* IN: name length */
 	char __user		*lstio_grp_namep;	/* IN: group name */
@@ -332,7 +332,7 @@ struct lstio_group_update_args {
 	lnet_process_id_t __user *lstio_grp_idsp;	/* IN: nodes */
 	struct list_head __user	*lstio_grp_resultp;	/* OUT: list head of
 								result buffer */
-} lstio_group_nodes_args_t;
+};
 
 typedef struct {
 	int	 lstio_grp_key;		/* IN: session key */
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index 0467f3f..fe42e63 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -313,7 +313,7 @@
 }
 
 static int
-lst_nodes_add_ioctl(lstio_group_nodes_args_t *args)
+lst_nodes_add_ioctl(struct lstio_group_nodes_args *args)
 {
 	unsigned int feats;
 	int rc;
@@ -876,7 +876,7 @@ static int lst_test_add_ioctl(lstio_test_args_t *args)
 		rc = lst_group_update_ioctl((struct lstio_group_update_args *)buf);
 		break;
 	case LSTIO_NODES_ADD:
-		rc = lst_nodes_add_ioctl((lstio_group_nodes_args_t *)buf);
+		rc = lst_nodes_add_ioctl((struct lstio_group_nodes_args *)buf);
 		break;
 	case LSTIO_GROUP_LIST:
 		rc = lst_group_list_ioctl((lstio_group_list_args_t *)buf);
-- 
1.8.3.1
