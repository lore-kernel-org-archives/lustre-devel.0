Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 3DDBFC19F29
	for <lustre-devel@archiver.kernel.org>; Thu,  4 Aug 2022 01:38:57 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Lyrww6C0fz23Jh;
	Wed,  3 Aug 2022 18:38:56 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4LyrwT4sKQz23JB
 for <lustre-devel@lists.lustre.org>; Wed,  3 Aug 2022 18:38:33 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id BFB60100B000;
 Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id BE2E380795; Wed,  3 Aug 2022 21:38:23 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed,  3 Aug 2022 21:37:56 -0400
Message-Id: <1659577097-19253-12-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
References: <1659577097-19253-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 11/32] lustre: som: disabling xattr cache for
 LSOM on client
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
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

From: Qian Yingjin <qian@ddn.com>

To obtain uptodate LSOM data, currently a client needs to set
llite.*.xattr_cache =0 to disable the xattr cache on client
completely. This leads that other kinds of xattr can not be cached
on the client too.
This patch introduces a heavy-weight solution to disable caching
only for LSOM xattr data ("trusted.som") on client.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11695
Lustre-commit: 192902851d73ec246 ("LU-11695 som: disabling xattr cache for LSOM on client")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/33711
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/xattr.c       | 3 ++-
 fs/lustre/llite/xattr_cache.c | 4 ++++
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/llite/xattr.c b/fs/lustre/llite/xattr.c
index 3a342ad..11310f9 100644
--- a/fs/lustre/llite/xattr.c
+++ b/fs/lustre/llite/xattr.c
@@ -373,7 +373,8 @@ int ll_xattr_list(struct inode *inode, const char *name, int type, void *buffer,
 	}
 
 	if (sbi->ll_xattr_cache_enabled && type != XATTR_ACL_ACCESS_T &&
-	    (type != XATTR_SECURITY_T || strcmp(name, "security.selinux"))) {
+	    (type != XATTR_SECURITY_T || strcmp(name, "security.selinux")) &&
+	    (type != XATTR_TRUSTED_T || strcmp(name, XATTR_NAME_SOM))) {
 		rc = ll_xattr_cache_get(inode, name, buffer, size, valid);
 		if (rc == -EAGAIN)
 			goto getxattr_nocache;
diff --git a/fs/lustre/llite/xattr_cache.c b/fs/lustre/llite/xattr_cache.c
index 723cc39..7e5b807 100644
--- a/fs/lustre/llite/xattr_cache.c
+++ b/fs/lustre/llite/xattr_cache.c
@@ -465,6 +465,10 @@ static int ll_xattr_cache_refill(struct inode *inode)
 			/* Filter out security.selinux, it is cached in slab */
 			CDEBUG(D_CACHE, "not caching security.selinux\n");
 			rc = 0;
+		} else if (!strcmp(xdata, XATTR_NAME_SOM)) {
+			/* Filter out trusted.som, it is not cached on client */
+			CDEBUG(D_CACHE, "not caching trusted.som\n");
+			rc = 0;
 		} else {
 			rc = ll_xattr_cache_add(&lli->lli_xattrs, xdata, xval,
 						*xsizes);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
