Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 4F588C433F5
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Mar 2022 13:31:51 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6A88E21FA70;
	Sun, 20 Mar 2022 06:31:34 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D8D0C21F3E8
 for <lustre-devel@lists.lustre.org>; Sun, 20 Mar 2022 06:31:18 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 68254EF9;
 Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 61C57D5A47; Sun, 20 Mar 2022 09:31:08 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Mar 2022 09:30:48 -0400
Message-Id: <1647783064-20688-35-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
References: <1647783064-20688-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 34/50] lustre: llite: Delay dput in
 ll_dirty_page_discard_warn
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

From: Oleg Drokin <green@whamcloud.com>

Otherwise we can be final dput and need to wait for pages
to clear which is bad because this is called from ptlrpcd
that is not supposed to block esp. for network traffic as
it can cause livelocks if it happens to be needed to kill
the very same RPC we are waiting on.

Additionally pass in the inode from IO since the page
we are using might come from directio and that is
probably not even a valid inode.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15340
Lustre-commit: a1d75780ba19cfca5 ("LU-15340 llite: Delay dput in ll_dirty_page_discard_warn")
Signed-off-by: Oleg Drokin <green@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/45784
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Shaun Tancheff <shaun.tancheff@hpe.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_internal.h |  2 +-
 fs/lustre/llite/llite_lib.c      | 49 +++++++++++++++++++++++++++++++---------
 fs/lustre/llite/vvp_page.c       |  2 +-
 3 files changed, 40 insertions(+), 13 deletions(-)

diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index a8d43bd..f51ab19 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -1208,7 +1208,7 @@ int ll_iocontrol(struct inode *inode, struct file *file,
 void ll_umount_begin(struct super_block *sb);
 int ll_remount_fs(struct super_block *sb, int *flags, char *data);
 int ll_show_options(struct seq_file *seq, struct dentry *dentry);
-void ll_dirty_page_discard_warn(struct page *page, int ioret);
+void ll_dirty_page_discard_warn(struct inode *inode, int ioret);
 int ll_prep_inode(struct inode **inode, struct req_capsule *pill,
 		  struct super_block *sb, struct lookup_intent *it);
 int ll_obd_statfs(struct inode *inode, void __user *arg);
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 4c91a78..423c531 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -3334,18 +3334,36 @@ int ll_get_obd_name(struct inode *inode, unsigned int cmd, unsigned long arg)
 	return 0;
 }
 
-void ll_dirty_page_discard_warn(struct page *page, int ioret)
+struct dname_buf {
+	struct work_struct db_work;
+	struct dentry *db_dentry;
+	/* Let's hope the path is not too long, 32 bytes for the work struct
+	 * on my kernel
+	 */
+	char buf[PAGE_SIZE - sizeof(struct work_struct) - sizeof(void *)];
+};
+
+static void ll_dput_later(struct work_struct *work)
 {
-	char *buf, *path = NULL;
+	struct dname_buf *db = container_of(work, struct dname_buf, db_work);
+
+	dput(db->db_dentry);
+	free_page((unsigned long)db);
+}
+
+void ll_dirty_page_discard_warn(struct inode *inode, int ioret)
+{
+	struct dname_buf *db;
+	char *path = NULL;
 	struct dentry *dentry = NULL;
-	struct inode *inode = page->mapping->host;
 
 	/* this can be called inside spin lock so use GFP_ATOMIC. */
-	buf = (char *)__get_free_page(GFP_ATOMIC);
-	if (buf) {
+	db = (struct dname_buf *)__get_free_page(GFP_ATOMIC);
+	if (db) {
 		dentry = d_find_alias(inode);
 		if (dentry)
-			path = dentry_path_raw(dentry, buf, PAGE_SIZE);
+			path = dentry_path_raw(dentry, db->buf,
+					       sizeof(db->buf));
 	}
 
 	/* The below message is checked in recovery-small.sh test_24b */
@@ -3356,11 +3374,20 @@ void ll_dirty_page_discard_warn(struct page *page, int ioret)
 	       PFID(ll_inode2fid(inode)),
 	       (path && !IS_ERR(path)) ? path : "", ioret);
 
-	if (dentry)
-		dput(dentry);
-
-	if (buf)
-		free_page((unsigned long)buf);
+	if (dentry) {
+		/* We cannot dput here since if we happen to be the last holder
+		 * then we can end up waiting for page evictions that
+		 * in turn wait for RPCs that need this instance of ptlrpcd
+		 * (callng brw_interpret->*page_completion*->vmpage_error->here)
+		 * LU-15340
+		 */
+		INIT_WORK(&db->db_work, ll_dput_later);
+		db->db_dentry = dentry;
+		schedule_work(&db->db_work);
+	} else {
+		if (db)
+			free_page((unsigned long)db);
+	}
 }
 
 ssize_t ll_copy_user_md(const struct lov_user_md __user *md,
diff --git a/fs/lustre/llite/vvp_page.c b/fs/lustre/llite/vvp_page.c
index ae51ba0..1e95ede 100644
--- a/fs/lustre/llite/vvp_page.c
+++ b/fs/lustre/llite/vvp_page.c
@@ -244,7 +244,7 @@ static void vvp_vmpage_error(struct inode *inode, struct page *vmpage,
 		if ((ioret == -ESHUTDOWN || ioret == -EINTR ||
 		     ioret == -EIO) && obj->vob_discard_page_warned == 0) {
 			obj->vob_discard_page_warned = 1;
-			ll_dirty_page_discard_warn(vmpage, ioret);
+			ll_dirty_page_discard_warn(inode, ioret);
 		}
 	}
 }
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
