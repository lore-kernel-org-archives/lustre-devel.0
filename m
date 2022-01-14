Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 0EBE2C433F5
	for <lustre-devel@archiver.kernel.org>; Fri, 14 Jan 2022 01:38:59 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D391821F792;
	Thu, 13 Jan 2022 17:38:44 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6E51121FFA9
 for <lustre-devel@lists.lustre.org>; Thu, 13 Jan 2022 17:38:08 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id B7C11100F325;
 Thu, 13 Jan 2022 20:38:04 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id AF560E080E; Thu, 13 Jan 2022 20:38:04 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 13 Jan 2022 20:37:45 -0500
Message-Id: <1642124283-10148-7-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
References: <1642124283-10148-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 06/24] lustre: llite: make foreign symlinks
 aware of mount namespaces
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

Currently the foreign symlink code test if mount namespace is the
same namespace related to the sysfs tree. This doesn't cover all
cases. Linux supports limiting which mounts are visible to a
process with mount namespaces. Lets add this support as well.

WC-bug-id: https://jira.whamcloud.com/browse/LU-10824
Lustre-commit: 942b4e118677af587 ("LU-10824 llite: make foreign symlinks aware of mount namespaces")
Signed-off-by: James Simmons <jsimmons@infradead.org>
Reviewed-on: https://review.whamcloud.com/45609
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Faccini Bruno <bruno.faccini@intel.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
---
 fs/lustre/llite/llite_foreign_symlink.c | 8 ++++----
 fs/lustre/llite/llite_internal.h        | 1 +
 fs/lustre/llite/llite_lib.c             | 1 +
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/llite/llite_foreign_symlink.c b/fs/lustre/llite/llite_foreign_symlink.c
index bfade93..64bc5db 100644
--- a/fs/lustre/llite/llite_foreign_symlink.c
+++ b/fs/lustre/llite/llite_foreign_symlink.c
@@ -367,15 +367,15 @@ static struct dentry *ll_foreign_dir_lookup(struct inode *parent,
 
 static bool has_same_mount_namespace(struct ll_sb_info *sbi)
 {
-	int rc;
+	bool same;
 
-	rc = (sbi->ll_mnt.mnt == current->fs->root.mnt);
-	if (!rc)
+	same = (sbi->ll_mnt_ns == current->nsproxy->mnt_ns);
+	if (!same)
 		LCONSOLE_WARN("%s: client mount %s and '%s.%d' not in same mnt-namespace\n",
 			      sbi->ll_fsname, sbi->ll_kset.kobj.name,
 			      current->comm, current->pid);
 
-	return rc;
+	return same;
 }
 
 ssize_t foreign_symlink_enable_show(struct kobject *kobj,
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 54fd8d4..a2abec6 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -672,6 +672,7 @@ struct ll_sb_info {
 	struct obd_device	*ll_dt_obd;
 	struct dentry		*ll_debugfs_entry;
 	struct lu_fid		ll_root_fid; /* root object fid */
+	struct mnt_namespace	*ll_mnt_ns;
 
 	DECLARE_BITMAP(ll_flags, LL_SBI_NUM_FLAGS); /* enum ll_sbi_flags */
 	unsigned int		ll_xattr_cache_enabled:1,
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 87cdc36..f8ecdcba 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -445,6 +445,7 @@ static int client_common_fill_super(struct super_block *sb, char *md, char *dt)
 	sb->s_maxbytes = MAX_LFS_FILESIZE;
 	sbi->ll_namelen = osfs->os_namelen;
 	sbi->ll_mnt.mnt = current->fs->root.mnt;
+	sbi->ll_mnt_ns = current->nsproxy->mnt_ns;
 
 	if (test_bit(LL_SBI_USER_XATTR, sbi->ll_flags) &&
 	    !(data->ocd_connect_flags & OBD_CONNECT_XATTR)) {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
