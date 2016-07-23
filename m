From: Oleg Drokin <green@linuxhacker.ru>
Date: Sat, 23 Jul 2016 02:37:02 -0400
Subject: [lustre-devel] [PATCH 05/15] ksocknal_lib_send_iov(): sendmsg
	doesn't bugger iovec...
In-Reply-To: <1469255832-746785-1-git-send-email-green@linuxhacker.ru>
References: <1469255832-746785-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1469255832-746785-6-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Al Viro <viro@zeniv.linux.org.uk>

From: Al Viro <viro@zeniv.linux.org.uk>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 .../lustre/lnet/klnds/socklnd/socklnd_lib.c        | 38 ++++++----------------
 1 file changed, 10 insertions(+), 28 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
index 77bb29ff..8eb4a68 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
@@ -73,9 +73,9 @@ ksocknal_lib_zc_capable(struct ksock_conn *conn)
 int
 ksocknal_lib_send_iov(struct ksock_conn *conn, struct ksock_tx *tx)
 {
+	struct msghdr msg = {.msg_flags = MSG_DONTWAIT};
 	struct socket *sock = conn->ksnc_sock;
-	int nob;
-	int rc;
+	int nob, i;
 
 	if (*ksocknal_tunables.ksnd_enable_csum	&& /* checksum enabled */
 	    conn->ksnc_proto == &ksocknal_protocol_v2x && /* V2.x connection  */
@@ -83,34 +83,16 @@ ksocknal_lib_send_iov(struct ksock_conn *conn, struct ksock_tx *tx)
 	    !tx->tx_msg.ksm_csum)		     /* not checksummed  */
 		ksocknal_lib_csum_tx(tx);
 
-	/*
-	 * NB we can't trust socket ops to either consume our iovs
-	 * or leave them alone.
-	 */
-	{
-#if SOCKNAL_SINGLE_FRAG_TX
-		struct kvec scratch;
-		struct kvec *scratchiov = &scratch;
-		unsigned int niov = 1;
-#else
-		struct kvec *scratchiov = conn->ksnc_scheduler->kss_scratch_iov;
-		unsigned int niov = tx->tx_niov;
-#endif
-		struct msghdr msg = {.msg_flags = MSG_DONTWAIT};
-		int i;
-
-		for (nob = i = 0; i < niov; i++) {
-			scratchiov[i] = tx->tx_iov[i];
-			nob += scratchiov[i].iov_len;
-		}
+	for (nob = i = 0; i < tx->tx_niov; i++)
+		nob += tx->tx_iov[i].iov_len;
 
-		if (!list_empty(&conn->ksnc_tx_queue) ||
-		    nob < tx->tx_resid)
-			msg.msg_flags |= MSG_MORE;
+	if (!list_empty(&conn->ksnc_tx_queue) ||
+	    nob < tx->tx_resid)
+		msg.msg_flags |= MSG_MORE;
 
-		rc = kernel_sendmsg(sock, &msg, scratchiov, niov, nob);
-	}
-	return rc;
+	iov_iter_kvec(&msg.msg_iter, WRITE | ITER_KVEC,
+		      tx->tx_iov, tx->tx_niov, nob);
+	return sock_sendmsg(sock, &msg);
 }
 
 int
-- 
2.7.4
