From: James Simmons <jsimmons@infradead.org>
Date: Sat, 28 Jan 2017 19:05:16 -0500
Subject: [lustre-devel] [PATCH 48/60] staging: lustre: ksocklnd: ignore
	timedout TX on closing connection
In-Reply-To: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1485648328-2141-49-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Liang Zhen <liang.zhen@intel.com>, James Simmons <jsimmons@infradead.org>

From: Liang Zhen <liang.zhen@intel.com>

ksocklnd reaper thread always tries to close the connection for the
first timedout zero-copy TX. This is wrong if this connection is
already being closed, because the reaper will see the same TX again
and again and cannot find out other timedout zero-copy TXs and close
connections for them.

Signed-off-by: Liang Zhen <liang.zhen@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8867
Reviewed-on: https://review.whamcloud.com/23973
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index df4f55e..b7043e2 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -2456,6 +2456,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 
 	list_for_each_entry(peer, peers, ksnp_list) {
 		unsigned long deadline = 0;
+		struct ksock_tx *tx_stale;
 		int resid = 0;
 		int n = 0;
 
@@ -2503,6 +2504,7 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 		if (list_empty(&peer->ksnp_zc_req_list))
 			continue;
 
+		tx_stale = NULL;
 		spin_lock(&peer->ksnp_lock);
 		list_for_each_entry(tx, &peer->ksnp_zc_req_list, tx_zc_list) {
 			if (!cfs_time_aftereq(cfs_time_current(),
@@ -2511,26 +2513,26 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 			/* ignore the TX if connection is being closed */
 			if (tx->tx_conn->ksnc_closing)
 				continue;
+			if (!tx_stale)
+				tx_stale = tx;
 			n++;
 		}
 
-		if (!n) {
+		if (!tx_stale) {
 			spin_unlock(&peer->ksnp_lock);
 			continue;
 		}
 
-		tx = list_entry(peer->ksnp_zc_req_list.next,
-				struct ksock_tx, tx_zc_list);
-		deadline = tx->tx_deadline;
-		resid = tx->tx_resid;
-		conn = tx->tx_conn;
+		deadline = tx_stale->tx_deadline;
+		resid = tx_stale->tx_resid;
+		conn = tx_stale->tx_conn;
 		ksocknal_conn_addref(conn);
 
 		spin_unlock(&peer->ksnp_lock);
 		read_unlock(&ksocknal_data.ksnd_global_lock);
 
 		CERROR("Total %d stale ZC_REQs for peer %s detected; the oldest(%p) timed out %ld secs ago, resid: %d, wmem: %d\n",
-		       n, libcfs_nid2str(peer->ksnp_id.nid), tx,
+		       n, libcfs_nid2str(peer->ksnp_id.nid), tx_stale,
 		       cfs_duration_sec(cfs_time_current() - deadline),
 		       resid, conn->ksnc_sock->sk->sk_wmem_queued);
 
-- 
1.8.3.1
