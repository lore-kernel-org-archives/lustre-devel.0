From: James Simmons <jsimmons@infradead.org>
Date: Wed,  3 Jun 2015 10:32:31 -0400
Subject: [lustre-devel] [PATCH v3 4/7] staging:lustre: rename tcpip handling
	functions to lnet_* prefix
In-Reply-To: <1433341954-654-1-git-send-email-jsimmons@infradead.org>
References: <1433341954-654-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1433341954-654-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

With all the TCPIP handling done in the lnet layer we should
rename all the functions with the prefix lnet_*. One other
change done was changing the remove argument of lnet_sock_getaddr
from a int to a bool.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/include/linux/libcfs/libcfs.h   |   15 -----
 .../staging/lustre/include/linux/lnet/lib-lnet.h   |   16 +++++
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    2 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |   11 ++--
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |    6 +-
 .../lustre/lnet/klnds/socklnd/socklnd_lib-linux.c  |   15 ++---
 .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |   43 ++++++-------
 drivers/staging/lustre/lnet/lnet/acceptor.c        |   43 ++++++-------
 drivers/staging/lustre/lnet/lnet/config.c          |   21 +++----
 drivers/staging/lustre/lnet/lnet/lib-socket.c      |   66 +++++++++----------
 10 files changed, 110 insertions(+), 128 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/libcfs/libcfs.h b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
index 457ce9a..5dd9cdf 100644
--- a/drivers/staging/lustre/include/linux/libcfs/libcfs.h
+++ b/drivers/staging/lustre/include/linux/libcfs/libcfs.h
@@ -65,21 +65,6 @@ static inline int __is_po2(unsigned long long val)
 int libcfs_arch_init(void);
 void libcfs_arch_cleanup(void);
 
-/* libcfs tcpip */
-int libcfs_ipif_query(char *name, int *up, __u32 *ip, __u32 *mask);
-int libcfs_ipif_enumerate(char ***names);
-void libcfs_ipif_free_enumeration(char **names, int n);
-int libcfs_sock_listen(struct socket **sockp, __u32 ip, int port, int backlog);
-int libcfs_sock_accept(struct socket **newsockp, struct socket *sock);
-int libcfs_sock_connect(struct socket **sockp, int *fatal,
-			__u32 local_ip, int local_port,
-			__u32 peer_ip, int peer_port);
-int libcfs_sock_setbuf(struct socket *socket, int txbufsize, int rxbufsize);
-int libcfs_sock_getbuf(struct socket *socket, int *txbufsize, int *rxbufsize);
-int libcfs_sock_getaddr(struct socket *socket, int remote, __u32 *ip, int *port);
-int libcfs_sock_write(struct socket *sock, void *buffer, int nob, int timeout);
-int libcfs_sock_read(struct socket *sock, void *buffer, int nob, int timeout);
-
 /* need both kernel and user-land acceptor */
 #define LNET_ACCEPTOR_MIN_RESERVED_PORT    512
 #define LNET_ACCEPTOR_MAX_RESERVED_PORT    1023
diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
index d84aa9a..ff07703 100644
--- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
+++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
@@ -844,6 +844,22 @@ int lnet_acceptor_port(void);
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
+void libcfs_sock_release(struct socket *sock);
+
 void lnet_get_tunables(void);
 int lnet_peers_start_down(void);
 int lnet_peer_buffer_credits(lnet_ni_t *ni);
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index a57c5c3..060b739 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2617,7 +2617,7 @@ static kib_dev_t *kiblnd_create_dev(char *ifname)
 	int up;
 	int rc;
 
-	rc = libcfs_ipif_query(ifname, &up, &ip, &netmask);
+	rc = lnet_ipif_query(ifname, &up, &ip, &netmask);
 	if (rc != 0) {
 		CERROR("Can't query IPoIB interface %s: %d\n",
 		       ifname, rc);
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 38e831f..ee5cf35 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -968,7 +968,7 @@ ksocknal_accept(lnet_ni_t *ni, struct socket *sock)
 	__u32 peer_ip;
 	int peer_port;
 
-	rc = libcfs_sock_getaddr(sock, 1, &peer_ip, &peer_port);
+	rc = lnet_sock_getaddr(sock, 1, &peer_ip, &peer_port);
 	LASSERT(rc == 0);		      /* we succeeded before */
 
 	LIBCFS_ALLOC(cr, sizeof(*cr));
@@ -2594,7 +2594,7 @@ ksocknal_enumerate_interfaces(ksock_net_t *net)
 	int rc;
 	int n;
 
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
@@ -2796,8 +2796,7 @@ ksocknal_startup(lnet_ni_t *ni)
 			if (ni->ni_interfaces[i] == NULL)
 				break;
 
-			rc = libcfs_ipif_query(
-				ni->ni_interfaces[i], &up,
+			rc = lnet_ipif_query(ni->ni_interfaces[i], &up,
 				&net->ksnn_interfaces[i].ksni_ipaddr,
 				&net->ksnn_interfaces[i].ksni_netmask);
 
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index a1a4ac0..fe2a83a 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -1707,7 +1707,7 @@ ksocknal_recv_hello (lnet_ni_t *ni, ksock_conn_t *conn,
 	timeout = active ? *ksocknal_tunables.ksnd_timeout :
 			    lnet_acceptor_timeout();
 
-	rc = libcfs_sock_read(sock, &hello->kshm_magic, sizeof (hello->kshm_magic), timeout);
+	rc = lnet_sock_read(sock, &hello->kshm_magic, sizeof (hello->kshm_magic), timeout);
 	if (rc != 0) {
 		CERROR("Error %d reading HELLO from %pI4h\n",
 			rc, &conn->ksnc_ipaddr);
@@ -1726,8 +1726,8 @@ ksocknal_recv_hello (lnet_ni_t *ni, ksock_conn_t *conn,
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
index caeb347..34c6a72 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib-linux.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_lib-linux.c
@@ -39,9 +39,8 @@
 int
 ksocknal_lib_get_conn_addrs(ksock_conn_t *conn)
 {
-	int rc = libcfs_sock_getaddr(conn->ksnc_sock, 1,
-				     &conn->ksnc_ipaddr,
-				     &conn->ksnc_port);
+	int rc = lnet_sock_getaddr(conn->ksnc_sock, 1, &conn->ksnc_ipaddr,
+				   &conn->ksnc_port);
 
 	/* Didn't need the {get,put}connsock dance to deref ksnc_sock... */
 	LASSERT(!conn->ksnc_closing);
@@ -51,8 +50,7 @@ ksocknal_lib_get_conn_addrs(ksock_conn_t *conn)
 		return rc;
 	}
 
-	rc = libcfs_sock_getaddr(conn->ksnc_sock, 0,
-				 &conn->ksnc_myipaddr, NULL);
+	rc = lnet_sock_getaddr(conn->ksnc_sock, 0, &conn->ksnc_myipaddr, NULL);
 	if (rc != 0) {
 		CERROR("Error %d getting sock local IP\n", rc);
 		return rc;
@@ -436,7 +434,7 @@ ksocknal_lib_get_conn_tunables(ksock_conn_t *conn, int *txmem, int *rxmem, int *
 		return -ESHUTDOWN;
 	}
 
-	rc = libcfs_sock_getbuf(sock, txmem, rxmem);
+	rc = lnet_sock_getbuf(sock, txmem, rxmem);
 	if (rc == 0) {
 		len = sizeof(*nagle);
 		rc = kernel_getsockopt(sock, SOL_TCP, TCP_NODELAY,
@@ -498,9 +496,8 @@ ksocknal_lib_setup_sock(struct socket *sock)
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
index 1938d6a..986bce4 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
@@ -495,9 +495,7 @@ ksocknal_send_hello_v1(ksock_conn_t *conn, ksock_hello_msg_t *hello)
 	hdr->msg.hello.type = cpu_to_le32 (hello->kshm_ctype);
 	hdr->msg.hello.incarnation = cpu_to_le64 (hello->kshm_src_incarnation);
 
-	rc = libcfs_sock_write(sock, hdr, sizeof(*hdr),
-			       lnet_acceptor_timeout());
-
+	rc = lnet_sock_write(sock, hdr, sizeof(*hdr), lnet_acceptor_timeout());
 	if (rc != 0) {
 		CNETERR("Error %d sending HELLO hdr to %pI4h/%d\n",
 			rc, &conn->ksnc_ipaddr, conn->ksnc_port);
@@ -511,9 +509,9 @@ ksocknal_send_hello_v1(ksock_conn_t *conn, ksock_hello_msg_t *hello)
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
@@ -544,9 +542,8 @@ ksocknal_send_hello_v2(ksock_conn_t *conn, ksock_hello_msg_t *hello)
 		LNET_UNLOCK();
 	}
 
-	rc = libcfs_sock_write(sock, hello, offsetof(ksock_hello_msg_t, kshm_ips),
-			       lnet_acceptor_timeout());
-
+	rc = lnet_sock_write(sock, hello, offsetof(ksock_hello_msg_t, kshm_ips),
+			     lnet_acceptor_timeout());
 	if (rc != 0) {
 		CNETERR("Error %d sending HELLO hdr to %pI4h/%d\n",
 			rc, &conn->ksnc_ipaddr, conn->ksnc_port);
@@ -556,9 +553,9 @@ ksocknal_send_hello_v2(ksock_conn_t *conn, ksock_hello_msg_t *hello)
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
@@ -583,9 +580,9 @@ ksocknal_recv_hello_v1(ksock_conn_t *conn, ksock_hello_msg_t *hello,
 		return -ENOMEM;
 	}
 
-	rc = libcfs_sock_read(sock, &hdr->src_nid,
-			      sizeof(*hdr) - offsetof(lnet_hdr_t, src_nid),
-			      timeout);
+	rc = lnet_sock_read(sock, &hdr->src_nid,
+			    sizeof(*hdr) - offsetof(lnet_hdr_t, src_nid),
+			    timeout);
 	if (rc != 0) {
 		CERROR("Error %d reading rest of HELLO hdr from %pI4h\n",
 			rc, &conn->ksnc_ipaddr);
@@ -619,8 +616,8 @@ ksocknal_recv_hello_v1(ksock_conn_t *conn, ksock_hello_msg_t *hello,
 	if (hello->kshm_nips == 0)
 		goto out;
 
-	rc = libcfs_sock_read(sock, hello->kshm_ips,
-			      hello->kshm_nips * sizeof(__u32), timeout);
+	rc = lnet_sock_read(sock, hello->kshm_ips,
+			    hello->kshm_nips * sizeof(__u32), timeout);
 	if (rc != 0) {
 		CERROR("Error %d reading IPs from ip %pI4h\n",
 			rc, &conn->ksnc_ipaddr);
@@ -656,10 +653,10 @@ ksocknal_recv_hello_v2(ksock_conn_t *conn, ksock_hello_msg_t *hello, int timeout
 	else
 		conn->ksnc_flip = 1;
 
-	rc = libcfs_sock_read(sock, &hello->kshm_src_nid,
-			      offsetof(ksock_hello_msg_t, kshm_ips) -
-				       offsetof(ksock_hello_msg_t, kshm_src_nid),
-			      timeout);
+	rc = lnet_sock_read(sock, &hello->kshm_src_nid,
+			    offsetof(ksock_hello_msg_t, kshm_ips) -
+				     offsetof(ksock_hello_msg_t, kshm_src_nid),
+			    timeout);
 	if (rc != 0) {
 		CERROR("Error %d reading HELLO from %pI4h\n",
 			rc, &conn->ksnc_ipaddr);
@@ -687,8 +684,8 @@ ksocknal_recv_hello_v2(ksock_conn_t *conn, ksock_hello_msg_t *hello, int timeout
 	if (hello->kshm_nips == 0)
 		return 0;
 
-	rc = libcfs_sock_read(sock, hello->kshm_ips,
-			      hello->kshm_nips * sizeof(__u32), timeout);
+	rc = lnet_sock_read(sock, hello->kshm_ips,
+			    hello->kshm_nips * sizeof(__u32), timeout);
 	if (rc != 0) {
 		CERROR("Error %d reading IPs from ip %pI4h\n",
 			rc, &conn->ksnc_ipaddr);
diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
index 5187e65..1dc7c8a 100644
--- a/drivers/staging/lustre/lnet/lnet/acceptor.c
+++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
@@ -155,9 +155,8 @@ lnet_connect(struct socket **sockp, lnet_nid_t peer_nid,
 	     --port) {
 		/* Iterate through reserved ports. */
 
-		rc = libcfs_sock_connect(&sock, &fatal,
-					 local_ip, port,
-					 peer_ip, peer_port);
+		rc = lnet_sock_connect(&sock, &fatal, local_ip, port, peer_ip,
+				       peer_port);
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
 
@@ -220,7 +218,7 @@ lnet_accept(struct socket *sock, __u32 magic)
 
 	LASSERT(sizeof(cr) <= 16);	     /* not too big for the stack */
 
-	rc = libcfs_sock_getaddr(sock, 1, &peer_ip, &peer_port);
+	rc = lnet_sock_getaddr(sock, 1, &peer_ip, &peer_port);
 	LASSERT(rc == 0);		      /* we succeeded before */
 
 	if (!lnet_accept_magic(magic, LNET_PROTO_ACCEPTOR_MAGIC)) {
@@ -234,8 +232,8 @@ lnet_accept(struct socket *sock, __u32 magic)
 			memset(&cr, 0, sizeof(cr));
 			cr.acr_magic = LNET_PROTO_ACCEPTOR_MAGIC;
 			cr.acr_version = LNET_PROTO_ACCEPTOR_VERSION;
-			rc = libcfs_sock_write(sock, &cr, sizeof(cr),
-					       accept_timeout);
+			rc = lnet_sock_write(sock, &cr, sizeof(cr),
+					     accept_timeout);
 
 			if (rc != 0)
 				CERROR("Error sending magic+version in response to LNET magic from %pI4h: %d\n",
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
@@ -280,19 +277,17 @@ lnet_accept(struct socket *sock, __u32 magic)
 		cr.acr_magic = LNET_PROTO_ACCEPTOR_MAGIC;
 		cr.acr_version = LNET_PROTO_ACCEPTOR_VERSION;
 
-		rc = libcfs_sock_write(sock, &cr, sizeof(cr),
-				       accept_timeout);
-
+		rc = lnet_sock_write(sock, &cr, sizeof(cr), accept_timeout);
 		if (rc != 0)
 			CERROR("Error sending magic+version in response to version %d from %pI4h: %d\n",
 			       peer_version, &peer_ip, rc);
 		return -EPROTO;
 	}
 
-	rc = libcfs_sock_read(sock, &cr.acr_nid,
-			      sizeof(cr) -
-			      offsetof(lnet_acceptor_connreq_t, acr_nid),
-			      accept_timeout);
+	rc = lnet_sock_read(sock, &cr.acr_nid,
+			    sizeof(cr) -
+			    offsetof(lnet_acceptor_connreq_t, acr_nid),
+			    accept_timeout);
 	if (rc != 0) {
 		CERROR("Error %d reading connection request from %pI4h\n",
 			rc, &peer_ip);
@@ -343,8 +338,8 @@ lnet_acceptor(void *arg)
 
 	cfs_block_allsigs();
 
-	rc = libcfs_sock_listen(&lnet_acceptor_state.pta_sock,
-				0, accept_port, accept_backlog);
+	rc = lnet_sock_listen(&lnet_acceptor_state.pta_sock, 0, accept_port,
+			      accept_backlog);
 	if (rc != 0) {
 		if (rc == -EADDRINUSE)
 			LCONSOLE_ERROR_MSG(0x122, "Can't start acceptor on port %d: port already in use\n",
@@ -367,7 +362,7 @@ lnet_acceptor(void *arg)
 
 	while (!lnet_acceptor_state.pta_shutdown) {
 
-		rc = libcfs_sock_accept(&newsock, lnet_acceptor_state.pta_sock);
+		rc = lnet_sock_accept(&newsock, lnet_acceptor_state.pta_sock);
 		if (rc != 0) {
 			if (rc != -EAGAIN) {
 				CWARN("Accept error %d: pausing...\n", rc);
@@ -383,7 +378,7 @@ lnet_acceptor(void *arg)
 			break;
 		}
 
-		rc = libcfs_sock_getaddr(newsock, 1, &peer_ip, &peer_port);
+		rc = lnet_sock_getaddr(newsock, 1, &peer_ip, &peer_port);
 		if (rc != 0) {
 			CERROR("Can't determine new connection's address\n");
 			goto failed;
@@ -395,8 +390,8 @@ lnet_acceptor(void *arg)
 			goto failed;
 		}
 
-		rc = libcfs_sock_read(newsock, &magic, sizeof(magic),
-				      accept_timeout);
+		rc = lnet_sock_read(newsock, &magic, sizeof(magic),
+				    accept_timeout);
 		if (rc != 0) {
 			CERROR("Error %d reading connection request from %pI4h\n",
 				rc, &peer_ip);
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index 70bc809..efbb74a 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -1118,7 +1118,7 @@ lnet_ipaddr_enumerate(__u32 **ipaddrsp)
 	__u32 *ipaddrs2;
 	int nip;
 	char **ifnames;
-	int nif = libcfs_ipif_enumerate(&ifnames);
+	int nif = lnet_ipif_enumerate(&ifnames);
 	int i;
 	int rc;
 
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
index bb8d9c2..2e87168 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -45,7 +45,7 @@
 #include <linux/syscalls.h>
 
 static int
-libcfs_sock_ioctl(int cmd, unsigned long arg)
+lnet_sock_ioctl(int cmd, unsigned long arg)
 {
 	mm_segment_t	oldmm = get_fs();
 	struct socket  *sock;
@@ -76,7 +76,7 @@ out:
 }
 
 int
-libcfs_ipif_query (char *name, int *up, __u32 *ip, __u32 *mask)
+lnet_ipif_query (char *name, int *up, __u32 *ip, __u32 *mask)
 {
 	struct ifreq   ifr;
 	int	    nob;
@@ -92,8 +92,7 @@ libcfs_ipif_query (char *name, int *up, __u32 *ip, __u32 *mask)
 	CLASSERT (sizeof(ifr.ifr_name) >= IFNAMSIZ);
 
 	strcpy(ifr.ifr_name, name);
-	rc = libcfs_sock_ioctl(SIOCGIFFLAGS, (unsigned long)&ifr);
-
+	rc = lnet_sock_ioctl(SIOCGIFFLAGS, (unsigned long)&ifr);
 	if (rc != 0) {
 		CERROR("Can't get flags for interface %s\n", name);
 		return rc;
@@ -110,8 +109,7 @@ libcfs_ipif_query (char *name, int *up, __u32 *ip, __u32 *mask)
 
 	strcpy(ifr.ifr_name, name);
 	ifr.ifr_addr.sa_family = AF_INET;
-	rc = libcfs_sock_ioctl(SIOCGIFADDR, (unsigned long)&ifr);
-
+	rc = lnet_sock_ioctl(SIOCGIFADDR, (unsigned long)&ifr);
 	if (rc != 0) {
 		CERROR("Can't get IP address for interface %s\n", name);
 		return rc;
@@ -122,8 +120,7 @@ libcfs_ipif_query (char *name, int *up, __u32 *ip, __u32 *mask)
 
 	strcpy(ifr.ifr_name, name);
 	ifr.ifr_addr.sa_family = AF_INET;
-	rc = libcfs_sock_ioctl(SIOCGIFNETMASK, (unsigned long)&ifr);
-
+	rc = lnet_sock_ioctl(SIOCGIFNETMASK, (unsigned long)&ifr);
 	if (rc != 0) {
 		CERROR("Can't get netmask for interface %s\n", name);
 		return rc;
@@ -135,10 +132,10 @@ libcfs_ipif_query (char *name, int *up, __u32 *ip, __u32 *mask)
 	return 0;
 }
 
-EXPORT_SYMBOL(libcfs_ipif_query);
+EXPORT_SYMBOL(lnet_ipif_query);
 
 int
-libcfs_ipif_enumerate (char ***namesp)
+lnet_ipif_enumerate (char ***namesp)
 {
 	/* Allocate and fill in 'names', returning # interfaces/error */
 	char	   **names;
@@ -172,8 +169,7 @@ libcfs_ipif_enumerate (char ***namesp)
 		ifc.ifc_buf = (char *)ifr;
 		ifc.ifc_len = nalloc * sizeof(*ifr);
 
-		rc = libcfs_sock_ioctl(SIOCGIFCONF, (unsigned long)&ifc);
-
+		rc = lnet_sock_ioctl(SIOCGIFCONF, (unsigned long)&ifc);
 		if (rc < 0) {
 			CERROR ("Error %d enumerating interfaces\n", rc);
 			goto out1;
@@ -226,17 +222,17 @@ libcfs_ipif_enumerate (char ***namesp)
 
  out2:
 	if (rc < 0)
-		libcfs_ipif_free_enumeration(names, nfound);
+		lnet_ipif_free_enumeration(names, nfound);
  out1:
 	LIBCFS_FREE(ifr, nalloc * sizeof(*ifr));
  out0:
 	return rc;
 }
 
-EXPORT_SYMBOL(libcfs_ipif_enumerate);
+EXPORT_SYMBOL(lnet_ipif_enumerate);
 
 void
-libcfs_ipif_free_enumeration (char **names, int n)
+lnet_ipif_free_enumeration (char **names, int n)
 {
 	int      i;
 
@@ -248,10 +244,10 @@ libcfs_ipif_free_enumeration (char **names, int n)
 	LIBCFS_FREE(names, n * sizeof(*names));
 }
 
-EXPORT_SYMBOL(libcfs_ipif_free_enumeration);
+EXPORT_SYMBOL(lnet_ipif_free_enumeration);
 
 int
-libcfs_sock_write (struct socket *sock, void *buffer, int nob, int timeout)
+lnet_sock_write (struct socket *sock, void *buffer, int nob, int timeout)
 {
 	int	    rc;
 	long	   ticks = timeout * HZ;
@@ -310,10 +306,10 @@ libcfs_sock_write (struct socket *sock, void *buffer, int nob, int timeout)
 
 	return 0;
 }
-EXPORT_SYMBOL(libcfs_sock_write);
+EXPORT_SYMBOL(lnet_sock_write);
 
 int
-libcfs_sock_read (struct socket *sock, void *buffer, int nob, int timeout)
+lnet_sock_read (struct socket *sock, void *buffer, int nob, int timeout)
 {
 	int	    rc;
 	long	   ticks = timeout * HZ;
@@ -366,10 +362,10 @@ libcfs_sock_read (struct socket *sock, void *buffer, int nob, int timeout)
 	}
 }
 
-EXPORT_SYMBOL(libcfs_sock_read);
+EXPORT_SYMBOL(lnet_sock_read);
 
 static int
-libcfs_sock_create (struct socket **sockp, int *fatal,
+lnet_sock_create (struct socket **sockp, int *fatal,
 		    __u32 local_ip, int local_port)
 {
 	struct sockaddr_in  locaddr;
@@ -424,7 +420,7 @@ libcfs_sock_create (struct socket **sockp, int *fatal,
 }
 
 int
-libcfs_sock_setbuf (struct socket *sock, int txbufsize, int rxbufsize)
+lnet_sock_setbuf (struct socket *sock, int txbufsize, int rxbufsize)
 {
 	int		 option;
 	int		 rc;
@@ -454,10 +450,10 @@ libcfs_sock_setbuf (struct socket *sock, int txbufsize, int rxbufsize)
 	return 0;
 }
 
-EXPORT_SYMBOL(libcfs_sock_setbuf);
+EXPORT_SYMBOL(lnet_sock_setbuf);
 
 int
-libcfs_sock_getaddr (struct socket *sock, int remote, __u32 *ip, int *port)
+lnet_sock_getaddr (struct socket *sock, bool remote, __u32 *ip, int *port)
 {
 	struct sockaddr_in sin;
 	int		len = sizeof (sin);
@@ -480,10 +476,10 @@ libcfs_sock_getaddr (struct socket *sock, int remote, __u32 *ip, int *port)
 	return 0;
 }
 
-EXPORT_SYMBOL(libcfs_sock_getaddr);
+EXPORT_SYMBOL(lnet_sock_getaddr);
 
 int
-libcfs_sock_getbuf (struct socket *sock, int *txbufsize, int *rxbufsize)
+lnet_sock_getbuf (struct socket *sock, int *txbufsize, int *rxbufsize)
 {
 
 	if (txbufsize != NULL) {
@@ -497,16 +493,16 @@ libcfs_sock_getbuf (struct socket *sock, int *txbufsize, int *rxbufsize)
 	return 0;
 }
 
-EXPORT_SYMBOL(libcfs_sock_getbuf);
+EXPORT_SYMBOL(lnet_sock_getbuf);
 
 int
-libcfs_sock_listen (struct socket **sockp,
+lnet_sock_listen (struct socket **sockp,
 		    __u32 local_ip, int local_port, int backlog)
 {
 	int      fatal;
 	int      rc;
 
-	rc = libcfs_sock_create(sockp, &fatal, local_ip, local_port);
+	rc = lnet_sock_create(sockp, &fatal, local_ip, local_port);
 	if (rc != 0) {
 		if (!fatal)
 			CERROR("Can't create socket: port %d already in use\n",
@@ -523,10 +519,10 @@ libcfs_sock_listen (struct socket **sockp,
 	return rc;
 }
 
-EXPORT_SYMBOL(libcfs_sock_listen);
+EXPORT_SYMBOL(lnet_sock_listen);
 
 int
-libcfs_sock_accept (struct socket **newsockp, struct socket *sock)
+lnet_sock_accept (struct socket **newsockp, struct socket *sock)
 {
 	wait_queue_t   wait;
 	struct socket *newsock;
@@ -566,17 +562,17 @@ libcfs_sock_accept (struct socket **newsockp, struct socket *sock)
 	return rc;
 }
 
-EXPORT_SYMBOL(libcfs_sock_accept);
+EXPORT_SYMBOL(lnet_sock_accept);
 
 int
-libcfs_sock_connect (struct socket **sockp, int *fatal,
+lnet_sock_connect (struct socket **sockp, int *fatal,
 		     __u32 local_ip, int local_port,
 		     __u32 peer_ip, int peer_port)
 {
 	struct sockaddr_in  srvaddr;
 	int		 rc;
 
-	rc = libcfs_sock_create(sockp, fatal, local_ip, local_port);
+	rc = lnet_sock_create(sockp, fatal, local_ip, local_port);
 	if (rc != 0)
 		return rc;
 
@@ -605,4 +601,4 @@ libcfs_sock_connect (struct socket **sockp, int *fatal,
 	return rc;
 }
 
-EXPORT_SYMBOL(libcfs_sock_connect);
+EXPORT_SYMBOL(lnet_sock_connect);
-- 
1.7.1
