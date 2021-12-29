Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 8AD23C433EF
	for <lustre-devel@archiver.kernel.org>; Wed, 29 Dec 2021 14:51:56 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B41313AD53B;
	Wed, 29 Dec 2021 06:51:51 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id D07C53AD51C
 for <lustre-devel@lists.lustre.org>; Wed, 29 Dec 2021 06:51:33 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id A92791008260;
 Wed, 29 Dec 2021 09:51:28 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id A7534D9E6F; Wed, 29 Dec 2021 09:51:28 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed, 29 Dec 2021 09:51:27 -0500
Message-Id: <1640789487-22279-14-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1640789487-22279-1-git-send-email-jsimmons@infradead.org>
References: <1640789487-22279-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 13/13] lustre: llite: set ra_pages of
 backing_dev_info with 0
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

The latest kernels sets initial @ra_pages of
backing_dev_info with VM_READAHEAD_PAGES:

struct backing_dev_info *bdi_alloc(int node_id)
{
        ...
        bdi->ra_pages = VM_READAHEAD_PAGES;
        bdi->io_pages = VM_READAHEAD_PAGES;
        ...
}

This will cause that @ra_pages of file readahead state is set
with @bdi->ra_pages, make the readahead is out of Lustre control
and trigger the readahead logic in Linux kernel wrongly. And it
results in the failure sanity 101j.

In this patch, we force to set @ra_pages of backing_dev_info with
0 after setup the backing device info. By this way, it disables
kernel readahead in the super block.

This patch also cleanups the unnecessary setting of @ra_pages in
llite "file.c" and "vvp_io.c".

WC-bug-id: https://jira.whamcloud.com/browse/LU-15244
Lustre-commit: 878561880d2aba038 ("LU-15244 llite: set ra_pages of backing_dev_info with 0")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-on: https://review.whamcloud.com/45712
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c      | 2 --
 fs/lustre/llite/llite_lib.c | 3 +++
 fs/lustre/llite/vvp_io.c    | 3 ---
 3 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index eafb936..30e99c0 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -757,8 +757,6 @@ static int ll_local_open(struct file *file, struct lookup_intent *it,
 	file->private_data = fd;
 	ll_readahead_init(inode, &fd->fd_ras);
 	fd->fd_omode = it->it_flags & (FMODE_READ | FMODE_WRITE | FMODE_EXEC);
-	/* turn off the kernel's read-ahead */
-	file->f_ra.ra_pages = 0;
 
 	return 0;
 }
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 11a545a3..87cdc36 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1203,6 +1203,9 @@ int ll_fill_super(struct super_block *sb)
 	if (err)
 		goto out_free;
 
+	/* disable kernel readahead */
+	sb->s_bdi->ra_pages = 0;
+
 	/* Call ll_debugsfs_register_super() before lustre_process_log()
 	 * so that "llite.*.*" params can be processed correctly.
 	 */
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index d8951ac..40047f8 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -834,9 +834,6 @@ static int vvp_io_read_start(const struct lu_env *env,
 			 "Read ino %lu, %zu bytes, offset %lld, size %llu\n",
 			 inode->i_ino, cnt, pos, i_size_read(inode));
 
-	/* turn off the kernel's read-ahead */
-	vio->vui_fd->fd_file->f_ra.ra_pages = 0;
-
 	/* initialize read-ahead window once per syscall */
 	if (!vio->vui_ra_valid) {
 		vio->vui_ra_valid = true;
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
