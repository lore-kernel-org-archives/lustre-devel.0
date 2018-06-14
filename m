From: James Simmons <jsimmons@infradead.org>
Date: Thu, 14 Jun 2018 03:38:58 +0100 (BST)
Subject: [lustre-devel] [PATCH 09/11] staging: lustre: discard WIRE_ATTR
In-Reply-To: <152826511920.16761.2460891067961959676.stgit@noble>
References: <152826510267.16761.14361003167157833896.stgit@noble>
 <152826511920.16761.2460891067961959676.stgit@noble>
Message-ID: <alpine.LFD.2.21.1806140338150.6734@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Doug Oucharek <dougso@me.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>


> This macro adds nothing of value, and make the code harder
> to read for new readers.

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  .../staging/lustre/include/linux/lnet/socklnd.h    |    8 ++-
>  .../lustre/include/uapi/linux/lnet/lnet-types.h    |   28 +++++-------
>  .../lustre/include/uapi/linux/lnet/lnetst.h        |    4 +-
>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |   22 +++++----
>  drivers/staging/lustre/lnet/selftest/rpc.h         |   48 ++++++++++----------
>  5 files changed, 54 insertions(+), 56 deletions(-)
> 
> diff --git a/drivers/staging/lustre/include/linux/lnet/socklnd.h b/drivers/staging/lustre/include/linux/lnet/socklnd.h
> index 6bd1bca190a3..9f69257e000b 100644
> --- a/drivers/staging/lustre/include/linux/lnet/socklnd.h
> +++ b/drivers/staging/lustre/include/linux/lnet/socklnd.h
> @@ -50,7 +50,7 @@ struct ksock_hello_msg {
>  	__u32		kshm_ctype;	/* connection type */
>  	__u32		kshm_nips;	/* # IP addrs */
>  	__u32		kshm_ips[0];	/* IP addrs */
> -} WIRE_ATTR;
> +} __packed;
>  
>  struct ksock_lnet_msg {
>  	struct lnet_hdr	ksnm_hdr;	/* lnet hdr */
> @@ -61,7 +61,7 @@ struct ksock_lnet_msg {
>  	 * structure definitions. lnet payload will be stored just after
>  	 * the body of structure ksock_lnet_msg_t
>  	 */
> -} WIRE_ATTR;
> +} __packed;
>  
>  struct ksock_msg {
>  	__u32	ksm_type;		/* type of socklnd message */
> @@ -71,8 +71,8 @@ struct ksock_msg {
>  		struct ksock_lnet_msg lnetmsg; /* lnet message, it's empty if
>  						* it's NOOP
>  						*/
> -	} WIRE_ATTR ksm_u;
> -} WIRE_ATTR;
> +	} __packed ksm_u;
> +} __packed;
>  
>  #define KSOCK_MSG_NOOP	0xC0	/* ksm_u empty */
>  #define KSOCK_MSG_LNET	0xC1	/* lnet msg */
> diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
> index 1be9b7aa7326..f97e7d9d881f 100644
> --- a/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
> +++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnet-types.h
> @@ -112,14 +112,12 @@ static inline __u32 LNET_MKNET(__u32 type, __u32 num)
>  	return (type << 16) | num;
>  }
>  
> -#define WIRE_ATTR	__packed
> -
>  /* Packed version of lnet_process_id to transfer via network */
>  struct lnet_process_id_packed {
>  	/* node id / process id */
>  	lnet_nid_t	nid;
>  	lnet_pid_t	pid;
> -} WIRE_ATTR;
> +} __packed;
>  
>  /*
>   * The wire handle's interface cookie only matches one network interface in
> @@ -130,7 +128,7 @@ struct lnet_process_id_packed {
>  struct lnet_handle_wire {
>  	__u64	wh_interface_cookie;
>  	__u64	wh_object_cookie;
> -} WIRE_ATTR;
> +} __packed;
>  
>  enum lnet_msg_type {
>  	LNET_MSG_ACK = 0,
> @@ -150,7 +148,7 @@ struct lnet_ack {
>  	struct lnet_handle_wire	dst_wmd;
>  	__u64			match_bits;
>  	__u32			mlength;
> -} WIRE_ATTR;
> +} __packed;
>  
>  struct lnet_put {
>  	struct lnet_handle_wire	ack_wmd;
> @@ -158,7 +156,7 @@ struct lnet_put {
>  	__u64			hdr_data;
>  	__u32			ptl_index;
>  	__u32			offset;
> -} WIRE_ATTR;
> +} __packed;
>  
>  struct lnet_get {
>  	struct lnet_handle_wire	return_wmd;
> @@ -166,16 +164,16 @@ struct lnet_get {
>  	__u32			ptl_index;
>  	__u32			src_offset;
>  	__u32			sink_length;
> -} WIRE_ATTR;
> +} __packed;
>  
>  struct lnet_reply {
>  	struct lnet_handle_wire	dst_wmd;
> -} WIRE_ATTR;
> +} __packed;
>  
>  struct lnet_hello {
>  	__u64			incarnation;
>  	__u32			type;
> -} WIRE_ATTR;
> +} __packed;
>  
>  struct lnet_hdr {
>  	lnet_nid_t	dest_nid;
> @@ -192,7 +190,7 @@ struct lnet_hdr {
>  		struct lnet_reply	reply;
>  		struct lnet_hello	hello;
>  	} msg;
> -} WIRE_ATTR;
> +} __packed;
>  
>  /*
>   * A HELLO message contains a magic number and protocol version
> @@ -208,7 +206,7 @@ struct lnet_magicversion {
>  	__u32	magic;		/* LNET_PROTO_TCP_MAGIC */
>  	__u16	version_major;	/* increment on incompatible change */
>  	__u16	version_minor;	/* increment on compatible change */
> -} WIRE_ATTR;
> +} __packed;
>  
>  /* PROTO MAGIC for LNDs */
>  #define LNET_PROTO_IB_MAGIC		0x0be91b91
> @@ -232,7 +230,7 @@ struct lnet_acceptor_connreq {
>  	__u32	acr_magic;		/* PTL_ACCEPTOR_PROTO_MAGIC */
>  	__u32	acr_version;		/* protocol version */
>  	__u64	acr_nid;		/* target NID */
> -} WIRE_ATTR;
> +} __packed;
>  
>  #define LNET_PROTO_ACCEPTOR_VERSION	1
>  
> @@ -240,7 +238,7 @@ struct lnet_ni_status {
>  	lnet_nid_t	ns_nid;
>  	__u32		ns_status;
>  	__u32		ns_unused;
> -} WIRE_ATTR;
> +} __packed;
>  
>  struct lnet_ping_info {
>  	__u32			pi_magic;
> @@ -248,7 +246,7 @@ struct lnet_ping_info {
>  	lnet_pid_t		pi_pid;
>  	__u32			pi_nnis;
>  	struct lnet_ni_status	pi_ni[0];
> -} WIRE_ATTR;
> +} __packed;
>  
>  struct lnet_counters {
>  	__u32	msgs_alloc;
> @@ -262,7 +260,7 @@ struct lnet_counters {
>  	__u64	recv_length;
>  	__u64	route_length;
>  	__u64	drop_length;
> -} WIRE_ATTR;
> +} __packed;
>  
>  #define LNET_NI_STATUS_UP      0x15aac0de
>  #define LNET_NI_STATUS_DOWN    0xdeadface
> diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnetst.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnetst.h
> index a4f9ff01d458..7edba2c5bb87 100644
> --- a/drivers/staging/lustre/include/uapi/linux/lnet/lnetst.h
> +++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnetst.h
> @@ -542,7 +542,7 @@ struct srpc_counters {
>  	__u32 rpcs_expired;
>  	__u64 bulk_get;
>  	__u64 bulk_put;
> -} WIRE_ATTR;
> +} __packed;
>  
>  struct sfw_counters {
>  	/** milliseconds since current session started */
> @@ -551,6 +551,6 @@ struct sfw_counters {
>  	__u32 zombie_sessions;
>  	__u32 brw_errors;
>  	__u32 ping_errors;
> -} WIRE_ATTR;
> +} __packed;
>  
>  #endif
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
> index 217503f125bc..7d8429672616 100644
> --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
> +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
> @@ -359,45 +359,45 @@ struct kib_connparams {
>  	__u16        ibcp_queue_depth;
>  	__u16        ibcp_max_frags;
>  	__u32        ibcp_max_msg_size;
> -} WIRE_ATTR;
> +} __packed;
>  
>  struct kib_immediate_msg {
>  	struct lnet_hdr	ibim_hdr;        /* portals header */
>  	char         ibim_payload[0]; /* piggy-backed payload */
> -} WIRE_ATTR;
> +} __packed;
>  
>  struct kib_rdma_frag {
>  	__u32        rf_nob;          /* # bytes this frag */
>  	__u64        rf_addr;         /* CAVEAT EMPTOR: misaligned!! */
> -} WIRE_ATTR;
> +} __packed;
>  
>  struct kib_rdma_desc {
>  	__u32           rd_key;       /* local/remote key */
>  	__u32           rd_nfrags;    /* # fragments */
>  	struct kib_rdma_frag	rd_frags[0];	/* buffer frags */
> -} WIRE_ATTR;
> +} __packed;
>  
>  struct kib_putreq_msg {
>  	struct lnet_hdr	ibprm_hdr;    /* portals header */
>  	__u64           ibprm_cookie; /* opaque completion cookie */
> -} WIRE_ATTR;
> +} __packed;
>  
>  struct kib_putack_msg {
>  	__u64           ibpam_src_cookie; /* reflected completion cookie */
>  	__u64           ibpam_dst_cookie; /* opaque completion cookie */
>  	struct kib_rdma_desc ibpam_rd;         /* sender's sink buffer */
> -} WIRE_ATTR;
> +} __packed;
>  
>  struct kib_get_msg {
>  	struct lnet_hdr ibgm_hdr;     /* portals header */
>  	__u64           ibgm_cookie;  /* opaque completion cookie */
>  	struct kib_rdma_desc ibgm_rd;      /* rdma descriptor */
> -} WIRE_ATTR;
> +} __packed;
>  
>  struct kib_completion_msg {
>  	__u64           ibcm_cookie;  /* opaque completion cookie */
>  	__s32           ibcm_status;  /* < 0 failure: >= 0 length */
> -} WIRE_ATTR;
> +} __packed;
>  
>  struct kib_msg {
>  	/* First 2 fields fixed FOR ALL TIME */
> @@ -420,8 +420,8 @@ struct kib_msg {
>  		struct kib_putack_msg		putack;
>  		struct kib_get_msg		get;
>  		struct kib_completion_msg	completion;
> -	} WIRE_ATTR ibm_u;
> -} WIRE_ATTR;
> +	} __packed ibm_u;
> +} __packed;
>  
>  #define IBLND_MSG_MAGIC     LNET_PROTO_IB_MAGIC /* unique magic */
>  
> @@ -447,7 +447,7 @@ struct kib_rej {
>  	__u8             ibr_padding;     /* padding */
>  	__u64            ibr_incarnation; /* incarnation of peer */
>  	struct kib_connparams ibr_cp;          /* connection parameters */
> -} WIRE_ATTR;
> +} __packed;
>  
>  /* connection rejection reasons */
>  #define IBLND_REJECT_CONN_RACE      1 /* You lost connection race */
> diff --git a/drivers/staging/lustre/lnet/selftest/rpc.h b/drivers/staging/lustre/lnet/selftest/rpc.h
> index 465b5b534423..9ce336739449 100644
> --- a/drivers/staging/lustre/lnet/selftest/rpc.h
> +++ b/drivers/staging/lustre/lnet/selftest/rpc.h
> @@ -72,12 +72,12 @@ enum srpc_msg_type {
>  struct srpc_generic_reqst {
>  	__u64			rpyid;		/* reply buffer matchbits */
>  	__u64			bulkid;		/* bulk buffer matchbits */
> -} WIRE_ATTR;
> +} __packed;
>  
>  struct srpc_generic_reply {
>  	__u32			status;
>  	struct lst_sid		sid;
> -} WIRE_ATTR;
> +} __packed;
>  
>  /* FRAMEWORK RPCs */
>  struct srpc_mksn_reqst {
> @@ -85,30 +85,30 @@ struct srpc_mksn_reqst {
>  	struct lst_sid		mksn_sid;	/* session id */
>  	__u32			mksn_force;	/* use brute force */
>  	char			mksn_name[LST_NAME_SIZE];
> -} WIRE_ATTR; /* make session request */
> +} __packed; /* make session request */
>  
>  struct srpc_mksn_reply {
>  	__u32			mksn_status;	/* session status */
>  	struct lst_sid		mksn_sid;	/* session id */
>  	__u32			mksn_timeout;	/* session timeout */
>  	char			mksn_name[LST_NAME_SIZE];
> -} WIRE_ATTR; /* make session reply */
> +} __packed; /* make session reply */
>  
>  struct srpc_rmsn_reqst {
>  	__u64			rmsn_rpyid;	/* reply buffer matchbits */
>  	struct lst_sid		rmsn_sid;	/* session id */
> -} WIRE_ATTR; /* remove session request */
> +} __packed; /* remove session request */
>  
>  struct srpc_rmsn_reply {
>  	__u32			rmsn_status;
>  	struct lst_sid		rmsn_sid;	/* session id */
> -} WIRE_ATTR; /* remove session reply */
> +} __packed; /* remove session reply */
>  
>  struct srpc_join_reqst {
>  	__u64			join_rpyid;	/* reply buffer matchbits */
>  	struct lst_sid		join_sid;	/* session id to join */
>  	char			join_group[LST_NAME_SIZE]; /* group name */
> -} WIRE_ATTR;
> +} __packed;
>  
>  struct srpc_join_reply {
>  	__u32			join_status;	/* returned status */
> @@ -117,13 +117,13 @@ struct srpc_join_reply {
>  						 * expire
>  						 */
>  	char			join_session[LST_NAME_SIZE]; /* session name */
> -} WIRE_ATTR;
> +} __packed;
>  
>  struct srpc_debug_reqst {
>  	__u64			dbg_rpyid;	/* reply buffer matchbits */
>  	struct lst_sid		dbg_sid;	/* session id */
>  	__u32			dbg_flags;	/* bitmap of debug */
> -} WIRE_ATTR;
> +} __packed;
>  
>  struct srpc_debug_reply {
>  	__u32			dbg_status;	/* returned code */
> @@ -131,7 +131,7 @@ struct srpc_debug_reply {
>  	__u32			dbg_timeout;	/* session timeout */
>  	__u32			dbg_nbatch;	/* # of batches in the node */
>  	char			dbg_name[LST_NAME_SIZE]; /* session name */
> -} WIRE_ATTR;
> +} __packed;
>  
>  #define SRPC_BATCH_OPC_RUN	1
>  #define SRPC_BATCH_OPC_STOP	2
> @@ -144,20 +144,20 @@ struct srpc_batch_reqst {
>  	__u32		   bar_opc;	   /* create/start/stop batch */
>  	__u32		   bar_testidx;    /* index of test */
>  	__u32		   bar_arg;	   /* parameters */
> -} WIRE_ATTR;
> +} __packed;
>  
>  struct srpc_batch_reply {
>  	__u32		   bar_status;	   /* status of request */
>  	struct lst_sid	   bar_sid;	   /* session id */
>  	__u32		   bar_active;	   /* # of active tests in batch/test */
>  	__u32		   bar_time;	   /* remained time */
> -} WIRE_ATTR;
> +} __packed;
>  
>  struct srpc_stat_reqst {
>  	__u64		   str_rpyid;	   /* reply buffer matchbits */
>  	struct lst_sid	   str_sid;	   /* session id */
>  	__u32		   str_type;	   /* type of stat */
> -} WIRE_ATTR;
> +} __packed;
>  
>  struct srpc_stat_reply {
>  	__u32		   str_status;
> @@ -165,25 +165,25 @@ struct srpc_stat_reply {
>  	struct sfw_counters	str_fw;
>  	struct srpc_counters	str_rpc;
>  	struct lnet_counters    str_lnet;
> -} WIRE_ATTR;
> +} __packed;
>  
>  struct test_bulk_req {
>  	__u32		   blk_opc;	   /* bulk operation code */
>  	__u32		   blk_npg;	   /* # of pages */
>  	__u32		   blk_flags;	   /* reserved flags */
> -} WIRE_ATTR;
> +} __packed;
>  
>  struct test_bulk_req_v1 {
>  	__u16		   blk_opc;	   /* bulk operation code */
>  	__u16		   blk_flags;	   /* data check flags */
>  	__u32		   blk_len;	   /* data length */
>  	__u32		   blk_offset;	   /* offset */
> -} WIRE_ATTR;
> +} __packed;
>  
>  struct test_ping_req {
>  	__u32		   png_size;	   /* size of ping message */
>  	__u32		   png_flags;	   /* reserved flags */
> -} WIRE_ATTR;
> +} __packed;
>  
>  struct srpc_test_reqst {
>  	__u64			tsr_rpyid;	/* reply buffer matchbits */
> @@ -204,12 +204,12 @@ struct srpc_test_reqst {
>  		struct test_bulk_req	bulk_v0;
>  		struct test_bulk_req_v1	bulk_v1;
>  	} tsr_u;
> -} WIRE_ATTR;
> +} __packed;
>  
>  struct srpc_test_reply {
>  	__u32			tsr_status;	/* returned code */
>  	struct lst_sid		tsr_sid;
> -} WIRE_ATTR;
> +} __packed;
>  
>  /* TEST RPCs */
>  struct srpc_ping_reqst {
> @@ -218,13 +218,13 @@ struct srpc_ping_reqst {
>  	__u32		   pnr_seq;
>  	__u64		   pnr_time_sec;
>  	__u64		   pnr_time_usec;
> -} WIRE_ATTR;
> +} __packed;
>  
>  struct srpc_ping_reply {
>  	__u32		   pnr_status;
>  	__u32		   pnr_magic;
>  	__u32		   pnr_seq;
> -} WIRE_ATTR;
> +} __packed;
>  
>  struct srpc_brw_reqst {
>  	__u64		   brw_rpyid;	   /* reply buffer matchbits */
> @@ -232,11 +232,11 @@ struct srpc_brw_reqst {
>  	__u32		   brw_rw;	   /* read or write */
>  	__u32		   brw_len;	   /* bulk data len */
>  	__u32		   brw_flags;	   /* bulk data patterns */
> -} WIRE_ATTR; /* bulk r/w request */
> +} __packed; /* bulk r/w request */
>  
>  struct srpc_brw_reply {
>  	__u32		   brw_status;
> -} WIRE_ATTR; /* bulk r/w reply */
> +} __packed; /* bulk r/w reply */
>  
>  #define SRPC_MSG_MAGIC		0xeeb0f00d
>  #define SRPC_MSG_VERSION	1
> @@ -272,7 +272,7 @@ struct srpc_msg {
>  		struct srpc_brw_reqst		brw_reqst;
>  		struct srpc_brw_reply		brw_reply;
>  	}     msg_body;
> -} WIRE_ATTR;
> +} __packed;
>  
>  static inline void
>  srpc_unpack_msg_hdr(struct srpc_msg *msg)
> 
> 
> 
