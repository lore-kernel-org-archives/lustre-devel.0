Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 69EA7C433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 12 Dec 2021 15:08:59 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id C29AB21E07C;
	Sun, 12 Dec 2021 07:08:20 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 7C40721F46A
 for <lustre-devel@lists.lustre.org>; Sun, 12 Dec 2021 07:08:08 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id C33A110084E6;
 Sun, 12 Dec 2021 10:08:04 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id B52BBE0811; Sun, 12 Dec 2021 10:08:04 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 12 Dec 2021 10:07:58 -0500
Message-Id: <1639321683-22909-8-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1639321683-22909-1-git-send-email-jsimmons@infradead.org>
References: <1639321683-22909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 07/12] lnet: Fix source specified to routed
 destination
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

If a source NI is specified for a send then we should not modify the
destination NID that was passed to lnet_send().

HPE-bug-id: LUS-10301
WC-bug-id: https://jira.whamcloud.com/browse/LU-14941
Lustre-commit: 98da4ace43a6c4c59 ("LU-14941 lnet: Fix source specified to routed destination")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/44730
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/lib-move.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/lnet/lnet/lib-move.c b/net/lnet/lnet/lib-move.c
index a411724..caffa30 100644
--- a/net/lnet/lnet/lib-move.c
+++ b/net/lnet/lnet/lib-move.c
@@ -1989,13 +1989,19 @@ struct lnet_ni *
 	}
 
 	if (!route_found) {
-		if (sd->sd_msg->msg_routing) {
+		if (sd->sd_msg->msg_routing || src_nid != LNET_NID_ANY) {
 			/* If I'm routing this message then I need to find the
 			 * next hop based on the destination NID
+			 *
+			 * We also find next hop based on the destination NID
+			 * if the source NI was specified
 			 */
 			best_rnet = lnet_find_rnet_locked(LNET_NIDNET(sd->sd_dst_nid));
 			if (!best_rnet) {
-				CERROR("Unable to route message to %s - Route table may be misconfigured\n",
+				CERROR("Unable to send message from %s to %s - Route table may be misconfigured\n",
+				       src_nid != LNET_NID_ANY ?
+						libcfs_nid2str(src_nid) :
+						"any local NI",
 				       libcfs_nid2str(sd->sd_dst_nid));
 				return -EHOSTUNREACH;
 			}
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
