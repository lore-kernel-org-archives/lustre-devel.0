Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 3E4F6C25B50
	for <lustre-devel@archiver.kernel.org>; Mon, 23 Jan 2023 23:24:27 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4P15P73X67z22R9;
	Mon, 23 Jan 2023 15:08:11 -0800 (PST)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4P15NC0w7cz22PM
 for <lustre-devel@lists.lustre.org>; Mon, 23 Jan 2023 15:07:23 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 8A60AA1D;
 Mon, 23 Jan 2023 18:00:58 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 88FFF5898C; Mon, 23 Jan 2023 18:00:58 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 23 Jan 2023 18:00:42 -0500
Message-Id: <1674514855-15399-30-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
References: <1674514855-15399-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 29/42] lustre: llite: remove false outdated
 comment
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

From: Aurelien Degremont <degremoa@amazon.com>

Old commit from before Lustre was submitted upstream changed
ll_i2gids() behavior without updating the function
documentation accordingly. Fix it as this is confusing.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16438
Lustre-commit: 557bb0004d7ea1d87 ("LU-16438 llite: remove false outdated comment");
Signed-off-by: Aurelien Degremont <degremoa@amazon.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49539
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/namei.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 93abec81896f..f23d3ae49fae 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -518,11 +518,7 @@ u32 ll_i2suppgid(struct inode *i)
 		return (u32)(-1);
 }
 
-/* Pack the required supplementary groups into the supplied groups array.
- * If we don't need to use the groups from the target inode(s) then we
- * instead pack one or more groups from the user's supplementary group
- * array in case it might be useful.  Not needed if doing an MDS-side upcall.
- */
+/* Pack the required supplementary groups into the supplied groups array. */
 void ll_i2gids(u32 *suppgids, struct inode *i1, struct inode *i2)
 {
 	LASSERT(i1);
-- 
2.27.0

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
