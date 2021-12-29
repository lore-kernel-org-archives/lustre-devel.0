Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 829BCC433F5
	for <lustre-devel@archiver.kernel.org>; Wed, 29 Dec 2021 14:52:10 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 7E47D3AD39B;
	Wed, 29 Dec 2021 06:52:05 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 87D7F3AD51C
 for <lustre-devel@lists.lustre.org>; Wed, 29 Dec 2021 06:51:33 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id A40B21006F16;
 Wed, 29 Dec 2021 09:51:28 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id A31F1D9E6D; Wed, 29 Dec 2021 09:51:28 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed, 29 Dec 2021 09:51:26 -0500
Message-Id: <1640789487-22279-13-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1640789487-22279-1-git-send-email-jsimmons@infradead.org>
References: <1640789487-22279-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 12/13] lnet: o2iblnd: convert ibp_refcount to
 a kref
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

This refcount is used exactly like a kref.  So change it to one.
kref uses refcount_t which will warn on increment-from-zero and
similar problems (which enabled with CONFIG option), so we don't
need the LASSERT calls.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12678
Lustre-commit: 2968a40a163aa1b0f ("LU-12678 o2iblnd: convert ibp_refcount to a kref")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/45685
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c | 11 ++++++-----
 net/lnet/klnds/o2iblnd/o2iblnd.h | 35 +++++++++++++++++------------------
 2 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index 9cdc12a..7d28acd 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -337,7 +337,7 @@ int kiblnd_create_peer(struct lnet_ni *ni, struct kib_peer_ni **peerp,
 	peer_ni->ibp_max_frags = IBLND_MAX_RDMA_FRAGS;
 	peer_ni->ibp_queue_depth = ni->ni_net->net_tunables.lct_peer_tx_credits;
 	peer_ni->ibp_queue_depth_mod = 0;	/* try to use the default */
-	atomic_set(&peer_ni->ibp_refcount, 1);  /* 1 ref for caller */
+	kref_init(&peer_ni->ibp_kref);
 
 	INIT_HLIST_NODE(&peer_ni->ibp_list);
 	INIT_LIST_HEAD(&peer_ni->ibp_conns);
@@ -357,12 +357,13 @@ int kiblnd_create_peer(struct lnet_ni *ni, struct kib_peer_ni **peerp,
 	return 0;
 }
 
-void kiblnd_destroy_peer(struct kib_peer_ni *peer_ni)
+void kiblnd_destroy_peer(struct kref *kref)
 {
+	struct kib_peer_ni *peer_ni = container_of(kref, struct kib_peer_ni,
+						   ibp_kref);
 	struct kib_net *net = peer_ni->ibp_ni->ni_data;
 
 	LASSERT(net);
-	LASSERT(!atomic_read(&peer_ni->ibp_refcount));
 	LASSERT(!kiblnd_peer_active(peer_ni));
 	LASSERT(kiblnd_peer_idle(peer_ni));
 	LASSERT(list_empty(&peer_ni->ibp_tx_queue));
@@ -403,7 +404,7 @@ struct kib_peer_ni *kiblnd_find_peer_locked(struct lnet_ni *ni, lnet_nid_t nid)
 
 		CDEBUG(D_NET, "got peer_ni [%p] -> %s (%d) version: %x\n",
 		       peer_ni, libcfs_nid2str(nid),
-		       atomic_read(&peer_ni->ibp_refcount),
+		       kref_read(&peer_ni->ibp_kref),
 		       peer_ni->ibp_version);
 		return peer_ni;
 	}
@@ -439,7 +440,7 @@ static int kiblnd_get_peer_info(struct lnet_ni *ni, int index,
 			continue;
 
 		*nidp = peer_ni->ibp_nid;
-		*count = atomic_read(&peer_ni->ibp_refcount);
+		*count = kref_read(&peer_ni->ibp_kref);
 
 		read_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
 		return 0;
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index 21f8981..4fb651e 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -499,7 +499,7 @@ struct kib_peer_ni {
 	/* when (in seconds) I was last alive */
 	time64_t		ibp_last_alive;
 	/* # users */
-	atomic_t		ibp_refcount;
+	struct kref		ibp_kref;
 	/* version of peer_ni */
 	u16			ibp_version;
 	/* current passive connection attempts */
@@ -607,23 +607,23 @@ static inline int kiblnd_timeout(void)
 	}								\
 } while (0)
 
-#define kiblnd_peer_addref(peer_ni)					\
-do {									\
-	CDEBUG(D_NET, "peer_ni[%p] -> %s (%d)++\n",			\
-	       (peer_ni), libcfs_nid2str((peer_ni)->ibp_nid),		\
-	       atomic_read(&(peer_ni)->ibp_refcount));			\
-	atomic_inc(&(peer_ni)->ibp_refcount);				\
-} while (0)
+void kiblnd_destroy_peer(struct kref *kref);
 
-#define kiblnd_peer_decref(peer_ni)					\
-do {									\
-	CDEBUG(D_NET, "peer_ni[%p] -> %s (%d)--\n",			\
-	       (peer_ni), libcfs_nid2str((peer_ni)->ibp_nid),		\
-	       atomic_read(&(peer_ni)->ibp_refcount));			\
-	LASSERT_ATOMIC_POS(&(peer_ni)->ibp_refcount);			\
-	if (atomic_dec_and_test(&(peer_ni)->ibp_refcount))		\
-		kiblnd_destroy_peer(peer_ni);				\
-} while (0)
+static inline void kiblnd_peer_addref(struct kib_peer_ni *peer_ni)
+{
+	CDEBUG(D_NET, "peer_ni[%p] -> %s (%d)++\n",
+	       peer_ni, libcfs_nid2str(peer_ni->ibp_nid),
+	       kref_read(&peer_ni->ibp_kref));
+	kref_get(&(peer_ni)->ibp_kref);
+}
+
+static inline void kiblnd_peer_decref(struct kib_peer_ni *peer_ni)
+{
+	CDEBUG(D_NET, "peer_ni[%p] -> %s (%d)--\n",
+	       peer_ni, libcfs_nid2str(peer_ni->ibp_nid),
+	       kref_read(&peer_ni->ibp_kref));
+	kref_put(&peer_ni->ibp_kref, kiblnd_destroy_peer);
+}
 
 static inline bool
 kiblnd_peer_connecting(struct kib_peer_ni *peer_ni)
@@ -929,7 +929,6 @@ int kiblnd_cm_callback(struct rdma_cm_id *cmid,
 int kiblnd_dev_failover(struct kib_dev *dev, struct net *ns);
 int kiblnd_create_peer(struct lnet_ni *ni, struct kib_peer_ni **peerp,
 		       lnet_nid_t nid);
-void kiblnd_destroy_peer(struct kib_peer_ni *peer_ni);
 bool kiblnd_reconnect_peer(struct kib_peer_ni *peer_ni);
 void kiblnd_destroy_dev(struct kib_dev *dev);
 void kiblnd_unlink_peer_locked(struct kib_peer_ni *peer_ni);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
