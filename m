Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.9 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNWANTED_LANGUAGE_BODY,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BDB47C43460
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:51:57 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 47AAC61396
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:51:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 47AAC61396
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id BD03E328A95;
	Mon,  5 Apr 2021 00:51:41 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 39FFB21F543
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:20 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id A55A36C7;
 Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id A08B090AA9; Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:50:37 -0400
Message-Id: <1617583870-32029-9-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
References: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 08/41] lnet: foundation patch for selection
 mod
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
Cc: Serguei Smirnov <ssmirnov@whamcloud.com>,
 Amir Shehata <ashehata@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Amir Shehata <ashehata@whamcloud.com>

Add the priority and preferred NIDs fields in the lnet_ni,
lnet_net, lnet_peer_net and lnet_peer_ni. Switched
the implementation of the preferred NIDs list to list_head
instead of array, because the code is more straight forward.
There is more memory overhead due to list_head, but these lists
are expected to be small, so I chose code simplicity over memory.

WC-bug-id: https://jira.whamcloud.com/browse/LU-9121
Lustre-commit: 51b2c0f75f727f0 ("LU-9121 lnet: foundation patch for selection mod")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/34350
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h |  24 +++++++-
 net/lnet/lnet/config.c         |   4 ++
 net/lnet/lnet/peer.c           | 134 ++++++++++++++++++++++-------------------
 3 files changed, 100 insertions(+), 62 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index a8bd5a5..187e1f3 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -58,6 +58,7 @@
  * All local and peer NIs created have their health default to this value.
  */
 #define LNET_MAX_HEALTH_VALUE 1000
+#define LNET_MAX_SELECTION_PRIORITY UINT_MAX
 
 /* forward refs */
 struct lnet_libmd;
@@ -364,6 +365,9 @@ struct lnet_net {
 	/* cumulative CPTs of all NIs in this net */
 	u32			*net_cpts;
 
+	/* relative net selection priority */
+	u32			net_sel_priority;
+
 	/* network tunables */
 	struct lnet_ioctl_config_lnd_cmn_tunables net_tunables;
 
@@ -388,6 +392,9 @@ struct lnet_net {
 
 	/* protects access to net_last_alive */
 	spinlock_t		net_lock;
+
+	/* list of router nids preferred for this network */
+	struct list_head	net_rtr_pref_nids;
 };
 
 struct lnet_ni {
@@ -466,6 +473,9 @@ struct lnet_ni {
 	 */
 	atomic_t		ni_fatal_error_on;
 
+	/* the relative selection priority of this NI */
+	u32			ni_sel_priority;
+
 	/*
 	 * equivalent interfaces to use
 	 * This is an array because socklnd bonding can still be configured
@@ -498,6 +508,11 @@ struct lnet_ping_buffer {
 #define LNET_PING_INFO_TO_BUFFER(PINFO)	\
 	container_of((PINFO), struct lnet_ping_buffer, pb_info)
 
+struct lnet_nid_list {
+	struct list_head nl_list;
+	lnet_nid_t nl_nid;
+};
+
 struct lnet_peer_ni {
 	/* chain on lpn_peer_nis */
 	struct list_head	 lpni_peer_nis;
@@ -557,8 +572,12 @@ struct lnet_peer_ni {
 	/* preferred local nids: if only one, use lpni_pref.nid */
 	union lpni_pref {
 		lnet_nid_t	 nid;
-		lnet_nid_t	*nids;
+		struct list_head nids;
 	} lpni_pref;
+	/* list of router nids preferred for this peer NI */
+	struct list_head	lpni_rtr_pref_nids;
+	/* The relative selection priority of this peer NI */
+	u32			lpni_sel_priority;
 	/* number of preferred NIDs in lnpi_pref_nids */
 	u32			 lpni_pref_nnids;
 };
@@ -752,6 +771,9 @@ struct lnet_peer_net {
 	/* selection sequence number */
 	u32			lpn_seq;
 
+	/* relative peer net selection priority */
+	u32			lpn_sel_priority;
+
 	/* reference count */
 	atomic_t		lpn_refcount;
 };
diff --git a/net/lnet/lnet/config.c b/net/lnet/lnet/config.c
index b078bc8..10a7fe9 100644
--- a/net/lnet/lnet/config.c
+++ b/net/lnet/lnet/config.c
@@ -366,11 +366,14 @@ struct lnet_net *
 	INIT_LIST_HEAD(&net->net_ni_list);
 	INIT_LIST_HEAD(&net->net_ni_added);
 	INIT_LIST_HEAD(&net->net_ni_zombie);
+	INIT_LIST_HEAD(&net->net_rtr_pref_nids);
 	spin_lock_init(&net->net_lock);
 
 	net->net_id = net_id;
 	net->net_last_alive = ktime_get_real_seconds();
 
+	net->net_sel_priority = LNET_MAX_SELECTION_PRIORITY;
+
 	/* initialize global paramters to undefiend */
 	net->net_tunables.lct_peer_timeout = -1;
 	net->net_tunables.lct_max_tx_credits = -1;
@@ -470,6 +473,7 @@ struct lnet_net *
 		ni->ni_net_ns = get_net(&init_net);
 
 	ni->ni_state = LNET_NI_STATE_INIT;
+	ni->ni_sel_priority = LNET_MAX_SELECTION_PRIORITY;
 	list_add_tail(&ni->ni_netlist, &net->net_ni_added);
 
 	/*
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 70df37a..60e6b51 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -124,8 +124,10 @@
 	INIT_LIST_HEAD(&lpni->lpni_peer_nis);
 	INIT_LIST_HEAD(&lpni->lpni_recovery);
 	INIT_LIST_HEAD(&lpni->lpni_on_remote_peer_ni_list);
+	INIT_LIST_HEAD(&lpni->lpni_rtr_pref_nids);
 	LNetInvalidateMDHandle(&lpni->lpni_recovery_ping_mdh);
 	atomic_set(&lpni->lpni_refcount, 1);
+	lpni->lpni_sel_priority = LNET_MAX_SELECTION_PRIORITY;
 
 	spin_lock_init(&lpni->lpni_lock);
 
@@ -175,6 +177,7 @@
 	INIT_LIST_HEAD(&lpn->lpn_peer_nets);
 	INIT_LIST_HEAD(&lpn->lpn_peer_nis);
 	lpn->lpn_net_id = net_id;
+	lpn->lpn_sel_priority = LNET_MAX_SELECTION_PRIORITY;
 
 	CDEBUG(D_NET, "%p net %s\n", lpn, libcfs_net2str(lpn->lpn_net_id));
 
@@ -899,14 +902,14 @@ struct lnet_peer_ni *
 bool
 lnet_peer_is_pref_nid_locked(struct lnet_peer_ni *lpni, lnet_nid_t nid)
 {
-	int i;
+	struct lnet_nid_list *ne;
 
 	if (lpni->lpni_pref_nnids == 0)
 		return false;
 	if (lpni->lpni_pref_nnids == 1)
 		return lpni->lpni_pref.nid == nid;
-	for (i = 0; i < lpni->lpni_pref_nnids; i++) {
-		if (lpni->lpni_pref.nids[i] == nid)
+	list_for_each_entry(ne, &lpni->lpni_pref.nids, nl_list) {
+		if (ne->nl_nid == nid)
 			return true;
 	}
 	return false;
@@ -978,11 +981,10 @@ struct lnet_peer_ni *
 int
 lnet_peer_add_pref_nid(struct lnet_peer_ni *lpni, lnet_nid_t nid)
 {
-	lnet_nid_t *nids = NULL;
-	lnet_nid_t *oldnids = NULL;
 	struct lnet_peer *lp = lpni->lpni_peer_net->lpn_peer;
-	int size;
-	int i;
+	struct lnet_nid_list *ne1 = NULL;
+	struct lnet_nid_list *ne2 = NULL;
+	lnet_nid_t tmp_nid = LNET_NID_ANY;
 	int rc = 0;
 
 	if (nid == LNET_NID_ANY) {
@@ -996,29 +998,46 @@ struct lnet_peer_ni *
 	}
 
 	/* A non-MR node may have only one preferred NI per peer_ni */
-	if (lpni->lpni_pref_nnids > 0) {
-		if (!(lp->lp_state & LNET_PEER_MULTI_RAIL)) {
-			rc = -EPERM;
-			goto out;
-		}
+	if (lpni->lpni_pref_nnids > 0 &&
+	    !(lp->lp_state & LNET_PEER_MULTI_RAIL)) {
+		rc = -EPERM;
+		goto out;
 	}
 
+	/* add the new preferred nid to the list of preferred nids */
 	if (lpni->lpni_pref_nnids != 0) {
-		size = sizeof(*nids) * (lpni->lpni_pref_nnids + 1);
-		nids = kzalloc_cpt(size, GFP_KERNEL, lpni->lpni_cpt);
-		if (!nids) {
+		size_t alloc_size = sizeof(*ne1);
+
+		if (lpni->lpni_pref_nnids == 1) {
+			tmp_nid = lpni->lpni_pref.nid;
+			INIT_LIST_HEAD(&lpni->lpni_pref.nids);
+		}
+
+		list_for_each_entry(ne1, &lpni->lpni_pref.nids, nl_list) {
+			if (ne1->nl_nid == nid) {
+				rc = -EEXIST;
+				goto out;
+			}
+		}
+
+		ne1 = kzalloc_cpt(alloc_size, GFP_KERNEL, lpni->lpni_cpt);
+		if (!ne1) {
 			rc = -ENOMEM;
 			goto out;
 		}
-		for (i = 0; i < lpni->lpni_pref_nnids; i++) {
-			if (lpni->lpni_pref.nids[i] == nid) {
-				kfree(nids);
-				rc = -EEXIST;
+
+		/* move the originally stored nid to the list */
+		if (lpni->lpni_pref_nnids == 1) {
+			ne2 = kzalloc_cpt(alloc_size, GFP_KERNEL,
+					  lpni->lpni_cpt);
+			if (!ne2) {
+				rc = -ENOMEM;
 				goto out;
 			}
-			nids[i] = lpni->lpni_pref.nids[i];
+			INIT_LIST_HEAD(&ne2->nl_list);
+			ne2->nl_nid = tmp_nid;
 		}
-		nids[i] = nid;
+		ne1->nl_nid = nid;
 	}
 
 	lnet_net_lock(LNET_LOCK_EX);
@@ -1026,15 +1045,15 @@ struct lnet_peer_ni *
 	if (lpni->lpni_pref_nnids == 0) {
 		lpni->lpni_pref.nid = nid;
 	} else {
-		oldnids = lpni->lpni_pref.nids;
-		lpni->lpni_pref.nids = nids;
+		if (ne2)
+			list_add_tail(&ne2->nl_list, &lpni->lpni_pref.nids);
+		list_add_tail(&ne1->nl_list, &lpni->lpni_pref.nids);
 	}
 	lpni->lpni_pref_nnids++;
 	lpni->lpni_state &= ~LNET_PEER_NI_NON_MR_PREF;
 	spin_unlock(&lpni->lpni_lock);
 	lnet_net_unlock(LNET_LOCK_EX);
 
-	kfree(oldnids);
 out:
 	if (rc == -EEXIST && (lpni->lpni_state & LNET_PEER_NI_NON_MR_PREF)) {
 		spin_lock(&lpni->lpni_lock);
@@ -1049,11 +1068,8 @@ struct lnet_peer_ni *
 int
 lnet_peer_del_pref_nid(struct lnet_peer_ni *lpni, lnet_nid_t nid)
 {
-	lnet_nid_t *nids = NULL;
-	lnet_nid_t *oldnids = NULL;
 	struct lnet_peer *lp = lpni->lpni_peer_net->lpn_peer;
-	int size;
-	int i, j;
+	struct lnet_nid_list *ne = NULL;
 	int rc = 0;
 
 	if (lpni->lpni_pref_nnids == 0) {
@@ -1066,52 +1082,41 @@ struct lnet_peer_ni *
 			rc = -ENOENT;
 			goto out;
 		}
-	} else if (lpni->lpni_pref_nnids == 2) {
-		if (lpni->lpni_pref.nids[0] != nid &&
-		    lpni->lpni_pref.nids[1] != nid) {
-			rc = -ENOENT;
-			goto out;
-		}
 	} else {
-		size = sizeof(*nids) * (lpni->lpni_pref_nnids - 1);
-		nids = kzalloc_cpt(size, GFP_KERNEL, lpni->lpni_cpt);
-		if (!nids) {
-			rc = -ENOMEM;
-			goto out;
-		}
-		for (i = 0, j = 0; i < lpni->lpni_pref_nnids; i++) {
-			if (lpni->lpni_pref.nids[i] != nid)
-				continue;
-			nids[j++] = lpni->lpni_pref.nids[i];
-		}
-		/* Check if we actually removed a nid. */
-		if (j == lpni->lpni_pref_nnids) {
-			kfree(nids);
-			rc = -ENOENT;
-			goto out;
+		list_for_each_entry(ne, &lpni->lpni_pref.nids, nl_list) {
+			if (ne->nl_nid == nid)
+				goto remove_nid_entry;
 		}
+		rc = -ENOENT;
+		ne = NULL;
+		goto out;
 	}
 
+remove_nid_entry:
 	lnet_net_lock(LNET_LOCK_EX);
 	spin_lock(&lpni->lpni_lock);
 	if (lpni->lpni_pref_nnids == 1) {
 		lpni->lpni_pref.nid = LNET_NID_ANY;
-	} else if (lpni->lpni_pref_nnids == 2) {
-		oldnids = lpni->lpni_pref.nids;
-		if (oldnids[0] == nid)
-			lpni->lpni_pref.nid = oldnids[1];
-		else
-			lpni->lpni_pref.nid = oldnids[2];
 	} else {
-		oldnids = lpni->lpni_pref.nids;
-		lpni->lpni_pref.nids = nids;
+		list_del_init(&ne->nl_list);
+		if (lpni->lpni_pref_nnids == 2) {
+			struct lnet_nid_list *ne, *tmp;
+
+			list_for_each_entry_safe(ne, tmp,
+						 &lpni->lpni_pref.nids,
+						 nl_list) {
+				lpni->lpni_pref.nid = ne->nl_nid;
+				list_del_init(&ne->nl_list);
+				kfree(ne);
+			}
+		}
 	}
 	lpni->lpni_pref_nnids--;
 	lpni->lpni_state &= ~LNET_PEER_NI_NON_MR_PREF;
 	spin_unlock(&lpni->lpni_lock);
 	lnet_net_unlock(LNET_LOCK_EX);
 
-	kfree(oldnids);
+	kfree(ne);
 out:
 	CDEBUG(D_NET, "peer %s nid %s: %d\n",
 	       libcfs_nid2str(lp->lp_primary_nid), libcfs_nid2str(nid), rc);
@@ -1707,8 +1712,15 @@ struct lnet_peer_net *
 		spin_unlock(&ptable->pt_zombie_lock);
 	}
 
-	if (lpni->lpni_pref_nnids > 1)
-		kfree(lpni->lpni_pref.nids);
+	if (lpni->lpni_pref_nnids > 1) {
+		struct lnet_nid_list *ne, *tmp;
+
+		list_for_each_entry_safe(ne, tmp, &lpni->lpni_pref.nids,
+					 nl_list) {
+			list_del_init(&ne->nl_list);
+			kfree(ne);
+		}
+	}
 	kfree(lpni);
 
 	if (lpn)
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
