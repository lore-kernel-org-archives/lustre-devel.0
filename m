From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Jan 2017 16:30:10 -0500
Subject: [lustre-devel] [PATCH 07/34] staging: lustre: lnet: change
	lstcon_test_batch_ent_t to proper structure
In-Reply-To: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
References: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1484602237-30867-8-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lstcon_test_batch_ent_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6142
Reviewed-on: https://review.whamcloud.com/24188
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/lnetst.h |  6 +++---
 drivers/staging/lustre/lnet/selftest/console.c     | 10 +++++-----
 drivers/staging/lustre/lnet/selftest/console.h     |  2 +-
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lnetst.h b/drivers/staging/lustre/include/linux/lnet/lnetst.h
index f2b98e9..adc03fe 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -112,7 +112,7 @@ struct lstcon_batch_ent {
 };				/*** batch summary entry, for
 				 *** list_batch command */
 
-typedef struct {
+struct lstcon_test_batch_ent {
 	struct lstcon_ndlist_ent   tbe_cli_nle;	/* client (group) node_list
 						 * entry */
 	struct lstcon_ndlist_ent   tbe_srv_nle;	/* server (group) node_list
@@ -121,7 +121,7 @@ struct lstcon_batch_ent {
 		struct lstcon_test_ent	tbe_test; /* test entry */
 		struct lstcon_batch_ent tbe_batch;/* batch entry */
 	} u;
-} lstcon_test_batch_ent_t;	/*** test/batch verbose information entry,
+};				/*** test/batch verbose information entry,
 				 *** for list_batch command */
 
 typedef struct {
@@ -413,7 +413,7 @@ struct lstcon_batch_ent {
 	int			 lstio_bat_server;	/* IN: query server
 							       or not */
 	int			 lstio_bat_testidx;	/* IN: test index */
-	lstcon_test_batch_ent_t __user *lstio_bat_entp;	/* OUT: batch ent */
+	struct lstcon_test_batch_ent __user *lstio_bat_entp;/* OUT: batch ent */
 
 	int __user		*lstio_bat_idxp;	/* IN/OUT: index of node */
 	int __user		*lstio_bat_ndentp;	/* IN/OUT: # of nodent */
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 9af761f..bf4111a 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -926,11 +926,11 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 }
 
 int
-lstcon_batch_info(char *name, lstcon_test_batch_ent_t __user *ent_up,
+lstcon_batch_info(char *name, struct lstcon_test_batch_ent __user *ent_up,
 		  int server, int testidx, int *index_p, int *ndent_p,
 		  struct lstcon_node_ent __user *dents_up)
 {
-	lstcon_test_batch_ent_t *entp;
+	struct lstcon_test_batch_ent *entp;
 	struct list_head *clilst;
 	struct list_head *srvlst;
 	struct lstcon_test *test = NULL;
@@ -969,7 +969,7 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 	}
 
 	/* non-verbose query */
-	LIBCFS_ALLOC(entp, sizeof(lstcon_test_batch_ent_t));
+	LIBCFS_ALLOC(entp, sizeof(struct lstcon_test_batch_ent));
 	if (!entp)
 		return -ENOMEM;
 
@@ -989,9 +989,9 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 		LST_NODE_STATE_COUNTER(ndl->ndl_node, &entp->tbe_srv_nle);
 
 	rc = copy_to_user(ent_up, entp,
-			  sizeof(lstcon_test_batch_ent_t)) ? -EFAULT : 0;
+			  sizeof(struct lstcon_test_batch_ent)) ? -EFAULT : 0;
 
-	LIBCFS_FREE(entp, sizeof(lstcon_test_batch_ent_t));
+	LIBCFS_FREE(entp, sizeof(struct lstcon_test_batch_ent));
 
 	return rc;
 }
diff --git a/drivers/staging/lustre/lnet/selftest/console.h b/drivers/staging/lustre/lnet/selftest/console.h
index 30d73b6..f8d61ce 100644
--- a/drivers/staging/lustre/lnet/selftest/console.h
+++ b/drivers/staging/lustre/lnet/selftest/console.h
@@ -227,7 +227,7 @@ int lstcon_test_batch_query(char *name, int testidx,
 			    struct list_head __user *result_up);
 int lstcon_batch_del(char *name);
 int lstcon_batch_list(int idx, int namelen, char __user *name_up);
-int lstcon_batch_info(char *name, lstcon_test_batch_ent_t __user *ent_up,
+int lstcon_batch_info(char *name, struct lstcon_test_batch_ent __user *ent_up,
 		      int server, int testidx, int *index_p,
 		      int *ndent_p, struct lstcon_node_ent __user *dents_up);
 int lstcon_group_stat(char *grp_name, int timeout,
-- 
1.8.3.1
