From: James Simmons <jsimmons@infradead.org>
Date: Mon, 30 Sep 2019 14:54:22 -0400
Subject: [lustre-devel] [PATCH 003/151] lnet: ksocklnd: add secondary IP
 address handling
In-Reply-To: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
References: <1569869810-23848-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1569869810-23848-4-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

With the current ksocknal_enumerate_interfaces() only
primary IP addresses are returned. This disables using network
aliasing which some people use. Remove the secondary IP address
filtering. Update the string handling since ifa_device names can
be different than the net_device name. Discard the 'j' counter
and instead keep ksnn_ninterfaces up to date. This means that
we return 0 on success, rather than a count of added interfaces.
Update the too many interfaces test with a better test using
ARRAY_SIZE.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11893
Lustre-commit: 9a2013af0668 ("LU-11893 ksocklnd: add secondary IP address handling
Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Reviewed-on: https://review.whamcloud.com/34392
Reviewed-by: Petros Koutoupis <pkoutoupis@cray.com>
Reviewed-by: Neil Brown <neilb@suse.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.c | 75 +++++++++++++++++++++++++++-------------
 1 file changed, 51 insertions(+), 24 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index ccc42f6..1c957dc 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -2604,54 +2604,58 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 static int
 ksocknal_enumerate_interfaces(struct ksock_net *net, char *iname)
 {
-	int j = 0;
 	struct net_device *dev;
 
 	rtnl_lock();
 	for_each_netdev(&init_net, dev) {
-		const char *name = dev->name;
+		/* The iname specified by a user land configuration can
+		 * map to an ifa_label so always treat iname as an ifa_label.
+		 * If iname is NULL then fall back to the net device name.
+		 */
+		const char *name = iname ? iname : dev->name;
 		const struct in_ifaddr *ifa;
 		struct in_device *in_dev;
-		struct ksock_interface *ksi =
-			&net->ksnn_interfaces[net->ksnn_ninterfaces + j];
 
-		if (strcmp(name, "lo") == 0) /* skip the loopback IF */
-			continue;
-		if (iname && strcmp(name, iname) != 0)
+		if (strcmp(dev->name, "lo") == 0) /* skip the loopback IF */
 			continue;
 
 		if (!(dev_get_flags(dev) & IFF_UP)) {
-			CWARN("Ignoring interface %s (down)\n", name);
+			CWARN("Ignoring interface %s (down)\n", dev->name);
 			continue;
 		}
 
-		if (j == LNET_INTERFACES_NUM) {
-			CWARN("Ignoring interface %s (too many interfaces)\n",
-			      name);
-			continue;
-		}
 		in_dev = __in_dev_get_rtnl(dev);
 		if (!in_dev) {
-			CWARN("Interface %s has no IPv4 status.\n", name);
+			CWARN("Interface %s has no IPv4 status.\n", dev->name);
 			continue;
 		}
-		in_dev_for_each_ifa_rcu(ifa, in_dev)
-			if (!(ifa->ifa_flags & IFA_F_SECONDARY) &&
-			    strcmp(ifa->ifa_label, name) == 0) {
+
+		in_dev_for_each_ifa_rcu(ifa, in_dev) {
+			if (strcmp(name, ifa->ifa_label) == 0) {
+				int idx = net->ksnn_ninterfaces;
+				struct ksock_interface *ksi;
+
+				if (idx >= ARRAY_SIZE(net->ksnn_interfaces)) {
+					rtnl_unlock();
+					return -E2BIG;
+				}
+
+				ksi = &net->ksnn_interfaces[idx];
 				ksi->ksni_ipaddr = ntohl(ifa->ifa_local);
 				ksi->ksni_netmask = ifa->ifa_mask;
 				strlcpy(ksi->ksni_name,
 					name, sizeof(ksi->ksni_name));
-				j++;
+				net->ksnn_ninterfaces++;
 				break;
 			}
+		}
 	}
 	rtnl_unlock();
 
-	if (!iname && !j)
+	if (net->ksnn_ninterfaces == 0)
 		CERROR("Can't find any usable interfaces\n");
 
-	return j;
+	return net->ksnn_ninterfaces > 0 ? 0 : -ENOENT;
 }
 
 static int
@@ -2810,17 +2814,40 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 		rc = ksocknal_enumerate_interfaces(net, NULL);
 		if (rc <= 0)
 			goto fail_1;
-
-		net->ksnn_ninterfaces = rc;
 	} else {
+		/* Before Multi-Rail ksocklnd would manage
+		 * multiple interfaces with its own tcp bonding.
+		 * If we encounter an old configuration using
+		 * this tcp bonding approach then we need to
+		 * handle more than one ni_interfaces.
+		 *
+		 * In Multi-Rail configuration only ONE ni_interface
+		 * should exist. Each IP alias should be mapped to
+		 * each 'struct net_ni'.
+		 */
 		for (i = 0; i < LNET_INTERFACES_NUM; i++) {
+			int j;
+
 			if (!ni->ni_interfaces[i])
 				break;
-			rc = ksocknal_enumerate_interfaces(net, ni->ni_interfaces[i]);
 
+			for (j = 0; j < net->ksnn_ninterfaces;  j++) {
+				struct ksock_interface *ksi;
+
+				ksi = &net->ksnn_interfaces[j];
+
+				if (strcmp(ni->ni_interfaces[i],
+					   ksi->ksni_name) == 0) {
+					CERROR("found duplicate %s\n",
+					       ksi->ksni_name);
+					rc = -EEXIST;
+					goto fail_1;
+				}
+			}
+
+			rc = ksocknal_enumerate_interfaces(net, ni->ni_interfaces[i]);
 			if (rc <= 0)
 				goto fail_1;
-			net->ksnn_ninterfaces += rc;
 		}
 	}
 
-- 
1.8.3.1
