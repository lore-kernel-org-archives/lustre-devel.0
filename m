From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Jan 2017 16:30:07 -0500
Subject: [lustre-devel] [PATCH 04/34] staging: lustre: lnet: change
	lstcon_ndlist_ent_t to proper structure
In-Reply-To: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
References: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1484602237-30867-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lstcon_ndlist_ent_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6142
Reviewed-on: https://review.whamcloud.com/24188
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/lnetst.h | 16 ++++++++--------
 drivers/staging/lustre/lnet/selftest/console.c     | 14 +++++++-------
 drivers/staging/lustre/lnet/selftest/console.h     |  4 ++--
 3 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lnetst.h b/drivers/staging/lustre/include/linux/lnet/lnetst.h
index 3252239..ec243d7 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -90,13 +90,13 @@ struct lstcon_node_ent {
 	int			nde_state;	/* state of node */
 };				/*** node entry, for list_group command */
 
-typedef struct {
+struct lstcon_ndlist_ent {
 	int	nle_nnode;	/* # of nodes */
 	int	nle_nactive;	/* # of active nodes */
 	int	nle_nbusy;	/* # of busy nodes */
 	int	nle_ndown;	/* # of down nodes */
 	int	nle_nunknown;	/* # of unknown nodes */
-} lstcon_ndlist_ent_t;		/*** node_list entry, for list_batch command */
+};				/*** node_list entry, for list_batch command */
 
 typedef struct {
 	int	tse_type;       /* test type */
@@ -113,9 +113,9 @@ struct lstcon_node_ent {
 				 *** list_batch command */
 
 typedef struct {
-	lstcon_ndlist_ent_t     tbe_cli_nle;	/* client (group) node_list
+	struct lstcon_ndlist_ent   tbe_cli_nle;	/* client (group) node_list
 						 * entry */
-	lstcon_ndlist_ent_t     tbe_srv_nle;	/* server (group) node_list
+	struct lstcon_ndlist_ent   tbe_srv_nle;	/* server (group) node_list
 						 * entry */
 	union {
 		lstcon_test_ent_t  tbe_test;	/* test entry */
@@ -256,7 +256,7 @@ struct lstcon_node_ent {
 	int __user		*lstio_ses_keyp;	/* OUT: local key */
 	/** OUT: session features */
 	unsigned int __user	*lstio_ses_featp;
-	lstcon_ndlist_ent_t __user *lstio_ses_ndinfo;	/* OUT: */
+	struct lstcon_ndlist_ent __user *lstio_ses_ndinfo;/* OUT: */
 	int			 lstio_ses_nmlen;	/* IN: name length */
 	char __user		*lstio_ses_namep;	/* OUT: session name */
 } lstio_session_info_args_t;
@@ -345,11 +345,11 @@ struct lstcon_node_ent {
 	int			 lstio_grp_key;		/* IN: session key */
 	int			 lstio_grp_nmlen;	/* IN: name len */
 	char __user		*lstio_grp_namep;	/* IN: name */
-	lstcon_ndlist_ent_t __user *lstio_grp_entp;	/* OUT: description of
-								group */
+	struct lstcon_ndlist_ent __user *lstio_grp_entp;/* OUT: description of
+							   group */
 	int __user		*lstio_grp_idxp;	/* IN/OUT: node index */
 	int __user		*lstio_grp_ndentp;	/* IN/OUT: # of nodent */
-	struct lstcon_node_ent __user *lstio_grp_dentsp;	/* OUT: nodent array */
+	struct lstcon_node_ent __user *lstio_grp_dentsp;/* OUT: nodent array */
 } lstio_group_info_args_t;
 
 #define LST_DEFAULT_BATCH	"batch"			/* default batch name */
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 8855d2e..9af761f 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -780,11 +780,11 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 }
 
 int
-lstcon_group_info(char *name, lstcon_ndlist_ent_t __user *gents_p,
+lstcon_group_info(char *name, struct lstcon_ndlist_ent __user *gents_p,
 		  int *index_p, int *count_p,
 		  struct lstcon_node_ent __user *dents_up)
 {
-	lstcon_ndlist_ent_t *gentp;
+	struct lstcon_ndlist_ent *gentp;
 	struct lstcon_group *grp;
 	struct lstcon_ndlink *ndl;
 	int rc;
@@ -805,7 +805,7 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 	}
 
 	/* non-verbose query */
-	LIBCFS_ALLOC(gentp, sizeof(lstcon_ndlist_ent_t));
+	LIBCFS_ALLOC(gentp, sizeof(struct lstcon_ndlist_ent));
 	if (!gentp) {
 		CERROR("Can't allocate ndlist_ent\n");
 		lstcon_group_decref(grp);
@@ -817,9 +817,9 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 		LST_NODE_STATE_COUNTER(ndl->ndl_node, gentp);
 
 	rc = copy_to_user(gents_p, gentp,
-			  sizeof(lstcon_ndlist_ent_t)) ? -EFAULT : 0;
+			  sizeof(struct lstcon_ndlist_ent)) ? -EFAULT : 0;
 
-	LIBCFS_FREE(gentp, sizeof(lstcon_ndlist_ent_t));
+	LIBCFS_FREE(gentp, sizeof(struct lstcon_ndlist_ent));
 
 	lstcon_group_decref(grp);
 
@@ -1778,10 +1778,10 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 int
 lstcon_session_info(struct lst_sid __user *sid_up, int __user *key_up,
 		    unsigned __user *featp,
-		    lstcon_ndlist_ent_t __user *ndinfo_up,
+		    struct lstcon_ndlist_ent __user *ndinfo_up,
 		    char __user *name_up, int len)
 {
-	lstcon_ndlist_ent_t *entp;
+	struct lstcon_ndlist_ent *entp;
 	struct lstcon_ndlink *ndl;
 	int rc = 0;
 
diff --git a/drivers/staging/lustre/lnet/selftest/console.h b/drivers/staging/lustre/lnet/selftest/console.h
index f6cc694..30d73b6 100644
--- a/drivers/staging/lustre/lnet/selftest/console.h
+++ b/drivers/staging/lustre/lnet/selftest/console.h
@@ -194,7 +194,7 @@ struct lstcon_session {
 int lstcon_session_new(char *name, int key, unsigned int version,
 		       int timeout, int flags, struct lst_sid __user *sid_up);
 int lstcon_session_info(struct lst_sid __user *sid_up, int __user *key,
-			unsigned __user *verp, lstcon_ndlist_ent_t __user *entp,
+			unsigned __user *verp, struct lstcon_ndlist_ent __user *entp,
 			char __user *name_up, int len);
 int lstcon_session_end(void);
 int lstcon_session_debug(int timeout, struct list_head __user *result_up);
@@ -213,7 +213,7 @@ int lstcon_nodes_add(char *name, int nnd, lnet_process_id_t __user *nds_up,
 		     unsigned int *featp, struct list_head __user *result_up);
 int lstcon_nodes_remove(char *name, int nnd, lnet_process_id_t __user *nds_up,
 			struct list_head __user *result_up);
-int lstcon_group_info(char *name, lstcon_ndlist_ent_t __user *gent_up,
+int lstcon_group_info(char *name, struct lstcon_ndlist_ent __user *gent_up,
 		      int *index_p, int *ndent_p,
 		      struct lstcon_node_ent __user *ndents_up);
 int lstcon_group_list(int idx, int len, char __user *name_up);
-- 
1.8.3.1
