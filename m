Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id C77A8C4332F
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Nov 2022 14:47:13 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4NFXwM0Wczz22YL;
	Sun, 20 Nov 2022 06:29:39 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4NFXsC6cw7z22Vd
 for <lustre-devel@lists.lustre.org>; Sun, 20 Nov 2022 06:26:55 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 09182100935B;
 Sun, 20 Nov 2022 09:17:10 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 0707FE8B8B; Sun, 20 Nov 2022 09:17:10 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Nov 2022 09:17:08 -0500
Message-Id: <1668953828-10909-23-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
References: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 22/22] lnet: change lnet_debug_peer() to
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

lnet_debug_peer() now takes 'struct lnet_nid *'.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: e834ad5992adef598 ("LU-10391 lnet: change lnet_debug_peer() to struct lnet_nid")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/44635
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h |  2 +-
 net/lnet/lnet/api-ni.c        |  2 +-
 net/lnet/lnet/peer.c          | 10 ++++------
 3 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index a2d5adc..ba68d50 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -936,7 +936,7 @@ void lnet_peer_primary_nid_locked(struct lnet_nid *nid,
 void lnet_peer_tables_cleanup(struct lnet_net *net);
 void lnet_peer_uninit(void);
 int lnet_peer_tables_create(void);
-void lnet_debug_peer(lnet_nid_t nid);
+void lnet_debug_peer(struct lnet_nid *nid);
 struct lnet_peer_net *lnet_peer_get_net_locked(struct lnet_peer *peer,
 					       u32 net_id);
 bool lnet_peer_is_pref_nid_locked(struct lnet_peer_ni *lpni,
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 0146509..e400de7 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -5257,7 +5257,7 @@ static int lnet_net_cmd(struct sk_buff *skb, struct genl_info *info)
 
 void LNetDebugPeer(struct lnet_processid *id)
 {
-	lnet_debug_peer(lnet_nid_to_nid4(&id->nid));
+	lnet_debug_peer(&id->nid);
 }
 EXPORT_SYMBOL(LNetDebugPeer);
 
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index a1305b6..8c603c9 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -3966,21 +3966,19 @@ void lnet_peer_discovery_stop(void)
 /* Debugging */
 
 void
-lnet_debug_peer(lnet_nid_t nid4)
+lnet_debug_peer(struct lnet_nid *nid)
 {
 	char *aliveness = "NA";
 	struct lnet_peer_ni *lp;
-	struct lnet_nid nid;
 	int cpt;
 
-	lnet_nid4_to_nid(nid4, &nid);
-	cpt = lnet_nid2cpt(&nid, NULL);
+	cpt = lnet_nid2cpt(nid, NULL);
 	lnet_net_lock(cpt);
 
-	lp = lnet_peerni_by_nid_locked(&nid, NULL, cpt);
+	lp = lnet_peerni_by_nid_locked(nid, NULL, cpt);
 	if (IS_ERR(lp)) {
 		lnet_net_unlock(cpt);
-		CDEBUG(D_WARNING, "No peer %s\n", libcfs_nidstr(&nid));
+		CDEBUG(D_WARNING, "No peer %s\n", libcfs_nidstr(nid));
 		return;
 	}
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
