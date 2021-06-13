Return-Path: <SRS0=27wn=LH=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B93A2C49360
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:12:14 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 78A5561363
	for <lustre-devel@archiver.kernel.org>; Sun, 13 Jun 2021 23:12:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78A5561363
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id EA6CD21F5AB;
	Sun, 13 Jun 2021 16:12:00 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id B850D21C959
 for <lustre-devel@lists.lustre.org>; Sun, 13 Jun 2021 16:11:41 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id B2924100B008;
 Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id AA0B89C30D; Sun, 13 Jun 2021 19:11:38 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 13 Jun 2021 19:11:14 -0400
Message-Id: <1623625897-17706-5-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
References: <1623625897-17706-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 04/27] lustre: flr: mmap write/punch does not
 stale other mirrors
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

From: Bobi Jam <bobijam@whamcloud.com>

mmap write and punch/fallocate do not stale other mirrors and makes
FLR file contains different content in different mirrors.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14647
Lustre-commit: 03511484c668355c ("LU-14647 flr: mmap write/punch does not stale other mirrors")
Signed-off-by: Bobi Jam <bobijam@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/43470
Reviewed-by: Wang Shilong <wshilong@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: John L. Hammond <jhammond@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h | 5 +++++
 fs/lustre/llite/llite_mmap.c  | 4 +++-
 fs/lustre/llite/vvp_io.c      | 3 ++-
 fs/lustre/lov/lov_io.c        | 8 +++++---
 4 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index b69c04a..c615091 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -2456,6 +2456,11 @@ int cl_io_lru_reserve(const struct lu_env *env, struct cl_io *io,
 int cl_io_read_ahead(const struct lu_env *env, struct cl_io *io,
 		     pgoff_t start, struct cl_read_ahead *ra);
 
+static inline int cl_io_is_fault_writable(const struct cl_io *io)
+{
+	return io->ci_type == CIT_FAULT && io->u.ci_fault.ft_writable;
+}
+
 /**
  * True, if @io is an O_APPEND write(2).
  */
diff --git a/fs/lustre/llite/llite_mmap.c b/fs/lustre/llite/llite_mmap.c
index a234a83..ebcb8d9 100644
--- a/fs/lustre/llite/llite_mmap.c
+++ b/fs/lustre/llite/llite_mmap.c
@@ -117,6 +117,9 @@ struct vm_area_struct *our_vma(struct mm_struct *mm, unsigned long addr,
 	else if (vma->vm_flags & VM_RAND_READ)
 		io->ci_rand_read = 1;
 
+	if (vma->vm_flags & VM_WRITE)
+		fio->ft_writable = 1;
+
 	rc = cl_io_init(env, io, CIT_FAULT, io->ci_obj);
 	if (rc == 0) {
 		struct vvp_io *vio = vvp_env_io(env);
@@ -128,7 +131,6 @@ struct vm_area_struct *our_vma(struct mm_struct *mm, unsigned long addr,
 		io->ci_lockreq = CILR_MANDATORY;
 		vio->vui_fd = fd;
 	} else {
-		LASSERT(rc < 0);
 		cl_io_fini(env, io);
 		if (io->ci_need_restart)
 			goto restart;
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index 12a28d9..12314fd 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -363,7 +363,8 @@ static void vvp_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 		io->ci_need_write_intent = 0;
 
 		LASSERT(io->ci_type == CIT_WRITE || cl_io_is_fallocate(io) ||
-			cl_io_is_trunc(io) || cl_io_is_mkwrite(io));
+			cl_io_is_trunc(io) || cl_io_is_mkwrite(io) ||
+			cl_io_is_fault_writable(io));
 
 		CDEBUG(D_VFSTRACE, DFID" write layout, type %u " DEXT "\n",
 		       PFID(lu_object_fid(&obj->co_lu)), io->ci_type,
diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index 86e3fbd..9012ad6 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -221,8 +221,9 @@ static int lov_io_mirror_write_intent(struct lov_io *lio,
 	*ext = (typeof(*ext)) { lio->lis_pos, lio->lis_endpos };
 	io->ci_need_write_intent = 0;
 
-	if (!(io->ci_type == CIT_WRITE || cl_io_is_trunc(io) ||
-	      cl_io_is_mkwrite(io)))
+	if (!(io->ci_type == CIT_WRITE || cl_io_is_mkwrite(io) ||
+	      cl_io_is_fallocate(io) || cl_io_is_trunc(io) ||
+	      cl_io_is_fault_writable(io)))
 		return 0;
 
 	/* FLR: check if it needs to send a write intent RPC to server.
@@ -574,7 +575,8 @@ static int lov_io_slice_init(struct lov_io *lio, struct lov_object *obj,
 	/* check if it needs to instantiate layout */
 	if (!(io->ci_type == CIT_WRITE || cl_io_is_mkwrite(io) ||
 	      cl_io_is_fallocate(io) ||
-	      (cl_io_is_trunc(io) && io->u.ci_setattr.sa_attr.lvb_size > 0))) {
+	      (cl_io_is_trunc(io) && io->u.ci_setattr.sa_attr.lvb_size > 0)) ||
+	      cl_io_is_fault_writable(io)) {
 		result = 0;
 		goto out;
 	}
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
