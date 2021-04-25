Return-Path: <SRS0=Gt0B=JW=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66A28C433ED
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:10:02 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 27811611CC
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:10:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27811611CC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 7B1BD21F87E;
	Sun, 25 Apr 2021 13:09:30 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id AC48721F7CA
 for <lustre-devel@lists.lustre.org>; Sun, 25 Apr 2021 13:08:47 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 3C2E910087D1;
 Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 3AC8969A7D; Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 25 Apr 2021 16:08:29 -0400
Message-Id: <1619381316-7719-23-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
References: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 22/29] lustre: osc: fall back to vmalloc for
 large RPCs
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

For large RPC sizes (16MB+) the page array (4096 brw_page) can
become very large (128KB+ with fscrypt) and should fall back to
vmalloc() if kmalloc() fails due to memory fragmentation.

The mdc/mdt allocations are currently limited to 1MB for readdir
RPCs, but it doesn't hurt to prepare them for larger RPCs from
clients in the future if this limit is increased.

Fixes: 5965de814e91 ("staging: lustre: rpc: increase bulk size")
WC-bug-id: https://jira.whamcloud.com/browse/LU-13212
Lustre-commit: 037a9e2cf6d5b8d6f ("LU-13212 osc: fall back to vmalloc for large RPCs")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/43281
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Wang Shilong <wshilong@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/mdc/mdc_request.c     | 5 +++--
 fs/lustre/mgc/mgc_request.c     | 5 +++--
 fs/lustre/obdecho/echo_client.c | 5 +++--
 fs/lustre/osc/osc_request.c     | 5 +++--
 4 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 6ac3a39..fb9971f 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -1312,7 +1312,8 @@ static int mdc_read_page_remote(void *data, struct page *page0)
 	fid = &op_data->op_fid1;
 	LASSERT(inode);
 
-	page_pool = kcalloc(max_pages, sizeof(page), GFP_NOFS);
+	page_pool = kvmalloc_array(max_pages, sizeof(page),
+				   GFP_KERNEL | __GFP_ZERO);
 	if (page_pool) {
 		page_pool[0] = page0;
 	} else {
@@ -1381,7 +1382,7 @@ static int mdc_read_page_remote(void *data, struct page *page0)
 	}
 
 	if (page_pool != &page0)
-		kfree(page_pool);
+		kvfree(page_pool);
 
 	return rc;
 }
diff --git a/fs/lustre/mgc/mgc_request.c b/fs/lustre/mgc/mgc_request.c
index f115479..4b60056a 100644
--- a/fs/lustre/mgc/mgc_request.c
+++ b/fs/lustre/mgc/mgc_request.c
@@ -1350,7 +1350,8 @@ static int mgc_process_recover_log(struct obd_device *obd,
 	if (cfg->cfg_last_idx == 0) /* the first time */
 		nrpages = CONFIG_READ_NRPAGES_INIT;
 
-	pages = kcalloc(nrpages, sizeof(*pages), GFP_KERNEL);
+	pages = kvmalloc_array(nrpages, sizeof(*pages),
+			       GFP_KERNEL | __GFP_ZERO);
 	if (!pages) {
 		rc = -ENOMEM;
 		goto out;
@@ -1474,7 +1475,7 @@ static int mgc_process_recover_log(struct obd_device *obd,
 				break;
 			__free_page(pages[i]);
 		}
-		kfree(pages);
+		kvfree(pages);
 	}
 	return rc;
 }
diff --git a/fs/lustre/obdecho/echo_client.c b/fs/lustre/obdecho/echo_client.c
index 3bee0c2..270226b 100644
--- a/fs/lustre/obdecho/echo_client.c
+++ b/fs/lustre/obdecho/echo_client.c
@@ -1302,7 +1302,8 @@ static int echo_client_kbrw(struct echo_device *ed, int rw, struct obdo *oa,
 	if (!pga)
 		return -ENOMEM;
 
-	pages = kcalloc(npages, sizeof(*pages), GFP_NOFS);
+	pages = kvmalloc_array(npages, sizeof(*pages),
+			       GFP_KERNEL | __GFP_ZERO);
 	if (!pages) {
 		kfree(pga);
 		return -ENOMEM;
@@ -1355,7 +1356,7 @@ static int echo_client_kbrw(struct echo_device *ed, int rw, struct obdo *oa,
 		__free_page(pgp->pg);
 	}
 	kfree(pga);
-	kfree(pages);
+	kvfree(pages);
 	return rc;
 }
 
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 1bd0d2c..973c504 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -2323,7 +2323,7 @@ static void sort_brw_pages(struct brw_page **array, int num)
 static void osc_release_ppga(struct brw_page **ppga, u32 count)
 {
 	LASSERT(ppga);
-	kfree(ppga);
+	kvfree(ppga);
 }
 
 static int brw_interpret(const struct lu_env *env,
@@ -2523,7 +2523,8 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	if (mem_tight)
 		mpflag = memalloc_noreclaim_save();
 
-	pga = kcalloc(page_count, sizeof(*pga), GFP_NOFS);
+	pga = kvmalloc_array(page_count, sizeof(*pga),
+			     GFP_KERNEL | __GFP_ZERO);
 	if (!pga) {
 		rc = -ENOMEM;
 		goto out;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
