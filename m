Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4DBB8C433ED
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:52:38 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 0BD836138E
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:52:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0BD836138E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 8291A328B2B;
	Mon,  5 Apr 2021 00:52:10 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E972C21F949
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:23 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id D75E49F9;
 Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id D49EC90AAE; Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:50:50 -0400
Message-Id: <1617583870-32029-22-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
References: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 21/41] lustre: sec: file ioctls to handle
 encryption policies
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

Introduce support for fscrypt IOCTLs that handle encryption
policies v2. It enables setting/getting encryption policies on
individual directories, letting users decide how they want to
encrypt specific directories. Add file IOCTls this time.

fscrypt encryption policies v2 are supported from Linux 5.4.

Fixes: b8b71993 ("lustre: sec: ioctls to handle encryption policies")
WC-bug-id: https://jira.whamcloud.com/browse/LU-12275
Lustre-commit: 3973cf8dc955c77 ("LU-12275 sec: ioctls to handle encryption policies")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/37673
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c | 27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index fd01e14..60b6ac4 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -3989,6 +3989,33 @@ static int ll_heat_set(struct inode *inode, enum lu_heat_flag flags)
 		kfree(state);
 		return rc;
 	}
+#ifdef CONFIG_FS_ENCRYPTION
+	case FS_IOC_SET_ENCRYPTION_POLICY:
+		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
+			return -EOPNOTSUPP;
+		return llcrypt_ioctl_set_policy(file, (const void __user *)arg);
+	case FS_IOC_GET_ENCRYPTION_POLICY_EX:
+		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
+			return -EOPNOTSUPP;
+		return llcrypt_ioctl_get_policy_ex(file, (void __user *)arg);
+	case FS_IOC_ADD_ENCRYPTION_KEY:
+		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
+			return -EOPNOTSUPP;
+		return llcrypt_ioctl_add_key(file, (void __user *)arg);
+	case FS_IOC_REMOVE_ENCRYPTION_KEY:
+		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
+			return -EOPNOTSUPP;
+		return llcrypt_ioctl_remove_key(file, (void __user *)arg);
+	case FS_IOC_REMOVE_ENCRYPTION_KEY_ALL_USERS:
+		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
+			return -EOPNOTSUPP;
+		return llcrypt_ioctl_remove_key_all_users(file,
+							  (void __user *)arg);
+	case FS_IOC_GET_ENCRYPTION_KEY_STATUS:
+		if (!ll_sbi_has_encrypt(ll_i2sbi(inode)))
+			return -EOPNOTSUPP;
+		return llcrypt_ioctl_get_key_status(file, (void __user *)arg);
+#endif
 	default:
 		return obd_iocontrol(cmd, ll_i2dtexp(inode), 0, NULL,
 				     (void __user *)arg);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
