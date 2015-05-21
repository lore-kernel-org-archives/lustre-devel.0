From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 May 2015 18:46:16 -0400
Subject: [lustre-devel] [PATCH 1/3] staging:lustre: remove tcpip abstraction
	from libcfs
In-Reply-To: <uja.ornl@gmail.com>
References: <uja.ornl@gmail.com>
Message-ID: <1432248378-28912-2-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: James Simmons <uja.ornl@yahoo.com>

Since libcfs no longer builds for user land we can
move the TCPIP abstraction that exist to the LNET
layer which is the only place that uses it. Also
the migrated code will use native linux kernel
APIs directly instead of with wrappers.

Signed-off-by: James Simmons <uja.ornl@gmail.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
Reviewed-on: http://review.whamcloud.com/13760
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Isaac Huang <he.huang@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |   17 -
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |   15 +
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    2 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |   16 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |    2 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |    7 +-
 .../lustre/lnet/klnds/socklnd/socklnd_lib-linux.c  |   17 +-
 .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |   30 +-
 drivers/staging/lustre/lnet/lnet/Makefile          |    7 +-
 drivers/staging/lustre/lnet/lnet/acceptor.c        |   43 +-
 drivers/staging/lustre/lnet/lnet/config.c          |   21 +-
 drivers/staging/lustre/lnet/lnet/lib-socket.c      |  616 +++++++++++++++++++
 drivers/staging/lustre/lustre/libcfs/Makefile      |    1 -
 .../lustre/lustre/libcfs/linux/linux-tcpip.c       |  623 --------------------
 14 files changed, 701 insertions(+), 716 deletions(-)
 create mode 100644 drivers/staging/lustre/lnet/lnet/lib-socket.c
 delete mode 100644 drivers/staging/lustre/lustre/libcfs/linux/linux-tcpip.c

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 947df7e..f54bab6 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -88,23 +88,6 @@ static inline int __is_po2(unsigned long long val)
 int libcfs_arch_init(void);
 void libcfs_arch_cleanup(void);
 
-/* libcfs tcpip */
-int libcfs_ipif_query(char *name, int *up, __u32 *ip, __u32 *mask);
-int libcfs_ipif_enumerate(char ***names);
-void libcfs_ipif_free_enumeration(char **names, int n);
-int libcfs_sock_listen(struct socket **sockp, __u32 ip, int port, int backlog);
-int libcfs_sock_accept(struct socket **newsockp, struct socket *sock);
-void libcfs_sock_abort_accept(struct socket *sock);
-int libcfs_sock_connect(struct socket **sockp, int *fatal,
-			__u32 local_ip, int local_port,
-			__u32 peer_ip, int peer_port);
-int libcfs_sock_setbuf(struct socket *socket, int txbufsize, int rxbufsize);
-int libcfs_sock_getbuf(struct socket *socket, int *txbufsize, int *rxbufsize);
-int libcfs_sock_getaddr(struct socket *socket, int remote, __u32 *ip, int *port);
-int libcfs_sock_write(struct socket *sock, void *buffer, int nob, int timeout);
-int libcfs_sock_read(struct socket *sock, void *buffer, int nob, int timeout);
-void libcfs_sock_release(struct socket *sock);
-
 /* need both kernel and user-land acceptor */
 #define LNET_ACCEPTOR_MIN_RESERVED_PORT    512
 #define LNET_ACCEPTOR_MAX_RESERVED_PORT    1023
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index 0038d29..c00a2ca 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -846,6 +846,21 @@ int lnet_acceptor_port(void);
 int lnet_acceptor_start(void);
 void lnet_acceptor_stop(void);
 
+int lnet_ipif_query(char *name, int *up, __u32 *ip, __u32 *mask);
+int lnet_ipif_enumerate(char ***names);
+void lnet_ipif_free_enumeration(char **names, int n);
+int lnet_sock_setbuf(struct socket *socket, int txbufsize, int rxbufsize);
+int lnet_sock_getbuf(struct socket *socket, int *txbufsize, int *rxbufsize);
+int lnet_sock_getaddr(struct socket *socket, bool remote, __u32 *ip, int *port);
+int lnet_sock_write(struct socket *sock, void *buffer, int nob, int timeout);
+int lnet_sock_read(struct socket *sock, void *buffer, int nob, int timeout);
+
+int lnet_sock_listen(struct socket **sockp, __u32 ip, int port, int backlog);
+int lnet_sock_accept(struct socket **newsockp, struct socket *sock);
+int lnet_sock_connect(struct socket **sockp, int *fatal,
+		      __u32 local_ip, int local_port,
+		      __u32 peer_ip, int peer_port);
+
 void lnet_get_tunables(void);
 int lnet_peers_start_down(void);
 int lnet_peer_buffer_credits(lnet_ni_t *ni);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 3bad441..be4de56 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2620,7 +2620,7 @@ static kib_dev_t *kiblnd_create_dev(char *ifname)
 	int		up;
 	int		rc;
 
-	rc = libcfs_ipif_query(ifname, &up, &ip, &netmask);
+	rc = lnet_ipif_query(ifname, &up, &ip, &netmask);
 	if (rc != 0) {
 		CERROR("Can't query IPoIB interface %s: %d\n",
 		       ifname, rc);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 7586b7e..cb49744 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -968,7 +968,7 @@ ksocknal_accept(lnet_ni_t *ni, struct socket *sock)
 	__u32	       peer_ip;
 	int		 peer_port;
 
-	rc = libcfs_sock_getaddr(sock, 1, &peer_ip, &peer_port);
+	rc = lnet_sock_getaddr(sock, 1, &peer_ip, &peer_port);
 	LASSERT(rc == 0);		      /* we succeeded before */
 
 	LIBCFS_ALLOC(cr, sizeof(*cr));
@@ -1378,15 +1378,15 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 	ksocknal_txlist_done(ni, &zombies, 1);
 	ksocknal_peer_decref(peer);
 
- failed_1:
+failed_1:
 	if (hello != NULL)
 		LIBCFS_FREE(hello, offsetof(ksock_hello_msg_t,
 					    kshm_ips[LNET_MAX_INTERFACES]));
 
 	LIBCFS_FREE(conn, sizeof(*conn));
 
- failed_0:
-	libcfs_sock_release(sock);
+failed_0:
+	sock_release(sock);
 	return rc;
 }
 
@@ -2594,7 +2594,7 @@ ksocknal_enumerate_interfaces(ksock_net_t *net)
 	int	 rc;
 	int	 n;
 
-	n = libcfs_ipif_enumerate(&names);
+	n = lnet_ipif_enumerate(&names);
 	if (n <= 0) {
 		CERROR("Can't enumerate interfaces: %d\n", n);
 		return n;
@@ -2608,7 +2608,7 @@ ksocknal_enumerate_interfaces(ksock_net_t *net)
 		if (!strcmp(names[i], "lo")) /* skip the loopback IF */
 			continue;
 
-		rc = libcfs_ipif_query(names[i], &up, &ip, &mask);
+		rc = lnet_ipif_query(names[i], &up, &ip, &mask);
 		if (rc != 0) {
 			CWARN("Can't get interface %s info: %d\n",
 			      names[i], rc);
@@ -2634,7 +2634,7 @@ ksocknal_enumerate_interfaces(ksock_net_t *net)
 		j++;
 	}
 
-	libcfs_ipif_free_enumeration(names, n);
+	lnet_ipif_free_enumeration(names, n);
 
 	if (j == 0)
 		CERROR("Can't find any usable interfaces\n");
@@ -2796,7 +2796,7 @@ ksocknal_startup(lnet_ni_t *ni)
 			if (ni->ni_interfaces[i] == NULL)
 				break;
 
-			rc = libcfs_ipif_query(
+			rc = lnet_ipif_query(
 				ni->ni_interfaces[i], &up,
 				&net->ksnn_interfaces[i].ksni_ipaddr,
 				&net->ksnn_interfaces[i].ksni_netmask);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
index c54c995..f3b4923 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.h
@@ -453,7 +453,7 @@ ksocknal_connsock_decref(ksock_conn_t *conn)
 	LASSERT(atomic_read(&conn->ksnc_sock_refcount) > 0);
 	if (atomic_dec_and_test(&conn->ksnc_sock_refcount)) {
 		LASSERT(conn->ksnc_closing);
-		libcfs_sock_release(conn->ksnc_sock);
+		sock_release(conn->ksnc_sock);
 		conn->ksnc_sock = NULL;
 		ksocknal_finalize_zcreq(conn);
 	}
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index fa7ad88..718a8e2 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -1707,7 +1707,8 @@ ksocknal_recv_hello (lnet_ni_t *ni, ksock_conn_t *conn,
 	timeout = active ? *ksocknal_tunables.ksnd_timeout :
 			    lnet_acceptor_timeout();
 
-	rc = libcfs_sock_read(sock, &hello->kshm_magic, sizeof (hello->kshm_magic), timeout);
+	rc = lnet_sock_read(sock, &hello->kshm_magic,
+			    sizeof(hello->kshm_magic), timeout);
 	if (rc != 0) {
 		CERROR("Error %d reading HELLO from %pI4h\n",
 			rc, &conn->ksnc_ipaddr);
@@ -1726,8 +1727,8 @@ ksocknal_recv_hello (lnet_ni_t *ni, ksock_conn_t *conn,
 		return -EPROTO;
 	}
 
-	rc = libcfs_sock_read(sock, &hello->kshm_version,
-			      sizeof(hello->kshm_version), timeout);
+	rc = lnet_sock_read(sock, &hello->kshm_version,
+			    sizeof(hello->kshm_version), timeout);
 	if (rc != 0) {
 		CERROR("Error %d reading HELLO from %pI4h\n",
 			rc, &conn->ksnc_ipaddr);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib-linux.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib-linux.c
index f5e8ab0..a93f59c 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib-linux.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib-linux.c
@@ -39,9 +39,9 @@
 int
 ksocknal_lib_get_conn_addrs(ksock_conn_t *conn)
 {
-	int rc = libcfs_sock_getaddr(conn->ksnc_sock, 1,
-				     &conn->ksnc_ipaddr,
-				     &conn->ksnc_port);
+	int rc = lnet_sock_getaddr(conn->ksnc_sock, 1,
+				   &conn->ksnc_ipaddr,
+				   &conn->ksnc_port);
 
 	/* Didn't need the {get,put}connsock dance to deref ksnc_sock... */
 	LASSERT(!conn->ksnc_closing);
@@ -51,8 +51,8 @@ ksocknal_lib_get_conn_addrs(ksock_conn_t *conn)
 		return rc;
 	}
 
-	rc = libcfs_sock_getaddr(conn->ksnc_sock, 0,
-				 &conn->ksnc_myipaddr, NULL);
+	rc = lnet_sock_getaddr(conn->ksnc_sock, 0,
+			       &conn->ksnc_myipaddr, NULL);
 	if (rc != 0) {
 		CERROR("Error %d getting sock local IP\n", rc);
 		return rc;
@@ -436,7 +436,7 @@ ksocknal_lib_get_conn_tunables(ksock_conn_t *conn, int *txmem, int *rxmem, int *
 		return -ESHUTDOWN;
 	}
 
-	rc = libcfs_sock_getbuf(sock, txmem, rxmem);
+	rc = lnet_sock_getbuf(sock, txmem, rxmem);
 	if (rc == 0) {
 		len = sizeof(*nagle);
 		rc = kernel_getsockopt(sock, SOL_TCP, TCP_NODELAY,
@@ -498,9 +498,8 @@ ksocknal_lib_setup_sock(struct socket *sock)
 		}
 	}
 
-	rc = libcfs_sock_setbuf(sock,
-				*ksocknal_tunables.ksnd_tx_buffer_size,
-				*ksocknal_tunables.ksnd_rx_buffer_size);
+	rc = lnet_sock_setbuf(sock, *ksocknal_tunables.ksnd_tx_buffer_size,
+			      *ksocknal_tunables.ksnd_rx_buffer_size);
 	if (rc != 0) {
 		CERROR("Can't set buffer tx %d, rx %d buffers: %d\n",
 			*ksocknal_tunables.ksnd_tx_buffer_size,
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
index 8596581..3916790 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
@@ -495,8 +495,8 @@ ksocknal_send_hello_v1(ksock_conn_t *conn, ksock_hello_msg_t *hello)
 	hdr->msg.hello.type = cpu_to_le32 (hello->kshm_ctype);
 	hdr->msg.hello.incarnation = cpu_to_le64 (hello->kshm_src_incarnation);
 
-	rc = libcfs_sock_write(sock, hdr, sizeof(*hdr),
-			       lnet_acceptor_timeout());
+	rc = lnet_sock_write(sock, hdr, sizeof(*hdr),
+			     lnet_acceptor_timeout());
 
 	if (rc != 0) {
 		CNETERR("Error %d sending HELLO hdr to %pI4h/%d\n",
@@ -511,9 +511,9 @@ ksocknal_send_hello_v1(ksock_conn_t *conn, ksock_hello_msg_t *hello)
 		hello->kshm_ips[i] = __cpu_to_le32 (hello->kshm_ips[i]);
 	}
 
-	rc = libcfs_sock_write(sock, hello->kshm_ips,
-			       hello->kshm_nips * sizeof(__u32),
-			       lnet_acceptor_timeout());
+	rc = lnet_sock_write(sock, hello->kshm_ips,
+			     hello->kshm_nips * sizeof(__u32),
+			     lnet_acceptor_timeout());
 	if (rc != 0) {
 		CNETERR("Error %d sending HELLO payload (%d) to %pI4h/%d\n",
 			rc, hello->kshm_nips,
@@ -544,8 +544,8 @@ ksocknal_send_hello_v2(ksock_conn_t *conn, ksock_hello_msg_t *hello)
 		LNET_UNLOCK();
 	}
 
-	rc = libcfs_sock_write(sock, hello, offsetof(ksock_hello_msg_t, kshm_ips),
-			       lnet_acceptor_timeout());
+	rc = lnet_sock_write(sock, hello, offsetof(ksock_hello_msg_t, kshm_ips),
+			     lnet_acceptor_timeout());
 
 	if (rc != 0) {
 		CNETERR("Error %d sending HELLO hdr to %pI4h/%d\n",
@@ -556,9 +556,9 @@ ksocknal_send_hello_v2(ksock_conn_t *conn, ksock_hello_msg_t *hello)
 	if (hello->kshm_nips == 0)
 		return 0;
 
-	rc = libcfs_sock_write(sock, hello->kshm_ips,
-			       hello->kshm_nips * sizeof(__u32),
-			       lnet_acceptor_timeout());
+	rc = lnet_sock_write(sock, hello->kshm_ips,
+			     hello->kshm_nips * sizeof(__u32),
+			     lnet_acceptor_timeout());
 	if (rc != 0) {
 		CNETERR("Error %d sending HELLO payload (%d) to %pI4h/%d\n",
 			rc, hello->kshm_nips,
@@ -583,7 +583,7 @@ ksocknal_recv_hello_v1(ksock_conn_t *conn, ksock_hello_msg_t *hello,
 		return -ENOMEM;
 	}
 
-	rc = libcfs_sock_read(sock, &hdr->src_nid,
+	rc = lnet_sock_read(sock, &hdr->src_nid,
 			      sizeof(*hdr) - offsetof(lnet_hdr_t, src_nid),
 			      timeout);
 	if (rc != 0) {
@@ -619,7 +619,7 @@ ksocknal_recv_hello_v1(ksock_conn_t *conn, ksock_hello_msg_t *hello,
 	if (hello->kshm_nips == 0)
 		goto out;
 
-	rc = libcfs_sock_read(sock, hello->kshm_ips,
+	rc = lnet_sock_read(sock, hello->kshm_ips,
 			      hello->kshm_nips * sizeof(__u32), timeout);
 	if (rc != 0) {
 		CERROR("Error %d reading IPs from ip %pI4h\n",
@@ -656,7 +656,7 @@ ksocknal_recv_hello_v2(ksock_conn_t *conn, ksock_hello_msg_t *hello, int timeout
 	else
 		conn->ksnc_flip = 1;
 
-	rc = libcfs_sock_read(sock, &hello->kshm_src_nid,
+	rc = lnet_sock_read(sock, &hello->kshm_src_nid,
 			      offsetof(ksock_hello_msg_t, kshm_ips) -
 				       offsetof(ksock_hello_msg_t, kshm_src_nid),
 			      timeout);
@@ -687,8 +687,8 @@ ksocknal_recv_hello_v2(ksock_conn_t *conn, ksock_hello_msg_t *hello, int timeout
 	if (hello->kshm_nips == 0)
 		return 0;
 
-	rc = libcfs_sock_read(sock, hello->kshm_ips,
-			      hello->kshm_nips * sizeof(__u32), timeout);
+	rc = lnet_sock_read(sock, hello->kshm_ips,
+			    hello->kshm_nips * sizeof(__u32), timeout);
 	if (rc != 0) {
 		CERROR("Error %d reading IPs from ip %pI4h\n",
 			rc, &conn->ksnc_ipaddr);
diff --git a/drivers/staging/lustre/lnet/lnet/Makefile b/drivers/staging/lustre/lnet/lnet/Makefile
index 336b8ea..52492fb 100644
--- a/drivers/staging/lustre/lnet/lnet/Makefile
+++ b/drivers/staging/lustre/lnet/lnet/Makefile
@@ -1,5 +1,6 @@
 obj-$(CONFIG_LNET) += lnet.o
 
-lnet-y := api-ni.o config.o lib-me.o lib-msg.o lib-eq.o	\
-	  lib-md.o lib-ptl.o lib-move.o module.o lo.o router.o		\
-	  router_proc.o acceptor.o peer.o
+lnet-y := api-ni.o config.o					\
+	  lib-me.o lib-msg.o lib-eq.o lib-md.o lib-ptl.o	\
+	  lib-socket.o lib-move.o module.o lo.o			\
+	  router.o router_proc.o acceptor.o peer.o
diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
index 72fd1bf..bd97099 100644
--- a/drivers/staging/lustre/lnet/lnet/acceptor.c
+++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
@@ -155,9 +155,8 @@ lnet_connect(struct socket **sockp, lnet_nid_t peer_nid,
 	     --port) {
 		/* Iterate through reserved ports. */
 
-		rc = libcfs_sock_connect(&sock, &fatal,
-					 local_ip, port,
-					 peer_ip, peer_port);
+		rc = lnet_sock_connect(&sock, &fatal, local_ip, port,
+				       peer_ip, peer_port);
 		if (rc != 0) {
 			if (fatal)
 				goto failed;
@@ -184,8 +183,7 @@ lnet_connect(struct socket **sockp, lnet_nid_t peer_nid,
 			lnet_net_unlock(LNET_LOCK_EX);
 		}
 
-		rc = libcfs_sock_write(sock, &cr, sizeof(cr),
-				       accept_timeout);
+		rc = lnet_sock_write(sock, &cr, sizeof(cr), accept_timeout);
 		if (rc != 0)
 			goto failed_sock;
 
@@ -197,7 +195,7 @@ lnet_connect(struct socket **sockp, lnet_nid_t peer_nid,
 	goto failed;
 
  failed_sock:
-	libcfs_sock_release(sock);
+	sock_release(sock);
  failed:
 	lnet_connect_console_error(rc, peer_nid, peer_ip, peer_port);
 	return rc;
@@ -220,7 +218,7 @@ lnet_accept(struct socket *sock, __u32 magic)
 
 	LASSERT(sizeof(cr) <= 16);	     /* not too big for the stack */
 
-	rc = libcfs_sock_getaddr(sock, 1, &peer_ip, &peer_port);
+	rc = lnet_sock_getaddr(sock, 1, &peer_ip, &peer_port);
 	LASSERT(rc == 0);		      /* we succeeded before */
 
 	if (!lnet_accept_magic(magic, LNET_PROTO_ACCEPTOR_MAGIC)) {
@@ -234,7 +232,7 @@ lnet_accept(struct socket *sock, __u32 magic)
 			memset(&cr, 0, sizeof(cr));
 			cr.acr_magic = LNET_PROTO_ACCEPTOR_MAGIC;
 			cr.acr_version = LNET_PROTO_ACCEPTOR_VERSION;
-			rc = libcfs_sock_write(sock, &cr, sizeof(cr),
+			rc = lnet_sock_write(sock, &cr, sizeof(cr),
 					       accept_timeout);
 
 			if (rc != 0)
@@ -257,9 +255,8 @@ lnet_accept(struct socket *sock, __u32 magic)
 
 	flip = (magic != LNET_PROTO_ACCEPTOR_MAGIC);
 
-	rc = libcfs_sock_read(sock, &cr.acr_version,
-			      sizeof(cr.acr_version),
-			      accept_timeout);
+	rc = lnet_sock_read(sock, &cr.acr_version, sizeof(cr.acr_version),
+			    accept_timeout);
 	if (rc != 0) {
 		CERROR("Error %d reading connection request version from %pI4h\n",
 			rc, &peer_ip);
@@ -280,7 +277,7 @@ lnet_accept(struct socket *sock, __u32 magic)
 		cr.acr_magic = LNET_PROTO_ACCEPTOR_MAGIC;
 		cr.acr_version = LNET_PROTO_ACCEPTOR_VERSION;
 
-		rc = libcfs_sock_write(sock, &cr, sizeof(cr),
+		rc = lnet_sock_write(sock, &cr, sizeof(cr),
 				       accept_timeout);
 
 		if (rc != 0)
@@ -289,7 +286,7 @@ lnet_accept(struct socket *sock, __u32 magic)
 		return -EPROTO;
 	}
 
-	rc = libcfs_sock_read(sock, &cr.acr_nid,
+	rc = lnet_sock_read(sock, &cr.acr_nid,
 			      sizeof(cr) -
 			      offsetof(lnet_acceptor_connreq_t, acr_nid),
 			      accept_timeout);
@@ -343,8 +340,8 @@ lnet_acceptor(void *arg)
 
 	cfs_block_allsigs();
 
-	rc = libcfs_sock_listen(&lnet_acceptor_state.pta_sock,
-				0, accept_port, accept_backlog);
+	rc = lnet_sock_listen(&lnet_acceptor_state.pta_sock, 0, accept_port,
+			      accept_backlog);
 	if (rc != 0) {
 		if (rc == -EADDRINUSE)
 			LCONSOLE_ERROR_MSG(0x122, "Can't start acceptor on port %d: port already in use\n",
@@ -367,7 +364,7 @@ lnet_acceptor(void *arg)
 
 	while (!lnet_acceptor_state.pta_shutdown) {
 
-		rc = libcfs_sock_accept(&newsock, lnet_acceptor_state.pta_sock);
+		rc = lnet_sock_accept(&newsock, lnet_acceptor_state.pta_sock);
 		if (rc != 0) {
 			if (rc != -EAGAIN) {
 				CWARN("Accept error %d: pausing...\n", rc);
@@ -377,13 +374,13 @@ lnet_acceptor(void *arg)
 			continue;
 		}
 
-		/* maybe we're waken up with libcfs_sock_abort_accept() */
+		/* maybe we're waken up with lnet_sock_abort_accept() */
 		if (lnet_acceptor_state.pta_shutdown) {
-			libcfs_sock_release(newsock);
+			sock_release(newsock);
 			break;
 		}
 
-		rc = libcfs_sock_getaddr(newsock, 1, &peer_ip, &peer_port);
+		rc = lnet_sock_getaddr(newsock, 1, &peer_ip, &peer_port);
 		if (rc != 0) {
 			CERROR("Can't determine new connection's address\n");
 			goto failed;
@@ -395,7 +392,7 @@ lnet_acceptor(void *arg)
 			goto failed;
 		}
 
-		rc = libcfs_sock_read(newsock, &magic, sizeof(magic),
+		rc = lnet_sock_read(newsock, &magic, sizeof(magic),
 				      accept_timeout);
 		if (rc != 0) {
 			CERROR("Error %d reading connection request from %pI4h\n",
@@ -410,10 +407,10 @@ lnet_acceptor(void *arg)
 		continue;
 
 failed:
-		libcfs_sock_release(newsock);
+		sock_release(newsock);
 	}
 
-	libcfs_sock_release(lnet_acceptor_state.pta_sock);
+	sock_release(lnet_acceptor_state.pta_sock);
 	lnet_acceptor_state.pta_sock = NULL;
 
 	CDEBUG(D_NET, "Acceptor stopping\n");
@@ -493,7 +490,7 @@ lnet_acceptor_stop(void)
 		return;
 
 	lnet_acceptor_state.pta_shutdown = 1;
-	libcfs_sock_abort_accept(lnet_acceptor_state.pta_sock);
+	wake_up_all(sk_sleep(lnet_acceptor_state.pta_sock->sk));
 
 	/* block until acceptor signals exit */
 	wait_for_completion(&lnet_acceptor_state.pta_signal);
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index 2dc4c4a..d8c8f2e 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -1118,7 +1118,7 @@ lnet_ipaddr_enumerate(__u32 **ipaddrsp)
 	__u32     *ipaddrs2;
 	int	nip;
 	char     **ifnames;
-	int	nif = libcfs_ipif_enumerate(&ifnames);
+	int	nif = lnet_ipif_enumerate(&ifnames);
 	int	i;
 	int	rc;
 
@@ -1128,7 +1128,7 @@ lnet_ipaddr_enumerate(__u32 **ipaddrsp)
 	LIBCFS_ALLOC(ipaddrs, nif * sizeof(*ipaddrs));
 	if (ipaddrs == NULL) {
 		CERROR("Can't allocate ipaddrs[%d]\n", nif);
-		libcfs_ipif_free_enumeration(ifnames, nif);
+		lnet_ipif_free_enumeration(ifnames, nif);
 		return -ENOMEM;
 	}
 
@@ -1136,8 +1136,7 @@ lnet_ipaddr_enumerate(__u32 **ipaddrsp)
 		if (!strcmp(ifnames[i], "lo"))
 			continue;
 
-		rc = libcfs_ipif_query(ifnames[i], &up,
-				       &ipaddrs[nip], &netmask);
+		rc = lnet_ipif_query(ifnames[i], &up, &ipaddrs[nip], &netmask);
 		if (rc != 0) {
 			CWARN("Can't query interface %s: %d\n",
 			      ifnames[i], rc);
@@ -1153,7 +1152,7 @@ lnet_ipaddr_enumerate(__u32 **ipaddrsp)
 		nip++;
 	}
 
-	libcfs_ipif_free_enumeration(ifnames, nif);
+	lnet_ipif_free_enumeration(ifnames, nif);
 
 	if (nip == nif) {
 		*ipaddrsp = ipaddrs;
@@ -1237,8 +1236,7 @@ lnet_set_ip_niaddr(lnet_ni_t *ni)
 			return -EPERM;
 		}
 
-		rc = libcfs_ipif_query(ni->ni_interfaces[0],
-				       &up, &ip, &netmask);
+		rc = lnet_ipif_query(ni->ni_interfaces[0], &up, &ip, &netmask);
 		if (rc != 0) {
 			CERROR("Net %s can't query interface %s: %d\n",
 			       libcfs_net2str(net), ni->ni_interfaces[0], rc);
@@ -1255,7 +1253,7 @@ lnet_set_ip_niaddr(lnet_ni_t *ni)
 		return 0;
 	}
 
-	n = libcfs_ipif_enumerate(&names);
+	n = lnet_ipif_enumerate(&names);
 	if (n <= 0) {
 		CERROR("Net %s can't enumerate interfaces: %d\n",
 		       libcfs_net2str(net), n);
@@ -1266,8 +1264,7 @@ lnet_set_ip_niaddr(lnet_ni_t *ni)
 		if (!strcmp(names[i], "lo")) /* skip the loopback IF */
 			continue;
 
-		rc = libcfs_ipif_query(names[i], &up, &ip, &netmask);
-
+		rc = lnet_ipif_query(names[i], &up, &ip, &netmask);
 		if (rc != 0) {
 			CWARN("Net %s can't query interface %s: %d\n",
 			      libcfs_net2str(net), names[i], rc);
@@ -1280,13 +1277,13 @@ lnet_set_ip_niaddr(lnet_ni_t *ni)
 			continue;
 		}
 
-		libcfs_ipif_free_enumeration(names, n);
+		lnet_ipif_free_enumeration(names, n);
 		ni->ni_nid = LNET_MKNID(net, ip);
 		return 0;
 	}
 
 	CERROR("Net %s can't find any interfaces\n", libcfs_net2str(net));
-	libcfs_ipif_free_enumeration(names, n);
+	lnet_ipif_free_enumeration(names, n);
 	return -ENOENT;
 }
 EXPORT_SYMBOL(lnet_set_ip_niaddr);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
new file mode 100644
index 0000000..da7b871
--- /dev/null
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -0,0 +1,616 @@
+/*
+ * GPL HEADER START
+ *
+ * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 only,
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License version 2 for more details (a copy is included
+ * in the LICENSE file that accompanied this code).
+ *
+ * You should have received a copy of the GNU General Public License
+ * version 2 along with this program; If not, see
+ * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
+ *
+ * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
+ * CA 95054 USA or visit www.sun.com if you need additional information or
+ * have any questions.
+ *
+ * GPL HEADER END
+ */
+/*
+ * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
+ * Use is subject to license terms.
+ *
+ * Copyright (c) 2012, 2014, Intel Corporation.
+ */
+/*
+ * This file is part of Lustre, http://www.lustre.org/
+ * Lustre is a trademark of Sun Microsystems, Inc.
+ */
+#define DEBUG_SUBSYSTEM S_LNET
+
+#include <linux/if.h>
+#include <linux/in.h>
+#include <linux/net.h>
+#include <linux/file.h>
+#include <linux/pagemap.h>
+/* For sys_open & sys_close */
+#include <linux/syscalls.h>
+#include <net/sock.h>
+
+#include "../../include/linux/libcfs/libcfs.h"
+#include "../../include/linux/lnet/lib-lnet.h"
+
+static int
+kernel_sock_unlocked_ioctl(struct file *filp, int cmd, unsigned long arg)
+{
+	mm_segment_t oldfs = get_fs();
+	int err;
+
+	set_fs(KERNEL_DS);
+	err = filp->f_op->unlocked_ioctl(filp, cmd, arg);
+	set_fs(oldfs);
+
+	return err;
+}
+
+static int
+lnet_sock_ioctl(int cmd, unsigned long arg)
+{
+	struct file *sock_filp;
+	struct socket *sock;
+	int fd = -1;
+	int rc;
+
+	rc = sock_create(PF_INET, SOCK_STREAM, 0, &sock);
+	if (rc != 0) {
+		CERROR("Can't create socket: %d\n", rc);
+		return rc;
+	}
+
+	sock_filp = sock_alloc_file(sock, 0, NULL);
+	if (!sock_filp) {
+		rc = -ENOMEM;
+		sock_release(sock);
+		goto out;
+	}
+
+	rc = kernel_sock_unlocked_ioctl(sock_filp, cmd, arg);
+
+	fput(sock_filp);
+out:
+	if (fd >= 0)
+		sys_close(fd);
+	return rc;
+}
+
+int
+lnet_ipif_query(char *name, int *up, __u32 *ip, __u32 *mask)
+{
+	struct ifreq ifr;
+	int nob;
+	int rc;
+	__u32 val;
+
+	nob = strnlen(name, IFNAMSIZ);
+	if (nob == IFNAMSIZ) {
+		CERROR("Interface name %s too long\n", name);
+		return -EINVAL;
+	}
+
+	CLASSERT(sizeof(ifr.ifr_name) >= IFNAMSIZ);
+
+	if (strlen(name) > sizeof(ifr.ifr_name)-1)
+		return -E2BIG;
+	strncpy(ifr.ifr_name, name, sizeof(ifr.ifr_name));
+
+	rc = lnet_sock_ioctl(SIOCGIFFLAGS, (unsigned long)&ifr);
+	if (rc != 0) {
+		CERROR("Can't get flags for interface %s\n", name);
+		return rc;
+	}
+
+	if ((ifr.ifr_flags & IFF_UP) == 0) {
+		CDEBUG(D_NET, "Interface %s down\n", name);
+		*up = 0;
+		*ip = *mask = 0;
+		return 0;
+	}
+	*up = 1;
+
+	if (strlen(name) > sizeof(ifr.ifr_name)-1)
+		return -E2BIG;
+	strncpy(ifr.ifr_name, name, sizeof(ifr.ifr_name));
+
+	ifr.ifr_addr.sa_family = AF_INET;
+	rc = lnet_sock_ioctl(SIOCGIFADDR, (unsigned long)&ifr);
+
+	if (rc != 0) {
+		CERROR("Can't get IP address for interface %s\n", name);
+		return rc;
+	}
+
+	val = ((struct sockaddr_in *)&ifr.ifr_addr)->sin_addr.s_addr;
+	*ip = ntohl(val);
+
+	if (strlen(name) > sizeof(ifr.ifr_name)-1)
+		return -E2BIG;
+	strncpy(ifr.ifr_name, name, sizeof(ifr.ifr_name));
+
+	ifr.ifr_addr.sa_family = AF_INET;
+	rc = lnet_sock_ioctl(SIOCGIFNETMASK, (unsigned long)&ifr);
+	if (rc != 0) {
+		CERROR("Can't get netmask for interface %s\n", name);
+		return rc;
+	}
+
+	val = ((struct sockaddr_in *)&ifr.ifr_netmask)->sin_addr.s_addr;
+	*mask = ntohl(val);
+
+	return 0;
+}
+EXPORT_SYMBOL(lnet_ipif_query);
+
+void
+lnet_ipif_free_enumeration(char **names, int n)
+{
+	int i;
+
+	LASSERT(n > 0);
+
+	for (i = 0; i < n && names[i] != NULL; i++)
+		LIBCFS_FREE(names[i], IFNAMSIZ);
+
+	LIBCFS_FREE(names, n * sizeof(*names));
+}
+EXPORT_SYMBOL(lnet_ipif_free_enumeration);
+
+int
+lnet_ipif_enumerate(char ***namesp)
+{
+	/* Allocate and fill in 'names', returning # interfaces/error */
+	char **names;
+	int toobig;
+	int nalloc;
+	int nfound;
+	struct ifreq *ifr;
+	struct ifconf ifc;
+	int rc;
+	int nob;
+	int i;
+
+	nalloc = 16;	/* first guess@max interfaces */
+	toobig = 0;
+	for (;;) {
+		if (nalloc * sizeof(*ifr) > PAGE_CACHE_SIZE) {
+			toobig = 1;
+			nalloc = PAGE_CACHE_SIZE/sizeof(*ifr);
+			CWARN("Too many interfaces: only enumerating "
+			      "first %d\n", nalloc);
+		}
+
+		LIBCFS_ALLOC(ifr, nalloc * sizeof(*ifr));
+		if (ifr == NULL) {
+			CERROR("ENOMEM enumerating up to %d interfaces\n",
+			       nalloc);
+			rc = -ENOMEM;
+			goto out0;
+		}
+
+		ifc.ifc_buf = (char *)ifr;
+		ifc.ifc_len = nalloc * sizeof(*ifr);
+
+		rc = lnet_sock_ioctl(SIOCGIFCONF, (unsigned long)&ifc);
+		if (rc < 0) {
+			CERROR("Error %d enumerating interfaces\n", rc);
+			goto out1;
+		}
+
+		LASSERT(rc == 0);
+
+		nfound = ifc.ifc_len/sizeof(*ifr);
+		LASSERT(nfound <= nalloc);
+
+		if (nfound < nalloc || toobig)
+			break;
+
+		LIBCFS_FREE(ifr, nalloc * sizeof(*ifr));
+		nalloc *= 2;
+	}
+
+	if (nfound == 0)
+		goto out1;
+
+	LIBCFS_ALLOC(names, nfound * sizeof(*names));
+	if (names == NULL) {
+		rc = -ENOMEM;
+		goto out1;
+	}
+
+	for (i = 0; i < nfound; i++) {
+		nob = strnlen(ifr[i].ifr_name, IFNAMSIZ);
+		if (nob == IFNAMSIZ) {
+			/* no space for terminating NULL */
+			CERROR("interface name %.*s too long (%d max)\n",
+			       nob, ifr[i].ifr_name, IFNAMSIZ);
+			rc = -ENAMETOOLONG;
+			goto out2;
+		}
+
+		LIBCFS_ALLOC(names[i], IFNAMSIZ);
+		if (names[i] == NULL) {
+			rc = -ENOMEM;
+			goto out2;
+		}
+
+		memcpy(names[i], ifr[i].ifr_name, nob);
+		names[i][nob] = 0;
+	}
+
+	*namesp = names;
+	rc = nfound;
+
+ out2:
+	if (rc < 0)
+		lnet_ipif_free_enumeration(names, nfound);
+ out1:
+	LIBCFS_FREE(ifr, nalloc * sizeof(*ifr));
+ out0:
+	return rc;
+}
+EXPORT_SYMBOL(lnet_ipif_enumerate);
+
+int
+lnet_sock_write(struct socket *sock, void *buffer, int nob, int timeout)
+{
+	int rc;
+	long jiffies_left = timeout * msecs_to_jiffies(MSEC_PER_SEC);
+	unsigned long then;
+	struct timeval tv;
+
+	LASSERT(nob > 0);
+	/* Caller may pass a zero timeout if she thinks the socket buffer is
+	 * empty enough to take the whole message immediately */
+
+	for (;;) {
+		struct kvec  iov = {
+			.iov_base = buffer,
+			.iov_len  = nob
+		};
+		struct msghdr msg = {
+			.msg_flags	= (timeout == 0) ? MSG_DONTWAIT : 0
+		};
+
+		if (timeout != 0) {
+			/* Set send timeout to remaining time */
+			tv = (struct timeval) {
+				.tv_sec = jiffies_left /
+					  msecs_to_jiffies(MSEC_PER_SEC),
+				.tv_usec = ((jiffies_left %
+					     msecs_to_jiffies(MSEC_PER_SEC)) *
+					     USEC_PER_SEC) /
+					     msecs_to_jiffies(MSEC_PER_SEC)
+			};
+
+			rc = kernel_setsockopt(sock, SOL_SOCKET, SO_SNDTIMEO,
+					       (char *)&tv, sizeof(tv));
+			if (rc != 0) {
+				CERROR("Can't set socket send timeout "
+				       "%ld.%06d: %d\n",
+				       (long)tv.tv_sec, (int)tv.tv_usec, rc);
+				return rc;
+			}
+		}
+
+		then = jiffies;
+		rc = kernel_sendmsg(sock, &msg, &iov, 1, nob);
+		jiffies_left -= jiffies - then;
+
+		if (rc == nob)
+			return 0;
+
+		if (rc < 0)
+			return rc;
+
+		if (rc == 0) {
+			CERROR("Unexpected zero rc\n");
+			return -ECONNABORTED;
+		}
+
+		if (jiffies_left <= 0)
+			return -EAGAIN;
+
+		buffer = ((char *)buffer) + rc;
+		nob -= rc;
+	}
+	return 0;
+}
+EXPORT_SYMBOL(lnet_sock_write);
+
+int
+lnet_sock_read(struct socket *sock, void *buffer, int nob, int timeout)
+{
+	int rc;
+	long jiffies_left = timeout * msecs_to_jiffies(MSEC_PER_SEC);
+	unsigned long then;
+	struct timeval tv;
+
+	LASSERT(nob > 0);
+	LASSERT(jiffies_left > 0);
+
+	for (;;) {
+		struct kvec  iov = {
+			.iov_base = buffer,
+			.iov_len  = nob
+		};
+		struct msghdr msg = {
+			.msg_flags	= 0
+		};
+
+		/* Set receive timeout to remaining time */
+		tv = (struct timeval) {
+			.tv_sec = jiffies_left / msecs_to_jiffies(MSEC_PER_SEC),
+			.tv_usec = ((jiffies_left %
+					msecs_to_jiffies(MSEC_PER_SEC)) *
+					USEC_PER_SEC) /
+					msecs_to_jiffies(MSEC_PER_SEC)
+		};
+		rc = kernel_setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO,
+				       (char *)&tv, sizeof(tv));
+		if (rc != 0) {
+			CERROR("Can't set socket recv timeout %ld.%06d: %d\n",
+			       (long)tv.tv_sec, (int)tv.tv_usec, rc);
+			return rc;
+		}
+
+		then = jiffies;
+		rc = kernel_recvmsg(sock, &msg, &iov, 1, nob, 0);
+		jiffies_left -= jiffies - then;
+
+		if (rc < 0)
+			return rc;
+
+		if (rc == 0)
+			return -ECONNRESET;
+
+		buffer = ((char *)buffer) + rc;
+		nob -= rc;
+
+		if (nob == 0)
+			return 0;
+
+		if (jiffies_left <= 0)
+			return -ETIMEDOUT;
+	}
+}
+EXPORT_SYMBOL(lnet_sock_read);
+
+static int
+lnet_sock_create(struct socket **sockp, int *fatal,
+		 __u32 local_ip, int local_port)
+{
+	struct sockaddr_in locaddr;
+	struct socket *sock;
+	int rc;
+	int option;
+
+	/* All errors are fatal except bind failure if the port is in use */
+	*fatal = 1;
+
+	rc = sock_create(PF_INET, SOCK_STREAM, 0, &sock);
+	*sockp = sock;
+	if (rc != 0) {
+		CERROR("Can't create socket: %d\n", rc);
+		return rc;
+	}
+
+	option = 1;
+	rc = kernel_setsockopt(sock, SOL_SOCKET, SO_REUSEADDR,
+			       (char *)&option, sizeof(option));
+	if (rc != 0) {
+		CERROR("Can't set SO_REUSEADDR for socket: %d\n", rc);
+		goto failed;
+	}
+
+	if (local_ip != 0 || local_port != 0) {
+		memset(&locaddr, 0, sizeof(locaddr));
+		locaddr.sin_family = AF_INET;
+		locaddr.sin_port = htons(local_port);
+		locaddr.sin_addr.s_addr = (local_ip == 0) ?
+					  INADDR_ANY : htonl(local_ip);
+
+		rc = kernel_bind(sock, (struct sockaddr *)&locaddr,
+				 sizeof(locaddr));
+		if (rc == -EADDRINUSE) {
+			CDEBUG(D_NET, "Port %d already in use\n", local_port);
+			*fatal = 0;
+			goto failed;
+		}
+		if (rc != 0) {
+			CERROR("Error trying to bind to port %d: %d\n",
+			       local_port, rc);
+			goto failed;
+		}
+	}
+	return 0;
+
+failed:
+	sock_release(sock);
+	return rc;
+}
+
+int
+lnet_sock_setbuf(struct socket *sock, int txbufsize, int rxbufsize)
+{
+	int option;
+	int rc;
+
+	if (txbufsize != 0) {
+		option = txbufsize;
+		rc = kernel_setsockopt(sock, SOL_SOCKET, SO_SNDBUF,
+				       (char *)&option, sizeof(option));
+		if (rc != 0) {
+			CERROR("Can't set send buffer %d: %d\n",
+				option, rc);
+			return rc;
+		}
+	}
+
+	if (rxbufsize != 0) {
+		option = rxbufsize;
+		rc = kernel_setsockopt(sock, SOL_SOCKET, SO_RCVBUF,
+				       (char *)&option, sizeof(option));
+		if (rc != 0) {
+			CERROR("Can't set receive buffer %d: %d\n",
+				option, rc);
+			return rc;
+		}
+	}
+	return 0;
+}
+EXPORT_SYMBOL(lnet_sock_setbuf);
+
+int
+lnet_sock_getaddr(struct socket *sock, bool remote, __u32 *ip, int *port)
+{
+	struct sockaddr_in sin;
+	int len = sizeof(sin);
+	int rc;
+
+	if (remote)
+		rc = kernel_getpeername(sock, (struct sockaddr *)&sin, &len);
+	else
+		rc = kernel_getsockname(sock, (struct sockaddr *)&sin, &len);
+	if (rc != 0) {
+		CERROR("Error %d getting sock %s IP/port\n",
+			rc, remote ? "peer" : "local");
+		return rc;
+	}
+
+	if (ip != NULL)
+		*ip = ntohl(sin.sin_addr.s_addr);
+
+	if (port != NULL)
+		*port = ntohs(sin.sin_port);
+
+	return 0;
+}
+EXPORT_SYMBOL(lnet_sock_getaddr);
+
+int
+lnet_sock_getbuf(struct socket *sock, int *txbufsize, int *rxbufsize)
+{
+	if (txbufsize != NULL)
+		*txbufsize = sock->sk->sk_sndbuf;
+
+	if (rxbufsize != NULL)
+		*rxbufsize = sock->sk->sk_rcvbuf;
+
+	return 0;
+}
+EXPORT_SYMBOL(lnet_sock_getbuf);
+
+int
+lnet_sock_listen(struct socket **sockp,
+		   __u32 local_ip, int local_port, int backlog)
+{
+	int fatal;
+	int rc;
+
+	rc = lnet_sock_create(sockp, &fatal, local_ip, local_port);
+	if (rc != 0) {
+		if (!fatal)
+			CERROR("Can't create socket: port %d already in use\n",
+			       local_port);
+		return rc;
+	}
+
+	rc = kernel_listen(*sockp, backlog);
+	if (rc == 0)
+		return 0;
+
+	CERROR("Can't set listen backlog %d: %d\n", backlog, rc);
+	sock_release(*sockp);
+	return rc;
+}
+
+int
+lnet_sock_accept(struct socket **newsockp, struct socket *sock)
+{
+	wait_queue_t wait;
+	struct socket *newsock;
+	int rc;
+
+	/* XXX this should add a ref to sock->ops->owner, if
+	 * TCP could be a module */
+	rc = sock_create_lite(PF_PACKET, sock->type, IPPROTO_TCP, &newsock);
+	if (rc) {
+		CERROR("Can't allocate socket\n");
+		return rc;
+	}
+
+	newsock->ops = sock->ops;
+
+	rc = sock->ops->accept(sock, newsock, O_NONBLOCK);
+	if (rc == -EAGAIN) {
+		/* Nothing ready, so wait for activity */
+		init_waitqueue_entry(&wait, current);
+		add_wait_queue(sk_sleep(sock->sk), &wait);
+		set_current_state(TASK_INTERRUPTIBLE);
+		schedule();
+		remove_wait_queue(sk_sleep(sock->sk), &wait);
+		rc = sock->ops->accept(sock, newsock, O_NONBLOCK);
+	}
+
+	if (rc != 0)
+		goto failed;
+
+	*newsockp = newsock;
+	return 0;
+
+failed:
+	sock_release(newsock);
+	return rc;
+}
+
+int
+lnet_sock_connect(struct socket **sockp, int *fatal,
+		  __u32 local_ip, int local_port,
+		  __u32 peer_ip, int peer_port)
+{
+	struct sockaddr_in srvaddr;
+	int rc;
+
+	rc = lnet_sock_create(sockp, fatal, local_ip, local_port);
+	if (rc != 0)
+		return rc;
+
+	memset(&srvaddr, 0, sizeof(srvaddr));
+	srvaddr.sin_family = AF_INET;
+	srvaddr.sin_port = htons(peer_port);
+	srvaddr.sin_addr.s_addr = htonl(peer_ip);
+
+	rc = kernel_connect(*sockp, (struct sockaddr *)&srvaddr,
+			    sizeof(srvaddr), 0);
+	if (rc == 0)
+		return 0;
+
+	/* EADDRNOTAVAIL probably means we're already connected to the same
+	 * peer/port on the same local port on a differently typed
+	 * connection.	Let our caller retry with a different local
+	 * port... */
+	*fatal = !(rc == -EADDRNOTAVAIL);
+
+	CDEBUG_LIMIT(*fatal ? D_NETERROR : D_NET,
+	       "Error %d connecting %pI4h/%d -> %pI4h/%d\n", rc,
+	       &local_ip, local_port, &peer_ip, peer_port);
+
+	sock_release(*sockp);
+	return rc;
+}
diff --git a/drivers/staging/lustre/lustre/libcfs/Makefile b/drivers/staging/lustre/lustre/libcfs/Makefile
index fabdd3e..ec98f44 100644
--- a/drivers/staging/lustre/lustre/libcfs/Makefile
+++ b/drivers/staging/lustre/lustre/libcfs/Makefile
@@ -2,7 +2,6 @@ obj-$(CONFIG_LUSTRE_FS) += libcfs.o
 
 libcfs-linux-objs := linux-tracefile.o linux-debug.o
 libcfs-linux-objs += linux-prim.o linux-cpu.o
-libcfs-linux-objs += linux-tcpip.o
 libcfs-linux-objs += linux-curproc.o
 libcfs-linux-objs += linux-module.o
 libcfs-linux-objs += linux-crypto.o
diff --git a/drivers/staging/lustre/lustre/libcfs/linux/linux-tcpip.c b/drivers/staging/lustre/lustre/libcfs/linux/linux-tcpip.c
deleted file mode 100644
index f2462e7..0000000
--- a/drivers/staging/lustre/lustre/libcfs/linux/linux-tcpip.c
+++ /dev/null
@@ -1,623 +0,0 @@
-/*
- * GPL HEADER START
- *
- * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 only,
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License version 2 for more details (a copy is included
- * in the LICENSE file that accompanied this code).
- *
- * You should have received a copy of the GNU General Public License
- * version 2 along with this program; If not, see
- * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
- *
- * Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa Clara,
- * CA 95054 USA or visit www.sun.com if you need additional information or
- * have any questions.
- *
- * GPL HEADER END
- */
-/*
- * Copyright (c) 2008, 2010, Oracle and/or its affiliates. All rights reserved.
- * Use is subject to license terms.
- *
- * Copyright (c) 2012, Intel Corporation.
- */
-/*
- * This file is part of Lustre, http://www.lustre.org/
- * Lustre is a trademark of Sun Microsystems, Inc.
- */
-#define DEBUG_SUBSYSTEM S_LNET
-
-#include "../../../include/linux/libcfs/libcfs.h"
-
-#include <linux/if.h>
-#include <linux/in.h>
-#include <linux/file.h>
-/* For sys_open & sys_close */
-#include <linux/syscalls.h>
-
-static int
-libcfs_sock_ioctl(int cmd, unsigned long arg)
-{
-	mm_segment_t	oldmm = get_fs();
-	struct socket  *sock;
-	int		rc;
-	struct file    *sock_filp;
-
-	rc = sock_create (PF_INET, SOCK_STREAM, 0, &sock);
-	if (rc != 0) {
-		CERROR ("Can't create socket: %d\n", rc);
-		return rc;
-	}
-
-	sock_filp = sock_alloc_file(sock, 0, NULL);
-	if (IS_ERR(sock_filp)) {
-		sock_release(sock);
-		rc = PTR_ERR(sock_filp);
-		goto out;
-	}
-
-	set_fs(KERNEL_DS);
-	if (sock_filp->f_op->unlocked_ioctl)
-		rc = sock_filp->f_op->unlocked_ioctl(sock_filp, cmd, arg);
-	set_fs(oldmm);
-
-	fput(sock_filp);
-out:
-	return rc;
-}
-
-int
-libcfs_ipif_query (char *name, int *up, __u32 *ip, __u32 *mask)
-{
-	struct ifreq   ifr;
-	int	    nob;
-	int	    rc;
-	__u32	  val;
-
-	nob = strnlen(name, IFNAMSIZ);
-	if (nob == IFNAMSIZ) {
-		CERROR("Interface name %s too long\n", name);
-		return -EINVAL;
-	}
-
-	CLASSERT (sizeof(ifr.ifr_name) >= IFNAMSIZ);
-
-	strcpy(ifr.ifr_name, name);
-	rc = libcfs_sock_ioctl(SIOCGIFFLAGS, (unsigned long)&ifr);
-
-	if (rc != 0) {
-		CERROR("Can't get flags for interface %s\n", name);
-		return rc;
-	}
-
-	if ((ifr.ifr_flags & IFF_UP) == 0) {
-		CDEBUG(D_NET, "Interface %s down\n", name);
-		*up = 0;
-		*ip = *mask = 0;
-		return 0;
-	}
-
-	*up = 1;
-
-	strcpy(ifr.ifr_name, name);
-	ifr.ifr_addr.sa_family = AF_INET;
-	rc = libcfs_sock_ioctl(SIOCGIFADDR, (unsigned long)&ifr);
-
-	if (rc != 0) {
-		CERROR("Can't get IP address for interface %s\n", name);
-		return rc;
-	}
-
-	val = ((struct sockaddr_in *)&ifr.ifr_addr)->sin_addr.s_addr;
-	*ip = ntohl(val);
-
-	strcpy(ifr.ifr_name, name);
-	ifr.ifr_addr.sa_family = AF_INET;
-	rc = libcfs_sock_ioctl(SIOCGIFNETMASK, (unsigned long)&ifr);
-
-	if (rc != 0) {
-		CERROR("Can't get netmask for interface %s\n", name);
-		return rc;
-	}
-
-	val = ((struct sockaddr_in *)&ifr.ifr_netmask)->sin_addr.s_addr;
-	*mask = ntohl(val);
-
-	return 0;
-}
-
-EXPORT_SYMBOL(libcfs_ipif_query);
-
-int
-libcfs_ipif_enumerate (char ***namesp)
-{
-	/* Allocate and fill in 'names', returning # interfaces/error */
-	char	   **names;
-	int	     toobig;
-	int	     nalloc;
-	int	     nfound;
-	struct ifreq   *ifr;
-	struct ifconf   ifc;
-	int	     rc;
-	int	     nob;
-	int	     i;
-
-
-	nalloc = 16;	/* first guess at max interfaces */
-	toobig = 0;
-	for (;;) {
-		if (nalloc * sizeof(*ifr) > PAGE_CACHE_SIZE) {
-			toobig = 1;
-			nalloc = PAGE_CACHE_SIZE/sizeof(*ifr);
-			CWARN("Too many interfaces: only enumerating first %d\n",
-			      nalloc);
-		}
-
-		LIBCFS_ALLOC(ifr, nalloc * sizeof(*ifr));
-		if (ifr == NULL) {
-			CERROR ("ENOMEM enumerating up to %d interfaces\n", nalloc);
-			rc = -ENOMEM;
-			goto out0;
-		}
-
-		ifc.ifc_buf = (char *)ifr;
-		ifc.ifc_len = nalloc * sizeof(*ifr);
-
-		rc = libcfs_sock_ioctl(SIOCGIFCONF, (unsigned long)&ifc);
-
-		if (rc < 0) {
-			CERROR ("Error %d enumerating interfaces\n", rc);
-			goto out1;
-		}
-
-		LASSERT (rc == 0);
-
-		nfound = ifc.ifc_len/sizeof(*ifr);
-		LASSERT (nfound <= nalloc);
-
-		if (nfound < nalloc || toobig)
-			break;
-
-		LIBCFS_FREE(ifr, nalloc * sizeof(*ifr));
-		nalloc *= 2;
-	}
-
-	if (nfound == 0)
-		goto out1;
-
-	LIBCFS_ALLOC(names, nfound * sizeof(*names));
-	if (names == NULL) {
-		rc = -ENOMEM;
-		goto out1;
-	}
-
-	for (i = 0; i < nfound; i++) {
-
-		nob = strnlen (ifr[i].ifr_name, IFNAMSIZ);
-		if (nob == IFNAMSIZ) {
-			/* no space for terminating NULL */
-			CERROR("interface name %.*s too long (%d max)\n",
-			       nob, ifr[i].ifr_name, IFNAMSIZ);
-			rc = -ENAMETOOLONG;
-			goto out2;
-		}
-
-		LIBCFS_ALLOC(names[i], IFNAMSIZ);
-		if (names[i] == NULL) {
-			rc = -ENOMEM;
-			goto out2;
-		}
-
-		memcpy(names[i], ifr[i].ifr_name, nob);
-		names[i][nob] = 0;
-	}
-
-	*namesp = names;
-	rc = nfound;
-
- out2:
-	if (rc < 0)
-		libcfs_ipif_free_enumeration(names, nfound);
- out1:
-	LIBCFS_FREE(ifr, nalloc * sizeof(*ifr));
- out0:
-	return rc;
-}
-
-EXPORT_SYMBOL(libcfs_ipif_enumerate);
-
-void
-libcfs_ipif_free_enumeration (char **names, int n)
-{
-	int      i;
-
-	LASSERT (n > 0);
-
-	for (i = 0; i < n && names[i] != NULL; i++)
-		LIBCFS_FREE(names[i], IFNAMSIZ);
-
-	LIBCFS_FREE(names, n * sizeof(*names));
-}
-
-EXPORT_SYMBOL(libcfs_ipif_free_enumeration);
-
-int
-libcfs_sock_write (struct socket *sock, void *buffer, int nob, int timeout)
-{
-	int	    rc;
-	long	   ticks = timeout * HZ;
-	unsigned long  then;
-	struct timeval tv;
-
-	LASSERT (nob > 0);
-	/* Caller may pass a zero timeout if she thinks the socket buffer is
-	 * empty enough to take the whole message immediately */
-
-	for (;;) {
-		struct kvec  iov = {
-			.iov_base = buffer,
-			.iov_len  = nob
-		};
-		struct msghdr msg = {
-			.msg_flags      = (timeout == 0) ? MSG_DONTWAIT : 0
-		};
-
-		if (timeout != 0) {
-			/* Set send timeout to remaining time */
-			tv = (struct timeval) {
-				.tv_sec = ticks / HZ,
-				.tv_usec = ((ticks % HZ) * 1000000) / HZ
-			};
-			rc = kernel_setsockopt(sock, SOL_SOCKET, SO_SNDTIMEO,
-					     (char *)&tv, sizeof(tv));
-			if (rc != 0) {
-				CERROR("Can't set socket send timeout %ld.%06d: %d\n",
-				       (long)tv.tv_sec, (int)tv.tv_usec, rc);
-				return rc;
-			}
-		}
-
-		then = jiffies;
-		rc = kernel_sendmsg(sock, &msg, &iov, 1, nob);
-		ticks -= jiffies - then;
-
-		if (rc == nob)
-			return 0;
-
-		if (rc < 0)
-			return rc;
-
-		if (rc == 0) {
-			CERROR ("Unexpected zero rc\n");
-			return -ECONNABORTED;
-		}
-
-		if (ticks <= 0)
-			return -EAGAIN;
-
-		buffer = ((char *)buffer) + rc;
-		nob -= rc;
-	}
-
-	return 0;
-}
-EXPORT_SYMBOL(libcfs_sock_write);
-
-int
-libcfs_sock_read (struct socket *sock, void *buffer, int nob, int timeout)
-{
-	int	    rc;
-	long	   ticks = timeout * HZ;
-	unsigned long  then;
-	struct timeval tv;
-
-	LASSERT (nob > 0);
-	LASSERT (ticks > 0);
-
-	for (;;) {
-		struct kvec  iov = {
-			.iov_base = buffer,
-			.iov_len  = nob
-		};
-		struct msghdr msg = {
-			.msg_flags      = 0
-		};
-
-		/* Set receive timeout to remaining time */
-		tv = (struct timeval) {
-			.tv_sec = ticks / HZ,
-			.tv_usec = ((ticks % HZ) * 1000000) / HZ
-		};
-		rc = kernel_setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO,
-				     (char *)&tv, sizeof(tv));
-		if (rc != 0) {
-			CERROR("Can't set socket recv timeout %ld.%06d: %d\n",
-			       (long)tv.tv_sec, (int)tv.tv_usec, rc);
-			return rc;
-		}
-
-		then = jiffies;
-		rc = kernel_recvmsg(sock, &msg, &iov, 1, nob, 0);
-		ticks -= jiffies - then;
-
-		if (rc < 0)
-			return rc;
-
-		if (rc == 0)
-			return -ECONNRESET;
-
-		buffer = ((char *)buffer) + rc;
-		nob -= rc;
-
-		if (nob == 0)
-			return 0;
-
-		if (ticks <= 0)
-			return -ETIMEDOUT;
-	}
-}
-
-EXPORT_SYMBOL(libcfs_sock_read);
-
-static int
-libcfs_sock_create (struct socket **sockp, int *fatal,
-		    __u32 local_ip, int local_port)
-{
-	struct sockaddr_in  locaddr;
-	struct socket      *sock;
-	int		 rc;
-	int		 option;
-
-	/* All errors are fatal except bind failure if the port is in use */
-	*fatal = 1;
-
-	rc = sock_create (PF_INET, SOCK_STREAM, 0, &sock);
-	*sockp = sock;
-	if (rc != 0) {
-		CERROR ("Can't create socket: %d\n", rc);
-		return rc;
-	}
-
-	option = 1;
-	rc = kernel_setsockopt(sock, SOL_SOCKET, SO_REUSEADDR,
-			     (char *)&option, sizeof (option));
-	if (rc != 0) {
-		CERROR("Can't set SO_REUSEADDR for socket: %d\n", rc);
-		goto failed;
-	}
-
-	if (local_ip != 0 || local_port != 0) {
-		memset(&locaddr, 0, sizeof(locaddr));
-		locaddr.sin_family = AF_INET;
-		locaddr.sin_port = htons(local_port);
-		locaddr.sin_addr.s_addr = (local_ip == 0) ?
-					  INADDR_ANY : htonl(local_ip);
-
-		rc = sock->ops->bind(sock, (struct sockaddr *)&locaddr,
-				     sizeof(locaddr));
-		if (rc == -EADDRINUSE) {
-			CDEBUG(D_NET, "Port %d already in use\n", local_port);
-			*fatal = 0;
-			goto failed;
-		}
-		if (rc != 0) {
-			CERROR("Error trying to bind to port %d: %d\n",
-			       local_port, rc);
-			goto failed;
-		}
-	}
-
-	return 0;
-
- failed:
-	sock_release(sock);
-	return rc;
-}
-
-int
-libcfs_sock_setbuf (struct socket *sock, int txbufsize, int rxbufsize)
-{
-	int		 option;
-	int		 rc;
-
-	if (txbufsize != 0) {
-		option = txbufsize;
-		rc = kernel_setsockopt(sock, SOL_SOCKET, SO_SNDBUF,
-				     (char *)&option, sizeof (option));
-		if (rc != 0) {
-			CERROR ("Can't set send buffer %d: %d\n",
-				option, rc);
-			return rc;
-		}
-	}
-
-	if (rxbufsize != 0) {
-		option = rxbufsize;
-		rc = kernel_setsockopt(sock, SOL_SOCKET, SO_RCVBUF,
-				      (char *)&option, sizeof (option));
-		if (rc != 0) {
-			CERROR ("Can't set receive buffer %d: %d\n",
-				option, rc);
-			return rc;
-		}
-	}
-
-	return 0;
-}
-
-EXPORT_SYMBOL(libcfs_sock_setbuf);
-
-int
-libcfs_sock_getaddr (struct socket *sock, int remote, __u32 *ip, int *port)
-{
-	struct sockaddr_in sin;
-	int		len = sizeof (sin);
-	int		rc;
-
-	rc = sock->ops->getname (sock, (struct sockaddr *)&sin, &len,
-				 remote ? 2 : 0);
-	if (rc != 0) {
-		CERROR ("Error %d getting sock %s IP/port\n",
-			rc, remote ? "peer" : "local");
-		return rc;
-	}
-
-	if (ip != NULL)
-		*ip = ntohl (sin.sin_addr.s_addr);
-
-	if (port != NULL)
-		*port = ntohs (sin.sin_port);
-
-	return 0;
-}
-
-EXPORT_SYMBOL(libcfs_sock_getaddr);
-
-int
-libcfs_sock_getbuf (struct socket *sock, int *txbufsize, int *rxbufsize)
-{
-
-	if (txbufsize != NULL) {
-		*txbufsize = sock->sk->sk_sndbuf;
-	}
-
-	if (rxbufsize != NULL) {
-		*rxbufsize = sock->sk->sk_rcvbuf;
-	}
-
-	return 0;
-}
-
-EXPORT_SYMBOL(libcfs_sock_getbuf);
-
-int
-libcfs_sock_listen (struct socket **sockp,
-		    __u32 local_ip, int local_port, int backlog)
-{
-	int      fatal;
-	int      rc;
-
-	rc = libcfs_sock_create(sockp, &fatal, local_ip, local_port);
-	if (rc != 0) {
-		if (!fatal)
-			CERROR("Can't create socket: port %d already in use\n",
-			       local_port);
-		return rc;
-	}
-
-	rc = (*sockp)->ops->listen(*sockp, backlog);
-	if (rc == 0)
-		return 0;
-
-	CERROR("Can't set listen backlog %d: %d\n", backlog, rc);
-	sock_release(*sockp);
-	return rc;
-}
-
-EXPORT_SYMBOL(libcfs_sock_listen);
-
-int
-libcfs_sock_accept (struct socket **newsockp, struct socket *sock)
-{
-	wait_queue_t   wait;
-	struct socket *newsock;
-	int	    rc;
-
-	init_waitqueue_entry(&wait, current);
-
-	/* XXX this should add a ref to sock->ops->owner, if
-	 * TCP could be a module */
-	rc = sock_create_lite(PF_PACKET, sock->type, IPPROTO_TCP, &newsock);
-	if (rc) {
-		CERROR("Can't allocate socket\n");
-		return rc;
-	}
-
-	newsock->ops = sock->ops;
-
-	rc = sock->ops->accept(sock, newsock, O_NONBLOCK);
-	if (rc == -EAGAIN) {
-		/* Nothing ready, so wait for activity */
-		set_current_state(TASK_INTERRUPTIBLE);
-		add_wait_queue(sk_sleep(sock->sk), &wait);
-		schedule();
-		remove_wait_queue(sk_sleep(sock->sk), &wait);
-		set_current_state(TASK_RUNNING);
-		rc = sock->ops->accept(sock, newsock, O_NONBLOCK);
-	}
-
-	if (rc != 0)
-		goto failed;
-
-	*newsockp = newsock;
-	return 0;
-
- failed:
-	sock_release(newsock);
-	return rc;
-}
-
-EXPORT_SYMBOL(libcfs_sock_accept);
-
-void
-libcfs_sock_abort_accept (struct socket *sock)
-{
-	wake_up_all(sk_sleep(sock->sk));
-}
-
-EXPORT_SYMBOL(libcfs_sock_abort_accept);
-
-int
-libcfs_sock_connect (struct socket **sockp, int *fatal,
-		     __u32 local_ip, int local_port,
-		     __u32 peer_ip, int peer_port)
-{
-	struct sockaddr_in  srvaddr;
-	int		 rc;
-
-	rc = libcfs_sock_create(sockp, fatal, local_ip, local_port);
-	if (rc != 0)
-		return rc;
-
-	memset (&srvaddr, 0, sizeof (srvaddr));
-	srvaddr.sin_family = AF_INET;
-	srvaddr.sin_port = htons(peer_port);
-	srvaddr.sin_addr.s_addr = htonl(peer_ip);
-
-	rc = (*sockp)->ops->connect(*sockp,
-				    (struct sockaddr *)&srvaddr, sizeof(srvaddr),
-				    0);
-	if (rc == 0)
-		return 0;
-
-	/* EADDRNOTAVAIL probably means we're already connected to the same
-	 * peer/port on the same local port on a differently typed
-	 * connection.  Let our caller retry with a different local
-	 * port... */
-	*fatal = !(rc == -EADDRNOTAVAIL);
-
-	CDEBUG_LIMIT(*fatal ? D_NETERROR : D_NET,
-	       "Error %d connecting %pI4h/%d -> %pI4h/%d\n", rc,
-	       &local_ip, local_port, &peer_ip, peer_port);
-
-	sock_release(*sockp);
-	return rc;
-}
-
-EXPORT_SYMBOL(libcfs_sock_connect);
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
