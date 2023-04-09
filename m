Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 11A39C77B61
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:41:33 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWTP3mmHz20rQ;
	Sun,  9 Apr 2023 05:22:49 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWNh2nSvz22Q5
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:18:44 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 4FB84100848C;
 Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 4C84E2B2; Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:13:10 -0400
Message-Id: <1681042400-15491-31-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 30/40] lnet: memory leak in
 copy_ioc_udsp_descr
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
Cc: Chris Horn <chris.horn@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Chris Horn <chris.horn@hpe.com>

copy_ioc_udsp_descr() doesn't correctly handle the case where a
net number was not specified. In this case, there isn't any net
number range that needs to be copied into the udsp descriptor.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16575
Lustre-commit: f8e129198b002589d ("LU-16575 lnet: memory leak in copy_ioc_udsp_descr")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50081
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Cyril Bordage <cbordage@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/udsp.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/net/lnet/lnet/udsp.c b/net/lnet/lnet/udsp.c
index 2594df1..deaca51 100644
--- a/net/lnet/lnet/udsp.c
+++ b/net/lnet/lnet/udsp.c
@@ -1485,8 +1485,19 @@ struct lnet_udsp *
 	CDEBUG(D_NET, "%u\n", nid_descr->ud_net_id.udn_net_type);
 
 	/* allocate the total memory required to copy this NID descriptor */
-	alloc_size = (sizeof(struct cfs_expr_list) * (expr_count + 1)) +
-		     (sizeof(struct cfs_range_expr) * (range_count));
+	if (ioc_nid->iud_net.ud_net_num_expr.le_count) {
+		if (ioc_nid->iud_net.ud_net_num_expr.le_count != 1) {
+			CERROR("Unexpected number of net numeric ranges \"%u\". Cannot add UDSP rule.\n",
+			       ioc_nid->iud_net.ud_net_num_expr.le_count);
+			return -EINVAL;
+		}
+		alloc_size = (sizeof(struct cfs_expr_list) * (expr_count + 1)) +
+			     (sizeof(struct cfs_range_expr) * (range_count));
+	} else {
+		alloc_size = (sizeof(struct cfs_expr_list) * (expr_count)) +
+			     (sizeof(struct cfs_range_expr) * (range_count));
+	}
+
 	buf = kzalloc(alloc_size, GFP_KERNEL);
 	if (!buf)
 		return -ENOMEM;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
