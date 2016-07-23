From: Oleg Drokin <green@linuxhacker.ru>
Date: Sat, 23 Jul 2016 02:37:03 -0400
Subject: [lustre-devel] [PATCH 06/15] ksocknal_lib_send_kiov(): sendmsg
	doesn't bugger iovec...
In-Reply-To: <1469255832-746785-1-git-send-email-green@linuxhacker.ru>
References: <1469255832-746785-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1469255832-746785-7-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Al Viro <viro@zeniv.linux.org.uk>

From: Al Viro <viro@zeniv.linux.org.uk>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 .../lustre/lnet/klnds/socklnd/socklnd_lib.c        | 29 ++++------------------
 1 file changed, 5 insertions(+), 24 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
index 8eb4a68..6c95e98 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
@@ -106,10 +106,6 @@ ksocknal_lib_send_kiov(struct ksock_conn *conn, struct ksock_tx *tx)
 	/* Not NOOP message */
 	LASSERT(tx->tx_lnetmsg);
 
-	/*
-	 * NB we can't trust socket ops to either consume our iovs
-	 * or leave them alone.
-	 */
 	if (tx->tx_msg.ksm_zc_cookies[0]) {
 		/* Zero copy is enabled */
 		struct sock *sk = sock->sk;
@@ -132,34 +128,19 @@ ksocknal_lib_send_kiov(struct ksock_conn *conn, struct ksock_tx *tx)
 			rc = tcp_sendpage(sk, page, offset, fragsize, msgflg);
 		}
 	} else {
-#if SOCKNAL_SINGLE_FRAG_TX || !SOCKNAL_RISK_KMAP_DEADLOCK
-		struct kvec scratch;
-		struct kvec *scratchiov = &scratch;
-		unsigned int niov = 1;
-#else
-#ifdef CONFIG_HIGHMEM
-#warning "XXX risk of kmap deadlock on multiple frags..."
-#endif
-		struct kvec *scratchiov = conn->ksnc_scheduler->kss_scratch_iov;
-		unsigned int niov = tx->tx_nkiov;
-#endif
 		struct msghdr msg = {.msg_flags = MSG_DONTWAIT};
 		int i;
 
-		for (nob = i = 0; i < niov; i++) {
-			scratchiov[i].iov_base = kmap(kiov[i].bv_page) +
-						 kiov[i].bv_offset;
-			nob += scratchiov[i].iov_len = kiov[i].bv_len;
-		}
+		for (nob = i = 0; i < tx->tx_nkiov; i++)
+			nob += kiov[i].bv_len;
 
 		if (!list_empty(&conn->ksnc_tx_queue) ||
 		    nob < tx->tx_resid)
 			msg.msg_flags |= MSG_MORE;
 
-		rc = kernel_sendmsg(sock, &msg, (struct kvec *)scratchiov, niov, nob);
-
-		for (i = 0; i < niov; i++)
-			kunmap(kiov[i].bv_page);
+		iov_iter_bvec(&msg.msg_iter, WRITE | ITER_BVEC,
+			      kiov, tx->tx_nkiov, nob);
+		rc = sock_sendmsg(sock, &msg);
 	}
 	return rc;
 }
-- 
2.7.4
