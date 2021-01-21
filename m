Return-Path: <SRS0=NZgA=GY=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A07CC433E0
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:18:01 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id B887E23A5A
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:18:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B887E23A5A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id C5F5021FDCF;
	Thu, 21 Jan 2021 09:17:40 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B0C4421FB64
 for <lustre-devel@lists.lustre.org>; Thu, 21 Jan 2021 09:17:09 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 441E21008055;
 Thu, 21 Jan 2021 12:17:05 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 426EDF0A5; Thu, 21 Jan 2021 12:17:05 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 21 Jan 2021 12:16:36 -0500
Message-Id: <1611249422-556-14-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
References: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 13/39] lustre: llite: allow DIO with
 unaligned IO count
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
Cc: Wang Shilong <wshilong@ddn.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Wang Shilong <wshilong@ddn.com>

DIO only require user buffer page aligned and
IO offset page aligned, it is ok that io count is
not page aligned, remove this unnecessary limit
so that we could use DIO with file not aligned
with PAGE SIZE.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14043
Lustre-commit: 45c46c6effd827 ("LU-14043 llite: allow DIO with unaligned IO count")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/40392
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/rw26.c | 33 +++++++++++++++++++++++++++++++--
 1 file changed, 31 insertions(+), 2 deletions(-)

diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index 605a326..28c0a75 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -181,6 +181,35 @@ static ssize_t ll_get_user_pages(int rw, struct iov_iter *iter,
 	return result;
 }
 
+/*
+ * Lustre could relax a bit for alignment, io count is not
+ * necessary page alignment.
+ */
+static unsigned long ll_iov_iter_alignment(struct iov_iter *i)
+{
+	size_t orig_size = i->count;
+	size_t count = orig_size & ~PAGE_MASK;
+	unsigned long res;
+
+	if (!count)
+		return iov_iter_alignment(i);
+
+	if (orig_size > PAGE_SIZE) {
+		iov_iter_truncate(i, orig_size - count);
+		res = iov_iter_alignment(i);
+		iov_iter_reexpand(i, orig_size);
+
+		return res;
+	}
+
+	res = iov_iter_alignment(i);
+	/* start address is page aligned */
+	if ((res & ~PAGE_MASK) == orig_size)
+		return PAGE_SIZE;
+
+	return res;
+}
+
 /* direct IO pages */
 struct ll_dio_pages {
 	struct cl_dio_aio	*ldp_aio;
@@ -325,7 +354,7 @@ static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 		return 0;
 
 	/* FIXME: io smaller than PAGE_SIZE is broken on ia64 ??? */
-	if ((file_offset & ~PAGE_MASK) || (count & ~PAGE_MASK))
+	if (file_offset & ~PAGE_MASK)
 		return -EINVAL;
 
 	CDEBUG(D_VFSTRACE,
@@ -335,7 +364,7 @@ static ssize_t ll_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
 	       MAX_DIO_SIZE >> PAGE_SHIFT);
 
 	/* Check that all user buffers are aligned as well */
-	if (iov_iter_alignment(iter) & ~PAGE_MASK)
+	if (ll_iov_iter_alignment(iter) & ~PAGE_MASK)
 		return -EINVAL;
 
 	lcc = ll_cl_find(file);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
