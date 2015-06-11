From: James Simmons <jsimmons@infradead.org>
Date: Thu, 11 Jun 2015 15:18:14 -0400
Subject: [lustre-devel] [PATCH v4 8/9] staging:lustre: LNet header code
	cleanup - indentation etc
In-Reply-To: <1434050295-10986-1-git-send-email-jsimmons@infradead.org>
References: <1434050295-10986-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1434050295-10986-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Handle all the style issues reported by checkpatch.pl.
Remove general white spaces, spaces in function calls,
alignments etc.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/include/linux/lnet/api.h    |   32 +-
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |   36 +-
 .../staging/lustre/include/linux/lnet/lib-types.h  |  459 ++++++++++---------
 drivers/staging/lustre/include/linux/lnet/lnetst.h |  473 +++++++++++---------
 .../staging/lustre/include/linux/lnet/socklnd.h    |   55 ++--
 drivers/staging/lustre/include/linux/lnet/types.h  |   78 ++--
 6 files changed, 595 insertions(+), 538 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/api.h b/drivers/staging/lustre/include/linux/lnet/api.h
index dee7f27..2eb0a05 100644
--- a/drivers/staging/lustre/include/linux/lnet/api.h
+++ b/drivers/staging/lustre/include/linux/lnet/api.h
@@ -95,16 +95,16 @@ void LNetSnprintHandle(char *str, int str_len, lnet_handle_any_t handle);
  * @{ */
 int LNetMEAttach(unsigned int      portal,
 		 lnet_process_id_t match_id_in,
-		 __u64	     match_bits_in,
-		 __u64	     ignore_bits_in,
+		 __u64		   match_bits_in,
+		 __u64		   ignore_bits_in,
 		 lnet_unlink_t     unlink_in,
 		 lnet_ins_pos_t    pos_in,
 		 lnet_handle_me_t *handle_out);
 
 int LNetMEInsert(lnet_handle_me_t  current_in,
 		 lnet_process_id_t match_id_in,
-		 __u64	     match_bits_in,
-		 __u64	     ignore_bits_in,
+		 __u64		   match_bits_in,
+		 __u64		   ignore_bits_in,
 		 lnet_unlink_t     unlink_in,
 		 lnet_ins_pos_t    position_in,
 		 lnet_handle_me_t *handle_out);
@@ -125,13 +125,13 @@ int LNetMEUnlink(lnet_handle_me_t current_in);
  * associated with a MD: LNetMDUnlink().
  * @{ */
 int LNetMDAttach(lnet_handle_me_t  current_in,
-		 lnet_md_t	 md_in,
+		 lnet_md_t	   md_in,
 		 lnet_unlink_t     unlink_in,
 		 lnet_handle_md_t *handle_out);
 
-int LNetMDBind(lnet_md_t	 md_in,
-	       lnet_unlink_t     unlink_in,
-	       lnet_handle_md_t *handle_out);
+int LNetMDBind(lnet_md_t	   md_in,
+	       lnet_unlink_t       unlink_in,
+	       lnet_handle_md_t   *handle_out);
 
 int LNetMDUnlink(lnet_handle_md_t md_in);
 /** @} lnet_md */
@@ -171,10 +171,10 @@ int LNetEQWait(lnet_handle_eq_t  eventq_in,
 	       lnet_event_t     *event_out);
 
 int LNetEQPoll(lnet_handle_eq_t *eventqs_in,
-	       int	       neq_in,
-	       int	       timeout_ms,
+	       int		 neq_in,
+	       int		 timeout_ms,
 	       lnet_event_t     *event_out,
-	       int	      *which_eq_out);
+	       int		*which_eq_out);
 /** @} lnet_eq */
 
 /** \defgroup lnet_data Data movement operations
@@ -182,20 +182,20 @@ int LNetEQPoll(lnet_handle_eq_t *eventqs_in,
  * The LNet API provides two data movement operations: LNetPut()
  * and LNetGet().
  * @{ */
-int LNetPut(lnet_nid_t	self,
+int LNetPut(lnet_nid_t	      self,
 	    lnet_handle_md_t  md_in,
 	    lnet_ack_req_t    ack_req_in,
 	    lnet_process_id_t target_in,
 	    unsigned int      portal_in,
-	    __u64	     match_bits_in,
+	    __u64	      match_bits_in,
 	    unsigned int      offset_in,
-	    __u64	     hdr_data_in);
+	    __u64	      hdr_data_in);
 
-int LNetGet(lnet_nid_t	self,
+int LNetGet(lnet_nid_t	      self,
 	    lnet_handle_md_t  md_in,
 	    lnet_process_id_t target_in,
 	    unsigned int      portal_in,
-	    __u64	     match_bits_in,
+	    __u64	      match_bits_in,
 	    unsigned int      offset_in);
 /** @} lnet_data */
 
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 6246e2e..0dbab6f 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -44,29 +44,29 @@
 #include "lnet.h"
 #include "lib-types.h"
 
-extern lnet_t  the_lnet;			/* THE network */
+extern lnet_t	the_lnet;	/* THE network */
 
 #if (BITS_PER_LONG == 32)
 /* 2 CPTs, allowing more CPTs might make us under memory pressure */
-# define LNET_CPT_MAX_BITS     1
+#define LNET_CPT_MAX_BITS	1
 
 #else /* 64-bit system */
 /*
  * 256 CPTs for thousands of CPUs, allowing more CPTs might make us
  * under risk of consuming all lh_cookie.
  */
-# define LNET_CPT_MAX_BITS     8
+#define LNET_CPT_MAX_BITS	8
 #endif /* BITS_PER_LONG == 32 */
 
 /* max allowed CPT number */
-#define LNET_CPT_MAX	    (1 << LNET_CPT_MAX_BITS)
+#define LNET_CPT_MAX		(1 << LNET_CPT_MAX_BITS)
 
-#define LNET_CPT_NUMBER	 (the_lnet.ln_cpt_number)
-#define LNET_CPT_BITS	   (the_lnet.ln_cpt_bits)
-#define LNET_CPT_MASK	   ((1ULL << LNET_CPT_BITS) - 1)
+#define LNET_CPT_NUMBER		(the_lnet.ln_cpt_number)
+#define LNET_CPT_BITS		(the_lnet.ln_cpt_bits)
+#define LNET_CPT_MASK		((1ULL << LNET_CPT_BITS) - 1)
 
 /** exclusive lock */
-#define LNET_LOCK_EX	    CFS_PERCPT_LOCK_EX
+#define LNET_LOCK_EX		CFS_PERCPT_LOCK_EX
 
 static inline int lnet_is_wire_handle_none(lnet_handle_wire_t *wh)
 {
@@ -163,7 +163,7 @@ lnet_net_lock_current(void)
 #define lnet_ni_lock(ni)	spin_lock(&(ni)->ni_lock)
 #define lnet_ni_unlock(ni)	spin_unlock(&(ni)->ni_lock)
 
-#define MAX_PORTALS     64
+#define MAX_PORTALS		64
 
 static inline lnet_eq_t *
 lnet_eq_alloc(void)
@@ -184,8 +184,8 @@ static inline lnet_libmd_t *
 lnet_md_alloc(lnet_md_t *umd)
 {
 	lnet_libmd_t *md;
-	unsigned int  size;
-	unsigned int  niov;
+	unsigned int size;
+	unsigned int niov;
 
 	if ((umd->options & LNET_MD_KIOV) != 0) {
 		niov = umd->length;
@@ -211,7 +211,7 @@ lnet_md_alloc(lnet_md_t *umd)
 static inline void
 lnet_md_free(lnet_libmd_t *md)
 {
-	unsigned int  size;
+	unsigned int size;
 
 	if ((md->md_options & LNET_MD_KIOV) != 0)
 		size = offsetof(lnet_libmd_t, md_iov.kiov[md->md_niov]);
@@ -299,7 +299,7 @@ lnet_handle2md(lnet_handle_md_t *handle)
 {
 	/* ALWAYS called with resource lock held */
 	lnet_libhandle_t *lh;
-	int		 cpt;
+	int cpt;
 
 	cpt = lnet_cpt_of_cookie(handle->cookie);
 	lh = lnet_res_lh_lookup(the_lnet.ln_md_containers[cpt],
@@ -315,7 +315,7 @@ lnet_wire_handle2md(lnet_handle_wire_t *wh)
 {
 	/* ALWAYS called with resource lock held */
 	lnet_libhandle_t *lh;
-	int		 cpt;
+	int cpt;
 
 	if (wh->wh_interface_cookie != the_lnet.ln_interface_cookie)
 		return NULL;
@@ -340,7 +340,7 @@ lnet_handle2me(lnet_handle_me_t *handle)
 {
 	/* ALWAYS called with resource lock held */
 	lnet_libhandle_t *lh;
-	int		 cpt;
+	int cpt;
 
 	cpt = lnet_cpt_of_cookie(handle->cookie);
 	lh = lnet_res_lh_lookup(the_lnet.ln_me_containers[cpt],
@@ -530,7 +530,9 @@ void lnet_recv(lnet_ni_t *ni, void *private, lnet_msg_t *msg, int delayed,
 	       unsigned int offset, unsigned int mlen, unsigned int rlen);
 lnet_msg_t *lnet_create_reply_msg(lnet_ni_t *ni, lnet_msg_t *get_msg);
 void lnet_set_reply_msg_len(lnet_ni_t *ni, lnet_msg_t *msg, unsigned int len);
+
 void lnet_finalize(lnet_ni_t *ni, lnet_msg_t *msg, int rc);
+
 void lnet_drop_delayed_msg_list(struct list_head *head, char *reason);
 void lnet_recv_delayed_msg_list(struct list_head *head);
 
@@ -679,12 +681,12 @@ void lnet_peer_tables_destroy(void);
 int lnet_peer_tables_create(void);
 void lnet_debug_peer(lnet_nid_t nid);
 
-static inline void lnet_peer_set_alive(lnet_peer_t *lp)
+static inline void
+lnet_peer_set_alive(lnet_peer_t *lp)
 {
 	lp->lp_last_alive = lp->lp_last_query = get_seconds();
 	if (!lp->lp_alive)
 		lnet_notify_locked(lp, 0, 1, lp->lp_last_alive);
 }
 
-
 #endif
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index 8e8e725..fa949d8 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -54,17 +54,17 @@
 #if (LNET_MAX_PAYLOAD < LNET_MTU)
 # error "LNET_MAX_PAYLOAD too small - error in configure --with-max-payload-mb"
 #elif (LNET_MAX_PAYLOAD > (PAGE_SIZE * LNET_MAX_IOV))
-#  error "LNET_MAX_PAYLOAD too large - error in configure --with-max-payload-mb"
+# error "LNET_MAX_PAYLOAD too large - error in configure --with-max-payload-mb"
 #endif
 
 /* forward refs */
 struct lnet_libmd;
 
 typedef struct lnet_msg {
-	struct list_head	    msg_activelist;
-	struct list_head	    msg_list;	   /* Q for credits/MD */
+	struct list_head	msg_activelist;
+	struct list_head	msg_list;	   /* Q for credits/MD */
 
-	lnet_process_id_t     msg_target;
+	lnet_process_id_t	msg_target;
 	/* where is it from, it's only for building event */
 	lnet_nid_t		msg_from;
 	__u32			msg_type;
@@ -84,110 +84,111 @@ typedef struct lnet_msg {
 	/* ready for pending on RX delay list */
 	unsigned int		msg_rx_ready_delay:1;
 
-	unsigned int	  msg_vmflush:1;      /* VM trying to free memory */
-	unsigned int	  msg_target_is_router:1; /* sending to a router */
-	unsigned int	  msg_routing:1;      /* being forwarded */
-	unsigned int	  msg_ack:1;	  /* ack on finalize (PUT) */
-	unsigned int	  msg_sending:1;      /* outgoing message */
-	unsigned int	  msg_receiving:1;    /* being received */
-	unsigned int	  msg_txcredit:1;     /* taken an NI send credit */
-	unsigned int	  msg_peertxcredit:1; /* taken a peer send credit */
-	unsigned int	  msg_rtrcredit:1;    /* taken a global router credit */
-	unsigned int	  msg_peerrtrcredit:1; /* taken a peer router credit */
-	unsigned int	  msg_onactivelist:1; /* on the activelist */
-
-	struct lnet_peer     *msg_txpeer;	 /* peer I'm sending to */
-	struct lnet_peer     *msg_rxpeer;	 /* peer I received from */
-
-	void		 *msg_private;
-	struct lnet_libmd    *msg_md;
-
-	unsigned int	  msg_len;
-	unsigned int	  msg_wanted;
-	unsigned int	  msg_offset;
-	unsigned int	  msg_niov;
-	struct kvec	 *msg_iov;
-	lnet_kiov_t	  *msg_kiov;
-
-	lnet_event_t	  msg_ev;
-	lnet_hdr_t	    msg_hdr;
+	unsigned int	msg_vmflush:1;		/* VM trying to free memory */
+	unsigned int	msg_target_is_router:1; /* sending to a router */
+	unsigned int	msg_routing:1;		/* being forwarded */
+	unsigned int	msg_ack:1;		/* ack on finalize (PUT) */
+	unsigned int	msg_sending:1;		/* outgoing message */
+	unsigned int	msg_receiving:1;	/* being received */
+	unsigned int	msg_txcredit:1;		/* taken an NI send credit */
+	unsigned int	msg_peertxcredit:1;	/* taken a peer send credit */
+	unsigned int	msg_rtrcredit:1;	/* taken a global
+						   router credit */
+	unsigned int	msg_peerrtrcredit:1;	/* taken a peer router credit */
+	unsigned int	msg_onactivelist:1;	/* on the activelist */
+
+	struct lnet_peer	*msg_txpeer;	 /* peer I'm sending to */
+	struct lnet_peer	*msg_rxpeer;	 /* peer I received from */
+
+	void			*msg_private;
+	struct lnet_libmd	*msg_md;
+
+	unsigned int		 msg_len;
+	unsigned int		 msg_wanted;
+	unsigned int		 msg_offset;
+	unsigned int		 msg_niov;
+	struct kvec		*msg_iov;
+	lnet_kiov_t		*msg_kiov;
+
+	lnet_event_t		 msg_ev;
+	lnet_hdr_t		 msg_hdr;
 } lnet_msg_t;
 
 typedef struct lnet_libhandle {
-	struct list_head	    lh_hash_chain;
-	__u64		 lh_cookie;
+	struct list_head	lh_hash_chain;
+	__u64			lh_cookie;
 } lnet_libhandle_t;
 
 #define lh_entry(ptr, type, member) \
 	((type *)((char *)(ptr)-(char *)(&((type *)0)->member)))
 
 typedef struct lnet_eq {
-	struct list_head		eq_list;
-	lnet_libhandle_t	eq_lh;
-	lnet_seq_t		eq_enq_seq;
-	lnet_seq_t		eq_deq_seq;
-	unsigned int		eq_size;
-	lnet_eq_handler_t	eq_callback;
-	lnet_event_t		*eq_events;
+	struct list_head	  eq_list;
+	lnet_libhandle_t	  eq_lh;
+	lnet_seq_t		  eq_enq_seq;
+	lnet_seq_t		  eq_deq_seq;
+	unsigned int		  eq_size;
+	lnet_eq_handler_t	  eq_callback;
+	lnet_event_t		 *eq_events;
 	int			**eq_refs;	/* percpt refcount for EQ */
 } lnet_eq_t;
 
 typedef struct lnet_me {
-	struct list_head	     me_list;
-	lnet_libhandle_t       me_lh;
-	lnet_process_id_t      me_match_id;
-	unsigned int	   me_portal;
-	unsigned int	   me_pos;		/* hash offset in mt_hash */
-	__u64		  me_match_bits;
-	__u64		  me_ignore_bits;
-	lnet_unlink_t	  me_unlink;
-	struct lnet_libmd     *me_md;
+	struct list_head	 me_list;
+	lnet_libhandle_t	 me_lh;
+	lnet_process_id_t	 me_match_id;
+	unsigned int		 me_portal;
+	unsigned int		 me_pos;	/* hash offset in mt_hash */
+	__u64			 me_match_bits;
+	__u64			 me_ignore_bits;
+	lnet_unlink_t		 me_unlink;
+	struct lnet_libmd	*me_md;
 } lnet_me_t;
 
 typedef struct lnet_libmd {
-	struct list_head	    md_list;
-	lnet_libhandle_t      md_lh;
-	lnet_me_t	    *md_me;
-	char		 *md_start;
-	unsigned int	  md_offset;
-	unsigned int	  md_length;
-	unsigned int	  md_max_size;
-	int		   md_threshold;
-	int		   md_refcount;
-	unsigned int	  md_options;
-	unsigned int	  md_flags;
-	void		 *md_user_ptr;
-	lnet_eq_t	    *md_eq;
-	unsigned int	  md_niov;		/* # frags */
+	struct list_head	 md_list;
+	lnet_libhandle_t	 md_lh;
+	lnet_me_t		*md_me;
+	char			*md_start;
+	unsigned int		 md_offset;
+	unsigned int		 md_length;
+	unsigned int		 md_max_size;
+	int			 md_threshold;
+	int			 md_refcount;
+	unsigned int		 md_options;
+	unsigned int		 md_flags;
+	void			*md_user_ptr;
+	lnet_eq_t		*md_eq;
+	unsigned int		 md_niov;	/* # frags */
 	union {
-		struct kvec   iov[LNET_MAX_IOV];
-		lnet_kiov_t   kiov[LNET_MAX_IOV];
+		struct kvec	iov[LNET_MAX_IOV];
+		lnet_kiov_t	kiov[LNET_MAX_IOV];
 	} md_iov;
 } lnet_libmd_t;
 
-#define LNET_MD_FLAG_ZOMBIE	   (1 << 0)
-#define LNET_MD_FLAG_AUTO_UNLINK      (1 << 1)
-#define LNET_MD_FLAG_ABORTED	 (1 << 2)
+#define LNET_MD_FLAG_ZOMBIE		(1 << 0)
+#define LNET_MD_FLAG_AUTO_UNLINK	(1 << 1)
+#define LNET_MD_FLAG_ABORTED		(1 << 2)
 
 typedef struct {
 	/* info about peers we are trying to fail */
-	struct list_head	     tp_list;	     /* ln_test_peers */
-	lnet_nid_t	     tp_nid;	      /* matching nid */
-	unsigned int	   tp_threshold;	/* # failures to simulate */
+	struct list_head	tp_list;	/* ln_test_peers */
+	lnet_nid_t		tp_nid;		/* matching nid */
+	unsigned int		tp_threshold;	/* # failures to simulate */
 } lnet_test_peer_t;
 
-#define LNET_COOKIE_TYPE_MD    1
-#define LNET_COOKIE_TYPE_ME    2
-#define LNET_COOKIE_TYPE_EQ    3
-#define LNET_COOKIE_TYPE_BITS  2
+#define LNET_COOKIE_TYPE_MD	1
+#define LNET_COOKIE_TYPE_ME	2
+#define LNET_COOKIE_TYPE_EQ	3
+#define LNET_COOKIE_TYPE_BITS	2
 #define LNET_COOKIE_MASK	((1ULL << LNET_COOKIE_TYPE_BITS) - 1ULL)
 
-struct lnet_ni;				  /* forward ref */
+struct lnet_ni;			/* forward ref */
 
 typedef struct lnet_lnd {
 	/* fields managed by portals */
-	struct list_head	    lnd_list;	     /* stash in the LND table */
-	int		   lnd_refcount;	 /* # active instances */
+	struct list_head	lnd_list;	/* stash in the LND table */
+	int			lnd_refcount;	/* # active instances */
 
 	/* fields initialised by the LND */
 	__u32			lnd_type;
@@ -222,7 +223,8 @@ typedef struct lnet_lnd {
 	int (*lnd_recv)(struct lnet_ni *ni, void *private, lnet_msg_t *msg,
 			int delayed, unsigned int niov,
 			struct kvec *iov, lnet_kiov_t *kiov,
-			unsigned int offset, unsigned int mlen, unsigned int rlen);
+			unsigned int offset, unsigned int mlen,
+			unsigned int rlen);
 
 	/* lnet_parse() has had to delay processing of this message
 	 * (e.g. waiting for a forwarding buffer or send credits).  Give the
@@ -230,49 +232,49 @@ typedef struct lnet_lnd {
 	 * for success and do NOT give back a receive credit; that has to wait
 	 * until lnd_recv() gets called.  On failure return < 0 and
 	 * release resources; lnd_recv() will not be called. */
-	int (*lnd_eager_recv)(struct lnet_ni *ni, void *private, lnet_msg_t *msg,
-			      void **new_privatep);
+	int (*lnd_eager_recv)(struct lnet_ni *ni, void *private,
+			      lnet_msg_t *msg, void **new_privatep);
 
 	/* notification of peer health */
 	void (*lnd_notify)(struct lnet_ni *ni, lnet_nid_t peer, int alive);
 
 	/* query of peer aliveness */
-	void (*lnd_query)(struct lnet_ni *ni, lnet_nid_t peer, unsigned long *when);
+	void (*lnd_query)(struct lnet_ni *ni, lnet_nid_t peer,
+			  unsigned long *when);
 
 	/* accept a new connection */
 	int (*lnd_accept)(struct lnet_ni *ni, struct socket *sock);
-
 } lnd_t;
 
 struct lnet_tx_queue {
 	int			tq_credits;	/* # tx credits free */
 	int			tq_credits_min;	/* lowest it's been */
 	int			tq_credits_max;	/* total # tx credits */
-	struct list_head		tq_delayed;	/* delayed TXs */
+	struct list_head	tq_delayed;	/* delayed TXs */
 };
 
 typedef struct lnet_ni {
-	spinlock_t		ni_lock;
-	struct list_head		ni_list;	/* chain on ln_nis */
-	struct list_head		ni_cptlist;	/* chain on ln_nis_cpt */
-	int			ni_maxtxcredits; /* # tx credits  */
+	spinlock_t		  ni_lock;
+	struct list_head	  ni_list;	/* chain on ln_nis */
+	struct list_head	  ni_cptlist;	/* chain on ln_nis_cpt */
+	int			  ni_maxtxcredits; /* # tx credits  */
 	/* # per-peer send credits */
-	int			ni_peertxcredits;
+	int			  ni_peertxcredits;
 	/* # per-peer router buffer credits */
-	int			ni_peerrtrcredits;
+	int			  ni_peerrtrcredits;
 	/* seconds to consider peer dead */
-	int			ni_peertimeout;
-	int			ni_ncpts;	/* number of CPTs */
-	__u32			*ni_cpts;	/* bond NI on some CPTs */
-	lnet_nid_t		ni_nid;		/* interface's NID */
-	void			*ni_data;	/* instance-specific data */
-	lnd_t			*ni_lnd;	/* procedural interface */
+	int			  ni_peertimeout;
+	int			  ni_ncpts;	/* number of CPTs */
+	__u32			 *ni_cpts;	/* bond NI on some CPTs */
+	lnet_nid_t		  ni_nid;	/* interface's NID */
+	void			 *ni_data;	/* instance-specific data */
+	lnd_t			 *ni_lnd;	/* procedural interface */
 	struct lnet_tx_queue	**ni_tx_queues;	/* percpt TX queues */
 	int			**ni_refs;	/* percpt reference count */
-	long			ni_last_alive;	/* when I was last alive */
-	lnet_ni_status_t	*ni_status;	/* my health status */
+	long			  ni_last_alive;/* when I was last alive */
+	lnet_ni_status_t	 *ni_status;	/* my health status */
 	/* equivalent interfaces to use */
-	char			*ni_interfaces[LNET_MAX_INTERFACES];
+	char			 *ni_interfaces[LNET_MAX_INTERFACES];
 } lnet_ni_t;
 
 #define LNET_PROTO_PING_MATCHBITS	0x8000000000000000LL
@@ -291,55 +293,65 @@ typedef struct lnet_ni {
 #define LNET_PINGINFO_SIZE offsetof(lnet_ping_info_t, pi_ni[LNET_MAX_RTR_NIS])
 typedef struct {
 	/* chain on the_lnet.ln_zombie_rcd or ln_deathrow_rcd */
-	struct list_head		rcd_list;
-	lnet_handle_md_t	rcd_mdh;	/* ping buffer MD */
+	struct list_head	 rcd_list;
+	lnet_handle_md_t	 rcd_mdh;	/* ping buffer MD */
 	struct lnet_peer	*rcd_gateway;	/* reference to gateway */
 	lnet_ping_info_t	*rcd_pinginfo;	/* ping buffer */
 } lnet_rc_data_t;
 
 typedef struct lnet_peer {
-	struct list_head	lp_hashlist;	  /* chain on peer hash */
-	struct list_head	lp_txq;	       /* messages blocking for tx credits */
-	struct list_head	lp_rtrq;	      /* messages blocking for router credits */
-	struct list_head	lp_rtr_list;	  /* chain on router list */
-	int	       lp_txcredits;	 /* # tx credits available */
-	int	       lp_mintxcredits;      /* low water mark */
-	int	       lp_rtrcredits;	/* # router credits */
-	int	       lp_minrtrcredits;     /* low water mark */
-	unsigned int      lp_alive:1;	   /* alive/dead? */
-	unsigned int      lp_notify:1;	  /* notification outstanding? */
-	unsigned int      lp_notifylnd:1;       /* outstanding notification for LND? */
-	unsigned int      lp_notifying:1;       /* some thread is handling notification */
-	unsigned int      lp_ping_notsent;      /* SEND event outstanding from ping */
-	int	       lp_alive_count;       /* # times router went dead<->alive */
-	long	      lp_txqnob;	    /* bytes queued for sending */
-	unsigned long	lp_timestamp;	 /* time of last aliveness news */
-	unsigned long	lp_ping_timestamp;    /* time of last ping attempt */
-	unsigned long	lp_ping_deadline;     /* != 0 if ping reply expected */
-	unsigned long	lp_last_alive;	/* when I was last alive */
-	unsigned long	lp_last_query;	/* when lp_ni was queried last time */
-	lnet_ni_t	*lp_ni;		/* interface peer is on */
-	lnet_nid_t	lp_nid;	       /* peer's NID */
-	int	       lp_refcount;	  /* # refs */
-	int			lp_cpt;		/* CPT this peer attached on */
+	struct list_head	 lp_hashlist;	/* chain on peer hash */
+	struct list_head	 lp_txq;	/* messages blocking for
+						   tx credits */
+	struct list_head	 lp_rtrq;	/* messages blocking for
+						   router credits */
+	struct list_head	 lp_rtr_list;	/* chain on router list */
+	int			 lp_txcredits;	/* # tx credits available */
+	int			 lp_mintxcredits;  /* low water mark */
+	int			 lp_rtrcredits;	   /* # router credits */
+	int			 lp_minrtrcredits; /* low water mark */
+	unsigned int		 lp_alive:1;	   /* alive/dead? */
+	unsigned int		 lp_notify:1;	/* notification outstanding? */
+	unsigned int		 lp_notifylnd:1;/* outstanding notification
+						   for LND? */
+	unsigned int		 lp_notifying:1; /* some thread is handling
+						    notification */
+	unsigned int		 lp_ping_notsent;/* SEND event outstanding
+						    from ping */
+	int			 lp_alive_count; /* # times router went
+						    dead<->alive */
+	long			 lp_txqnob;	 /* bytes queued for sending */
+	unsigned long		 lp_timestamp;	 /* time of last aliveness
+						    news */
+	unsigned long		 lp_ping_timestamp;/* time of last ping
+						      attempt */
+	unsigned long		 lp_ping_deadline; /* != 0 if ping reply
+						      expected */
+	unsigned long		 lp_last_alive;	/* when I was last alive */
+	unsigned long		 lp_last_query;	/* when lp_ni was queried
+						   last time */
+	lnet_ni_t		*lp_ni;		/* interface peer is on */
+	lnet_nid_t		 lp_nid;	/* peer's NID */
+	int			 lp_refcount;	/* # refs */
+	int			 lp_cpt;	/* CPT this peer attached on */
 	/* # refs from lnet_route_t::lr_gateway */
-	int			lp_rtr_refcount;
+	int			 lp_rtr_refcount;
 	/* returned RC ping features */
-	unsigned int		lp_ping_feats;
-	struct list_head		lp_routes;	/* routers on this peer */
+	unsigned int		 lp_ping_feats;
+	struct list_head	 lp_routes;	/* routers on this peer */
 	lnet_rc_data_t		*lp_rcd;	/* router checker state */
 } lnet_peer_t;
 
 /* peer hash size */
-#define LNET_PEER_HASH_BITS     9
-#define LNET_PEER_HASH_SIZE     (1 << LNET_PEER_HASH_BITS)
+#define LNET_PEER_HASH_BITS	9
+#define LNET_PEER_HASH_SIZE	(1 << LNET_PEER_HASH_BITS)
 
 /* peer hash table */
 struct lnet_peer_table {
-	int			pt_version;	/* /proc validity stamp */
-	int			pt_number;	/* # peers extant */
-	struct list_head		pt_deathrow;	/* zombie peers */
-	struct list_head		*pt_hash;	/* NID->peer hash */
+	int			 pt_version;	/* /proc validity stamp */
+	int			 pt_number;	/* # peers extant */
+	struct list_head	 pt_deathrow;	/* zombie peers */
+	struct list_head	*pt_hash;	/* NID->peer hash */
 };
 
 /* peer aliveness is enabled only on routers for peers in a network where the
@@ -348,14 +360,14 @@ struct lnet_peer_table {
 					 (lp)->lp_ni->ni_peertimeout > 0)
 
 typedef struct {
-	struct list_head		lr_list;	/* chain on net */
-	struct list_head		lr_gwlist;	/* chain on gateway */
+	struct list_head	 lr_list;	/* chain on net */
+	struct list_head	 lr_gwlist;	/* chain on gateway */
 	lnet_peer_t		*lr_gateway;	/* router node */
-	__u32			lr_net;		/* remote network number */
-	int			lr_seq;		/* sequence for round-robin */
-	unsigned int		lr_downis;	/* number of down NIs */
-	unsigned int		lr_hops;	/* how far I am */
-	unsigned int            lr_priority;    /* route priority */
+	__u32			 lr_net;	/* remote network number */
+	int			 lr_seq;	/* sequence for round-robin */
+	unsigned int		 lr_downis;	/* number of down NIs */
+	unsigned int		 lr_hops;	/* how far I am */
+	unsigned int             lr_priority;	/* route priority */
 } lnet_route_t;
 
 #define LNET_REMOTE_NETS_HASH_DEFAULT	(1U << 7)
@@ -363,9 +375,10 @@ typedef struct {
 #define LNET_REMOTE_NETS_HASH_SIZE	(1 << the_lnet.ln_remote_nets_hbits)
 
 typedef struct {
-	struct list_head	      lrn_list;       /* chain on ln_remote_nets_hash */
-	struct list_head	      lrn_routes;     /* routes to me */
-	__u32		   lrn_net;	/* my net number */
+	struct list_head	lrn_list;	/* chain on
+						   ln_remote_nets_hash */
+	struct list_head	lrn_routes;	/* routes to me */
+	__u32			lrn_net;	/* my net number */
 } lnet_remotenet_t;
 
 /** lnet message has credit and can be submitted to lnd for send/receive */
@@ -374,21 +387,23 @@ typedef struct {
 #define LNET_CREDIT_WAIT	1
 
 typedef struct {
-	struct list_head rbp_bufs;	     /* my free buffer pool */
-	struct list_head rbp_msgs;	     /* messages blocking for a buffer */
-	int	rbp_npages;	   /* # pages in each buffer */
-	int	rbp_nbuffers;	 /* # buffers */
-	int	rbp_credits;	  /* # free buffers / blocked messages */
-	int	rbp_mincredits;       /* low water mark */
+	struct list_head	rbp_bufs;	/* my free buffer pool */
+	struct list_head	rbp_msgs;	/* messages blocking
+						   for a buffer */
+	int			rbp_npages;	/* # pages in each buffer */
+	int			rbp_nbuffers;	/* # buffers */
+	int			rbp_credits;	/* # free buffers /
+						     blocked messages */
+	int			rbp_mincredits;	/* low water mark */
 } lnet_rtrbufpool_t;
 
 typedef struct {
-	struct list_head	     rb_list;	     /* chain on rbp_bufs */
-	lnet_rtrbufpool_t     *rb_pool;	     /* owning pool */
-	lnet_kiov_t	    rb_kiov[0];	  /* the buffer space */
+	struct list_head	 rb_list;	/* chain on rbp_bufs */
+	lnet_rtrbufpool_t	*rb_pool;	/* owning pool */
+	lnet_kiov_t		 rb_kiov[0];	/* the buffer space */
 } lnet_rtrbuf_t;
 
-#define LNET_PEER_HASHSIZE   503		/* prime! */
+#define LNET_PEER_HASHSIZE	503	/* prime! */
 
 #define LNET_NRBPOOLS		3	/* # different router buffer pools */
 
@@ -400,15 +415,16 @@ enum {
 	/* Must be discarded */
 	LNET_MATCHMD_DROP	= (1 << 2),
 	/* match and buffer is exhausted */
-	LNET_MATCHMD_EXHAUSTED  = (1 << 3),
+	LNET_MATCHMD_EXHAUSTED	= (1 << 3),
 	/* match or drop */
-	LNET_MATCHMD_FINISH     = (LNET_MATCHMD_OK | LNET_MATCHMD_DROP),
+	LNET_MATCHMD_FINISH	= (LNET_MATCHMD_OK | LNET_MATCHMD_DROP),
 };
 
 /* Options for lnet_portal_t::ptl_options */
-#define LNET_PTL_LAZY	       (1 << 0)
-#define LNET_PTL_MATCH_UNIQUE       (1 << 1)    /* unique match, for RDMA */
-#define LNET_PTL_MATCH_WILDCARD     (1 << 2)    /* wildcard match, request portal */
+#define LNET_PTL_LAZY		(1 << 0)
+#define LNET_PTL_MATCH_UNIQUE	(1 << 1)	/* unique match, for RDMA */
+#define LNET_PTL_MATCH_WILDCARD	(1 << 2)	/* wildcard match,
+						   request portal */
 
 /* parameter for matching operations (GET, PUT) */
 struct lnet_match_info {
@@ -437,14 +453,14 @@ struct lnet_match_info {
 /* portal match table */
 struct lnet_match_table {
 	/* reserved for upcoming patches, CPU partition ID */
-	unsigned int		mt_cpt;
-	unsigned int		mt_portal;      /* portal index */
+	unsigned int		 mt_cpt;
+	unsigned int		 mt_portal;	/* portal index */
 	/* match table is set as "enabled" if there's non-exhausted MD
 	 * attached on mt_mhash, it's only valid for wildcard portal */
-	unsigned int		mt_enabled;
+	unsigned int		 mt_enabled;
 	/* bitmap to flag whether MEs on mt_hash are exhausted or not */
-	__u64			mt_exhausted[LNET_MT_EXHAUSTED_BMAP];
-	struct list_head		*mt_mhash;      /* matching hash */
+	__u64			 mt_exhausted[LNET_MT_EXHAUSTED_BMAP];
+	struct list_head	*mt_mhash;	/* matching hash */
 };
 
 /* these are only useful for wildcard portal */
@@ -458,22 +474,22 @@ struct lnet_match_table {
 #define	LNET_PTL_ROTOR_HASH_RT	3
 
 typedef struct lnet_portal {
-	spinlock_t		ptl_lock;
-	unsigned int		ptl_index;	/* portal ID, reserved */
+	spinlock_t		  ptl_lock;
+	unsigned int		  ptl_index;	/* portal ID, reserved */
 	/* flags on this portal: lazy, unique... */
-	unsigned int		ptl_options;
+	unsigned int		  ptl_options;
 	/* list of messages which are stealing buffer */
-	struct list_head		ptl_msg_stealing;
+	struct list_head	  ptl_msg_stealing;
 	/* messages blocking for MD */
-	struct list_head		ptl_msg_delayed;
+	struct list_head	  ptl_msg_delayed;
 	/* Match table for each CPT */
 	struct lnet_match_table	**ptl_mtables;
 	/* spread rotor of incoming "PUT" */
-	unsigned int		ptl_rotor;
+	unsigned int		  ptl_rotor;
 	/* # active entries for this portal */
-	int		     ptl_mt_nmaps;
+	int			  ptl_mt_nmaps;
 	/* array of active entries' cpu-partition-id */
-	int		     ptl_mt_maps[0];
+	int			  ptl_mt_maps[0];
 } lnet_portal_t;
 
 #define LNET_LH_HASH_BITS	12
@@ -482,20 +498,20 @@ typedef struct lnet_portal {
 
 /* resource container (ME, MD, EQ) */
 struct lnet_res_container {
-	unsigned int		rec_type;	/* container type */
-	__u64			rec_lh_cookie;	/* cookie generator */
-	struct list_head		rec_active;	/* active resource list */
-	struct list_head		*rec_lh_hash;	/* handle hash */
+	unsigned int		 rec_type;	/* container type */
+	__u64			 rec_lh_cookie;	/* cookie generator */
+	struct list_head	 rec_active;	/* active resource list */
+	struct list_head	*rec_lh_hash;	/* handle hash */
 };
 
 /* message container */
 struct lnet_msg_container {
-	int			msc_init;	/* initialized or not */
+	int			  msc_init;	/* initialized or not */
 	/* max # threads finalizing */
-	int			msc_nfinalizers;
+	int			  msc_nfinalizers;
 	/* msgs waiting to complete finalizing */
-	struct list_head		msc_finalizing;
-	struct list_head		msc_active;	/* active message list */
+	struct list_head	  msc_finalizing;
+	struct list_head	  msc_active;	/* active message list */
 	/* threads doing finalization */
 	void			**msc_finalizers;
 };
@@ -507,15 +523,15 @@ struct lnet_msg_container {
 
 typedef struct {
 	/* CPU partition table of LNet */
-	struct cfs_cpt_table		*ln_cpt_table;
+	struct cfs_cpt_table		 *ln_cpt_table;
 	/* number of CPTs in ln_cpt_table */
-	unsigned int			ln_cpt_number;
-	unsigned int			ln_cpt_bits;
+	unsigned int			  ln_cpt_number;
+	unsigned int			  ln_cpt_bits;
 
 	/* protect LNet resources (ME/MD/EQ) */
-	struct cfs_percpt_lock		*ln_res_lock;
+	struct cfs_percpt_lock		 *ln_res_lock;
 	/* # portals */
-	int				ln_nportals;
+	int				  ln_nportals;
 	/* the vector of portals */
 	lnet_portal_t			**ln_portals;
 	/* percpt ME containers */
@@ -524,77 +540,78 @@ typedef struct {
 	struct lnet_res_container	**ln_md_containers;
 
 	/* Event Queue container */
-	struct lnet_res_container	ln_eq_container;
-	wait_queue_head_t			ln_eq_waitq;
-	spinlock_t			ln_eq_wait_lock;
-	unsigned int			ln_remote_nets_hbits;
+	struct lnet_res_container	  ln_eq_container;
+	wait_queue_head_t		  ln_eq_waitq;
+	spinlock_t			  ln_eq_wait_lock;
+	unsigned int			  ln_remote_nets_hbits;
 
 	/* protect NI, peer table, credits, routers, rtrbuf... */
-	struct cfs_percpt_lock		*ln_net_lock;
+	struct cfs_percpt_lock		 *ln_net_lock;
 	/* percpt message containers for active/finalizing/freed message */
 	struct lnet_msg_container	**ln_msg_containers;
 	lnet_counters_t			**ln_counters;
 	struct lnet_peer_table		**ln_peer_tables;
 	/* failure simulation */
-	struct list_head			ln_test_peers;
+	struct list_head		  ln_test_peers;
 
-	struct list_head			ln_nis;		/* LND instances */
+	struct list_head		  ln_nis;	/* LND instances */
 	/* NIs bond on specific CPT(s) */
-	struct list_head			ln_nis_cpt;
+	struct list_head		  ln_nis_cpt;
 	/* dying LND instances */
-	struct list_head			ln_nis_zombie;
-	lnet_ni_t			*ln_loni;	/* the loopback NI */
+	struct list_head		  ln_nis_zombie;
+	lnet_ni_t			 *ln_loni;	/* the loopback NI */
 	/* NI to wait for events in */
-	lnet_ni_t			*ln_eq_waitni;
+	lnet_ni_t			 *ln_eq_waitni;
 
 	/* remote networks with routes to them */
-	struct list_head			*ln_remote_nets_hash;
+	struct list_head		 *ln_remote_nets_hash;
 	/* validity stamp */
-	__u64				ln_remote_nets_version;
+	__u64				  ln_remote_nets_version;
 	/* list of all known routers */
-	struct list_head			ln_routers;
+	struct list_head		  ln_routers;
 	/* validity stamp */
-	__u64				ln_routers_version;
+	__u64				  ln_routers_version;
 	/* percpt router buffer pools */
 	lnet_rtrbufpool_t		**ln_rtrpools;
 
-	lnet_handle_md_t		ln_ping_target_md;
-	lnet_handle_eq_t		ln_ping_target_eq;
-	lnet_ping_info_t		*ln_ping_info;
+	lnet_handle_md_t		  ln_ping_target_md;
+	lnet_handle_eq_t		  ln_ping_target_eq;
+	lnet_ping_info_t		 *ln_ping_info;
 
 	/* router checker startup/shutdown state */
-	int				ln_rc_state;
+	int				  ln_rc_state;
 	/* router checker's event queue */
-	lnet_handle_eq_t		ln_rc_eqh;
+	lnet_handle_eq_t		  ln_rc_eqh;
 	/* rcd still pending on net */
-	struct list_head			ln_rcd_deathrow;
+	struct list_head		  ln_rcd_deathrow;
 	/* rcd ready for free */
-	struct list_head			ln_rcd_zombie;
+	struct list_head		  ln_rcd_zombie;
 	/* serialise startup/shutdown */
-	struct semaphore		ln_rc_signal;
+	struct semaphore		  ln_rc_signal;
 
-	struct mutex			ln_api_mutex;
-	struct mutex			ln_lnd_mutex;
-	int				ln_init;	/* lnet_init() called? */
+	struct mutex			  ln_api_mutex;
+	struct mutex			  ln_lnd_mutex;
+	int				  ln_init;	/* lnet_init()
+							   called? */
 	/* Have I called LNetNIInit myself? */
-	int				ln_niinit_self;
+	int				  ln_niinit_self;
 	/* LNetNIInit/LNetNIFini counter */
-	int				ln_refcount;
+	int				  ln_refcount;
 	/* shutdown in progress */
-	int				ln_shutdown;
+	int				  ln_shutdown;
 
-	int				ln_routing;	/* am I a router? */
-	lnet_pid_t			ln_pid;		/* requested pid */
+	int				  ln_routing;	/* am I a router? */
+	lnet_pid_t			  ln_pid;	/* requested pid */
 	/* uniquely identifies this ni in this epoch */
-	__u64				ln_interface_cookie;
+	__u64				  ln_interface_cookie;
 	/* registered LNDs */
-	struct list_head			ln_lnds;
+	struct list_head		  ln_lnds;
 
 	/* space for network names */
-	char				*ln_network_tokens;
-	int				ln_network_tokens_nob;
+	char				 *ln_network_tokens;
+	int				  ln_network_tokens_nob;
 	/* test protocol compatibility flags */
-	int				ln_testprotocompat;
+	int				  ln_testprotocompat;
 
 } lnet_t;
 
diff --git a/drivers/staging/lustre/include/linux/lnet/lnetst.h b/drivers/staging/lustre/include/linux/lnet/lnetst.h
index 57432fd..ea1e0c6 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetst.h
@@ -49,99 +49,107 @@
 #define LST_FEATS_EMPTY		(LST_FEAT_NONE)
 #define LST_FEATS_MASK		(LST_FEAT_NONE | LST_FEAT_BULK_LEN)
 
-#define LST_NAME_SIZE	   32	      /* max name buffer length */
-
-#define LSTIO_DEBUG	     0xC00	   /* debug */
-#define LSTIO_SESSION_NEW       0xC01	   /* create session */
-#define LSTIO_SESSION_END       0xC02	   /* end session */
-#define LSTIO_SESSION_INFO      0xC03	   /* query session */
-#define LSTIO_GROUP_ADD	 0xC10	   /* add group */
-#define LSTIO_GROUP_LIST	0xC11	   /* list all groups in session */
-#define LSTIO_GROUP_INFO	0xC12	   /* query default information of specified group */
-#define LSTIO_GROUP_DEL	 0xC13	   /* delete group */
-#define LSTIO_NODES_ADD	 0xC14	   /* add nodes to specified group */
-#define LSTIO_GROUP_UPDATE      0xC15	   /* update group */
-#define LSTIO_BATCH_ADD	 0xC20	   /* add batch */
-#define LSTIO_BATCH_START       0xC21	   /* start batch */
-#define LSTIO_BATCH_STOP	0xC22	   /* stop batch */
-#define LSTIO_BATCH_DEL	 0xC23	   /* delete batch */
-#define LSTIO_BATCH_LIST	0xC24	   /* show all batches in the session */
-#define LSTIO_BATCH_INFO	0xC25	   /* show defail of specified batch */
-#define LSTIO_TEST_ADD	  0xC26	   /* add test (to batch) */
-#define LSTIO_BATCH_QUERY       0xC27	   /* query batch status */
-#define LSTIO_STAT_QUERY	0xC30	   /* get stats */
-
-typedef struct {
-	lnet_nid_t	      ses_nid;		/* nid of console node */
-	__u64		   ses_stamp;	      /* time stamp */
-} lst_sid_t;					    /*** session id */
+#define LST_NAME_SIZE		32	/* max name buffer length */
+
+#define LSTIO_DEBUG		0xC00	/* debug */
+#define LSTIO_SESSION_NEW	0xC01	/* create session */
+#define LSTIO_SESSION_END	0xC02	/* end session */
+#define LSTIO_SESSION_INFO	0xC03	/* query session */
+#define LSTIO_GROUP_ADD		0xC10	/* add group */
+#define LSTIO_GROUP_LIST	0xC11	/* list all groups in session */
+#define LSTIO_GROUP_INFO	0xC12	/* query default information of
+					 * specified group */
+#define LSTIO_GROUP_DEL		0xC13	/* delete group */
+#define LSTIO_NODES_ADD		0xC14	/* add nodes to specified group */
+#define LSTIO_GROUP_UPDATE      0xC15	/* update group */
+#define LSTIO_BATCH_ADD		0xC20	/* add batch */
+#define LSTIO_BATCH_START	0xC21	/* start batch */
+#define LSTIO_BATCH_STOP	0xC22	/* stop batch */
+#define LSTIO_BATCH_DEL		0xC23	/* delete batch */
+#define LSTIO_BATCH_LIST	0xC24	/* show all batches in the session */
+#define LSTIO_BATCH_INFO	0xC25	/* show defail of specified batch */
+#define LSTIO_TEST_ADD		0xC26	/* add test (to batch) */
+#define LSTIO_BATCH_QUERY	0xC27	/* query batch status */
+#define LSTIO_STAT_QUERY	0xC30	/* get stats */
+
+typedef struct {
+	lnet_nid_t	ses_nid;	/* nid of console node */
+	__u64		ses_stamp;	/* time stamp */
+} lst_sid_t;				/*** session id */
 
 extern lst_sid_t LST_INVALID_SID;
 
 typedef struct {
-	__u64		   bat_id;		 /* unique id in session */
-} lst_bid_t;					    /*** batch id (group of tests) */
+	__u64	bat_id;		/* unique id in session */
+} lst_bid_t;			/*** batch id (group of tests) */
 
 /* Status of test node */
-#define LST_NODE_ACTIVE	 0x1		     /* node in this session */
-#define LST_NODE_BUSY	   0x2		     /* node is taken by other session */
-#define LST_NODE_DOWN	   0x4		     /* node is down */
-#define LST_NODE_UNKNOWN	0x8		     /* node not in session */
+#define LST_NODE_ACTIVE		0x1	/* node in this session */
+#define LST_NODE_BUSY		0x2	/* node is taken by other session */
+#define LST_NODE_DOWN		0x4	/* node is down */
+#define LST_NODE_UNKNOWN	0x8	/* node not in session */
 
 typedef struct {
-	lnet_process_id_t       nde_id;		 /* id of node */
-	int		     nde_state;	      /* state of node */
-} lstcon_node_ent_t;				    /*** node entry, for list_group command */
+	lnet_process_id_t       nde_id;		/* id of node */
+	int			nde_state;	/* state of node */
+} lstcon_node_ent_t;		/*** node entry, for list_group command */
 
 typedef struct {
-	int		     nle_nnode;	      /* # of nodes */
-	int		     nle_nactive;	    /* # of active nodes */
-	int		     nle_nbusy;	      /* # of busy nodes */
-	int		     nle_ndown;	      /* # of down nodes */
-	int		     nle_nunknown;	   /* # of unknown nodes */
-} lstcon_ndlist_ent_t;				  /*** node_list entry, for list_batch command */
+	int	nle_nnode;	/* # of nodes */
+	int	nle_nactive;	/* # of active nodes */
+	int	nle_nbusy;	/* # of busy nodes */
+	int	nle_ndown;	/* # of down nodes */
+	int	nle_nunknown;	/* # of unknown nodes */
+} lstcon_ndlist_ent_t;		/*** node_list entry, for list_batch command */
 
 typedef struct {
-	int		     tse_type;	       /* test type */
-	int		     tse_loop;	       /* loop count */
-	int		     tse_concur;	     /* concurrency of test */
-} lstcon_test_ent_t;				    /*** test summary entry, for list_batch command */
+	int	tse_type;       /* test type */
+	int	tse_loop;       /* loop count */
+	int	tse_concur;     /* concurrency of test */
+} lstcon_test_ent_t;		/*** test summary entry, for
+				 *** list_batch command */
 
 typedef struct {
-	int		     bae_state;	      /* batch status */
-	int		     bae_timeout;	    /* batch timeout */
-	int		     bae_ntest;	      /* # of tests in the batch */
-} lstcon_batch_ent_t;				   /*** batch summary entry, for list_batch command */
+	int	bae_state;	/* batch status */
+	int	bae_timeout;	/* batch timeout */
+	int	bae_ntest;	/* # of tests in the batch */
+} lstcon_batch_ent_t;		/*** batch summary entry, for
+				 *** list_batch command */
 
 typedef struct {
-	lstcon_ndlist_ent_t     tbe_cli_nle;	    /* client (group) node_list entry */
-	lstcon_ndlist_ent_t     tbe_srv_nle;	    /* server (group) node_list entry */
+	lstcon_ndlist_ent_t     tbe_cli_nle;	/* client (group) node_list
+						 * entry */
+	lstcon_ndlist_ent_t     tbe_srv_nle;	/* server (group) node_list
+						 * entry */
 	union {
-		lstcon_test_ent_t  tbe_test;	    /* test entry */
-		lstcon_batch_ent_t tbe_batch;	   /* batch entry */
+		lstcon_test_ent_t  tbe_test;	/* test entry */
+		lstcon_batch_ent_t tbe_batch;	/* batch entry */
 	} u;
-} lstcon_test_batch_ent_t;			      /*** test/batch verbose information entry,
-							 *** for list_batch command */
+} lstcon_test_batch_ent_t;	/*** test/batch verbose information entry,
+				 *** for list_batch command */
 
 typedef struct {
-	struct list_head	      rpe_link;	       /* link chain */
-	lnet_process_id_t       rpe_peer;	       /* peer's id */
-	struct timeval	  rpe_stamp;	      /* time stamp of RPC */
-	int		     rpe_state;	      /* peer's state */
-	int		     rpe_rpc_errno;	  /* RPC errno */
+	struct list_head	rpe_link;	/* link chain */
+	lnet_process_id_t	rpe_peer;	/* peer's id */
+	struct timeval		rpe_stamp;	/* time stamp of RPC */
+	int			rpe_state;	/* peer's state */
+	int			rpe_rpc_errno;	/* RPC errno */
 
-	lst_sid_t	       rpe_sid;		/* peer's session id */
-	int		     rpe_fwk_errno;	  /* framework errno */
-	int		     rpe_priv[4];	    /* private data */
-	char		    rpe_payload[0];	 /* private reply payload */
+	lst_sid_t		rpe_sid;	/* peer's session id */
+	int			rpe_fwk_errno;	/* framework errno */
+	int			rpe_priv[4];	/* private data */
+	char			rpe_payload[0];	/* private reply payload */
 } lstcon_rpc_ent_t;
 
 typedef struct {
-	int		     trs_rpc_stat[4];	/* RPCs stat (0: total, 1: failed, 2: finished, 4: reserved */
-	int		     trs_rpc_errno;	  /* RPC errno */
-	int		     trs_fwk_stat[8];	/* framework stat */
-	int		     trs_fwk_errno;	  /* errno of the first remote error */
-	void		   *trs_fwk_private;	/* private framework stat */
+	int	trs_rpc_stat[4];	/* RPCs stat (0: total
+						      1: failed
+						      2: finished
+						      4: reserved */
+	int	trs_rpc_errno;		/* RPC errno */
+	int	trs_fwk_stat[8];	/* framework stat */
+	int	trs_fwk_errno;		/* errno of the first remote error */
+	void	*trs_fwk_private;	/* private framework stat */
 } lstcon_trans_stat_t;
 
 static inline int
@@ -236,234 +244,263 @@ lstcon_statqry_stat_failure(lstcon_trans_stat_t *stat, int inc)
 
 /* create a session */
 typedef struct {
-	int		     lstio_ses_key;	  /* IN: local key */
-	int		     lstio_ses_timeout;      /* IN: session timeout */
-	int		     lstio_ses_force;	/* IN: force create ? */
+	int		 lstio_ses_key;		/* IN: local key */
+	int		 lstio_ses_timeout;	/* IN: session timeout */
+	int		 lstio_ses_force;	/* IN: force create ? */
 	/** IN: session features */
-	unsigned		lstio_ses_feats;
-	lst_sid_t	      *lstio_ses_idp;	  /* OUT: session id */
-	int		     lstio_ses_nmlen;	/* IN: name length */
-	char		   *lstio_ses_namep;	/* IN: session name */
+	unsigned	 lstio_ses_feats;
+	lst_sid_t	*lstio_ses_idp;		/* OUT: session id */
+	int		 lstio_ses_nmlen;	/* IN: name length */
+	char		*lstio_ses_namep;	/* IN: session name */
 } lstio_session_new_args_t;
 
 /* query current session */
 typedef struct {
-	lst_sid_t	      *lstio_ses_idp;	  /* OUT: session id */
-	int		    *lstio_ses_keyp;	 /* OUT: local key */
+	lst_sid_t		*lstio_ses_idp;		/* OUT: session id */
+	int			*lstio_ses_keyp;	/* OUT: local key */
 	/** OUT: session features */
-	unsigned	       *lstio_ses_featp;
-	lstcon_ndlist_ent_t    *lstio_ses_ndinfo;       /* OUT: */
-	int		     lstio_ses_nmlen;	/* IN: name length */
-	char		   *lstio_ses_namep;	/* OUT: session name */
+	unsigned		*lstio_ses_featp;
+	lstcon_ndlist_ent_t	*lstio_ses_ndinfo;	/* OUT: */
+	int			 lstio_ses_nmlen;	/* IN: name length */
+	char			*lstio_ses_namep;	/* OUT: session name */
 } lstio_session_info_args_t;
 
 /* delete a session */
 typedef struct {
-	int		     lstio_ses_key;	  /* IN: session key */
+	int			lstio_ses_key;	/* IN: session key */
 } lstio_session_end_args_t;
 
-#define LST_OPC_SESSION	 1
-#define LST_OPC_GROUP	   2
-#define LST_OPC_NODES	   3
+#define LST_OPC_SESSION		1
+#define LST_OPC_GROUP		2
+#define LST_OPC_NODES		3
 #define LST_OPC_BATCHCLI	4
 #define LST_OPC_BATCHSRV	5
 
 typedef struct {
-	int		     lstio_dbg_key;	  /* IN: session key */
-	int		     lstio_dbg_type;	 /* IN: debug sessin|batch|group|nodes list */
-	int		     lstio_dbg_flags;	/* IN: reserved debug flags */
-	int		     lstio_dbg_timeout;      /* IN: timeout of debug */
-
-	int		     lstio_dbg_nmlen;	/* IN: len of name */
-	char		   *lstio_dbg_namep;	/* IN: name of group|batch */
-	int		     lstio_dbg_count;	/* IN: # of test nodes to debug */
-	lnet_process_id_t      *lstio_dbg_idsp;	 /* IN: id of test nodes */
-	struct list_head	     *lstio_dbg_resultp;      /* OUT: list head of result buffer */
+	int			 lstio_dbg_key;		/* IN: session key */
+	int			 lstio_dbg_type;	/* IN: debug
+								session|batch|
+								group|nodes
+								list */
+	int			 lstio_dbg_flags;	/* IN: reserved debug
+							       flags */
+	int			 lstio_dbg_timeout;	/* IN: timeout of
+							       debug */
+	int			 lstio_dbg_nmlen;	/* IN: len of name */
+	char			*lstio_dbg_namep;	/* IN: name of
+							       group|batch */
+	int			 lstio_dbg_count;	/* IN: # of test nodes
+							       to debug */
+	lnet_process_id_t	*lstio_dbg_idsp;	/* IN: id of test
+							       nodes */
+	struct list_head	*lstio_dbg_resultp;	/* OUT: list head of
+								result buffer */
 } lstio_debug_args_t;
 
 typedef struct {
-	int		     lstio_grp_key;	  /* IN: session key */
-	int		     lstio_grp_nmlen;	/* IN: name length */
-	char		   *lstio_grp_namep;	/* IN: group name */
+	int	 lstio_grp_key;		/* IN: session key */
+	int	 lstio_grp_nmlen;	/* IN: name length */
+	char	*lstio_grp_namep;	/* IN: group name */
 } lstio_group_add_args_t;
 
 typedef struct {
-	int		     lstio_grp_key;	  /* IN: session key */
-	int		     lstio_grp_nmlen;	/* IN: name length */
-	char		   *lstio_grp_namep;	/* IN: group name */
+	int	 lstio_grp_key;		/* IN: session key */
+	int	 lstio_grp_nmlen;	/* IN: name length */
+	char	*lstio_grp_namep;	/* IN: group name */
 } lstio_group_del_args_t;
 
-#define LST_GROUP_CLEAN	 1		       /* remove inactive nodes in the group */
-#define LST_GROUP_REFRESH       2		       /* refresh inactive nodes in the group */
-#define LST_GROUP_RMND	  3		       /* delete nodes from the group */
-
-typedef struct {
-	int		     lstio_grp_key;	  /* IN: session key */
-	int		     lstio_grp_opc;	  /* IN: OPC */
-	int		     lstio_grp_args;	 /* IN: arguments */
-	int		     lstio_grp_nmlen;	/* IN: name length */
-	char		   *lstio_grp_namep;	/* IN: group name */
-	int		     lstio_grp_count;	/* IN: # of nodes id */
-	lnet_process_id_t      *lstio_grp_idsp;	 /* IN: array of nodes */
-	struct list_head	     *lstio_grp_resultp;      /* OUT: list head of result buffer */
+#define LST_GROUP_CLEAN		1	/* remove inactive nodes in the group */
+#define LST_GROUP_REFRESH	2	/* refresh inactive nodes
+					 * in the group */
+#define LST_GROUP_RMND		3	/* delete nodes from the group */
+
+typedef struct {
+	int			 lstio_grp_key;		/* IN: session key */
+	int			 lstio_grp_opc;		/* IN: OPC */
+	int			 lstio_grp_args;	/* IN: arguments */
+	int			 lstio_grp_nmlen;	/* IN: name length */
+	char			*lstio_grp_namep;	/* IN: group name */
+	int			 lstio_grp_count;	/* IN: # of nodes id */
+	lnet_process_id_t	*lstio_grp_idsp;	/* IN: array of nodes */
+	struct list_head	*lstio_grp_resultp;	/* OUT: list head of
+								result buffer */
 } lstio_group_update_args_t;
 
 typedef struct {
-	int		     lstio_grp_key;	  /* IN: session key */
-	int		     lstio_grp_nmlen;	/* IN: name length */
-	char		   *lstio_grp_namep;	/* IN: group name */
-	int		     lstio_grp_count;	/* IN: # of nodes */
+	int			 lstio_grp_key;		/* IN: session key */
+	int			 lstio_grp_nmlen;	/* IN: name length */
+	char			*lstio_grp_namep;	/* IN: group name */
+	int			 lstio_grp_count;	/* IN: # of nodes */
 	/** OUT: session features */
-	unsigned	       *lstio_grp_featp;
-	lnet_process_id_t      *lstio_grp_idsp;	 /* IN: nodes */
-	struct list_head	     *lstio_grp_resultp;      /* OUT: list head of result buffer */
+	unsigned		*lstio_grp_featp;
+	lnet_process_id_t	*lstio_grp_idsp;	/* IN: nodes */
+	struct list_head	*lstio_grp_resultp;	/* OUT: list head of
+								result buffer */
 } lstio_group_nodes_args_t;
 
 typedef struct {
-	int		     lstio_grp_key;	  /* IN: session key */
-	int		     lstio_grp_idx;	  /* IN: group idx */
-	int		     lstio_grp_nmlen;	/* IN: name len */
-	char		   *lstio_grp_namep;	/* OUT: name */
+	int	 lstio_grp_key;		/* IN: session key */
+	int	 lstio_grp_idx;		/* IN: group idx */
+	int	 lstio_grp_nmlen;	/* IN: name len */
+	char	*lstio_grp_namep;	/* OUT: name */
 } lstio_group_list_args_t;
 
 typedef struct {
-	int		     lstio_grp_key;	  /* IN: session key */
-	int		     lstio_grp_nmlen;	/* IN: name len */
-	char		   *lstio_grp_namep;	/* IN: name */
-	lstcon_ndlist_ent_t    *lstio_grp_entp;	 /* OUT: description of group */
-
-	int		    *lstio_grp_idxp;	 /* IN/OUT: node index */
-	int		    *lstio_grp_ndentp;       /* IN/OUT: # of nodent */
-	lstcon_node_ent_t      *lstio_grp_dentsp;       /* OUT: nodent array */
+	int			 lstio_grp_key;		/* IN: session key */
+	int			 lstio_grp_nmlen;	/* IN: name len */
+	char			*lstio_grp_namep;	/* IN: name */
+	lstcon_ndlist_ent_t	*lstio_grp_entp;	/* OUT: description of
+								group */
+	int			*lstio_grp_idxp;	/* IN/OUT: node index */
+	int			*lstio_grp_ndentp;	/* IN/OUT: # of nodent */
+	lstcon_node_ent_t	*lstio_grp_dentsp;	/* OUT: nodent array */
 } lstio_group_info_args_t;
 
-#define LST_DEFAULT_BATCH       "batch"		 /* default batch name */
+#define LST_DEFAULT_BATCH	"batch"			/* default batch name */
 
 typedef struct {
-	int		     lstio_bat_key;	  /* IN: session key */
-	int		     lstio_bat_nmlen;	/* IN: name length */
-	char		   *lstio_bat_namep;	/* IN: batch name */
+	int	 lstio_bat_key;		/* IN: session key */
+	int	 lstio_bat_nmlen;	/* IN: name length */
+	char	*lstio_bat_namep;	/* IN: batch name */
 } lstio_batch_add_args_t;
 
 typedef struct {
-	int		     lstio_bat_key;	  /* IN: session key */
-	int		     lstio_bat_nmlen;	/* IN: name length */
-	char		   *lstio_bat_namep;	/* IN: batch name */
+	int	 lstio_bat_key;		/* IN: session key */
+	int	 lstio_bat_nmlen;	/* IN: name length */
+	char	*lstio_bat_namep;	/* IN: batch name */
 } lstio_batch_del_args_t;
 
 typedef struct {
-	int		     lstio_bat_key;	  /* IN: session key */
-	int		     lstio_bat_timeout;      /* IN: timeout for the batch */
-	int		     lstio_bat_nmlen;	/* IN: name length */
-	char		   *lstio_bat_namep;	/* IN: batch name */
-	struct list_head	     *lstio_bat_resultp;      /* OUT: list head of result buffer */
+	int			 lstio_bat_key;		/* IN: session key */
+	int			 lstio_bat_timeout;	/* IN: timeout for
+							       the batch */
+	int			 lstio_bat_nmlen;	/* IN: name length */
+	char			*lstio_bat_namep;	/* IN: batch name */
+	struct list_head	*lstio_bat_resultp;	/* OUT: list head of
+								result buffer */
 } lstio_batch_run_args_t;
 
 typedef struct {
-	int		     lstio_bat_key;	  /* IN: session key */
-	int		     lstio_bat_force;	/* IN: abort unfinished test RPC */
-	int		     lstio_bat_nmlen;	/* IN: name length */
-	char		   *lstio_bat_namep;	/* IN: batch name */
-	struct list_head	     *lstio_bat_resultp;      /* OUT: list head of result buffer */
+	int			 lstio_bat_key;		/* IN: session key */
+	int			 lstio_bat_force;	/* IN: abort unfinished
+							       test RPC */
+	int			 lstio_bat_nmlen;	/* IN: name length */
+	char			*lstio_bat_namep;	/* IN: batch name */
+	struct list_head	*lstio_bat_resultp;	/* OUT: list head of
+								result buffer */
 } lstio_batch_stop_args_t;
 
 typedef struct {
-	int		     lstio_bat_key;	  /* IN: session key */
-	int		     lstio_bat_testidx;      /* IN: test index */
-	int		     lstio_bat_client;       /* IN: is test client? */
-	int		     lstio_bat_timeout;      /* IN: timeout for waiting */
-	int		     lstio_bat_nmlen;	/* IN: name length */
-	char		   *lstio_bat_namep;	/* IN: batch name */
-	struct list_head	     *lstio_bat_resultp;      /* OUT: list head of result buffer */
+	int			 lstio_bat_key;		/* IN: session key */
+	int			 lstio_bat_testidx;	/* IN: test index */
+	int			 lstio_bat_client;	/* IN: we testing
+							       client? */
+	int			 lstio_bat_timeout;	/* IN: timeout for
+							       waiting */
+	int			 lstio_bat_nmlen;	/* IN: name length */
+	char			*lstio_bat_namep;	/* IN: batch name */
+	struct list_head	*lstio_bat_resultp;	/* OUT: list head of
+								result buffer */
 } lstio_batch_query_args_t;
 
 typedef struct {
-	int		     lstio_bat_key;	  /* IN: session key */
-	int		     lstio_bat_idx;	  /* IN: index */
-	int		     lstio_bat_nmlen;	/* IN: name length */
-	char		   *lstio_bat_namep;	/* IN: batch name */
+	int	 lstio_bat_key;		/* IN: session key */
+	int	 lstio_bat_idx;		/* IN: index */
+	int	 lstio_bat_nmlen;	/* IN: name length */
+	char	*lstio_bat_namep;	/* IN: batch name */
 } lstio_batch_list_args_t;
 
 typedef struct {
-	int		     lstio_bat_key;	  /* IN: session key */
-	int		     lstio_bat_nmlen;	/* IN: name length */
-	char		   *lstio_bat_namep;	/* IN: name */
-	int		     lstio_bat_server;       /* IN: query server or not */
-	int		     lstio_bat_testidx;      /* IN: test index */
-	lstcon_test_batch_ent_t *lstio_bat_entp;	/* OUT: batch ent */
+	int			 lstio_bat_key;		/* IN: session key */
+	int			 lstio_bat_nmlen;	/* IN: name length */
+	char			*lstio_bat_namep;	/* IN: name */
+	int			 lstio_bat_server;	/* IN: query server
+							       or not */
+	int			 lstio_bat_testidx;	/* IN: test index */
+	lstcon_test_batch_ent_t	*lstio_bat_entp;	/* OUT: batch ent */
 
-	int		    *lstio_bat_idxp;	 /* IN/OUT: index of node */
-	int		    *lstio_bat_ndentp;       /* IN/OUT: # of nodent */
-	lstcon_node_ent_t      *lstio_bat_dentsp;       /* array of nodent */
+	int			*lstio_bat_idxp;	/* IN/OUT: index of node */
+	int			*lstio_bat_ndentp;	/* IN/OUT: # of nodent */
+	lstcon_node_ent_t	*lstio_bat_dentsp;	/* array of nodent */
 } lstio_batch_info_args_t;
 
 /* add stat in session */
 typedef struct {
-	int		     lstio_sta_key;	  /* IN: session key */
-	int		     lstio_sta_timeout;      /* IN: timeout for stat request */
-	int		     lstio_sta_nmlen;	/* IN: group name length */
-	char		   *lstio_sta_namep;	/* IN: group name */
-	int		     lstio_sta_count;	/* IN: # of pid */
-	lnet_process_id_t      *lstio_sta_idsp;	 /* IN: pid */
-	struct list_head	     *lstio_sta_resultp;      /* OUT: list head of result buffer */
+	int			 lstio_sta_key;		/* IN: session key */
+	int			 lstio_sta_timeout;	/* IN: timeout for
+							       stat request */
+	int			 lstio_sta_nmlen;	/* IN: group name
+							       length */
+	char			*lstio_sta_namep;	/* IN: group name */
+	int			 lstio_sta_count;	/* IN: # of pid */
+	lnet_process_id_t	*lstio_sta_idsp;	/* IN: pid */
+	struct list_head	*lstio_sta_resultp;	/* OUT: list head of
+								result buffer */
 } lstio_stat_args_t;
 
 typedef enum {
-	LST_TEST_BULK   = 1,
-	LST_TEST_PING   = 2
+	LST_TEST_BULK	= 1,
+	LST_TEST_PING	= 2
 } lst_test_type_t;
 
 /* create a test in a batch */
-#define LST_MAX_CONCUR	  1024		    /* Max concurrency of test */
-
-typedef struct {
-	int		     lstio_tes_key;	  /* IN: session key */
-	int		     lstio_tes_bat_nmlen;    /* IN: batch name len */
-	char		   *lstio_tes_bat_name;     /* IN: batch name */
-	int		     lstio_tes_type;	 /* IN: test type */
-	int		     lstio_tes_oneside;      /* IN: one sided test */
-	int		     lstio_tes_loop;	 /* IN: loop count */
-	int		     lstio_tes_concur;       /* IN: concurrency */
-
-	int		     lstio_tes_dist;	 /* IN: node distribution in destination groups */
-	int		     lstio_tes_span;	 /* IN: node span in destination groups */
-	int		     lstio_tes_sgrp_nmlen;   /* IN: source group name length */
-	char		   *lstio_tes_sgrp_name;    /* IN: group name */
-	int		     lstio_tes_dgrp_nmlen;   /* IN: destination group name length */
-	char		   *lstio_tes_dgrp_name;    /* IN: group name */
-
-	int		     lstio_tes_param_len;    /* IN: param buffer len */
-	void		   *lstio_tes_param;	/* IN: parameter for specified test:
-							       lstio_bulk_param_t,
-							       lstio_ping_param_t,
-							       ... more */
-	int		    *lstio_tes_retp;	 /* OUT: private returned value */
-	struct list_head	     *lstio_tes_resultp;      /* OUT: list head of result buffer */
+#define LST_MAX_CONCUR	1024	/* Max concurrency of test */
+
+typedef struct {
+	int		  lstio_tes_key;	/* IN: session key */
+	int		  lstio_tes_bat_nmlen;	/* IN: batch name len */
+	char		 *lstio_tes_bat_name;	/* IN: batch name */
+	int		  lstio_tes_type;	/* IN: test type */
+	int		  lstio_tes_oneside;	/* IN: one sided test */
+	int		  lstio_tes_loop;	/* IN: loop count */
+	int		  lstio_tes_concur;	/* IN: concurrency */
+
+	int		  lstio_tes_dist;	/* IN: node distribution in
+						       destination groups */
+	int		  lstio_tes_span;	/* IN: node span in
+						       destination groups */
+	int		  lstio_tes_sgrp_nmlen;	/* IN: source group
+						       name length */
+	char		 *lstio_tes_sgrp_name;	/* IN: group name */
+	int		  lstio_tes_dgrp_nmlen;	/* IN: destination group
+						       name length */
+	char		 *lstio_tes_dgrp_name;	/* IN: group name */
+
+	int		  lstio_tes_param_len;	/* IN: param buffer len */
+	void		 *lstio_tes_param;	/* IN: parameter for specified
+						       test:
+						       lstio_bulk_param_t,
+						       lstio_ping_param_t,
+						       ... more */
+	int		 *lstio_tes_retp;	/* OUT: private returned
+							value */
+	struct list_head *lstio_tes_resultp;	/* OUT: list head of
+							result buffer */
 } lstio_test_args_t;
 
 typedef enum {
-	LST_BRW_READ    = 1,
-	LST_BRW_WRITE   = 2
+	LST_BRW_READ	= 1,
+	LST_BRW_WRITE	= 2
 } lst_brw_type_t;
 
 typedef enum {
-	LST_BRW_CHECK_NONE   = 1,
-	LST_BRW_CHECK_SIMPLE = 2,
-	LST_BRW_CHECK_FULL   = 3
+	LST_BRW_CHECK_NONE	= 1,
+	LST_BRW_CHECK_SIMPLE	= 2,
+	LST_BRW_CHECK_FULL	= 3
 } lst_brw_flags_t;
 
 typedef struct {
-	int		     blk_opc;		/* bulk operation code */
-	int		     blk_size;	       /* size (bytes) */
-	int		     blk_time;	       /* time of running the test*/
-	int		     blk_flags;	      /* reserved flags */
+	int	blk_opc;	/* bulk operation code */
+	int	blk_size;       /* size (bytes) */
+	int	blk_time;       /* time of running the test*/
+	int	blk_flags;      /* reserved flags */
 } lst_test_bulk_param_t;
 
 typedef struct {
-	int		     png_size;	       /* size of ping message */
-	int		     png_time;	       /* time */
-	int		     png_loop;	       /* loop */
-	int		     png_flags;	      /* reserved flags */
+	int	png_size;	/* size of ping message */
+	int	png_time;	/* time */
+	int	png_loop;	/* loop */
+	int	png_flags;	/* reserved flags */
 } lst_test_ping_param_t;
 
 typedef struct {
diff --git a/drivers/staging/lustre/include/linux/lnet/socklnd.h b/drivers/staging/lustre/include/linux/lnet/socklnd.h
index f7c7b08..4c790bd 100644
--- a/drivers/staging/lustre/include/linux/lnet/socklnd.h
+++ b/drivers/staging/lustre/include/linux/lnet/socklnd.h
@@ -42,29 +42,29 @@
 
 #define SOCKLND_CONN_NONE     (-1)
 #define SOCKLND_CONN_ANY	0
-#define SOCKLND_CONN_CONTROL    1
-#define SOCKLND_CONN_BULK_IN    2
-#define SOCKLND_CONN_BULK_OUT   3
-#define SOCKLND_CONN_NTYPES     4
+#define SOCKLND_CONN_CONTROL	1
+#define SOCKLND_CONN_BULK_IN	2
+#define SOCKLND_CONN_BULK_OUT	3
+#define SOCKLND_CONN_NTYPES	4
 
 #define SOCKLND_CONN_ACK	SOCKLND_CONN_BULK_IN
 
 typedef struct {
-	__u32		   kshm_magic;     /* magic number of socklnd message */
-	__u32		   kshm_version;   /* version of socklnd message */
-	lnet_nid_t	      kshm_src_nid;   /* sender's nid */
-	lnet_nid_t	      kshm_dst_nid;   /* destination nid */
-	lnet_pid_t	      kshm_src_pid;   /* sender's pid */
-	lnet_pid_t	      kshm_dst_pid;   /* destination pid */
-	__u64		   kshm_src_incarnation; /* sender's incarnation */
-	__u64		   kshm_dst_incarnation; /* destination's incarnation */
-	__u32		   kshm_ctype;     /* connection type */
-	__u32		   kshm_nips;      /* # IP addrs */
-	__u32		   kshm_ips[0];    /* IP addrs */
+	__u32		kshm_magic;	/* magic number of socklnd message */
+	__u32		kshm_version;	/* version of socklnd message */
+	lnet_nid_t      kshm_src_nid;	/* sender's nid */
+	lnet_nid_t	kshm_dst_nid;	/* destination nid */
+	lnet_pid_t	kshm_src_pid;	/* sender's pid */
+	lnet_pid_t	kshm_dst_pid;	/* destination pid */
+	__u64		kshm_src_incarnation; /* sender's incarnation */
+	__u64		kshm_dst_incarnation; /* destination's incarnation */
+	__u32		kshm_ctype;	/* connection type */
+	__u32		kshm_nips;	/* # IP addrs */
+	__u32		kshm_ips[0];	/* IP addrs */
 } WIRE_ATTR ksock_hello_msg_t;
 
 typedef struct {
-	lnet_hdr_t	      ksnm_hdr;       /* lnet hdr */
+	lnet_hdr_t	ksnm_hdr;	/* lnet hdr */
 
 	/*
 	 * ksnm_payload is removed because of winnt compiler's limitation:
@@ -75,28 +75,29 @@ typedef struct {
 } WIRE_ATTR ksock_lnet_msg_t;
 
 typedef struct {
-	__u32		   ksm_type;       /* type of socklnd message */
-	__u32		   ksm_csum;       /* checksum if != 0 */
-	__u64		   ksm_zc_cookies[2]; /* Zero-Copy request/ACK cookie */
+	__u32	ksm_type;		/* type of socklnd message */
+	__u32	ksm_csum;		/* checksum if != 0 */
+	__u64	ksm_zc_cookies[2];	/* Zero-Copy request/ACK cookie */
 	union {
-		ksock_lnet_msg_t lnetmsg;       /* lnet message, it's empty if it's NOOP */
+		ksock_lnet_msg_t lnetmsg;/* lnet message, it's empty if
+					  * it's NOOP */
 	} WIRE_ATTR ksm_u;
 } WIRE_ATTR ksock_msg_t;
 
 static inline void
 socklnd_init_msg(ksock_msg_t *msg, int type)
 {
-	msg->ksm_csum	   = 0;
-	msg->ksm_type	   = type;
-	msg->ksm_zc_cookies[0]  = msg->ksm_zc_cookies[1]  = 0;
+	msg->ksm_csum = 0;
+	msg->ksm_type = type;
+	msg->ksm_zc_cookies[0] = msg->ksm_zc_cookies[1]  = 0;
 }
 
-#define KSOCK_MSG_NOOP	  0xc0	    /* ksm_u empty */
-#define KSOCK_MSG_LNET	  0xc1	    /* lnet msg */
+#define KSOCK_MSG_NOOP	0xC0	/* ksm_u empty */
+#define KSOCK_MSG_LNET	0xC1	/* lnet msg */
 
 /* We need to know this number to parse hello msg from ksocklnd in
  * other LND (usocklnd, for example) */
-#define KSOCK_PROTO_V2	  2
-#define KSOCK_PROTO_V3	  3
+#define KSOCK_PROTO_V2	2
+#define KSOCK_PROTO_V3	3
 
 #endif
diff --git a/drivers/staging/lustre/include/linux/lnet/types.h b/drivers/staging/lustre/include/linux/lnet/types.h
index 32b9431..06d73c0 100644
--- a/drivers/staging/lustre/include/linux/lnet/types.h
+++ b/drivers/staging/lustre/include/linux/lnet/types.h
@@ -48,7 +48,7 @@
 /** Portal reserved for LNet's own use.
  * \see lustre/include/lustre/lustre_idl.h for Lustre portal assignments.
  */
-#define LNET_RESERVED_PORTAL      0
+#define LNET_RESERVED_PORTAL	0
 
 /**
  * Address of an end-point in an LNet network.
@@ -68,15 +68,15 @@ typedef __u64 lnet_nid_t;
 typedef __u32 lnet_pid_t;
 
 /** wildcard NID that matches any end-point address */
-#define LNET_NID_ANY      ((lnet_nid_t) -1)
+#define LNET_NID_ANY	((lnet_nid_t) -1)
 /** wildcard PID that matches any lnet_pid_t */
-#define LNET_PID_ANY      ((lnet_pid_t) -1)
+#define LNET_PID_ANY	((lnet_pid_t) -1)
 
 #define LNET_PID_RESERVED 0xf0000000 /* reserved bits in PID */
 #define LNET_PID_USERFLAG 0x80000000 /* set in userspace peers */
 #define LNET_PID_LUSTRE	  12345
 
-#define LNET_TIME_FOREVER    (-1)
+#define LNET_TIME_FOREVER (-1)
 
 /* how an LNET NID encodes net:address */
 /** extract the address part of an lnet_nid_t */
@@ -380,8 +380,8 @@ typedef struct {
 	 * one must start on page boundary, and all but the last must end on
 	 * page boundary.
 	 */
-	void	    *start;
-	unsigned int     length;
+	void		*start;
+	unsigned int	 length;
 	/**
 	 * Specifies the maximum number of operations that can be performed
 	 * on the memory descriptor. An operation is any action that could
@@ -392,7 +392,7 @@ typedef struct {
 	 * there is no bound on the number of operations that may be applied
 	 * to a MD.
 	 */
-	int	      threshold;
+	int		 threshold;
 	/**
 	 * Specifies the largest incoming request that the memory descriptor
 	 * should respond to. When the unused portion of a MD (length -
@@ -400,7 +400,7 @@ typedef struct {
 	 * does not respond to further operations. This value is only used
 	 * if the LNET_MD_MAX_SIZE option is set.
 	 */
-	int	      max_size;
+	int		 max_size;
 	/**
 	 * Specifies the behavior of the memory descriptor. A bitwise OR
 	 * of the following values can be used:
@@ -437,14 +437,14 @@ typedef struct {
 	 *   region (i.e. sum of all fragment lengths) must not be less than
 	 *   \a max_size.
 	 */
-	unsigned int     options;
+	unsigned int	 options;
 	/**
 	 * A user-specified value that is associated with the memory
 	 * descriptor. The value does not need to be a pointer, but must fit
 	 * in the space used by a pointer. This value is recorded in events
 	 * associated with operations on this MD.
 	 */
-	void	    *user_ptr;
+	void		*user_ptr;
 	/**
 	 * A handle for the event queue used to log the operations performed on
 	 * the memory region. If this argument is a NULL handle (i.e. nullified
@@ -461,33 +461,33 @@ typedef struct {
 #define LNET_MTU	(1 << LNET_MTU_BITS)
 
 /** limit on the number of fragments in discontiguous MDs */
-#define LNET_MAX_IOV    256
+#define LNET_MAX_IOV	256
 
 /**
  * Options for the MD structure. See lnet_md_t::options.
  */
-#define LNET_MD_OP_PUT	       (1 << 0)
+#define LNET_MD_OP_PUT		(1 << 0)
 /** See lnet_md_t::options. */
-#define LNET_MD_OP_GET	       (1 << 1)
+#define LNET_MD_OP_GET		(1 << 1)
 /** See lnet_md_t::options. */
 #define LNET_MD_MANAGE_REMOTE	(1 << 2)
-/* unused			    (1 << 3) */
+/* unused			(1 << 3) */
 /** See lnet_md_t::options. */
-#define LNET_MD_TRUNCATE	     (1 << 4)
+#define LNET_MD_TRUNCATE	(1 << 4)
 /** See lnet_md_t::options. */
-#define LNET_MD_ACK_DISABLE	  (1 << 5)
+#define LNET_MD_ACK_DISABLE	(1 << 5)
 /** See lnet_md_t::options. */
 #define LNET_MD_IOVEC		(1 << 6)
 /** See lnet_md_t::options. */
-#define LNET_MD_MAX_SIZE	     (1 << 7)
+#define LNET_MD_MAX_SIZE	(1 << 7)
 /** See lnet_md_t::options. */
-#define LNET_MD_KIOV		 (1 << 8)
+#define LNET_MD_KIOV		(1 << 8)
 
 /* For compatibility with Cray Portals */
-#define LNET_MD_PHYS			 0
+#define LNET_MD_PHYS		0
 
 /** Infinite threshold on MD operations. See lnet_md_t::threshold */
-#define LNET_MD_THRESH_INF       (-1)
+#define LNET_MD_THRESH_INF	(-1)
 
 /* NB lustre portals uses struct iovec internally! */
 typedef struct iovec lnet_md_iovec_t;
@@ -497,15 +497,15 @@ typedef struct iovec lnet_md_iovec_t;
  */
 typedef struct {
 	/** Pointer to the page where the fragment resides */
-	struct page      *kiov_page;
+	struct page	*kiov_page;
 	/** Length in bytes of the fragment */
-	unsigned int     kiov_len;
+	unsigned int	 kiov_len;
 	/**
 	 * Starting offset of the fragment within the page. Note that the
 	 * end of the fragment must not pass the end of the page; i.e.,
 	 * kiov_len + kiov_offset <= PAGE_CACHE_SIZE.
 	 */
-	unsigned int     kiov_offset;
+	unsigned int	 kiov_offset;
 } lnet_kiov_t;
 /** @} lnet_md */
 
@@ -553,7 +553,7 @@ typedef enum {
 	LNET_EVENT_UNLINK,
 } lnet_event_kind_t;
 
-#define LNET_SEQ_BASETYPE       long
+#define LNET_SEQ_BASETYPE	long
 typedef unsigned LNET_SEQ_BASETYPE lnet_seq_t;
 #define LNET_SEQ_GT(a, b)	(((signed LNET_SEQ_BASETYPE)((a) - (b))) > 0)
 
@@ -562,23 +562,23 @@ typedef unsigned LNET_SEQ_BASETYPE lnet_seq_t;
  */
 typedef struct {
 	/** The identifier (nid, pid) of the target. */
-	lnet_process_id_t   target;
+	lnet_process_id_t	target;
 	/** The identifier (nid, pid) of the initiator. */
-	lnet_process_id_t   initiator;
+	lnet_process_id_t	initiator;
 	/**
 	 * The NID of the immediate sender. If the request has been forwarded
 	 * by routers, this is the NID of the last hop; otherwise it's the
 	 * same as the initiator.
 	 */
-	lnet_nid_t	  sender;
+	lnet_nid_t		sender;
 	/** Indicates the type of the event. */
-	lnet_event_kind_t   type;
+	lnet_event_kind_t	type;
 	/** The portal table index specified in the request */
-	unsigned int	pt_index;
+	unsigned int		pt_index;
 	/** A copy of the match bits specified in the request. */
-	__u64	       match_bits;
+	__u64			match_bits;
 	/** The length (in bytes) specified in the request. */
-	unsigned int	rlength;
+	unsigned int		rlength;
 	/**
 	 * The length (in bytes) of the data that was manipulated by the
 	 * operation. For truncated operations, the manipulated length will be
@@ -586,47 +586,47 @@ typedef struct {
 	 * see lnet_md_t). For all other operations, the manipulated length
 	 * will be the length of the requested operation, i.e. rlength.
 	 */
-	unsigned int	mlength;
+	unsigned int		mlength;
 	/**
 	 * The handle to the MD associated with the event. The handle may be
 	 * invalid if the MD has been unlinked.
 	 */
-	lnet_handle_md_t    md_handle;
+	lnet_handle_md_t	md_handle;
 	/**
 	 * A snapshot of the state of the MD immediately after the event has
 	 * been processed. In particular, the threshold field in md will
 	 * reflect the value of the threshold after the operation occurred.
 	 */
-	lnet_md_t	   md;
+	lnet_md_t		md;
 	/**
 	 * 64 bits of out-of-band user data. Only valid for LNET_EVENT_PUT.
 	 * \see LNetPut
 	 */
-	__u64	       hdr_data;
+	__u64			hdr_data;
 	/**
 	 * Indicates the completion status of the operation. It's 0 for
 	 * successful operations, otherwise it's an error code.
 	 */
-	int		 status;
+	int			status;
 	/**
 	 * Indicates whether the MD has been unlinked. Note that:
 	 * - An event with unlinked set is the last event on the MD.
 	 * - This field is also set for an explicit LNET_EVENT_UNLINK event.
 	 * \see LNetMDUnlink
 	 */
-	int		 unlinked;
+	int			unlinked;
 	/**
 	 * The displacement (in bytes) into the memory region that the
 	 * operation used. The offset can be determined by the operation for
 	 * a remote managed MD or by the local MD.
 	 * \see lnet_md_t::options
 	 */
-	unsigned int	offset;
+	unsigned int		offset;
 	/**
 	 * The sequence number for this event. Sequence numbers are unique
 	 * to each event.
 	 */
-	volatile lnet_seq_t sequence;
+	volatile lnet_seq_t	sequence;
 } lnet_event_t;
 
 /**
-- 
1.7.1
