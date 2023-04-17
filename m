Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 70097C77B76
	for <lustre-devel@archiver.kernel.org>; Mon, 17 Apr 2023 14:07:21 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Q0T574889z22Rs;
	Mon, 17 Apr 2023 06:52:27 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Q0T1P5J66z21BZ
 for <lustre-devel@lists.lustre.org>; Mon, 17 Apr 2023 06:49:13 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 9B0D61008493;
 Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 9971A375; Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 17 Apr 2023 09:47:13 -0400
Message-Id: <1681739243-29375-18-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
References: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 17/27] lnet: Health logging improvements
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Chris Horn <chris.horn@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Chris Horn <chris.horn@hpe.com>

LNet health activity can generate noise in console logs. The NI/Peer
NI recovery pings could be expected to fail and the related messages
from lnet_handle_recovery_reply() are generally redundant.

Improve this logging by having the lnet_monitor_thread() provide a
summary of NIs in recovery.

Another useful metric in spotting network trouble is if we have
messages exceeding their deadline. We do not currently log this
information. Keep a count of messages that have exceeded their
deadline and track the total excess time. The lnet_monitor_thread()
will then provide a summary of the number of messages and their
average excess time at a regular interval. These stats are then
reset when the monitor thread prints this information to the console.

Because NIs can be in recovery for extended periods of time, the
interval of console updates will increase from 1 to 5 minutes.
The interval is reset when it is detected that there are no longer any
NIs in recovery and there haven't been any messages past their
deadline since the last console update.

HPE-bug-id: LUS-11500
WC-bug-id: https://jira.whamcloud.com/browse/LU-16643
Lustre-commit: 0cb3d86c4004d7581 ("LU-16643 lnet: Health logging improvements")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50305
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h |   5 ++
 net/lnet/lnet/api-ni.c         |   2 +
 net/lnet/lnet/lib-move.c       | 165 +++++++++++++++++++++++++++++++++++++++--
 net/lnet/lnet/lib-msg.c        |  16 +++-
 4 files changed, 176 insertions(+), 12 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index eb54e75..1ae4530 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -1529,6 +1529,11 @@ struct lnet {
 	struct completion		ln_started;
 	/* UDSP list */
 	struct list_head		ln_udsp_list;
+
+	/* Number of messages that have exceeded their message deadline */
+	atomic_t			ln_late_msg_count;
+	/* Total amount of time past their deadline for all late ^ messages */
+	atomic64_t			ln_late_msg_nsecs;
 };
 
 struct genl_filter_list {
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index fb596ed..f3f9aee 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -1295,6 +1295,8 @@ struct list_head **
 	init_waitqueue_head(&the_lnet.ln_dc_waitq);
 	the_lnet.ln_mt_handler = NULL;
 	init_completion(&the_lnet.ln_started);
+	atomic_set(&the_lnet.ln_late_msg_count, 0);
+	atomic64_set(&the_lnet.ln_late_msg_nsecs, 0);
 
 	rc = lnet_slab_setup();
 	if (rc != 0)
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 95abe4f1..9d50260 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -3237,8 +3237,11 @@ struct lnet_mt_event_info {
 	lnet_ni_lock(ni);
 }
 
-static void
-lnet_recover_local_nis(void)
+/* Returns the total number of local NIs in recovery.
+ * Records up to @arrsz of the associated NIDs in the @nidarr array
+ */
+static int
+lnet_recover_local_nis(struct lnet_nid *nidarr, unsigned int arrsz)
 {
 	struct lnet_mt_event_info *ev_info;
 	LIST_HEAD(processed_list);
@@ -3250,6 +3253,7 @@ struct lnet_mt_event_info {
 	int healthv;
 	int rc;
 	time64_t now;
+	unsigned int nnis = 0;
 
 	/* splice the recovery queue on a local queue. We will iterate
 	 * through the local queue and update it as needed. Once we're
@@ -3286,6 +3290,10 @@ struct lnet_mt_event_info {
 			continue;
 		}
 
+		if (nnis < arrsz)
+			nidarr[nnis] = ni->ni_nid;
+		nnis++;
+
 		/* if the local NI failed recovery we must unlink the md.
 		 * But we want to keep the local_ni on the recovery queue
 		 * so we can continue the attempts to recover it.
@@ -3391,6 +3399,8 @@ struct lnet_mt_event_info {
 	lnet_net_lock(0);
 	list_splice(&local_queue, &the_lnet.ln_mt_localNIRecovq);
 	lnet_net_unlock(0);
+
+	return nnis;
 }
 
 static int
@@ -3490,12 +3500,16 @@ struct lnet_mt_event_info {
 	cfs_percpt_free(the_lnet.ln_mt_resendqs);
 }
 
-static void
-lnet_recover_peer_nis(void)
+/* Returns the total number of peer NIs in recovery.
+ * Records up to @arrsz of the associated NIDs in the @nidarr array
+ */
+static unsigned int
+lnet_recover_peer_nis(struct lnet_nid *nidarr, unsigned int arrsz)
 {
 	struct lnet_mt_event_info *ev_info;
 	LIST_HEAD(processed_list);
 	LIST_HEAD(local_queue);
+	unsigned int nlpnis = 0;
 	struct lnet_handle_md mdh;
 	struct lnet_peer_ni *lpni;
 	struct lnet_peer_ni *tmp;
@@ -3532,6 +3546,10 @@ struct lnet_mt_event_info {
 			continue;
 		}
 
+		if (nlpnis < arrsz)
+			nidarr[nlpnis] = lpni->lpni_nid;
+		nlpnis++;
+
 		/* If the peer NI has failed recovery we must unlink the
 		 * md. But we want to keep the peer ni on the recovery
 		 * queue so we can try to continue recovering it
@@ -3621,6 +3639,131 @@ struct lnet_mt_event_info {
 	lnet_net_lock(0);
 	list_splice(&local_queue, &the_lnet.ln_mt_peerNIRecovq);
 	lnet_net_unlock(0);
+
+	return nlpnis;
+}
+
+#define LNET_MAX_NNIDS 20
+/* @nids is array of nids that are in recovery. It has max size of
+ * LNET_MAX_NNIDS.
+ * @nnids is the total number of nids that are in recovery. It can be
+ * larger than LNET_MAX_NNIDS.
+ * @local tells us whether these are local or peer NIs in recovery.
+ */
+static void
+lnet_print_recovery_list(struct lnet_nid *nids, unsigned int nnids,
+			 bool local)
+{
+	static bool printed;
+	char *buf = NULL;
+	char *tmp;
+	int i;
+	unsigned int arrsz;
+	unsigned int bufsz;
+
+	if (!nnids)
+		return;
+
+	arrsz = nnids < LNET_MAX_NNIDS ? nnids : LNET_MAX_NNIDS;
+
+	/* Printing arrsz NIDs, each has max size LNET_NIDSTR_SIZE, a comma
+	 * and space for each nid after the first (2 * (arrsz - 1)),
+	 * + 1 for terminating null byte
+	 */
+	bufsz = (arrsz * LNET_NIDSTR_SIZE) + (2 * (arrsz - 1)) + 1;
+	buf = kzalloc(bufsz, GFP_KERNEL);
+	if (!buf) {
+		LCONSOLE(D_INFO, "%u %s NIs in recovery\n",
+			 nnids, local ? "local" : "peer");
+		return;
+	}
+
+	tmp = buf;
+	tmp += sprintf(tmp, "%s", libcfs_nidstr(&nids[0]));
+	for (i = 1; i < arrsz; i++)
+		tmp += sprintf(tmp, ", %s", libcfs_nidstr(&nids[i]));
+
+	/* LCONSOLE() used to avoid rate limiting when we have both local
+	 * and peer NIs in recovery
+	 */
+	LCONSOLE(D_INFO, "%u %s NIs in recovery (showing %u): %s\n",
+		 nnids, local ? "local" : "peer", arrsz, buf);
+
+	kfree(buf);
+
+	if (!printed && nnids > LNET_MAX_NNIDS) {
+		LCONSOLE(D_INFO, "See full list with 'lnetctl debug recovery -(p|l)'\n");
+		printed = true;
+	}
+}
+
+static void
+lnet_health_update_console(struct lnet_nid *lnids, unsigned int nnis,
+			   struct lnet_nid *rnids, unsigned int nlpnis,
+			   time64_t now)
+{
+	static time64_t next_ni_update;
+	static time64_t next_lpni_update;
+	static time64_t next_msg_update;
+	static unsigned int num_ni_updates;
+	static unsigned int num_lpni_updates;
+	static unsigned int num_msg_updates = 1;
+	int late_count;
+
+	if (now >= next_ni_update) {
+		if (nnis) {
+			lnet_print_recovery_list(lnids, nnis, true);
+			if (num_ni_updates < 5)
+				num_ni_updates++;
+			next_ni_update = now + (60 * num_ni_updates);
+		} else {
+			next_ni_update = 0;
+			num_ni_updates = 0;
+		}
+	}
+
+	if (now >= next_lpni_update) {
+		if (nlpnis) {
+			lnet_print_recovery_list(rnids, nlpnis, false);
+			if (num_lpni_updates < 5)
+				num_lpni_updates++;
+			next_lpni_update = now + (60 * num_lpni_updates);
+		} else {
+			next_lpni_update = 0;
+			num_lpni_updates = 0;
+		}
+	}
+
+	/* Let late_count accumulate for 60 seconds */
+	if (unlikely(!next_msg_update))
+		next_msg_update = now + 60;
+
+	if (now >= next_msg_update) {
+		late_count = atomic_read(&the_lnet.ln_late_msg_count);
+
+		if (late_count) {
+			s64 avg = atomic64_xchg(&the_lnet.ln_late_msg_nsecs, 0) /
+				  atomic_xchg(&the_lnet.ln_late_msg_count, 0);
+
+			if (avg > NSEC_PER_SEC) {
+				unsigned int avg_msec;
+
+				avg_msec = do_div(avg, NSEC_PER_SEC) /
+					   NSEC_PER_MSEC;
+				LCONSOLE_INFO("%u messages in past %us over their deadline by avg %lld.%03us\n",
+					      late_count,
+					      (60 * num_msg_updates), avg,
+					      avg_msec);
+
+				if (num_msg_updates < 5)
+					num_msg_updates++;
+				next_msg_update = now + (60 * num_msg_updates);
+			}
+		} else {
+			next_msg_update = now + 60;
+			num_msg_updates = 1;
+		}
+	}
 }
 
 static int
@@ -3628,6 +3771,10 @@ struct lnet_mt_event_info {
 {
 	time64_t rsp_timeout = 0;
 	time64_t now;
+	unsigned int nnis;
+	unsigned int nlpnis;
+	struct lnet_nid local_nids[LNET_MAX_NNIDS];
+	struct lnet_nid peer_nids[LNET_MAX_NNIDS];
 
 	wait_for_completion(&the_lnet.ln_started);
 
@@ -3653,8 +3800,10 @@ struct lnet_mt_event_info {
 			rsp_timeout = now + (lnet_transaction_timeout / 2);
 		}
 
-		lnet_recover_local_nis();
-		lnet_recover_peer_nis();
+		nnis = lnet_recover_local_nis(local_nids, LNET_MAX_NNIDS);
+		nlpnis = lnet_recover_peer_nis(peer_nids, LNET_MAX_NNIDS);
+		lnet_health_update_console(local_nids, nnis, peer_nids, nlpnis,
+					   now);
 
 		/* TODO do we need to check if we should sleep without
 		 * timeout?  Technically, an active system will always
@@ -3768,7 +3917,7 @@ struct lnet_mt_event_info {
 		lnet_net_unlock(0);
 
 		if (status != 0) {
-			CERROR("local NI (%s) recovery failed with %d\n",
+			CDEBUG(D_NET, "local NI (%s) recovery failed with %d\n",
 			       libcfs_nidstr(nid), status);
 			return;
 		}
@@ -3800,7 +3949,7 @@ struct lnet_mt_event_info {
 		lnet_net_unlock(cpt);
 
 		if (status != 0)
-			CERROR("peer NI (%s) recovery failed with %d\n",
+			CDEBUG(D_NET, "peer NI (%s) recovery failed with %d\n",
 			       libcfs_nidstr(nid), status);
 	}
 }
diff --git a/net/lnet/lnet/lib-msg.c b/net/lnet/lnet/lib-msg.c
index 82d117d..420236d 100644
--- a/net/lnet/lnet/lib-msg.c
+++ b/net/lnet/lnet/lib-msg.c
@@ -761,6 +761,7 @@
 	bool attempt_remote_resend;
 	bool handle_local_health;
 	bool handle_remote_health;
+	ktime_t now;
 
 	/* if we're shutting down no point in handling health. */
 	if (the_lnet.ln_mt_state != LNET_MT_STATE_RUNNING)
@@ -778,10 +779,6 @@
 		 nid_is_lo0(&msg->msg_txni->ni_nid))
 		lo = true;
 
-	if (hstatus != LNET_MSG_STATUS_OK &&
-	    ktime_after(ktime_get(), msg->msg_deadline))
-		return -1;
-
 	/* always prefer txni/txpeer if they message is committed for both
 	 * directions.
 	 */
@@ -802,6 +799,17 @@
 	else
 		LASSERT(ni);
 
+	now = ktime_get();
+	if (ktime_after(now, msg->msg_deadline)) {
+		s64 time = ktime_to_ns(ktime_sub(now, msg->msg_deadline));
+
+		atomic64_add(time, &the_lnet.ln_late_msg_nsecs);
+		atomic_inc(&the_lnet.ln_late_msg_count);
+
+		if (hstatus != LNET_MSG_STATUS_OK)
+			return -1;
+	}
+
 	CDEBUG(D_NET, "health check: %s->%s: %s: %s\n",
 	       libcfs_nidstr(&ni->ni_nid),
 	       (lo) ? "self" : libcfs_nidstr(&lpni->lpni_nid),
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
