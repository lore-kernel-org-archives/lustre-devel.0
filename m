From: James Simmons <jsimmons@infradead.org>
Date: Sun, 26 Feb 2017 19:41:51 -0500
Subject: [lustre-devel] [PATCH 26/34] staging: lustre: lnet: change
	lnet_process_id_t to proper structure
In-Reply-To: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
References: <1488156119-19670-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1488156119-19670-27-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

Change lnet_process_id_t from typedef to proper structure.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/20831
Reviewed-by: Olaf Weber <olaf@sgi.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/api.h    | 12 ++++----
 .../staging/lustre/include/linux/lnet/lib-lnet.h   | 11 +++----
 .../staging/lustre/include/linux/lnet/lib-types.h  |  6 ++--
 drivers/staging/lustre/include/linux/lnet/lnetst.h | 12 ++++----
 drivers/staging/lustre/include/linux/lnet/nidstr.h |  2 +-
 drivers/staging/lustre/include/linux/lnet/types.h  | 12 ++++----
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |  4 +--
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    | 26 ++++++++--------
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    | 15 +++++-----
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c | 11 +++----
 drivers/staging/lustre/lnet/lnet/api-ni.c          | 24 +++++++--------
 drivers/staging/lustre/lnet/lnet/lib-me.c          |  6 ++--
 drivers/staging/lustre/lnet/lnet/lib-move.c        | 20 ++++++-------
 drivers/staging/lustre/lnet/lnet/lib-ptl.c         |  8 ++---
 drivers/staging/lustre/lnet/lnet/nidstrings.c      |  2 +-
 drivers/staging/lustre/lnet/lnet/router.c          |  2 +-
 drivers/staging/lustre/lnet/selftest/brw_test.c    |  4 +--
 drivers/staging/lustre/lnet/selftest/conrpc.c      |  2 +-
 drivers/staging/lustre/lnet/selftest/console.c     | 35 +++++++++++-----------
 drivers/staging/lustre/lnet/selftest/console.h     | 14 +++++----
 drivers/staging/lustre/lnet/selftest/framework.c   |  4 +--
 drivers/staging/lustre/lnet/selftest/ping_test.c   |  2 +-
 drivers/staging/lustre/lnet/selftest/rpc.c         | 11 +++----
 drivers/staging/lustre/lnet/selftest/selftest.h    | 22 +++++++-------
 drivers/staging/lustre/lustre/include/lustre_net.h |  8 ++---
 drivers/staging/lustre/lustre/llite/llite_lib.c    |  2 +-
 drivers/staging/lustre/lustre/llite/super25.c      |  2 +-
 drivers/staging/lustre/lustre/osc/osc_request.c    |  5 ++--
 drivers/staging/lustre/lustre/ptlrpc/client.c      |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/connection.c  |  6 ++--
 drivers/staging/lustre/lustre/ptlrpc/events.c      |  2 +-
 drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |  4 +--
 32 files changed, 153 insertions(+), 145 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/api.h b/drivers/staging/lustre/include/linux/lnet/api.h
index b46a769..7a67fd2 100644
--- a/drivers/staging/lustre/include/linux/lnet/api.h
+++ b/drivers/staging/lustre/include/linux/lnet/api.h
@@ -74,7 +74,7 @@
  * \see LNetMEAttach
  * @{
  */
-int LNetGetId(unsigned int index, lnet_process_id_t *id);
+int LNetGetId(unsigned int index, struct lnet_process_id *id);
 int LNetDist(lnet_nid_t nid, lnet_nid_t *srcnid, __u32 *order);
 
 /** @} lnet_addr */
@@ -93,7 +93,7 @@
  * @{
  */
 int LNetMEAttach(unsigned int      portal,
-		 lnet_process_id_t match_id_in,
+		 struct lnet_process_id match_id_in,
 		 __u64		   match_bits_in,
 		 __u64		   ignore_bits_in,
 		 lnet_unlink_t     unlink_in,
@@ -101,7 +101,7 @@ int LNetMEAttach(unsigned int      portal,
 		 struct lnet_handle_me *handle_out);
 
 int LNetMEInsert(struct lnet_handle_me current_in,
-		 lnet_process_id_t match_id_in,
+		 struct lnet_process_id match_id_in,
 		 __u64		   match_bits_in,
 		 __u64		   ignore_bits_in,
 		 lnet_unlink_t     unlink_in,
@@ -181,7 +181,7 @@ int LNetEQPoll(struct lnet_handle_eq *eventqs_in,
 int LNetPut(lnet_nid_t	      self,
 	    struct lnet_handle_md md_in,
 	    lnet_ack_req_t    ack_req_in,
-	    lnet_process_id_t target_in,
+	    struct lnet_process_id target_in,
 	    unsigned int      portal_in,
 	    __u64	      match_bits_in,
 	    unsigned int      offset_in,
@@ -189,7 +189,7 @@ int LNetPut(lnet_nid_t	      self,
 
 int LNetGet(lnet_nid_t	      self,
 	    struct lnet_handle_md md_in,
-	    lnet_process_id_t target_in,
+	    struct lnet_process_id target_in,
 	    unsigned int      portal_in,
 	    __u64	      match_bits_in,
 	    unsigned int      offset_in);
@@ -202,7 +202,7 @@ int LNetGet(lnet_nid_t	      self,
 int LNetSetLazyPortal(int portal);
 int LNetClearLazyPortal(int portal);
 int LNetCtl(unsigned int cmd, void *arg);
-void LNetDebugPeer(lnet_process_id_t id);
+void LNetDebugPeer(struct lnet_process_id id);
 
 /** @} lnet_misc */
 
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index d770a03..e21323f 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -491,8 +491,9 @@ void lnet_msg_attach_md(struct lnet_msg *msg, struct lnet_libmd *md,
 void lnet_msg_decommit(struct lnet_msg *msg, int cpt, int status);
 
 void lnet_eq_enqueue_event(struct lnet_eq *eq, struct lnet_event *ev);
-void lnet_prep_send(struct lnet_msg *msg, int type, lnet_process_id_t target,
-		    unsigned int offset, unsigned int len);
+void lnet_prep_send(struct lnet_msg *msg, int type,
+		    struct lnet_process_id target, unsigned int offset,
+		    unsigned int len);
 int lnet_send(lnet_nid_t nid, struct lnet_msg *msg, lnet_nid_t rtr_nid);
 void lnet_return_tx_credits_locked(struct lnet_msg *msg);
 void lnet_return_rx_credits_locked(struct lnet_msg *msg);
@@ -533,10 +534,10 @@ void lnet_prep_send(struct lnet_msg *msg, int type, lnet_process_id_t target,
 
 /* match-table functions */
 struct list_head *lnet_mt_match_head(struct lnet_match_table *mtable,
-				     lnet_process_id_t id, __u64 mbits);
+				     struct lnet_process_id id, __u64 mbits);
 struct lnet_match_table *lnet_mt_of_attach(unsigned int index,
-					   lnet_process_id_t id, __u64 mbits,
-					   __u64 ignore_bits,
+					   struct lnet_process_id id,
+					   __u64 mbits, __u64 ignore_bits,
 					   lnet_ins_pos_t pos);
 int lnet_mt_match_md(struct lnet_match_table *mtable,
 		     struct lnet_match_info *info, struct lnet_msg *msg);
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 808a05c..81c93d4 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -58,7 +58,7 @@ struct lnet_msg {
 	struct list_head	msg_activelist;
 	struct list_head	msg_list;	   /* Q for credits/MD */
 
-	lnet_process_id_t	msg_target;
+	struct lnet_process_id	msg_target;
 	/* where is it from, it's only for building event */
 	lnet_nid_t		msg_from;
 	__u32			msg_type;
@@ -130,7 +130,7 @@ struct lnet_eq {
 struct lnet_me {
 	struct list_head	 me_list;
 	struct lnet_libhandle	 me_lh;
-	lnet_process_id_t	 me_match_id;
+	struct lnet_process_id	 me_match_id;
 	unsigned int		 me_portal;
 	unsigned int		 me_pos;	/* hash offset in mt_hash */
 	__u64			 me_match_bits;
@@ -447,7 +447,7 @@ enum lnet_match_flags {
 /* parameter for matching operations (GET, PUT) */
 struct lnet_match_info {
 	__u64			mi_mbits;
-	lnet_process_id_t	mi_id;
+	struct lnet_process_id	mi_id;
 	unsigned int		mi_opc;
 	unsigned int		mi_portal;
 	unsigned int		mi_rlength;
diff --git a/drivers/staging/lustre/include/linux/lnet/lnetst.h b/drivers/staging/lustre/include/linux/lnet/lnetst.h
index c81c246..ea736f8 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -86,7 +86,7 @@ struct lst_bid {
 #define LST_NODE_UNKNOWN	0x8	/* node not in session */
 
 struct lstcon_node_ent {
-	lnet_process_id_t       nde_id;		/* id of node */
+	struct lnet_process_id	nde_id;		/* id of node */
 	int			nde_state;	/* state of node */
 };				/*** node entry, for list_group command */
 
@@ -126,7 +126,7 @@ struct lstcon_test_batch_ent {
 
 struct lstcon_rpc_ent {
 	struct list_head	rpe_link;	/* link chain */
-	lnet_process_id_t	rpe_peer;	/* peer's id */
+	struct lnet_process_id	rpe_peer;	/* peer's id */
 	struct timeval		rpe_stamp;	/* time stamp of RPC */
 	int			rpe_state;	/* peer's state */
 	int			rpe_rpc_errno;	/* RPC errno */
@@ -287,7 +287,7 @@ struct lstio_debug_args {
 							       group|batch */
 	int			 lstio_dbg_count;	/* IN: # of test nodes
 							       to debug */
-	lnet_process_id_t __user *lstio_dbg_idsp;	/* IN: id of test
+	struct lnet_process_id __user *lstio_dbg_idsp;	/* IN: id of test
 							       nodes */
 	struct list_head __user	*lstio_dbg_resultp;	/* OUT: list head of
 								result buffer */
@@ -317,7 +317,7 @@ struct lstio_group_update_args {
 	int			 lstio_grp_nmlen;	/* IN: name length */
 	char __user		*lstio_grp_namep;	/* IN: group name */
 	int			 lstio_grp_count;	/* IN: # of nodes id */
-	lnet_process_id_t __user *lstio_grp_idsp;	/* IN: array of nodes */
+	struct lnet_process_id __user *lstio_grp_idsp;	/* IN: array of nodes */
 	struct list_head __user	*lstio_grp_resultp;	/* OUT: list head of
 								result buffer */
 };
@@ -329,7 +329,7 @@ struct lstio_group_nodes_args {
 	int			 lstio_grp_count;	/* IN: # of nodes */
 	/** OUT: session features */
 	unsigned int __user	*lstio_grp_featp;
-	lnet_process_id_t __user *lstio_grp_idsp;	/* IN: nodes */
+	struct lnet_process_id __user *lstio_grp_idsp;	/* IN: nodes */
 	struct list_head __user	*lstio_grp_resultp;	/* OUT: list head of
 								result buffer */
 };
@@ -429,7 +429,7 @@ struct lstio_stat_args {
 							       length */
 	char __user		*lstio_sta_namep;	/* IN: group name */
 	int			 lstio_sta_count;	/* IN: # of pid */
-	lnet_process_id_t __user *lstio_sta_idsp;	/* IN: pid */
+	struct lnet_process_id __user *lstio_sta_idsp;	/* IN: pid */
 	struct list_head __user	*lstio_sta_resultp;	/* OUT: list head of
 								result buffer */
 };
diff --git a/drivers/staging/lustre/include/linux/lnet/nidstr.h b/drivers/staging/lustre/include/linux/lnet/nidstr.h
index 937fcc9..ecdd0db 100644
--- a/drivers/staging/lustre/include/linux/lnet/nidstr.h
+++ b/drivers/staging/lustre/include/linux/lnet/nidstr.h
@@ -88,7 +88,7 @@ static inline char *libcfs_nid2str(lnet_nid_t nid)
 __u32 libcfs_str2net(const char *str);
 lnet_nid_t libcfs_str2nid(const char *str);
 int libcfs_str2anynid(lnet_nid_t *nid, const char *str);
-char *libcfs_id2str(lnet_process_id_t id);
+char *libcfs_id2str(struct lnet_process_id id);
 void cfs_free_nidlist(struct list_head *list);
 int cfs_parse_nidlist(char *str, int len, struct list_head *list);
 int cfs_print_nidlist(char *buffer, int count, struct list_head *list);
diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/linux/lnet/types.h
index 53eb1da..74118d0 100644
--- a/drivers/staging/lustre/include/linux/lnet/types.h
+++ b/drivers/staging/lustre/include/linux/lnet/types.h
@@ -64,7 +64,7 @@
 typedef __u64 lnet_nid_t;
 /**
  * ID of a process in a node. Shortened as PID to distinguish from
- * lnet_process_id_t, the global process ID.
+ * lnet_process_id, the global process ID.
  */
 typedef __u32 lnet_pid_t;
 
@@ -114,7 +114,7 @@ static inline __u32 LNET_MKNET(__u32 type, __u32 num)
 
 #define WIRE_ATTR	__packed
 
-/* Packed version of lnet_process_id_t to transfer via network */
+/* Packed version of lnet_process_id to transfer via network */
 struct lnet_process_id_packed {
 	/* node id / process id */
 	lnet_nid_t	nid;
@@ -330,12 +330,12 @@ struct lnet_handle_me {
 /**
  * Global process ID.
  */
-typedef struct {
+struct lnet_process_id {
 	/** node id */
 	lnet_nid_t nid;
 	/** process id */
 	lnet_pid_t pid;
-} lnet_process_id_t;
+};
 /** @} lnet_addr */
 
 /** \addtogroup lnet_me
@@ -570,9 +570,9 @@ struct lnet_md {
  */
 struct lnet_event {
 	/** The identifier (nid, pid) of the target. */
-	lnet_process_id_t	target;
+	struct lnet_process_id	target;
 	/** The identifier (nid, pid) of the initiator. */
-	lnet_process_id_t	initiator;
+	struct lnet_process_id	initiator;
 	/**
 	 * The NID of the immediate sender. If the request has been forwarded
 	 * by routers, this is the NID of the last hop; otherwise it's the
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 0c9b40f..e850f4c 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1482,7 +1482,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 {
 	struct lnet_hdr *hdr = &lntmsg->msg_hdr;
 	int type = lntmsg->msg_type;
-	lnet_process_id_t target = lntmsg->msg_target;
+	struct lnet_process_id target = lntmsg->msg_target;
 	int target_is_router = lntmsg->msg_target_is_router;
 	int routing = lntmsg->msg_routing;
 	unsigned int payload_niov = lntmsg->msg_niov;
@@ -1653,7 +1653,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 static void
 kiblnd_reply(struct lnet_ni *ni, struct kib_rx *rx, struct lnet_msg *lntmsg)
 {
-	lnet_process_id_t target = lntmsg->msg_target;
+	struct lnet_process_id target = lntmsg->msg_target;
 	unsigned int niov = lntmsg->msg_niov;
 	struct kvec *iov = lntmsg->msg_iov;
 	lnet_kiov_t *kiov = lntmsg->msg_kiov;
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index f92fa4b..fbbd8a5 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -97,7 +97,7 @@
 
 static int
 ksocknal_create_peer(struct ksock_peer **peerp, struct lnet_ni *ni,
-		     lnet_process_id_t id)
+		     struct lnet_process_id id)
 {
 	int cpt = lnet_cpt_of_nid(id.nid);
 	struct ksock_net *net = ni->ni_data;
@@ -173,7 +173,7 @@
 }
 
 struct ksock_peer *
-ksocknal_find_peer_locked(struct lnet_ni *ni, lnet_process_id_t id)
+ksocknal_find_peer_locked(struct lnet_ni *ni, struct lnet_process_id id)
 {
 	struct list_head *peer_list = ksocknal_nid2peerlist(id.nid);
 	struct list_head *tmp;
@@ -200,7 +200,7 @@ struct ksock_peer *
 }
 
 struct ksock_peer *
-ksocknal_find_peer(struct lnet_ni *ni, lnet_process_id_t id)
+ksocknal_find_peer(struct lnet_ni *ni, struct lnet_process_id id)
 {
 	struct ksock_peer *peer;
 
@@ -247,7 +247,7 @@ struct ksock_peer *
 
 static int
 ksocknal_get_peer_info(struct lnet_ni *ni, int index,
-		       lnet_process_id_t *id, __u32 *myip, __u32 *peer_ip,
+		       struct lnet_process_id *id, __u32 *myip, __u32 *peer_ip,
 		       int *port, int *conn_count, int *share_count)
 {
 	struct ksock_peer *peer;
@@ -450,7 +450,7 @@ struct ksock_peer *
 }
 
 int
-ksocknal_add_peer(struct lnet_ni *ni, lnet_process_id_t id, __u32 ipaddr,
+ksocknal_add_peer(struct lnet_ni *ni, struct lnet_process_id id, __u32 ipaddr,
 		  int port)
 {
 	struct list_head *tmp;
@@ -569,7 +569,7 @@ struct ksock_peer *
 }
 
 static int
-ksocknal_del_peer(struct lnet_ni *ni, lnet_process_id_t id, __u32 ip)
+ksocknal_del_peer(struct lnet_ni *ni, struct lnet_process_id id, __u32 ip)
 {
 	LIST_HEAD(zombies);
 	struct list_head *ptmp;
@@ -1031,7 +1031,7 @@ struct ksock_peer *
 {
 	rwlock_t *global_lock = &ksocknal_data.ksnd_global_lock;
 	LIST_HEAD(zombies);
-	lnet_process_id_t peerid;
+	struct lnet_process_id peerid;
 	struct list_head *tmp;
 	__u64 incarnation;
 	struct ksock_conn *conn;
@@ -1764,7 +1764,7 @@ struct ksock_peer *
 }
 
 int
-ksocknal_close_matching_conns(lnet_process_id_t id, __u32 ipaddr)
+ksocknal_close_matching_conns(struct lnet_process_id id, __u32 ipaddr)
 {
 	struct ksock_peer *peer;
 	struct list_head *ptmp;
@@ -1817,7 +1817,7 @@ struct ksock_peer *
 	 * The router is telling me she's been notified of a change in
 	 * gateway state....
 	 */
-	lnet_process_id_t id = {0};
+	struct lnet_process_id id = {0};
 
 	id.nid = gw_nid;
 	id.pid = LNET_PID_ANY;
@@ -1845,7 +1845,7 @@ struct ksock_peer *
 	unsigned long now = cfs_time_current();
 	struct ksock_peer *peer = NULL;
 	rwlock_t *glock = &ksocknal_data.ksnd_global_lock;
-	lnet_process_id_t id = {
+	struct lnet_process_id id = {
 		.nid = nid,
 		.pid = LNET_PID_LUSTRE,
 	};
@@ -1933,7 +1933,7 @@ struct ksock_peer *
 	}
 }
 
-static int ksocknal_push(struct lnet_ni *ni, lnet_process_id_t id)
+static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 {
 	struct list_head *start;
 	struct list_head *end;
@@ -2135,7 +2135,7 @@ static int ksocknal_push(struct lnet_ni *ni, lnet_process_id_t id)
 int
 ksocknal_ctl(struct lnet_ni *ni, unsigned int cmd, void *arg)
 {
-	lnet_process_id_t id = {0};
+	struct lnet_process_id id = {0};
 	struct libcfs_ioctl_data *data = arg;
 	int rc;
 
@@ -2592,7 +2592,7 @@ static int ksocknal_push(struct lnet_ni *ni, lnet_process_id_t id)
 {
 	struct ksock_net *net = ni->ni_data;
 	int i;
-	lnet_process_id_t anyid = {0};
+	struct lnet_process_id anyid = {0};
 
 	anyid.nid = LNET_NID_ANY;
 	anyid.pid = LNET_PID_ANY;
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index 99fec18..3f48b60 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -428,7 +428,7 @@ struct ksock_peer {
 	unsigned long      ksnp_last_alive;     /* when (in jiffies) I was last
 						 * alive
 						 */
-	lnet_process_id_t  ksnp_id;             /* who's on the other end(s) */
+	struct lnet_process_id  ksnp_id;	/* who's on the other end(s) */
 	atomic_t           ksnp_refcount;       /* # users */
 	int                ksnp_sharecount;     /* lconf usage counter */
 	int                ksnp_closing;        /* being closed */
@@ -655,12 +655,12 @@ int ksocknal_recv(struct lnet_ni *ni, void *private, struct lnet_msg *lntmsg,
 		  int delayed, struct iov_iter *to, unsigned int rlen);
 int ksocknal_accept(struct lnet_ni *ni, struct socket *sock);
 
-int ksocknal_add_peer(struct lnet_ni *ni, lnet_process_id_t id, __u32 ip,
+int ksocknal_add_peer(struct lnet_ni *ni, struct lnet_process_id id, __u32 ip,
 		      int port);
 struct ksock_peer *ksocknal_find_peer_locked(struct lnet_ni *ni,
-					     lnet_process_id_t id);
+					     struct lnet_process_id id);
 struct ksock_peer *ksocknal_find_peer(struct lnet_ni *ni,
-				      lnet_process_id_t id);
+				      struct lnet_process_id id);
 void ksocknal_peer_failed(struct ksock_peer *peer);
 int ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
 			 struct socket *sock, int type);
@@ -670,12 +670,12 @@ int ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
 int  ksocknal_close_peer_conns_locked(struct ksock_peer *peer,
 				      __u32 ipaddr, int why);
 int ksocknal_close_conn_and_siblings(struct ksock_conn *conn, int why);
-int ksocknal_close_matching_conns(lnet_process_id_t id, __u32 ipaddr);
+int ksocknal_close_matching_conns(struct lnet_process_id id, __u32 ipaddr);
 struct ksock_conn *ksocknal_find_conn_locked(struct ksock_peer *peer,
 					     struct ksock_tx *tx, int nonblk);
 
 int  ksocknal_launch_packet(struct lnet_ni *ni, struct ksock_tx *tx,
-			    lnet_process_id_t id);
+			    struct lnet_process_id id);
 struct ksock_tx *ksocknal_alloc_tx(int type, int size);
 void ksocknal_free_tx(struct ksock_tx *tx);
 struct ksock_tx *ksocknal_alloc_tx_noop(__u64 cookie, int nonblk);
@@ -696,7 +696,8 @@ int  ksocknal_launch_packet(struct lnet_ni *ni, struct ksock_tx *tx,
 int ksocknal_send_hello(struct lnet_ni *ni, struct ksock_conn *conn,
 			lnet_nid_t peer_nid, struct ksock_hello_msg *hello);
 int ksocknal_recv_hello(struct lnet_ni *ni, struct ksock_conn *conn,
-			struct ksock_hello_msg *hello, lnet_process_id_t *id,
+			struct ksock_hello_msg *hello,
+			struct lnet_process_id *id,
 			__u64 *incarnation);
 void ksocknal_read_callback(struct ksock_conn *conn);
 void ksocknal_write_callback(struct ksock_conn *conn);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index 8cea4f6..695b586 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -846,7 +846,7 @@ struct ksock_route *
 
 int
 ksocknal_launch_packet(struct lnet_ni *ni, struct ksock_tx *tx,
-		       lnet_process_id_t id)
+		       struct lnet_process_id id)
 {
 	struct ksock_peer *peer;
 	struct ksock_conn *conn;
@@ -943,7 +943,7 @@ struct ksock_route *
 {
 	int mpflag = 1;
 	int type = lntmsg->msg_type;
-	lnet_process_id_t target = lntmsg->msg_target;
+	struct lnet_process_id target = lntmsg->msg_target;
 	unsigned int payload_niov = lntmsg->msg_niov;
 	struct kvec *payload_iov = lntmsg->msg_iov;
 	lnet_kiov_t *payload_kiov = lntmsg->msg_kiov;
@@ -1133,7 +1133,7 @@ struct ksock_route *
 ksocknal_process_receive(struct ksock_conn *conn)
 {
 	struct lnet_hdr *lhdr;
-	lnet_process_id_t *id;
+	struct lnet_process_id *id;
 	int rc;
 
 	LASSERT(atomic_read(&conn->ksnc_conn_refcount) > 0);
@@ -1715,7 +1715,8 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 
 int
 ksocknal_recv_hello(struct lnet_ni *ni, struct ksock_conn *conn,
-		    struct ksock_hello_msg *hello, lnet_process_id_t *peerid,
+		    struct ksock_hello_msg *hello,
+		    struct lnet_process_id *peerid,
 		    __u64 *incarnation)
 {
 	/* Return < 0	fatal error
@@ -1729,7 +1730,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	int proto_match;
 	int rc;
 	struct ksock_proto *proto;
-	lnet_process_id_t recv_id;
+	struct lnet_process_id recv_id;
 
 	/* socket type set on active connections - not set on passive */
 	LASSERT(!active == !(conn->ksnc_type != SOCKLND_CONN_NONE));
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 1d2004f..0b91d18 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -58,8 +58,8 @@
 module_param(rnet_htable_size, int, 0444);
 MODULE_PARM_DESC(rnet_htable_size, "size of remote network hash table");
 
-static int lnet_ping(lnet_process_id_t id, int timeout_ms,
-		     lnet_process_id_t __user *ids, int n_ids);
+static int lnet_ping(struct lnet_process_id id, int timeout_ms,
+		     struct lnet_process_id __user *ids, int n_ids);
 
 static char *
 lnet_get_routes(void)
@@ -901,7 +901,7 @@ struct lnet_ni  *
 		     struct lnet_handle_md *md_handle,
 		     int ni_count, bool set_eq)
 {
-	lnet_process_id_t id = {LNET_NID_ANY, LNET_PID_ANY};
+	struct lnet_process_id id = {LNET_NID_ANY, LNET_PID_ANY};
 	struct lnet_handle_me me_handle;
 	struct lnet_md md = { NULL };
 	int rc, rc2;
@@ -1887,7 +1887,7 @@ void lnet_lib_exit(void)
 {
 	struct libcfs_ioctl_data *data = arg;
 	struct lnet_ioctl_config_data *config;
-	lnet_process_id_t id = {0};
+	struct lnet_process_id id = {0};
 	struct lnet_ni *ni;
 	int rc;
 	unsigned long secs_passed;
@@ -2059,7 +2059,7 @@ void lnet_lib_exit(void)
 		id.pid = data->ioc_u32[0];
 		rc = lnet_ping(id, data->ioc_u32[1], /* timeout */
 			       data->ioc_pbuf1,
-			       data->ioc_plen1 / sizeof(lnet_process_id_t));
+			       data->ioc_plen1 / sizeof(struct lnet_process_id));
 		if (rc < 0)
 			return rc;
 		data->ioc_count = rc;
@@ -2082,25 +2082,25 @@ void lnet_lib_exit(void)
 }
 EXPORT_SYMBOL(LNetCtl);
 
-void LNetDebugPeer(lnet_process_id_t id)
+void LNetDebugPeer(struct lnet_process_id id)
 {
 	lnet_debug_peer(id.nid);
 }
 EXPORT_SYMBOL(LNetDebugPeer);
 
 /**
- * Retrieve the lnet_process_id_t ID of LNet interface at \a index. Note that
+ * Retrieve the lnet_process_id ID of LNet interface at \a index. Note that
  * all interfaces share a same PID, as requested by LNetNIInit().
  *
  * \param index Index of the interface to look up.
  * \param id On successful return, this location will hold the
- * lnet_process_id_t ID of the interface.
+ * lnet_process_id ID of the interface.
  *
  * \retval 0 If an interface exists at \a index.
  * \retval -ENOENT If no interface has been found.
  */
 int
-LNetGetId(unsigned int index, lnet_process_id_t *id)
+LNetGetId(unsigned int index, struct lnet_process_id *id)
 {
 	struct lnet_ni *ni;
 	struct list_head *tmp;
@@ -2128,8 +2128,8 @@ void LNetDebugPeer(lnet_process_id_t id)
 }
 EXPORT_SYMBOL(LNetGetId);
 
-static int lnet_ping(lnet_process_id_t id, int timeout_ms,
-		     lnet_process_id_t __user *ids, int n_ids)
+static int lnet_ping(struct lnet_process_id id, int timeout_ms,
+		     struct lnet_process_id __user *ids, int n_ids)
 {
 	struct lnet_handle_eq eqh;
 	struct lnet_handle_md mdh;
@@ -2141,7 +2141,7 @@ static int lnet_ping(lnet_process_id_t id, int timeout_ms,
 	const int a_long_time = 60000; /* mS */
 	int infosz;
 	struct lnet_ping_info *info;
-	lnet_process_id_t tmpid;
+	struct lnet_process_id tmpid;
 	int i;
 	int nob;
 	int rc;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-me.c b/drivers/staging/lustre/lnet/lnet/lib-me.c
index 7614088..d8f40de 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-me.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-me.c
@@ -46,7 +46,7 @@
  * \param portal The portal table index where the ME should be attached.
  * \param match_id Specifies the match criteria for the process ID of
  * the requester. The constants LNET_PID_ANY and LNET_NID_ANY can be
- * used to wildcard either of the identifiers in the lnet_process_id_t
+ * used to wildcard either of the identifiers in the lnet_process_id
  * structure.
  * \param match_bits,ignore_bits Specify the match criteria to apply
  * to the match bits in the incoming request. The ignore bits are used
@@ -70,7 +70,7 @@
  */
 int
 LNetMEAttach(unsigned int portal,
-	     lnet_process_id_t match_id,
+	     struct lnet_process_id match_id,
 	     __u64 match_bits, __u64 ignore_bits,
 	     lnet_unlink_t unlink, lnet_ins_pos_t pos,
 	     struct lnet_handle_me *handle)
@@ -141,7 +141,7 @@
  */
 int
 LNetMEInsert(struct lnet_handle_me current_meh,
-	     lnet_process_id_t match_id,
+	     struct lnet_process_id match_id,
 	     __u64 match_bits, __u64 ignore_bits,
 	     lnet_unlink_t unlink, lnet_ins_pos_t pos,
 	     struct lnet_handle_me *handle)
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 96fb7fc..3c54a3d 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -429,7 +429,7 @@
 }
 
 void
-lnet_prep_send(struct lnet_msg *msg, int type, lnet_process_id_t target,
+lnet_prep_send(struct lnet_msg *msg, int type, struct lnet_process_id target,
 	       unsigned int offset, unsigned int len)
 {
 	msg->msg_type = type;
@@ -1392,7 +1392,7 @@
 {
 	void *private = msg->msg_private;
 	struct lnet_hdr *hdr = &msg->msg_hdr;
-	lnet_process_id_t src = {0};
+	struct lnet_process_id src = {0};
 	struct lnet_libmd *md;
 	int rlength;
 	int mlength;
@@ -1456,7 +1456,7 @@
 lnet_parse_ack(struct lnet_ni *ni, struct lnet_msg *msg)
 {
 	struct lnet_hdr *hdr = &msg->msg_hdr;
-	lnet_process_id_t src = {0};
+	struct lnet_process_id src = {0};
 	struct lnet_libmd *md;
 	int cpt;
 
@@ -1580,8 +1580,8 @@
 void
 lnet_print_hdr(struct lnet_hdr *hdr)
 {
-	lnet_process_id_t src = {0};
-	lnet_process_id_t dst = {0};
+	struct lnet_process_id src = {0};
+	struct lnet_process_id dst = {0};
 	char *type_str = lnet_msgtyp2str(hdr->type);
 
 	src.nid = hdr->src_nid;
@@ -1875,7 +1875,7 @@
 lnet_drop_delayed_msg_list(struct list_head *head, char *reason)
 {
 	while (!list_empty(head)) {
-		lnet_process_id_t id = {0};
+		struct lnet_process_id id = {0};
 		struct lnet_msg *msg;
 
 		msg = list_entry(head->next, struct lnet_msg, msg_list);
@@ -1918,7 +1918,7 @@
 {
 	while (!list_empty(head)) {
 		struct lnet_msg *msg;
-		lnet_process_id_t id;
+		struct lnet_process_id id;
 
 		msg = list_entry(head->next, struct lnet_msg, msg_list);
 		list_del(&msg->msg_list);
@@ -1991,7 +1991,7 @@
  */
 int
 LNetPut(lnet_nid_t self, struct lnet_handle_md mdh, lnet_ack_req_t ack,
-	lnet_process_id_t target, unsigned int portal,
+	struct lnet_process_id target, unsigned int portal,
 	__u64 match_bits, unsigned int offset,
 	__u64 hdr_data)
 {
@@ -2087,7 +2087,7 @@ struct lnet_msg *
 	 */
 	struct lnet_msg *msg = lnet_msg_alloc();
 	struct lnet_libmd *getmd = getmsg->msg_md;
-	lnet_process_id_t peer_id = getmsg->msg_target;
+	struct lnet_process_id peer_id = getmsg->msg_target;
 	int cpt;
 
 	LASSERT(!getmsg->msg_target_is_router);
@@ -2197,7 +2197,7 @@ struct lnet_msg *
  */
 int
 LNetGet(lnet_nid_t self, struct lnet_handle_md mdh,
-	lnet_process_id_t target, unsigned int portal,
+	struct lnet_process_id target, unsigned int portal,
 	__u64 match_bits, unsigned int offset)
 {
 	struct lnet_msg *msg;
diff --git a/drivers/staging/lustre/lnet/lnet/lib-ptl.c b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
index 9ea3c08..fc67af0 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-ptl.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-ptl.c
@@ -39,7 +39,7 @@
 MODULE_PARM_DESC(portal_rotor, "redirect PUTs to different cpu-partitions");
 
 static int
-lnet_ptl_match_type(unsigned int index, lnet_process_id_t match_id,
+lnet_ptl_match_type(unsigned int index, struct lnet_process_id match_id,
 		    __u64 mbits, __u64 ignore_bits)
 {
 	struct lnet_portal *ptl = the_lnet.ln_portals[index];
@@ -212,7 +212,7 @@
 }
 
 static struct lnet_match_table *
-lnet_match2mt(struct lnet_portal *ptl, lnet_process_id_t id, __u64 mbits)
+lnet_match2mt(struct lnet_portal *ptl, struct lnet_process_id id, __u64 mbits)
 {
 	if (LNET_CPT_NUMBER == 1)
 		return ptl->ptl_mtables[0]; /* the only one */
@@ -223,7 +223,7 @@
 }
 
 struct lnet_match_table *
-lnet_mt_of_attach(unsigned int index, lnet_process_id_t id,
+lnet_mt_of_attach(unsigned int index, struct lnet_process_id id,
 		  __u64 mbits, __u64 ignore_bits, lnet_ins_pos_t pos)
 {
 	struct lnet_portal *ptl;
@@ -357,7 +357,7 @@ struct lnet_match_table *
 
 struct list_head *
 lnet_mt_match_head(struct lnet_match_table *mtable,
-		   lnet_process_id_t id, __u64 mbits)
+		   struct lnet_process_id id, __u64 mbits)
 {
 	struct lnet_portal *ptl = the_lnet.ln_portals[mtable->mt_portal];
 	unsigned long hash = mbits;
diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
index a9fe3e6..298533d 100644
--- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
+++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
@@ -1226,7 +1226,7 @@ static void cfs_ip_min_max(struct list_head *nidlist, __u32 *min_nid,
 EXPORT_SYMBOL(libcfs_str2nid);
 
 char *
-libcfs_id2str(lnet_process_id_t id)
+libcfs_id2str(struct lnet_process_id id)
 {
 	char *str = libcfs_next_nidstring();
 
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 84092ad..194a220 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -1024,7 +1024,7 @@ int lnet_get_rtr_pool_cfg(int idx, struct lnet_ioctl_pool_cfg *pool_cfg)
 	    cfs_time_after(now, cfs_time_add(rtr->lp_ping_timestamp,
 					     cfs_time_seconds(secs)))) {
 		int rc;
-		lnet_process_id_t id;
+		struct lnet_process_id id;
 		struct lnet_handle_md mdh;
 
 		id.nid = rtr->lp_nid;
diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
index b9ac34e..f8b9175 100644
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -267,8 +267,8 @@ static int brw_inject_one_error(void)
 }
 
 static int
-brw_client_prep_rpc(struct sfw_test_unit *tsu,
-		    lnet_process_id_t dest, struct srpc_client_rpc **rpcpp)
+brw_client_prep_rpc(struct sfw_test_unit *tsu, struct lnet_process_id dest,
+		    struct srpc_client_rpc **rpcpp)
 {
 	struct srpc_bulk *bulk = tsu->tsu_private;
 	struct sfw_test_instance *tsi = tsu->tsu_instance;
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index 680a559..7985b09 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -505,7 +505,7 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 		jiffies_to_timeval(dur, &tv);
 
 		if (copy_to_user(&ent->rpe_peer, &nd->nd_id,
-				 sizeof(lnet_process_id_t)) ||
+				 sizeof(struct lnet_process_id)) ||
 		    copy_to_user(&ent->rpe_stamp, &tv, sizeof(tv)) ||
 		    copy_to_user(&ent->rpe_state, &nd->nd_state,
 				 sizeof(nd->nd_state)) ||
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 358cae8..d62c448 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -65,7 +65,8 @@
 }
 
 static int
-lstcon_node_find(lnet_process_id_t id, struct lstcon_node **ndpp, int create)
+lstcon_node_find(struct lnet_process_id id, struct lstcon_node **ndpp,
+		 int create)
 {
 	struct lstcon_ndlink	*ndl;
 	unsigned int idx = LNET_NIDADDR(id.nid) % LST_GLOBAL_HASHSIZE;
@@ -135,7 +136,7 @@
 }
 
 static int
-lstcon_ndlink_find(struct list_head *hash, lnet_process_id_t id,
+lstcon_ndlink_find(struct list_head *hash, struct lnet_process_id id,
 		   struct lstcon_ndlink **ndlpp, int create)
 {
 	unsigned int idx = LNET_NIDADDR(id.nid) % LST_NODE_HASHSIZE;
@@ -283,7 +284,7 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 }
 
 static int
-lstcon_group_ndlink_find(struct lstcon_group *grp, lnet_process_id_t id,
+lstcon_group_ndlink_find(struct lstcon_group *grp, struct lnet_process_id id,
 			 struct lstcon_ndlink **ndlpp, int create)
 {
 	int rc;
@@ -397,14 +398,14 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 
 static int
 lstcon_group_nodes_add(struct lstcon_group *grp,
-		       int count, lnet_process_id_t __user *ids_up,
+		       int count, struct lnet_process_id __user *ids_up,
 		       unsigned int *featp,
 		       struct list_head __user *result_up)
 {
 	struct lstcon_rpc_trans *trans;
 	struct lstcon_ndlink	*ndl;
 	struct lstcon_group *tmp;
-	lnet_process_id_t id;
+	struct lnet_process_id id;
 	int i;
 	int rc;
 
@@ -465,13 +466,13 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 
 static int
 lstcon_group_nodes_remove(struct lstcon_group *grp,
-			  int count, lnet_process_id_t __user *ids_up,
+			  int count, struct lnet_process_id __user *ids_up,
 			  struct list_head __user *result_up)
 {
 	struct lstcon_rpc_trans *trans;
 	struct lstcon_ndlink *ndl;
 	struct lstcon_group *tmp;
-	lnet_process_id_t id;
+	struct lnet_process_id id;
 	int rc;
 	int i;
 
@@ -543,9 +544,8 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 }
 
 int
-lstcon_nodes_add(char *name, int count, lnet_process_id_t __user *ids_up,
-		 unsigned int *featp,
-		 struct list_head __user *result_up)
+lstcon_nodes_add(char *name, int count, struct lnet_process_id __user *ids_up,
+		 unsigned int *featp, struct list_head __user *result_up)
 {
 	struct lstcon_group *grp;
 	int rc;
@@ -650,7 +650,8 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 }
 
 int
-lstcon_nodes_remove(char *name, int count, lnet_process_id_t __user *ids_up,
+lstcon_nodes_remove(char *name, int count,
+		    struct lnet_process_id __user *ids_up,
 		    struct list_head __user *result_up)
 {
 	struct lstcon_group *grp = NULL;
@@ -1533,12 +1534,12 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 }
 
 int
-lstcon_nodes_stat(int count, lnet_process_id_t __user *ids_up,
+lstcon_nodes_stat(int count, struct lnet_process_id __user *ids_up,
 		  int timeout, struct list_head __user *result_up)
 {
 	struct lstcon_ndlink	*ndl;
 	struct lstcon_group *tmp;
-	lnet_process_id_t id;
+	struct lnet_process_id id;
 	int i;
 	int rc;
 
@@ -1644,11 +1645,11 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 }
 
 int
-lstcon_nodes_debug(int timeout,
-		   int count, lnet_process_id_t __user *ids_up,
+lstcon_nodes_debug(int timeout, int count,
+		   struct lnet_process_id __user *ids_up,
 		   struct list_head __user *result_up)
 {
-	lnet_process_id_t id;
+	struct lnet_process_id id;
 	struct lstcon_ndlink *ndl;
 	struct lstcon_group *grp;
 	int i;
@@ -1697,7 +1698,7 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 static void
 lstcon_new_session_id(struct lst_sid *sid)
 {
-	lnet_process_id_t id;
+	struct lnet_process_id id;
 
 	LASSERT(console_session.ses_state == LST_SESSION_NONE);
 
diff --git a/drivers/staging/lustre/lnet/selftest/console.h b/drivers/staging/lustre/lnet/selftest/console.h
index 05b4b70..e3e11aa 100644
--- a/drivers/staging/lustre/lnet/selftest/console.h
+++ b/drivers/staging/lustre/lnet/selftest/console.h
@@ -48,7 +48,7 @@
 
 /* node descriptor */
 struct lstcon_node {
-	lnet_process_id_t nd_id;      /* id of the node */
+	struct lnet_process_id	nd_id;	/* id of the node */
 	int		  nd_ref;     /* reference count */
 	int		  nd_state;   /* state of the node */
 	int		  nd_timeout; /* session timeout */
@@ -180,7 +180,7 @@ struct lstcon_session {
 }
 
 static inline struct list_head *
-lstcon_id2hash(lnet_process_id_t id, struct list_head *hash)
+lstcon_id2hash(struct lnet_process_id id, struct list_head *hash)
 {
 	unsigned int idx = LNET_NIDADDR(id.nid) % LST_NODE_HASHSIZE;
 
@@ -203,15 +203,17 @@ int lstcon_batch_debug(int timeout, char *name,
 		       int client, struct list_head __user *result_up);
 int lstcon_group_debug(int timeout, char *name,
 		       struct list_head __user *result_up);
-int lstcon_nodes_debug(int timeout, int nnd, lnet_process_id_t __user *nds_up,
+int lstcon_nodes_debug(int timeout, int nnd,
+		       struct lnet_process_id __user *nds_up,
 		       struct list_head __user *result_up);
 int lstcon_group_add(char *name);
 int lstcon_group_del(char *name);
 int lstcon_group_clean(char *name, int args);
 int lstcon_group_refresh(char *name, struct list_head __user *result_up);
-int lstcon_nodes_add(char *name, int nnd, lnet_process_id_t __user *nds_up,
+int lstcon_nodes_add(char *name, int nnd, struct lnet_process_id __user *nds_up,
 		     unsigned int *featp, struct list_head __user *result_up);
-int lstcon_nodes_remove(char *name, int nnd, lnet_process_id_t __user *nds_up,
+int lstcon_nodes_remove(char *name, int nnd,
+			struct lnet_process_id __user *nds_up,
 			struct list_head __user *result_up);
 int lstcon_group_info(char *name, struct lstcon_ndlist_ent __user *gent_up,
 		      int *index_p, int *ndent_p,
@@ -232,7 +234,7 @@ int lstcon_batch_info(char *name, struct lstcon_test_batch_ent __user *ent_up,
 		      int *ndent_p, struct lstcon_node_ent __user *dents_up);
 int lstcon_group_stat(char *grp_name, int timeout,
 		      struct list_head __user *result_up);
-int lstcon_nodes_stat(int count, lnet_process_id_t __user *ids_up,
+int lstcon_nodes_stat(int count, struct lnet_process_id __user *ids_up,
 		      int timeout, struct list_head __user *result_up);
 int lstcon_test_add(char *batch_name, int type, int loop,
 		    int concur, int dist, int span,
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 9dd4e1a..ef27bff 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -899,7 +899,7 @@
 }
 
 int
-sfw_create_test_rpc(struct sfw_test_unit *tsu, lnet_process_id_t peer,
+sfw_create_test_rpc(struct sfw_test_unit *tsu, struct lnet_process_id peer,
 		    unsigned int features, int nblk, int blklen,
 		    struct srpc_client_rpc **rpcpp)
 {
@@ -1379,7 +1379,7 @@
 }
 
 struct srpc_client_rpc *
-sfw_create_rpc(lnet_process_id_t peer, int service,
+sfw_create_rpc(struct lnet_process_id peer, int service,
 	       unsigned int features, int nbulkiov, int bulklen,
 	       void (*done)(struct srpc_client_rpc *), void *priv)
 {
diff --git a/drivers/staging/lustre/lnet/selftest/ping_test.c b/drivers/staging/lustre/lnet/selftest/ping_test.c
index b9601b0..9653ac6 100644
--- a/drivers/staging/lustre/lnet/selftest/ping_test.c
+++ b/drivers/staging/lustre/lnet/selftest/ping_test.c
@@ -82,7 +82,7 @@ struct lst_ping_data {
 }
 
 static int
-ping_client_prep_rpc(struct sfw_test_unit *tsu, lnet_process_id_t dest,
+ping_client_prep_rpc(struct sfw_test_unit *tsu, struct lnet_process_id dest,
 		     struct srpc_client_rpc **rpc)
 {
 	struct srpc_ping_reqst *req;
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index f56f740..2231ed2 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -355,7 +355,7 @@ struct srpc_bulk *
 
 static int
 srpc_post_passive_rdma(int portal, int local, __u64 matchbits, void *buf,
-		       int len, int options, lnet_process_id_t peer,
+		       int len, int options, struct lnet_process_id peer,
 		       struct lnet_handle_md *mdh, struct srpc_event *ev)
 {
 	int rc;
@@ -394,8 +394,9 @@ struct srpc_bulk *
 
 static int
 srpc_post_active_rdma(int portal, __u64 matchbits, void *buf, int len,
-		      int options, lnet_process_id_t peer, lnet_nid_t self,
-		      struct lnet_handle_md *mdh, struct srpc_event *ev)
+		      int options, struct lnet_process_id peer,
+		      lnet_nid_t self, struct lnet_handle_md *mdh,
+		      struct srpc_event *ev)
 {
 	int rc;
 	struct lnet_md md;
@@ -450,7 +451,7 @@ struct srpc_bulk *
 srpc_post_passive_rqtbuf(int service, int local, void *buf, int len,
 			 struct lnet_handle_md *mdh, struct srpc_event *ev)
 {
-	lnet_process_id_t any = { 0 };
+	struct lnet_process_id any = { 0 };
 
 	any.nid = LNET_NID_ANY;
 	any.pid = LNET_PID_ANY;
@@ -1310,7 +1311,7 @@ struct srpc_bulk *
 }
 
 struct srpc_client_rpc *
-srpc_create_client_rpc(lnet_process_id_t peer, int service,
+srpc_create_client_rpc(struct lnet_process_id peer, int service,
 		       int nbulkiov, int bulklen,
 		       void (*rpc_done)(struct srpc_client_rpc *),
 		       void (*rpc_fini)(struct srpc_client_rpc *), void *priv)
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 91088c6..2e2c215 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -165,7 +165,7 @@ struct srpc_buffer {
 	struct srpc_msg	  buf_msg;
 	struct lnet_handle_md	buf_mdh;
 	lnet_nid_t	  buf_self;
-	lnet_process_id_t buf_peer;
+	struct lnet_process_id	buf_peer;
 };
 
 struct swi_workitem;
@@ -186,7 +186,7 @@ struct srpc_server_rpc {
 	struct swi_workitem	srpc_wi;
 	struct srpc_event	srpc_ev;	/* bulk/reply event */
 	lnet_nid_t	       srpc_self;
-	lnet_process_id_t      srpc_peer;
+	struct lnet_process_id	srpc_peer;
 	struct srpc_msg		srpc_replymsg;
 	struct lnet_handle_md	srpc_replymdh;
 	struct srpc_buffer	*srpc_reqstbuf;
@@ -206,7 +206,7 @@ struct srpc_client_rpc {
 	int		  crpc_timeout;   /* # seconds to wait for reply */
 	struct stt_timer       crpc_timer;
 	struct swi_workitem	crpc_wi;
-	lnet_process_id_t crpc_dest;
+	struct lnet_process_id	crpc_dest;
 
 	void		  (*crpc_done)(struct srpc_client_rpc *);
 	void		  (*crpc_fini)(struct srpc_client_rpc *);
@@ -355,7 +355,7 @@ struct sfw_test_client_ops {
 							  * client
 							  */
 	int  (*tso_prep_rpc)(struct sfw_test_unit *tsu,
-			     lnet_process_id_t dest,
+			     struct lnet_process_id dest,
 			     struct srpc_client_rpc **rpc);	/* prep a tests rpc */
 	void (*tso_done_rpc)(struct sfw_test_unit *tsu,
 			     struct srpc_client_rpc *rpc);	/* done a test rpc */
@@ -392,8 +392,8 @@ struct sfw_test_instance {
 };
 
 /*
- * XXX: trailing (PAGE_SIZE % sizeof(lnet_process_id_t)) bytes at the end of
- * pages are not used
+ * XXX: trailing (PAGE_SIZE % sizeof(struct lnet_process_id)) bytes at the end
+ * of pages are not used
  */
 #define SFW_MAX_CONCUR	   LST_MAX_CONCUR
 #define SFW_ID_PER_PAGE    (PAGE_SIZE / sizeof(struct lnet_process_id_packed))
@@ -402,7 +402,7 @@ struct sfw_test_instance {
 
 struct sfw_test_unit {
 	struct list_head    tsu_list;	   /* chain on lst_test_instance */
-	lnet_process_id_t   tsu_dest;	   /* id of dest node */
+	struct lnet_process_id		tsu_dest;	/* id of dest node */
 	int		    tsu_loop;	   /* loop count of the test */
 	struct sfw_test_instance	*tsu_instance; /* pointer to test instance */
 	void		    *tsu_private;  /* private data */
@@ -416,11 +416,11 @@ struct sfw_test_case {
 };
 
 struct srpc_client_rpc *
-sfw_create_rpc(lnet_process_id_t peer, int service,
+sfw_create_rpc(struct lnet_process_id peer, int service,
 	       unsigned int features, int nbulkiov, int bulklen,
 	       void (*done)(struct srpc_client_rpc *), void *priv);
 int sfw_create_test_rpc(struct sfw_test_unit *tsu,
-			lnet_process_id_t peer, unsigned int features,
+			struct lnet_process_id peer, unsigned int features,
 			int nblk, int blklen, struct srpc_client_rpc **rpc);
 void sfw_abort_rpc(struct srpc_client_rpc *rpc);
 void sfw_post_rpc(struct srpc_client_rpc *rpc);
@@ -434,7 +434,7 @@ int sfw_make_session(struct srpc_mksn_reqst *request,
 		     struct srpc_mksn_reply *reply);
 
 struct srpc_client_rpc *
-srpc_create_client_rpc(lnet_process_id_t peer, int service,
+srpc_create_client_rpc(struct lnet_process_id peer, int service,
 		       int nbulkiov, int bulklen,
 		       void (*rpc_done)(struct srpc_client_rpc *),
 		       void (*rpc_fini)(struct srpc_client_rpc *), void *priv);
@@ -522,7 +522,7 @@ struct srpc_bulk *srpc_alloc_bulk(int cpt, unsigned int off,
 }
 
 static inline void
-srpc_init_client_rpc(struct srpc_client_rpc *rpc, lnet_process_id_t peer,
+srpc_init_client_rpc(struct srpc_client_rpc *rpc, struct lnet_process_id peer,
 		     int service, int nbulkiov, int bulklen,
 		     void (*rpc_done)(struct srpc_client_rpc *),
 		     void (*rpc_fini)(struct srpc_client_rpc *), void *priv)
diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index c7c7c3a..d61b000 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -288,7 +288,7 @@ struct ptlrpc_connection {
 	/** Our own lnet nid for this connection */
 	lnet_nid_t	      c_self;
 	/** Remote side nid for this connection */
-	lnet_process_id_t       c_peer;
+	struct lnet_process_id	c_peer;
 	/** UUID of the other side */
 	struct obd_uuid	 c_remote_uuid;
 	/** reference counter for this connection */
@@ -876,7 +876,7 @@ struct ptlrpc_request {
 	/** our LNet NID */
 	lnet_nid_t	   rq_self;
 	/** Peer description (the other side) */
-	lnet_process_id_t    rq_peer;
+	struct lnet_process_id	rq_peer;
 	/**
 	 * service time estimate (secs)
 	 * If the request is not served by this time, it is marked as timed out.
@@ -1751,7 +1751,7 @@ static inline bool nrs_policy_compat_one(const struct ptlrpc_service *svc,
 /* ptlrpc/events.c */
 extern struct lnet_handle_eq ptlrpc_eq_h;
 int ptlrpc_uuid_to_peer(struct obd_uuid *uuid,
-			lnet_process_id_t *peer, lnet_nid_t *self);
+			struct lnet_process_id *peer, lnet_nid_t *self);
 /**
  * These callbacks are invoked by LNet when something happened to
  * underlying buffer
@@ -1765,7 +1765,7 @@ int ptlrpc_uuid_to_peer(struct obd_uuid *uuid,
 /** @} */
 
 /* ptlrpc/connection.c */
-struct ptlrpc_connection *ptlrpc_connection_get(lnet_process_id_t peer,
+struct ptlrpc_connection *ptlrpc_connection_get(struct lnet_process_id peer,
 						lnet_nid_t self,
 						struct obd_uuid *uuid);
 int ptlrpc_connection_put(struct ptlrpc_connection *c);
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 973eee6..7b80040 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -2512,7 +2512,7 @@ ssize_t ll_copy_user_md(const struct lov_user_md __user *md,
 void ll_compute_rootsquash_state(struct ll_sb_info *sbi)
 {
 	struct root_squash_info *squash = &sbi->ll_squash;
-	lnet_process_id_t id;
+	struct lnet_process_id id;
 	bool matched;
 	int i;
 
diff --git a/drivers/staging/lustre/lustre/llite/super25.c b/drivers/staging/lustre/lustre/llite/super25.c
index 4759802..56f4b10 100644
--- a/drivers/staging/lustre/lustre/llite/super25.c
+++ b/drivers/staging/lustre/lustre/llite/super25.c
@@ -84,7 +84,7 @@ struct super_operations lustre_super_operations = {
 
 static int __init lustre_init(void)
 {
-	lnet_process_id_t lnet_id;
+	struct lnet_process_id lnet_id;
 	struct timespec64 ts;
 	int i, rc, seed[2];
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 4cf0664..d8aa3fb 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -1195,7 +1195,8 @@ static int osc_brw_prep_request(int cmd, struct client_obd *cli,
 	return rc;
 }
 
-static int check_write_checksum(struct obdo *oa, const lnet_process_id_t *peer,
+static int check_write_checksum(struct obdo *oa,
+				const struct lnet_process_id *peer,
 				__u32 client_cksum, __u32 server_cksum, int nob,
 				u32 page_count, struct brw_page **pga,
 				enum cksum_type client_cksum_type)
@@ -1245,7 +1246,7 @@ static int check_write_checksum(struct obdo *oa, const lnet_process_id_t *peer,
 static int osc_brw_fini_request(struct ptlrpc_request *req, int rc)
 {
 	struct osc_brw_async_args *aa = (void *)&req->rq_async_args;
-	const lnet_process_id_t *peer =
+	const struct lnet_process_id *peer =
 			&req->rq_import->imp_connection->c_peer;
 	struct client_obd *cli = aa->aa_cli;
 	struct ost_body *body;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 5645c31..6466974 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -78,7 +78,7 @@ struct ptlrpc_connection *ptlrpc_uuid_to_connection(struct obd_uuid *uuid)
 {
 	struct ptlrpc_connection *c;
 	lnet_nid_t self;
-	lnet_process_id_t peer;
+	struct lnet_process_id peer;
 	int err;
 
 	/*
diff --git a/drivers/staging/lustre/lustre/ptlrpc/connection.c b/drivers/staging/lustre/lustre/ptlrpc/connection.c
index 6c7c8b6..73a2dbb 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/connection.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/connection.c
@@ -41,7 +41,7 @@
 static struct cfs_hash_ops conn_hash_ops;
 
 struct ptlrpc_connection *
-ptlrpc_connection_get(lnet_process_id_t peer, lnet_nid_t self,
+ptlrpc_connection_get(struct lnet_process_id peer, lnet_nid_t self,
 		      struct obd_uuid *uuid)
 {
 	struct ptlrpc_connection *conn, *conn2;
@@ -155,14 +155,14 @@ void ptlrpc_connection_fini(void)
 static unsigned int
 conn_hashfn(struct cfs_hash *hs, const void *key, unsigned int mask)
 {
-	return cfs_hash_djb2_hash(key, sizeof(lnet_process_id_t), mask);
+	return cfs_hash_djb2_hash(key, sizeof(struct lnet_process_id), mask);
 }
 
 static int
 conn_keycmp(const void *key, struct hlist_node *hnode)
 {
 	struct ptlrpc_connection *conn;
-	const lnet_process_id_t *conn_key;
+	const struct lnet_process_id *conn_key;
 
 	LASSERT(key);
 	conn_key = key;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/events.c b/drivers/staging/lustre/lustre/ptlrpc/events.c
index 3aec148..978bdac 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/events.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/events.c
@@ -446,7 +446,7 @@ static void ptlrpc_master_callback(struct lnet_event *ev)
 }
 
 int ptlrpc_uuid_to_peer(struct obd_uuid *uuid,
-			lnet_process_id_t *peer, lnet_nid_t *self)
+			struct lnet_process_id *peer, lnet_nid_t *self)
 {
 	int best_dist = 0;
 	__u32 best_order = 0;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
index befd73c..e3d2c0d 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/niobuf.c
@@ -109,7 +109,7 @@ static void mdunlink_iterate_helper(struct lnet_handle_md *bd_mds, int count)
 static int ptlrpc_register_bulk(struct ptlrpc_request *req)
 {
 	struct ptlrpc_bulk_desc *desc = req->rq_bulk;
-	lnet_process_id_t peer;
+	struct lnet_process_id peer;
 	int rc = 0;
 	int rc2;
 	int posted_md;
@@ -719,7 +719,7 @@ int ptl_send_rpc(struct ptlrpc_request *request, int noreply)
 int ptlrpc_register_rqbd(struct ptlrpc_request_buffer_desc *rqbd)
 {
 	struct ptlrpc_service *service = rqbd->rqbd_svcpt->scp_service;
-	static lnet_process_id_t match_id = {LNET_NID_ANY, LNET_PID_ANY};
+	static struct lnet_process_id match_id = {LNET_NID_ANY, LNET_PID_ANY};
 	int rc;
 	struct lnet_md md;
 	struct lnet_handle_me me_h;
-- 
1.8.3.1
