Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id F34A7C433FE
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Nov 2022 14:19:48 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4NFXfb2w1Kz1yBc;
	Sun, 20 Nov 2022 06:17:43 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4NFXf424KFz1y6B
 for <lustre-devel@lists.lustre.org>; Sun, 20 Nov 2022 06:17:16 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id BA67D1007A82;
 Sun, 20 Nov 2022 09:17:09 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id B504BE8B84; Sun, 20 Nov 2022 09:17:09 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Nov 2022 09:16:51 -0500
Message-Id: <1668953828-10909-6-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
References: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 05/22] lnet: o2iblnd: add verbose debug
 prints for rx/tx events
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
Cc: Serguei Smirnov <ssmirnov@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Serguei Smirnov <ssmirnov@whamcloud.com>

Added/modified debug messages for syncing with mlnx driver
debug output. On rx/tx events print message type, size and
peer credits. Make printing of debug message on o2iblnd conn
refcount change events compile-time optional. Add compile-time
option for dumping detailed connection state info to net debug log.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16172
Lustre-commit: b4e06ff1e4856ce08 ("LU-16172 o2iblnd: add verbose debug prints for rx/tx events")
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48600
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.h    |  78 +++++++++++++++++-------
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 117 ++++++++++++++++++++++--------------
 2 files changed, 129 insertions(+), 66 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index 56d486f..bef7a55 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -588,28 +588,32 @@ static inline int kiblnd_timeout(void)
 	return dev->ibd_can_failover;
 }
 
-#define kiblnd_conn_addref(conn)					\
-do {									\
-	CDEBUG(D_NET, "conn[%p] (%d)++\n",				\
-	       (conn), atomic_read(&(conn)->ibc_refcount));		\
-	atomic_inc(&(conn)->ibc_refcount);				\
-} while (0)
-
-#define kiblnd_conn_decref(conn)					\
-do {									\
-	unsigned long flags;						\
-									\
-	CDEBUG(D_NET, "conn[%p] (%d)--\n",				\
-	       (conn), atomic_read(&(conn)->ibc_refcount));		\
-	LASSERT_ATOMIC_POS(&(conn)->ibc_refcount);			\
-	if (atomic_dec_and_test(&(conn)->ibc_refcount)) {		\
-		spin_lock_irqsave(&kiblnd_data.kib_connd_lock, flags);	\
-		list_add_tail(&(conn)->ibc_list,			\
-				  &kiblnd_data.kib_connd_zombies);	\
-		wake_up(&kiblnd_data.kib_connd_waitq);			\
-		spin_unlock_irqrestore(&kiblnd_data.kib_connd_lock, flags);\
-	}								\
-} while (0)
+static inline void kiblnd_conn_addref(struct kib_conn *conn)
+{
+#ifdef CONFIG_LUSTRE_DEBUG_EXPENSIVE_CHECK
+	CDEBUG(D_NET, "conn[%p] (%d)++\n",
+	       conn, atomic_read(&conn->ibc_refcount));
+#endif
+	atomic_inc(&(conn)->ibc_refcount);
+}
+
+static inline void kiblnd_conn_decref(struct kib_conn *conn)
+{
+	unsigned long flags;
+
+#ifdef CONFIG_LUSTRE_DEBUG_EXPENSIVE_CHECK
+	CDEBUG(D_NET, "conn[%p] (%d)--\n",
+	       conn, atomic_read(&conn->ibc_refcount));
+#endif
+	LASSERT_ATOMIC_POS(&conn->ibc_refcount);
+	if (atomic_dec_and_test(&conn->ibc_refcount)) {
+		spin_lock_irqsave(&kiblnd_data.kib_connd_lock, flags);
+		list_add_tail(&conn->ibc_list,
+			      &kiblnd_data.kib_connd_zombies);
+		wake_up(&kiblnd_data.kib_connd_waitq);
+		spin_unlock_irqrestore(&kiblnd_data.kib_connd_lock, flags);
+	}
+}
 
 void kiblnd_destroy_peer(struct kref *kref);
 
@@ -971,3 +975,33 @@ void kiblnd_pack_msg(struct lnet_ni *ni, struct kib_msg *msg, int version,
 int kiblnd_recv(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg,
 		int delayed, struct iov_iter *to, unsigned int rlen);
 unsigned int kiblnd_get_dev_prio(struct lnet_ni *ni, unsigned int dev_idx);
+
+#define kiblnd_dump_conn_dbg(conn)			\
+({							\
+	if (conn && conn->ibc_cmid)			\
+		CDEBUG(D_NET,				\
+		       "conn %p state %d nposted %d/%d c/o/r %d/%d/%d ce %d : cm_id %p qp_num 0x%x device_name %s\n",    \
+		       conn,				\
+		       conn->ibc_state,			\
+		       conn->ibc_noops_posted,		\
+		       conn->ibc_nsends_posted,		\
+		       conn->ibc_credits,		\
+		       conn->ibc_outstanding_credits,	\
+		       conn->ibc_reserved_credits,	\
+		       conn->ibc_comms_error,		\
+		       conn->ibc_cmid,			\
+		       conn->ibc_cmid->qp ? conn->ibc_cmid->qp->qp_num : 0,	\
+		       conn->ibc_cmid->qp ? (conn->ibc_cmid->qp->device ? dev_name(&conn->ibc_cmid->qp->device->dev) : "NULL") : "NULL");	\
+	else if (conn)                                  \
+		CDEBUG(D_NET,				\
+		       "conn %p state %d nposted %d/%d c/o/r %d/%d/%d ce %d : cm_id NULL\n",	\
+		       conn,				\
+		       conn->ibc_state,			\
+		       conn->ibc_noops_posted,		\
+		       conn->ibc_nsends_posted,		\
+		       conn->ibc_credits,		\
+		       conn->ibc_outstanding_credits,	\
+		       conn->ibc_reserved_credits,	\
+		       conn->ibc_comms_error		\
+		       );				\
+})
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index b16841e..d4de326 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -337,9 +337,12 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 
 	LASSERT(conn->ibc_state >= IBLND_CONN_ESTABLISHED);
 
-	CDEBUG(D_NET, "Received %x[%d] from %s\n",
+	CDEBUG(D_NET, "Received %x[%d] nob %u cm_id %p qp_num 0x%x\n",
 	       msg->ibm_type, credits,
-	       libcfs_nid2str(conn->ibc_peer->ibp_nid));
+	       msg->ibm_nob,
+	       conn->ibc_cmid,
+	       conn->ibc_cmid->qp ? conn->ibc_cmid->qp->qp_num : 0);
+	kiblnd_dump_conn_dbg(conn);
 
 	if (credits) {
 		/* Have I received credits that will let me send? */
@@ -760,8 +763,11 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	}
 
 	if (credit && !conn->ibc_credits) {   /* no credits */
-		CDEBUG(D_NET, "%s: no credits\n",
-		       libcfs_nid2str(peer_ni->ibp_nid));
+		CDEBUG(D_NET, "%s: no credits cm_id %p qp_num 0x%x\n",
+		       libcfs_nid2str(peer_ni->ibp_nid),
+		       conn->ibc_cmid,
+		       conn->ibc_cmid->qp ? conn->ibc_cmid->qp->qp_num : 0);
+		kiblnd_dump_conn_dbg(conn);
 		return -EAGAIN;
 	}
 
@@ -790,12 +796,22 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		tx->tx_hstatus = LNET_MSG_STATUS_LOCAL_ERROR;
 		kiblnd_tx_done(tx);
 		spin_lock(&conn->ibc_lock);
-		CDEBUG(D_NET, "%s(%d): redundant or enough NOOP\n",
+		CDEBUG(D_NET, "%s(%d): redundant or enough NOOP cm_id %p qp_num 0x%x\n",
 		       libcfs_nid2str(peer_ni->ibp_nid),
-		       conn->ibc_noops_posted);
+		       conn->ibc_noops_posted,
+		       conn->ibc_cmid,
+		       conn->ibc_cmid->qp ? conn->ibc_cmid->qp->qp_num : 0);
+		kiblnd_dump_conn_dbg(conn);
 		return 0;
 	}
 
+	CDEBUG(D_NET, "Transmit %x[%d] nob %u cm_id %p qp_num 0x%x\n",
+	       msg->ibm_type, credit,
+	       msg->ibm_nob,
+	       conn->ibc_cmid,
+	       conn->ibc_cmid->qp ? conn->ibc_cmid->qp->qp_num : 0);
+	kiblnd_dump_conn_dbg(conn);
+
 	kiblnd_pack_msg(peer_ni->ibp_ni, msg, ver,
 			conn->ibc_outstanding_credits,
 			peer_ni->ibp_nid, conn->ibc_incarnation);
@@ -1000,6 +1016,9 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		tx->tx_hstatus = LNET_MSG_STATUS_REMOTE_DROPPED;
 		tx->tx_waiting = 0;	/* don't wait for peer_ni */
 		tx->tx_status = -EIO;
+#ifdef CONFIG_LUSTRE_DEBUG_EXPENSIVE_CHECK
+		kiblnd_dump_conn_dbg(conn);
+#endif
 	}
 
 	idle = !tx->tx_sending &&	/* This is the final callback */
@@ -1982,10 +2001,12 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	    list_empty(&conn->ibc_tx_queue_rsrvd) &&
 	    list_empty(&conn->ibc_tx_queue_nocred) &&
 	    list_empty(&conn->ibc_active_txs)) {
-		CDEBUG(D_NET, "closing conn to %s\n",
+		CDEBUG(D_NET, "closing conn %p to %s\n",
+		       conn,
 		       libcfs_nid2str(peer_ni->ibp_nid));
 	} else {
-		CNETERR("Closing conn to %s: error %d%s%s%s%s%s\n",
+		CNETERR("Closing conn %p to %s: error %d%s%s%s%s%s\n",
+			conn,
 			libcfs_nid2str(peer_ni->ibp_nid), error,
 			list_empty(&conn->ibc_tx_queue) ? "" : "(sending)",
 			list_empty(&conn->ibc_tx_noops) ? "" : "(sending_noops)",
@@ -2660,11 +2681,11 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	cp.retry_count = *kiblnd_tunables.kib_retry_count;
 	cp.rnr_retry_count = *kiblnd_tunables.kib_rnr_retry_count;
 
-	CDEBUG(D_NET, "Accept %s\n", libcfs_nid2str(nid));
+	CDEBUG(D_NET, "Accept %s conn %p\n", libcfs_nid2str(nid), conn);
 
 	rc = rdma_accept(cmid, &cp);
 	if (rc) {
-		CERROR("Can't accept %s: %d\n", libcfs_nid2str(nid), rc);
+		CNETERR("Can't accept %s: %d cm_id %p\n", libcfs_nid2str(nid), rc, cmid);
 		rej.ibr_version = version;
 		rej.ibr_why = IBLND_REJECT_FATAL;
 
@@ -3085,10 +3106,13 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 
 	rc = rdma_connect(cmid, &cp);
 	if (rc) {
-		CERROR("Can't connect to %s: %d\n",
-		       libcfs_nid2str(peer_ni->ibp_nid), rc);
+		CNETERR("Can't connect to %s: %d cm_id %p\n",
+			libcfs_nid2str(peer_ni->ibp_nid), rc, cmid);
 		kiblnd_connreq_done(conn, rc);
 		kiblnd_conn_decref(conn);
+	} else {
+		CDEBUG(D_NET, "Connected to %s: cm_id %p\n",
+		       libcfs_nid2str(peer_ni->ibp_nid), cmid);
 	}
 
 	return 0;
@@ -3112,13 +3136,13 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		rc = kiblnd_passive_connect(cmid,
 					    (void *)KIBLND_CONN_PARAM(event),
 					    KIBLND_CONN_PARAM_LEN(event));
-		CDEBUG(D_NET, "connreq: %d\n", rc);
+		CDEBUG(D_NET, "connreq: %d cm_id %p\n", rc, cmid);
 		return rc;
 
 	case RDMA_CM_EVENT_ADDR_ERROR:
 		peer_ni = (struct kib_peer_ni *)cmid->context;
-		CNETERR("%s: ADDR ERROR %d\n",
-			libcfs_nid2str(peer_ni->ibp_nid), event->status);
+		CNETERR("%s: ADDR ERROR %d cm_id %p\n",
+			libcfs_nid2str(peer_ni->ibp_nid), event->status, cmid);
 		kiblnd_peer_connect_failed(peer_ni, 1, -EHOSTUNREACH);
 		kiblnd_peer_decref(peer_ni);
 		return -EHOSTUNREACH;      /* rc destroys cmid */
@@ -3126,13 +3150,13 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	case RDMA_CM_EVENT_ADDR_RESOLVED:
 		peer_ni = (struct kib_peer_ni *)cmid->context;
 
-		CDEBUG(D_NET, "%s Addr resolved: %d\n",
-		       libcfs_nid2str(peer_ni->ibp_nid), event->status);
+		CDEBUG(D_NET, "%s Addr resolved: %d cm_id %p\n",
+		       libcfs_nid2str(peer_ni->ibp_nid), event->status, cmid);
 
 		if (event->status) {
-			CNETERR("Can't resolve address for %s: %d\n",
+			CNETERR("Can't resolve address for %s: %d cm_id %p\n",
 				libcfs_nid2str(peer_ni->ibp_nid),
-				event->status);
+				event->status, cmid);
 			rc = event->status;
 		} else {
 			rc = rdma_resolve_route(cmid,
@@ -3151,8 +3175,8 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 			}
 
 			/* Can't initiate route resolution */
-			CERROR("Can't resolve route for %s: %d\n",
-			       libcfs_nid2str(peer_ni->ibp_nid), rc);
+			CNETERR("Can't resolve route for %s: %d cm_id %p\n",
+				libcfs_nid2str(peer_ni->ibp_nid), rc, cmid);
 		}
 		kiblnd_peer_connect_failed(peer_ni, 1, rc);
 		kiblnd_peer_decref(peer_ni);
@@ -3160,8 +3184,8 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 
 	case RDMA_CM_EVENT_ROUTE_ERROR:
 		peer_ni = (struct kib_peer_ni *)cmid->context;
-		CNETERR("%s: ROUTE ERROR %d\n",
-			libcfs_nid2str(peer_ni->ibp_nid), event->status);
+		CNETERR("%s: ROUTE ERROR %d cm_id %p\n",
+			libcfs_nid2str(peer_ni->ibp_nid), event->status, cmid);
 		kiblnd_peer_connect_failed(peer_ni, 1, -EHOSTUNREACH);
 		kiblnd_peer_decref(peer_ni);
 		return -EHOSTUNREACH;	/* rc destroys cmid */
@@ -3174,17 +3198,15 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		if (!event->status)
 			return kiblnd_active_connect(cmid);
 
-		CNETERR("Can't resolve route for %s: %d\n",
-			libcfs_nid2str(peer_ni->ibp_nid), event->status);
+		CNETERR("Can't resolve route for %s: %d cm_id %p\n",
+			libcfs_nid2str(peer_ni->ibp_nid), event->status, cmid);
 		kiblnd_peer_connect_failed(peer_ni, 1, event->status);
 		kiblnd_peer_decref(peer_ni);
 		return event->status;	/* rc destroys cmid */
 
 	case RDMA_CM_EVENT_UNREACHABLE:
-		CNETERR("%s: UNREACHABLE %d, ibc_state: %d\n",
-			libcfs_nid2str(conn->ibc_peer->ibp_nid),
-			event->status,
-			conn->ibc_state);
+		CNETERR("%s: UNREACHABLE %d cm_id %p conn %p\n",
+			libcfs_nid2str(conn->ibc_peer->ibp_nid), event->status, cmid, conn);
 		LASSERT(conn->ibc_state != IBLND_CONN_ESTABLISHED &&
 			conn->ibc_state != IBLND_CONN_INIT);
 		if (conn->ibc_state == IBLND_CONN_ACTIVE_CONNECT ||
@@ -3198,8 +3220,8 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		conn = (struct kib_conn *)cmid->context;
 		LASSERT(conn->ibc_state == IBLND_CONN_ACTIVE_CONNECT ||
 			conn->ibc_state == IBLND_CONN_PASSIVE_WAIT);
-		CNETERR("%s: CONNECT ERROR %d\n",
-			libcfs_nid2str(conn->ibc_peer->ibp_nid), event->status);
+		CNETERR("%s: CONNECT ERROR %d cm_id %p conn %p\n",
+			libcfs_nid2str(conn->ibc_peer->ibp_nid), event->status, cmid, conn);
 		kiblnd_connreq_done(conn, -ENOTCONN);
 		kiblnd_conn_decref(conn);
 		return 0;
@@ -3211,9 +3233,9 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 			LBUG();
 
 		case IBLND_CONN_PASSIVE_WAIT:
-			CERROR("%s: REJECTED %d\n",
+			CERROR("%s: REJECTED %d cm_id %p\n",
 			       libcfs_nid2str(conn->ibc_peer->ibp_nid),
-			       event->status);
+			       event->status, cmid);
 			kiblnd_connreq_done(conn, -ECONNRESET);
 			break;
 
@@ -3233,14 +3255,14 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 			LBUG();
 
 		case IBLND_CONN_PASSIVE_WAIT:
-			CDEBUG(D_NET, "ESTABLISHED (passive): %s\n",
-			       libcfs_nid2str(conn->ibc_peer->ibp_nid));
+			CDEBUG(D_NET, "ESTABLISHED (passive): %s cm_id %p conn %p\n",
+			       libcfs_nid2str(conn->ibc_peer->ibp_nid), cmid, conn);
 			kiblnd_connreq_done(conn, 0);
 			break;
 
 		case IBLND_CONN_ACTIVE_CONNECT:
-			CDEBUG(D_NET, "ESTABLISHED(active): %s\n",
-			       libcfs_nid2str(conn->ibc_peer->ibp_nid));
+			CDEBUG(D_NET, "ESTABLISHED(active): %s cm_id %p conn %p\n",
+			       libcfs_nid2str(conn->ibc_peer->ibp_nid), cmid, conn);
 			kiblnd_check_connreply(conn,
 					       (void *)KIBLND_CONN_PARAM(event),
 					       KIBLND_CONN_PARAM_LEN(event));
@@ -3255,8 +3277,8 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	case RDMA_CM_EVENT_DISCONNECTED:
 		conn = (struct kib_conn *)cmid->context;
 		if (conn->ibc_state < IBLND_CONN_ESTABLISHED) {
-			CERROR("%s DISCONNECTED\n",
-			       libcfs_nid2str(conn->ibc_peer->ibp_nid));
+			CERROR("%s DISCONNECTED cm_id %p conn %p\n",
+			       libcfs_nid2str(conn->ibc_peer->ibp_nid), cmid, conn);
 			kiblnd_connreq_done(conn, -ECONNRESET);
 		} else {
 			kiblnd_close_conn(conn, 0);
@@ -3372,6 +3394,9 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 				       conn->ibc_credits,
 				       conn->ibc_outstanding_credits,
 				       conn->ibc_reserved_credits);
+#ifdef CONFIG_LUSTRE_DEBUG_EXPENSIVE_CHECK
+				kiblnd_dump_conn_dbg(conn);
+#endif
 				list_add(&conn->ibc_connd_list, &closes);
 			} else {
 				list_add(&conn->ibc_connd_list, &checksends);
@@ -3425,7 +3450,9 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	LASSERT(!in_interrupt());
 	LASSERT(current == kiblnd_data.kib_connd);
 	LASSERT(conn->ibc_state == IBLND_CONN_CLOSING);
-
+#ifdef CONFIG_LUSTRE_DEBUG_EXPENSIVE_CHECK
+	kiblnd_dump_conn_dbg(conn);
+#endif
 	rdma_disconnect(conn->ibc_cmid);
 	kiblnd_finalise_conn(conn);
 
@@ -3716,6 +3743,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	    (conn->ibc_nrx > 0 ||
 	     conn->ibc_nsends_posted > 0)) {
 		kiblnd_conn_addref(conn); /* +1 ref for sched_conns */
+		kiblnd_dump_conn_dbg(conn);
 		conn->ibc_scheduled = 1;
 		list_add_tail(&conn->ibc_sched_list, &sched->ibs_conns);
 
@@ -3788,8 +3816,9 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 				rc = ib_req_notify_cq(conn->ibc_cq,
 						      IB_CQ_NEXT_COMP);
 				if (rc < 0) {
-					CWARN("%s: ib_req_notify_cq failed: %d, closing connection\n",
-					      libcfs_nid2str(conn->ibc_peer->ibp_nid), rc);
+					CWARN("%s: ib_req_notify_cq failed: %d, closing connection %p\n",
+					      libcfs_nid2str(conn->ibc_peer->ibp_nid),
+					      rc, conn);
 					kiblnd_close_conn(conn, -EIO);
 					kiblnd_conn_decref(conn);
 					spin_lock_irqsave(&sched->ibs_lock,
@@ -3810,9 +3839,9 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 			}
 
 			if (rc < 0) {
-				CWARN("%s: ib_poll_cq failed: %d, closing connection\n",
+				CWARN("%s: ib_poll_cq failed: %d, closing connection %p\n",
 				      libcfs_nid2str(conn->ibc_peer->ibp_nid),
-				      rc);
+				      rc, conn);
 				kiblnd_close_conn(conn, -EIO);
 				kiblnd_conn_decref(conn);
 				spin_lock_irqsave(&sched->ibs_lock, flags);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
