From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:24 -0500
Subject: [lustre-devel] [PATCH 516/622] lustre/lnet: remove unnecessary use
 of msecs_to_jiffies()
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-517-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: NeilBrown <neilb@suse.de>

msecs_to_jiffies() is useful when you have a number of milliseconds,
but when you have a number of seconds,
   sec * HZ
is simpler than
   msecs_to_jiffies(sec * MSECS_PER_SEC)

Similary for small divisions of a second (e.g. HZ/4)

So change all calls to msecs_to_jiffies() the reference MSECS_PER_SEC to
simple multiplications by HZ.

Signed-off-by: NeilBrown <neilb@suse.de>
Reviewed-by: James Simmons <jsimmons@infradaed.org>
---
 fs/lustre/mgc/mgc_request.c         | 8 ++++----
 fs/lustre/obdclass/integrity.c      | 2 +-
 fs/lustre/osc/osc_request.c         | 5 ++---
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 2 +-
 net/lnet/libcfs/linux-crypto.c      | 2 +-
 net/lnet/lnet/lib-socket.c          | 4 ++--
 6 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/fs/lustre/mgc/mgc_request.c b/fs/lustre/mgc/mgc_request.c
index 5bfa1b7..28064fd 100644
--- a/fs/lustre/mgc/mgc_request.c
+++ b/fs/lustre/mgc/mgc_request.c
@@ -555,12 +555,12 @@ static int mgc_requeue_thread(void *data)
 		 * caused the lock revocation to finish its setup, plus some
 		 * random so everyone doesn't try to reconnect at once.
 		 */
-		to = msecs_to_jiffies(MGC_TIMEOUT_MIN_SECONDS * MSEC_PER_SEC);
-		/* rand is centi-seconds */
-		to += msecs_to_jiffies(rand * MSEC_PER_SEC / 100);
+		/* rand is centi-seconds, "to" is in centi-HZ */
+		to = MGC_TIMEOUT_MIN_SECONDS * HZ * 100;
+		to += rand * HZ;
 		wait_event_idle_timeout(rq_waitq,
 					rq_state & (RQ_STOP | RQ_PRECLEANUP),
-					to);
+					to/100);
 
 		/*
 		 * iterate & processing through the list. for each cld, process
diff --git a/fs/lustre/obdclass/integrity.c b/fs/lustre/obdclass/integrity.c
index 2d5760d..230e1a5 100644
--- a/fs/lustre/obdclass/integrity.c
+++ b/fs/lustre/obdclass/integrity.c
@@ -226,7 +226,7 @@ static void obd_t10_performance_test(const char *obd_name,
 	memset(buf, 0xAD, PAGE_SIZE);
 	kunmap(page);
 
-	for (start = jiffies, end = start + msecs_to_jiffies(MSEC_PER_SEC / 4),
+	for (start = jiffies, end = start + HZ / 4,
 	     bcount = 0; time_before(jiffies, end) && rc == 0; bcount++) {
 		rc = __obd_t10_performance_test(obd_name, cksum_type, page,
 						buf_len / PAGE_SIZE);
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 95e09ce..9c43756 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -901,9 +901,8 @@ static void osc_grant_work_handler(struct work_struct *data)
 		return;
 
 	if (next_shrink > ktime_get_seconds())
-		schedule_delayed_work(&work, msecs_to_jiffies(
-					(next_shrink - ktime_get_seconds()) *
-					MSEC_PER_SEC));
+		schedule_delayed_work(&work,
+				      (next_shrink - ktime_get_seconds()) * HZ);
 	else
 		schedule_work(&work.work);
 }
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 1110553..fcd9db2 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -3550,7 +3550,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 					     kiblnd_data.kib_peer_hash_size;
 			}
 
-			deadline += msecs_to_jiffies(p * MSEC_PER_SEC);
+			deadline += p * HZ;
 			spin_lock_irqsave(lock, flags);
 		}
 
diff --git a/net/lnet/libcfs/linux-crypto.c b/net/lnet/libcfs/linux-crypto.c
index 532fab4..add4e79 100644
--- a/net/lnet/libcfs/linux-crypto.c
+++ b/net/lnet/libcfs/linux-crypto.c
@@ -346,7 +346,7 @@ static void cfs_crypto_performance_test(enum cfs_crypto_hash_alg hash_alg)
 	memset(buf, 0xAD, PAGE_SIZE);
 	kunmap(page);
 
-	for (start = jiffies, end = start + msecs_to_jiffies(MSEC_PER_SEC / 4),
+	for (start = jiffies, end = start + HZ / 4,
 	     bcount = 0; time_before(jiffies, end) && err == 0; bcount++) {
 		struct ahash_request *hdesc;
 		int i;
diff --git a/net/lnet/lnet/lib-socket.c b/net/lnet/lnet/lib-socket.c
index 046bd2d..0c65dc9 100644
--- a/net/lnet/lnet/lib-socket.c
+++ b/net/lnet/lnet/lib-socket.c
@@ -47,7 +47,7 @@
 lnet_sock_write(struct socket *sock, void *buffer, int nob, int timeout)
 {
 	int rc;
-	long jiffies_left = timeout * msecs_to_jiffies(MSEC_PER_SEC);
+	long jiffies_left = timeout * HZ;
 	unsigned long then;
 	struct timeval tv;
 	struct __kernel_sock_timeval ktv;
@@ -105,7 +105,7 @@
 lnet_sock_read(struct socket *sock, void *buffer, int nob, int timeout)
 {
 	int rc;
-	long jiffies_left = timeout * msecs_to_jiffies(MSEC_PER_SEC);
+	long jiffies_left = timeout * HZ;
 	unsigned long then;
 	struct timeval tv;
 	struct __kernel_sock_timeval ktv;
-- 
1.8.3.1
