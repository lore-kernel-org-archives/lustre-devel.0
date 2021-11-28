Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id B718AC433EF
	for <lustre-devel@archiver.kernel.org>; Sun, 28 Nov 2021 23:28:52 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B8D03200EE1;
	Sun, 28 Nov 2021 15:28:34 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id F33EC200F73
 for <lustre-devel@lists.lustre.org>; Sun, 28 Nov 2021 15:28:02 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id B66B9266;
 Sun, 28 Nov 2021 18:27:56 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id B544BC1ADA; Sun, 28 Nov 2021 18:27:56 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 28 Nov 2021 18:27:50 -0500
Message-Id: <1638142074-5945-16-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1638142074-5945-1-git-send-email-jsimmons@infradead.org>
References: <1638142074-5945-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 15/19] lnet: set eth routes needed for multi
 rail
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

When ksocklnd is initialized or new ethernet interfaces
are added via lnetctl, set the routing rules using a common
shell script ksocklnd-config. This ensures control over
source interface when sending traffic.

For example, for eth0 with ip 192.168.122.142/24:
   the output of "ip route show table eth0" should be
192.168.122.0/24 dev eth0 proto kernel scope link src 192.168.122.142

This step can be omitted by specifying
   options ksocklnd skip_mr_route_setup=1
in the conf file, or by using switch
   --skip-mr-route-setup
when adding NI with lnetctl. Note that the module parameter
takes priority over the lnetctl switch: if skip-mr-route-setup
is not specified when adding NI with lnetctl, the route still
won't get created if the conf file has skip_mr_route_setup=1.

The route also won't be created if any route already exists
for the given interface, assuming advanced users who manage
routing on their own will want to continue doing so.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14662
Lustre-commit: c9bfe57bd2495671f ("LU-14662 lnet: set eth routes needed for multi rail")
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/44065
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/socklnd/socklnd_modparams.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/lnet/klnds/socklnd/socklnd_modparams.c b/net/lnet/klnds/socklnd/socklnd_modparams.c
index c00ea49..5eb58ca 100644
--- a/net/lnet/klnds/socklnd/socklnd_modparams.c
+++ b/net/lnet/klnds/socklnd/socklnd_modparams.c
@@ -147,6 +147,11 @@
 module_param(conns_per_peer, uint, 0644);
 MODULE_PARM_DESC(conns_per_peer, "number of connections per peer");
 
+/* By default skip_mr_route_setup is 0 (do not skip) */
+static unsigned int skip_mr_route_setup;
+module_param(skip_mr_route_setup, uint, 0444);
+MODULE_PARM_DESC(skip_mr_route_setup, "skip automatic setup of linux routes for MR");
+
 #if SOCKNAL_VERSION_DEBUG
 static int protocol = 3;
 module_param(protocol, int, 0644);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
