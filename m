Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 0A38EC77B70
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:14:51 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWH44TyTz1y7L;
	Sun,  9 Apr 2023 05:13:52 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWGk6w2Rz1y6W
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:13:34 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id CEAC61008270;
 Sun,  9 Apr 2023 08:13:27 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id C697A2B5; Sun,  9 Apr 2023 08:13:27 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:12:44 -0400
Message-Id: <1681042400-15491-5-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 04/40] lustre: osc: page fault in
 osc_release_bounce_pages()
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
Cc: Andriy Skulysh <andriy.skulysh@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Andriy Skulysh <andriy.skulysh@hpe.com>

pga[i] can be uninitialized. It happens after following
code path in osc_build_rpc():

	oa = kmem_cache_zalloc(osc_obdo_kmem, GFP_NOFS);
	if (!oa) {
		rc = -ENOMEM;
		goto out;
	}

Fixes: ef93d889b4c6 ("lustre: sec: encryption for write path")
HPE-bug-id: LUS-10991
WC-bug-id: https://jira.whamcloud.com/browse/LU-16333
Signed-off-by: Andriy Skulysh <andriy.skulysh@hpe.com>
Reviewed-by: Alexander Zarochentsev <alexander.zarochentsev@hpe.com>
Reviewed-by: Alexander Boyko <c17825@cray.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49210
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_request.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index bd294c5..6ea1db6 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -1463,6 +1463,9 @@ static inline void osc_release_bounce_pages(struct brw_page **pga,
 	struct page **pa = NULL;
 	int i, j = 0;
 
+	if (!pga[0])
+		return;
+
 	if (PageChecked(pga[0]->pg)) {
 		pa = kvmalloc_array(page_count, sizeof(*pa),
 				    GFP_KERNEL | __GFP_ZERO);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
