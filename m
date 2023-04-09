Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id C1A93C77B61
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:40:25 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWSd3qPTz22WX;
	Sun,  9 Apr 2023 05:22:09 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWP938nDz22Qt
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:19:09 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 530F2100848D;
 Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 515032B3; Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:13:11 -0400
Message-Id: <1681042400-15491-32-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 31/40] lnet: remove crash with UDSP
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

The following sequence of commands caused a crash:
  # lnetctl udsp add --dst tcp --prio 1
  # lnetctl discover 192.168.122.60@tcp
Pointer to lnet_peer_net in udsp_info is checked before used.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15944
Lustre-commit: c56b9455f05f760ae ("LU-15944 lnet: remove crash with UDSP")
Signed-off-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48801
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/udsp.c | 21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

diff --git a/net/lnet/lnet/udsp.c b/net/lnet/lnet/udsp.c
index deaca51..eb9a614 100644
--- a/net/lnet/lnet/udsp.c
+++ b/net/lnet/lnet/udsp.c
@@ -74,13 +74,17 @@
  *     from the policy list.
  *
  *   Generally, the syntax is as follows
- *     lnetctl policy <add | del | show>
- *      --src:      ip2nets syntax specifying the local NID to match
- *      --dst:      ip2nets syntax specifying the remote NID to match
- *      --rte:      ip2nets syntax specifying the router NID to match
- *      --priority: Priority to apply to rule matches
- *      --idx:      Index of where to insert or delete the rule
- *                  By default add appends to the end of the rule list
+ *     lnetctl udsp add: add a udsp
+ *      --src: ip2nets syntax specifying the local NID to match
+ *      --dst: ip2nets syntax specifying the remote NID to match
+ *      --rte: ip2nets syntax specifying the router NID to match
+ *      --priority: priority value (0 - highest priority)
+ *      --idx: index of where to insert the rule.
+ *             By default, appends to the end of the rule list.
+ *     lnetctl udsp del: delete a udsp
+ *      --idx: index of the Policy.
+ *     lnetctl udsp show: show udsps
+ *       --idx: index of the policy to show.
  *
  * Author: Amir Shehata
  */
@@ -536,7 +540,8 @@ enum udsp_apply {
 
 	/* check if looking for a net match */
 	if (!rc &&
-	    (lnet_get_list_len(&lp_match->ud_addr_range) ||
+	    (!udi->udi_lpn ||
+	     lnet_get_list_len(&lp_match->ud_addr_range) ||
 	     !cfs_match_net(udi->udi_lpn->lpn_net_id,
 			    lp_match->ud_net_id.udn_net_type,
 			    &lp_match->ud_net_id.udn_net_num_range))) {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
