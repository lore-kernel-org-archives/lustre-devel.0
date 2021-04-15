Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42E52C433B4
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:04:21 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id EC4DE61222
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:04:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC4DE61222
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9B62F32AD54;
	Wed, 14 Apr 2021 21:03:39 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id BBAFB32F5F1
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:53 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 8AF99100F359;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 8978791890; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:16 -0400
Message-Id: <1618459361-17909-25-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 24/49] lustre: ldlm: not freed req on enqueue
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
Cc: Vitaly Fertman <c17818@cray.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Vitaly Fertman <c17818@cray.com>

ldlm_cli_enqueue may allocate a req but failed to allocate a req
slot and returns an errors without freeing the req.

Fixes: b16c40c836 ("lustre: ldlm: FLOCK request can be processed twice")
HPE-bug-id: LUS-9337
WC-bug-id: https://jira.whamcloud.com/browse/LU-12828
Lustre-commit: ce9c1c11593814da ("LU-12828 ldlm: not freed req on enqueue")
Signed-off-by: Vitaly Fertman <c17818@cray.com>
Reviewed-on: https://es-gerrit.dev.cray.com/158433
Reviewed-by: Alexander Boyko <c17825@cray.com>
Reviewed-by: Andriy Skulysh <c17819@cray.com>
Reviewed-on: https://review.whamcloud.com/41818
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Andriy Skulysh <askulysh@gmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_request.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/lustre/ldlm/ldlm_request.c b/fs/lustre/ldlm/ldlm_request.c
index 1c2ecf2..d8ca744 100644
--- a/fs/lustre/ldlm/ldlm_request.c
+++ b/fs/lustre/ldlm/ldlm_request.c
@@ -840,6 +840,8 @@ int ldlm_cli_enqueue(struct obd_export *exp, struct ptlrpc_request **reqp,
 				ptlrpc_put_mod_rpc_slot(req);
 			failed_lock_cleanup(ns, lock, einfo->ei_mode);
 			LDLM_LOCK_RELEASE(lock);
+			if (!req_passed_in)
+				ptlrpc_req_finished(req);
 			goto out;
 		}
 	}
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
