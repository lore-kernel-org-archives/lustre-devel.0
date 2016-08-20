From: Oleg Drokin <green@linuxhacker.ru>
Date: Sat, 20 Aug 2016 17:34:18 -0400
Subject: [lustre-devel] [PATCH 01/13] ksocknal_lib_recv_iov(): recvmsg
	doesn't bugger iovec anymore...
In-Reply-To: <1471728870-518753-1-git-send-email-green@linuxhacker.ru>
References: <1471728870-518753-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1471728870-518753-2-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Al Viro <viro@zeniv.linux.org.uk>, Oleg Drokin <green@linuxhacker.ru>

From: Al Viro <viro@zeniv.linux.org.uk>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../lustre/lnet/klnds/socklnd/socklnd_lib.c        | 22 +++++-----------------
 1 file changed, 5 insertions(+), 17 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
index fe7b9f9..77bb29ff 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib.c
@@ -201,14 +201,7 @@ ksocknal_lib_eager_ack(struct ksock_conn *conn)
 int
 ksocknal_lib_recv_iov(struct ksock_conn *conn)
 {
-#if SOCKNAL_SINGLE_FRAG_RX
-	struct kvec scratch;
-	struct kvec *scratchiov = &scratch;
-	unsigned int niov = 1;
-#else
-	struct kvec *scratchiov = conn->ksnc_scheduler->kss_scratch_iov;
 	unsigned int niov = conn->ksnc_rx_niov;
-#endif
 	struct kvec *iov = conn->ksnc_rx_iov;
 	struct msghdr msg = {
 		.msg_flags = 0
@@ -220,20 +213,15 @@ ksocknal_lib_recv_iov(struct ksock_conn *conn)
 	int sum;
 	__u32 saved_csum;
 
-	/*
-	 * NB we can't trust socket ops to either consume our iovs
-	 * or leave them alone.
-	 */
 	LASSERT(niov > 0);
 
-	for (nob = i = 0; i < niov; i++) {
-		scratchiov[i] = iov[i];
-		nob += scratchiov[i].iov_len;
-	}
+	for (nob = i = 0; i < niov; i++)
+		nob += iov[i].iov_len;
+
 	LASSERT(nob <= conn->ksnc_rx_nob_wanted);
 
-	rc = kernel_recvmsg(conn->ksnc_sock, &msg, scratchiov, niov, nob,
-			    MSG_DONTWAIT);
+	iov_iter_kvec(&msg.msg_iter, READ | ITER_KVEC, iov, niov, nob);
+	rc = sock_recvmsg(conn->ksnc_sock, &msg, MSG_DONTWAIT);
 
 	saved_csum = 0;
 	if (conn->ksnc_proto == &ksocknal_protocol_v2x) {
-- 
2.7.4
