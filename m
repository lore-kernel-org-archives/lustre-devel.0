Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 1F937C77B70
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:28:27 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWLX46LSz21HH;
	Sun,  9 Apr 2023 05:16:52 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWJ66wCqz1yFH
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:14:46 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 082F1100827D;
 Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 06E102B2; Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:12:55 -0400
Message-Id: <1681042400-15491-16-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 15/40] lustre: llite: fix relatime support
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

relatime behavior is properly managed by VFS, however
Lustre also stores acmtime on OST objects and atime
updates for OST objects should honor relatime behavior.

This patch updates 'ci_noatime' feature which was introduced to
properly honor noatime option for OST objects, to also support
'relatime'.
file_is_noatime() code already comes from upstream touch_atime().
Add missing parts from touch_atime() to also support relatime.

It also forces atime to disk on MDD if ondisk atime is older than
ondisk mtime/ctime to match relatime (even if relatime is not enabled)

WC-bug-id: https://jira.whamcloud.com/browse/LU-15728
Lustre-commit: c10c6eeb37dd55316 ("LU-15728 llite: fix relatime support")
Signed-off-by: Aurelien Degremont <degremoa@amazon.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/47017
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Yang Sheng <ys@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c | 45 ++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 42 insertions(+), 3 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 668d544..18f3302 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -1541,12 +1541,46 @@ void ll_io_set_mirror(struct cl_io *io, const struct file *file)
 	       file->f_path.dentry->d_name.name, io->ci_designated_mirror);
 }
 
+/*
+ * This is relatime_need_update() from Linux 5.17, which is not exported.
+ */
+static int relatime_need_update(struct vfsmount *mnt, struct inode *inode,
+				struct timespec64 now)
+{
+	if (!(mnt->mnt_flags & MNT_RELATIME))
+		return 1;
+	/*
+	 * Is mtime younger than atime? If yes, update atime:
+	 */
+	if (timespec64_compare(&inode->i_mtime, &inode->i_atime) >= 0)
+		return 1;
+	/*
+	 * Is ctime younger than atime? If yes, update atime:
+	 */
+	if (timespec64_compare(&inode->i_ctime, &inode->i_atime) >= 0)
+		return 1;
+
+	/*
+	 * Is the previous atime value older than a day? If yes,
+	 * update atime:
+	 */
+	if ((long)(now.tv_sec - inode->i_atime.tv_sec) >= 24*60*60)
+		return 1;
+	/*
+	 * Good, we can skip the atime update:
+	 */
+	return 0;
+}
+
+/*
+ * Very similar to kernel function: !__atime_needs_update()
+ */
 static bool file_is_noatime(const struct file *file)
 {
-	const struct vfsmount *mnt = file->f_path.mnt;
-	const struct inode *inode = file_inode(file);
+	struct vfsmount *mnt = file->f_path.mnt;
+	struct inode *inode = file_inode(file);
+	struct timespec64 now;
 
-	/* Adapted from file_accessed() and touch_atime().*/
 	if (file->f_flags & O_NOATIME)
 		return true;
 
@@ -1565,6 +1599,11 @@ static bool file_is_noatime(const struct file *file)
 	if ((inode->i_sb->s_flags & SB_NODIRATIME) && S_ISDIR(inode->i_mode))
 		return true;
 
+	now = current_time(inode);
+
+	if (!relatime_need_update(mnt, inode, now))
+		return true;
+
 	return false;
 }
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
