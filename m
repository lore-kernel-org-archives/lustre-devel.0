From: James Simmons <jsimmons@infradead.org>
Date: Thu, 31 Jan 2019 12:19:05 -0500
Subject: [lustre-devel] [PATCH 01/26] lnet: use kernel types for lnet core
 kernel code
In-Reply-To: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
References: <1548955170-13456-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1548955170-13456-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

LNet stack was originally both a user land and kernel
implementation. The source contains many types of the
form __u32 but since this is mostly kernel code change
the types to kernel internal types.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/api.h    | 16 ++--
 .../staging/lustre/include/linux/lnet/lib-lnet.h   | 66 ++++++++--------
 .../staging/lustre/include/linux/lnet/lib-types.h  | 50 ++++++------
 .../staging/lustre/include/linux/lnet/socklnd.h    | 20 ++---
 drivers/staging/lustre/lnet/lnet/acceptor.c        | 14 ++--
 drivers/staging/lustre/lnet/lnet/api-ni.c          | 26 +++----
 drivers/staging/lustre/lnet/lnet/config.c          | 48 ++++++------
 drivers/staging/lustre/lnet/lnet/lib-me.c          |  4 +-
 drivers/staging/lustre/lnet/lnet/lib-move.c        | 28 +++----
 drivers/staging/lustre/lnet/lnet/lib-ptl.c         | 14 ++--
 drivers/staging/lustre/lnet/lnet/lib-socket.c      | 10 +--
 drivers/staging/lustre/lnet/lnet/nidstrings.c      | 88 +++++++++++-----------
 drivers/staging/lustre/lnet/lnet/peer.c            | 20 ++---
 drivers/staging/lustre/lnet/lnet/router.c          | 16 ++--
 drivers/staging/lustre/lnet/lnet/router_proc.c     |  4 +-
 15 files changed, 212 insertions(+), 212 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/api.h b/drivers/staging/lustre/include/linux/lnet/api.h
index 70c9919..7c30475 100644
--- a/drivers/staging/lustre/include/linux/lnet/api.h
+++ b/drivers/staging/lustre/include/linux/lnet/api.h
@@ -76,7 +76,7 @@
  * @{
  */
 int LNetGetId(unsigned int index, struct lnet_process_id *id);
-int LNetDist(lnet_nid_t nid, lnet_nid_t *srcnid, __u32 *order);
+int LNetDist(lnet_nid_t nid, lnet_nid_t *srcnid, u32 *order);
 lnet_nid_t LNetPrimaryNID(lnet_nid_t nid);
 
 /** @} lnet_addr */
@@ -96,16 +96,16 @@
  */
 int LNetMEAttach(unsigned int      portal,
 		 struct lnet_process_id match_id_in,
-		 __u64		   match_bits_in,
-		 __u64		   ignore_bits_in,
+		 u64		   match_bits_in,
+		 u64		   ignore_bits_in,
 		 enum lnet_unlink unlink_in,
 		 enum lnet_ins_pos pos_in,
 		 struct lnet_handle_me *handle_out);
 
 int LNetMEInsert(struct lnet_handle_me current_in,
 		 struct lnet_process_id match_id_in,
-		 __u64		   match_bits_in,
-		 __u64		   ignore_bits_in,
+		 u64		   match_bits_in,
+		 u64		   ignore_bits_in,
 		 enum lnet_unlink unlink_in,
 		 enum lnet_ins_pos position_in,
 		 struct lnet_handle_me *handle_out);
@@ -186,15 +186,15 @@ int LNetPut(lnet_nid_t	      self,
 	    enum lnet_ack_req ack_req_in,
 	    struct lnet_process_id target_in,
 	    unsigned int      portal_in,
-	    __u64	      match_bits_in,
+	    u64 match_bits_in,
 	    unsigned int      offset_in,
-	    __u64	      hdr_data_in);
+	    u64	hdr_data_in);
 
 int LNetGet(lnet_nid_t	      self,
 	    struct lnet_handle_md md_in,
 	    struct lnet_process_id target_in,
 	    unsigned int      portal_in,
-	    __u64	      match_bits_in,
+	    u64	match_bits_in,
 	    unsigned int      offset_in);
 /** @} lnet_data */
 
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index fcfd844..5c3f5e3 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -127,7 +127,7 @@ static inline int lnet_md_unlinkable(struct lnet_libmd *md)
 #define lnet_cpt_current()	cfs_cpt_current(the_lnet.ln_cpt_table, 1)
 
 static inline int
-lnet_cpt_of_cookie(__u64 cookie)
+lnet_cpt_of_cookie(u64 cookie)
 {
 	unsigned int cpt = (cookie >> LNET_COOKIE_TYPE_BITS) & LNET_CPT_MASK;
 
@@ -217,7 +217,7 @@ static inline int lnet_md_unlinkable(struct lnet_libmd *md)
 }
 
 struct lnet_libhandle *lnet_res_lh_lookup(struct lnet_res_container *rec,
-					  __u64 cookie);
+					  u64 cookie);
 void lnet_res_lh_initialize(struct lnet_res_container *rec,
 			    struct lnet_libhandle *lh);
 static inline void
@@ -404,13 +404,13 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 void lnet_net_free(struct lnet_net *net);
 
 struct lnet_net *
-lnet_net_alloc(__u32 net_type, struct list_head *netlist);
+lnet_net_alloc(u32 net_type, struct list_head *netlist);
 
 struct lnet_ni *
 lnet_ni_alloc(struct lnet_net *net, struct cfs_expr_list *el,
 	      char *iface);
 struct lnet_ni *
-lnet_ni_alloc_w_cpt_array(struct lnet_net *net, __u32 *cpts, __u32 ncpts,
+lnet_ni_alloc_w_cpt_array(struct lnet_net *net, u32 *cpts, u32 ncpts,
 			  char *iface);
 
 static inline int
@@ -420,7 +420,7 @@ struct lnet_ni *
 }
 
 static inline struct list_head *
-lnet_net2rnethash(__u32 net)
+lnet_net2rnethash(u32 net)
 {
 	return &the_lnet.ln_remote_nets_hash[(LNET_NETNUM(net) +
 		LNET_NETTYP(net)) &
@@ -435,8 +435,8 @@ struct lnet_ni *
 int lnet_cpt_of_nid(lnet_nid_t nid, struct lnet_ni *ni);
 struct lnet_ni *lnet_nid2ni_locked(lnet_nid_t nid, int cpt);
 struct lnet_ni *lnet_nid2ni_addref(lnet_nid_t nid);
-struct lnet_ni *lnet_net2ni_locked(__u32 net, int cpt);
-struct lnet_ni *lnet_net2ni_addref(__u32 net);
+struct lnet_ni *lnet_net2ni_locked(u32 net, int cpt);
+struct lnet_ni *lnet_net2ni_addref(u32 net);
 bool lnet_is_ni_healthy_locked(struct lnet_ni *ni);
 struct lnet_net *lnet_get_net_locked(u32 net_id);
 
@@ -451,18 +451,18 @@ int lnet_notify(struct lnet_ni *ni, lnet_nid_t peer, int alive,
 		time64_t when);
 void lnet_notify_locked(struct lnet_peer_ni *lp, int notifylnd, int alive,
 			time64_t when);
-int lnet_add_route(__u32 net, __u32 hops, lnet_nid_t gateway_nid,
+int lnet_add_route(u32 net, u32 hops, lnet_nid_t gateway_nid,
 		   unsigned int priority);
 int lnet_check_routes(void);
-int lnet_del_route(__u32 net, lnet_nid_t gw_nid);
+int lnet_del_route(u32 net, lnet_nid_t gw_nid);
 void lnet_destroy_routes(void);
-int lnet_get_route(int idx, __u32 *net, __u32 *hops,
-		   lnet_nid_t *gateway, __u32 *alive, __u32 *priority);
+int lnet_get_route(int idx, u32 *net, u32 *hops,
+		   lnet_nid_t *gateway, u32 *alive, u32 *priority);
 int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg);
 struct lnet_ni *lnet_get_next_ni_locked(struct lnet_net *mynet,
 					struct lnet_ni *prev);
 struct lnet_ni *lnet_get_ni_idx_locked(int idx);
-int lnet_get_peer_list(__u32 *countp, __u32 *sizep,
+int lnet_get_peer_list(u32 *countp, u32 *sizep,
 		       struct lnet_process_id __user *ids);
 
 void lnet_router_debugfs_init(void);
@@ -473,16 +473,16 @@ int lnet_get_peer_list(__u32 *countp, __u32 *sizep,
 int lnet_rtrpools_enable(void);
 void lnet_rtrpools_disable(void);
 void lnet_rtrpools_free(int keep_pools);
-struct lnet_remotenet *lnet_find_rnet_locked(__u32 net);
+struct lnet_remotenet *lnet_find_rnet_locked(u32 net);
 int lnet_dyn_add_net(struct lnet_ioctl_config_data *conf);
-int lnet_dyn_del_net(__u32 net);
+int lnet_dyn_del_net(u32 net);
 int lnet_dyn_add_ni(struct lnet_ioctl_config_ni *conf);
 int lnet_dyn_del_ni(struct lnet_ioctl_config_ni *conf);
 int lnet_clear_lazy_portal(struct lnet_ni *ni, int portal, char *reason);
-struct lnet_net *lnet_get_net_locked(__u32 net_id);
+struct lnet_net *lnet_get_net_locked(u32 net_id);
 
 int lnet_islocalnid(lnet_nid_t nid);
-int lnet_islocalnet(__u32 net);
+int lnet_islocalnet(u32 net);
 
 void lnet_msg_attach_md(struct lnet_msg *msg, struct lnet_libmd *md,
 			unsigned int offset, unsigned int mlen);
@@ -536,10 +536,10 @@ void lnet_prep_send(struct lnet_msg *msg, int type,
 
 /* match-table functions */
 struct list_head *lnet_mt_match_head(struct lnet_match_table *mtable,
-				     struct lnet_process_id id, __u64 mbits);
+				     struct lnet_process_id id, u64 mbits);
 struct lnet_match_table *lnet_mt_of_attach(unsigned int index,
 					   struct lnet_process_id id,
-					   __u64 mbits, __u64 ignore_bits,
+					   u64 mbits, u64 ignore_bits,
 					   enum lnet_ins_pos pos);
 int lnet_mt_match_md(struct lnet_match_table *mtable,
 		     struct lnet_match_info *info, struct lnet_msg *msg);
@@ -575,7 +575,7 @@ void lnet_set_reply_msg_len(struct lnet_ni *ni, struct lnet_msg *msg,
 void lnet_finalize(struct lnet_msg *msg, int rc);
 
 void lnet_drop_message(struct lnet_ni *ni, int cpt, void *private,
-		       unsigned int nob, __u32 msg_type);
+		       unsigned int nob, u32 msg_type);
 void lnet_drop_delayed_msg_list(struct list_head *head, char *reason);
 void lnet_recv_delayed_msg_list(struct list_head *head);
 
@@ -637,9 +637,9 @@ void lnet_copy_kiov2iter(struct iov_iter *to,
 void lnet_unregister_lnd(struct lnet_lnd *lnd);
 
 int lnet_connect(struct socket **sockp, lnet_nid_t peer_nid,
-		 __u32 local_ip, __u32 peer_ip, int peer_port);
+		 u32 local_ip, u32 peer_ip, int peer_port);
 void lnet_connect_console_error(int rc, lnet_nid_t peer_nid,
-				__u32 peer_ip, int port);
+				u32 peer_ip, int port);
 int lnet_count_acceptor_nets(void);
 int lnet_acceptor_timeout(void);
 int lnet_acceptor_port(void);
@@ -652,15 +652,15 @@ void lnet_connect_console_error(int rc, lnet_nid_t peer_nid,
 
 int lnet_sock_setbuf(struct socket *socket, int txbufsize, int rxbufsize);
 int lnet_sock_getbuf(struct socket *socket, int *txbufsize, int *rxbufsize);
-int lnet_sock_getaddr(struct socket *socket, bool remote, __u32 *ip, int *port);
+int lnet_sock_getaddr(struct socket *socket, bool remote, u32 *ip, int *port);
 int lnet_sock_write(struct socket *sock, void *buffer, int nob, int timeout);
 int lnet_sock_read(struct socket *sock, void *buffer, int nob, int timeout);
 
-int lnet_sock_listen(struct socket **sockp, __u32 ip, int port, int backlog);
+int lnet_sock_listen(struct socket **sockp, u32 ip, int port, int backlog);
 int lnet_sock_accept(struct socket **newsockp, struct socket *sock);
 int lnet_sock_connect(struct socket **sockp, int *fatal,
-		      __u32 local_ip, int local_port,
-		      __u32 peer_ip, int peer_port);
+		      u32 local_ip, int local_port,
+		      u32 peer_ip, int peer_port);
 void libcfs_sock_release(struct socket *sock);
 
 int lnet_peers_start_down(void);
@@ -668,7 +668,7 @@ int lnet_sock_connect(struct socket **sockp, int *fatal,
 
 int lnet_router_checker_start(void);
 void lnet_router_checker_stop(void);
-void lnet_router_ni_update_locked(struct lnet_peer_ni *gw, __u32 net);
+void lnet_router_ni_update_locked(struct lnet_peer_ni *gw, u32 net);
 void lnet_swap_pinginfo(struct lnet_ping_buffer *pbuf);
 
 int lnet_ping_info_validate(struct lnet_ping_info *pinfo);
@@ -703,7 +703,7 @@ static inline int lnet_push_target_resize_needed(void)
 int lnet_parse_routes(char *route_str, int *im_a_router);
 int lnet_parse_networks(struct list_head *nilist, char *networks,
 			bool use_tcp_bonding);
-bool lnet_net_unique(__u32 net_id, struct list_head *nilist,
+bool lnet_net_unique(u32 net_id, struct list_head *nilist,
 		     struct lnet_net **net);
 bool lnet_ni_unique_net(struct list_head *nilist, char *iface);
 void lnet_incr_dlc_seq(void);
@@ -734,12 +734,12 @@ struct lnet_peer_net *lnet_peer_get_net_locked(struct lnet_peer *peer,
 int lnet_add_peer_ni(lnet_nid_t key_nid, lnet_nid_t nid, bool mr);
 int lnet_del_peer_ni(lnet_nid_t key_nid, lnet_nid_t nid);
 int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk);
-int lnet_get_peer_ni_info(__u32 peer_index, __u64 *nid,
+int lnet_get_peer_ni_info(u32 peer_index, u64 *nid,
 			  char alivness[LNET_MAX_STR_LEN],
-			  __u32 *cpt_iter, __u32 *refcount,
-			  __u32 *ni_peer_tx_credits, __u32 *peer_tx_credits,
-			  __u32 *peer_rtr_credits, __u32 *peer_min_rtr_credtis,
-			  __u32 *peer_tx_qnob);
+			  u32 *cpt_iter, u32 *refcount,
+			  u32 *ni_peer_tx_credits, u32 *peer_tx_credits,
+			  u32 *peer_rtr_credits, u32 *peer_min_rtr_credtis,
+			  u32 *peer_tx_qnob);
 
 static inline bool
 lnet_is_peer_ni_healthy_locked(struct lnet_peer_ni *lpni)
@@ -827,7 +827,7 @@ void lnet_incr_stats(struct lnet_element_stats *stats,
 		     enum lnet_msg_type msg_type,
 		     enum lnet_stats_type stats_type);
 
-__u32 lnet_sum_stats(struct lnet_element_stats *stats,
+u32 lnet_sum_stats(struct lnet_element_stats *stats,
 		     enum lnet_stats_type stats_type);
 
 void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 3a54e06..0646f07 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -64,7 +64,7 @@ struct lnet_msg {
 	lnet_nid_t		msg_initiator;
 	/* where is it from, it's only for building event */
 	lnet_nid_t		msg_from;
-	__u32			msg_type;
+	u32			msg_type;
 
 	/*
 	 * hold parameters in case message is with held due
@@ -123,7 +123,7 @@ struct lnet_msg {
 
 struct lnet_libhandle {
 	struct list_head	lh_hash_chain;
-	__u64			lh_cookie;
+	u64			lh_cookie;
 };
 
 #define lh_entry(ptr, type, member) \
@@ -146,8 +146,8 @@ struct lnet_me {
 	struct lnet_process_id	 me_match_id;
 	unsigned int		 me_portal;
 	unsigned int		 me_pos;	/* hash offset in mt_hash */
-	__u64			 me_match_bits;
-	__u64			 me_ignore_bits;
+	u64			 me_match_bits;
+	u64			 me_ignore_bits;
 	enum lnet_unlink	 me_unlink;
 	struct lnet_libmd	*me_md;
 };
@@ -199,7 +199,7 @@ struct lnet_lnd {
 	int			lnd_refcount;	/* # active instances */
 
 	/* fields initialised by the LND */
-	__u32			lnd_type;
+	u32			lnd_type;
 
 	int  (*lnd_startup)(struct lnet_ni *ni);
 	void (*lnd_shutdown)(struct lnet_ni *ni);
@@ -306,13 +306,13 @@ struct lnet_net {
 	 * (net_type << 16) | net_num.
 	 * net_type can be one of the enumerated types defined in
 	 * lnet/include/lnet/nidstr.h */
-	__u32			net_id;
+	u32			net_id;
 
 	/* total number of CPTs in the array */
-	__u32			net_ncpts;
+	u32			net_ncpts;
 
 	/* cumulative CPTs of all NIs in this net */
-	__u32			*net_cpts;
+	u32			*net_cpts;
 
 	/* network tunables */
 	struct lnet_ioctl_config_lnd_cmn_tunables net_tunables;
@@ -343,7 +343,7 @@ struct lnet_ni {
 	int			ni_ncpts;
 
 	/* bond NI on some CPTs */
-	__u32			*ni_cpts;
+	u32			*ni_cpts;
 
 	/* interface's NID */
 	lnet_nid_t		ni_nid;
@@ -497,7 +497,7 @@ struct lnet_peer_ni {
 	/* sequence number used to round robin over peer nis within a net */
 	u32			lpni_seq;
 	/* sequence number used to round robin over gateways */
-	__u32			lpni_gw_seq;
+	u32			lpni_gw_seq;
 	/* health flag */
 	bool			lpni_healthy;
 	/* returned RC ping features. Protected with lpni_lock */
@@ -559,13 +559,13 @@ struct lnet_peer {
 	int			lp_data_nnis;
 
 	/* NI config sequence number of peer */
-	__u32			lp_peer_seqno;
+	u32			lp_peer_seqno;
 
 	/* Local NI config sequence number acked by peer */
-	__u32			lp_node_seqno;
+	u32			lp_node_seqno;
 
 	/* Local NI config sequence number sent to peer */
-	__u32			lp_node_seqno_sent;
+	u32			lp_node_seqno_sent;
 
 	/* Ping error encountered during discovery. */
 	int			lp_ping_error;
@@ -645,7 +645,7 @@ struct lnet_peer_net {
 	struct lnet_peer	*lpn_peer;
 
 	/* Net ID */
-	__u32			lpn_net_id;
+	u32			lpn_net_id;
 
 	/* reference count */
 	atomic_t		lpn_refcount;
@@ -706,13 +706,13 @@ struct lnet_route {
 	/* router node */
 	struct lnet_peer_ni	*lr_gateway;
 	/* remote network number */
-	__u32			lr_net;
+	u32			lr_net;
 	/* sequence for round-robin */
 	int			lr_seq;
 	/* number of down NIs */
 	unsigned int		lr_downis;
 	/* how far I am */
-	__u32			lr_hops;
+	u32			lr_hops;
 	/* route priority */
 	unsigned int		lr_priority;
 };
@@ -727,7 +727,7 @@ struct lnet_remotenet {
 	/* routes to me */
 	struct list_head	lrn_routes;
 	/* my net number */
-	__u32			lrn_net;
+	u32			lrn_net;
 };
 
 /** lnet message has credit and can be submitted to lnd for send/receive */
@@ -788,7 +788,7 @@ enum lnet_match_flags {
 
 /* parameter for matching operations (GET, PUT) */
 struct lnet_match_info {
-	__u64			mi_mbits;
+	u64			mi_mbits;
 	struct lnet_process_id	mi_id;
 	unsigned int		mi_cpt;
 	unsigned int		mi_opc;
@@ -807,8 +807,8 @@ struct lnet_match_info {
  */
 #define LNET_MT_HASH_IGNORE		LNET_MT_HASH_SIZE
 /*
- * __u64 has 2^6 bits, so need 2^(LNET_MT_HASH_BITS - LNET_MT_BITS_U64) which
- * is 4 __u64s as bit-map, and add an extra __u64 (only use one bit) for the
+ * u64 has 2^6 bits, so need 2^(LNET_MT_HASH_BITS - LNET_MT_BITS_U64) which
+ * is 4 u64s as bit-map, and add an extra u64 (only use one bit) for the
  * ME-list with ignore-bits, which is mtable::mt_hash[LNET_MT_HASH_IGNORE]
  */
 #define LNET_MT_BITS_U64		6	/* 2^6 bits */
@@ -826,7 +826,7 @@ struct lnet_match_table {
 	 */
 	unsigned int		 mt_enabled;
 	/* bitmap to flag whether MEs on mt_hash are exhausted or not */
-	__u64			 mt_exhausted[LNET_MT_EXHAUSTED_BMAP];
+	u64			 mt_exhausted[LNET_MT_EXHAUSTED_BMAP];
 	struct list_head	*mt_mhash;	/* matching hash */
 };
 
@@ -866,7 +866,7 @@ struct lnet_portal {
 /* resource container (ME, MD, EQ) */
 struct lnet_res_container {
 	unsigned int		 rec_type;	/* container type */
-	__u64			 rec_lh_cookie;	/* cookie generator */
+	u64			 rec_lh_cookie;	/* cookie generator */
 	struct list_head	 rec_active;	/* active resource list */
 	struct list_head	*rec_lh_hash;	/* handle hash */
 };
@@ -949,11 +949,11 @@ struct lnet {
 	/* remote networks with routes to them */
 	struct list_head		 *ln_remote_nets_hash;
 	/* validity stamp */
-	__u64				  ln_remote_nets_version;
+	u64				  ln_remote_nets_version;
 	/* list of all known routers */
 	struct list_head		  ln_routers;
 	/* validity stamp */
-	__u64				  ln_routers_version;
+	u64				  ln_routers_version;
 	/* percpt router buffer pools */
 	struct lnet_rtrbufpool		**ln_rtrpools;
 
@@ -1019,7 +1019,7 @@ struct lnet {
 	int				  ln_routing;	/* am I a router? */
 	lnet_pid_t			  ln_pid;	/* requested pid */
 	/* uniquely identifies this ni in this epoch */
-	__u64				  ln_interface_cookie;
+	u64				  ln_interface_cookie;
 	/* registered LNDs */
 	struct list_head		  ln_lnds;
 
diff --git a/drivers/staging/lustre/include/linux/lnet/socklnd.h b/drivers/staging/lustre/include/linux/lnet/socklnd.h
index 9f69257..20fa221d 100644
--- a/drivers/staging/lustre/include/linux/lnet/socklnd.h
+++ b/drivers/staging/lustre/include/linux/lnet/socklnd.h
@@ -39,17 +39,17 @@
 #include <uapi/linux/lnet/socklnd.h>
 
 struct ksock_hello_msg {
-	__u32		kshm_magic;	/* magic number of socklnd message */
-	__u32		kshm_version;	/* version of socklnd message */
+	u32		kshm_magic;	/* magic number of socklnd message */
+	u32		kshm_version;	/* version of socklnd message */
 	lnet_nid_t      kshm_src_nid;	/* sender's nid */
 	lnet_nid_t	kshm_dst_nid;	/* destination nid */
 	lnet_pid_t	kshm_src_pid;	/* sender's pid */
 	lnet_pid_t	kshm_dst_pid;	/* destination pid */
-	__u64		kshm_src_incarnation; /* sender's incarnation */
-	__u64		kshm_dst_incarnation; /* destination's incarnation */
-	__u32		kshm_ctype;	/* connection type */
-	__u32		kshm_nips;	/* # IP addrs */
-	__u32		kshm_ips[0];	/* IP addrs */
+	u64		kshm_src_incarnation; /* sender's incarnation */
+	u64		kshm_dst_incarnation; /* destination's incarnation */
+	u32		kshm_ctype;	/* connection type */
+	u32		kshm_nips;	/* # IP addrs */
+	u32		kshm_ips[0];	/* IP addrs */
 } __packed;
 
 struct ksock_lnet_msg {
@@ -64,9 +64,9 @@ struct ksock_lnet_msg {
 } __packed;
 
 struct ksock_msg {
-	__u32	ksm_type;		/* type of socklnd message */
-	__u32	ksm_csum;		/* checksum if != 0 */
-	__u64	ksm_zc_cookies[2];	/* Zero-Copy request/ACK cookie */
+	u32	ksm_type;		/* type of socklnd message */
+	u32	ksm_csum;		/* checksum if != 0 */
+	u64	ksm_zc_cookies[2];	/* Zero-Copy request/ACK cookie */
 	union {
 		struct ksock_lnet_msg lnetmsg; /* lnet message, it's empty if
 						* it's NOOP
diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
index 150fcd6..aa28a9f 100644
--- a/drivers/staging/lustre/lnet/lnet/acceptor.c
+++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
@@ -56,7 +56,7 @@
 EXPORT_SYMBOL(lnet_acceptor_port);
 
 static inline int
-lnet_accept_magic(__u32 magic, __u32 constant)
+lnet_accept_magic(u32 magic, u32 constant)
 {
 	return (magic == constant ||
 		magic == __swab32(constant));
@@ -96,7 +96,7 @@
 
 void
 lnet_connect_console_error(int rc, lnet_nid_t peer_nid,
-			   __u32 peer_ip, int peer_port)
+			   u32 peer_ip, int peer_port)
 {
 	switch (rc) {
 	/* "normal" errors */
@@ -142,7 +142,7 @@
 
 int
 lnet_connect(struct socket **sockp, lnet_nid_t peer_nid,
-	     __u32 local_ip, __u32 peer_ip, int peer_port)
+	     u32 local_ip, u32 peer_ip, int peer_port)
 {
 	struct lnet_acceptor_connreq cr;
 	struct socket *sock;
@@ -205,10 +205,10 @@
 EXPORT_SYMBOL(lnet_connect);
 
 static int
-lnet_accept(struct socket *sock, __u32 magic)
+lnet_accept(struct socket *sock, u32 magic)
 {
 	struct lnet_acceptor_connreq cr;
-	__u32 peer_ip;
+	u32 peer_ip;
 	int peer_port;
 	int rc;
 	int flip;
@@ -328,8 +328,8 @@
 {
 	struct socket *newsock;
 	int rc;
-	__u32 magic;
-	__u32 peer_ip;
+	u32 magic;
+	u32 peer_ip;
 	int peer_port;
 	int secure = (int)((long)arg);
 
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 6d52824..be77e10 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -104,7 +104,7 @@ struct lnet the_lnet = {
 static int lnet_ping(struct lnet_process_id id, signed long timeout,
 		     struct lnet_process_id __user *ids, int n_ids);
 
-static int lnet_discover(struct lnet_process_id id, __u32 force,
+static int lnet_discover(struct lnet_process_id id, u32 force,
 			 struct lnet_process_id __user *ids, int n_ids);
 
 static int
@@ -420,7 +420,7 @@ static void lnet_assert_wire_constants(void)
 }
 
 static struct lnet_lnd *
-lnet_find_lnd_by_type(__u32 type)
+lnet_find_lnd_by_type(u32 type)
 {
 	struct lnet_lnd *lnd;
 
@@ -632,7 +632,7 @@ static void lnet_assert_wire_constants(void)
 }
 
 struct lnet_libhandle *
-lnet_res_lh_lookup(struct lnet_res_container *rec, __u64 cookie)
+lnet_res_lh_lookup(struct lnet_res_container *rec, u64 cookie)
 {
 	/* ALWAYS called with lnet_res_lock held */
 	struct list_head *head;
@@ -803,7 +803,7 @@ struct lnet_libhandle *
 }
 
 struct lnet_ni  *
-lnet_net2ni_locked(__u32 net_id, int cpt)
+lnet_net2ni_locked(u32 net_id, int cpt)
 {
 	struct lnet_ni *ni;
 	struct lnet_net *net;
@@ -822,7 +822,7 @@ struct lnet_ni  *
 }
 
 struct lnet_ni *
-lnet_net2ni_addref(__u32 net)
+lnet_net2ni_addref(u32 net)
 {
 	struct lnet_ni *ni;
 
@@ -837,7 +837,7 @@ struct lnet_ni *
 EXPORT_SYMBOL(lnet_net2ni_addref);
 
 struct lnet_net *
-lnet_get_net_locked(__u32 net_id)
+lnet_get_net_locked(u32 net_id)
 {
 	struct lnet_net *net;
 
@@ -852,7 +852,7 @@ struct lnet_net *
 unsigned int
 lnet_nid_cpt_hash(lnet_nid_t nid, unsigned int number)
 {
-	__u64 key = nid;
+	u64 key = nid;
 	unsigned int val;
 
 	LASSERT(number >= 1 && number <= LNET_CPT_NUMBER);
@@ -920,7 +920,7 @@ struct lnet_net *
 EXPORT_SYMBOL(lnet_cpt_of_nid);
 
 int
-lnet_islocalnet(__u32 net_id)
+lnet_islocalnet(u32 net_id)
 {
 	struct lnet_net *net;
 	int cpt;
@@ -2234,7 +2234,7 @@ void lnet_lib_exit(void)
 lnet_fill_ni_info(struct lnet_ni *ni, struct lnet_ioctl_config_ni *cfg_ni,
 		  struct lnet_ioctl_config_lnd_tunables *tun,
 		  struct lnet_ioctl_element_stats *stats,
-		  __u32 tun_size)
+		  u32 tun_size)
 {
 	size_t min_size = 0;
 	int i;
@@ -2471,7 +2471,7 @@ struct lnet_ni *
 lnet_get_ni_config(struct lnet_ioctl_config_ni *cfg_ni,
 		   struct lnet_ioctl_config_lnd_tunables *tun,
 		   struct lnet_ioctl_element_stats *stats,
-		   __u32 tun_size)
+		   u32 tun_size)
 {
 	struct lnet_ni *ni;
 	int cpt;
@@ -2848,7 +2848,7 @@ int lnet_dyn_del_ni(struct lnet_ioctl_config_ni *conf)
 }
 
 int
-lnet_dyn_del_net(__u32 net_id)
+lnet_dyn_del_net(u32 net_id)
 {
 	struct lnet_net *net;
 	struct lnet_ping_buffer *pbuf;
@@ -2980,7 +2980,7 @@ u32 lnet_get_dlc_seq_locked(void)
 		struct lnet_ioctl_config_ni *cfg_ni;
 		struct lnet_ioctl_config_lnd_tunables *tun = NULL;
 		struct lnet_ioctl_element_stats *stats;
-		__u32 tun_size;
+		u32 tun_size;
 
 		cfg_ni = arg;
 
@@ -3522,7 +3522,7 @@ static int lnet_ping(struct lnet_process_id id, signed long timeout,
 }
 
 static int
-lnet_discover(struct lnet_process_id id, __u32 force,
+lnet_discover(struct lnet_process_id id, u32 force,
 	      struct lnet_process_id __user *ids,
 	      int n_ids)
 {
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index 087d9a8..16c42bf 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -82,7 +82,7 @@ struct lnet_text_buf {	    /* tmp struct for parsing routes */
 }
 
 bool
-lnet_net_unique(__u32 net_id, struct list_head *netlist,
+lnet_net_unique(u32 net_id, struct list_head *netlist,
 		struct lnet_net **net)
 {
 	struct lnet_net *net_l;
@@ -136,7 +136,7 @@ struct lnet_text_buf {	    /* tmp struct for parsing routes */
 }
 
 static bool
-in_array(__u32 *array, __u32 size, __u32 value)
+in_array(u32 *array, u32 size, u32 value)
 {
 	int i;
 
@@ -149,9 +149,9 @@ struct lnet_text_buf {	    /* tmp struct for parsing routes */
 }
 
 static int
-lnet_net_append_cpts(__u32 *cpts, __u32 ncpts, struct lnet_net *net)
+lnet_net_append_cpts(u32 *cpts, u32 ncpts, struct lnet_net *net)
 {
-	__u32 *added_cpts = NULL;
+	u32 *added_cpts = NULL;
 	int i, j = 0, rc = 0;
 
 	/*
@@ -193,8 +193,8 @@ struct lnet_text_buf {	    /* tmp struct for parsing routes */
 
 	/* append the new cpts if any to the list of cpts in the net */
 	if (j > 0) {
-		__u32 *array = NULL, *loc;
-		__u32 total_entries = j + net->net_ncpts;
+		u32 *array = NULL, *loc;
+		u32 total_entries = j + net->net_ncpts;
 
 		array = kmalloc_array(total_entries, sizeof(*net->net_cpts),
 				      GFP_KERNEL);
@@ -220,7 +220,7 @@ struct lnet_text_buf {	    /* tmp struct for parsing routes */
 }
 
 static void
-lnet_net_remove_cpts(__u32 *cpts, __u32 ncpts, struct lnet_net *net)
+lnet_net_remove_cpts(u32 *cpts, u32 ncpts, struct lnet_net *net)
 {
 	struct lnet_ni *ni;
 	int rc;
@@ -344,7 +344,7 @@ struct lnet_text_buf {	    /* tmp struct for parsing routes */
 }
 
 struct lnet_net *
-lnet_net_alloc(__u32 net_id, struct list_head *net_list)
+lnet_net_alloc(u32 net_id, struct list_head *net_list)
 {
 	struct lnet_net *net;
 
@@ -525,7 +525,7 @@ struct lnet_ni *
 }
 
 struct lnet_ni *
-lnet_ni_alloc_w_cpt_array(struct lnet_net *net, __u32 *cpts, __u32 ncpts,
+lnet_ni_alloc_w_cpt_array(struct lnet_net *net, u32 *cpts, u32 ncpts,
 			  char *iface)
 {
 	struct lnet_ni *ni;
@@ -573,7 +573,7 @@ struct lnet_ni *
 	char *str;
 	struct lnet_net *net;
 	struct lnet_ni *ni = NULL;
-	__u32 net_id;
+	u32 net_id;
 	int nnets = 0;
 
 	if (!networks) {
@@ -1098,7 +1098,7 @@ struct lnet_ni *
 	struct list_head gateways;
 	struct list_head *tmp1;
 	struct list_head *tmp2;
-	__u32 net;
+	u32 net;
 	lnet_nid_t nid;
 	struct lnet_text_buf *ltb;
 	struct lnet_text_buf *ltb1, *ltb2;
@@ -1107,7 +1107,7 @@ struct lnet_ni *
 	char *token = str;
 	int ntokens = 0;
 	int myrc = -1;
-	__u32 hops;
+	u32 hops;
 	int got_hops = 0;
 	unsigned int priority = 0;
 
@@ -1276,7 +1276,7 @@ struct lnet_ni *
 }
 
 static int
-lnet_match_network_token(char *token, int len, __u32 *ipaddrs, int nip)
+lnet_match_network_token(char *token, int len, u32 *ipaddrs, int nip)
 {
 	LIST_HEAD(list);
 	int rc;
@@ -1295,7 +1295,7 @@ struct lnet_ni *
 }
 
 static int
-lnet_match_network_tokens(char *net_entry, __u32 *ipaddrs, int nip)
+lnet_match_network_tokens(char *net_entry, u32 *ipaddrs, int nip)
 {
 	static char tokens[LNET_SINGLE_TEXTBUF_NOB];
 
@@ -1352,11 +1352,11 @@ struct lnet_ni *
 	return 1;
 }
 
-static __u32
+static u32
 lnet_netspec2net(char *netspec)
 {
 	char *bracket = strchr(netspec, '(');
-	__u32 net;
+	u32 net;
 
 	if (bracket)
 		*bracket = 0;
@@ -1379,7 +1379,7 @@ struct lnet_ni *
 	struct lnet_text_buf *tb2;
 	char *sep;
 	char *bracket;
-	__u32 net;
+	u32 net;
 
 	LASSERT(!list_empty(nets));
 	LASSERT(nets->next == nets->prev);     /* single entry */
@@ -1447,7 +1447,7 @@ struct lnet_ni *
 }
 
 static int
-lnet_match_networks(char **networksp, char *ip2nets, __u32 *ipaddrs, int nip)
+lnet_match_networks(char **networksp, char *ip2nets, u32 *ipaddrs, int nip)
 {
 	static char networks[LNET_SINGLE_TEXTBUF_NOB];
 	static char source[LNET_SINGLE_TEXTBUF_NOB];
@@ -1459,8 +1459,8 @@ struct lnet_ni *
 	struct list_head *t2;
 	struct lnet_text_buf *tb;
 	struct lnet_text_buf *tb2;
-	__u32 net1;
-	__u32 net2;
+	u32 net1;
+	u32 net2;
 	int len;
 	int count;
 	int dup;
@@ -1563,10 +1563,10 @@ struct lnet_ni *
 }
 
 static int
-lnet_ipaddr_enumerate(__u32 **ipaddrsp)
+lnet_ipaddr_enumerate(u32 **ipaddrsp)
 {
 	struct net_device *dev;
-	__u32 *ipaddrs;
+	u32 *ipaddrs;
 	int nalloc = 64;
 	int nip;
 
@@ -1594,7 +1594,7 @@ struct lnet_ni *
 		}
 
 		if (nip >= nalloc) {
-			__u32 *ipaddrs2;
+			u32 *ipaddrs2;
 			nalloc += nalloc;
 			ipaddrs2 = krealloc(ipaddrs, nalloc * sizeof(*ipaddrs2),
 					    GFP_KERNEL);
@@ -1622,7 +1622,7 @@ struct lnet_ni *
 int
 lnet_parse_ip2nets(char **networksp, char *ip2nets)
 {
-	__u32 *ipaddrs = NULL;
+	u32 *ipaddrs = NULL;
 	int nip = lnet_ipaddr_enumerate(&ipaddrs);
 	int rc;
 
diff --git a/drivers/staging/lustre/lnet/lnet/lib-me.c b/drivers/staging/lustre/lnet/lnet/lib-me.c
index 672e37b..4a5ffb1 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-me.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-me.c
@@ -72,7 +72,7 @@
 int
 LNetMEAttach(unsigned int portal,
 	     struct lnet_process_id match_id,
-	     __u64 match_bits, __u64 ignore_bits,
+	     u64 match_bits, u64 ignore_bits,
 	     enum lnet_unlink unlink, enum lnet_ins_pos pos,
 	     struct lnet_handle_me *handle)
 {
@@ -143,7 +143,7 @@
 int
 LNetMEInsert(struct lnet_handle_me current_meh,
 	     struct lnet_process_id match_id,
-	     __u64 match_bits, __u64 ignore_bits,
+	     u64 match_bits, u64 ignore_bits,
 	     enum lnet_unlink unlink, enum lnet_ins_pos pos,
 	     struct lnet_handle_me *handle)
 {
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index eaa1dfa..639f67ed 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -94,7 +94,7 @@ void lnet_incr_stats(struct lnet_element_stats *stats,
 	}
 }
 
-__u32 lnet_sum_stats(struct lnet_element_stats *stats,
+u32 lnet_sum_stats(struct lnet_element_stats *stats,
 		     enum lnet_stats_type stats_type)
 {
 	struct lnet_comm_count *counts = get_stats_counts(stats, stats_type);
@@ -1845,7 +1845,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	 */
 	cpt2 = lnet_cpt_of_nid_locked(best_lpni->lpni_nid, best_ni);
 	if (cpt != cpt2) {
-		__u32 seq = lnet_get_dlc_seq_locked();
+		u32 seq = lnet_get_dlc_seq_locked();
 		lnet_net_unlock(cpt);
 		cpt = cpt2;
 		lnet_net_lock(cpt);
@@ -1962,7 +1962,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 
 void
 lnet_drop_message(struct lnet_ni *ni, int cpt, void *private, unsigned int nob,
-		  __u32 msg_type)
+		  u32 msg_type)
 {
 	lnet_net_lock(cpt);
 	lnet_incr_stats(&ni->ni_stats, msg_type, LNET_STATS_TYPE_DROP);
@@ -2383,8 +2383,8 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	lnet_nid_t dest_nid;
 	lnet_nid_t src_nid;
 	struct lnet_peer_ni *lpni;
-	__u32 payload_length;
-	__u32 type;
+	u32 payload_length;
+	u32 type;
 
 	LASSERT(!in_interrupt());
 
@@ -2418,7 +2418,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	case LNET_MSG_PUT:
 	case LNET_MSG_REPLY:
 		if (payload_length >
-		   (__u32)(for_me ? LNET_MAX_PAYLOAD : LNET_MTU)) {
+		   (u32)(for_me ? LNET_MAX_PAYLOAD : LNET_MTU)) {
 			CERROR("%s, src %s: bad %s payload %d (%d max expected)\n",
 			       libcfs_nid2str(from_nid),
 			       libcfs_nid2str(src_nid),
@@ -2741,8 +2741,8 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 int
 LNetPut(lnet_nid_t self, struct lnet_handle_md mdh, enum lnet_ack_req ack,
 	struct lnet_process_id target, unsigned int portal,
-	__u64 match_bits, unsigned int offset,
-	__u64 hdr_data)
+	u64 match_bits, unsigned int offset,
+	u64 hdr_data)
 {
 	struct lnet_msg *msg;
 	struct lnet_libmd *md;
@@ -2948,7 +2948,7 @@ struct lnet_msg *
 int
 LNetGet(lnet_nid_t self, struct lnet_handle_md mdh,
 	struct lnet_process_id target, unsigned int portal,
-	__u64 match_bits, unsigned int offset)
+	u64 match_bits, unsigned int offset)
 {
 	struct lnet_msg *msg;
 	struct lnet_libmd *md;
@@ -3037,14 +3037,14 @@ struct lnet_msg *
  * \retval -EHOSTUNREACH If \a dstnid is not reachable.
  */
 int
-LNetDist(lnet_nid_t dstnid, lnet_nid_t *srcnidp, __u32 *orderp)
+LNetDist(lnet_nid_t dstnid, lnet_nid_t *srcnidp, u32 *orderp)
 {
 	struct lnet_ni *ni = NULL;
 	struct lnet_remotenet *rnet;
-	__u32 dstnet = LNET_NIDNET(dstnid);
+	u32 dstnet = LNET_NIDNET(dstnid);
 	int hops;
 	int cpt;
-	__u32 order = 2;
+	u32 order = 2;
 	struct list_head *rn_list;
 
 	/*
@@ -3098,8 +3098,8 @@ struct lnet_msg *
 		if (rnet->lrn_net == dstnet) {
 			struct lnet_route *route;
 			struct lnet_route *shortest = NULL;
-			__u32 shortest_hops = LNET_UNDEFINED_HOPS;
-			__u32 route_hops;
+			u32 shortest_hops = LNET_UNDEFINED_HOPS;
+			u32 route_hops;
 
 			LASSERT(!list_empty(&rnet->lrn_routes));
 
diff --git a/drivers/staging/lustre/lnet/lnet/lib-ptl.c b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
index 6fa5bbf..fa391ee 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-ptl.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
@@ -41,7 +41,7 @@
 
 static int
 lnet_ptl_match_type(unsigned int index, struct lnet_process_id match_id,
-		    __u64 mbits, __u64 ignore_bits)
+		    u64 mbits, u64 ignore_bits)
 {
 	struct lnet_portal *ptl = the_lnet.ln_portals[index];
 	int unique;
@@ -213,7 +213,7 @@
 }
 
 static struct lnet_match_table *
-lnet_match2mt(struct lnet_portal *ptl, struct lnet_process_id id, __u64 mbits)
+lnet_match2mt(struct lnet_portal *ptl, struct lnet_process_id id, u64 mbits)
 {
 	if (LNET_CPT_NUMBER == 1)
 		return ptl->ptl_mtables[0]; /* the only one */
@@ -225,7 +225,7 @@
 
 struct lnet_match_table *
 lnet_mt_of_attach(unsigned int index, struct lnet_process_id id,
-		  __u64 mbits, __u64 ignore_bits, enum lnet_ins_pos pos)
+		  u64 mbits, u64 ignore_bits, enum lnet_ins_pos pos)
 {
 	struct lnet_portal *ptl;
 	struct lnet_match_table	*mtable;
@@ -316,7 +316,7 @@ struct lnet_match_table *
 static int
 lnet_mt_test_exhausted(struct lnet_match_table *mtable, int pos)
 {
-	__u64 *bmap;
+	u64 *bmap;
 	int i;
 
 	if (!lnet_ptl_is_wildcard(the_lnet.ln_portals[mtable->mt_portal]))
@@ -324,7 +324,7 @@ struct lnet_match_table *
 
 	if (pos < 0) { /* check all bits */
 		for (i = 0; i < LNET_MT_EXHAUSTED_BMAP; i++) {
-			if (mtable->mt_exhausted[i] != (__u64)(-1))
+			if (mtable->mt_exhausted[i] != (u64)(-1))
 				return 0;
 		}
 		return 1;
@@ -341,7 +341,7 @@ struct lnet_match_table *
 static void
 lnet_mt_set_exhausted(struct lnet_match_table *mtable, int pos, int exhausted)
 {
-	__u64 *bmap;
+	u64 *bmap;
 
 	LASSERT(lnet_ptl_is_wildcard(the_lnet.ln_portals[mtable->mt_portal]));
 	LASSERT(pos <= LNET_MT_HASH_IGNORE);
@@ -358,7 +358,7 @@ struct lnet_match_table *
 
 struct list_head *
 lnet_mt_match_head(struct lnet_match_table *mtable,
-		   struct lnet_process_id id, __u64 mbits)
+		   struct lnet_process_id id, u64 mbits)
 {
 	struct lnet_portal *ptl = the_lnet.ln_portals[mtable->mt_portal];
 	unsigned long hash = mbits;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
index 62a742e..cff3d1e 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -146,7 +146,7 @@
 EXPORT_SYMBOL(lnet_sock_read);
 
 static int
-lnet_sock_create(struct socket **sockp, int *fatal, __u32 local_ip,
+lnet_sock_create(struct socket **sockp, int *fatal, u32 local_ip,
 		 int local_port)
 {
 	struct sockaddr_in locaddr;
@@ -233,7 +233,7 @@
 EXPORT_SYMBOL(lnet_sock_setbuf);
 
 int
-lnet_sock_getaddr(struct socket *sock, bool remote, __u32 *ip, int *port)
+lnet_sock_getaddr(struct socket *sock, bool remote, u32 *ip, int *port)
 {
 	struct sockaddr_in sin;
 	int rc;
@@ -272,7 +272,7 @@
 EXPORT_SYMBOL(lnet_sock_getbuf);
 
 int
-lnet_sock_listen(struct socket **sockp, __u32 local_ip, int local_port,
+lnet_sock_listen(struct socket **sockp, u32 local_ip, int local_port,
 		 int backlog)
 {
 	int fatal;
@@ -337,8 +337,8 @@
 }
 
 int
-lnet_sock_connect(struct socket **sockp, int *fatal, __u32 local_ip,
-		  int local_port, __u32 peer_ip, int peer_port)
+lnet_sock_connect(struct socket **sockp, int *fatal, u32 local_ip,
+		  int local_port, u32 peer_ip, int peer_port)
 {
 	struct sockaddr_in srvaddr;
 	int rc;
diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
index 43d957f..0f2b75e 100644
--- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
+++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
@@ -465,12 +465,12 @@ int cfs_print_nidlist(char *buffer, int count, struct list_head *nidlist)
  * \param	min_nid
  * \param	max_nid
  */
-static void cfs_ip_ar_min_max(struct addrrange *ar, __u32 *min_nid,
-			      __u32 *max_nid)
+static void cfs_ip_ar_min_max(struct addrrange *ar, u32 *min_nid,
+			      u32 *max_nid)
 {
 	struct cfs_expr_list *el;
 	struct cfs_range_expr *re;
-	__u32 tmp_ip_addr = 0;
+	u32 tmp_ip_addr = 0;
 	unsigned int min_ip[4] = {0};
 	unsigned int max_ip[4] = {0};
 	int re_count = 0;
@@ -504,8 +504,8 @@ static void cfs_ip_ar_min_max(struct addrrange *ar, __u32 *min_nid,
  * \param	min_nid
  * \param	max_nid
  */
-static void cfs_num_ar_min_max(struct addrrange *ar, __u32 *min_nid,
-			       __u32 *max_nid)
+static void cfs_num_ar_min_max(struct addrrange *ar, u32 *min_nid,
+			       u32 *max_nid)
 {
 	struct cfs_expr_list *el;
 	struct cfs_range_expr *re;
@@ -581,9 +581,9 @@ static bool cfs_num_is_contiguous(struct list_head *nidlist)
 	struct cfs_expr_list *el;
 	struct cfs_range_expr *re;
 	int last_hi = 0;
-	__u32 last_end_nid = 0;
-	__u32 current_start_nid = 0;
-	__u32 current_end_nid = 0;
+	u32 last_end_nid = 0;
+	u32 current_start_nid = 0;
+	u32 current_end_nid = 0;
 
 	list_for_each_entry(nr, nidlist, nr_link) {
 		list_for_each_entry(ar, &nr->nr_addrranges, ar_link) {
@@ -629,9 +629,9 @@ static bool cfs_ip_is_contiguous(struct list_head *nidlist)
 	int expr_count;
 	int last_hi = 255;
 	int last_diff = 0;
-	__u32 last_end_nid = 0;
-	__u32 current_start_nid = 0;
-	__u32 current_end_nid = 0;
+	u32 last_end_nid = 0;
+	u32 current_start_nid = 0;
+	u32 current_end_nid = 0;
 
 	list_for_each_entry(nr, nidlist, nr_link) {
 		list_for_each_entry(ar, &nr->nr_addrranges, ar_link) {
@@ -678,8 +678,8 @@ void cfs_nidrange_find_min_max(struct list_head *nidlist, char *min_nid,
 	struct nidrange *nr;
 	struct netstrfns *nf = NULL;
 	int netnum = -1;
-	__u32 min_addr;
-	__u32 max_addr;
+	u32 min_addr;
+	u32 max_addr;
 	char *lndname = NULL;
 	char min_addr_str[IPSTRING_LENGTH];
 	char max_addr_str[IPSTRING_LENGTH];
@@ -709,8 +709,8 @@ void cfs_nidrange_find_min_max(struct list_head *nidlist, char *min_nid,
  * \param	*min_nid
  * \param	*max_nid
  */
-static void cfs_num_min_max(struct list_head *nidlist, __u32 *min_nid,
-			    __u32 *max_nid)
+static void cfs_num_min_max(struct list_head *nidlist, u32 *min_nid,
+			    u32 *max_nid)
 {
 	struct nidrange	*nr;
 	struct addrrange *ar;
@@ -741,15 +741,15 @@ static void cfs_num_min_max(struct list_head *nidlist, __u32 *min_nid,
  * \param	*min_nid
  * \param	*max_nid
  */
-static void cfs_ip_min_max(struct list_head *nidlist, __u32 *min_nid,
-			   __u32 *max_nid)
+static void cfs_ip_min_max(struct list_head *nidlist, u32 *min_nid,
+			   u32 *max_nid)
 {
 	struct nidrange *nr;
 	struct addrrange *ar;
-	__u32 tmp_min_ip_addr = 0;
-	__u32 tmp_max_ip_addr = 0;
-	__u32 min_ip_addr = 0;
-	__u32 max_ip_addr = 0;
+	u32 tmp_min_ip_addr = 0;
+	u32 tmp_max_ip_addr = 0;
+	u32 min_ip_addr = 0;
+	u32 max_ip_addr = 0;
 
 	list_for_each_entry(nr, nidlist, nr_link) {
 		list_for_each_entry(ar, &nr->nr_addrranges, ar_link) {
@@ -769,14 +769,14 @@ static void cfs_ip_min_max(struct list_head *nidlist, __u32 *min_nid,
 }
 
 static int
-libcfs_lo_str2addr(const char *str, int nob, __u32 *addr)
+libcfs_lo_str2addr(const char *str, int nob, u32 *addr)
 {
 	*addr = 0;
 	return 1;
 }
 
 static void
-libcfs_ip_addr2str(__u32 addr, char *str, size_t size)
+libcfs_ip_addr2str(u32 addr, char *str, size_t size)
 {
 	snprintf(str, size, "%u.%u.%u.%u",
 		 (addr >> 24) & 0xff, (addr >> 16) & 0xff,
@@ -792,7 +792,7 @@ static void cfs_ip_min_max(struct list_head *nidlist, __u32 *min_nid,
  * fine too :)
  */
 static int
-libcfs_ip_str2addr(const char *str, int nob, __u32 *addr)
+libcfs_ip_str2addr(const char *str, int nob, u32 *addr)
 {
 	unsigned int	a;
 	unsigned int	b;
@@ -873,7 +873,7 @@ static void cfs_ip_min_max(struct list_head *nidlist, __u32 *min_nid,
  * \retval 0 otherwise
  */
 int
-cfs_ip_addr_match(__u32 addr, struct list_head *list)
+cfs_ip_addr_match(u32 addr, struct list_head *list)
 {
 	struct cfs_expr_list *el;
 	int i = 0;
@@ -889,13 +889,13 @@ static void cfs_ip_min_max(struct list_head *nidlist, __u32 *min_nid,
 }
 
 static void
-libcfs_decnum_addr2str(__u32 addr, char *str, size_t size)
+libcfs_decnum_addr2str(u32 addr, char *str, size_t size)
 {
 	snprintf(str, size, "%u", addr);
 }
 
 static int
-libcfs_num_str2addr(const char *str, int nob, __u32 *addr)
+libcfs_num_str2addr(const char *str, int nob, u32 *addr)
 {
 	int     n;
 
@@ -955,7 +955,7 @@ static void cfs_ip_min_max(struct list_head *nidlist, __u32 *min_nid,
  * \retval 0 otherwise
  */
 static int
-libcfs_num_match(__u32 addr, struct list_head *numaddr)
+libcfs_num_match(u32 addr, struct list_head *numaddr)
 {
 	struct cfs_expr_list *el;
 
@@ -1021,7 +1021,7 @@ static void cfs_ip_min_max(struct list_head *nidlist, __u32 *min_nid,
 static const size_t libcfs_nnetstrfns = ARRAY_SIZE(libcfs_netstrfns);
 
 static struct netstrfns *
-libcfs_lnd2netstrfns(__u32 lnd)
+libcfs_lnd2netstrfns(u32 lnd)
 {
 	int i;
 
@@ -1059,14 +1059,14 @@ static void cfs_ip_min_max(struct list_head *nidlist, __u32 *min_nid,
 }
 
 int
-libcfs_isknown_lnd(__u32 lnd)
+libcfs_isknown_lnd(u32 lnd)
 {
 	return !!libcfs_lnd2netstrfns(lnd);
 }
 EXPORT_SYMBOL(libcfs_isknown_lnd);
 
 char *
-libcfs_lnd2modname(__u32 lnd)
+libcfs_lnd2modname(u32 lnd)
 {
 	struct netstrfns *nf = libcfs_lnd2netstrfns(lnd);
 
@@ -1087,7 +1087,7 @@ static void cfs_ip_min_max(struct list_head *nidlist, __u32 *min_nid,
 EXPORT_SYMBOL(libcfs_str2lnd);
 
 char *
-libcfs_lnd2str_r(__u32 lnd, char *buf, size_t buf_size)
+libcfs_lnd2str_r(u32 lnd, char *buf, size_t buf_size)
 {
 	struct netstrfns *nf;
 
@@ -1102,10 +1102,10 @@ static void cfs_ip_min_max(struct list_head *nidlist, __u32 *min_nid,
 EXPORT_SYMBOL(libcfs_lnd2str_r);
 
 char *
-libcfs_net2str_r(__u32 net, char *buf, size_t buf_size)
+libcfs_net2str_r(u32 net, char *buf, size_t buf_size)
 {
-	__u32 nnum = LNET_NETNUM(net);
-	__u32 lnd = LNET_NETTYP(net);
+	u32 nnum = LNET_NETNUM(net);
+	u32 lnd = LNET_NETTYP(net);
 	struct netstrfns *nf;
 
 	nf = libcfs_lnd2netstrfns(lnd);
@@ -1123,10 +1123,10 @@ static void cfs_ip_min_max(struct list_head *nidlist, __u32 *min_nid,
 char *
 libcfs_nid2str_r(lnet_nid_t nid, char *buf, size_t buf_size)
 {
-	__u32 addr = LNET_NIDADDR(nid);
-	__u32 net = LNET_NIDNET(nid);
-	__u32 nnum = LNET_NETNUM(net);
-	__u32 lnd = LNET_NETTYP(net);
+	u32 addr = LNET_NIDADDR(nid);
+	u32 net = LNET_NIDNET(nid);
+	u32 nnum = LNET_NETNUM(net);
+	u32 lnd = LNET_NETTYP(net);
 	struct netstrfns *nf;
 
 	if (nid == LNET_NID_ANY) {
@@ -1156,7 +1156,7 @@ static void cfs_ip_min_max(struct list_head *nidlist, __u32 *min_nid,
 EXPORT_SYMBOL(libcfs_nid2str_r);
 
 static struct netstrfns *
-libcfs_str2net_internal(const char *str, __u32 *net)
+libcfs_str2net_internal(const char *str, u32 *net)
 {
 	struct netstrfns *nf = NULL;
 	int nob;
@@ -1191,10 +1191,10 @@ static void cfs_ip_min_max(struct list_head *nidlist, __u32 *min_nid,
 	return nf;
 }
 
-__u32
+u32
 libcfs_str2net(const char *str)
 {
-	__u32  net;
+	u32  net;
 
 	if (libcfs_str2net_internal(str, &net))
 		return net;
@@ -1208,8 +1208,8 @@ static void cfs_ip_min_max(struct list_head *nidlist, __u32 *min_nid,
 {
 	const char *sep = strchr(str, '@');
 	struct netstrfns *nf;
-	__u32 net;
-	__u32 addr;
+	u32 net;
+	u32 addr;
 
 	if (sep) {
 		nf = libcfs_str2net_internal(sep + 1, &net);
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index db36b5c..d807dd4 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -697,17 +697,17 @@ struct lnet_peer_ni *
 
 /* Call with the ln_api_mutex held */
 int
-lnet_get_peer_list(__u32 *countp, __u32 *sizep,
+lnet_get_peer_list(u32 *countp, u32 *sizep,
 		   struct lnet_process_id __user *ids)
 {
 	struct lnet_process_id id;
 	struct lnet_peer_table *ptable;
 	struct lnet_peer *lp;
-	__u32 count = 0;
-	__u32 size = 0;
+	u32 count = 0;
+	u32 size = 0;
 	int lncpt;
 	int cpt;
-	__u32 i;
+	u32 i;
 	int rc;
 
 	rc = -ESHUTDOWN;
@@ -3234,12 +3234,12 @@ void lnet_peer_discovery_stop(void)
 /* Gathering information for userspace. */
 
 int
-lnet_get_peer_ni_info(__u32 peer_index, __u64 *nid,
+lnet_get_peer_ni_info(u32 peer_index, u64 *nid,
 		      char aliveness[LNET_MAX_STR_LEN],
-		      __u32 *cpt_iter, __u32 *refcount,
-		      __u32 *ni_peer_tx_credits, __u32 *peer_tx_credits,
-		      __u32 *peer_rtr_credits, __u32 *peer_min_rtr_credits,
-		      __u32 *peer_tx_qnob)
+		      u32 *cpt_iter, u32 *refcount,
+		      u32 *ni_peer_tx_credits, u32 *peer_tx_credits,
+		      u32 *peer_rtr_credits, u32 *peer_min_rtr_credits,
+		      u32 *peer_tx_qnob)
 {
 	struct lnet_peer_table *peer_table;
 	struct lnet_peer_ni *lp;
@@ -3305,7 +3305,7 @@ int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk)
 	struct lnet_peer_ni *lpni;
 	struct lnet_peer *lp;
 	lnet_nid_t nid;
-	__u32 size;
+	u32 size;
 	int rc;
 
 	lp = lnet_find_peer(cfg->prcfg_prim_nid);
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 86cce27..22c88ec 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -247,7 +247,7 @@
 }
 
 struct lnet_remotenet *
-lnet_find_rnet_locked(__u32 net)
+lnet_find_rnet_locked(u32 net)
 {
 	struct lnet_remotenet *rnet;
 	struct list_head *rn_list;
@@ -273,7 +273,7 @@ static void lnet_shuffle_seed(void)
 	/* Nodes with small feet have little entropy
 	 * the NID for this node gives the most entropy in the low bits */
 	while ((ni = lnet_get_next_ni_locked(NULL, ni))) {
-		__u32 lnd_type, seed;
+		u32 lnd_type, seed;
 		lnd_type = LNET_NETTYP(LNET_NIDNET(ni->ni_nid));
 		if (lnd_type != LOLND) {
 			seed = (LNET_NIDADDR(ni->ni_nid) | lnd_type);
@@ -313,7 +313,7 @@ static void lnet_shuffle_seed(void)
 }
 
 int
-lnet_add_route(__u32 net, __u32 hops, lnet_nid_t gateway,
+lnet_add_route(u32 net, u32 hops, lnet_nid_t gateway,
 	       unsigned int priority)
 {
 	struct lnet_remotenet *rnet;
@@ -479,7 +479,7 @@ static void lnet_shuffle_seed(void)
 }
 
 int
-lnet_del_route(__u32 net, lnet_nid_t gw_nid)
+lnet_del_route(u32 net, lnet_nid_t gw_nid)
 {
 	struct lnet_peer_ni *gateway;
 	struct lnet_remotenet *rnet;
@@ -585,8 +585,8 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 }
 
 int
-lnet_get_route(int idx, __u32 *net, __u32 *hops,
-	       lnet_nid_t *gateway, __u32 *alive, __u32 *priority)
+lnet_get_route(int idx, u32 *net, u32 *hops,
+	       lnet_nid_t *gateway, u32 *alive, u32 *priority)
 {
 	struct lnet_remotenet *rnet;
 	struct lnet_route *route;
@@ -836,7 +836,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 }
 
 void
-lnet_router_ni_update_locked(struct lnet_peer_ni *gw, __u32 net)
+lnet_router_ni_update_locked(struct lnet_peer_ni *gw, u32 net)
 {
 	struct lnet_route *rte;
 
@@ -1274,7 +1274,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 	struct lnet_peer_ni *rtr;
 
 	while (the_lnet.ln_rc_state == LNET_RC_STATE_RUNNING) {
-		__u64 version;
+		u64 version;
 		int cpt;
 		int cpt2;
 
diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
index 236b5a1..e8cc70f 100644
--- a/drivers/staging/lustre/lnet/lnet/router_proc.c
+++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
@@ -211,8 +211,8 @@ static int proc_lnet_routes(struct ctl_table *table, int write,
 		}
 
 		if (route) {
-			__u32 net = rnet->lrn_net;
-			__u32 hops = route->lr_hops;
+			u32 net = rnet->lrn_net;
+			u32 hops = route->lr_hops;
 			unsigned int priority = route->lr_priority;
 			lnet_nid_t nid = route->lr_gateway->lpni_nid;
 			int alive = lnet_is_route_alive(route);
-- 
1.8.3.1
