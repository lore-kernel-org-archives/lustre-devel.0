From: James Simmons <jsimmons@infradead.org>
Date: Mon,  8 Jun 2015 22:27:09 -0400
Subject: [lustre-devel] [PATCH v5 3/7] staging:lustre: remove useless
	libcfs_sock_abort_accept
In-Reply-To: <1433816833-3244-1-git-send-email-jsimmons@infradead.org>
References: <1433816833-3244-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1433816833-3244-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Another one of those silly one line wrappers which is not
needed. Replace libcfs_sock_abort_accept wrapper with a
direct call to wake_up_all on the lnet_acceptor_state sock.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |    1 -
 drivers/staging/lustre/lnet/lnet/acceptor.c        |    4 ++--
 drivers/staging/lustre/lnet/lnet/lib-socket.c      |    8 --------
 3 files changed, 2 insertions(+), 11 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index f469333..457ce9a 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -71,7 +71,6 @@ int libcfs_ipif_enumerate(char ***names);
 void libcfs_ipif_free_enumeration(char **names, int n);
 int libcfs_sock_listen(struct socket **sockp, __u32 ip, int port, int backlog);
 int libcfs_sock_accept(struct socket **newsockp, struct socket *sock);
-void libcfs_sock_abort_accept(struct socket *sock);
 int libcfs_sock_connect(struct socket **sockp, int *fatal,
 			__u32 local_ip, int local_port,
 			__u32 peer_ip, int peer_port);
diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
index 1657106..246a583 100644
--- a/drivers/staging/lustre/lnet/lnet/acceptor.c
+++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
@@ -377,7 +377,7 @@ lnet_acceptor(void *arg)
 			continue;
 		}
 
-		/* maybe we're waken up with libcfs_sock_abort_accept() */
+		/* maybe the LNet acceptor thread has been waken */
 		if (lnet_acceptor_state.pta_shutdown) {
 			sock_release(newsock);
 			break;
@@ -493,7 +493,7 @@ lnet_acceptor_stop(void)
 		return;
 
 	lnet_acceptor_state.pta_shutdown = 1;
-	libcfs_sock_abort_accept(lnet_acceptor_state.pta_sock);
+	wake_up_all(sk_sleep(lnet_acceptor_state.pta_sock->sk));
 
 	/* block until acceptor signals exit */
 	wait_for_completion(&lnet_acceptor_state.pta_signal);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
index 259db61..bb8d9c2 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -568,14 +568,6 @@ libcfs_sock_accept (struct socket **newsockp, struct socket *sock)
 
 EXPORT_SYMBOL(libcfs_sock_accept);
 
-void
-libcfs_sock_abort_accept (struct socket *sock)
-{
-	wake_up_all(sk_sleep(sock->sk));
-}
-
-EXPORT_SYMBOL(libcfs_sock_abort_accept);
-
 int
 libcfs_sock_connect (struct socket **sockp, int *fatal,
 		     __u32 local_ip, int local_port,
-- 
1.7.1
