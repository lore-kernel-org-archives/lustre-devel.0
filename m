From: James Simmons <jsimmons@infradead.org>
Date: Wed,  3 Jun 2015 15:57:08 -0400
Subject: [lustre-devel] [PATCH v4 2/7] staging:lustre: remove useless
	libcfs_sock_release
In-Reply-To: <1433361433-24976-1-git-send-email-jsimmons@infradead.org>
References: <1433361433-24976-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1433361433-24976-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

There is no reason to have a one line exported function
libcfs_sock_release. Instead we can call sock_release directly.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |    1 -
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    2 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |    2 +-
 drivers/staging/lustre/lnet/lnet/acceptor.c        |    8 ++++----
 drivers/staging/lustre/lnet/lnet/lib-socket.c      |    8 --------
 5 files changed, 6 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index a789559..f469333 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -80,7 +80,6 @@ int libcfs_sock_getbuf(struct socket *socket, int *txbufsize, int *rxbufsize);
 int libcfs_sock_getaddr(struct socket *socket, int remote, __u32 *ip, int *port);
 int libcfs_sock_write(struct socket *sock, void *buffer, int nob, int timeout);
 int libcfs_sock_read(struct socket *sock, void *buffer, int nob, int timeout);
-void libcfs_sock_release(struct socket *sock);
 
 /* need both kernel and user-land acceptor */
 #define LNET_ACCEPTOR_MIN_RESERVED_PORT    512
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 7b5d407..38e831f 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -1386,7 +1386,7 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 	LIBCFS_FREE(conn, sizeof(*conn));
 
  failed_0:
-	libcfs_sock_release(sock);
+	sock_release(sock);
 	return rc;
 }
 
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index c34378c..06531c1 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -519,7 +519,7 @@ ksocknal_connsock_decref(ksock_conn_t *conn)
 	LASSERT(atomic_read(&conn->ksnc_sock_refcount) > 0);
 	if (atomic_dec_and_test(&conn->ksnc_sock_refcount)) {
 		LASSERT(conn->ksnc_closing);
-		libcfs_sock_release(conn->ksnc_sock);
+		sock_release(conn->ksnc_sock);
 		conn->ksnc_sock = NULL;
 		ksocknal_finalize_zcreq(conn);
 	}
diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
index 69d4b19..bc212f5 100644
--- a/drivers/staging/lustre/lnet/lnet/acceptor.c
+++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
@@ -197,7 +197,7 @@ lnet_connect(struct socket **sockp, lnet_nid_t peer_nid,
 	goto failed;
 
  failed_sock:
-	libcfs_sock_release(sock);
+	sock_release(sock);
  failed:
 	lnet_connect_console_error(rc, peer_nid, peer_ip, peer_port);
 	return rc;
@@ -379,7 +379,7 @@ lnet_acceptor(void *arg)
 
 		/* maybe we're waken up with libcfs_sock_abort_accept() */
 		if (lnet_acceptor_state.pta_shutdown) {
-			libcfs_sock_release(newsock);
+			sock_release(newsock);
 			break;
 		}
 
@@ -410,10 +410,10 @@ lnet_acceptor(void *arg)
 		continue;
 
 failed:
-		libcfs_sock_release(newsock);
+		sock_release(newsock);
 	}
 
-	libcfs_sock_release(lnet_acceptor_state.pta_sock);
+	sock_release(lnet_acceptor_state.pta_sock);
 	lnet_acceptor_state.pta_sock = NULL;
 
 	CDEBUG(D_NET, "Acceptor stopping\n");
diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
index 7f80612..259db61 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -614,11 +614,3 @@ libcfs_sock_connect (struct socket **sockp, int *fatal,
 }
 
 EXPORT_SYMBOL(libcfs_sock_connect);
-
-void
-libcfs_sock_release (struct socket *sock)
-{
-	sock_release(sock);
-}
-
-EXPORT_SYMBOL(libcfs_sock_release);
-- 
1.7.1
