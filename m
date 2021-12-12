Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 95DBCC433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 12 Dec 2021 15:09:08 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B989D21CBC5;
	Sun, 12 Dec 2021 07:08:23 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id EBB7721F46A
 for <lustre-devel@lists.lustre.org>; Sun, 12 Dec 2021 07:08:08 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id C56B910084F4;
 Sun, 12 Dec 2021 10:08:04 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id BC313E07E0; Sun, 12 Dec 2021 10:08:04 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 12 Dec 2021 10:08:00 -0500
Message-Id: <1639321683-22909-10-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1639321683-22909-1-git-send-email-jsimmons@infradead.org>
References: <1639321683-22909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 09/12] lustre: llite: properly detect SELinux
 disabled case
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

From: Sebastien Buisson <sbuisson@ddn.com>

Usually, security_dentry_init_security() returns -EOPNOTSUPP when
SELinux is disabled. But on some kernels it returns 0 when SELinux
is disabled, and in this case the security context is empty.
So in both cases make sure the security context name is not set, which
means "SELinux is disabled" for the rest of the code.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15184
Lustre-commit: 42661f7ba106b7d2e ("LU-15184 llite: properly detect SELinux disabled case")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/45501
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/xattr_security.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/llite/xattr_security.c b/fs/lustre/llite/xattr_security.c
index e4fb64a..f14021d 100644
--- a/fs/lustre/llite/xattr_security.c
+++ b/fs/lustre/llite/xattr_security.c
@@ -60,7 +60,13 @@ int ll_dentry_init_security(struct dentry *dentry, int mode, struct qstr *name,
 
 	rc = security_dentry_init_security(dentry, mode, name, secctx,
 					   secctx_size);
-	if (rc == -EOPNOTSUPP)
+	/* Usually, security_dentry_init_security() returns -EOPNOTSUPP when
+	 * SELinux is disabled.
+	 * But on some kernels (e.g. rhel 8.5) it returns 0 when SELinux is
+	 * disabled, and in this case the security context is empty.
+	 */
+	if (rc == -EOPNOTSUPP || (rc == 0 && *secctx_size == 0))
+		/* do nothing */
 		return 0;
 	if (rc < 0)
 		return rc;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
