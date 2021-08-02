Return-Path: <SRS0=Kfxm=MZ=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8231C432BE
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:51:53 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7F3B660F36
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:51:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 7F3B660F36
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id C88BA352ECE;
	Mon,  2 Aug 2021 12:51:37 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 24D03352C5E
 for <lustre-devel@lists.lustre.org>; Mon,  2 Aug 2021 12:51:02 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 9784C100F35E;
 Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 96846C2F55; Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  2 Aug 2021 15:50:47 -0400
Message-Id: <1627933851-7603-28-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
References: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 24/25] lnet: o2iblnd: clear fatal error on
 successful failover
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

In IB bonding configuration link down event causes fatal error
flag to be set on the bonded interface so it is not selected by
LNet for tx, e.g. when just one of the two cables is pulled.
This change allows for the interface status to be restored on
successful failover.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14806
Lustre-commit: 4668283cd13079dd ("LU-14806 o2iblnd: clear fatal error on successful failover")
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/44139
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c | 27 +++++++++++++++++++++++++--
 1 file changed, 25 insertions(+), 2 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index 3141953..686581a 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -1487,6 +1487,21 @@ static void kiblnd_fini_fmr_poolset(struct kib_fmr_poolset *fps)
 	}
 }
 
+static int kiblnd_get_link_status(struct net_device *dev)
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
 static int
 kiblnd_init_fmr_poolset(struct kib_fmr_poolset *fps, int cpt, int ncpts,
 			struct kib_net *net,
@@ -2347,6 +2362,7 @@ int kiblnd_dev_failover(struct kib_dev *dev, struct net *ns)
 	struct ib_pd *pd;
 	struct kib_net *net;
 	struct sockaddr_in addr;
+	struct net_device *netdev;
 	unsigned long flags;
 	int rc = 0;
 	int i;
@@ -2467,11 +2483,18 @@ int kiblnd_dev_failover(struct kib_dev *dev, struct net *ns)
 	if (hdev)
 		kiblnd_hdev_decref(hdev);
 
-	if (rc)
+	if (rc) {
 		dev->ibd_failed_failover++;
-	else
+	} else {
 		dev->ibd_failed_failover = 0;
 
+		rcu_read_lock();
+		netdev = dev_get_by_name_rcu(ns, dev->ibd_ifname);
+		if (netdev && (kiblnd_get_link_status(netdev) == 1))
+			kiblnd_set_ni_fatal_on(dev->ibd_hdev, 0);
+		rcu_read_unlock();
+	}
+
 	return rc;
 }
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
