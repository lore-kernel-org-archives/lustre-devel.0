Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 7BF7DC433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:32:56 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 609A821FBDE;
	Sun, 20 Mar 2022 06:32:07 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 5088F21CA7D
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:11 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 0692DED8;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id E7140FCF2B; Sun, 20 Mar 2022 09:31:07 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:19 -0400
Message-Id: <1647783064-20688-6-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 05/50] lnet: use large nids in struct
 lnet_event
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

All nids, including those in process_id, are changed to
to struct lnet_nid / struct lnet_processid.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: e1d0224fb4045571a ("LU-10391 lnet: use large nids in struct lnet_event")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/43600
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_net.h       |  6 +++---
 fs/lustre/include/obd_class.h        |  4 ++--
 fs/lustre/ldlm/ldlm_lib.c            |  6 +++---
 fs/lustre/ldlm/ldlm_request.c        |  2 +-
 fs/lustre/obdclass/lprocfs_status.c  |  8 ++++----
 fs/lustre/osc/osc_request.c          | 14 ++++++-------
 fs/lustre/ptlrpc/client.c            |  6 +++---
 fs/lustre/ptlrpc/connection.c        | 20 +++++++++---------
 fs/lustre/ptlrpc/events.c            | 10 ++++-----
 fs/lustre/ptlrpc/import.c            |  6 +++---
 fs/lustre/ptlrpc/niobuf.c            | 10 ++++-----
 fs/lustre/ptlrpc/pack_generic.c      |  8 ++++----
 fs/lustre/ptlrpc/ptlrpc_internal.h   |  2 +-
 fs/lustre/ptlrpc/sec.c               |  4 ++--
 fs/lustre/ptlrpc/sec_config.c        |  9 +++++----
 fs/lustre/ptlrpc/service.c           |  2 +-
 include/linux/lnet/api.h             |  2 +-
 include/linux/lnet/lib-lnet.h        |  3 ++-
 include/uapi/linux/lnet/lnet-types.h |  8 ++++----
 net/lnet/lnet/api-ni.c               |  8 ++++----
 net/lnet/lnet/lib-msg.c              | 24 +++++++++++-----------
 net/lnet/lnet/peer.c                 | 39 +++++++++++++++++++++++++++---------
 net/lnet/selftest/rpc.c              |  6 +++---
 23 files changed, 114 insertions(+), 93 deletions(-)

diff --git a/fs/lustre/include/lustre_net.h b/fs/lustre/include/lustre_net.h
index cf1bb7f..7d29542 100644
--- a/fs/lustre/include/lustre_net.h
+++ b/fs/lustre/include/lustre_net.h
@@ -364,9 +364,9 @@ struct ptlrpc_connection {
 	/** linkage for connections hash table */
 	struct rhash_head	c_hash;
 	/** Our own lnet nid for this connection */
-	lnet_nid_t		c_self;
+	struct lnet_nid		c_self;
 	/** Remote side nid for this connection */
-	struct lnet_process_id	c_peer;
+	struct lnet_processid	c_peer;
 	/** UUID of the other side */
 	struct obd_uuid		c_remote_uuid;
 	/** reference counter for this connection */
@@ -1749,7 +1749,7 @@ static inline void  ptlrpc_connection_put(struct ptlrpc_connection *conn)
 
 	CDEBUG(D_INFO, "PUT conn=%p refcount %d to %s\n",
 	       conn, atomic_read(&conn->c_refcount),
-	       libcfs_nid2str(conn->c_peer.nid));
+	       libcfs_nidstr(&conn->c_peer.nid));
 }
 
 struct ptlrpc_connection *ptlrpc_connection_addref(struct ptlrpc_connection *);
diff --git a/fs/lustre/include/obd_class.h b/fs/lustre/include/obd_class.h
index b69331d..3f444b0 100644
--- a/fs/lustre/include/obd_class.h
+++ b/fs/lustre/include/obd_class.h
@@ -98,13 +98,13 @@ int obd_connect_flags2str(char *page, int count, u64 flags, u64 flags2,
 static inline char *obd_export_nid2str(struct obd_export *exp)
 {
 	return exp->exp_connection ?
-		libcfs_nid2str(exp->exp_connection->c_peer.nid) : "<unknown>";
+		libcfs_nidstr(&exp->exp_connection->c_peer.nid) : "<unknown>";
 }
 
 static inline char *obd_import_nid2str(struct obd_import *imp)
 {
 	return imp->imp_connection ?
-		libcfs_nid2str(imp->imp_connection->c_peer.nid) : "<unknown>";
+		libcfs_nidstr(&imp->imp_connection->c_peer.nid) : "<unknown>";
 }
 
 int obd_zombie_impexp_init(void);
diff --git a/fs/lustre/ldlm/ldlm_lib.c b/fs/lustre/ldlm/ldlm_lib.c
index 9aa87d1..02d1eea 100644
--- a/fs/lustre/ldlm/ldlm_lib.c
+++ b/fs/lustre/ldlm/ldlm_lib.c
@@ -67,7 +67,7 @@ static int import_set_conn(struct obd_import *imp, struct obd_uuid *uuid,
 	if (imp->imp_connection &&
 	    imp->imp_connection->c_remote_uuid.uuid[0] == 0)
 		/* nid4refnet is used to restrict network connections */
-		nid4refnet = imp->imp_connection->c_self;
+		nid4refnet = lnet_nid_to_nid4(&imp->imp_connection->c_self);
 
 	ptlrpc_conn = ptlrpc_uuid_to_connection(uuid, nid4refnet);
 	if (!ptlrpc_conn) {
@@ -297,7 +297,7 @@ int client_obd_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	const char *name = obd->obd_type->typ_name;
 	enum ldlm_ns_type ns_type = LDLM_NS_TYPE_UNKNOWN;
 	struct ptlrpc_connection fake_conn = {
-		.c_self = 0,
+		.c_self = {},
 		.c_remote_uuid.uuid[0] = 0
 	};
 	int rc;
@@ -494,7 +494,7 @@ int client_obd_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 			       rc);
 			goto err_import;
 		}
-		fake_conn.c_self = LNET_MKNID(refnet, 0);
+		lnet_nid4_to_nid(LNET_MKNID(refnet, 0), &fake_conn.c_self);
 		imp->imp_connection = &fake_conn;
 	}
 
diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 44e1ec2..4ba64b1 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -1099,7 +1099,7 @@ static int ldlm_cli_cancel_req(struct obd_export *exp,
 		if (rc == LUSTRE_ESTALE) {
 			CDEBUG(D_DLMTRACE,
 			       "client/server (nid %s) out of sync -- not fatal\n",
-			       libcfs_nid2str(req->rq_import->imp_connection->c_peer.nid));
+			       libcfs_nidstr(&req->rq_import->imp_connection->c_peer.nid));
 			rc = 0;
 		} else if (rc == -ETIMEDOUT && /* check there was no reconnect*/
 			   req->rq_import_generation == imp->imp_generation) {
diff --git a/fs/lustre/obdclass/lprocfs_status.c b/fs/lustre/obdclass/lprocfs_status.c
index 335fc34..335e748 100644
--- a/fs/lustre/obdclass/lprocfs_status.c
+++ b/fs/lustre/obdclass/lprocfs_status.c
@@ -854,14 +854,14 @@ static void ldebugfs_import_locked(struct seq_file *m,
 	spin_lock(&imp->imp_lock);
 	j = 0;
 	list_for_each_entry(conn, &imp->imp_conn_list, oic_item) {
-		libcfs_nid2str_r(conn->oic_conn->c_peer.nid,
-				 nidstr, sizeof(nidstr));
+		libcfs_nidstr_r(&conn->oic_conn->c_peer.nid,
+				  nidstr, sizeof(nidstr));
 		seq_printf(m, "%s%s", j ? ", " : "", nidstr);
 		j++;
 	}
 	if (imp->imp_connection)
-		libcfs_nid2str_r(imp->imp_connection->c_peer.nid,
-				 nidstr, sizeof(nidstr));
+		libcfs_nidstr_r(&imp->imp_connection->c_peer.nid,
+				  nidstr, sizeof(nidstr));
 	else
 		strncpy(nidstr, "<none>", sizeof(nidstr));
 	seq_printf(m,
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 14863dc..c442819 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1899,7 +1899,7 @@ static void dump_all_bulk_pages(struct obdo *oa, u32 page_count,
 }
 
 static int check_write_checksum(struct obdo *oa,
-				const struct lnet_process_id *peer,
+				const struct lnet_processid *peer,
 				u32 client_cksum, u32 server_cksum,
 				struct osc_brw_async_args *aa)
 {
@@ -1967,7 +1967,7 @@ static int check_write_checksum(struct obdo *oa,
 
 	LCONSOLE_ERROR_MSG(0x132,
 			   "%s: BAD WRITE CHECKSUM: %s: from %s inode " DFID " object " DOSTID " extent [%llu-%llu], original client csum %x (type %x), server csum %x (type %x), client csum now %x\n",
-			   obd_name, msg, libcfs_nid2str(peer->nid),
+			   obd_name, msg, libcfs_nidstr(&peer->nid),
 			   oa->o_valid & OBD_MD_FLFID ? oa->o_parent_seq : (u64)0,
 			   oa->o_valid & OBD_MD_FLFID ? oa->o_parent_oid : 0,
 			   oa->o_valid & OBD_MD_FLFID ? oa->o_parent_ver : 0,
@@ -1985,8 +1985,8 @@ static int check_write_checksum(struct obdo *oa,
 static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 {
 	struct osc_brw_async_args *aa = (void *)&req->rq_async_args;
-	const struct lnet_process_id *peer =
-			&req->rq_import->imp_connection->c_peer;
+	const struct lnet_processid *peer =
+		&req->rq_import->imp_connection->c_peer;
 	struct client_obd *cli = aa->aa_cli;
 	const char *obd_name = cli->cl_import->imp_obd->obd_name;
 	struct ost_body *body;
@@ -2129,7 +2129,7 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 			goto out;
 
 		if (req->rq_bulk &&
-		    peer->nid != req->rq_bulk->bd_sender) {
+		    lnet_nid_to_nid4(&peer->nid) != req->rq_bulk->bd_sender) {
 			via = " via ";
 			router = libcfs_nid2str(req->rq_bulk->bd_sender);
 		}
@@ -2152,7 +2152,7 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 			LCONSOLE_ERROR_MSG(0x133,
 					   "%s: BAD READ CHECKSUM: from %s%s%s inode "DFID" object "DOSTID" extent [%llu-%llu], client %x/%x, server %x, cksum_type %x\n",
 					   obd_name,
-					   libcfs_nid2str(peer->nid),
+					   libcfs_nidstr(&peer->nid),
 					   via, router,
 					   clbody->oa.o_valid & OBD_MD_FLFID ?
 					   clbody->oa.o_parent_seq : (u64)0,
@@ -2181,7 +2181,7 @@ static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 		if ((cksum_missed & (-cksum_missed)) == cksum_missed)
 			CERROR("%s: checksum %u requested from %s but not sent\n",
 			       obd_name, cksum_missed,
-			       libcfs_nid2str(peer->nid));
+			       libcfs_nidstr(&peer->nid));
 	} else {
 		rc = 0;
 	}
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index dedb5db..ec0cd5f 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -1303,7 +1303,7 @@ static int ptlrpc_check_status(struct ptlrpc_request *req)
 	rc = lustre_msg_get_status(req->rq_repmsg);
 	if (lustre_msg_get_type(req->rq_repmsg) == PTL_RPC_MSG_ERR) {
 		struct obd_import *imp = req->rq_import;
-		lnet_nid_t nid = imp->imp_connection->c_peer.nid;
+		struct lnet_nid *nid = &imp->imp_connection->c_peer.nid;
 		u32 opc = lustre_msg_get_opc(req->rq_reqmsg);
 
 		/* -EAGAIN is normal when using POSIX flocks */
@@ -1313,7 +1313,7 @@ static int ptlrpc_check_status(struct ptlrpc_request *req)
 					   "%s: operation %s to node %s failed: rc = %d\n",
 					   imp->imp_obd->obd_name,
 					   ll_opcode2str(opc),
-					   libcfs_nid2str(nid), rc);
+					   libcfs_nidstr(nid), rc);
 		return rc < 0 ? rc : -EINVAL;
 	}
 
@@ -2199,7 +2199,7 @@ int ptlrpc_expire_one_request(struct ptlrpc_request *req, int async_unlink)
 		  req->rq_sent, req->rq_real_sent);
 
 	if (imp && obd_debug_peer_on_timeout)
-		LNetDebugPeer(imp->imp_connection->c_peer);
+		LNetDebugPeer(&imp->imp_connection->c_peer);
 
 	ptlrpc_unregister_reply(req, async_unlink);
 	ptlrpc_unregister_bulk(req, async_unlink);
diff --git a/fs/lustre/ptlrpc/connection.c b/fs/lustre/ptlrpc/connection.c
index 0415357..8dbaea40 100644
--- a/fs/lustre/ptlrpc/connection.c
+++ b/fs/lustre/ptlrpc/connection.c
@@ -48,20 +48,20 @@
 
 static u32 lnet_process_id_hash(const void *data, u32 len, u32 seed)
 {
-	const struct lnet_process_id *lpi = data;
+	const struct lnet_processid *lpi = data;
 
 	seed = hash_32(seed ^ lpi->pid, 32);
-	seed ^= hash_64(lpi->nid, 32);
+	seed = hash_32(nidhash(&lpi->nid) ^ seed, 32);
 	return seed;
 }
 
 static int lnet_process_id_cmp(struct rhashtable_compare_arg *arg,
 			       const void *obj)
 {
-	const struct lnet_process_id *lpi = arg->key;
+	const struct lnet_processid *lpi = arg->key;
 	const struct ptlrpc_connection *con = obj;
 
-	if (lpi->nid == con->c_peer.nid &&
+	if (nid_same(&lpi->nid, &con->c_peer.nid) &&
 	    lpi->pid == con->c_peer.pid)
 		return 0;
 	return -ESRCH;
@@ -76,12 +76,14 @@ static int lnet_process_id_cmp(struct rhashtable_compare_arg *arg,
 };
 
 struct ptlrpc_connection *
-ptlrpc_connection_get(struct lnet_process_id peer, lnet_nid_t self,
+ptlrpc_connection_get(struct lnet_process_id peer4, lnet_nid_t self,
 		      struct obd_uuid *uuid)
 {
 	struct ptlrpc_connection *conn, *conn2;
+	struct lnet_processid peer;
 
-	peer.nid = LNetPrimaryNID(peer.nid);
+	peer4.nid = LNetPrimaryNID(peer4.nid);
+	lnet_pid4_to_pid(peer4, &peer);
 	conn = rhashtable_lookup_fast(&conn_hash, &peer, conn_hash_params);
 	if (conn) {
 		ptlrpc_connection_addref(conn);
@@ -93,7 +95,7 @@ struct ptlrpc_connection *
 		return NULL;
 
 	conn->c_peer = peer;
-	conn->c_self = self;
+	lnet_nid4_to_nid(self, &conn->c_self);
 	atomic_set(&conn->c_refcount, 1);
 	if (uuid)
 		obd_str2uuid(&conn->c_remote_uuid, uuid->uuid);
@@ -125,7 +127,7 @@ struct ptlrpc_connection *
 out:
 	CDEBUG(D_INFO, "conn=%p refcount %d to %s\n",
 	       conn, atomic_read(&conn->c_refcount),
-	       libcfs_nid2str(conn->c_peer.nid));
+	       libcfs_nidstr(&conn->c_peer.nid));
 	return conn;
 }
 
@@ -135,7 +137,7 @@ struct ptlrpc_connection *
 	atomic_inc(&conn->c_refcount);
 	CDEBUG(D_INFO, "conn=%p refcount %d to %s\n",
 	       conn, atomic_read(&conn->c_refcount),
-	       libcfs_nid2str(conn->c_peer.nid));
+	       libcfs_nidstr(&conn->c_peer.nid));
 
 	return conn;
 }
diff --git a/fs/lustre/ptlrpc/events.c b/fs/lustre/ptlrpc/events.c
index dbf9f9d..385a6f2 100644
--- a/fs/lustre/ptlrpc/events.c
+++ b/fs/lustre/ptlrpc/events.c
@@ -213,7 +213,7 @@ void client_bulk_callback(struct lnet_event *ev)
 
 	if (ev->type != LNET_EVENT_UNLINK && ev->status == 0) {
 		desc->bd_nob_transferred += ev->mlength;
-		desc->bd_sender = ev->sender;
+		desc->bd_sender = lnet_nid_to_nid4(&ev->sender);
 	} else {
 		/* start reconnect and resend if network error hit */
 		spin_lock(&req->rq_lock);
@@ -330,7 +330,7 @@ void request_in_callback(struct lnet_event *ev)
 		if (!req) {
 			CERROR("Can't allocate incoming request descriptor: Dropping %s RPC from %s\n",
 			       service->srv_name,
-			       libcfs_id2str(ev->initiator));
+			       libcfs_idstr(&ev->initiator));
 			return;
 		}
 	}
@@ -346,9 +346,9 @@ void request_in_callback(struct lnet_event *ev)
 		req->rq_reqdata_len = ev->mlength;
 	ktime_get_real_ts64(&req->rq_arrival_time);
 	/* Multi-Rail: keep track of both initiator and source NID. */
-	req->rq_peer = ev->initiator;
-	req->rq_source = ev->source;
-	req->rq_self = ev->target.nid;
+	req->rq_peer = lnet_pid_to_pid4(&ev->initiator);
+	req->rq_source = lnet_pid_to_pid4(&ev->source);
+	req->rq_self = lnet_nid_to_nid4(&ev->target.nid);
 	req->rq_rqbd = rqbd;
 	req->rq_phase = RQ_PHASE_NEW;
 	if (ev->type == LNET_EVENT_PUT)
diff --git a/fs/lustre/ptlrpc/import.c b/fs/lustre/ptlrpc/import.c
index f28fb68..3dc987cf 100644
--- a/fs/lustre/ptlrpc/import.c
+++ b/fs/lustre/ptlrpc/import.c
@@ -516,7 +516,7 @@ static int import_select_connection(struct obd_import *imp)
 	list_for_each_entry(conn, &imp->imp_conn_list, oic_item) {
 		CDEBUG(D_HA, "%s: connect to NID %s last attempt %lld\n",
 		       imp->imp_obd->obd_name,
-		       libcfs_nid2str(conn->oic_conn->c_peer.nid),
+		       libcfs_nidstr(&conn->oic_conn->c_peer.nid),
 		       conn->oic_last_attempt);
 
 		/* If we have not tried this connection since
@@ -591,7 +591,7 @@ static int import_select_connection(struct obd_import *imp)
 			       "%s: Connection changing to %.*s (at %s)\n",
 			       imp->imp_obd->obd_name,
 			       target_len, target_start,
-			       libcfs_nid2str(imp_conn->oic_conn->c_peer.nid));
+			       libcfs_nidstr(&imp_conn->oic_conn->c_peer.nid));
 		}
 
 		imp->imp_conn_current = imp_conn;
@@ -600,7 +600,7 @@ static int import_select_connection(struct obd_import *imp)
 	/* The below message is checked in conf-sanity.sh test_35[ab] */
 	CDEBUG(D_HA, "%s: import %p using connection %s/%s\n",
 	       imp->imp_obd->obd_name, imp, imp_conn->oic_uuid.uuid,
-	       libcfs_nid2str(imp_conn->oic_conn->c_peer.nid));
+	       libcfs_nidstr(&imp_conn->oic_conn->c_peer.nid));
 
 out_unlock:
 	spin_unlock(&imp->imp_lock);
diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index da04d4e..afe83ad 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -150,9 +150,7 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 
 	desc->bd_failure = 0;
 
-	peer.pid = desc->bd_import->imp_connection->c_peer.pid;
-	lnet_nid4_to_nid(desc->bd_import->imp_connection->c_peer.nid,
-		      &peer.nid);
+	peer = desc->bd_import->imp_connection->c_peer;
 
 	LASSERT(desc->bd_cbid.cbid_fn == client_bulk_callback);
 	LASSERT(desc->bd_cbid.cbid_arg == desc);
@@ -630,8 +628,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 			request->rq_repmsg = NULL;
 		}
 
-		peer.pid = connection->c_peer.pid;
-		lnet_nid4_to_nid(connection->c_peer.nid, &peer.nid);
+		peer = connection->c_peer;
 		if (request->rq_bulk &&
 		    OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_BULK_REPLY_ATTACH)) {
 			reply_me = ERR_PTR(-ENOMEM);
@@ -723,7 +720,8 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	rc = ptl_send_buf(&request->rq_req_md_h,
 			  request->rq_reqbuf, request->rq_reqdata_len,
 			  LNET_NOACK_REQ, &request->rq_req_cbid,
-			  LNET_NID_ANY, connection->c_peer,
+			  LNET_NID_ANY,
+			  lnet_pid_to_pid4(&connection->c_peer),
 			  request->rq_request_portal,
 			  request->rq_xid, 0, &bulk_cookie);
 	if (likely(rc == 0))
diff --git a/fs/lustre/ptlrpc/pack_generic.c b/fs/lustre/ptlrpc/pack_generic.c
index e06c421..f075188e 100644
--- a/fs/lustre/ptlrpc/pack_generic.c
+++ b/fs/lustre/ptlrpc/pack_generic.c
@@ -2460,7 +2460,7 @@ void _debug_req(struct ptlrpc_request *req,
 {
 	bool req_ok = req->rq_reqmsg != NULL;
 	bool rep_ok = false;
-	lnet_nid_t nid = LNET_NID_ANY;
+	struct lnet_nid *nid = NULL;
 	int rep_flags = -1;
 	int rep_status = -1;
 	va_list args;
@@ -2482,9 +2482,9 @@ void _debug_req(struct ptlrpc_request *req,
 	spin_unlock(&req->rq_early_free_lock);
 
 	if (req->rq_import && req->rq_import->imp_connection)
-		nid = req->rq_import->imp_connection->c_peer.nid;
+		nid = &req->rq_import->imp_connection->c_peer.nid;
 	else if (req->rq_export && req->rq_export->exp_connection)
-		nid = req->rq_export->exp_connection->c_peer.nid;
+		nid = &req->rq_export->exp_connection->c_peer.nid;
 
 	va_start(args, fmt);
 	vaf.fmt = fmt;
@@ -2500,7 +2500,7 @@ void _debug_req(struct ptlrpc_request *req,
 			 req->rq_export ?
 			 req->rq_export->exp_client_uuid.uuid :
 			 "<?>",
-			 libcfs_nid2str(nid),
+			 nid ? libcfs_nidstr(nid) : "<unknown>",
 			 req->rq_request_portal, req->rq_reply_portal,
 			 req->rq_reqlen, req->rq_replen,
 			 req->rq_early_count, (s64)req->rq_timedout,
diff --git a/fs/lustre/ptlrpc/ptlrpc_internal.h b/fs/lustre/ptlrpc/ptlrpc_internal.h
index d902cfe..9eddb3b 100644
--- a/fs/lustre/ptlrpc/ptlrpc_internal.h
+++ b/fs/lustre/ptlrpc/ptlrpc_internal.h
@@ -278,7 +278,7 @@ struct ptlrpc_reply_state *
 void sptlrpc_conf_choose_flavor(enum lustre_sec_part from,
 				enum lustre_sec_part to,
 				struct obd_uuid *target,
-				lnet_nid_t nid,
+				struct lnet_nid *nid,
 				struct sptlrpc_flavor *sf);
 int sptlrpc_conf_init(void);
 void sptlrpc_conf_fini(void);
diff --git a/fs/lustre/ptlrpc/sec.c b/fs/lustre/ptlrpc/sec.c
index 7e6b681..f2d0340 100644
--- a/fs/lustre/ptlrpc/sec.c
+++ b/fs/lustre/ptlrpc/sec.c
@@ -1396,7 +1396,7 @@ int sptlrpc_import_sec_adapt(struct obd_import *imp,
 			sptlrpc_conf_choose_flavor(cliobd->cl_sp_me,
 						   cliobd->cl_sp_to,
 						   &cliobd->cl_target_uuid,
-						   conn->c_self, &sf);
+						   &conn->c_self, &sf);
 
 		sp = imp->imp_obd->u.cli.cl_sp_me;
 	} else {
@@ -1435,7 +1435,7 @@ int sptlrpc_import_sec_adapt(struct obd_import *imp,
 		CDEBUG(D_SEC, "import %s->%s netid %x: select flavor %s\n",
 		       imp->imp_obd->obd_name,
 		       obd_uuid2str(&conn->c_remote_uuid),
-		       LNET_NIDNET(conn->c_self),
+		       LNET_NID_NET(&conn->c_self),
 		       sptlrpc_flavor2name(&sf, str, sizeof(str)));
 	}
 
diff --git a/fs/lustre/ptlrpc/sec_config.c b/fs/lustre/ptlrpc/sec_config.c
index d44af0f..e0ddebd 100644
--- a/fs/lustre/ptlrpc/sec_config.c
+++ b/fs/lustre/ptlrpc/sec_config.c
@@ -786,7 +786,7 @@ static inline void flavor_set_flags(struct sptlrpc_flavor *sf,
 void sptlrpc_conf_choose_flavor(enum lustre_sec_part from,
 				enum lustre_sec_part to,
 				struct obd_uuid *target,
-				lnet_nid_t nid,
+				struct lnet_nid *nid,
 				struct sptlrpc_flavor *sf)
 {
 	struct sptlrpc_conf *conf;
@@ -810,13 +810,14 @@ void sptlrpc_conf_choose_flavor(enum lustre_sec_part from,
 
 	conf_tgt = sptlrpc_conf_get_tgt(conf, name, 0);
 	if (conf_tgt) {
-		rc = sptlrpc_rule_set_choose(&conf_tgt->sct_rset,
-					     from, to, nid, sf);
+		rc = sptlrpc_rule_set_choose(&conf_tgt->sct_rset, from, to,
+					     lnet_nid_to_nid4(nid), sf);
 		if (rc)
 			goto out;
 	}
 
-	rc = sptlrpc_rule_set_choose(&conf->sc_rset, from, to, nid, sf);
+	rc = sptlrpc_rule_set_choose(&conf->sc_rset, from, to,
+				     lnet_nid_to_nid4(nid), sf);
 out:
 	mutex_unlock(&sptlrpc_conf_lock);
 
diff --git a/fs/lustre/ptlrpc/service.c b/fs/lustre/ptlrpc/service.c
index dbe2347..7db6f52 100644
--- a/fs/lustre/ptlrpc/service.c
+++ b/fs/lustre/ptlrpc/service.c
@@ -1937,7 +1937,7 @@ static int ptlrpc_handle_rs(struct ptlrpc_reply_state *rs)
 		CDEBUG(D_HA,
 		       "All locks stolen from rs %p x%lld.t%lld o%d NID %s\n",
 		       rs, rs->rs_xid, rs->rs_transno, rs->rs_opc,
-		       libcfs_nid2str(exp->exp_connection->c_peer.nid));
+		       libcfs_nidstr(&exp->exp_connection->c_peer.nid));
 	}
 
 	if ((rs->rs_sent && !rs->rs_unlinked) || nlocks > 0) {
diff --git a/include/linux/lnet/api.h b/include/linux/lnet/api.h
index 040bf18..ee0a9a6 100644
--- a/include/linux/lnet/api.h
+++ b/include/linux/lnet/api.h
@@ -162,7 +162,7 @@ int LNetGet(lnet_nid_t self,
 int LNetSetLazyPortal(int portal);
 int LNetClearLazyPortal(int portal);
 int LNetCtl(unsigned int cmd, void *arg);
-void LNetDebugPeer(struct lnet_process_id id);
+void LNetDebugPeer(struct lnet_processid *id);
 int LNetGetPeerDiscoveryStatus(void);
 int LNetAddPeer(lnet_nid_t *nids, u32 num_nids);
 
diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 8b4a29b..9441265 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -852,7 +852,8 @@ struct lnet_peer_ni *lnet_peer_ni_get_locked(struct lnet_peer *lp,
 					     struct lnet_nid *nid);
 struct lnet_peer_ni *lnet_find_peer_ni_locked(lnet_nid_t nid);
 struct lnet_peer_ni *lnet_peer_ni_find_locked(struct lnet_nid *nid);
-struct lnet_peer *lnet_find_peer(lnet_nid_t nid);
+struct lnet_peer *lnet_find_peer4(lnet_nid_t nid);
+struct lnet_peer *lnet_find_peer(struct lnet_nid *nid);
 void lnet_peer_net_added(struct lnet_net *net);
 void lnet_peer_primary_nid_locked(lnet_nid_t nid, struct lnet_nid *result);
 int lnet_discover_peer_locked(struct lnet_peer_ni *lpni, int cpt, bool block);
diff --git a/include/uapi/linux/lnet/lnet-types.h b/include/uapi/linux/lnet/lnet-types.h
index ec0c4ef..4818271 100644
--- a/include/uapi/linux/lnet/lnet-types.h
+++ b/include/uapi/linux/lnet/lnet-types.h
@@ -518,17 +518,17 @@ enum lnet_event_kind {
  */
 struct lnet_event {
 	/** The identifier (nid, pid) of the target. */
-	struct lnet_process_id	target;
+	struct lnet_processid	target;
 	/** The identifier (nid, pid) of the initiator. */
-	struct lnet_process_id	initiator;
+	struct lnet_processid	initiator;
 	/** The source NID on the initiator. */
-	struct lnet_process_id	source;
+	struct lnet_processid	source;
 	/**
 	 * The NID of the immediate sender. If the request has been forwarded
 	 * by routers, this is the NID of the last hop; otherwise it's the
 	 * same as the source.
 	 */
-	lnet_nid_t		sender;
+	struct lnet_nid		sender;
 	/** Indicates the type of the event. */
 	enum lnet_event_kind	type;
 	/** The portal table index specified in the request */
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 550f035..d61c03a 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -4310,7 +4310,7 @@ u32 lnet_get_dlc_seq_locked(void)
 			return rc;
 
 		mutex_lock(&the_lnet.ln_api_mutex);
-		lp = lnet_find_peer(ping->ping_id.nid);
+		lp = lnet_find_peer4(ping->ping_id.nid);
 		if (lp) {
 			ping->ping_id.nid =
 				lnet_nid_to_nid4(&lp->lp_primary_nid);
@@ -4334,7 +4334,7 @@ u32 lnet_get_dlc_seq_locked(void)
 			return rc;
 
 		mutex_lock(&the_lnet.ln_api_mutex);
-		lp = lnet_find_peer(discover->ping_id.nid);
+		lp = lnet_find_peer4(discover->ping_id.nid);
 		if (lp) {
 			discover->ping_id.nid =
 				lnet_nid_to_nid4(&lp->lp_primary_nid);
@@ -4464,9 +4464,9 @@ u32 lnet_get_dlc_seq_locked(void)
 }
 EXPORT_SYMBOL(LNetCtl);
 
-void LNetDebugPeer(struct lnet_process_id id)
+void LNetDebugPeer(struct lnet_processid *id)
 {
-	lnet_debug_peer(id.nid);
+	lnet_debug_peer(lnet_nid_to_nid4(&id->nid));
 }
 EXPORT_SYMBOL(LNetDebugPeer);
 
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index f432488..4102c7b 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -66,25 +66,25 @@
 
 	if (ev_type == LNET_EVENT_SEND) {
 		/* event for active message */
-		ev->target.nid = le64_to_cpu(hdr->dest_nid);
+		lnet_nid4_to_nid(le64_to_cpu(hdr->dest_nid), &ev->target.nid);
 		ev->target.pid = le32_to_cpu(hdr->dest_pid);
-		ev->initiator.nid = LNET_NID_ANY;
+		ev->initiator.nid = LNET_ANY_NID;
 		ev->initiator.pid = the_lnet.ln_pid;
-		ev->source.nid = LNET_NID_ANY;
+		ev->source.nid = LNET_ANY_NID;
 		ev->source.pid = the_lnet.ln_pid;
-		ev->sender = LNET_NID_ANY;
+		ev->sender = LNET_ANY_NID;
 	} else {
 		/* event for passive message */
 		ev->target.pid = hdr->dest_pid;
-		ev->target.nid = hdr->dest_nid;
+		lnet_nid4_to_nid(hdr->dest_nid, &ev->target.nid);
 		ev->initiator.pid = hdr->src_pid;
 		/* Multi-Rail: resolve src_nid to "primary" peer NID */
-		ev->initiator.nid = lnet_nid_to_nid4(&msg->msg_initiator);
+		ev->initiator.nid = msg->msg_initiator;
 		/* Multi-Rail: track source NID. */
 		ev->source.pid = hdr->src_pid;
-		ev->source.nid = hdr->src_nid;
+		lnet_nid4_to_nid(hdr->src_nid, &ev->source.nid);
 		ev->rlength = hdr->payload_length;
-		ev->sender = lnet_nid_to_nid4(&msg->msg_from);
+		ev->sender = msg->msg_from;
 		ev->mlength = msg->msg_wanted;
 		ev->offset = msg->msg_offset;
 	}
@@ -379,7 +379,6 @@
 
 	if (!status && msg->msg_ack) {
 		/* Only send an ACK if the PUT completed successfully */
-		struct lnet_nid src;
 
 		lnet_msg_decommit(msg, cpt, 0);
 
@@ -391,14 +390,15 @@
 
 		ack_wmd = msg->msg_hdr.msg.put.ack_wmd;
 
-		lnet_prep_send(msg, LNET_MSG_ACK, msg->msg_ev.source, 0, 0);
+		lnet_prep_send(msg, LNET_MSG_ACK,
+			       lnet_pid_to_pid4(&msg->msg_ev.source), 0, 0);
 
 		msg->msg_hdr.msg.ack.dst_wmd = ack_wmd;
 		msg->msg_hdr.msg.ack.match_bits = msg->msg_ev.match_bits;
 		msg->msg_hdr.msg.ack.mlength = cpu_to_le32(msg->msg_ev.mlength);
 
-		lnet_nid4_to_nid(msg->msg_ev.target.nid, &src);
-		rc = lnet_send(&src, msg, &msg->msg_from);
+		rc = lnet_send(&msg->msg_ev.target.nid, msg,
+			       &msg->msg_from);
 
 		lnet_net_lock(cpt);
 		/*
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 505065f..d0b7bc8 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -768,7 +768,7 @@ struct lnet_peer_ni *
 }
 
 struct lnet_peer *
-lnet_find_peer(lnet_nid_t nid)
+lnet_find_peer4(lnet_nid_t nid)
 {
 	struct lnet_peer_ni *lpni;
 	struct lnet_peer *lp = NULL;
@@ -786,6 +786,25 @@ struct lnet_peer *
 	return lp;
 }
 
+struct lnet_peer *
+lnet_find_peer(struct lnet_nid *nid)
+{
+	struct lnet_peer_ni *lpni;
+	struct lnet_peer *lp = NULL;
+	int cpt;
+
+	cpt = lnet_net_lock_current();
+	lpni = lnet_peer_ni_find_locked(nid);
+	if (lpni) {
+		lp = lpni->lpni_peer_net->lpn_peer;
+		lnet_peer_addref_locked(lp);
+		lnet_peer_ni_decref_locked(lpni);
+	}
+	lnet_net_unlock(cpt);
+
+	return lp;
+}
+
 struct lnet_peer_net *
 lnet_get_next_peer_net_locked(struct lnet_peer *lp, u32 prev_lpn_id)
 {
@@ -2321,12 +2340,12 @@ void lnet_peer_push_event(struct lnet_event *ev)
 	pbuf = LNET_PING_INFO_TO_BUFFER(ev->md_start + ev->offset);
 
 	/* lnet_find_peer() adds a refcount */
-	lp = lnet_find_peer(ev->source.nid);
+	lp = lnet_find_peer(&ev->source.nid);
 	if (!lp) {
 		CDEBUG(D_NET,
 		       "Push Put from unknown %s (source %s). Ignoring...\n",
-		       libcfs_nid2str(ev->initiator.nid),
-		       libcfs_nid2str(ev->source.nid));
+		       libcfs_nidstr(&ev->initiator.nid),
+		       libcfs_nidstr(&ev->source.nid));
 		pbuf->pb_needs_post = true;
 		return;
 	}
@@ -2345,7 +2364,7 @@ void lnet_peer_push_event(struct lnet_event *ev)
 		CDEBUG(D_NET, "Push Put error %d from %s (source %s)\n",
 		       ev->status,
 		       libcfs_nidstr(&lp->lp_primary_nid),
-		       libcfs_nid2str(ev->source.nid));
+		       libcfs_nidstr(&ev->source.nid));
 		goto out;
 	}
 
@@ -2643,8 +2662,8 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 
 	spin_lock(&lp->lp_lock);
 
-	lnet_nid4_to_nid(ev->target.nid, &lp->lp_disc_src_nid);
-	lnet_nid4_to_nid(ev->source.nid, &lp->lp_disc_dst_nid);
+	lp->lp_disc_src_nid = ev->target.nid;
+	lp->lp_disc_dst_nid = ev->source.nid;
 
 	/*
 	 * If some kind of error happened the contents of message
@@ -2656,7 +2675,7 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 		CDEBUG(D_NET, "Ping Reply error %d from %s (source %s)\n",
 		       ev->status,
 		       libcfs_nidstr(&lp->lp_primary_nid),
-		       libcfs_nid2str(ev->source.nid));
+		       libcfs_nidstr(&ev->source.nid));
 		goto out;
 	}
 
@@ -2843,7 +2862,7 @@ static void lnet_peer_clear_discovery_error(struct lnet_peer *lp)
 out:
 	CDEBUG(D_NET, "%s Send to %s: %d\n",
 	       (ev->msg_type == LNET_MSG_GET ? "Ping" : "Push"),
-	       libcfs_nid2str(ev->target.nid), rc);
+	       libcfs_nidstr(&ev->target.nid), rc);
 	return rc;
 }
 
@@ -4031,7 +4050,7 @@ int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk)
 	u32 size;
 	int rc;
 
-	lp = lnet_find_peer(cfg->prcfg_prim_nid);
+	lp = lnet_find_peer4(cfg->prcfg_prim_nid);
 
 	if (!lp) {
 		rc = -ENOENT;
diff --git a/net/lnet/selftest/rpc.c b/net/lnet/selftest/rpc.c
index bd95e88..d1538be 100644
--- a/net/lnet/selftest/rpc.c
+++ b/net/lnet/selftest/rpc.c
@@ -1492,8 +1492,8 @@ struct srpc_client_rpc *
 			sv->sv_shuttingdown);
 
 		buffer = container_of(ev->md_start, struct srpc_buffer, buf_msg);
-		buffer->buf_peer = ev->source;
-		buffer->buf_self = ev->target.nid;
+		buffer->buf_peer = lnet_pid_to_pid4(&ev->source);
+		buffer->buf_self = lnet_nid_to_nid4(&ev->target.nid);
 
 		LASSERT(scd->scd_buf_nposted > 0);
 		scd->scd_buf_nposted--;
@@ -1532,7 +1532,7 @@ struct srpc_client_rpc *
 		    (msg->msg_magic != SRPC_MSG_MAGIC &&
 		     msg->msg_magic != __swab32(SRPC_MSG_MAGIC))) {
 			CERROR("Dropping RPC (%s) from %s: status %d mlength %d type %u magic %u.\n",
-			       sv->sv_name, libcfs_id2str(ev->initiator),
+			       sv->sv_name, libcfs_idstr(&ev->initiator),
 			       ev->status, ev->mlength,
 			       msg->msg_type, msg->msg_magic);
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
