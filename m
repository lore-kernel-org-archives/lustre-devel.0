From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:23 -0400
Subject: [lustre-devel] [PATCH 004/151] lnet: o2iblnd: add secondary IP
 address handling
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Using dev_get_by_name() in kiblnd_create_dev() means we can only
discover primary IP addresses. This breaks using network
aliasing which some people use. Move away from dev_get_by_name()
to using for_ifa() so we can detect any secondary IP addresses.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11893
Linux-commit: c4b39bf56bbc ("LU-11893 o2iblnd: add secondary IP address handling")
Reviewed-on: https://review.whamcloud.com/34476
WC-bug-id: https://jira.whamcloud.com/browse/LU-12381
Linux-commit: 1dea5aac9d9b ("LU-11893 o2iblnd: ignore down interfaces")
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/35098
Reviewed-by: Petros Koutoupis <pkoutoupis@cray.com>
Reviewed-by: Neil Brown <neilb@suse.com>
Reviewed-by: Chris Horn <hornc@cray.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c | 78 ++++++++++++++++++++++------------------
 1 file changed, 44 insertions(+), 34 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index 97ed1ec..e952c0c 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2557,53 +2557,58 @@ static struct kib_dev *kiblnd_create_dev(char *ifname)
 {
 	const struct in_ifaddr *ifa;
 	struct net_device *netdev;
-	struct in_device *in_dev;
-	struct kib_dev *dev;
+	struct kib_dev *dev = NULL;
 	int flags;
 	int rc;
 
 	rtnl_lock();
-	netdev = dev_get_by_name(&init_net, ifname);
-	if (!netdev) {
-		CERROR("Can't find IPoIB interface %s\n",
-		       ifname);
-		goto unlock;
-	}
+	for_each_netdev(&init_net, netdev) {
+		struct in_device *in_dev;
 
-	flags = dev_get_flags(netdev);
-	if (!(flags & IFF_UP)) {
-		CERROR("Can't query IPoIB interface %s: it's down\n", ifname);
-		goto unlock;
-	}
+		if (strcmp(netdev->name, "lo") == 0) /* skip the loopback IF */
+			continue;
 
-	dev = kzalloc(sizeof(*dev), GFP_NOFS);
-	if (!dev)
-		goto unlock;
+		flags = dev_get_flags(netdev);
+		if (!(flags & IFF_UP)) {
+			CWARN("Can't query IPoIB interface %s: it's down\n",
+			      netdev->name);
+			continue;
+		}
 
-	dev->ibd_can_failover = !!(flags & IFF_MASTER);
+		in_dev = __in_dev_get_rtnl(netdev);
+		if (!in_dev) {
+			CWARN("Interface %s has no IPv4 status.\n",
+			      netdev->name);
+			continue;
+		}
 
-	INIT_LIST_HEAD(&dev->ibd_nets);
-	INIT_LIST_HEAD(&dev->ibd_list); /* not yet in kib_devs */
-	INIT_LIST_HEAD(&dev->ibd_fail_list);
+		in_dev_for_each_ifa_rcu(ifa, in_dev) {
+			if (strcmp(ifname, ifa->ifa_label) == 0) {
+				dev = kzalloc(sizeof(*dev), GFP_NOFS);
+				if (!dev)
+					goto unlock;
 
-	in_dev = __in_dev_get_rtnl(netdev);
-	if (!in_dev) {
-		kfree(dev);
-		goto unlock;
-	}
+				dev->ibd_can_failover = !!(flags & IFF_MASTER);
+				dev->ibd_ifip = ntohl(ifa->ifa_local);
 
-	in_dev_for_each_ifa_rcu(ifa, in_dev)
-		if (!(ifa->ifa_flags & IFA_F_SECONDARY) &&
-		    strcmp(ifa->ifa_label, ifname) == 0) {
-			dev->ibd_ifip = ntohl(ifa->ifa_local);
-			break;
+				INIT_LIST_HEAD(&dev->ibd_nets);
+				/* not yet in kib_devs */
+				INIT_LIST_HEAD(&dev->ibd_list);
+				INIT_LIST_HEAD(&dev->ibd_fail_list);
+				break;
+			}
 		}
+	}
 	rtnl_unlock();
 
+	if (!dev) {
+		CERROR("Can't find any usable interfaces\n");
+		return NULL;
+	}
+
 	if (dev->ibd_ifip == 0) {
 		CERROR("Can't initialize device: no IP address\n");
-		kfree(dev);
-		return NULL;
+		goto free_dev;
 	}
 	strcpy(&dev->ibd_ifname[0], ifname);
 
@@ -2611,14 +2616,15 @@ static struct kib_dev *kiblnd_create_dev(char *ifname)
 	rc = kiblnd_dev_failover(dev);
 	if (rc) {
 		CERROR("Can't initialize device: %d\n", rc);
-		kfree(dev);
-		return NULL;
+		goto free_dev;
 	}
 
 	list_add_tail(&dev->ibd_list, &kiblnd_data.kib_devs);
 	return dev;
 unlock:
 	rtnl_unlock();
+free_dev:
+	kfree(dev);
 	return NULL;
 }
 
@@ -2968,6 +2974,10 @@ static int kiblnd_startup(struct lnet_ni *ni)
 	if (rc)
 		goto net_failed;
 
+	/* ni_interfaces is only to support legacy pre Multi-Rail
+	 * tcp bonding for ksocklnd. Multi-Rail wants each secondary
+	 * IP to be treated as an unique 'struct ni' interfaces instead.
+	 */
 	if (ni->ni_interfaces[0]) {
 		/* Use the IPoIB interface specified in 'networks=' */
 
-- 
1.8.3.1
