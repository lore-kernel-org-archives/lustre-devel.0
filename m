From: NeilBrown <neilb@suse.com>
Date: Tue, 09 Jan 2018 12:19:38 +1100
Subject: [lustre-devel] [PATCH 01/14] staging: lustre: replace simple cases
 of LIBCFS_ALLOC with kzalloc.
In-Reply-To: <151546052331.9776.7408338350463291753.stgit@noble>
References: <151546052331.9776.7408338350463291753.stgit@noble>
Message-ID: <151546077813.9776.9595918013533133469.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

All usages of the form
  LIBCFS_ALLOC(variable, sizeof(variable))
or
  LIBCFS_ALLOC(variable, sizeof(variable's-type))

are changed to
  variable = kzalloc(sizeof(...), GFP_NOFS);

Similarly, all
   LIBCFS_FREE(variable, sizeof(variable))
become
   kfree(variable);

None of these need the vmalloc option, or any of the other minor
benefits of LIBCFS_ALLOC().

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   39 ++++++++++----------
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |    4 +-
 .../lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c  |    4 +-
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |   22 ++++++-----
 .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |    2 +
 .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |    8 ++--
 drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c    |    4 +-
 drivers/staging/lustre/lnet/libcfs/libcfs_lock.c   |    6 ++-
 drivers/staging/lustre/lnet/libcfs/libcfs_string.c |   10 +++--
 .../staging/lustre/lnet/libcfs/linux/linux-cpu.c   |   19 ++++------
 drivers/staging/lustre/lnet/libcfs/workitem.c      |    8 ++--
 drivers/staging/lustre/lnet/lnet/api-ni.c          |    4 +-
 drivers/staging/lustre/lnet/lnet/config.c          |    7 ++--
 drivers/staging/lustre/lnet/lnet/lib-move.c        |    6 ++-
 drivers/staging/lustre/lnet/lnet/nidstrings.c      |    8 ++--
 drivers/staging/lustre/lnet/lnet/peer.c            |    2 +
 drivers/staging/lustre/lnet/lnet/router.c          |   28 ++++++--------
 drivers/staging/lustre/lnet/lnet/router_proc.c     |    6 ++-
 drivers/staging/lustre/lnet/selftest/conrpc.c      |   10 +++--
 drivers/staging/lustre/lnet/selftest/console.c     |   26 +++++++------
 drivers/staging/lustre/lnet/selftest/framework.c   |   22 ++++++-----
 drivers/staging/lustre/lnet/selftest/rpc.c         |   12 +++---
 22 files changed, 124 insertions(+), 133 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
index 8024843521ab..3aa81168c84f 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
@@ -367,7 +367,7 @@ void kiblnd_destroy_peer(struct kib_peer *peer)
 	LASSERT(kiblnd_peer_idle(peer));
 	LASSERT(list_empty(&peer->ibp_tx_queue));
 
-	LIBCFS_FREE(peer, sizeof(*peer));
+	kfree(peer);
 
 	/*
 	 * NB a peer's connections keep a reference on their peer until
@@ -776,7 +776,7 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer *peer, struct rdma_cm_id *cm
 		goto failed_2;
 	}
 
-	LIBCFS_FREE(init_qp_attr, sizeof(*init_qp_attr));
+	kfree(init_qp_attr);
 
 	/* 1 ref for caller and each rxmsg */
 	atomic_set(&conn->ibc_refcount, 1 + IBLND_RX_MSGS(conn));
@@ -828,7 +828,7 @@ struct kib_conn *kiblnd_create_conn(struct kib_peer *peer, struct rdma_cm_id *cm
  failed_2:
 	kiblnd_destroy_conn(conn, true);
  failed_1:
-	LIBCFS_FREE(init_qp_attr, sizeof(*init_qp_attr));
+	kfree(init_qp_attr);
  failed_0:
 	return NULL;
 }
@@ -882,8 +882,7 @@ void kiblnd_destroy_conn(struct kib_conn *conn, bool free_conn)
 			    IBLND_RX_MSGS(conn) * sizeof(struct kib_rx));
 	}
 
-	if (conn->ibc_connvars)
-		LIBCFS_FREE(conn->ibc_connvars, sizeof(*conn->ibc_connvars));
+	kfree(conn->ibc_connvars);
 
 	if (conn->ibc_hdev)
 		kiblnd_hdev_decref(conn->ibc_hdev);
@@ -897,7 +896,7 @@ void kiblnd_destroy_conn(struct kib_conn *conn, bool free_conn)
 		atomic_dec(&net->ibn_nconns);
 	}
 
-	LIBCFS_FREE(conn, sizeof(*conn));
+	kfree(conn);
 }
 
 int kiblnd_close_peer_conns_locked(struct kib_peer *peer, int why)
@@ -1299,7 +1298,7 @@ static void kiblnd_destroy_fmr_pool(struct kib_fmr_pool *fpo)
 					 frd_list) {
 			list_del(&frd->frd_list);
 			ib_dereg_mr(frd->frd_mr);
-			LIBCFS_FREE(frd, sizeof(*frd));
+			kfree(frd);
 			i++;
 		}
 		if (i < fpo->fast_reg.fpo_pool_size)
@@ -1310,7 +1309,7 @@ static void kiblnd_destroy_fmr_pool(struct kib_fmr_pool *fpo)
 	if (fpo->fpo_hdev)
 		kiblnd_hdev_decref(fpo->fpo_hdev);
 
-	LIBCFS_FREE(fpo, sizeof(*fpo));
+	kfree(fpo);
 }
 
 static void kiblnd_destroy_fmr_pool_list(struct list_head *head)
@@ -1405,14 +1404,14 @@ static int kiblnd_alloc_freg_pool(struct kib_fmr_poolset *fps, struct kib_fmr_po
 out_middle:
 	if (frd->frd_mr)
 		ib_dereg_mr(frd->frd_mr);
-	LIBCFS_FREE(frd, sizeof(*frd));
+	kfree(frd);
 
 out:
 	list_for_each_entry_safe(frd, tmp, &fpo->fast_reg.fpo_pool_list,
 				 frd_list) {
 		list_del(&frd->frd_list);
 		ib_dereg_mr(frd->frd_mr);
-		LIBCFS_FREE(frd, sizeof(*frd));
+		kfree(frd);
 	}
 
 	return rc;
@@ -1464,7 +1463,7 @@ static int kiblnd_create_fmr_pool(struct kib_fmr_poolset *fps,
 
 out_fpo:
 	kiblnd_hdev_decref(fpo->fpo_hdev);
-	LIBCFS_FREE(fpo, sizeof(*fpo));
+	kfree(fpo);
 	return rc;
 }
 
@@ -2011,7 +2010,7 @@ static void kiblnd_destroy_tx_pool(struct kib_pool *pool)
 		    pool->po_size * sizeof(struct kib_tx));
 out:
 	kiblnd_fini_pool(pool);
-	LIBCFS_FREE(tpo, sizeof(*tpo));
+	kfree(tpo);
 }
 
 static int kiblnd_tx_pool_size(int ncpts)
@@ -2043,7 +2042,7 @@ static int kiblnd_create_tx_pool(struct kib_poolset *ps, int size,
 	npg = DIV_ROUND_UP(size * IBLND_MSG_SIZE, PAGE_SIZE);
 	if (kiblnd_alloc_pages(&tpo->tpo_tx_pages, ps->ps_cpt, npg)) {
 		CERROR("Can't allocate tx pages: %d\n", npg);
-		LIBCFS_FREE(tpo, sizeof(*tpo));
+		kfree(tpo);
 		return -ENOMEM;
 	}
 
@@ -2263,7 +2262,7 @@ void kiblnd_hdev_destroy(struct kib_hca_dev *hdev)
 	if (hdev->ibh_cmid)
 		rdma_destroy_id(hdev->ibh_cmid);
 
-	LIBCFS_FREE(hdev, sizeof(*hdev));
+	kfree(hdev);
 }
 
 /* DUMMY */
@@ -2392,7 +2391,7 @@ int kiblnd_dev_failover(struct kib_dev *dev)
 		goto out;
 	}
 
-	LIBCFS_ALLOC(hdev, sizeof(*hdev));
+	hdev = kzalloc(sizeof(*hdev), GFP_NOFS);
 	if (!hdev) {
 		CERROR("Failed to allocate kib_hca_dev\n");
 		rdma_destroy_id(cmid);
@@ -2471,7 +2470,7 @@ void kiblnd_destroy_dev(struct kib_dev *dev)
 	if (dev->ibd_hdev)
 		kiblnd_hdev_decref(dev->ibd_hdev);
 
-	LIBCFS_FREE(dev, sizeof(*dev));
+	kfree(dev);
 }
 
 static struct kib_dev *kiblnd_create_dev(char *ifname)
@@ -2495,7 +2494,7 @@ static struct kib_dev *kiblnd_create_dev(char *ifname)
 		return NULL;
 	}
 
-	LIBCFS_ALLOC(dev, sizeof(*dev));
+	dev = kzalloc(sizeof(*dev), GFP_NOFS);
 	if (!dev)
 		return NULL;
 
@@ -2517,7 +2516,7 @@ static struct kib_dev *kiblnd_create_dev(char *ifname)
 	rc = kiblnd_dev_failover(dev);
 	if (rc) {
 		CERROR("Can't initialize device: %d\n", rc);
-		LIBCFS_FREE(dev, sizeof(*dev));
+		kfree(dev);
 		return NULL;
 	}
 
@@ -2648,7 +2647,7 @@ static void kiblnd_shutdown(struct lnet_ni *ni)
 	net->ibn_init = IBLND_INIT_NOTHING;
 	ni->ni_data = NULL;
 
-	LIBCFS_FREE(net, sizeof(*net));
+	kfree(net);
 
 out:
 	if (list_empty(&kiblnd_data.kib_devs))
@@ -2865,7 +2864,7 @@ static int kiblnd_startup(struct lnet_ni *ni)
 			return rc;
 	}
 
-	LIBCFS_ALLOC(net, sizeof(*net));
+	net = kzalloc(sizeof(*net), GFP_NOFS);
 	ni->ni_data = net;
 	if (!net)
 		goto net_failed;
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 40e3af5d8b04..9b3328c5d1e7 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -2124,7 +2124,7 @@ kiblnd_connreq_done(struct kib_conn *conn, int status)
 		 (conn->ibc_state == IBLND_CONN_PASSIVE_WAIT &&
 		 peer->ibp_accepting > 0));
 
-	LIBCFS_FREE(conn->ibc_connvars, sizeof(*conn->ibc_connvars));
+	kfree(conn->ibc_connvars);
 	conn->ibc_connvars = NULL;
 
 	if (status) {
@@ -3363,7 +3363,7 @@ kiblnd_connd(void *arg)
 
 			reconn += kiblnd_reconnect_peer(conn->ibc_peer);
 			kiblnd_peer_decref(conn->ibc_peer);
-			LIBCFS_FREE(conn, sizeof(*conn));
+			kfree(conn);
 
 			spin_lock_irqsave(lock, flags);
 		}
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
index a71b765215ad..b9235400bf1d 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c
@@ -181,8 +181,8 @@ int kiblnd_tunables_setup(struct lnet_ni *ni)
 	 * defaulted
 	 */
 	if (!ni->ni_lnd_tunables) {
-		LIBCFS_ALLOC(ni->ni_lnd_tunables,
-			     sizeof(*ni->ni_lnd_tunables));
+		ni->ni_lnd_tunables = kzalloc(sizeof(*ni->ni_lnd_tunables),
+					      GFP_NOFS);
 		if (!ni->ni_lnd_tunables)
 			return -ENOMEM;
 
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 8267119ccc8e..51157ae14a9e 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -66,7 +66,7 @@ ksocknal_create_route(__u32 ipaddr, int port)
 {
 	struct ksock_route *route;
 
-	LIBCFS_ALLOC(route, sizeof(*route));
+	route = kzalloc(sizeof(*route), GFP_NOFS);
 	if (!route)
 		return NULL;
 
@@ -93,7 +93,7 @@ ksocknal_destroy_route(struct ksock_route *route)
 	if (route->ksnr_peer)
 		ksocknal_peer_decref(route->ksnr_peer);
 
-	LIBCFS_FREE(route, sizeof(*route));
+	kfree(route);
 }
 
 static int
@@ -132,7 +132,7 @@ ksocknal_create_peer(struct ksock_peer **peerp, struct lnet_ni *ni,
 	if (net->ksnn_shutdown) {
 		spin_unlock_bh(&net->ksnn_lock);
 
-		LIBCFS_FREE(peer, sizeof(*peer));
+		kfree(peer);
 		CERROR("Can't create peer: network shutdown\n");
 		return -ESHUTDOWN;
 	}
@@ -160,7 +160,7 @@ ksocknal_destroy_peer(struct ksock_peer *peer)
 	LASSERT(list_empty(&peer->ksnp_tx_queue));
 	LASSERT(list_empty(&peer->ksnp_zc_req_list));
 
-	LIBCFS_FREE(peer, sizeof(*peer));
+	kfree(peer);
 
 	/*
 	 * NB a peer's connections and routes keep a reference on their peer
@@ -985,7 +985,7 @@ ksocknal_accept(struct lnet_ni *ni, struct socket *sock)
 	rc = lnet_sock_getaddr(sock, 1, &peer_ip, &peer_port);
 	LASSERT(!rc);		      /* we succeeded before */
 
-	LIBCFS_ALLOC(cr, sizeof(*cr));
+	cr = kzalloc(sizeof(*cr), GFP_NOFS);
 	if (!cr) {
 		LCONSOLE_ERROR_MSG(0x12f, "Dropping connection request from %pI4h: memory exhausted\n",
 				   &peer_ip);
@@ -1043,7 +1043,7 @@ ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
 
 	LASSERT(active == (type != SOCKLND_CONN_NONE));
 
-	LIBCFS_ALLOC(conn, sizeof(*conn));
+	conn = kzalloc(sizeof(*conn), GFP_NOFS);
 	if (!conn) {
 		rc = -ENOMEM;
 		goto failed_0;
@@ -1419,7 +1419,7 @@ ksocknal_create_conn(struct lnet_ni *ni, struct ksock_route *route,
 		LIBCFS_FREE(hello, offsetof(struct ksock_hello_msg,
 					    kshm_ips[LNET_MAX_INTERFACES]));
 
-	LIBCFS_FREE(conn, sizeof(*conn));
+	kfree(conn);
 
 failed_0:
 	sock_release(sock);
@@ -1716,7 +1716,7 @@ ksocknal_destroy_conn(struct ksock_conn *conn)
 
 	ksocknal_peer_decref(conn->ksnc_peer);
 
-	LIBCFS_FREE(conn, sizeof(*conn));
+	kfree(conn);
 }
 
 int
@@ -2622,7 +2622,7 @@ ksocknal_shutdown(struct lnet_ni *ni)
 	}
 
 	list_del(&net->ksnn_list);
-	LIBCFS_FREE(net, sizeof(*net));
+	kfree(net);
 
 	ksocknal_data.ksnd_nnets--;
 	if (!ksocknal_data.ksnd_nnets)
@@ -2815,7 +2815,7 @@ ksocknal_startup(struct lnet_ni *ni)
 			return rc;
 	}
 
-	LIBCFS_ALLOC(net, sizeof(*net));
+	net = kzalloc(sizeof(*net), GFP_NOFS);
 	if (!net)
 		goto fail_0;
 
@@ -2877,7 +2877,7 @@ ksocknal_startup(struct lnet_ni *ni)
 	return 0;
 
  fail_1:
-	LIBCFS_FREE(net, sizeof(*net));
+	kfree(net);
  fail_0:
 	if (!ksocknal_data.ksnd_nnets)
 		ksocknal_base_shutdown();
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
index 27c56d5ae4e5..994b6693c6b7 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_cb.c
@@ -2117,7 +2117,7 @@ ksocknal_connd(void *arg)
 			ksocknal_create_conn(cr->ksncr_ni, NULL,
 					     cr->ksncr_sock, SOCKLND_CONN_NONE);
 			lnet_ni_decref(cr->ksncr_ni);
-			LIBCFS_FREE(cr, sizeof(*cr));
+			kfree(cr);
 
 			spin_lock_bh(connd_lock);
 		}
diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
index d827f770e831..05982dac781c 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd_proto.c
@@ -467,7 +467,7 @@ ksocknal_send_hello_v1(struct ksock_conn *conn, struct ksock_hello_msg *hello)
 
 	BUILD_BUG_ON(sizeof(struct lnet_magicversion) != offsetof(struct lnet_hdr, src_nid));
 
-	LIBCFS_ALLOC(hdr, sizeof(*hdr));
+	hdr = kzalloc(sizeof(*hdr), GFP_NOFS);
 	if (!hdr) {
 		CERROR("Can't allocate struct lnet_hdr\n");
 		return -ENOMEM;
@@ -526,7 +526,7 @@ ksocknal_send_hello_v1(struct ksock_conn *conn, struct ksock_hello_msg *hello)
 			&conn->ksnc_ipaddr, conn->ksnc_port);
 	}
 out:
-	LIBCFS_FREE(hdr, sizeof(*hdr));
+	kfree(hdr);
 
 	return rc;
 }
@@ -582,7 +582,7 @@ ksocknal_recv_hello_v1(struct ksock_conn *conn, struct ksock_hello_msg *hello,
 	int rc;
 	int i;
 
-	LIBCFS_ALLOC(hdr, sizeof(*hdr));
+	hdr = kzalloc(sizeof(*hdr), GFP_NOFS);
 	if (!hdr) {
 		CERROR("Can't allocate struct lnet_hdr\n");
 		return -ENOMEM;
@@ -644,7 +644,7 @@ ksocknal_recv_hello_v1(struct ksock_conn *conn, struct ksock_hello_msg *hello,
 		}
 	}
 out:
-	LIBCFS_FREE(hdr, sizeof(*hdr));
+	kfree(hdr);
 
 	return rc;
 }
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
index e3a4c67a66b5..d05c3932b3b9 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_cpu.c
@@ -51,7 +51,7 @@ cfs_cpt_table_alloc(unsigned int ncpt)
 		return NULL;
 	}
 
-	LIBCFS_ALLOC(cptab, sizeof(*cptab));
+	cptab = kzalloc(sizeof(*cptab), GFP_NOFS);
 	if (cptab) {
 		cptab->ctb_version = CFS_CPU_VERSION_MAGIC;
 		node_set(0, cptab->ctb_nodemask);
@@ -67,7 +67,7 @@ cfs_cpt_table_free(struct cfs_cpt_table *cptab)
 {
 	LASSERT(cptab->ctb_version == CFS_CPU_VERSION_MAGIC);
 
-	LIBCFS_FREE(cptab, sizeof(*cptab));
+	kfree(cptab);
 }
 EXPORT_SYMBOL(cfs_cpt_table_free);
 
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c b/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
index f6a0040f4ab1..670ad5a34224 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_lock.c
@@ -38,7 +38,7 @@ cfs_percpt_lock_free(struct cfs_percpt_lock *pcl)
 	LASSERT(!pcl->pcl_locked);
 
 	cfs_percpt_free(pcl->pcl_locks);
-	LIBCFS_FREE(pcl, sizeof(*pcl));
+	kfree(pcl);
 }
 EXPORT_SYMBOL(cfs_percpt_lock_free);
 
@@ -58,14 +58,14 @@ cfs_percpt_lock_create(struct cfs_cpt_table *cptab,
 	int i;
 
 	/* NB: cptab can be NULL, pcl will be for HW CPUs on that case */
-	LIBCFS_ALLOC(pcl, sizeof(*pcl));
+	pcl = kzalloc(sizeof(*pcl), GFP_NOFS);
 	if (!pcl)
 		return NULL;
 
 	pcl->pcl_cptab = cptab;
 	pcl->pcl_locks = cfs_percpt_alloc(cptab, sizeof(*lock));
 	if (!pcl->pcl_locks) {
-		LIBCFS_FREE(pcl, sizeof(*pcl));
+		kfree(pcl);
 		return NULL;
 	}
 
diff --git a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
index cb0533b36cc7..b8d1ce831ff1 100644
--- a/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
+++ b/drivers/staging/lustre/lnet/libcfs/libcfs_string.c
@@ -260,7 +260,7 @@ cfs_range_expr_parse(struct cfs_lstr *src, unsigned int min, unsigned int max,
 	struct cfs_range_expr *re;
 	struct cfs_lstr tok;
 
-	LIBCFS_ALLOC(re, sizeof(*re));
+	re = kzalloc(sizeof(*re), GFP_NOFS);
 	if (!re)
 		return -ENOMEM;
 
@@ -313,7 +313,7 @@ cfs_range_expr_parse(struct cfs_lstr *src, unsigned int min, unsigned int max,
 	return 0;
 
  failed:
-	LIBCFS_FREE(re, sizeof(*re));
+	kfree(re);
 	return -EINVAL;
 }
 
@@ -468,10 +468,10 @@ cfs_expr_list_free(struct cfs_expr_list *expr_list)
 		expr = list_entry(expr_list->el_exprs.next,
 				  struct cfs_range_expr, re_link);
 		list_del(&expr->re_link);
-		LIBCFS_FREE(expr, sizeof(*expr));
+		kfree(expr);
 	}
 
-	LIBCFS_FREE(expr_list, sizeof(*expr_list));
+	kfree(expr_list);
 }
 EXPORT_SYMBOL(cfs_expr_list_free);
 
@@ -490,7 +490,7 @@ cfs_expr_list_parse(char *str, int len, unsigned int min, unsigned int max,
 	struct cfs_lstr	src;
 	int rc;
 
-	LIBCFS_ALLOC(expr_list, sizeof(*expr_list));
+	expr_list = kzalloc(sizeof(*expr_list), GFP_NOFS);
 	if (!expr_list)
 		return -ENOMEM;
 
diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
index 2f5d8f300ef5..9679bd73025d 100644
--- a/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
+++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c
@@ -102,11 +102,7 @@ cfs_cpt_table_free(struct cfs_cpt_table *cptab)
 	for (i = 0; cptab->ctb_parts && i < cptab->ctb_nparts; i++) {
 		struct cfs_cpu_partition *part = &cptab->ctb_parts[i];
 
-		if (part->cpt_nodemask) {
-			LIBCFS_FREE(part->cpt_nodemask,
-				    sizeof(*part->cpt_nodemask));
-		}
-
+		kfree(part->cpt_nodemask);
 		if (part->cpt_cpumask)
 			LIBCFS_FREE(part->cpt_cpumask, cpumask_size());
 	}
@@ -116,12 +112,11 @@ cfs_cpt_table_free(struct cfs_cpt_table *cptab)
 			    cptab->ctb_nparts * sizeof(cptab->ctb_parts[0]));
 	}
 
-	if (cptab->ctb_nodemask)
-		LIBCFS_FREE(cptab->ctb_nodemask, sizeof(*cptab->ctb_nodemask));
+	kfree(cptab->ctb_nodemask);
 	if (cptab->ctb_cpumask)
 		LIBCFS_FREE(cptab->ctb_cpumask, cpumask_size());
 
-	LIBCFS_FREE(cptab, sizeof(*cptab));
+	kfree(cptab);
 }
 EXPORT_SYMBOL(cfs_cpt_table_free);
 
@@ -131,14 +126,15 @@ cfs_cpt_table_alloc(unsigned int ncpt)
 	struct cfs_cpt_table *cptab;
 	int i;
 
-	LIBCFS_ALLOC(cptab, sizeof(*cptab));
+	cptab = kzalloc(sizeof(*cptab), GFP_NOFS);
 	if (!cptab)
 		return NULL;
 
 	cptab->ctb_nparts = ncpt;
 
 	LIBCFS_ALLOC(cptab->ctb_cpumask, cpumask_size());
-	LIBCFS_ALLOC(cptab->ctb_nodemask, sizeof(*cptab->ctb_nodemask));
+	cptab->ctb_nodemask = kzalloc(sizeof(*cptab->ctb_nodemask),
+				      GFP_NOFS);
 
 	if (!cptab->ctb_cpumask || !cptab->ctb_nodemask)
 		goto failed;
@@ -159,7 +155,8 @@ cfs_cpt_table_alloc(unsigned int ncpt)
 		struct cfs_cpu_partition *part = &cptab->ctb_parts[i];
 
 		LIBCFS_ALLOC(part->cpt_cpumask, cpumask_size());
-		LIBCFS_ALLOC(part->cpt_nodemask, sizeof(*part->cpt_nodemask));
+		part->cpt_nodemask = kzalloc(sizeof(*part->cpt_nodemask),
+					     GFP_NOFS);
 		if (!part->cpt_cpumask || !part->cpt_nodemask)
 			goto failed;
 	}
diff --git a/drivers/staging/lustre/lnet/libcfs/workitem.c b/drivers/staging/lustre/lnet/libcfs/workitem.c
index 6a05d9bab8dc..74a9595dc730 100644
--- a/drivers/staging/lustre/lnet/libcfs/workitem.c
+++ b/drivers/staging/lustre/lnet/libcfs/workitem.c
@@ -328,7 +328,7 @@ cfs_wi_sched_destroy(struct cfs_wi_sched *sched)
 	spin_unlock(&cfs_wi_data.wi_glock);
 	LASSERT(!sched->ws_nscheduled);
 
-	LIBCFS_FREE(sched, sizeof(*sched));
+	kfree(sched);
 }
 EXPORT_SYMBOL(cfs_wi_sched_destroy);
 
@@ -344,12 +344,12 @@ cfs_wi_sched_create(char *name, struct cfs_cpt_table *cptab,
 	LASSERT(!cptab || cpt == CFS_CPT_ANY ||
 		(cpt >= 0 && cpt < cfs_cpt_number(cptab)));
 
-	LIBCFS_ALLOC(sched, sizeof(*sched));
+	sched = kzalloc(sizeof(*sched), GFP_NOFS);
 	if (!sched)
 		return -ENOMEM;
 
 	if (strlen(name) > sizeof(sched->ws_name) - 1) {
-		LIBCFS_FREE(sched, sizeof(*sched));
+		kfree(sched);
 		return -E2BIG;
 	}
 	strncpy(sched->ws_name, name, sizeof(sched->ws_name));
@@ -458,7 +458,7 @@ cfs_wi_shutdown(void)
 	}
 	list_for_each_entry_safe(sched, temp, &cfs_wi_data.wi_scheds, ws_list) {
 		list_del(&sched->ws_list);
-		LIBCFS_FREE(sched, sizeof(*sched));
+		kfree(sched);
 	}
 
 	cfs_wi_data.wi_stopping = 0;
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 30d0999118c7..e8f623190133 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1280,8 +1280,8 @@ lnet_startup_lndni(struct lnet_ni *ni, struct lnet_ioctl_config_data *conf)
 		lnd_tunables = (struct lnet_ioctl_config_lnd_tunables *)conf->cfg_bulk;
 
 	if (lnd_tunables) {
-		LIBCFS_ALLOC(ni->ni_lnd_tunables,
-			     sizeof(*ni->ni_lnd_tunables));
+		ni->ni_lnd_tunables = kzalloc(sizeof(*ni->ni_lnd_tunables),
+					      GFP_NOFS);
 		if (!ni->ni_lnd_tunables) {
 			mutex_unlock(&the_lnet.ln_lnd_mutex);
 			rc = -ENOMEM;
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index 0ba2a3940009..a1a3c35ea4dc 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -106,8 +106,7 @@ lnet_ni_free(struct lnet_ni *ni)
 	if (ni->ni_cpts)
 		cfs_expr_list_values_free(ni->ni_cpts, ni->ni_ncpts);
 
-	if (ni->ni_lnd_tunables)
-		LIBCFS_FREE(ni->ni_lnd_tunables, sizeof(*ni->ni_lnd_tunables));
+	kfree(ni->ni_lnd_tunables);
 
 	for (i = 0; i < LNET_MAX_INTERFACES && ni->ni_interfaces[i]; i++) {
 		LIBCFS_FREE(ni->ni_interfaces[i],
@@ -118,7 +117,7 @@ lnet_ni_free(struct lnet_ni *ni)
 	if (ni->ni_net_ns)
 		put_net(ni->ni_net_ns);
 
-	LIBCFS_FREE(ni, sizeof(*ni));
+	kfree(ni);
 }
 
 struct lnet_ni *
@@ -135,7 +134,7 @@ lnet_ni_alloc(__u32 net, struct cfs_expr_list *el, struct list_head *nilist)
 		return NULL;
 	}
 
-	LIBCFS_ALLOC(ni, sizeof(*ni));
+	ni = kzalloc(sizeof(*ni), GFP_NOFS);
 	if (!ni) {
 		CERROR("Out of memory creating network %s\n",
 		       libcfs_net2str(net));
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 137e3ab970dc..d724c4c73ecc 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -57,7 +57,7 @@ lnet_fail_nid(lnet_nid_t nid, unsigned int threshold)
 	/* NB: use lnet_net_lock(0) to serialize operations on test peers */
 	if (threshold) {
 		/* Adding a new entry */
-		LIBCFS_ALLOC(tp, sizeof(*tp));
+		tp = kzalloc(sizeof(*tp), GFP_NOFS);
 		if (!tp)
 			return -ENOMEM;
 
@@ -90,7 +90,7 @@ lnet_fail_nid(lnet_nid_t nid, unsigned int threshold)
 
 	list_for_each_entry_safe(tp, temp, &cull, tp_list) {
 		list_del(&tp->tp_list);
-		LIBCFS_FREE(tp, sizeof(*tp));
+		kfree(tp);
 	}
 	return 0;
 }
@@ -149,7 +149,7 @@ fail_peer(lnet_nid_t nid, int outgoing)
 	list_for_each_entry_safe(tp, temp, &cull, tp_list) {
 		list_del(&tp->tp_list);
 
-		LIBCFS_FREE(tp, sizeof(*tp));
+		kfree(tp);
 	}
 
 	return fail;
diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
index 05b120c2d45a..3aba1421c741 100644
--- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
+++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
@@ -166,7 +166,7 @@ parse_addrange(const struct cfs_lstr *src, struct nidrange *nidrange)
 		return 0;
 	}
 
-	LIBCFS_ALLOC(addrrange, sizeof(struct addrrange));
+	addrrange = kzalloc(sizeof(struct addrrange), GFP_NOFS);
 	if (!addrrange)
 		return -ENOMEM;
 	list_add_tail(&addrrange->ar_link, &nidrange->nr_addrranges);
@@ -225,7 +225,7 @@ add_nidrange(const struct cfs_lstr *src,
 		return nr;
 	}
 
-	LIBCFS_ALLOC(nr, sizeof(struct nidrange));
+	nr = kzalloc(sizeof(struct nidrange), GFP_NOFS);
 	if (!nr)
 		return NULL;
 	list_add_tail(&nr->nr_link, nidlist);
@@ -286,7 +286,7 @@ free_addrranges(struct list_head *list)
 
 		cfs_expr_list_free_list(&ar->ar_numaddr_ranges);
 		list_del(&ar->ar_link);
-		LIBCFS_FREE(ar, sizeof(struct addrrange));
+		kfree(ar);
 	}
 }
 
@@ -308,7 +308,7 @@ cfs_free_nidlist(struct list_head *list)
 		nr = list_entry(pos, struct nidrange, nr_link);
 		free_addrranges(&nr->nr_addrranges);
 		list_del(pos);
-		LIBCFS_FREE(nr, sizeof(struct nidrange));
+		kfree(nr);
 	}
 }
 EXPORT_SYMBOL(cfs_free_nidlist);
diff --git a/drivers/staging/lustre/lnet/lnet/peer.c b/drivers/staging/lustre/lnet/lnet/peer.c
index 5e94ad349454..19fcbcf0f642 100644
--- a/drivers/staging/lustre/lnet/lnet/peer.c
+++ b/drivers/staging/lustre/lnet/lnet/peer.c
@@ -212,7 +212,7 @@ lnet_peer_tables_cleanup(struct lnet_ni *ni)
 
 	list_for_each_entry_safe(lp, temp, &deathrow, lp_hashlist) {
 		list_del(&lp->lp_hashlist);
-		LIBCFS_FREE(lp, sizeof(*lp));
+		kfree(lp);
 	}
 }
 
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index f5b21c51c49c..409244e57a31 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -315,15 +315,13 @@ lnet_add_route(__u32 net, __u32 hops, lnet_nid_t gateway,
 		return -EEXIST;
 
 	/* Assume net, route, all new */
-	LIBCFS_ALLOC(route, sizeof(*route));
-	LIBCFS_ALLOC(rnet, sizeof(*rnet));
+	route = kzalloc(sizeof(*route), GFP_NOFS);
+	rnet = kzalloc(sizeof(*rnet), GFP_NOFS);
 	if (!route || !rnet) {
 		CERROR("Out of memory creating route %s %d %s\n",
 		       libcfs_net2str(net), hops, libcfs_nid2str(gateway));
-		if (route)
-			LIBCFS_FREE(route, sizeof(*route));
-		if (rnet)
-			LIBCFS_FREE(rnet, sizeof(*rnet));
+		kfree(route);
+		kfree(rnet);
 		return -ENOMEM;
 	}
 
@@ -339,8 +337,8 @@ lnet_add_route(__u32 net, __u32 hops, lnet_nid_t gateway,
 	if (rc) {
 		lnet_net_unlock(LNET_LOCK_EX);
 
-		LIBCFS_FREE(route, sizeof(*route));
-		LIBCFS_FREE(rnet, sizeof(*rnet));
+		kfree(route);
+		kfree(rnet);
 
 		if (rc == -EHOSTUNREACH) /* gateway is not on a local net */
 			return rc;	/* ignore the route entry */
@@ -395,11 +393,11 @@ lnet_add_route(__u32 net, __u32 hops, lnet_nid_t gateway,
 
 	if (!add_route) {
 		rc = -EEXIST;
-		LIBCFS_FREE(route, sizeof(*route));
+		kfree(route);
 	}
 
 	if (rnet != rnet2)
-		LIBCFS_FREE(rnet, sizeof(*rnet));
+		kfree(rnet);
 
 	/* indicate to startup the router checker if configured */
 	wake_up(&the_lnet.ln_rc_waitq);
@@ -517,10 +515,8 @@ lnet_del_route(__u32 net, lnet_nid_t gw_nid)
 
 			lnet_net_unlock(LNET_LOCK_EX);
 
-			LIBCFS_FREE(route, sizeof(*route));
-
-			if (rnet)
-				LIBCFS_FREE(rnet, sizeof(*rnet));
+			kfree(route);
+			kfree(rnet);
 
 			rc = 0;
 			lnet_net_lock(LNET_LOCK_EX);
@@ -891,7 +887,7 @@ lnet_destroy_rc_data(struct lnet_rc_data *rcd)
 	if (rcd->rcd_pinginfo)
 		LIBCFS_FREE(rcd->rcd_pinginfo, LNET_PINGINFO_SIZE);
 
-	LIBCFS_FREE(rcd, sizeof(*rcd));
+	kfree(rcd);
 }
 
 static struct lnet_rc_data *
@@ -905,7 +901,7 @@ lnet_create_rc_data_locked(struct lnet_peer *gateway)
 
 	lnet_net_unlock(gateway->lp_cpt);
 
-	LIBCFS_ALLOC(rcd, sizeof(*rcd));
+	rcd = kzalloc(sizeof(*rcd), GFP_NOFS);
 	if (!rcd)
 		goto out;
 
diff --git a/drivers/staging/lustre/lnet/lnet/router_proc.c b/drivers/staging/lustre/lnet/lnet/router_proc.c
index e863a5e0ab38..43038f930ba1 100644
--- a/drivers/staging/lustre/lnet/lnet/router_proc.c
+++ b/drivers/staging/lustre/lnet/lnet/router_proc.c
@@ -91,13 +91,13 @@ static int __proc_lnet_stats(void *data, int write,
 
 	/* read */
 
-	LIBCFS_ALLOC(ctrs, sizeof(*ctrs));
+	ctrs = kzalloc(sizeof(*ctrs), GFP_NOFS);
 	if (!ctrs)
 		return -ENOMEM;
 
 	LIBCFS_ALLOC(tmpstr, tmpsiz);
 	if (!tmpstr) {
-		LIBCFS_FREE(ctrs, sizeof(*ctrs));
+		kfree(ctrs);
 		return -ENOMEM;
 	}
 
@@ -119,7 +119,7 @@ static int __proc_lnet_stats(void *data, int write,
 					      tmpstr + pos, "\n");
 
 	LIBCFS_FREE(tmpstr, tmpsiz);
-	LIBCFS_FREE(ctrs, sizeof(*ctrs));
+	kfree(ctrs);
 	return rc;
 }
 
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index 6a0f770e0e24..7aa515c34594 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -129,7 +129,7 @@ lstcon_rpc_prep(struct lstcon_node *nd, int service, unsigned int feats,
 	spin_unlock(&console_session.ses_rpc_lock);
 
 	if (!crpc) {
-		LIBCFS_ALLOC(crpc, sizeof(*crpc));
+		crpc = kzalloc(sizeof(*crpc), GFP_NOFS);
 		if (!crpc)
 			return -ENOMEM;
 	}
@@ -140,7 +140,7 @@ lstcon_rpc_prep(struct lstcon_node *nd, int service, unsigned int feats,
 		return 0;
 	}
 
-	LIBCFS_FREE(crpc, sizeof(*crpc));
+	kfree(crpc);
 
 	return rc;
 }
@@ -250,7 +250,7 @@ lstcon_rpc_trans_prep(struct list_head *translist, int transop,
 	}
 
 	/* create a trans group */
-	LIBCFS_ALLOC(trans, sizeof(*trans));
+	trans = kzalloc(sizeof(*trans), GFP_NOFS);
 	if (!trans)
 		return -ENOMEM;
 
@@ -585,7 +585,7 @@ lstcon_rpc_trans_destroy(struct lstcon_rpc_trans *trans)
 	CDEBUG(D_NET, "Transaction %s destroyed with %d pending RPCs\n",
 	       lstcon_rpc_trans_name(trans->tas_opc), count);
 
-	LIBCFS_FREE(trans, sizeof(*trans));
+	kfree(trans);
 }
 
 int
@@ -1369,7 +1369,7 @@ lstcon_rpc_cleanup_wait(void)
 
 	list_for_each_entry_safe(crpc, temp, &zlist, crp_link) {
 		list_del(&crpc->crp_link);
-		LIBCFS_FREE(crpc, sizeof(struct lstcon_rpc));
+		kfree(crpc);
 	}
 }
 
diff --git a/drivers/staging/lustre/lnet/selftest/console.c b/drivers/staging/lustre/lnet/selftest/console.c
index a2662638d599..edf5e59a4351 100644
--- a/drivers/staging/lustre/lnet/selftest/console.c
+++ b/drivers/staging/lustre/lnet/selftest/console.c
@@ -166,7 +166,7 @@ lstcon_ndlink_find(struct list_head *hash, struct lnet_process_id id,
 	if (rc)
 		return rc;
 
-	LIBCFS_ALLOC(ndl, sizeof(struct lstcon_ndlink));
+	ndl = kzalloc(sizeof(struct lstcon_ndlink), GFP_NOFS);
 	if (!ndl) {
 		lstcon_node_put(nd);
 		return -ENOMEM;
@@ -190,7 +190,7 @@ lstcon_ndlink_release(struct lstcon_ndlink *ndl)
 	list_del(&ndl->ndl_hlink); /* delete from hash */
 	lstcon_node_put(ndl->ndl_node);
 
-	LIBCFS_FREE(ndl, sizeof(*ndl));
+	kfree(ndl);
 }
 
 static int
@@ -807,7 +807,7 @@ lstcon_group_info(char *name, struct lstcon_ndlist_ent __user *gents_p,
 	}
 
 	/* non-verbose query */
-	LIBCFS_ALLOC(gentp, sizeof(struct lstcon_ndlist_ent));
+	gentp = kzalloc(sizeof(struct lstcon_ndlist_ent), GFP_NOFS);
 	if (!gentp) {
 		CERROR("Can't allocate ndlist_ent\n");
 		lstcon_group_decref(grp);
@@ -821,7 +821,7 @@ lstcon_group_info(char *name, struct lstcon_ndlist_ent __user *gents_p,
 	rc = copy_to_user(gents_p, gentp,
 			  sizeof(struct lstcon_ndlist_ent)) ? -EFAULT : 0;
 
-	LIBCFS_FREE(gentp, sizeof(struct lstcon_ndlist_ent));
+	kfree(gentp);
 
 	lstcon_group_decref(grp);
 
@@ -856,7 +856,7 @@ lstcon_batch_add(char *name)
 		return rc;
 	}
 
-	LIBCFS_ALLOC(bat, sizeof(struct lstcon_batch));
+	bat = kzalloc(sizeof(struct lstcon_batch), GFP_NOFS);
 	if (!bat) {
 		CERROR("Can't allocate descriptor for batch %s\n", name);
 		return -ENOMEM;
@@ -866,7 +866,7 @@ lstcon_batch_add(char *name)
 		     sizeof(struct list_head) * LST_NODE_HASHSIZE);
 	if (!bat->bat_cli_hash) {
 		CERROR("Can't allocate hash for batch %s\n", name);
-		LIBCFS_FREE(bat, sizeof(struct lstcon_batch));
+		kfree(bat);
 
 		return -ENOMEM;
 	}
@@ -876,7 +876,7 @@ lstcon_batch_add(char *name)
 	if (!bat->bat_srv_hash) {
 		CERROR("Can't allocate hash for batch %s\n", name);
 		LIBCFS_FREE(bat->bat_cli_hash, LST_NODE_HASHSIZE);
-		LIBCFS_FREE(bat, sizeof(struct lstcon_batch));
+		kfree(bat);
 
 		return -ENOMEM;
 	}
@@ -884,7 +884,7 @@ lstcon_batch_add(char *name)
 	if (strlen(name) > sizeof(bat->bat_name) - 1) {
 		LIBCFS_FREE(bat->bat_srv_hash, LST_NODE_HASHSIZE);
 		LIBCFS_FREE(bat->bat_cli_hash, LST_NODE_HASHSIZE);
-		LIBCFS_FREE(bat, sizeof(struct lstcon_batch));
+		kfree(bat);
 		return -E2BIG;
 	}
 	strncpy(bat->bat_name, name, sizeof(bat->bat_name));
@@ -971,7 +971,7 @@ lstcon_batch_info(char *name, struct lstcon_test_batch_ent __user *ent_up,
 	}
 
 	/* non-verbose query */
-	LIBCFS_ALLOC(entp, sizeof(struct lstcon_test_batch_ent));
+	entp = kzalloc(sizeof(struct lstcon_test_batch_ent), GFP_NOFS);
 	if (!entp)
 		return -ENOMEM;
 
@@ -993,7 +993,7 @@ lstcon_batch_info(char *name, struct lstcon_test_batch_ent __user *ent_up,
 	rc = copy_to_user(ent_up, entp,
 			  sizeof(struct lstcon_test_batch_ent)) ? -EFAULT : 0;
 
-	LIBCFS_FREE(entp, sizeof(struct lstcon_test_batch_ent));
+	kfree(entp);
 
 	return rc;
 }
@@ -1138,7 +1138,7 @@ lstcon_batch_destroy(struct lstcon_batch *bat)
 		    sizeof(struct list_head) * LST_NODE_HASHSIZE);
 	LIBCFS_FREE(bat->bat_srv_hash,
 		    sizeof(struct list_head) * LST_NODE_HASHSIZE);
-	LIBCFS_FREE(bat, sizeof(struct lstcon_batch));
+	kfree(bat);
 }
 
 static int
@@ -1790,7 +1790,7 @@ lstcon_session_info(struct lst_sid __user *sid_up, int __user *key_up,
 	if (console_session.ses_state != LST_SESSION_ACTIVE)
 		return -ESRCH;
 
-	LIBCFS_ALLOC(entp, sizeof(*entp));
+	entp = kzalloc(sizeof(*entp), GFP_NOFS);
 	if (!entp)
 		return -ENOMEM;
 
@@ -1807,7 +1807,7 @@ lstcon_session_info(struct lst_sid __user *sid_up, int __user *key_up,
 	    copy_to_user(name_up, console_session.ses_name, len))
 		rc = -EFAULT;
 
-	LIBCFS_FREE(entp, sizeof(*entp));
+	kfree(entp);
 
 	return rc;
 }
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index 6c2091ef8dba..b734e629bf29 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -143,7 +143,7 @@ sfw_register_test(struct srpc_service *service,
 		return -EEXIST;
 	}
 
-	LIBCFS_ALLOC(tsc, sizeof(struct sfw_test_case));
+	tsc = kzalloc(sizeof(struct sfw_test_case), GFP_NOFS);
 	if (!tsc)
 		return -ENOMEM;
 
@@ -344,7 +344,7 @@ sfw_bid2batch(struct lst_bid bid)
 	if (bat)
 		return bat;
 
-	LIBCFS_ALLOC(bat, sizeof(struct sfw_batch));
+	bat = kzalloc(sizeof(struct sfw_batch), GFP_NOFS);
 	if (!bat)
 		return NULL;
 
@@ -447,7 +447,7 @@ sfw_make_session(struct srpc_mksn_reqst *request, struct srpc_mksn_reply *reply)
 	}
 
 	/* brand new or create by force */
-	LIBCFS_ALLOC(sn, sizeof(struct sfw_session));
+	sn = kzalloc(sizeof(struct sfw_session), GFP_NOFS);
 	if (!sn) {
 		CERROR("dropping RPC mksn under memory pressure\n");
 		return -ENOMEM;
@@ -632,7 +632,7 @@ sfw_destroy_test_instance(struct sfw_test_instance *tsi)
 		tsu = list_entry(tsi->tsi_units.next,
 				 struct sfw_test_unit, tsu_list);
 		list_del(&tsu->tsu_list);
-		LIBCFS_FREE(tsu, sizeof(*tsu));
+		kfree(tsu);
 	}
 
 	while (!list_empty(&tsi->tsi_free_rpcs)) {
@@ -644,7 +644,7 @@ sfw_destroy_test_instance(struct sfw_test_instance *tsi)
 
 clean:
 	sfw_unload_test(tsi);
-	LIBCFS_FREE(tsi, sizeof(*tsi));
+	kfree(tsi);
 }
 
 static void
@@ -662,7 +662,7 @@ sfw_destroy_batch(struct sfw_batch *tsb)
 		sfw_destroy_test_instance(tsi);
 	}
 
-	LIBCFS_FREE(tsb, sizeof(struct sfw_batch));
+	kfree(tsb);
 }
 
 void
@@ -680,7 +680,7 @@ sfw_destroy_session(struct sfw_session *sn)
 		sfw_destroy_batch(batch);
 	}
 
-	LIBCFS_FREE(sn, sizeof(*sn));
+	kfree(sn);
 	atomic_dec(&sfw_data.fw_nzombies);
 }
 
@@ -740,7 +740,7 @@ sfw_add_test_instance(struct sfw_batch *tsb, struct srpc_server_rpc *rpc)
 	int i;
 	int rc;
 
-	LIBCFS_ALLOC(tsi, sizeof(*tsi));
+	tsi = kzalloc(sizeof(*tsi), GFP_NOFS);
 	if (!tsi) {
 		CERROR("Can't allocate test instance for batch: %llu\n",
 		       tsb->bat_id.bat_id);
@@ -763,7 +763,7 @@ sfw_add_test_instance(struct sfw_batch *tsb, struct srpc_server_rpc *rpc)
 
 	rc = sfw_load_test(tsi);
 	if (rc) {
-		LIBCFS_FREE(tsi, sizeof(*tsi));
+		kfree(tsi);
 		return rc;
 	}
 
@@ -795,7 +795,7 @@ sfw_add_test_instance(struct sfw_batch *tsb, struct srpc_server_rpc *rpc)
 			sfw_unpack_id(id);
 
 		for (j = 0; j < tsi->tsi_concur; j++) {
-			LIBCFS_ALLOC(tsu, sizeof(struct sfw_test_unit));
+			tsu = kzalloc(sizeof(struct sfw_test_unit), GFP_NOFS);
 			if (!tsu) {
 				rc = -ENOMEM;
 				CERROR("Can't allocate tsu for %d\n",
@@ -1785,6 +1785,6 @@ sfw_shutdown(void)
 		srpc_wait_service_shutdown(tsc->tsc_srv_service);
 
 		list_del(&tsc->tsc_list);
-		LIBCFS_FREE(tsc, sizeof(*tsc));
+		kfree(tsc);
 	}
 }
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index fe0d735487b9..eb76447b2b8d 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -214,7 +214,7 @@ srpc_service_fini(struct srpc_service *svc)
 				buf = list_entry(q->next, struct srpc_buffer,
 						 buf_list);
 				list_del(&buf->buf_list);
-				LIBCFS_FREE(buf, sizeof(*buf));
+				kfree(buf);
 			}
 		}
 
@@ -225,7 +225,7 @@ srpc_service_fini(struct srpc_service *svc)
 					 struct srpc_server_rpc,
 					 srpc_list);
 			list_del(&rpc->srpc_list);
-			LIBCFS_FREE(rpc, sizeof(*rpc));
+			kfree(rpc);
 		}
 	}
 
@@ -508,7 +508,7 @@ __must_hold(&scd->scd_lock)
 	list_del(&buf->buf_list);
 	spin_unlock(&scd->scd_lock);
 
-	LIBCFS_FREE(buf, sizeof(*buf));
+	kfree(buf);
 
 	spin_lock(&scd->scd_lock);
 	return rc;
@@ -535,7 +535,7 @@ srpc_add_buffer(struct swi_workitem *wi)
 
 		spin_unlock(&scd->scd_lock);
 
-		LIBCFS_ALLOC(buf, sizeof(*buf));
+		buf = kzalloc(sizeof(*buf), GFP_NOFS);
 		if (!buf) {
 			CERROR("Failed to add new buf to service: %s\n",
 			       scd->scd_svc->sv_name);
@@ -547,7 +547,7 @@ srpc_add_buffer(struct swi_workitem *wi)
 		spin_lock(&scd->scd_lock);
 		if (scd->scd_svc->sv_shuttingdown) {
 			spin_unlock(&scd->scd_lock);
-			LIBCFS_FREE(buf, sizeof(*buf));
+			kfree(buf);
 
 			spin_lock(&scd->scd_lock);
 			rc = -ESHUTDOWN;
@@ -725,7 +725,7 @@ __must_hold(&scd->scd_lock)
 	}
 
 	spin_unlock(&scd->scd_lock);
-	LIBCFS_FREE(buf, sizeof(*buf));
+	kfree(buf);
 	spin_lock(&scd->scd_lock);
 }
 
