From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Jan 2017 16:30:06 -0500
Subject: [lustre-devel] [PATCH 03/34] staging: lustre: lnet: change
	lstcon_node_ent_t to proper structure
In-Reply-To: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
References: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1484602237-30867-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lstcon_node_ent_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6142
Reviewed-on: https://review.whamcloud.com/24188
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/lnetst.h | 8 ++++----
 drivers/staging/lustre/lnet/selftest/console.c     | 6 +++---
 drivers/staging/lustre/lnet/selftest/console.h     | 4 ++--
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lnetst.h b/drivers/staging/lustre/include/linux/lnet/lnetst.h
index b721287..3252239 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -85,10 +85,10 @@ struct lst_bid {
 #define LST_NODE_DOWN		0x4	/* node is down */
 #define LST_NODE_UNKNOWN	0x8	/* node not in session */
 
-typedef struct {
+struct lstcon_node_ent {
 	lnet_process_id_t       nde_id;		/* id of node */
 	int			nde_state;	/* state of node */
-} lstcon_node_ent_t;		/*** node entry, for list_group command */
+};				/*** node entry, for list_group command */
 
 typedef struct {
 	int	nle_nnode;	/* # of nodes */
@@ -349,7 +349,7 @@ struct lst_bid {
 								group */
 	int __user		*lstio_grp_idxp;	/* IN/OUT: node index */
 	int __user		*lstio_grp_ndentp;	/* IN/OUT: # of nodent */
-	lstcon_node_ent_t __user *lstio_grp_dentsp;	/* OUT: nodent array */
+	struct lstcon_node_ent __user *lstio_grp_dentsp;	/* OUT: nodent array */
 } lstio_group_info_args_t;
 
 #define LST_DEFAULT_BATCH	"batch"			/* default batch name */
@@ -417,7 +417,7 @@ struct lst_bid {
 
 	int __user		*lstio_bat_idxp;	/* IN/OUT: index of node */
 	int __user		*lstio_bat_ndentp;	/* IN/OUT: # of nodent */
-	lstcon_node_ent_t __user *lstio_bat_dentsp;	/* array of nodent */
+	struct lstcon_node_ent __user *lstio_bat_dentsp;/* array of nodent */
 } lstio_batch_info_args_t;
 
 /* add stat in session */
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 02dbfef..8855d2e 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -741,7 +741,7 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 
 static int
 lstcon_nodes_getent(struct list_head *head, int *index_p,
-		    int *count_p, lstcon_node_ent_t __user *dents_up)
+		    int *count_p, struct lstcon_node_ent __user *dents_up)
 {
 	struct lstcon_ndlink *ndl;
 	struct lstcon_node *nd;
@@ -782,7 +782,7 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 int
 lstcon_group_info(char *name, lstcon_ndlist_ent_t __user *gents_p,
 		  int *index_p, int *count_p,
-		  lstcon_node_ent_t __user *dents_up)
+		  struct lstcon_node_ent __user *dents_up)
 {
 	lstcon_ndlist_ent_t *gentp;
 	struct lstcon_group *grp;
@@ -928,7 +928,7 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 int
 lstcon_batch_info(char *name, lstcon_test_batch_ent_t __user *ent_up,
 		  int server, int testidx, int *index_p, int *ndent_p,
-		  lstcon_node_ent_t __user *dents_up)
+		  struct lstcon_node_ent __user *dents_up)
 {
 	lstcon_test_batch_ent_t *entp;
 	struct list_head *clilst;
diff --git a/drivers/staging/lustre/lnet/selftest/console.h b/drivers/staging/lustre/lnet/selftest/console.h
index b37c37e..f6cc694 100644
--- a/drivers/staging/lustre/lnet/selftest/console.h
+++ b/drivers/staging/lustre/lnet/selftest/console.h
@@ -215,7 +215,7 @@ int lstcon_nodes_remove(char *name, int nnd, lnet_process_id_t __user *nds_up,
 			struct list_head __user *result_up);
 int lstcon_group_info(char *name, lstcon_ndlist_ent_t __user *gent_up,
 		      int *index_p, int *ndent_p,
-		      lstcon_node_ent_t __user *ndents_up);
+		      struct lstcon_node_ent __user *ndents_up);
 int lstcon_group_list(int idx, int len, char __user *name_up);
 int lstcon_batch_add(char *name);
 int lstcon_batch_run(char *name, int timeout,
@@ -229,7 +229,7 @@ int lstcon_test_batch_query(char *name, int testidx,
 int lstcon_batch_list(int idx, int namelen, char __user *name_up);
 int lstcon_batch_info(char *name, lstcon_test_batch_ent_t __user *ent_up,
 		      int server, int testidx, int *index_p,
-		      int *ndent_p, lstcon_node_ent_t __user *dents_up);
+		      int *ndent_p, struct lstcon_node_ent __user *dents_up);
 int lstcon_group_stat(char *grp_name, int timeout,
 		      struct list_head __user *result_up);
 int lstcon_nodes_stat(int count, lnet_process_id_t __user *ids_up,
-- 
1.8.3.1
