From: James Simmons <jsimmons@infradead.org>
Date: Wed, 15 Jul 2020 16:45:05 -0400
Subject: [lustre-devel] [PATCH 24/37] lnet: o2iblnd: Use
 list_for_each_entry_safe
In-Reply-To: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
References: <1594845918-29027-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1594845918-29027-25-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Mr NeilBrown <neilb@suse.de>

Several loops use list_for_each_safe(), then call
list_entry() as first step.
These can be merged using list_for_each_entry_safe().

WC-bug-id: https://jira.whamcloud.com/browse/LU-12678
Lustre-commit: e5574f72f2fd9 ("LU-12678 o2iblnd: Use list_for_each_entry_safe")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39126
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c    | 26 ++++++++++----------------
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c |  7 ++-----
 2 files changed, 12 insertions(+), 21 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index 6c7659c..c6a077b 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -454,18 +454,16 @@ static int kiblnd_get_peer_info(struct lnet_ni *ni, int index,
 
 static void kiblnd_del_peer_locked(struct kib_peer_ni *peer_ni)
 {
-	struct list_head *ctmp;
-	struct list_head *cnxt;
+	struct kib_conn *cnxt;
 	struct kib_conn *conn;
 
 	if (list_empty(&peer_ni->ibp_conns)) {
 		kiblnd_unlink_peer_locked(peer_ni);
 	} else {
-		list_for_each_safe(ctmp, cnxt, &peer_ni->ibp_conns) {
-			conn = list_entry(ctmp, struct kib_conn, ibc_list);
-
+		list_for_each_entry_safe(conn, cnxt, &peer_ni->ibp_conns,
+					 ibc_list)
 			kiblnd_close_conn_locked(conn, 0);
-		}
+
 		/* NB closing peer_ni's last conn unlinked it. */
 	}
 	/*
@@ -952,13 +950,11 @@ void kiblnd_destroy_conn(struct kib_conn *conn)
 int kiblnd_close_peer_conns_locked(struct kib_peer_ni *peer_ni, int why)
 {
 	struct kib_conn *conn;
-	struct list_head *ctmp;
-	struct list_head *cnxt;
+	struct kib_conn *cnxt;
 	int count = 0;
 
-	list_for_each_safe(ctmp, cnxt, &peer_ni->ibp_conns) {
-		conn = list_entry(ctmp, struct kib_conn, ibc_list);
-
+	list_for_each_entry_safe(conn, cnxt, &peer_ni->ibp_conns,
+				 ibc_list) {
 		CDEBUG(D_NET, "Closing conn -> %s, version: %x, reason: %d\n",
 		       libcfs_nid2str(peer_ni->ibp_nid),
 		       conn->ibc_version, why);
@@ -974,13 +970,11 @@ int kiblnd_close_stale_conns_locked(struct kib_peer_ni *peer_ni,
 				    int version, u64 incarnation)
 {
 	struct kib_conn *conn;
-	struct list_head *ctmp;
-	struct list_head *cnxt;
+	struct kib_conn *cnxt;
 	int count = 0;
 
-	list_for_each_safe(ctmp, cnxt, &peer_ni->ibp_conns) {
-		conn = list_entry(ctmp, struct kib_conn, ibc_list);
-
+	list_for_each_entry_safe(conn, cnxt, &peer_ni->ibp_conns,
+				 ibc_list) {
 		if (conn->ibc_version == version &&
 		    conn->ibc_incarnation == incarnation)
 			continue;
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 2c670a33..ba2f46f 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1982,15 +1982,12 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 kiblnd_abort_txs(struct kib_conn *conn, struct list_head *txs)
 {
 	LIST_HEAD(zombies);
-	struct list_head *tmp;
-	struct list_head *nxt;
+	struct kib_tx *nxt;
 	struct kib_tx *tx;
 
 	spin_lock(&conn->ibc_lock);
 
-	list_for_each_safe(tmp, nxt, txs) {
-		tx = list_entry(tmp, struct kib_tx, tx_list);
-
+	list_for_each_entry_safe(tx, nxt, txs, tx_list) {
 		if (txs == &conn->ibc_active_txs) {
 			LASSERT(!tx->tx_queued);
 			LASSERT(tx->tx_waiting || tx->tx_sending);
-- 
1.8.3.1
