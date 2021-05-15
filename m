Return-Path: <SRS0=EXfh=KK=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B629DC433B4
	for <lustre-devel@archiver.kernel.org>; Sat, 15 May 2021 13:06:25 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 4B92A61287
	for <lustre-devel@archiver.kernel.org>; Sat, 15 May 2021 13:06:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B92A61287
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id F02F021EBCC;
	Sat, 15 May 2021 06:06:19 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0853E21CAD2
 for <lustre-devel@lists.lustre.org>; Sat, 15 May 2021 06:06:16 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 8C74F1006C90;
 Sat, 15 May 2021 09:06:12 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 824BA64D42; Sat, 15 May 2021 09:06:12 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sat, 15 May 2021 09:06:05 -0400
Message-Id: <1621083970-32463-9-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1621083970-32463-1-git-send-email-jsimmons@infradead.org>
References: <1621083970-32463-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 08/13] lustre: ptlrpc: remove might_sleep()
 in sptlrpc_gc_del_sec()
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
Cc: Nikitas Angelinas <nikitas.angelinas@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Nikitas Angelinas <nikitas.angelinas@hpe.com>

sptlrpc_gc_del_sec() calls mutex_lock() which calls might_sleep(), so
the explicit might_sleep() call can be removed as redundant.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14628
Lustre-commit: c31fb42f9aa561ae ("LU-14628 ptlrpc: remove might_sleep() in sptlrpc_gc_del_sec()")
Signed-off-by: Nikitas Angelinas <nikitas.angelinas@hpe.com>
Reviewed-on: https://review.whamcloud.com/43397
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ptlrpc/sec_gc.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/lustre/ptlrpc/sec_gc.c b/fs/lustre/ptlrpc/sec_gc.c
index bc76323..fedcf2c 100644
--- a/fs/lustre/ptlrpc/sec_gc.c
+++ b/fs/lustre/ptlrpc/sec_gc.c
@@ -76,8 +76,6 @@ void sptlrpc_gc_del_sec(struct ptlrpc_sec *sec)
 	if (list_empty(&sec->ps_gc_list))
 		return;
 
-	might_sleep();
-
 	/* signal before list_del to make iteration in gc thread safe */
 	atomic_inc(&sec_gc_wait_del);
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
