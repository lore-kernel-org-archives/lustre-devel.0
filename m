Return-Path: <SRS0=2ypu=OM=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 736D3C433EF
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:21:48 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3E373610A1
	for <lustre-devel@archiver.kernel.org>; Wed, 22 Sep 2021 02:21:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.1 mail.kernel.org 3E373610A1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 5777521CBD5;
	Tue, 21 Sep 2021 19:21:47 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id CDB4D21CB9F
 for <lustre-devel@lists.lustre.org>; Tue, 21 Sep 2021 19:20:12 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 47211491;
 Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 45C25FF4BF; Tue, 21 Sep 2021 22:20:04 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Tue, 21 Sep 2021 22:20:01 -0400
Message-Id: <1632277201-6920-25-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
References: <1632277201-6920-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 24/24] lustre: pcc: VM_WRITE should not
 trigger layout write
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

VM area marked with VM_WRITE means that pages may be written, but
mmap page write may never happen.
It should delay layout write until the actual modification on the
file happen in ->page_mkwrite().
Otherwise, it will trigger panic for PCC-RO sanity-pcc test_21f().

Fixes: 0b5ce361e ("lustre: flr: mmap write/punch does not stale other mirrors")
WC-bug-id: https://jira.whamcloud.com/browse/LU-14709
Lustre-commit: 373475a4f448c8e26 ("LU-14709 pcc: VM_WRITE should not trigger layout write")
Signed-off-by: Qian Yingjin <qian@ddn.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/44483
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h |  5 -----
 fs/lustre/llite/llite_mmap.c  | 19 ++++++++++---------
 fs/lustre/llite/vvp_io.c      |  3 +--
 fs/lustre/lov/lov_io.c        |  6 ++----
 4 files changed, 13 insertions(+), 20 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index d068454..a65240b 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -2465,11 +2465,6 @@ int cl_io_lru_reserve(const struct lu_env *env, struct cl_io *io,
 int cl_io_read_ahead(const struct lu_env *env, struct cl_io *io,
 		     pgoff_t start, struct cl_read_ahead *ra);
 
-static inline int cl_io_is_fault_writable(const struct cl_io *io)
-{
-	return io->ci_type == CIT_FAULT && io->u.ci_fault.ft_writable;
-}
-
 /**
  * True, if @io is an O_APPEND write(2).
  */
diff --git a/fs/lustre/llite/llite_mmap.c b/fs/lustre/llite/llite_mmap.c
index 85a082c..8238a4e 100644
--- a/fs/lustre/llite/llite_mmap.c
+++ b/fs/lustre/llite/llite_mmap.c
@@ -83,11 +83,13 @@ struct vm_area_struct *our_vma(struct mm_struct *mm, unsigned long addr,
  * @vma		virtual memory area addressed to page fault
  * @env		corespondent lu_env to processing
  * @index	page index corespondent to fault.
+ * @mkwrite	whether it is mmap write.
  *
  * RETURN	error codes from cl_io_init.
  */
 static struct cl_io *
-ll_fault_io_init(struct lu_env *env, struct vm_area_struct *vma, pgoff_t index)
+ll_fault_io_init(struct lu_env *env, struct vm_area_struct *vma,
+		 pgoff_t index, bool mkwrite)
 {
 	struct file *file = vma->vm_file;
 	struct inode *inode = file_inode(file);
@@ -107,6 +109,11 @@ struct vm_area_struct *our_vma(struct mm_struct *mm, unsigned long addr,
 	fio->ft_index = index;
 	fio->ft_executable = vma->vm_flags & VM_EXEC;
 
+	if (mkwrite) {
+		fio->ft_mkwrite = 1;
+		fio->ft_writable = 1;
+	}
+
 	CDEBUG(D_MMAP,
 	       DFID": vma=%p start=%#lx end=%#lx vm_flags=%#lx idx=%lu\n",
 	       PFID(&ll_i2info(inode)->lli_fid), vma, vma->vm_start,
@@ -117,9 +124,6 @@ struct vm_area_struct *our_vma(struct mm_struct *mm, unsigned long addr,
 	else if (vma->vm_flags & VM_RAND_READ)
 		io->ci_rand_read = 1;
 
-	if (vma->vm_flags & VM_WRITE)
-		fio->ft_writable = 1;
-
 	rc = cl_io_init(env, io, CIT_FAULT, io->ci_obj);
 	if (rc == 0) {
 		struct vvp_io *vio = vvp_env_io(env);
@@ -157,7 +161,7 @@ static int __ll_page_mkwrite(struct vm_area_struct *vma, struct page *vmpage,
 	if (IS_ERR(env))
 		return PTR_ERR(env);
 
-	io = ll_fault_io_init(env, vma, vmpage->index);
+	io = ll_fault_io_init(env, vma, vmpage->index, true);
 	if (IS_ERR(io)) {
 		result = PTR_ERR(io);
 		goto out;
@@ -167,9 +171,6 @@ static int __ll_page_mkwrite(struct vm_area_struct *vma, struct page *vmpage,
 	if (result < 0)
 		goto out_io;
 
-	io->u.ci_fault.ft_mkwrite = 1;
-	io->u.ci_fault.ft_writable = 1;
-
 	vio = vvp_env_io(env);
 	vio->u.fault.ft_vma = vma;
 	vio->u.fault.ft_vmpage = vmpage;
@@ -309,7 +310,7 @@ static vm_fault_t __ll_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 		fault_ret = 0;
 	}
 
-	io = ll_fault_io_init(env, vma, vmf->pgoff);
+	io = ll_fault_io_init(env, vma, vmf->pgoff, false);
 	if (IS_ERR(io)) {
 		fault_ret = to_fault_error(PTR_ERR(io));
 		goto out;
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index a117800..d8951ac 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -363,8 +363,7 @@ static void vvp_io_fini(const struct lu_env *env, const struct cl_io_slice *ios)
 		io->ci_need_write_intent = 0;
 
 		LASSERT(io->ci_type == CIT_WRITE || cl_io_is_fallocate(io) ||
-			cl_io_is_trunc(io) || cl_io_is_mkwrite(io) ||
-			cl_io_is_fault_writable(io));
+			cl_io_is_trunc(io) || cl_io_is_mkwrite(io));
 
 		CDEBUG(D_VFSTRACE, DFID" write layout, type %u " DEXT "\n",
 		       PFID(lu_object_fid(&obj->co_lu)), io->ci_type,
diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index 2885943..eb71d7a 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -222,8 +222,7 @@ static int lov_io_mirror_write_intent(struct lov_io *lio,
 	io->ci_need_write_intent = 0;
 
 	if (!(io->ci_type == CIT_WRITE || cl_io_is_mkwrite(io) ||
-	      cl_io_is_fallocate(io) || cl_io_is_trunc(io) ||
-	      cl_io_is_fault_writable(io)))
+	      cl_io_is_fallocate(io) || cl_io_is_trunc(io)))
 		return 0;
 
 	/* FLR: check if it needs to send a write intent RPC to server.
@@ -575,8 +574,7 @@ static int lov_io_slice_init(struct lov_io *lio, struct lov_object *obj,
 	/* check if it needs to instantiate layout */
 	if (!(io->ci_type == CIT_WRITE || cl_io_is_mkwrite(io) ||
 	      cl_io_is_fallocate(io) ||
-	      (cl_io_is_trunc(io) && io->u.ci_setattr.sa_attr.lvb_size > 0)) ||
-	      cl_io_is_fault_writable(io)) {
+	      (cl_io_is_trunc(io) && io->u.ci_setattr.sa_attr.lvb_size > 0))) {
 		result = 0;
 		goto out;
 	}
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
