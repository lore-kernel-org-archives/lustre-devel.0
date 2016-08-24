From: Oleg Drokin <green@linuxhacker.ru>
Date: Wed, 24 Aug 2016 11:11:58 -0400
Subject: [lustre-devel] [PATCH v2 8/8] staging/lustre/o2iblnd: handle mixed
	page size configurations.
In-Reply-To: <1472051518-745466-1-git-send-email-green@linuxhacker.ru>
References: <1472051518-745466-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1472051518-745466-9-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <uja.ornl@yahoo.com>, Oleg Drokin <green@linuxhacker.ru>

From: James Simmons <uja.ornl@yahoo.com>

Currently it is not possible to send LNet traffic between
two nodes using infiniband hardware that have different
page sizes for the case when RDMA fragments are used.
When two nodes establish a connection they tell the other
node the maximum number of RDMA fragments they support.
The issue is that the units are pages, and 256 64K pages
corresponds to 16MB of data, whereas a 4K page system is
limited to messages with 1MB of data. The solution is to
report over the wire the maximum number of fragments in
4K unites regardless of the native page size. The recipient
then uses its native page size to translate into the
maximum number of pages sized fragments it can send to
the other node.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: http://review.whamcloud.com/21304
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7650
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Olaf Weber <olaf@sgi.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    | 14 +++---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    | 13 ++---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 55 ++++++++++------------
 3 files changed, 41 insertions(+), 41 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index e93dbeb..c7a5d49 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -128,6 +128,7 @@ static int kiblnd_msgtype2size(int type)
 static int kiblnd_unpack_rd(struct kib_msg *msg, int flip)
 {
 	struct kib_rdma_desc *rd;
+	int msg_size;
 	int nob;
 	int n;
 	int i;
@@ -146,12 +147,6 @@ static int kiblnd_unpack_rd(struct kib_msg *msg, int flip)
 
 	n = rd->rd_nfrags;
 
-	if (n <= 0 || n > IBLND_MAX_RDMA_FRAGS) {
-		CERROR("Bad nfrags: %d, should be 0 < n <= %d\n",
-		       n, IBLND_MAX_RDMA_FRAGS);
-		return 1;
-	}
-
 	nob = offsetof(struct kib_msg, ibm_u) +
 	      kiblnd_rd_msg_size(rd, msg->ibm_type, n);
 
@@ -161,6 +156,13 @@ static int kiblnd_unpack_rd(struct kib_msg *msg, int flip)
 		return 1;
 	}
 
+	msg_size = kiblnd_rd_size(rd);
+	if (msg_size <= 0 || msg_size > LNET_MAX_PAYLOAD) {
+		CERROR("Bad msg_size: %d, should be 0 < n <= %d\n",
+		       msg_size, LNET_MAX_PAYLOAD);
+		return 1;
+	}
+
 	if (!flip)
 		return 0;
 
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 3cf8942..1457697 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -113,8 +113,9 @@ extern struct kib_tunables  kiblnd_tunables;
 #define IBLND_OOB_CAPABLE(v)       ((v) != IBLND_MSG_VERSION_1)
 #define IBLND_OOB_MSGS(v)	   (IBLND_OOB_CAPABLE(v) ? 2 : 0)
 
-#define IBLND_MSG_SIZE		(4 << 10)	 /* max size of queued messages (inc hdr) */
-#define IBLND_MAX_RDMA_FRAGS	 LNET_MAX_IOV	   /* max # of fragments supported */
+#define IBLND_FRAG_SHIFT	(PAGE_SHIFT - 12)	/* frag size on wire is in 4K units */
+#define IBLND_MSG_SIZE		(4 << 10)		/* max size of queued messages (inc hdr) */
+#define IBLND_MAX_RDMA_FRAGS	(LNET_MAX_PAYLOAD >> 12)/* max # of fragments supported in 4K size */
 
 /************************/
 /* derived constants... */
@@ -133,8 +134,8 @@ extern struct kib_tunables  kiblnd_tunables;
 /* WRs and CQEs (per connection) */
 #define IBLND_RECV_WRS(c)	IBLND_RX_MSGS(c)
 #define IBLND_SEND_WRS(c)	\
-	((c->ibc_max_frags + 1) * kiblnd_concurrent_sends(c->ibc_version, \
-							  c->ibc_peer->ibp_ni))
+	(((c->ibc_max_frags + 1) << IBLND_FRAG_SHIFT) * \
+	  kiblnd_concurrent_sends(c->ibc_version, c->ibc_peer->ibp_ni))
 #define IBLND_CQ_ENTRIES(c)	(IBLND_RECV_WRS(c) + IBLND_SEND_WRS(c))
 
 struct kib_hca_dev;
@@ -609,14 +610,14 @@ kiblnd_cfg_rdma_frags(struct lnet_ni *ni)
 
 	tunables = &ni->ni_lnd_tunables->lt_tun_u.lt_o2ib;
 	mod = tunables->lnd_map_on_demand;
-	return mod ? mod : IBLND_MAX_RDMA_FRAGS;
+	return mod ? mod : IBLND_MAX_RDMA_FRAGS >> IBLND_FRAG_SHIFT;
 }
 
 static inline int
 kiblnd_rdma_frags(int version, struct lnet_ni *ni)
 {
 	return version == IBLND_MSG_VERSION_1 ?
-			  IBLND_MAX_RDMA_FRAGS :
+			  (IBLND_MAX_RDMA_FRAGS >> IBLND_FRAG_SHIFT) :
 			  kiblnd_cfg_rdma_frags(ni);
 }
 
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 1563428..3a86879 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -764,7 +764,6 @@ kiblnd_post_tx_locked(struct kib_conn *conn, struct kib_tx *tx, int credit)
 	LASSERT(tx->tx_queued);
 	/* We rely on this for QP sizing */
 	LASSERT(tx->tx_nwrq > 0);
-	LASSERT(tx->tx_nwrq <= 1 + conn->ibc_max_frags);
 
 	LASSERT(!credit || credit == 1);
 	LASSERT(conn->ibc_outstanding_credits >= 0);
@@ -1072,6 +1071,15 @@ kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 	LASSERT(type == IBLND_MSG_GET_DONE ||
 		type == IBLND_MSG_PUT_DONE);
 
+	if (kiblnd_rd_size(srcrd) > conn->ibc_max_frags << PAGE_SHIFT) {
+		CERROR("RDMA is too large for peer %s (%d), src size: %d dst size: %d\n",
+		       libcfs_nid2str(conn->ibc_peer->ibp_nid),
+		       conn->ibc_max_frags << PAGE_SHIFT,
+		       kiblnd_rd_size(srcrd), kiblnd_rd_size(dstrd));
+		rc = -EMSGSIZE;
+		goto too_big;
+	}
+
 	while (resid > 0) {
 		if (srcidx >= srcrd->rd_nfrags) {
 			CERROR("Src buffer exhausted: %d frags\n", srcidx);
@@ -1085,16 +1093,6 @@ kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 			break;
 		}
 
-		if (tx->tx_nwrq >= conn->ibc_max_frags) {
-			CERROR("RDMA has too many fragments for peer %s (%d), src idx/frags: %d/%d dst idx/frags: %d/%d\n",
-			       libcfs_nid2str(conn->ibc_peer->ibp_nid),
-			       conn->ibc_max_frags,
-			       srcidx, srcrd->rd_nfrags,
-			       dstidx, dstrd->rd_nfrags);
-			rc = -EMSGSIZE;
-			break;
-		}
-
 		wrknob = min(min(kiblnd_rd_frag_size(srcrd, srcidx),
 				 kiblnd_rd_frag_size(dstrd, dstidx)),
 			     (__u32)resid);
@@ -1126,7 +1124,7 @@ kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 		wrq++;
 		sge++;
 	}
-
+too_big:
 	if (rc < 0)			     /* no RDMA if completing with failure */
 		tx->tx_nwrq = 0;
 
@@ -2226,6 +2224,7 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 	struct kib_rej rej;
 	int version = IBLND_MSG_VERSION;
 	unsigned long flags;
+	int max_frags;
 	int rc;
 	struct sockaddr_in *peer_addr;
 
@@ -2332,22 +2331,20 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 		goto failed;
 	}
 
-	if (reqmsg->ibm_u.connparams.ibcp_max_frags >
-	    kiblnd_rdma_frags(version, ni)) {
-		CWARN("Can't accept conn from %s (version %x): max_frags %d too large (%d wanted)\n",
-		      libcfs_nid2str(nid), version,
-		      reqmsg->ibm_u.connparams.ibcp_max_frags,
+	max_frags = reqmsg->ibm_u.connparams.ibcp_max_frags >> IBLND_FRAG_SHIFT;
+	if (max_frags > kiblnd_rdma_frags(version, ni)) {
+		CWARN("Can't accept conn from %s (version %x): max message size %d is too large (%d wanted)\n",
+		      libcfs_nid2str(nid), version, max_frags,
 		      kiblnd_rdma_frags(version, ni));
 
 		if (version >= IBLND_MSG_VERSION)
 			rej.ibr_why = IBLND_REJECT_RDMA_FRAGS;
 
 		goto failed;
-	} else if (reqmsg->ibm_u.connparams.ibcp_max_frags <
-		   kiblnd_rdma_frags(version, ni) && !net->ibn_fmr_ps) {
-		CWARN("Can't accept conn from %s (version %x): max_frags %d incompatible without FMR pool (%d wanted)\n",
-		      libcfs_nid2str(nid), version,
-		      reqmsg->ibm_u.connparams.ibcp_max_frags,
+	} else if (max_frags < kiblnd_rdma_frags(version, ni) &&
+		   !net->ibn_fmr_ps) {
+		CWARN("Can't accept conn from %s (version %x): max message size %d incompatible without FMR pool (%d wanted)\n",
+		      libcfs_nid2str(nid), version, max_frags,
 		      kiblnd_rdma_frags(version, ni));
 
 		if (version == IBLND_MSG_VERSION)
@@ -2373,7 +2370,7 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 	}
 
 	/* We have validated the peer's parameters so use those */
-	peer->ibp_max_frags = reqmsg->ibm_u.connparams.ibcp_max_frags;
+	peer->ibp_max_frags = max_frags;
 	peer->ibp_queue_depth = reqmsg->ibm_u.connparams.ibcp_queue_depth;
 
 	write_lock_irqsave(g_lock, flags);
@@ -2494,7 +2491,7 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 	kiblnd_init_msg(ackmsg, IBLND_MSG_CONNACK,
 			sizeof(ackmsg->ibm_u.connparams));
 	ackmsg->ibm_u.connparams.ibcp_queue_depth = conn->ibc_queue_depth;
-	ackmsg->ibm_u.connparams.ibcp_max_frags = conn->ibc_max_frags;
+	ackmsg->ibm_u.connparams.ibcp_max_frags = conn->ibc_max_frags << IBLND_FRAG_SHIFT;
 	ackmsg->ibm_u.connparams.ibcp_max_msg_size = IBLND_MSG_SIZE;
 
 	kiblnd_pack_msg(ni, ackmsg, version, 0, nid, reqmsg->ibm_srcstamp);
@@ -2556,7 +2553,7 @@ kiblnd_check_reconnect(struct kib_conn *conn, int version,
 
 	if (cp) {
 		msg_size = cp->ibcp_max_msg_size;
-		frag_num = cp->ibcp_max_frags;
+		frag_num	= cp->ibcp_max_frags << IBLND_FRAG_SHIFT;
 		queue_dep = cp->ibcp_queue_depth;
 	}
 
@@ -2821,11 +2818,11 @@ kiblnd_check_connreply(struct kib_conn *conn, void *priv, int priv_nob)
 		goto failed;
 	}
 
-	if (msg->ibm_u.connparams.ibcp_max_frags >
+	if ((msg->ibm_u.connparams.ibcp_max_frags >> IBLND_FRAG_SHIFT) >
 	    conn->ibc_max_frags) {
 		CERROR("%s has incompatible max_frags %d (<=%d wanted)\n",
 		       libcfs_nid2str(peer->ibp_nid),
-		       msg->ibm_u.connparams.ibcp_max_frags,
+		       msg->ibm_u.connparams.ibcp_max_frags >> IBLND_FRAG_SHIFT,
 		       conn->ibc_max_frags);
 		rc = -EPROTO;
 		goto failed;
@@ -2859,7 +2856,7 @@ kiblnd_check_connreply(struct kib_conn *conn, void *priv, int priv_nob)
 	conn->ibc_credits = msg->ibm_u.connparams.ibcp_queue_depth;
 	conn->ibc_reserved_credits = msg->ibm_u.connparams.ibcp_queue_depth;
 	conn->ibc_queue_depth = msg->ibm_u.connparams.ibcp_queue_depth;
-	conn->ibc_max_frags = msg->ibm_u.connparams.ibcp_max_frags;
+	conn->ibc_max_frags = msg->ibm_u.connparams.ibcp_max_frags >> IBLND_FRAG_SHIFT;
 	LASSERT(conn->ibc_credits + conn->ibc_reserved_credits +
 		IBLND_OOB_MSGS(ver) <= IBLND_RX_MSGS(conn));
 
@@ -2916,7 +2913,7 @@ kiblnd_active_connect(struct rdma_cm_id *cmid)
 	memset(msg, 0, sizeof(*msg));
 	kiblnd_init_msg(msg, IBLND_MSG_CONNREQ, sizeof(msg->ibm_u.connparams));
 	msg->ibm_u.connparams.ibcp_queue_depth = conn->ibc_queue_depth;
-	msg->ibm_u.connparams.ibcp_max_frags = conn->ibc_max_frags;
+	msg->ibm_u.connparams.ibcp_max_frags = conn->ibc_max_frags << IBLND_FRAG_SHIFT;
 	msg->ibm_u.connparams.ibcp_max_msg_size = IBLND_MSG_SIZE;
 
 	kiblnd_pack_msg(peer->ibp_ni, msg, version,
-- 
2.7.4
