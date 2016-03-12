From: James Simmons <jsimmons@infradead.org>
Date: Fri, 11 Mar 2016 20:29:47 -0500
Subject: [lustre-devel] [PATCH 06/10] staging: lustre: filter remaining
	extra spacing for lnet selftest
In-Reply-To: <1457746191-27981-1-git-send-email-jsimmons@infradead.org>
References: <1457746191-27981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1457746191-27981-7-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

This patch is a result of a filter applied to the lnet selftest
code to remove the last bits of hidden white spaces.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/selftest/brw_test.c  |    6 +-
 drivers/staging/lustre/lnet/selftest/conctl.c    |   10 +-
 drivers/staging/lustre/lnet/selftest/conrpc.h    |   56 +++---
 drivers/staging/lustre/lnet/selftest/console.c   |    8 +-
 drivers/staging/lustre/lnet/selftest/console.h   |  116 +++++-----
 drivers/staging/lustre/lnet/selftest/framework.c |   86 ++++----
 drivers/staging/lustre/lnet/selftest/module.c    |    2 +-
 drivers/staging/lustre/lnet/selftest/ping_test.c |    2 +-
 drivers/staging/lustre/lnet/selftest/rpc.c       |   10 +-
 drivers/staging/lustre/lnet/selftest/rpc.h       |  178 ++++++++--------
 drivers/staging/lustre/lnet/selftest/selftest.h  |  250 +++++++++++-----------
 drivers/staging/lustre/lnet/selftest/timer.c     |    8 +-
 drivers/staging/lustre/lnet/selftest/timer.h     |    6 +-
 13 files changed, 369 insertions(+), 369 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
index 0d0c22c..eebc924 100644
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -131,9 +131,9 @@ brw_client_init(sfw_test_instance_t *tsi)
 	return 0;
 }
 
-#define BRW_POISON      0xbeefbeefbeefbeefULL
-#define BRW_MAGIC       0xeeb0eeb1eeb2eeb3ULL
-#define BRW_MSIZE       sizeof(__u64)
+#define BRW_POISON	0xbeefbeefbeefbeefULL
+#define BRW_MAGIC	0xeeb0eeb1eeb2eeb3ULL
+#define BRW_MSIZE	sizeof(__u64)
 
 static int
 brw_inject_one_error(void)
diff --git a/drivers/staging/lustre/lnet/selftest/conctl.c b/drivers/staging/lustre/lnet/selftest/conctl.c
index 9793bc6..872df72 100644
--- a/drivers/staging/lustre/lnet/selftest/conctl.c
+++ b/drivers/staging/lustre/lnet/selftest/conctl.c
@@ -100,7 +100,7 @@ lst_session_info_ioctl(lstio_session_info_args_t *args)
 	    !args->lstio_ses_featp || /* address for output features */
 	    !args->lstio_ses_ndinfo || /* address for output ndinfo */
 	    !args->lstio_ses_namep || /* address for output name */
-	    args->lstio_ses_nmlen  <= 0 ||
+	    args->lstio_ses_nmlen <= 0 ||
 	    args->lstio_ses_nmlen > LST_NAME_SIZE)
 		return -EINVAL;
 
@@ -297,7 +297,7 @@ lst_group_update_ioctl(lstio_group_update_args_t *args)
 		break;
 
 	case LST_GROUP_RMND:
-		if (args->lstio_grp_count  <= 0 ||
+		if (args->lstio_grp_count <= 0 ||
 		    !args->lstio_grp_idsp) {
 			rc = -EINVAL;
 			break;
@@ -368,7 +368,7 @@ lst_group_list_ioctl(lstio_group_list_args_t *args)
 	if (args->lstio_grp_key != console_session.ses_key)
 		return -EACCES;
 
-	if (args->lstio_grp_idx   < 0 ||
+	if (args->lstio_grp_idx < 0 ||
 	    !args->lstio_grp_namep ||
 	    args->lstio_grp_nmlen <= 0 ||
 	    args->lstio_grp_nmlen > LST_NAME_SIZE)
@@ -591,7 +591,7 @@ lst_batch_list_ioctl(lstio_batch_list_args_t *args)
 	if (args->lstio_bat_key != console_session.ses_key)
 		return -EACCES;
 
-	if (args->lstio_bat_idx   < 0 ||
+	if (args->lstio_bat_idx < 0 ||
 	    !args->lstio_bat_namep ||
 	    args->lstio_bat_nmlen <= 0 ||
 	    args->lstio_bat_nmlen > LST_NAME_SIZE)
@@ -755,7 +755,7 @@ static int lst_test_add_ioctl(lstio_test_args_t *args)
 		goto out;
 
 	LIBCFS_ALLOC(dst_name, args->lstio_tes_dgrp_nmlen + 1);
-	 if (!dst_name)
+	if (!dst_name)
 		goto out;
 
 	if (args->lstio_tes_param) {
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.h b/drivers/staging/lustre/lnet/selftest/conrpc.h
index d2133bc..3e7839d 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.h
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.h
@@ -51,12 +51,12 @@
 #include "selftest.h"
 
 /* Console rpc and rpc transaction */
-#define LST_TRANS_TIMEOUT       30
-#define LST_TRANS_MIN_TIMEOUT   3
+#define LST_TRANS_TIMEOUT	30
+#define LST_TRANS_MIN_TIMEOUT	3
 
 #define LST_VALIDATE_TIMEOUT(t) min(max(t, LST_TRANS_MIN_TIMEOUT), LST_TRANS_TIMEOUT)
 
-#define LST_PING_INTERVAL       8
+#define LST_PING_INTERVAL	8
 
 struct lstcon_rpc_trans;
 struct lstcon_tsb_hdr;
@@ -64,46 +64,46 @@ struct lstcon_test;
 struct lstcon_node;
 
 typedef struct lstcon_rpc {
-	struct list_head        crp_link;       /* chain on rpc transaction */
-	srpc_client_rpc_t       *crp_rpc;	/* client rpc */
-	struct lstcon_node      *crp_node;      /* destination node */
-	struct lstcon_rpc_trans *crp_trans;     /* conrpc transaction */
-
-	unsigned int            crp_posted:1;   /* rpc is posted */
-	unsigned int            crp_finished:1; /* rpc is finished */
-	unsigned int            crp_unpacked:1; /* reply is unpacked */
+	struct list_head	 crp_link;	/* chain on rpc transaction */
+	srpc_client_rpc_t	*crp_rpc;	/* client rpc */
+	struct lstcon_node	*crp_node;	/* destination node */
+	struct lstcon_rpc_trans *crp_trans;	/* conrpc transaction */
+
+	unsigned int		 crp_posted:1;	/* rpc is posted */
+	unsigned int		 crp_finished:1; /* rpc is finished */
+	unsigned int		 crp_unpacked:1; /* reply is unpacked */
 	/** RPC is embedded in other structure and can't free it */
-	unsigned int            crp_embedded:1;
-	int                     crp_status;     /* console rpc errors */
-	unsigned long           crp_stamp;      /* replied time stamp */
+	unsigned int		 crp_embedded:1;
+	int			 crp_status;	/* console rpc errors */
+	unsigned long		 crp_stamp;	/* replied time stamp */
 } lstcon_rpc_t;
 
 typedef struct lstcon_rpc_trans {
-	struct list_head  tas_olink;         /* link chain on owner list */
-	struct list_head  tas_link;          /* link chain on global list */
-	int               tas_opc;           /* operation code of transaction */
-	unsigned          tas_feats_updated; /* features mask is uptodate */
-	unsigned          tas_features;      /* test features mask */
-	wait_queue_head_t tas_waitq;         /* wait queue head */
-	atomic_t          tas_remaining;     /* # of un-scheduled rpcs */
+	struct list_head  tas_olink;	     /* link chain on owner list */
+	struct list_head  tas_link;	     /* link chain on global list */
+	int		  tas_opc;	     /* operation code of transaction */
+	unsigned	  tas_feats_updated; /* features mask is uptodate */
+	unsigned	  tas_features;      /* test features mask */
+	wait_queue_head_t tas_waitq;	     /* wait queue head */
+	atomic_t	  tas_remaining;     /* # of un-scheduled rpcs */
 	struct list_head  tas_rpcs_list;     /* queued requests */
 } lstcon_rpc_trans_t;
 
-#define LST_TRANS_PRIVATE       0x1000
+#define LST_TRANS_PRIVATE	0x1000
 
 #define LST_TRANS_SESNEW	(LST_TRANS_PRIVATE | 0x01)
 #define LST_TRANS_SESEND	(LST_TRANS_PRIVATE | 0x02)
 #define LST_TRANS_SESQRY	0x03
-#define LST_TRANS_SESPING       0x04
+#define LST_TRANS_SESPING	0x04
 
-#define LST_TRANS_TSBCLIADD     (LST_TRANS_PRIVATE | 0x11)
-#define LST_TRANS_TSBSRVADD     (LST_TRANS_PRIVATE | 0x12)
+#define LST_TRANS_TSBCLIADD	(LST_TRANS_PRIVATE | 0x11)
+#define LST_TRANS_TSBSRVADD	(LST_TRANS_PRIVATE | 0x12)
 #define LST_TRANS_TSBRUN	(LST_TRANS_PRIVATE | 0x13)
-#define LST_TRANS_TSBSTOP       (LST_TRANS_PRIVATE | 0x14)
-#define LST_TRANS_TSBCLIQRY     0x15
-#define LST_TRANS_TSBSRVQRY     0x16
+#define LST_TRANS_TSBSTOP	(LST_TRANS_PRIVATE | 0x14)
+#define LST_TRANS_TSBCLIQRY	0x15
+#define LST_TRANS_TSBSRVQRY	0x16
 
-#define LST_TRANS_STATQRY       0x21
+#define LST_TRANS_STATQRY	0x21
 
 typedef int (*lstcon_rpc_cond_func_t)(int, struct lstcon_node *, void *);
 typedef int (*lstcon_rpc_readent_func_t)(int, srpc_msg_t *,
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 15cd830..6017f21 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -49,9 +49,9 @@
 do {							\
 	if ((nd)->nd_state == LST_NODE_ACTIVE)		\
 		(p)->nle_nactive++;			\
-	else if ((nd)->nd_state == LST_NODE_BUSY)       \
+	else if ((nd)->nd_state == LST_NODE_BUSY)	\
 		(p)->nle_nbusy++;			\
-	else if ((nd)->nd_state == LST_NODE_DOWN)       \
+	else if ((nd)->nd_state == LST_NODE_DOWN)	\
 		(p)->nle_ndown++;			\
 	else						\
 		(p)->nle_nunknown++;			\
@@ -1690,7 +1690,7 @@ int
 lstcon_session_match(lst_sid_t sid)
 {
 	return (console_session.ses_id.ses_nid == sid.ses_nid &&
-		console_session.ses_id.ses_stamp == sid.ses_stamp) ?  1 : 0;
+		console_session.ses_id.ses_stamp == sid.ses_stamp) ? 1 : 0;
 }
 
 static void
@@ -1723,7 +1723,7 @@ lstcon_session_new(char *name, int key, unsigned feats,
 		rc = lstcon_session_end();
 
 		/* lstcon_session_end() only return local error */
-		if  (rc)
+		if (rc)
 			return rc;
 	}
 
diff --git a/drivers/staging/lustre/lnet/selftest/console.h b/drivers/staging/lustre/lnet/selftest/console.h
index 5421311..554f582 100644
--- a/drivers/staging/lustre/lnet/selftest/console.h
+++ b/drivers/staging/lustre/lnet/selftest/console.h
@@ -52,79 +52,79 @@
 
 typedef struct lstcon_node {
 	lnet_process_id_t nd_id;      /* id of the node */
-	int               nd_ref;     /* reference count */
-	int               nd_state;   /* state of the node */
-	int               nd_timeout; /* session timeout */
-	unsigned long     nd_stamp;   /* timestamp of last replied RPC */
+	int		  nd_ref;     /* reference count */
+	int		  nd_state;   /* state of the node */
+	int		  nd_timeout; /* session timeout */
+	unsigned long	  nd_stamp;   /* timestamp of last replied RPC */
 	struct lstcon_rpc nd_ping;    /* ping rpc */
 } lstcon_node_t; /* node descriptor */
 
 typedef struct {
 	struct list_head ndl_link;    /* chain on list */
 	struct list_head ndl_hlink;   /* chain on hash */
-	lstcon_node_t    *ndl_node;   /* pointer to node */
+	lstcon_node_t	 *ndl_node;   /* pointer to node */
 } lstcon_ndlink_t; /* node link descriptor */
 
 typedef struct {
-	struct list_head grp_link;                /* chain on global group list
+	struct list_head grp_link;		  /* chain on global group list
 						   */
-	int              grp_ref;                 /* reference count */
-	int              grp_userland;            /* has userland nodes */
-	int              grp_nnode;               /* # of nodes */
-	char             grp_name[LST_NAME_SIZE]; /* group name */
-
-	struct list_head grp_trans_list;          /* transaction list */
-	struct list_head grp_ndl_list;            /* nodes list */
-	struct list_head grp_ndl_hash[0];         /* hash table for nodes */
+	int		 grp_ref;		  /* reference count */
+	int		 grp_userland;		  /* has userland nodes */
+	int		 grp_nnode;		  /* # of nodes */
+	char		 grp_name[LST_NAME_SIZE]; /* group name */
+
+	struct list_head grp_trans_list;	  /* transaction list */
+	struct list_head grp_ndl_list;		  /* nodes list */
+	struct list_head grp_ndl_hash[0];	  /* hash table for nodes */
 } lstcon_group_t; /* (alias of nodes) group descriptor */
 
-#define LST_BATCH_IDLE    0xB0	    /* idle batch */
+#define LST_BATCH_IDLE	  0xB0	    /* idle batch */
 #define LST_BATCH_RUNNING 0xB1	    /* running batch */
 
 typedef struct lstcon_tsb_hdr {
-	lst_bid_t        tsb_id;	 /* batch ID */
-	int              tsb_index;      /* test index */
+	lst_bid_t	 tsb_id;	 /* batch ID */
+	int		 tsb_index;	 /* test index */
 } lstcon_tsb_hdr_t;
 
 typedef struct {
-	lstcon_tsb_hdr_t bat_hdr;         /* test_batch header */
-	struct list_head bat_link;        /* chain on session's batches list */
-	int              bat_ntest;       /* # of test */
-	int              bat_state;       /* state of the batch */
-	int              bat_arg;         /* parameter for run|stop, timeout
+	lstcon_tsb_hdr_t bat_hdr;	  /* test_batch header */
+	struct list_head bat_link;	  /* chain on session's batches list */
+	int		 bat_ntest;	  /* # of test */
+	int		 bat_state;	  /* state of the batch */
+	int		 bat_arg;	  /* parameter for run|stop, timeout
 					   * for run, force for stop */
-	char             bat_name[LST_NAME_SIZE];/* name of batch */
+	char		 bat_name[LST_NAME_SIZE];/* name of batch */
 
 	struct list_head bat_test_list;   /* list head of tests (lstcon_test_t)
 					   */
 	struct list_head bat_trans_list;  /* list head of transaction */
-	struct list_head bat_cli_list;    /* list head of client nodes
+	struct list_head bat_cli_list;	  /* list head of client nodes
 					   * (lstcon_node_t) */
 	struct list_head *bat_cli_hash;   /* hash table of client nodes */
-	struct list_head bat_srv_list;    /* list head of server nodes */
+	struct list_head bat_srv_list;	  /* list head of server nodes */
 	struct list_head *bat_srv_hash;   /* hash table of server nodes */
 } lstcon_batch_t; /* (tests ) batch descriptor */
 
 typedef struct lstcon_test {
-	lstcon_tsb_hdr_t tes_hdr;        /* test batch header */
-	struct list_head tes_link;       /* chain on batch's tests list */
-	lstcon_batch_t   *tes_batch;     /* pointer to batch */
-
-	int              tes_type;       /* type of the test, i.e: bulk, ping */
-	int              tes_stop_onerr; /* stop on error */
-	int              tes_oneside;    /* one-sided test */
-	int              tes_concur;     /* concurrency */
-	int              tes_loop;       /* loop count */
-	int              tes_dist;       /* nodes distribution of target group */
-	int              tes_span;       /* nodes span of target group */
-	int              tes_cliidx;     /* client index, used for RPC creating */
+	lstcon_tsb_hdr_t tes_hdr;	 /* test batch header */
+	struct list_head tes_link;	 /* chain on batch's tests list */
+	lstcon_batch_t	 *tes_batch;	 /* pointer to batch */
+
+	int		 tes_type;	 /* type of the test, i.e: bulk, ping */
+	int		 tes_stop_onerr; /* stop on error */
+	int		 tes_oneside;	 /* one-sided test */
+	int		 tes_concur;	 /* concurrency */
+	int		 tes_loop;	 /* loop count */
+	int		 tes_dist;	 /* nodes distribution of target group */
+	int		 tes_span;	 /* nodes span of target group */
+	int		 tes_cliidx;	 /* client index, used for RPC creating */
 
 	struct list_head tes_trans_list; /* transaction list */
-	lstcon_group_t   *tes_src_grp;   /* group run the test */
-	lstcon_group_t   *tes_dst_grp;   /* target group */
+	lstcon_group_t	 *tes_src_grp;	 /* group run the test */
+	lstcon_group_t	 *tes_dst_grp;	 /* target group */
 
-	int              tes_paramlen;   /* test parameter length */
-	char             tes_param[0];   /* test parameter */
+	int		 tes_paramlen;	 /* test parameter length */
+	char		 tes_param[0];	 /* test parameter */
 } lstcon_test_t; /* a single test descriptor */
 
 #define LST_GLOBAL_HASHSIZE 503	     /* global nodes hash table size */
@@ -136,24 +136,24 @@ typedef struct lstcon_test {
 #define LST_CONSOLE_TIMEOUT 300	     /* default console timeout */
 
 struct lstcon_session {
-	struct mutex        ses_mutex;        /* only 1 thread in session */
-	lst_sid_t           ses_id;           /* global session id */
-	int                 ses_key;          /* local session key */
-	int                 ses_state;        /* state of session */
-	int                 ses_timeout;      /* timeout in seconds */
-	time64_t            ses_laststamp;    /* last operation stamp (seconds)
+	struct mutex	    ses_mutex;	      /* only 1 thread in session */
+	lst_sid_t	    ses_id;	      /* global session id */
+	int		    ses_key;	      /* local session key */
+	int		    ses_state;	      /* state of session */
+	int		    ses_timeout;      /* timeout in seconds */
+	time64_t	    ses_laststamp;    /* last operation stamp (seconds)
 					       */
-	unsigned            ses_features;     /* tests features of the session
+	unsigned	    ses_features;     /* tests features of the session
 					       */
-	unsigned            ses_feats_updated:1; /* features are synced with
+	unsigned	    ses_feats_updated:1; /* features are synced with
 						  * remote test nodes */
-	unsigned            ses_force:1;      /* force creating */
-	unsigned            ses_shutdown:1;   /* session is shutting down */
-	unsigned            ses_expired:1;    /* console is timedout */
-	__u64               ses_id_cookie;    /* batch id cookie */
-	char                ses_name[LST_NAME_SIZE];/* session name */
-	lstcon_rpc_trans_t  *ses_ping;        /* session pinger */
-	struct stt_timer         ses_ping_timer;   /* timer for pinger */
+	unsigned	    ses_force:1;      /* force creating */
+	unsigned	    ses_shutdown:1;   /* session is shutting down */
+	unsigned	    ses_expired:1;    /* console is timedout */
+	__u64		    ses_id_cookie;    /* batch id cookie */
+	char		    ses_name[LST_NAME_SIZE];/* session name */
+	lstcon_rpc_trans_t  *ses_ping;	      /* session pinger */
+	struct stt_timer	 ses_ping_timer;   /* timer for pinger */
 	lstcon_trans_stat_t ses_trans_stat;   /* transaction stats */
 
 	struct list_head    ses_trans_list;   /* global list of transaction */
@@ -162,8 +162,8 @@ struct lstcon_session {
 	struct list_head    ses_ndl_list;     /* global list of nodes */
 	struct list_head    *ses_ndl_hash;    /* hash table of nodes */
 
-	spinlock_t          ses_rpc_lock;     /* serialize */
-	atomic_t            ses_rpc_counter;  /* # of initialized RPCs */
+	spinlock_t	    ses_rpc_lock;     /* serialize */
+	atomic_t	    ses_rpc_counter;  /* # of initialized RPCs */
 	struct list_head    ses_rpc_freelist; /* idle console rpc */
 }; /* session descriptor */
 
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index a3ccd78..2ff47d2 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -53,64 +53,64 @@ static int rpc_timeout = 64;
 module_param(rpc_timeout, int, 0644);
 MODULE_PARM_DESC(rpc_timeout, "rpc timeout in seconds (64 by default, 0 == never)");
 
-#define sfw_unpack_id(id)          \
-do {                               \
-	__swab64s(&(id).nid);	   \
-	__swab32s(&(id).pid);	   \
+#define sfw_unpack_id(id)		\
+do {					\
+	__swab64s(&(id).nid);		\
+	__swab32s(&(id).pid);		\
 } while (0)
 
-#define sfw_unpack_sid(sid)             \
-do {                                    \
-	__swab64s(&(sid).ses_nid);      \
-	__swab64s(&(sid).ses_stamp);    \
+#define sfw_unpack_sid(sid)		\
+do {					\
+	__swab64s(&(sid).ses_nid);	\
+	__swab64s(&(sid).ses_stamp);	\
 } while (0)
 
-#define sfw_unpack_fw_counters(fc)        \
-do {                                      \
-	__swab32s(&(fc).running_ms);      \
+#define sfw_unpack_fw_counters(fc)	  \
+do {					  \
+	__swab32s(&(fc).running_ms);	  \
 	__swab32s(&(fc).active_batches);  \
 	__swab32s(&(fc).zombie_sessions); \
-	__swab32s(&(fc).brw_errors);      \
-	__swab32s(&(fc).ping_errors);     \
+	__swab32s(&(fc).brw_errors);	  \
+	__swab32s(&(fc).ping_errors);	  \
 } while (0)
 
-#define sfw_unpack_rpc_counters(rc)     \
-do {                                    \
+#define sfw_unpack_rpc_counters(rc)	\
+do {					\
 	__swab32s(&(rc).errors);	\
-	__swab32s(&(rc).rpcs_sent);     \
-	__swab32s(&(rc).rpcs_rcvd);     \
-	__swab32s(&(rc).rpcs_dropped);  \
-	__swab32s(&(rc).rpcs_expired);  \
-	__swab64s(&(rc).bulk_get);      \
-	__swab64s(&(rc).bulk_put);      \
+	__swab32s(&(rc).rpcs_sent);	\
+	__swab32s(&(rc).rpcs_rcvd);	\
+	__swab32s(&(rc).rpcs_dropped);	\
+	__swab32s(&(rc).rpcs_expired);	\
+	__swab64s(&(rc).bulk_get);	\
+	__swab64s(&(rc).bulk_put);	\
 } while (0)
 
-#define sfw_unpack_lnet_counters(lc)    \
-do {                                    \
+#define sfw_unpack_lnet_counters(lc)	\
+do {					\
 	__swab32s(&(lc).errors);	\
-	__swab32s(&(lc).msgs_max);      \
-	__swab32s(&(lc).msgs_alloc);    \
-	__swab32s(&(lc).send_count);    \
-	__swab32s(&(lc).recv_count);    \
-	__swab32s(&(lc).drop_count);    \
-	__swab32s(&(lc).route_count);   \
-	__swab64s(&(lc).send_length);   \
-	__swab64s(&(lc).recv_length);   \
-	__swab64s(&(lc).drop_length);   \
-	__swab64s(&(lc).route_length);  \
+	__swab32s(&(lc).msgs_max);	\
+	__swab32s(&(lc).msgs_alloc);	\
+	__swab32s(&(lc).send_count);	\
+	__swab32s(&(lc).recv_count);	\
+	__swab32s(&(lc).drop_count);	\
+	__swab32s(&(lc).route_count);	\
+	__swab64s(&(lc).send_length);	\
+	__swab64s(&(lc).recv_length);	\
+	__swab64s(&(lc).drop_length);	\
+	__swab64s(&(lc).route_length);	\
 } while (0)
 
-#define sfw_test_active(t)      (atomic_read(&(t)->tsi_nactive))
-#define sfw_batch_active(b)     (atomic_read(&(b)->bat_nactive))
+#define sfw_test_active(t)	(atomic_read(&(t)->tsi_nactive))
+#define sfw_batch_active(b)	(atomic_read(&(b)->bat_nactive))
 
 static struct smoketest_framework {
 	struct list_head  fw_zombie_rpcs;     /* RPCs to be recycled */
 	struct list_head  fw_zombie_sessions; /* stopping sessions */
-	struct list_head  fw_tests;           /* registered test cases */
-	atomic_t          fw_nzombies;        /* # zombie sessions */
-	spinlock_t        fw_lock;            /* serialise */
-	sfw_session_t     *fw_session;        /* _the_ session */
-	int               fw_shuttingdown;    /* shutdown in progress */
+	struct list_head  fw_tests;	      /* registered test cases */
+	atomic_t	  fw_nzombies;	      /* # zombie sessions */
+	spinlock_t	  fw_lock;	      /* serialise */
+	sfw_session_t	  *fw_session;	      /* _the_ session */
+	int		  fw_shuttingdown;    /* shutdown in progress */
 	struct srpc_server_rpc *fw_active_srpc;/* running RPC */
 } sfw_data;
 
@@ -194,7 +194,7 @@ sfw_del_session_timer(void)
 
 static void
 sfw_deactivate_session(void)
-	__must_hold(&sfw_data.fw_lock)
+__must_hold(&sfw_data.fw_lock)
 {
 	sfw_session_t *sn = sfw_data.fw_session;
 	int nactive = 0;
@@ -1164,7 +1164,7 @@ sfw_add_test(struct srpc_server_rpc *rpc)
 		if (!(sn->sn_features & LST_FEAT_BULK_LEN)) {
 			len = npg * PAGE_CACHE_SIZE;
 
-		} else  {
+		} else {
 			len = sizeof(lnet_process_id_packed_t) *
 			      request->tsr_ndest;
 		}
@@ -1274,7 +1274,7 @@ sfw_handle_server_rpc(struct srpc_server_rpc *rpc)
 		}
 
 	} else if (request->msg_ses_feats & ~LST_FEATS_MASK) {
-		/*
+		/**
 		 * NB: at this point, old version will ignore features and
 		 * create new session anyway, so console should be able
 		 * to handle this
diff --git a/drivers/staging/lustre/lnet/selftest/module.c b/drivers/staging/lustre/lnet/selftest/module.c
index 55082ce..1e858e9 100644
--- a/drivers/staging/lustre/lnet/selftest/module.c
+++ b/drivers/staging/lustre/lnet/selftest/module.c
@@ -40,7 +40,7 @@
 #include "console.h"
 
 enum {
-	LST_INIT_NONE = 0,
+	LST_INIT_NONE		= 0,
 	LST_INIT_WI_SERIAL,
 	LST_INIT_WI_TEST,
 	LST_INIT_RPC,
diff --git a/drivers/staging/lustre/lnet/selftest/ping_test.c b/drivers/staging/lustre/lnet/selftest/ping_test.c
index cb2707a..81a4504 100644
--- a/drivers/staging/lustre/lnet/selftest/ping_test.c
+++ b/drivers/staging/lustre/lnet/selftest/ping_test.c
@@ -42,7 +42,7 @@
 
 #include "selftest.h"
 
-#define LST_PING_TEST_MAGIC     0xbabeface
+#define LST_PING_TEST_MAGIC	0xbabeface
 
 static int ping_srv_workitems = SFW_TEST_WI_MAX;
 module_param(ping_srv_workitems, int, 0644);
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index f344d56..69be7d6 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -463,7 +463,7 @@ srpc_post_passive_rqtbuf(int service, int local, void *buf, int len,
 
 static int
 srpc_service_post_buffer(struct srpc_service_cd *scd, struct srpc_buffer *buf)
-	__must_hold(&scd->scd_lock)
+__must_hold(&scd->scd_lock)
 {
 	struct srpc_service *sv = scd->scd_svc;
 	struct srpc_msg	*msg = &buf->buf_msg;
@@ -698,7 +698,7 @@ srpc_finish_service(struct srpc_service *sv)
 /* called with sv->sv_lock held */
 static void
 srpc_service_recycle_buffer(struct srpc_service_cd *scd, srpc_buffer_t *buf)
-	__must_hold(&scd->scd_lock)
+__must_hold(&scd->scd_lock)
 {
 	if (!scd->scd_svc->sv_shuttingdown && scd->scd_buf_adjust >= 0) {
 		if (srpc_service_post_buffer(scd, buf)) {
@@ -1104,8 +1104,8 @@ srpc_add_client_rpc_timer(srpc_client_rpc_t *rpc)
 		return;
 
 	INIT_LIST_HEAD(&timer->stt_list);
-	timer->stt_data = rpc;
-	timer->stt_func = srpc_client_rpc_expired;
+	timer->stt_data	= rpc;
+	timer->stt_func	= srpc_client_rpc_expired;
 	timer->stt_expires = ktime_get_real_seconds() + rpc->crpc_timeout;
 	stt_add_timer(timer);
 }
@@ -1333,7 +1333,7 @@ srpc_abort_rpc(srpc_client_rpc_t *rpc, int why)
 	LASSERT(why);
 
 	if (rpc->crpc_aborted || /* already aborted */
-	    rpc->crpc_closed)    /* callback imminent */
+	    rpc->crpc_closed)	 /* callback imminent */
 		return;
 
 	CDEBUG(D_NET, "Aborting RPC: service %d, peer %s, state %s, why %d\n",
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.h b/drivers/staging/lustre/lnet/selftest/rpc.h
index 9dfb366..a79c315 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.h
+++ b/drivers/staging/lustre/lnet/selftest/rpc.h
@@ -45,24 +45,24 @@
  * XXX: *REPLY == *REQST + 1
  */
 typedef enum {
-	SRPC_MSG_MKSN_REQST     = 0,
-	SRPC_MSG_MKSN_REPLY     = 1,
-	SRPC_MSG_RMSN_REQST     = 2,
-	SRPC_MSG_RMSN_REPLY     = 3,
-	SRPC_MSG_BATCH_REQST    = 4,
-	SRPC_MSG_BATCH_REPLY    = 5,
-	SRPC_MSG_STAT_REQST     = 6,
-	SRPC_MSG_STAT_REPLY     = 7,
-	SRPC_MSG_TEST_REQST     = 8,
-	SRPC_MSG_TEST_REPLY     = 9,
-	SRPC_MSG_DEBUG_REQST    = 10,
-	SRPC_MSG_DEBUG_REPLY    = 11,
-	SRPC_MSG_BRW_REQST      = 12,
-	SRPC_MSG_BRW_REPLY      = 13,
-	SRPC_MSG_PING_REQST     = 14,
-	SRPC_MSG_PING_REPLY     = 15,
-	SRPC_MSG_JOIN_REQST     = 16,
-	SRPC_MSG_JOIN_REPLY     = 17,
+	SRPC_MSG_MKSN_REQST	= 0,
+	SRPC_MSG_MKSN_REPLY	= 1,
+	SRPC_MSG_RMSN_REQST	= 2,
+	SRPC_MSG_RMSN_REPLY	= 3,
+	SRPC_MSG_BATCH_REQST	= 4,
+	SRPC_MSG_BATCH_REPLY	= 5,
+	SRPC_MSG_STAT_REQST	= 6,
+	SRPC_MSG_STAT_REPLY	= 7,
+	SRPC_MSG_TEST_REQST	= 8,
+	SRPC_MSG_TEST_REPLY	= 9,
+	SRPC_MSG_DEBUG_REQST	= 10,
+	SRPC_MSG_DEBUG_REPLY	= 11,
+	SRPC_MSG_BRW_REQST	= 12,
+	SRPC_MSG_BRW_REPLY	= 13,
+	SRPC_MSG_PING_REQST	= 14,
+	SRPC_MSG_PING_REPLY	= 15,
+	SRPC_MSG_JOIN_REQST	= 16,
+	SRPC_MSG_JOIN_REPLY	= 17,
 } srpc_msg_type_t;
 
 /* CAVEAT EMPTOR:
@@ -78,127 +78,127 @@ typedef struct {
 } WIRE_ATTR srpc_generic_reqst_t;
 
 typedef struct {
-	__u32                   status;
-	lst_sid_t               sid;
+	__u32			status;
+	lst_sid_t		sid;
 } WIRE_ATTR srpc_generic_reply_t;
 
 /* FRAMEWORK RPCs */
 typedef struct {
-	__u64                   mksn_rpyid;     /* reply buffer matchbits */
-	lst_sid_t               mksn_sid;	/* session id */
-	__u32			mksn_force;     /* use brute force */
+	__u64			mksn_rpyid;	/* reply buffer matchbits */
+	lst_sid_t		mksn_sid;	/* session id */
+	__u32			mksn_force;	/* use brute force */
 	char			mksn_name[LST_NAME_SIZE];
 } WIRE_ATTR srpc_mksn_reqst_t; /* make session request */
 
 typedef struct {
-	__u32                   mksn_status;    /* session status */
-	lst_sid_t               mksn_sid;       /* session id */
-	__u32                   mksn_timeout;   /* session timeout */
-	char                    mksn_name[LST_NAME_SIZE];
+	__u32			mksn_status;	/* session status */
+	lst_sid_t		mksn_sid;	/* session id */
+	__u32			mksn_timeout;	/* session timeout */
+	char			mksn_name[LST_NAME_SIZE];
 } WIRE_ATTR srpc_mksn_reply_t; /* make session reply */
 
 typedef struct {
-	__u64                   rmsn_rpyid;     /* reply buffer matchbits */
-	lst_sid_t               rmsn_sid;       /* session id */
+	__u64			rmsn_rpyid;	/* reply buffer matchbits */
+	lst_sid_t		rmsn_sid;	/* session id */
 } WIRE_ATTR srpc_rmsn_reqst_t; /* remove session request */
 
 typedef struct {
-	__u32                   rmsn_status;
-	lst_sid_t               rmsn_sid;       /* session id */
+	__u32			rmsn_status;
+	lst_sid_t		rmsn_sid;	/* session id */
 } WIRE_ATTR srpc_rmsn_reply_t; /* remove session reply */
 
 typedef struct {
-	__u64                   join_rpyid;     /* reply buffer matchbits */
-	lst_sid_t               join_sid;       /* session id to join */
-	char                    join_group[LST_NAME_SIZE]; /* group name */
+	__u64			join_rpyid;	/* reply buffer matchbits */
+	lst_sid_t		join_sid;	/* session id to join */
+	char			join_group[LST_NAME_SIZE]; /* group name */
 } WIRE_ATTR srpc_join_reqst_t;
 
 typedef struct {
-	__u32                   join_status;    /* returned status */
-	lst_sid_t               join_sid;       /* session id */
-	__u32			join_timeout;   /* # seconds' inactivity to
+	__u32			join_status;	/* returned status */
+	lst_sid_t		join_sid;	/* session id */
+	__u32			join_timeout;	/* # seconds' inactivity to
 						 * expire */
-	char                    join_session[LST_NAME_SIZE]; /* session name */
+	char			join_session[LST_NAME_SIZE]; /* session name */
 } WIRE_ATTR srpc_join_reply_t;
 
 typedef struct {
-	__u64                   dbg_rpyid;      /* reply buffer matchbits */
-	lst_sid_t               dbg_sid;        /* session id */
-	__u32                   dbg_flags;      /* bitmap of debug */
+	__u64			dbg_rpyid;	/* reply buffer matchbits */
+	lst_sid_t		dbg_sid;	/* session id */
+	__u32			dbg_flags;	/* bitmap of debug */
 } WIRE_ATTR srpc_debug_reqst_t;
 
 typedef struct {
-	__u32                   dbg_status;     /* returned code */
-	lst_sid_t               dbg_sid;        /* session id */
-	__u32                   dbg_timeout;    /* session timeout */
-	__u32                   dbg_nbatch;     /* # of batches in the node */
-	char                    dbg_name[LST_NAME_SIZE]; /* session name */
+	__u32			dbg_status;	/* returned code */
+	lst_sid_t		dbg_sid;	/* session id */
+	__u32			dbg_timeout;	/* session timeout */
+	__u32			dbg_nbatch;	/* # of batches in the node */
+	char			dbg_name[LST_NAME_SIZE]; /* session name */
 } WIRE_ATTR srpc_debug_reply_t;
 
-#define SRPC_BATCH_OPC_RUN      1
-#define SRPC_BATCH_OPC_STOP     2
-#define SRPC_BATCH_OPC_QUERY    3
+#define SRPC_BATCH_OPC_RUN	1
+#define SRPC_BATCH_OPC_STOP	2
+#define SRPC_BATCH_OPC_QUERY	3
 
 typedef struct {
-	__u64              bar_rpyid;      /* reply buffer matchbits */
-	lst_sid_t          bar_sid;        /* session id */
-	lst_bid_t          bar_bid;        /* batch id */
-	__u32              bar_opc;        /* create/start/stop batch */
-	__u32              bar_testidx;    /* index of test */
-	__u32              bar_arg;        /* parameters */
+	__u64		   bar_rpyid;	   /* reply buffer matchbits */
+	lst_sid_t	   bar_sid;	   /* session id */
+	lst_bid_t	   bar_bid;	   /* batch id */
+	__u32		   bar_opc;	   /* create/start/stop batch */
+	__u32		   bar_testidx;    /* index of test */
+	__u32		   bar_arg;	   /* parameters */
 } WIRE_ATTR srpc_batch_reqst_t;
 
 typedef struct {
-	__u32              bar_status;     /* status of request */
-	lst_sid_t          bar_sid;        /* session id */
-	__u32              bar_active;     /* # of active tests in batch/test */
-	__u32              bar_time;       /* remained time */
+	__u32		   bar_status;	   /* status of request */
+	lst_sid_t	   bar_sid;	   /* session id */
+	__u32		   bar_active;	   /* # of active tests in batch/test */
+	__u32		   bar_time;	   /* remained time */
 } WIRE_ATTR srpc_batch_reply_t;
 
 typedef struct {
-	__u64              str_rpyid;      /* reply buffer matchbits */
-	lst_sid_t          str_sid;        /* session id */
-	__u32              str_type;       /* type of stat */
+	__u64		   str_rpyid;	   /* reply buffer matchbits */
+	lst_sid_t	   str_sid;	   /* session id */
+	__u32		   str_type;	   /* type of stat */
 } WIRE_ATTR srpc_stat_reqst_t;
 
 typedef struct {
-	__u32              str_status;
-	lst_sid_t          str_sid;
-	sfw_counters_t     str_fw;
+	__u32		   str_status;
+	lst_sid_t	   str_sid;
+	sfw_counters_t	   str_fw;
 	srpc_counters_t    str_rpc;
 	lnet_counters_t    str_lnet;
 } WIRE_ATTR srpc_stat_reply_t;
 
 typedef struct {
-	__u32              blk_opc;        /* bulk operation code */
-	__u32              blk_npg;        /* # of pages */
-	__u32              blk_flags;      /* reserved flags */
+	__u32		   blk_opc;	   /* bulk operation code */
+	__u32		   blk_npg;	   /* # of pages */
+	__u32		   blk_flags;	   /* reserved flags */
 } WIRE_ATTR test_bulk_req_t;
 
 typedef struct {
-	__u16              blk_opc;        /* bulk operation code */
-	__u16              blk_flags;      /* data check flags */
-	__u32              blk_len;        /* data length */
-	__u32              blk_offset;     /* reserved: offset */
+	__u16		   blk_opc;	   /* bulk operation code */
+	__u16		   blk_flags;	   /* data check flags */
+	__u32		   blk_len;	   /* data length */
+	__u32		   blk_offset;	   /* reserved: offset */
 } WIRE_ATTR test_bulk_req_v1_t;
 
 typedef struct {
-	__u32              png_size;       /* size of ping message */
-	__u32              png_flags;      /* reserved flags */
+	__u32		   png_size;	   /* size of ping message */
+	__u32		   png_flags;	   /* reserved flags */
 } WIRE_ATTR test_ping_req_t;
 
 typedef struct {
-	__u64			tsr_rpyid;      /* reply buffer matchbits */
-	__u64			tsr_bulkid;     /* bulk buffer matchbits */
+	__u64			tsr_rpyid;	/* reply buffer matchbits */
+	__u64			tsr_bulkid;	/* bulk buffer matchbits */
 	lst_sid_t		tsr_sid;	/* session id */
 	lst_bid_t		tsr_bid;	/* batch id */
-	__u32			tsr_service;    /* test type: bulk|ping|... */
-	__u32			tsr_loop;       /* test client loop count or
+	__u32			tsr_service;	/* test type: bulk|ping|... */
+	__u32			tsr_loop;	/* test client loop count or
 						 * # server buffers needed */
-	__u32			tsr_concur;     /* concurrency of test */
-	__u8			tsr_is_client;  /* is test client or not */
+	__u32			tsr_concur;	/* concurrency of test */
+	__u8			tsr_is_client;	/* is test client or not */
 	__u8			tsr_stop_onerr; /* stop on error */
-	__u32			tsr_ndest;      /* # of dest nodes */
+	__u32			tsr_ndest;	/* # of dest nodes */
 
 	union {
 		test_ping_req_t		ping;
@@ -208,7 +208,7 @@ typedef struct {
 } WIRE_ATTR srpc_test_reqst_t;
 
 typedef struct {
-	__u32			tsr_status;     /* returned code */
+	__u32			tsr_status;	/* returned code */
 	lst_sid_t		tsr_sid;
 } WIRE_ATTR srpc_test_reply_t;
 
@@ -228,19 +228,19 @@ typedef struct {
 } WIRE_ATTR srpc_ping_reply_t;
 
 typedef struct {
-	__u64		   brw_rpyid;      /* reply buffer matchbits */
-	__u64		   brw_bulkid;     /* bulk buffer matchbits */
-	__u32		   brw_rw;         /* read or write */
-	__u32		   brw_len;        /* bulk data len */
-	__u32		   brw_flags;      /* bulk data patterns */
+	__u64		   brw_rpyid;	   /* reply buffer matchbits */
+	__u64		   brw_bulkid;	   /* bulk buffer matchbits */
+	__u32		   brw_rw;	   /* read or write */
+	__u32		   brw_len;	   /* bulk data len */
+	__u32		   brw_flags;	   /* bulk data patterns */
 } WIRE_ATTR srpc_brw_reqst_t; /* bulk r/w request */
 
 typedef struct {
 	__u32		   brw_status;
 } WIRE_ATTR srpc_brw_reply_t; /* bulk r/w reply */
 
-#define SRPC_MSG_MAGIC   0xeeb0f00d
-#define SRPC_MSG_VERSION 1
+#define SRPC_MSG_MAGIC		0xeeb0f00d
+#define SRPC_MSG_VERSION	1
 
 typedef struct srpc_msg {
 	__u32	msg_magic;     /* magic number */
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 7a22bd3..288522d 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -56,14 +56,14 @@
 #define MADE_WITHOUT_COMPROMISE
 #endif
 
-#define SWI_STATE_NEWBORN           0
-#define SWI_STATE_REPLY_SUBMITTED   1
-#define SWI_STATE_REPLY_SENT        2
-#define SWI_STATE_REQUEST_SUBMITTED 3
-#define SWI_STATE_REQUEST_SENT      4
-#define SWI_STATE_REPLY_RECEIVED    5
-#define SWI_STATE_BULK_STARTED      6
-#define SWI_STATE_DONE             10
+#define SWI_STATE_NEWBORN		0
+#define SWI_STATE_REPLY_SUBMITTED	1
+#define SWI_STATE_REPLY_SENT		2
+#define SWI_STATE_REQUEST_SUBMITTED	3
+#define SWI_STATE_REQUEST_SENT		4
+#define SWI_STATE_REPLY_RECEIVED	5
+#define SWI_STATE_BULK_STARTED		6
+#define SWI_STATE_DONE			10
 
 /* forward refs */
 struct srpc_service;
@@ -74,24 +74,24 @@ struct sfw_test_instance;
 /* services below SRPC_FRAMEWORK_SERVICE_MAX_ID are framework
  * services, e.g. create/modify session.
  */
-#define SRPC_SERVICE_DEBUG             0
-#define SRPC_SERVICE_MAKE_SESSION      1
-#define SRPC_SERVICE_REMOVE_SESSION    2
-#define SRPC_SERVICE_BATCH             3
-#define SRPC_SERVICE_TEST              4
-#define SRPC_SERVICE_QUERY_STAT        5
-#define SRPC_SERVICE_JOIN              6
-#define SRPC_FRAMEWORK_SERVICE_MAX_ID 10
+#define SRPC_SERVICE_DEBUG		0
+#define SRPC_SERVICE_MAKE_SESSION	1
+#define SRPC_SERVICE_REMOVE_SESSION	2
+#define SRPC_SERVICE_BATCH		3
+#define SRPC_SERVICE_TEST		4
+#define SRPC_SERVICE_QUERY_STAT		5
+#define SRPC_SERVICE_JOIN		6
+#define SRPC_FRAMEWORK_SERVICE_MAX_ID	10
 /* other services start from SRPC_FRAMEWORK_SERVICE_MAX_ID+1 */
-#define SRPC_SERVICE_BRW              11
-#define SRPC_SERVICE_PING             12
-#define SRPC_SERVICE_MAX_ID           12
+#define SRPC_SERVICE_BRW		11
+#define SRPC_SERVICE_PING		12
+#define SRPC_SERVICE_MAX_ID		12
 
-#define SRPC_REQUEST_PORTAL           50
+#define SRPC_REQUEST_PORTAL		50
 /* a lazy portal for framework RPC requests */
-#define SRPC_FRAMEWORK_REQUEST_PORTAL 51
+#define SRPC_FRAMEWORK_REQUEST_PORTAL	51
 /* all reply/bulk RDMAs go to this portal */
-#define SRPC_RDMA_PORTAL              52
+#define SRPC_RDMA_PORTAL		52
 
 static inline srpc_msg_type_t
 srpc_service2request(int service)
@@ -149,25 +149,25 @@ typedef enum {
 typedef struct {
 	srpc_event_type_t ev_type;   /* what's up */
 	lnet_event_kind_t ev_lnet;   /* LNet event type */
-	int               ev_fired;  /* LNet event fired? */
-	int               ev_status; /* LNet event status */
-	void              *ev_data;  /* owning server/client RPC */
+	int		  ev_fired;  /* LNet event fired? */
+	int		  ev_status; /* LNet event status */
+	void		  *ev_data;  /* owning server/client RPC */
 } srpc_event_t;
 
 typedef struct {
-	int              bk_len;     /* len of bulk data */
+	int		 bk_len;     /* len of bulk data */
 	lnet_handle_md_t bk_mdh;
-	int              bk_sink;    /* sink/source */
-	int              bk_niov;    /* # iov in bk_iovs */
-	lnet_kiov_t      bk_iovs[0];
+	int		 bk_sink;    /* sink/source */
+	int		 bk_niov;    /* # iov in bk_iovs */
+	lnet_kiov_t	 bk_iovs[0];
 } srpc_bulk_t; /* bulk descriptor */
 
 /* message buffer descriptor */
 typedef struct srpc_buffer {
 	struct list_head  buf_list; /* chain on srpc_service::*_msgq */
-	srpc_msg_t        buf_msg;
+	srpc_msg_t	  buf_msg;
 	lnet_handle_md_t  buf_mdh;
-	lnet_nid_t        buf_self;
+	lnet_nid_t	  buf_self;
 	lnet_process_id_t buf_peer;
 } srpc_buffer_t;
 
@@ -176,9 +176,9 @@ typedef int (*swi_action_t) (struct swi_workitem *);
 
 typedef struct swi_workitem {
 	struct cfs_wi_sched *swi_sched;
-	cfs_workitem_t      swi_workitem;
-	swi_action_t        swi_action;
-	int                 swi_state;
+	cfs_workitem_t	    swi_workitem;
+	swi_action_t	    swi_action;
+	int		    swi_state;
 } swi_workitem_t;
 
 /* server-side state of a RPC */
@@ -186,73 +186,73 @@ struct srpc_server_rpc {
 	/* chain on srpc_service::*_rpcq */
 	struct list_head       srpc_list;
 	struct srpc_service_cd *srpc_scd;
-	swi_workitem_t         srpc_wi;
-	srpc_event_t           srpc_ev;      /* bulk/reply event */
-	lnet_nid_t             srpc_self;
+	swi_workitem_t	       srpc_wi;
+	srpc_event_t	       srpc_ev;      /* bulk/reply event */
+	lnet_nid_t	       srpc_self;
 	lnet_process_id_t      srpc_peer;
-	srpc_msg_t             srpc_replymsg;
+	srpc_msg_t	       srpc_replymsg;
 	lnet_handle_md_t       srpc_replymdh;
-	srpc_buffer_t          *srpc_reqstbuf;
-	srpc_bulk_t            *srpc_bulk;
+	srpc_buffer_t	       *srpc_reqstbuf;
+	srpc_bulk_t	       *srpc_bulk;
 
-	unsigned int           srpc_aborted; /* being given up */
-	int                    srpc_status;
-	void                   (*srpc_done)(struct srpc_server_rpc *);
+	unsigned int	       srpc_aborted; /* being given up */
+	int		       srpc_status;
+	void		       (*srpc_done)(struct srpc_server_rpc *);
 };
 
 /* client-side state of a RPC */
 typedef struct srpc_client_rpc {
-	struct list_head  crpc_list;      /* chain on user's lists */
-	spinlock_t        crpc_lock;      /* serialize */
-	int               crpc_service;
-	atomic_t          crpc_refcount;
-	int               crpc_timeout;   /* # seconds to wait for reply */
+	struct list_head  crpc_list;	  /* chain on user's lists */
+	spinlock_t	  crpc_lock;	  /* serialize */
+	int		  crpc_service;
+	atomic_t	  crpc_refcount;
+	int		  crpc_timeout;   /* # seconds to wait for reply */
 	struct stt_timer       crpc_timer;
-	swi_workitem_t    crpc_wi;
+	swi_workitem_t	  crpc_wi;
 	lnet_process_id_t crpc_dest;
 
-	void              (*crpc_done)(struct srpc_client_rpc *);
-	void              (*crpc_fini)(struct srpc_client_rpc *);
-	int               crpc_status;    /* completion status */
-	void              *crpc_priv;     /* caller data */
+	void		  (*crpc_done)(struct srpc_client_rpc *);
+	void		  (*crpc_fini)(struct srpc_client_rpc *);
+	int		  crpc_status;	  /* completion status */
+	void		  *crpc_priv;	  /* caller data */
 
 	/* state flags */
-	unsigned int      crpc_aborted:1; /* being given up */
-	unsigned int      crpc_closed:1;  /* completed */
+	unsigned int	  crpc_aborted:1; /* being given up */
+	unsigned int	  crpc_closed:1;  /* completed */
 
 	/* RPC events */
-	srpc_event_t      crpc_bulkev;    /* bulk event */
-	srpc_event_t      crpc_reqstev;   /* request event */
-	srpc_event_t      crpc_replyev;   /* reply event */
+	srpc_event_t	  crpc_bulkev;	  /* bulk event */
+	srpc_event_t	  crpc_reqstev;   /* request event */
+	srpc_event_t	  crpc_replyev;   /* reply event */
 
 	/* bulk, request(reqst), and reply exchanged on wire */
-	srpc_msg_t        crpc_reqstmsg;
-	srpc_msg_t        crpc_replymsg;
+	srpc_msg_t	  crpc_reqstmsg;
+	srpc_msg_t	  crpc_replymsg;
 	lnet_handle_md_t  crpc_reqstmdh;
 	lnet_handle_md_t  crpc_replymdh;
-	srpc_bulk_t       crpc_bulk;
+	srpc_bulk_t	  crpc_bulk;
 } srpc_client_rpc_t;
 
-#define srpc_client_rpc_size(rpc)                                        \
+#define srpc_client_rpc_size(rpc)					\
 offsetof(srpc_client_rpc_t, crpc_bulk.bk_iovs[(rpc)->crpc_bulk.bk_niov])
 
-#define srpc_client_rpc_addref(rpc)                                      \
-do {                                                                     \
-	CDEBUG(D_NET, "RPC[%p] -> %s (%d)++\n",                          \
-	       (rpc), libcfs_id2str((rpc)->crpc_dest),                   \
-	       atomic_read(&(rpc)->crpc_refcount));                      \
-	LASSERT(atomic_read(&(rpc)->crpc_refcount) > 0);                 \
-	atomic_inc(&(rpc)->crpc_refcount);                               \
+#define srpc_client_rpc_addref(rpc)					\
+do {									\
+	CDEBUG(D_NET, "RPC[%p] -> %s (%d)++\n",				\
+	       (rpc), libcfs_id2str((rpc)->crpc_dest),			\
+	       atomic_read(&(rpc)->crpc_refcount));			\
+	LASSERT(atomic_read(&(rpc)->crpc_refcount) > 0);		\
+	atomic_inc(&(rpc)->crpc_refcount);				\
 } while (0)
 
-#define srpc_client_rpc_decref(rpc)                                      \
-do {                                                                     \
-	CDEBUG(D_NET, "RPC[%p] -> %s (%d)--\n",                          \
-	       (rpc), libcfs_id2str((rpc)->crpc_dest),                   \
-	       atomic_read(&(rpc)->crpc_refcount));                      \
-	LASSERT(atomic_read(&(rpc)->crpc_refcount) > 0);                 \
-	if (atomic_dec_and_test(&(rpc)->crpc_refcount))                  \
-		srpc_destroy_client_rpc(rpc);                            \
+#define srpc_client_rpc_decref(rpc)					\
+do {									\
+	CDEBUG(D_NET, "RPC[%p] -> %s (%d)--\n",				\
+	       (rpc), libcfs_id2str((rpc)->crpc_dest),			\
+	       atomic_read(&(rpc)->crpc_refcount));			\
+	LASSERT(atomic_read(&(rpc)->crpc_refcount) > 0);		\
+	if (atomic_dec_and_test(&(rpc)->crpc_refcount))			\
+		srpc_destroy_client_rpc(rpc);				\
 } while (0)
 
 #define srpc_event_pending(rpc)   (!(rpc)->crpc_bulkev.ev_fired ||	\
@@ -268,9 +268,9 @@ struct srpc_service_cd {
 	/** event buffer */
 	srpc_event_t		scd_ev;
 	/** free RPC descriptors */
-	struct list_head        scd_rpc_free;
+	struct list_head	scd_rpc_free;
 	/** in-flight RPCs */
-	struct list_head        scd_rpc_active;
+	struct list_head	scd_rpc_active;
 	/** workitem for posting buffer */
 	swi_workitem_t		scd_buf_wi;
 	/** CPT id */
@@ -278,7 +278,7 @@ struct srpc_service_cd {
 	/** error code for scd_buf_wi */
 	int			scd_buf_err;
 	/** timestamp for scd_buf_err */
-	time64_t                scd_buf_err_stamp;
+	time64_t		scd_buf_err_stamp;
 	/** total # request buffers */
 	int			scd_buf_total;
 	/** # posted request buffers */
@@ -290,16 +290,16 @@ struct srpc_service_cd {
 	/** increase/decrease some buffers */
 	int			scd_buf_adjust;
 	/** posted message buffers */
-	struct list_head        scd_buf_posted;
+	struct list_head	scd_buf_posted;
 	/** blocked for RPC descriptor */
-	struct list_head        scd_buf_blocked;
+	struct list_head	scd_buf_blocked;
 };
 
 /* number of server workitems (mini-thread) for testing service */
 #define SFW_TEST_WI_MIN		256
 #define SFW_TEST_WI_MAX		2048
 /* extra buffers for tolerating buggy peers, or unbalanced number
- * of peers between partitions  */
+ * of peers between partitions	*/
 #define SFW_TEST_WI_EXTRA	64
 
 /* number of server workitems (mini-thread) for framework service */
@@ -324,29 +324,29 @@ typedef struct srpc_service {
 
 typedef struct {
 	struct list_head sn_list;    /* chain on fw_zombie_sessions */
-	lst_sid_t        sn_id;      /* unique identifier */
-	unsigned int     sn_timeout; /* # seconds' inactivity to expire */
-	int              sn_timer_active;
-	unsigned int     sn_features;
+	lst_sid_t	 sn_id;      /* unique identifier */
+	unsigned int	 sn_timeout; /* # seconds' inactivity to expire */
+	int		 sn_timer_active;
+	unsigned int	 sn_features;
 	struct stt_timer      sn_timer;
 	struct list_head sn_batches; /* list of batches */
-	char             sn_name[LST_NAME_SIZE];
-	atomic_t         sn_refcount;
-	atomic_t         sn_brw_errors;
-	atomic_t         sn_ping_errors;
-	unsigned long    sn_started;
+	char		 sn_name[LST_NAME_SIZE];
+	atomic_t	 sn_refcount;
+	atomic_t	 sn_brw_errors;
+	atomic_t	 sn_ping_errors;
+	unsigned long	 sn_started;
 } sfw_session_t;
 
 #define sfw_sid_equal(sid0, sid1)     ((sid0).ses_nid == (sid1).ses_nid && \
 				       (sid0).ses_stamp == (sid1).ses_stamp)
 
 typedef struct {
-	struct list_head bat_list;      /* chain on sn_batches */
-	lst_bid_t        bat_id;	/* batch id */
-	int              bat_error;     /* error code of batch */
-	sfw_session_t    *bat_session;  /* batch's session */
-	atomic_t         bat_nactive;   /* # of active tests */
-	struct list_head bat_tests;     /* test instances */
+	struct list_head bat_list;	/* chain on sn_batches */
+	lst_bid_t	 bat_id;	/* batch id */
+	int		 bat_error;	/* error code of batch */
+	sfw_session_t	 *bat_session;	/* batch's session */
+	atomic_t	 bat_nactive;	/* # of active tests */
+	struct list_head bat_tests;	/* test instances */
 } sfw_batch_t;
 
 typedef struct {
@@ -356,32 +356,32 @@ typedef struct {
 							  * client */
 	int  (*tso_prep_rpc)(struct sfw_test_unit *tsu,
 			     lnet_process_id_t dest,
-			     srpc_client_rpc_t **rpc);   /* prep a tests rpc */
+			     srpc_client_rpc_t **rpc);	 /* prep a tests rpc */
 	void (*tso_done_rpc)(struct sfw_test_unit *tsu,
-			     srpc_client_rpc_t *rpc);    /* done a test rpc */
+			     srpc_client_rpc_t *rpc);	 /* done a test rpc */
 } sfw_test_client_ops_t;
 
 typedef struct sfw_test_instance {
-	struct list_head           tsi_list;            /* chain on batch */
-	int                        tsi_service;         /* test type */
-	sfw_batch_t                *tsi_batch;          /* batch */
-	sfw_test_client_ops_t      *tsi_ops;            /* test client operation
+	struct list_head	   tsi_list;		/* chain on batch */
+	int			   tsi_service;		/* test type */
+	sfw_batch_t		   *tsi_batch;		/* batch */
+	sfw_test_client_ops_t	   *tsi_ops;		/* test client operation
 							 */
 
 	/* public parameter for all test units */
-	unsigned int               tsi_is_client:1;     /* is test client */
-	unsigned int               tsi_stoptsu_onerr:1; /* stop tsu on error */
-	int                        tsi_concur;          /* concurrency */
-	int                        tsi_loop;            /* loop count */
+	unsigned int		   tsi_is_client:1;	/* is test client */
+	unsigned int		   tsi_stoptsu_onerr:1; /* stop tsu on error */
+	int			   tsi_concur;		/* concurrency */
+	int			   tsi_loop;		/* loop count */
 
 	/* status of test instance */
-	spinlock_t                 tsi_lock;            /* serialize */
-	unsigned int               tsi_stopping:1;      /* test is stopping */
-	atomic_t                   tsi_nactive;         /* # of active test
+	spinlock_t		   tsi_lock;		/* serialize */
+	unsigned int		   tsi_stopping:1;	/* test is stopping */
+	atomic_t		   tsi_nactive;		/* # of active test
 							 * unit */
-	struct list_head           tsi_units;           /* test units */
-	struct list_head           tsi_free_rpcs;       /* free rpcs */
-	struct list_head           tsi_active_rpcs;     /* active rpcs */
+	struct list_head	   tsi_units;		/* test units */
+	struct list_head	   tsi_free_rpcs;	/* free rpcs */
+	struct list_head	   tsi_active_rpcs;	/* active rpcs */
 
 	union {
 		test_ping_req_t	   ping;    /* ping parameter */
@@ -392,24 +392,24 @@ typedef struct sfw_test_instance {
 
 /* XXX: trailing (PAGE_CACHE_SIZE % sizeof(lnet_process_id_t)) bytes at
  * the end of pages are not used */
-#define SFW_MAX_CONCUR     LST_MAX_CONCUR
+#define SFW_MAX_CONCUR	   LST_MAX_CONCUR
 #define SFW_ID_PER_PAGE    (PAGE_CACHE_SIZE / sizeof(lnet_process_id_packed_t))
-#define SFW_MAX_NDESTS     (LNET_MAX_IOV * SFW_ID_PER_PAGE)
+#define SFW_MAX_NDESTS	   (LNET_MAX_IOV * SFW_ID_PER_PAGE)
 #define sfw_id_pages(n)    (((n) + SFW_ID_PER_PAGE - 1) / SFW_ID_PER_PAGE)
 
 typedef struct sfw_test_unit {
-	struct list_head    tsu_list;      /* chain on lst_test_instance */
-	lnet_process_id_t   tsu_dest;      /* id of dest node */
-	int                 tsu_loop;      /* loop count of the test */
+	struct list_head    tsu_list;	   /* chain on lst_test_instance */
+	lnet_process_id_t   tsu_dest;	   /* id of dest node */
+	int		    tsu_loop;	   /* loop count of the test */
 	sfw_test_instance_t *tsu_instance; /* pointer to test instance */
-	void                *tsu_private;  /* private data */
-	swi_workitem_t      tsu_worker;    /* workitem of the test unit */
+	void		    *tsu_private;  /* private data */
+	swi_workitem_t	    tsu_worker;    /* workitem of the test unit */
 } sfw_test_unit_t;
 
 typedef struct sfw_test_case {
-	struct list_head      tsc_list;         /* chain on fw_tests */
-	srpc_service_t        *tsc_srv_service; /* test service */
-	sfw_test_client_ops_t *tsc_cli_ops;     /* ops of test client */
+	struct list_head      tsc_list;		/* chain on fw_tests */
+	srpc_service_t	      *tsc_srv_service; /* test service */
+	sfw_test_client_ops_t *tsc_cli_ops;	/* ops of test client */
 } sfw_test_case_t;
 
 srpc_client_rpc_t *
@@ -511,7 +511,7 @@ srpc_destroy_client_rpc(srpc_client_rpc_t *rpc)
 	if (!rpc->crpc_fini)
 		LIBCFS_FREE(rpc, srpc_client_rpc_size(rpc));
 	else
-		(*rpc->crpc_fini) (rpc);
+		(*rpc->crpc_fini)(rpc);
 }
 
 static inline void
diff --git a/drivers/staging/lustre/lnet/selftest/timer.c b/drivers/staging/lustre/lnet/selftest/timer.c
index f9f37ba..8be5252 100644
--- a/drivers/staging/lustre/lnet/selftest/timer.c
+++ b/drivers/staging/lustre/lnet/selftest/timer.c
@@ -57,13 +57,13 @@
 						    (STTIMER_NSLOTS - 1))])
 
 static struct st_timer_data {
-	spinlock_t        stt_lock;
-	unsigned long     stt_prev_slot; /* start time of the slot processed
+	spinlock_t	  stt_lock;
+	unsigned long	  stt_prev_slot; /* start time of the slot processed
 					  * previously */
 	struct list_head  stt_hash[STTIMER_NSLOTS];
-	int               stt_shuttingdown;
+	int		  stt_shuttingdown;
 	wait_queue_head_t stt_waitq;
-	int               stt_nthreads;
+	int		  stt_nthreads;
 } stt_data;
 
 void
diff --git a/drivers/staging/lustre/lnet/selftest/timer.h b/drivers/staging/lustre/lnet/selftest/timer.h
index 39327bb..f1fbebd 100644
--- a/drivers/staging/lustre/lnet/selftest/timer.h
+++ b/drivers/staging/lustre/lnet/selftest/timer.h
@@ -40,9 +40,9 @@
 
 struct stt_timer {
 	struct list_head stt_list;
-	time64_t         stt_expires;
-	void             (*stt_func)(void *);
-	void             *stt_data;
+	time64_t	 stt_expires;
+	void		 (*stt_func)(void *);
+	void		 *stt_data;
 };
 
 void stt_add_timer(struct stt_timer *timer);
-- 
1.7.1
