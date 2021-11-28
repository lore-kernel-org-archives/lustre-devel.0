Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 76FEDC433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 28 Nov 2021 23:28:59 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A0148200F4A;
	Sun, 28 Nov 2021 15:28:41 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id DE44E200EB1
 for <lustre-devel@lists.lustre.org>; Sun, 28 Nov 2021 15:27:59 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 8E181243;
 Sun, 28 Nov 2021 18:27:56 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 818EFC1ACE; Sun, 28 Nov 2021 18:27:56 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 28 Nov 2021 18:27:37 -0500
Message-Id: <1638142074-5945-3-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1638142074-5945-1-git-send-email-jsimmons@infradead.org>
References: <1638142074-5945-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 02/19] lnet: change tp_nid to 16byte in
 lnet_test_peer.
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

This updates 'struct lnet_test_peer' to store a large address nid.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: 7e89b556ea7dc4b4c ("LU-10391 lnet: change tp_nid to 16byte in lnet_test_peer.")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/43595
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Amir Shehata <ashehata@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-types.h |  2 +-
 net/lnet/lnet/lib-move.c       | 18 +++++++++++-------
 2 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/include/linux/lnet/lib-types.h b/include/linux/lnet/lib-types.h
index 380a7b9..1901ad2 100644
--- a/include/linux/lnet/lib-types.h
+++ b/include/linux/lnet/lib-types.h
@@ -233,7 +233,7 @@ struct lnet_libmd {
 struct lnet_test_peer {
 	/* info about peers we are trying to fail */
 	struct list_head	tp_list;	/* ln_test_peers */
-	lnet_nid_t		tp_nid;		/* matching nid */
+	struct lnet_nid		tp_nid;		/* matching nid */
 	unsigned int		tp_threshold;	/* # failures to simulate */
 };
 
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 170d684..b9f5973 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -190,13 +190,15 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 }
 
 int
-lnet_fail_nid(lnet_nid_t nid, unsigned int threshold)
+lnet_fail_nid(lnet_nid_t nid4, unsigned int threshold)
 {
 	struct lnet_test_peer *tp;
 	struct list_head *el;
 	struct list_head *next;
+	struct lnet_nid nid;
 	LIST_HEAD(cull);
 
+	lnet_nid4_to_nid(nid4, &nid);
 	/* NB: use lnet_net_lock(0) to serialize operations on test peers */
 	if (threshold) {
 		/* Adding a new entry */
@@ -218,9 +220,9 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 	list_for_each_safe(el, next, &the_lnet.ln_test_peers) {
 		tp = list_entry(el, struct lnet_test_peer, tp_list);
 
-		if (!tp->tp_threshold ||    /* needs culling anyway */
-		    nid == LNET_NID_ANY ||       /* removing all entries */
-		    tp->tp_nid == nid) {	  /* matched this one */
+		if (!tp->tp_threshold ||	/* needs culling anyway */
+		    LNET_NID_IS_ANY(&nid) ||	/* removing all entries */
+		    nid_same(&tp->tp_nid, &nid)) {	/* matched this one */
 			list_move(&tp->tp_list, &cull);
 		}
 	}
@@ -237,14 +239,16 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 }
 
 static int
-fail_peer(lnet_nid_t nid, int outgoing)
+fail_peer(lnet_nid_t nid4, int outgoing)
 {
 	struct lnet_test_peer *tp;
 	struct list_head *el;
 	struct list_head *next;
+	struct lnet_nid nid;
 	LIST_HEAD(cull);
 	int fail = 0;
 
+	lnet_nid4_to_nid(nid4, &nid);
 	/* NB: use lnet_net_lock(0) to serialize operations on test peers */
 	lnet_net_lock(0);
 
@@ -264,8 +268,8 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 			continue;
 		}
 
-		if (tp->tp_nid == LNET_NID_ANY || /* fail every peer */
-		    nid == tp->tp_nid) {	/* fail this peer */
+		if (LNET_NID_IS_ANY(&tp->tp_nid) ||	/* fail every peer */
+		    nid_same(&nid, &tp->tp_nid)) {	/* fail this peer */
 			fail = 1;
 
 			if (tp->tp_threshold != LNET_MD_THRESH_INF) {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
