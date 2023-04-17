Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id DA9DDC77B76
	for <lustre-devel@archiver.kernel.org>; Mon, 17 Apr 2023 13:59:32 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Q0T3P3dVbz21Nx;
	Mon, 17 Apr 2023 06:50:57 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Q0Szv4h3Mz1yDy
 for <lustre-devel@lists.lustre.org>; Mon, 17 Apr 2023 06:47:55 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 7AE3B1008483;
 Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 796B3372; Mon, 17 Apr 2023 09:47:24 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 17 Apr 2023 09:47:06 -0400
Message-Id: <1681739243-29375-11-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
References: <1681739243-29375-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 10/27] lnet: use discovered ni status to set
 initial health
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Serguei Smirnov <ssmirnov@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Serguei Smirnov <ssmirnov@whamcloud.com>

If not routing, track local NI status in the ping buffer
such that locally recognized "down" state, for example,
due to a downed network interface/link, is available
to any discovering peer.
If NI 'fatal' status is changed, push update to peers.

On the active side of discovery, check peer NI status so if NI
is down, decrement its health score and queue for recovery.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16563
Lustre-commit: da230373bd14306cb ("LU-16563 lnet: use discovered ni status to set initial health")
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50027
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h    |  3 ++-
 net/lnet/klnds/o2iblnd/o2iblnd.c | 51 ++++++++++++++++++++++++++++++----------
 net/lnet/klnds/socklnd/socklnd.c | 38 +++++++++++++++++++++++-------
 net/lnet/lnet/api-ni.c           | 20 ++++++++++++++++
 net/lnet/lnet/peer.c             | 14 +++++++++++
 5 files changed, 104 insertions(+), 22 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index e26e150..f9f4815 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -127,7 +127,7 @@
 		return LNET_NI_STATUS_UP;
 	else if (atomic_read(&ni->ni_fatal_error_on))
 		return LNET_NI_STATUS_DOWN;
-	else if (ni->ni_status)
+	else if (the_lnet.ln_routing && ni->ni_status)
 		return *ni->ni_status;
 	else
 		return LNET_NI_STATUS_UP;
@@ -1216,4 +1216,5 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		       old ? "up" : "down",
 		       alive ? "up" : "down");
 }
+void lnet_update_ping_buffer(void);
 #endif
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index a7a3c79..fc59f88 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2382,15 +2382,23 @@ static int kiblnd_port_get_attr(struct kib_hca_dev *hdev)
 static inline void
 kiblnd_set_ni_fatal_on(struct kib_hca_dev *hdev, int val)
 {
-	struct kib_net  *net;
+	struct kib_net *net;
+	u32 ni_state_before;
+	bool update_ping_buf = false;
 
 	/* for health check */
 	list_for_each_entry(net, &hdev->ibh_dev->ibd_nets, ibn_list) {
 		if (val)
 			CDEBUG(D_NETERROR, "Fatal device error for NI %s\n",
 			       libcfs_nidstr(&net->ibn_ni->ni_nid));
-		atomic_set(&net->ibn_ni->ni_fatal_error_on, val);
+		ni_state_before = atomic_xchg(&net->ibn_ni->ni_fatal_error_on,
+					      val);
+		if (!update_ping_buf && val != ni_state_before)
+			update_ping_buf = true;
 	}
+
+	if (update_ping_buf)
+		lnet_update_ping_buffer();
 }
 
 void
@@ -2748,6 +2756,8 @@ void kiblnd_destroy_dev(struct kib_dev *dev)
 	bool link_down = !(operstate == IF_OPER_UP);
 	struct in_device *in_dev;
 	bool found_ip = false;
+	u32 ni_state_before;
+	bool update_ping_buf = false;
 	const struct in_ifaddr *ifa;
 
 	event_kibdev = kiblnd_dev_search(dev->name);
@@ -2757,7 +2767,6 @@ void kiblnd_destroy_dev(struct kib_dev *dev)
 
 	list_for_each_entry_safe(net, cnxt, &event_kibdev->ibd_nets, ibn_list) {
 		found_ip = false;
-
 		ni = net->ibn_ni;
 
 		in_dev = __in_dev_get_rtnl(dev);
@@ -2766,8 +2775,9 @@ void kiblnd_destroy_dev(struct kib_dev *dev)
 			       dev->name);
 			CDEBUG(D_NET, "%s: set link fatal state to 1\n",
 			       libcfs_nidstr(&net->ibn_ni->ni_nid));
-			atomic_set(&ni->ni_fatal_error_on, 1);
-			continue;
+			ni_state_before = atomic_xchg(&ni->ni_fatal_error_on,
+						      1);
+			goto ni_done;
 		}
 		in_dev_for_each_ifa_rtnl(ifa, in_dev) {
 			if (htonl(event_kibdev->ibd_ifip) == ifa->ifa_local)
@@ -2779,22 +2789,31 @@ void kiblnd_destroy_dev(struct kib_dev *dev)
 			       dev->name);
 			CDEBUG(D_NET, "%s: set link fatal state to 1\n",
 			       libcfs_nidstr(&net->ibn_ni->ni_nid));
-			atomic_set(&ni->ni_fatal_error_on, 1);
-			continue;
+			ni_state_before = atomic_xchg(&ni->ni_fatal_error_on,
+						      1);
+			goto ni_done;
 		}
 
 		if (link_down) {
 			CDEBUG(D_NET, "%s: set link fatal state to 1\n",
 			       libcfs_nidstr(&net->ibn_ni->ni_nid));
-			atomic_set(&ni->ni_fatal_error_on, link_down);
+			ni_state_before = atomic_xchg(&ni->ni_fatal_error_on,
+						      link_down);
 		} else {
 			CDEBUG(D_NET, "%s: set link fatal state to %u\n",
 			       libcfs_nidstr(&net->ibn_ni->ni_nid),
 			       (kiblnd_get_link_status(dev) == 0));
-			atomic_set(&ni->ni_fatal_error_on,
-				   (kiblnd_get_link_status(dev) == 0));
+			ni_state_before = atomic_xchg(&ni->ni_fatal_error_on,
+						      (kiblnd_get_link_status(dev) == 0));
 		}
+ni_done:
+		if (!update_ping_buf &&
+		    (atomic_read(&ni->ni_fatal_error_on) != ni_state_before))
+			update_ping_buf = true;
 	}
+
+	if (update_ping_buf)
+		lnet_update_ping_buffer();
 out:
 	return 0;
 }
@@ -2806,6 +2825,8 @@ void kiblnd_destroy_dev(struct kib_dev *dev)
 	struct kib_net *net;
 	struct kib_net *cnxt;
 	struct net_device *event_netdev = ifa->ifa_dev->dev;
+	u32 ni_state_before;
+	bool update_ping_buf = false;
 
 	event_kibdev = kiblnd_dev_search(event_netdev->name);
 
@@ -2820,9 +2841,15 @@ void kiblnd_destroy_dev(struct kib_dev *dev)
 		CDEBUG(D_NET, "%s: set link fatal state to %u\n",
 		       libcfs_nidstr(&net->ibn_ni->ni_nid),
 		       (event == NETDEV_DOWN));
-		atomic_set(&net->ibn_ni->ni_fatal_error_on,
-			   (event == NETDEV_DOWN));
+		ni_state_before = atomic_xchg(&net->ibn_ni->ni_fatal_error_on,
+					      (event == NETDEV_DOWN));
+		if (!update_ping_buf &&
+		    ((event == NETDEV_DOWN) != ni_state_before))
+			update_ping_buf = true;
 	}
+
+	if (update_ping_buf)
+		lnet_update_ping_buffer();
 out:
 	return 0;
 }
diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index b8d6e28..435762f 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -2000,6 +2000,8 @@ static int ksocknal_get_link_status(struct net_device *dev)
 	bool found_ip = false;
 	struct ksock_interface *ksi = NULL;
 	struct sockaddr_in *sa;
+	u32 ni_state_before;
+	bool update_ping_buf = false;
 	const struct in_ifaddr *ifa;
 
 	ifindex = dev->ifindex;
@@ -2045,8 +2047,9 @@ static int ksocknal_get_link_status(struct net_device *dev)
 			CDEBUG(D_NET, "Interface %s has no IPv4 status.\n",
 			       dev->name);
 			CDEBUG(D_NET, "set link fatal state to 1\n");
-			atomic_set(&ni->ni_fatal_error_on, 1);
-			continue;
+			ni_state_before = atomic_xchg(&ni->ni_fatal_error_on,
+						      1);
+			goto ni_done;
 		}
 		in_dev_for_each_ifa_rtnl(ifa, in_dev) {
 			if (sa->sin_addr.s_addr == ifa->ifa_local)
@@ -2057,20 +2060,29 @@ static int ksocknal_get_link_status(struct net_device *dev)
 			CDEBUG(D_NET, "Interface %s has no matching ip\n",
 			       dev->name);
 			CDEBUG(D_NET, "set link fatal state to 1\n");
-			atomic_set(&ni->ni_fatal_error_on, 1);
-			continue;
+			ni_state_before = atomic_xchg(&ni->ni_fatal_error_on,
+						      1);
+			goto ni_done;
 		}
 
 		if (link_down) {
 			CDEBUG(D_NET, "set link fatal state to 1\n");
-			atomic_set(&ni->ni_fatal_error_on, link_down);
+			ni_state_before = atomic_xchg(&ni->ni_fatal_error_on,
+						      1);
 		} else {
 			CDEBUG(D_NET, "set link fatal state to %u\n",
 			       (ksocknal_get_link_status(dev) == 0));
-			atomic_set(&ni->ni_fatal_error_on,
-				   (ksocknal_get_link_status(dev) == 0));
+			ni_state_before = atomic_xchg(&ni->ni_fatal_error_on,
+						      (ksocknal_get_link_status(dev) == 0));
 		}
+ni_done:
+		if (!update_ping_buf &&
+		    (atomic_read(&ni->ni_fatal_error_on) != ni_state_before))
+			update_ping_buf = true;
 	}
+
+	if (update_ping_buf)
+		lnet_update_ping_buffer();
 out:
 	return 0;
 }
@@ -2086,6 +2098,8 @@ static int ksocknal_get_link_status(struct net_device *dev)
 	int ifindex;
 	struct ksock_interface *ksi = NULL;
 	struct sockaddr_in *sa;
+	u32 ni_state_before;
+	bool update_ping_buf = false;
 
 	if (!ksocknal_data.ksnd_nnets)
 		goto out;
@@ -2106,10 +2120,16 @@ static int ksocknal_get_link_status(struct net_device *dev)
 			CDEBUG(D_NET, "set link fatal state to %u\n",
 			       (event == NETDEV_DOWN));
 			ni = net->ksnn_ni;
-			atomic_set(&ni->ni_fatal_error_on,
-				   (event == NETDEV_DOWN));
+			ni_state_before = atomic_xchg(&ni->ni_fatal_error_on,
+						      (event == NETDEV_DOWN));
+			if (!update_ping_buf &&
+			    ((event == NETDEV_DOWN) != ni_state_before))
+				update_ping_buf = true;
 		}
 	}
+
+	if (update_ping_buf)
+		lnet_update_ping_buffer();
 out:
 	return 0;
 }
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 8b0ab53..9f01dbe 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -3841,6 +3841,26 @@ int lnet_dyn_del_ni(struct lnet_nid *nid)
 	return rc;
 }
 
+void lnet_update_ping_buffer(void)
+{
+	struct lnet_ping_buffer *pbuf;
+	struct lnet_handle_md ping_mdh;
+
+	if (the_lnet.ln_routing)
+		return;
+
+	mutex_lock(&the_lnet.ln_api_mutex);
+
+	if (!lnet_ping_target_setup(&pbuf, &ping_mdh,
+				    LNET_PING_INFO_HDR_SIZE +
+				    lnet_get_ni_bytes(),
+				    false))
+		lnet_ping_target_update(pbuf, ping_mdh);
+
+	mutex_unlock(&the_lnet.ln_api_mutex);
+}
+EXPORT_SYMBOL(lnet_update_ping_buffer);
+
 void lnet_incr_dlc_seq(void)
 {
 	atomic_inc(&lnet_dlc_seq_no);
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 619973b..ef924ce 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -3079,6 +3079,15 @@ int ping_info_count_entries(struct lnet_ping_buffer *pbuf)
 	return nnis;
 }
 
+static inline void handle_disc_lpni_health(struct lnet_peer_ni *lpni)
+{
+	if (lpni->lpni_ns_status == LNET_NI_STATUS_DOWN)
+		lnet_handle_remote_failure_locked(lpni);
+	else if (lpni->lpni_ns_status == LNET_NI_STATUS_UP &&
+		 !lpni->lpni_last_alive)
+		atomic_set(&lpni->lpni_healthv, LNET_MAX_HEALTH_VALUE);
+}
+
 /*
  * Build a peer from incoming data.
  *
@@ -3118,6 +3127,7 @@ static int lnet_peer_merge_data(struct lnet_peer *lp,
 	int i;
 	int j;
 	int rc;
+	u32 old_st;
 
 	flags = LNET_PEER_DISCOVERED;
 	if (pbuf->pb_info.pi_features & LNET_PING_FEAT_MULTI_RAIL)
@@ -3194,7 +3204,10 @@ static int lnet_peer_merge_data(struct lnet_peer *lp,
 				 */
 				lpni = lnet_peer_ni_find_locked(&curnis[i]);
 				if (lpni) {
+					old_st = lpni->lpni_ns_status;
 					lpni->lpni_ns_status = *stp;
+					if (old_st != lpni->lpni_ns_status)
+						handle_disc_lpni_health(lpni);
 					lnet_peer_ni_decref_locked(lpni);
 				}
 				break;
@@ -3224,6 +3237,7 @@ static int lnet_peer_merge_data(struct lnet_peer *lp,
 		lpni = lnet_peer_ni_find_locked(&addnis[i].ns_nid);
 		if (lpni) {
 			lpni->lpni_ns_status = addnis[i].ns_status;
+			handle_disc_lpni_health(lpni);
 			lnet_peer_ni_decref_locked(lpni);
 		}
 	}
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
