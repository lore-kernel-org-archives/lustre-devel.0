From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Jan 2017 16:30:22 -0500
Subject: [lustre-devel] [PATCH 19/34] staging: lustre: lnet: change
	lstio_group_info_args_t to proper structure
In-Reply-To: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
References: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1484602237-30867-20-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lstio_group_info_args_t from typedef to proper structure.

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
index 12aa7b6..715e591 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -341,7 +341,7 @@ struct lstio_group_list_args {
 	char __user *lstio_grp_namep;	/* OUT: name */
 };
 
-typedef struct {
+struct lstio_group_info_args {
 	int			 lstio_grp_key;		/* IN: session key */
 	int			 lstio_grp_nmlen;	/* IN: name len */
 	char __user		*lstio_grp_namep;	/* IN: name */
@@ -350,7 +350,7 @@ struct lstio_group_list_args {
 	int __user		*lstio_grp_idxp;	/* IN/OUT: node index */
 	int __user		*lstio_grp_ndentp;	/* IN/OUT: # of nodent */
 	struct lstcon_node_ent __user *lstio_grp_dentsp;/* OUT: nodent array */
-} lstio_group_info_args_t;
+};
 
 #define LST_DEFAULT_BATCH	"batch"			/* default batch name */
 
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index a2513d8..e9b2d97 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -375,7 +375,7 @@
 }
 
 static int
-lst_group_info_ioctl(lstio_group_info_args_t *args)
+lst_group_info_ioctl(struct lstio_group_info_args *args)
 {
 	char *name;
 	int ndent;
@@ -882,7 +882,7 @@ static int lst_test_add_ioctl(lstio_test_args_t *args)
 		rc = lst_group_list_ioctl((struct lstio_group_list_args *)buf);
 		break;
 	case LSTIO_GROUP_INFO:
-		rc = lst_group_info_ioctl((lstio_group_info_args_t *)buf);
+		rc = lst_group_info_ioctl((struct lstio_group_info_args *)buf);
 		break;
 	case LSTIO_BATCH_ADD:
 		rc = lst_batch_add_ioctl((lstio_batch_add_args_t *)buf);
-- 
1.8.3.1
