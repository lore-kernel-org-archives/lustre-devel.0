From: James Simmons <jsimmons@infradead.org>
Date: Sun, 24 Jun 2018 17:53:52 -0400
Subject: [lustre-devel] [PATCH 8/8] staging: lustre: selftest: fix time
 reporting
In-Reply-To: <1529877232-15582-1-git-send-email-jsimmons@infradead.org>
References: <1529877232-15582-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1529877232-15582-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Migrate crp_stamp to nanoseconds and both timestamps nd_stamp,
sn_start to ktime. The move away from jiffies, which can vary on
platforms, to something that is the consistent on every node.
Currently jiffies data was being transmitted over the wire and
the other node could have a different HZ value configured which
lead to incorrect results. This will ensure that the reported
results to the user will always be correct.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-9019
Reviewed-on: https://review.whamcloud.com/31041
Reviewed-by: Doug Oucharek <dougso@me.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/include/uapi/linux/lnet/lnetst.h        |  2 +-
 drivers/staging/lustre/lnet/selftest/conrpc.c      | 39 +++++++++++-----------
 drivers/staging/lustre/lnet/selftest/conrpc.h      |  2 +-
 drivers/staging/lustre/lnet/selftest/console.c     |  4 +--
 drivers/staging/lustre/lnet/selftest/console.h     |  2 +-
 drivers/staging/lustre/lnet/selftest/framework.c   |  4 +--
 drivers/staging/lustre/lnet/selftest/selftest.h    |  2 +-
 drivers/staging/lustre/lnet/selftest/timer.c       |  8 ++---
 8 files changed, 32 insertions(+), 31 deletions(-)

diff --git a/drivers/staging/lustre/include/uapi/linux/lnet/lnetst.h b/drivers/staging/lustre/include/uapi/linux/lnet/lnetst.h
index a4f9ff0..7cfc241 100644
--- a/drivers/staging/lustre/include/uapi/linux/lnet/lnetst.h
+++ b/drivers/staging/lustre/include/uapi/linux/lnet/lnetst.h
@@ -71,7 +71,7 @@
 
 struct lst_sid {
 	lnet_nid_t	ses_nid;	/* nid of console node */
-	__u64		ses_stamp;	/* time stamp */
+	__s64		ses_stamp;	/* time stamp */
 };					/*** session id */
 
 extern struct lst_sid LST_INVALID_SID;
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index 0dabade..95cbd1a 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -70,11 +70,11 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 	/* not an orphan RPC */
 	crpc->crp_finished = 1;
 
-	if (!crpc->crp_stamp) {
+	if (!crpc->crp_stamp_ns) {
 		/* not aborted */
 		LASSERT(!crpc->crp_status);
 
-		crpc->crp_stamp = jiffies;
+		crpc->crp_stamp_ns = ktime_get_ns();
 		crpc->crp_status = rpc->crpc_status;
 	}
 
@@ -102,7 +102,7 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 	crpc->crp_finished = 0;
 	crpc->crp_unpacked = 0;
 	crpc->crp_status = 0;
-	crpc->crp_stamp = 0;
+	crpc->crp_stamp_ns = 0;
 	crpc->crp_embedded = embedded;
 	INIT_LIST_HEAD(&crpc->crp_link);
 
@@ -294,16 +294,16 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 		spin_lock(&rpc->crpc_lock);
 
 		if (!crpc->crp_posted || /* not posted */
-		    crpc->crp_stamp) {	 /* rpc done or aborted already */
-			if (!crpc->crp_stamp) {
-				crpc->crp_stamp = jiffies;
+		    crpc->crp_stamp_ns) {	 /* rpc done or aborted already */
+			if (!crpc->crp_stamp_ns) {
+				crpc->crp_stamp_ns = ktime_get_ns();
 				crpc->crp_status = -EINTR;
 			}
 			spin_unlock(&rpc->crpc_lock);
 			continue;
 		}
 
-		crpc->crp_stamp = jiffies;
+		crpc->crp_stamp_ns = ktime_get_ns();
 		crpc->crp_status = error;
 
 		spin_unlock(&rpc->crpc_lock);
@@ -314,10 +314,10 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 			continue;
 
 		nd = crpc->crp_node;
-		if (time_after(nd->nd_stamp, crpc->crp_stamp))
+		if (ktime_to_ns(nd->nd_stamp) > crpc->crp_stamp_ns)
 			continue;
 
-		nd->nd_stamp = crpc->crp_stamp;
+		nd->nd_stamp = ktime_set(0, crpc->crp_stamp_ns);
 		nd->nd_state = LST_NODE_DOWN;
 	}
 }
@@ -390,7 +390,7 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 	struct srpc_generic_reply *rep;
 
 	LASSERT(nd && rpc);
-	LASSERT(crpc->crp_stamp);
+	LASSERT(crpc->crp_stamp_ns);
 
 	if (crpc->crp_status) {
 		*msgpp = NULL;
@@ -403,10 +403,10 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 		crpc->crp_unpacked = 1;
 	}
 
-	if (time_after(nd->nd_stamp, crpc->crp_stamp))
+	if (ktime_to_ns(nd->nd_stamp) > crpc->crp_stamp_ns)
 		return 0;
 
-	nd->nd_stamp = crpc->crp_stamp;
+	nd->nd_stamp = ktime_set(0, crpc->crp_stamp_ns);
 	rep = &(*msgpp)->msg_body.reply;
 
 	if (rep->sid.ses_nid == LNET_NID_ANY)
@@ -433,7 +433,7 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 	list_for_each_entry(crpc, &trans->tas_rpcs_list, crp_link) {
 		lstcon_rpc_stat_total(stat, 1);
 
-		LASSERT(crpc->crp_stamp);
+		LASSERT(crpc->crp_stamp_ns);
 
 		error = lstcon_rpc_get_reply(crpc, &rep);
 		if (error) {
@@ -474,9 +474,9 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 	struct lstcon_rpc *crpc;
 	struct srpc_msg *msg;
 	struct lstcon_node *nd;
-	long dur;
 	struct timeval tv;
 	int error;
+	s64 dur;
 
 	LASSERT(head_up);
 
@@ -493,15 +493,15 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 
 		ent = list_entry(next, struct lstcon_rpc_ent, rpe_link);
 
-		LASSERT(crpc->crp_stamp);
+		LASSERT(crpc->crp_stamp_ns);
 
 		error = lstcon_rpc_get_reply(crpc, &msg);
 
 		nd = crpc->crp_node;
 
-		dur = (long)(crpc->crp_stamp -
-			     (unsigned long)console_session.ses_id.ses_stamp);
-		jiffies_to_timeval(dur, &tv);
+		dur = crpc->crp_stamp_ns -
+		      console_session.ses_id.ses_stamp * NSEC_PER_MSEC;
+		tv = ns_to_timeval(dur);
 
 		if (copy_to_user(&ent->rpe_peer, &nd->nd_id,
 				 sizeof(struct lnet_process_id)) ||
@@ -1246,7 +1246,8 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 		if (nd->nd_state != LST_NODE_ACTIVE)
 			continue;
 
-		intv = (jiffies - nd->nd_stamp) / msecs_to_jiffies(MSEC_PER_SEC);
+		intv = div_u64(ktime_ms_delta(ktime_get(), nd->nd_stamp),
+			       MSEC_PER_SEC);
 		if (intv < nd->nd_timeout / 2)
 			continue;
 
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.h b/drivers/staging/lustre/lnet/selftest/conrpc.h
index ce2f92d..dfc31b8 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.h
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.h
@@ -70,7 +70,7 @@ struct lstcon_rpc {
 	/** RPC is embedded in other structure and can't free it */
 	unsigned int		 crp_embedded:1;
 	int			 crp_status;	/* console rpc errors */
-	unsigned long		 crp_stamp;	/* replied time stamp */
+	s64			 crp_stamp_ns;	/* replied time stamp */
 };
 
 struct lstcon_rpc_trans {
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index 3c1c1b5..8e6f875 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -97,7 +97,7 @@
 
 	ndl->ndl_node->nd_ref = 1;
 	ndl->ndl_node->nd_id = id;
-	ndl->ndl_node->nd_stamp = jiffies;
+	ndl->ndl_node->nd_stamp = ktime_get();
 	ndl->ndl_node->nd_state = LST_NODE_UNKNOWN;
 	ndl->ndl_node->nd_timeout = 0;
 	memset(&ndl->ndl_node->nd_ping, 0, sizeof(struct lstcon_rpc));
@@ -1700,7 +1700,7 @@ static void lstcon_group_ndlink_release(struct lstcon_group *,
 
 	LNetGetId(1, &id);
 	sid->ses_nid = id.nid;
-	sid->ses_stamp = jiffies;
+	sid->ses_stamp = div_u64(ktime_get_ns(), NSEC_PER_MSEC);
 }
 
 int
diff --git a/drivers/staging/lustre/lnet/selftest/console.h b/drivers/staging/lustre/lnet/selftest/console.h
index 2826205..eaad07c 100644
--- a/drivers/staging/lustre/lnet/selftest/console.h
+++ b/drivers/staging/lustre/lnet/selftest/console.h
@@ -51,7 +51,7 @@ struct lstcon_node {
 	int		  nd_ref;     /* reference count */
 	int		  nd_state;   /* state of the node */
 	int		  nd_timeout; /* session timeout */
-	unsigned long	  nd_stamp;   /* timestamp of last replied RPC */
+	ktime_t			nd_stamp;   /* timestamp of last replied RPC */
 	struct lstcon_rpc nd_ping;    /* ping rpc */
 };
 
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 741af10..6768aef 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -272,7 +272,7 @@
 	sn->sn_id = sid;
 	sn->sn_features = features;
 	sn->sn_timeout = session_timeout;
-	sn->sn_started = jiffies;
+	sn->sn_started = ktime_get();
 
 	timer->stt_data = sn;
 	timer->stt_func = sfw_session_expired;
@@ -384,7 +384,7 @@
 	 * send over the msecs since the session was started
 	 * with 32 bits to send, this is ~49 days
 	 */
-	cnt->running_ms = jiffies_to_msecs(jiffies - sn->sn_started);
+	cnt->running_ms = ktime_ms_delta(ktime_get(), sn->sn_started);
 	cnt->brw_errors = atomic_read(&sn->sn_brw_errors);
 	cnt->ping_errors = atomic_read(&sn->sn_ping_errors);
 	cnt->zombie_sessions = atomic_read(&sfw_data.fw_nzombies);
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 8737fa9..76e02cd 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -331,7 +331,7 @@ struct sfw_session {
 	atomic_t	 sn_refcount;
 	atomic_t	 sn_brw_errors;
 	atomic_t	 sn_ping_errors;
-	unsigned long	 sn_started;
+	ktime_t		 sn_started;
 };
 
 #define sfw_sid_equal(sid0, sid1)     ((sid0).ses_nid == (sid1).ses_nid && \
diff --git a/drivers/staging/lustre/lnet/selftest/timer.c b/drivers/staging/lustre/lnet/selftest/timer.c
index 582f252..c83473e 100644
--- a/drivers/staging/lustre/lnet/selftest/timer.c
+++ b/drivers/staging/lustre/lnet/selftest/timer.c
@@ -55,7 +55,7 @@
 
 static struct st_timer_data {
 	spinlock_t	  stt_lock;
-	unsigned long	  stt_prev_slot; /* start time of the slot processed
+	time64_t	  stt_prev_slot; /* start time of the slot processed
 					  * previously
 					  */
 	struct list_head  stt_hash[STTIMER_NSLOTS];
@@ -144,18 +144,18 @@
 }
 
 static int
-stt_check_timers(unsigned long *last)
+stt_check_timers(time64_t *last)
 {
 	int expired = 0;
 	time64_t now;
-	unsigned long this_slot;
+	time64_t this_slot;
 
 	now = ktime_get_real_seconds();
 	this_slot = now & STTIMER_SLOTTIMEMASK;
 
 	spin_lock(&stt_data.stt_lock);
 
-	while (time_after_eq(this_slot, *last)) {
+	while (this_slot >= *last) {
 		expired += stt_expire_list(STTIMER_SLOT(this_slot), now);
 		this_slot = this_slot - STTIMER_SLOTTIME;
 	}
-- 
1.8.3.1
