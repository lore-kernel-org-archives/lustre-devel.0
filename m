Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EAF78C433B4
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:53:05 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id AB6F360FF0
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:53:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB6F360FF0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 604E9328C6D;
	Mon,  5 Apr 2021 00:52:29 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4FC5332C4E2
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:29 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 3925CECA;
 Sun,  4 Apr 2021 20:51:17 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 379D990AAC; Sun,  4 Apr 2021 20:51:17 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:51:10 -0400
Message-Id: <1617583870-32029-42-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
References: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 41/41] lnet: o2iblnd: convert peers hash
 table to hashtable.h
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

Using a hashtable.h hashtable, rather than bespoke code, has several
advantages:

  - the table is comprised of hlist_head, rather than list_head, so
    it consumes less memory (though we need to make it a little bigger
    as it must be a power-of-2)
  - there are existing macros for easily walking the whole table
  - it uses a "real" hash function rather than "mod a prime number".

In some ways, rhashtable might be even better, but it can change the
ordering of objects in the table are arbitrary moments, and that could
hurt the user-space API.  It also does not support the partitioned
walking that ksocknal_check_peer_timeouts() depends on.

Note that new peers are inserted at the top of a hash chain, rather
than appended at the end.  I don't think that should be a problem.

Also various white-space cleanups etc.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12678
Lustre-commit: c66668387a11492e ("LU-12678 o2iblnd: convert peers hash table to hashtable.h")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39303
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c    | 101 +++++++++++++++---------------------
 net/lnet/klnds/o2iblnd/o2iblnd.h    |  19 ++-----
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c |  12 ++---
 3 files changed, 52 insertions(+), 80 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index f6865ad3..c8cebf6 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -339,7 +339,7 @@ int kiblnd_create_peer(struct lnet_ni *ni, struct kib_peer_ni **peerp,
 	peer_ni->ibp_queue_depth_mod = 0;	/* try to use the default */
 	atomic_set(&peer_ni->ibp_refcount, 1);  /* 1 ref for caller */
 
-	INIT_LIST_HEAD(&peer_ni->ibp_list);
+	INIT_HLIST_NODE(&peer_ni->ibp_list);
 	INIT_LIST_HEAD(&peer_ni->ibp_conns);
 	INIT_LIST_HEAD(&peer_ni->ibp_tx_queue);
 
@@ -385,10 +385,10 @@ struct kib_peer_ni *kiblnd_find_peer_locked(struct lnet_ni *ni, lnet_nid_t nid)
 	 * the caller is responsible for accounting the additional reference
 	 * that this creates
 	 */
-	struct list_head *peer_list = kiblnd_nid2peerlist(nid);
 	struct kib_peer_ni *peer_ni;
 
-	list_for_each_entry(peer_ni, peer_list, ibp_list) {
+	hash_for_each_possible(kiblnd_data.kib_peers, peer_ni,
+			       ibp_list, nid) {
 		LASSERT(!kiblnd_peer_idle(peer_ni));
 
 		/*
@@ -415,7 +415,7 @@ void kiblnd_unlink_peer_locked(struct kib_peer_ni *peer_ni)
 	LASSERT(list_empty(&peer_ni->ibp_conns));
 
 	LASSERT(kiblnd_peer_active(peer_ni));
-	list_del_init(&peer_ni->ibp_list);
+	hlist_del_init(&peer_ni->ibp_list);
 	/* lose peerlist's ref */
 	kiblnd_peer_decref(peer_ni);
 }
@@ -429,24 +429,20 @@ static int kiblnd_get_peer_info(struct lnet_ni *ni, int index,
 
 	read_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
 
-	for (i = 0; i < kiblnd_data.kib_peer_hash_size; i++) {
-		list_for_each_entry(peer_ni, &kiblnd_data.kib_peers[i],
-				    ibp_list) {
-			LASSERT(!kiblnd_peer_idle(peer_ni));
+	hash_for_each(kiblnd_data.kib_peers, i, peer_ni, ibp_list) {
+		LASSERT(!kiblnd_peer_idle(peer_ni));
 
-			if (peer_ni->ibp_ni != ni)
-				continue;
+		if (peer_ni->ibp_ni != ni)
+			continue;
 
-			if (index-- > 0)
-				continue;
+		if (index-- > 0)
+			continue;
 
-			*nidp = peer_ni->ibp_nid;
-			*count = atomic_read(&peer_ni->ibp_refcount);
+		*nidp = peer_ni->ibp_nid;
+		*count = atomic_read(&peer_ni->ibp_refcount);
 
-			read_unlock_irqrestore(&kiblnd_data.kib_global_lock,
-					       flags);
-			return 0;
-		}
+		read_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
+		return 0;
 	}
 
 	read_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
@@ -476,7 +472,7 @@ static void kiblnd_del_peer_locked(struct kib_peer_ni *peer_ni)
 static int kiblnd_del_peer(struct lnet_ni *ni, lnet_nid_t nid)
 {
 	LIST_HEAD(zombies);
-	struct kib_peer_ni *pnxt;
+	struct hlist_node *pnxt;
 	struct kib_peer_ni *peer_ni;
 	int lo;
 	int hi;
@@ -487,16 +483,16 @@ static int kiblnd_del_peer(struct lnet_ni *ni, lnet_nid_t nid)
 	write_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
 
 	if (nid != LNET_NID_ANY) {
-		lo = kiblnd_nid2peerlist(nid) - kiblnd_data.kib_peers;
-		hi = kiblnd_nid2peerlist(nid) - kiblnd_data.kib_peers;
+		lo = hash_min(nid, HASH_BITS(kiblnd_data.kib_peers));
+		hi = lo;
 	} else {
 		lo = 0;
-		hi = kiblnd_data.kib_peer_hash_size - 1;
+		hi = HASH_SIZE(kiblnd_data.kib_peers) - 1;
 	}
 
 	for (i = lo; i <= hi; i++) {
-		list_for_each_entry_safe(peer_ni, pnxt,
-					 &kiblnd_data.kib_peers[i], ibp_list) {
+		hlist_for_each_entry_safe(peer_ni, pnxt,
+					  &kiblnd_data.kib_peers[i], ibp_list) {
 			LASSERT(!kiblnd_peer_idle(peer_ni));
 
 			if (peer_ni->ibp_ni != ni)
@@ -533,25 +529,21 @@ static struct kib_conn *kiblnd_get_conn_by_idx(struct lnet_ni *ni, int index)
 
 	read_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
 
-	for (i = 0; i < kiblnd_data.kib_peer_hash_size; i++) {
-		list_for_each_entry(peer_ni, &kiblnd_data.kib_peers[i],
-				    ibp_list) {
-			LASSERT(!kiblnd_peer_idle(peer_ni));
+	hash_for_each(kiblnd_data.kib_peers, i, peer_ni, ibp_list) {
+		LASSERT(!kiblnd_peer_idle(peer_ni));
 
-			if (peer_ni->ibp_ni != ni)
-				continue;
+		if (peer_ni->ibp_ni != ni)
+			continue;
 
-			list_for_each_entry(conn, &peer_ni->ibp_conns,
-					    ibc_list) {
-				if (index-- > 0)
-					continue;
+		list_for_each_entry(conn, &peer_ni->ibp_conns,
+				    ibc_list) {
+			if (index-- > 0)
+				continue;
 
-				kiblnd_conn_addref(conn);
-				read_unlock_irqrestore(
-					&kiblnd_data.kib_global_lock,
-					flags);
-				return conn;
-			}
+			kiblnd_conn_addref(conn);
+			read_unlock_irqrestore(&kiblnd_data.kib_global_lock,
+					       flags);
+			return conn;
 		}
 	}
 
@@ -1014,7 +1006,7 @@ int kiblnd_close_stale_conns_locked(struct kib_peer_ni *peer_ni,
 static int kiblnd_close_matching_conns(struct lnet_ni *ni, lnet_nid_t nid)
 {
 	struct kib_peer_ni *peer_ni;
-	struct kib_peer_ni *pnxt;
+	struct hlist_node *pnxt;
 	int lo;
 	int hi;
 	int i;
@@ -1024,16 +1016,16 @@ static int kiblnd_close_matching_conns(struct lnet_ni *ni, lnet_nid_t nid)
 	write_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
 
 	if (nid != LNET_NID_ANY) {
-		lo = kiblnd_nid2peerlist(nid) - kiblnd_data.kib_peers;
-		hi = kiblnd_nid2peerlist(nid) - kiblnd_data.kib_peers;
+		lo = hash_min(nid, HASH_BITS(kiblnd_data.kib_peers));
+		hi = lo;
 	} else {
 		lo = 0;
-		hi = kiblnd_data.kib_peer_hash_size - 1;
+		hi = HASH_SIZE(kiblnd_data.kib_peers) - 1;
 	}
 
 	for (i = lo; i <= hi; i++) {
-		list_for_each_entry_safe(peer_ni, pnxt,
-					 &kiblnd_data.kib_peers[i], ibp_list) {
+		hlist_for_each_entry_safe(peer_ni, pnxt,
+					  &kiblnd_data.kib_peers[i], ibp_list) {
 			LASSERT(!kiblnd_peer_idle(peer_ni));
 
 			if (peer_ni->ibp_ni != ni)
@@ -2499,6 +2491,7 @@ void kiblnd_destroy_dev(struct kib_dev *dev)
 static void kiblnd_base_shutdown(void)
 {
 	struct kib_sched_info *sched;
+	struct kib_peer_ni *peer_ni;
 	int i;
 
 	LASSERT(list_empty(&kiblnd_data.kib_devs));
@@ -2509,9 +2502,8 @@ static void kiblnd_base_shutdown(void)
 
 	case IBLND_INIT_ALL:
 	case IBLND_INIT_DATA:
-		LASSERT(kiblnd_data.kib_peers);
-		for (i = 0; i < kiblnd_data.kib_peer_hash_size; i++)
-			LASSERT(list_empty(&kiblnd_data.kib_peers[i]));
+		hash_for_each(kiblnd_data.kib_peers, i, peer_ni, ibp_list)
+			LASSERT(0);
 		LASSERT(list_empty(&kiblnd_data.kib_connd_zombies));
 		LASSERT(list_empty(&kiblnd_data.kib_connd_conns));
 		LASSERT(list_empty(&kiblnd_data.kib_reconn_list));
@@ -2541,8 +2533,6 @@ static void kiblnd_base_shutdown(void)
 		break;
 	}
 
-	kvfree(kiblnd_data.kib_peers);
-
 	if (kiblnd_data.kib_scheds)
 		cfs_percpt_free(kiblnd_data.kib_scheds);
 
@@ -2628,14 +2618,7 @@ static int kiblnd_base_startup(struct net *ns)
 	INIT_LIST_HEAD(&kiblnd_data.kib_devs);
 	INIT_LIST_HEAD(&kiblnd_data.kib_failed_devs);
 
-	kiblnd_data.kib_peer_hash_size = IBLND_PEER_HASH_SIZE;
-	kiblnd_data.kib_peers = kvmalloc_array(kiblnd_data.kib_peer_hash_size,
-					       sizeof(struct list_head),
-					       GFP_KERNEL);
-	if (!kiblnd_data.kib_peers)
-		goto failed;
-	for (i = 0; i < kiblnd_data.kib_peer_hash_size; i++)
-		INIT_LIST_HEAD(&kiblnd_data.kib_peers[i]);
+	hash_init(kiblnd_data.kib_peers);
 
 	spin_lock_init(&kiblnd_data.kib_connd_lock);
 	INIT_LIST_HEAD(&kiblnd_data.kib_connd_conns);
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index 8db03bd..a5a66ee 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -66,7 +66,7 @@
 #include <linux/lnet/lib-lnet.h>
 #include "o2iblnd-idl.h"
 
-#define IBLND_PEER_HASH_SIZE		101	/* # peer_ni lists */
+#define IBLND_PEER_HASH_BITS		7	/* log2 of # peer_ni lists */
 
 #define IBLND_N_SCHED			2
 #define IBLND_N_SCHED_HIGH		4
@@ -342,9 +342,7 @@ struct kib_data {
 	/* stabilize net/dev/peer_ni/conn ops */
 	rwlock_t		kib_global_lock;
 	/* hash table of all my known peers */
-	struct list_head       *kib_peers;
-	/* size of kib_peers */
-	int			kib_peer_hash_size;
+	DECLARE_HASHTABLE(kib_peers, IBLND_PEER_HASH_BITS);
 	/* the connd task (serialisation assertions) */
 	void		       *kib_connd;
 	/* connections to setup/teardown */
@@ -488,7 +486,7 @@ struct kib_conn {
 #define IBLND_CONN_DISCONNECTED		5	/* disconnected */
 
 struct kib_peer_ni {
-	struct list_head	ibp_list;	/* stash on global peer_ni list */
+	struct hlist_node	ibp_list;	/* on peer_ni hash chain */
 	lnet_nid_t		ibp_nid;	/* who's on the other end(s) */
 	struct lnet_ni		*ibp_ni;	/* LNet interface */
 	struct list_head	ibp_conns;	/* all active connections */
@@ -642,20 +640,11 @@ static inline int kiblnd_timeout(void)
 		list_empty(&peer_ni->ibp_conns);
 }
 
-static inline struct list_head *
-kiblnd_nid2peerlist(lnet_nid_t nid)
-{
-	unsigned int hash =
-		((unsigned int)nid) % kiblnd_data.kib_peer_hash_size;
-
-	return &kiblnd_data.kib_peers[hash];
-}
-
 static inline int
 kiblnd_peer_active(struct kib_peer_ni *peer_ni)
 {
 	/* Am I in the peer_ni hash table? */
-	return !list_empty(&peer_ni->ibp_list);
+	return !hlist_unhashed(&peer_ni->ibp_list);
 }
 
 static inline struct kib_conn *
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 9f9afce..2ebda4e 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1494,7 +1494,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		list_add_tail(&tx->tx_list, &peer_ni->ibp_tx_queue);
 
 	kiblnd_peer_addref(peer_ni);
-	list_add_tail(&peer_ni->ibp_list, kiblnd_nid2peerlist(nid));
+	hash_add(kiblnd_data.kib_peers, &peer_ni->ibp_list, nid);
 
 	write_unlock_irqrestore(g_lock, flags);
 
@@ -2533,7 +2533,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		LASSERT(!net->ibn_shutdown);
 
 		kiblnd_peer_addref(peer_ni);
-		list_add_tail(&peer_ni->ibp_list, kiblnd_nid2peerlist(nid));
+		hash_add(kiblnd_data.kib_peers, &peer_ni->ibp_list, nid);
 
 		write_unlock_irqrestore(g_lock, flags);
 	}
@@ -3257,7 +3257,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	LIST_HEAD(closes);
 	LIST_HEAD(checksends);
 	LIST_HEAD(timedout_txs);
-	struct list_head *peers = &kiblnd_data.kib_peers[idx];
+	struct hlist_head *peers = &kiblnd_data.kib_peers[idx];
 	struct kib_peer_ni *peer_ni;
 	struct kib_tx *tx_tmp, *tx;
 	struct kib_conn *conn;
@@ -3270,7 +3270,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	 */
 	write_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
 
-	list_for_each_entry(peer_ni, peers, ibp_list) {
+	hlist_for_each_entry(peer_ni, peers, ibp_list) {
 		/* Check tx_deadline */
 		list_for_each_entry_safe(tx, tx_tmp, &peer_ni->ibp_tx_queue, tx_list) {
 			if (ktime_compare(ktime_get(), tx->tx_deadline) >= 0) {
@@ -3499,7 +3499,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		if (timeout <= 0) {
 			const int n = 4;
 			const int p = 1;
-			int chunk = kiblnd_data.kib_peer_hash_size;
+			int chunk = HASH_SIZE(kiblnd_data.kib_peers);
 			unsigned int lnd_timeout;
 
 			spin_unlock_irqrestore(lock, flags);
@@ -3524,7 +3524,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 			for (i = 0; i < chunk; i++) {
 				kiblnd_check_conns(peer_index);
 				peer_index = (peer_index + 1) %
-					     kiblnd_data.kib_peer_hash_size;
+					HASH_SIZE(kiblnd_data.kib_peers);
 			}
 
 			deadline += p * HZ;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
