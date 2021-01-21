Return-Path: <SRS0=NZgA=GY=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10493C433DB
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:18:08 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 95A0523A5A
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:18:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95A0523A5A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id EDBCF21FB9F;
	Thu, 21 Jan 2021 09:17:43 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 7D0F921FC4B
 for <lustre-devel@lists.lustre.org>; Thu, 21 Jan 2021 09:17:13 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 6F636100848B;
 Thu, 21 Jan 2021 12:17:05 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 6E0E71B49D; Thu, 21 Jan 2021 12:17:05 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 21 Jan 2021 12:16:50 -0500
Message-Id: <1611249422-556-28-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
References: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 27/39] lustre: lov: instantiate components
 layout for fallocate
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

fallocate() need send intent lock to MDS to instantiate layout
like PFL.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14186
Lustre-commit: 7e25e6c7d0a710 ("LU-14186 lov: instantiate components layout for fallocate")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/40885
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Yingjin Qian <qian@ddn.com>
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/vvp_io.c | 2 +-
 fs/lustre/lov/lov_io.c   | 1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index 8dbe835..b0b31c37 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -361,7 +361,7 @@ static void vvp_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 
 		io->ci_need_write_intent = 0;
 
-		LASSERT(io->ci_type == CIT_WRITE ||
+		LASSERT(io->ci_type == CIT_WRITE || cl_io_is_fallocate(io) ||
 			cl_io_is_trunc(io) || cl_io_is_mkwrite(io));
 
 		CDEBUG(D_VFSTRACE, DFID" write layout, type %u " DEXT "\n",
diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index ac88a55..d4a0c9d 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -571,6 +571,7 @@ static int lov_io_slice_init(struct lov_io *lio, struct lov_object *obj,
 
 	/* check if it needs to instantiate layout */
 	if (!(io->ci_type == CIT_WRITE || cl_io_is_mkwrite(io) ||
+	      cl_io_is_fallocate(io) ||
 	      (cl_io_is_trunc(io) && io->u.ci_setattr.sa_attr.lvb_size > 0))) {
 		result = 0;
 		goto out;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
