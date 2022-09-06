Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 3BE4EC6FA86
	for <lustre-devel@archiver.kernel.org>; Tue,  6 Sep 2022 01:56:10 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4MM7lY56mVz1y6k;
	Mon,  5 Sep 2022 18:56:09 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4MM7lD6nksz1y2G
 for <lustre-devel@lists.lustre.org>; Mon,  5 Sep 2022 18:55:52 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id D85B8100B02F;
 Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id D0E5658999; Mon,  5 Sep 2022 21:55:39 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  5 Sep 2022 21:55:29 -0400
Message-Id: <1662429337-18737-17-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
References: <1662429337-18737-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 16/24] lnet: Use fatal NI if none other
 available
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
Cc: Chris Horn <chris.horn@hpe.com>, Serguei Smirnov <ssmirnov@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Serguei Smirnov <ssmirnov@whamcloud.com>

Allow NI in fatal state to be selected for sending if there are no
NIs in non-fatal state.

HPE-bug-id: LUS-11019
WC-bug-id: https://jira.whamcloud.com/browse/LU-14955
Lustre-commit: ff3322fd0c77a8042 ("LU-14955 lnet: Use fatal NI if none other available")
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/44746
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 22 +++++++++++++++++-----
 1 file changed, 17 insertions(+), 5 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 6ad0963..3b20a1b7 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1449,6 +1449,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	int best_healthv;
 	u32 best_sel_prio;
 	unsigned int best_dev_prio;
+	int best_ni_fatal;
 	unsigned int dev_idx = UINT_MAX;
 	bool gpu = md ? (md->md_flags & LNET_MD_FLAG_GPU) : false;
 
@@ -1470,6 +1471,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		best_dev_prio = UINT_MAX;
 		best_credits = INT_MIN;
 		best_healthv = 0;
+		best_ni_fatal = true;
 	} else {
 		best_dev_prio = lnet_dev_prio_of_md(best_ni, dev_idx);
 		shortest_distance = cfs_cpt_distance(lnet_cpt_table(), md_cpt,
@@ -1477,6 +1479,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		best_credits = atomic_read(&best_ni->ni_tx_credits);
 		best_healthv = atomic_read(&best_ni->ni_healthv);
 		best_sel_prio = best_ni->ni_sel_priority;
+		best_ni_fatal = atomic_read(&best_ni->ni_fatal_error_on);
 	}
 
 	while ((ni = lnet_get_next_ni_locked(local_net, ni))) {
@@ -1510,7 +1513,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		if (!gpu && distance < lnet_numa_range)
 			distance = lnet_numa_range;
 
-		/* * Select on health, selection policy, direct dma prio,
+		/** Select on health, selection policy, direct dma prio,
 		 * shorter distance, available credits, then round-robin.
 		 */
 		if (ni_fatal)
@@ -1518,16 +1521,24 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 
 		if (best_ni)
 			CDEBUG(D_NET,
-			       "compare ni %s [c:%d, d:%d, s:%d, p:%u, g:%u, h:%d] with best_ni %s [c:%d, d:%d, s:%d, p:%u, g:%u, h:%d]\n",
-			       libcfs_nidstr(&ni->ni_nid), ni_credits, distance,
+			       "compare ni %s [f:%s, c:%d, d:%d, s:%d, p:%u, g:%u, h:%d] with best_ni %s [f:%s, c:%d, d:%d, s:%d, p:%u, g:%u, h:%d]\n",
+			       libcfs_nidstr(&ni->ni_nid),
+			       ni_fatal ? "y" : "n", ni_credits, distance,
 			       ni->ni_seq, ni_sel_prio, ni_dev_prio, ni_healthv,
-			       (best_ni) ? libcfs_nidstr(&best_ni->ni_nid)
-			       : "not selected", best_credits, shortest_distance,
+			       (best_ni) ? libcfs_nidstr(&best_ni->ni_nid) :
+			       "not selected",
+			       best_ni_fatal ? "y" : "n", best_credits,
+			       shortest_distance,
 			       (best_ni) ? best_ni->ni_seq : 0,
 			       best_sel_prio, best_dev_prio, best_healthv);
 		else
 			goto select_ni;
 
+		if (ni_fatal && !best_ni_fatal)
+			continue;
+		else if (!ni_fatal && best_ni_fatal)
+			goto select_ni;
+
 		if (ni_healthv < best_healthv)
 			continue;
 		else if (ni_healthv > best_healthv)
@@ -1563,6 +1574,7 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		best_healthv = ni_healthv;
 		best_ni = ni;
 		best_credits = ni_credits;
+		best_ni_fatal = ni_fatal;
 	}
 
 	CDEBUG(D_NET, "selected best_ni %s\n",
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
