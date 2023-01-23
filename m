Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id EC84FC25B50
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:25:20 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15PT4RbQz22SC;
	Mon, 23 Jan 2023 15:08:29 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15Lf0c4Qz21JD
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:06:02 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 6B35A9F4;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 6911358994; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:34 -0500
Message-Id: <1674514855-15399-22-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
References: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 21/42] lnet: handles unregister/register
 events
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
Cc: Cyril Bordage <cbordage@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Cyril Bordage <cbordage@whamcloud.com>

When network is restarted, devices are unregistered and then
registered again. When a device registers using an index that is
different from the previous one (before network was restarted), LNet
ignores it. Consequently, this device stays with link in fatal state.

To fix that, we catch unregistering events to clear the saved index
value, and when a registering event comes, we save the new value.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16378
Lustre-commit: 3c9282a67d73799a0 ("LU-16378 lnet: handles unregister/register events")
Signed-off-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49375
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd.c | 26 ++++++++++++++++++++++++--
 1 file changed, 24 insertions(+), 2 deletions(-)

diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index d8d1071d40f4..07e056845b24 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -2010,10 +2010,30 @@ ksocknal_handle_link_state_change(struct net_device *dev,
 		sa = (void *)&ksi->ksni_addr;
 		found_ip = false;
 
-		if (ksi->ksni_index != ifindex ||
-		    strcmp(ksi->ksni_name, dev->name))
+		if (strcmp(ksi->ksni_name, dev->name))
+			continue;
+
+		if (ksi->ksni_index == -1) {
+			if (dev->reg_state != NETREG_REGISTERED)
+				continue;
+			/* A registration just happened: save the new index for
+			 * the device
+			 */
+			ksi->ksni_index = ifindex;
+			goto out;
+		}
+
+		if (ksi->ksni_index != ifindex)
 			continue;
 
+		if (dev->reg_state == NETREG_UNREGISTERING) {
+			/* Device is being unregitering, we need to clear the
+			 * index, it can change when device will be back
+			 */
+			ksi->ksni_index = -1;
+			goto out;
+		}
+
 		ni = net->ksnn_ni;
 
 		in_dev = __in_dev_get_rtnl(dev);
@@ -2108,6 +2128,8 @@ static int ksocknal_device_event(struct notifier_block *unused,
 	case NETDEV_UP:
 	case NETDEV_DOWN:
 	case NETDEV_CHANGE:
+	case NETDEV_REGISTER:
+	case NETDEV_UNREGISTER:
 		ksocknal_handle_link_state_change(dev, operstate);
 		break;
 	}
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
