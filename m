Return-Path: <SRS0=2ypu=OM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 724E7C433EF
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:20:11 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 83FA56112F
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:20:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 83FA56112F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id AC31C21F176;
	Tue, 21 Sep 2021 19:20:08 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B8F4521CB9F
 for <lustre-devel@lists.lustre.org>; Tue, 21 Sep 2021 19:20:05 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 03ABB34E;
 Tue, 21 Sep 2021 22:20:03 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id EE6ECFF4BC; Tue, 21 Sep 2021 22:20:03 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Tue, 21 Sep 2021 22:19:39 -0400
Message-Id: <1632277201-6920-3-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
References: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 02/24] lustre: quota: enforce block quota for
 chgrp
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
Cc: Hongchao Zhang <hongchao@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Hongchao Zhang <hongchao@whamcloud.com>

In patch https://review.whamcloud.com/30146 "LU-5152 quota: enforce
block quota for chgrp", problems were introduced due to synchronous
requests from the MDS to the OSS to change the quota assignment of
files during chgrp operations. However, in some cases, the OSTs are
themselves out of grant and may send a quota request to the MDS,
which may result in a deadlock. Another issue is the slow performance
caused by the synchronous operation between MDT and OSTs.

This patch drops the synchronous RPC requirement of the original
patch #30146 to avoid this problem.

Previously, problems in quota tracking related to chgrp were introduced
due to synchronous RPCs from the MDS to the OSS when changing the group
ownership of objects for quota tracking since
Fixes: ("LU-5152 quota: enforce block quota for chgrp")

WC-bug-id: https://jira.whamcloud.com/browse/LU-11303
Lustre-commit: 83f5544d8518ad12 ("LU-11303 quota: enforce block quota for chgrp")
Signed-off-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33996
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Wang Shilong <wangshilong1991@gmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_lib.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index f540caf..cc50503 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1714,6 +1714,16 @@ static int ll_md_setattr(struct dentry *dentry, struct md_op_data *op_data)
 	if (IS_ERR(op_data))
 		return PTR_ERR(op_data);
 
+	/* If this is a chgrp of a regular file, we want to reserve enough
+	 * quota to cover the entire file size.
+	 */
+	if (S_ISREG(inode->i_mode) && op_data->op_attr.ia_valid & ATTR_GID &&
+	    from_kgid(&init_user_ns, op_data->op_attr.ia_gid) !=
+	    from_kgid(&init_user_ns, inode->i_gid)) {
+		op_data->op_xvalid |= OP_XVALID_BLOCKS;
+		op_data->op_attr_blocks = inode->i_blocks;
+	}
+
 	rc = md_setattr(sbi->ll_md_exp, op_data, NULL, 0, &request);
 	if (rc) {
 		ptlrpc_req_finished(request);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
