From: James Simmons <jsimmons@infradead.org>
Date: Sun, 26 Feb 2017 19:41:59 -0500
Subject: [lustre-devel] [PATCH 34/34] staging: lustre: lnet: use struct
	bio_vec instead of typedef
In-Reply-To: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
References: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1488156119-19670-35-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Kill off lnet_kiov_t and use struct bio_vec directly.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
---
 drivers/staging/lustre/include/linux/lnet/lib-lnet.h    |  8 ++++----
 drivers/staging/lustre/include/linux/lnet/lib-types.h   |  6 +++---
 drivers/staging/lustre/include/linux/lnet/types.h       |  7 +++----
 drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c  |  6 +++---
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h     | 12 ++++++------
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c  |  6 +++---
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c |  4 ++--
 drivers/staging/lustre/lnet/lnet/lib-move.c             | 10 +++++-----
 drivers/staging/lustre/lnet/selftest/conrpc.c           |  4 ++--
 drivers/staging/lustre/lnet/selftest/selftest.h         |  2 +-
 10 files changed, 32 insertions(+), 33 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index dce09fe..8ae7423 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -612,16 +612,16 @@ int lnet_extract_iov(int dst_niov, struct kvec *dst,
 		     int src_niov, const struct kvec *src,
 		      unsigned int offset, unsigned int len);
 
-unsigned int lnet_kiov_nob(unsigned int niov, lnet_kiov_t *iov);
-int lnet_extract_kiov(int dst_niov, lnet_kiov_t *dst,
-		      int src_niov, const lnet_kiov_t *src,
+unsigned int lnet_kiov_nob(unsigned int niov, struct bio_vec *iov);
+int lnet_extract_kiov(int dst_niov, struct bio_vec *dst,
+		      int src_niov, const struct bio_vec *src,
 		      unsigned int offset, unsigned int len);
 
 void lnet_copy_iov2iter(struct iov_iter *to,
 			unsigned int nsiov, const struct kvec *siov,
 			unsigned int soffset, unsigned int nob);
 void lnet_copy_kiov2iter(struct iov_iter *to,
-			 unsigned int nkiov, const lnet_kiov_t *kiov,
+			 unsigned int nkiov, const struct bio_vec *kiov,
 			 unsigned int kiovoffset, unsigned int nob);
 
 void lnet_me_unlink(struct lnet_me *me);
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 69c11c1..321752d 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -102,7 +102,7 @@ struct lnet_msg {
 	unsigned int		 msg_offset;
 	unsigned int		 msg_niov;
 	struct kvec		*msg_iov;
-	lnet_kiov_t		*msg_kiov;
+	struct bio_vec		*msg_kiov;
 
 	struct lnet_event	 msg_ev;
 	struct lnet_hdr		 msg_hdr;
@@ -156,7 +156,7 @@ struct lnet_libmd {
 	unsigned int		 md_niov;	/* # frags */
 	union {
 		struct kvec	iov[LNET_MAX_IOV];
-		lnet_kiov_t	kiov[LNET_MAX_IOV];
+		struct bio_vec	kiov[LNET_MAX_IOV];
 	} md_iov;
 };
 
@@ -413,7 +413,7 @@ struct lnet_rtrbufpool {
 struct lnet_rtrbuf {
 	struct list_head	 rb_list;	/* chain on rbp_bufs */
 	struct lnet_rtrbufpool	*rb_pool;	/* owning pool */
-	lnet_kiov_t		 rb_kiov[0];	/* the buffer space */
+	struct bio_vec		 rb_kiov[0];	/* the buffer space */
 };
 
 #define LNET_PEER_HASHSIZE	503	/* prime! */
diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/linux/lnet/types.h
index 44cee82..1be9b7a 100644
--- a/drivers/staging/lustre/include/linux/lnet/types.h
+++ b/drivers/staging/lustre/include/linux/lnet/types.h
@@ -382,9 +382,9 @@ struct lnet_md {
 	 * Specify the memory region associated with the memory descriptor.
 	 * If the options field has:
 	 * - LNET_MD_KIOV bit set: The start field points to the starting
-	 * address of an array of lnet_kiov_t and the length field specifies
+	 * address of an array of struct bio_vec and the length field specifies
 	 * the number of entries in the array. The length can't be bigger
-	 * than LNET_MAX_IOV. The lnet_kiov_t is used to describe page-based
+	 * than LNET_MAX_IOV. The struct bio_vec is used to describe page-based
 	 * fragments that are not necessarily mapped in virtual memory.
 	 * - LNET_MD_IOVEC bit set: The start field points to the starting
 	 * address of an array of struct iovec and the length field specifies
@@ -444,7 +444,7 @@ struct lnet_md {
 	 *   acknowledgment. Acknowledgments are never sent for GET operations.
 	 *   The data sent in the REPLY serves as an implicit acknowledgment.
 	 * - LNET_MD_KIOV: The start and length fields specify an array of
-	 *   lnet_kiov_t.
+	 *   struct bio_vec.
 	 * - LNET_MD_IOVEC: The start and length fields specify an array of
 	 *   struct iovec.
 	 * - LNET_MD_MAX_SIZE: The max_size field is valid.
@@ -510,7 +510,6 @@ struct lnet_md {
 /** Infinite threshold on MD operations. See lnet_md::threshold */
 #define LNET_MD_THRESH_INF	(-1)
 
-typedef struct bio_vec lnet_kiov_t;
 /** @} lnet_md */
 
 /** \addtogroup lnet_eq
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index e850f4c..4a519c4 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -699,7 +699,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 static int
 kiblnd_setup_rd_kiov(struct lnet_ni *ni, struct kib_tx *tx,
 		     struct kib_rdma_desc *rd, int nkiov,
-		     const lnet_kiov_t *kiov, int offset, int nob)
+		     const struct bio_vec *kiov, int offset, int nob)
 {
 	struct kib_net *net = ni->ni_data;
 	struct scatterlist *sg;
@@ -1487,7 +1487,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	int routing = lntmsg->msg_routing;
 	unsigned int payload_niov = lntmsg->msg_niov;
 	struct kvec *payload_iov = lntmsg->msg_iov;
-	lnet_kiov_t *payload_kiov = lntmsg->msg_kiov;
+	struct bio_vec *payload_kiov = lntmsg->msg_kiov;
 	unsigned int payload_offset = lntmsg->msg_offset;
 	unsigned int payload_nob = lntmsg->msg_len;
 	struct iov_iter from;
@@ -1656,7 +1656,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	struct lnet_process_id target = lntmsg->msg_target;
 	unsigned int niov = lntmsg->msg_niov;
 	struct kvec *iov = lntmsg->msg_iov;
-	lnet_kiov_t *kiov = lntmsg->msg_kiov;
+	struct bio_vec *kiov = lntmsg->msg_kiov;
 	unsigned int offset = lntmsg->msg_offset;
 	unsigned int nob = lntmsg->msg_len;
 	struct kib_tx *tx;
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index 3f48b60..5540de6 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -256,11 +256,11 @@ struct ksock_nal_data {
 /*
  * A packet just assembled for transmission is represented by 1 or more
  * struct iovec fragments (the first frag contains the portals header),
- * followed by 0 or more lnet_kiov_t fragments.
+ * followed by 0 or more struct bio_vec fragments.
  *
  * On the receive side, initially 1 struct iovec fragment is posted for
  * receive (the header).  Once the header has been received, the payload is
- * received into either struct iovec or lnet_kiov_t fragments, depending on
+ * received into either struct iovec or struct bio_vec fragments, depending on
  * what the header matched or whether the message needs forwarding.
  */
 struct ksock_conn;  /* forward ref */
@@ -282,7 +282,7 @@ struct ksock_tx {			   /* transmit packet */
 	unsigned short    tx_zc_capable:1; /* payload is large enough for ZC */
 	unsigned short    tx_zc_checked:1; /* Have I checked if I should ZC? */
 	unsigned short    tx_nonblk:1;     /* it's a non-blocking ACK */
-	lnet_kiov_t       *tx_kiov;        /* packet page frags */
+	struct bio_vec	  *tx_kiov;	   /* packet page frags */
 	struct ksock_conn *tx_conn;        /* owning conn */
 	struct lnet_msg        *tx_lnetmsg;     /* lnet message for lnet_finalize()
 					    */
@@ -292,7 +292,7 @@ struct ksock_tx {			   /* transmit packet */
 	union {
 		struct {
 			struct kvec iov;     /* virt hdr */
-			lnet_kiov_t kiov[0]; /* paged payload */
+			struct bio_vec kiov[0]; /* paged payload */
 		} paged;
 		struct {
 			struct kvec iov[1];  /* virt hdr + payload */
@@ -310,7 +310,7 @@ struct ksock_tx {			   /* transmit packet */
  */
 union ksock_rxiovspace {
 	struct kvec      iov[LNET_MAX_IOV];
-	lnet_kiov_t      kiov[LNET_MAX_IOV];
+	struct bio_vec	kiov[LNET_MAX_IOV];
 };
 
 #define SOCKNAL_RX_KSM_HEADER   1 /* reading ksock message header */
@@ -362,7 +362,7 @@ struct ksock_conn {
 	int                ksnc_rx_niov;      /* # iovec frags */
 	struct kvec        *ksnc_rx_iov;      /* the iovec frags */
 	int                ksnc_rx_nkiov;     /* # page frags */
-	lnet_kiov_t        *ksnc_rx_kiov;     /* the page frags */
+	struct bio_vec		*ksnc_rx_kiov;	/* the page frags */
 	union ksock_rxiovspace ksnc_rx_iov_space; /* space for frag descriptors */
 	__u32              ksnc_rx_csum;      /* partial checksum for incoming
 					       * data
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index 695b586..eaa4399 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -145,7 +145,7 @@ struct ksock_tx *
 static int
 ksocknal_send_kiov(struct ksock_conn *conn, struct ksock_tx *tx)
 {
-	lnet_kiov_t *kiov = tx->tx_kiov;
+	struct bio_vec *kiov = tx->tx_kiov;
 	int nob;
 	int rc;
 
@@ -298,7 +298,7 @@ struct ksock_tx *
 static int
 ksocknal_recv_kiov(struct ksock_conn *conn)
 {
-	lnet_kiov_t *kiov = conn->ksnc_rx_kiov;
+	struct bio_vec *kiov = conn->ksnc_rx_kiov;
 	int nob;
 	int rc;
 
@@ -946,7 +946,7 @@ struct ksock_route *
 	struct lnet_process_id target = lntmsg->msg_target;
 	unsigned int payload_niov = lntmsg->msg_niov;
 	struct kvec *payload_iov = lntmsg->msg_iov;
-	lnet_kiov_t *payload_kiov = lntmsg->msg_kiov;
+	struct bio_vec *payload_kiov = lntmsg->msg_kiov;
 	unsigned int payload_offset = lntmsg->msg_offset;
 	unsigned int payload_nob = lntmsg->msg_len;
 	struct ksock_tx *tx;
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
index 4bcab4b..8a036f4 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
@@ -99,7 +99,7 @@
 ksocknal_lib_send_kiov(struct ksock_conn *conn, struct ksock_tx *tx)
 {
 	struct socket *sock = conn->ksnc_sock;
-	lnet_kiov_t *kiov = tx->tx_kiov;
+	struct bio_vec *kiov = tx->tx_kiov;
 	int rc;
 	int nob;
 
@@ -215,7 +215,7 @@
 ksocknal_lib_recv_kiov(struct ksock_conn *conn)
 {
 	unsigned int niov = conn->ksnc_rx_nkiov;
-	lnet_kiov_t   *kiov = conn->ksnc_rx_kiov;
+	struct bio_vec *kiov = conn->ksnc_rx_kiov;
 	struct msghdr msg = {
 		.msg_flags = 0
 	};
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 48e1f5b..a99c5c0 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -212,7 +212,7 @@
 
 void
 lnet_copy_kiov2iter(struct iov_iter *to,
-		    unsigned int nsiov, const lnet_kiov_t *siov,
+		    unsigned int nsiov, const struct bio_vec *siov,
 		    unsigned int soffset, unsigned int nob)
 {
 	if (!nob)
@@ -298,7 +298,7 @@
 EXPORT_SYMBOL(lnet_extract_iov);
 
 unsigned int
-lnet_kiov_nob(unsigned int niov, lnet_kiov_t *kiov)
+lnet_kiov_nob(unsigned int niov, struct bio_vec *kiov)
 {
 	unsigned int nob = 0;
 
@@ -311,8 +311,8 @@
 EXPORT_SYMBOL(lnet_kiov_nob);
 
 int
-lnet_extract_kiov(int dst_niov, lnet_kiov_t *dst,
-		  int src_niov, const lnet_kiov_t *src,
+lnet_extract_kiov(int dst_niov, struct bio_vec *dst,
+		  int src_niov, const struct bio_vec *src,
 		  unsigned int offset, unsigned int len)
 {
 	/*
@@ -370,7 +370,7 @@
 {
 	unsigned int niov = 0;
 	struct kvec *iov = NULL;
-	lnet_kiov_t *kiov = NULL;
+	struct bio_vec *kiov = NULL;
 	struct iov_iter to;
 	int rc;
 
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index 7985b09..da36c55 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -699,7 +699,7 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 }
 
 static struct lnet_process_id_packed *
-lstcon_next_id(int idx, int nkiov, lnet_kiov_t *kiov)
+lstcon_next_id(int idx, int nkiov, struct bio_vec *kiov)
 {
 	struct lnet_process_id_packed *pid;
 	int i;
@@ -715,7 +715,7 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 
 static int
 lstcon_dstnodes_prep(struct lstcon_group *grp, int idx,
-		     int dist, int span, int nkiov, lnet_kiov_t *kiov)
+		     int dist, int span, int nkiov, struct bio_vec *kiov)
 {
 	struct lnet_process_id_packed *pid;
 	struct lstcon_ndlink *ndl;
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 3c68cf3..b614e6f 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -156,7 +156,7 @@ struct srpc_bulk {
 	struct lnet_handle_md	bk_mdh;
 	int		 bk_sink;    /* sink/source */
 	int		 bk_niov;    /* # iov in bk_iovs */
-	lnet_kiov_t	 bk_iovs[0];
+	struct bio_vec		bk_iovs[0];
 };
 
 /* message buffer descriptor */
-- 
1.8.3.1
