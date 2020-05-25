From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:08:03 -0400
Subject: [lustre-devel] [PATCH 26/45] lnet: stop using struct timeval
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-27-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The struct timeval is not 2038 safe so the Linux kernel is moving
away from its use. The use of rpe_stamp hasn't been used since
Lustre 2.2 so remove the userland use of this field. This frees
use to change rpe_stamp to an equivalent struct timespec64 for
future use. Greatly simplify lnet_sock_[read|write] by using
jiffies values of sk_sndtimeo, sk_rcvtimeo cached in struct sock.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13344
Lustre-commit: 5e4c658c4fea4 ("LU-13344 lnet: stop using struct timeval")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/38105
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
---
 include/uapi/linux/lnet/lnetst.h        |  8 +++++++-
 include/uapi/linux/lustre/lustre_user.h |  2 +-
 net/lnet/lnet/lib-socket.c              | 34 ++++++++++-----------------------
 net/lnet/selftest/conctl.c              |  1 -
 net/lnet/selftest/conrpc.c              |  6 +++---
 net/lnet/selftest/conrpc.h              |  1 -
 net/lnet/selftest/console.h             |  1 -
 7 files changed, 21 insertions(+), 32 deletions(-)

diff --git a/include/uapi/linux/lnet/lnetst.h b/include/uapi/linux/lnet/lnetst.h
index 9e61c16..dd38a90 100644
--- a/include/uapi/linux/lnet/lnetst.h
+++ b/include/uapi/linux/lnet/lnetst.h
@@ -149,7 +149,13 @@ struct list_head {
 struct lstcon_rpc_ent {
 	struct list_head	rpe_link;	/* link chain */
 	struct lnet_process_id	rpe_peer;	/* peer's id */
-	struct timeval		rpe_stamp;	/* time stamp of RPC */
+	/* This has not been used since Lustre 2.2 so its safe to use.
+	 * Update to allow future use of timespec64
+	 */
+	struct {
+		__s64		tv_sec;
+		__s64		tv_nsec;
+	} rpe_stamp;				/* time stamp of RPC */
 	int			rpe_state;	/* peer's state */
 	int			rpe_rpc_errno;	/* RPC errno */
 
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 80e5c24..4b7c89b 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -961,7 +961,7 @@ struct identity_downcall_data {
 
 struct sepol_downcall_data {
 	__u32		sdd_magic;
-	__kernel_time_t	sdd_sepol_mtime;
+	__s64		sdd_sepol_mtime;
 	__u16		sdd_sepol_len;
 	char		sdd_sepol[0];
 };
diff --git a/net/lnet/lnet/lib-socket.c b/net/lnet/lnet/lib-socket.c
index 72e45ca..a4db830 100644
--- a/net/lnet/lnet/lib-socket.c
+++ b/net/lnet/lnet/lib-socket.c
@@ -50,8 +50,6 @@
 	int rc;
 	long jiffies_left = timeout * HZ;
 	unsigned long then;
-	struct timeval tv;
-	struct __kernel_sock_timeval ktv;
 	struct kvec iov = {
 		.iov_base = buffer,
 		.iov_len = nob
@@ -67,17 +65,12 @@
 	for (;;) {
 		msg.msg_flags = !timeout ? MSG_DONTWAIT : 0;
 		if (timeout) {
+			struct sock *sk = sock->sk;
+
 			/* Set send timeout to remaining time */
-			jiffies_to_timeval(jiffies_left, &tv);
-			ktv.tv_sec = tv.tv_sec;
-			ktv.tv_usec = tv.tv_usec;
-			rc = kernel_setsockopt(sock, SOL_SOCKET, SO_SNDTIMEO_NEW,
-					       (char *)&ktv, sizeof(ktv));
-			if (rc) {
-				CERROR("Can't set socket send timeout %ld.%06d: %d\n",
-				       (long)tv.tv_sec, (int)tv.tv_usec, rc);
-				return rc;
-			}
+			lock_sock(sk);
+			sk->sk_sndtimeo = jiffies_left;
+			release_sock(sk);
 		}
 
 		then = jiffies;
@@ -108,8 +101,6 @@
 	int rc;
 	long jiffies_left = timeout * HZ;
 	unsigned long then;
-	struct timeval tv;
-	struct __kernel_sock_timeval ktv;
 	struct kvec iov = {
 		.iov_base = buffer,
 		.iov_len = nob
@@ -124,17 +115,12 @@
 	iov_iter_kvec(&msg.msg_iter, READ, &iov, 1, nob);
 
 	for (;;) {
+		struct sock *sk = sock->sk;
+
 		/* Set receive timeout to remaining time */
-		jiffies_to_timeval(jiffies_left, &tv);
-		ktv.tv_sec = tv.tv_sec;
-		ktv.tv_usec = tv.tv_usec;
-		rc = kernel_setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO_NEW,
-				       (char *)&ktv, sizeof(ktv));
-		if (rc) {
-			CERROR("Can't set socket recv timeout %ld.%06d: %d\n",
-			       (long)tv.tv_sec, (int)tv.tv_usec, rc);
-			return rc;
-		}
+		lock_sock(sk);
+		sk->sk_rcvtimeo = jiffies_left;
+		release_sock(sk);
 
 		then = jiffies;
 		rc = sock_recvmsg(sock, &msg, 0);
diff --git a/net/lnet/selftest/conctl.c b/net/lnet/selftest/conctl.c
index ed9eab9..7e82304 100644
--- a/net/lnet/selftest/conctl.c
+++ b/net/lnet/selftest/conctl.c
@@ -38,7 +38,6 @@
  */
 
 #include <linux/lnet/lib-lnet.h>
-#include <uapi/linux/lnet/lnetst.h>
 #include "console.h"
 
 static int
diff --git a/net/lnet/selftest/conrpc.c b/net/lnet/selftest/conrpc.c
index 8baaac8..6a55b23 100644
--- a/net/lnet/selftest/conrpc.c
+++ b/net/lnet/selftest/conrpc.c
@@ -474,7 +474,7 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 	struct lstcon_rpc *crpc;
 	struct srpc_msg *msg;
 	struct lstcon_node *nd;
-	struct timeval tv;
+	struct timespec64 ts;
 	int error;
 	s64 dur;
 
@@ -501,11 +501,11 @@ void lstcon_rpc_stat_reply(struct lstcon_rpc_trans *, struct srpc_msg *,
 
 		dur = crpc->crp_stamp_ns -
 		      console_session.ses_id.ses_stamp * NSEC_PER_MSEC;
-		tv = ns_to_timeval(dur);
+		ts = ns_to_timespec64(dur);
 
 		if (copy_to_user(&ent->rpe_peer, &nd->nd_id,
 				 sizeof(struct lnet_process_id)) ||
-		    copy_to_user(&ent->rpe_stamp, &tv, sizeof(tv)) ||
+		    copy_to_user(&ent->rpe_stamp, &ts, sizeof(ts)) ||
 		    copy_to_user(&ent->rpe_state, &nd->nd_state,
 				 sizeof(nd->nd_state)) ||
 		    copy_to_user(&ent->rpe_rpc_errno, &error,
diff --git a/net/lnet/selftest/conrpc.h b/net/lnet/selftest/conrpc.h
index fd75c50..180fa02 100644
--- a/net/lnet/selftest/conrpc.h
+++ b/net/lnet/selftest/conrpc.h
@@ -41,7 +41,6 @@
 #define __LST_CONRPC_H__
 
 #include <linux/lnet/lib-types.h>
-#include <uapi/linux/lnet/lnetst.h>
 #include "rpc.h"
 #include "selftest.h"
 
diff --git a/net/lnet/selftest/console.h b/net/lnet/selftest/console.h
index a463276..cd132e1 100644
--- a/net/lnet/selftest/console.h
+++ b/net/lnet/selftest/console.h
@@ -41,7 +41,6 @@
 #define __LST_CONSOLE_H__
 
 #include <linux/lnet/lib-types.h>
-#include <uapi/linux/lnet/lnetst.h>
 #include "selftest.h"
 #include "conrpc.h"
 
-- 
1.8.3.1
