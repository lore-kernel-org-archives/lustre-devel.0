From: James Simmons <jsimmons@infradead.org>
Date: Wed,  2 Mar 2016 17:01:53 -0500
Subject: [lustre-devel] [PATCH 10/27] staging: lustre: replace direct LNet
	HZ access with kernel APIs
In-Reply-To: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
References: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456956130-6110-11-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jian Yu <jian.yu@intel.com>

From: Jian Yu <jian.yu@intel.com>

On some customers' systems, the kernel was compiled with HZ defined
to 100, instead of 1000. This improves performance for HPC applications.
However, to use these systems with Lustre, customers have to re-build
Lustre for the kernel because Lustre directly uses the defined constant
HZ.

Since kernel 2.6.21, some non-HZ dependent timing APIs become non-
inline functions, which can be used in Lustre codes to replace the
direct HZ access.

These kernel APIs include:
 jiffies_to_msecs()
 jiffies_to_usecs()
 jiffies_to_timespec()
 msecs_to_jiffies()
 usecs_to_jiffies()
 timespec_to_jiffies()

And here are some samples of the replacement:
 HZ            -> msecs_to_jiffies(MSEC_PER_SEC)
 n * HZ        -> msecs_to_jiffies(n * MSEC_PER_SEC)
 HZ / n        -> msecs_to_jiffies(MSEC_PER_SEC / n)
 n / HZ        -> jiffies_to_msecs(n) / MSEC_PER_SEC
 n / HZ * 1000 -> jiffies_to_msecs(n)

This patch replaces the direct HZ access in lnet module.

Signed-off-by: Jian Yu <jian.yu@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5443
Reviewed-by: Nathaniel Clark <nathaniel.l.clark@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |    3 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    6 +++-
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    4 ++-
 drivers/staging/lustre/lnet/lnet/lib-socket.c      |   24 +++++++------------
 drivers/staging/lustre/lnet/selftest/conrpc.c      |    2 +-
 5 files changed, 19 insertions(+), 20 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 2abb574..fb7079c 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -691,7 +691,8 @@ kiblnd_send_keepalive(kib_conn_t *conn)
 {
 	return (*kiblnd_tunables.kib_keepalive > 0) &&
 		cfs_time_after(jiffies, conn->ibc_last_send +
-			       *kiblnd_tunables.kib_keepalive * HZ);
+			       msecs_to_jiffies(*kiblnd_tunables.kib_keepalive *
+						MSEC_PER_SEC));
 }
 
 static inline int
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 0608431..d955a66 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1147,7 +1147,9 @@ kiblnd_queue_tx_locked(kib_tx_t *tx, kib_conn_t *conn)
 	LASSERT(conn->ibc_state >= IBLND_CONN_ESTABLISHED);
 
 	tx->tx_queued = 1;
-	tx->tx_deadline = jiffies + (*kiblnd_tunables.kib_timeout * HZ);
+	tx->tx_deadline = jiffies +
+			  msecs_to_jiffies(*kiblnd_tunables.kib_timeout *
+					   MSEC_PER_SEC);
 
 	if (!tx->tx_conn) {
 		kiblnd_conn_addref(conn);
@@ -3188,7 +3190,7 @@ kiblnd_connd(void *arg)
 					     kiblnd_data.kib_peer_hash_size;
 			}
 
-			deadline += p * HZ;
+			deadline += msecs_to_jiffies(p * MSEC_PER_SEC);
 			spin_lock_irqsave(&kiblnd_data.kib_connd_lock, flags);
 		}
 
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 6c42786..f6f6cd8 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -2011,8 +2011,10 @@ LNetCtl(unsigned int cmd, void *arg)
 
 	case IOC_LIBCFS_NOTIFY_ROUTER:
 		secs_passed = (ktime_get_real_seconds() - data->ioc_u64[0]);
+		secs_passed *= msecs_to_jiffies(MSEC_PER_SEC);
+
 		return lnet_notify(NULL, data->ioc_nid, data->ioc_flags,
-				   jiffies - secs_passed * HZ);
+				   jiffies - secs_passed);
 
 	case IOC_LIBCFS_LNET_DIST:
 		rc = LNetDist(data->ioc_nid, &data->ioc_nid, &data->ioc_u32[1]);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
index 269a6d8..cc0c275 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -262,7 +262,7 @@ int
 lnet_sock_write(struct socket *sock, void *buffer, int nob, int timeout)
 {
 	int rc;
-	long ticks = timeout * HZ;
+	long jiffies_left = timeout * msecs_to_jiffies(MSEC_PER_SEC);
 	unsigned long then;
 	struct timeval tv;
 
@@ -282,10 +282,7 @@ lnet_sock_write(struct socket *sock, void *buffer, int nob, int timeout)
 
 		if (timeout) {
 			/* Set send timeout to remaining time */
-			tv = (struct timeval) {
-				.tv_sec = ticks / HZ,
-				.tv_usec = ((ticks % HZ) * 1000000) / HZ
-			};
+			jiffies_to_timeval(jiffies_left, &tv);
 			rc = kernel_setsockopt(sock, SOL_SOCKET, SO_SNDTIMEO,
 					       (char *)&tv, sizeof(tv));
 			if (rc) {
@@ -297,7 +294,7 @@ lnet_sock_write(struct socket *sock, void *buffer, int nob, int timeout)
 
 		then = jiffies;
 		rc = kernel_sendmsg(sock, &msg, &iov, 1, nob);
-		ticks -= jiffies - then;
+		jiffies_left -= jiffies - then;
 
 		if (rc == nob)
 			return 0;
@@ -310,7 +307,7 @@ lnet_sock_write(struct socket *sock, void *buffer, int nob, int timeout)
 			return -ECONNABORTED;
 		}
 
-		if (ticks <= 0)
+		if (jiffies_left <= 0)
 			return -EAGAIN;
 
 		buffer = ((char *)buffer) + rc;
@@ -324,12 +321,12 @@ int
 lnet_sock_read(struct socket *sock, void *buffer, int nob, int timeout)
 {
 	int rc;
-	long ticks = timeout * HZ;
+	long jiffies_left = timeout * msecs_to_jiffies(MSEC_PER_SEC);
 	unsigned long then;
 	struct timeval tv;
 
 	LASSERT(nob > 0);
-	LASSERT(ticks > 0);
+	LASSERT(jiffies_left > 0);
 
 	for (;;) {
 		struct kvec  iov = {
@@ -341,10 +338,7 @@ lnet_sock_read(struct socket *sock, void *buffer, int nob, int timeout)
 		};
 
 		/* Set receive timeout to remaining time */
-		tv = (struct timeval) {
-			.tv_sec = ticks / HZ,
-			.tv_usec = ((ticks % HZ) * 1000000) / HZ
-		};
+		jiffies_to_timeval(jiffies_left, &tv);
 		rc = kernel_setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO,
 				       (char *)&tv, sizeof(tv));
 		if (rc) {
@@ -355,7 +349,7 @@ lnet_sock_read(struct socket *sock, void *buffer, int nob, int timeout)
 
 		then = jiffies;
 		rc = kernel_recvmsg(sock, &msg, &iov, 1, nob, 0);
-		ticks -= jiffies - then;
+		jiffies_left -= jiffies - then;
 
 		if (rc < 0)
 			return rc;
@@ -369,7 +363,7 @@ lnet_sock_read(struct socket *sock, void *buffer, int nob, int timeout)
 		if (!nob)
 			return 0;
 
-		if (ticks <= 0)
+		if (jiffies_left <= 0)
 			return -ETIMEDOUT;
 	}
 }
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index b02a140..736efce 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -1252,7 +1252,7 @@ lstcon_rpc_pinger(void *arg)
 		if (nd->nd_state != LST_NODE_ACTIVE)
 			continue;
 
-		intv = (jiffies - nd->nd_stamp) / HZ;
+		intv = (jiffies - nd->nd_stamp) / msecs_to_jiffies(MSEC_PER_SEC);
 		if (intv < nd->nd_timeout / 2)
 			continue;
 
-- 
1.7.1
