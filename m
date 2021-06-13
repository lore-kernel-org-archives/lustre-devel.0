Return-Path: <SRS0=27wn=LH=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CEC2BC49360
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:12:02 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 860B3611CA
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:12:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 860B3611CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 1802021F4CB;
	Sun, 13 Jun 2021 16:11:54 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id BCB8321CB16
 for <lustre-devel@lists.lustre.org>; Sun, 13 Jun 2021 16:11:42 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id BC309100B031;
 Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id B1F789C318; Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 13 Jun 2021 19:11:17 -0400
Message-Id: <1623625897-17706-8-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
References: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 07/27] lustre: quota: default OST Pool Quotas
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
Cc: Sergey Cheremencev <sergey.cheremencev@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Sergey Cheremencev <sergey.cheremencev@hpe.com>

Patch makes ability to set default quota limits per OST pool.

HPE-bug-id: LUS-9133
WC-bug-id: https://jira.whamcloud.com/browse/LU-13952
Lustre-commit: 25a70a88c9eb35b7 ("LU-13952 quota: default OST Pool Quotas")
Signed-off-by: Sergey Cheremencev <sergey.cheremencev@hpe.com>
Reviewed-on: https://review.whamcloud.com/39873
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c                   | 2 ++
 include/uapi/linux/lustre/lustre_user.h | 3 ++-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 13676c1..d7466f3 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -1096,12 +1096,14 @@ int quotactl_ioctl(struct ll_sb_info *sbi, struct if_quotactl *qctl)
 	case LUSTRE_Q_SETDEFAULT:
 	case LUSTRE_Q_SETQUOTAPOOL:
 	case LUSTRE_Q_SETINFOPOOL:
+	case LUSTRE_Q_SETDEFAULT_POOL:
 		if (!capable(CAP_SYS_ADMIN))
 			return -EPERM;
 		break;
 	case Q_GETQUOTA:
 	case LUSTRE_Q_GETDEFAULT:
 	case LUSTRE_Q_GETQUOTAPOOL:
+	case LUSTRE_Q_GETDEFAULT_POOL:
 		if (check_owner(type, id) && !capable(CAP_SYS_ADMIN))
 			return -EPERM;
 		break;
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 972678f..aae6642 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -975,7 +975,8 @@ static inline void obd_uuid2fsname(char *buf, char *uuid, int buflen)
 #define LUSTRE_Q_SETQUOTAPOOL	0x800010	/* set user pool quota */
 #define LUSTRE_Q_GETINFOPOOL	0x800011	/* get pool quota info */
 #define LUSTRE_Q_SETINFOPOOL	0x800012	/* set pool quota info */
-
+#define LUSTRE_Q_GETDEFAULT_POOL	0x800013 /* get default pool quota*/
+#define LUSTRE_Q_SETDEFAULT_POOL	0x800014 /* set default pool quota */
 /* In the current Lustre implementation, the grace time is either the time
  * or the timestamp to be used after some quota ID exceeds the soft limt,
  * 48 bits should be enough, its high 16 bits can be used as quota flags.
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
