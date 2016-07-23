From: Oleg Drokin <green@linuxhacker.ru>
Date: Sat, 23 Jul 2016 02:36:58 -0400
Subject: [lustre-devel] [PATCH 01/15] lustre: switch lnet_sock_write() to
	sock_sendmsg()
In-Reply-To: <1469255832-746785-1-git-send-email-green@linuxhacker.ru>
References: <1469255832-746785-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1469255832-746785-2-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Al Viro <viro@zeniv.linux.org.uk>

From: Al Viro <viro@zeniv.linux.org.uk>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 drivers/staging/lustre/lnet/lnet/lib-socket.c | 21 +++++++--------------
 1 file changed, 7 insertions(+), 14 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
index 891fd59..4e6dd51 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -265,21 +265,17 @@ lnet_sock_write(struct socket *sock, void *buffer, int nob, int timeout)
 	long jiffies_left = timeout * msecs_to_jiffies(MSEC_PER_SEC);
 	unsigned long then;
 	struct timeval tv;
+	struct kvec  iov = { .iov_base = buffer, .iov_len  = nob };
+	struct msghdr msg = {NULL,};
 
 	LASSERT(nob > 0);
 	/*
 	 * Caller may pass a zero timeout if she thinks the socket buffer is
 	 * empty enough to take the whole message immediately
 	 */
+	iov_iter_kvec(&msg.msg_iter, WRITE | ITER_KVEC, &iov, 1, nob);
 	for (;;) {
-		struct kvec  iov = {
-			.iov_base = buffer,
-			.iov_len  = nob
-		};
-		struct msghdr msg = {
-			.msg_flags      = !timeout ? MSG_DONTWAIT : 0
-		};
-
+		msg.msg_flags = !timeout ? MSG_DONTWAIT : 0;
 		if (timeout) {
 			/* Set send timeout to remaining time */
 			jiffies_to_timeval(jiffies_left, &tv);
@@ -296,9 +292,6 @@ lnet_sock_write(struct socket *sock, void *buffer, int nob, int timeout)
 		rc = kernel_sendmsg(sock, &msg, &iov, 1, nob);
 		jiffies_left -= jiffies - then;
 
-		if (rc == nob)
-			return 0;
-
 		if (rc < 0)
 			return rc;
 
@@ -307,11 +300,11 @@ lnet_sock_write(struct socket *sock, void *buffer, int nob, int timeout)
 			return -ECONNABORTED;
 		}
 
+		if (!msg_data_left(&msg))
+			break;
+
 		if (jiffies_left <= 0)
 			return -EAGAIN;
-
-		buffer = ((char *)buffer) + rc;
-		nob -= rc;
 	}
 	return 0;
 }
-- 
2.7.4
