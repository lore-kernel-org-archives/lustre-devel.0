From: NeilBrown <neilb@suse.com>
Date: Wed, 25 Jul 2018 09:07:16 +1000
Subject: [lustre-devel] [PATCH 2/5] lustre: socklnd: use
 ksocknal_enumerate_interfaces for individual interfaces.
In-Reply-To: <153247352950.25051.3479450943810758169.stgit@noble>
References: <153247352950.25051.3479450943810758169.stgit@noble>
Message-ID: <153247363637.25051.1816811991601800158.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

When individual interfaces are listed, such a via a module parameter,
it is easy to use ksocknal_enumerate_interfaces() to find them, and
save duplicating code.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |   37 ++++++--------------
 1 file changed, 12 insertions(+), 25 deletions(-)

diff --git a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
index 895f744bb959..d37f7134b31d 100644
--- a/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
+++ b/drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c
@@ -2613,7 +2613,7 @@ ksocknal_shutdown(struct lnet_ni *ni)
 }
 
 static int
-ksocknal_enumerate_interfaces(struct ksock_net *net)
+ksocknal_enumerate_interfaces(struct ksock_net *net, char *iname)
 {
 	int j = 0;
 	struct net_device *dev;
@@ -2622,10 +2622,13 @@ ksocknal_enumerate_interfaces(struct ksock_net *net)
 	for_each_netdev(&init_net, dev) {
 		const char *name = dev->name;
 		struct in_device *in_dev;
-		struct ksock_interface *ksi = &net->ksnn_interfaces[j];
+		struct ksock_interface *ksi =
+			&net->ksnn_interfaces[net->ksnn_ninterfaces + j];
 
 		if (strcmp(name, "lo") == 0) /* skip the loopback IF */
 			continue;
+		if (iname && strcmp(name, iname) != 0)
+			continue;
 
 		if (!(dev_get_flags(dev) & IFF_UP)) {
 			CWARN("Ignoring interface %s (down)\n", name);
@@ -2655,7 +2658,7 @@ ksocknal_enumerate_interfaces(struct ksock_net *net)
 	}
 	rtnl_unlock();
 
-	if (!j)
+	if (!iname && !j)
 		CERROR("Can't find any usable interfaces\n");
 
 	return j;
@@ -2802,40 +2805,24 @@ ksocknal_startup(struct lnet_ni *ni)
 	ni->ni_peertxcredits  = *ksocknal_tunables.ksnd_peertxcredits;
 	ni->ni_peerrtrcredits = *ksocknal_tunables.ksnd_peerrtrcredits;
 
+	net->ksnn_ninterfaces = 0;
 	if (!ni->ni_interfaces[0]) {
-		rc = ksocknal_enumerate_interfaces(net);
+		rc = ksocknal_enumerate_interfaces(net, NULL);
 		if (rc <= 0)
 			goto fail_1;
 
+		/* FIXME why is this 1, not rc ?? */
 		net->ksnn_ninterfaces = 1;
 	} else {
 		for (i = 0; i < LNET_MAX_INTERFACES; i++) {
-			int up;
-
 			if (!ni->ni_interfaces[i])
 				break;
+			rc = ksocknal_enumerate_interfaces(net, ni->ni_interfaces[i]);
 
-			rc = lnet_ipif_query(ni->ni_interfaces[i], &up,
-					     &net->ksnn_interfaces[i].ksni_ipaddr,
-					     &net->ksnn_interfaces[i].ksni_netmask);
-
-			if (rc) {
-				CERROR("Can't get interface %s info: %d\n",
-				       ni->ni_interfaces[i], rc);
-				goto fail_1;
-			}
-
-			if (!up) {
-				CERROR("Interface %s is down\n",
-				       ni->ni_interfaces[i]);
+			if (rc <= 0)
 				goto fail_1;
-			}
-
-			strlcpy(net->ksnn_interfaces[i].ksni_name,
-				ni->ni_interfaces[i],
-				sizeof(net->ksnn_interfaces[i].ksni_name));
+			net->ksnn_ninterfaces += rc;
 		}
-		net->ksnn_ninterfaces = i;
 	}
 
 	/* call it before add it to ksocknal_data.ksnd_nets */
