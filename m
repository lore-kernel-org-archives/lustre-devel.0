Return-Path: <SRS0=FD7t=JM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CBE20C43462
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:05:57 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 93A2361222
	for <lustre-devel@archiver.kernel.org>; Thu, 15 Apr 2021 04:05:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93A2361222
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A985932CC8F;
	Wed, 14 Apr 2021 21:04:24 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 900E632F6A5
 for <lustre-devel@lists.lustre.org>; Wed, 14 Apr 2021 21:02:58 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id C0721100F36A;
 Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id BEE629188E; Thu, 15 Apr 2021 00:02:45 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 15 Apr 2021 00:02:33 -0400
Message-Id: <1618459361-17909-42-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
References: <1618459361-17909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 41/49] lustre: llite: mirror extend/copy
 keeps sparseness
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
Cc: Mikhail Pershin <mpershin@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mikhail Pershin <mpershin@whamcloud.com>

- make ll_lseek() to work under group lock and on designated
  mirror

WC-bug-id: https://jira.whamcloud.com/browse/LU-13397
Lustre-commit: 0561c144cc1bb623 ("LU-13397 lfs: mirror extend/copy keeps sparseness")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Li Xi <lixi@ddn.com>
Reviewed-on: https://review.whamcloud.com/40772
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 225008e..bbb2ff9 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -4017,8 +4017,9 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 	}
 }
 
-loff_t ll_lseek(struct inode *inode, loff_t offset, int whence)
+loff_t ll_lseek(struct file *file, loff_t offset, int whence)
 {
+	struct inode *inode = file_inode(file);
 	struct lu_env *env;
 	struct cl_io *io;
 	struct cl_lseek_io *lsio;
@@ -4032,6 +4033,7 @@ loff_t ll_lseek(struct inode *inode, loff_t offset, int whence)
 
 	io = vvp_env_thread_io(env);
 	io->ci_obj = ll_i2info(inode)->lli_clob;
+	ll_io_set_mirror(io, file);
 
 	lsio = &io->u.ci_lseek;
 	lsio->ls_start = offset;
@@ -4040,10 +4042,14 @@ loff_t ll_lseek(struct inode *inode, loff_t offset, int whence)
 
 	do {
 		rc = cl_io_init(env, io, CIT_LSEEK, io->ci_obj);
-		if (!rc)
+		if (!rc) {
+			struct vvp_io *vio = vvp_env_io(env);
+
+			vio->vui_fd = file->private_data;
 			rc = cl_io_loop(env, io);
-		else
+		} else {
 			rc = io->ci_result;
+		}
 		retval = rc ? : lsio->ls_result;
 		cl_io_fini(env, io);
 	} while (unlikely(io->ci_need_restart));
@@ -4077,7 +4083,7 @@ static loff_t ll_file_seek(struct file *file, loff_t offset, int origin)
 		cl_sync_file_range(inode, offset, OBD_OBJECT_EOF,
 				   CL_FSYNC_LOCAL, 0);
 
-		retval = ll_lseek(inode, offset, origin);
+		retval = ll_lseek(file, offset, origin);
 		if (retval < 0)
 			return retval;
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
