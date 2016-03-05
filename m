From: James Simmons <jsimmons@infradead.org>
Date: Fri,  4 Mar 2016 21:09:42 -0500
Subject: [lustre-devel] [PATCH 02/10] staging: lustre: LNet network latency
	simulation
In-Reply-To: <1457143790-19422-1-git-send-email-jsimmons@infradead.org>
References: <1457143790-19422-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1457143790-19422-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Liang Zhen <liang.zhen@intel.com>

From: Liang Zhen <liang.zhen@intel.com>

Incoming lnet message can be delayed for seconds if it can match
any of LNet Delay Rules.

User can add/remove/list Delay Rule by lctl commands:
- lctl net_delay_add
  Add a new Delay Rule to LNet, options
  <-s | --source SRC_NID>
  <-d | --dest DST_NID>
  <<-r | --rate RATE_NUMBER>
  <-i | --interlval SECONDS>>
  <-l | --latency DELAY_LATENCY>

- lctl net_delay_del
  Remove matched Delay Rule from LNet, options:
  <[-a | --all] |
  <-s | --source SRC_NID>
  <-d | --dest DST_NID>>

- lctl net_delay_list
  List all Delay Rules in LNet

- lctl net_delay_reset
  Reset statistic counters for all Delay Rules

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5435
Reviewed-on: http://review.whamcloud.com/11409
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Reviewed-by: Bobi Jam <bobijam@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |   17 +
 .../staging/lustre/include/linux/lnet/lib-types.h  |    3 +
 .../staging/lustre/include/linux/lnet/lnetctl.h    |   21 +-
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    1 +
 drivers/staging/lustre/lnet/lnet/lib-move.c        |   73 ++-
 drivers/staging/lustre/lnet/lnet/lib-msg.c         |    6 +
 drivers/staging/lustre/lnet/lnet/net_fault.c       |  601 +++++++++++++++++++-
 7 files changed, 683 insertions(+), 39 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 7b3f858..dfc0208 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -559,13 +559,22 @@ void lnet_portals_destroy(void);
 /* message functions */
 int lnet_parse(lnet_ni_t *ni, lnet_hdr_t *hdr,
 	       lnet_nid_t fromnid, void *private, int rdma_req);
+int lnet_parse_local(lnet_ni_t *ni, lnet_msg_t *msg);
+int lnet_parse_forward_locked(lnet_ni_t *ni, lnet_msg_t *msg);
+
 void lnet_recv(lnet_ni_t *ni, void *private, lnet_msg_t *msg, int delayed,
 	       unsigned int offset, unsigned int mlen, unsigned int rlen);
+void lnet_ni_recv(lnet_ni_t *ni, void *private, lnet_msg_t *msg,
+		  int delayed, unsigned int offset,
+		  unsigned int mlen, unsigned int rlen);
+
 lnet_msg_t *lnet_create_reply_msg(lnet_ni_t *ni, lnet_msg_t *get_msg);
 void lnet_set_reply_msg_len(lnet_ni_t *ni, lnet_msg_t *msg, unsigned int len);
 
 void lnet_finalize(lnet_ni_t *ni, lnet_msg_t *msg, int rc);
 
+void lnet_drop_message(lnet_ni_t *ni, int cpt, void *private,
+		       unsigned int nob);
 void lnet_drop_delayed_msg_list(struct list_head *head, char *reason);
 void lnet_recv_delayed_msg_list(struct list_head *head);
 
@@ -586,6 +595,14 @@ void lnet_fault_fini(void);
 
 bool lnet_drop_rule_match(lnet_hdr_t *hdr);
 
+int lnet_delay_rule_add(struct lnet_fault_attr *attr);
+int lnet_delay_rule_del(lnet_nid_t src, lnet_nid_t dst, bool shutdown);
+int lnet_delay_rule_list(int pos, struct lnet_fault_attr *attr,
+			 struct lnet_fault_stat *stat);
+void lnet_delay_rule_reset(void);
+void lnet_delay_rule_check(void);
+bool lnet_delay_rule_match_locked(lnet_hdr_t *hdr, struct lnet_msg *msg);
+
 /** @} lnet_fault_simulation */
 
 void lnet_counters_get(lnet_counters_t *counters);
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-types.h b/drivers/staging/lustre/include/linux/lnet/lib-types.h
index cb09a8a..29c72f8 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-types.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-types.h
@@ -88,6 +88,7 @@ typedef struct lnet_msg {
 	unsigned int	msg_rtrcredit:1;	/* taken a global router credit */
 	unsigned int	msg_peerrtrcredit:1;	/* taken a peer router credit */
 	unsigned int	msg_onactivelist:1;	/* on the activelist */
+	unsigned int	msg_rdma_get:1;
 
 	struct lnet_peer	*msg_txpeer;	 /* peer I'm sending to */
 	struct lnet_peer	*msg_rxpeer;	 /* peer I received from */
@@ -574,6 +575,7 @@ typedef struct {
 	/* failure simulation */
 	struct list_head		  ln_test_peers;
 	struct list_head		  ln_drop_rules;
+	struct list_head		  ln_delay_rules;
 
 	struct list_head		  ln_nis;	/* LND instances */
 	/* NIs bond on specific CPT(s) */
@@ -610,6 +612,7 @@ typedef struct {
 
 	struct mutex			  ln_api_mutex;
 	struct mutex			  ln_lnd_mutex;
+	struct mutex			  ln_delay_mutex;
 	/* Have I called LNetNIInit myself? */
 	int				  ln_niinit_self;
 	/* LNetNIInit/LNetNIFini counter */
diff --git a/drivers/staging/lustre/include/linux/lnet/lnetctl.h b/drivers/staging/lustre/include/linux/lnet/lnetctl.h
index ec33bf8..3957507 100644
--- a/drivers/staging/lustre/include/linux/lnet/lnetctl.h
+++ b/drivers/staging/lustre/include/linux/lnet/lnetctl.h
@@ -26,6 +26,10 @@ enum {
 	LNET_CTL_DROP_DEL,
 	LNET_CTL_DROP_RESET,
 	LNET_CTL_DROP_LIST,
+	LNET_CTL_DELAY_ADD,
+	LNET_CTL_DELAY_DEL,
+	LNET_CTL_DELAY_RESET,
+	LNET_CTL_DELAY_LIST,
 };
 
 #define LNET_ACK_BIT		BIT(0)
@@ -71,7 +75,17 @@ struct lnet_fault_attr {
 			 */
 			__u32			da_interval;
 		} drop;
-		/** TODO: add more */
+		/** message latency simulation */
+		struct {
+			__u32			la_rate;
+			/**
+			 * time interval of message delay, it is exclusive
+			 * with la_rate
+			 */
+			__u32			la_interval;
+			/** latency to delay */
+			__u32			la_latency;
+		} delay;
 		__u64			space[8];
 	} u;
 };
@@ -93,7 +107,10 @@ struct lnet_fault_stat {
 			/** total # dropped messages */
 			__u64			ds_dropped;
 		} drop;
-		/** TODO: add more */
+		struct {
+			/** total # delayed messages */
+			__u64			ls_delayed;
+		} delay;
 		__u64			space[8];
 	} u;
 };
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 4d77ca3..a666d49 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -551,6 +551,7 @@ lnet_prepare(lnet_pid_t requested_pid)
 	INIT_LIST_HEAD(&the_lnet.ln_nis_zombie);
 	INIT_LIST_HEAD(&the_lnet.ln_routers);
 	INIT_LIST_HEAD(&the_lnet.ln_drop_rules);
+	INIT_LIST_HEAD(&the_lnet.ln_delay_rules);
 
 	rc = lnet_create_remote_nets_table();
 	if (rc)
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 7a0f185..a5e90e7 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -42,11 +42,6 @@
 
 #include "../../include/linux/lnet/lib-lnet.h"
 
-/** lnet message has credit and can be submitted to lnd for send/receive */
-#define LNET_CREDIT_OK		0
-/** lnet message is waiting for credit */
-#define LNET_CREDIT_WAIT	1
-
 static int local_nid_dist_zero = 1;
 module_param(local_nid_dist_zero, int, 0444);
 MODULE_PARM_DESC(local_nid_dist_zero, "Reserved");
@@ -570,7 +565,7 @@ lnet_extract_kiov(int dst_niov, lnet_kiov_t *dst,
 }
 EXPORT_SYMBOL(lnet_extract_kiov);
 
-static void
+void
 lnet_ni_recv(lnet_ni_t *ni, void *private, lnet_msg_t *msg, int delayed,
 	     unsigned int offset, unsigned int mlen, unsigned int rlen)
 {
@@ -1431,7 +1426,7 @@ lnet_send(lnet_nid_t src_nid, lnet_msg_t *msg, lnet_nid_t rtr_nid)
 	return 0; /* rc == LNET_CREDIT_OK or LNET_CREDIT_WAIT */
 }
 
-static void
+void
 lnet_drop_message(lnet_ni_t *ni, int cpt, void *private, unsigned int nob)
 {
 	lnet_net_lock(cpt);
@@ -1705,7 +1700,7 @@ lnet_parse_ack(lnet_ni_t *ni, lnet_msg_t *msg)
  * \retval LNET_CREDIT_WAIT	If \a msg is blocked because w/o buffer
  * \retval -ve			error code
  */
-static int
+int
 lnet_parse_forward_locked(lnet_ni_t *ni, lnet_msg_t *msg)
 {
 	int rc = 0;
@@ -1729,6 +1724,33 @@ lnet_parse_forward_locked(lnet_ni_t *ni, lnet_msg_t *msg)
 	return rc;
 }
 
+int
+lnet_parse_local(lnet_ni_t *ni, lnet_msg_t *msg)
+{
+	int rc;
+
+	switch (msg->msg_type) {
+	case LNET_MSG_ACK:
+		rc = lnet_parse_ack(ni, msg);
+		break;
+	case LNET_MSG_PUT:
+		rc = lnet_parse_put(ni, msg);
+		break;
+	case LNET_MSG_GET:
+		rc = lnet_parse_get(ni, msg, msg->msg_rdma_get);
+		break;
+	case LNET_MSG_REPLY:
+		rc = lnet_parse_reply(ni, msg);
+		break;
+	default: /* prevent an unused label if !kernel */
+		LASSERT(0);
+		return -EPROTO;
+	}
+
+	LASSERT(!rc || rc == -ENOENT);
+	return rc;
+}
+
 char *
 lnet_msgtyp2str(int type)
 {
@@ -1953,6 +1975,7 @@ lnet_parse(lnet_ni_t *ni, lnet_hdr_t *hdr, lnet_nid_t from_nid,
 	msg->msg_type = type;
 	msg->msg_private = private;
 	msg->msg_receiving = 1;
+	msg->msg_rdma_get = rdma_req;
 	msg->msg_wanted = payload_length;
 	msg->msg_len = payload_length;
 	msg->msg_offset = 0;
@@ -2000,6 +2023,13 @@ lnet_parse(lnet_ni_t *ni, lnet_hdr_t *hdr, lnet_nid_t from_nid,
 
 	lnet_msg_commit(msg, cpt);
 
+	/* message delay simulation */
+	if (unlikely(!list_empty(&the_lnet.ln_delay_rules) &&
+		     lnet_delay_rule_match_locked(hdr, msg))) {
+		lnet_net_unlock(cpt);
+		return 0;
+	}
+
 	if (!for_me) {
 		rc = lnet_parse_forward_locked(ni, msg);
 		lnet_net_unlock(cpt);
@@ -2016,29 +2046,10 @@ lnet_parse(lnet_ni_t *ni, lnet_hdr_t *hdr, lnet_nid_t from_nid,
 
 	lnet_net_unlock(cpt);
 
-	switch (type) {
-	case LNET_MSG_ACK:
-		rc = lnet_parse_ack(ni, msg);
-		break;
-	case LNET_MSG_PUT:
-		rc = lnet_parse_put(ni, msg);
-		break;
-	case LNET_MSG_GET:
-		rc = lnet_parse_get(ni, msg, rdma_req);
-		break;
-	case LNET_MSG_REPLY:
-		rc = lnet_parse_reply(ni, msg);
-		break;
-	default:
-		LASSERT(0);
-		rc = -EPROTO;
-		goto free_drop;  /* prevent an unused label if !kernel */
-	}
-
-	if (!rc)
-		return 0;
-
-	LASSERT(rc == -ENOENT);
+	rc = lnet_parse_local(ni, msg);
+	if (rc)
+		goto free_drop;
+	return 0;
 
  free_drop:
 	LASSERT(!msg->msg_md);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-msg.c b/drivers/staging/lustre/lnet/lnet/lib-msg.c
index c372390..f879d7f 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-msg.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-msg.c
@@ -535,6 +535,12 @@ lnet_finalize(lnet_ni_t *ni, lnet_msg_t *msg, int status)
 			break;
 	}
 
+	if (unlikely(!list_empty(&the_lnet.ln_delay_rules))) {
+		lnet_net_unlock(cpt);
+		lnet_delay_rule_check();
+		lnet_net_lock(cpt);
+	}
+
 	container->msc_finalizers[my_slot] = NULL;
 	lnet_net_unlock(cpt);
 
diff --git a/drivers/staging/lustre/lnet/lnet/net_fault.c b/drivers/staging/lustre/lnet/lnet/net_fault.c
index 8ed05b6..91f44a7 100644
--- a/drivers/staging/lustre/lnet/lnet/net_fault.c
+++ b/drivers/staging/lustre/lnet/lnet/net_fault.c
@@ -138,6 +138,10 @@ lnet_fault_stat_inc(struct lnet_fault_stat *stat, unsigned int type)
 }
 
 /**
+ * LNet message drop simulation
+ */
+
+/**
  * Add a new drop rule to LNet
  * There is no check for duplicated drop rule, all rules will be checked for
  * incoming message.
@@ -147,8 +151,8 @@ lnet_drop_rule_add(struct lnet_fault_attr *attr)
 {
 	struct lnet_drop_rule *rule;
 
-	if (!attr->u.drop.da_rate == !attr->u.drop.da_interval) {
-		CDEBUG(D_NET, "invalid rate %d or interval %d\n",
+	if (attr->u.drop.da_rate & attr->u.drop.da_interval) {
+		CDEBUG(D_NET, "please provide either drop rate or drop interval, but not both at the same time %d/%d\n",
 		       attr->u.drop.da_rate, attr->u.drop.da_interval);
 		return -EINVAL;
 	}
@@ -276,8 +280,7 @@ lnet_drop_rule_reset(void)
 		} else {
 			rule->dr_drop_time = cfs_time_shift(cfs_rand() %
 						attr->u.drop.da_interval);
-			rule->dr_time_base = cfs_time_shift(attr->u.drop.
-								  da_interval);
+			rule->dr_time_base = cfs_time_shift(attr->u.drop.da_interval);
 		}
 		spin_unlock(&rule->dr_lock);
 	}
@@ -313,8 +316,7 @@ drop_rule_match(struct lnet_drop_rule *rule, lnet_nid_t src,
 			rule->dr_drop_time = rule->dr_time_base +
 					     cfs_time_seconds(cfs_rand() %
 						attr->u.drop.da_interval);
-			rule->dr_time_base += cfs_time_seconds(attr->u.drop.
-							       da_interval);
+			rule->dr_time_base += cfs_time_seconds(attr->u.drop.da_interval);
 
 			CDEBUG(D_NET, "Drop Rule %s->%s: next drop : %lu\n",
 			       libcfs_nid2str(attr->fa_src),
@@ -377,6 +379,559 @@ lnet_drop_rule_match(lnet_hdr_t *hdr)
 	return drop;
 }
 
+/**
+ * LNet Delay Simulation
+ */
+/** timestamp (second) to send delayed message */
+#define msg_delay_send		 msg_ev.hdr_data
+
+struct lnet_delay_rule {
+	/** link chain on the_lnet.ln_delay_rules */
+	struct list_head	dl_link;
+	/** link chain on delay_dd.dd_sched_rules */
+	struct list_head	dl_sched_link;
+	/** attributes of this rule */
+	struct lnet_fault_attr	dl_attr;
+	/** lock to protect \a below members */
+	spinlock_t		dl_lock;
+	/** refcount of delay rule */
+	atomic_t		dl_refcount;
+	/**
+	 * the message sequence to delay, which means message is delayed when
+	 * dl_stat.fs_count == dl_delay_at
+	 */
+	unsigned long		dl_delay_at;
+	/**
+	 * seconds to delay the next message, it's exclusive with dl_delay_at
+	 */
+	unsigned long		dl_delay_time;
+	/** baseline to caculate dl_delay_time */
+	unsigned long		dl_time_base;
+	/** jiffies to send the next delayed message */
+	unsigned long		dl_msg_send;
+	/** delayed message list */
+	struct list_head	dl_msg_list;
+	/** statistic of delayed messages */
+	struct lnet_fault_stat	dl_stat;
+	/** timer to wakeup delay_daemon */
+	struct timer_list	dl_timer;
+};
+
+struct delay_daemon_data {
+	/** serialise rule add/remove */
+	struct mutex		dd_mutex;
+	/** protect rules on \a dd_sched_rules */
+	spinlock_t		dd_lock;
+	/** scheduled delay rules (by timer) */
+	struct list_head	dd_sched_rules;
+	/** daemon thread sleeps at here */
+	wait_queue_head_t	dd_waitq;
+	/** controller (lctl command) wait at here */
+	wait_queue_head_t	dd_ctl_waitq;
+	/** daemon is running */
+	unsigned int		dd_running;
+	/** daemon stopped */
+	unsigned int		dd_stopped;
+};
+
+static struct delay_daemon_data	delay_dd;
+
+static unsigned long
+round_timeout(unsigned long timeout)
+{
+	return cfs_time_seconds((unsigned int)
+			cfs_duration_sec(cfs_time_sub(timeout, 0)) + 1);
+}
+
+static void
+delay_rule_decref(struct lnet_delay_rule *rule)
+{
+	if (atomic_dec_and_test(&rule->dl_refcount)) {
+		LASSERT(list_empty(&rule->dl_sched_link));
+		LASSERT(list_empty(&rule->dl_msg_list));
+		LASSERT(list_empty(&rule->dl_link));
+
+		CFS_FREE_PTR(rule);
+	}
+}
+
+/**
+ * check source/destination NID, portal, message type and delay rate,
+ * decide whether should delay this message or not
+ */
+static bool
+delay_rule_match(struct lnet_delay_rule *rule, lnet_nid_t src,
+		 lnet_nid_t dst, unsigned int type, unsigned int portal,
+		 struct lnet_msg *msg)
+{
+	struct lnet_fault_attr *attr = &rule->dl_attr;
+	bool delay;
+
+	if (!lnet_fault_attr_match(attr, src, dst, type, portal))
+		return false;
+
+	/* match this rule, check delay rate now */
+	spin_lock(&rule->dl_lock);
+	if (rule->dl_delay_time) { /* time based delay */
+		unsigned long now = cfs_time_current();
+
+		rule->dl_stat.fs_count++;
+		delay = cfs_time_aftereq(now, rule->dl_delay_time);
+		if (delay) {
+			if (cfs_time_after(now, rule->dl_time_base))
+				rule->dl_time_base = now;
+
+			rule->dl_delay_time = rule->dl_time_base +
+					     cfs_time_seconds(cfs_rand() %
+						attr->u.delay.la_interval);
+			rule->dl_time_base += cfs_time_seconds(attr->u.delay.la_interval);
+
+			CDEBUG(D_NET, "Delay Rule %s->%s: next delay : %lu\n",
+			       libcfs_nid2str(attr->fa_src),
+			       libcfs_nid2str(attr->fa_dst),
+			       rule->dl_delay_time);
+		}
+
+	} else { /* rate based delay */
+		delay = rule->dl_stat.fs_count++ == rule->dl_delay_at;
+		/* generate the next random rate sequence */
+		if (!(rule->dl_stat.fs_count % attr->u.delay.la_rate)) {
+			rule->dl_delay_at = rule->dl_stat.fs_count +
+					    cfs_rand() % attr->u.delay.la_rate;
+			CDEBUG(D_NET, "Delay Rule %s->%s: next delay: %lu\n",
+			       libcfs_nid2str(attr->fa_src),
+			       libcfs_nid2str(attr->fa_dst), rule->dl_delay_at);
+		}
+	}
+
+	if (!delay) {
+		spin_unlock(&rule->dl_lock);
+		return false;
+	}
+
+	/* delay this message, update counters */
+	lnet_fault_stat_inc(&rule->dl_stat, type);
+	rule->dl_stat.u.delay.ls_delayed++;
+
+	list_add_tail(&msg->msg_list, &rule->dl_msg_list);
+	msg->msg_delay_send = round_timeout(
+			cfs_time_shift(attr->u.delay.la_latency));
+	if (rule->dl_msg_send == -1) {
+		rule->dl_msg_send = msg->msg_delay_send;
+		mod_timer(&rule->dl_timer, rule->dl_msg_send);
+	}
+
+	spin_unlock(&rule->dl_lock);
+	return true;
+}
+
+/**
+ * check if \a msg can match any Delay Rule, receiving of this message
+ * will be delayed if there is a match.
+ */
+bool
+lnet_delay_rule_match_locked(lnet_hdr_t *hdr, struct lnet_msg *msg)
+{
+	struct lnet_delay_rule *rule;
+	lnet_nid_t src = le64_to_cpu(hdr->src_nid);
+	lnet_nid_t dst = le64_to_cpu(hdr->dest_nid);
+	unsigned int typ = le32_to_cpu(hdr->type);
+	unsigned int ptl = -1;
+
+	/* NB: called with hold of lnet_net_lock */
+
+	/**
+	 * NB: if Portal is specified, then only PUT and GET will be
+	 * filtered by delay rule
+	 */
+	if (typ == LNET_MSG_PUT)
+		ptl = le32_to_cpu(hdr->msg.put.ptl_index);
+	else if (typ == LNET_MSG_GET)
+		ptl = le32_to_cpu(hdr->msg.get.ptl_index);
+
+	list_for_each_entry(rule, &the_lnet.ln_delay_rules, dl_link) {
+		if (delay_rule_match(rule, src, dst, typ, ptl, msg))
+			return true;
+	}
+
+	return false;
+}
+
+/** check out delayed messages for send */
+static void
+delayed_msg_check(struct lnet_delay_rule *rule, bool all,
+		  struct list_head *msg_list)
+{
+	struct lnet_msg *msg;
+	struct lnet_msg *tmp;
+	unsigned long now = cfs_time_current();
+
+	if (!all && rule->dl_msg_send > now)
+		return;
+
+	spin_lock(&rule->dl_lock);
+	list_for_each_entry_safe(msg, tmp, &rule->dl_msg_list, msg_list) {
+		if (!all && msg->msg_delay_send > now)
+			break;
+
+		msg->msg_delay_send = 0;
+		list_move_tail(&msg->msg_list, msg_list);
+	}
+
+	if (list_empty(&rule->dl_msg_list)) {
+		del_timer(&rule->dl_timer);
+		rule->dl_msg_send = -1;
+
+	} else if (!list_empty(msg_list)) {
+		/*
+		 * dequeued some timedout messages, update timer for the
+		 * next delayed message on rule
+		 */
+		msg = list_entry(rule->dl_msg_list.next,
+				 struct lnet_msg, msg_list);
+		rule->dl_msg_send = msg->msg_delay_send;
+		mod_timer(&rule->dl_timer, rule->dl_msg_send);
+	}
+	spin_unlock(&rule->dl_lock);
+}
+
+static void
+delayed_msg_process(struct list_head *msg_list, bool drop)
+{
+	struct lnet_msg	*msg;
+
+	while (!list_empty(msg_list)) {
+		struct lnet_ni *ni;
+		int cpt;
+		int rc;
+
+		msg = list_entry(msg_list->next, struct lnet_msg, msg_list);
+		LASSERT(msg->msg_rxpeer);
+
+		ni = msg->msg_rxpeer->lp_ni;
+		cpt = msg->msg_rx_cpt;
+
+		list_del_init(&msg->msg_list);
+		if (drop) {
+			rc = -ECANCELED;
+
+		} else if (!msg->msg_routing) {
+			rc = lnet_parse_local(ni, msg);
+			if (!rc)
+				continue;
+
+		} else {
+			lnet_net_lock(cpt);
+			rc = lnet_parse_forward_locked(ni, msg);
+			lnet_net_unlock(cpt);
+
+			switch (rc) {
+			case LNET_CREDIT_OK:
+				lnet_ni_recv(ni, msg->msg_private, msg, 0,
+					     0, msg->msg_len, msg->msg_len);
+			case LNET_CREDIT_WAIT:
+				continue;
+			default: /* failures */
+				break;
+			}
+		}
+
+		lnet_drop_message(ni, cpt, msg->msg_private, msg->msg_len);
+		lnet_finalize(ni, msg, rc);
+	}
+}
+
+/**
+ * Process delayed messages for scheduled rules
+ * This function can either be called by delay_rule_daemon, or by lnet_finalise
+ */
+void
+lnet_delay_rule_check(void)
+{
+	struct lnet_delay_rule *rule;
+	struct list_head msgs;
+
+	INIT_LIST_HEAD(&msgs);
+	while (1) {
+		if (list_empty(&delay_dd.dd_sched_rules))
+			break;
+
+		spin_lock_bh(&delay_dd.dd_lock);
+		if (list_empty(&delay_dd.dd_sched_rules)) {
+			spin_unlock_bh(&delay_dd.dd_lock);
+			break;
+		}
+
+		rule = list_entry(delay_dd.dd_sched_rules.next,
+				  struct lnet_delay_rule, dl_sched_link);
+		list_del_init(&rule->dl_sched_link);
+		spin_unlock_bh(&delay_dd.dd_lock);
+
+		delayed_msg_check(rule, false, &msgs);
+		delay_rule_decref(rule); /* -1 for delay_dd.dd_sched_rules */
+	}
+
+	if (!list_empty(&msgs))
+		delayed_msg_process(&msgs, false);
+}
+
+/** daemon thread to handle delayed messages */
+static int
+lnet_delay_rule_daemon(void *arg)
+{
+	delay_dd.dd_running = 1;
+	wake_up(&delay_dd.dd_ctl_waitq);
+
+	while (delay_dd.dd_running) {
+		wait_event_interruptible(delay_dd.dd_waitq,
+					 !delay_dd.dd_running ||
+					 !list_empty(&delay_dd.dd_sched_rules));
+		lnet_delay_rule_check();
+	}
+
+	/* in case more rules have been enqueued after my last check */
+	lnet_delay_rule_check();
+	delay_dd.dd_stopped = 1;
+	wake_up(&delay_dd.dd_ctl_waitq);
+
+	return 0;
+}
+
+static void
+delay_timer_cb(unsigned long arg)
+{
+	struct lnet_delay_rule *rule = (struct lnet_delay_rule *)arg;
+
+	spin_lock_bh(&delay_dd.dd_lock);
+	if (list_empty(&rule->dl_sched_link) && delay_dd.dd_running) {
+		atomic_inc(&rule->dl_refcount);
+		list_add_tail(&rule->dl_sched_link, &delay_dd.dd_sched_rules);
+		wake_up(&delay_dd.dd_waitq);
+	}
+	spin_unlock_bh(&delay_dd.dd_lock);
+}
+
+/**
+ * Add a new delay rule to LNet
+ * There is no check for duplicated delay rule, all rules will be checked for
+ * incoming message.
+ */
+int
+lnet_delay_rule_add(struct lnet_fault_attr *attr)
+{
+	struct lnet_delay_rule *rule;
+	int rc = 0;
+
+	if (attr->u.delay.la_rate & attr->u.delay.la_interval) {
+		CDEBUG(D_NET, "please provide either delay rate or delay interval, but not both at the same time %d/%d\n",
+		       attr->u.delay.la_rate, attr->u.delay.la_interval);
+		return -EINVAL;
+	}
+
+	if (!attr->u.delay.la_latency) {
+		CDEBUG(D_NET, "delay latency cannot be zero\n");
+		return -EINVAL;
+	}
+
+	if (lnet_fault_attr_validate(attr))
+		return -EINVAL;
+
+	CFS_ALLOC_PTR(rule);
+	if (!rule)
+		return -ENOMEM;
+
+	mutex_lock(&delay_dd.dd_mutex);
+	if (!delay_dd.dd_running) {
+		struct task_struct *task;
+
+		/**
+		 *  NB: although LND threads will process delayed message
+		 * in lnet_finalize, but there is no guarantee that LND
+		 * threads will be waken up if no other message needs to
+		 * be handled.
+		 * Only one daemon thread, performance is not the concern
+		 * of this simualation module.
+		 */
+		task = kthread_run(lnet_delay_rule_daemon, NULL, "lnet_dd");
+		if (IS_ERR(task)) {
+			rc = PTR_ERR(task);
+			goto failed;
+		}
+		wait_event(delay_dd.dd_ctl_waitq, delay_dd.dd_running);
+	}
+
+	init_timer(&rule->dl_timer);
+	rule->dl_timer.function = delay_timer_cb;
+	rule->dl_timer.data = (unsigned long)rule;
+
+	spin_lock_init(&rule->dl_lock);
+	INIT_LIST_HEAD(&rule->dl_msg_list);
+	INIT_LIST_HEAD(&rule->dl_sched_link);
+
+	rule->dl_attr = *attr;
+	if (attr->u.delay.la_interval) {
+		rule->dl_time_base = cfs_time_shift(attr->u.delay.la_interval);
+		rule->dl_delay_time = cfs_time_shift(cfs_rand() %
+						     attr->u.delay.la_interval);
+	} else {
+		rule->dl_delay_at = cfs_rand() % attr->u.delay.la_rate;
+	}
+
+	rule->dl_msg_send = -1;
+
+	lnet_net_lock(LNET_LOCK_EX);
+	atomic_set(&rule->dl_refcount, 1);
+	list_add(&rule->dl_link, &the_lnet.ln_delay_rules);
+	lnet_net_unlock(LNET_LOCK_EX);
+
+	CDEBUG(D_NET, "Added delay rule: src %s, dst %s, rate %d\n",
+	       libcfs_nid2str(attr->fa_src), libcfs_nid2str(attr->fa_src),
+	       attr->u.delay.la_rate);
+
+	mutex_unlock(&delay_dd.dd_mutex);
+	return 0;
+failed:
+	mutex_unlock(&delay_dd.dd_mutex);
+	CFS_FREE_PTR(rule);
+	return rc;
+}
+
+/**
+ * Remove matched Delay Rules from lnet, if \a shutdown is true or both \a src
+ * and \a dst are zero, all rules will be removed, otherwise only matched rules
+ * will be removed.
+ * If \a src is zero, then all rules have \a dst as destination will be remove
+ * If \a dst is zero, then all rules have \a src as source will be removed
+ *
+ * When a delay rule is removed, all delayed messages of this rule will be
+ * processed immediately.
+ */
+int
+lnet_delay_rule_del(lnet_nid_t src, lnet_nid_t dst, bool shutdown)
+{
+	struct lnet_delay_rule *rule;
+	struct lnet_delay_rule *tmp;
+	struct list_head rule_list;
+	struct list_head msg_list;
+	int n = 0;
+	bool cleanup;
+
+	INIT_LIST_HEAD(&rule_list);
+	INIT_LIST_HEAD(&msg_list);
+
+	if (shutdown) {
+		src = 0;
+		dst = 0;
+	}
+
+	mutex_lock(&delay_dd.dd_mutex);
+	lnet_net_lock(LNET_LOCK_EX);
+
+	list_for_each_entry_safe(rule, tmp, &the_lnet.ln_delay_rules, dl_link) {
+		if (rule->dl_attr.fa_src != src && src)
+			continue;
+
+		if (rule->dl_attr.fa_dst != dst && dst)
+			continue;
+
+		CDEBUG(D_NET, "Remove delay rule: src %s->dst: %s (1/%d, %d)\n",
+		       libcfs_nid2str(rule->dl_attr.fa_src),
+		       libcfs_nid2str(rule->dl_attr.fa_dst),
+		       rule->dl_attr.u.delay.la_rate,
+		       rule->dl_attr.u.delay.la_interval);
+		/* refcount is taken over by rule_list */
+		list_move(&rule->dl_link, &rule_list);
+	}
+
+	/* check if we need to shutdown delay_daemon */
+	cleanup = list_empty(&the_lnet.ln_delay_rules) &&
+		  !list_empty(&rule_list);
+	lnet_net_unlock(LNET_LOCK_EX);
+
+	list_for_each_entry_safe(rule, tmp, &rule_list, dl_link) {
+		list_del_init(&rule->dl_link);
+
+		del_timer_sync(&rule->dl_timer);
+		delayed_msg_check(rule, true, &msg_list);
+		delay_rule_decref(rule); /* -1 for the_lnet.ln_delay_rules */
+		n++;
+	}
+
+	if (cleanup) { /* no more delay rule, shutdown delay_daemon */
+		LASSERT(delay_dd.dd_running);
+		delay_dd.dd_running = 0;
+		wake_up(&delay_dd.dd_waitq);
+
+		while (!delay_dd.dd_stopped)
+			wait_event(delay_dd.dd_ctl_waitq, delay_dd.dd_stopped);
+	}
+	mutex_unlock(&delay_dd.dd_mutex);
+
+	if (!list_empty(&msg_list))
+		delayed_msg_process(&msg_list, shutdown);
+
+	return n;
+}
+
+/**
+ * List Delay Rule at position of \a pos
+ */
+int
+lnet_delay_rule_list(int pos, struct lnet_fault_attr *attr,
+		     struct lnet_fault_stat *stat)
+{
+	struct lnet_delay_rule *rule;
+	int cpt;
+	int i = 0;
+	int rc = -ENOENT;
+
+	cpt = lnet_net_lock_current();
+	list_for_each_entry(rule, &the_lnet.ln_delay_rules, dl_link) {
+		if (i++ < pos)
+			continue;
+
+		spin_lock(&rule->dl_lock);
+		*attr = rule->dl_attr;
+		*stat = rule->dl_stat;
+		spin_unlock(&rule->dl_lock);
+		rc = 0;
+		break;
+	}
+
+	lnet_net_unlock(cpt);
+	return rc;
+}
+
+/**
+ * reset counters for all Delay Rules
+ */
+void
+lnet_delay_rule_reset(void)
+{
+	struct lnet_delay_rule *rule;
+	int cpt;
+
+	cpt = lnet_net_lock_current();
+
+	list_for_each_entry(rule, &the_lnet.ln_delay_rules, dl_link) {
+		struct lnet_fault_attr *attr = &rule->dl_attr;
+
+		spin_lock(&rule->dl_lock);
+
+		memset(&rule->dl_stat, 0, sizeof(rule->dl_stat));
+		if (attr->u.delay.la_rate) {
+			rule->dl_delay_at = cfs_rand() % attr->u.delay.la_rate;
+		} else {
+			rule->dl_delay_time = cfs_time_shift(cfs_rand() %
+						attr->u.delay.la_interval);
+			rule->dl_time_base = cfs_time_shift(attr->u.delay.la_interval);
+		}
+		spin_unlock(&rule->dl_lock);
+	}
+
+	lnet_net_unlock(cpt);
+}
+
 int
 lnet_fault_ctl(int opc, struct libcfs_ioctl_data *data)
 {
@@ -413,6 +968,31 @@ lnet_fault_ctl(int opc, struct libcfs_ioctl_data *data)
 			return -EINVAL;
 
 		return lnet_drop_rule_list(data->ioc_count, attr, stat);
+
+	case LNET_CTL_DELAY_ADD:
+		if (!attr)
+			return -EINVAL;
+
+		return lnet_delay_rule_add(attr);
+
+	case LNET_CTL_DELAY_DEL:
+		if (!attr)
+			return -EINVAL;
+
+		data->ioc_count = lnet_delay_rule_del(attr->fa_src,
+						      attr->fa_dst, false);
+		return 0;
+
+	case LNET_CTL_DELAY_RESET:
+		lnet_delay_rule_reset();
+		return 0;
+
+	case LNET_CTL_DELAY_LIST:
+		stat = (struct lnet_fault_stat *)data->ioc_inlbuf2;
+		if (!attr || !stat)
+			return -EINVAL;
+
+		return lnet_delay_rule_list(data->ioc_count, attr, stat);
 	}
 }
 
@@ -424,6 +1004,12 @@ lnet_fault_init(void)
 	CLASSERT(LNET_GET_BIT == 1 << LNET_MSG_GET);
 	CLASSERT(LNET_REPLY_BIT == 1 << LNET_MSG_REPLY);
 
+	mutex_init(&delay_dd.dd_mutex);
+	spin_lock_init(&delay_dd.dd_lock);
+	init_waitqueue_head(&delay_dd.dd_waitq);
+	init_waitqueue_head(&delay_dd.dd_ctl_waitq);
+	INIT_LIST_HEAD(&delay_dd.dd_sched_rules);
+
 	return 0;
 }
 
@@ -431,6 +1017,9 @@ void
 lnet_fault_fini(void)
 {
 	lnet_drop_rule_del(0, 0);
+	lnet_delay_rule_del(0, 0, true);
 
 	LASSERT(list_empty(&the_lnet.ln_drop_rules));
+	LASSERT(list_empty(&the_lnet.ln_delay_rules));
+	LASSERT(list_empty(&delay_dd.dd_sched_rules));
 }
-- 
1.7.1
