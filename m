Return-Path: <SRS0=Xi2l=P3=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B41DC433F5
	for <lustre-devel@archiver.kernel.org>; Mon,  8 Nov 2021 15:08:40 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id DDD776105A
	for <lustre-devel@archiver.kernel.org>; Mon,  8 Nov 2021 15:08:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org DDD776105A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 869D921CA71;
	Mon,  8 Nov 2021 07:08:23 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (SMTP3.CCS.ORNL.GOV [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 5890F21C967
 for <lustre-devel@lists.lustre.org>; Mon,  8 Nov 2021 07:07:49 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 1D9F82225;
 Mon,  8 Nov 2021 10:07:46 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 144FDE0816; Mon,  8 Nov 2021 10:07:46 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  8 Nov 2021 10:07:34 -0500
Message-Id: <1636384063-13838-7-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1636384063-13838-1-git-send-email-jsimmons@infradead.org>
References: <1636384063-13838-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 06/15] lnet: don't retry allocating router
 buffers
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

From: Andreas Dilger <adilger@whamcloud.com>

Don't loop indefinitely trying to allocate router buffer pools if
the number of requested buffers is too large for the system.

WC-bug-id: https://jira.whamcloud.com/browse/LU-2084
Lustre-commit: 3038917f12a53b059 ("LU-2084 lnet: don't retry allocating router buffers")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/45174
Reviewed-by: Serguei Smirnov <ssmirnov@whamcloud.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 net/lnet/lnet/router.c | 26 ++++++++++++++++----------
 1 file changed, 16 insertions(+), 10 deletions(-)

diff --git a/net/lnet/lnet/router.c b/net/lnet/lnet/router.c
index 6cfcead..7ce33eb 100644
--- a/net/lnet/lnet/router.c
+++ b/net/lnet/lnet/router.c
@@ -1245,18 +1245,19 @@ bool lnet_router_checker_active(void)
 	int sz = offsetof(struct lnet_rtrbuf, rb_kiov[npages]);
 	struct page *page;
 	struct lnet_rtrbuf *rb;
-	int i;
+	int i, node;
 
 	rb = kzalloc_cpt(sz, GFP_NOFS, cpt);
 	if (!rb)
 		return NULL;
 
+	node = cfs_cpt_spread_node(lnet_cpt_table(), cpt);
 	rb->rb_pool = rbp;
 
 	for (i = 0; i < npages; i++) {
-		page = alloc_pages_node(
-				cfs_cpt_spread_node(lnet_cpt_table(), cpt),
-				GFP_KERNEL | __GFP_ZERO, 0);
+		page = alloc_pages_node(node,
+					GFP_KERNEL | __GFP_ZERO | __GFP_NORETRY,
+					0);
 		if (!page) {
 			while (--i >= 0)
 				__free_page(rb->rb_kiov[i].bv_page);
@@ -1344,8 +1345,8 @@ bool lnet_router_checker_active(void)
 	while (num_rb-- > 0) {
 		rb = lnet_new_rtrbuf(rbp, cpt);
 		if (!rb) {
-			CERROR("Failed to allocate %d route bufs of %d pages\n",
-			       nbufs, npages);
+			CERROR("lnet: error allocating %ux%u page router buffers on CPT %u: rc = %d\n",
+			       nbufs, npages, cpt, -ENOMEM);
 
 			lnet_net_lock(cpt);
 			rbp->rbp_req_nbuffers = old_req_nbufs;
@@ -1496,8 +1497,11 @@ bool lnet_router_checker_active(void)
 	} else if (!strcmp(forwarding, "enabled")) {
 		/* explicitly enabled */
 	} else {
-		LCONSOLE_ERROR_MSG(0x10b, "'forwarding' not set to either 'enabled' or 'disabled'\n");
-		return -EINVAL;
+		rc = -EINVAL;
+		LCONSOLE_ERROR_MSG(0x10b,
+				   "lnet: forwarding='%s' not set to either 'enabled' or 'disabled': rc = %d\n",
+				   forwarding, rc);
+		return rc;
 	}
 
 	nrb_tiny = lnet_nrb_tiny_calculate();
@@ -1516,9 +1520,11 @@ bool lnet_router_checker_active(void)
 						LNET_NRBPOOLS *
 						sizeof(*the_lnet.ln_rtrpools[0]));
 	if (!the_lnet.ln_rtrpools) {
+		rc = -ENOMEM;
 		LCONSOLE_ERROR_MSG(0x10c,
-				   "Failed to initialize router buffe pool\n");
-		return -ENOMEM;
+			"lnet: error allocating router buffer pool: rc = %d\n",
+			rc);
+		return rc;
 	}
 
 	cfs_percpt_for_each(rtrp, i, the_lnet.ln_rtrpools) {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
