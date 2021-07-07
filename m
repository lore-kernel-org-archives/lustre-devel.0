Return-Path: <SRS0=JyPa=L7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE2B0C07E9B
	for <lustre-devel@archiver.kernel.org>; Wed,  7 Jul 2021 19:11:26 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 58B7061C48
	for <lustre-devel@archiver.kernel.org>; Wed,  7 Jul 2021 19:11:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 58B7061C48
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 5456221FDD7;
	Wed,  7 Jul 2021 12:11:25 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 8433921F888
 for <lustre-devel@lists.lustre.org>; Wed,  7 Jul 2021 12:11:21 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 488D610090EF;
 Wed,  7 Jul 2021 15:11:18 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 429BA9D8AD; Wed,  7 Jul 2021 15:11:18 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  7 Jul 2021 15:11:08 -0400
Message-Id: <1625685076-1964-8-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1625685076-1964-1-git-send-email-jsimmons@infradead.org>
References: <1625685076-1964-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 07/15] lnet: socklnd: detect link state to
 set fatal error on ni
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
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

To help avoid selecting lnet ni which corresponds to a downed
ethernet link for sending, add a mechanism for detecting link
events in socklnd. On link up/down events, find corresponding
ni and toggle ni_fatal_error_on flag, similar to o2iblnd way.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14742
Lustre-commit: fc2df80e96dc5db9f ("LU-14742 socklnd: detect link state to set fatal error on ni")
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/43952
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.c | 78 ++++++++++++++++++++++++++++++++++++++++
 net/lnet/klnds/socklnd/socklnd.h |  1 +
 2 files changed, 79 insertions(+)

diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index eb8c736..e15f1c0 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -1843,6 +1843,78 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 	}
 }
 
+static int ksocknal_get_link_status(struct net_device *dev)
+{
+	int ret = -1;
+
+	LASSERT(dev);
+
+	if (!netif_running(dev))
+		ret = 0;
+	/* Some devices may not be providing link settings */
+	else if (dev->ethtool_ops->get_link)
+		ret = dev->ethtool_ops->get_link(dev);
+
+	return ret;
+}
+
+static int
+ksocknal_handle_link_state_change(struct net_device *dev,
+				  unsigned char operstate)
+{
+	struct lnet_ni *ni;
+	struct ksock_net *net;
+	struct ksock_net *cnxt;
+	int ifindex;
+	unsigned char link_down = !(operstate == IF_OPER_UP);
+
+	ifindex = dev->ifindex;
+
+	if (!ksocknal_data.ksnd_nnets)
+		goto out;
+
+	list_for_each_entry_safe(net, cnxt, &ksocknal_data.ksnd_nets,
+				 ksnn_list) {
+		if (net->ksnn_interface.ksni_index != ifindex)
+			continue;
+		ni = net->ksnn_ni;
+		if (link_down)
+			atomic_set(&ni->ni_fatal_error_on, link_down);
+		else
+			atomic_set(&ni->ni_fatal_error_on,
+				   (ksocknal_get_link_status(dev) == 0));
+	}
+out:
+	return 0;
+}
+
+
+/************************************
+ * Net device notifier event handler
+ ************************************/
+static int ksocknal_device_event(struct notifier_block *unused,
+				 unsigned long event, void *ptr)
+{
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+	unsigned char operstate;
+
+	operstate = dev->operstate;
+
+	switch (event) {
+	case NETDEV_UP:
+	case NETDEV_DOWN:
+	case NETDEV_CHANGE:
+		ksocknal_handle_link_state_change(dev, operstate);
+		break;
+	}
+
+	return NOTIFY_OK;
+}
+
+static struct notifier_block ksocknal_notifier_block = {
+	.notifier_call = ksocknal_device_event,
+};
+
 static void
 ksocknal_base_shutdown(void)
 {
@@ -1852,6 +1924,9 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 
 	LASSERT(!ksocknal_data.ksnd_nnets);
 
+	if (ksocknal_data.ksnd_init == SOCKNAL_INIT_ALL)
+		unregister_netdevice_notifier(&ksocknal_notifier_block);
+
 	switch (ksocknal_data.ksnd_init) {
 	default:
 		LASSERT(0);
@@ -2015,6 +2090,8 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 		goto failed;
 	}
 
+	register_netdevice_notifier(&ksocknal_notifier_block);
+
 	/* flag everything initialised */
 	ksocknal_data.ksnd_init = SOCKNAL_INIT_ALL;
 
@@ -2297,6 +2374,7 @@ static int ksocknal_push(struct lnet_ni *ni, struct lnet_process_id id)
 	ni->ni_nid = LNET_MKNID(LNET_NIDNET(ni->ni_nid),
 				ntohl(((struct sockaddr_in *)&ksi->ksni_addr)->sin_addr.s_addr));
 	list_add(&net->ksnn_list, &ksocknal_data.ksnd_nets);
+	net->ksnn_ni = ni;
 	ksocknal_data.ksnd_nnets++;
 
 	return 0;
diff --git a/net/lnet/klnds/socklnd/socklnd.h b/net/lnet/klnds/socklnd/socklnd.h
index dac8559..357769a 100644
--- a/net/lnet/klnds/socklnd/socklnd.h
+++ b/net/lnet/klnds/socklnd/socklnd.h
@@ -175,6 +175,7 @@ struct ksock_net {
 	struct list_head	ksnn_list;		/* chain on global list */
 	atomic_t		ksnn_npeers;		/* # peers */
 	struct ksock_interface	ksnn_interface;		/* IP interface */
+	struct lnet_ni		*ksnn_ni;
 };
 
 /* When the ksock_net is shut down, this bias is added to
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
