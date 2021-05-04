Return-Path: <SRS0=WSMT=J7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 975D1C433B4
	for <lustre-devel@archiver.kernel.org>; Tue,  4 May 2021 00:10:32 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id ECD1E610E6
	for <lustre-devel@archiver.kernel.org>; Tue,  4 May 2021 00:10:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ECD1E610E6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 4EA5821F434;
	Mon,  3 May 2021 17:10:28 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0049E21F3B4
 for <lustre-devel@lists.lustre.org>; Mon,  3 May 2021 17:10:21 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 1A404EDB;
 Mon,  3 May 2021 20:10:20 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 10B428AD3C; Mon,  3 May 2021 20:10:20 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon,  3 May 2021 20:10:03 -0400
Message-Id: <1620087016-17857-2-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1620087016-17857-1-git-send-email-jsimmons@infradead.org>
References: <1620087016-17857-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 01/14] lustre: llite: Remove last lockahead
 old compat
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
Cc: Patrick Farrell <farr0186@gmail.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Patrick Farrell <farr0186@gmail.com>

The CEF_NONBLOCK flag in cld_enq_flags is required for the
old Cray-only server release of lockahead.  In the more
recent versions, the required nonblocking behavior (on the
server side) is associated with LDLM_FL_SPECULATIVE, not
with the combination of LDLM_FL_NO_EXPAND and
LDLM_FL_BLOCK_NOWAIT (as was done in the old
implementation).

Now we control 'speculative' or not with the async flag
from userspace.

Now that we've removed OBD_CONNECT_LOCKAHEAD_OLD support
from the client, we should be good to go there.

The existing testing explores both sync and async requests,
and should be enough to verify this is OK.

WC-bug-id: https://jira.whamcloud.com/browse/LU-6179
Lustre-commit: 12a0c7b5944d9e48 ("LU-6179 llite: Remove last lockahead old compat")
Signed-off-by: Patrick Farrell <farr0186@gmail.com>
Reviewed-on: https://review.whamcloud.com/38179
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 1561af1..346e31c 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -3033,8 +3033,7 @@ int ll_file_lock_ahead(struct file *file, struct llapi_lu_ladvise *ladvise)
 		/* CEF_MUST is used because we do not want to convert a
 		 * lockahead request to a lockless lock
 		 */
-		descr->cld_enq_flags = CEF_MUST | CEF_LOCK_NO_EXPAND |
-				       CEF_NONBLOCK;
+		descr->cld_enq_flags = CEF_MUST | CEF_LOCK_NO_EXPAND;
 
 		if (ladvise->lla_peradvice_flags & LF_ASYNC)
 			descr->cld_enq_flags |= CEF_SPECULATIVE;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
