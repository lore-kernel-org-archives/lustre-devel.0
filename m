Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id EF257C0218A
	for <lustre-devel@archiver.kernel.org>; Thu, 30 Jan 2025 14:35:44 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YkLgB3czmz2285;
	Thu, 30 Jan 2025 06:16:38 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YkLYS2XCkz1whJ
 for <lustre-devel@lists.lustre.org>; Thu, 30 Jan 2025 06:11:40 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id E8262893E88;
 Thu, 30 Jan 2025 09:11:32 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id E581A106BE16; Thu, 30 Jan 2025 09:11:32 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 30 Jan 2025 09:10:56 -0500
Message-ID: <20250130141115.950749-7-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250130141115.950749-1-jsimmons@infradead.org>
References: <20250130141115.950749-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 06/25] lustre: tbf: pb_uid/pb_gid ptlrpc_body
 fields for TBF rules
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Etienne AUJAMES <etienne.aujames@cea.fr>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Etienne AUJAMES <etienne.aujames@cea.fr>

The file UID/GID are packed inside bulk IO because the requests are
sent asynchronously (cannot use the current thread UID/GID).

This is an issue for TBF rules if the file/inode UID/GID doesn't
match the process ones (e.g: reading common libraries): we can't limit
the user RPCs doing the IOs in that case.

This patch pack UID/GID for TBF rules inside ptlrpc_body (
pb_padding64_2 -> (pb_uid, pb_gid)) to be independent of quota
interactions: it stores the client process UID/GID instead of the
values of the file attrs.
Moreover, it enables to track requests naturally without UID/GID like
ldlm_flock_enqueue.

This patch saves the process UID/GID inside the ll_inode_info struct.
Then it restores these values when sending a bulk IO from a ptlrpc
thread (like for jobids).

Fixes: fa7d8b2 ("lustre: ptlrpc: Add QoS for uid and gid in NRS-TBF")
WC-bug-id: https://jira.whamcloud.com/browse/LU-16077
Lustre-commit: 0544c108c12c87a43 ("LU-16077 tbf: pb_uid/pb_gid ptlrpc_body fields for TBF rules")
Signed-off-by: Etienne AUJAMES <etienne.aujames@cea.fr>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48235
Reviewed-by: Qian Yingjin <qian@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h          |  3 +
 fs/lustre/include/lustre_net.h         |  2 +
 fs/lustre/llite/llite_internal.h       | 12 ++--
 fs/lustre/llite/llite_lib.c            |  4 +-
 fs/lustre/llite/vvp_io.c               |  8 ++-
 fs/lustre/llite/vvp_object.c           |  9 ++-
 fs/lustre/osc/osc_request.c            |  2 +
 fs/lustre/ptlrpc/client.c              |  4 +-
 fs/lustre/ptlrpc/pack_generic.c        | 99 +++++++++++++++++++++++---
 fs/lustre/ptlrpc/ptlrpcd.c             |  4 +-
 fs/lustre/ptlrpc/wiretest.c            | 22 +++---
 include/uapi/linux/lustre/lustre_idl.h |  4 +-
 12 files changed, 141 insertions(+), 32 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 8a98413fba31..77f00d7fc220 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -1974,6 +1974,9 @@ struct cl_req_attr {
 	struct obdo	       *cra_oa;
 	/** Jobid */
 	char			cra_jobid[LUSTRE_JOBID_SIZE];
+	/** uid/gid of the process doing an io */
+	u32			cra_uid;
+	u32			cra_gid;
 };
 
 enum cache_stats_item {
diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index a305ba3d08db..de1ef881d9d0 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -2088,6 +2088,7 @@ u32 lustre_msg_get_conn_cnt(struct lustre_msg *msg);
 u32 lustre_msg_get_magic(struct lustre_msg *msg);
 timeout_t lustre_msg_get_timeout(struct lustre_msg *msg);
 timeout_t lustre_msg_get_service_timeout(struct lustre_msg *msg);
+int lustre_msg_get_uid_gid(struct lustre_msg *msg, u32 *uid, u32 *gid);
 char *lustre_msg_get_jobid(struct lustre_msg *msg);
 u32 lustre_msg_get_cksum(struct lustre_msg *msg);
 u64 lustre_msg_get_mbits(struct lustre_msg *msg);
@@ -2106,6 +2107,7 @@ void ptlrpc_request_set_replen(struct ptlrpc_request *req);
 void lustre_msg_set_timeout(struct lustre_msg *msg, timeout_t timeout);
 void lustre_msg_set_service_timeout(struct lustre_msg *msg,
 				    timeout_t service_timeout);
+void lustre_msg_set_uid_gid(struct lustre_msg *msg, u32 *uid, u32 *gid);
 void lustre_msg_set_jobid(struct lustre_msg *msg, char *jobid);
 void lustre_msg_set_cksum(struct lustre_msg *msg, u32 cksum);
 void lustre_msg_set_mbits(struct lustre_msg *msg, u64 mbits);
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 88dbd6c692db..e86d700a182b 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -230,13 +230,17 @@ struct ll_inode_info {
 
 			/*
 			 * Whenever a process try to read/write the file, the
-			 * jobid of the process will be saved here, and it'll
-			 * be packed into the write PRC when flush later.
+			 * jobid, uid and gid of the process will be saved here,
+			 * and it'll be packed into write RPC when flush later.
 			 *
-			 * So the read/write statistics for jobid will not be
-			 * accurate if the file is shared by different jobs.
+			 * So the read/write statistics or TBF rules for jobid,
+			 * uid or gid will not be accurate if the file is shared
+			 * by different jobs.
 			 */
 			char				lli_jobid[LUSTRE_JOBID_SIZE];
+			u32				lli_uid;
+			u32				lli_gid;
+
 
 			struct mutex		 lli_pcc_lock;
 			enum lu_pcc_state_flags	 lli_pcc_state;
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index d4f17ce24465..936a81c65870 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1215,9 +1215,11 @@ void ll_lli_init(struct ll_inode_info *lli)
 		mutex_init(&lli->lli_group_mutex);
 		lli->lli_group_users = 0;
 		lli->lli_group_gid = 0;
+		memset(lli->lli_jobid, 0, sizeof(lli->lli_jobid));
+		lli->lli_uid = (u32) -1;
+		lli->lli_gid = (u32) -1;
 	}
 	mutex_init(&lli->lli_layout_mutex);
-	memset(lli->lli_jobid, 0, sizeof(lli->lli_jobid));
 	/* ll_cl_context initialize */
 	INIT_LIST_HEAD(&lli->lli_lccs);
 	seqlock_init(&lli->lli_page_inv_lock);
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index 31a3992dad34..26dfaaa76bd9 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -1741,13 +1741,15 @@ int vvp_io_init(const struct lu_env *env, struct cl_object *obj,
 		else
 			vio->vui_tot_count = count;
 
-		/* for read/write, we store the jobid in the inode, and
-		 * it'll be fetched by osc when building RPC.
+		/* for read/write, we store the process jobid/gid/uid in the
+		 * inode, and it'll be fetched by osc when building RPC.
 		 *
 		 * it's not accurate if the file is shared by different
-		 * jobs.
+		 * jobs/user/group.
 		 */
 		lustre_get_jobid(lli->lli_jobid, sizeof(lli->lli_jobid));
+		lli->lli_uid = from_kuid(&init_user_ns, current_uid());
+		lli->lli_gid = from_kgid(&init_user_ns, current_gid());
 	} else if (io->ci_type == CIT_SETATTR) {
 		if (!cl_io_is_trunc(io))
 			io->ci_lockreq = CILR_MANDATORY;
diff --git a/fs/lustre/llite/vvp_object.c b/fs/lustre/llite/vvp_object.c
index 302f90018982..c79bc5c0e6c9 100644
--- a/fs/lustre/llite/vvp_object.c
+++ b/fs/lustre/llite/vvp_object.c
@@ -199,11 +199,13 @@ static void vvp_req_attr_set(const struct lu_env *env, struct cl_object *obj,
 {
 	u64 valid_flags = OBD_MD_FLTYPE | OBD_MD_FLUID | OBD_MD_FLGID |
 			  OBD_MD_FLPROJID;
+	struct ll_inode_info *lli;
 	struct inode *inode;
 	struct obdo *oa;
 
 	oa = attr->cra_oa;
 	inode = vvp_object_inode(obj);
+	lli = ll_i2info(inode);
 
 	if (attr->cra_type == CRT_WRITE) {
 		valid_flags |= OBD_MD_FLMTIME | OBD_MD_FLCTIME;
@@ -215,8 +217,11 @@ static void vvp_req_attr_set(const struct lu_env *env, struct cl_object *obj,
 	obdo_set_parent_fid(oa, &ll_i2info(inode)->lli_fid);
 	if (OBD_FAIL_CHECK(OBD_FAIL_LFSCK_INVALID_PFID))
 		oa->o_parent_oid++;
-	memcpy(attr->cra_jobid, ll_i2info(inode)->lli_jobid,
-	       sizeof(attr->cra_jobid));
+
+	attr->cra_uid = lli->lli_uid;
+	attr->cra_gid = lli->lli_gid;
+
+	memcpy(attr->cra_jobid, &lli->lli_jobid, sizeof(attr->cra_jobid));
 }
 
 static const struct cl_object_operations vvp_ops = {
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index e0955c11191b..8efdd5a8cd8a 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -2797,6 +2797,8 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	crattr->cra_oa = &body->oa;
 	crattr->cra_flags = OBD_MD_FLMTIME | OBD_MD_FLCTIME | OBD_MD_FLATIME;
 	cl_req_attr_set(env, osc2cl(obj), crattr);
+	lustre_msg_set_uid_gid(req->rq_reqmsg, &crattr->cra_uid,
+			       &crattr->cra_gid);
 	lustre_msg_set_jobid(req->rq_reqmsg, crattr->cra_jobid);
 
 	aa = ptlrpc_req_async_args(aa, req);
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index c9a8c8f5841d..13c27977b14d 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -1159,8 +1159,10 @@ void ptlrpc_set_add_req(struct ptlrpc_request_set *set,
 	atomic_inc(&set->set_remaining);
 	req->rq_queued_time = ktime_get_seconds();
 
-	if (req->rq_reqmsg)
+	if (req->rq_reqmsg) {
 		lustre_msg_set_jobid(req->rq_reqmsg, NULL);
+		lustre_msg_set_uid_gid(req->rq_reqmsg, NULL, NULL);
+	}
 
 	if (set->set_producer)
 		/*
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index 8d58f9b9da2e..53e2912a28e7 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -1182,6 +1182,37 @@ timeout_t lustre_msg_get_service_timeout(struct lustre_msg *msg)
 	}
 }
 
+int lustre_msg_get_uid_gid(struct lustre_msg *msg, u32 *uid, u32 *gid)
+{
+	switch (msg->lm_magic) {
+	case LUSTRE_MSG_MAGIC_V2: {
+		struct ptlrpc_body *pb;
+
+		/* the old pltrpc_body_v2 is smaller; doesn't include uid/gid */
+		if (msg->lm_buflens[MSG_PTLRPC_BODY_OFF] <
+		    sizeof(struct ptlrpc_body))
+			return -EOPNOTSUPP;
+
+		pb = lustre_msg_buf_v2(msg, MSG_PTLRPC_BODY_OFF,
+					  sizeof(struct ptlrpc_body));
+
+		if (!pb || !(pb->pb_flags & MSG_PACK_UID_GID))
+			return -EOPNOTSUPP;
+
+		if (uid)
+			*uid = pb->pb_uid;
+		if (gid)
+			*gid = pb->pb_gid;
+
+		return 0;
+	}
+	default:
+		CERROR("incorrect message magic: %08x\n", msg->lm_magic);
+		return -EOPNOTSUPP;
+	}
+}
+EXPORT_SYMBOL(lustre_msg_get_uid_gid);
+
 char *lustre_msg_get_jobid(struct lustre_msg *msg)
 {
 	switch (msg->lm_magic) {
@@ -1443,6 +1474,40 @@ void lustre_msg_set_service_timeout(struct lustre_msg *msg,
 	}
 }
 
+void lustre_msg_set_uid_gid(struct lustre_msg *msg, u32 *uid, u32 *gid)
+{
+	switch (msg->lm_magic) {
+	case LUSTRE_MSG_MAGIC_V2: {
+		u32 opc = lustre_msg_get_opc(msg);
+		struct ptlrpc_body *pb;
+
+		/* Don't set uid/gid for ldlm ast RPCs */
+		if (!opc || opc == LDLM_BL_CALLBACK ||
+		    opc == LDLM_CP_CALLBACK || opc == LDLM_GL_CALLBACK)
+			return;
+
+		pb = lustre_msg_buf_v2(msg, MSG_PTLRPC_BODY_OFF,
+				       sizeof(struct ptlrpc_body));
+		LASSERTF(pb, "invalid msg %p: no ptlrpc body!\n", msg);
+
+		if (uid && gid) {
+			pb->pb_uid = *uid;
+			pb->pb_gid = *gid;
+			pb->pb_flags |= MSG_PACK_UID_GID;
+		} else if (!(pb->pb_flags & MSG_PACK_UID_GID)) {
+			pb->pb_uid = from_kuid(&init_user_ns, current_uid());
+			pb->pb_gid = from_kgid(&init_user_ns, current_gid());
+			pb->pb_flags |= MSG_PACK_UID_GID;
+		}
+
+		return;
+	}
+	default:
+		LASSERTF(0, "incorrect message magic: %08x\n", msg->lm_magic);
+	}
+}
+EXPORT_SYMBOL(lustre_msg_set_uid_gid);
+
 void lustre_msg_set_jobid(struct lustre_msg *msg, char *jobid)
 {
 	switch (msg->lm_magic) {
@@ -1592,7 +1657,8 @@ void lustre_swab_ptlrpc_body(struct ptlrpc_body *body)
 	__swab64s(&body->pb_mbits);
 	BUILD_BUG_ON(offsetof(typeof(*body), pb_padding64_0) == 0);
 	BUILD_BUG_ON(offsetof(typeof(*body), pb_padding64_1) == 0);
-	BUILD_BUG_ON(offsetof(typeof(*body), pb_padding64_2) == 0);
+	__swab32s(&body->pb_uid);
+	__swab32s(&body->pb_gid);
 	/* While we need to maintain compatibility between
 	 * clients and servers without ptlrpc_body_v2 (< 2.3)
 	 * do not swab any fields beyond pb_jobid, as we are
@@ -2473,8 +2539,14 @@ void _debug_req(struct ptlrpc_request *req,
 	struct lnet_nid *nid = NULL;
 	int rep_flags = -1;
 	int rep_status = -1;
-	va_list args;
+	u64 req_transno = 0;
+	int req_opc = -1;
+	u32 req_flags =  (u32) -1;
+	u32 req_uid = (u32) -1;
+	u32 req_gid = (u32) -1;
+	char *req_jobid = NULL;
 	struct va_format vaf;
+	va_list args;
 
 	spin_lock(&req->rq_early_free_lock);
 	if (req->rq_repmsg)
@@ -2496,15 +2568,22 @@ void _debug_req(struct ptlrpc_request *req,
 	else if (req->rq_export && req->rq_export->exp_connection)
 		nid = &req->rq_export->exp_connection->c_peer.nid;
 
+	if (req_ok) {
+		req_transno = lustre_msg_get_transno(req->rq_reqmsg);
+		req_opc = lustre_msg_get_opc(req->rq_reqmsg);
+		req_jobid = lustre_msg_get_jobid(req->rq_reqmsg);
+		lustre_msg_get_uid_gid(req->rq_reqmsg, &req_uid, &req_gid);
+		req_flags = lustre_msg_get_flags(req->rq_reqmsg);
+	}
+
 	va_start(args, fmt);
 	vaf.fmt = fmt;
 	vaf.va = &args;
 	libcfs_debug_msg(msgdata,
-			 "%pV req@%p x%llu/t%lld(%lld) o%d->%s@%s:%d/%d lens %d/%d e %d to %lld dl %lld ref %d fl " REQ_FLAGS_FMT "/%x/%x rc %d/%d job:'%s'\n",
+			 "%pV req@%p x%llu/t%lld(%llu) o%d->%s@%s:%d/%d lens %d/%d e %d to %lld dl %lld ref %d fl " REQ_FLAGS_FMT "/%x/%x rc %d/%d uid:%u gid:%u job:'%s'\n",
 			 &vaf,
-			 req, req->rq_xid, req->rq_transno,
-			 req_ok ? lustre_msg_get_transno(req->rq_reqmsg) : 0,
-			 req_ok ? lustre_msg_get_opc(req->rq_reqmsg) : -1,
+			 req, req->rq_xid, req->rq_transno, req_transno,
+			 req_opc,
 			 req->rq_import ?
 			 req->rq_import->imp_obd->obd_name :
 			 req->rq_export ?
@@ -2516,11 +2595,9 @@ void _debug_req(struct ptlrpc_request *req,
 			 req->rq_early_count, (s64)req->rq_timedout,
 			 (s64)req->rq_deadline,
 			 atomic_read(&req->rq_refcount),
-			 DEBUG_REQ_FLAGS(req),
-			 req_ok ? lustre_msg_get_flags(req->rq_reqmsg) : -1,
-			 rep_flags, req->rq_status, rep_status,
-			 req_ok ? lustre_msg_get_jobid(req->rq_reqmsg) ?: ""
-				: "");
+			 DEBUG_REQ_FLAGS(req), req_flags, rep_flags,
+			 req->rq_status, rep_status,
+			 req_uid, req_gid, req_jobid ?: "");
 	va_end(args);
 }
 EXPORT_SYMBOL(_debug_req);
diff --git a/fs/lustre/ptlrpc/ptlrpcd.c b/fs/lustre/ptlrpc/ptlrpcd.c
index 23fb52dc2b6b..7342db8e56a3 100644
--- a/fs/lustre/ptlrpc/ptlrpcd.c
+++ b/fs/lustre/ptlrpc/ptlrpcd.c
@@ -224,8 +224,10 @@ void ptlrpcd_add_req(struct ptlrpc_request *req)
 {
 	struct ptlrpcd_ctl *pc;
 
-	if (req->rq_reqmsg)
+	if (req->rq_reqmsg) {
 		lustre_msg_set_jobid(req->rq_reqmsg, NULL);
+		lustre_msg_set_uid_gid(req->rq_reqmsg, NULL, NULL);
+	}
 
 	spin_lock(&req->rq_lock);
 	if (req->rq_invalid_rqset) {
diff --git a/fs/lustre/ptlrpc/wiretest.c b/fs/lustre/ptlrpc/wiretest.c
index 6e893f0275bc..0da776dc6366 100644
--- a/fs/lustre/ptlrpc/wiretest.c
+++ b/fs/lustre/ptlrpc/wiretest.c
@@ -772,10 +772,14 @@ void lustre_assert_wire_constants(void)
 		 (long long)(int)offsetof(struct ptlrpc_body_v3, pb_padding64_1));
 	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding64_1) == 8, "found %lld\n",
 		 (long long)(int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding64_1));
-	LASSERTF((int)offsetof(struct ptlrpc_body_v3, pb_padding64_2) == 144, "found %lld\n",
-		 (long long)(int)offsetof(struct ptlrpc_body_v3, pb_padding64_2));
-	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding64_2) == 8, "found %lld\n",
-		 (long long)(int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding64_2));
+	LASSERTF((int)offsetof(struct ptlrpc_body_v3, pb_uid) == 144, "found %lld\n",
+		 (long long)(int)offsetof(struct ptlrpc_body_v3, pb_uid));
+	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_uid) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_uid));
+	LASSERTF((int)offsetof(struct ptlrpc_body_v3, pb_gid) == 148, "found %lld\n",
+		 (long long)(int)offsetof(struct ptlrpc_body_v3, pb_gid));
+	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_gid) == 4, "found %lld\n",
+		 (long long)(int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_gid));
 	BUILD_BUG_ON(LUSTRE_JOBID_SIZE != 32);
 	LASSERTF((int)offsetof(struct ptlrpc_body_v3, pb_jobid) == 152, "found %lld\n",
 		 (long long)(int)offsetof(struct ptlrpc_body_v3, pb_jobid));
@@ -869,10 +873,12 @@ void lustre_assert_wire_constants(void)
 		 (int)offsetof(struct ptlrpc_body_v3, pb_padding64_1), (int)offsetof(struct ptlrpc_body_v2, pb_padding64_1));
 	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding64_1) == (int)sizeof(((struct ptlrpc_body_v2 *)0)->pb_padding64_1), "%d != %d\n",
 		 (int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding64_1), (int)sizeof(((struct ptlrpc_body_v2 *)0)->pb_padding64_1));
-	LASSERTF((int)offsetof(struct ptlrpc_body_v3, pb_padding64_2) == (int)offsetof(struct ptlrpc_body_v2, pb_padding64_2), "%d != %d\n",
-		 (int)offsetof(struct ptlrpc_body_v3, pb_padding64_2), (int)offsetof(struct ptlrpc_body_v2, pb_padding64_2));
-	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding64_2) == (int)sizeof(((struct ptlrpc_body_v2 *)0)->pb_padding64_2), "%d != %d\n",
-		 (int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_padding64_2), (int)sizeof(((struct ptlrpc_body_v2 *)0)->pb_padding64_2));
+	LASSERTF((int)offsetof(struct ptlrpc_body_v3, pb_uid) == (int)offsetof(struct ptlrpc_body_v2, pb_padding64_2), "%d != %d\n",
+		 (int)offsetof(struct ptlrpc_body_v3, pb_uid), (int)offsetof(struct ptlrpc_body_v2, pb_padding64_2));
+	LASSERTF((int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_uid) + (int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_gid) ==
+		 (int)sizeof(((struct ptlrpc_body_v2 *)0)->pb_padding64_2), "%d != %d\n",
+		 (int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_uid) + (int)sizeof(((struct ptlrpc_body_v3 *)0)->pb_gid),
+		 (int)sizeof(((struct ptlrpc_body_v2 *)0)->pb_padding64_2));
 	LASSERTF(MSG_PTLRPC_BODY_OFF == 0, "found %lld\n",
 		 (long long)MSG_PTLRPC_BODY_OFF);
 	LASSERTF(REQ_REC_OFF == 1, "found %lld\n",
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index 83c8ea8f841a..a77a005f0ab1 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -593,6 +593,7 @@ enum lustre_msg_version {
 /* #define MSG_CONNECT_ASYNC	0x00000040 obsolete since 1.5 */
 #define MSG_CONNECT_NEXT_VER	0x00000080 /* use next version of lustre_msg */
 #define MSG_CONNECT_TRANSNO	0x00000100 /* client sent transno in replay */
+#define MSG_PACK_UID_GID	0x00000200 /* thread UID/GID in ptlrpc_body */
 
 /* number of previous object versions in pb_pre_versions[] */
 #define PTLRPC_NUM_VERSIONS	4
@@ -622,7 +623,8 @@ struct ptlrpc_body_v3 {
 	/* padding for future needs - fix lustre_swab_ptlrpc_body() also */
 	__u64 pb_padding64_0;
 	__u64 pb_padding64_1;
-	__u64 pb_padding64_2;
+	__u32 pb_uid;		/* req: process uid, use by tbf rules */
+	__u32 pb_gid;		/* req: process gid, use by tbf rules */
 	char  pb_jobid[LUSTRE_JOBID_SIZE]; /* req: ASCII jobid from env + NUL */
 };
 
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
