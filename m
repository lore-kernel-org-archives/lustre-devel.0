From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:16:10 -0500
Subject: [lustre-devel] [PATCH 502/622] lnet: o2ib: Reintroduce
 kiblnd_dev_search
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-503-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Chris Horn <hornc@cray.com>

If we add an interface to multiple nets then we need to re-use the
struct ib_dev object for each of the nets.

Cray-bug-id: LUS-7935
Fixes: 3aa523159321 ("lnet: consoldate secondary IP address handling")
WC-bug-id: https://jira.whamcloud.com/browse/LU-12824
Lustre-commit: e25e45c612a0 ("LU-12824 o2ib: Reintroduce kiblnd_dev_search")
Signed-off-by: Chris Horn <hornc@cray.com>
Reviewed-on: https://review.whamcloud.com/36326
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c | 85 +++++++++++++++++++++++++++++-----------
 1 file changed, 63 insertions(+), 22 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index d162b0a7..1cc5358 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2821,7 +2821,8 @@ static int kiblnd_start_schedulers(struct kib_sched_info *sched)
 	return rc;
 }
 
-static int kiblnd_dev_start_threads(struct kib_dev *dev, u32 *cpts, int ncpts)
+static int kiblnd_dev_start_threads(struct kib_dev *dev, bool newdev, u32 *cpts,
+				    int ncpts)
 {
 	int cpt;
 	int rc;
@@ -2833,7 +2834,7 @@ static int kiblnd_dev_start_threads(struct kib_dev *dev, u32 *cpts, int ncpts)
 		cpt = !cpts ? i : cpts[i];
 		sched = kiblnd_data.kib_scheds[cpt];
 
-		if (sched->ibs_nthreads > 0)
+		if (!newdev && sched->ibs_nthreads > 0)
 			continue;
 
 		rc = kiblnd_start_schedulers(kiblnd_data.kib_scheds[cpt]);
@@ -2846,6 +2847,39 @@ static int kiblnd_dev_start_threads(struct kib_dev *dev, u32 *cpts, int ncpts)
 	return 0;
 }
 
+static struct kib_dev *
+kiblnd_dev_search(char *ifname)
+{
+	struct kib_dev *alias = NULL;
+	struct kib_dev *dev;
+	char            *colon;
+	char            *colon2;
+
+	colon = strchr(ifname, ':');
+	list_for_each_entry(dev, &kiblnd_data.kib_devs, ibd_list) {
+		if (strcmp(&dev->ibd_ifname[0], ifname) == 0)
+			return dev;
+
+		if (alias)
+			continue;
+
+		colon2 = strchr(dev->ibd_ifname, ':');
+		if (colon)
+			*colon = 0;
+		if (colon2)
+			*colon2 = 0;
+
+		if (strcmp(&dev->ibd_ifname[0], ifname) == 0)
+			alias = dev;
+
+		if (colon)
+			*colon = ':';
+		if (colon2)
+			*colon2 = ':';
+	}
+	return alias;
+}
+
 static int kiblnd_startup(struct lnet_ni *ni)
 {
 	char *ifname = NULL;
@@ -2855,6 +2889,7 @@ static int kiblnd_startup(struct lnet_ni *ni)
 	unsigned long flags;
 	int rc;
 	int i;
+	bool newdev;
 
 	LASSERT(ni->ni_net->net_lnd == &the_o2iblnd);
 
@@ -2916,36 +2951,42 @@ static int kiblnd_startup(struct lnet_ni *ni)
 		goto failed;
 	}
 
-	ibdev = kzalloc(sizeof(*ibdev), GFP_KERNEL);
-	if (!ibdev) {
-		rc = -ENOMEM;
-		goto failed;
-	}
+	ibdev = kiblnd_dev_search(ifname);
+	newdev = !ibdev;
+	/* hmm...create kib_dev even for alias */
+	if (!ibdev || strcmp(&ibdev->ibd_ifname[0], ifname) != 0) {
+		ibdev = kzalloc(sizeof(*ibdev), GFP_NOFS);
+		if (!ibdev) {
+			rc = -ENOMEM;
+			goto failed;
+		}
 
-	ibdev->ibd_ifip = ifaces[i].li_ipaddr;
-	strlcpy(ibdev->ibd_ifname, ifaces[i].li_name,
-		sizeof(ibdev->ibd_ifname));
-	ibdev->ibd_can_failover = !!(ifaces[i].li_flags & IFF_MASTER);
+		ibdev->ibd_ifip = ifaces[i].li_ipaddr;
+		strlcpy(ibdev->ibd_ifname, ifaces[i].li_name,
+			sizeof(ibdev->ibd_ifname));
+		ibdev->ibd_can_failover = !!(ifaces[i].li_flags & IFF_MASTER);
 
-	INIT_LIST_HEAD(&ibdev->ibd_nets);
-	INIT_LIST_HEAD(&ibdev->ibd_list); /* not yet in kib_devs */
-	INIT_LIST_HEAD(&ibdev->ibd_fail_list);
+		INIT_LIST_HEAD(&ibdev->ibd_nets);
+		INIT_LIST_HEAD(&ibdev->ibd_list); /* not yet in kib_devs */
+		INIT_LIST_HEAD(&ibdev->ibd_fail_list);
 
-	/* initialize the device */
-	rc = kiblnd_dev_failover(ibdev, ni->ni_net_ns);
-	if (rc) {
-		CERROR("ko2iblnd: Can't initialize device: rc = %d\n", rc);
-		goto failed;
-	}
+		/* initialize the device */
+		rc = kiblnd_dev_failover(ibdev, ni->ni_net_ns);
+		if (rc) {
+			CERROR("ko2iblnd: Can't initialize device: rc = %d\n",
+			       rc);
+			goto failed;
+		}
 
-	list_add_tail(&ibdev->ibd_list, &kiblnd_data.kib_devs);
+		list_add_tail(&ibdev->ibd_list, &kiblnd_data.kib_devs);
+	}
 
 	net->ibn_dev = ibdev;
 	ni->ni_nid = LNET_MKNID(LNET_NIDNET(ni->ni_nid), ibdev->ibd_ifip);
 
 	ni->ni_dev_cpt = ifaces[i].li_cpt;
 
-	rc = kiblnd_dev_start_threads(ibdev, ni->ni_cpts, ni->ni_ncpts);
+	rc = kiblnd_dev_start_threads(ibdev, newdev, ni->ni_cpts, ni->ni_ncpts);
 	if (rc)
 		goto failed;
 
-- 
1.8.3.1
