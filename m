Return-Path: <SRS0=6+cL=NO=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF120C4338F
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Aug 2021 02:28:31 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 721EF611F2
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Aug 2021 02:28:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 721EF611F2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 015CE21CB69;
	Sun, 22 Aug 2021 19:28:12 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id CF52B21CAB2
 for <lustre-devel@lists.lustre.org>; Sun, 22 Aug 2021 19:27:53 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 34B0F100BB01;
 Sun, 22 Aug 2021 22:27:48 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 2A30AB6C7F; Sun, 22 Aug 2021 22:27:48 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 22 Aug 2021 22:27:41 -0400
Message-Id: <1629685666-4533-11-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1629685666-4533-1-git-send-email-jsimmons@infradead.org>
References: <1629685666-4533-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 10/15] lnet: Provide kernel API for adding
 peers
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
Cc: Chris Horn <chris.horn@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Chris Horn <chris.horn@hpe.com>

Implement LNetAddPeer() API to allow other kernel modules to add
peers to LNet.

Peers created via this API are not marked as having been configured
by DLC. As such, they can be overwritten by discovery.

HPE-bug-id: LUS-9293
WC-bug-id: https://jira.whamcloud.com/browse/LU-14661
Lustre-commit: ac201366ad5700ed ("LU-14661 lnet: Provide kernel API for adding peers")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/43509
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/api.h      |  1 +
 include/linux/lnet/lib-lnet.h |  2 +-
 net/lnet/lnet/api-ni.c        |  2 +-
 net/lnet/lnet/peer.c          | 60 ++++++++++++++++++++++++++++++++++++++++---
 4 files changed, 59 insertions(+), 6 deletions(-)

diff --git a/include/linux/lnet/api.h b/include/linux/lnet/api.h
index 891c4a6..d32c7c1 100644
--- a/include/linux/lnet/api.h
+++ b/include/linux/lnet/api.h
@@ -164,6 +164,7 @@ int LNetGet(lnet_nid_t self,
 int LNetCtl(unsigned int cmd, void *arg);
 void LNetDebugPeer(struct lnet_process_id id);
 int LNetGetPeerDiscoveryStatus(void);
+int LNetAddPeer(lnet_nid_t *nids, u32 num_nids);
 
 /** @} lnet_misc */
 
diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 760c093..37489ae 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -854,7 +854,7 @@ struct lnet_peer_net *lnet_peer_get_net_locked(struct lnet_peer *peer,
 void lnet_peer_clr_pref_rtrs(struct lnet_peer_ni *lpni);
 int lnet_peer_add_pref_rtr(struct lnet_peer_ni *lpni, lnet_nid_t nid);
 int lnet_peer_ni_set_non_mr_pref_nid(struct lnet_peer_ni *lpni, lnet_nid_t nid);
-int lnet_add_peer_ni(lnet_nid_t key_nid, lnet_nid_t nid, bool mr);
+int lnet_add_peer_ni(lnet_nid_t key_nid, lnet_nid_t nid, bool mr, bool temp);
 int lnet_del_peer_ni(lnet_nid_t key_nid, lnet_nid_t nid);
 int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk);
 int lnet_get_peer_ni_info(u32 peer_index, u64 *nid,
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index bb5fb56..41d2d26 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -4015,7 +4015,7 @@ u32 lnet_get_dlc_seq_locked(void)
 		mutex_lock(&the_lnet.ln_api_mutex);
 		rc = lnet_add_peer_ni(cfg->prcfg_prim_nid,
 				      cfg->prcfg_cfg_nid,
-				      cfg->prcfg_mr);
+				      cfg->prcfg_mr, false);
 		mutex_unlock(&the_lnet.ln_api_mutex);
 		return rc;
 	}
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 224f4e2..c2f5d8b 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -1320,6 +1320,51 @@ struct lnet_peer_ni *
 	return rc;
 }
 
+int
+LNetAddPeer(lnet_nid_t *nids, u32 num_nids)
+{
+	lnet_nid_t pnid = 0;
+	bool mr;
+	int i, rc;
+
+	if (!nids || num_nids < 1)
+		return -EINVAL;
+
+	rc = LNetNIInit(LNET_PID_ANY);
+	if (rc < 0)
+		return rc;
+
+	mutex_lock(&the_lnet.ln_api_mutex);
+
+	mr = lnet_peer_discovery_disabled == 0;
+
+	rc = 0;
+	for (i = 0; i < num_nids; i++) {
+		if (nids[i] == LNET_NID_LO_0)
+			continue;
+
+		if (!pnid) {
+			pnid = nids[i];
+			rc = lnet_add_peer_ni(pnid, LNET_NID_ANY, mr, true);
+		} else if (lnet_peer_discovery_disabled) {
+			rc = lnet_add_peer_ni(nids[i], LNET_NID_ANY, mr, true);
+		} else {
+			rc = lnet_add_peer_ni(pnid, nids[i], mr, true);
+		}
+
+		if (rc && rc != -EEXIST)
+			goto unlock;
+	}
+
+unlock:
+	mutex_unlock(&the_lnet.ln_api_mutex);
+
+	LNetNIFini();
+
+	return rc == -EEXIST ? 0 : rc;
+}
+EXPORT_SYMBOL(LNetAddPeer);
+
 lnet_nid_t
 LNetPrimaryNID(lnet_nid_t nid)
 {
@@ -1538,6 +1583,11 @@ struct lnet_peer_net *
 			else if ((lp->lp_state ^ flags) & LNET_PEER_MULTI_RAIL)
 				rc = -EPERM;
 			goto out;
+		} else if (!(flags & LNET_PEER_CONFIGURED)) {
+			if (lp->lp_primary_nid == nid) {
+				rc = -EEXIST;
+				goto out;
+			}
 		}
 		/* Delete and recreate as a configured peer. */
 		lnet_peer_del(lp);
@@ -1777,17 +1827,19 @@ struct lnet_peer_net *
  * being created/modified/deleted by a different thread.
  */
 int
-lnet_add_peer_ni(lnet_nid_t prim_nid, lnet_nid_t nid, bool mr)
+lnet_add_peer_ni(lnet_nid_t prim_nid, lnet_nid_t nid, bool mr, bool temp)
 {
 	struct lnet_peer *lp = NULL;
 	struct lnet_peer_ni *lpni;
-	unsigned int flags;
+	unsigned int flags = 0;
 
 	/* The prim_nid must always be specified */
 	if (prim_nid == LNET_NID_ANY)
 		return -EINVAL;
 
-	flags = LNET_PEER_CONFIGURED;
+	if (!temp)
+		flags = LNET_PEER_CONFIGURED;
+
 	if (mr)
 		flags |= LNET_PEER_MULTI_RAIL;
 
@@ -1806,7 +1858,7 @@ struct lnet_peer_net *
 	lp = lpni->lpni_peer_net->lpn_peer;
 
 	/* Peer must have been configured. */
-	if (!(lp->lp_state & LNET_PEER_CONFIGURED)) {
+	if (!temp && !(lp->lp_state & LNET_PEER_CONFIGURED)) {
 		CDEBUG(D_NET, "peer %s was not configured\n",
 		       libcfs_nid2str(prim_nid));
 		return -ENOENT;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
