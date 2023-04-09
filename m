Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id B7AF7C77B61
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:22:16 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWJb20BTz215N;
	Sun,  9 Apr 2023 05:15:11 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWHH6gl7z1yBw
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:14:03 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id E060F1008277;
 Sun,  9 Apr 2023 08:13:27 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id DEC3C2B3; Sun,  9 Apr 2023 08:13:27 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:12:49 -0400
Message-Id: <1681042400-15491-10-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 09/40] lustre: quota: fix insane grant quota
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
Cc: Hongchao Zhang <hongchao@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Hongchao Zhang <hongchao@whamcloud.com>

Fix the insane grant value in quota master/slave index,
the logs often contain the content similar to the following,

LustreError: 39815:0:(qmt_handler.c:527:qmt_dqacq0())
$$$ Release too much! uuid:work-MDT0000-lwp-MDT0002_UUID
release:18446744070274413724 granted:18446744070291193856,
total:4118877744 qmt:work-QMT0000 pool:0-dt id:40212 enforced:1
hard:128849018880 soft:12884901888 granted:4118877744 time:0
qunit: 16777216 edquot:0 may_rel:0 revoke:0 default:no

It could be caused by chgrp, which reserves quota before changing
GID for some file at MDT, then release the reserved quota after
the file GID has been changed on the corresponding OST, (this issue
is tracked at LU-5152 and LU-11303)

In some case, some quota could be released even the quota was not
reserved correctly, which cause the grant quota to be some negative
value, which is regarded as some insane big value because the type
of grant is "u64", then the normal grant release will fail and
the grant field of some quota ID in the quota file (both at QMT and
QSD) contain insane value, but can't be reset correctly.

This patch resets the affected quota by clear the quota limits and
grant, and the grant will be reported by each QSD when the quota ID
is enforced again, then rebuild the grant at QMT.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15880
Lustre-commit: a2fd4d3aee9739dcb ("LU-15880 quota: fix insane grant quota")
Signed-off-by: Hongchao Zhang <hongchao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48981
Reviewed-by: Sergey Cheremencev <scherementsev@ddn.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c                   | 1 +
 include/uapi/linux/lustre/lustre_user.h | 1 +
 2 files changed, 2 insertions(+)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index 7dca0fc..56ef1bb 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -1158,6 +1158,7 @@ int quotactl_ioctl(struct super_block *sb, struct if_quotactl *qctl)
 	case LUSTRE_Q_SETINFOPOOL:
 	case LUSTRE_Q_SETDEFAULT_POOL:
 	case LUSTRE_Q_DELETEQID:
+	case LUSTRE_Q_RESETQID:
 		if (!capable(CAP_SYS_ADMIN))
 			return -EPERM;
 
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 9bbb1c9..68fddcf 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -1041,6 +1041,7 @@ static inline void obd_uuid2fsname(char *buf, char *uuid, int buflen)
 #define LUSTRE_Q_GETDEFAULT_POOL	0x800013 /* get default pool quota*/
 #define LUSTRE_Q_SETDEFAULT_POOL	0x800014 /* set default pool quota */
 #define LUSTRE_Q_DELETEQID	0x800015  /* delete quota ID */
+#define LUSTRE_Q_RESETQID	0x800016  /* reset quota ID */
 /* In the current Lustre implementation, the grace time is either the time
  * or the timestamp to be used after some quota ID exceeds the soft limt,
  * 48 bits should be enough, its high 16 bits can be used as quota flags.
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
