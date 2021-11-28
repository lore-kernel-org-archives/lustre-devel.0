Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 6C6F4C433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 28 Nov 2021 23:28:35 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id C0E5B21C951;
	Sun, 28 Nov 2021 15:28:20 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id ED979200E02
 for <lustre-devel@lists.lustre.org>; Sun, 28 Nov 2021 15:28:00 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 995B5247;
 Sun, 28 Nov 2021 18:27:56 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 93FCCC1AF6; Sun, 28 Nov 2021 18:27:56 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 28 Nov 2021 18:27:42 -0500
Message-Id: <1638142074-5945-8-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1638142074-5945-1-git-send-email-jsimmons@infradead.org>
References: <1638142074-5945-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 07/19] lnet: o2iblnd: map_on_demand not
 needed for frag interop
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

The map_on_demand tunable is not used for setting max frags so don't
require that it be set in order to negotiate max frags.

HPE-bug-id: LUS-10488
WC-bug-id: https://jira.whamcloud.com/browse/LU-15094
Lustre-commit: 4e61a4aacdbc237606 ("LU-15094 o2iblnd: map_on_demand not needed for frag interop")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/45215
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Andriy Skulysh <andriy.skulysh@hpe.com>
Reviewed-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/klnds/o2iblnd/o2iblnd_cb.c | 16 +++-------------
 1 file changed, 3 insertions(+), 13 deletions(-)

diff --git a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
index 380374e..a053e7d 100644
--- a/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
+++ b/net/lnet/klnds/o2iblnd/o2iblnd_cb.c
@@ -2658,22 +2658,12 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		reason = "Unknown";
 		break;
 
-	case IBLND_REJECT_RDMA_FRAGS: {
-		struct lnet_ioctl_config_o2iblnd_tunables *tunables;
-
+	case IBLND_REJECT_RDMA_FRAGS:
 		if (!cp) {
 			reason = "can't negotiate max frags";
 			goto out;
 		}
-		tunables = &peer_ni->ibp_ni->ni_lnd_tunables.lnd_tun_u.lnd_o2ib;
-		/*
-		 * This check only makes sense if the kernel supports global
-		 * memory registration. Otherwise, map_on_demand will never == 0
-		 */
-		if (!tunables->lnd_map_on_demand) {
-			reason = "map_on_demand must be enabled";
-			goto out;
-		}
+
 		if (conn->ibc_max_frags <= frag_num) {
 			reason = "unsupported max frags";
 			goto out;
@@ -2682,7 +2672,7 @@ static int kiblnd_map_tx(struct lnet_ni *ni, struct kib_tx *tx,
 		peer_ni->ibp_max_frags = frag_num;
 		reason = "rdma fragments";
 		break;
-	}
+
 	case IBLND_REJECT_MSG_QUEUE_SIZE:
 		if (!cp) {
 			reason = "can't negotiate queue depth";
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
