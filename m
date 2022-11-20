Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id A2C85C433FE
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Nov 2022 14:43:33 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4NFXq50jY1z22RT;
	Sun, 20 Nov 2022 06:25:05 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4NFXpm2GCLz22RJ
 for <lustre-devel@lists.lustre.org>; Sun, 20 Nov 2022 06:24:48 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 039611009358;
 Sun, 20 Nov 2022 09:17:10 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id F35A9E8B84; Sun, 20 Nov 2022 09:17:09 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Nov 2022 09:17:06 -0500
Message-Id: <1668953828-10909-21-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
References: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 20/22] lnet: change lnet_notify() to take
 struct lnet_nid
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
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mr NeilBrown <neilb@suse.de>

lnet_notify() now takes a 'struct lnet_nid *' instead of a
lnet_nid_t.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 4a88236f40a47c05d ("LU-10391 lnet: change lnet_notify() to take struct lnet_nid")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/44633
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h       |  4 ++--
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 10 +++++++---
 net/lnet/klnds/socklnd/socklnd.c    |  2 +-
 net/lnet/lnet/api-ni.c              |  3 ++-
 net/lnet/lnet/router.c              | 15 +++++++--------
 5 files changed, 19 insertions(+), 15 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 7ce6cff..3bcea11 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -574,8 +574,8 @@ unsigned int lnet_nid_cpt_hash(struct lnet_nid *nid,
 
 void lnet_mt_event_handler(struct lnet_event *event);
 
-int lnet_notify(struct lnet_ni *ni, lnet_nid_t peer, bool alive, bool reset,
-		time64_t when);
+int lnet_notify(struct lnet_ni *ni, struct lnet_nid *peer, bool alive,
+		bool reset, time64_t when);
 void lnet_notify_locked(struct lnet_peer_ni *lp, int notifylnd, int alive,
 			time64_t when);
 int lnet_add_route(u32 net, u32 hops, struct lnet_nid *gateway,
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index d4de326..451363b 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -1967,9 +1967,13 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 
 	read_unlock_irqrestore(&kiblnd_data.kib_global_lock, flags);
 
-	if (error)
-		lnet_notify(peer_ni->ibp_ni,
-			    peer_ni->ibp_nid, false, false, last_alive);
+	if (error != 0) {
+		struct lnet_nid nid;
+
+		lnet_nid4_to_nid(peer_ni->ibp_nid, &nid);
+		lnet_notify(peer_ni->ibp_ni, &nid,
+			    false, false, last_alive);
+	}
 }
 
 void
diff --git a/net/lnet/klnds/socklnd/socklnd.c b/net/lnet/klnds/socklnd/socklnd.c
index 21fccfa..d8d1071 100644
--- a/net/lnet/klnds/socklnd/socklnd.c
+++ b/net/lnet/klnds/socklnd/socklnd.c
@@ -1424,7 +1424,7 @@ struct ksock_peer_ni *
 
 	if (notify)
 		lnet_notify(peer_ni->ksnp_ni,
-			    lnet_nid_to_nid4(&peer_ni->ksnp_id.nid),
+			    &peer_ni->ksnp_id.nid,
 			    false, false, last_alive);
 }
 
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 8b53adf..5be2aff 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -4372,7 +4372,8 @@ u32 lnet_get_dlc_seq_locked(void)
 		 * that deadline to the wall clock.
 		 */
 		deadline += ktime_get_seconds();
-		return lnet_notify(NULL, data->ioc_nid, data->ioc_flags, false,
+		lnet_nid4_to_nid(data->ioc_nid, &nid);
+		return lnet_notify(NULL, &nid, data->ioc_flags, false,
 				   deadline);
 	}
 
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index ee4f1d8..358c3f1 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -1672,26 +1672,25 @@ bool lnet_router_checker_active(void)
  * when: notificaiton time.
  */
 int
-lnet_notify(struct lnet_ni *ni, lnet_nid_t nid4, bool alive, bool reset,
+lnet_notify(struct lnet_ni *ni, struct lnet_nid *nid, bool alive, bool reset,
 	    time64_t when)
 {
 	struct lnet_peer_ni *lpni = NULL;
 	struct lnet_route *route;
 	struct lnet_peer *lp;
 	time64_t now = ktime_get_seconds();
-	struct lnet_nid nid;
 	int cpt;
 
 	LASSERT(!in_interrupt());
 
 	CDEBUG(D_NET, "%s notifying %s: %s\n",
 	       !ni ? "userspace" : libcfs_nidstr(&ni->ni_nid),
-	       libcfs_nidstr(&nid), alive ? "up" : "down");
+	       libcfs_nidstr(nid), alive ? "up" : "down");
 
 	if (ni &&
-	    LNET_NID_NET(&ni->ni_nid) != LNET_NID_NET(&nid)) {
+	    LNET_NID_NET(&ni->ni_nid) != LNET_NID_NET(nid)) {
 		CWARN("Ignoring notification of %s %s by %s (different net)\n",
-		      libcfs_nidstr(&nid), alive ? "birth" : "death",
+		      libcfs_nidstr(nid), alive ? "birth" : "death",
 		      libcfs_nidstr(&ni->ni_nid));
 		return -EINVAL;
 	}
@@ -1700,7 +1699,7 @@ bool lnet_router_checker_active(void)
 	if (when > now) {
 		CWARN("Ignoring prediction from %s of %s %s %lld seconds in the future\n",
 		      ni ? libcfs_nidstr(&ni->ni_nid) : "userspace",
-		      libcfs_nidstr(&nid), alive ? "up" : "down", when - now);
+		      libcfs_nidstr(nid), alive ? "up" : "down", when - now);
 		return -EINVAL;
 	}
 
@@ -1718,11 +1717,11 @@ bool lnet_router_checker_active(void)
 		return -ESHUTDOWN;
 	}
 
-	lpni = lnet_peer_ni_find_locked(&nid);
+	lpni = lnet_peer_ni_find_locked(nid);
 	if (!lpni) {
 		/* nid not found */
 		lnet_net_unlock(0);
-		CDEBUG(D_NET, "%s not found\n", libcfs_nidstr(&nid));
+		CDEBUG(D_NET, "%s not found\n", libcfs_nidstr(nid));
 		return 0;
 	}
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
