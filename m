From: James Simmons <jsimmons@infradead.org>
Date: Fri,  6 May 2016 21:30:25 -0400
Subject: [lustre-devel] [PATCH 04/10] staging: lustre: o2iblnd: convert
	macros to inline functions
In-Reply-To: <1462584631-5388-1-git-send-email-jsimmons@infradead.org>
References: <1462584631-5388-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1462584631-5388-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Amir Shehata <amir.shehata@intel.com>, James Simmons <uja.ornl@yahoo.com>, James Simmons <jsimmons@infradead.org>

From: Amir Shehata <amir.shehata@intel.com>

Convert a few macros in o2iblnd.h to inline functions.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7101
Reviewed-on: http://review.whamcloud.com/16367
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    2 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |   62 ++++++++++++--------
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |   21 ++++---
 .../lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c  |   11 ++++
 4 files changed, 61 insertions(+), 35 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index ddc3313..a2e188e 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -335,7 +335,7 @@ int kiblnd_create_peer(lnet_ni_t *ni, kib_peer_t **peerp, lnet_nid_t nid)
 	peer->ibp_nid = nid;
 	peer->ibp_error = 0;
 	peer->ibp_last_alive = 0;
-	peer->ibp_max_frags = IBLND_CFG_RDMA_FRAGS;
+	peer->ibp_max_frags = kiblnd_cfg_rdma_frags(peer->ibp_ni);
 	peer->ibp_queue_depth = *kiblnd_tunables.kib_peertxcredits;
 	atomic_set(&peer->ibp_refcount, 1);  /* 1 ref for caller */
 
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 52245e0..fab0ef9 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -116,9 +116,6 @@ extern kib_tunables_t  kiblnd_tunables;
 #define IBLND_CREDITS_DEFAULT     8 /* default # of peer credits */
 #define IBLND_CREDITS_MAX	  ((typeof(((kib_msg_t *) 0)->ibm_credits)) - 1)  /* Max # of peer credits */
 
-#define IBLND_MSG_QUEUE_SIZE(v)    ((v) == IBLND_MSG_VERSION_1 ? \
-				     IBLND_MSG_QUEUE_SIZE_V1 :   \
-				     *kiblnd_tunables.kib_peertxcredits) /* # messages/RDMAs in-flight */
 #define IBLND_CREDITS_HIGHWATER(v) ((v) == IBLND_MSG_VERSION_1 ? \
 				     IBLND_CREDIT_HIGHWATER_V1 : \
 				     *kiblnd_tunables.kib_peercredits_hiw) /* when eagerly to return credits */
@@ -127,32 +124,12 @@ extern kib_tunables_t  kiblnd_tunables;
 							       cb, dev, \
 							       ps, qpt)
 
-static inline int
-kiblnd_concurrent_sends_v1(void)
-{
-	if (*kiblnd_tunables.kib_concurrent_sends > IBLND_MSG_QUEUE_SIZE_V1 * 2)
-		return IBLND_MSG_QUEUE_SIZE_V1 * 2;
-
-	if (*kiblnd_tunables.kib_concurrent_sends < IBLND_MSG_QUEUE_SIZE_V1 / 2)
-		return IBLND_MSG_QUEUE_SIZE_V1 / 2;
-
-	return *kiblnd_tunables.kib_concurrent_sends;
-}
-
-#define IBLND_CONCURRENT_SENDS(v)  ((v) == IBLND_MSG_VERSION_1 ? \
-				     kiblnd_concurrent_sends_v1() : \
-				     *kiblnd_tunables.kib_concurrent_sends)
 /* 2 OOB shall suffice for 1 keepalive and 1 returning credits */
 #define IBLND_OOB_CAPABLE(v)       ((v) != IBLND_MSG_VERSION_1)
 #define IBLND_OOB_MSGS(v)	   (IBLND_OOB_CAPABLE(v) ? 2 : 0)
 
 #define IBLND_MSG_SIZE		(4 << 10)	 /* max size of queued messages (inc hdr) */
 #define IBLND_MAX_RDMA_FRAGS	 LNET_MAX_IOV	   /* max # of fragments supported */
-#define IBLND_CFG_RDMA_FRAGS       (*kiblnd_tunables.kib_map_on_demand ? \
-				    *kiblnd_tunables.kib_map_on_demand :      \
-				     IBLND_MAX_RDMA_FRAGS)  /* max # of fragments configured by user */
-#define IBLND_RDMA_FRAGS(v)	((v) == IBLND_MSG_VERSION_1 ? \
-				     IBLND_MAX_RDMA_FRAGS : IBLND_CFG_RDMA_FRAGS)
 
 /************************/
 /* derived constants... */
@@ -171,7 +148,8 @@ kiblnd_concurrent_sends_v1(void)
 /* WRs and CQEs (per connection) */
 #define IBLND_RECV_WRS(c)	IBLND_RX_MSGS(c)
 #define IBLND_SEND_WRS(c)	\
-	((c->ibc_max_frags + 1) * IBLND_CONCURRENT_SENDS(c->ibc_version))
+	((c->ibc_max_frags + 1) * kiblnd_concurrent_sends(c->ibc_version, \
+							  c->ibc_peer->ibp_ni))
 #define IBLND_CQ_ENTRIES(c)	(IBLND_RECV_WRS(c) + IBLND_SEND_WRS(c))
 
 struct kib_hca_dev;
@@ -634,6 +612,42 @@ extern kib_data_t kiblnd_data;
 
 void kiblnd_hdev_destroy(kib_hca_dev_t *hdev);
 
+int kiblnd_msg_queue_size(int version, struct lnet_ni *ni);
+
+/* max # of fragments configured by user */
+static inline int
+kiblnd_cfg_rdma_frags(struct lnet_ni *ni)
+{
+	int mod = *kiblnd_tunables.kib_map_on_demand;
+	return mod ? mod : IBLND_MAX_RDMA_FRAGS;
+}
+
+static inline int
+kiblnd_rdma_frags(int version, struct lnet_ni *ni)
+{
+	return version == IBLND_MSG_VERSION_1 ?
+			  IBLND_MAX_RDMA_FRAGS :
+			  kiblnd_cfg_rdma_frags(ni);
+}
+
+static inline int
+kiblnd_concurrent_sends(int version, struct lnet_ni *ni)
+{
+	int concurrent_sends;
+
+	concurrent_sends = *kiblnd_tunables.kib_concurrent_sends;
+
+	if (version == IBLND_MSG_VERSION_1) {
+		if (concurrent_sends > IBLND_MSG_QUEUE_SIZE_V1 * 2)
+			return IBLND_MSG_QUEUE_SIZE_V1 * 2;
+
+		if (concurrent_sends < IBLND_MSG_QUEUE_SIZE_V1 / 2)
+			return IBLND_MSG_QUEUE_SIZE_V1 / 2;
+	}
+
+	return concurrent_sends;
+}
+
 static inline void
 kiblnd_hdev_addref_locked(kib_hca_dev_t *hdev)
 {
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 8bbd116..c3bd7fa 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -757,6 +757,7 @@ kiblnd_post_tx_locked(kib_conn_t *conn, kib_tx_t *tx, int credit)
 {
 	kib_msg_t *msg = tx->tx_msg;
 	kib_peer_t *peer = conn->ibc_peer;
+	struct lnet_ni *ni = peer->ibp_ni;
 	int ver = conn->ibc_version;
 	int rc;
 	int done;
@@ -772,7 +773,7 @@ kiblnd_post_tx_locked(kib_conn_t *conn, kib_tx_t *tx, int credit)
 	LASSERT(conn->ibc_credits >= 0);
 	LASSERT(conn->ibc_credits <= conn->ibc_queue_depth);
 
-	if (conn->ibc_nsends_posted == IBLND_CONCURRENT_SENDS(ver)) {
+	if (conn->ibc_nsends_posted == kiblnd_concurrent_sends(ver, ni)) {
 		/* tx completions outstanding... */
 		CDEBUG(D_NET, "%s: posted enough\n",
 		       libcfs_nid2str(peer->ibp_nid));
@@ -923,7 +924,7 @@ kiblnd_check_sends(kib_conn_t *conn)
 
 	spin_lock(&conn->ibc_lock);
 
-	LASSERT(conn->ibc_nsends_posted <= IBLND_CONCURRENT_SENDS(ver));
+	LASSERT(conn->ibc_nsends_posted <= kiblnd_concurrent_sends(ver, ni));
 	LASSERT(!IBLND_OOB_CAPABLE(ver) ||
 		conn->ibc_noops_posted <= IBLND_OOB_MSGS(ver));
 	LASSERT(conn->ibc_reserved_credits >= 0);
@@ -2337,11 +2338,11 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 	}
 
 	if (reqmsg->ibm_u.connparams.ibcp_queue_depth >
-	    IBLND_MSG_QUEUE_SIZE(version)) {
+	    kiblnd_msg_queue_size(version, ni)) {
 		CERROR("Can't accept conn from %s, queue depth too large: %d (<=%d wanted)\n",
 		       libcfs_nid2str(nid),
 		       reqmsg->ibm_u.connparams.ibcp_queue_depth,
-		       IBLND_MSG_QUEUE_SIZE(version));
+		       kiblnd_msg_queue_size(version, ni));
 
 		if (version == IBLND_MSG_VERSION)
 			rej.ibr_why = IBLND_REJECT_MSG_QUEUE_SIZE;
@@ -2350,22 +2351,22 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 	}
 
 	if (reqmsg->ibm_u.connparams.ibcp_max_frags >
-	    IBLND_RDMA_FRAGS(version)) {
+	    kiblnd_rdma_frags(version, ni)) {
 		CWARN("Can't accept conn from %s (version %x): max_frags %d too large (%d wanted)\n",
 		      libcfs_nid2str(nid), version,
 		      reqmsg->ibm_u.connparams.ibcp_max_frags,
-		      IBLND_RDMA_FRAGS(version));
+		      kiblnd_rdma_frags(version, ni));
 
 		if (version >= IBLND_MSG_VERSION)
 			rej.ibr_why = IBLND_REJECT_RDMA_FRAGS;
 
 		goto failed;
 	} else if (reqmsg->ibm_u.connparams.ibcp_max_frags <
-		   IBLND_RDMA_FRAGS(version) && !net->ibn_fmr_ps) {
+		   kiblnd_rdma_frags(version, ni) && !net->ibn_fmr_ps) {
 		CWARN("Can't accept conn from %s (version %x): max_frags %d incompatible without FMR pool (%d wanted)\n",
 		      libcfs_nid2str(nid), version,
 		      reqmsg->ibm_u.connparams.ibcp_max_frags,
-		      IBLND_RDMA_FRAGS(version));
+		      kiblnd_rdma_frags(version, ni));
 
 		if (version >= IBLND_MSG_VERSION)
 			rej.ibr_why = IBLND_REJECT_RDMA_FRAGS;
@@ -2532,8 +2533,8 @@ kiblnd_passive_connect(struct rdma_cm_id *cmid, void *priv, int priv_nob)
 		lnet_ni_decref(ni);
 
 	rej.ibr_version             = version;
-	rej.ibr_cp.ibcp_queue_depth = IBLND_MSG_QUEUE_SIZE(version);
-	rej.ibr_cp.ibcp_max_frags   = IBLND_RDMA_FRAGS(version);
+	rej.ibr_cp.ibcp_queue_depth = kiblnd_msg_queue_size(version, ni);
+	rej.ibr_cp.ibcp_max_frags = kiblnd_rdma_frags(version, ni);
 	kiblnd_reject(cmid, &rej);
 
 	return -ECONNREFUSED;
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
index b4607da..a6415fc 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
@@ -171,6 +171,17 @@ kib_tunables_t kiblnd_tunables = {
 	.kib_nscheds           = &nscheds
 };
 
+/* # messages/RDMAs in-flight */
+int kiblnd_msg_queue_size(int version, lnet_ni_t *ni)
+{
+	if (version == IBLND_MSG_VERSION_1)
+		return IBLND_MSG_QUEUE_SIZE_V1;
+	else if (ni)
+		return ni->ni_peertxcredits;
+	else
+		return peer_credits;
+}
+
 int
 kiblnd_tunables_init(void)
 {
-- 
1.7.1
