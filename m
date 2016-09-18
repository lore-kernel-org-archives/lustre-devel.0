From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:51 -0400
Subject: [lustre-devel] [PATCH 112/124] staging: lustre: ptlrpc: remove
	unnecessary EXPORT_SYMBOL
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-113-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, frank zago <fzago@cray.com>, James Simmons <jsimmons@infradead.org>

From: frank zago <fzago@cray.com>

A lot of symbols don't need to be exported at all because they are
only used in the module they belong to.

Signed-off-by: frank zago <fzago@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5829
Reviewed-on: http://review.whamcloud.com/12510
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/include/lustre_net.h |    7 ---
 drivers/staging/lustre/lustre/ptlrpc/client.c      |   17 +-----
 drivers/staging/lustre/lustre/ptlrpc/connection.c  |    5 --
 drivers/staging/lustre/lustre/ptlrpc/import.c      |    1 -
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |    5 --
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |   57 --------------------
 drivers/staging/lustre/lustre/ptlrpc/pinger.c      |    1 -
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |    5 ++
 drivers/staging/lustre/lustre/ptlrpc/recover.c     |    2 -
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |    4 --
 drivers/staging/lustre/lustre/ptlrpc/sec_config.c  |    1 -
 drivers/staging/lustre/lustre/ptlrpc/sec_gc.c      |    2 -
 drivers/staging/lustre/lustre/ptlrpc/service.c     |    1 -
 13 files changed, 8 insertions(+), 100 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index 21e2267..e9aba99 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -2408,7 +2408,6 @@ int ptlrpc_send_reply(struct ptlrpc_request *req, int flags);
 int ptlrpc_reply(struct ptlrpc_request *req);
 int ptlrpc_send_error(struct ptlrpc_request *req, int difficult);
 int ptlrpc_error(struct ptlrpc_request *req);
-void ptlrpc_resend_req(struct ptlrpc_request *request);
 int ptlrpc_at_get_net_latency(struct ptlrpc_request *req);
 int ptl_send_rpc(struct ptlrpc_request *request, int noreply);
 int ptlrpc_register_rqbd(struct ptlrpc_request_buffer_desc *rqbd);
@@ -2428,23 +2427,17 @@ struct ptlrpc_connection *ptlrpc_uuid_to_connection(struct obd_uuid *uuid);
 
 int ptlrpc_queue_wait(struct ptlrpc_request *req);
 int ptlrpc_replay_req(struct ptlrpc_request *req);
-int ptlrpc_unregister_reply(struct ptlrpc_request *req, int async);
 void ptlrpc_abort_inflight(struct obd_import *imp);
 void ptlrpc_abort_set(struct ptlrpc_request_set *set);
 
 struct ptlrpc_request_set *ptlrpc_prep_set(void);
 struct ptlrpc_request_set *ptlrpc_prep_fcset(int max, set_producer_func func,
 					     void *arg);
-int ptlrpc_set_next_timeout(struct ptlrpc_request_set *);
 int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set);
 int ptlrpc_set_wait(struct ptlrpc_request_set *);
-int ptlrpc_expired_set(void *data);
-void ptlrpc_interrupted_set(void *data);
 void ptlrpc_mark_interrupted(struct ptlrpc_request *req);
 void ptlrpc_set_destroy(struct ptlrpc_request_set *);
 void ptlrpc_set_add_req(struct ptlrpc_request_set *, struct ptlrpc_request *);
-void ptlrpc_set_add_new_req(struct ptlrpcd_ctl *pc,
-			    struct ptlrpc_request *req);
 
 void ptlrpc_free_rq_pool(struct ptlrpc_request_pool *pool);
 int ptlrpc_add_rqs_to_pool(struct ptlrpc_request_pool *pool, int num_rq);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index f3914cc..18c7ff7 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -45,6 +45,7 @@
 
 static int ptlrpc_send_new_req(struct ptlrpc_request *req);
 static int ptlrpcd_check_work(struct ptlrpc_request *req);
+static int ptlrpc_unregister_reply(struct ptlrpc_request *request, int async);
 
 /**
  * Initialize passed in client structure \a cl.
@@ -89,7 +90,6 @@ struct ptlrpc_connection *ptlrpc_uuid_to_connection(struct obd_uuid *uuid)
 
 	return c;
 }
-EXPORT_SYMBOL(ptlrpc_uuid_to_connection);
 
 /**
  * Allocate and initialize new bulk descriptor on the sender.
@@ -886,7 +886,6 @@ struct ptlrpc_request_set *ptlrpc_prep_fcset(int max, set_producer_func func,
 
 	return set;
 }
-EXPORT_SYMBOL(ptlrpc_prep_fcset);
 
 /**
  * Wind down and free request set structure previously allocated with
@@ -1006,7 +1005,6 @@ void ptlrpc_set_add_new_req(struct ptlrpcd_ctl *pc,
 			wake_up(&pc->pc_partners[i]->pc_set->set_waitq);
 	}
 }
-EXPORT_SYMBOL(ptlrpc_set_add_new_req);
 
 /**
  * Based on the current state of the import, determine if the request
@@ -2005,7 +2003,6 @@ int ptlrpc_expired_set(void *data)
 	 */
 	return 1;
 }
-EXPORT_SYMBOL(ptlrpc_expired_set);
 
 /**
  * Sets rq_intr flag in \a req under spinlock.
@@ -2022,7 +2019,7 @@ EXPORT_SYMBOL(ptlrpc_mark_interrupted);
  * Interrupts (sets interrupted flag) all uncompleted requests in
  * a set \a data. Callback for l_wait_event for interruptible waits.
  */
-void ptlrpc_interrupted_set(void *data)
+static void ptlrpc_interrupted_set(void *data)
 {
 	struct ptlrpc_request_set *set = data;
 	struct list_head *tmp;
@@ -2040,7 +2037,6 @@ void ptlrpc_interrupted_set(void *data)
 		ptlrpc_mark_interrupted(req);
 	}
 }
-EXPORT_SYMBOL(ptlrpc_interrupted_set);
 
 /**
  * Get the smallest timeout in the set; this does NOT set a timeout.
@@ -2084,7 +2080,6 @@ int ptlrpc_set_next_timeout(struct ptlrpc_request_set *set)
 	}
 	return timeout;
 }
-EXPORT_SYMBOL(ptlrpc_set_next_timeout);
 
 /**
  * Send all unset request from the set and then wait until all
@@ -2335,7 +2330,7 @@ EXPORT_SYMBOL(ptlrpc_req_xid);
  * The request owner (i.e. the thread doing the I/O) must call...
  * Returns 0 on success or 1 if unregistering cannot be made.
  */
-int ptlrpc_unregister_reply(struct ptlrpc_request *request, int async)
+static int ptlrpc_unregister_reply(struct ptlrpc_request *request, int async)
 {
 	int rc;
 	wait_queue_head_t *wq;
@@ -2400,7 +2395,6 @@ int ptlrpc_unregister_reply(struct ptlrpc_request *request, int async)
 	}
 	return 0;
 }
-EXPORT_SYMBOL(ptlrpc_unregister_reply);
 
 static void ptlrpc_free_request(struct ptlrpc_request *req)
 {
@@ -2555,7 +2549,6 @@ void ptlrpc_resend_req(struct ptlrpc_request *req)
 	ptlrpc_client_wake_req(req);
 	spin_unlock(&req->rq_lock);
 }
-EXPORT_SYMBOL(ptlrpc_resend_req);
 
 /**
  * Grab additional reference on a request \a req
@@ -2624,7 +2617,6 @@ void ptlrpc_retain_replayable_request(struct ptlrpc_request *req,
 
 	list_add(&req->rq_replay_list, &imp->imp_replay_list);
 }
-EXPORT_SYMBOL(ptlrpc_retain_replayable_request);
 
 /**
  * Send request and wait until it completes.
@@ -2797,7 +2789,6 @@ int ptlrpc_replay_req(struct ptlrpc_request *req)
 	ptlrpcd_add_req(req);
 	return 0;
 }
-EXPORT_SYMBOL(ptlrpc_replay_req);
 
 /**
  * Aborts all in-flight request on import \a imp sending and delayed lists
@@ -2857,7 +2848,6 @@ void ptlrpc_abort_inflight(struct obd_import *imp)
 
 	spin_unlock(&imp->imp_lock);
 }
-EXPORT_SYMBOL(ptlrpc_abort_inflight);
 
 /**
  * Abort all uncompleted requests in request set \a set
@@ -2943,7 +2933,6 @@ __u64 ptlrpc_next_xid(void)
 
 	return next;
 }
-EXPORT_SYMBOL(ptlrpc_next_xid);
 
 /**
  * Get a glimpse at what next xid value might have been.
diff --git a/drivers/staging/lustre/lustre/ptlrpc/connection.c b/drivers/staging/lustre/lustre/ptlrpc/connection.c
index 177a379..7b020d6 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/connection.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/connection.c
@@ -82,7 +82,6 @@ out:
 	       libcfs_nid2str(conn->c_peer.nid));
 	return conn;
 }
-EXPORT_SYMBOL(ptlrpc_connection_get);
 
 int ptlrpc_connection_put(struct ptlrpc_connection *conn)
 {
@@ -118,7 +117,6 @@ int ptlrpc_connection_put(struct ptlrpc_connection *conn)
 
 	return rc;
 }
-EXPORT_SYMBOL(ptlrpc_connection_put);
 
 struct ptlrpc_connection *
 ptlrpc_connection_addref(struct ptlrpc_connection *conn)
@@ -130,7 +128,6 @@ ptlrpc_connection_addref(struct ptlrpc_connection *conn)
 
 	return conn;
 }
-EXPORT_SYMBOL(ptlrpc_connection_addref);
 
 int ptlrpc_connection_init(void)
 {
@@ -146,13 +143,11 @@ int ptlrpc_connection_init(void)
 
 	return 0;
 }
-EXPORT_SYMBOL(ptlrpc_connection_init);
 
 void ptlrpc_connection_fini(void)
 {
 	cfs_hash_putref(conn_hash);
 }
-EXPORT_SYMBOL(ptlrpc_connection_fini);
 
 /*
  * Hash operations for net_peer<->connection
diff --git a/drivers/staging/lustre/lustre/ptlrpc/import.c b/drivers/staging/lustre/lustre/ptlrpc/import.c
index 20daa06..5333cda 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/import.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/import.c
@@ -425,7 +425,6 @@ void ptlrpc_fail_import(struct obd_import *imp, __u32 conn_cnt)
 		ptlrpc_pinger_force(imp);
 	}
 }
-EXPORT_SYMBOL(ptlrpc_fail_import);
 
 int ptlrpc_reconnect_import(struct obd_import *imp)
 {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
index 5bab248..9c93739 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
@@ -295,7 +295,6 @@ int ptlrpc_unregister_bulk(struct ptlrpc_request *req, int async)
 	}
 	return 0;
 }
-EXPORT_SYMBOL(ptlrpc_unregister_bulk);
 
 static void ptlrpc_at_set_reply(struct ptlrpc_request *req, int flags)
 {
@@ -434,7 +433,6 @@ out:
 	ptlrpc_connection_put(conn);
 	return rc;
 }
-EXPORT_SYMBOL(ptlrpc_send_reply);
 
 int ptlrpc_reply(struct ptlrpc_request *req)
 {
@@ -442,7 +440,6 @@ int ptlrpc_reply(struct ptlrpc_request *req)
 		return 0;
 	return ptlrpc_send_reply(req, 0);
 }
-EXPORT_SYMBOL(ptlrpc_reply);
 
 /**
  * For request \a req send an error reply back. Create empty
@@ -469,13 +466,11 @@ int ptlrpc_send_error(struct ptlrpc_request *req, int may_be_difficult)
 	rc = ptlrpc_send_reply(req, may_be_difficult);
 	return rc;
 }
-EXPORT_SYMBOL(ptlrpc_send_error);
 
 int ptlrpc_error(struct ptlrpc_request *req)
 {
 	return ptlrpc_send_error(req, 0);
 }
-EXPORT_SYMBOL(ptlrpc_error);
 
 /**
  * Send request \a request.
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index a1ea0c2..1349bf6 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -66,7 +66,6 @@ u32 lustre_msg_hdr_size(__u32 magic, u32 count)
 		return 0;
 	}
 }
-EXPORT_SYMBOL(lustre_msg_hdr_size);
 
 void ptlrpc_buf_set_swabbed(struct ptlrpc_request *req, const int inout,
 			    u32 index)
@@ -76,7 +75,6 @@ void ptlrpc_buf_set_swabbed(struct ptlrpc_request *req, const int inout,
 	else
 		lustre_set_rep_swabbed(req, index);
 }
-EXPORT_SYMBOL(ptlrpc_buf_set_swabbed);
 
 int ptlrpc_buf_need_swab(struct ptlrpc_request *req, const int inout,
 			 u32 index)
@@ -88,7 +86,6 @@ int ptlrpc_buf_need_swab(struct ptlrpc_request *req, const int inout,
 		return (ptlrpc_rep_need_swab(req) &&
 			!lustre_rep_swabbed(req, index));
 }
-EXPORT_SYMBOL(ptlrpc_buf_need_swab);
 
 /* early reply size */
 u32 lustre_msg_early_size(void)
@@ -151,7 +148,6 @@ u32 lustre_msg_size(__u32 magic, int count, __u32 *lens)
 		return 0;
 	}
 }
-EXPORT_SYMBOL(lustre_msg_size);
 
 /* This is used to determine the size of a buffer that was already packed
  * and will correctly handle the different message formats.
@@ -166,7 +162,6 @@ u32 lustre_packed_msg_size(struct lustre_msg *msg)
 		return 0;
 	}
 }
-EXPORT_SYMBOL(lustre_packed_msg_size);
 
 void lustre_init_msg_v2(struct lustre_msg_v2 *msg, int count, __u32 *lens,
 			char **bufs)
@@ -227,7 +222,6 @@ int lustre_pack_request(struct ptlrpc_request *req, __u32 magic, int count,
 	/* only use new format, we don't need to be compatible with 1.4 */
 	return lustre_pack_request_v2(req, count, lens, bufs);
 }
-EXPORT_SYMBOL(lustre_pack_request);
 
 #if RS_DEBUG
 LIST_HEAD(ptlrpc_rs_debug_lru);
@@ -369,7 +363,6 @@ int lustre_pack_reply_flags(struct ptlrpc_request *req, int count, __u32 *lens,
 		       lustre_msg_size(req->rq_reqmsg->lm_magic, count, lens));
 	return rc;
 }
-EXPORT_SYMBOL(lustre_pack_reply_flags);
 
 int lustre_pack_reply(struct ptlrpc_request *req, int count, __u32 *lens,
 		      char **bufs)
@@ -491,7 +484,6 @@ void lustre_free_reply_state(struct ptlrpc_reply_state *rs)
 
 	sptlrpc_svc_free_rs(rs);
 }
-EXPORT_SYMBOL(lustre_free_reply_state);
 
 static int lustre_unpack_msg_v2(struct lustre_msg_v2 *m, int len)
 {
@@ -579,7 +571,6 @@ int ptlrpc_unpack_req_msg(struct ptlrpc_request *req, int len)
 	}
 	return rc;
 }
-EXPORT_SYMBOL(ptlrpc_unpack_req_msg);
 
 int ptlrpc_unpack_rep_msg(struct ptlrpc_request *req, int len)
 {
@@ -592,7 +583,6 @@ int ptlrpc_unpack_rep_msg(struct ptlrpc_request *req, int len)
 	}
 	return rc;
 }
-EXPORT_SYMBOL(ptlrpc_unpack_rep_msg);
 
 static inline int lustre_unpack_ptlrpc_body_v2(struct ptlrpc_request *req,
 					       const int inout, int offset)
@@ -685,7 +675,6 @@ u32 lustre_msg_bufcount(struct lustre_msg *m)
 		return 0;
 	}
 }
-EXPORT_SYMBOL(lustre_msg_bufcount);
 
 char *lustre_msg_string(struct lustre_msg *m, u32 index, u32 max_len)
 {
@@ -729,7 +718,6 @@ char *lustre_msg_string(struct lustre_msg *m, u32 index, u32 max_len)
 
 	return str;
 }
-EXPORT_SYMBOL(lustre_msg_string);
 
 /* Wrap up the normal fixed length cases */
 static inline void *__lustre_swab_buf(struct lustre_msg *msg, u32 index,
@@ -832,7 +820,6 @@ void lustre_msg_set_flags(struct lustre_msg *msg, u32 flags)
 		LASSERTF(0, "incorrect message magic: %08x\n", msg->lm_magic);
 	}
 }
-EXPORT_SYMBOL(lustre_msg_set_flags);
 
 void lustre_msg_clear_flags(struct lustre_msg *msg, u32 flags)
 {
@@ -866,7 +853,6 @@ __u32 lustre_msg_get_op_flags(struct lustre_msg *msg)
 		return 0;
 	}
 }
-EXPORT_SYMBOL(lustre_msg_get_op_flags);
 
 void lustre_msg_add_op_flags(struct lustre_msg *msg, u32 flags)
 {
@@ -901,7 +887,6 @@ struct lustre_handle *lustre_msg_get_handle(struct lustre_msg *msg)
 		return NULL;
 	}
 }
-EXPORT_SYMBOL(lustre_msg_get_handle);
 
 __u32 lustre_msg_get_type(struct lustre_msg *msg)
 {
@@ -936,7 +921,6 @@ void lustre_msg_add_version(struct lustre_msg *msg, u32 version)
 		LASSERTF(0, "incorrect message magic: %08x\n", msg->lm_magic);
 	}
 }
-EXPORT_SYMBOL(lustre_msg_add_version);
 
 __u32 lustre_msg_get_opc(struct lustre_msg *msg)
 {
@@ -1053,7 +1037,6 @@ __u64 lustre_msg_get_slv(struct lustre_msg *msg)
 		return -EINVAL;
 	}
 }
-EXPORT_SYMBOL(lustre_msg_get_slv);
 
 void lustre_msg_set_slv(struct lustre_msg *msg, __u64 slv)
 {
@@ -1073,7 +1056,6 @@ void lustre_msg_set_slv(struct lustre_msg *msg, __u64 slv)
 		return;
 	}
 }
-EXPORT_SYMBOL(lustre_msg_set_slv);
 
 __u32 lustre_msg_get_limit(struct lustre_msg *msg)
 {
@@ -1092,7 +1074,6 @@ __u32 lustre_msg_get_limit(struct lustre_msg *msg)
 		return -EINVAL;
 	}
 }
-EXPORT_SYMBOL(lustre_msg_get_limit);
 
 void lustre_msg_set_limit(struct lustre_msg *msg, __u64 limit)
 {
@@ -1112,7 +1093,6 @@ void lustre_msg_set_limit(struct lustre_msg *msg, __u64 limit)
 		return;
 	}
 }
-EXPORT_SYMBOL(lustre_msg_set_limit);
 
 __u32 lustre_msg_get_conn_cnt(struct lustre_msg *msg)
 {
@@ -1143,7 +1123,6 @@ __u32 lustre_msg_get_magic(struct lustre_msg *msg)
 		return 0;
 	}
 }
-EXPORT_SYMBOL(lustre_msg_get_magic);
 
 __u32 lustre_msg_get_timeout(struct lustre_msg *msg)
 {
@@ -1226,7 +1205,6 @@ void lustre_msg_set_handle(struct lustre_msg *msg, struct lustre_handle *handle)
 		LASSERTF(0, "incorrect message magic: %08x\n", msg->lm_magic);
 	}
 }
-EXPORT_SYMBOL(lustre_msg_set_handle);
 
 void lustre_msg_set_type(struct lustre_msg *msg, __u32 type)
 {
@@ -1242,7 +1220,6 @@ void lustre_msg_set_type(struct lustre_msg *msg, __u32 type)
 		LASSERTF(0, "incorrect message magic: %08x\n", msg->lm_magic);
 	}
 }
-EXPORT_SYMBOL(lustre_msg_set_type);
 
 void lustre_msg_set_opc(struct lustre_msg *msg, __u32 opc)
 {
@@ -1258,7 +1235,6 @@ void lustre_msg_set_opc(struct lustre_msg *msg, __u32 opc)
 		LASSERTF(0, "incorrect message magic: %08x\n", msg->lm_magic);
 	}
 }
-EXPORT_SYMBOL(lustre_msg_set_opc);
 
 void lustre_msg_set_versions(struct lustre_msg *msg, __u64 *versions)
 {
@@ -1325,7 +1301,6 @@ void lustre_msg_set_conn_cnt(struct lustre_msg *msg, __u32 conn_cnt)
 		LASSERTF(0, "incorrect message magic: %08x\n", msg->lm_magic);
 	}
 }
-EXPORT_SYMBOL(lustre_msg_set_conn_cnt);
 
 void lustre_msg_set_timeout(struct lustre_msg *msg, __u32 timeout)
 {
@@ -1490,7 +1465,6 @@ void lustre_swab_ptlrpc_body(struct ptlrpc_body *b)
 	 */
 	CLASSERT(offsetof(typeof(*b), pb_jobid) != 0);
 }
-EXPORT_SYMBOL(lustre_swab_ptlrpc_body);
 
 void lustre_swab_connect(struct obd_connect_data *ocd)
 {
@@ -1590,7 +1564,6 @@ void lustre_swab_obd_statfs(struct obd_statfs *os)
 	CLASSERT(offsetof(typeof(*os), os_spare8) != 0);
 	CLASSERT(offsetof(typeof(*os), os_spare9) != 0);
 }
-EXPORT_SYMBOL(lustre_swab_obd_statfs);
 
 void lustre_swab_obd_ioobj(struct obd_ioobj *ioo)
 {
@@ -1598,7 +1571,6 @@ void lustre_swab_obd_ioobj(struct obd_ioobj *ioo)
 	__swab32s(&ioo->ioo_max_brw);
 	__swab32s(&ioo->ioo_bufcnt);
 }
-EXPORT_SYMBOL(lustre_swab_obd_ioobj);
 
 void lustre_swab_niobuf_remote(struct niobuf_remote *nbr)
 {
@@ -1606,25 +1578,21 @@ void lustre_swab_niobuf_remote(struct niobuf_remote *nbr)
 	__swab32s(&nbr->rnb_len);
 	__swab32s(&nbr->rnb_flags);
 }
-EXPORT_SYMBOL(lustre_swab_niobuf_remote);
 
 void lustre_swab_ost_body(struct ost_body *b)
 {
 	lustre_swab_obdo(&b->oa);
 }
-EXPORT_SYMBOL(lustre_swab_ost_body);
 
 void lustre_swab_ost_last_id(u64 *id)
 {
 	__swab64s(id);
 }
-EXPORT_SYMBOL(lustre_swab_ost_last_id);
 
 void lustre_swab_generic_32s(__u32 *val)
 {
 	__swab32s(val);
 }
-EXPORT_SYMBOL(lustre_swab_generic_32s);
 
 void lustre_swab_gl_desc(union ldlm_gl_desc *desc)
 {
@@ -1703,7 +1671,6 @@ void lustre_swab_mdt_body(struct mdt_body *b)
 	__swab32s(&b->mbo_gid_h);
 	CLASSERT(offsetof(typeof(*b), mbo_padding_5) != 0);
 }
-EXPORT_SYMBOL(lustre_swab_mdt_body);
 
 void lustre_swab_mdt_ioepoch(struct mdt_ioepoch *b)
 {
@@ -1712,7 +1679,6 @@ void lustre_swab_mdt_ioepoch(struct mdt_ioepoch *b)
 	 __swab32s(&b->flags);
 	 CLASSERT(offsetof(typeof(*b), padding) != 0);
 }
-EXPORT_SYMBOL(lustre_swab_mdt_ioepoch);
 
 void lustre_swab_mgs_target_info(struct mgs_target_info *mti)
 {
@@ -1728,7 +1694,6 @@ void lustre_swab_mgs_target_info(struct mgs_target_info *mti)
 	for (i = 0; i < MTI_NIDS_MAX; i++)
 		__swab64s(&mti->mti_nids[i]);
 }
-EXPORT_SYMBOL(lustre_swab_mgs_target_info);
 
 void lustre_swab_mgs_nidtbl_entry(struct mgs_nidtbl_entry *entry)
 {
@@ -1759,14 +1724,12 @@ void lustre_swab_mgs_config_body(struct mgs_config_body *body)
 	__swab32s(&body->mcb_units);
 	__swab16s(&body->mcb_type);
 }
-EXPORT_SYMBOL(lustre_swab_mgs_config_body);
 
 void lustre_swab_mgs_config_res(struct mgs_config_res *body)
 {
 	__swab64s(&body->mcr_offset);
 	__swab64s(&body->mcr_size);
 }
-EXPORT_SYMBOL(lustre_swab_mgs_config_res);
 
 static void lustre_swab_obd_dqinfo(struct obd_dqinfo *i)
 {
@@ -1799,7 +1762,6 @@ void lustre_swab_obd_quotactl(struct obd_quotactl *q)
 	lustre_swab_obd_dqinfo(&q->qc_dqinfo);
 	lustre_swab_obd_dqblk(&q->qc_dqblk);
 }
-EXPORT_SYMBOL(lustre_swab_obd_quotactl);
 
 void lustre_swab_fid2path(struct getinfo_fid2path *gf)
 {
@@ -1833,7 +1795,6 @@ void lustre_swab_fiemap(struct ll_user_fiemap *fiemap)
 	for (i = 0; i < fiemap->fm_mapped_extents; i++)
 		lustre_swab_fiemap_extent(&fiemap->fm_extents[i]);
 }
-EXPORT_SYMBOL(lustre_swab_fiemap);
 
 void lustre_swab_mdt_rec_reint (struct mdt_rec_reint *rr)
 {
@@ -1862,7 +1823,6 @@ void lustre_swab_mdt_rec_reint (struct mdt_rec_reint *rr)
 
 	CLASSERT(offsetof(typeof(*rr), rr_padding_4) != 0);
 };
-EXPORT_SYMBOL(lustre_swab_mdt_rec_reint);
 
 void lustre_swab_lov_desc(struct lov_desc *ld)
 {
@@ -1901,7 +1861,6 @@ void lustre_swab_lmv_mds_md(union lmv_mds_md *lmm)
 		break;
 	}
 }
-EXPORT_SYMBOL(lustre_swab_lmv_mds_md);
 
 void lustre_swab_lmv_user_md(struct lmv_user_md *lum)
 {
@@ -1955,7 +1914,6 @@ void lustre_swab_lov_mds_md(struct lov_mds_md *lmm)
 	__swab16s(&lmm->lmm_stripe_count);
 	__swab16s(&lmm->lmm_layout_gen);
 }
-EXPORT_SYMBOL(lustre_swab_lov_mds_md);
 
 void lustre_swab_lov_user_md_objects(struct lov_user_ost_data *lod,
 				     int stripe_count)
@@ -1995,7 +1953,6 @@ void lustre_swab_ldlm_intent(struct ldlm_intent *i)
 {
 	__swab64s(&i->opc);
 }
-EXPORT_SYMBOL(lustre_swab_ldlm_intent);
 
 static void lustre_swab_ldlm_resource_desc(struct ldlm_resource_desc *r)
 {
@@ -2019,7 +1976,6 @@ void lustre_swab_ldlm_request(struct ldlm_request *rq)
 	__swab32s(&rq->lock_count);
 	/* lock_handle[] opaque */
 }
-EXPORT_SYMBOL(lustre_swab_ldlm_request);
 
 void lustre_swab_ldlm_reply(struct ldlm_reply *r)
 {
@@ -2030,7 +1986,6 @@ void lustre_swab_ldlm_reply(struct ldlm_reply *r)
 	__swab64s(&r->lock_policy_res1);
 	__swab64s(&r->lock_policy_res2);
 }
-EXPORT_SYMBOL(lustre_swab_ldlm_reply);
 
 /* Dump functions */
 void dump_ioo(struct obd_ioobj *ioo)
@@ -2040,14 +1995,12 @@ void dump_ioo(struct obd_ioobj *ioo)
 	       POSTID(&ioo->ioo_oid), ioo->ioo_max_brw,
 	       ioo->ioo_bufcnt);
 }
-EXPORT_SYMBOL(dump_ioo);
 
 void dump_rniobuf(struct niobuf_remote *nb)
 {
 	CDEBUG(D_RPCTRACE, "niobuf_remote: offset=%llu, len=%d, flags=%x\n",
 	       nb->rnb_offset, nb->rnb_len, nb->rnb_flags);
 }
-EXPORT_SYMBOL(dump_rniobuf);
 
 static void dump_obdo(struct obdo *oa)
 {
@@ -2115,13 +2068,11 @@ void dump_ost_body(struct ost_body *ob)
 {
 	dump_obdo(&ob->oa);
 }
-EXPORT_SYMBOL(dump_ost_body);
 
 void dump_rcs(__u32 *rc)
 {
 	CDEBUG(D_RPCTRACE, "rmf_rcs: %d\n", *rc);
 }
-EXPORT_SYMBOL(dump_rcs);
 
 static inline int req_ptlrpc_body_swabbed(struct ptlrpc_request *req)
 {
@@ -2206,14 +2157,12 @@ void lustre_swab_lustre_capa(struct lustre_capa *c)
 	__swab32s(&c->lc_timeout);
 	__swab32s(&c->lc_expiry);
 }
-EXPORT_SYMBOL(lustre_swab_lustre_capa);
 
 void lustre_swab_hsm_user_state(struct hsm_user_state *state)
 {
 	__swab32s(&state->hus_states);
 	__swab32s(&state->hus_archive_id);
 }
-EXPORT_SYMBOL(lustre_swab_hsm_user_state);
 
 void lustre_swab_hsm_state_set(struct hsm_state_set *hss)
 {
@@ -2236,14 +2185,12 @@ void lustre_swab_hsm_current_action(struct hsm_current_action *action)
 	__swab32s(&action->hca_action);
 	lustre_swab_hsm_extent(&action->hca_location);
 }
-EXPORT_SYMBOL(lustre_swab_hsm_current_action);
 
 void lustre_swab_hsm_user_item(struct hsm_user_item *hui)
 {
 	lustre_swab_lu_fid(&hui->hui_fid);
 	lustre_swab_hsm_extent(&hui->hui_extent);
 }
-EXPORT_SYMBOL(lustre_swab_hsm_user_item);
 
 void lustre_swab_layout_intent(struct layout_intent *li)
 {
@@ -2252,7 +2199,6 @@ void lustre_swab_layout_intent(struct layout_intent *li)
 	__swab64s(&li->li_start);
 	__swab64s(&li->li_end);
 }
-EXPORT_SYMBOL(lustre_swab_layout_intent);
 
 void lustre_swab_hsm_progress_kernel(struct hsm_progress_kernel *hpk)
 {
@@ -2263,7 +2209,6 @@ void lustre_swab_hsm_progress_kernel(struct hsm_progress_kernel *hpk)
 	__swab16s(&hpk->hpk_flags);
 	__swab16s(&hpk->hpk_errval);
 }
-EXPORT_SYMBOL(lustre_swab_hsm_progress_kernel);
 
 void lustre_swab_hsm_request(struct hsm_request *hr)
 {
@@ -2273,7 +2218,6 @@ void lustre_swab_hsm_request(struct hsm_request *hr)
 	__swab32s(&hr->hr_itemcount);
 	__swab32s(&hr->hr_data_len);
 }
-EXPORT_SYMBOL(lustre_swab_hsm_request);
 
 void lustre_swab_swap_layouts(struct mdc_swap_layouts *msl)
 {
@@ -2286,4 +2230,3 @@ void lustre_swab_close_data(struct close_data *cd)
 	lustre_swab_lu_fid(&cd->cd_fid);
 	__swab64s(&cd->cd_data_version);
 }
-EXPORT_SYMBOL(lustre_swab_close_data);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pinger.c b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
index c0529d8..5504fc2 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pinger.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pinger.c
@@ -340,7 +340,6 @@ void ptlrpc_pinger_sending_on_import(struct obd_import *imp)
 {
 	ptlrpc_update_next_ping(imp, 0);
 }
-EXPORT_SYMBOL(ptlrpc_pinger_sending_on_import);
 
 void ptlrpc_pinger_commit_expected(struct obd_import *imp)
 {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
index b420aa8..f14d193 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
@@ -62,6 +62,11 @@ void ptlrpc_request_cache_fini(void);
 struct ptlrpc_request *ptlrpc_request_cache_alloc(gfp_t flags);
 void ptlrpc_request_cache_free(struct ptlrpc_request *req);
 void ptlrpc_init_xid(void);
+void ptlrpc_set_add_new_req(struct ptlrpcd_ctl *pc,
+			    struct ptlrpc_request *req);
+int ptlrpc_expired_set(void *data);
+int ptlrpc_set_next_timeout(struct ptlrpc_request_set *);
+void ptlrpc_resend_req(struct ptlrpc_request *request);
 
 /* events.c */
 int ptlrpc_init_portals(void);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/recover.c b/drivers/staging/lustre/lustre/ptlrpc/recover.c
index 718b3a8..405faf0 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/recover.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/recover.c
@@ -201,7 +201,6 @@ int ptlrpc_resend(struct obd_import *imp)
 
 	return 0;
 }
-EXPORT_SYMBOL(ptlrpc_resend);
 
 /**
  * Go through all requests in delayed list and wake their threads
@@ -221,7 +220,6 @@ void ptlrpc_wake_delayed(struct obd_import *imp)
 	}
 	spin_unlock(&imp->imp_lock);
 }
-EXPORT_SYMBOL(ptlrpc_wake_delayed);
 
 void ptlrpc_request_handle_notconn(struct ptlrpc_request *failed_req)
 {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
index 6adf274..b2cc5ea 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c
@@ -348,7 +348,6 @@ void sptlrpc_enc_pool_put_pages(struct ptlrpc_bulk_desc *desc)
 	kfree(desc->bd_enc_iov);
 	desc->bd_enc_iov = NULL;
 }
-EXPORT_SYMBOL(sptlrpc_enc_pool_put_pages);
 
 static inline void enc_pools_alloc(void)
 {
@@ -457,13 +456,11 @@ const char *sptlrpc_get_hash_name(__u8 hash_alg)
 {
 	return cfs_crypto_hash_name(cfs_hash_alg_id[hash_alg]);
 }
-EXPORT_SYMBOL(sptlrpc_get_hash_name);
 
 __u8 sptlrpc_get_hash_alg(const char *algname)
 {
 	return cfs_crypto_hash_alg(algname);
 }
-EXPORT_SYMBOL(sptlrpc_get_hash_alg);
 
 int bulk_sec_desc_unpack(struct lustre_msg *msg, int offset, int swabbed)
 {
@@ -544,4 +541,3 @@ int sptlrpc_get_bulk_checksum(struct ptlrpc_bulk_desc *desc, __u8 alg,
 
 	return err;
 }
-EXPORT_SYMBOL(sptlrpc_get_bulk_checksum);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
index c140354..2181a85 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
@@ -58,7 +58,6 @@ enum lustre_sec_part sptlrpc_target_sec_part(struct obd_device *obd)
 	CERROR("unknown target %p(%s)\n", obd, type);
 	return LUSTRE_SP_ANY;
 }
-EXPORT_SYMBOL(sptlrpc_target_sec_part);
 
 /****************************************
  * user supplied flavor string parsing  *
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
index f79a889..8ffd000 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
@@ -71,7 +71,6 @@ void sptlrpc_gc_add_sec(struct ptlrpc_sec *sec)
 
 	CDEBUG(D_SEC, "added sec %p(%s)\n", sec, sec->ps_policy->sp_name);
 }
-EXPORT_SYMBOL(sptlrpc_gc_add_sec);
 
 void sptlrpc_gc_del_sec(struct ptlrpc_sec *sec)
 {
@@ -95,7 +94,6 @@ void sptlrpc_gc_del_sec(struct ptlrpc_sec *sec)
 
 	CDEBUG(D_SEC, "del sec %p(%s)\n", sec, sec->ps_policy->sp_name);
 }
-EXPORT_SYMBOL(sptlrpc_gc_del_sec);
 
 static void sec_process_ctx_list(void)
 {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index a2fce66..3edc9b1 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -2407,7 +2407,6 @@ int ptlrpc_start_threads(struct ptlrpc_service *svc)
 	ptlrpc_stop_all_threads(svc);
 	return rc;
 }
-EXPORT_SYMBOL(ptlrpc_start_threads);
 
 int ptlrpc_start_thread(struct ptlrpc_service_part *svcpt, int wait)
 {
-- 
1.7.1
