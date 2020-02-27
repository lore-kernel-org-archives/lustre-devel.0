From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:24 -0500
Subject: [lustre-devel] [PATCH 096/622] lnet: health error simulation
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-97-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

Modified the error simulation code to simulate health errors for
testing purposes. The specific error can be set. If multiple
errors are configured then one at random is chosen from the set.

EX:
lctl net_drop_add -s *@tcp -d *@tcp -m GET -i 1 -e local_interrupt

The -e can be repeated multiple times to specify different
errors to simulate. The available set are
        local_interrupt
        local_dropped
        local_aborted
        local_no_route
        local_error
        local_timeout
        remote_error
        remote_dropped
        remote_timeout
        network_timeout
        random

a -n, "--random", has been added to randomize error generation for
drop rules. This will rely an interval value provided via -i. This
will generate a random number no bigger than interval. If the number
is smaller than half of the interval then the rule isn't matched,
otherwise it is.

The purpose of this is because drop matching can happen multiple
times in the path of sending the message, and using time based
or rate will not result in even error generation across the
multiple calls.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9120
Lustre-commit: 5c17777d97bd ("LU-9120 lnet: health error simulation")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/32951
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h       |  4 +-
 include/linux/lnet/lib-types.h      |  3 +-
 include/uapi/linux/lnet/lnetctl.h   | 17 +++++++++
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c |  6 ++-
 net/lnet/klnds/socklnd/socklnd_cb.c | 27 ++++++++++----
 net/lnet/lnet/lib-move.c            |  2 +-
 net/lnet/lnet/lib-msg.c             | 24 ++++++++++++
 net/lnet/lnet/net_fault.c           | 73 ++++++++++++++++++++++++++++++++++---
 8 files changed, 138 insertions(+), 18 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index e4d9ccc..4915a87 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -639,6 +639,8 @@ void lnet_set_reply_msg_len(struct lnet_ni *ni, struct lnet_msg *msg,
 void lnet_detach_rsp_tracker(struct lnet_libmd *md, int cpt);
 
 void lnet_finalize(struct lnet_msg *msg, int rc);
+bool lnet_send_error_simulation(struct lnet_msg *msg,
+				enum lnet_msg_hstatus *hstatus);
 
 void lnet_drop_message(struct lnet_ni *ni, int cpt, void *private,
 		       unsigned int nob, u32 msg_type);
@@ -661,7 +663,7 @@ void lnet_drop_message(struct lnet_ni *ni, int cpt, void *private,
 int lnet_fault_init(void);
 void lnet_fault_fini(void);
 
-bool lnet_drop_rule_match(struct lnet_hdr *hdr);
+bool lnet_drop_rule_match(struct lnet_hdr *hdr, enum lnet_msg_hstatus *hstatus);
 
 int lnet_delay_rule_add(struct lnet_fault_attr *attr);
 int lnet_delay_rule_del(lnet_nid_t src, lnet_nid_t dst, bool shutdown);
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index e5d4128..f82ebb6 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -72,7 +72,8 @@ enum lnet_msg_hstatus {
 	LNET_MSG_STATUS_REMOTE_ERROR,
 	LNET_MSG_STATUS_REMOTE_DROPPED,
 	LNET_MSG_STATUS_REMOTE_TIMEOUT,
-	LNET_MSG_STATUS_NETWORK_TIMEOUT
+	LNET_MSG_STATUS_NETWORK_TIMEOUT,
+	LNET_MSG_STATUS_END,
 };
 
 struct lnet_rsp_tracker {
diff --git a/include/uapi/linux/lnet/lnetctl.h b/include/uapi/linux/lnet/lnetctl.h
index 191689c..2eb9c82 100644
--- a/include/uapi/linux/lnet/lnetctl.h
+++ b/include/uapi/linux/lnet/lnetctl.h
@@ -41,6 +41,19 @@ enum {
 #define LNET_GET_BIT		(1 << 2)
 #define LNET_REPLY_BIT		(1 << 3)
 
+#define HSTATUS_END			11
+#define HSTATUS_LOCAL_INTERRUPT_BIT	(1 << 1)
+#define HSTATUS_LOCAL_DROPPED_BIT	(1 << 2)
+#define HSTATUS_LOCAL_ABORTED_BIT	(1 << 3)
+#define HSTATUS_LOCAL_NO_ROUTE_BIT	(1 << 4)
+#define HSTATUS_LOCAL_ERROR_BIT		(1 << 5)
+#define HSTATUS_LOCAL_TIMEOUT_BIT	(1 << 6)
+#define HSTATUS_REMOTE_ERROR_BIT	(1 << 7)
+#define HSTATUS_REMOTE_DROPPED_BIT	(1 << 8)
+#define HSTATUS_REMOTE_TIMEOUT_BIT	(1 << 9)
+#define HSTATUS_NETWORK_TIMEOUT_BIT	(1 << 10)
+#define HSTATUS_RANDOM			0xffffffff
+
 /** ioctl parameter for LNet fault simulation */
 struct lnet_fault_attr {
 	/**
@@ -78,6 +91,10 @@ struct lnet_fault_attr {
 			 * with da_rate
 			 */
 			__u32			da_interval;
+			/** error type mask */
+			__u32			da_health_error_mask;
+			/** randomize error generation */
+			bool			da_random;
 		} drop;
 		/** message latency simulation */
 		struct {
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 293a859..5680f2a 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -912,7 +912,11 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 			 bad->wr_id, bad->opcode, bad->send_flags,
 			 libcfs_nid2str(conn->ibc_peer->ibp_nid));
 		bad = NULL;
-		rc = ib_post_send(conn->ibc_cmid->qp, wrq, &bad);
+		if (lnet_send_error_simulation(tx->tx_lntmsg[0],
+					       &tx->tx_hstatus))
+			rc = -EINVAL;
+		else
+			rc = ib_post_send(conn->ibc_cmid->qp, wrq, &bad);
 	}
 
 	conn->ibc_last_send = ktime_get();
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index 8bc23d2..057c7f3 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -335,7 +335,8 @@ struct ksock_tx *
 
 	if (!rc && (tx->tx_resid != 0 || tx->tx_zc_aborted)) {
 		rc = -EIO;
-		hstatus = LNET_MSG_STATUS_LOCAL_ERROR;
+		if (hstatus == LNET_MSG_STATUS_OK)
+			hstatus = LNET_MSG_STATUS_LOCAL_ERROR;
 	}
 
 	if (tx->tx_conn)
@@ -467,6 +468,13 @@ struct ksock_tx *
 ksocknal_process_transmit(struct ksock_conn *conn, struct ksock_tx *tx)
 {
 	int rc;
+	bool error_sim = false;
+
+	if (lnet_send_error_simulation(tx->tx_lnetmsg, &tx->tx_hstatus)) {
+		error_sim = true;
+		rc = -EINVAL;
+		goto simulate_error;
+	}
 
 	if (tx->tx_zc_capable && !tx->tx_zc_checked)
 		ksocknal_check_zc_req(tx);
@@ -512,16 +520,19 @@ struct ksock_tx *
 		return rc;
 	}
 
+simulate_error:
 	/* Actual error */
 	LASSERT(rc < 0);
 
-	/* set the health status of the message which determines
-	 * whether we should retry the transmit
-	 */
-	if (rc == -ETIMEDOUT)
-		tx->tx_hstatus = LNET_MSG_STATUS_REMOTE_TIMEOUT;
-	else
-		tx->tx_hstatus = LNET_MSG_STATUS_LOCAL_ERROR;
+	if (!error_sim) {
+		/* set the health status of the message which determines
+		 * whether we should retry the transmit
+		 */
+		if (rc == -ETIMEDOUT)
+			tx->tx_hstatus = LNET_MSG_STATUS_REMOTE_TIMEOUT;
+		else
+			tx->tx_hstatus = LNET_MSG_STATUS_LOCAL_ERROR;
+	}
 
 	if (!conn->ksnc_closing) {
 		switch (rc) {
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 6a3704d..eb0b48d 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -3875,7 +3875,7 @@ void lnet_monitor_thr_stop(void)
 	}
 
 	if (!list_empty(&the_lnet.ln_drop_rules) &&
-	    lnet_drop_rule_match(hdr)) {
+	    lnet_drop_rule_match(hdr, NULL)) {
 		CDEBUG(D_NET, "%s, src %s, dst %s: Dropping %s to simulate silent message loss\n",
 		       libcfs_nid2str(from_nid), libcfs_nid2str(src_nid),
 		       libcfs_nid2str(dest_nid), lnet_msgtyp2str(type));
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 70decc7..5072238 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -812,6 +812,30 @@
 	}
 }
 
+bool
+lnet_send_error_simulation(struct lnet_msg *msg,
+			   enum lnet_msg_hstatus *hstatus)
+{
+	if (!msg)
+		return false;
+
+	if (list_empty(&the_lnet.ln_drop_rules))
+		return false;
+
+	/* match only health rules */
+	if (!lnet_drop_rule_match(&msg->msg_hdr, hstatus))
+		return false;
+
+	CDEBUG(D_NET, "src %s, dst %s: %s simulate health error: %s\n",
+	       libcfs_nid2str(msg->msg_hdr.src_nid),
+	       libcfs_nid2str(msg->msg_hdr.dest_nid),
+	       lnet_msgtyp2str(msg->msg_type),
+	       lnet_health_error2str(*hstatus));
+
+	return true;
+}
+EXPORT_SYMBOL(lnet_send_error_simulation);
+
 void
 lnet_finalize(struct lnet_msg *msg, int status)
 {
diff --git a/net/lnet/lnet/net_fault.c b/net/lnet/lnet/net_fault.c
index 4589b17..becb709 100644
--- a/net/lnet/lnet/net_fault.c
+++ b/net/lnet/lnet/net_fault.c
@@ -292,13 +292,56 @@ struct lnet_drop_rule {
 	lnet_net_unlock(cpt);
 }
 
+static void
+lnet_fault_match_health(enum lnet_msg_hstatus *hstatus, __u32 mask)
+{
+	int choice;
+	int delta;
+	int best_delta;
+	int i;
+
+	/* assign a random failure */
+	choice = prandom_u32_max(LNET_MSG_STATUS_END - LNET_MSG_STATUS_OK);
+	if (choice == 0)
+		choice++;
+
+	if (mask == HSTATUS_RANDOM) {
+		*hstatus = choice;
+		return;
+	}
+
+	if (mask & (1 << choice)) {
+		*hstatus = choice;
+		return;
+	}
+
+	/* round to the closest ON bit */
+	i = HSTATUS_END;
+	best_delta = HSTATUS_END;
+	while (i > 0) {
+		if (mask & (1 << i)) {
+			delta = choice - i;
+			if (delta < 0)
+				delta *= -1;
+			if (delta < best_delta) {
+				best_delta = delta;
+				choice = i;
+			}
+		}
+		i--;
+	}
+
+	*hstatus = choice;
+}
+
 /**
  * check source/destination NID, portal, message type and drop rate,
  * decide whether should drop this message or not
  */
 static bool
 drop_rule_match(struct lnet_drop_rule *rule, lnet_nid_t src,
-		lnet_nid_t dst, unsigned int type, unsigned int portal)
+		lnet_nid_t dst, unsigned int type, unsigned int portal,
+		enum lnet_msg_hstatus *hstatus)
 {
 	struct lnet_fault_attr *attr = &rule->dr_attr;
 	bool drop;
@@ -306,9 +349,23 @@ struct lnet_drop_rule {
 	if (!lnet_fault_attr_match(attr, src, dst, type, portal))
 		return false;
 
+	/* if we're trying to match a health status error but it hasn't
+	 * been set in the rule, then don't match
+	 */
+	if ((hstatus && !attr->u.drop.da_health_error_mask) ||
+	    (!hstatus && attr->u.drop.da_health_error_mask))
+		return false;
+
 	/* match this rule, check drop rate now */
 	spin_lock(&rule->dr_lock);
-	if (rule->dr_drop_time) { /* time based drop */
+	if (attr->u.drop.da_random) {
+		int value = prandom_u32_max(attr->u.drop.da_interval);
+
+		if (value >= (attr->u.drop.da_interval / 2))
+			drop = true;
+		else
+			drop = false;
+	} else if (rule->dr_drop_time) { /* time based drop */
 		time64_t now = ktime_get_seconds();
 
 		rule->dr_stat.fs_count++;
@@ -340,6 +397,9 @@ struct lnet_drop_rule {
 	}
 
 	if (drop) { /* drop this message, update counters */
+		if (hstatus)
+			lnet_fault_match_health(hstatus,
+						attr->u.drop.da_health_error_mask);
 		lnet_fault_stat_inc(&rule->dr_stat, type);
 		rule->dr_stat.u.drop.ds_dropped++;
 	}
@@ -352,12 +412,12 @@ struct lnet_drop_rule {
  * Check if message from @src to @dst can match any existed drop rule
  */
 bool
-lnet_drop_rule_match(struct lnet_hdr *hdr)
+lnet_drop_rule_match(struct lnet_hdr *hdr, enum lnet_msg_hstatus *hstatus)
 {
-	struct lnet_drop_rule *rule;
 	lnet_nid_t src = le64_to_cpu(hdr->src_nid);
 	lnet_nid_t dst = le64_to_cpu(hdr->dest_nid);
 	unsigned int typ = le32_to_cpu(hdr->type);
+	struct lnet_drop_rule *rule;
 	unsigned int ptl = -1;
 	bool drop = false;
 	int cpt;
@@ -373,12 +433,13 @@ struct lnet_drop_rule {
 
 	cpt = lnet_net_lock_current();
 	list_for_each_entry(rule, &the_lnet.ln_drop_rules, dr_link) {
-		drop = drop_rule_match(rule, src, dst, typ, ptl);
+		drop = drop_rule_match(rule, src, dst, typ, ptl,
+				       hstatus);
 		if (drop)
 			break;
 	}
-
 	lnet_net_unlock(cpt);
+
 	return drop;
 }
 
-- 
1.8.3.1
