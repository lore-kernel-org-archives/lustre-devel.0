From: James Simmons <jsimmons@infradead.org>
Date: Mon, 16 Jan 2017 16:30:04 -0500
Subject: [lustre-devel] [PATCH 01/34] staging: lustre: lnet: change
	lst_nid_t to proper structure
In-Reply-To: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
References: <1484602237-30867-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1484602237-30867-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lst_nid_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6142
Reviewed-on: https://review.whamcloud.com/24188
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/lnetst.h | 12 ++++-----
 drivers/staging/lustre/lnet/selftest/conrpc.c      |  2 +-
 drivers/staging/lustre/lnet/selftest/console.c     | 12 ++++-----
 drivers/staging/lustre/lnet/selftest/console.h     |  8 +++---
 drivers/staging/lustre/lnet/selftest/framework.c   |  4 +--
 drivers/staging/lustre/lnet/selftest/rpc.h         | 30 +++++++++++-----------
 drivers/staging/lustre/lnet/selftest/selftest.h    |  2 +-
 7 files changed, 35 insertions(+), 35 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lnetst.h b/drivers/staging/lustre/include/linux/lnet/lnetst.h
index 8a84888..68c7f58 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -68,12 +68,12 @@
 #define LSTIO_BATCH_QUERY	0xC27	/* query batch status */
 #define LSTIO_STAT_QUERY	0xC30	/* get stats */
 
-typedef struct {
+struct lst_sid {
 	lnet_nid_t	ses_nid;	/* nid of console node */
 	__u64		ses_stamp;	/* time stamp */
-} lst_sid_t;				/*** session id */
+};					/*** session id */
 
-extern lst_sid_t LST_INVALID_SID;
+extern struct lst_sid LST_INVALID_SID;
 
 typedef struct {
 	__u64	bat_id;		/* unique id in session */
@@ -131,7 +131,7 @@
 	int			rpe_state;	/* peer's state */
 	int			rpe_rpc_errno;	/* RPC errno */
 
-	lst_sid_t		rpe_sid;	/* peer's session id */
+	struct lst_sid		rpe_sid;	/* peer's session id */
 	int			rpe_fwk_errno;	/* framework errno */
 	int			rpe_priv[4];	/* private data */
 	char			rpe_payload[0];	/* private reply payload */
@@ -245,14 +245,14 @@
 	int		 lstio_ses_force;	/* IN: force create ? */
 	/** IN: session features */
 	unsigned int	 lstio_ses_feats;
-	lst_sid_t __user *lstio_ses_idp;	/* OUT: session id */
+	struct lst_sid __user *lstio_ses_idp;	/* OUT: session id */
 	int		 lstio_ses_nmlen;	/* IN: name length */
 	char __user	 *lstio_ses_namep;	/* IN: session name */
 } lstio_session_new_args_t;
 
 /* query current session */
 typedef struct {
-	lst_sid_t __user	*lstio_ses_idp;		/* OUT: session id */
+	struct lst_sid __user	*lstio_ses_idp;		/* OUT: session id */
 	int __user		*lstio_ses_keyp;	/* OUT: local key */
 	/** OUT: session features */
 	unsigned int __user	*lstio_ses_featp;
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index 994422c..84ae010 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -519,7 +519,7 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 		/* RPC is done */
 		rep = (struct srpc_generic_reply *)&msg->msg_body.reply;
 
-		if (copy_to_user(&ent->rpe_sid, &rep->sid, sizeof(lst_sid_t)) ||
+		if (copy_to_user(&ent->rpe_sid, &rep->sid, sizeof(rep->sid)) ||
 		    copy_to_user(&ent->rpe_fwk_errno, &rep->status,
 				 sizeof(rep->status)))
 			return -EFAULT;
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 1456d239..02dbfef 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -1688,14 +1688,14 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 }
 
 int
-lstcon_session_match(lst_sid_t sid)
+lstcon_session_match(struct lst_sid sid)
 {
 	return (console_session.ses_id.ses_nid == sid.ses_nid &&
 		console_session.ses_id.ses_stamp == sid.ses_stamp) ? 1 : 0;
 }
 
 static void
-lstcon_new_session_id(lst_sid_t *sid)
+lstcon_new_session_id(struct lst_sid *sid)
 {
 	lnet_process_id_t id;
 
@@ -1708,7 +1708,7 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 
 int
 lstcon_session_new(char *name, int key, unsigned int feats,
-		   int timeout, int force, lst_sid_t __user *sid_up)
+		   int timeout, int force, struct lst_sid __user *sid_up)
 {
 	int rc = 0;
 	int i;
@@ -1767,7 +1767,7 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 	}
 
 	if (!copy_to_user(sid_up, &console_session.ses_id,
-			  sizeof(lst_sid_t)))
+			  sizeof(struct lst_sid)))
 		return rc;
 
 	lstcon_session_end();
@@ -1776,7 +1776,7 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 }
 
 int
-lstcon_session_info(lst_sid_t __user *sid_up, int __user *key_up,
+lstcon_session_info(struct lst_sid __user *sid_up, int __user *key_up,
 		    unsigned __user *featp,
 		    lstcon_ndlist_ent_t __user *ndinfo_up,
 		    char __user *name_up, int len)
@@ -1796,7 +1796,7 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 		LST_NODE_STATE_COUNTER(ndl->ndl_node, entp);
 
 	if (copy_to_user(sid_up, &console_session.ses_id,
-			 sizeof(lst_sid_t)) ||
+			 sizeof(*sid_up)) ||
 	    copy_to_user(key_up, &console_session.ses_key,
 			 sizeof(*key_up)) ||
 	    copy_to_user(featp, &console_session.ses_features,
diff --git a/drivers/staging/lustre/lnet/selftest/console.h b/drivers/staging/lustre/lnet/selftest/console.h
index 5dc1de4..4bf7ecd 100644
--- a/drivers/staging/lustre/lnet/selftest/console.h
+++ b/drivers/staging/lustre/lnet/selftest/console.h
@@ -140,7 +140,7 @@ struct lstcon_test {
 
 struct lstcon_session {
 	struct mutex	    ses_mutex;	      /* only 1 thread in session */
-	lst_sid_t	    ses_id;	      /* global session id */
+	struct lst_sid	    ses_id;	      /* global session id */
 	int		    ses_key;	      /* local session key */
 	int		    ses_state;	      /* state of session */
 	int		    ses_timeout;      /* timeout in seconds */
@@ -190,10 +190,10 @@ struct lstcon_session {
 int lstcon_ioctl_entry(unsigned int cmd, struct libcfs_ioctl_hdr *hdr);
 int lstcon_console_init(void);
 int lstcon_console_fini(void);
-int lstcon_session_match(lst_sid_t sid);
+int lstcon_session_match(struct lst_sid sid);
 int lstcon_session_new(char *name, int key, unsigned int version,
-		       int timeout, int flags, lst_sid_t __user *sid_up);
-int lstcon_session_info(lst_sid_t __user *sid_up, int __user *key,
+		       int timeout, int flags, struct lst_sid __user *sid_up);
+int lstcon_session_info(struct lst_sid __user *sid_up, int __user *key,
 			unsigned __user *verp, lstcon_ndlist_ent_t __user *entp,
 			char __user *name_up, int len);
 int lstcon_session_end(void);
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 48dcc330..4100f67 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -39,7 +39,7 @@
 
 #include "selftest.h"
 
-lst_sid_t LST_INVALID_SID = {LNET_NID_ANY, -1};
+struct lst_sid LST_INVALID_SID = {LNET_NID_ANY, -1};
 
 static int session_timeout = 100;
 module_param(session_timeout, int, 0444);
@@ -254,7 +254,7 @@
 }
 
 static inline void
-sfw_init_session(struct sfw_session *sn, lst_sid_t sid,
+sfw_init_session(struct sfw_session *sn, struct lst_sid sid,
 		 unsigned int features, const char *name)
 {
 	struct stt_timer *timer = &sn->sn_timer;
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.h b/drivers/staging/lustre/lnet/selftest/rpc.h
index f353a63..3324c3f 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.h
+++ b/drivers/staging/lustre/lnet/selftest/rpc.h
@@ -75,43 +75,43 @@ struct srpc_generic_reqst {
 
 struct srpc_generic_reply {
 	__u32			status;
-	lst_sid_t		sid;
+	struct lst_sid		sid;
 } WIRE_ATTR;
 
 /* FRAMEWORK RPCs */
 struct srpc_mksn_reqst {
 	__u64			mksn_rpyid;	/* reply buffer matchbits */
-	lst_sid_t		mksn_sid;	/* session id */
+	struct lst_sid		mksn_sid;	/* session id */
 	__u32			mksn_force;	/* use brute force */
 	char			mksn_name[LST_NAME_SIZE];
 } WIRE_ATTR; /* make session request */
 
 struct srpc_mksn_reply {
 	__u32			mksn_status;	/* session status */
-	lst_sid_t		mksn_sid;	/* session id */
+	struct lst_sid		mksn_sid;	/* session id */
 	__u32			mksn_timeout;	/* session timeout */
 	char			mksn_name[LST_NAME_SIZE];
 } WIRE_ATTR; /* make session reply */
 
 struct srpc_rmsn_reqst {
 	__u64			rmsn_rpyid;	/* reply buffer matchbits */
-	lst_sid_t		rmsn_sid;	/* session id */
+	struct lst_sid		rmsn_sid;	/* session id */
 } WIRE_ATTR; /* remove session request */
 
 struct srpc_rmsn_reply {
 	__u32			rmsn_status;
-	lst_sid_t		rmsn_sid;	/* session id */
+	struct lst_sid		rmsn_sid;	/* session id */
 } WIRE_ATTR; /* remove session reply */
 
 struct srpc_join_reqst {
 	__u64			join_rpyid;	/* reply buffer matchbits */
-	lst_sid_t		join_sid;	/* session id to join */
+	struct lst_sid		join_sid;	/* session id to join */
 	char			join_group[LST_NAME_SIZE]; /* group name */
 } WIRE_ATTR;
 
 struct srpc_join_reply {
 	__u32			join_status;	/* returned status */
-	lst_sid_t		join_sid;	/* session id */
+	struct lst_sid		join_sid;	/* session id */
 	__u32			join_timeout;	/* # seconds' inactivity to
 						 * expire
 						 */
@@ -120,13 +120,13 @@ struct srpc_join_reply {
 
 struct srpc_debug_reqst {
 	__u64			dbg_rpyid;	/* reply buffer matchbits */
-	lst_sid_t		dbg_sid;	/* session id */
+	struct lst_sid		dbg_sid;	/* session id */
 	__u32			dbg_flags;	/* bitmap of debug */
 } WIRE_ATTR;
 
 struct srpc_debug_reply {
 	__u32			dbg_status;	/* returned code */
-	lst_sid_t		dbg_sid;	/* session id */
+	struct lst_sid		dbg_sid;	/* session id */
 	__u32			dbg_timeout;	/* session timeout */
 	__u32			dbg_nbatch;	/* # of batches in the node */
 	char			dbg_name[LST_NAME_SIZE]; /* session name */
@@ -138,7 +138,7 @@ struct srpc_debug_reply {
 
 struct srpc_batch_reqst {
 	__u64		   bar_rpyid;	   /* reply buffer matchbits */
-	lst_sid_t	   bar_sid;	   /* session id */
+	struct lst_sid	   bar_sid;	   /* session id */
 	lst_bid_t	   bar_bid;	   /* batch id */
 	__u32		   bar_opc;	   /* create/start/stop batch */
 	__u32		   bar_testidx;    /* index of test */
@@ -147,20 +147,20 @@ struct srpc_batch_reqst {
 
 struct srpc_batch_reply {
 	__u32		   bar_status;	   /* status of request */
-	lst_sid_t	   bar_sid;	   /* session id */
+	struct lst_sid	   bar_sid;	   /* session id */
 	__u32		   bar_active;	   /* # of active tests in batch/test */
 	__u32		   bar_time;	   /* remained time */
 } WIRE_ATTR;
 
 struct srpc_stat_reqst {
 	__u64		   str_rpyid;	   /* reply buffer matchbits */
-	lst_sid_t	   str_sid;	   /* session id */
+	struct lst_sid	   str_sid;	   /* session id */
 	__u32		   str_type;	   /* type of stat */
 } WIRE_ATTR;
 
 struct srpc_stat_reply {
 	__u32		   str_status;
-	lst_sid_t	   str_sid;
+	struct lst_sid	   str_sid;
 	sfw_counters_t	   str_fw;
 	srpc_counters_t    str_rpc;
 	lnet_counters_t    str_lnet;
@@ -187,7 +187,7 @@ struct test_ping_req {
 struct srpc_test_reqst {
 	__u64			tsr_rpyid;	/* reply buffer matchbits */
 	__u64			tsr_bulkid;	/* bulk buffer matchbits */
-	lst_sid_t		tsr_sid;	/* session id */
+	struct lst_sid		tsr_sid;	/* session id */
 	lst_bid_t		tsr_bid;	/* batch id */
 	__u32			tsr_service;	/* test type: bulk|ping|... */
 	__u32			tsr_loop;	/* test client loop count or
@@ -207,7 +207,7 @@ struct srpc_test_reqst {
 
 struct srpc_test_reply {
 	__u32			tsr_status;	/* returned code */
-	lst_sid_t		tsr_sid;
+	struct lst_sid		tsr_sid;
 } WIRE_ATTR;
 
 /* TEST RPCs */
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index c8833a0..35f98ae 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -322,7 +322,7 @@ struct srpc_service {
 
 struct sfw_session {
 	struct list_head sn_list;    /* chain on fw_zombie_sessions */
-	lst_sid_t	 sn_id;      /* unique identifier */
+	struct lst_sid	 sn_id;      /* unique identifier */
 	unsigned int	 sn_timeout; /* # seconds' inactivity to expire */
 	int		 sn_timer_active;
 	unsigned int	 sn_features;
-- 
1.8.3.1
