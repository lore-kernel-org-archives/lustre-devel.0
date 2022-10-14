Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id E8A07C433FE
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Oct 2022 21:38:54 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Mq0Bk4hZDz1y2t;
	Fri, 14 Oct 2022 14:38:54 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Mq0BC3QC9z21J5
 for <lustre-devel@lists.lustre.org>; Fri, 14 Oct 2022 14:38:27 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 25D78100CA13;
 Fri, 14 Oct 2022 17:38:14 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 246B6DD53C; Fri, 14 Oct 2022 17:38:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 14 Oct 2022 17:38:08 -0400
Message-Id: <1665783491-13827-18-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
References: <1665783491-13827-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 17/20] lnet: Router test interop check and
 aarch fix
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

Enabling routing may fail on nodes with small amount of memory (like
aarch config). Define small number of router buffers to work around
this issue. Modify the functions which calculate the number of buffers
to allow small sizes to be specified via parameters.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15595
Lustre-commit: 1aba6b0d9b661d369 ("LU-15595 tests: Router test interop check and aarch fix")
Signed-off-by: Chris Horn <chris.horn@hpe.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48578
Reviewed-by: Frank Sehr <fsehr@whamcloud.com>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/router.c | 24 ++++++++++++++++++------
 1 file changed, 18 insertions(+), 6 deletions(-)

diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 5d1e5a05a9fb..ee4f1d84dc9f 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -1405,11 +1405,15 @@ lnet_nrb_tiny_calculate(void)
 		return -EINVAL;
 	}
 
-	if (tiny_router_buffers > 0)
+	if (tiny_router_buffers > 0) {
+		if (tiny_router_buffers < LNET_NRB_TINY_MIN)
+			CWARN("tiny_router_buffers=%d less than recommended minimum %d\n",
+			      tiny_router_buffers, LNET_NRB_TINY_MIN);
 		nrbs = tiny_router_buffers;
+	}
 
 	nrbs /= LNET_CPT_NUMBER;
-	return max(nrbs, LNET_NRB_TINY_MIN);
+	return max(nrbs, 1);
 }
 
 static int
@@ -1424,11 +1428,15 @@ lnet_nrb_small_calculate(void)
 		return -EINVAL;
 	}
 
-	if (small_router_buffers > 0)
+	if (small_router_buffers > 0) {
+		if (small_router_buffers < LNET_NRB_SMALL_MIN)
+			CWARN("small_router_buffers=%d less than recommended minimum %d\n",
+			      small_router_buffers, LNET_NRB_SMALL_MIN);
 		nrbs = small_router_buffers;
+	}
 
 	nrbs /= LNET_CPT_NUMBER;
-	return max(nrbs, LNET_NRB_SMALL_MIN);
+	return max(nrbs, 1);
 }
 
 static int
@@ -1443,11 +1451,15 @@ lnet_nrb_large_calculate(void)
 		return -EINVAL;
 	}
 
-	if (large_router_buffers > 0)
+	if (large_router_buffers > 0) {
+		if (large_router_buffers < LNET_NRB_LARGE_MIN)
+			CWARN("large_router_buffers=%d less than recommended minimum %d\n",
+			      large_router_buffers, LNET_NRB_LARGE_MIN);
 		nrbs = large_router_buffers;
+	}
 
 	nrbs /= LNET_CPT_NUMBER;
-	return max(nrbs, LNET_NRB_LARGE_MIN);
+	return max(nrbs, 1);
 }
 
 int
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
