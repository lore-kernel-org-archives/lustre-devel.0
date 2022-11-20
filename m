Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id BDEB1C433FE
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Nov 2022 14:45:20 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4NFXvd4xgJz22Xp;
	Sun, 20 Nov 2022 06:29:01 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4NFXqd4Z0Hz22SJ
 for <lustre-devel@lists.lustre.org>; Sun, 20 Nov 2022 06:25:33 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 064A91009359;
 Sun, 20 Nov 2022 09:17:10 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 032F5E8B89; Sun, 20 Nov 2022 09:17:10 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Nov 2022 09:17:07 -0500
Message-Id: <1668953828-10909-22-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
References: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 21/22] lnet: discard lnet_nid2ni_*()
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

These 'struct lnet_ni' lookup functions which take a nid4, are
discarded in favour of the versions which take a 'struct lnet_nid'.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10391
Lustre-commit: cbfbe6d132c6d0fe5 ("LU-10391 lnet: discard lnet_nid2ni_*()")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/44634
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h       |  2 --
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c |  9 +++++----
 net/lnet/lnet/api-ni.c              | 33 +++------------------------------
 3 files changed, 8 insertions(+), 36 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index 3bcea11..a2d5adc 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -542,9 +542,7 @@ unsigned int lnet_nid_cpt_hash(struct lnet_nid *nid,
 int lnet_cpt_of_nid_locked(struct lnet_nid *nid, struct lnet_ni *ni);
 int lnet_cpt_of_nid(lnet_nid_t nid, struct lnet_ni *ni);
 int lnet_nid2cpt(struct lnet_nid *nid, struct lnet_ni *ni);
-struct lnet_ni *lnet_nid2ni_locked(lnet_nid_t nid, int cpt);
 struct lnet_ni *lnet_nid_to_ni_locked(struct lnet_nid *nid, int cpt);
-struct lnet_ni *lnet_nid2ni_addref(lnet_nid_t nid);
 struct lnet_ni *lnet_net2ni_locked(u32 net, int cpt);
 struct lnet_ni *lnet_net2ni_addref(u32 net);
 struct lnet_ni *lnet_nid_to_ni_addref(struct lnet_nid *nid);
diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 451363b..6fc1730 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -2397,8 +2397,9 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	struct kib_peer_ni *peer_ni;
 	struct kib_peer_ni *peer2;
 	struct kib_conn *conn;
-	struct lnet_ni *ni  = NULL;
+	struct lnet_ni *ni = NULL;
 	struct kib_net *net = NULL;
+	struct lnet_nid destnid;
 	lnet_nid_t nid;
 	struct rdma_conn_param cp;
 	struct kib_rej rej;
@@ -2461,7 +2462,8 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	}
 
 	nid = reqmsg->ibm_srcnid;
-	ni = lnet_nid2ni_addref(reqmsg->ibm_dstnid);
+	lnet_nid4_to_nid(reqmsg->ibm_dstnid, &destnid);
+	ni  = lnet_nid_to_ni_addref(&destnid);
 
 	if (ni) {
 		net = (struct kib_net *)ni->ni_data;
@@ -2469,8 +2471,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 	}
 
 	if (!ni ||				/* no matching net */
-	    lnet_nid_to_nid4(&ni->ni_nid) !=
-	    reqmsg->ibm_dstnid ||		/* right NET, wrong NID! */
+	    !nid_same(&ni->ni_nid, &destnid) ||	/* right NET, wrong NID! */
 	    net->ibn_dev != ibdev) {		/* wrong device */
 		CERROR("Can't accept conn from %s on %s (%s:%d:%pI4h): bad dst nid %s\n",
 		       libcfs_nid2str(nid),
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 5be2aff..0146509 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -1654,33 +1654,6 @@ struct lnet_ni *
 	return NULL;
 }
 
-struct lnet_ni  *
-lnet_nid2ni_locked(lnet_nid_t nid4, int cpt)
-{
-	struct lnet_nid nid;
-
-	lnet_nid4_to_nid(nid4, &nid);
-	return lnet_nid_to_ni_locked(&nid, cpt);
-}
-
-struct lnet_ni *
-lnet_nid2ni_addref(lnet_nid_t nid4)
-{
-	struct lnet_ni *ni;
-	struct lnet_nid nid;
-
-	lnet_nid4_to_nid(nid4, &nid);
-
-	lnet_net_lock(0);
-	ni = lnet_nid_to_ni_locked(&nid, 0);
-	if (ni)
-		lnet_ni_addref_locked(ni, 0);
-	lnet_net_unlock(0);
-
-	return ni;
-}
-EXPORT_SYMBOL(lnet_nid2ni_addref);
-
 struct lnet_ni *
 lnet_nid_to_ni_addref(struct lnet_nid *nid)
 {
@@ -3918,11 +3891,11 @@ u32 lnet_get_dlc_seq_locked(void)
 {
 	int cpt, rc = 0;
 	struct lnet_ni *ni;
-	lnet_nid_t nid = stats->hlni_nid;
+	struct lnet_nid nid;
 
+	lnet_nid4_to_nid(stats->hlni_nid, &nid);
 	cpt = lnet_net_lock_current();
-	ni = lnet_nid2ni_locked(nid, cpt);
-
+	ni = lnet_nid_to_ni_locked(&nid, cpt);
 	if (!ni) {
 		rc = -ENOENT;
 		goto unlock;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
