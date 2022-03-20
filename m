Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id DDC7DC433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:33:22 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 819DD21FA50;
	Sun, 20 Mar 2022 06:32:19 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 52A1F21CABE
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:21 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 8E5871027;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 8B03FAB; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:58 -0400
Message-Id: <1647783064-20688-45-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 44/50] lnet: lnet_peer_data_present() memory
 leak
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

If the ping buffer has nnis <= 1 then the ref on the ping buffer does
not get dropped. This causes a memory leak.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15440
Lustre-commit: 56384a4fc39ff99c8 ("U-15440 lnet: lnet_peer_data_present() memory leak")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/46052
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Andriy Skulysh <andriy.skulysh@hpe.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/peer.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/lnet/lnet/peer.c b/net/lnet/lnet/peer.c
index f70ceb5..16a694c 100644
--- a/net/lnet/lnet/peer.c
+++ b/net/lnet/lnet/peer.c
@@ -3344,8 +3344,10 @@ static int lnet_peer_data_present(struct lnet_peer *lp)
 	 * primary NID to the correct value here. Moreover, this peer
 	 * can show up with only the loopback NID in the ping buffer.
 	 */
-	if (pbuf->pb_info.pi_nnis <= 1)
+	if (pbuf->pb_info.pi_nnis <= 1) {
+		lnet_ping_buffer_decref(pbuf);
 		goto out;
+	}
 	nid = pbuf->pb_info.pi_ni[1].ns_nid;
 	if (nid_is_lo0(&lp->lp_primary_nid)) {
 		rc = lnet_peer_set_primary_nid(lp, nid, flags);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
