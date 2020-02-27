From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:18:03 -0500
Subject: [lustre-devel] [PATCH 615/622] lnet: handling device failure by IB
 event handler
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-616-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Tatsushi Takamura <takamr.tatsushi@jp.fujitsu.com>

The following IB events cannot be handled by QP event handler
- IB_EVENT_DEVICE_FATAL
- IB_EVENT_PORT_ERR
- IB_EVENT_PORT_ACTIVE

IB event handler handles device errors such as hardware errors
and link down.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12287
Lustre-commit: c6e4c21c4f8b ("LU-12287 lnet: handling device failure by IB event handler")
Signed-off-by: Tatsushi Takamura <takamr.tatsushi@jp.fujitsu.com>
Signed-off-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/35037
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c | 100 +++++++++++++++++++++++++++++++++++++++
 net/lnet/klnds/o2iblnd/o2iblnd.h |   8 ++++
 2 files changed, 108 insertions(+)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index f6db2c7..7bf2883 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2306,9 +2306,93 @@ static int kiblnd_net_init_pools(struct kib_net *net, struct lnet_ni *ni,
 	return rc;
 }
 
+static int kiblnd_port_get_attr(struct kib_hca_dev *hdev)
+{
+	struct ib_port_attr *port_attr;
+	int rc;
+	unsigned long flags;
+	rwlock_t *g_lock = &kiblnd_data.kib_global_lock;
+
+	port_attr = kzalloc(sizeof(*port_attr), GFP_NOFS);
+	if (!port_attr) {
+		CDEBUG(D_NETERROR, "Out of memory\n");
+		return -ENOMEM;
+	}
+
+	rc = ib_query_port(hdev->ibh_ibdev, hdev->ibh_port, port_attr);
+
+	write_lock_irqsave(g_lock, flags);
+
+	if (rc == 0)
+		hdev->ibh_state = port_attr->state == IB_PORT_ACTIVE
+				 ? IBLND_DEV_PORT_ACTIVE
+				 : IBLND_DEV_PORT_DOWN;
+
+	write_unlock_irqrestore(g_lock, flags);
+	kfree(port_attr);
+
+	if (rc != 0) {
+		CDEBUG(D_NETERROR, "Failed to query IB port: %d\n", rc);
+		return rc;
+	}
+	return 0;
+}
+
+static inline void
+kiblnd_set_ni_fatal_on(struct kib_hca_dev *hdev, int val)
+{
+	struct kib_net  *net;
+
+	/* for health check */
+	list_for_each_entry(net, &hdev->ibh_dev->ibd_nets, ibn_list) {
+		if (val)
+			CDEBUG(D_NETERROR, "Fatal device error for NI %s\n",
+			       libcfs_nid2str(net->ibn_ni->ni_nid));
+		atomic_set(&net->ibn_ni->ni_fatal_error_on, val);
+	}
+}
+
+void
+kiblnd_event_handler(struct ib_event_handler *handler, struct ib_event *event)
+{
+	rwlock_t *g_lock = &kiblnd_data.kib_global_lock;
+	struct kib_hca_dev  *hdev;
+	unsigned long flags;
+
+	hdev = container_of(handler, struct kib_hca_dev, ibh_event_handler);
+
+	write_lock_irqsave(g_lock, flags);
+
+	switch (event->event) {
+	case IB_EVENT_DEVICE_FATAL:
+		CDEBUG(D_NET, "IB device fatal\n");
+		hdev->ibh_state = IBLND_DEV_FATAL;
+		kiblnd_set_ni_fatal_on(hdev, 1);
+		break;
+	case IB_EVENT_PORT_ACTIVE:
+		CDEBUG(D_NET, "IB port active\n");
+		if (event->element.port_num == hdev->ibh_port) {
+			hdev->ibh_state = IBLND_DEV_PORT_ACTIVE;
+			kiblnd_set_ni_fatal_on(hdev, 0);
+		}
+		break;
+	case IB_EVENT_PORT_ERR:
+		CDEBUG(D_NET, "IB port err\n");
+		if (event->element.port_num == hdev->ibh_port) {
+			hdev->ibh_state = IBLND_DEV_PORT_DOWN;
+			kiblnd_set_ni_fatal_on(hdev, 1);
+		}
+		break;
+	default:
+		break;
+	}
+	write_unlock_irqrestore(g_lock, flags);
+}
+
 static int kiblnd_hdev_get_attr(struct kib_hca_dev *hdev)
 {
 	struct ib_device_attr *dev_attr = &hdev->ibh_ibdev->attrs;
+	int rc2 = 0;
 
 	/*
 	 * It's safe to assume a HCA can handle a page size
@@ -2338,12 +2422,19 @@ static int kiblnd_hdev_get_attr(struct kib_hca_dev *hdev)
 	hdev->ibh_mr_size = dev_attr->max_mr_size;
 	hdev->ibh_max_qp_wr = dev_attr->max_qp_wr;
 
+	rc2 = kiblnd_port_get_attr(hdev);
+	if (rc2 != 0)
+		return rc2;
+
 	CERROR("Invalid mr size: %#llx\n", hdev->ibh_mr_size);
 	return -EINVAL;
 }
 
 void kiblnd_hdev_destroy(struct kib_hca_dev *hdev)
 {
+	if (hdev->ibh_event_handler.device)
+		ib_unregister_event_handler(&hdev->ibh_event_handler);
+
 	if (hdev->ibh_pd)
 		ib_dealloc_pd(hdev->ibh_pd);
 
@@ -2491,6 +2582,7 @@ int kiblnd_dev_failover(struct kib_dev *dev, struct net *ns)
 	hdev->ibh_dev = dev;
 	hdev->ibh_cmid = cmid;
 	hdev->ibh_ibdev = cmid->device;
+	hdev->ibh_port  = cmid->port_num;
 
 	pd = ib_alloc_pd(cmid->device, 0);
 	if (IS_ERR(pd)) {
@@ -2513,6 +2605,10 @@ int kiblnd_dev_failover(struct kib_dev *dev, struct net *ns)
 		goto out;
 	}
 
+	INIT_IB_EVENT_HANDLER(&hdev->ibh_event_handler,
+			      hdev->ibh_ibdev, kiblnd_event_handler);
+	ib_register_event_handler(&hdev->ibh_event_handler);
+
 	write_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
 
 	swap(dev->ibd_hdev, hdev); /* take over the refcount */
@@ -2907,6 +3003,7 @@ static int kiblnd_startup(struct lnet_ni *ni)
 		goto net_failed;
 	}
 
+	net->ibn_ni = ni;
 	net->ibn_incarnation = ktime_get_real_ns() / NSEC_PER_USEC;
 
 	rc = kiblnd_tunables_setup(ni);
@@ -3000,6 +3097,9 @@ static int kiblnd_startup(struct lnet_ni *ni)
 	write_lock_irqsave(&kiblnd_data.kib_global_lock, flags);
 	ibdev->ibd_nnets++;
 	list_add_tail(&net->ibn_list, &ibdev->ibd_nets);
+	/* for health check */
+	if (ibdev->ibd_hdev->ibh_state == IBLND_DEV_PORT_DOWN)
+		kiblnd_set_ni_fatal_on(ibdev->ibd_hdev, 1);
 	write_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
 
 	net->ibn_init = IBLND_INIT_ALL;
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.h b/net/lnet/klnds/o2iblnd/o2iblnd.h
index 2169fdd..8aa79d5 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.h
@@ -180,6 +180,13 @@ struct kib_hca_dev {
 	u64			ibh_mr_size;	/* size of MR */
 	int			ibh_max_qp_wr;	/* maximum work requests size */
 	struct ib_pd		*ibh_pd;	/* PD */
+	u8			ibh_port;	/* port number */
+	struct ib_event_handler
+				ibh_event_handler; /* IB event handler */
+	int			ibh_state;	/* device status */
+#define IBLND_DEV_PORT_DOWN	0
+#define IBLND_DEV_PORT_ACTIVE	1
+#define IBLND_DEV_FATAL		2
 	struct kib_dev		*ibh_dev;	/* owner */
 	atomic_t		ibh_ref;	/* refcount */
 };
@@ -309,6 +316,7 @@ struct kib_net {
 	struct kib_fmr_poolset	**ibn_fmr_ps;	/* fmr pool-set */
 
 	struct kib_dev		*ibn_dev;	/* underlying IB device */
+	struct lnet_ni		*ibn_ni;	/* LNet interface */
 };
 
 #define KIB_THREAD_SHIFT		16
-- 
1.8.3.1
