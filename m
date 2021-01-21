Return-Path: <SRS0=NZgA=GY=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C52BC433DB
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:18:44 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3F13623A57
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:18:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F13623A57
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 7006821FDF1;
	Thu, 21 Jan 2021 09:18:00 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 252D521FC85
 for <lustre-devel@lists.lustre.org>; Thu, 21 Jan 2021 09:17:15 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 81E441008491;
 Thu, 21 Jan 2021 12:17:05 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 814791B49E; Thu, 21 Jan 2021 12:17:05 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 21 Jan 2021 12:16:56 -0500
Message-Id: <1611249422-556-34-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
References: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 33/39] lustre: ldlm: Use req_mode while lock
 cleanup
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
Cc: Yang Sheng <ys@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Yang Sheng <ys@whamcloud.com>

For local lock, the decref cannot count exactly by
granted_mode if the lock has not been granted.
 LustreError: (ldlm_lock.c:354:ldlm_lock_destroy_internal())
 ### lock still has references ns: ??
 lock: ffff88342aa07200/0x9b92ad3407bea22a
 lrc: 4/0,1 mode: --/PW res: ?? rrc=?? type: ???
 flags: 0x10106400000000 nid: local
 remote: 0x5248822d3123ac19 expref: -99
 pid: 14515 timeout: 0 lvb_type: 0
LustreError: (ldlm_lock.c:355:ldlm_lock_destroy_internal()) LBUG
Pid: 14562, comm: ll_imp_inval 3.10.0-693.21.1.el7.x86_64 #1 SMP
Call Trace:
[] save_stack_trace_tsk+0x22/0x40
[] libcfs_call_trace+0x8c/0xc0 [libcfs]
[] lbug_with_loc+0x4c/0xa0 [libcfs]
[] ldlm_lock_destroy_internal+0x269/0x2a0 [ptlrpc]
[] ldlm_lock_destroy_nolock+0x2b/0x110 [ptlrpc]
[] ldlm_flock_completion_ast+0x4f5/0x1080 [ptlrpc]
[] cleanup_resource+0x18e/0x370 [ptlrpc]
[] ldlm_resource_clean+0x53/0x60 [ptlrpc]
[] cfs_hash_for_each_relax+0x250/0x450 [libcfs]
[] cfs_hash_for_each_nolock+0x75/0x1c0 [libcfs]
[] ldlm_namespace_cleanup+0x30/0xc0 [ptlrpc]
[] mdc_import_event+0x1b6/0xa20 [mdc]
[] ptlrpc_invalidate_import+0x220/0x8f0 [ptlrpc]
[] ptlrpc_invalidate_import_thread+0x48/0x2b0 [ptlrpc]
[] kthread+0xd1/0xe0

WC-bug-id: https://jira.whamcloud.com/browse/LU-14082
Lustre-commit: a11c18cbab00d0 ("LU-14082 ldlm: Use req_mode while lock cleanup")
Signed-off-by: Yang Sheng <ys@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/40433
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_flock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/lustre/ldlm/ldlm_flock.c b/fs/lustre/ldlm/ldlm_flock.c
index 720362f..b4916cb15 100644
--- a/fs/lustre/ldlm/ldlm_flock.c
+++ b/fs/lustre/ldlm/ldlm_flock.c
@@ -414,7 +414,7 @@ static int ldlm_process_flock_lock(struct ldlm_lock *req)
 		if (ldlm_is_test_lock(lock) || ldlm_is_flock_deadlock(lock))
 			mode = getlk->fl_type;
 		else
-			mode = lock->l_granted_mode;
+			mode = lock->l_req_mode;
 
 		if (ldlm_is_flock_deadlock(lock)) {
 			LDLM_DEBUG(lock,
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
