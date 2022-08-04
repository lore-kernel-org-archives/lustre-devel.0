Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 758F0C19F29
	for <lustre-devel@archiver.kernel.org>; Thu,  4 Aug 2022 01:40:03 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4LyryB4gRTz23M1;
	Wed,  3 Aug 2022 18:40:02 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Lyrwn3SlPz23KB
 for <lustre-devel@lists.lustre.org>; Wed,  3 Aug 2022 18:38:49 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 0DFB0100B058;
 Wed,  3 Aug 2022 21:38:24 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 0CC128D620; Wed,  3 Aug 2022 21:38:24 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  3 Aug 2022 21:38:17 -0400
Message-Id: <1659577097-19253-33-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
References: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 32/32] lustre: ldlm: Prioritize blocking
 callbacks
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

From: Patrick Farrell <pfarrell@whamcloud.com>

The current code places bl_ast lock callbacks at the end of
the global BL callback queue.  This is bad because it
causes urgent requests from the server to wait behind
non-urgent cleanup tasks to keep lru_size at the right
level.

This can lead to evictions if there is a large queue of
items in the global queue so the callback is not serviced
in a timely manner.

Put bl_ast callbacks on the priority queue so they do not
wait behind the background traffic.

Add some additional debug in this area.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15821
Lustre-commit: 2d59294d52b696125 ("LU-15821 ldlm: Prioritize blocking callbacks")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/47215
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_lockd.c | 39 +++++++++++++++++++++++++++++++++++++--
 1 file changed, 37 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_lockd.c b/fs/lustre/ldlm/ldlm_lockd.c
index 04fe92e..9f89766 100644
--- a/fs/lustre/ldlm/ldlm_lockd.c
+++ b/fs/lustre/ldlm/ldlm_lockd.c
@@ -94,6 +94,8 @@ struct ldlm_bl_pool {
 	atomic_t		blp_busy_threads;
 	int			blp_min_threads;
 	int			blp_max_threads;
+	int			blp_total_locks;
+	int			blp_total_blwis;
 };
 
 struct ldlm_bl_work_item {
@@ -399,19 +401,39 @@ static int __ldlm_bl_to_thread(struct ldlm_bl_work_item *blwi,
 			       enum ldlm_cancel_flags cancel_flags)
 {
 	struct ldlm_bl_pool *blp = ldlm_state->ldlm_bl_pool;
+	char *prio = "regular";
+	int count;
 
 	spin_lock(&blp->blp_lock);
-	if (blwi->blwi_lock && ldlm_is_discard_data(blwi->blwi_lock)) {
-		/* add LDLM_FL_DISCARD_DATA requests to the priority list */
+	/* cannot access blwi after added to list and lock is dropped */
+	count = blwi->blwi_lock ? 1 : blwi->blwi_count;
+
+	/* if the server is waiting on a lock to be cancelled (bl_ast), this is
+	 * an urgent request and should go in the priority queue so it doesn't
+	 * get stuck behind non-priority work (eg, lru size management)
+	 *
+	 * We also prioritize discard_data, which is for eviction handling
+	 */
+	if (blwi->blwi_lock &&
+	    (ldlm_is_discard_data(blwi->blwi_lock) ||
+	     ldlm_is_bl_ast(blwi->blwi_lock))) {
 		list_add_tail(&blwi->blwi_entry, &blp->blp_prio_list);
+		prio = "priority";
 	} else {
 		/* other blocking callbacks are added to the regular list */
 		list_add_tail(&blwi->blwi_entry, &blp->blp_list);
 	}
+	blp->blp_total_locks += count;
+	blp->blp_total_blwis++;
 	spin_unlock(&blp->blp_lock);
 
 	wake_up(&blp->blp_waitq);
 
+	/* unlocked read of blp values is intentional - OK for debug */
+	CDEBUG(D_DLMTRACE,
+	       "added %d/%d locks to %s blp list, %d blwis in pool\n",
+	       count, blp->blp_total_locks, prio, blp->blp_total_blwis);
+
 	/*
 	 * Can not check blwi->blwi_flags as blwi could be already freed in
 	 * LCF_ASYNC mode
@@ -772,6 +794,17 @@ static int ldlm_bl_get_work(struct ldlm_bl_pool *blp,
 	spin_unlock(&blp->blp_lock);
 	*p_blwi = blwi;
 
+	/* intentional unlocked read of blp values - OK for debug */
+	if (blwi) {
+		CDEBUG(D_DLMTRACE,
+		       "Got %d locks of %d total in blp.  (%d blwis in pool)\n",
+		       blwi->blwi_lock ? 1 : blwi->blwi_count,
+		       blp->blp_total_locks, blp->blp_total_blwis);
+	} else {
+		CDEBUG(D_DLMTRACE,
+		       "No blwi found in queue (no bl locks in queue)\n");
+	}
+
 	return (*p_blwi || *p_exp) ? 1 : 0;
 }
 
@@ -1126,6 +1159,8 @@ static int ldlm_setup(void)
 	init_waitqueue_head(&blp->blp_waitq);
 	atomic_set(&blp->blp_num_threads, 0);
 	atomic_set(&blp->blp_busy_threads, 0);
+	blp->blp_total_locks = 0;
+	blp->blp_total_blwis = 0;
 
 	if (ldlm_num_threads == 0) {
 		blp->blp_min_threads = LDLM_NTHRS_INIT;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
