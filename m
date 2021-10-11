Return-Path: <SRS0=0agL=O7=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7FC0C433EF
	for <lustre-devel@archiver.kernel.org>; Mon, 11 Oct 2021 17:41:06 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 736F860E78
	for <lustre-devel@archiver.kernel.org>; Mon, 11 Oct 2021 17:41:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 736F860E78
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 85C5E380CED;
	Mon, 11 Oct 2021 10:41:01 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id EF7F321FB84
 for <lustre-devel@lists.lustre.org>; Mon, 11 Oct 2021 10:40:53 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id A968825E;
 Mon, 11 Oct 2021 13:40:51 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 9FF6ED5A44; Mon, 11 Oct 2021 13:40:51 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Mon, 11 Oct 2021 13:40:32 -0400
Message-Id: <1633974049-26490-4-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1633974049-26490-1-git-send-email-jsimmons@infradead.org>
References: <1633974049-26490-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 03/20] lustre: llite: support fallocate() on
 selected mirror
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
Cc: Mikhail Pershin <mpershin@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Mikhail Pershin <mpershin@whamcloud.com>

- add ability to do fallocate() on designated mirror in
  FLR file
- add missing FALLOC_FL_KEEP_SIZE flag to fallocate() call
  in llapi_hole_punch(). It was just not working without
  that flag silently

Fixes: 7ce65bb0cd ("lustre: llite: mirror resync to keep sparseness")
WC-bug-id: https://jira.whamcloud.com/browse/LU-13397
Lustre-commit: 89736d502cc99f095 ("LU-13397 llite: support fallocate() on selected mirror")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/44721
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c | 9 ++++++---
 fs/lustre/lov/lov_io.c | 3 ++-
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index f340d67..9dd5c8c 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -5220,7 +5220,8 @@ int ll_getattr(const struct path *path, struct kstat *stat,
 				 false);
 }
 
-int cl_falloc(struct inode *inode, int mode, loff_t offset, loff_t len)
+int cl_falloc(struct file *file, struct inode *inode, int mode, loff_t offset,
+	      loff_t len)
 {
 	struct lu_env *env;
 	struct cl_io *io;
@@ -5234,6 +5235,8 @@ int cl_falloc(struct inode *inode, int mode, loff_t offset, loff_t len)
 
 	io = vvp_env_thread_io(env);
 	io->ci_obj = ll_i2info(inode)->lli_clob;
+	ll_io_set_mirror(io, file);
+
 	io->ci_verify_layout = 1;
 	io->u.ci_setattr.sa_parent_fid = lu_object_fid(&io->ci_obj->co_lu);
 	io->u.ci_setattr.sa_falloc_mode = mode;
@@ -5272,7 +5275,7 @@ int cl_falloc(struct inode *inode, int mode, loff_t offset, loff_t len)
 
 long ll_fallocate(struct file *filp, int mode, loff_t offset, loff_t len)
 {
-	struct inode *inode = filp->f_path.dentry->d_inode;
+	struct inode *inode = file_inode(filp);
 	int rc;
 
 	if (offset < 0 || len <= 0)
@@ -5298,7 +5301,7 @@ long ll_fallocate(struct file *filp, int mode, loff_t offset, loff_t len)
 
 	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_FALLOCATE, 1);
 
-	rc = cl_falloc(inode, mode, offset, len);
+	rc = cl_falloc(filp, inode, mode, offset, len);
 	/*
 	 * ENOTSUPP (524) is an NFSv3 specific error code erroneously
 	 * used by Lustre in several places. Retuning it here would
diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index eb71d7a..d5f895f 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -322,7 +322,8 @@ static int lov_io_mirror_init(struct lov_io *lio, struct lov_object *obj,
 		CDEBUG(D_LAYOUT, "designated I/O mirror state: %d\n",
 		      lov_flr_state(obj));
 
-		if ((cl_io_is_trunc(io) || io->ci_type == CIT_WRITE) &&
+		if ((cl_io_is_trunc(io) || io->ci_type == CIT_WRITE ||
+		     cl_io_is_fallocate(io)) &&
 		    (io->ci_layout_version != obj->lo_lsm->lsm_layout_gen)) {
 			/* For resync I/O, the ci_layout_version was the layout
 			 * version when resync starts. If it doesn't match the
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
