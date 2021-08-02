Return-Path: <SRS0=Kfxm=MZ=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86FCFC4338F
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:54:20 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 4B88260F36
	for <lustre-devel@archiver.kernel.org>; Mon,  2 Aug 2021 19:54:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 4B88260F36
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B3DBD34FCF1;
	Mon,  2 Aug 2021 12:54:18 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4A36635286A
 for <lustre-devel@lists.lustre.org>; Mon,  2 Aug 2021 12:50:55 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 516861007A8E;
 Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 48919C2F50; Mon,  2 Aug 2021 15:50:53 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  2 Aug 2021 15:50:22 -0400
Message-Id: <1627933851-7603-3-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
References: <1627933851-7603-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 02/25] lustre: llite: No locked parallel DIO
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

If we are doing locked DIO, the OSC & LDLM locks are
released at the end of cl_io_loop, ie, before we wait for
parallel DIO at the llite layer.

This is problematic because the locks are released before
i/o done using them is complete; this can lead to data
inconsistencies.  (And at least one LBUG, see LU-14805.)

The easiest solution for now is only do parallel DIO when
working lockless (which is the default; DIO only switches
to locked to manage conflicts with buffered i/o).

This problem & fix apply to AIO as well as parallel DIO.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14805
Lustre-commit: 0f8db7e06abbc341 ("LU-14805 llite: No locked parallel DIO")
Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/44131
Reviewed-by: Wang Shilong <wshilong@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/rw26.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index ba9c070..0d72c3e 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -410,10 +410,19 @@ static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 	else
 		vio->u.readwrite.vui_read += tot_bytes;
 
-	/* If async dio submission is not allowed, we must wait here. */
-	if (is_sync_kiocb(iocb) && !io->ci_parallel_dio) {
+	/* We cannot do async submission - for AIO or regular DIO - unless
+	 * lockless because it causes us to release the lock early.
+	 *
+	 * There are also several circumstances in which we must disable
+	 * parallel DIO, so we check if it is enabled.
+	 *
+	 * The check for "is_sync_kiocb" excludes AIO, which does not need to
+	 * be disabled in these situations.
+	 */
+	if (io->ci_dio_lock || (is_sync_kiocb(iocb) && !io->ci_parallel_dio)) {
 		ssize_t rc2;
 
+		/* Wait here rather than doing async submission */
 		rc2 = cl_sync_io_wait_recycle(env, &aio->cda_sync, 0, 0);
 		if (result == 0 && rc2)
 			result = rc2;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
