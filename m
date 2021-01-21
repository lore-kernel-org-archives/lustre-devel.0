Return-Path: <SRS0=NZgA=GY=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4B35C433DB
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:17:32 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7D5D723A57
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 17:17:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D5D723A57
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 743AC21FDAD;
	Thu, 21 Jan 2021 09:17:24 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9F39B21FA40
 for <lustre-devel@lists.lustre.org>; Thu, 21 Jan 2021 09:17:08 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 37D301008051;
 Thu, 21 Jan 2021 12:17:05 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 357001158C; Thu, 21 Jan 2021 12:17:05 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 21 Jan 2021 12:16:32 -0500
Message-Id: <1611249422-556-10-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
References: <1611249422-556-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 09/39] lustre: llite: fix client evicition
 with DIO
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
Cc: Wang Shilong <wshilong@ddn.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Wang Shilong <wshilong@ddn.com>

We set lockless in file open if O_DIRECT flag is passed,
however O_DIRECT flag could be cleared by
fcntl(..., F_SETFL, ...).

Finally we comes to a case where buffer IO without lock
held properly, and hit hang:

[<ffffffffc0d421ed>] osc_extent_wait+0x21d/0x7c0 [osc]
[<ffffffffc0d44897>] osc_cache_wait_range+0x2e7/0x940 [osc]
[<ffffffffc0d4585e>] osc_cache_writeback_range+0x96e/0xff0 [osc]
[<ffffffffc0d31c45>] osc_lock_flush+0x195/0x290 [osc]
[<ffffffffc0d31d7c>] osc_lock_lockless_cancel+0x3c/0xe0 [osc]
[<ffffffffc081f488>] cl_lock_cancel+0x78/0x160 [obdclass]
[<ffffffffc0cd8079>] lov_lock_cancel+0x99/0x190 [lov]
[<ffffffffc081f488>] cl_lock_cancel+0x78/0x160 [obdclass]
[<ffffffffc081f9a2>] cl_lock_release+0x52/0x140 [obdclass]
[<ffffffffc08238a9>] cl_io_unlock+0x139/0x290 [obdclass]
[<ffffffffc08242e8>] cl_io_loop+0xb8/0x200 [obdclass]
[<ffffffffc0e1d36b>] ll_file_io_generic+0x91b/0xdf0 [lustre]
[<ffffffffc0e1dd0c>] ll_file_aio_write+0x29c/0x6e0 [lustre]
[<ffffffffc0e1e250>] ll_file_write+0x100/0x1c0 [lustre]
[<ffffffffa984aa90>] vfs_write+0xc0/0x1f0
[<ffffffffa984b8af>] SyS_write+0x7f/0xf0
[<ffffffffa9d8eede>] system_call_fastpath+0x25/0x2a
[<ffffffffffffffff>] 0xffffffffffffffff

Lock cancel time out in the server side and client
eviction happen.

Fix this problem by testing O_DIRECT flag to decide if
we could issue lockless IO.

Fixes: bf18998820 ("lustre: clio: turn on lockless for some kind of IO")
WC-bug-id: https://jira.whamcloud.com/browse/LU-14072
Lustre-commit: f348437218d0b9 ("LU-14072 llite: fix client evicition with DIO")
Signed-off-by: Wang Shilong <wshilong@ddn.com>
Reviewed-on: https://review.whamcloud.com/40389
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Gu Zheng <gzheng@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h           | 2 +-
 fs/lustre/llite/file.c                  | 9 +++------
 fs/lustre/llite/rw.c                    | 4 ++--
 fs/lustre/llite/rw26.c                  | 6 +++---
 fs/lustre/llite/vvp_io.c                | 6 +++---
 include/uapi/linux/lustre/lustre_user.h | 1 -
 6 files changed, 12 insertions(+), 16 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index e17385c0..d2cee34 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -1962,7 +1962,7 @@ struct cl_io {
 	/**
 	 * Ignore lockless and do normal locking for this io.
 	 */
-				ci_ignore_lockless:1,
+				ci_dio_lock:1,
 	/**
 	 * Set if we've tried all mirrors for this read IO, if it's not set,
 	 * the read IO will check to-be-read OSCs' status, and make fast-switch
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index f7f917b..2b0ffad 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -945,9 +945,6 @@ int ll_file_open(struct inode *inode, struct file *file)
 
 	mutex_unlock(&lli->lli_och_mutex);
 
-	/* lockless for direct IO so that it can do IO in parallel */
-	if (file->f_flags & O_DIRECT)
-		fd->fd_flags |= LL_FILE_LOCKLESS_IO;
 	fd = NULL;
 
 	/* Must do this outside lli_och_mutex lock to prevent deadlock where
@@ -1573,7 +1570,7 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 	ssize_t result = 0;
 	int rc = 0;
 	unsigned int retried = 0;
-	unsigned int ignore_lockless = 0;
+	unsigned int dio_lock = 0;
 	bool is_aio = false;
 	struct cl_dio_aio *ci_aio = NULL;
 
@@ -1595,7 +1592,7 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 	io = vvp_env_thread_io(env);
 	ll_io_init(io, file, iot == CIT_WRITE, args);
 	io->ci_aio = ci_aio;
-	io->ci_ignore_lockless = ignore_lockless;
+	io->ci_dio_lock = dio_lock;
 	io->ci_ndelay_tried = retried;
 
 	if (cl_io_rw_init(env, io, iot, *ppos, count) == 0) {
@@ -1675,7 +1672,7 @@ static void ll_heat_add(struct inode *inode, enum cl_io_type iot,
 		       *ppos, count, result);
 		/* preserve the tried count for FLR */
 		retried = io->ci_ndelay_tried;
-		ignore_lockless = io->ci_ignore_lockless;
+		dio_lock = io->ci_dio_lock;
 		goto restart;
 	}
 
diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index 54f0b9a..da4a26d 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -1723,9 +1723,9 @@ int ll_readpage(struct file *file, struct page *vmpage)
 	 */
 	if (file->f_flags & O_DIRECT &&
 	    lcc && lcc->lcc_type == LCC_RW &&
-	    !io->ci_ignore_lockless) {
+	    !io->ci_dio_lock) {
 		unlock_page(vmpage);
-		io->ci_ignore_lockless = 1;
+		io->ci_dio_lock = 1;
 		io->ci_need_restart = 1;
 		return -ENOLCK;
 	}
diff --git a/fs/lustre/llite/rw26.c b/fs/lustre/llite/rw26.c
index 1736e9a..605a326 100644
--- a/fs/lustre/llite/rw26.c
+++ b/fs/lustre/llite/rw26.c
@@ -538,12 +538,12 @@ static int ll_write_begin(struct file *file, struct address_space *mapping,
 		}
 
 		/*
-		 * Direct read can fall back to buffered read, but DIO is done
+		 * Direct write can fall back to buffered read, but DIO is done
 		 * with lockless i/o, and buffered requires LDLM locking, so
 		 * in this case we must restart without lockless.
 		 */
-		if (!io->ci_ignore_lockless) {
-			io->ci_ignore_lockless = 1;
+		if (!io->ci_dio_lock) {
+			io->ci_dio_lock = 1;
 			io->ci_need_restart = 1;
 			result = -ENOLCK;
 			goto out;
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index d6ca267..8dbe835 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -557,11 +557,11 @@ static int vvp_io_rw_lock(const struct lu_env *env, struct cl_io *io,
 	if (vio->vui_fd) {
 		/* Group lock held means no lockless any more */
 		if (vio->vui_fd->fd_flags & LL_FILE_GROUP_LOCKED)
-			io->ci_ignore_lockless = 1;
+			io->ci_dio_lock = 1;
 
 		if (ll_file_nolock(vio->vui_fd->fd_file) ||
-		    (vio->vui_fd->fd_flags & LL_FILE_LOCKLESS_IO &&
-		     !io->ci_ignore_lockless))
+		    (vio->vui_fd->fd_file->f_flags & O_DIRECT &&
+		     !io->ci_dio_lock))
 			ast_flags |= CEF_NEVER;
 	}
 
diff --git a/include/uapi/linux/lustre/lustre_user.h b/include/uapi/linux/lustre/lustre_user.h
index b0301e1..143b7d5 100644
--- a/include/uapi/linux/lustre/lustre_user.h
+++ b/include/uapi/linux/lustre/lustre_user.h
@@ -402,7 +402,6 @@ struct ll_ioc_lease_id {
 #define LL_FILE_GROUP_LOCKED	0x00000002
 #define LL_FILE_READAHEA	0x00000004
 #define LL_FILE_LOCKED_DIRECTIO 0x00000008 /* client-side locks with dio */
-#define LL_FILE_LOCKLESS_IO	0x00000010 /* server-side locks with cio */
 #define LL_FILE_FLOCK_WARNING	0x00000020 /* warned about disabled flock */
 
 #define LOV_USER_MAGIC_V1	0x0BD10BD0
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
