From: James Simmons <jsimmons@infradead.org>
Date: Thu, 31 Jan 2019 12:19:07 -0500
Subject: [lustre-devel] [PATCH 03/26] lnet: use kernel types for lnet
 selftest kernel code
In-Reply-To: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
References: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1548955170-13456-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

LNet self test was originally both a user land and kernel
implementation. The source contains many types of the
form __u32 but since this is mostly kernel code change
the types to kernel internal types.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/selftest/brw_test.c |  20 ++--
 drivers/staging/lustre/lnet/selftest/console.h  |   2 +-
 drivers/staging/lustre/lnet/selftest/rpc.c      |  22 ++--
 drivers/staging/lustre/lnet/selftest/rpc.h      | 132 ++++++++++++------------
 4 files changed, 88 insertions(+), 88 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
index e372ff3..eb8b1e9 100644
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -153,7 +153,7 @@ static int brw_inject_one_error(void)
 }
 
 static void
-brw_fill_page(struct page *pg, int off, int len, int pattern, __u64 magic)
+brw_fill_page(struct page *pg, int off, int len, int pattern, u64 magic)
 {
 	char *addr = page_address(pg) + off;
 	int i;
@@ -186,10 +186,10 @@ static int brw_inject_one_error(void)
 }
 
 static int
-brw_check_page(struct page *pg, int off, int len, int pattern, __u64 magic)
+brw_check_page(struct page *pg, int off, int len, int pattern, u64 magic)
 {
 	char *addr = page_address(pg) + off;
-	__u64 data = 0; /* make compiler happy */
+	u64 data = 0; /* make compiler happy */
 	int i;
 
 	LASSERT(addr);
@@ -199,13 +199,13 @@ static int brw_inject_one_error(void)
 		return 0;
 
 	if (pattern == LST_BRW_CHECK_SIMPLE) {
-		data = *((__u64 *)addr);
+		data = *((u64 *)addr);
 		if (data != magic)
 			goto bad_data;
 
 		if (len > BRW_MSIZE) {
 			addr += PAGE_SIZE - BRW_MSIZE;
-			data = *((__u64 *)addr);
+			data = *((u64 *)addr);
 			if (data != magic)
 				goto bad_data;
 		}
@@ -230,7 +230,7 @@ static int brw_inject_one_error(void)
 }
 
 static void
-brw_fill_bulk(struct srpc_bulk *bk, int pattern, __u64 magic)
+brw_fill_bulk(struct srpc_bulk *bk, int pattern, u64 magic)
 {
 	int i;
 	struct page *pg;
@@ -246,7 +246,7 @@ static int brw_inject_one_error(void)
 }
 
 static int
-brw_check_bulk(struct srpc_bulk *bk, int pattern, __u64 magic)
+brw_check_bulk(struct srpc_bulk *bk, int pattern, u64 magic)
 {
 	int i;
 	struct page *pg;
@@ -331,7 +331,7 @@ static int brw_inject_one_error(void)
 static void
 brw_client_done_rpc(struct sfw_test_unit *tsu, struct srpc_client_rpc *rpc)
 {
-	__u64 magic = BRW_MAGIC;
+	u64 magic = BRW_MAGIC;
 	struct sfw_test_instance *tsi = tsu->tsu_instance;
 	struct sfw_session *sn = tsi->tsi_batch->bat_session;
 	struct srpc_msg *msg = &rpc->crpc_replymsg;
@@ -397,7 +397,7 @@ static int brw_inject_one_error(void)
 static int
 brw_bulk_ready(struct srpc_server_rpc *rpc, int status)
 {
-	__u64 magic = BRW_MAGIC;
+	u64 magic = BRW_MAGIC;
 	struct srpc_brw_reply *reply = &rpc->srpc_replymsg.msg_body.brw_reply;
 	struct srpc_brw_reqst *reqst;
 	struct srpc_msg *reqstmsg;
@@ -452,7 +452,7 @@ static int brw_inject_one_error(void)
 		__swab64s(&reqst->brw_rpyid);
 		__swab64s(&reqst->brw_bulkid);
 	}
-	LASSERT(reqstmsg->msg_type == (__u32)srpc_service2request(sv->sv_id));
+	LASSERT(reqstmsg->msg_type == (u32)srpc_service2request(sv->sv_id));
 
 	reply->brw_status = 0;
 	rpc->srpc_done = brw_server_rpc_done;
diff --git a/drivers/staging/lustre/lnet/selftest/console.h b/drivers/staging/lustre/lnet/selftest/console.h
index eaad07c..b5709a4 100644
--- a/drivers/staging/lustre/lnet/selftest/console.h
+++ b/drivers/staging/lustre/lnet/selftest/console.h
@@ -153,7 +153,7 @@ struct lstcon_session {
 	unsigned int	    ses_force:1;      /* force creating */
 	unsigned int	    ses_shutdown:1;   /* session is shutting down */
 	unsigned int	    ses_expired:1;    /* console is timedout */
-	__u64		    ses_id_cookie;    /* batch id cookie */
+	u64		    ses_id_cookie;    /* batch id cookie */
 	char		    ses_name[LST_NAME_SIZE];/* session name */
 	struct lstcon_rpc_trans	*ses_ping;		/* session pinger */
 	struct stt_timer	 ses_ping_timer;   /* timer for pinger */
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index 26132ab..2a30107 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -57,7 +57,7 @@ enum srpc_state {
 	struct lnet_handle_eq	 rpc_lnet_eq;	/* _the_ LNet event queue */
 	enum srpc_state	 rpc_state;
 	struct srpc_counters	 rpc_counters;
-	__u64		 rpc_matchbits;	/* matchbits counter */
+	u64		 rpc_matchbits;	/* matchbits counter */
 } srpc_data;
 
 static inline int
@@ -159,10 +159,10 @@ struct srpc_bulk *
 	return bk;
 }
 
-static inline __u64
+static inline u64
 srpc_next_id(void)
 {
-	__u64 id;
+	u64 id;
 
 	spin_lock(&srpc_data.rpc_glock);
 	id = srpc_data.rpc_matchbits++;
@@ -354,7 +354,7 @@ struct srpc_bulk *
 }
 
 static int
-srpc_post_passive_rdma(int portal, int local, __u64 matchbits, void *buf,
+srpc_post_passive_rdma(int portal, int local, u64 matchbits, void *buf,
 		       int len, int options, struct lnet_process_id peer,
 		       struct lnet_handle_md *mdh, struct srpc_event *ev)
 {
@@ -393,7 +393,7 @@ struct srpc_bulk *
 }
 
 static int
-srpc_post_active_rdma(int portal, __u64 matchbits, void *buf, int len,
+srpc_post_active_rdma(int portal, u64 matchbits, void *buf, int len,
 		      int options, struct lnet_process_id peer,
 		      lnet_nid_t self, struct lnet_handle_md *mdh,
 		      struct srpc_event *ev)
@@ -813,7 +813,7 @@ struct srpc_bulk *
 srpc_prepare_reply(struct srpc_client_rpc *rpc)
 {
 	struct srpc_event *ev = &rpc->crpc_replyev;
-	__u64 *id = &rpc->crpc_reqstmsg.msg_body.reqst.rpyid;
+	u64 *id = &rpc->crpc_reqstmsg.msg_body.reqst.rpyid;
 	int rc;
 
 	ev->ev_fired = 0;
@@ -839,7 +839,7 @@ struct srpc_bulk *
 {
 	struct srpc_bulk *bk = &rpc->crpc_bulk;
 	struct srpc_event *ev = &rpc->crpc_bulkev;
-	__u64 *id = &rpc->crpc_reqstmsg.msg_body.reqst.bulkid;
+	u64 *id = &rpc->crpc_reqstmsg.msg_body.reqst.bulkid;
 	int rc;
 	int opt;
 
@@ -872,7 +872,7 @@ struct srpc_bulk *
 {
 	struct srpc_event *ev = &rpc->srpc_ev;
 	struct srpc_bulk *bk = rpc->srpc_bulk;
-	__u64 id = rpc->srpc_reqstbuf->buf_msg.msg_body.reqst.bulkid;
+	u64 id = rpc->srpc_reqstbuf->buf_msg.msg_body.reqst.bulkid;
 	int rc;
 	int opt;
 
@@ -1362,7 +1362,7 @@ struct srpc_client_rpc *
 	struct srpc_buffer *buffer = rpc->srpc_reqstbuf;
 	struct srpc_service_cd *scd = rpc->srpc_scd;
 	struct srpc_service *sv = scd->scd_svc;
-	__u64 rpyid;
+	u64 rpyid;
 	int rc;
 
 	LASSERT(buffer);
@@ -1415,7 +1415,7 @@ struct srpc_client_rpc *
 	LASSERT(!in_interrupt());
 
 	if (ev->status) {
-		__u32 errors;
+		u32 errors;
 
 		spin_lock(&srpc_data.rpc_glock);
 		if (ev->status != -ECANCELED) /* cancellation is not error */
@@ -1604,7 +1604,7 @@ struct srpc_client_rpc *
 
 	/* 1 second pause to avoid timestamp reuse */
 	schedule_timeout_uninterruptible(HZ);
-	srpc_data.rpc_matchbits = ((__u64)ktime_get_real_seconds()) << 48;
+	srpc_data.rpc_matchbits = ((u64)ktime_get_real_seconds()) << 48;
 
 	srpc_data.rpc_state = SRPC_STATE_NONE;
 
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.h b/drivers/staging/lustre/lnet/selftest/rpc.h
index 9ce3367..ae1c07f 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.h
+++ b/drivers/staging/lustre/lnet/selftest/rpc.h
@@ -66,70 +66,70 @@ enum srpc_msg_type {
  * All srpc_*_reqst_t's 1st field must be matchbits of reply buffer,
  * and 2nd field matchbits of bulk buffer if any.
  *
- * All srpc_*_reply_t's 1st field must be a __u32 status, and 2nd field
+ * All srpc_*_reply_t's 1st field must be a u32 status, and 2nd field
  * session id if needed.
  */
 struct srpc_generic_reqst {
-	__u64			rpyid;		/* reply buffer matchbits */
-	__u64			bulkid;		/* bulk buffer matchbits */
+	u64			rpyid;		/* reply buffer matchbits */
+	u64			bulkid;		/* bulk buffer matchbits */
 } __packed;
 
 struct srpc_generic_reply {
-	__u32			status;
+	u32			status;
 	struct lst_sid		sid;
 } __packed;
 
 /* FRAMEWORK RPCs */
 struct srpc_mksn_reqst {
-	__u64			mksn_rpyid;	/* reply buffer matchbits */
+	u64			mksn_rpyid;	/* reply buffer matchbits */
 	struct lst_sid		mksn_sid;	/* session id */
-	__u32			mksn_force;	/* use brute force */
+	u32			mksn_force;	/* use brute force */
 	char			mksn_name[LST_NAME_SIZE];
 } __packed; /* make session request */
 
 struct srpc_mksn_reply {
-	__u32			mksn_status;	/* session status */
+	u32			mksn_status;	/* session status */
 	struct lst_sid		mksn_sid;	/* session id */
-	__u32			mksn_timeout;	/* session timeout */
+	u32			mksn_timeout;	/* session timeout */
 	char			mksn_name[LST_NAME_SIZE];
 } __packed; /* make session reply */
 
 struct srpc_rmsn_reqst {
-	__u64			rmsn_rpyid;	/* reply buffer matchbits */
+	u64			rmsn_rpyid;	/* reply buffer matchbits */
 	struct lst_sid		rmsn_sid;	/* session id */
 } __packed; /* remove session request */
 
 struct srpc_rmsn_reply {
-	__u32			rmsn_status;
+	u32			rmsn_status;
 	struct lst_sid		rmsn_sid;	/* session id */
 } __packed; /* remove session reply */
 
 struct srpc_join_reqst {
-	__u64			join_rpyid;	/* reply buffer matchbits */
+	u64			join_rpyid;	/* reply buffer matchbits */
 	struct lst_sid		join_sid;	/* session id to join */
 	char			join_group[LST_NAME_SIZE]; /* group name */
 } __packed;
 
 struct srpc_join_reply {
-	__u32			join_status;	/* returned status */
+	u32			join_status;	/* returned status */
 	struct lst_sid		join_sid;	/* session id */
-	__u32			join_timeout;	/* # seconds' inactivity to
+	u32			join_timeout;	/* # seconds' inactivity to
 						 * expire
 						 */
 	char			join_session[LST_NAME_SIZE]; /* session name */
 } __packed;
 
 struct srpc_debug_reqst {
-	__u64			dbg_rpyid;	/* reply buffer matchbits */
+	u64			dbg_rpyid;	/* reply buffer matchbits */
 	struct lst_sid		dbg_sid;	/* session id */
-	__u32			dbg_flags;	/* bitmap of debug */
+	u32			dbg_flags;	/* bitmap of debug */
 } __packed;
 
 struct srpc_debug_reply {
-	__u32			dbg_status;	/* returned code */
+	u32			dbg_status;	/* returned code */
 	struct lst_sid		dbg_sid;	/* session id */
-	__u32			dbg_timeout;	/* session timeout */
-	__u32			dbg_nbatch;	/* # of batches in the node */
+	u32			dbg_timeout;	/* session timeout */
+	u32			dbg_nbatch;	/* # of batches in the node */
 	char			dbg_name[LST_NAME_SIZE]; /* session name */
 } __packed;
 
@@ -138,29 +138,29 @@ struct srpc_debug_reply {
 #define SRPC_BATCH_OPC_QUERY	3
 
 struct srpc_batch_reqst {
-	__u64		   bar_rpyid;	   /* reply buffer matchbits */
+	u64		   bar_rpyid;	   /* reply buffer matchbits */
 	struct lst_sid	   bar_sid;	   /* session id */
 	struct lst_bid	   bar_bid;	   /* batch id */
-	__u32		   bar_opc;	   /* create/start/stop batch */
-	__u32		   bar_testidx;    /* index of test */
-	__u32		   bar_arg;	   /* parameters */
+	u32		   bar_opc;	   /* create/start/stop batch */
+	u32		   bar_testidx;    /* index of test */
+	u32		   bar_arg;	   /* parameters */
 } __packed;
 
 struct srpc_batch_reply {
-	__u32		   bar_status;	   /* status of request */
+	u32		   bar_status;	   /* status of request */
 	struct lst_sid	   bar_sid;	   /* session id */
-	__u32		   bar_active;	   /* # of active tests in batch/test */
-	__u32		   bar_time;	   /* remained time */
+	u32		   bar_active;	   /* # of active tests in batch/test */
+	u32		   bar_time;	   /* remained time */
 } __packed;
 
 struct srpc_stat_reqst {
-	__u64		   str_rpyid;	   /* reply buffer matchbits */
+	u64		   str_rpyid;	   /* reply buffer matchbits */
 	struct lst_sid	   str_sid;	   /* session id */
-	__u32		   str_type;	   /* type of stat */
+	u32		   str_type;	   /* type of stat */
 } __packed;
 
 struct srpc_stat_reply {
-	__u32		   str_status;
+	u32		   str_status;
 	struct lst_sid	   str_sid;
 	struct sfw_counters	str_fw;
 	struct srpc_counters	str_rpc;
@@ -168,36 +168,36 @@ struct srpc_stat_reply {
 } __packed;
 
 struct test_bulk_req {
-	__u32		   blk_opc;	   /* bulk operation code */
-	__u32		   blk_npg;	   /* # of pages */
-	__u32		   blk_flags;	   /* reserved flags */
+	u32		   blk_opc;	   /* bulk operation code */
+	u32		   blk_npg;	   /* # of pages */
+	u32		   blk_flags;	   /* reserved flags */
 } __packed;
 
 struct test_bulk_req_v1 {
-	__u16		   blk_opc;	   /* bulk operation code */
-	__u16		   blk_flags;	   /* data check flags */
-	__u32		   blk_len;	   /* data length */
-	__u32		   blk_offset;	   /* offset */
+	u16		   blk_opc;	   /* bulk operation code */
+	u16		   blk_flags;	   /* data check flags */
+	u32		   blk_len;	   /* data length */
+	u32		   blk_offset;	   /* offset */
 } __packed;
 
 struct test_ping_req {
-	__u32		   png_size;	   /* size of ping message */
-	__u32		   png_flags;	   /* reserved flags */
+	u32		   png_size;	   /* size of ping message */
+	u32		   png_flags;	   /* reserved flags */
 } __packed;
 
 struct srpc_test_reqst {
-	__u64			tsr_rpyid;	/* reply buffer matchbits */
-	__u64			tsr_bulkid;	/* bulk buffer matchbits */
+	u64			tsr_rpyid;	/* reply buffer matchbits */
+	u64			tsr_bulkid;	/* bulk buffer matchbits */
 	struct lst_sid		tsr_sid;	/* session id */
 	struct lst_bid		tsr_bid;	/* batch id */
-	__u32			tsr_service;	/* test type: bulk|ping|... */
-	__u32			tsr_loop;	/* test client loop count or
+	u32			tsr_service;	/* test type: bulk|ping|... */
+	u32			tsr_loop;	/* test client loop count or
 						 * # server buffers needed
 						 */
-	__u32			tsr_concur;	/* concurrency of test */
-	__u8			tsr_is_client;	/* is test client or not */
-	__u8			tsr_stop_onerr; /* stop on error */
-	__u32			tsr_ndest;	/* # of dest nodes */
+	u32			tsr_concur;	/* concurrency of test */
+	u8			tsr_is_client;	/* is test client or not */
+	u8			tsr_stop_onerr; /* stop on error */
+	u32			tsr_ndest;	/* # of dest nodes */
 
 	union {
 		struct test_ping_req	ping;
@@ -207,47 +207,47 @@ struct srpc_test_reqst {
 } __packed;
 
 struct srpc_test_reply {
-	__u32			tsr_status;	/* returned code */
+	u32			tsr_status;	/* returned code */
 	struct lst_sid		tsr_sid;
 } __packed;
 
 /* TEST RPCs */
 struct srpc_ping_reqst {
-	__u64		   pnr_rpyid;
-	__u32		   pnr_magic;
-	__u32		   pnr_seq;
-	__u64		   pnr_time_sec;
-	__u64		   pnr_time_usec;
+	u64		   pnr_rpyid;
+	u32		   pnr_magic;
+	u32		   pnr_seq;
+	u64		   pnr_time_sec;
+	u64		   pnr_time_usec;
 } __packed;
 
 struct srpc_ping_reply {
-	__u32		   pnr_status;
-	__u32		   pnr_magic;
-	__u32		   pnr_seq;
+	u32		   pnr_status;
+	u32		   pnr_magic;
+	u32		   pnr_seq;
 } __packed;
 
 struct srpc_brw_reqst {
-	__u64		   brw_rpyid;	   /* reply buffer matchbits */
-	__u64		   brw_bulkid;	   /* bulk buffer matchbits */
-	__u32		   brw_rw;	   /* read or write */
-	__u32		   brw_len;	   /* bulk data len */
-	__u32		   brw_flags;	   /* bulk data patterns */
+	u64		   brw_rpyid;	   /* reply buffer matchbits */
+	u64		   brw_bulkid;	   /* bulk buffer matchbits */
+	u32		   brw_rw;	   /* read or write */
+	u32		   brw_len;	   /* bulk data len */
+	u32		   brw_flags;	   /* bulk data patterns */
 } __packed; /* bulk r/w request */
 
 struct srpc_brw_reply {
-	__u32		   brw_status;
+	u32		   brw_status;
 } __packed; /* bulk r/w reply */
 
 #define SRPC_MSG_MAGIC		0xeeb0f00d
 #define SRPC_MSG_VERSION	1
 
 struct srpc_msg {
-	__u32	msg_magic;     /* magic number */
-	__u32	msg_version;   /* message version number */
-	__u32	msg_type;      /* type of message body: srpc_msg_type */
-	__u32	msg_reserved0;
-	__u32	msg_reserved1;
-	__u32	msg_ses_feats; /* test session features */
+	u32	msg_magic;     /* magic number */
+	u32	msg_version;   /* message version number */
+	u32	msg_type;      /* type of message body: srpc_msg_type */
+	u32	msg_reserved0;
+	u32	msg_reserved1;
+	u32	msg_ses_feats; /* test session features */
 	union {
 		struct srpc_generic_reqst	reqst;
 		struct srpc_generic_reply	reply;
-- 
1.8.3.1
