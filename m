Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-21.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21DB9C433ED
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:53:31 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id CF27D6112E
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:53:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF27D6112E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A8A4C328F5F;
	Mon,  5 Apr 2021 00:52:48 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1829F21F6C6
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:29 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 34F40EC9;
 Sun,  4 Apr 2021 20:51:17 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 32DA790AA9; Sun,  4 Apr 2021 20:51:17 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:51:09 -0400
Message-Id: <1617583870-32029-41-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
References: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 40/41] lnet: discard LNET_MD_PHYS
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

From: Mr NeilBrown <neilb@suse.de>

This macro has no value and is never set.
It claims "compatibility with Cray Portals", yet cray-dvs
   git://github.com/glennklockwood/cray-dvs.git
does not use it in any non-trivial way.

Much has changed in lnet and lib-md since 2007 when this
value was added - it seems likely that this really
is dead.

So remove it.  If/when this results in problems, it can
easily be re-added and more details can be provided at
that time.

WC-bug-id: https://jira.whamcloud.com/browse/LU-12678
Lustre-commit: aa57e829867caa9 ("LU-12678 lnet: discard LNET_MD_PHYS")
Signed-off-by: Mr NeilBrown <neilb@suse.de>
Reviewed-on: https://review.whamcloud.com/39301
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Alexey Lyashkov <alexey.lyashkov@hpe.com>
Reviewed-by: Chris Horn <chris.horn@hpe.com>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/pers.c              | 1 -
 include/uapi/linux/lnet/lnet-types.h | 3 ---
 2 files changed, 4 deletions(-)

diff --git a/fs/lustre/ptlrpc/pers.c b/fs/lustre/ptlrpc/pers.c
index ecbc9d3..78b8ce2 100644
--- a/fs/lustre/ptlrpc/pers.c
+++ b/fs/lustre/ptlrpc/pers.c
@@ -50,7 +50,6 @@ void ptlrpc_fill_bulk_md(struct lnet_md *md, struct ptlrpc_bulk_desc *desc,
 
 	LASSERT(mdidx < desc->bd_md_max_brw);
 	LASSERT(desc->bd_iov_count <= PTLRPC_MAX_BRW_PAGES);
-	LASSERT(!(md->options & (LNET_MD_KIOV | LNET_MD_PHYS)));
 
 	/* just send a lnet header */
 	if (mdidx >= desc->bd_md_count) {
diff --git a/include/uapi/linux/lnet/lnet-types.h b/include/uapi/linux/lnet/lnet-types.h
index 4d0b6f9..43800ae 100644
--- a/include/uapi/linux/lnet/lnet-types.h
+++ b/include/uapi/linux/lnet/lnet-types.h
@@ -357,9 +357,6 @@ struct lnet_md {
 /** See struct lnet_md::options. */
 #define LNET_MD_NO_TRACK_RESPONSE	(1 << 11)
 
-/* For compatibility with Cray Portals */
-#define LNET_MD_PHYS		0
-
 /** Infinite threshold on MD operations. See lnet_md::threshold */
 #define LNET_MD_THRESH_INF	(-1)
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
