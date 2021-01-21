Return-Path: <SRS0=NZgA=GY=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 445FFC433DB
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:18:30 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7E31523A5A
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:18:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E31523A5A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 26CD321FDFF;
	Thu, 21 Jan 2021 09:17:54 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D756521FBD8
 for <lustre-devel@lists.lustre.org>; Thu, 21 Jan 2021 09:17:11 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 5BEC81008481;
 Thu, 21 Jan 2021 12:17:05 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 5B3E51B49B; Thu, 21 Jan 2021 12:17:05 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 21 Jan 2021 12:16:44 -0500
Message-Id: <1611249422-556-22-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
References: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 21/39] lustre: ldlm: osc_object_ast_clear()
 is called for mdc object on eviction
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
Cc: Andriy Skulysh <c17819@cray.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Andriy Skulysh <c17819@cray.com>

Replace osc_object_prune() with cl_object_prune()

PID: 3477   TASK: ffff9360d82fa0e0  CPU: 0   COMMAND: "ll_imp_inval"
 #0 [ffff9360d5c5b990] machine_kexec at ffffffff86865704
 #1 [ffff9360d5c5b9f0] __crash_kexec at ffffffff869209a2
 #2 [ffff9360d5c5bac0] panic at ffffffff86f7294c
 #3 [ffff9360d5c5bb40] lbug_with_loc at ffffffffc04b78cb [libcfs]
 #4 [ffff9360d5c5bb60] osc_object_ast_clear at ffffffffc0956471 [osc]
 #5 [ffff9360d5c5bbc8] ldlm_resource_foreach at ffffffffc07e2fd6 [ptlrpc]
 #6 [ffff9360d5c5bc08] ldlm_resource_iterate at ffffffffc07e3266 [ptlrpc]
 #7 [ffff9360d5c5bc38] osc_object_prune at ffffffffc0956140 [osc]
 #8 [ffff9360d5c5bc58] osc_object_invalidate at ffffffffc0956e12 [osc]
 #9 [ffff9360d5c5bcd0] osc_ldlm_resource_invalidate at ffffffffc09477bf [osc]

HPE-bug-id: LUS-8399
WC-bug-id: https://jira.whamcloud.com/browse/LU-13994
Lustre-commit: 542d0059184060 ("LU-13994 ldlm: osc_object_ast_clear() is called for mdc object on eviction")
Signed-off-by: Andriy Skulysh <c17819@cray.com>
Reviewed-on: https://review.whamcloud.com/40052
Reviewed-by: Alexander Boyko <c17825@cray.com>
Reviewed-by: Vitaly Fertman <c17818@cray.com>
Tested-by: Alexander Lezhoev <c17454@cray.com>
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Vitaly Fertman <vitaly.fertman@hpe.com>
Reviewed-by: Mike Pershin <mpershin@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_object.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/lustre/osc/osc_object.c b/fs/lustre/osc/osc_object.c
index 9a0fc54..273098a 100644
--- a/fs/lustre/osc/osc_object.c
+++ b/fs/lustre/osc/osc_object.c
@@ -493,7 +493,7 @@ int osc_object_invalidate(const struct lu_env *env, struct osc_object *osc)
 	osc_lock_discard_pages(env, osc, 0, CL_PAGE_EOF, true);
 
 	/* Clear ast data of dlm lock. Do this after discarding all pages */
-	osc_object_prune(env, osc2cl(osc));
+	cl_object_prune(env, osc2cl(osc));
 
 	return 0;
 }
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
