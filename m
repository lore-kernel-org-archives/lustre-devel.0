Return-Path: <SRS0=NZgA=GY=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.9 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNWANTED_LANGUAGE_BODY,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B01F1C433DB
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:18:03 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 680F723A5A
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:18:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 680F723A5A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 07CE821FE3D;
	Thu, 21 Jan 2021 09:17:42 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D580221FA40
 for <lustre-devel@lists.lustre.org>; Thu, 21 Jan 2021 09:17:07 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 32F6E100804E;
 Thu, 21 Jan 2021 12:17:05 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 2C28DF0A5; Thu, 21 Jan 2021 12:17:05 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 21 Jan 2021 12:16:29 -0500
Message-Id: <1611249422-556-7-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
References: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 06/39] lnet: Introduce constant for net ID of
 LNET_NID_ANY
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
Cc: Chris Horn <chris.horn@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Chris Horn <chris.horn@hpe.com>

This patch adds a new constant, LNET_NET_ANY, to represent the net
ID of the LNET_NID_ANY wildcard NID.

HPE-bug-id: LUS-9122
WC-bug-id: https://jira.whamcloud.com/browse/LU-13837
Lustre-commit: 1741e993c874ed ("LU-13837 lnet: Introduce constant for net ID of LNET_NID_ANY")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/39544
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_lib.c            |  2 +-
 fs/lustre/ptlrpc/sec_config.c        | 10 +++++-----
 include/uapi/linux/lnet/lnet-types.h |  2 ++
 net/lnet/lnet/config.c               |  8 ++++----
 net/lnet/lnet/lib-move.c             |  3 +--
 net/lnet/lnet/nidstrings.c           |  2 +-
 net/lnet/lnet/peer.c                 |  2 +-
 net/lnet/lnet/router.c               |  6 +++---
 8 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_lib.c b/fs/lustre/ldlm/ldlm_lib.c
index 713ca1c..2965395 100644
--- a/fs/lustre/ldlm/ldlm_lib.c
+++ b/fs/lustre/ldlm/ldlm_lib.c
@@ -487,7 +487,7 @@ int client_obd_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 	if (lustre_cfg_buf(lcfg, 4)) {
 		u32 refnet = libcfs_str2net(lustre_cfg_string(lcfg, 4));
 
-		if (refnet == LNET_NIDNET(LNET_NID_ANY)) {
+		if (refnet == LNET_NET_ANY) {
 			rc = -EINVAL;
 			CERROR("%s: bad mount option 'network=%s': rc = %d\n",
 			       obd->obd_name, lustre_cfg_string(lcfg, 4),
diff --git a/fs/lustre/ptlrpc/sec_config.c b/fs/lustre/ptlrpc/sec_config.c
index 9ced6c7..0891f2f 100644
--- a/fs/lustre/ptlrpc/sec_config.c
+++ b/fs/lustre/ptlrpc/sec_config.c
@@ -145,7 +145,7 @@ static void get_default_flavor(struct sptlrpc_flavor *sf)
 
 static void sptlrpc_rule_init(struct sptlrpc_rule *rule)
 {
-	rule->sr_netid = LNET_NIDNET(LNET_NID_ANY);
+	rule->sr_netid = LNET_NET_ANY;
 	rule->sr_from = LUSTRE_SP_ANY;
 	rule->sr_to = LUSTRE_SP_ANY;
 	rule->sr_padding = 0;
@@ -177,7 +177,7 @@ static int sptlrpc_parse_rule(char *param, struct sptlrpc_rule *rule)
 	/* 1.1 network */
 	if (strcmp(param, "default")) {
 		rule->sr_netid = libcfs_str2net(param);
-		if (rule->sr_netid == LNET_NIDNET(LNET_NID_ANY)) {
+		if (rule->sr_netid == LNET_NET_ANY) {
 			CERROR("invalid network name: %s\n", param);
 			return -EINVAL;
 		}
@@ -263,7 +263,7 @@ static inline int rule_spec_dir(struct sptlrpc_rule *rule)
 
 static inline int rule_spec_net(struct sptlrpc_rule *rule)
 {
-	return (rule->sr_netid != LNET_NIDNET(LNET_NID_ANY));
+	return (rule->sr_netid != LNET_NET_ANY);
 }
 
 static inline int rule_match_dir(struct sptlrpc_rule *r1,
@@ -384,8 +384,8 @@ static int sptlrpc_rule_set_choose(struct sptlrpc_rule_set *rset,
 	for (n = 0; n < rset->srs_nrule; n++) {
 		r = &rset->srs_rules[n];
 
-		if (LNET_NIDNET(nid) != LNET_NIDNET(LNET_NID_ANY) &&
-		    r->sr_netid != LNET_NIDNET(LNET_NID_ANY) &&
+		if (LNET_NIDNET(nid) != LNET_NET_ANY &&
+		    r->sr_netid != LNET_NET_ANY &&
 		    LNET_NIDNET(nid) != r->sr_netid)
 			continue;
 
diff --git a/include/uapi/linux/lnet/lnet-types.h b/include/uapi/linux/lnet/lnet-types.h
index 70fab42..3324792 100644
--- a/include/uapi/linux/lnet/lnet-types.h
+++ b/include/uapi/linux/lnet/lnet-types.h
@@ -112,6 +112,8 @@ static inline __u32 LNET_MKNET(__u32 type, __u32 num)
 /** The lolnd NID (i.e. myself) */
 #define LNET_NID_LO_0 LNET_MKNID(LNET_MKNET(LOLND, 0), 0)
 
+#define LNET_NET_ANY LNET_NIDNET(LNET_NID_ANY)
+
 /* Packed version of lnet_process_id to transfer via network */
 struct lnet_process_id_packed {
 	/* node id / process id */
diff --git a/net/lnet/lnet/config.c b/net/lnet/lnet/config.c
index 6ddd9d6..b078bc8 100644
--- a/net/lnet/lnet/config.c
+++ b/net/lnet/lnet/config.c
@@ -679,7 +679,7 @@ struct lnet_ni *
 		 * At this point the name is properly terminated.
 		 */
 		net_id = libcfs_str2net(name);
-		if (net_id == LNET_NIDNET(LNET_NID_ANY)) {
+		if (net_id == LNET_NET_ANY) {
 			LCONSOLE_ERROR_MSG(0x113,
 					"Unrecognised network type\n");
 			str = name;
@@ -1169,7 +1169,7 @@ struct lnet_ni *
 
 			if (ntokens == 1) {
 				net = libcfs_str2net(ltb->ltb_text);
-				if (net == LNET_NIDNET(LNET_NID_ANY) ||
+				if (net == LNET_NET_ANY ||
 				    LNET_NETTYP(net) == LOLND)
 					goto token_error;
 			} else {
@@ -1197,7 +1197,7 @@ struct lnet_ni *
 
 	list_for_each_entry(ltb1, &nets, ltb_list) {
 		net = libcfs_str2net(ltb1->ltb_text);
-		LASSERT(net != LNET_NIDNET(LNET_NID_ANY));
+		LASSERT(net != LNET_NET_ANY);
 
 		list_for_each_entry(ltb2, &gateways, ltb_list) {
 			nid = libcfs_str2nid(ltb2->ltb_text);
@@ -1403,7 +1403,7 @@ struct lnet_ni *
 			*sep++ = 0;
 
 		net = lnet_netspec2net(tb->ltb_text);
-		if (net == LNET_NIDNET(LNET_NID_ANY)) {
+		if (net == LNET_NET_ANY) {
 			lnet_syntax("ip2nets", source, offset,
 				    strlen(tb->ltb_text));
 			return -EINVAL;
diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index 1c9fb41..4687acd 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1222,10 +1222,9 @@ void lnet_usr_translate_stats(struct lnet_ioctl_element_msg_stats *msg_stats,
 		    struct lnet_peer *peer, u32 net_id)
 {
 	struct lnet_peer_net *peer_net;
-	u32 any_net = LNET_NIDNET(LNET_NID_ANY);
 
 	/* find the best_lpni on any local network */
-	if (net_id == any_net) {
+	if (net_id == LNET_NET_ANY) {
 		struct lnet_peer_ni *best_lpni = NULL;
 		struct lnet_peer_net *lpn;
 
diff --git a/net/lnet/lnet/nidstrings.c b/net/lnet/lnet/nidstrings.c
index fb8d3e2..f260092 100644
--- a/net/lnet/lnet/nidstrings.c
+++ b/net/lnet/lnet/nidstrings.c
@@ -884,7 +884,7 @@ int cfs_print_nidlist(char *buffer, int count, struct list_head *nidlist)
 	if (libcfs_str2net_internal(str, &net))
 		return net;
 
-	return LNET_NIDNET(LNET_NID_ANY);
+	return LNET_NET_ANY;
 }
 EXPORT_SYMBOL(libcfs_str2net);
 
diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index 3889310..70df37a 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -596,7 +596,7 @@ void lnet_peer_uninit(void)
 			gw_nid = lp->lpni_peer_net->lpn_peer->lp_primary_nid;
 
 			lnet_net_unlock(LNET_LOCK_EX);
-			lnet_del_route(LNET_NIDNET(LNET_NID_ANY), gw_nid);
+			lnet_del_route(LNET_NET_ANY, gw_nid);
 			lnet_net_lock(LNET_LOCK_EX);
 		}
 	}
diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 1253e4c..e030b16 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -664,7 +664,7 @@ static void lnet_shuffle_seed(void)
 
 	if (gateway == LNET_NID_ANY ||
 	    gateway == LNET_NID_LO_0 ||
-	    net == LNET_NIDNET(LNET_NID_ANY) ||
+	    net == LNET_NET_ANY ||
 	    LNET_NETTYP(net) == LOLND ||
 	    LNET_NIDNET(gateway) == net ||
 	    (hops != LNET_UNDEFINED_HOPS && (hops < 1 || hops > 255)))
@@ -841,7 +841,7 @@ static void lnet_shuffle_seed(void)
 		lnet_peer_ni_decref_locked(lpni);
 	}
 
-	if (net != LNET_NIDNET(LNET_NID_ANY)) {
+	if (net != LNET_NET_ANY) {
 		rnet = lnet_find_rnet_locked(net);
 		if (!rnet) {
 			lnet_net_unlock(LNET_LOCK_EX);
@@ -898,7 +898,7 @@ static void lnet_shuffle_seed(void)
 void
 lnet_destroy_routes(void)
 {
-	lnet_del_route(LNET_NIDNET(LNET_NID_ANY), LNET_NID_ANY);
+	lnet_del_route(LNET_NET_ANY, LNET_NID_ANY);
 }
 
 int lnet_get_rtr_pool_cfg(int cpt, struct lnet_ioctl_pool_cfg *pool_cfg)
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
