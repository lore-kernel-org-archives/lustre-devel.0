Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 73001C0218F
	for <lustre-devel@archiver.kernel.org>; Sun,  2 Feb 2025 20:50:43 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YmMCk3y98z20vV;
	Sun, 02 Feb 2025 12:48:18 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YmMB06WQ7z1yBk
 for <lustre-devel@lists.lustre.org>; Sun, 02 Feb 2025 12:46:48 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm-e204-208.ccs.ornl.gov [160.91.203.12])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id B05AC182332;
 Sun,  2 Feb 2025 15:46:41 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id AE1B3106BE16; Sun,  2 Feb 2025 15:46:41 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  2 Feb 2025 15:46:06 -0500
Message-ID: <20250202204633.1148872-7-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250202204633.1148872-1-jsimmons@infradead.org>
References: <20250202204633.1148872-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 06/33] lustre: uapi: cleanup FSFILT defines
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
Cc: Alex Deiter <alex.deiter@gmail.com>, Li Dongyang <dongyangli@ddn.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Andreas Dilger <adilger@whamcloud.com>

The various FSFILT_IOC_* defines are standard in Linux so remove
them from lustre_user.h. We do keep LL_IOC_GETVERSION to prevent
old tools breakage.

WC-bug-id: https://jira.whamcloud.com/browse/LU-137
Lustre-commit: ac0380dc519aa1531 ("LU-137 osd-ldiskfs: pass through resize ioctl")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/20161
Reviewed-by: Alex Deiter <alex.deiter@gmail.com>
Reviewed-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_lib.c             |  2 +-
 include/uapi/linux/lustre/lustre_user.h | 10 ++--------
 2 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 37327be5be66..a9acce572e32 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -2877,7 +2877,7 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 	case BLKSSZGET:
 		rc = put_user(PAGE_SIZE, (int __user *)uarg);
 		break;
-	case FSFILT_IOC_GETVERSION:
+	case LL_IOC_GETVERSION:
 	case FS_IOC_GETVERSION:
 		rc = put_user(inode->i_generation, (int __user *)uarg);
 		break;
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index 9c0632856bc8..0383db67361d 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -91,14 +91,8 @@ typedef struct stat	lstat_t;
 /* for statfs() */
 #define LL_SUPER_MAGIC 0x0BD00BD0
 
-#ifndef FSFILT_IOC_GETFLAGS
-#define FSFILT_IOC_GETFLAGS		_IOR('f', 1, long)
-#define FSFILT_IOC_SETFLAGS		_IOW('f', 2, long)
-#define FSFILT_IOC_GETVERSION		_IOR('f', 3, long)
-#define FSFILT_IOC_SETVERSION		_IOW('f', 4, long)
-#define FSFILT_IOC_GETVERSION_OLD	_IOR('v', 1, long)
-#define FSFILT_IOC_SETVERSION_OLD	_IOW('v', 2, long)
-#endif
+#define LL_IOC_GETVERSION		_IOR('f', 3, long)
+#define FSFILT_IOC_GETVERSION		LL_IOC_GETVERSION /* backward compat */
 
 /* FIEMAP flags supported by Lustre */
 #define LUSTRE_FIEMAP_FLAGS_COMPAT (FIEMAP_FLAG_SYNC | FIEMAP_FLAG_DEVICE_ORDER)
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
