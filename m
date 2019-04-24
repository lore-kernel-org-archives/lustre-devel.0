From: NeilBrown <neilb@suse.com>
Date: Wed, 24 Apr 2019 12:17:26 +1000
Subject: [lustre-devel] [PATCH 2/4] lustre: update for SO_RCVTIMEO
 SO_SNDTIMEO changes.
In-Reply-To: <155607223991.16863.3231709121984405156.stgit@noble.brown>
References: <155607223991.16863.3231709121984405156.stgit@noble.brown>
Message-ID: <155607224617.16863.14802160542309003623.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

These socket options have been changed to be Y2K038 compliant.
So we need to use the _NEW versions and use the correct
data structure.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lnet/lnet/lib-socket.c |   14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
index 095f9f5e5ea1..6ea8f3f904d0 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -50,6 +50,7 @@ lnet_sock_write(struct socket *sock, void *buffer, int nob, int timeout)
 	long jiffies_left = timeout * msecs_to_jiffies(MSEC_PER_SEC);
 	unsigned long then;
 	struct timeval tv;
+	struct __kernel_sock_timeval ktv;
 	struct kvec iov = {
 		.iov_base = buffer,
 		.iov_len = nob
@@ -67,8 +68,10 @@ lnet_sock_write(struct socket *sock, void *buffer, int nob, int timeout)
 		if (timeout) {
 			/* Set send timeout to remaining time */
 			jiffies_to_timeval(jiffies_left, &tv);
-			rc = kernel_setsockopt(sock, SOL_SOCKET, SO_SNDTIMEO,
-					       (char *)&tv, sizeof(tv));
+			ktv.tv_sec = tv.tv_sec;
+			ktv.tv_usec = tv.tv_usec;
+			rc = kernel_setsockopt(sock, SOL_SOCKET, SO_SNDTIMEO_NEW,
+					       (char *)&ktv, sizeof(ktv));
 			if (rc) {
 				CERROR("Can't set socket send timeout %ld.%06d: %d\n",
 				       (long)tv.tv_sec, (int)tv.tv_usec, rc);
@@ -105,6 +108,7 @@ lnet_sock_read(struct socket *sock, void *buffer, int nob, int timeout)
 	long jiffies_left = timeout * msecs_to_jiffies(MSEC_PER_SEC);
 	unsigned long then;
 	struct timeval tv;
+	struct __kernel_sock_timeval ktv;
 	struct kvec iov = {
 		.iov_base = buffer,
 		.iov_len = nob
@@ -121,8 +125,10 @@ lnet_sock_read(struct socket *sock, void *buffer, int nob, int timeout)
 	for (;;) {
 		/* Set receive timeout to remaining time */
 		jiffies_to_timeval(jiffies_left, &tv);
-		rc = kernel_setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO,
-				       (char *)&tv, sizeof(tv));
+		ktv.tv_sec = tv.tv_sec;
+		ktv.tv_usec = tv.tv_usec;
+		rc = kernel_setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO_NEW,
+				       (char *)&ktv, sizeof(ktv));
 		if (rc) {
 			CERROR("Can't set socket recv timeout %ld.%06d: %d\n",
 			       (long)tv.tv_sec, (int)tv.tv_usec, rc);
