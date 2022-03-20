Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 06146C433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:33:16 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 86EAA21FAF8;
	Sun, 20 Mar 2022 06:32:16 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9F69121CB93
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:20 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 81FDE1020;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 7E076D6A26; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:55 -0400
Message-Id: <1647783064-20688-42-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 41/50] lustre: quota: delete unused quota ID
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

Add ability for user land to delete unused quota ID.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15218
Lustre-commit: 78be823f333968197 ("LU-15218 quota: delete unused quota ID")
Signed-off-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/45548
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c                   | 1 +
 include/uapi/linux/lustre/lustre_user.h | 2 ++
 2 files changed, 3 insertions(+)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index d3df4d0..4165726 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -1145,6 +1145,7 @@ int quotactl_ioctl(struct super_block *sb, struct if_quotactl *qctl)
 	case LUSTRE_Q_SETQUOTAPOOL:
 	case LUSTRE_Q_SETINFOPOOL:
 	case LUSTRE_Q_SETDEFAULT_POOL:
+	case LUSTRE_Q_DELETEQID:
 		if (!capable(CAP_SYS_ADMIN))
 			return -EPERM;
 
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 96efdf0..9892fc5 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -992,6 +992,7 @@ static inline void obd_uuid2fsname(char *buf, char *uuid, int buflen)
 #define LUSTRE_Q_SETINFOPOOL	0x800012	/* set pool quota info */
 #define LUSTRE_Q_GETDEFAULT_POOL	0x800013 /* get default pool quota*/
 #define LUSTRE_Q_SETDEFAULT_POOL	0x800014 /* set default pool quota */
+#define LUSTRE_Q_DELETEQID	0x800015  /* delete quota ID */
 /* In the current Lustre implementation, the grace time is either the time
  * or the timestamp to be used after some quota ID exceeds the soft limt,
  * 48 bits should be enough, its high 16 bits can be used as quota flags.
@@ -1011,6 +1012,7 @@ static inline void obd_uuid2fsname(char *buf, char *uuid, int buflen)
  * and high 16 bits will contain this flag (see above comment).
  */
 #define LQUOTA_FLAG_DEFAULT	0x0001
+#define LQUOTA_FLAG_DELETED	0x0002
 
 #define LUSTRE_Q_CMD_IS_POOL(cmd)		\
 	(cmd == LUSTRE_Q_GETQUOTAPOOL ||	\
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
