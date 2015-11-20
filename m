From: James Simmons <jsimmons@infradead.org>
Date: Fri, 20 Nov 2015 18:35:53 -0500
Subject: [lustre-devel] [PATCH 17/40] staging: lustre: add sparse annotation
	__user wherever needed for lnet
In-Reply-To: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1448062576-23757-18-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: frank zago <fzago@cray.com>

This fixes sparse warnings such as:

   .../api-ni.c:1639:33: warning: incorrect type in argument 3
                                 (different address spaces)
   .../api-ni.c:1639:33: expected struct lnet_process_id_t
                                 [noderef] [usertype] <asn:1>*ids
   .../api-ni.c:1639:33: got struct lnet_process_id_t
                                 [usertype] *<noident>

There is no code change.

Signed-off-by: frank zago <fzago@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5396
Reviewed-on: http://review.whamcloud.com/11819
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |    9 +-
 drivers/staging/lustre/include/linux/lnet/lnetst.h |   96 ++++++++++----------
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    5 +-
 drivers/staging/lustre/lnet/selftest/conrpc.c      |    4 +-
 drivers/staging/lustre/lnet/selftest/conrpc.h      |    5 +-
 drivers/staging/lustre/lnet/selftest/console.c     |   91 ++++++++++---------
 drivers/staging/lustre/lnet/selftest/console.h     |   54 ++++++-----
 7 files changed, 140 insertions(+), 124 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 874af17..a1f94db 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -602,7 +602,7 @@ void lnet_copy_kiov2kiov(unsigned int ndkiov, lnet_kiov_t *dkiov,
 			  unsigned int soffset, unsigned int nob);
 
 static inline void
-lnet_copy_iov2flat(int dlen, void *dest, unsigned int doffset,
+lnet_copy_iov2flat(int dlen, void __user *dest, unsigned int doffset,
 		   unsigned int nsiov, struct kvec *siov, unsigned int soffset,
 		   unsigned int nob)
 {
@@ -613,7 +613,7 @@ lnet_copy_iov2flat(int dlen, void *dest, unsigned int doffset,
 }
 
 static inline void
-lnet_copy_kiov2flat(int dlen, void *dest, unsigned int doffset,
+lnet_copy_kiov2flat(int dlen, void __user *dest, unsigned int doffset,
 		    unsigned int nsiov, lnet_kiov_t *skiov,
 		    unsigned int soffset, unsigned int nob)
 {
@@ -625,7 +625,8 @@ lnet_copy_kiov2flat(int dlen, void *dest, unsigned int doffset,
 
 static inline void
 lnet_copy_flat2iov(unsigned int ndiov, struct kvec *diov, unsigned int doffset,
-		   int slen, void *src, unsigned int soffset, unsigned int nob)
+		   int slen, void __user *src, unsigned int soffset,
+		   unsigned int nob)
 {
 	struct kvec siov = {/*.iov_base = */ src, /*.iov_len = */slen};
 
@@ -635,7 +636,7 @@ lnet_copy_flat2iov(unsigned int ndiov, struct kvec *diov, unsigned int doffset,
 
 static inline void
 lnet_copy_flat2kiov(unsigned int ndiov, lnet_kiov_t *dkiov,
-		    unsigned int doffset, int slen, void *src,
+		    unsigned int doffset, int slen, void __user *src,
 		    unsigned int soffset, unsigned int nob)
 {
 	struct kvec siov = {/* .iov_base = */ src, /* .iov_len = */ slen};
diff --git a/drivers/staging/lustre/include/linux/lnet/lnetst.h b/drivers/staging/lustre/include/linux/lnet/lnetst.h
index fd1e0fd..fc183f8 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -245,20 +245,20 @@ typedef struct {
 	int		 lstio_ses_force;	/* IN: force create ? */
 	/** IN: session features */
 	unsigned	 lstio_ses_feats;
-	lst_sid_t	*lstio_ses_idp;		/* OUT: session id */
+	lst_sid_t __user	*lstio_ses_idp;		/* OUT: session id */
 	int		 lstio_ses_nmlen;	/* IN: name length */
-	char		*lstio_ses_namep;	/* IN: session name */
+	char __user		*lstio_ses_namep;	/* IN: session name */
 } lstio_session_new_args_t;
 
 /* query current session */
 typedef struct {
-	lst_sid_t		*lstio_ses_idp;		/* OUT: session id */
-	int			*lstio_ses_keyp;	/* OUT: local key */
+	lst_sid_t __user		*lstio_ses_idp;		/* OUT: session id */
+	int __user			*lstio_ses_keyp;	/* OUT: local key */
 	/** OUT: session features */
-	unsigned		*lstio_ses_featp;
-	lstcon_ndlist_ent_t	*lstio_ses_ndinfo;	/* OUT: */
+	unsigned __user			*lstio_ses_featp;
+	lstcon_ndlist_ent_t __user	*lstio_ses_ndinfo;	/* OUT: */
 	int			 lstio_ses_nmlen;	/* IN: name length */
-	char			*lstio_ses_namep;	/* OUT: session name */
+	char __user			*lstio_ses_namep;	/* OUT: session name */
 } lstio_session_info_args_t;
 
 /* delete a session */
@@ -283,26 +283,26 @@ typedef struct {
 	int			 lstio_dbg_timeout;	/* IN: timeout of
 							       debug */
 	int			 lstio_dbg_nmlen;	/* IN: len of name */
-	char			*lstio_dbg_namep;	/* IN: name of
+	char __user			*lstio_dbg_namep;	/* IN: name of
 							       group|batch */
 	int			 lstio_dbg_count;	/* IN: # of test nodes
 							       to debug */
-	lnet_process_id_t	*lstio_dbg_idsp;	/* IN: id of test
+	lnet_process_id_t __user	*lstio_dbg_idsp;	/* IN: id of test
 							       nodes */
-	struct list_head	*lstio_dbg_resultp;	/* OUT: list head of
+	struct list_head __user		*lstio_dbg_resultp;	/* OUT: list head of
 								result buffer */
 } lstio_debug_args_t;
 
 typedef struct {
 	int	 lstio_grp_key;		/* IN: session key */
 	int	 lstio_grp_nmlen;	/* IN: name length */
-	char	*lstio_grp_namep;	/* IN: group name */
+	char __user			*lstio_grp_namep;	/* IN: group name */
 } lstio_group_add_args_t;
 
 typedef struct {
 	int	 lstio_grp_key;		/* IN: session key */
 	int	 lstio_grp_nmlen;	/* IN: name length */
-	char	*lstio_grp_namep;	/* IN: group name */
+	char __user			*lstio_grp_namep;	/* IN: group name */
 } lstio_group_del_args_t;
 
 #define LST_GROUP_CLEAN		1	/* remove inactive nodes in the group */
@@ -315,22 +315,22 @@ typedef struct {
 	int			 lstio_grp_opc;		/* IN: OPC */
 	int			 lstio_grp_args;	/* IN: arguments */
 	int			 lstio_grp_nmlen;	/* IN: name length */
-	char			*lstio_grp_namep;	/* IN: group name */
+	char __user			*lstio_grp_namep;	/* IN: group name */
 	int			 lstio_grp_count;	/* IN: # of nodes id */
-	lnet_process_id_t	*lstio_grp_idsp;	/* IN: array of nodes */
-	struct list_head	*lstio_grp_resultp;	/* OUT: list head of
+	lnet_process_id_t __user	*lstio_grp_idsp;	/* IN: array of nodes */
+	struct list_head __user		*lstio_grp_resultp;	/* OUT: list head of
 								result buffer */
 } lstio_group_update_args_t;
 
 typedef struct {
 	int			 lstio_grp_key;		/* IN: session key */
 	int			 lstio_grp_nmlen;	/* IN: name length */
-	char			*lstio_grp_namep;	/* IN: group name */
+	char __user			*lstio_grp_namep;	/* IN: group name */
 	int			 lstio_grp_count;	/* IN: # of nodes */
 	/** OUT: session features */
-	unsigned		*lstio_grp_featp;
-	lnet_process_id_t	*lstio_grp_idsp;	/* IN: nodes */
-	struct list_head	*lstio_grp_resultp;	/* OUT: list head of
+	unsigned __user			*lstio_grp_featp;
+	lnet_process_id_t __user	*lstio_grp_idsp;	/* IN: nodes */
+	struct list_head __user		*lstio_grp_resultp;	/* OUT: list head of
 								result buffer */
 } lstio_group_nodes_args_t;
 
@@ -338,18 +338,18 @@ typedef struct {
 	int	 lstio_grp_key;		/* IN: session key */
 	int	 lstio_grp_idx;		/* IN: group idx */
 	int	 lstio_grp_nmlen;	/* IN: name len */
-	char	*lstio_grp_namep;	/* OUT: name */
+	char __user			*lstio_grp_namep;	/* OUT: name */
 } lstio_group_list_args_t;
 
 typedef struct {
 	int			 lstio_grp_key;		/* IN: session key */
 	int			 lstio_grp_nmlen;	/* IN: name len */
-	char			*lstio_grp_namep;	/* IN: name */
-	lstcon_ndlist_ent_t	*lstio_grp_entp;	/* OUT: description of
+	char __user			*lstio_grp_namep;	/* IN: name */
+	lstcon_ndlist_ent_t __user	*lstio_grp_entp;	/* OUT: description of
 								group */
-	int			*lstio_grp_idxp;	/* IN/OUT: node index */
-	int			*lstio_grp_ndentp;	/* IN/OUT: # of nodent */
-	lstcon_node_ent_t	*lstio_grp_dentsp;	/* OUT: nodent array */
+	int __user			*lstio_grp_idxp;	/* IN/OUT: node index */
+	int __user			*lstio_grp_ndentp;	/* IN/OUT: # of nodent */
+	lstcon_node_ent_t __user	*lstio_grp_dentsp;	/* OUT: nodent array */
 } lstio_group_info_args_t;
 
 #define LST_DEFAULT_BATCH	"batch"			/* default batch name */
@@ -357,13 +357,13 @@ typedef struct {
 typedef struct {
 	int	 lstio_bat_key;		/* IN: session key */
 	int	 lstio_bat_nmlen;	/* IN: name length */
-	char	*lstio_bat_namep;	/* IN: batch name */
+	char __user			*lstio_bat_namep;	/* IN: batch name */
 } lstio_batch_add_args_t;
 
 typedef struct {
 	int	 lstio_bat_key;		/* IN: session key */
 	int	 lstio_bat_nmlen;	/* IN: name length */
-	char	*lstio_bat_namep;	/* IN: batch name */
+	char __user		*lstio_bat_namep;	/* IN: batch name */
 } lstio_batch_del_args_t;
 
 typedef struct {
@@ -371,8 +371,8 @@ typedef struct {
 	int			 lstio_bat_timeout;	/* IN: timeout for
 							       the batch */
 	int			 lstio_bat_nmlen;	/* IN: name length */
-	char			*lstio_bat_namep;	/* IN: batch name */
-	struct list_head	*lstio_bat_resultp;	/* OUT: list head of
+	char __user		*lstio_bat_namep;	/* IN: batch name */
+	struct list_head __user	*lstio_bat_resultp;	/* OUT: list head of
 								result buffer */
 } lstio_batch_run_args_t;
 
@@ -381,8 +381,8 @@ typedef struct {
 	int			 lstio_bat_force;	/* IN: abort unfinished
 							       test RPC */
 	int			 lstio_bat_nmlen;	/* IN: name length */
-	char			*lstio_bat_namep;	/* IN: batch name */
-	struct list_head	*lstio_bat_resultp;	/* OUT: list head of
+	char __user		*lstio_bat_namep;	/* IN: batch name */
+	struct list_head __user	*lstio_bat_resultp;	/* OUT: list head of
 								result buffer */
 } lstio_batch_stop_args_t;
 
@@ -394,8 +394,8 @@ typedef struct {
 	int			 lstio_bat_timeout;	/* IN: timeout for
 							       waiting */
 	int			 lstio_bat_nmlen;	/* IN: name length */
-	char			*lstio_bat_namep;	/* IN: batch name */
-	struct list_head	*lstio_bat_resultp;	/* OUT: list head of
+	char __user		*lstio_bat_namep;	/* IN: batch name */
+	struct list_head __user	*lstio_bat_resultp;	/* OUT: list head of
 								result buffer */
 } lstio_batch_query_args_t;
 
@@ -403,21 +403,21 @@ typedef struct {
 	int	 lstio_bat_key;		/* IN: session key */
 	int	 lstio_bat_idx;		/* IN: index */
 	int	 lstio_bat_nmlen;	/* IN: name length */
-	char	*lstio_bat_namep;	/* IN: batch name */
+	char __user		*lstio_bat_namep;	/* IN: batch name */
 } lstio_batch_list_args_t;
 
 typedef struct {
 	int			 lstio_bat_key;		/* IN: session key */
 	int			 lstio_bat_nmlen;	/* IN: name length */
-	char			*lstio_bat_namep;	/* IN: name */
+	char __user			*lstio_bat_namep;	/* IN: name */
 	int			 lstio_bat_server;	/* IN: query server
 							       or not */
 	int			 lstio_bat_testidx;	/* IN: test index */
-	lstcon_test_batch_ent_t	*lstio_bat_entp;	/* OUT: batch ent */
+	lstcon_test_batch_ent_t	__user	*lstio_bat_entp;	/* OUT: batch ent */
 
-	int			*lstio_bat_idxp;	/* IN/OUT: index of node */
-	int			*lstio_bat_ndentp;	/* IN/OUT: # of nodent */
-	lstcon_node_ent_t	*lstio_bat_dentsp;	/* array of nodent */
+	int __user			*lstio_bat_idxp;	/* IN/OUT: index of node */
+	int __user			*lstio_bat_ndentp;	/* IN/OUT: # of nodent */
+	lstcon_node_ent_t __user	*lstio_bat_dentsp;	/* array of nodent */
 } lstio_batch_info_args_t;
 
 /* add stat in session */
@@ -427,10 +427,10 @@ typedef struct {
 							       stat request */
 	int			 lstio_sta_nmlen;	/* IN: group name
 							       length */
-	char			*lstio_sta_namep;	/* IN: group name */
+	char __user			*lstio_sta_namep;	/* IN: group name */
 	int			 lstio_sta_count;	/* IN: # of pid */
-	lnet_process_id_t	*lstio_sta_idsp;	/* IN: pid */
-	struct list_head	*lstio_sta_resultp;	/* OUT: list head of
+	lnet_process_id_t __user	*lstio_sta_idsp;	/* IN: pid */
+	struct list_head __user		*lstio_sta_resultp;	/* OUT: list head of
 								result buffer */
 } lstio_stat_args_t;
 
@@ -445,7 +445,7 @@ typedef enum {
 typedef struct {
 	int		  lstio_tes_key;	/* IN: session key */
 	int		  lstio_tes_bat_nmlen;	/* IN: batch name len */
-	char		 *lstio_tes_bat_name;	/* IN: batch name */
+	char __user		 *lstio_tes_bat_name;	/* IN: batch name */
 	int		  lstio_tes_type;	/* IN: test type */
 	int		  lstio_tes_oneside;	/* IN: one sided test */
 	int		  lstio_tes_loop;	/* IN: loop count */
@@ -457,20 +457,20 @@ typedef struct {
 						       destination groups */
 	int		  lstio_tes_sgrp_nmlen;	/* IN: source group
 						       name length */
-	char		 *lstio_tes_sgrp_name;	/* IN: group name */
+	char __user		 *lstio_tes_sgrp_name;	/* IN: group name */
 	int		  lstio_tes_dgrp_nmlen;	/* IN: destination group
 						       name length */
-	char		 *lstio_tes_dgrp_name;	/* IN: group name */
+	char __user		 *lstio_tes_dgrp_name;	/* IN: group name */
 
 	int		  lstio_tes_param_len;	/* IN: param buffer len */
-	void		 *lstio_tes_param;	/* IN: parameter for specified
+	void __user		 *lstio_tes_param;	/* IN: parameter for specified
 						       test:
 						       lstio_bulk_param_t,
 						       lstio_ping_param_t,
 						       ... more */
-	int		 *lstio_tes_retp;	/* OUT: private returned
+	int __user		*lstio_tes_retp;	/* OUT: private returned
 							value */
-	struct list_head *lstio_tes_resultp;	/* OUT: list head of
+	struct list_head __user	*lstio_tes_resultp;	/* OUT: list head of
 							result buffer */
 } lstio_test_args_t;
 
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 3b2bfd5..acc216e 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1982,7 +1982,7 @@ LNetCtl(unsigned int cmd, void *arg)
 		id.nid = data->ioc_nid;
 		id.pid = data->ioc_u32[0];
 		rc = lnet_ping(id, data->ioc_u32[1], /* timeout */
-			       (lnet_process_id_t *)data->ioc_pbuf1,
+			       (lnet_process_id_t __user *)data->ioc_pbuf1,
 			       data->ioc_plen1/sizeof(lnet_process_id_t));
 		if (rc < 0)
 			return rc;
@@ -2085,7 +2085,8 @@ LNetSnprintHandle(char *str, int len, lnet_handle_any_t h)
 EXPORT_SYMBOL(LNetSnprintHandle);
 
 static int
-lnet_ping(lnet_process_id_t id, int timeout_ms, lnet_process_id_t *ids, int n_ids)
+lnet_ping(lnet_process_id_t id, int timeout_ms, lnet_process_id_t __user *ids,
+	  int n_ids)
 {
 	lnet_handle_eq_t eqh;
 	lnet_handle_md_t mdh;
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index 1066c70..15a61de 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -466,11 +466,11 @@ lstcon_rpc_trans_stat(lstcon_rpc_trans_t *trans, lstcon_trans_stat_t *stat)
 
 int
 lstcon_rpc_trans_interpreter(lstcon_rpc_trans_t *trans,
-			     struct list_head *head_up,
+			     struct list_head __user *head_up,
 			     lstcon_rpc_readent_func_t readent)
 {
 	struct list_head tmp;
-	struct list_head *next;
+	struct list_head __user *next;
 	lstcon_rpc_ent_t *ent;
 	srpc_generic_reply_t *rep;
 	lstcon_rpc_t *crpc;
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.h b/drivers/staging/lustre/lnet/selftest/conrpc.h
index 95c832f..d2133bc 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.h
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.h
@@ -106,7 +106,8 @@ typedef struct lstcon_rpc_trans {
 #define LST_TRANS_STATQRY       0x21
 
 typedef int (*lstcon_rpc_cond_func_t)(int, struct lstcon_node *, void *);
-typedef int (*lstcon_rpc_readent_func_t)(int, srpc_msg_t *, lstcon_rpc_ent_t *);
+typedef int (*lstcon_rpc_readent_func_t)(int, srpc_msg_t *,
+					 lstcon_rpc_ent_t __user *);
 
 int  lstcon_sesrpc_prep(struct lstcon_node *nd, int transop,
 			unsigned version, lstcon_rpc_t **crpc);
@@ -128,7 +129,7 @@ int  lstcon_rpc_trans_ndlist(struct list_head *ndlist,
 void lstcon_rpc_trans_stat(lstcon_rpc_trans_t *trans,
 			   lstcon_trans_stat_t *stat);
 int  lstcon_rpc_trans_interpreter(lstcon_rpc_trans_t *trans,
-				  struct list_head *head_up,
+				  struct list_head __user *head_up,
 				  lstcon_rpc_readent_func_t readent);
 void lstcon_rpc_trans_abort(lstcon_rpc_trans_t *trans, int error);
 void lstcon_rpc_trans_destroy(lstcon_rpc_trans_t *trans);
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 898912b..f8d6dfe 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -363,7 +363,7 @@ lstcon_sesrpc_condition(int transop, lstcon_node_t *nd, void *arg)
 
 static int
 lstcon_sesrpc_readent(int transop, srpc_msg_t *msg,
-		      lstcon_rpc_ent_t *ent_up)
+		      lstcon_rpc_ent_t __user *ent_up)
 {
 	srpc_debug_reply_t *rep;
 
@@ -392,8 +392,8 @@ lstcon_sesrpc_readent(int transop, srpc_msg_t *msg,
 
 static int
 lstcon_group_nodes_add(lstcon_group_t *grp,
-		       int count, lnet_process_id_t *ids_up,
-		       unsigned *featp, struct list_head *result_up)
+		       int count, lnet_process_id_t __user *ids_up,
+		       unsigned *featp, struct list_head __user *result_up)
 {
 	lstcon_rpc_trans_t *trans;
 	lstcon_ndlink_t *ndl;
@@ -459,8 +459,8 @@ lstcon_group_nodes_add(lstcon_group_t *grp,
 
 static int
 lstcon_group_nodes_remove(lstcon_group_t *grp,
-			  int count, lnet_process_id_t *ids_up,
-			  struct list_head *result_up)
+			  int count, lnet_process_id_t __user *ids_up,
+			  struct list_head __user *result_up)
 {
 	lstcon_rpc_trans_t *trans;
 	lstcon_ndlink_t *ndl;
@@ -537,8 +537,8 @@ lstcon_group_add(char *name)
 }
 
 int
-lstcon_nodes_add(char *name, int count, lnet_process_id_t *ids_up,
-		 unsigned *featp, struct list_head *result_up)
+lstcon_nodes_add(char *name, int count, lnet_process_id_t __user *ids_up,
+		 unsigned *featp, struct list_head __user *result_up)
 {
 	lstcon_group_t *grp;
 	int rc;
@@ -642,7 +642,8 @@ lstcon_group_clean(char *name, int args)
 
 int
 lstcon_nodes_remove(char *name, int count,
-		    lnet_process_id_t *ids_up, struct list_head *result_up)
+		    lnet_process_id_t __user *ids_up,
+		    struct list_head __user *result_up)
 {
 	lstcon_group_t *grp = NULL;
 	int rc;
@@ -671,7 +672,7 @@ lstcon_nodes_remove(char *name, int count,
 }
 
 int
-lstcon_group_refresh(char *name, struct list_head *result_up)
+lstcon_group_refresh(char *name, struct list_head __user *result_up)
 {
 	lstcon_rpc_trans_t *trans;
 	lstcon_group_t *grp;
@@ -732,7 +733,7 @@ lstcon_group_list(int index, int len, char *name_up)
 
 static int
 lstcon_nodes_getent(struct list_head *head, int *index_p,
-		    int *count_p, lstcon_node_ent_t *dents_up)
+		    int *count_p, lstcon_node_ent_t __user *dents_up)
 {
 	lstcon_ndlink_t *ndl;
 	lstcon_node_t *nd;
@@ -771,8 +772,9 @@ lstcon_nodes_getent(struct list_head *head, int *index_p,
 }
 
 int
-lstcon_group_info(char *name, lstcon_ndlist_ent_t *gents_p,
-		  int *index_p, int *count_p, lstcon_node_ent_t *dents_up)
+lstcon_group_info(char *name, lstcon_ndlist_ent_t __user *gents_p,
+		  int *index_p, int *count_p,
+		  lstcon_node_ent_t __user *dents_up)
 {
 	lstcon_ndlist_ent_t *gentp;
 	lstcon_group_t *grp;
@@ -910,9 +912,9 @@ lstcon_batch_list(int index, int len, char *name_up)
 }
 
 int
-lstcon_batch_info(char *name, lstcon_test_batch_ent_t *ent_up, int server,
-		  int testidx, int *index_p, int *ndent_p,
-		  lstcon_node_ent_t *dents_up)
+lstcon_batch_info(char *name, lstcon_test_batch_ent_t __user *ent_up,
+		  int server, int testidx, int *index_p, int *ndent_p,
+		  lstcon_node_ent_t __user *dents_up)
 {
 	lstcon_test_batch_ent_t *entp;
 	struct list_head *clilst;
@@ -1006,7 +1008,7 @@ lstcon_batrpc_condition(int transop, lstcon_node_t *nd, void *arg)
 
 static int
 lstcon_batch_op(lstcon_batch_t *bat, int transop,
-		struct list_head *result_up)
+		struct list_head __user *result_up)
 {
 	lstcon_rpc_trans_t *trans;
 	int rc;
@@ -1029,7 +1031,7 @@ lstcon_batch_op(lstcon_batch_t *bat, int transop,
 }
 
 int
-lstcon_batch_run(char *name, int timeout, struct list_head *result_up)
+lstcon_batch_run(char *name, int timeout, struct list_head __user *result_up)
 {
 	lstcon_batch_t *bat;
 	int rc;
@@ -1051,7 +1053,7 @@ lstcon_batch_run(char *name, int timeout, struct list_head *result_up)
 }
 
 int
-lstcon_batch_stop(char *name, int force, struct list_head *result_up)
+lstcon_batch_stop(char *name, int force, struct list_head __user *result_up)
 {
 	lstcon_batch_t *bat;
 	int rc;
@@ -1170,7 +1172,7 @@ lstcon_testrpc_condition(int transop, lstcon_node_t *nd, void *arg)
 }
 
 static int
-lstcon_test_nodes_add(lstcon_test_t *test, struct list_head *result_up)
+lstcon_test_nodes_add(lstcon_test_t *test, struct list_head __user *result_up)
 {
 	lstcon_rpc_trans_t *trans;
 	lstcon_group_t *grp;
@@ -1266,7 +1268,7 @@ lstcon_test_add(char *batch_name, int type, int loop,
 		int concur, int dist, int span,
 		char *src_name, char *dst_name,
 		void *param, int paramlen, int *retp,
-		struct list_head *result_up)
+		struct list_head __user *result_up)
 {
 	lstcon_test_t	 *test	 = NULL;
 	int		 rc;
@@ -1369,7 +1371,7 @@ lstcon_test_find(lstcon_batch_t *batch, int idx, lstcon_test_t **testpp)
 
 static int
 lstcon_tsbrpc_readent(int transop, srpc_msg_t *msg,
-		      lstcon_rpc_ent_t *ent_up)
+		      lstcon_rpc_ent_t __user *ent_up)
 {
 	srpc_batch_reply_t *rep = &msg->msg_body.bat_reply;
 
@@ -1386,7 +1388,7 @@ lstcon_tsbrpc_readent(int transop, srpc_msg_t *msg,
 
 int
 lstcon_test_batch_query(char *name, int testidx, int client,
-			int timeout, struct list_head *result_up)
+			int timeout, struct list_head __user *result_up)
 {
 	lstcon_rpc_trans_t *trans;
 	struct list_head *translist;
@@ -1448,19 +1450,21 @@ lstcon_test_batch_query(char *name, int testidx, int client,
 
 static int
 lstcon_statrpc_readent(int transop, srpc_msg_t *msg,
-		       lstcon_rpc_ent_t *ent_up)
+		       lstcon_rpc_ent_t __user *ent_up)
 {
 	srpc_stat_reply_t *rep = &msg->msg_body.stat_reply;
-	sfw_counters_t *sfwk_stat;
-	srpc_counters_t *srpc_stat;
-	lnet_counters_t *lnet_stat;
+	sfw_counters_t __user *sfwk_stat;
+	srpc_counters_t __user *srpc_stat;
+	lnet_counters_t __user *lnet_stat;
 
 	if (rep->str_status != 0)
 		return 0;
 
-	sfwk_stat = (sfw_counters_t *)&ent_up->rpe_payload[0];
-	srpc_stat = (srpc_counters_t *)((char *)sfwk_stat + sizeof(*sfwk_stat));
-	lnet_stat = (lnet_counters_t *)((char *)srpc_stat + sizeof(*srpc_stat));
+	sfwk_stat = (sfw_counters_t __user *)&ent_up->rpe_payload[0];
+	srpc_stat = (srpc_counters_t __user *)((char __user *)sfwk_stat +
+						sizeof(*sfwk_stat));
+	lnet_stat = (lnet_counters_t __user *)((char __user *)srpc_stat +
+						sizeof(*srpc_stat));
 
 	if (copy_to_user(sfwk_stat, &rep->str_fw, sizeof(*sfwk_stat)) ||
 	    copy_to_user(srpc_stat, &rep->str_rpc, sizeof(*srpc_stat)) ||
@@ -1472,7 +1476,7 @@ lstcon_statrpc_readent(int transop, srpc_msg_t *msg,
 
 static int
 lstcon_ndlist_stat(struct list_head *ndlist,
-		   int timeout, struct list_head *result_up)
+		   int timeout, struct list_head __user *result_up)
 {
 	struct list_head head;
 	lstcon_rpc_trans_t *trans;
@@ -1497,7 +1501,8 @@ lstcon_ndlist_stat(struct list_head *ndlist,
 }
 
 int
-lstcon_group_stat(char *grp_name, int timeout, struct list_head *result_up)
+lstcon_group_stat(char *grp_name, int timeout,
+		  struct list_head __user *result_up)
 {
 	lstcon_group_t *grp;
 	int rc;
@@ -1516,8 +1521,8 @@ lstcon_group_stat(char *grp_name, int timeout, struct list_head *result_up)
 }
 
 int
-lstcon_nodes_stat(int count, lnet_process_id_t *ids_up,
-		  int timeout, struct list_head *result_up)
+lstcon_nodes_stat(int count, lnet_process_id_t __user *ids_up,
+		  int timeout, struct list_head __user *result_up)
 {
 	lstcon_ndlink_t *ndl;
 	lstcon_group_t *tmp;
@@ -1562,7 +1567,7 @@ lstcon_nodes_stat(int count, lnet_process_id_t *ids_up,
 static int
 lstcon_debug_ndlist(struct list_head *ndlist,
 		    struct list_head *translist,
-		    int timeout, struct list_head *result_up)
+		    int timeout, struct list_head __user *result_up)
 {
 	lstcon_rpc_trans_t *trans;
 	int		 rc;
@@ -1584,7 +1589,7 @@ lstcon_debug_ndlist(struct list_head *ndlist,
 }
 
 int
-lstcon_session_debug(int timeout, struct list_head *result_up)
+lstcon_session_debug(int timeout, struct list_head __user *result_up)
 {
 	return lstcon_debug_ndlist(&console_session.ses_ndl_list,
 				   NULL, timeout, result_up);
@@ -1592,7 +1597,7 @@ lstcon_session_debug(int timeout, struct list_head *result_up)
 
 int
 lstcon_batch_debug(int timeout, char *name,
-		   int client, struct list_head *result_up)
+		   int client, struct list_head __user *result_up)
 {
 	lstcon_batch_t *bat;
 	int rc;
@@ -1610,7 +1615,7 @@ lstcon_batch_debug(int timeout, char *name,
 
 int
 lstcon_group_debug(int timeout, char *name,
-		   struct list_head *result_up)
+		   struct list_head __user *result_up)
 {
 	lstcon_group_t *grp;
 	int rc;
@@ -1628,8 +1633,8 @@ lstcon_group_debug(int timeout, char *name,
 
 int
 lstcon_nodes_debug(int timeout,
-		   int count, lnet_process_id_t *ids_up,
-		   struct list_head *result_up)
+		   int count, lnet_process_id_t __user *ids_up,
+		   struct list_head __user *result_up)
 {
 	lnet_process_id_t id;
 	lstcon_ndlink_t *ndl;
@@ -1693,7 +1698,7 @@ extern srpc_service_t lstcon_acceptor_service;
 
 int
 lstcon_session_new(char *name, int key, unsigned feats,
-		   int timeout, int force, lst_sid_t *sid_up)
+		   int timeout, int force, lst_sid_t __user *sid_up)
 {
 	int rc = 0;
 	int i;
@@ -1758,8 +1763,10 @@ lstcon_session_new(char *name, int key, unsigned feats,
 }
 
 int
-lstcon_session_info(lst_sid_t *sid_up, int *key_up, unsigned *featp,
-		    lstcon_ndlist_ent_t *ndinfo_up, char *name_up, int len)
+lstcon_session_info(lst_sid_t __user *sid_up, int __user *key_up,
+		    unsigned __user *featp,
+		    lstcon_ndlist_ent_t __user *ndinfo_up,
+		    char __user *name_up, int len)
 {
 	lstcon_ndlist_ent_t *entp;
 	lstcon_ndlink_t *ndl;
diff --git a/drivers/staging/lustre/lnet/selftest/console.h b/drivers/staging/lustre/lnet/selftest/console.h
index 7af3540..bab6557 100644
--- a/drivers/staging/lustre/lnet/selftest/console.h
+++ b/drivers/staging/lustre/lnet/selftest/console.h
@@ -187,47 +187,53 @@ int lstcon_console_init(void);
 int lstcon_console_fini(void);
 int lstcon_session_match(lst_sid_t sid);
 int lstcon_session_new(char *name, int key, unsigned version,
-		       int timeout, int flags, lst_sid_t *sid_up);
-int lstcon_session_info(lst_sid_t *sid_up, int *key, unsigned *verp,
-			lstcon_ndlist_ent_t *entp, char *name_up, int len);
+		       int timeout, int flags, lst_sid_t __user *sid_up);
+int lstcon_session_info(lst_sid_t __user *sid_up, int __user *key,
+			unsigned __user *verp,
+			lstcon_ndlist_ent_t __user *entp,
+			char __user *name_up, int len);
 int lstcon_session_end(void);
-int lstcon_session_debug(int timeout, struct list_head *result_up);
+int lstcon_session_debug(int timeout, struct list_head __user *result_up);
 int lstcon_session_feats_check(unsigned feats);
 int lstcon_batch_debug(int timeout, char *name,
-		       int client, struct list_head *result_up);
+		       int client, struct list_head __user *result_up);
 int lstcon_group_debug(int timeout, char *name,
-		       struct list_head *result_up);
-int lstcon_nodes_debug(int timeout, int nnd, lnet_process_id_t *nds_up,
-		       struct list_head *result_up);
+		       struct list_head __user *result_up);
+int lstcon_nodes_debug(int timeout, int nnd,
+		       lnet_process_id_t __user *nds_up,
+		       struct list_head __user *result_up);
 int lstcon_group_add(char *name);
 int lstcon_group_del(char *name);
 int lstcon_group_clean(char *name, int args);
-int lstcon_group_refresh(char *name, struct list_head *result_up);
-int lstcon_nodes_add(char *name, int nnd, lnet_process_id_t *nds_up,
-		     unsigned *featp, struct list_head *result_up);
-int lstcon_nodes_remove(char *name, int nnd, lnet_process_id_t *nds_up,
-			struct list_head *result_up);
-int lstcon_group_info(char *name, lstcon_ndlist_ent_t *gent_up,
-		      int *index_p, int *ndent_p, lstcon_node_ent_t *ndents_up);
+int lstcon_group_refresh(char *name, struct list_head __user *result_up);
+int lstcon_nodes_add(char *name, int nnd, lnet_process_id_t __user *nds_up,
+		     unsigned *featp, struct list_head __user *result_up);
+int lstcon_nodes_remove(char *name, int nnd, lnet_process_id_t __user *nds_up,
+			struct list_head __user *result_up);
+int lstcon_group_info(char *name, lstcon_ndlist_ent_t __user *gent_up,
+		      int *index_p, int *ndent_p,
+		      lstcon_node_ent_t __user *ndents_up);
 int lstcon_group_list(int idx, int len, char *name_up);
 int lstcon_batch_add(char *name);
-int lstcon_batch_run(char *name, int timeout, struct list_head *result_up);
-int lstcon_batch_stop(char *name, int force, struct list_head *result_up);
+int lstcon_batch_run(char *name, int timeout,
+		     struct list_head __user *result_up);
+int lstcon_batch_stop(char *name, int force,
+		      struct list_head __user *result_up);
 int lstcon_test_batch_query(char *name, int testidx,
 			    int client, int timeout,
-			    struct list_head *result_up);
+			    struct list_head __user *result_up);
 int lstcon_batch_del(char *name);
 int lstcon_batch_list(int idx, int namelen, char *name_up);
-int lstcon_batch_info(char *name, lstcon_test_batch_ent_t *ent_up,
+int lstcon_batch_info(char *name, lstcon_test_batch_ent_t __user *ent_up,
 		      int server, int testidx, int *index_p,
-		      int *ndent_p, lstcon_node_ent_t *dents_up);
+		      int *ndent_p, lstcon_node_ent_t __user *dents_up);
 int lstcon_group_stat(char *grp_name, int timeout,
-		      struct list_head *result_up);
-int lstcon_nodes_stat(int count, lnet_process_id_t *ids_up,
-		      int timeout, struct list_head *result_up);
+		      struct list_head __user *result_up);
+int lstcon_nodes_stat(int count, lnet_process_id_t __user *ids_up,
+		      int timeout, struct list_head __user *result_up);
 int lstcon_test_add(char *batch_name, int type, int loop,
 		    int concur, int dist, int span,
 		    char *src_name, char *dst_name,
 		    void *param, int paramlen, int *retp,
-		    struct list_head *result_up);
+		    struct list_head __user *result_up);
 #endif
-- 
1.7.1
