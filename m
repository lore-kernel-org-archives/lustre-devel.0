From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:14:53 -0500
Subject: [lustre-devel] [PATCH 425/622] lnet: support non-default network
 namespace
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-426-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Aurelien Degremont <degremoa@amazon.com>

Replace hard coded references to default root network namespace
(&init_net) in LNET code (LNET, socklnd and o2iblnd).

When a network interface is created, Lustre records the current
network namespace. This patch improves the LNET code to use
this reference namespace most of the time instead of the root
network namespace. When using lctl, lnetctl or insmod, we
use the current process network namespace.
When starting the listening acceptor, we use the namespace of the
process that triggers this start.

An additional patch is needed for RPCSEC GSS support.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12236
Lustre-commit: 93b08edfb1c6 ("LU-12236 lnet: support non-default network namespace")
Signed-off-by: Aurelien Degremont <degremoa@amazon.com>
Reviewed-on: https://review.whamcloud.com/34768
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Shaun Tancheff <stancheff@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h       |  9 +++++----
 net/lnet/klnds/o2iblnd/o2iblnd.c    | 22 +++++++++++-----------
 net/lnet/klnds/o2iblnd/o2iblnd.h    |  9 ++++-----
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c |  8 +++++---
 net/lnet/klnds/socklnd/socklnd.c    |  2 +-
 net/lnet/klnds/socklnd/socklnd_cb.c |  3 ++-
 net/lnet/lnet/acceptor.c            | 11 +++++++----
 net/lnet/lnet/config.c              |  6 +++---
 net/lnet/lnet/lib-socket.c          | 13 +++++++------
 9 files changed, 45 insertions(+), 38 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index b1407b3..b889af2 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -717,7 +717,7 @@ void lnet_copy_kiov2iter(struct iov_iter *to,
 void lnet_unregister_lnd(struct lnet_lnd *lnd);
 
 int lnet_connect(struct socket **sockp, lnet_nid_t peer_nid,
-		 u32 local_ip, u32 peer_ip, int peer_port);
+		 u32 local_ip, u32 peer_ip, int peer_port, struct net *ns);
 void lnet_connect_console_error(int rc, lnet_nid_t peer_nid,
 				u32 peer_ip, int port);
 int lnet_count_acceptor_nets(void);
@@ -738,18 +738,19 @@ struct lnet_inetdev {
 	char	li_name[IFNAMSIZ];
 };
 
-int lnet_inet_enumerate(struct lnet_inetdev **dev_list);
+int lnet_inet_enumerate(struct lnet_inetdev **dev_list, struct net *ns);
 int lnet_sock_setbuf(struct socket *socket, int txbufsize, int rxbufsize);
 int lnet_sock_getbuf(struct socket *socket, int *txbufsize, int *rxbufsize);
 int lnet_sock_getaddr(struct socket *socket, bool remote, u32 *ip, int *port);
 int lnet_sock_write(struct socket *sock, void *buffer, int nob, int timeout);
 int lnet_sock_read(struct socket *sock, void *buffer, int nob, int timeout);
 
-int lnet_sock_listen(struct socket **sockp, u32 ip, int port, int backlog);
+int lnet_sock_listen(struct socket **sockp, u32 ip, int port, int backlog,
+		     struct net *ns);
 int lnet_sock_accept(struct socket **newsockp, struct socket *sock);
 int lnet_sock_connect(struct socket **sockp, int *fatal,
 		      u32 local_ip, int local_port,
-		      u32 peer_ip, int peer_port);
+		      u32 peer_ip, int peer_port, struct net *ns);
 void libcfs_sock_release(struct socket *sock);
 
 int lnet_peers_start_down(void);
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index bb7590f..f3176e1 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2358,7 +2358,7 @@ static int kiblnd_dummy_callback(struct rdma_cm_id *cmid,
 	return 0;
 }
 
-static int kiblnd_dev_need_failover(struct kib_dev *dev)
+static int kiblnd_dev_need_failover(struct kib_dev *dev, struct net *ns)
 {
 	struct rdma_cm_id *cmid;
 	struct sockaddr_in srcaddr;
@@ -2382,8 +2382,8 @@ static int kiblnd_dev_need_failover(struct kib_dev *dev)
 	 * a. rdma_bind_addr(), it will conflict with listener cmid
 	 * b. rdma_resolve_addr() to zero addr
 	 */
-	cmid = kiblnd_rdma_create_id(kiblnd_dummy_callback, dev, RDMA_PS_TCP,
-				     IB_QPT_RC);
+	cmid = kiblnd_rdma_create_id(ns, kiblnd_dummy_callback, dev,
+				     RDMA_PS_TCP, IB_QPT_RC);
 	if (IS_ERR(cmid)) {
 		rc = PTR_ERR(cmid);
 		CERROR("Failed to create cmid for failover: %d\n", rc);
@@ -2412,7 +2412,7 @@ static int kiblnd_dev_need_failover(struct kib_dev *dev)
 	return rc;
 }
 
-int kiblnd_dev_failover(struct kib_dev *dev)
+int kiblnd_dev_failover(struct kib_dev *dev, struct net *ns)
 {
 	LIST_HEAD(zombie_tpo);
 	LIST_HEAD(zombie_ppo);
@@ -2429,7 +2429,7 @@ int kiblnd_dev_failover(struct kib_dev *dev)
 	LASSERT(*kiblnd_tunables.kib_dev_failover > 1 ||
 		dev->ibd_can_failover || !dev->ibd_hdev);
 
-	rc = kiblnd_dev_need_failover(dev);
+	rc = kiblnd_dev_need_failover(dev, ns);
 	if (rc <= 0)
 		goto out;
 
@@ -2454,7 +2454,7 @@ int kiblnd_dev_failover(struct kib_dev *dev)
 		rdma_destroy_id(cmid);
 	}
 
-	cmid = kiblnd_rdma_create_id(kiblnd_cm_callback, dev, RDMA_PS_TCP,
+	cmid = kiblnd_rdma_create_id(ns, kiblnd_cm_callback, dev, RDMA_PS_TCP,
 				     IB_QPT_RC);
 	if (IS_ERR(cmid)) {
 		rc = PTR_ERR(cmid);
@@ -2683,7 +2683,7 @@ static void kiblnd_shutdown(struct lnet_ni *ni)
 		kiblnd_base_shutdown();
 }
 
-static int kiblnd_base_startup(void)
+static int kiblnd_base_startup(struct net *ns)
 {
 	struct kib_sched_info *sched;
 	int rc;
@@ -2758,7 +2758,7 @@ static int kiblnd_base_startup(void)
 	}
 
 	if (*kiblnd_tunables.kib_dev_failover)
-		rc = kiblnd_thread_start(kiblnd_failover_thread, NULL,
+		rc = kiblnd_thread_start(kiblnd_failover_thread, ns,
 					 "kiblnd_failover");
 
 	if (rc) {
@@ -2856,7 +2856,7 @@ static int kiblnd_startup(struct lnet_ni *ni)
 	LASSERT(ni->ni_net->net_lnd == &the_o2iblnd);
 
 	if (kiblnd_data.kib_init == IBLND_INIT_NOTHING) {
-		rc = kiblnd_base_startup();
+		rc = kiblnd_base_startup(ni->ni_net_ns);
 		if (rc)
 			return rc;
 	}
@@ -2894,7 +2894,7 @@ static int kiblnd_startup(struct lnet_ni *ni)
 		goto failed;
 	}
 
-	rc = lnet_inet_enumerate(&ifaces);
+	rc = lnet_inet_enumerate(&ifaces, ni->ni_net_ns);
 	if (rc < 0)
 		goto failed;
 
@@ -2925,7 +2925,7 @@ static int kiblnd_startup(struct lnet_ni *ni)
 	INIT_LIST_HEAD(&ibdev->ibd_fail_list);
 
 	/* initialize the device */
-	rc = kiblnd_dev_failover(ibdev);
+	rc = kiblnd_dev_failover(ibdev, ni->ni_net_ns);
 	if (rc) {
 		CERROR("ko2iblnd: Can't initialize device: rc = %d\n", rc);
 		goto failed;
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index 2f7ca52..1285ab1 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -109,10 +109,9 @@ struct kib_tunables {
 					IBLND_CREDIT_HIGHWATER_V1 : \
 					t->lnd_peercredits_hiw)
 
-#define kiblnd_rdma_create_id(cb, dev, ps, qpt) rdma_create_id(current->nsproxy->net_ns, \
-							       cb, dev, \
-							       ps, qpt)
-
+# define kiblnd_rdma_create_id(ns, cb, dev, ps, qpt) rdma_create_id(ns, cb, \
+								    dev, ps, \
+								    qpt)
 /* 2 OOB shall suffice for 1 keepalive and 1 returning credits */
 #define IBLND_OOB_CAPABLE(v)	((v) != IBLND_MSG_VERSION_1)
 #define IBLND_OOB_MSGS(v)	(IBLND_OOB_CAPABLE(v) ? 2 : 0)
@@ -1030,7 +1029,7 @@ int kiblnd_cm_callback(struct rdma_cm_id *cmid,
 		       struct rdma_cm_event *event);
 int kiblnd_translate_mtu(int value);
 
-int kiblnd_dev_failover(struct kib_dev *dev);
+int kiblnd_dev_failover(struct kib_dev *dev, struct net *ns);
 int kiblnd_create_peer(struct lnet_ni *ni, struct kib_peer_ni **peerp,
 		       lnet_nid_t nid);
 void kiblnd_destroy_peer(struct kib_peer_ni *peer_ni);
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 69918cf..1110553 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1330,8 +1330,9 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 	LASSERT(net);
 	LASSERT(peer_ni->ibp_connecting > 0);
 
-	cmid = kiblnd_rdma_create_id(kiblnd_cm_callback, peer_ni, RDMA_PS_TCP,
-				     IB_QPT_RC);
+	cmid = kiblnd_rdma_create_id(peer_ni->ibp_ni->ni_net_ns,
+				     kiblnd_cm_callback, peer_ni,
+				     RDMA_PS_TCP, IB_QPT_RC);
 
 	if (IS_ERR(cmid)) {
 		CERROR("Can't create CMID for %s: %ld\n",
@@ -3830,6 +3831,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 {
 	rwlock_t *glock = &kiblnd_data.kib_global_lock;
 	struct kib_dev *dev;
+	struct net *ns = arg;
 	wait_queue_entry_t wait;
 	unsigned long flags;
 	int rc;
@@ -3856,7 +3858,7 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
 			dev->ibd_failover = 1;
 			write_unlock_irqrestore(glock, flags);
 
-			rc = kiblnd_dev_failover(dev);
+			rc = kiblnd_dev_failover(dev, ns);
 
 			write_lock_irqsave(glock, flags);
 
diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 0f5c7fc..78f6c7e 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -2718,7 +2718,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 		net_tunables->lct_peer_rtr_credits =
 			*ksocknal_tunables.ksnd_peerrtrcredits;
 
-	rc = lnet_inet_enumerate(&ifaces);
+	rc = lnet_inet_enumerate(&ifaces, ni->ni_net_ns);
 	if (rc < 0)
 		goto fail_1;
 
diff --git a/net/lnet/klnds/socklnd/socklnd_cb.c b/net/lnet/klnds/socklnd/socklnd_cb.c
index 581f734..0132727 100644
--- a/net/lnet/klnds/socklnd/socklnd_cb.c
+++ b/net/lnet/klnds/socklnd/socklnd_cb.c
@@ -1871,7 +1871,8 @@ void ksocknal_write_callback(struct ksock_conn *conn)
 
 		rc = lnet_connect(&sock, peer_ni->ksnp_id.nid,
 				  route->ksnr_myipaddr,
-				  route->ksnr_ipaddr, route->ksnr_port);
+				  route->ksnr_ipaddr, route->ksnr_port,
+				  peer_ni->ksnp_ni->ni_net_ns);
 		if (rc)
 			goto failed;
 
diff --git a/net/lnet/lnet/acceptor.c b/net/lnet/lnet/acceptor.c
index 1854347..23b5bf0 100644
--- a/net/lnet/lnet/acceptor.c
+++ b/net/lnet/lnet/acceptor.c
@@ -44,6 +44,7 @@
 	int			pta_shutdown;
 	struct socket		*pta_sock;
 	struct completion	pta_signal;
+	struct net		*pta_ns;
 } lnet_acceptor_state = {
 	.pta_shutdown = 1
 };
@@ -142,7 +143,7 @@
 
 int
 lnet_connect(struct socket **sockp, lnet_nid_t peer_nid,
-	     u32 local_ip, u32 peer_ip, int peer_port)
+	     u32 local_ip, u32 peer_ip, int peer_port, struct net *ns)
 {
 	struct lnet_acceptor_connreq cr;
 	struct socket *sock;
@@ -158,7 +159,7 @@
 		/* Iterate through reserved ports. */
 
 		rc = lnet_sock_connect(&sock, &fatal, local_ip, port, peer_ip,
-				       peer_port);
+				       peer_port, ns);
 		if (rc) {
 			if (fatal)
 				goto failed;
@@ -335,8 +336,9 @@
 
 	LASSERT(!lnet_acceptor_state.pta_sock);
 
-	rc = lnet_sock_listen(&lnet_acceptor_state.pta_sock, 0, accept_port,
-			      accept_backlog);
+	rc = lnet_sock_listen(&lnet_acceptor_state.pta_sock,
+			      0, accept_port, accept_backlog,
+			      lnet_acceptor_state.pta_ns);
 	if (rc) {
 		if (rc == -EADDRINUSE)
 			LCONSOLE_ERROR_MSG(0x122, "Can't start acceptor on port %d: port already in use\n",
@@ -457,6 +459,7 @@
 	if (!lnet_count_acceptor_nets())  /* not required */
 		return 0;
 
+	lnet_acceptor_state.pta_ns = current->nsproxy->net_ns;
 	task = kthread_run(lnet_acceptor, (void *)(uintptr_t)secure,
 			   "acceptor_%03ld", secure);
 	if (IS_ERR(task)) {
diff --git a/net/lnet/lnet/config.c b/net/lnet/lnet/config.c
index a2a9c79..2c8edcd 100644
--- a/net/lnet/lnet/config.c
+++ b/net/lnet/lnet/config.c
@@ -1563,7 +1563,7 @@ struct lnet_ni *
 	return count;
 }
 
-int lnet_inet_enumerate(struct lnet_inetdev **dev_list)
+int lnet_inet_enumerate(struct lnet_inetdev **dev_list, struct net *ns)
 {
 	struct lnet_inetdev *ifaces = NULL;
 	struct net_device *dev;
@@ -1571,7 +1571,7 @@ int lnet_inet_enumerate(struct lnet_inetdev **dev_list)
 	int nip = 0;
 
 	rtnl_lock();
-	for_each_netdev(&init_net, dev) {
+	for_each_netdev(ns, dev) {
 		int flags = dev_get_flags(dev);
 		const struct in_ifaddr *ifa;
 		struct in_device *in_dev;
@@ -1642,7 +1642,7 @@ int lnet_inet_enumerate(struct lnet_inetdev **dev_list)
 	int rc;
 	int i;
 
-	nip = lnet_inet_enumerate(&ifaces);
+	nip = lnet_inet_enumerate(&ifaces, current->nsproxy->net_ns);
 	if (nip < 0) {
 		if (nip != -ENOENT) {
 			LCONSOLE_ERROR_MSG(0x117,
diff --git a/net/lnet/lnet/lib-socket.c b/net/lnet/lnet/lib-socket.c
index d430d6f..046bd2d 100644
--- a/net/lnet/lnet/lib-socket.c
+++ b/net/lnet/lnet/lib-socket.c
@@ -156,7 +156,7 @@
 
 static int
 lnet_sock_create(struct socket **sockp, int *fatal, u32 local_ip,
-		 int local_port)
+		 int local_port, struct net *ns)
 {
 	struct sockaddr_in locaddr;
 	struct socket *sock;
@@ -166,7 +166,7 @@
 	/* All errors are fatal except bind failure if the port is in use */
 	*fatal = 1;
 
-	rc = sock_create_kern(&init_net, PF_INET, SOCK_STREAM, 0, &sock);
+	rc = sock_create_kern(ns, PF_INET, SOCK_STREAM, 0, &sock);
 	*sockp = sock;
 	if (rc) {
 		CERROR("Can't create socket: %d\n", rc);
@@ -282,12 +282,12 @@
 
 int
 lnet_sock_listen(struct socket **sockp, u32 local_ip, int local_port,
-		 int backlog)
+		 int backlog, struct net *ns)
 {
 	int fatal;
 	int rc;
 
-	rc = lnet_sock_create(sockp, &fatal, local_ip, local_port);
+	rc = lnet_sock_create(sockp, &fatal, local_ip, local_port, ns);
 	if (rc) {
 		if (!fatal)
 			CERROR("Can't create socket: port %d already in use\n",
@@ -347,12 +347,13 @@
 
 int
 lnet_sock_connect(struct socket **sockp, int *fatal, u32 local_ip,
-		  int local_port, u32 peer_ip, int peer_port)
+		  int local_port, u32 peer_ip, int peer_port,
+		  struct net *ns)
 {
 	struct sockaddr_in srvaddr;
 	int rc;
 
-	rc = lnet_sock_create(sockp, fatal, local_ip, local_port);
+	rc = lnet_sock_create(sockp, fatal, local_ip, local_port, ns);
 	if (rc)
 		return rc;
 
-- 
1.8.3.1
