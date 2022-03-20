Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 8D568C433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:32:08 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 75D5D21FAD6;
	Sun, 20 Mar 2022 06:31:43 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E8BB821CA88
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:14 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 2DC2CEE7;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 2A5DDDD6ED; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:34 -0400
Message-Id: <1647783064-20688-21-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 20/50] lnet: alter lnd_notify_peer_down() to
 take lnet_nid
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

The lnd_notify_peer_down() interface now takes a large nid.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 6a9bdf59e6306d49c ("LU-10391 lnet: alter lnd_notify_peer_down() to take lnet_nid")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/43608
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h   |  2 +-
 net/lnet/klnds/socklnd/socklnd.c | 12 +++++-------
 net/lnet/lnet/router.c           |  4 ++--
 3 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 40767e6..f7f0b0b 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -328,7 +328,7 @@ struct lnet_lnd {
 			      struct lnet_msg *msg, void **new_privatep);
 
 	/* notification of peer down */
-	void (*lnd_notify_peer_down)(lnet_nid_t peer);
+	void (*lnd_notify_peer_down)(struct lnet_nid *peer);
 
 	/* accept a new connection */
 	int (*lnd_accept)(struct lnet_ni *ni, struct socket *sock);
diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 6d1f85c..e3201d1 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -1670,25 +1670,23 @@ struct ksock_peer_ni *
 }
 
 void
-ksocknal_notify_gw_down(lnet_nid_t gw_nid)
+ksocknal_notify_gw_down(struct lnet_nid *gw_nid)
 {
-	/*
-	 * The router is telling me she's been notified of a change in
+	/* The router is telling me she's been notified of a change in
 	 * gateway state....
 	 */
 	struct lnet_processid id = {
 		.pid	= LNET_PID_ANY,
+		.nid	= *gw_nid,
 	};
 
-	CDEBUG(D_NET, "gw %s down\n", libcfs_nid2str(gw_nid));
+	CDEBUG(D_NET, "gw %s down\n", libcfs_nidstr(gw_nid));
 
-	lnet_nid4_to_nid(gw_nid, &id.nid);
 	/* If the gateway crashed, close all open connections... */
 	ksocknal_close_matching_conns(&id, 0);
 	return;
 
-	/*
-	 * We can only establish new connections
+	/* We can only establish new connections
 	 * if we have autroutes, and these connect on demand.
 	 */
 }
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 97e5ab2..87ae1f9 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -1681,7 +1681,7 @@ bool lnet_router_checker_active(void)
 }
 
 static inline void
-lnet_notify_peer_down(struct lnet_ni *ni, lnet_nid_t nid)
+lnet_notify_peer_down(struct lnet_ni *ni, struct lnet_nid *nid)
 {
 	if (ni->ni_net->net_lnd->lnd_notify_peer_down)
 		ni->ni_net->net_lnd->lnd_notify_peer_down(nid);
@@ -1796,7 +1796,7 @@ bool lnet_router_checker_active(void)
 	lnet_net_unlock(0);
 
 	if (ni && !alive)
-		lnet_notify_peer_down(ni, lnet_nid_to_nid4(&lpni->lpni_nid));
+		lnet_notify_peer_down(ni, &lpni->lpni_nid);
 
 	cpt = lpni->lpni_cpt;
 	lnet_net_lock(cpt);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
