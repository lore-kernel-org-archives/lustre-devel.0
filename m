From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Jan 2017 16:30:19 -0500
Subject: [lustre-devel] [PATCH 16/34] staging: lustre: lnet: change
	lstio_group_update_args_t to proper structure
In-Reply-To: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
References: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1484602237-30867-17-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lstio_group_update_args_t from typedef to proper structure.

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
index 2a02ce5..ff64c2f 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -310,7 +310,7 @@ struct lstio_group_del_args {
 					 * in the group */
 #define LST_GROUP_RMND		3	/* delete nodes from the group */
 
-typedef struct {
+struct lstio_group_update_args {
 	int			 lstio_grp_key;		/* IN: session key */
 	int			 lstio_grp_opc;		/* IN: OPC */
 	int			 lstio_grp_args;	/* IN: arguments */
@@ -320,7 +320,7 @@ struct lstio_group_del_args {
 	lnet_process_id_t __user *lstio_grp_idsp;	/* IN: array of nodes */
 	struct list_head __user	*lstio_grp_resultp;	/* OUT: list head of
 								result buffer */
-} lstio_group_update_args_t;
+};
 
 typedef struct {
 	int			 lstio_grp_key;		/* IN: session key */
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index 5a84c1f..0467f3f 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -256,7 +256,7 @@
 }
 
 static int
-lst_group_update_ioctl(lstio_group_update_args_t *args)
+lst_group_update_ioctl(struct lstio_group_update_args *args)
 {
 	int rc;
 	char *name;
@@ -873,7 +873,7 @@ static int lst_test_add_ioctl(lstio_test_args_t *args)
 		rc = lst_group_del_ioctl((struct lstio_group_del_args *)buf);
 		break;
 	case LSTIO_GROUP_UPDATE:
-		rc = lst_group_update_ioctl((lstio_group_update_args_t *)buf);
+		rc = lst_group_update_ioctl((struct lstio_group_update_args *)buf);
 		break;
 	case LSTIO_NODES_ADD:
 		rc = lst_nodes_add_ioctl((lstio_group_nodes_args_t *)buf);
-- 
1.8.3.1
