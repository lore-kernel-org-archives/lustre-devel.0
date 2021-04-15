Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8ABF2C433B4
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:05:18 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3B2B861222
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:05:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B2B861222
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id C3ED12F74CD;
	Wed, 14 Apr 2021 21:04:06 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 40E2632F6D6
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:03:00 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id D46B9100F377;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id D1D006DF7E; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:39 -0400
Message-Id: <1618459361-17909-48-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 47/49] lnet: convert lpni_refcount to a kref
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

From: "Mr. NeilBrown" <neilb@suse.de>

This refcount is used exactly like a kref.  So change it to one.
kref uses refcount_t which will warn on increment-from-zero and
similar problems (which enabled with CONFIG option), so we don't
need the LASSERT calls.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12678
Lustre-commit: e520ee276800362c ("LU-12678 lnet: convert lpni_refcount to a kref")
Signed-off-by: Mr. NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/41941
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h  |  9 +++------
 include/linux/lnet/lib-types.h |  3 ++-
 net/lnet/lnet/peer.c           | 14 ++++++++------
 net/lnet/lnet/router_proc.c    |  2 +-
 4 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 8b369dd..e4dbe0e 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -351,18 +351,15 @@ void lnet_res_lh_initialize(struct lnet_res_container *rec,
 static inline void
 lnet_peer_ni_addref_locked(struct lnet_peer_ni *lp)
 {
-	LASSERT(atomic_read(&lp->lpni_refcount) > 0);
-	atomic_inc(&lp->lpni_refcount);
+	kref_get(&lp->lpni_kref);
 }
 
-void lnet_destroy_peer_ni_locked(struct lnet_peer_ni *lp);
+void lnet_destroy_peer_ni_locked(struct kref *ref);
 
 static inline void
 lnet_peer_ni_decref_locked(struct lnet_peer_ni *lp)
 {
-	LASSERT(atomic_read(&lp->lpni_refcount) > 0);
-	if (atomic_dec_and_test(&lp->lpni_refcount))
-		lnet_destroy_peer_ni_locked(lp);
+	kref_put(&lp->lpni_kref, lnet_destroy_peer_ni_locked);
 }
 
 static inline int
diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index af8f61e..ce067b3 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -42,6 +42,7 @@
 #include <linux/uio.h>
 #include <linux/types.h>
 #include <linux/completion.h>
+#include <linux/kref.h>
 
 #include <uapi/linux/lnet/lnet-types.h>
 #include <uapi/linux/lnet/lnetctl.h>
@@ -568,7 +569,7 @@ struct lnet_peer_ni {
 	/* peer's NID */
 	lnet_nid_t		 lpni_nid;
 	/* # refs */
-	atomic_t		 lpni_refcount;
+	struct kref		 lpni_kref;
 	/* health value for the peer */
 	atomic_t		 lpni_healthv;
 	/* recovery ping mdh */
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 15fcb5e..c833e34 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -127,7 +127,7 @@
 	INIT_LIST_HEAD(&lpni->lpni_on_remote_peer_ni_list);
 	INIT_LIST_HEAD(&lpni->lpni_rtr_pref_nids);
 	LNetInvalidateMDHandle(&lpni->lpni_recovery_ping_mdh);
-	atomic_set(&lpni->lpni_refcount, 1);
+	kref_init(&lpni->lpni_kref);
 	lpni->lpni_sel_priority = LNET_MAX_SELECTION_PRIORITY;
 
 	spin_lock_init(&lpni->lpni_lock);
@@ -1864,14 +1864,16 @@ struct lnet_peer_net *
 }
 
 void
-lnet_destroy_peer_ni_locked(struct lnet_peer_ni *lpni)
+lnet_destroy_peer_ni_locked(struct kref *ref)
 {
+	struct lnet_peer_ni *lpni = container_of(ref, struct lnet_peer_ni,
+						 lpni_kref);
 	struct lnet_peer_table *ptable;
 	struct lnet_peer_net *lpn;
 
 	CDEBUG(D_NET, "%p nid %s\n", lpni, libcfs_nid2str(lpni->lpni_nid));
 
-	LASSERT(atomic_read(&lpni->lpni_refcount) == 0);
+	LASSERT(kref_read(&lpni->lpni_kref) == 0);
 	LASSERT(list_empty(&lpni->lpni_txq));
 	LASSERT(lpni->lpni_txqnob == 0);
 	LASSERT(list_empty(&lpni->lpni_peer_nis));
@@ -3779,7 +3781,7 @@ void lnet_peer_discovery_stop(void)
 		aliveness = (lnet_is_peer_ni_alive(lp)) ? "up" : "down";
 
 	CDEBUG(D_WARNING, "%-24s %4d %5s %5d %5d %5d %5d %5d %ld\n",
-	       libcfs_nid2str(lp->lpni_nid), atomic_read(&lp->lpni_refcount),
+	       libcfs_nid2str(lp->lpni_nid), kref_read(&lp->lpni_kref),
 	       aliveness, lp->lpni_net->net_tunables.lct_peer_tx_credits,
 	       lp->lpni_rtrcredits, lp->lpni_minrtrcredits,
 	       lp->lpni_txcredits, lp->lpni_mintxcredits, lp->lpni_txqnob);
@@ -3837,7 +3839,7 @@ void lnet_peer_discovery_stop(void)
 					 ? "up" : "down");
 
 			*nid = lp->lpni_nid;
-			*refcount = atomic_read(&lp->lpni_refcount);
+			*refcount = kref_read(&lp->lpni_kref);
 			*ni_peer_tx_credits =
 				lp->lpni_net->net_tunables.lct_peer_tx_credits;
 			*peer_tx_credits = lp->lpni_txcredits;
@@ -3922,7 +3924,7 @@ int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk)
 			snprintf(lpni_info->cr_aliveness, LNET_MAX_STR_LEN,
 				 lnet_is_peer_ni_alive(lpni) ? "up" : "down");
 
-		lpni_info->cr_refcount = atomic_read(&lpni->lpni_refcount);
+		lpni_info->cr_refcount = kref_read(&lpni->lpni_kref);
 		lpni_info->cr_ni_peer_tx_credits = lpni->lpni_net ?
 			lpni->lpni_net->net_tunables.lct_peer_tx_credits : 0;
 		lpni_info->cr_peer_tx_credits = lpni->lpni_txcredits;
diff --git a/net/lnet/lnet/router_proc.c b/net/lnet/lnet/router_proc.c
index 25d172d..dd52a08 100644
--- a/net/lnet/lnet/router_proc.c
+++ b/net/lnet/lnet/router_proc.c
@@ -475,7 +475,7 @@ static int proc_lnet_peers(struct ctl_table *table, int write,
 
 		if (peer) {
 			lnet_nid_t nid = peer->lpni_nid;
-			int nrefs = atomic_read(&peer->lpni_refcount);
+			int nrefs = kref_read(&peer->lpni_kref);
 			time64_t lastalive = -1;
 			char *aliveness = "NA";
 			int maxcr = peer->lpni_net ?
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
