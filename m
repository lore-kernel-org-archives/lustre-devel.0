Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id C70E4C433FE
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Nov 2022 14:25:10 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4NFXgy16s7z1yG1;
	Sun, 20 Nov 2022 06:18:54 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4NFXf24WKsz1y2s
 for <lustre-devel@lists.lustre.org>; Sun, 20 Nov 2022 06:17:14 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id B698E1007866;
 Sun, 20 Nov 2022 09:17:09 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id B0629E8B9B; Sun, 20 Nov 2022 09:17:09 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Nov 2022 09:16:50 -0500
Message-Id: <1668953828-10909-5-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
References: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 04/22] lustre: llite: Explicitly support
 .splice_write
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
Cc: Shaun Tancheff <shaun.tancheff@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Shaun Tancheff <shaun.tancheff@hpe.com>

Linux commit v5.9-rc1-6-g36e2c7421f02
  fs: don't allow splice read/write without explicit ops

Lustre supports splice_write and previously provide handlers
for splice_read.
Explicitly use iter_file_splice_write, if it exists.

HPE-bug-id: LUS-11259
WC-bug-id: https://jira.whamcloud.com/browse/LU-16258
Lustre-commit: c619b6d6a54235cc0 ("LU-16258 llite: Explicitly support .splice_write")
Signed-off-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48928
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 350d5df..34a449e 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -5564,6 +5564,7 @@ int ll_inode_permission(struct inode *inode, int mask)
 	.mmap			= ll_file_mmap,
 	.llseek			= ll_file_seek,
 	.splice_read		= generic_file_splice_read,
+	.splice_write		= iter_file_splice_write,
 	.fsync			= ll_fsync,
 	.flush			= ll_flush,
 	.fallocate		= ll_fallocate,
@@ -5578,6 +5579,7 @@ int ll_inode_permission(struct inode *inode, int mask)
 	.mmap			= ll_file_mmap,
 	.llseek			= ll_file_seek,
 	.splice_read		= generic_file_splice_read,
+	.splice_write		= iter_file_splice_write,
 	.fsync			= ll_fsync,
 	.flush			= ll_flush,
 	.flock			= ll_file_flock,
@@ -5595,6 +5597,7 @@ int ll_inode_permission(struct inode *inode, int mask)
 	.mmap			= ll_file_mmap,
 	.llseek			= ll_file_seek,
 	.splice_read		= generic_file_splice_read,
+	.splice_write		= iter_file_splice_write,
 	.fsync			= ll_fsync,
 	.flush			= ll_flush,
 	.flock			= ll_file_noflock,
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
