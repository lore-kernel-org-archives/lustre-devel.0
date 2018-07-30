From: NeilBrown <neilb@suse.com>
Date: Mon, 30 Jul 2018 13:37:41 +1000
Subject: [lustre-devel] [PATCH 14/22] Revert: Staging: lustre: Iterate list
 using list_for_each_entry
In-Reply-To: <153292153459.13840.17465048403476297915.stgit@noble>
References: <153292153459.13840.17465048403476297915.stgit@noble>
Message-ID: <153292186117.13840.9041811734708835901.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This reverts (what is left of) 5a2ca43fa54f561c252c2ceb986daa49e258ab13

These loops really want to remove everything, and using a
  while(!list_empty())
loop makes this more obvious.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 9cf1f64e3d76..bda67d49597d 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -2106,7 +2106,6 @@ kiblnd_connreq_done(struct kib_conn *conn, int status)
 {
 	struct kib_peer *peer = conn->ibc_peer;
 	struct kib_tx *tx;
-	struct kib_tx *tmp;
 	struct list_head txs;
 	unsigned long flags;
 	int active;
@@ -2197,7 +2196,8 @@ kiblnd_connreq_done(struct kib_conn *conn, int status)
 	 * scheduled.  We won't be using round robin on this first batch.
 	 */
 	spin_lock(&conn->ibc_lock);
-	list_for_each_entry_safe(tx, tmp, &txs, tx_list) {
+	while (!list_empty(&txs)) {
+		tx = list_first_entry(&txs, struct kib_tx, tx_list);
 		list_del(&tx->tx_list);
 
 		kiblnd_queue_tx_locked(tx, conn);
@@ -3185,7 +3185,6 @@ kiblnd_check_conns(int idx)
 	struct list_head *ptmp;
 	struct kib_peer *peer;
 	struct kib_conn *conn;
-	struct kib_conn *tmp;
 	struct list_head *ctmp;
 	unsigned long flags;
 
@@ -3241,7 +3240,8 @@ kiblnd_check_conns(int idx)
 	 * connection. We can only be sure RDMA activity
 	 * has ceased once the QP has been modified.
 	 */
-	list_for_each_entry_safe(conn, tmp, &closes, ibc_connd_list) {
+	while (!list_empty(&closes)) {
+		conn = list_first_entry(&closes, struct kib_conn, ibc_connd_list);
 		list_del(&conn->ibc_connd_list);
 		kiblnd_close_conn(conn, -ETIMEDOUT);
 		kiblnd_conn_decref(conn);
