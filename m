Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 2B02AC43217
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Nov 2022 14:28:27 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4NFXhm0C8vz215y;
	Sun, 20 Nov 2022 06:19:36 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4NFXg63Nndz1yCf
 for <lustre-devel@lists.lustre.org>; Sun, 20 Nov 2022 06:18:10 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id C44D41007B78;
 Sun, 20 Nov 2022 09:17:09 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id BE863E8B89; Sun, 20 Nov 2022 09:17:09 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Nov 2022 09:16:53 -0500
Message-Id: <1668953828-10909-8-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
References: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 07/22] lustre: obdclass: improve precision of
 wakeups for mod_rpcs
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

From: Mr NeilBrown <neilb@suse.de>

There is a limit of the number of in-flight mod rpcs with a
complication that a 'close' rpc is always permitted if there are no
other close rpcs in flight, even if that would exceed the limit.

When a non-close-request complete, we just wake the first waiting
request and assume it will use the slot we released.  When a
close-request completes, the first waiting request may not find a slot
if the close was using the 'extra' slot.  So in that case we wake all
waiting requests and let them fit it out.  This is wasteful and
unfair.

To correct this we revise the wait/wake approach to use a dedicated
wakeup function which atomically checks if a given task can proceed,
and updates the counters when permission to proceed is given.  This
means that once a task has been woken, it has already been accounted
and it can proceed.

To minimise locking, cl_mod_rpcs_lock is discarded and
cl_mod_rpcs_waitq.lock is used to protect the counters.  For the
fast-path where the max has not been reached, this means we take and
release that spinlock just once.  We call wake_up_locked while still
holding the lock, and if that woke the process, then we don't drop the
spinlock to wait, but proceed directly to the remainder of the task.

When the last 'close' rpc completes, the wake function will iterate
the whole wait queue until it finds a task waiting to submit a close
request.  When any other rpc completes, the queue will only be
searched until the maximum is reached.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15947
Lustre-commit: 5243630b09d22e0b5 ("LU-15947 obdclass: improve precision of wakeups for mod_rpcs")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/44041
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Petros Koutoupis <petros.koutoupis@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd.h     |   1 -
 fs/lustre/ldlm/ldlm_lib.c   |   1 -
 fs/lustre/obdclass/genops.c | 158 ++++++++++++++++++++++++--------------------
 3 files changed, 88 insertions(+), 72 deletions(-)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index 16f66ea..56e5641 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -326,7 +326,6 @@ struct client_obd {
 	/* modify rpcs in flight
 	 * currently used for metadata only
 	 */
-	spinlock_t		cl_mod_rpcs_lock;
 	u16			cl_max_mod_rpcs_in_flight;
 	u16			cl_mod_rpcs_in_flight;
 	u16			cl_close_rpcs_in_flight;
diff --git a/fs/lustre/ldlm/ldlm_lib.c b/fs/lustre/ldlm/ldlm_lib.c
index 08aff4f..e4262c3 100644
--- a/fs/lustre/ldlm/ldlm_lib.c
+++ b/fs/lustre/ldlm/ldlm_lib.c
@@ -444,7 +444,6 @@ int client_obd_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	else
 		cli->cl_max_rpcs_in_flight = OBD_MAX_RIF_DEFAULT;
 
-	spin_lock_init(&cli->cl_mod_rpcs_lock);
 	spin_lock_init(&cli->cl_mod_rpcs_hist.oh_lock);
 	cli->cl_max_mod_rpcs_in_flight = 0;
 	cli->cl_mod_rpcs_in_flight = 0;
diff --git a/fs/lustre/obdclass/genops.c b/fs/lustre/obdclass/genops.c
index 2031320..6e4d240 100644
--- a/fs/lustre/obdclass/genops.c
+++ b/fs/lustre/obdclass/genops.c
@@ -1426,16 +1426,16 @@ int obd_set_max_mod_rpcs_in_flight(struct client_obd *cli, u16 max)
 		return -ERANGE;
 	}
 
-	spin_lock(&cli->cl_mod_rpcs_lock);
+	spin_lock_irq(&cli->cl_mod_rpcs_waitq.lock);
 
 	prev = cli->cl_max_mod_rpcs_in_flight;
 	cli->cl_max_mod_rpcs_in_flight = max;
 
 	/* wakeup waiters if limit has been increased */
 	if (cli->cl_max_mod_rpcs_in_flight > prev)
-		wake_up(&cli->cl_mod_rpcs_waitq);
+		wake_up_locked(&cli->cl_mod_rpcs_waitq);
 
-	spin_unlock(&cli->cl_mod_rpcs_lock);
+	spin_unlock_irq(&cli->cl_mod_rpcs_waitq.lock);
 
 	return 0;
 }
@@ -1446,7 +1446,7 @@ int obd_mod_rpc_stats_seq_show(struct client_obd *cli, struct seq_file *seq)
 	unsigned long mod_tot = 0, mod_cum;
 	int i;
 
-	spin_lock(&cli->cl_mod_rpcs_lock);
+	spin_lock_irq(&cli->cl_mod_rpcs_waitq.lock);
 	lprocfs_stats_header(seq, ktime_get(), cli->cl_mod_rpcs_init, 25,
 			     ":", true);
 	seq_printf(seq, "modify_RPCs_in_flight:  %hu\n",
@@ -1469,13 +1469,13 @@ int obd_mod_rpc_stats_seq_show(struct client_obd *cli, struct seq_file *seq)
 			break;
 	}
 
-	spin_unlock(&cli->cl_mod_rpcs_lock);
+	spin_unlock_irq(&cli->cl_mod_rpcs_waitq.lock);
 
 	return 0;
 }
 EXPORT_SYMBOL(obd_mod_rpc_stats_seq_show);
-/*
- * The number of modify RPCs sent in parallel is limited
+
+/* The number of modify RPCs sent in parallel is limited
  * because the server has a finite number of slots per client to
  * store request result and ensure reply reconstruction when needed.
  * On the client, this limit is stored in cl_max_mod_rpcs_in_flight
@@ -1484,34 +1484,55 @@ int obd_mod_rpc_stats_seq_show(struct client_obd *cli, struct seq_file *seq)
  * On the MDC client, to avoid a potential deadlock (see Bugzilla 3462),
  * one close request is allowed above the maximum.
  */
-static inline bool obd_mod_rpc_slot_avail_locked(struct client_obd *cli,
-						 bool close_req)
+struct mod_waiter {
+	struct client_obd *cli;
+	bool close_req;
+	wait_queue_entry_t wqe;
+};
+static int claim_mod_rpc_function(wait_queue_entry_t *wq_entry,
+				  unsigned int mode, int flags, void *key)
 {
+	struct mod_waiter *w = container_of(wq_entry, struct mod_waiter, wqe);
+	struct client_obd *cli = w->cli;
+	bool close_req = w->close_req;
 	bool avail;
+	int ret;
+
+	/* As woken_wake_function() doesn't remove us from the wait_queue,
+	 * we could get called twice for the same thread - take care.
+	 */
+	if (wq_entry->flags & WQ_FLAG_WOKEN)
+		/* Already woke this thread, don't try again */
+		return 0;
 
 	/* A slot is available if
 	 * - number of modify RPCs in flight is less than the max
 	 * - it's a close RPC and no other close request is in flight
 	 */
 	avail = cli->cl_mod_rpcs_in_flight < cli->cl_max_mod_rpcs_in_flight ||
-		(close_req && !cli->cl_close_rpcs_in_flight);
-
-	return avail;
-}
-
-static inline bool obd_mod_rpc_slot_avail(struct client_obd *cli,
-					  bool close_req)
-{
-	bool avail;
-
-	spin_lock(&cli->cl_mod_rpcs_lock);
-	avail = obd_mod_rpc_slot_avail_locked(cli, close_req);
-	spin_unlock(&cli->cl_mod_rpcs_lock);
-	return avail;
+		(close_req && cli->cl_close_rpcs_in_flight == 0);
+	if (avail) {
+		cli->cl_mod_rpcs_in_flight++;
+		if (w->close_req)
+			cli->cl_close_rpcs_in_flight++;
+		ret = woken_wake_function(wq_entry, mode, flags, key);
+	} else if (cli->cl_close_rpcs_in_flight)
+		/* No other waiter could be woken */
+		ret = -1;
+	else if (!key)
+		/* This was not a wakeup from a close completion, so there is no
+		 * point seeing if there are close waiters to be woken
+		 */
+		ret = -1;
+	else
+		/* There might be a close so we could wake, keep looking */
+		ret = 0;
+	return ret;
 }
 
 /* Get a modify RPC slot from the obd client @cli according
- * to the kind of operation @opc that is going to be sent.
+ * to the kind of operation @opc that is going to be sent
+ * and the intent @it of the operation if it applies.
  * If the maximum number of modify RPCs in flight is reached
  * the thread is put to sleep.
  * Returns the tag to be set in the request message. Tag 0
@@ -1519,51 +1540,51 @@ static inline bool obd_mod_rpc_slot_avail(struct client_obd *cli,
  */
 u16 obd_get_mod_rpc_slot(struct client_obd *cli, u32 opc)
 {
-	bool close_req = false;
+	struct mod_waiter wait = {
+		.cli = cli,
+		.close_req = (opc == MDS_CLOSE),
+	};
 	u16 i, max;
 
-	if (opc == MDS_CLOSE)
-		close_req = true;
-
-	do {
-		spin_lock(&cli->cl_mod_rpcs_lock);
-		max = cli->cl_max_mod_rpcs_in_flight;
-		if (obd_mod_rpc_slot_avail_locked(cli, close_req)) {
-			/* there is a slot available */
-			cli->cl_mod_rpcs_in_flight++;
-			if (close_req)
-				cli->cl_close_rpcs_in_flight++;
-			lprocfs_oh_tally(&cli->cl_mod_rpcs_hist,
-					 cli->cl_mod_rpcs_in_flight);
-			/* find a free tag */
-			i = find_first_zero_bit(cli->cl_mod_tag_bitmap,
-						max + 1);
-			LASSERT(i < OBD_MAX_RIF_MAX);
-			LASSERT(!test_and_set_bit(i, cli->cl_mod_tag_bitmap));
-			spin_unlock(&cli->cl_mod_rpcs_lock);
-			/* tag 0 is reserved for non-modify RPCs */
-
-			CDEBUG(D_RPCTRACE,
-			       "%s: modify RPC slot %u is allocated opc %u, max %hu\n",
-			       cli->cl_import->imp_obd->obd_name,
-			       i + 1, opc, max);
-
-			return i + 1;
-		}
-		spin_unlock(&cli->cl_mod_rpcs_lock);
-
-		CDEBUG(D_RPCTRACE, "%s: sleeping for a modify RPC slot opc %u, max %hu\n",
-		       cli->cl_import->imp_obd->obd_name, opc, max);
+	init_wait(&wait.wqe);
+	wait.wqe.func = claim_mod_rpc_function;
 
-		wait_event_idle_exclusive(cli->cl_mod_rpcs_waitq,
-					  obd_mod_rpc_slot_avail(cli,
-								 close_req));
-	} while (true);
+	spin_lock_irq(&cli->cl_mod_rpcs_waitq.lock);
+	__add_wait_queue(&cli->cl_mod_rpcs_waitq, &wait.wqe);
+	/* This wakeup will only succeed if the maximums haven't
+	 * been reached.  If that happens, WQ_FLAG_WOKEN will be cleared
+	 * and there will be no need to wait.
+	 */
+	wake_up_locked(&cli->cl_mod_rpcs_waitq);
+	if (!(wait.wqe.flags & WQ_FLAG_WOKEN)) {
+		spin_unlock_irq(&cli->cl_mod_rpcs_waitq.lock);
+		wait_woken(&wait.wqe, TASK_UNINTERRUPTIBLE,
+			   MAX_SCHEDULE_TIMEOUT);
+		spin_lock_irq(&cli->cl_mod_rpcs_waitq.lock);
+	}
+	__remove_wait_queue(&cli->cl_mod_rpcs_waitq, &wait.wqe);
+
+	max = cli->cl_max_mod_rpcs_in_flight;
+	lprocfs_oh_tally(&cli->cl_mod_rpcs_hist,
+			 cli->cl_mod_rpcs_in_flight);
+	/* find a free tag */
+	i = find_first_zero_bit(cli->cl_mod_tag_bitmap,
+				max + 1);
+	LASSERT(i < OBD_MAX_RIF_MAX);
+	LASSERT(!test_and_set_bit(i, cli->cl_mod_tag_bitmap));
+	spin_unlock_irq(&cli->cl_mod_rpcs_waitq.lock);
+	/* tag 0 is reserved for non-modify RPCs */
+
+	CDEBUG(D_RPCTRACE,
+	       "%s: modify RPC slot %u is allocated opc %u, max %hu\n",
+	       cli->cl_import->imp_obd->obd_name,
+	       i + 1, opc, max);
+
+	return i + 1;
 }
 EXPORT_SYMBOL(obd_get_mod_rpc_slot);
 
-/*
- * Put a modify RPC slot from the obd client @cli according
+/* Put a modify RPC slot from the obd client @cli according
  * to the kind of operation @opc that has been sent.
  */
 void obd_put_mod_rpc_slot(struct client_obd *cli, u32 opc, u16 tag)
@@ -1576,18 +1597,15 @@ void obd_put_mod_rpc_slot(struct client_obd *cli, u32 opc, u16 tag)
 	if (opc == MDS_CLOSE)
 		close_req = true;
 
-	spin_lock(&cli->cl_mod_rpcs_lock);
+	spin_lock_irq(&cli->cl_mod_rpcs_waitq.lock);
 	cli->cl_mod_rpcs_in_flight--;
 	if (close_req)
 		cli->cl_close_rpcs_in_flight--;
 	/* release the tag in the bitmap */
 	LASSERT(tag - 1 < OBD_MAX_RIF_MAX);
 	LASSERT(test_and_clear_bit(tag - 1, cli->cl_mod_tag_bitmap) != 0);
-	spin_unlock(&cli->cl_mod_rpcs_lock);
-	/* LU-14741 - to prevent close RPCs stuck behind normal ones */
-	if (close_req)
-		wake_up_all(&cli->cl_mod_rpcs_waitq);
-	else
-		wake_up(&cli->cl_mod_rpcs_waitq);
+	__wake_up_locked_key(&cli->cl_mod_rpcs_waitq, TASK_NORMAL,
+			     (void *)close_req);
+	spin_unlock_irq(&cli->cl_mod_rpcs_waitq.lock);
 }
 EXPORT_SYMBOL(obd_put_mod_rpc_slot);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
