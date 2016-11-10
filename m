From: James Simmons <jsimmons@infradead.org>
Date: Thu, 10 Nov 2016 12:30:33 -0500
Subject: [lustre-devel] [PATCH 03/35] staging: lustre: ptlrpc: mbits is sent
	within ptlrpc_body
In-Reply-To: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
References: <1478799065-24841-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1478799065-24841-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Liang Zhen <liang.zhen@intel.com>, James Simmons <jsimmons@infradead.org>

From: Liang Zhen <liang.zhen@intel.com>

ptlrpc is using rq_xid as matchbits of bulk data, which means it
has to change rq_xid for bulk resend to avoid several bulk data
landing into the same buffer from different resends.

This patch uses one of reserved __u64 of ptlrpc_body to transfer
mbits to peer, matchbits is now separated from xid. With this change,
ptlrpc can keep rq_xid unchanged on resend, it only updates matchbits
for bulk data.

This protocol change is only applied if both sides of connection have
OBD_CONNECT_BULK_MBITS, otherwise, ptlrpc still uses old approach and
update xid while resending bulk.

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3534
Reviewed-on: http://review.whamcloud.com/15421
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |   12 +++-
 drivers/staging/lustre/lustre/include/lustre_net.h |    5 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    7 ++-
 .../lustre/lustre/obdclass/lprocfs_status.c        |    1 +
 drivers/staging/lustre/lustre/obdclass/obd_mount.c |    2 +-
 drivers/staging/lustre/lustre/ptlrpc/client.c      |   72 ++++++++++++-------
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |   63 +++++++++--------
 .../staging/lustre/lustre/ptlrpc/pack_generic.c    |   20 +++++-
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |    1 +
 drivers/staging/lustre/lustre/ptlrpc/wiretest.c    |   40 +++++++++--
 10 files changed, 151 insertions(+), 72 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 21abab4..33deee6 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1006,8 +1006,11 @@ struct ptlrpc_body_v3 {
 	__u64 pb_slv;
 	/* VBR: pre-versions */
 	__u64 pb_pre_versions[PTLRPC_NUM_VERSIONS];
+	__u64 pb_mbits; /**< match bits for bulk request */
 	/* padding for future needs */
-	__u64 pb_padding[4];
+	__u64 pb_padding64_0;
+	__u64 pb_padding64_1;
+	__u64 pb_padding64_2;
 	char  pb_jobid[LUSTRE_JOBID_SIZE];
 };
 
@@ -1036,8 +1039,11 @@ struct ptlrpc_body_v2 {
 	__u64 pb_slv;
 	/* VBR: pre-versions */
 	__u64 pb_pre_versions[PTLRPC_NUM_VERSIONS];
+	__u64 pb_mbits; /**< unused in V2 */
 	/* padding for future needs */
-	__u64 pb_padding[4];
+	__u64 pb_padding64_0;
+	__u64 pb_padding64_1;
+	__u64 pb_padding64_2;
 };
 
 void lustre_swab_ptlrpc_body(struct ptlrpc_body *pb);
@@ -1182,6 +1188,8 @@ struct ptlrpc_body_v2 {
 						       *  RPCs in parallel
 						       */
 #define OBD_CONNECT_DIR_STRIPE	 0x400000000000000ULL/* striped DNE dir */
+/** bulk matchbits is sent within ptlrpc_body */
+#define OBD_CONNECT_BULK_MBITS	 0x2000000000000000ULL
 
 /* XXX README XXX:
  * Please DO NOT add flag values here before first ensuring that this same
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index a14f1a4..7f549a3 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -796,6 +796,8 @@ struct ptlrpc_request {
 	__u64 rq_transno;
 	/** xid */
 	__u64 rq_xid;
+	/** bulk match bits */
+	u64				rq_mbits;
 	/**
 	 * List item to for replay list. Not yet committed requests get linked
 	 * there.
@@ -1208,7 +1210,7 @@ struct ptlrpc_bulk_desc {
 	int		    bd_nob;	  /* # bytes covered */
 	int		    bd_nob_transferred; /* # bytes GOT/PUT */
 
-	__u64		  bd_last_xid;
+	u64			bd_last_mbits;
 
 	struct ptlrpc_cb_id    bd_cbid;	 /* network callback info */
 	lnet_nid_t	     bd_sender;       /* stash event::sender */
@@ -2080,6 +2082,7 @@ void lustre_msg_set_handle(struct lustre_msg *msg,
 void lustre_msg_set_service_time(struct lustre_msg *msg, __u32 service_time);
 void lustre_msg_set_jobid(struct lustre_msg *msg, char *jobid);
 void lustre_msg_set_cksum(struct lustre_msg *msg, __u32 cksum);
+void lustre_msg_set_mbits(struct lustre_msg *msg, u64 mbits);
 
 static inline void
 lustre_shrink_reply(struct ptlrpc_request *req, int segment,
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index c52653e..c1b646c 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -191,7 +191,8 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 				  OBD_CONNECT_FLOCK_DEAD |
 				  OBD_CONNECT_DISP_STRIPE | OBD_CONNECT_LFSCK |
 				  OBD_CONNECT_OPEN_BY_FID |
-				  OBD_CONNECT_DIR_STRIPE;
+				  OBD_CONNECT_DIR_STRIPE |
+				  OBD_CONNECT_BULK_MBITS;
 
 	if (sbi->ll_flags & LL_SBI_LRU_RESIZE)
 		data->ocd_connect_flags |= OBD_CONNECT_LRU_RESIZE;
@@ -352,7 +353,9 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt,
 				  OBD_CONNECT_64BITHASH | OBD_CONNECT_MAXBYTES |
 				  OBD_CONNECT_EINPROGRESS |
 				  OBD_CONNECT_JOBSTATS | OBD_CONNECT_LVB_TYPE |
-				  OBD_CONNECT_LAYOUTLOCK | OBD_CONNECT_PINGLESS;
+				  OBD_CONNECT_LAYOUTLOCK |
+				  OBD_CONNECT_PINGLESS | OBD_CONNECT_LFSCK |
+				  OBD_CONNECT_BULK_MBITS;
 
 	if (!OBD_FAIL_CHECK(OBD_FAIL_OSC_CONNECT_CKSUM)) {
 		/* OBD_CONNECT_CKSUM should always be set, even if checksums are
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index b520c96..8a2f02f 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -102,6 +102,7 @@
 	"unlink_close",
 	"multi_mod_rpcs",
 	"dir_stripe",
+	"bulk_mbits",
 	"unknown",
 	NULL
 };
diff --git a/drivers/staging/lustre/lustre/obdclass/obd_mount.c b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
index 59fbc29..1d13751 100644
--- a/drivers/staging/lustre/lustre/obdclass/obd_mount.c
+++ b/drivers/staging/lustre/lustre/obdclass/obd_mount.c
@@ -382,7 +382,7 @@ int lustre_start_mgc(struct super_block *sb)
 	/* We connect to the MGS at setup, and don't disconnect until cleanup */
 	data->ocd_connect_flags = OBD_CONNECT_VERSION | OBD_CONNECT_AT |
 				  OBD_CONNECT_FULL20 | OBD_CONNECT_IMP_RECOV |
-				  OBD_CONNECT_LVB_TYPE;
+				  OBD_CONNECT_LVB_TYPE | OBD_CONNECT_BULK_MBITS;
 
 #if OBD_OCD_VERSION(3, 0, 53, 0) > LUSTRE_VERSION_CODE
 	data->ocd_connect_flags |= OBD_CONNECT_MNE_SWAB;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index bb7ae4e..b940e24 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -1304,13 +1304,6 @@ static int after_reply(struct ptlrpc_request *req)
 		spin_unlock(&req->rq_lock);
 		req->rq_nr_resend++;
 
-		/* allocate new xid to avoid reply reconstruction */
-		if (!req->rq_bulk) {
-			/* new xid is already allocated for bulk in ptlrpc_check_set() */
-			req->rq_xid = ptlrpc_next_xid();
-			DEBUG_REQ(D_RPCTRACE, req, "Allocating new xid for resend on EINPROGRESS");
-		}
-
 		/* Readjust the timeout for current conditions */
 		ptlrpc_at_set_req_timeout(req);
 		/*
@@ -1802,18 +1795,9 @@ int ptlrpc_check_set(const struct lu_env *env, struct ptlrpc_request_set *set)
 					spin_lock(&req->rq_lock);
 					req->rq_resend = 1;
 					spin_unlock(&req->rq_lock);
-					if (req->rq_bulk) {
-						__u64 old_xid;
-
-						if (!ptlrpc_unregister_bulk(req, 1))
-							continue;
-
-						/* ensure previous bulk fails */
-						old_xid = req->rq_xid;
-						req->rq_xid = ptlrpc_next_xid();
-						CDEBUG(D_HA, "resend bulk old x%llu new x%llu\n",
-						       old_xid, req->rq_xid);
-					}
+					if (req->rq_bulk &&
+					    !ptlrpc_unregister_bulk(req, 1))
+						continue;
 				}
 				/*
 				 * rq_wait_ctx is only touched by ptlrpcd,
@@ -2664,14 +2648,6 @@ void ptlrpc_resend_req(struct ptlrpc_request *req)
 	req->rq_resend = 1;
 	req->rq_net_err = 0;
 	req->rq_timedout = 0;
-	if (req->rq_bulk) {
-		__u64 old_xid = req->rq_xid;
-
-		/* ensure previous bulk fails */
-		req->rq_xid = ptlrpc_next_xid();
-		CDEBUG(D_HA, "resend bulk old x%llu new x%llu\n",
-		       old_xid, req->rq_xid);
-	}
 	ptlrpc_client_wake_req(req);
 	spin_unlock(&req->rq_lock);
 }
@@ -3068,6 +3044,48 @@ __u64 ptlrpc_next_xid(void)
 }
 
 /**
+ * If request has a new allocated XID (new request or EINPROGRESS resend),
+ * use this XID as matchbits of bulk, otherwise allocate a new matchbits for
+ * request to ensure previous bulk fails and avoid problems with lost replies
+ * and therefore several transfers landing into the same buffer from different
+ * sending attempts.
+ */
+void ptlrpc_set_bulk_mbits(struct ptlrpc_request *req)
+{
+	struct ptlrpc_bulk_desc *bd = req->rq_bulk;
+
+	LASSERT(bd);
+
+	if (!req->rq_resend || req->rq_nr_resend) {
+		/* this request has a new xid, just use it as bulk matchbits */
+		req->rq_mbits = req->rq_xid;
+
+	} else { /* needs to generate a new matchbits for resend */
+		u64 old_mbits = req->rq_mbits;
+
+		if ((bd->bd_import->imp_connect_data.ocd_connect_flags &
+		     OBD_CONNECT_BULK_MBITS)) {
+			req->rq_mbits = ptlrpc_next_xid();
+		} else {
+			/* old version transfers rq_xid to peer as matchbits */
+			req->rq_mbits = ptlrpc_next_xid();
+			req->rq_xid = req->rq_mbits;
+		}
+
+		CDEBUG(D_HA, "resend bulk old x%llu new x%llu\n",
+		       old_mbits, req->rq_mbits);
+	}
+
+	/*
+	 * For multi-bulk RPCs, rq_mbits is the last mbits needed for bulks so
+	 * that server can infer the number of bulks that were prepared,
+	 * see LU-1431
+	 */
+	req->rq_mbits += ((bd->bd_iov_count + LNET_MAX_IOV - 1) /
+			  LNET_MAX_IOV) - 1;
+}
+
+/**
  * Get a glimpse at what next xid value might have been.
  * Returns possible next xid.
  */
diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
index 4e80ba9..5810565 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
@@ -114,7 +114,7 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 	int rc2;
 	int posted_md;
 	int total_md;
-	__u64 xid;
+	u64 mbits;
 	lnet_handle_me_t me_h;
 	lnet_md_t md;
 
@@ -142,40 +142,37 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 	LASSERT(desc->bd_cbid.cbid_fn == client_bulk_callback);
 	LASSERT(desc->bd_cbid.cbid_arg == desc);
 
-	/* An XID is only used for a single request from the client.
-	 * For retried bulk transfers, a new XID will be allocated in
-	 * in ptlrpc_check_set() if it needs to be resent, so it is not
-	 * using the same RDMA match bits after an error.
-	 *
-	 * For multi-bulk RPCs, rq_xid is the last XID needed for bulks. The
-	 * first bulk XID is power-of-two aligned before rq_xid. LU-1431
-	 */
-	xid = req->rq_xid & ~((__u64)desc->bd_md_max_brw - 1);
+	total_md = (desc->bd_iov_count + LNET_MAX_IOV - 1) / LNET_MAX_IOV;
+	/* rq_mbits is matchbits of the final bulk */
+	mbits = req->rq_mbits - total_md + 1;
+
+	LASSERTF(mbits == (req->rq_mbits & PTLRPC_BULK_OPS_MASK),
+		 "first mbits = x%llu, last mbits = x%llu\n",
+		 mbits, req->rq_mbits);
 	LASSERTF(!(desc->bd_registered &&
 		   req->rq_send_state != LUSTRE_IMP_REPLAY) ||
-		 xid != desc->bd_last_xid,
-		 "registered: %d  rq_xid: %llu bd_last_xid: %llu\n",
-		 desc->bd_registered, xid, desc->bd_last_xid);
+		 mbits != desc->bd_last_mbits,
+		 "registered: %d  rq_mbits: %llu bd_last_mbits: %llu\n",
+		 desc->bd_registered, mbits, desc->bd_last_mbits);
 
-	total_md = (desc->bd_iov_count + LNET_MAX_IOV - 1) / LNET_MAX_IOV;
 	desc->bd_registered = 1;
-	desc->bd_last_xid = xid;
+	desc->bd_last_mbits = mbits;
 	desc->bd_md_count = total_md;
 	md.user_ptr = &desc->bd_cbid;
 	md.eq_handle = ptlrpc_eq_h;
 	md.threshold = 1;		       /* PUT or GET */
 
-	for (posted_md = 0; posted_md < total_md; posted_md++, xid++) {
+	for (posted_md = 0; posted_md < total_md; posted_md++, mbits++) {
 		md.options = PTLRPC_MD_OPTIONS |
 			     (ptlrpc_is_bulk_op_get(desc->bd_type) ?
 			      LNET_MD_OP_GET : LNET_MD_OP_PUT);
 		ptlrpc_fill_bulk_md(&md, desc, posted_md);
 
-		rc = LNetMEAttach(desc->bd_portal, peer, xid, 0,
+		rc = LNetMEAttach(desc->bd_portal, peer, mbits, 0,
 				  LNET_UNLINK, LNET_INS_AFTER, &me_h);
 		if (rc != 0) {
 			CERROR("%s: LNetMEAttach failed x%llu/%d: rc = %d\n",
-			       desc->bd_import->imp_obd->obd_name, xid,
+			       desc->bd_import->imp_obd->obd_name, mbits,
 			       posted_md, rc);
 			break;
 		}
@@ -185,7 +182,7 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 				  &desc->bd_mds[posted_md]);
 		if (rc != 0) {
 			CERROR("%s: LNetMDAttach failed x%llu/%d: rc = %d\n",
-			       desc->bd_import->imp_obd->obd_name, xid,
+			       desc->bd_import->imp_obd->obd_name, mbits,
 			       posted_md, rc);
 			rc2 = LNetMEUnlink(me_h);
 			LASSERT(rc2 == 0);
@@ -204,27 +201,19 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 		return -ENOMEM;
 	}
 
-	/* Set rq_xid to matchbits of the final bulk so that server can
-	 * infer the number of bulks that were prepared
-	 */
-	req->rq_xid = --xid;
-	LASSERTF(desc->bd_last_xid == (req->rq_xid & PTLRPC_BULK_OPS_MASK),
-		 "bd_last_xid = x%llu, rq_xid = x%llu\n",
-		 desc->bd_last_xid, req->rq_xid);
-
 	spin_lock(&desc->bd_lock);
-	/* Holler if peer manages to touch buffers before he knows the xid */
+	/* Holler if peer manages to touch buffers before he knows the mbits */
 	if (desc->bd_md_count != total_md)
 		CWARN("%s: Peer %s touched %d buffers while I registered\n",
 		      desc->bd_import->imp_obd->obd_name, libcfs_id2str(peer),
 		      total_md - desc->bd_md_count);
 	spin_unlock(&desc->bd_lock);
 
-	CDEBUG(D_NET, "Setup %u bulk %s buffers: %u pages %u bytes, xid x%#llx-%#llx, portal %u\n",
+	CDEBUG(D_NET, "Setup %u bulk %s buffers: %u pages %u bytes, mbits x%#llx-%#llx, portal %u\n",
 	       desc->bd_md_count,
 	       ptlrpc_is_bulk_op_get(desc->bd_type) ? "get-source" : "put-sink",
 	       desc->bd_iov_count, desc->bd_nob,
-	       desc->bd_last_xid, req->rq_xid, desc->bd_portal);
+	       desc->bd_last_mbits, req->rq_mbits, desc->bd_portal);
 
 	return 0;
 }
@@ -520,6 +509,20 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	lustre_msg_set_conn_cnt(request->rq_reqmsg, imp->imp_conn_cnt);
 	lustre_msghdr_set_flags(request->rq_reqmsg, imp->imp_msghdr_flags);
 
+	if (request->rq_nr_resend) {
+		/*
+		 * resend for EINPROGRESS, allocate new xid to avoid reply
+		 * reconstruction
+		 */
+		request->rq_xid = ptlrpc_next_xid();
+		DEBUG_REQ(D_RPCTRACE, request, "Allocating new xid for resend on EINPROGRESS");
+	}
+
+	if (request->rq_bulk) {
+		ptlrpc_set_bulk_mbits(request);
+		lustre_msg_set_mbits(request->rq_reqmsg, request->rq_mbits);
+	}
+
 	/**
 	 * For enabled AT all request should have AT_SUPPORT in the
 	 * FULL import state when OBD_CONNECT_AT is set
diff --git a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
index 4f63a80..39c4e18 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/pack_generic.c
@@ -1423,6 +1423,21 @@ void lustre_msg_set_cksum(struct lustre_msg *msg, __u32 cksum)
 	}
 }
 
+void lustre_msg_set_mbits(struct lustre_msg *msg, __u64 mbits)
+{
+	switch (msg->lm_magic) {
+	case LUSTRE_MSG_MAGIC_V2: {
+		struct ptlrpc_body *pb = lustre_msg_ptlrpc_body(msg);
+
+		LASSERTF(pb, "invalid msg %p: no ptlrpc body!\n", msg);
+		pb->pb_mbits = mbits;
+		return;
+	}
+	default:
+		LASSERTF(0, "incorrect message magic: %08x\n", msg->lm_magic);
+	}
+}
+
 void ptlrpc_request_set_replen(struct ptlrpc_request *req)
 {
 	int count = req_capsule_filled_sizes(&req->rq_pill, RCL_SERVER);
@@ -1506,9 +1521,12 @@ void lustre_swab_ptlrpc_body(struct ptlrpc_body *b)
 	__swab64s(&b->pb_pre_versions[1]);
 	__swab64s(&b->pb_pre_versions[2]);
 	__swab64s(&b->pb_pre_versions[3]);
+	__swab64s(&b->pb_mbits);
 	CLASSERT(offsetof(typeof(*b), pb_padding0) != 0);
 	CLASSERT(offsetof(typeof(*b), pb_padding1) != 0);
-	CLASSERT(offsetof(typeof(*b), pb_padding) != 0);
+	CLASSERT(offsetof(typeof(*b), pb_padding64_0) != 0);
+	CLASSERT(offsetof(typeof(*b), pb_padding64_1) != 0);
+	CLASSERT(offsetof(typeof(*b), pb_padding64_2) != 0);
 	/* While we need to maintain compatibility between
 	 * clients and servers without ptlrpc_body_v2 (< 2.3)
 	 * do not swab any fields beyond pb_jobid, as we are
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
index b848c25..f056c82 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
@@ -70,6 +70,7 @@ void ptlrpc_set_add_new_req(struct ptlrpcd_ctl *pc,
 int ptlrpc_expired_set(void *data);
 int ptlrpc_set_next_timeout(struct ptlrpc_request_set *);
 void ptlrpc_resend_req(struct ptlrpc_request *request);
+void ptlrpc_set_bulk_mbits(struct ptlrpc_request *req);
 
 /* events.c */
 int ptlrpc_init_portals(void);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
index 6c75446..485ac88 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/wiretest.c
@@ -668,10 +668,22 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct ptlrpc_body_v3, pb_pre_versions));
 	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_pre_versions) == 32, "found %lld\n",
 		 (long long)(int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_pre_versions));
-	LASSERTF((int)offsetof(struct ptlrpc_body_v3, pb_padding) == 120, "found %lld\n",
-		 (long long)(int)offsetof(struct ptlrpc_body_v3, pb_padding));
-	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding) == 32, "found %lld\n",
-		 (long long)(int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding));
+	LASSERTF((int)offsetof(struct ptlrpc_body_v3, pb_mbits) == 120, "found %lld\n",
+		 (long long)(int)offsetof(struct ptlrpc_body_v3, pb_mbits));
+	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_mbits) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_mbits));
+	LASSERTF((int)offsetof(struct ptlrpc_body_v3, pb_padding64_0) == 128, "found %lld\n",
+		 (long long)(int)offsetof(struct ptlrpc_body_v3, pb_padding64_0));
+	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding64_0) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding64_0));
+	LASSERTF((int)offsetof(struct ptlrpc_body_v3, pb_padding64_1) == 136, "found %lld\n",
+		 (long long)(int)offsetof(struct ptlrpc_body_v3, pb_padding64_1));
+	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding64_1) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding64_1));
+	LASSERTF((int)offsetof(struct ptlrpc_body_v3, pb_padding64_2) == 144, "found %lld\n",
+		 (long long)(int)offsetof(struct ptlrpc_body_v3, pb_padding64_2));
+	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding64_2) == 8, "found %lld\n",
+		 (long long)(int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding64_2));
 	CLASSERT(LUSTRE_JOBID_SIZE == 32);
 	LASSERTF((int)offsetof(struct ptlrpc_body_v3, pb_jobid) == 152, "found %lld\n",
 		 (long long)(int)offsetof(struct ptlrpc_body_v3, pb_jobid));
@@ -753,10 +765,22 @@ void lustre_assert_wire_constants(void)
 		 (int)offsetof(struct ptlrpc_body_v3, pb_pre_versions), (int)offsetof(struct ptlrpc_body_v2, pb_pre_versions));
 	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_pre_versions) == (int)sizeof(((struct ptlrpc_body_v2 *)0)->pb_pre_versions), "%d != %d\n",
 		 (int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_pre_versions), (int)sizeof(((struct ptlrpc_body_v2 *)0)->pb_pre_versions));
-	LASSERTF((int)offsetof(struct ptlrpc_body_v3, pb_padding) == (int)offsetof(struct ptlrpc_body_v2, pb_padding), "%d != %d\n",
-		 (int)offsetof(struct ptlrpc_body_v3, pb_padding), (int)offsetof(struct ptlrpc_body_v2, pb_padding));
-	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding) == (int)sizeof(((struct ptlrpc_body_v2 *)0)->pb_padding), "%d != %d\n",
-		 (int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding), (int)sizeof(((struct ptlrpc_body_v2 *)0)->pb_padding));
+	LASSERTF((int)offsetof(struct ptlrpc_body_v3, pb_mbits) == (int)offsetof(struct ptlrpc_body_v2, pb_mbits), "%d != %d\n",
+		 (int)offsetof(struct ptlrpc_body_v3, pb_mbits), (int)offsetof(struct ptlrpc_body_v2, pb_mbits));
+	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_mbits) == (int)sizeof(((struct ptlrpc_body_v2 *)0)->pb_mbits), "%d != %d\n",
+		 (int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_mbits), (int)sizeof(((struct ptlrpc_body_v2 *)0)->pb_mbits));
+	LASSERTF((int)offsetof(struct ptlrpc_body_v3, pb_padding64_0) == (int)offsetof(struct ptlrpc_body_v2, pb_padding64_0), "%d != %d\n",
+		 (int)offsetof(struct ptlrpc_body_v3, pb_padding64_0), (int)offsetof(struct ptlrpc_body_v2, pb_padding64_0));
+	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding64_0) == (int)sizeof(((struct ptlrpc_body_v2 *)0)->pb_padding64_0), "%d != %d\n",
+		 (int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding64_0), (int)sizeof(((struct ptlrpc_body_v2 *)0)->pb_padding64_0));
+	LASSERTF((int)offsetof(struct ptlrpc_body_v3, pb_padding64_1) == (int)offsetof(struct ptlrpc_body_v2, pb_padding64_1), "%d != %d\n",
+		 (int)offsetof(struct ptlrpc_body_v3, pb_padding64_1), (int)offsetof(struct ptlrpc_body_v2, pb_padding64_1));
+	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding64_1) == (int)sizeof(((struct ptlrpc_body_v2 *)0)->pb_padding64_1), "%d != %d\n",
+		 (int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding64_1), (int)sizeof(((struct ptlrpc_body_v2 *)0)->pb_padding64_1));
+	LASSERTF((int)offsetof(struct ptlrpc_body_v3, pb_padding64_2) == (int)offsetof(struct ptlrpc_body_v2, pb_padding64_2), "%d != %d\n",
+		 (int)offsetof(struct ptlrpc_body_v3, pb_padding64_2), (int)offsetof(struct ptlrpc_body_v2, pb_padding64_2));
+	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding64_2) == (int)sizeof(((struct ptlrpc_body_v2 *)0)->pb_padding64_2), "%d != %d\n",
+		 (int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding64_2), (int)sizeof(((struct ptlrpc_body_v2 *)0)->pb_padding64_2));
 	LASSERTF(MSG_PTLRPC_BODY_OFF == 0, "found %lld\n",
 		 (long long)MSG_PTLRPC_BODY_OFF);
 	LASSERTF(REQ_REC_OFF == 1, "found %lld\n",
-- 
1.7.1
