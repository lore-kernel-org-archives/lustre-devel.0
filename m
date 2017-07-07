From: Craig Inches <Craig@craiginches.com>
Date: Fri, 07 Jul 2017 01:47:04 +0000 (UTC)
Subject: [lustre-devel] [PATCH 3/4] Staging: Lustre Fixing multiline block
 comments in lnetst.h
In-Reply-To: <cover.1499388016.git.Craig@craiginches.com>
References: <cover.1499388016.git.Craig@craiginches.com>
Message-ID: <dea8ec86c52eb0f89a75774953af127b7e7a7e64.1499388016.git.Craig@craiginches.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

This fixes multiple block statements found not to match
style as per checkpatch

Signed-off-by: Craig Inches <Craig@craiginches.com>
---
 drivers/staging/lustre/include/linux/lnet/lnetst.h | 129 +++++++++++++--------
 1 file changed, 81 insertions(+), 48 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lnetst.h b/drivers/staging/lustre/include/linux/lnet/lnetst.h
index ea736f8d5231..a4f9ff01d458 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -54,7 +54,8 @@
 #define LSTIO_GROUP_ADD		0xC10	/* add group */
 #define LSTIO_GROUP_LIST	0xC11	/* list all groups in session */
 #define LSTIO_GROUP_INFO	0xC12	/* query default information of
-					 * specified group */
+					 * specified group
+					 */
 #define LSTIO_GROUP_DEL		0xC13	/* delete group */
 #define LSTIO_NODES_ADD		0xC14	/* add nodes to specified group */
 #define LSTIO_GROUP_UPDATE      0xC15	/* update group */
@@ -102,27 +103,32 @@ struct lstcon_test_ent {
 	int	tse_type;       /* test type */
 	int	tse_loop;       /* loop count */
 	int	tse_concur;     /* concurrency of test */
-};				/*** test summary entry, for
-				 *** list_batch command */
+};				/* test summary entry, for
+				 * list_batch command
+				 */
 
 struct lstcon_batch_ent {
 	int	bae_state;	/* batch status */
 	int	bae_timeout;	/* batch timeout */
 	int	bae_ntest;	/* # of tests in the batch */
-};				/*** batch summary entry, for
-				 *** list_batch command */
+};				/* batch summary entry, for
+				 * list_batch command
+				 */
 
 struct lstcon_test_batch_ent {
 	struct lstcon_ndlist_ent   tbe_cli_nle;	/* client (group) node_list
-						 * entry */
+						 * entry
+						 */
 	struct lstcon_ndlist_ent   tbe_srv_nle;	/* server (group) node_list
-						 * entry */
+						 * entry
+						 */
 	union {
 		struct lstcon_test_ent	tbe_test; /* test entry */
 		struct lstcon_batch_ent tbe_batch;/* batch entry */
 	} u;
-};				/*** test/batch verbose information entry,
-				 *** for list_batch command */
+};				/* test/batch verbose information entry,
+				 * for list_batch command
+				 */
 
 struct lstcon_rpc_ent {
 	struct list_head	rpe_link;	/* link chain */
@@ -138,10 +144,10 @@ struct lstcon_rpc_ent {
 };
 
 struct lstcon_trans_stat {
-	int	trs_rpc_stat[4];	/* RPCs stat (0: total
-						      1: failed
-						      2: finished
-						      4: reserved */
+	int	trs_rpc_stat[4];	/* RPCs stat (0: total 1: failed
+					 * 2: finished
+					 * 4: reserved
+					 */
 	int	trs_rpc_errno;		/* RPC errno */
 	int	trs_fwk_stat[8];	/* framework stat */
 	int	trs_fwk_errno;		/* errno of the first remote error */
@@ -275,22 +281,28 @@ struct lstio_session_end_args {
 struct lstio_debug_args {
 	int			 lstio_dbg_key;		/* IN: session key */
 	int			 lstio_dbg_type;	/* IN: debug
-								session|batch|
-								group|nodes
-								list */
+							 * session|batch|
+							 * group|nodes list
+							 */
 	int			 lstio_dbg_flags;	/* IN: reserved debug
-							       flags */
+							 * flags
+							 */
 	int			 lstio_dbg_timeout;	/* IN: timeout of
-							       debug */
+							 * debug
+							 */
 	int			 lstio_dbg_nmlen;	/* IN: len of name */
 	char __user		*lstio_dbg_namep;	/* IN: name of
-							       group|batch */
+							 * group|batch
+							 */
 	int			 lstio_dbg_count;	/* IN: # of test nodes
-							       to debug */
+							 * to debug
+							 */
 	struct lnet_process_id __user *lstio_dbg_idsp;	/* IN: id of test
-							       nodes */
+							 * nodes
+							 */
 	struct list_head __user	*lstio_dbg_resultp;	/* OUT: list head of
-								result buffer */
+							 * result buffer
+							 */
 };
 
 struct lstio_group_add_args {
@@ -307,7 +319,8 @@ struct lstio_group_del_args {
 
 #define LST_GROUP_CLEAN		1	/* remove inactive nodes in the group */
 #define LST_GROUP_REFRESH	2	/* refresh inactive nodes
-					 * in the group */
+					 * in the group
+					 */
 #define LST_GROUP_RMND		3	/* delete nodes from the group */
 
 struct lstio_group_update_args {
@@ -319,7 +332,8 @@ struct lstio_group_update_args {
 	int			 lstio_grp_count;	/* IN: # of nodes id */
 	struct lnet_process_id __user *lstio_grp_idsp;	/* IN: array of nodes */
 	struct list_head __user	*lstio_grp_resultp;	/* OUT: list head of
-								result buffer */
+							 * result buffer
+							 */
 };
 
 struct lstio_group_nodes_args {
@@ -331,7 +345,8 @@ struct lstio_group_nodes_args {
 	unsigned int __user	*lstio_grp_featp;
 	struct lnet_process_id __user *lstio_grp_idsp;	/* IN: nodes */
 	struct list_head __user	*lstio_grp_resultp;	/* OUT: list head of
-								result buffer */
+							 * result buffer
+							 */
 };
 
 struct lstio_group_list_args {
@@ -345,8 +360,9 @@ struct lstio_group_info_args {
 	int			 lstio_grp_key;		/* IN: session key */
 	int			 lstio_grp_nmlen;	/* IN: name len */
 	char __user		*lstio_grp_namep;	/* IN: name */
-	struct lstcon_ndlist_ent __user *lstio_grp_entp;/* OUT: description of
-							   group */
+	struct lstcon_ndlist_ent __user *lstio_grp_entp;/* OUT: description
+							 * of group
+							 */
 	int __user		*lstio_grp_idxp;	/* IN/OUT: node index */
 	int __user		*lstio_grp_ndentp;	/* IN/OUT: # of nodent */
 	struct lstcon_node_ent __user *lstio_grp_dentsp;/* OUT: nodent array */
@@ -369,34 +385,41 @@ struct lstio_batch_del_args {
 struct lstio_batch_run_args {
 	int			 lstio_bat_key;		/* IN: session key */
 	int			 lstio_bat_timeout;	/* IN: timeout for
-							       the batch */
+							 * the batch
+							 */
 	int			 lstio_bat_nmlen;	/* IN: name length */
 	char __user		*lstio_bat_namep;	/* IN: batch name */
 	struct list_head __user	*lstio_bat_resultp;	/* OUT: list head of
-								result buffer */
+							 * result buffer
+							 */
 };
 
 struct lstio_batch_stop_args {
 	int			 lstio_bat_key;		/* IN: session key */
 	int			 lstio_bat_force;	/* IN: abort unfinished
-							       test RPC */
+							 * test RPC
+							 */
 	int			 lstio_bat_nmlen;	/* IN: name length */
 	char __user		*lstio_bat_namep;	/* IN: batch name */
 	struct list_head __user	*lstio_bat_resultp;	/* OUT: list head of
-								result buffer */
+							 * result buffer
+							 */
 };
 
 struct lstio_batch_query_args {
 	int			 lstio_bat_key;		/* IN: session key */
 	int			 lstio_bat_testidx;	/* IN: test index */
 	int			 lstio_bat_client;	/* IN: we testing
-							       client? */
+							 * client?
+							 */
 	int			 lstio_bat_timeout;	/* IN: timeout for
-							       waiting */
+							 * waiting
+							 */
 	int			 lstio_bat_nmlen;	/* IN: name length */
 	char __user		*lstio_bat_namep;	/* IN: batch name */
 	struct list_head __user	*lstio_bat_resultp;	/* OUT: list head of
-								result buffer */
+							 * result buffer
+							 */
 };
 
 struct lstio_batch_list_args {
@@ -411,7 +434,8 @@ struct lstio_batch_info_args {
 	int			 lstio_bat_nmlen;	/* IN: name length */
 	char __user		*lstio_bat_namep;	/* IN: name */
 	int			 lstio_bat_server;	/* IN: query server
-							       or not */
+							 * or not
+							 */
 	int			 lstio_bat_testidx;	/* IN: test index */
 	struct lstcon_test_batch_ent __user *lstio_bat_entp;/* OUT: batch ent */
 
@@ -424,14 +448,17 @@ struct lstio_batch_info_args {
 struct lstio_stat_args {
 	int			 lstio_sta_key;		/* IN: session key */
 	int			 lstio_sta_timeout;	/* IN: timeout for
-							       stat request */
+							 * stat request
+							 */
 	int			 lstio_sta_nmlen;	/* IN: group name
-							       length */
+							 * length
+							 */
 	char __user		*lstio_sta_namep;	/* IN: group name */
 	int			 lstio_sta_count;	/* IN: # of pid */
 	struct lnet_process_id __user *lstio_sta_idsp;	/* IN: pid */
 	struct list_head __user	*lstio_sta_resultp;	/* OUT: list head of
-								result buffer */
+							 * result buffer
+							 */
 };
 
 enum lst_test_type {
@@ -452,26 +479,32 @@ struct lstio_test_args {
 	int		  lstio_tes_concur;	/* IN: concurrency */
 
 	int		  lstio_tes_dist;	/* IN: node distribution in
-						       destination groups */
+						 * destination groups
+						 */
 	int		  lstio_tes_span;	/* IN: node span in
-						       destination groups */
+						 * destination groups
+						 */
 	int		  lstio_tes_sgrp_nmlen;	/* IN: source group
-						       name length */
+						 * name length
+						 */
 	char __user	 *lstio_tes_sgrp_name;	/* IN: group name */
 	int		  lstio_tes_dgrp_nmlen;	/* IN: destination group
-						       name length */
+						 * name length
+						 */
 	char __user	 *lstio_tes_dgrp_name;	/* IN: group name */
 
 	int		  lstio_tes_param_len;	/* IN: param buffer len */
 	void __user	 *lstio_tes_param;	/* IN: parameter for specified
-						       test:
-						       lstio_bulk_param_t,
-						       lstio_ping_param_t,
-						       ... more */
+						 * test: lstio_bulk_param_t,
+						 * lstio_ping_param_t,
+						 * ... more
+						 */
 	int __user	 *lstio_tes_retp;	/* OUT: private returned
-							value */
+						 * value
+						 */
 	struct list_head __user *lstio_tes_resultp;/* OUT: list head of
-							result buffer */
+						    * result buffer
+						    */
 };
 
 enum lst_brw_type {
-- 
2.13.0
