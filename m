Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 9102CC433EF
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Jan 2022 01:38:46 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id AF4CE21FFA9;
	Thu, 13 Jan 2022 17:38:34 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id F13AC3B60F7
 for <lustre-devel@lists.lustre.org>; Thu, 13 Jan 2022 17:38:08 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id BFC5E100F327;
 Thu, 13 Jan 2022 20:38:04 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id B9DB0A8103; Thu, 13 Jan 2022 20:38:04 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 13 Jan 2022 20:37:47 -0500
Message-Id: <1642124283-10148-9-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
References: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 08/24] lnet: o2iblnd: treat cmid->device ==
 NULL as an error
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

Even if rdma_bind_addr is successful, kiblnd_dev_failover should
treat cmid->device == NULL as an error in order to later avoid
calling kiblnd_set_ni_fatal_on with possibly dev->ibd_hdev == NULL.

Fixes: 5e07562bc3 ("lnet: o2iblnd: clear fatal error on successful failover")
WC-bug-id: https://jira.whamcloud.com/browse/LU-15018
Lustre-commit: abd0ce62e96523193 ("LU-15018 o2iblnd: treat cmid->device == NULL as an error")
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/44981
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd.c b/net/lnet/klnds/o2iblnd/o2iblnd.c
index 7d28acd..76f5e7f 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd.c
@@ -2365,6 +2365,7 @@ int kiblnd_dev_failover(struct kib_dev *dev, struct net *ns)
 	struct kib_net *net;
 	struct sockaddr_in addr;
 	struct net_device *netdev;
+	bool set_fatal = true;
 	unsigned long flags;
 	int rc = 0;
 	int i;
@@ -2416,6 +2417,8 @@ int kiblnd_dev_failover(struct kib_dev *dev, struct net *ns)
 		CERROR("Failed to bind %s:%pI4h to device(%p): %d\n",
 		       dev->ibd_ifname, &dev->ibd_ifip,
 		       cmid->device, rc);
+		if (!rc && !cmid->device)
+			set_fatal = false;
 		rdma_destroy_id(cmid);
 		goto out;
 	}
@@ -2490,11 +2493,13 @@ int kiblnd_dev_failover(struct kib_dev *dev, struct net *ns)
 	} else {
 		dev->ibd_failed_failover = 0;
 
-		rcu_read_lock();
-		netdev = dev_get_by_name_rcu(ns, dev->ibd_ifname);
-		if (netdev && (kiblnd_get_link_status(netdev) == 1))
-			kiblnd_set_ni_fatal_on(dev->ibd_hdev, 0);
-		rcu_read_unlock();
+		if (set_fatal) {
+			rcu_read_lock();
+			netdev = dev_get_by_name_rcu(ns, dev->ibd_ifname);
+			if (netdev && (kiblnd_get_link_status(netdev) == 1))
+				kiblnd_set_ni_fatal_on(dev->ibd_hdev, 0);
+			rcu_read_unlock();
+		}
 	}
 
 	return rc;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
