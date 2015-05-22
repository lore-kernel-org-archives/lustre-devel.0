From: James Simmons <jsimmons@infradead.org>
Date: Fri, 22 May 2015 14:32:31 -0400
Subject: [lustre-devel] [PATCH 5/6] staging:lustre: style cleanups for
	lib-socket.c
In-Reply-To: <uja.ornl@gmail.com>
References: <uja.ornl@gmail.com>
Message-ID: <1432319552-10479-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Handle all the style issues reported by checkpatch.pl.
Remove general white spaces, spaces in function calls,
etc.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |    4 +-
 drivers/staging/lustre/lnet/lnet/lib-socket.c      |  210 +++++++++-----------
 2 files changed, 98 insertions(+), 116 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index a27dddf..caccb00 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -1378,14 +1378,14 @@ ksocknal_create_conn(lnet_ni_t *ni, ksock_route_t *route,
 	ksocknal_txlist_done(ni, &zombies, 1);
 	ksocknal_peer_decref(peer);
 
- failed_1:
+failed_1:
 	if (hello != NULL)
 		LIBCFS_FREE(hello, offsetof(ksock_hello_msg_t,
 					    kshm_ips[LNET_MAX_INTERFACES]));
 
 	LIBCFS_FREE(conn, sizeof(*conn));
 
- failed_0:
+failed_0:
 	sock_release(sock);
 	return rc;
 }
diff --git a/drivers/staging/lustre/lnet/lnet/lib-socket.c b/drivers/staging/lustre/lnet/lnet/lib-socket.c
index 2d46a69..f0b187d 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-socket.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-socket.c
@@ -63,13 +63,13 @@ kernel_sock_unlocked_ioctl(struct file *filp, int cmd, unsigned long arg)
 static int
 lnet_sock_ioctl(int cmd, unsigned long arg)
 {
-	struct file    *sock_filp;
-	struct socket  *sock;
-	int		rc;
+	struct file *sock_filp;
+	struct socket *sock;
+	int rc;
 
-	rc = sock_create (PF_INET, SOCK_STREAM, 0, &sock);
+	rc = sock_create(PF_INET, SOCK_STREAM, 0, &sock);
 	if (rc != 0) {
-		CERROR ("Can't create socket: %d\n", rc);
+		CERROR("Can't create socket: %d\n", rc);
 		return rc;
 	}
 
@@ -88,12 +88,12 @@ out:
 }
 
 int
-lnet_ipif_query (char *name, int *up, __u32 *ip, __u32 *mask)
+lnet_ipif_query(char *name, int *up, __u32 *ip, __u32 *mask)
 {
-	struct ifreq   ifr;
-	int	    nob;
-	int	    rc;
-	__u32	  val;
+	struct ifreq ifr;
+	int nob;
+	int rc;
+	__u32 val;
 
 	nob = strnlen(name, IFNAMSIZ);
 	if (nob == IFNAMSIZ) {
@@ -101,7 +101,7 @@ lnet_ipif_query (char *name, int *up, __u32 *ip, __u32 *mask)
 		return -EINVAL;
 	}
 
-	CLASSERT (sizeof(ifr.ifr_name) >= IFNAMSIZ);
+	CLASSERT(sizeof(ifr.ifr_name) >= IFNAMSIZ);
 
 	strcpy(ifr.ifr_name, name);
 	rc = lnet_sock_ioctl(SIOCGIFFLAGS, (unsigned long)&ifr);
@@ -116,7 +116,6 @@ lnet_ipif_query (char *name, int *up, __u32 *ip, __u32 *mask)
 		*ip = *mask = 0;
 		return 0;
 	}
-
 	*up = 1;
 
 	strcpy(ifr.ifr_name, name);
@@ -143,23 +142,21 @@ lnet_ipif_query (char *name, int *up, __u32 *ip, __u32 *mask)
 
 	return 0;
 }
-
 EXPORT_SYMBOL(lnet_ipif_query);
 
 int
-lnet_ipif_enumerate (char ***namesp)
+lnet_ipif_enumerate(char ***namesp)
 {
 	/* Allocate and fill in 'names', returning # interfaces/error */
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
+	char **names;
+	int toobig;
+	int nalloc;
+	int nfound;
+	struct ifreq *ifr;
+	struct ifconf ifc;
+	int rc;
+	int nob;
+	int i;
 
 	nalloc = 16;	/* first guess at max interfaces */
 	toobig = 0;
@@ -167,13 +164,14 @@ lnet_ipif_enumerate (char ***namesp)
 		if (nalloc * sizeof(*ifr) > PAGE_CACHE_SIZE) {
 			toobig = 1;
 			nalloc = PAGE_CACHE_SIZE/sizeof(*ifr);
-			CWARN("Too many interfaces: only enumerating first %d\n",
-			      nalloc);
+			CWARN("Too many interfaces: only enumerating "
+			      "first %d\n", nalloc);
 		}
 
 		LIBCFS_ALLOC(ifr, nalloc * sizeof(*ifr));
 		if (ifr == NULL) {
-			CERROR ("ENOMEM enumerating up to %d interfaces\n", nalloc);
+			CERROR("ENOMEM enumerating up to %d interfaces\n",
+			       nalloc);
 			rc = -ENOMEM;
 			goto out0;
 		}
@@ -183,14 +181,14 @@ lnet_ipif_enumerate (char ***namesp)
 
 		rc = lnet_sock_ioctl(SIOCGIFCONF, (unsigned long)&ifc);
 		if (rc < 0) {
-			CERROR ("Error %d enumerating interfaces\n", rc);
+			CERROR("Error %d enumerating interfaces\n", rc);
 			goto out1;
 		}
 
-		LASSERT (rc == 0);
+		LASSERT(rc == 0);
 
 		nfound = ifc.ifc_len/sizeof(*ifr);
-		LASSERT (nfound <= nalloc);
+		LASSERT(nfound <= nalloc);
 
 		if (nfound < nalloc || toobig)
 			break;
@@ -209,8 +207,7 @@ lnet_ipif_enumerate (char ***namesp)
 	}
 
 	for (i = 0; i < nfound; i++) {
-
-		nob = strnlen (ifr[i].ifr_name, IFNAMSIZ);
+		nob = strnlen(ifr[i].ifr_name, IFNAMSIZ);
 		if (nob == IFNAMSIZ) {
 			/* no space for terminating NULL */
 			CERROR("interface name %.*s too long (%d max)\n",
@@ -232,41 +229,39 @@ lnet_ipif_enumerate (char ***namesp)
 	*namesp = names;
 	rc = nfound;
 
- out2:
+out2:
 	if (rc < 0)
 		lnet_ipif_free_enumeration(names, nfound);
- out1:
+out1:
 	LIBCFS_FREE(ifr, nalloc * sizeof(*ifr));
- out0:
+out0:
 	return rc;
 }
-
 EXPORT_SYMBOL(lnet_ipif_enumerate);
 
 void
-lnet_ipif_free_enumeration (char **names, int n)
+lnet_ipif_free_enumeration(char **names, int n)
 {
-	int      i;
+	int i;
 
-	LASSERT (n > 0);
+	LASSERT(n > 0);
 
 	for (i = 0; i < n && names[i] != NULL; i++)
 		LIBCFS_FREE(names[i], IFNAMSIZ);
 
 	LIBCFS_FREE(names, n * sizeof(*names));
 }
-
 EXPORT_SYMBOL(lnet_ipif_free_enumeration);
 
 int
-lnet_sock_write (struct socket *sock, void *buffer, int nob, int timeout)
+lnet_sock_write(struct socket *sock, void *buffer, int nob, int timeout)
 {
-	int	    rc;
-	long	   ticks = timeout * HZ;
-	unsigned long  then;
+	int rc;
+	long ticks = timeout * HZ;
+	unsigned long then;
 	struct timeval tv;
 
-	LASSERT (nob > 0);
+	LASSERT(nob > 0);
 	/* Caller may pass a zero timeout if she thinks the socket buffer is
 	 * empty enough to take the whole message immediately */
 
@@ -286,9 +281,10 @@ lnet_sock_write (struct socket *sock, void *buffer, int nob, int timeout)
 				.tv_usec = ((ticks % HZ) * 1000000) / HZ
 			};
 			rc = kernel_setsockopt(sock, SOL_SOCKET, SO_SNDTIMEO,
-					     (char *)&tv, sizeof(tv));
+					       (char *)&tv, sizeof(tv));
 			if (rc != 0) {
-				CERROR("Can't set socket send timeout %ld.%06d: %d\n",
+				CERROR("Can't set socket send timeout "
+				       "%ld.%06d: %d\n",
 				       (long)tv.tv_sec, (int)tv.tv_usec, rc);
 				return rc;
 			}
@@ -305,7 +301,7 @@ lnet_sock_write (struct socket *sock, void *buffer, int nob, int timeout)
 			return rc;
 
 		if (rc == 0) {
-			CERROR ("Unexpected zero rc\n");
+			CERROR("Unexpected zero rc\n");
 			return -ECONNABORTED;
 		}
 
@@ -315,21 +311,20 @@ lnet_sock_write (struct socket *sock, void *buffer, int nob, int timeout)
 		buffer = ((char *)buffer) + rc;
 		nob -= rc;
 	}
-
 	return 0;
 }
 EXPORT_SYMBOL(lnet_sock_write);
 
 int
-lnet_sock_read (struct socket *sock, void *buffer, int nob, int timeout)
+lnet_sock_read(struct socket *sock, void *buffer, int nob, int timeout)
 {
-	int	    rc;
-	long	   ticks = timeout * HZ;
-	unsigned long  then;
+	int rc;
+	long ticks = timeout * HZ;
+	unsigned long then;
 	struct timeval tv;
 
-	LASSERT (nob > 0);
-	LASSERT (ticks > 0);
+	LASSERT(nob > 0);
+	LASSERT(ticks > 0);
 
 	for (;;) {
 		struct kvec  iov = {
@@ -337,7 +332,7 @@ lnet_sock_read (struct socket *sock, void *buffer, int nob, int timeout)
 			.iov_len  = nob
 		};
 		struct msghdr msg = {
-			.msg_flags      = 0
+			.msg_flags = 0
 		};
 
 		/* Set receive timeout to remaining time */
@@ -346,7 +341,7 @@ lnet_sock_read (struct socket *sock, void *buffer, int nob, int timeout)
 			.tv_usec = ((ticks % HZ) * 1000000) / HZ
 		};
 		rc = kernel_setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO,
-				     (char *)&tv, sizeof(tv));
+				       (char *)&tv, sizeof(tv));
 		if (rc != 0) {
 			CERROR("Can't set socket recv timeout %ld.%06d: %d\n",
 			       (long)tv.tv_sec, (int)tv.tv_usec, rc);
@@ -373,31 +368,30 @@ lnet_sock_read (struct socket *sock, void *buffer, int nob, int timeout)
 			return -ETIMEDOUT;
 	}
 }
-
 EXPORT_SYMBOL(lnet_sock_read);
 
 static int
-lnet_sock_create (struct socket **sockp, int *fatal,
-		    __u32 local_ip, int local_port)
+lnet_sock_create(struct socket **sockp, int *fatal, __u32 local_ip,
+		 int local_port)
 {
-	struct sockaddr_in  locaddr;
-	struct socket      *sock;
-	int		 rc;
-	int		 option;
+	struct sockaddr_in locaddr;
+	struct socket *sock;
+	int rc;
+	int option;
 
 	/* All errors are fatal except bind failure if the port is in use */
 	*fatal = 1;
 
-	rc = sock_create (PF_INET, SOCK_STREAM, 0, &sock);
+	rc = sock_create(PF_INET, SOCK_STREAM, 0, &sock);
 	*sockp = sock;
 	if (rc != 0) {
-		CERROR ("Can't create socket: %d\n", rc);
+		CERROR("Can't create socket: %d\n", rc);
 		return rc;
 	}
 
 	option = 1;
 	rc = kernel_setsockopt(sock, SOL_SOCKET, SO_REUSEADDR,
-			     (char *)&option, sizeof (option));
+			       (char *)&option, sizeof(option));
 	if (rc != 0) {
 		CERROR("Can't set SO_REUSEADDR for socket: %d\n", rc);
 		goto failed;
@@ -423,27 +417,26 @@ lnet_sock_create (struct socket **sockp, int *fatal,
 			goto failed;
 		}
 	}
-
 	return 0;
 
- failed:
+failed:
 	sock_release(sock);
 	return rc;
 }
 
 int
-lnet_sock_setbuf (struct socket *sock, int txbufsize, int rxbufsize)
+lnet_sock_setbuf(struct socket *sock, int txbufsize, int rxbufsize)
 {
-	int		 option;
-	int		 rc;
+	int option;
+	int rc;
 
 	if (txbufsize != 0) {
 		option = txbufsize;
 		rc = kernel_setsockopt(sock, SOL_SOCKET, SO_SNDBUF,
-				     (char *)&option, sizeof (option));
+				       (char *)&option, sizeof(option));
 		if (rc != 0) {
-			CERROR ("Can't set send buffer %d: %d\n",
-				option, rc);
+			CERROR("Can't set send buffer %d: %d\n",
+			       option, rc);
 			return rc;
 		}
 	}
@@ -451,70 +444,63 @@ lnet_sock_setbuf (struct socket *sock, int txbufsize, int rxbufsize)
 	if (rxbufsize != 0) {
 		option = rxbufsize;
 		rc = kernel_setsockopt(sock, SOL_SOCKET, SO_RCVBUF,
-				      (char *)&option, sizeof (option));
+				      (char *)&option, sizeof(option));
 		if (rc != 0) {
-			CERROR ("Can't set receive buffer %d: %d\n",
-				option, rc);
+			CERROR("Can't set receive buffer %d: %d\n",
+			       option, rc);
 			return rc;
 		}
 	}
-
 	return 0;
 }
-
 EXPORT_SYMBOL(lnet_sock_setbuf);
 
 int
-lnet_sock_getaddr (struct socket *sock, bool remote, __u32 *ip, int *port)
+lnet_sock_getaddr(struct socket *sock, bool remote, __u32 *ip, int *port)
 {
 	struct sockaddr_in sin;
-	int		len = sizeof (sin);
-	int		rc;
+	int len = sizeof(sin);
+	int rc;
 
 	if (remote)
 		rc = kernel_getpeername(sock, (struct sockaddr *)&sin, &len);
 	else
 		rc = kernel_getsockname(sock, (struct sockaddr *)&sin, &len);
 	if (rc != 0) {
-		CERROR ("Error %d getting sock %s IP/port\n",
-			rc, remote ? "peer" : "local");
+		CERROR("Error %d getting sock %s IP/port\n",
+		       rc, remote ? "peer" : "local");
 		return rc;
 	}
 
 	if (ip != NULL)
-		*ip = ntohl (sin.sin_addr.s_addr);
+		*ip = ntohl(sin.sin_addr.s_addr);
 
 	if (port != NULL)
-		*port = ntohs (sin.sin_port);
+		*port = ntohs(sin.sin_port);
 
 	return 0;
 }
-
 EXPORT_SYMBOL(lnet_sock_getaddr);
 
 int
-lnet_sock_getbuf (struct socket *sock, int *txbufsize, int *rxbufsize)
+lnet_sock_getbuf(struct socket *sock, int *txbufsize, int *rxbufsize)
 {
-
-	if (txbufsize != NULL) {
+	if (txbufsize != NULL)
 		*txbufsize = sock->sk->sk_sndbuf;
-	}
 
-	if (rxbufsize != NULL) {
+	if (rxbufsize != NULL)
 		*rxbufsize = sock->sk->sk_rcvbuf;
-	}
 
 	return 0;
 }
-
 EXPORT_SYMBOL(lnet_sock_getbuf);
 
 int
-lnet_sock_listen (struct socket **sockp,
-		    __u32 local_ip, int local_port, int backlog)
+lnet_sock_listen(struct socket **sockp, __u32 local_ip, int local_port,
+		 int backlog)
 {
-	int      fatal;
-	int      rc;
+	int fatal;
+	int rc;
 
 	rc = lnet_sock_create(sockp, &fatal, local_ip, local_port);
 	if (rc != 0) {
@@ -532,15 +518,14 @@ lnet_sock_listen (struct socket **sockp,
 	sock_release(*sockp);
 	return rc;
 }
-
 EXPORT_SYMBOL(lnet_sock_listen);
 
 int
-lnet_sock_accept (struct socket **newsockp, struct socket *sock)
+lnet_sock_accept(struct socket **newsockp, struct socket *sock)
 {
-	wait_queue_t   wait;
+	wait_queue_t wait;
 	struct socket *newsock;
-	int	    rc;
+	int rc;
 
 	init_waitqueue_entry(&wait, current);
 
@@ -571,26 +556,24 @@ lnet_sock_accept (struct socket **newsockp, struct socket *sock)
 	*newsockp = newsock;
 	return 0;
 
- failed:
+failed:
 	sock_release(newsock);
 	return rc;
 }
-
 EXPORT_SYMBOL(lnet_sock_accept);
 
 int
-lnet_sock_connect (struct socket **sockp, int *fatal,
-		     __u32 local_ip, int local_port,
-		     __u32 peer_ip, int peer_port)
+lnet_sock_connect(struct socket **sockp, int *fatal, __u32 local_ip,
+		  int local_port, __u32 peer_ip, int peer_port)
 {
-	struct sockaddr_in  srvaddr;
-	int		 rc;
+	struct sockaddr_in srvaddr;
+	int rc;
 
 	rc = lnet_sock_create(sockp, fatal, local_ip, local_port);
 	if (rc != 0)
 		return rc;
 
-	memset (&srvaddr, 0, sizeof (srvaddr));
+	memset(&srvaddr, 0, sizeof(srvaddr));
 	srvaddr.sin_family = AF_INET;
 	srvaddr.sin_port = htons(peer_port);
 	srvaddr.sin_addr.s_addr = htonl(peer_ip);
@@ -607,11 +590,10 @@ lnet_sock_connect (struct socket **sockp, int *fatal,
 	*fatal = !(rc == -EADDRNOTAVAIL);
 
 	CDEBUG_LIMIT(*fatal ? D_NETERROR : D_NET,
-	       "Error %d connecting %pI4h/%d -> %pI4h/%d\n", rc,
-	       &local_ip, local_port, &peer_ip, peer_port);
+		     "Error %d connecting %pI4h/%d -> %pI4h/%d\n", rc,
+		     &local_ip, local_port, &peer_ip, peer_port);
 
 	sock_release(*sockp);
 	return rc;
 }
-
 EXPORT_SYMBOL(lnet_sock_connect);
-- 
1.7.1
