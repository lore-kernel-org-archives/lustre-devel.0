Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67EC0C77B61
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:42:11 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWVC6wGHz22Yp;
	Sun,  9 Apr 2023 05:23:31 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWS62n1tz1yGl
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:21:42 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 608AE1008490;
 Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 5F5262B3; Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:13:14 -0400
Message-Id: <1681042400-15491-35-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 34/40] lnet: add 'force' option to lnetctl
 peer del
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
Cc: Serguei Smirnov <ssmirnov@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Serguei Smirnov <ssmirnov@whamcloud.com>

Add --force option to 'lnetctl peer del' command.
If the peer has primary NID locked, this option allows
for the peer to be deleted manually:
  lnetctl peer del --prim_nid <nid> --force

Add --prim_lock option to 'lnetctl peer add' command.
If specified, the primary NID of the peer is locked
such that it is going to be the NID used to identify
the peer in communications with Lustre layer.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14668
Lustre-commit: f1b2d8d60c593a670 ("LU-14668 lnet: add 'force' option to lnetctl peer del")
Signed-off-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50149
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 include/linux/lnet/lib-lnet.h      |  6 ++++--
 include/uapi/linux/lnet/lnet-dlc.h |  4 +++-
 net/lnet/lnet/api-ni.c             |  6 ++++--
 net/lnet/lnet/peer.c               | 12 ++++++++----
 4 files changed, 19 insertions(+), 9 deletions(-)

diff --git a/include/linux/lnet/lib-lnet.h b/include/linux/lnet/lib-lnet.h
index a8aa924..e26e150 100644
--- a/include/linux/lnet/lib-lnet.h
+++ b/include/linux/lnet/lib-lnet.h
@@ -953,8 +953,10 @@ bool lnet_peer_is_pref_rtr_locked(struct lnet_peer_ni *lpni,
 int lnet_peer_add_pref_rtr(struct lnet_peer_ni *lpni, struct lnet_nid *nid);
 int lnet_peer_ni_set_non_mr_pref_nid(struct lnet_peer_ni *lpni,
 				     struct lnet_nid *nid);
-int lnet_user_add_peer_ni(struct lnet_nid *key_nid, struct lnet_nid *nid, bool mr);
-int lnet_del_peer_ni(struct lnet_nid *key_nid, struct lnet_nid *nid);
+int lnet_user_add_peer_ni(struct lnet_nid *key_nid, struct lnet_nid *nid,
+			  bool mr, bool lock_prim);
+int lnet_del_peer_ni(struct lnet_nid *key_nid, struct lnet_nid *nid,
+		     int force);
 int lnet_get_peer_info(struct lnet_ioctl_peer_cfg *cfg, void __user *bulk);
 int lnet_get_peer_ni_info(u32 peer_index, u64 *nid,
 			  char alivness[LNET_MAX_STR_LEN],
diff --git a/include/uapi/linux/lnet/lnet-dlc.h b/include/uapi/linux/lnet/lnet-dlc.h
index 63578a0..fc1d40c 100644
--- a/include/uapi/linux/lnet/lnet-dlc.h
+++ b/include/uapi/linux/lnet/lnet-dlc.h
@@ -298,7 +298,9 @@ struct lnet_ioctl_peer_cfg {
 	struct libcfs_ioctl_hdr prcfg_hdr;
 	lnet_nid_t prcfg_prim_nid;
 	lnet_nid_t prcfg_cfg_nid;
-	__u32 prcfg_count;
+	__u32 prcfg_count;	/* ADD_PEER_NI: used for 'lock_prim' option
+				 * DEL_PEER_NI: used for 'force' option
+				 */
 	__u32 prcfg_mr;
 	__u32 prcfg_state;
 	__u32 prcfg_size;
diff --git a/net/lnet/lnet/api-ni.c b/net/lnet/lnet/api-ni.c
index 20093a9..9095d4e 100644
--- a/net/lnet/lnet/api-ni.c
+++ b/net/lnet/lnet/api-ni.c
@@ -4239,7 +4239,8 @@ u32 lnet_get_dlc_seq_locked(void)
 		mutex_lock(&the_lnet.ln_api_mutex);
 		lnet_nid4_to_nid(cfg->prcfg_prim_nid, &prim_nid);
 		lnet_nid4_to_nid(cfg->prcfg_cfg_nid, &nid);
-		rc = lnet_user_add_peer_ni(&prim_nid, &nid, cfg->prcfg_mr);
+		rc = lnet_user_add_peer_ni(&prim_nid, &nid, cfg->prcfg_mr,
+					   cfg->prcfg_count == 1);
 		mutex_unlock(&the_lnet.ln_api_mutex);
 		return rc;
 	}
@@ -4255,7 +4256,8 @@ u32 lnet_get_dlc_seq_locked(void)
 		lnet_nid4_to_nid(cfg->prcfg_prim_nid, &prim_nid);
 		lnet_nid4_to_nid(cfg->prcfg_cfg_nid, &nid);
 		rc = lnet_del_peer_ni(&prim_nid,
-				      &nid);
+				      &nid,
+				      cfg->prcfg_count);
 		mutex_unlock(&the_lnet.ln_api_mutex);
 		return rc;
 	}
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 0a5e73a..619973b 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -1978,9 +1978,12 @@ struct lnet_peer_net *
 	return lnet_peer_add_nid(lp, nid, flags);
 }
 
-int lnet_user_add_peer_ni(struct lnet_nid *prim_nid, struct lnet_nid *nid, bool mr)
+int lnet_user_add_peer_ni(struct lnet_nid *prim_nid, struct lnet_nid *nid,
+			  bool mr, bool lock_prim)
 {
-	return lnet_add_peer_ni(prim_nid, nid, mr, LNET_PEER_CONFIGURED);
+	int fl = LNET_PEER_CONFIGURED | (LNET_PEER_LOCK_PRIMARY * lock_prim);
+
+	return lnet_add_peer_ni(prim_nid, nid, mr, fl);
 }
 
 static int
@@ -2029,7 +2032,8 @@ int lnet_user_add_peer_ni(struct lnet_nid *prim_nid, struct lnet_nid *nid, bool
  * being modified/deleted by a different thread.
  */
 int
-lnet_del_peer_ni(struct lnet_nid *prim_nid, struct lnet_nid *nid)
+lnet_del_peer_ni(struct lnet_nid *prim_nid, struct lnet_nid *nid,
+		 int force)
 {
 	struct lnet_peer *lp;
 	struct lnet_peer_ni *lpni;
@@ -2061,7 +2065,7 @@ int lnet_user_add_peer_ni(struct lnet_nid *prim_nid, struct lnet_nid *nid, bool
 	lnet_net_unlock(LNET_LOCK_EX);
 
 	if (LNET_NID_IS_ANY(nid) || nid_same(nid, &lp->lp_primary_nid)) {
-		if (lp->lp_state & LNET_PEER_LOCK_PRIMARY) {
+		if (!force && lp->lp_state & LNET_PEER_LOCK_PRIMARY) {
 			CERROR("peer %s created by Lustre. Must preserve primary NID, but will remove other NIDs\n",
 			       libcfs_nidstr(&lp->lp_primary_nid));
 			return lnet_reset_peer(lp);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
