From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:09:34 -0500
Subject: [lustre-devel] [PATCH 106/622] lnet: lnd: conditionally set health
 status
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-107-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <ashehata@whamcloud.com>

For specific error scenarios a more accurate health status is set
per transmit. These shouldn't be overwritten in
kiblnd_txlist_done()

WC-bug-id: https://jira.whamcloud.com/browse/LU-11271
Lustre-commit: cf3cc2c72e6e ("LU-11271 lnd: conditionally set health status")
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33042
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Sonia Sharma <sharmaso@whamcloud.com>
Reviewed-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 5680f2a..68ab7d5 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -110,7 +110,8 @@ static int kiblnd_init_rdma(struct kib_conn *conn, struct kib_tx *tx, int type,
 		/* complete now */
 		tx->tx_waiting = 0;
 		tx->tx_status = status;
-		tx->tx_hstatus = hstatus;
+		if (hstatus != LNET_MSG_STATUS_OK)
+			tx->tx_hstatus = hstatus;
 		kiblnd_tx_done(tx);
 	}
 }
@@ -2108,9 +2109,11 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	spin_unlock(&conn->ibc_lock);
 
 	/* aborting transmits occurs when finalizing the connection.
-	 * The connection is finalized on error
+	 * The connection is finalized on error.
+	 * Passing LNET_MSG_STATUS_OK to txlist_done() will not
+	 * override the value already set in tx->tx_hstatus above.
 	 */
-	kiblnd_txlist_done(&zombies, -ECONNABORTED, -1);
+	kiblnd_txlist_done(&zombies, -ECONNABORTED, LNET_MSG_STATUS_OK);
 }
 
 static void
-- 
1.8.3.1
