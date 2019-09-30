From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:56:50 -0400
Subject: [lustre-devel] [PATCH 151/151] lustre: clean up some comment
 alignment.
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-152-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.com>

This patch resulted from search for "<tab><space>/*" and
cleaning up the alignment, often removing the space and
possibly inserting a tab, but sometimes leaving spaces
after tabs, particularly in structure declarations.

Signed-off-by: NeilBrown <neilb@suse.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lprocfs_status.h       |  2 +-
 fs/lustre/include/lustre_import.h        |  4 +-
 fs/lustre/include/lustre_net.h           |  8 +--
 fs/lustre/include/obd.h                  | 14 ++---
 fs/lustre/include/obd_support.h          |  2 +-
 fs/lustre/ldlm/ldlm_lockd.c              |  2 +-
 fs/lustre/llite/llite_internal.h         | 10 ++--
 fs/lustre/mdc/mdc_lib.c                  |  2 +-
 fs/lustre/obdclass/llog.c                |  2 +-
 fs/lustre/obdclass/lprocfs_status.c      |  4 +-
 fs/lustre/obdecho/echo_client.c          |  2 +-
 fs/lustre/ptlrpc/client.c                |  4 +-
 fs/lustre/ptlrpc/niobuf.c                |  4 +-
 fs/lustre/ptlrpc/pack_generic.c          |  2 +-
 fs/lustre/ptlrpc/sec_null.c              |  4 +-
 fs/lustre/ptlrpc/sec_plain.c             |  6 +-
 fs/lustre/ptlrpc/service.c               | 10 ++--
 fs/lustre/ptlrpc/wiretest.c              | 12 ++--
 include/linux/libcfs/libcfs_debug.h      |  4 +-
 include/linux/lnet/lib-types.h           |  8 +--
 include/uapi/linux/lustre/lustre_idl.h   | 34 +++++------
 include/uapi/linux/lustre/lustre_param.h | 28 +++++-----
 include/uapi/linux/lustre/lustre_user.h  | 32 +++++------
 net/lnet/klnds/o2iblnd/o2iblnd.c         |  6 +-
 net/lnet/klnds/o2iblnd/o2iblnd.h         | 78 +++++++++++++++-----------
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c      | 84 ++++++++++++++--------------
 net/lnet/klnds/socklnd/socklnd.c         | 10 ++--
 net/lnet/klnds/socklnd/socklnd_cb.c      | 26 ++++-----
 net/lnet/klnds/socklnd/socklnd_lib.c     |  8 +--
 net/lnet/libcfs/debug.c                  |  4 +-
 net/lnet/libcfs/tracefile.c              |  8 +--
 net/lnet/lnet/acceptor.c                 |  6 +-
 net/lnet/lnet/config.c                   |  6 +-
 net/lnet/lnet/lib-move.c                 | 16 +++---
 net/lnet/lnet/lo.c                       |  2 +-
 net/lnet/lnet/router.c                   |  8 +--
 net/lnet/selftest/conrpc.c               |  2 +-
 net/lnet/selftest/conrpc.h               | 16 +++---
 net/lnet/selftest/console.h              | 96 ++++++++++++++++----------------
 net/lnet/selftest/framework.c            | 14 ++---
 net/lnet/selftest/rpc.h                  | 28 +++++-----
 net/lnet/selftest/selftest.h             | 38 ++++++-------
 42 files changed, 336 insertions(+), 320 deletions(-)

diff --git a/fs/lustre/include/lprocfs_status.h b/fs/lustre/include/lprocfs_status.h
index c3644f9..965f8a1 100644
--- a/fs/lustre/include/lprocfs_status.h
+++ b/fs/lustre/include/lprocfs_status.h
@@ -216,7 +216,7 @@ struct lprocfs_stats {
 static inline int opcode_offset(u32 opc)
 {
 	if (opc < OST_LAST_OPC) {
-		 /* OST opcode */
+		/* OST opcode */
 		return (opc - OST_FIRST_OPC);
 	} else if (opc < MDS_LAST_OPC) {
 		/* MDS opcode */
diff --git a/fs/lustre/include/lustre_import.h b/fs/lustre/include/lustre_import.h
index ad06f30..522e5b7 100644
--- a/fs/lustre/include/lustre_import.h
+++ b/fs/lustre/include/lustre_import.h
@@ -54,8 +54,8 @@
  * @{
  */
 #define D_ADAPTTO D_OTHER
-#define AT_BINS 4		  /* "bin" means "N seconds of history" */
-#define AT_FLG_NOHIST 0x1	  /* use last reported value only */
+#define AT_BINS 4		/* "bin" means "N seconds of history" */
+#define AT_FLG_NOHIST 0x1	/* use last reported value only */
 
 struct adaptive_timeout {
 	time64_t	at_binstart;		/* bin start time */
diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index 23cd565..961b8cb 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -418,7 +418,7 @@ struct ptlrpc_request_set {
  */
 struct ptlrpc_cb_id {
 	void   (*cbid_fn)(struct lnet_event *ev); /* specific callback fn */
-	void    *cbid_arg;		      /* additional arg */
+	void    *cbid_arg;			  /* additional arg */
 };
 
 /** Maximum number of locks to fit into reply state */
@@ -1235,9 +1235,9 @@ struct ptlrpc_bulk_desc {
 	/** Back pointer to the request */
 	struct ptlrpc_request		*bd_req;
 	const struct ptlrpc_bulk_frag_ops *bd_frag_ops;
-	int				bd_iov_count; /* # entries in bd_iov */
-	int				bd_max_iov;   /* allocated size of bd_iov */
-	int				bd_nob;	      /* # bytes covered */
+	int				bd_iov_count;	/* # entries in bd_iov */
+	int				bd_max_iov;	/* allocated size of bd_iov */
+	int				bd_nob;		/* # bytes covered */
 	int				bd_nob_transferred; /* # bytes GOT/PUT */
 
 	u64				bd_last_mbits;
diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 6e779cf..99577e4 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -544,21 +544,21 @@ struct obd_device {
 	char			 obd_name[MAX_OBD_NAME];
 
 	/* bitfield modification is protected by obd_dev_lock */
-	unsigned long obd_attached:1,      /* finished attach */
-		      obd_set_up:1,	/* finished setup */
+	unsigned long obd_attached:1,	   /* finished attach */
+		      obd_set_up:1,	   /* finished setup */
 		      obd_version_recov:1, /* obd uses version checking */
-		      obd_replayable:1,/* recovery is enabled; inform clients */
-		      obd_no_transno:1,  /* no committed-transno notification */
+		      obd_replayable:1,	   /* recovery is enabled; inform clients */
+		      obd_no_transno:1,	   /* no committed-transno notification */
 		      obd_no_recov:1,      /* fail instead of retry messages */
 		      obd_stopping:1,      /* started cleanup */
 		      obd_starting:1,      /* started setup */
-		      obd_force:1,	 /* cleanup with > 0 obd refcount */
-		      obd_fail:1,	 /* cleanup with failover */
+		      obd_force:1,	   /* cleanup with > 0 obd refcount */
+		      obd_fail:1,	   /* cleanup with failover */
 		      obd_no_conn:1,       /* deny new connections */
 		      obd_inactive:1,      /* device active/inactive
 					    * (for sysfs status only!!)
 					    */
-		      obd_no_ir:1,	 /* no imperative recovery. */
+		      obd_no_ir:1,	   /* no imperative recovery. */
 		      obd_process_conf:1,  /* device is processing mgs config */
 		      obd_checksum_dump:1; /* dump pages upon cksum error */
 	/* use separate field as it is set in interrupt to don't mess with
diff --git a/fs/lustre/include/obd_support.h b/fs/lustre/include/obd_support.h
index 3e273f8..e10b372 100644
--- a/fs/lustre/include/obd_support.h
+++ b/fs/lustre/include/obd_support.h
@@ -46,7 +46,7 @@
 /* obd_timeout should only be used for recovery, not for
  * networking / disk / timings affected by load (use Adaptive Timeouts)
  */
-extern unsigned int obd_timeout;	  /* seconds */
+extern unsigned int obd_timeout;	/* seconds */
 extern unsigned int obd_timeout_set;
 extern unsigned int at_min;
 extern unsigned int at_max;
diff --git a/fs/lustre/ldlm/ldlm_lockd.c b/fs/lustre/ldlm/ldlm_lockd.c
index 6ad2c1a..84d73e6 100644
--- a/fs/lustre/ldlm/ldlm_lockd.c
+++ b/fs/lustre/ldlm/ldlm_lockd.c
@@ -659,7 +659,7 @@ static int ldlm_callback_handler(struct ptlrpc_request *req)
 		ldlm_handle_gl_callback(req, ns, dlm_req, lock);
 		break;
 	default:
-		LBUG();			 /* checked above */
+		LBUG();			/* checked above */
 	}
 
 	return 0;
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index ee8d160..f0a50fc 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -330,11 +330,11 @@ struct ll_ra_info {
  * counted by page index.
  */
 struct ra_io_arg {
-	unsigned long ria_start;  /* start offset of read-ahead*/
-	unsigned long ria_end;    /* end offset of read-ahead*/
-	unsigned long ria_reserved; /* reserved pages for read-ahead */
-	unsigned long ria_end_min;  /* minimum end to cover current read */
-	bool ria_eof;		    /* reach end of file */
+	unsigned long ria_start;	/* start offset of read-ahead*/
+	unsigned long ria_end;		/* end offset of read-ahead*/
+	unsigned long ria_reserved;	/* reserved pages for read-ahead */
+	unsigned long ria_end_min;	/* minimum end to cover current read */
+	bool ria_eof;			/* reach end of file */
 	/* If stride read pattern is detected, ria_stoff means where
 	 * stride read is started. Note: for normal read-ahead, the
 	 * value here is meaningless, and also it will not be accessed
diff --git a/fs/lustre/mdc/mdc_lib.c b/fs/lustre/mdc/mdc_lib.c
index ba4eb3f..d4b2bb9 100644
--- a/fs/lustre/mdc/mdc_lib.c
+++ b/fs/lustre/mdc/mdc_lib.c
@@ -145,7 +145,7 @@ void mdc_readdir_pack(struct ptlrpc_request *req, u64 pgoff, size_t size,
 						    &RMF_MDT_BODY);
 	b->mbo_fid1 = *fid;
 	b->mbo_valid |= OBD_MD_FLID;
-	b->mbo_size = pgoff;		       /* !! */
+	b->mbo_size = pgoff;			/* !! */
 	b->mbo_nlink = size;			/* !! */
 	__mdc_pack_body(b, -1);
 	b->mbo_mode = LUDA_FID | LUDA_TYPE;
diff --git a/fs/lustre/obdclass/llog.c b/fs/lustre/obdclass/llog.c
index 3187a9c..65384ded 100644
--- a/fs/lustre/obdclass/llog.c
+++ b/fs/lustre/obdclass/llog.c
@@ -123,7 +123,7 @@ static int llog_read_header(const struct lu_env *env,
 
 		/* lrh_len should be initialized in llog_init_handle */
 		handle->lgh_last_idx = 0; /* header is record with index 0 */
-		llh->llh_count = 1;	 /* for the header record */
+		llh->llh_count = 1;	/* for the header record */
 		llh->llh_hdr.lrh_type = LLOG_HDR_MAGIC;
 		LASSERT(handle->lgh_ctxt->loc_chunk_size >= LLOG_MIN_CHUNK_SIZE);
 		llh->llh_hdr.lrh_len = handle->lgh_ctxt->loc_chunk_size;
diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index 0e7fc70..33c76c1 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -1604,8 +1604,8 @@ char *lprocfs_find_named_value(const char *buffer, const char *name,
 	if (!val)
 		return (char *)buffer;
 
-	val += strlen(name);			     /* skip prefix */
-	while (val < buffer + buflen && isspace(*val)) /* skip separator */
+	val += strlen(name);				/* skip prefix */
+	while (val < buffer + buflen && isspace(*val))	/* skip separator */
 		val++;
 
 	*count = 0;
diff --git a/fs/lustre/obdecho/echo_client.c b/fs/lustre/obdecho/echo_client.c
index 4ae21fb..ca963bb 100644
--- a/fs/lustre/obdecho/echo_client.c
+++ b/fs/lustre/obdecho/echo_client.c
@@ -1506,7 +1506,7 @@ static int echo_client_brw_ioctl(const struct lu_env *env, int rw,
 	}
 
 	switch (cmd) {
-	case OBD_IOC_CREATE:		    /* may create echo object */
+	case OBD_IOC_CREATE:		/* may create echo object */
 		if (!capable(CAP_SYS_ADMIN)) {
 			rc = -EPERM;
 			goto out;
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 69c14d2..a533cbb 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -277,8 +277,8 @@ int ptlrpc_prep_bulk_frag(struct ptlrpc_bulk_desc *desc,
 
 void ptlrpc_free_bulk(struct ptlrpc_bulk_desc *desc)
 {
-	LASSERT(desc->bd_iov_count != LI_POISON); /* not freed already */
-	LASSERT(desc->bd_md_count == 0);	 /* network hands off */
+	LASSERT(desc->bd_iov_count != LI_POISON);	/* not freed already */
+	LASSERT(desc->bd_md_count == 0);		/* network hands off */
 	LASSERT((desc->bd_export != NULL) ^ (desc->bd_import != NULL));
 	LASSERT(desc->bd_frag_ops);
 
diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index 47d4159..02ed373 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -171,7 +171,7 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 	desc->bd_md_count = total_md;
 	md.user_ptr = &desc->bd_cbid;
 	md.eq_handle = ptlrpc_eq_h;
-	md.threshold = 1;		       /* PUT or GET */
+	md.threshold = 1;		/* PUT or GET */
 
 	for (posted_md = 0; posted_md < total_md; posted_md++, mbits++) {
 		md.options = PTLRPC_MD_OPTIONS |
@@ -416,7 +416,7 @@ int ptlrpc_send_reply(struct ptlrpc_request *req, int flags)
 		CERROR("not replying on NULL connection\n"); /* bug 9635 */
 		return -ENOTCONN;
 	}
-	ptlrpc_rs_addref(rs);		   /* +1 ref for the network */
+	ptlrpc_rs_addref(rs);		/* +1 ref for the network */
 
 	rc = sptlrpc_svc_wrap_reply(req);
 	if (unlikely(rc))
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index f7afc4c..b6a4fd8 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -703,7 +703,7 @@ char *lustre_msg_string(struct lustre_msg *m, u32 index, u32 max_len)
 
 	slen = strnlen(str, blen);
 
-	if (slen == blen) {		     /* not NULL terminated */
+	if (slen == blen) {		/* not NULL terminated */
 		CERROR("can't unpack non-NULL terminated string in msg %p buffer[%d] len %d\n",
 		       m, index, blen);
 		return NULL;
diff --git a/fs/lustre/ptlrpc/sec_null.c b/fs/lustre/ptlrpc/sec_null.c
index 726db6e..3c7fb68 100644
--- a/fs/lustre/ptlrpc/sec_null.c
+++ b/fs/lustre/ptlrpc/sec_null.c
@@ -409,7 +409,7 @@ static void null_init_internal(void)
 	static HLIST_HEAD(__list);
 
 	null_sec.ps_policy = &null_policy;
-	atomic_set(&null_sec.ps_refcount, 1);     /* always busy */
+	atomic_set(&null_sec.ps_refcount, 1);	/* always busy */
 	null_sec.ps_id = -1;
 	null_sec.ps_import = NULL;
 	null_sec.ps_flvr.sf_rpc = SPTLRPC_FLVR_NULL;
@@ -417,7 +417,7 @@ static void null_init_internal(void)
 	null_sec.ps_part = LUSTRE_SP_ANY;
 	null_sec.ps_dying = 0;
 	spin_lock_init(&null_sec.ps_lock);
-	atomic_set(&null_sec.ps_nctx, 1);	 /* for "null_cli_ctx" */
+	atomic_set(&null_sec.ps_nctx, 1);	/* for "null_cli_ctx" */
 	INIT_LIST_HEAD(&null_sec.ps_gc_list);
 	null_sec.ps_gc_interval = 0;
 	null_sec.ps_gc_next = 0;
diff --git a/fs/lustre/ptlrpc/sec_plain.c b/fs/lustre/ptlrpc/sec_plain.c
index 84ff1fd..2358c3f 100644
--- a/fs/lustre/ptlrpc/sec_plain.c
+++ b/fs/lustre/ptlrpc/sec_plain.c
@@ -76,10 +76,10 @@ static inline struct plain_sec *sec2plsec(struct ptlrpc_sec *sec)
 #define PLAIN_FL_BULK		(0x02)
 
 struct plain_header {
-	u8	    ph_ver;	    /* 0 */
+	u8	    ph_ver;		/* 0 */
 	u8	    ph_flags;
-	u8	    ph_sp;	     /* source */
-	u8	    ph_bulk_hash_alg;  /* complete flavor desc */
+	u8	    ph_sp;		/* source */
+	u8	    ph_bulk_hash_alg;	/* complete flavor desc */
 	u8	    ph_pad[4];
 };
 
diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index c2a00de..d57df36 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -712,9 +712,9 @@ static void ptlrpc_server_free_request(struct ptlrpc_request *req)
 	LASSERT(atomic_read(&req->rq_refcount) == 0);
 	LASSERT(list_empty(&req->rq_timed_list));
 
-	 /* DEBUG_REQ() assumes the reply state of a request with a valid
-	  * ref will not be destroyed until that reference is dropped.
-	  */
+	/* DEBUG_REQ() assumes the reply state of a request with a valid
+	 * ref will not be destroyed until that reference is dropped.
+	 */
 	ptlrpc_req_drop_rs(req);
 
 	sptlrpc_svc_ctx_decref(req);
@@ -1852,8 +1852,8 @@ static bool ptlrpc_server_normal_pending(struct ptlrpc_service_part *svcpt,
 	been_handled = rs->rs_handled;
 	rs->rs_handled = 1;
 
-	nlocks = rs->rs_nlocks;		 /* atomic "steal", but */
-	rs->rs_nlocks = 0;		      /* locks still on rs_locks! */
+	nlocks = rs->rs_nlocks;		/* atomic "steal", but */
+	rs->rs_nlocks = 0;		/* locks still on rs_locks! */
 
 	if (nlocks == 0 && !been_handled) {
 		/* If we see this, we should already have seen the warning
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 68eb33c..21698cc 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -46,12 +46,12 @@
 
 void lustre_assert_wire_constants(void)
 {
-	 /* Wire protocol assertions generated by 'wirecheck'
-	  * (make -C lustre/utils newwiretest)
-	  * running on Linux centos6-bis 2.6.32-358.0.1.el6-head
-	  * #3 SMP Wed Apr 17 17:37:43 CEST 2013
-	  * with gcc version 4.4.6 20110731 (Red Hat 4.4.6-3) (GCC)
-	  */
+	/* Wire protocol assertions generated by 'wirecheck'
+	 * (make -C lustre/utils newwiretest)
+	 * running on Linux centos6-bis 2.6.32-358.0.1.el6-head
+	 * #3 SMP Wed Apr 17 17:37:43 CEST 2013
+	 * with gcc version 4.4.6 20110731 (Red Hat 4.4.6-3) (GCC)
+	 */
 
 	/* Constants... */
 	LASSERTF(PTL_RPC_MSG_REQUEST == 4711, "found %lld\n",
diff --git a/include/linux/libcfs/libcfs_debug.h b/include/linux/libcfs/libcfs_debug.h
index ed00320..ee46deaf 100644
--- a/include/linux/libcfs/libcfs_debug.h
+++ b/include/linux/libcfs/libcfs_debug.h
@@ -101,8 +101,8 @@
 # define DEBUG_SUBSYSTEM S_UNDEFINED
 #endif
 
-#define CDEBUG_DEFAULT_MAX_DELAY (600 * HZ)	 /* jiffies */
-#define CDEBUG_DEFAULT_MIN_DELAY ((HZ + 1) / 2) /* jiffies */
+#define CDEBUG_DEFAULT_MAX_DELAY (600 * HZ)	/* jiffies */
+#define CDEBUG_DEFAULT_MIN_DELAY ((HZ + 1) / 2)	/* jiffies */
 #define CDEBUG_DEFAULT_BACKOFF   2
 struct cfs_debug_limit_state {
 	unsigned long			cdls_next;
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 15968ba..e9560a9 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -57,7 +57,7 @@
 
 struct lnet_msg {
 	struct list_head	msg_activelist;
-	struct list_head	msg_list;	   /* Q for credits/MD */
+	struct list_head	msg_list;	/* Q for credits/MD */
 
 	struct lnet_process_id	msg_target;
 	/* Primary NID of the source. */
@@ -101,8 +101,8 @@ struct lnet_msg {
 	unsigned int		msg_onactivelist:1;	/* on the activelist */
 	unsigned int		msg_rdma_get:1;
 
-	struct lnet_peer_ni	*msg_txpeer;	 /* peer I'm sending to */
-	struct lnet_peer_ni	*msg_rxpeer;	 /* peer I received from */
+	struct lnet_peer_ni	*msg_txpeer;		/* peer I'm sending to */
+	struct lnet_peer_ni	*msg_rxpeer;		/* peer I received from */
 
 	void			*msg_private;
 	struct lnet_libmd	*msg_md;
@@ -470,7 +470,7 @@ struct lnet_peer_ni {
 	unsigned int		 lpni_ping_notsent;
 	/* # times router went dead<->alive */
 	int			 lpni_alive_count;
-	 /* ytes queued for sending */
+	/* ytes queued for sending */
 	long			 lpni_txqnob;
 	/* time of last aliveness news */
 	time64_t		 lpni_timestamp;
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 6ef7d45..401f7ef 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -846,22 +846,22 @@ struct obd_connect_data {
 	 * may result in out-of-bound memory access and kernel oops.
 	 */
 	__u16 ocd_maxmodrpcs;		/* Maximum modify RPCs in parallel */
-	__u16 padding0;			/* added 2.1.0. also fix lustre_swab_connect */
-	__u32 padding1;			/* added 2.1.0. also fix lustre_swab_connect */
+	__u16 padding0;		/* added 2.1.0. also fix lustre_swab_connect */
+	__u32 padding1;		/* added 2.1.0. also fix lustre_swab_connect */
 	__u64 ocd_connect_flags2;
-	__u64 padding3;	  /* added 2.1.0. also fix lustre_swab_connect */
-	__u64 padding4;	  /* added 2.1.0. also fix lustre_swab_connect */
-	__u64 padding5;	  /* added 2.1.0. also fix lustre_swab_connect */
-	__u64 padding6;	  /* added 2.1.0. also fix lustre_swab_connect */
-	__u64 padding7;	  /* added 2.1.0. also fix lustre_swab_connect */
-	__u64 padding8;	  /* added 2.1.0. also fix lustre_swab_connect */
-	__u64 padding9;	  /* added 2.1.0. also fix lustre_swab_connect */
-	__u64 paddingA;	  /* added 2.1.0. also fix lustre_swab_connect */
-	__u64 paddingB;	  /* added 2.1.0. also fix lustre_swab_connect */
-	__u64 paddingC;	  /* added 2.1.0. also fix lustre_swab_connect */
-	__u64 paddingD;	  /* added 2.1.0. also fix lustre_swab_connect */
-	__u64 paddingE;	  /* added 2.1.0. also fix lustre_swab_connect */
-	__u64 paddingF;	  /* added 2.1.0. also fix lustre_swab_connect */
+	__u64 padding3;		/* added 2.1.0. also fix lustre_swab_connect */
+	__u64 padding4;		/* added 2.1.0. also fix lustre_swab_connect */
+	__u64 padding5;		/* added 2.1.0. also fix lustre_swab_connect */
+	__u64 padding6;		/* added 2.1.0. also fix lustre_swab_connect */
+	__u64 padding7;		/* added 2.1.0. also fix lustre_swab_connect */
+	__u64 padding8;		/* added 2.1.0. also fix lustre_swab_connect */
+	__u64 padding9;		/* added 2.1.0. also fix lustre_swab_connect */
+	__u64 paddingA;		/* added 2.1.0. also fix lustre_swab_connect */
+	__u64 paddingB;		/* added 2.1.0. also fix lustre_swab_connect */
+	__u64 paddingC;		/* added 2.1.0. also fix lustre_swab_connect */
+	__u64 paddingD;		/* added 2.1.0. also fix lustre_swab_connect */
+	__u64 paddingE;		/* added 2.1.0. also fix lustre_swab_connect */
+	__u64 paddingF;		/* added 2.1.0. also fix lustre_swab_connect */
 };
 
 /* XXX README XXX:
@@ -2208,8 +2208,8 @@ struct ldlm_reply {
 enum mgs_cmd {
 	MGS_CONNECT = 250,
 	MGS_DISCONNECT,
-	MGS_EXCEPTION,	 /* node died, etc. */
-	MGS_TARGET_REG,	/* whenever target starts up */
+	MGS_EXCEPTION,		/* node died, etc. */
+	MGS_TARGET_REG,		/* whenever target starts up */
 	MGS_TARGET_DEL,
 	MGS_SET_INFO,
 	MGS_CONFIG_READ,
diff --git a/include/uapi/linux/lustre/lustre_param.h b/include/uapi/linux/lustre/lustre_param.h
index 1eab2ce..ab026e3 100644
--- a/include/uapi/linux/lustre/lustre_param.h
+++ b/include/uapi/linux/lustre/lustre_param.h
@@ -55,20 +55,20 @@
 /* System global or special params not handled in obd's proc
  * See mgs_write_log_sys()
  */
-#define PARAM_TIMEOUT		"timeout="	   /* global */
-#define PARAM_LDLM_TIMEOUT	"ldlm_timeout="	   /* global */
-#define PARAM_AT_MIN		"at_min="	   /* global */
-#define PARAM_AT_MAX		"at_max="	   /* global */
-#define PARAM_AT_EXTRA		"at_extra="	   /* global */
-#define PARAM_AT_EARLY_MARGIN	"at_early_margin=" /* global */
-#define PARAM_AT_HISTORY	"at_history="	   /* global */
-#define PARAM_JOBID_VAR		"jobid_var="	   /* global */
-#define PARAM_MGSNODE		"mgsnode="	   /* only at mounttime */
-#define PARAM_FAILNODE		"failover.node="   /* add failover nid */
-#define PARAM_FAILMODE		"failover.mode="   /* initial mount only */
-#define PARAM_ACTIVE		"active="	   /* activate/deactivate */
-#define PARAM_NETWORK		"network="	   /* bind on nid */
-#define PARAM_ID_UPCALL		"identity_upcall=" /* identity upcall */
+#define PARAM_TIMEOUT		"timeout="		/* global */
+#define PARAM_LDLM_TIMEOUT	"ldlm_timeout="		/* global */
+#define PARAM_AT_MIN		"at_min="		/* global */
+#define PARAM_AT_MAX		"at_max="		/* global */
+#define PARAM_AT_EXTRA		"at_extra="		/* global */
+#define PARAM_AT_EARLY_MARGIN	"at_early_margin="	/* global */
+#define PARAM_AT_HISTORY	"at_history="		/* global */
+#define PARAM_JOBID_VAR		"jobid_var="		/* global */
+#define PARAM_MGSNODE		"mgsnode="		/* only at mounttime */
+#define PARAM_FAILNODE		"failover.node="	/* add failover nid */
+#define PARAM_FAILMODE		"failover.mode="	/* initial mount only */
+#define PARAM_ACTIVE		"active="		/* activate/deactivate */
+#define PARAM_NETWORK		"network="		/* bind on nid */
+#define PARAM_ID_UPCALL		"identity_upcall="	/* identity upcall */
 
 /* Prefixes for parameters handled by obd's proc methods (XXX_process_config) */
 #define PARAM_OST		"ost."
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 2c4f837..0566afa 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -417,12 +417,12 @@ struct lov_user_md_v1 {		/* LOV EA user data (host-endian) */
 	__u32 lmm_stripe_size;	/* size of stripe in bytes */
 	__u16 lmm_stripe_count;	/* num stripes in use for this object */
 	union {
-		__u16 lmm_stripe_offset;  /* starting stripe offset in
-					   * lmm_objects, use when writing
-					   */
-		__u16 lmm_layout_gen;	  /* layout generation number
-					   * used when reading
-					   */
+		__u16 lmm_stripe_offset;	/* starting stripe offset in
+						 * lmm_objects, use when writing
+						 */
+		__u16 lmm_layout_gen;		/* layout generation number
+						 * used when reading
+						 */
 	};
 	struct lov_user_ost_data_v1 lmm_objects[0]; /* per-stripe data */
 } __attribute__((packed,  __may_alias__));
@@ -434,12 +434,12 @@ struct lov_user_md_v3 {		/* LOV EA user data (host-endian) */
 	__u32 lmm_stripe_size;	/* size of stripe in bytes */
 	__u16 lmm_stripe_count;	/* num stripes in use for this object */
 	union {
-		__u16 lmm_stripe_offset;  /* starting stripe offset in
-					   * lmm_objects, use when writing
-					   */
-		__u16 lmm_layout_gen;	  /* layout generation number
-					   * used when reading
-					   */
+		__u16 lmm_stripe_offset;	/* starting stripe offset in
+						 * lmm_objects, use when writing
+						 */
+		__u16 lmm_layout_gen;		/* layout generation number
+						 * used when reading
+						 */
 	};
 	char  lmm_pool_name[LOV_MAXPOOLNAME + 1];   /* pool name */
 	struct lov_user_ost_data_v1 lmm_objects[0]; /* per-stripe data */
@@ -571,13 +571,13 @@ static inline __u32 lov_user_md_size(__u16 stripes, __u32 lmm_magic)
 #ifdef HAVE_LOV_USER_MDS_DATA
 #define lov_user_mds_data lov_user_mds_data_v1
 struct lov_user_mds_data_v1 {
-	lstat_t lmd_st;		 /* MDS stat struct */
-	struct lov_user_md_v1 lmd_lmm;  /* LOV EA V1 user data */
+	lstat_t lmd_st;			/* MDS stat struct */
+	struct lov_user_md_v1 lmd_lmm;	/* LOV EA V1 user data */
 } __packed;
 
 struct lov_user_mds_data_v3 {
-	lstat_t lmd_st;		 /* MDS stat struct */
-	struct lov_user_md_v3 lmd_lmm;  /* LOV EA V3 user data */
+	lstat_t lmd_st;			/* MDS stat struct */
+	struct lov_user_md_v3 lmd_lmm;	/* LOV EA V3 user data */
 } __packed;
 #endif
 
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index 4b3018e..825fe30 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -513,7 +513,7 @@ static int kiblnd_del_peer(struct lnet_ni *ni, lnet_nid_t nid)
 			}
 
 			kiblnd_del_peer_locked(peer_ni);
-			rc = 0;	 /* matched something */
+			rc = 0;		/* matched something */
 		}
 	}
 
@@ -730,8 +730,8 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
 
 	conn->ibc_state = IBLND_CONN_INIT;
 	conn->ibc_version = version;
-	conn->ibc_peer = peer_ni;		  /* I take the caller's ref */
-	cmid->context = conn;		   /* for future CM callbacks */
+	conn->ibc_peer = peer_ni;		/* I take the caller's ref */
+	cmid->context = conn;			/* for future CM callbacks */
 	conn->ibc_cmid = cmid;
 	conn->ibc_max_frags = peer_ni->ibp_max_frags;
 	conn->ibc_queue_depth = peer_ni->ibp_queue_depth;
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index 541f95a..9021051 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -222,10 +222,10 @@ struct kib_poolset {
 	int			ps_pool_size;	/* new pool size */
 	int			ps_cpt;		/* CPT id */
 
-	kib_ps_pool_create_t	ps_pool_create;	 /* create a new pool */
+	kib_ps_pool_create_t	ps_pool_create;	/* create a new pool */
 	kib_ps_pool_destroy_t	ps_pool_destroy; /* destroy a pool */
-	kib_ps_node_init_t	ps_node_init;	 /* initialize new allocated node */
-	kib_ps_node_fini_t	ps_node_fini;    /* finalize node */
+	kib_ps_node_init_t	ps_node_init;	/* initialize new allocated node */
+	kib_ps_node_fini_t	ps_node_fini;	/* finalize node */
 };
 
 struct kib_pool {
@@ -329,32 +329,48 @@ struct kib_sched_info {
 };
 
 struct kib_data {
-	int			kib_init;	    /* initialisation state */
-	int			kib_shutdown;	    /* shut down? */
-	struct list_head	kib_devs;	    /* IB devices extant */
-	struct list_head	kib_failed_devs;    /* list head of failed devices */
-	wait_queue_head_t	kib_failover_waitq; /* schedulers sleep here */
-	atomic_t		kib_nthreads;	    /* # live threads */
-	rwlock_t		kib_global_lock;    /* stabilize net/dev/peer_ni/conn ops */
-	struct list_head       *kib_peers;	    /* hash table of all my known peers */
-	int			kib_peer_hash_size; /* size of kib_peers */
-	void		       *kib_connd;	    /* the connd task (serialisation assertions) */
-	struct list_head	kib_connd_conns;    /* connections to setup/teardown */
-	struct list_head	kib_connd_zombies;  /* connections with zero refcount */
+	/* initialisation state */
+	int			kib_init;
+	/* shut down? */
+	int			kib_shutdown;
+	/* IB devices extant */
+	struct list_head	kib_devs;
+	/* list head of failed devices */
+	struct list_head	kib_failed_devs;
+	/* schedulers sleep here */
+	wait_queue_head_t	kib_failover_waitq;
+	/* # live threads */
+	atomic_t		kib_nthreads;
+	/* stabilize net/dev/peer_ni/conn ops */
+	rwlock_t		kib_global_lock;
+	/* hash table of all my known peers */
+	struct list_head       *kib_peers;
+	/* size of kib_peers */
+	int			kib_peer_hash_size;
+	/* the connd task (serialisation assertions) */
+	void		       *kib_connd;
+	/* connections to setup/teardown */
+	struct list_head	kib_connd_conns;
+	/* connections with zero refcount */
+	struct list_head	kib_connd_zombies;
 	/* connections to reconnect */
 	struct list_head	kib_reconn_list;
 	/* peers wait for reconnection */
 	struct list_head	kib_reconn_wait;
-	/**
+	/*
 	 * The second that peers are pulled out from @kib_reconn_wait
 	 * for reconnection.
 	 */
 	time64_t		kib_reconn_sec;
 
-	wait_queue_head_t	kib_connd_waitq;    /* connection daemon sleeps here */
-	spinlock_t		kib_connd_lock;	    /* serialise */
-	struct ib_qp_attr	kib_error_qpa;	    /* QP->ERROR */
-	struct kib_sched_info **kib_scheds;	    /* percpt data for schedulers */
+	/* connection daemon sleeps here */
+	wait_queue_head_t	kib_connd_waitq;
+	/* serialise */
+	spinlock_t		kib_connd_lock;
+	/* QP->ERROR */
+	struct ib_qp_attr	kib_error_qpa;
+	/* percpt data for schedulers */
+	struct kib_sched_info **kib_scheds;
 };
 
 #define IBLND_INIT_NOTHING	0
@@ -373,8 +389,8 @@ struct kib_connparams {
 } __packed;
 
 struct kib_immediate_msg {
-	struct lnet_hdr		ibim_hdr;	/* portals header */
-	char			ibim_payload[0];/* piggy-backed payload */
+	struct lnet_hdr		ibim_hdr;	 /* portals header */
+	char			ibim_payload[0]; /* piggy-backed payload */
 } __packed;
 
 struct kib_rdma_frag {
@@ -573,12 +589,12 @@ struct kib_conn {
 	struct kib_connvars	*ibc_connvars;	/* in-progress connection state */
 };
 
-#define IBLND_CONN_INIT			0	 /* being initialised */
-#define IBLND_CONN_ACTIVE_CONNECT	1	 /* active sending req */
-#define IBLND_CONN_PASSIVE_WAIT		2	 /* passive waiting for rtu */
-#define IBLND_CONN_ESTABLISHED		3	 /* connection established */
-#define IBLND_CONN_CLOSING		4	 /* being closed */
-#define IBLND_CONN_DISCONNECTED		5	 /* disconnected */
+#define IBLND_CONN_INIT			0	/* being initialised */
+#define IBLND_CONN_ACTIVE_CONNECT	1	/* active sending req */
+#define IBLND_CONN_PASSIVE_WAIT		2	/* passive waiting for rtu */
+#define IBLND_CONN_ESTABLISHED		3	/* connection established */
+#define IBLND_CONN_CLOSING		4	/* being closed */
+#define IBLND_CONN_DISCONNECTED		5	/* disconnected */
 
 struct kib_peer_ni {
 	struct list_head	ibp_list;	/* stash on global peer_ni list */
@@ -774,11 +790,11 @@ struct kib_peer_ni {
 
 	if (!list_empty(&conn->ibc_tx_noops) || /* NOOP already queued */
 	    !list_empty(&conn->ibc_tx_queue_nocred) || /* piggyback NOOP */
-	    !conn->ibc_credits)		    /* no credit */
+	    !conn->ibc_credits)			/* no credit */
 		return 0;
 
-	if (conn->ibc_credits == 1 &&      /* last credit reserved for */
-	    !conn->ibc_outstanding_credits) /* giving back credits */
+	if (conn->ibc_credits == 1 &&		/* last credit reserved for */
+	    !conn->ibc_outstanding_credits)	/* giving back credits */
 		return 0;
 
 	/* No tx to piggyback NOOP onto or no credit to send a tx */
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index a702654..c2ce3b9 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -177,10 +177,10 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 	rx->rx_wrq.wr_id = kiblnd_ptr2wreqid(rx, IBLND_WID_RX);
 
 	LASSERT(conn->ibc_state >= IBLND_CONN_INIT);
-	LASSERT(rx->rx_nob >= 0);	      /* not posted */
+	LASSERT(rx->rx_nob >= 0);		/* not posted */
 
 	if (conn->ibc_state > IBLND_CONN_ESTABLISHED) {
-		kiblnd_drop_rx(rx);	     /* No more posts for this rx */
+		kiblnd_drop_rx(rx);		/* No more posts for this rx */
 		return 0;
 	}
 
@@ -202,7 +202,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 
 	if (unlikely(rc)) {
 		kiblnd_close_conn(conn, rc);
-		kiblnd_drop_rx(rx);	     /* No more posts for this rx */
+		kiblnd_drop_rx(rx);		/* No more posts for this rx */
 		goto out;
 	}
 
@@ -264,7 +264,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 		return;
 	}
 
-	if (!tx->tx_status) {	       /* success so far */
+	if (!tx->tx_status) {		/* success so far */
 		if (status < 0) /* failed? */
 			tx->tx_status = status;
 		else if (txtype == IBLND_MSG_GET_REQ)
@@ -363,9 +363,9 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 			break;
 		}
 
-		if (credits) /* credit already posted */
+		if (credits)	/* credit already posted */
 			post_credit = IBLND_POSTRX_NO_CREDIT;
-		else	      /* a keepalive NOOP */
+		else		/* a keepalive NOOP */
 			post_credit = IBLND_POSTRX_PEER_CREDIT;
 		break;
 
@@ -373,7 +373,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 		post_credit = IBLND_POSTRX_DONT_POST;
 		rc = lnet_parse(ni, &msg->ibm_u.immediate.ibim_hdr,
 				msg->ibm_srcnid, rx, 0);
-		if (rc < 0)		     /* repost on error */
+		if (rc < 0)		/* repost on error */
 			post_credit = IBLND_POSTRX_PEER_CREDIT;
 		break;
 
@@ -381,7 +381,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 		post_credit = IBLND_POSTRX_DONT_POST;
 		rc = lnet_parse(ni, &msg->ibm_u.putreq.ibprm_hdr,
 				msg->ibm_srcnid, rx, 1);
-		if (rc < 0)		     /* repost on error */
+		if (rc < 0)		/* repost on error */
 			post_credit = IBLND_POSTRX_PEER_CREDIT;
 		break;
 
@@ -445,7 +445,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 		post_credit = IBLND_POSTRX_DONT_POST;
 		rc = lnet_parse(ni, &msg->ibm_u.get.ibgm_hdr,
 				msg->ibm_srcnid, rx, 1);
-		if (rc < 0)		     /* repost on error */
+		if (rc < 0)		/* repost on error */
 			post_credit = IBLND_POSTRX_PEER_CREDIT;
 		break;
 
@@ -457,7 +457,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 		break;
 	}
 
-	if (rc < 0)			     /* protocol error */
+	if (rc < 0)			/* protocol error */
 		kiblnd_close_conn(conn, rc);
 
 	if (post_credit != IBLND_POSTRX_DONT_POST)
@@ -475,8 +475,8 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 	int err = -EIO;
 
 	LASSERT(net);
-	LASSERT(rx->rx_nob < 0);	       /* was posted */
-	rx->rx_nob = 0;			 /* isn't now */
+	LASSERT(rx->rx_nob < 0);	/* was posted */
+	rx->rx_nob = 0;			/* isn't now */
 
 	if (conn->ibc_state > IBLND_CONN_ESTABLISHED)
 		goto ignore;
@@ -532,7 +532,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 	CDEBUG(D_NET, "rx %p conn %p\n", rx, conn);
 	kiblnd_close_conn(conn, err);
 ignore:
-	kiblnd_drop_rx(rx);		     /* Don't re-post rx. */
+	kiblnd_drop_rx(rx);		/* Don't re-post rx. */
 }
 
 static int
@@ -1036,13 +1036,13 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		conn->ibc_noops_posted--;
 
 	if (failed) {
-		tx->tx_waiting = 0;	     /* don't wait for peer_ni */
+		tx->tx_waiting = 0;	/* don't wait for peer_ni */
 		tx->tx_status = -EIO;
 	}
 
-	idle = !tx->tx_sending &&	 /* This is the final callback */
-	       !tx->tx_waiting &&	       /* Not waiting for peer_ni */
-	       !tx->tx_queued;		  /* Not re-queued (PUT_DONE) */
+	idle = !tx->tx_sending &&	/* This is the final callback */
+	       !tx->tx_waiting &&	/* Not waiting for peer_ni */
+	       !tx->tx_queued;		/* Not re-queued (PUT_DONE) */
 	if (idle)
 		list_del(&tx->tx_list);
 
@@ -1181,8 +1181,8 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	struct list_head *q;
 	s64 timeout_ns;
 
-	LASSERT(tx->tx_nwrq > 0);	      /* work items set up */
-	LASSERT(!tx->tx_queued);	       /* not queued for sending already */
+	LASSERT(tx->tx_nwrq > 0);	/* work items set up */
+	LASSERT(!tx->tx_queued);	/* not queued for sending already */
 	LASSERT(conn->ibc_state >= IBLND_CONN_ESTABLISHED);
 
 	timeout_ns = *kiblnd_tunables.kib_timeout * NSEC_PER_SEC;
@@ -1309,7 +1309,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	dstaddr.sin_port = htons(*kiblnd_tunables.kib_service);
 	dstaddr.sin_addr.s_addr = htonl(LNET_NIDADDR(peer_ni->ibp_nid));
 
-	kiblnd_peer_addref(peer_ni);	       /* cmid's ref */
+	kiblnd_peer_addref(peer_ni);	/* cmid's ref */
 
 	if (*kiblnd_tunables.kib_use_priv_port) {
 		rc = kiblnd_resolve_addr(cmid, &srcaddr, &dstaddr,
@@ -1331,7 +1331,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 
 failed2:
 	kiblnd_peer_connect_failed(peer_ni, 1, rc);
-	kiblnd_peer_decref(peer_ni);	       /* cmid's ref */
+	kiblnd_peer_decref(peer_ni);	/* cmid's ref */
 	rdma_destroy_id(cmid);
 	return;
 failed:
@@ -1569,12 +1569,12 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 
 	case LNET_MSG_GET:
 		if (routing || target_is_router)
-			break;		  /* send IMMEDIATE */
+			break;		/* send IMMEDIATE */
 
 		/* is the REPLY message too small for RDMA? */
 		nob = offsetof(struct kib_msg, ibm_u.immediate.ibim_payload[lntmsg->msg_md->md_length]);
 		if (nob <= IBLND_MSG_SIZE)
-			break;		  /* send IMMEDIATE */
+			break;		/* send IMMEDIATE */
 
 		tx = kiblnd_get_idle_tx(ni, target.nid);
 		if (!tx) {
@@ -1616,8 +1616,8 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 			return -EIO;
 		}
 
-		tx->tx_lntmsg[0] = lntmsg;      /* finalise lntmsg[0,1] on completion */
-		tx->tx_waiting = 1;	     /* waiting for GET_DONE */
+		tx->tx_lntmsg[0] = lntmsg;	/* finalise lntmsg[0,1] on completion */
+		tx->tx_waiting = 1;		/* waiting for GET_DONE */
 		kiblnd_launch_tx(ni, tx, target.nid);
 		return 0;
 
@@ -1626,7 +1626,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 		/* Is the payload small enough not to need RDMA? */
 		nob = offsetof(struct kib_msg, ibm_u.immediate.ibim_payload[payload_nob]);
 		if (nob <= IBLND_MSG_SIZE)
-			break;		  /* send IMMEDIATE */
+			break;			/* send IMMEDIATE */
 
 		tx = kiblnd_get_idle_tx(ni, target.nid);
 		if (!tx) {
@@ -1656,8 +1656,8 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 		ibmsg->ibm_u.putreq.ibprm_cookie = tx->tx_cookie;
 		kiblnd_init_tx_msg(ni, tx, IBLND_MSG_PUT_REQ, sizeof(struct kib_putreq_msg));
 
-		tx->tx_lntmsg[0] = lntmsg;      /* finalise lntmsg on completion */
-		tx->tx_waiting = 1;	     /* waiting for PUT_{ACK,NAK} */
+		tx->tx_lntmsg[0] = lntmsg;	/* finalise lntmsg on completion */
+		tx->tx_waiting = 1;		/* waiting for PUT_{ACK,NAK} */
 		kiblnd_launch_tx(ni, tx, target.nid);
 		return 0;
 	}
@@ -1687,7 +1687,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	nob = offsetof(struct kib_immediate_msg, ibim_payload[payload_nob]);
 	kiblnd_init_tx_msg(ni, tx, IBLND_MSG_IMMEDIATE, nob);
 
-	tx->tx_lntmsg[0] = lntmsg;	      /* finalise lntmsg on completion */
+	tx->tx_lntmsg[0] = lntmsg;		/* finalise lntmsg on completion */
 	kiblnd_launch_tx(ni, tx, target.nid);
 	return 0;
 }
@@ -1843,8 +1843,8 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 
 		kiblnd_init_tx_msg(ni, tx, IBLND_MSG_PUT_ACK, nob);
 
-		tx->tx_lntmsg[0] = lntmsg;      /* finalise lntmsg on completion */
-		tx->tx_waiting = 1;	     /* waiting for PUT_DONE */
+		tx->tx_lntmsg[0] = lntmsg;	/* finalise lntmsg on completion */
+		tx->tx_waiting = 1;		/* waiting for PUT_DONE */
 		kiblnd_queue_tx(tx, conn);
 
 		/* reposted buffer reserved for PUT_DONE */
@@ -1965,8 +1965,8 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	list_del(&conn->ibc_list);
 	/* connd (see below) takes over ibc_list's ref */
 
-	if (list_empty(&peer_ni->ibp_conns) &&    /* no more conns */
-	    kiblnd_peer_active(peer_ni)) {	 /* still in peer_ni table */
+	if (list_empty(&peer_ni->ibp_conns) &&	/* no more conns */
+	    kiblnd_peer_active(peer_ni)) {	/* still in peer_ni table */
 		kiblnd_unlink_peer_locked(peer_ni);
 
 		/* set/clear error on last conn */
@@ -2183,7 +2183,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	 * Add conn to peer_ni's list and nuke any dangling conns from
 	 * a different peer_ni instance...
 	 */
-	kiblnd_conn_addref(conn);	       /* +1 ref for ibc_list */
+	kiblnd_conn_addref(conn);		/* +1 ref for ibc_list */
 	list_add(&conn->ibc_list, &peer_ni->ibp_conns);
 	peer_ni->ibp_reconnected = 0;
 	if (active)
@@ -2341,9 +2341,9 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 		rej.ibr_incarnation = net->ibn_incarnation;
 	}
 
-	if (!ni ||			 /* no matching net */
-	    ni->ni_nid != reqmsg->ibm_dstnid ||   /* right NET, wrong NID! */
-	    net->ibn_dev != ibdev) {	      /* wrong device */
+	if (!ni ||				/* no matching net */
+	    ni->ni_nid != reqmsg->ibm_dstnid ||	/* right NET, wrong NID! */
+	    net->ibn_dev != ibdev) {		/* wrong device */
 		CERROR("Can't accept conn from %s on %s (%s:%d:%pI4h): bad dst nid %s\n",
 		       libcfs_nid2str(nid),
 		       !ni ? "NA" : libcfs_nid2str(ni->ni_nid),
@@ -2551,7 +2551,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	memset(&cp, 0, sizeof(cp));
 	cp.private_data	= ackmsg;
 	cp.private_data_len = ackmsg->ibm_nob;
-	cp.responder_resources = 0;	     /* No atomic ops or RDMA reads */
+	cp.responder_resources = 0;	/* No atomic ops or RDMA reads */
 	cp.initiator_depth = 0;
 	cp.flow_control	= 1;
 	cp.retry_count = *kiblnd_tunables.kib_retry_count;
@@ -2985,7 +2985,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	memset(&cp, 0, sizeof(cp));
 	cp.private_data	= msg;
 	cp.private_data_len = msg->ibm_nob;
-	cp.responder_resources = 0;	     /* No atomic ops or RDMA reads */
+	cp.responder_resources = 0;	/* No atomic ops or RDMA reads */
 	cp.initiator_depth = 0;
 	cp.flow_control = 1;
 	cp.retry_count = *kiblnd_tunables.kib_retry_count;
@@ -3067,7 +3067,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 		}
 		kiblnd_peer_connect_failed(peer_ni, 1, rc);
 		kiblnd_peer_decref(peer_ni);
-		return rc;		      /* rc destroys cmid */
+		return rc;		/* rc destroys cmid */
 
 	case RDMA_CM_EVENT_ROUTE_ERROR:
 		peer_ni = (struct kib_peer_ni *)cmid->context;
@@ -3075,7 +3075,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 			libcfs_nid2str(peer_ni->ibp_nid), event->status);
 		kiblnd_peer_connect_failed(peer_ni, 1, -EHOSTUNREACH);
 		kiblnd_peer_decref(peer_ni);
-		return -EHOSTUNREACH;	   /* rc destroys cmid */
+		return -EHOSTUNREACH;	/* rc destroys cmid */
 
 	case RDMA_CM_EVENT_ROUTE_RESOLVED:
 		peer_ni = (struct kib_peer_ni *)cmid->context;
@@ -3089,7 +3089,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 			libcfs_nid2str(peer_ni->ibp_nid), event->status);
 		kiblnd_peer_connect_failed(peer_ni, 1, event->status);
 		kiblnd_peer_decref(peer_ni);
-		return event->status;	   /* rc destroys cmid */
+		return event->status;	/* rc destroys cmid */
 
 	case RDMA_CM_EVENT_UNREACHABLE:
 		conn = (struct kib_conn *)cmid->context;
diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index d55b00f..03fa706 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -74,7 +74,7 @@
 
 	atomic_set(&route->ksnr_refcount, 1);
 	route->ksnr_peer = NULL;
-	route->ksnr_retry_interval = 0;	 /* OK to connect at any time */
+	route->ksnr_retry_interval = 0;		/* OK to connect at any time */
 	route->ksnr_ipaddr = ipaddr;
 	route->ksnr_port = port;
 	route->ksnr_scheduled = 0;
@@ -427,7 +427,7 @@ struct ksock_peer *
 
 	route->ksnr_deleted = 1;
 	list_del(&route->ksnr_list);
-	ksocknal_route_decref(route);	     /* drop peer_ni's ref */
+	ksocknal_route_decref(route);		/* drop peer_ni's ref */
 
 	if (list_empty(&peer_ni->ksnp_routes) &&
 	    list_empty(&peer_ni->ksnp_conns)) {
@@ -601,7 +601,7 @@ struct ksock_peer *
 
 			ksocknal_peer_decref(peer_ni);     /* ...till here */
 
-			rc = 0;		 /* matched! */
+			rc = 0;		/* matched! */
 		}
 	}
 
@@ -974,7 +974,7 @@ struct ksock_peer *
 	int peer_port;
 
 	rc = lnet_sock_getaddr(sock, 1, &peer_ip, &peer_port);
-	LASSERT(!rc);		      /* we succeeded before */
+	LASSERT(!rc);			/* we succeeded before */
 
 	cr = kzalloc(sizeof(*cr), GFP_NOFS);
 	if (!cr) {
@@ -2564,7 +2564,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 	LASSERT(ksocknal_data.ksnd_nnets > 0);
 
 	spin_lock_bh(&net->ksnn_lock);
-	net->ksnn_shutdown = 1;		 /* prevent new peers */
+	net->ksnn_shutdown = 1;		/* prevent new peers */
 	spin_unlock_bh(&net->ksnn_lock);
 
 	/* Delete all peers */
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index 4861dcf..5b75ea6 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -119,7 +119,7 @@ struct ksock_tx *
 	/* Never touch tx->tx_iov inside ksocknal_lib_send_iov() */
 	rc = ksocknal_lib_send_iov(conn, tx);
 
-	if (rc <= 0)			    /* sent nothing? */
+	if (rc <= 0)			/* sent nothing? */
 		return rc;
 
 	nob = rc;
@@ -157,7 +157,7 @@ struct ksock_tx *
 	/* Never touch tx->tx_kiov inside ksocknal_lib_send_kiov() */
 	rc = ksocknal_lib_send_kiov(conn, tx);
 
-	if (rc <= 0)			    /* sent nothing? */
+	if (rc <= 0)			/* sent nothing? */
 		return rc;
 
 	nob = rc;
@@ -212,7 +212,7 @@ struct ksock_tx *
 		}
 
 		bufnob = conn->ksnc_sock->sk->sk_wmem_queued;
-		if (rc > 0)		     /* sent something? */
+		if (rc > 0)			/* sent something? */
 			conn->ksnc_tx_bufnob += rc; /* account it */
 
 		if (bufnob < conn->ksnc_tx_bufnob) {
@@ -268,7 +268,7 @@ struct ksock_tx *
 	conn->ksnc_peer->ksnp_last_alive = ktime_get_seconds();
 	conn->ksnc_rx_deadline = ktime_get_seconds() +
 				 *ksocknal_tunables.ksnd_timeout;
-	mb();		       /* order with setting rx_started */
+	mb();		/* order with setting rx_started */
 	conn->ksnc_rx_started = 1;
 
 	conn->ksnc_rx_nob_left -= nob;
@@ -522,8 +522,8 @@ struct ksock_tx *
 	LASSERT(!route->ksnr_connecting);
 	LASSERT(ksocknal_route_mask() & ~route->ksnr_connected);
 
-	route->ksnr_scheduled = 1;	      /* scheduling conn for connd */
-	ksocknal_route_addref(route);	   /* extra ref for connd */
+	route->ksnr_scheduled = 1;	/* scheduling conn for connd */
+	ksocknal_route_addref(route);	/* extra ref for connd */
 
 	spin_lock_bh(&ksocknal_data.ksnd_connd_lock);
 
@@ -906,7 +906,7 @@ struct ksock_route *
 		return -ENOMEM;
 	}
 
-	tx->tx_conn = NULL;		     /* set when assigned a conn */
+	tx->tx_conn = NULL;		/* set when assigned a conn */
 	tx->tx_lnetmsg = lntmsg;
 
 	if (payload_iov) {
@@ -984,9 +984,9 @@ struct ksock_route *
 		ksocknal_lib_eager_ack(conn);
 	}
 
-	if (!nob_to_skip) {	 /* right at next packet boundary now */
+	if (!nob_to_skip) {	/* right at next packet boundary now */
 		conn->ksnc_rx_started = 0;
-		mb();		       /* racing with timeout thread */
+		mb();		/* racing with timeout thread */
 
 		switch (conn->ksnc_proto->pro_version) {
 		case  KSOCK_PROTO_V2:
@@ -1231,8 +1231,8 @@ struct ksock_route *
 	case SOCKNAL_RX_SLOP:
 		/* starting new packet? */
 		if (ksocknal_new_packet(conn, conn->ksnc_rx_nob_left))
-			return 0;       /* come back later */
-		goto again;	     /* try to finish reading slop now */
+			return 0;	/* come back later */
+		goto again;		/* try to finish reading slop now */
 
 	default:
 		break;
@@ -1240,7 +1240,7 @@ struct ksock_route *
 
 	/* Not Reached */
 	LBUG();
-	return -EINVAL;		       /* keep gcc happy */
+	return -EINVAL;		/* keep gcc happy */
 }
 
 int
@@ -1449,7 +1449,7 @@ int ksocknal_scheduler(void *arg)
 
 			did_something = 1;
 		}
-		if (!did_something ||	   /* nothing to do */
+		if (!did_something ||		/* nothing to do */
 		    ++nloops == SOCKNAL_RESCHED) { /* hogging CPU? */
 			spin_unlock_bh(&sched->kss_lock);
 
diff --git a/net/lnet/klnds/socklnd/socklnd_lib.c b/net/lnet/klnds/socklnd/socklnd_lib.c
index 3ac5f2e..251c28f 100644
--- a/net/lnet/klnds/socklnd/socklnd_lib.c
+++ b/net/lnet/klnds/socklnd/socklnd_lib.c
@@ -381,7 +381,7 @@ static int lustre_csum(struct kvec *v, void *context)
 	int rc;
 
 	rc = ksocknal_connsock_addref(conn);
-	if (rc)			    /* being shut down */
+	if (rc)			/* being shut down */
 		return;
 
 	sk = conn->ksnc_sock->sk;
@@ -416,7 +416,7 @@ static int lustre_csum(struct kvec *v, void *context)
 	read_lock(&ksocknal_data.ksnd_global_lock);
 
 	conn = sk->sk_user_data;
-	if (!conn) {	     /* raced with ksocknal_terminate_conn */
+	if (!conn) {		/* raced with ksocknal_terminate_conn */
 		LASSERT(sk->sk_data_ready != &ksocknal_data_ready);
 		sk->sk_data_ready(sk);
 	} else {
@@ -450,7 +450,7 @@ static int lustre_csum(struct kvec *v, void *context)
 	       !conn ? "" : (list_empty(&conn->ksnc_tx_queue) ?
 				      " empty" : " queued"));
 
-	if (!conn) {	     /* raced with ksocknal_terminate_conn */
+	if (!conn) {		/* raced with ksocknal_terminate_conn */
 		LASSERT(sk->sk_write_space != &ksocknal_write_space);
 		sk->sk_write_space(sk);
 
@@ -458,7 +458,7 @@ static int lustre_csum(struct kvec *v, void *context)
 		return;
 	}
 
-	if (wspace >= min_wpace) {	      /* got enough space */
+	if (wspace >= min_wpace) {		/* got enough space */
 		ksocknal_write_callback(conn);
 
 		/*
diff --git a/net/lnet/libcfs/debug.c b/net/lnet/libcfs/debug.c
index e779d6b..88c4c36 100644
--- a/net/lnet/libcfs/debug.c
+++ b/net/lnet/libcfs/debug.c
@@ -277,10 +277,10 @@ static const char *libcfs_debug_dbg2str(int debug)
 				continue;
 
 			token = fn(i);
-			if (!token)	      /* unused bit */
+			if (!token)		/* unused bit */
 				continue;
 
-			if (len > 0) {		  /* separator? */
+			if (len > 0) {		/* separator? */
 				if (len < size)
 					str[len] = ' ';
 				len++;
diff --git a/net/lnet/libcfs/tracefile.c b/net/lnet/libcfs/tracefile.c
index 5f51ec7..3b29116 100644
--- a/net/lnet/libcfs/tracefile.c
+++ b/net/lnet/libcfs/tracefile.c
@@ -892,17 +892,17 @@ int cfs_trace_copyin_string(char *knl_buffer, int knl_buffer_nob,
 		return -EFAULT;
 
 	nob = strnlen(knl_buffer, usr_buffer_nob);
-	while (--nob >= 0)		      /* strip trailing whitespace */
+	while (--nob >= 0)		/* strip trailing whitespace */
 		if (!isspace(knl_buffer[nob]))
 			break;
 
-	if (nob < 0)			    /* empty string */
+	if (nob < 0)			/* empty string */
 		return -EINVAL;
 
-	if (nob == knl_buffer_nob)	      /* no space to terminate */
+	if (nob == knl_buffer_nob)	/* no space to terminate */
 		return -EOVERFLOW;
 
-	knl_buffer[nob + 1] = 0;		/* terminate */
+	knl_buffer[nob + 1] = 0;	/* terminate */
 	return 0;
 }
 EXPORT_SYMBOL(cfs_trace_copyin_string);
diff --git a/net/lnet/lnet/acceptor.c b/net/lnet/lnet/acceptor.c
index d91a38c..1854347 100644
--- a/net/lnet/lnet/acceptor.c
+++ b/net/lnet/lnet/acceptor.c
@@ -150,7 +150,7 @@
 	int port;
 	int fatal;
 
-	BUILD_BUG_ON(sizeof(cr) > 16);	    /* too big to be on the stack */
+	BUILD_BUG_ON(sizeof(cr) > 16);		/* too big to be on the stack */
 
 	for (port = LNET_ACCEPTOR_MAX_RESERVED_PORT;
 	     port >= LNET_ACCEPTOR_MIN_RESERVED_PORT;
@@ -215,10 +215,10 @@
 	struct lnet_ni *ni;
 	char *str;
 
-	LASSERT(sizeof(cr) <= 16);	     /* not too big for the stack */
+	LASSERT(sizeof(cr) <= 16);		/* not too big for the stack */
 
 	rc = lnet_sock_getaddr(sock, 1, &peer_ip, &peer_port);
-	LASSERT(!rc);		      /* we succeeded before */
+	LASSERT(!rc);				/* we succeeded before */
 
 	if (!lnet_accept_magic(magic, LNET_PROTO_ACCEPTOR_MAGIC)) {
 		if (lnet_accept_magic(magic, LNET_PROTO_MAGIC)) {
diff --git a/net/lnet/lnet/config.c b/net/lnet/lnet/config.c
index ef1faa0..0560215 100644
--- a/net/lnet/lnet/config.c
+++ b/net/lnet/lnet/config.c
@@ -1142,7 +1142,7 @@ struct lnet_ni *
 			tmp2 = &nets;		/* expanding nets */
 		} else if (ntokens == 2 &&
 			   lnet_parse_hops(token, &hops)) {
-			got_hops = 1;	   /* got a hop count */
+			got_hops = 1;		/* got a hop count */
 			continue;
 		} else {
 			tmp2 = &gateways;	/* expanding gateways */
@@ -1347,7 +1347,7 @@ struct lnet_ni *
 	if (!matched)
 		return 0;
 
-	strcpy(net_entry, net);		 /* replace with matched net */
+	strcpy(net_entry, net);		/* replace with matched net */
 	return 1;
 }
 
@@ -1491,7 +1491,7 @@ struct lnet_ni *
 
 		list_del(&tb->ltb_list);
 
-		if (!rc) {		  /* no match */
+		if (!rc) {		/* no match */
 			lnet_free_text_buf(tb);
 			continue;
 		}
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index eee4510a..cab830a 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -362,11 +362,11 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	unsigned int frag_len;
 	unsigned int niov;
 
-	if (!len)			   /* no data => */
-		return 0;		     /* no frags */
+	if (!len)			/* no data => */
+		return 0;		/* no frags */
 
 	LASSERT(src_niov > 0);
-	while (offset >= src->iov_len) {      /* skip initial frags */
+	while (offset >= src->iov_len) {	/* skip initial frags */
 		offset -= src->iov_len;
 		src_niov--;
 		src++;
@@ -424,11 +424,11 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	unsigned int frag_len;
 	unsigned int niov;
 
-	if (!len)			   /* no data => */
-		return 0;		     /* no frags */
+	if (!len)			/* no data => */
+		return 0;		/* no frags */
 
 	LASSERT(src_niov > 0);
-	while (offset >= src->bv_len) {      /* skip initial frags */
+	while (offset >= src->bv_len) {	/* skip initial frags */
 		offset -= src->bv_len;
 		src_niov--;
 		src++;
@@ -2507,7 +2507,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	 * call back lnd_recv() come what may...
 	 */
 	if (!list_empty(&the_lnet.ln_test_peers) && /* normally we don't */
-	    fail_peer(src_nid, 0)) {	     /* shall we now? */
+	    fail_peer(src_nid, 0)) {		/* shall we now? */
 		CERROR("%s, src %s: Dropping %s to simulate failure\n",
 		       libcfs_nid2str(from_nid), libcfs_nid2str(src_nid),
 		       lnet_msgtyp2str(type));
@@ -2976,7 +2976,7 @@ struct lnet_msg *
 	LASSERT(the_lnet.ln_refcount > 0);
 
 	if (!list_empty(&the_lnet.ln_test_peers) && /* normally we don't */
-	    fail_peer(target.nid, 1)) {	  /* shall we now? */
+	    fail_peer(target.nid, 1)) {		/* shall we now? */
 		CERROR("Dropping GET to %s: simulated failure\n",
 		       libcfs_id2str(target));
 		return -EIO;
diff --git a/net/lnet/lnet/lo.c b/net/lnet/lnet/lo.c
index 2563243..350495f 100644
--- a/net/lnet/lnet/lo.c
+++ b/net/lnet/lnet/lo.c
@@ -50,7 +50,7 @@
 {
 	struct lnet_msg *sendmsg = private;
 
-	if (lntmsg) {		   /* not discarding */
+	if (lntmsg) {		/* not discarding */
 		if (sendmsg->msg_iov)
 			lnet_copy_iov2iter(to,
 					   sendmsg->msg_niov,
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 4b0c57a..278807d 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -117,10 +117,10 @@
 	spin_lock(&lp->lpni_lock);
 
 	lp->lpni_timestamp = when;		/* update timestamp */
-	lp->lpni_ping_deadline = 0;	       /* disable ping timeout */
+	lp->lpni_ping_deadline = 0;		/* disable ping timeout */
 
-	if (lp->lpni_alive_count &&	  /* got old news */
-	    (!lp->lpni_alive) == (!alive)) {      /* new date for old news */
+	if (lp->lpni_alive_count &&		/* got old news */
+	    (!lp->lpni_alive) == (!alive)) {	/* new date for old news */
 		spin_unlock(&lp->lpni_lock);
 		CDEBUG(D_NET, "Old news\n");
 		return;
@@ -337,7 +337,7 @@ static void lnet_shuffle_seed(void)
 	    (hops != LNET_UNDEFINED_HOPS && (hops < 1 || hops > 255)))
 		return -EINVAL;
 
-	if (lnet_islocalnet(net))	       /* it's a local network */
+	if (lnet_islocalnet(net))	/* it's a local network */
 		return -EEXIST;
 
 	/* Assume net, route, all new */
diff --git a/net/lnet/selftest/conrpc.c b/net/lnet/selftest/conrpc.c
index af0d2aa..112f545 100644
--- a/net/lnet/selftest/conrpc.c
+++ b/net/lnet/selftest/conrpc.c
@@ -294,7 +294,7 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 		spin_lock(&rpc->crpc_lock);
 
 		if (!crpc->crp_posted || /* not posted */
-		    crpc->crp_stamp_ns) {	 /* rpc done or aborted already */
+		    crpc->crp_stamp_ns) {	/* rpc done or aborted already */
 			if (!crpc->crp_stamp_ns) {
 				crpc->crp_stamp_ns = ktime_get_ns();
 				crpc->crp_status = -EINTR;
diff --git a/net/lnet/selftest/conrpc.h b/net/lnet/selftest/conrpc.h
index dfc31b8..fd75c50 100644
--- a/net/lnet/selftest/conrpc.h
+++ b/net/lnet/selftest/conrpc.h
@@ -74,14 +74,14 @@ struct lstcon_rpc {
 };
 
 struct lstcon_rpc_trans {
-	struct list_head  tas_olink;	     /* link chain on owner list */
-	struct list_head  tas_link;	     /* link chain on global list */
-	int		  tas_opc;	     /* operation code of transaction */
-	unsigned int	  tas_feats_updated; /* features mask is uptodate */
-	unsigned int	  tas_features;      /* test features mask */
-	wait_queue_head_t tas_waitq;	     /* wait queue head */
-	atomic_t	  tas_remaining;     /* # of un-scheduled rpcs */
-	struct list_head  tas_rpcs_list;     /* queued requests */
+	struct list_head  tas_olink;		/* link chain on owner list */
+	struct list_head  tas_link;		/* link chain on global list */
+	int		  tas_opc;		/* operation code of transaction */
+	unsigned int	  tas_feats_updated;	/* features mask is uptodate */
+	unsigned int	  tas_features;		/* test features mask */
+	wait_queue_head_t tas_waitq;		/* wait queue head */
+	atomic_t	  tas_remaining;	/* # of un-scheduled rpcs */
+	struct list_head  tas_rpcs_list;	/* queued requests */
 };
 
 #define LST_TRANS_PRIVATE	0x1000
diff --git a/net/lnet/selftest/console.h b/net/lnet/selftest/console.h
index b5709a4..a463276 100644
--- a/net/lnet/selftest/console.h
+++ b/net/lnet/selftest/console.h
@@ -64,8 +64,7 @@ struct lstcon_ndlink {
 
 /* (alias of nodes) group descriptor */
 struct lstcon_group {
-	struct list_head grp_link;		  /* chain on global group list
-						   */
+	struct list_head grp_link;		  /* chain on global group list */
 	int		 grp_ref;		  /* reference count */
 	int		 grp_userland;		  /* has userland nodes */
 	int		 grp_nnode;		  /* # of nodes */
@@ -76,17 +75,17 @@ struct lstcon_group {
 	struct list_head grp_ndl_hash[0];	  /* hash table for nodes */
 };
 
-#define LST_BATCH_IDLE	  0xB0	    /* idle batch */
-#define LST_BATCH_RUNNING 0xB1	    /* running batch */
+#define LST_BATCH_IDLE		0xB0	/* idle batch */
+#define LST_BATCH_RUNNING	0xB1	/* running batch */
 
 struct lstcon_tsb_hdr {
-	struct lst_bid	 tsb_id;	 /* batch ID */
-	int		 tsb_index;	 /* test index */
+	struct lst_bid	 tsb_id;	/* batch ID */
+	int		 tsb_index;	/* test index */
 };
 
 /* (tests ) batch descriptor */
 struct lstcon_batch {
-	struct lstcon_tsb_hdr	bat_hdr;	/* test_batch header */
+	struct lstcon_tsb_hdr	bat_hdr;  /* test_batch header */
 	struct list_head bat_link;	  /* chain on session's batches list */
 	int		 bat_ntest;	  /* # of test */
 	int		 bat_state;	  /* state of the batch */
@@ -95,22 +94,23 @@ struct lstcon_batch {
 					   */
 	char		 bat_name[LST_NAME_SIZE];/* name of batch */
 
-	struct list_head bat_test_list;   /* list head of tests (struct lstcon_test)
+	struct list_head bat_test_list;	  /* list head of tests
+					   *   (struct lstcon_test)
 					   */
 	struct list_head bat_trans_list;  /* list head of transaction */
 	struct list_head bat_cli_list;	  /* list head of client nodes
 					   * (struct lstcon_node)
 					   */
-	struct list_head *bat_cli_hash;   /* hash table of client nodes */
+	struct list_head *bat_cli_hash;	  /* hash table of client nodes */
 	struct list_head bat_srv_list;	  /* list head of server nodes */
-	struct list_head *bat_srv_hash;   /* hash table of server nodes */
+	struct list_head *bat_srv_hash;	  /* hash table of server nodes */
 };
 
 /* a single test descriptor */
 struct lstcon_test {
 	struct lstcon_tsb_hdr	tes_hdr;	/* test batch header */
-	struct list_head tes_link;	 /* chain on batch's tests list */
-	struct lstcon_batch	*tes_batch;	 /* pointer to batch */
+	struct list_head	tes_link;	/* chain on batch's tests list */
+	struct lstcon_batch	*tes_batch;	/* pointer to batch */
 
 	int		 tes_type;	 /* type of the test, i.e: bulk, ping */
 	int		 tes_stop_onerr; /* stop on error */
@@ -129,48 +129,48 @@ struct lstcon_test {
 	char		 tes_param[0];	 /* test parameter */
 };
 
-#define LST_GLOBAL_HASHSIZE 503	     /* global nodes hash table size */
-#define LST_NODE_HASHSIZE   239	     /* node hash table (for batch or group) */
+#define LST_GLOBAL_HASHSIZE	503	/* global nodes hash table size */
+#define LST_NODE_HASHSIZE	239	/* node hash table (for batch or group) */
 
-#define LST_SESSION_NONE    0x0	     /* no session */
-#define LST_SESSION_ACTIVE  0x1	     /* working session */
+#define LST_SESSION_NONE	0x0	/* no session */
+#define LST_SESSION_ACTIVE	0x1	/* working session */
 
-#define LST_CONSOLE_TIMEOUT 300	     /* default console timeout */
+#define LST_CONSOLE_TIMEOUT	300	/* default console timeout */
 
 struct lstcon_session {
-	struct mutex	    ses_mutex;	      /* only 1 thread in session */
-	struct lst_sid	    ses_id;	      /* global session id */
-	int		    ses_key;	      /* local session key */
-	int		    ses_state;	      /* state of session */
-	int		    ses_timeout;      /* timeout in seconds */
-	time64_t	    ses_laststamp;    /* last operation stamp (seconds)
-					       */
-	unsigned int	    ses_features;     /* tests features of the session
-					       */
-	unsigned int	    ses_feats_updated:1; /* features are synced with
-						  * remote test nodes
-						  */
-	unsigned int	    ses_force:1;      /* force creating */
-	unsigned int	    ses_shutdown:1;   /* session is shutting down */
-	unsigned int	    ses_expired:1;    /* console is timedout */
-	u64		    ses_id_cookie;    /* batch id cookie */
-	char		    ses_name[LST_NAME_SIZE];/* session name */
-	struct lstcon_rpc_trans	*ses_ping;		/* session pinger */
-	struct stt_timer	 ses_ping_timer;   /* timer for pinger */
-	struct lstcon_trans_stat ses_trans_stat;   /* transaction stats */
-
-	struct list_head    ses_trans_list;   /* global list of transaction */
-	struct list_head    ses_grp_list;     /* global list of groups */
-	struct list_head    ses_bat_list;     /* global list of batches */
-	struct list_head    ses_ndl_list;     /* global list of nodes */
-	struct list_head    *ses_ndl_hash;    /* hash table of nodes */
-
-	spinlock_t	    ses_rpc_lock;     /* serialize */
-	atomic_t	    ses_rpc_counter;  /* # of initialized RPCs */
-	struct list_head    ses_rpc_freelist; /* idle console rpc */
+	struct mutex	   ses_mutex;		/* only 1 thread in session */
+	struct lst_sid	   ses_id;		/* global session id */
+	int		   ses_key;		/* local session key */
+	int		   ses_state;		/* state of session */
+	int		   ses_timeout;		/* timeout in seconds */
+	time64_t	   ses_laststamp;	/* last operation stamp (secs) */
+	unsigned int	   ses_features;	/* tests features of the session */
+	unsigned int	   ses_feats_updated:1; /* features are synced with
+						 * remote test nodes
+						 */
+	unsigned int	   ses_force:1;		/* force creating */
+	unsigned int	   ses_shutdown:1;	/* session is shutting down */
+	unsigned int	   ses_expired:1;	/* console is timedout */
+	u64		   ses_id_cookie;	/* batch id cookie */
+	char		   ses_name[LST_NAME_SIZE];/* session name */
+	struct lstcon_rpc_trans
+			   *ses_ping;		/* session pinger */
+	struct stt_timer   ses_ping_timer;	/* timer for pinger */
+	struct lstcon_trans_stat
+			   ses_trans_stat;	/* transaction stats */
+
+	struct list_head   ses_trans_list;	/* global list of transaction */
+	struct list_head   ses_grp_list;	/* global list of groups */
+	struct list_head   ses_bat_list;	/* global list of batches */
+	struct list_head   ses_ndl_list;	/* global list of nodes */
+	struct list_head   *ses_ndl_hash;	/* hash table of nodes */
+
+	spinlock_t	   ses_rpc_lock;	/* serialize */
+	atomic_t	   ses_rpc_counter;	/* # of initialized RPCs */
+	struct list_head   ses_rpc_freelist;	/* idle console rpc */
 }; /* session descriptor */
 
-extern struct lstcon_session	 console_session;
+extern struct lstcon_session	console_session;
 
 static inline struct lstcon_trans_stat *
 lstcon_trans_stat(void)
diff --git a/net/lnet/selftest/framework.c b/net/lnet/selftest/framework.c
index 714ceec..c8c42b9 100644
--- a/net/lnet/selftest/framework.c
+++ b/net/lnet/selftest/framework.c
@@ -101,13 +101,13 @@
 #define sfw_batch_active(b)	(atomic_read(&(b)->bat_nactive))
 
 static struct smoketest_framework {
-	struct list_head  fw_zombie_rpcs;     /* RPCs to be recycled */
-	struct list_head  fw_zombie_sessions; /* stopping sessions */
-	struct list_head  fw_tests;	      /* registered test cases */
-	atomic_t	  fw_nzombies;	      /* # zombie sessions */
-	spinlock_t	  fw_lock;	      /* serialise */
-	struct sfw_session	  *fw_session;	      /* _the_ session */
-	int		  fw_shuttingdown;    /* shutdown in progress */
+	struct list_head  fw_zombie_rpcs;	/* RPCs to be recycled */
+	struct list_head  fw_zombie_sessions;	/* stopping sessions */
+	struct list_head  fw_tests;		/* registered test cases */
+	atomic_t	  fw_nzombies;		/* # zombie sessions */
+	spinlock_t	  fw_lock;		/* serialise */
+	struct sfw_session *fw_session;		/* _the_ session */
+	int		  fw_shuttingdown;	/* shutdown in progress */
 	struct srpc_server_rpc *fw_active_srpc;/* running RPC */
 } sfw_data;
 
diff --git a/net/lnet/selftest/rpc.h b/net/lnet/selftest/rpc.h
index ae1c07f..8ccae3a 100644
--- a/net/lnet/selftest/rpc.h
+++ b/net/lnet/selftest/rpc.h
@@ -213,29 +213,29 @@ struct srpc_test_reply {
 
 /* TEST RPCs */
 struct srpc_ping_reqst {
-	u64		   pnr_rpyid;
-	u32		   pnr_magic;
-	u32		   pnr_seq;
-	u64		   pnr_time_sec;
-	u64		   pnr_time_usec;
+	u64	pnr_rpyid;
+	u32	pnr_magic;
+	u32	pnr_seq;
+	u64	pnr_time_sec;
+	u64	pnr_time_usec;
 } __packed;
 
 struct srpc_ping_reply {
-	u32		   pnr_status;
-	u32		   pnr_magic;
-	u32		   pnr_seq;
+	u32	pnr_status;
+	u32	pnr_magic;
+	u32	pnr_seq;
 } __packed;
 
 struct srpc_brw_reqst {
-	u64		   brw_rpyid;	   /* reply buffer matchbits */
-	u64		   brw_bulkid;	   /* bulk buffer matchbits */
-	u32		   brw_rw;	   /* read or write */
-	u32		   brw_len;	   /* bulk data len */
-	u32		   brw_flags;	   /* bulk data patterns */
+	u64	brw_rpyid;	/* reply buffer matchbits */
+	u64	brw_bulkid;	/* bulk buffer matchbits */
+	u32	brw_rw;		/* read or write */
+	u32	brw_len;	/* bulk data len */
+	u32	brw_flags;	/* bulk data patterns */
 } __packed; /* bulk r/w request */
 
 struct srpc_brw_reply {
-	u32		   brw_status;
+	u32	brw_status;
 } __packed; /* bulk r/w reply */
 
 #define SRPC_MSG_MAGIC		0xeeb0f00d
diff --git a/net/lnet/selftest/selftest.h b/net/lnet/selftest/selftest.h
index fb16143..0fe8c4f 100644
--- a/net/lnet/selftest/selftest.h
+++ b/net/lnet/selftest/selftest.h
@@ -198,23 +198,23 @@ struct srpc_server_rpc {
 
 /* client-side state of a RPC */
 struct srpc_client_rpc {
-	struct list_head  crpc_list;	  /* chain on user's lists */
-	spinlock_t	  crpc_lock;	  /* serialize */
-	int		  crpc_service;
-	atomic_t	  crpc_refcount;
-	int		  crpc_timeout;   /* # seconds to wait for reply */
-	struct stt_timer       crpc_timer;
+	struct list_head	crpc_list;	/* chain on user's lists */
+	spinlock_t		crpc_lock;	/* serialize */
+	int			crpc_service;
+	atomic_t		crpc_refcount;
+	int			crpc_timeout;	/* # seconds to wait for reply */
+	struct stt_timer	crpc_timer;
 	struct swi_workitem	crpc_wi;
 	struct lnet_process_id	crpc_dest;
 
-	void		  (*crpc_done)(struct srpc_client_rpc *);
-	void		  (*crpc_fini)(struct srpc_client_rpc *);
-	int		  crpc_status;	  /* completion status */
-	void		  *crpc_priv;	  /* caller data */
+	void			(*crpc_done)(struct srpc_client_rpc *);
+	void			(*crpc_fini)(struct srpc_client_rpc *);
+	int			crpc_status;	/* completion status */
+	void			*crpc_priv;	/* caller data */
 
 	/* state flags */
-	unsigned int	  crpc_aborted:1; /* being given up */
-	unsigned int	  crpc_closed:1;  /* completed */
+	unsigned int		crpc_aborted:1;	/* being given up */
+	unsigned int		crpc_closed:1;	/* completed */
 
 	/* RPC events */
 	struct srpc_event	crpc_bulkev;	/* bulk event */
@@ -400,17 +400,17 @@ struct sfw_test_instance {
 #define sfw_id_pages(n)    DIV_ROUND_UP(n, SFW_ID_PER_PAGE)
 
 struct sfw_test_unit {
-	struct list_head    tsu_list;	   /* chain on lst_test_instance */
-	struct lnet_process_id		tsu_dest;	/* id of dest node */
-	int		    tsu_loop;	   /* loop count of the test */
-	struct sfw_test_instance	*tsu_instance; /* pointer to test instance */
-	void		    *tsu_private;  /* private data */
+	struct list_head	tsu_list;	/* chain on lst_test_instance */
+	struct lnet_process_id	tsu_dest;	/* id of dest node */
+	int			tsu_loop;	/* loop count of the test */
+	struct sfw_test_instance *tsu_instance;	/* pointer to test instance */
+	void			*tsu_private;	/* private data */
 	struct swi_workitem	tsu_worker;	/* workitem of the test unit */
 };
 
 struct sfw_test_case {
-	struct list_head      tsc_list;		/* chain on fw_tests */
-	struct srpc_service		*tsc_srv_service;	/* test service */
+	struct list_head		tsc_list;	/* chain on fw_tests */
+	struct srpc_service		*tsc_srv_service; /* test service */
 	struct sfw_test_client_ops	*tsc_cli_ops;	/* ops of test client */
 };
 
-- 
1.8.3.1
