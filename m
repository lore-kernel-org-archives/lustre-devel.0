Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id A584FC433EF
	for <lustre-devel@archiver.kernel.org>; Sun, 12 Dec 2021 15:08:50 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1128321C9B2;
	Sun, 12 Dec 2021 07:08:18 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2EF7D21F46A
 for <lustre-devel@lists.lustre.org>; Sun, 12 Dec 2021 07:08:09 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id C997E10084F5;
 Sun, 12 Dec 2021 10:08:04 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id C2881E07E5; Sun, 12 Dec 2021 10:08:04 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 12 Dec 2021 10:08:02 -0500
Message-Id: <1639321683-22909-12-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1639321683-22909-1-git-send-email-jsimmons@infradead.org>
References: <1639321683-22909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 11/12] lustre: pcc: disable PCC for encrypted
 files
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

From: Qian Yingjin <qian@ddn.com>

When files are encrypted in Lustre using fscrypt, they should
normally not be accessible to users without the proper encyrption
key. However, if a user has then encryption key loaded when they
read a file, it may be decrypted in memory and saved to the PCC
backend in unencrypted form.

Due to the above reason, we just disable PCC caching for encrypted
files.

DDN-bug-id: EX-3571
WC-bug-id: https://jira.whamcloud.com/browse/LU-15217
Lustre-commit: f8c79eea11ac96019 ("LU-15217 pcc: disable PCC for encrypted files")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/45545
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c | 3 +++
 fs/lustre/llite/pcc.c  | 3 +++
 2 files changed, 6 insertions(+)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index d3374232..898db80 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -3598,6 +3598,9 @@ static long ll_file_unlock_lease(struct file *file, struct ll_ioc_lease *ioc,
 		if (ioc->lil_count != 1)
 			return -EINVAL;
 
+		if (IS_ENCRYPTED(inode))
+			return -EOPNOTSUPP;
+
 		arg += sizeof(*ioc);
 		if (copy_from_user(&param.pa_archive_id, (void __user *)arg,
 				   sizeof(u32))) {
diff --git a/fs/lustre/llite/pcc.c b/fs/lustre/llite/pcc.c
index 8430fff..85114b8 100644
--- a/fs/lustre/llite/pcc.c
+++ b/fs/lustre/llite/pcc.c
@@ -1472,6 +1472,9 @@ int pcc_file_open(struct inode *inode, struct file *file)
 	if (!S_ISREG(inode->i_mode))
 		return 0;
 
+	if (IS_ENCRYPTED(inode))
+		return 0;
+
 	pcc_inode_lock(inode);
 	pcci = ll_i2pcci(inode);
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
