Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 54B5AC02199
	for <lustre-devel@archiver.kernel.org>; Sat,  8 Feb 2025 00:44:01 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YqWzg2tRpz20tl;
	Fri, 07 Feb 2025 16:33:51 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YqWw85cFGz1xnj
 for <lustre-devel@lists.lustre.org>; Fri, 07 Feb 2025 16:30:48 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm3-e204-208.ccs.ornl.gov [160.91.203.26])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 30CB6188AC7;
 Fri,  7 Feb 2025 19:30:33 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 2E4E9106BE19; Fri,  7 Feb 2025 19:30:33 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri,  7 Feb 2025 19:30:26 -0500
Message-ID: <20250208003027.180076-21-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250208003027.180076-1-jsimmons@infradead.org>
References: <20250208003027.180076-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 20/21] lnet: fix locking multiple NIDs of the
 MR peer
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
Cc: Frank Sehr <fsehr@whamcloud.com>, Chris Horn <chris.horn@hpe.com>,
 Serguei Smirnov <ssmirnov@whamcloud.com>,
 Cyril Bordage <cbordage@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Serguei Smirnov <ssmirnov@whamcloud.com>

If Lustre identifies the same peer with multiple NIDs,
as a result of peer discovery it is possible that
the discovered peer is found to contain a NID which is locked
as primary by a different existing peer record.
In this case it is safe to merge the peer records,
but the NID which got locked the earliest should be
kept as primary.

This allows for the first of the two locked NIDs
to stay primary as intended for the purpose of communicating
with Lustre even if peer discovery succeeded
using a different NID of MR peer.

Fixes: cede069b76 ("lnet: Lock primary NID logic")
WC-bug-id: https://jira.whamcloud.com/browse/LU-16709
Lustre-commit: 3b7a02ee4d656b7b3 ("LU-16709 lnet: fix locking multiple NIDs of the MR peer")
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50530
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h         |  3 ++
 include/uapi/linux/lnet/libcfs_ioctl.h |  3 +-
 net/lnet/lnet/api-ni.c                 | 24 +++++++++++
 net/lnet/lnet/peer.c                   | 59 ++++++++++++++++++++------
 4 files changed, 75 insertions(+), 14 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 0de7654e3a67..c17c55ff88e0 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -987,6 +987,9 @@ struct lnet_peer {
 	 * nets/NIs
 	 */
 	u32			lp_send_seq;
+
+	/* timestamp (ns) of primary nid lock */
+	u64			lp_prim_lock_ts;
 };
 
 /*
diff --git a/include/uapi/linux/lnet/libcfs_ioctl.h b/include/uapi/linux/lnet/libcfs_ioctl.h
index 98b61b1f1292..2a067cdafc48 100644
--- a/include/uapi/linux/lnet/libcfs_ioctl.h
+++ b/include/uapi/linux/lnet/libcfs_ioctl.h
@@ -156,6 +156,7 @@ struct libcfs_ioctl_data {
 #define IOC_LIBCFS_GET_CONST_UDSP_INFO	_IOWR(IOC_LIBCFS_TYPE, 109, IOCTL_CONFIG_SIZE)
 #define IOC_LIBCFS_RESET_LNET_STATS	_IOWR(IOC_LIBCFS_TYPE, 110, IOCTL_CONFIG_SIZE)
 #define IOC_LIBCFS_SET_CONNS_PER_PEER	_IOWR(IOC_LIBCFS_TYPE, 111, IOCTL_CONFIG_SIZE)
-#define IOC_LIBCFS_MAX_NR				       111
+#define IOC_LIBCFS_SET_PEER		_IOWR(IOC_LIBCFS_TYPE, 112, IOCTL_CONFIG_SIZE)
+#define IOC_LIBCFS_MAX_NR				       112
 
 #endif /* __LIBCFS_IOCTL_H__ */
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 6884c5d3ad86..870ae4312d78 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -4384,6 +4384,30 @@ LNetCtl(unsigned int cmd, void *arg)
 		return 0;
 	}
 
+	case IOC_LIBCFS_SET_PEER: {
+		struct lnet_ioctl_peer_cfg *cfg = arg;
+		struct lnet_peer *lp;
+
+		if (cfg->prcfg_hdr.ioc_len < sizeof(*cfg))
+			return -EINVAL;
+
+		mutex_lock(&the_lnet.ln_api_mutex);
+		lnet_nid4_to_nid(cfg->prcfg_prim_nid, &nid);
+		lp = lnet_find_peer(&nid);
+		if (!lp) {
+			mutex_unlock(&the_lnet.ln_api_mutex);
+			return -ENOENT;
+		}
+		spin_lock(&lp->lp_lock);
+		lp->lp_state = cfg->prcfg_state;
+		spin_unlock(&lp->lp_lock);
+		lnet_peer_decref_locked(lp);
+		mutex_unlock(&the_lnet.ln_api_mutex);
+		CDEBUG(D_NET, "Set peer %s state to %u\n",
+		       libcfs_nid2str(cfg->prcfg_prim_nid), cfg->prcfg_state);
+		return 0;
+	}
+
 	case IOC_LIBCFS_SET_CONNS_PER_PEER: {
 		struct lnet_ioctl_reset_conns_per_peer_cfg *cfg = arg;
 		int value;
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 916864100bee..0aa4a77ab0d4 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -1429,8 +1429,10 @@ void LNetPrimaryNID(struct lnet_nid *nid)
 	 */
 again:
 	spin_lock(&lp->lp_lock);
-	if (!(lp->lp_state & LNET_PEER_LOCK_PRIMARY) && lock_prim_nid)
+	if (!(lp->lp_state & LNET_PEER_LOCK_PRIMARY) && lock_prim_nid) {
 		lp->lp_state |= LNET_PEER_LOCK_PRIMARY;
+		lp->lp_prim_lock_ts = ktime_get_ns();
+	}
 
 	/* DD disabled, nothing to do */
 	if (lnet_peer_discovery_disabled) {
@@ -1577,8 +1579,10 @@ lnet_peer_attach_peer_ni(struct lnet_peer *lp,
 			lnet_peer_clr_non_mr_pref_nids(lp);
 		}
 	}
-	if (flags & LNET_PEER_LOCK_PRIMARY)
+	if (flags & LNET_PEER_LOCK_PRIMARY) {
 		lp->lp_state |= LNET_PEER_LOCK_PRIMARY;
+		lp->lp_prim_lock_ts = ktime_get_ns();
+	}
 	spin_unlock(&lp->lp_lock);
 
 	lp->lp_nnis++;
@@ -1762,24 +1766,53 @@ lnet_peer_add_nid(struct lnet_peer *lp, struct lnet_nid *nid,
 			struct lnet_peer *lp2 =
 				lpni->lpni_peer_net->lpn_peer;
 			int rtr_refcount = lp2->lp_rtr_refcount;
-
-			/* If the new peer that this NID belongs to is
-			 * a primary NID for another peer which we're
-			 * suppose to preserve the Primary for then we
-			 * don't want to mess with it. But the
-			 * configuration is wrong at this point, so we
-			 * should flag both of these peers as in a bad
+			unsigned int peer2_state;
+			u64 peer2_prim_lock_ts;
+
+			/* If there's another peer that this NID belongs to
+			 * and the primary NID for that peer is locked,
+			 * then, unless it is the only NID, we don't want
+			 * to mess with it.
+			 * But the configuration is wrong at this point,
+			 * so we should flag both of these peers as in a bad
 			 * state
 			 */
-			if (lp2->lp_state & LNET_PEER_LOCK_PRIMARY) {
+			spin_lock(&lp2->lp_lock);
+			if (lp2->lp_state & LNET_PEER_LOCK_PRIMARY &&
+			    lp2->lp_nnis > 1) {
+				lp2->lp_state |= LNET_PEER_BAD_CONFIG;
+				spin_unlock(&lp2->lp_lock);
 				spin_lock(&lp->lp_lock);
 				lp->lp_state |= LNET_PEER_BAD_CONFIG;
 				spin_unlock(&lp->lp_lock);
-				spin_lock(&lp2->lp_lock);
-				lp2->lp_state |= LNET_PEER_BAD_CONFIG;
-				spin_unlock(&lp2->lp_lock);
+				CERROR("Peer %s NID %s is already locked with peer %s\n",
+				       libcfs_nidstr(&lp->lp_primary_nid),
+				       libcfs_nidstr(nid),
+				       libcfs_nidstr(&lp2->lp_primary_nid));
 				goto out_free_lpni;
 			}
+			peer2_state = lp2->lp_state;
+			peer2_prim_lock_ts = lp2->lp_prim_lock_ts;
+			spin_unlock(&lp2->lp_lock);
+
+			/* NID which got locked the earliest should be
+			 * kept as primary. In case if the peers were
+			 * created by Lustre, this allows the
+			 * first listed NID to stay primary as intended
+			 * for the purpose of communicating with Lustre
+			 * even if peer discovery succeeded using
+			 * a different NID of MR peer.
+			 */
+			spin_lock(&lp->lp_lock);
+			if (peer2_state & LNET_PEER_LOCK_PRIMARY &&
+			    ((lp->lp_state & LNET_PEER_LOCK_PRIMARY &&
+			    peer2_prim_lock_ts < lp->lp_prim_lock_ts) ||
+			     !(lp->lp_state & LNET_PEER_LOCK_PRIMARY))) {
+				lp->lp_prim_lock_ts = peer2_prim_lock_ts;
+				lp->lp_primary_nid = *nid;
+				lp->lp_state |= LNET_PEER_LOCK_PRIMARY;
+			}
+			spin_unlock(&lp->lp_lock);
 			/* if we're trying to delete a router it means
 			 * we're moving this peer NI to a new peer so must
 			 * transfer router properties to the new peer
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
