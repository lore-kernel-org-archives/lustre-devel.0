Return-Path: <SRS0=Kfxm=MZ=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EDCEC4338F
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:52:16 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 5553860F36
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:52:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 5553860F36
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 3A7F6352F91;
	Mon,  2 Aug 2021 12:51:52 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 3FA04352C09
 for <lustre-devel@lists.lustre.org>; Mon,  2 Aug 2021 12:51:00 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 83E971008055;
 Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 81980C2F50; Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  2 Aug 2021 15:50:40 -0400
Message-Id: <1627933851-7603-21-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
References: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 20/25] lustre: osc: osc: Do not flush on
 lockless cancel
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

From: Patrick Farrell <pfarrell@whamcloud.com>

The cancellation of a an OSC lock without an LDLM lock
(a 'lockless' OSC lock) should not flush pages.  Only
direct i/o is allowed to use a lockless OSC lock, and
direct i/o does not create flushable pages.

DIO pages are not flushable because:
A) all synced ASAP, and
B) the OSC extents created for them are not added to the
extent tree which is used to track these pages.

Instead, this has the effect of trying to flush pages from
ongoing buffered i/o.  This can lead to crashes like the
following:

osc_cache_writeback_range()) ASSERTION(hp == 0 && discard == 0) failed

This assert essentially says the lock cancellation
(hp == 1) found an active i/o (an extent in the OES_ACTIVE
state).

This is not allowed because the flushing code assumes an
LDLM lock is being cancelled, which will only start once
there is no active i/o.  Because the OSC lock being
cancelled is not associated with an LDLM lock, this is not
true, and nothing prevents active i/o under a different
lock, leading to this assert.

The solution is simply to not flush pages when cancelling a
no-LDLM-lock OSC lock.

Additional note:
New lockless OSC locks cannot be created if they are
blocked by a regular OSC lock, but a new regular lock can
be created if there is a lockless lock present.

Thus, the sequence is something like this:
Direct i/o creates lockless OSC lock
Buffered i/o creates OSC and LDLM lock on the same range
Direct i/o finishes, starts cancelling its OSC lock
Buffered i/o is still ongoing, with extents in OES_ACTIVE

This results in the above crash during the OSC lock
cancellation.

Note it would be possible to resolve this issue by not
allowing lockless OSC locks to match regular OSC locks, but
this is not necessary, since there's no reason for lockless
locks to flush pages on cancellation.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14814
Lustre-commit: 6717c573ed90da91 ("LU-14814 osc: osc: Do not flush on lockless cancel")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/44152
Reviewed-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-by: Wang Shilong <wshilong@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/osc/osc_lock.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/fs/lustre/osc/osc_lock.c b/fs/lustre/osc/osc_lock.c
index f6faed7..eb3cb58 100644
--- a/fs/lustre/osc/osc_lock.c
+++ b/fs/lustre/osc/osc_lock.c
@@ -1134,16 +1134,8 @@ static void osc_lock_lockless_cancel(const struct lu_env *env,
 {
 	struct osc_lock *ols = cl2osc_lock(slice);
 	struct osc_object *osc = cl2osc(slice->cls_obj);
-	struct cl_lock_descr *descr = &slice->cls_lock->cll_descr;
-	int result;
 
 	LASSERT(!ols->ols_dlmlock);
-	result = osc_lock_flush(osc, descr->cld_start, descr->cld_end,
-				descr->cld_mode, false);
-	if (result)
-		CERROR("Pages for lockless lock %p were not purged(%d)\n",
-		       ols, result);
-
 	osc_lock_wake_waiters(env, osc, ols);
 }
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
