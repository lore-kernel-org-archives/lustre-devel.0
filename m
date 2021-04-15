Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB1F9C433B4
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:03:09 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7083A610CB
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:03:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7083A610CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 646E032F5DD;
	Wed, 14 Apr 2021 21:03:02 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B0C1332F3FA
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:49 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 61F1E100F34B;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 5DEDB9188E; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:02 -0400
Message-Id: <1618459361-17909-11-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 10/49] lnet: socklnd: change various ints to
 bool.
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

Each of these int variables, and one int function, are
really truth values, so change to bool.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12678
Lustre-commit: a3275d1d79df5ab5 ("LU-12678 socklnd: change various ints to bool.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39302
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.c    | 13 ++++++-------
 net/lnet/klnds/socklnd/socklnd_cb.c | 22 +++++++++++-----------
 2 files changed, 17 insertions(+), 18 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index a7c0b65..589a835 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -1533,7 +1533,7 @@ struct ksock_peer_ni *
 void
 ksocknal_peer_failed(struct ksock_peer_ni *peer_ni)
 {
-	int notify = 0;
+	bool notify = false;
 	time64_t last_alive = 0;
 
 	/*
@@ -1547,7 +1547,7 @@ struct ksock_peer_ni *
 	    list_empty(&peer_ni->ksnp_conns) &&
 	    !peer_ni->ksnp_accepting &&
 	    !ksocknal_find_connecting_route_locked(peer_ni)) {
-		notify = 1;
+		notify = true;
 		last_alive = peer_ni->ksnp_last_alive;
 	}
 
@@ -1598,15 +1598,14 @@ struct ksock_peer_ni *
 void
 ksocknal_terminate_conn(struct ksock_conn *conn)
 {
-	/*
-	 * This gets called by the reaper (guaranteed thread context) to
+	/* This gets called by the reaper (guaranteed thread context) to
 	 * disengage the socket from its callbacks and close it.
 	 * ksnc_refcount will eventually hit zero, and then the reaper will
 	 * destroy it.
 	 */
 	struct ksock_peer_ni *peer_ni = conn->ksnc_peer;
 	struct ksock_sched *sched = conn->ksnc_scheduler;
-	int failed = 0;
+	bool failed = false;
 
 	LASSERT(conn->ksnc_closing);
 
@@ -1643,7 +1642,7 @@ struct ksock_peer_ni *
 	if (peer_ni->ksnp_error) {
 		/* peer_ni's last conn closed in error */
 		LASSERT(list_empty(&peer_ni->ksnp_conns));
-		failed = 1;
+		failed = true;
 		peer_ni->ksnp_error = 0;     /* avoid multiple notifications */
 	}
 
@@ -2493,7 +2492,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 	for (i = 0; i < net->ksnn_ninterfaces; i++) {
 		char *ifnam = &net->ksnn_interfaces[i].ksni_name[0];
 		char *colon = strchr(ifnam, ':');
-		int found  = 0;
+		bool found  = false;
 		struct ksock_net *tmp;
 		int j;
 
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index 7fa2d58..b1146dc 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -1337,7 +1337,7 @@ int ksocknal_scheduler(void *arg)
 	spin_lock_bh(&sched->kss_lock);
 
 	while (!ksocknal_data.ksnd_shuttingdown) {
-		int did_something = 0;
+		bool did_something = false;
 
 		/* Ensure I progress everything semi-fairly */
 
@@ -1387,7 +1387,7 @@ int ksocknal_scheduler(void *arg)
 				ksocknal_conn_decref(conn);
 			}
 
-			did_something = 1;
+			did_something = true;
 		}
 
 		if (!list_empty(&sched->kss_tx_conns)) {
@@ -1463,7 +1463,7 @@ int ksocknal_scheduler(void *arg)
 				ksocknal_conn_decref(conn);
 			}
 
-			did_something = 1;
+			did_something = true;
 		}
 		if (!did_something ||	/* nothing to do */
 		    need_resched()) {	/* hogging CPU? */
@@ -1767,7 +1767,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	return 0;
 }
 
-static int
+static bool
 ksocknal_connect(struct ksock_route *route)
 {
 	LIST_HEAD(zombies);
@@ -1776,7 +1776,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 	int wanted;
 	struct socket *sock;
 	time64_t deadline;
-	int retry_later = 0;
+	bool retry_later = 0;
 	int rc = 0;
 
 	deadline = ktime_get_seconds() + ksocknal_timeout();
@@ -1797,7 +1797,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 		 */
 		if (peer_ni->ksnp_closing || route->ksnr_deleted ||
 		    !wanted) {
-			retry_later = 0;
+			retry_later = false;
 			break;
 		}
 
@@ -1807,7 +1807,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 			       "peer_ni %s(%d) already connecting to me, retry later.\n",
 			       libcfs_nid2str(peer_ni->ksnp_id.nid),
 			       peer_ni->ksnp_accepting);
-			retry_later = 1;
+			retry_later = true;
 		}
 
 		if (retry_later) /* needs reschedule */
@@ -2087,7 +2087,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 		struct ksock_route *route = NULL;
 		time64_t sec = ktime_get_real_seconds();
 		long timeout = MAX_SCHEDULE_TIMEOUT;
-		int dropped_lock = 0;
+		bool dropped_lock = false;
 
 		if (ksocknal_connd_check_stop(sec, &timeout)) {
 			/* wakeup another one to check stop */
@@ -2097,7 +2097,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 
 		if (ksocknal_connd_check_start(sec, &timeout)) {
 			/* created new thread */
-			dropped_lock = 1;
+			dropped_lock = true;
 		}
 
 		cr = list_first_entry_or_null(&ksocknal_data.ksnd_connd_connreqs,
@@ -2107,7 +2107,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 
 			list_del(&cr->ksncr_list);
 			spin_unlock_bh(connd_lock);
-			dropped_lock = 1;
+			dropped_lock = true;
 
 			ksocknal_create_conn(cr->ksncr_ni, NULL,
 					     cr->ksncr_sock, SOCKLND_CONN_NONE);
@@ -2130,7 +2130,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 			list_del(&route->ksnr_connd_list);
 			ksocknal_data.ksnd_connd_connecting++;
 			spin_unlock_bh(connd_lock);
-			dropped_lock = 1;
+			dropped_lock = true;
 
 			if (ksocknal_connect(route)) {
 				/* consecutive retry */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
