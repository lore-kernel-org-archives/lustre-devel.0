Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 3C49EC433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 28 Nov 2021 23:28:04 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id BA057200F69;
	Sun, 28 Nov 2021 15:28:02 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 33142200EB1
 for <lustre-devel@lists.lustre.org>; Sun, 28 Nov 2021 15:28:00 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 9061D244;
 Sun, 28 Nov 2021 18:27:56 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 84479C1AE4; Sun, 28 Nov 2021 18:27:56 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 28 Nov 2021 18:27:39 -0500
Message-Id: <1638142074-5945-5-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1638142074-5945-1-git-send-email-jsimmons@infradead.org>
References: <1638142074-5945-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 04/19] lnet: switch to large lnet_processid
 for matching
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

Change lnet_libhandle.me_match_id and lnet_match_info.mi_id to
struct lnet_processid, so they support large nids.

This requires changing
  LNetMEAttach(), lnet_mt_match_head(), lnet_mt_of_attach(),
  lnet_ptl_match_type(), lnet_match2mt()
to accept a pointer to lnet_processid rather than an
lnet_process_id.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: db49fbf00d24edc83 ("LU-10391 lnet: switch to large lnet_processid for matching")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/43597
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/niobuf.c      | 21 ++++++++++++--------
 include/linux/lnet/api.h       |  2 +-
 include/linux/lnet/lib-lnet.h  |  4 ++--
 include/linux/lnet/lib-types.h |  4 ++--
 net/lnet/lnet/api-ni.c         | 12 +++++------
 net/lnet/lnet/lib-me.c         |  4 ++--
 net/lnet/lnet/lib-move.c       | 10 +++++-----
 net/lnet/lnet/lib-ptl.c        | 45 ++++++++++++++++++++++--------------------
 net/lnet/selftest/rpc.c        | 10 +++++++---
 9 files changed, 62 insertions(+), 50 deletions(-)

diff --git a/fs/lustre/ptlrpc/niobuf.c b/fs/lustre/ptlrpc/niobuf.c
index 614bb63..c5bbf5a 100644
--- a/fs/lustre/ptlrpc/niobuf.c
+++ b/fs/lustre/ptlrpc/niobuf.c
@@ -120,7 +120,7 @@ static void __mdunlink_iterate_helper(struct lnet_handle_md *bd_mds,
 static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 {
 	struct ptlrpc_bulk_desc *desc = req->rq_bulk;
-	struct lnet_process_id peer;
+	struct lnet_processid peer;
 	int rc = 0;
 	int posted_md;
 	int total_md;
@@ -150,7 +150,9 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 
 	desc->bd_failure = 0;
 
-	peer = desc->bd_import->imp_connection->c_peer;
+	peer.pid = desc->bd_import->imp_connection->c_peer.pid;
+	lnet_nid4_to_nid(desc->bd_import->imp_connection->c_peer.nid,
+		      &peer.nid);
 
 	LASSERT(desc->bd_cbid.cbid_fn == client_bulk_callback);
 	LASSERT(desc->bd_cbid.cbid_arg == desc);
@@ -186,7 +188,7 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 		    OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_BULK_ATTACH)) {
 			rc = -ENOMEM;
 		} else {
-			me = LNetMEAttach(desc->bd_portal, peer, mbits, 0,
+			me = LNetMEAttach(desc->bd_portal, &peer, mbits, 0,
 					  LNET_UNLINK, LNET_INS_AFTER);
 			rc = PTR_ERR_OR_ZERO(me);
 		}
@@ -225,7 +227,7 @@ static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 	/* Holler if peer manages to touch buffers before he knows the mbits */
 	if (desc->bd_refs != total_md)
 		CWARN("%s: Peer %s touched %d buffers while I registered\n",
-		      desc->bd_import->imp_obd->obd_name, libcfs_id2str(peer),
+		      desc->bd_import->imp_obd->obd_name, libcfs_idstr(&peer),
 		      total_md - desc->bd_refs);
 	spin_unlock(&desc->bd_lock);
 
@@ -492,6 +494,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 	unsigned int mpflag = 0;
 	bool rep_mbits = false;
 	struct lnet_handle_md bulk_cookie;
+	struct lnet_processid peer;
 	struct ptlrpc_connection *connection;
 	struct lnet_me *reply_me;
 	struct lnet_md reply_md;
@@ -627,12 +630,14 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 			request->rq_repmsg = NULL;
 		}
 
+		peer.pid = connection->c_peer.pid;
+		lnet_nid4_to_nid(connection->c_peer.nid, &peer.nid);
 		if (request->rq_bulk &&
 		    OBD_FAIL_CHECK(OBD_FAIL_PTLRPC_BULK_REPLY_ATTACH)) {
 			reply_me = ERR_PTR(-ENOMEM);
 		} else {
 			reply_me = LNetMEAttach(request->rq_reply_portal,
-						connection->c_peer,
+						&peer,
 						rep_mbits ? request->rq_mbits :
 						request->rq_xid,
 						0, LNET_UNLINK, LNET_INS_AFTER);
@@ -761,8 +766,8 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 int ptlrpc_register_rqbd(struct ptlrpc_request_buffer_desc *rqbd)
 {
 	struct ptlrpc_service *service = rqbd->rqbd_svcpt->scp_service;
-	static struct lnet_process_id match_id = {
-		.nid = LNET_NID_ANY,
+	static struct lnet_processid match_id = {
+		.nid = LNET_ANY_NID,
 		.pid = LNET_PID_ANY
 	};
 	int rc;
@@ -780,7 +785,7 @@ int ptlrpc_register_rqbd(struct ptlrpc_request_buffer_desc *rqbd)
 	 * threads can find it by grabbing a local lock
 	 */
 	me = LNetMEAttach(service->srv_req_portal,
-			  match_id, 0, ~0, LNET_UNLINK,
+			  &match_id, 0, ~0, LNET_UNLINK,
 			  rqbd->rqbd_svcpt->scp_cpt >= 0 ?
 			  LNET_INS_LOCAL : LNET_INS_AFTER);
 	if (IS_ERR(me)) {
diff --git a/include/linux/lnet/api.h b/include/linux/lnet/api.h
index d32c7c1..040bf18 100644
--- a/include/linux/lnet/api.h
+++ b/include/linux/lnet/api.h
@@ -96,7 +96,7 @@
  */
 struct lnet_me *
 LNetMEAttach(unsigned int portal,
-	     struct lnet_process_id match_id_in,
+	     struct lnet_processid *match_id_in,
 	     u64 match_bits_in,
 	     u64 ignore_bits_in,
 	     enum lnet_unlink unlink_in,
diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index fb2f42fcb..02eae6b 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -629,9 +629,9 @@ int lnet_send_ping(lnet_nid_t dest_nid, struct lnet_handle_md *mdh, int nnis,
 
 /* match-table functions */
 struct list_head *lnet_mt_match_head(struct lnet_match_table *mtable,
-				     struct lnet_process_id id, u64 mbits);
+				     struct lnet_processid *id, u64 mbits);
 struct lnet_match_table *lnet_mt_of_attach(unsigned int index,
-					   struct lnet_process_id id,
+					   struct lnet_processid *id,
 					   u64 mbits, u64 ignore_bits,
 					   enum lnet_ins_pos pos);
 int lnet_mt_match_md(struct lnet_match_table *mtable,
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index bde7249..628d133 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -187,7 +187,7 @@ struct lnet_libhandle {
 struct lnet_me {
 	struct list_head	 me_list;
 	int			 me_cpt;
-	struct lnet_process_id	 me_match_id;
+	struct lnet_processid	 me_match_id;
 	unsigned int		 me_portal;
 	unsigned int		 me_pos;	/* hash offset in mt_hash */
 	u64			 me_match_bits;
@@ -994,7 +994,7 @@ enum lnet_match_flags {
 /* parameter for matching operations (GET, PUT) */
 struct lnet_match_info {
 	u64			mi_mbits;
-	struct lnet_process_id	mi_id;
+	struct lnet_processid	mi_id;
 	unsigned int		mi_cpt;
 	unsigned int		mi_opc;
 	unsigned int		mi_portal;
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 340cc84e..9d9d0e6 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -1840,8 +1840,8 @@ struct lnet_ping_buffer *
 		       struct lnet_handle_md *ping_mdh,
 		       int ni_count, bool set_eq)
 {
-	struct lnet_process_id id = {
-		.nid = LNET_NID_ANY,
+	struct lnet_processid id = {
+		.nid = LNET_ANY_NID,
 		.pid = LNET_PID_ANY
 	};
 	struct lnet_me *me;
@@ -1859,7 +1859,7 @@ struct lnet_ping_buffer *
 	}
 
 	/* Ping target ME/MD */
-	me = LNetMEAttach(LNET_RESERVED_PORTAL, id,
+	me = LNetMEAttach(LNET_RESERVED_PORTAL, &id,
 			  LNET_PROTO_PING_MATCHBITS, 0,
 			  LNET_UNLINK, LNET_INS_AFTER);
 	if (IS_ERR(me)) {
@@ -2056,15 +2056,15 @@ int lnet_push_target_resize(void)
 int lnet_push_target_post(struct lnet_ping_buffer *pbuf,
 			  struct lnet_handle_md *mdhp)
 {
-	struct lnet_process_id id = {
-		.nid	= LNET_NID_ANY,
+	struct lnet_processid id = {
+		.nid	= LNET_ANY_NID,
 		.pid	= LNET_PID_ANY
 	};
 	struct lnet_md md = { NULL };
 	struct lnet_me *me;
 	int rc;
 
-	me = LNetMEAttach(LNET_RESERVED_PORTAL, id,
+	me = LNetMEAttach(LNET_RESERVED_PORTAL, &id,
 			  LNET_PROTO_PING_MATCHBITS, 0,
 			  LNET_UNLINK, LNET_INS_AFTER);
 	if (IS_ERR(me)) {
diff --git a/net/lnet/lnet/lib-me.c b/net/lnet/lnet/lib-me.c
index 66a79e2..7868165 100644
--- a/net/lnet/lnet/lib-me.c
+++ b/net/lnet/lnet/lib-me.c
@@ -68,7 +68,7 @@
  */
 struct lnet_me *
 LNetMEAttach(unsigned int portal,
-	     struct lnet_process_id match_id,
+	     struct lnet_processid *match_id,
 	     u64 match_bits, u64 ignore_bits,
 	     enum lnet_unlink unlink, enum lnet_ins_pos pos)
 {
@@ -93,7 +93,7 @@ struct lnet_me *
 	lnet_res_lock(mtable->mt_cpt);
 
 	me->me_portal = portal;
-	me->me_match_id = match_id;
+	me->me_match_id = *match_id;
 	me->me_match_bits = match_bits;
 	me->me_ignore_bits = ignore_bits;
 	me->me_unlink = unlink;
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 2f7c37d..088a754 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -3900,7 +3900,7 @@ void lnet_monitor_thr_stop(void)
 	le32_to_cpus(&hdr->msg.put.offset);
 
 	/* Primary peer NID. */
-	info.mi_id.nid = msg->msg_initiator;
+	lnet_nid4_to_nid(msg->msg_initiator, &info.mi_id.nid);
 	info.mi_id.pid = hdr->src_pid;
 	info.mi_opc = LNET_MD_OP_PUT;
 	info.mi_portal = hdr->msg.put.ptl_index;
@@ -3939,7 +3939,7 @@ void lnet_monitor_thr_stop(void)
 
 	case LNET_MATCHMD_DROP:
 		CNETERR("Dropping PUT from %s portal %d match %llu offset %d length %d: %d\n",
-			libcfs_id2str(info.mi_id), info.mi_portal,
+			libcfs_idstr(&info.mi_id), info.mi_portal,
 			info.mi_mbits, info.mi_roffset, info.mi_rlength, rc);
 
 		return -ENOENT;	/* -ve: OK but no match */
@@ -3964,7 +3964,7 @@ void lnet_monitor_thr_stop(void)
 	source_id.nid = hdr->src_nid;
 	source_id.pid = hdr->src_pid;
 	/* Primary peer NID */
-	info.mi_id.nid = msg->msg_initiator;
+	lnet_nid4_to_nid(msg->msg_initiator, &info.mi_id.nid);
 	info.mi_id.pid = hdr->src_pid;
 	info.mi_opc = LNET_MD_OP_GET;
 	info.mi_portal = hdr->msg.get.ptl_index;
@@ -3976,7 +3976,7 @@ void lnet_monitor_thr_stop(void)
 	rc = lnet_ptl_match_md(&info, msg);
 	if (rc == LNET_MATCHMD_DROP) {
 		CNETERR("Dropping GET from %s portal %d match %llu offset %d length %d\n",
-			libcfs_id2str(info.mi_id), info.mi_portal,
+			libcfs_idstr(&info.mi_id), info.mi_portal,
 			info.mi_mbits, info.mi_roffset, info.mi_rlength);
 		return -ENOENT;	/* -ve: OK but no match */
 	}
@@ -4008,7 +4008,7 @@ void lnet_monitor_thr_stop(void)
 		/* didn't get as far as lnet_ni_send() */
 		CERROR("%s: Unable to send REPLY for GET from %s: %d\n",
 		       libcfs_nidstr(&ni->ni_nid),
-		       libcfs_id2str(info.mi_id), rc);
+		       libcfs_idstr(&info.mi_id), rc);
 
 		lnet_finalize(msg, rc);
 	}
diff --git a/net/lnet/lnet/lib-ptl.c b/net/lnet/lnet/lib-ptl.c
index 095b190..d367c00 100644
--- a/net/lnet/lnet/lib-ptl.c
+++ b/net/lnet/lnet/lib-ptl.c
@@ -39,15 +39,15 @@
 MODULE_PARM_DESC(portal_rotor, "redirect PUTs to different cpu-partitions");
 
 static int
-lnet_ptl_match_type(unsigned int index, struct lnet_process_id match_id,
+lnet_ptl_match_type(unsigned int index, struct lnet_processid *match_id,
 		    u64 mbits, u64 ignore_bits)
 {
 	struct lnet_portal *ptl = the_lnet.ln_portals[index];
 	int unique;
 
-	unique = !ignore_bits &&
-		 match_id.nid != LNET_NID_ANY &&
-		 match_id.pid != LNET_PID_ANY;
+	unique = (!ignore_bits &&
+		  !LNET_NID_IS_ANY(&match_id->nid) &&
+		  match_id->pid != LNET_PID_ANY);
 
 	LASSERT(!lnet_ptl_is_unique(ptl) || !lnet_ptl_is_wildcard(ptl));
 
@@ -151,8 +151,8 @@
 		return LNET_MATCHMD_NONE;
 
 	/* mismatched ME nid/pid? */
-	if (me->me_match_id.nid != LNET_NID_ANY &&
-	    me->me_match_id.nid != info->mi_id.nid)
+	if (!LNET_NID_IS_ANY(&me->me_match_id.nid) &&
+	    !nid_same(&me->me_match_id.nid, &info->mi_id.nid))
 		return LNET_MATCHMD_NONE;
 
 	if (me->me_match_id.pid != LNET_PID_ANY &&
@@ -182,7 +182,7 @@
 	} else if (!(md->md_options & LNET_MD_TRUNCATE)) {
 		/* this packet _really_ is too big */
 		CERROR("Matching packet from %s, match %llu length %d too big: %d left, %d allowed\n",
-		       libcfs_id2str(info->mi_id), info->mi_mbits,
+		       libcfs_idstr(&info->mi_id), info->mi_mbits,
 		       info->mi_rlength, md->md_length - offset, mlength);
 
 		return LNET_MATCHMD_DROP;
@@ -191,7 +191,7 @@
 	/* Commit to this ME/MD */
 	CDEBUG(D_NET, "Incoming %s index %x from %s of length %d/%d into md %#llx [%d] + %d\n",
 	       (info->mi_opc == LNET_MD_OP_PUT) ? "put" : "get",
-	       info->mi_portal, libcfs_id2str(info->mi_id), mlength,
+	       info->mi_portal, libcfs_idstr(&info->mi_id), mlength,
 	       info->mi_rlength, md->md_lh.lh_cookie, md->md_niov, offset);
 
 	lnet_msg_attach_md(msg, md, offset, mlength);
@@ -212,18 +212,18 @@
 }
 
 static struct lnet_match_table *
-lnet_match2mt(struct lnet_portal *ptl, struct lnet_process_id id, u64 mbits)
+lnet_match2mt(struct lnet_portal *ptl, struct lnet_processid *id, u64 mbits)
 {
 	if (LNET_CPT_NUMBER == 1)
 		return ptl->ptl_mtables[0]; /* the only one */
 
 	/* if it's a unique portal, return match-table hashed by NID */
 	return lnet_ptl_is_unique(ptl) ?
-	       ptl->ptl_mtables[lnet_cpt_of_nid(id.nid, NULL)] : NULL;
+	       ptl->ptl_mtables[lnet_nid2cpt(&id->nid, NULL)] : NULL;
 }
 
 struct lnet_match_table *
-lnet_mt_of_attach(unsigned int index, struct lnet_process_id id,
+lnet_mt_of_attach(unsigned int index, struct lnet_processid *id,
 		  u64 mbits, u64 ignore_bits, enum lnet_ins_pos pos)
 {
 	struct lnet_portal *ptl;
@@ -274,7 +274,7 @@ struct lnet_match_table *
 
 	LASSERT(lnet_ptl_is_wildcard(ptl) || lnet_ptl_is_unique(ptl));
 
-	mtable = lnet_match2mt(ptl, info->mi_id, info->mi_mbits);
+	mtable = lnet_match2mt(ptl, &info->mi_id, info->mi_mbits);
 	if (mtable)
 		return mtable;
 
@@ -357,13 +357,13 @@ struct lnet_match_table *
 
 struct list_head *
 lnet_mt_match_head(struct lnet_match_table *mtable,
-		   struct lnet_process_id id, u64 mbits)
+		   struct lnet_processid *id, u64 mbits)
 {
 	struct lnet_portal *ptl = the_lnet.ln_portals[mtable->mt_portal];
 	unsigned long hash = mbits;
 
 	if (!lnet_ptl_is_wildcard(ptl)) {
-		hash += id.nid + id.pid;
+		hash += nidhash(&id->nid) + id->pid;
 
 		LASSERT(lnet_ptl_is_unique(ptl));
 		hash = hash_long(hash, LNET_MT_HASH_BITS);
@@ -385,7 +385,8 @@ struct list_head *
 	if (!list_empty(&mtable->mt_mhash[LNET_MT_HASH_IGNORE]))
 		head = &mtable->mt_mhash[LNET_MT_HASH_IGNORE];
 	else
-		head = lnet_mt_match_head(mtable, info->mi_id, info->mi_mbits);
+		head = lnet_mt_match_head(mtable, &info->mi_id,
+					  info->mi_mbits);
 again:
 	/* NB: only wildcard portal needs to return LNET_MATCHMD_EXHAUSTED */
 	if (lnet_ptl_is_wildcard(the_lnet.ln_portals[mtable->mt_portal]))
@@ -418,7 +419,8 @@ struct list_head *
 	}
 
 	if (!exhausted && head == &mtable->mt_mhash[LNET_MT_HASH_IGNORE]) {
-		head = lnet_mt_match_head(mtable, info->mi_id, info->mi_mbits);
+		head = lnet_mt_match_head(mtable, &info->mi_id,
+					  info->mi_mbits);
 		goto again; /* re-check MEs w/o ignore-bits */
 	}
 
@@ -570,8 +572,9 @@ struct list_head *
 	struct lnet_portal *ptl;
 	int rc;
 
-	CDEBUG(D_NET, "Request from %s of length %d into portal %d MB=%#llx\n",
-	       libcfs_id2str(info->mi_id), info->mi_rlength, info->mi_portal,
+	CDEBUG(D_NET,
+	       "Request from %s of length %d into portal %d MB=%#llx\n",
+	       libcfs_idstr(&info->mi_id), info->mi_rlength, info->mi_portal,
 	       info->mi_mbits);
 
 	if (info->mi_portal >= the_lnet.ln_nportals) {
@@ -629,7 +632,7 @@ struct list_head *
 		CDEBUG(D_NET,
 		       "Delaying %s from %s ptl %d MB %#llx off %d len %d\n",
 		       info->mi_opc == LNET_MD_OP_PUT ? "PUT" : "GET",
-		       libcfs_id2str(info->mi_id), info->mi_portal,
+		       libcfs_idstr(&info->mi_id), info->mi_portal,
 		       info->mi_mbits, info->mi_roffset, info->mi_rlength);
 	}
 	goto out0;
@@ -687,7 +690,7 @@ struct list_head *
 
 		hdr = &msg->msg_hdr;
 		/* Multi-Rail: Primary peer NID */
-		info.mi_id.nid = msg->msg_initiator;
+		lnet_nid4_to_nid(msg->msg_initiator, &info.mi_id.nid);
 		info.mi_id.pid = hdr->src_pid;
 		info.mi_opc = LNET_MD_OP_PUT;
 		info.mi_portal = hdr->msg.put.ptl_index;
@@ -719,7 +722,7 @@ struct list_head *
 			list_add_tail(&msg->msg_list, matches);
 
 			CDEBUG(D_NET, "Resuming delayed PUT from %s portal %d match %llu offset %d length %d.\n",
-			       libcfs_id2str(info.mi_id),
+			       libcfs_idstr(&info.mi_id),
 			       info.mi_portal, info.mi_mbits,
 			       info.mi_roffset, info.mi_rlength);
 		} else {
diff --git a/net/lnet/selftest/rpc.c b/net/lnet/selftest/rpc.c
index 7141da4..bd95e88 100644
--- a/net/lnet/selftest/rpc.c
+++ b/net/lnet/selftest/rpc.c
@@ -354,14 +354,18 @@ struct srpc_bulk *
 
 static int
 srpc_post_passive_rdma(int portal, int local, u64 matchbits, void *buf,
-		       int len, int options, struct lnet_process_id peer,
+		       int len, int options, struct lnet_process_id peer4,
 		       struct lnet_handle_md *mdh, struct srpc_event *ev)
 {
 	int rc;
 	struct lnet_md md;
 	struct lnet_me *me;
+	struct lnet_processid peer;
 
-	me = LNetMEAttach(portal, peer, matchbits, 0, LNET_UNLINK,
+	peer.pid = peer4.pid;
+	lnet_nid4_to_nid(peer4.nid, &peer.nid);
+
+	me = LNetMEAttach(portal, &peer, matchbits, 0, LNET_UNLINK,
 			  local ? LNET_INS_LOCAL : LNET_INS_AFTER);
 	if (IS_ERR(me)) {
 		rc = PTR_ERR(me);
@@ -387,7 +391,7 @@ struct srpc_bulk *
 
 	CDEBUG(D_NET,
 	       "Posted passive RDMA: peer %s, portal %d, matchbits %#llx\n",
-	       libcfs_id2str(peer), portal, matchbits);
+	       libcfs_id2str(peer4), portal, matchbits);
 	return 0;
 }
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
