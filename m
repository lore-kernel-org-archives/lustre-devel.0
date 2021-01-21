Return-Path: <SRS0=NZgA=GY=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06EE3C433DB
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:17:55 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A2E3123A5A
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:17:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A2E3123A5A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B184D21FE0F;
	Thu, 21 Jan 2021 09:17:37 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2E56421FA40
 for <lustre-devel@lists.lustre.org>; Thu, 21 Jan 2021 09:17:08 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 34766100804F;
 Thu, 21 Jan 2021 12:17:05 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 2F921F0A7; Thu, 21 Jan 2021 12:17:05 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 21 Jan 2021 12:16:30 -0500
Message-Id: <1611249422-556-8-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
References: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 07/39] lustre: ldlm: Don't re-enqueue glimpse
 lock on read
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

cl_glimpse_lock() doesn't match a lock with LDLM_FL_BL_AST
even if this lock is acquired by the same thread earlier.

It needs only size to check for spare file,
so let't add LDLM_FL_CBPENDING to match flags.

 #1 [ffff9ba7326036f0] schedule at ffffffff87b67c49
 #2 [ffff9ba732603700] obd_get_request_slot at ffffffffc0dbe0a4 [obdclass]
 #3 [ffff9ba7326037b8] ldlm_cli_enqueue at ffffffffc0faedce [ptlrpc]
 #4 [ffff9ba732603878] mdc_enqueue_send at ffffffffc11b38a8 [mdc]
 #5 [ffff9ba732603938] mdc_lock_enqueue at ffffffffc11b3eb2 [mdc]
 #6 [ffff9ba7326039a8] cl_lock_enqueue at ffffffffc0dfee95 [obdclass]
 #7 [ffff9ba7326039e0] lov_lock_enqueue at ffffffffc10ef265 [lov]
 #8 [ffff9ba732603a20] cl_lock_enqueue at ffffffffc0dfee95 [obdclass]
 #9 [ffff9ba732603a58] cl_lock_request at ffffffffc0dff54b [obdclass]

HPE-bug-id: LUS-8690
WC-bug-id: https://jira.whamcloud.com/browse/LU-13987
Lustre-commit: 829a3a93d43e4d ("LU-13987 ldlm: Don't re-enqueue glimpse lock on read")
Reviewed-on: https://review.whamcloud.com/40044
Signed-off-by: Andriy Skulysh <c17819@cray.com>
Reviewed-by: Vitaly Fertman <c17818@cray.com>
Reviewed-by: Alexander Boyko <c17825@cray.com>
Reviewed-by: Andrew Perepechko <c17827@cray.com>
Tested-by: Elena Gryaznova <c17455@cray.com>
Reviewed-by: Alexander Boyko <alexander.boyko@hpe.com>
Reviewed-by: Vitaly Fertman <vitaly.fertman@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_osc.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/lustre/include/lustre_osc.h b/fs/lustre/include/lustre_osc.h
index e7bf392..e32723c 100644
--- a/fs/lustre/include/lustre_osc.h
+++ b/fs/lustre/include/lustre_osc.h
@@ -203,7 +203,7 @@ static inline u64 osc_enq2ldlm_flags(u32 enqflags)
 	if (enqflags & CEF_NONBLOCK)
 		result |= LDLM_FL_BLOCK_NOWAIT;
 	if (enqflags & CEF_GLIMPSE)
-		result |= LDLM_FL_HAS_INTENT;
+		result |= LDLM_FL_HAS_INTENT | LDLM_FL_CBPENDING;
 	if (enqflags & CEF_DISCARD_DATA)
 		result |= LDLM_FL_AST_DISCARD_DATA;
 	if (enqflags & CEF_PEEK)
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
