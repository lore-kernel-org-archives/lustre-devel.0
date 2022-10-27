Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id A0F4BFA3740
	for <lustre-devel@archiver.kernel.org>; Thu, 27 Oct 2022 14:11:06 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MynYR3TVtz215Q;
	Thu, 27 Oct 2022 07:07:07 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MynX30tGcz1wdw
 for <lustre-devel@lists.lustre.org>; Thu, 27 Oct 2022 07:05:55 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 768BF10090F8;
 Thu, 27 Oct 2022 10:05:44 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 6F691FD4F7; Thu, 27 Oct 2022 10:05:44 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 27 Oct 2022 10:05:31 -0400
Message-Id: <1666879542-10737-5-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1666879542-10737-1-git-send-email-jsimmons@infradead.org>
References: <1666879542-10737-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 04/15] lustre: ptlrpc: reduce lock contention
 in ptlrpc_free_committed
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Andreas Dilger <adilger@whamcloud.com>

This patch breaks out of the loop in ptlrpc_free_committed()
if need_resched() is true or there are other threads waiting
on the imp_lock. This can avoid the thread holding the
CPU for too long time to free large number of requests. The
remaining requests in the list will be processed the next
time this function is called. That also avoids delaying a
single thread too long if the list is long.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16180
Lustre-commit: d3074511f3ee322d ("LU-16180 ptlrpc: reduce lock contention in ptlrpc_free_committed")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: Jian Yu <yujian@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48629
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_import.h       |  6 ++
 fs/lustre/obdclass/genops.c             |  1 +
 fs/lustre/ptlrpc/client.c               | 99 ++++++++++++++++++++++++++++-----
 include/uapi/linux/lustre/lustre_user.h |  2 +-
 4 files changed, 93 insertions(+), 15 deletions(-)

diff --git a/fs/lustre/include/lustre_import.h b/fs/lustre/include/lustre_import.h
index 8c1fe65..3ae05b5 100644
--- a/fs/lustre/include/lustre_import.h
+++ b/fs/lustre/include/lustre_import.h
@@ -279,6 +279,12 @@ struct obd_import {
 	/** Protects flags, level, generation, conn_cnt, *_list */
 	spinlock_t			imp_lock;
 
+	/**
+	 * A "sentinel" value used to check if there are other threads
+	 * waiting on the imp_lock.
+	 */
+	atomic_t			imp_waiting;
+
 	/* flags */
 	unsigned long			imp_invalid:1,    /* evicted */
 					/* administratively disabled */
diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index 81e3498..2031320 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -997,6 +997,7 @@ struct obd_import *class_new_import(struct obd_device *obd)
 	atomic_set(&imp->imp_replay_inflight, 0);
 	init_waitqueue_head(&imp->imp_replay_waitq);
 	atomic_set(&imp->imp_inval_count, 0);
+	atomic_set(&imp->imp_waiting, 0);
 	INIT_LIST_HEAD(&imp->imp_conn_list);
 	init_imp_at(&imp->imp_at);
 
diff --git a/fs/lustre/ptlrpc/client.c b/fs/lustre/ptlrpc/client.c
index 5f0ff47..6c1d98d 100644
--- a/fs/lustre/ptlrpc/client.c
+++ b/fs/lustre/ptlrpc/client.c
@@ -1507,7 +1507,15 @@ static int after_reply(struct ptlrpc_request *req)
 	}
 
 	if (imp->imp_replayable) {
+		/* if other threads are waiting for ptlrpc_free_committed()
+		 * they could continue the work of freeing RPCs. That reduces
+		 * lock hold times, and distributes work more fairly across
+		 * waiting threads.  We can't use spin_is_contended() since
+		 * there are many other places where imp_lock is held.
+		 */
+		atomic_inc(&imp->imp_waiting);
 		spin_lock(&imp->imp_lock);
+		atomic_dec(&imp->imp_waiting);
 		/*
 		 * No point in adding already-committed requests to the replay
 		 * list, we will just remove them immediately. b=9829
@@ -1528,7 +1536,9 @@ static int after_reply(struct ptlrpc_request *req)
 			 */
 			spin_unlock(&imp->imp_lock);
 			req->rq_commit_cb(req);
+			atomic_inc(&imp->imp_waiting);
 			spin_lock(&imp->imp_lock);
+			atomic_dec(&imp->imp_waiting);
 		}
 
 		/* Replay-enabled imports return commit-status information. */
@@ -2754,25 +2764,33 @@ void ptlrpc_free_committed(struct obd_import *imp)
 	struct ptlrpc_request *req, *saved;
 	struct ptlrpc_request *last_req = NULL; /* temporary fire escape */
 	bool skip_committed_list = true;
+	unsigned int replay_scanned = 0, replay_freed = 0;
+	unsigned int commit_scanned = 0, commit_freed = 0;
+	unsigned int debug_level = D_INFO;
+	u64 peer_committed_transno;
+	int imp_generation;
+	time64_t start, now;
 
 	assert_spin_locked(&imp->imp_lock);
 
-	if (imp->imp_peer_committed_transno == imp->imp_last_transno_checked &&
-	    imp->imp_generation == imp->imp_last_generation_checked) {
+	start = ktime_get_seconds();
+	/* save these here, we can potentially drop imp_lock after checking */
+	peer_committed_transno = imp->imp_peer_committed_transno;
+	imp_generation = imp->imp_generation;
+
+	if (peer_committed_transno == imp->imp_last_transno_checked &&
+	    imp_generation == imp->imp_last_generation_checked) {
 		CDEBUG(D_INFO, "%s: skip recheck: last_committed %llu\n",
-		       imp->imp_obd->obd_name, imp->imp_peer_committed_transno);
+		       imp->imp_obd->obd_name, peer_committed_transno);
 		return;
 	}
 	CDEBUG(D_RPCTRACE, "%s: committing for last_committed %llu gen %d\n",
-	       imp->imp_obd->obd_name, imp->imp_peer_committed_transno,
-	       imp->imp_generation);
+	       imp->imp_obd->obd_name, peer_committed_transno, imp_generation);
 
-	if (imp->imp_generation != imp->imp_last_generation_checked ||
+	if (imp_generation != imp->imp_last_generation_checked ||
 	    !imp->imp_last_transno_checked)
 		skip_committed_list = false;
-
-	imp->imp_last_transno_checked = imp->imp_peer_committed_transno;
-	imp->imp_last_generation_checked = imp->imp_generation;
+	/* maybe drop imp_lock here, if another lock protected the lists */
 
 	list_for_each_entry_safe(req, saved, &imp->imp_replay_list,
 				 rq_replay_list) {
@@ -2784,7 +2802,27 @@ void ptlrpc_free_committed(struct obd_import *imp)
 			DEBUG_REQ(D_EMERG, req, "zero transno during replay");
 			LBUG();
 		}
-		if (req->rq_import_generation < imp->imp_generation) {
+
+		/* If other threads are waiting on imp_lock, stop processing
+		 * in this thread. Another thread can finish remaining work.
+		 * This may happen if there are huge numbers of open files
+		 * that are closed suddenly or evicted, or if the server
+		 * commit interval is very high vs. RPC rate.
+		 */
+		if (++replay_scanned % 2048 == 0) {
+			now = ktime_get_seconds();
+			if (now > start + 5)
+				debug_level = D_WARNING;
+
+			if ((replay_freed > 128 && now > start + 3) &&
+			    atomic_read(&imp->imp_waiting)) {
+				if (debug_level == D_INFO)
+					debug_level = D_RPCTRACE;
+				break;
+			}
+		}
+
+		if (req->rq_import_generation < imp_generation) {
 			DEBUG_REQ(D_RPCTRACE, req, "free request with old gen");
 			goto free_req;
 		}
@@ -2803,29 +2841,62 @@ void ptlrpc_free_committed(struct obd_import *imp)
 		}
 
 		DEBUG_REQ(D_INFO, req, "commit (last_committed %llu)",
-			  imp->imp_peer_committed_transno);
+			  peer_committed_transno);
 free_req:
+		replay_freed++;
 		ptlrpc_free_request(req);
 	}
+
 	if (skip_committed_list)
-		return;
+		goto out;
 
 	list_for_each_entry_safe(req, saved, &imp->imp_committed_list,
 				 rq_replay_list) {
 		LASSERT(req->rq_transno != 0);
-		if (req->rq_import_generation < imp->imp_generation ||
+
+		/* If other threads are waiting on imp_lock, stop processing
+		 * in this thread. Another thread can finish remaining work.
+		 */
+		if (++commit_scanned % 2048 == 0) {
+			now = ktime_get_seconds();
+			if (now > start + 6)
+				debug_level = D_WARNING;
+
+			if ((commit_freed > 128 && now > start + 4) &&
+			    atomic_read(&imp->imp_waiting)) {
+				if (debug_level == D_INFO)
+					debug_level = D_RPCTRACE;
+				break;
+			}
+		}
+
+		if (req->rq_import_generation < imp_generation ||
 		    !req->rq_replay) {
 			DEBUG_REQ(D_RPCTRACE, req, "free %s open request",
 				  req->rq_import_generation <
-				  imp->imp_generation ? "stale" : "closed");
+				  imp_generation ? "stale" : "closed");
 
 			if (imp->imp_replay_cursor == &req->rq_replay_list)
 				imp->imp_replay_cursor =
 					req->rq_replay_list.next;
 
+			commit_freed++;
 			ptlrpc_free_request(req);
 		}
 	}
+out:
+	/* if full lists processed without interruption, avoid next scan */
+	if (debug_level == D_INFO) {
+		imp->imp_last_transno_checked = peer_committed_transno;
+		imp->imp_last_generation_checked = imp_generation;
+	}
+
+	CDEBUG_LIMIT(debug_level,
+		     "%s: %s: skip=%u replay=%u/%u committed=%u/%u\n",
+		     imp->imp_obd->obd_name,
+		     debug_level == D_INFO ? "normal" : "overloaded",
+		     skip_committed_list, replay_freed, replay_scanned,
+		     commit_freed, commit_scanned);
 }
 
 /**
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index db18cd5..e97ccb0 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -987,7 +987,7 @@ static inline void obd_uuid2fsname(char *buf, char *uuid, int buflen)
  */
 #define SFID "0x%llx:0x%x:0x%x"
 #define RFID(fid) &((fid)->f_seq), &((fid)->f_oid), &((fid)->f_ver)
-#define PLOGID(logid) ((unsigned long long)(logid)->lgl_oi.oi.oi_seq, (__u32)(logid)->lgl_oi.oi.oi_id, 0)
+#define PLOGID(logid) (unsigned long long)(logid)->lgl_oi.oi.oi_seq, (__u32)(logid)->lgl_oi.oi.oi_id, 0
 
 /********* Quotas **********/
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
