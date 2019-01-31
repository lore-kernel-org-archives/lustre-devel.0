From: James Simmons <jsimmons@infradead.org>
Date: Thu, 31 Jan 2019 12:19:06 -0500
Subject: [lustre-devel] [PATCH 02/26] lnet: use kernel types for lnet klnd
 kernel code
In-Reply-To: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
References: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1548955170-13456-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

LNet klnd drivers was originally both a user land and kernel
implementation. The source contains many types of the
form __u32 but since this is mostly kernel code change
the types to kernel internal types.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |  30 ++---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    | 126 ++++++++++-----------
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |  22 ++--
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |  54 ++++-----
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |  44 +++----
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |   8 +-
 .../lustre/lnet/klnds/socklnd/socklnd_lib.c        |   4 +-
 .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |  24 ++--
 8 files changed, 156 insertions(+), 156 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index bd7ff7d..1a6bc45 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -44,10 +44,10 @@
 
 struct kib_data kiblnd_data;
 
-static __u32 kiblnd_cksum(void *ptr, int nob)
+static u32 kiblnd_cksum(void *ptr, int nob)
 {
 	char *c = ptr;
-	__u32 sum = 0;
+	u32 sum = 0;
 
 	while (nob-- > 0)
 		sum = ((sum << 1) | (sum >> 31)) + *c++;
@@ -175,7 +175,7 @@ static int kiblnd_unpack_rd(struct kib_msg *msg, int flip)
 }
 
 void kiblnd_pack_msg(struct lnet_ni *ni, struct kib_msg *msg, int version,
-		     int credits, lnet_nid_t dstnid, __u64 dststamp)
+		     int credits, lnet_nid_t dstnid, u64 dststamp)
 {
 	struct kib_net *net = ni->ni_data;
 
@@ -203,8 +203,8 @@ void kiblnd_pack_msg(struct lnet_ni *ni, struct kib_msg *msg, int version,
 int kiblnd_unpack_msg(struct kib_msg *msg, int nob)
 {
 	const int hdr_size = offsetof(struct kib_msg, ibm_u);
-	__u32 msg_cksum;
-	__u16 version;
+	u32 msg_cksum;
+	u16 version;
 	int msg_nob;
 	int flip;
 
@@ -994,7 +994,7 @@ int kiblnd_close_peer_conns_locked(struct kib_peer_ni *peer_ni, int why)
 }
 
 int kiblnd_close_stale_conns_locked(struct kib_peer_ni *peer_ni,
-				    int version, __u64 incarnation)
+				    int version, u64 incarnation)
 {
 	struct kib_conn *conn;
 	struct list_head *ctmp;
@@ -1240,7 +1240,7 @@ void kiblnd_map_rx_descs(struct kib_conn *conn)
 
 		CDEBUG(D_NET, "rx %d: %p %#llx(%#llx)\n",
 		       i, rx->rx_msg, rx->rx_msgaddr,
-		       (__u64)(page_to_phys(pg) + pg_off));
+		       (u64)(page_to_phys(pg) + pg_off));
 
 		pg_off += IBLND_MSG_SIZE;
 		LASSERT(pg_off <= PAGE_SIZE);
@@ -1610,7 +1610,7 @@ static int kiblnd_fmr_pool_is_idle(struct kib_fmr_pool *fpo, time64_t now)
 static int
 kiblnd_map_tx_pages(struct kib_tx *tx, struct kib_rdma_desc *rd)
 {
-	__u64 *pages = tx->tx_pages;
+	u64 *pages = tx->tx_pages;
 	struct kib_hca_dev *hdev;
 	int npages;
 	int size;
@@ -1685,15 +1685,15 @@ void kiblnd_fmr_pool_unmap(struct kib_fmr *fmr, int status)
 }
 
 int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
-			struct kib_rdma_desc *rd, __u32 nob, __u64 iov,
+			struct kib_rdma_desc *rd, u32 nob, u64 iov,
 			struct kib_fmr *fmr)
 {
-	__u64 *pages = tx->tx_pages;
+	u64 *pages = tx->tx_pages;
 	bool is_rx = (rd != tx->tx_rd);
 	bool tx_pages_mapped = false;
 	struct kib_fmr_pool *fpo;
 	int npages = 0;
-	__u64 version;
+	u64 version;
 	int rc;
 
  again:
@@ -1740,7 +1740,7 @@ int kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
 				mr = frd->frd_mr;
 
 				if (!frd->frd_valid) {
-					__u32 key = is_rx ? mr->rkey : mr->lkey;
+					u32 key = is_rx ? mr->rkey : mr->lkey;
 					struct ib_send_wr *inv_wr;
 
 					inv_wr = &frd->frd_inv_wr;
@@ -2204,7 +2204,7 @@ static void kiblnd_net_fini_pools(struct kib_net *net)
 }
 
 static int kiblnd_net_init_pools(struct kib_net *net, struct lnet_ni *ni,
-				 __u32 *cpts, int ncpts)
+				 u32 *cpts, int ncpts)
 {
 	struct lnet_ioctl_config_o2iblnd_tunables *tunables;
 	int cpt;
@@ -2303,7 +2303,7 @@ static int kiblnd_hdev_get_attr(struct kib_hca_dev *hdev)
 	 */
 	hdev->ibh_page_shift = PAGE_SHIFT;
 	hdev->ibh_page_size  = 1 << PAGE_SHIFT;
-	hdev->ibh_page_mask  = ~((__u64)hdev->ibh_page_size - 1);
+	hdev->ibh_page_mask  = ~((u64)hdev->ibh_page_size - 1);
 
 	if (hdev->ibh_ibdev->ops.alloc_fmr &&
 	    hdev->ibh_ibdev->ops.dealloc_fmr &&
@@ -2878,7 +2878,7 @@ static int kiblnd_start_schedulers(struct kib_sched_info *sched)
 	return rc;
 }
 
-static int kiblnd_dev_start_threads(struct kib_dev *dev, int newdev, __u32 *cpts,
+static int kiblnd_dev_start_threads(struct kib_dev *dev, int newdev, u32 *cpts,
 				    int ncpts)
 {
 	int cpt;
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 2ddd83b..423bae7 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -157,7 +157,7 @@ enum kib_dev_caps {
 struct kib_dev {
 	struct list_head   ibd_list;            /* chain on kib_devs */
 	struct list_head   ibd_fail_list;       /* chain on kib_failed_devs */
-	__u32              ibd_ifip;            /* IPoIB interface IP */
+	u32              ibd_ifip;            /* IPoIB interface IP */
 
 	/* IPoIB interface name */
 	char               ibd_ifname[KIB_IFNAME_SIZE];
@@ -177,9 +177,9 @@ struct kib_hca_dev {
 	struct ib_device   *ibh_ibdev;          /* IB device */
 	int                ibh_page_shift;      /* page shift of current HCA */
 	int                ibh_page_size;       /* page size of current HCA */
-	__u64              ibh_page_mask;       /* page mask of current HCA */
+	u64              ibh_page_mask;       /* page mask of current HCA */
 	int                ibh_mr_shift;        /* bits shift of max MR size */
-	__u64              ibh_mr_size;         /* size of MR */
+	u64              ibh_mr_size;         /* size of MR */
 	struct ib_pd       *ibh_pd;             /* PD */
 	struct kib_dev	   *ibh_dev;		/* owner */
 	atomic_t           ibh_ref;             /* refcount */
@@ -238,7 +238,7 @@ struct kib_pool {
 
 struct kib_tx_poolset {
 	struct kib_poolset	tps_poolset;		/* pool-set */
-	__u64                 tps_next_tx_cookie; /* cookie of TX */
+	u64                 tps_next_tx_cookie; /* cookie of TX */
 };
 
 struct kib_tx_pool {
@@ -253,7 +253,7 @@ struct kib_fmr_poolset {
 	struct kib_net        *fps_net;            /* IB network */
 	struct list_head      fps_pool_list;       /* FMR pool list */
 	struct list_head      fps_failed_pool_list;/* FMR pool list */
-	__u64                 fps_version;         /* validity stamp */
+	u64                 fps_version;         /* validity stamp */
 	int                   fps_cpt;             /* CPT id */
 	int                   fps_pool_size;
 	int                   fps_flush_trigger;
@@ -299,7 +299,7 @@ struct kib_fmr {
 
 struct kib_net {
 	struct list_head      ibn_list;       /* chain on struct kib_dev::ibd_nets */
-	__u64                 ibn_incarnation;/* my epoch */
+	u64                 ibn_incarnation;/* my epoch */
 	int                   ibn_init;       /* initialisation state */
 	int                   ibn_shutdown;   /* shutting down? */
 
@@ -365,9 +365,9 @@ struct kib_data {
  */
 
 struct kib_connparams {
-	__u16        ibcp_queue_depth;
-	__u16        ibcp_max_frags;
-	__u32        ibcp_max_msg_size;
+	u16        ibcp_queue_depth;
+	u16        ibcp_max_frags;
+	u32        ibcp_max_msg_size;
 } __packed;
 
 struct kib_immediate_msg {
@@ -376,51 +376,51 @@ struct kib_immediate_msg {
 } __packed;
 
 struct kib_rdma_frag {
-	__u32        rf_nob;          /* # bytes this frag */
-	__u64        rf_addr;         /* CAVEAT EMPTOR: misaligned!! */
+	u32        rf_nob;          /* # bytes this frag */
+	u64        rf_addr;         /* CAVEAT EMPTOR: misaligned!! */
 } __packed;
 
 struct kib_rdma_desc {
-	__u32           rd_key;       /* local/remote key */
-	__u32           rd_nfrags;    /* # fragments */
+	u32           rd_key;       /* local/remote key */
+	u32           rd_nfrags;    /* # fragments */
 	struct kib_rdma_frag	rd_frags[0];	/* buffer frags */
 } __packed;
 
 struct kib_putreq_msg {
 	struct lnet_hdr	ibprm_hdr;    /* portals header */
-	__u64           ibprm_cookie; /* opaque completion cookie */
+	u64           ibprm_cookie; /* opaque completion cookie */
 } __packed;
 
 struct kib_putack_msg {
-	__u64           ibpam_src_cookie; /* reflected completion cookie */
-	__u64           ibpam_dst_cookie; /* opaque completion cookie */
+	u64           ibpam_src_cookie; /* reflected completion cookie */
+	u64           ibpam_dst_cookie; /* opaque completion cookie */
 	struct kib_rdma_desc ibpam_rd;         /* sender's sink buffer */
 } __packed;
 
 struct kib_get_msg {
 	struct lnet_hdr ibgm_hdr;     /* portals header */
-	__u64           ibgm_cookie;  /* opaque completion cookie */
+	u64           ibgm_cookie;  /* opaque completion cookie */
 	struct kib_rdma_desc ibgm_rd;      /* rdma descriptor */
 } __packed;
 
 struct kib_completion_msg {
-	__u64           ibcm_cookie;  /* opaque completion cookie */
-	__s32           ibcm_status;  /* < 0 failure: >= 0 length */
+	u64           ibcm_cookie;  /* opaque completion cookie */
+	s32           ibcm_status;  /* < 0 failure: >= 0 length */
 } __packed;
 
 struct kib_msg {
 	/* First 2 fields fixed FOR ALL TIME */
-	__u32           ibm_magic;    /* I'm an ibnal message */
-	__u16           ibm_version;  /* this is my version number */
-
-	__u8            ibm_type;     /* msg type */
-	__u8            ibm_credits;  /* returned credits */
-	__u32           ibm_nob;      /* # bytes in whole message */
-	__u32           ibm_cksum;    /* checksum (0 == no checksum) */
-	__u64           ibm_srcnid;   /* sender's NID */
-	__u64           ibm_srcstamp; /* sender's incarnation */
-	__u64           ibm_dstnid;   /* destination's NID */
-	__u64           ibm_dststamp; /* destination's incarnation */
+	u32           ibm_magic;    /* I'm an ibnal message */
+	u16           ibm_version;  /* this is my version number */
+
+	u8            ibm_type;     /* msg type */
+	u8            ibm_credits;  /* returned credits */
+	u32           ibm_nob;      /* # bytes in whole message */
+	u32           ibm_cksum;    /* checksum (0 == no checksum) */
+	u64           ibm_srcnid;   /* sender's NID */
+	u64           ibm_srcstamp; /* sender's incarnation */
+	u64           ibm_dstnid;   /* destination's NID */
+	u64           ibm_dststamp; /* destination's incarnation */
 
 	union {
 		struct kib_connparams		connparams;
@@ -450,11 +450,11 @@ struct kib_msg {
 #define IBLND_MSG_GET_DONE  0xd7	/* completion (src->sink: all OK) */
 
 struct kib_rej {
-	__u32            ibr_magic;       /* sender's magic */
-	__u16            ibr_version;     /* sender's version */
-	__u8             ibr_why;         /* reject reason */
-	__u8             ibr_padding;     /* padding */
-	__u64            ibr_incarnation; /* incarnation of peer_ni */
+	u32            ibr_magic;       /* sender's magic */
+	u16            ibr_version;     /* sender's version */
+	u8             ibr_why;         /* reject reason */
+	u8             ibr_padding;     /* padding */
+	u64            ibr_incarnation; /* incarnation of peer_ni */
 	struct kib_connparams ibr_cp;          /* connection parameters */
 } __packed;
 
@@ -478,7 +478,7 @@ struct kib_rx {					/* receive message */
 	int                    rx_nob; /* # bytes received (-1 while posted) */
 	enum ib_wc_status      rx_status;     /* completion status */
 	struct kib_msg		*rx_msg;	/* message buffer (host vaddr) */
-	__u64                  rx_msgaddr;    /* message buffer (I/O addr) */
+	u64                  rx_msgaddr;    /* message buffer (I/O addr) */
 	DEFINE_DMA_UNMAP_ADDR(rx_msgunmap);  /* for dma_unmap_single() */
 	struct ib_recv_wr      rx_wrq;        /* receive work item... */
 	struct ib_sge          rx_sge;        /* ...and its memory */
@@ -498,10 +498,10 @@ struct kib_tx {					/* transmit message */
 	short                 tx_waiting;     /* waiting for peer_ni */
 	int                   tx_status;      /* LNET completion status */
 	ktime_t			tx_deadline;	/* completion deadline */
-	__u64                 tx_cookie;      /* completion cookie */
+	u64                 tx_cookie;      /* completion cookie */
 	struct lnet_msg		*tx_lntmsg[2];	/* lnet msgs to finalize on completion */
 	struct kib_msg	      *tx_msg;        /* message buffer (host vaddr) */
-	__u64                 tx_msgaddr;     /* message buffer (I/O addr) */
+	u64                 tx_msgaddr;     /* message buffer (I/O addr) */
 	DEFINE_DMA_UNMAP_ADDR(tx_msgunmap);  /* for dma_unmap_single() */
 	/** sge for tx_msgaddr */
 	struct ib_sge		tx_msgsge;
@@ -513,7 +513,7 @@ struct kib_tx {					/* transmit message */
 	struct kib_rdma_desc  *tx_rd;         /* rdma descriptor */
 	int                   tx_nfrags;      /* # entries in... */
 	struct scatterlist    *tx_frags;      /* dma_map_sg descriptor */
-	__u64                 *tx_pages;      /* rdma phys page addrs */
+	u64                 *tx_pages;      /* rdma phys page addrs */
 	/* gaps in fragments */
 	bool			tx_gaps;
 	struct kib_fmr		tx_fmr;		/* FMR */
@@ -530,10 +530,10 @@ struct kib_conn {
 	struct kib_hca_dev         *ibc_hdev;       /* HCA bound on */
 	struct list_head ibc_list;            /* stash on peer_ni's conn list */
 	struct list_head      ibc_sched_list;  /* schedule for attention */
-	__u16                 ibc_version;     /* version of connection */
+	u16                 ibc_version;     /* version of connection */
 	/* reconnect later */
-	__u16			ibc_reconnect:1;
-	__u64                 ibc_incarnation; /* which instance of the peer_ni */
+	u16			ibc_reconnect:1;
+	u64                 ibc_incarnation; /* which instance of the peer_ni */
 	atomic_t              ibc_refcount;    /* # users */
 	int                   ibc_state;       /* what's happening */
 	int                   ibc_nsends_posted; /* # uncompleted sends */
@@ -543,9 +543,9 @@ struct kib_conn {
 	int                   ibc_reserved_credits; /* # ACK/DONE msg credits */
 	int                   ibc_comms_error; /* set on comms error */
 	/* connections queue depth */
-	__u16		      ibc_queue_depth;
+	u16		      ibc_queue_depth;
 	/* connections max frags */
-	__u16		      ibc_max_frags;
+	u16		      ibc_max_frags;
 	unsigned int          ibc_nrx:16;      /* receive buffers owned */
 	unsigned int          ibc_scheduled:1; /* scheduled for attention */
 	unsigned int          ibc_ready:1;     /* CQ callback fired */
@@ -586,13 +586,13 @@ struct kib_peer_ni {
 	struct kib_conn	*ibp_next_conn;  /* next connection to send on for
 					  * round robin */
 	struct list_head ibp_tx_queue;    /* msgs waiting for a conn */
-	__u64            ibp_incarnation; /* incarnation of peer_ni */
+	u64            ibp_incarnation; /* incarnation of peer_ni */
 	/* when (in seconds) I was last alive */
 	time64_t		ibp_last_alive;
 	/* # users */
 	atomic_t		ibp_refcount;
 	/* version of peer_ni */
-	__u16			ibp_version;
+	u16			ibp_version;
 	/* current passive connection attempts */
 	unsigned short		ibp_accepting;
 	/* current active connection attempts */
@@ -606,9 +606,9 @@ struct kib_peer_ni {
 	/* errno on closing this peer_ni */
 	int              ibp_error;
 	/* max map_on_demand */
-	__u16		 ibp_max_frags;
+	u16		 ibp_max_frags;
 	/* max_peer_credits */
-	__u16		 ibp_queue_depth;
+	u16		 ibp_queue_depth;
 };
 
 extern struct kib_data kiblnd_data;
@@ -819,24 +819,24 @@ struct kib_peer_ni {
 #define IBLND_WID_MR	4
 #define IBLND_WID_MASK	7UL
 
-static inline __u64
+static inline u64
 kiblnd_ptr2wreqid(void *ptr, int type)
 {
 	unsigned long lptr = (unsigned long)ptr;
 
 	LASSERT(!(lptr & IBLND_WID_MASK));
 	LASSERT(!(type & ~IBLND_WID_MASK));
-	return (__u64)(lptr | type);
+	return (u64)(lptr | type);
 }
 
 static inline void *
-kiblnd_wreqid2ptr(__u64 wreqid)
+kiblnd_wreqid2ptr(u64 wreqid)
 {
 	return (void *)(((unsigned long)wreqid) & ~IBLND_WID_MASK);
 }
 
 static inline int
-kiblnd_wreqid2type(__u64 wreqid)
+kiblnd_wreqid2type(u64 wreqid)
 {
 	return wreqid & IBLND_WID_MASK;
 }
@@ -867,26 +867,26 @@ struct kib_peer_ni {
 	return size;
 }
 
-static inline __u64
+static inline u64
 kiblnd_rd_frag_addr(struct kib_rdma_desc *rd, int index)
 {
 	return rd->rd_frags[index].rf_addr;
 }
 
-static inline __u32
+static inline u32
 kiblnd_rd_frag_size(struct kib_rdma_desc *rd, int index)
 {
 	return rd->rd_frags[index].rf_nob;
 }
 
-static inline __u32
+static inline u32
 kiblnd_rd_frag_key(struct kib_rdma_desc *rd, int index)
 {
 	return rd->rd_key;
 }
 
 static inline int
-kiblnd_rd_consume_frag(struct kib_rdma_desc *rd, int index, __u32 nob)
+kiblnd_rd_consume_frag(struct kib_rdma_desc *rd, int index, u32 nob)
 {
 	if (nob < rd->rd_frags[index].rf_nob) {
 		rd->rd_frags[index].rf_addr += nob;
@@ -909,13 +909,13 @@ struct kib_peer_ni {
 	       offsetof(struct kib_putack_msg, ibpam_rd.rd_frags[n]);
 }
 
-static inline __u64
+static inline u64
 kiblnd_dma_mapping_error(struct ib_device *dev, u64 dma_addr)
 {
 	return ib_dma_mapping_error(dev, dma_addr);
 }
 
-static inline __u64 kiblnd_dma_map_single(struct ib_device *dev,
+static inline u64 kiblnd_dma_map_single(struct ib_device *dev,
 					  void *msg, size_t size,
 					  enum dma_data_direction direction)
 {
@@ -923,7 +923,7 @@ static inline __u64 kiblnd_dma_map_single(struct ib_device *dev,
 }
 
 static inline void kiblnd_dma_unmap_single(struct ib_device *dev,
-					   __u64 addr, size_t size,
+					   u64 addr, size_t size,
 					  enum dma_data_direction direction)
 {
 	ib_dma_unmap_single(dev, addr, size, direction);
@@ -946,7 +946,7 @@ static inline void kiblnd_dma_unmap_sg(struct ib_device *dev,
 	ib_dma_unmap_sg(dev, sg, nents, direction);
 }
 
-static inline __u64 kiblnd_sg_dma_address(struct ib_device *dev,
+static inline u64 kiblnd_sg_dma_address(struct ib_device *dev,
 					  struct scatterlist *sg)
 {
 	return ib_sg_dma_address(dev, sg);
@@ -971,7 +971,7 @@ static inline unsigned int kiblnd_sg_dma_len(struct ib_device *dev,
 struct list_head *kiblnd_pool_alloc_node(struct kib_poolset *ps);
 
 int  kiblnd_fmr_pool_map(struct kib_fmr_poolset *fps, struct kib_tx *tx,
-			 struct kib_rdma_desc *rd, __u32 nob, __u64 iov,
+			 struct kib_rdma_desc *rd, u32 nob, u64 iov,
 			 struct kib_fmr *fmr);
 void kiblnd_fmr_pool_unmap(struct kib_fmr *fmr, int status);
 
@@ -998,7 +998,7 @@ int kiblnd_create_peer(struct lnet_ni *ni, struct kib_peer_ni **peerp,
 void kiblnd_unlink_peer_locked(struct kib_peer_ni *peer_ni);
 struct kib_peer_ni *kiblnd_find_peer_locked(struct lnet_ni *ni, lnet_nid_t nid);
 int  kiblnd_close_stale_conns_locked(struct kib_peer_ni *peer_ni,
-				     int version, __u64 incarnation);
+				     int version, u64 incarnation);
 int  kiblnd_close_peer_conns_locked(struct kib_peer_ni *peer_ni, int why);
 
 struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
@@ -1016,7 +1016,7 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer_ni *peer_ni,
 void kiblnd_cq_completion(struct ib_cq *cq, void *arg);
 
 void kiblnd_pack_msg(struct lnet_ni *ni, struct kib_msg *msg, int version,
-		     int credits, lnet_nid_t dstnid, __u64 dststamp);
+		     int credits, lnet_nid_t dstnid, u64 dststamp);
 int  kiblnd_unpack_msg(struct kib_msg *msg, int nob);
 int  kiblnd_post_rx(struct kib_rx *rx, int credit);
 
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 57fe037..48f2814 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -47,7 +47,7 @@ static void kiblnd_init_tx_msg(struct lnet_ni *ni, struct kib_tx *tx,
 			       int type, int body_nob);
 static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 			    int resid, struct kib_rdma_desc *dstrd,
-			    __u64 dstcookie);
+			    u64 dstcookie);
 static void kiblnd_queue_tx_locked(struct kib_tx *tx, struct kib_conn *conn);
 static void kiblnd_queue_tx(struct kib_tx *tx, struct kib_conn *conn);
 static void kiblnd_unmap_tx(struct kib_tx *tx);
@@ -223,7 +223,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 }
 
 static struct kib_tx *
-kiblnd_find_waiting_tx_locked(struct kib_conn *conn, int txtype, __u64 cookie)
+kiblnd_find_waiting_tx_locked(struct kib_conn *conn, int txtype, u64 cookie)
 {
 	struct kib_tx *tx;
 
@@ -246,7 +246,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 }
 
 static void
-kiblnd_handle_completion(struct kib_conn *conn, int txtype, int status, __u64 cookie)
+kiblnd_handle_completion(struct kib_conn *conn, int txtype, int status, u64 cookie)
 {
 	struct kib_tx *tx;
 	struct lnet_ni *ni = conn->ibc_peer->ibp_ni;
@@ -284,7 +284,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 }
 
 static void
-kiblnd_send_completion(struct kib_conn *conn, int type, int status, __u64 cookie)
+kiblnd_send_completion(struct kib_conn *conn, int type, int status, u64 cookie)
 {
 	struct lnet_ni *ni = conn->ibc_peer->ibp_ni;
 	struct kib_tx *tx = kiblnd_get_idle_tx(ni, conn->ibc_peer->ibp_nid);
@@ -536,7 +536,7 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 }
 
 static int
-kiblnd_fmr_map_tx(struct kib_net *net, struct kib_tx *tx, struct kib_rdma_desc *rd, __u32 nob)
+kiblnd_fmr_map_tx(struct kib_net *net, struct kib_tx *tx, struct kib_rdma_desc *rd, u32 nob)
 {
 	struct kib_hca_dev *hdev;
 	struct kib_fmr_poolset *fps;
@@ -637,7 +637,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 {
 	struct kib_net *net = ni->ni_data;
 	struct kib_hca_dev *hdev = net->ibn_dev->ibd_hdev;
-	__u32 nob;
+	u32 nob;
 	int i;
 
 	/*
@@ -1086,7 +1086,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 
 static int
 kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
-		 int resid, struct kib_rdma_desc *dstrd, __u64 dstcookie)
+		 int resid, struct kib_rdma_desc *dstrd, u64 dstcookie)
 {
 	struct kib_msg *ibmsg = tx->tx_msg;
 	struct kib_rdma_desc *srcrd = tx->tx_rd;
@@ -2296,7 +2296,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	peer_addr = (struct sockaddr_in *)&cmid->route.addr.dst_addr;
 	if (*kiblnd_tunables.kib_require_priv_port &&
 	    ntohs(peer_addr->sin_port) >= PROT_SOCK) {
-		__u32 ip = ntohl(peer_addr->sin_addr.s_addr);
+		u32 ip = ntohl(peer_addr->sin_addr.s_addr);
 
 		CERROR("peer_ni's port (%pI4h:%hu) is not privileged\n",
 		       &ip, ntohs(peer_addr->sin_port));
@@ -2589,7 +2589,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 
 static void
 kiblnd_check_reconnect(struct kib_conn *conn, int version,
-		       __u64 incarnation, int why, struct kib_connparams *cp)
+		       u64 incarnation, int why, struct kib_connparams *cp)
 {
 	rwlock_t *glock = &kiblnd_data.kib_global_lock;
 	struct kib_peer_ni *peer_ni = conn->ibc_peer;
@@ -2734,7 +2734,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 			struct kib_rej *rej = priv;
 			struct kib_connparams *cp = NULL;
 			int flip = 0;
-			__u64 incarnation = -1;
+			u64 incarnation = -1;
 
 			/* NB. default incarnation is -1 because:
 			 * a) V1 will ignore dst incarnation in connreq.
@@ -2947,7 +2947,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	struct kib_msg *msg;
 	struct rdma_conn_param cp;
 	int version;
-	__u64 incarnation;
+	u64 incarnation;
 	unsigned long flags;
 	int rc;
 
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index ff8d732..f048f0a 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -46,7 +46,7 @@
 struct ksock_nal_data ksocknal_data;
 
 static struct ksock_interface *
-ksocknal_ip2iface(struct lnet_ni *ni, __u32 ip)
+ksocknal_ip2iface(struct lnet_ni *ni, u32 ip)
 {
 	struct ksock_net *net = ni->ni_data;
 	int i;
@@ -64,7 +64,7 @@
 }
 
 static struct ksock_route *
-ksocknal_create_route(__u32 ipaddr, int port)
+ksocknal_create_route(u32 ipaddr, int port)
 {
 	struct ksock_route *route;
 
@@ -217,7 +217,7 @@ struct ksock_peer *
 ksocknal_unlink_peer_locked(struct ksock_peer *peer_ni)
 {
 	int i;
-	__u32 ip;
+	u32 ip;
 	struct ksock_interface *iface;
 
 	for (i = 0; i < peer_ni->ksnp_n_passive_ips; i++) {
@@ -247,7 +247,7 @@ struct ksock_peer *
 
 static int
 ksocknal_get_peer_info(struct lnet_ni *ni, int index,
-		       struct lnet_process_id *id, __u32 *myip, __u32 *peer_ip,
+		       struct lnet_process_id *id, u32 *myip, u32 *peer_ip,
 		       int *port, int *conn_count, int *share_count)
 {
 	struct ksock_peer *peer_ni;
@@ -440,7 +440,7 @@ struct ksock_peer *
 }
 
 int
-ksocknal_add_peer(struct lnet_ni *ni, struct lnet_process_id id, __u32 ipaddr,
+ksocknal_add_peer(struct lnet_ni *ni, struct lnet_process_id id, u32 ipaddr,
 		  int port)
 {
 	struct ksock_peer *peer_ni;
@@ -497,7 +497,7 @@ struct ksock_peer *
 }
 
 static void
-ksocknal_del_peer_locked(struct ksock_peer *peer_ni, __u32 ip)
+ksocknal_del_peer_locked(struct ksock_peer *peer_ni, u32 ip)
 {
 	struct ksock_conn *conn;
 	struct ksock_route *route;
@@ -553,7 +553,7 @@ struct ksock_peer *
 }
 
 static int
-ksocknal_del_peer(struct lnet_ni *ni, struct lnet_process_id id, __u32 ip)
+ksocknal_del_peer(struct lnet_ni *ni, struct lnet_process_id id, u32 ip)
 {
 	LIST_HEAD(zombies);
 	struct ksock_peer *pnxt;
@@ -680,7 +680,7 @@ struct ksock_peer *
 }
 
 static int
-ksocknal_local_ipvec(struct lnet_ni *ni, __u32 *ipaddrs)
+ksocknal_local_ipvec(struct lnet_ni *ni, u32 *ipaddrs)
 {
 	struct ksock_net *net = ni->ni_data;
 	int i;
@@ -710,7 +710,7 @@ struct ksock_peer *
 }
 
 static int
-ksocknal_match_peerip(struct ksock_interface *iface, __u32 *ips, int nips)
+ksocknal_match_peerip(struct ksock_interface *iface, u32 *ips, int nips)
 {
 	int best_netmatch = 0;
 	int best_xor      = 0;
@@ -742,7 +742,7 @@ struct ksock_peer *
 }
 
 static int
-ksocknal_select_ips(struct ksock_peer *peer_ni, __u32 *peerips, int n_peerips)
+ksocknal_select_ips(struct ksock_peer *peer_ni, u32 *peerips, int n_peerips)
 {
 	rwlock_t *global_lock = &ksocknal_data.ksnd_global_lock;
 	struct ksock_net *net = peer_ni->ksnp_ni->ni_data;
@@ -752,8 +752,8 @@ struct ksock_peer *
 	int i;
 	int j;
 	int k;
-	__u32 ip;
-	__u32 xor;
+	u32 ip;
+	u32 xor;
 	int this_netmatch;
 	int best_netmatch;
 	int best_npeers;
@@ -858,7 +858,7 @@ struct ksock_peer *
 
 static void
 ksocknal_create_routes(struct ksock_peer *peer_ni, int port,
-		       __u32 *peer_ipaddrs, int npeer_ipaddrs)
+		       u32 *peer_ipaddrs, int npeer_ipaddrs)
 {
 	struct ksock_route *newroute = NULL;
 	rwlock_t *global_lock = &ksocknal_data.ksnd_global_lock;
@@ -968,7 +968,7 @@ struct ksock_peer *
 {
 	struct ksock_connreq *cr;
 	int rc;
-	__u32 peer_ip;
+	u32 peer_ip;
 	int peer_port;
 
 	rc = lnet_sock_getaddr(sock, 1, &peer_ip, &peer_port);
@@ -995,7 +995,7 @@ struct ksock_peer *
 }
 
 static int
-ksocknal_connecting(struct ksock_peer *peer_ni, __u32 ipaddr)
+ksocknal_connecting(struct ksock_peer *peer_ni, u32 ipaddr)
 {
 	struct ksock_route *route;
 
@@ -1013,7 +1013,7 @@ struct ksock_peer *
 	rwlock_t *global_lock = &ksocknal_data.ksnd_global_lock;
 	LIST_HEAD(zombies);
 	struct lnet_process_id peerid;
-	__u64 incarnation;
+	u64 incarnation;
 	struct ksock_conn *conn;
 	struct ksock_conn *conn2;
 	struct ksock_peer *peer_ni = NULL;
@@ -1714,7 +1714,7 @@ struct ksock_peer *
 
 int
 ksocknal_close_peer_conns_locked(struct ksock_peer *peer_ni,
-				 __u32 ipaddr, int why)
+				 u32 ipaddr, int why)
 {
 	struct ksock_conn *conn;
 	struct list_head *ctmp;
@@ -1737,7 +1737,7 @@ struct ksock_peer *
 ksocknal_close_conn_and_siblings(struct ksock_conn *conn, int why)
 {
 	struct ksock_peer *peer_ni = conn->ksnc_peer;
-	__u32 ipaddr = conn->ksnc_ipaddr;
+	u32 ipaddr = conn->ksnc_ipaddr;
 	int count;
 
 	write_lock_bh(&ksocknal_data.ksnd_global_lock);
@@ -1750,7 +1750,7 @@ struct ksock_peer *
 }
 
 int
-ksocknal_close_matching_conns(struct lnet_process_id id, __u32 ipaddr)
+ksocknal_close_matching_conns(struct lnet_process_id id, u32 ipaddr)
 {
 	struct ksock_peer *peer_ni;
 	struct ksock_peer *pnxt;
@@ -1964,7 +1964,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 }
 
 static int
-ksocknal_add_interface(struct lnet_ni *ni, __u32 ipaddress, __u32 netmask)
+ksocknal_add_interface(struct lnet_ni *ni, u32 ipaddress, u32 netmask)
 {
 	struct ksock_net *net = ni->ni_data;
 	struct ksock_interface *iface;
@@ -2027,7 +2027,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 }
 
 static void
-ksocknal_peer_del_interface_locked(struct ksock_peer *peer_ni, __u32 ipaddr)
+ksocknal_peer_del_interface_locked(struct ksock_peer *peer_ni, u32 ipaddr)
 {
 	struct list_head *tmp;
 	struct list_head *nxt;
@@ -2068,13 +2068,13 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 }
 
 static int
-ksocknal_del_interface(struct lnet_ni *ni, __u32 ipaddress)
+ksocknal_del_interface(struct lnet_ni *ni, u32 ipaddress)
 {
 	struct ksock_net *net = ni->ni_data;
 	int rc = -ENOENT;
 	struct ksock_peer *nxt;
 	struct ksock_peer *peer_ni;
-	__u32 this_ip;
+	u32 this_ip;
 	int i;
 	int j;
 
@@ -2126,7 +2126,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 
 		read_lock(&ksocknal_data.ksnd_global_lock);
 
-		if (data->ioc_count >= (__u32)net->ksnn_ninterfaces) {
+		if (data->ioc_count >= (u32)net->ksnn_ninterfaces) {
 			rc = -ENOENT;
 		} else {
 			rc = 0;
@@ -2152,8 +2152,8 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 					      data->ioc_u32[0]); /* IP address */
 
 	case IOC_LIBCFS_GET_PEER: {
-		__u32 myip = 0;
-		__u32 ip = 0;
+		u32 myip = 0;
+		u32 ip = 0;
 		int port = 0;
 		int conn_count = 0;
 		int share_count = 0;
@@ -2742,7 +2742,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 }
 
 static int
-ksocknal_net_start_threads(struct ksock_net *net, __u32 *cpts, int ncpts)
+ksocknal_net_start_threads(struct ksock_net *net, u32 *cpts, int ncpts)
 {
 	int newif = ksocknal_search_new_ipif(net);
 	int rc;
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index 297d1e5..a390381 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -101,8 +101,8 @@ struct ksock_sched_info {
 #define KSOCK_THREAD_SID(id)      ((id) & ((1UL << KSOCK_CPT_SHIFT) - 1))
 
 struct ksock_interface {			/* in-use interface */
-	__u32		ksni_ipaddr;		/* interface's IP address */
-	__u32		ksni_netmask;		/* interface's network mask */
+	u32		ksni_ipaddr;		/* interface's IP address */
+	u32		ksni_netmask;		/* interface's network mask */
 	int		ksni_nroutes;		/* # routes using (active) */
 	int		ksni_npeers;		/* # peers using (passive) */
 	char		ksni_name[IFNAMSIZ];	/* interface name */
@@ -167,7 +167,7 @@ struct ksock_tunables {
 };
 
 struct ksock_net {
-	__u64		  ksnn_incarnation;	/* my epoch */
+	u64		  ksnn_incarnation;	/* my epoch */
 	spinlock_t	  ksnn_lock;		/* serialise */
 	struct list_head	  ksnn_list;		/* chain on global list */
 	int		  ksnn_npeers;		/* # peers */
@@ -326,8 +326,8 @@ struct ksock_conn {
 	atomic_t           ksnc_sock_refcount;/* sock refcount */
 	struct ksock_sched *ksnc_scheduler;	/* who schedules this connection
 						 */
-	__u32              ksnc_myipaddr;     /* my IP */
-	__u32              ksnc_ipaddr;       /* peer_ni's IP */
+	u32              ksnc_myipaddr;     /* my IP */
+	u32              ksnc_ipaddr;       /* peer_ni's IP */
 	int                ksnc_port;         /* peer_ni's port */
 	signed int         ksnc_type:3;       /* type of connection, should be
 					       * signed value
@@ -344,14 +344,14 @@ struct ksock_conn {
 	time64_t	   ksnc_rx_deadline;  /* when (in secs) receive times
 					       * out
 					       */
-	__u8               ksnc_rx_started;   /* started receiving a message */
-	__u8               ksnc_rx_ready;     /* data ready to read */
-	__u8               ksnc_rx_scheduled; /* being progressed */
-	__u8               ksnc_rx_state;     /* what is being read */
+	u8               ksnc_rx_started;   /* started receiving a message */
+	u8               ksnc_rx_ready;     /* data ready to read */
+	u8               ksnc_rx_scheduled; /* being progressed */
+	u8               ksnc_rx_state;     /* what is being read */
 	int                ksnc_rx_nob_left;  /* # bytes to next hdr/body */
 	struct iov_iter    ksnc_rx_to;		/* copy destination */
 	struct kvec        ksnc_rx_iov_space[LNET_MAX_IOV]; /* space for frag descriptors */
-	__u32              ksnc_rx_csum;      /* partial checksum for incoming
+	u32              ksnc_rx_csum;      /* partial checksum for incoming
 					       * data
 					       */
 	void               *ksnc_cookie;      /* rx lnet_finalize passthru arg
@@ -391,8 +391,8 @@ struct ksock_route {
 						* can happen next
 						*/
 	time64_t	  ksnr_retry_interval; /* how long between retries */
-	__u32             ksnr_myipaddr;       /* my IP */
-	__u32             ksnr_ipaddr;         /* IP address to connect to */
+	u32             ksnr_myipaddr;       /* my IP */
+	u32             ksnr_ipaddr;         /* IP address to connect to */
 	int               ksnr_port;           /* port to connect to */
 	unsigned int      ksnr_scheduled:1;    /* scheduled for attention */
 	unsigned int      ksnr_connecting:1;   /* connection establishment in
@@ -422,8 +422,8 @@ struct ksock_peer {
 	int                ksnp_accepting;      /* # passive connections pending
 						 */
 	int                ksnp_error;          /* errno on closing last conn */
-	__u64              ksnp_zc_next_cookie; /* ZC completion cookie */
-	__u64              ksnp_incarnation;    /* latest known peer_ni
+	u64              ksnp_zc_next_cookie; /* ZC completion cookie */
+	u64              ksnp_incarnation;    /* latest known peer_ni
 						 * incarnation
 						 */
 	struct ksock_proto *ksnp_proto;         /* latest known peer_ni
@@ -479,13 +479,13 @@ struct ksock_proto {
 	struct ksock_tx *(*pro_queue_tx_msg)(struct ksock_conn *, struct ksock_tx *);
 
 	/* queue ZC ack on the connection */
-	int        (*pro_queue_tx_zcack)(struct ksock_conn *, struct ksock_tx *, __u64);
+	int        (*pro_queue_tx_zcack)(struct ksock_conn *, struct ksock_tx *, u64);
 
 	/* handle ZC request */
-	int        (*pro_handle_zcreq)(struct ksock_conn *, __u64, int);
+	int        (*pro_handle_zcreq)(struct ksock_conn *, u64, int);
 
 	/* handle ZC ACK */
-	int        (*pro_handle_zcack)(struct ksock_conn *, __u64, __u64);
+	int        (*pro_handle_zcack)(struct ksock_conn *, u64, u64);
 
 	/*
 	 * msg type matches the connection type:
@@ -634,7 +634,7 @@ int ksocknal_recv(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg,
 		  int delayed, struct iov_iter *to, unsigned int rlen);
 int ksocknal_accept(struct lnet_ni *ni, struct socket *sock);
 
-int ksocknal_add_peer(struct lnet_ni *ni, struct lnet_process_id id, __u32 ip,
+int ksocknal_add_peer(struct lnet_ni *ni, struct lnet_process_id id, u32 ip,
 		      int port);
 struct ksock_peer *ksocknal_find_peer_locked(struct lnet_ni *ni,
 					     struct lnet_process_id id);
@@ -647,9 +647,9 @@ int ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
 void ksocknal_terminate_conn(struct ksock_conn *conn);
 void ksocknal_destroy_conn(struct ksock_conn *conn);
 int  ksocknal_close_peer_conns_locked(struct ksock_peer *peer_ni,
-				      __u32 ipaddr, int why);
+				      u32 ipaddr, int why);
 int ksocknal_close_conn_and_siblings(struct ksock_conn *conn, int why);
-int ksocknal_close_matching_conns(struct lnet_process_id id, __u32 ipaddr);
+int ksocknal_close_matching_conns(struct lnet_process_id id, u32 ipaddr);
 struct ksock_conn *ksocknal_find_conn_locked(struct ksock_peer *peer_ni,
 					     struct ksock_tx *tx, int nonblk);
 
@@ -657,7 +657,7 @@ int  ksocknal_launch_packet(struct lnet_ni *ni, struct ksock_tx *tx,
 			    struct lnet_process_id id);
 struct ksock_tx *ksocknal_alloc_tx(int type, int size);
 void ksocknal_free_tx(struct ksock_tx *tx);
-struct ksock_tx *ksocknal_alloc_tx_noop(__u64 cookie, int nonblk);
+struct ksock_tx *ksocknal_alloc_tx_noop(u64 cookie, int nonblk);
 void ksocknal_next_tx_carrier(struct ksock_conn *conn);
 void ksocknal_queue_tx_locked(struct ksock_tx *tx, struct ksock_conn *conn);
 void ksocknal_txlist_done(struct lnet_ni *ni, struct list_head *txlist, int error);
@@ -679,7 +679,7 @@ int ksocknal_send_hello(struct lnet_ni *ni, struct ksock_conn *conn,
 int ksocknal_recv_hello(struct lnet_ni *ni, struct ksock_conn *conn,
 			struct ksock_hello_msg *hello,
 			struct lnet_process_id *id,
-			__u64 *incarnation);
+			u64 *incarnation);
 void ksocknal_read_callback(struct ksock_conn *conn);
 void ksocknal_write_callback(struct ksock_conn *conn);
 
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index 4abf0eb..dd4fb69 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -64,7 +64,7 @@ struct ksock_tx *
 }
 
 struct ksock_tx *
-ksocknal_alloc_tx_noop(__u64 cookie, int nonblk)
+ksocknal_alloc_tx_noop(u64 cookie, int nonblk)
 {
 	struct ksock_tx *tx;
 
@@ -1126,7 +1126,7 @@ struct ksock_route *
 		}
 
 		if (conn->ksnc_msg.ksm_zc_cookies[1]) {
-			__u64 cookie = 0;
+			u64 cookie = 0;
 
 			LASSERT(conn->ksnc_proto != &ksocknal_protocol_v1x);
 
@@ -1533,7 +1533,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 static struct ksock_proto *
 ksocknal_parse_proto_version(struct ksock_hello_msg *hello)
 {
-	__u32 version = 0;
+	u32 version = 0;
 
 	if (hello->kshm_magic == LNET_PROTO_MAGIC)
 		version = hello->kshm_version;
@@ -1614,7 +1614,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 ksocknal_recv_hello(struct lnet_ni *ni, struct ksock_conn *conn,
 		    struct ksock_hello_msg *hello,
 		    struct lnet_process_id *peerid,
-		    __u64 *incarnation)
+		    u64 *incarnation)
 {
 	/* Return < 0	fatal error
 	 *	0	  success
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
index 686c2d3..565c50c 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
@@ -175,7 +175,7 @@ static int lustre_csum(struct kvec *v, void *context)
 ksocknal_lib_recv(struct ksock_conn *conn)
 {
 	struct msghdr msg = { .msg_iter = conn->ksnc_rx_to };
-	__u32 saved_csum;
+	u32 saved_csum;
 	int rc;
 
 	rc = sock_recvmsg(conn->ksnc_sock, &msg, MSG_DONTWAIT);
@@ -203,7 +203,7 @@ static int lustre_csum(struct kvec *v, void *context)
 ksocknal_lib_csum_tx(struct ksock_tx *tx)
 {
 	int i;
-	__u32 csum;
+	u32 csum;
 	void *base;
 
 	LASSERT(tx->tx_iov[0].iov_base == &tx->tx_msg);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
index 54ec5d0..91bed59 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
@@ -68,7 +68,7 @@
 
 static int
 ksocknal_queue_tx_zcack_v2(struct ksock_conn *conn,
-			   struct ksock_tx *tx_ack, __u64 cookie)
+			   struct ksock_tx *tx_ack, u64 cookie)
 {
 	struct ksock_tx *tx = conn->ksnc_tx_carrier;
 
@@ -151,7 +151,7 @@
 
 static int
 ksocknal_queue_tx_zcack_v3(struct ksock_conn *conn,
-			   struct ksock_tx *tx_ack, __u64 cookie)
+			   struct ksock_tx *tx_ack, u64 cookie)
 {
 	struct ksock_tx *tx;
 
@@ -220,7 +220,7 @@
 	/* takes two or more cookies already */
 
 	if (tx->tx_msg.ksm_zc_cookies[0] > tx->tx_msg.ksm_zc_cookies[1]) {
-		__u64   tmp = 0;
+		u64   tmp = 0;
 
 		/* two separated cookies: (a+2, a) or (a+1, a) */
 		LASSERT(tx->tx_msg.ksm_zc_cookies[0] -
@@ -365,7 +365,7 @@
 
 /* (Sink) handle incoming ZC request from sender */
 static int
-ksocknal_handle_zcreq(struct ksock_conn *c, __u64 cookie, int remote)
+ksocknal_handle_zcreq(struct ksock_conn *c, u64 cookie, int remote)
 {
 	struct ksock_peer *peer_ni = c->ksnc_peer;
 	struct ksock_conn *conn;
@@ -409,7 +409,7 @@
 
 /* (Sender) handle ZC_ACK from sink */
 static int
-ksocknal_handle_zcack(struct ksock_conn *conn, __u64 cookie1, __u64 cookie2)
+ksocknal_handle_zcack(struct ksock_conn *conn, u64 cookie1, u64 cookie2)
 {
 	struct ksock_peer *peer_ni = conn->ksnc_peer;
 	struct ksock_tx *tx;
@@ -432,7 +432,7 @@
 
 	list_for_each_entry_safe(tx, tmp, &peer_ni->ksnp_zc_req_list,
 				 tx_zc_list) {
-		__u64 c = tx->tx_msg.ksm_zc_cookies[0];
+		u64 c = tx->tx_msg.ksm_zc_cookies[0];
 
 		if (c == cookie1 || c == cookie2 ||
 		    (cookie1 < c && c < cookie2)) {
@@ -500,7 +500,7 @@
 	hdr->src_nid = cpu_to_le64(hello->kshm_src_nid);
 	hdr->src_pid = cpu_to_le32(hello->kshm_src_pid);
 	hdr->type = cpu_to_le32(LNET_MSG_HELLO);
-	hdr->payload_length = cpu_to_le32(hello->kshm_nips * sizeof(__u32));
+	hdr->payload_length = cpu_to_le32(hello->kshm_nips * sizeof(u32));
 	hdr->msg.hello.type = cpu_to_le32(hello->kshm_ctype);
 	hdr->msg.hello.incarnation = cpu_to_le64(hello->kshm_src_incarnation);
 
@@ -518,7 +518,7 @@
 		hello->kshm_ips[i] = __cpu_to_le32(hello->kshm_ips[i]);
 
 	rc = lnet_sock_write(sock, hello->kshm_ips,
-			     hello->kshm_nips * sizeof(__u32),
+			     hello->kshm_nips * sizeof(u32),
 			     lnet_acceptor_timeout());
 	if (rc) {
 		CNETERR("Error %d sending HELLO payload (%d) to %pI4h/%d\n",
@@ -562,7 +562,7 @@
 		return 0;
 
 	rc = lnet_sock_write(sock, hello->kshm_ips,
-			     hello->kshm_nips * sizeof(__u32),
+			     hello->kshm_nips * sizeof(u32),
 			     lnet_acceptor_timeout());
 	if (rc) {
 		CNETERR("Error %d sending HELLO payload (%d) to %pI4h/%d\n",
@@ -612,7 +612,7 @@
 	hello->kshm_src_incarnation = le64_to_cpu(hdr->msg.hello.incarnation);
 	hello->kshm_ctype           = le32_to_cpu(hdr->msg.hello.type);
 	hello->kshm_nips            = le32_to_cpu(hdr->payload_length) /
-						  sizeof(__u32);
+						  sizeof(u32);
 
 	if (hello->kshm_nips > LNET_INTERFACES_NUM) {
 		CERROR("Bad nips %d from ip %pI4h\n",
@@ -625,7 +625,7 @@
 		goto out;
 
 	rc = lnet_sock_read(sock, hello->kshm_ips,
-			    hello->kshm_nips * sizeof(__u32), timeout);
+			    hello->kshm_nips * sizeof(u32), timeout);
 	if (rc) {
 		CERROR("Error %d reading IPs from ip %pI4h\n",
 		       rc, &conn->ksnc_ipaddr);
@@ -694,7 +694,7 @@
 		return 0;
 
 	rc = lnet_sock_read(sock, hello->kshm_ips,
-			    hello->kshm_nips * sizeof(__u32), timeout);
+			    hello->kshm_nips * sizeof(u32), timeout);
 	if (rc) {
 		CERROR("Error %d reading IPs from ip %pI4h\n",
 		       rc, &conn->ksnc_ipaddr);
-- 
1.8.3.1
