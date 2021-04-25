Return-Path: <SRS0=Gt0B=JW=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.9 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNWANTED_LANGUAGE_BODY,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EBF7CC433ED
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:10:09 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id ADF7E611ED
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:10:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADF7E611ED
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 43CE921F8A5;
	Sun, 25 Apr 2021 13:09:37 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id E94E721F7E9
 for <lustre-devel@lists.lustre.org>; Sun, 25 Apr 2021 13:08:48 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 4EA2010087D5;
 Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 4D4E569A63; Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 25 Apr 2021 16:08:33 -0400
Message-Id: <1619381316-7719-27-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
References: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 26/29] lustre: fallocate: Add punch mode to
 fallocate
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
Cc: Arshad Hussain <arshad.hussain@aeoncomputing.com>,
 Mikhail Pershin <mpershin@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Arshad Hussain <arshad.hussain@aeoncomputing.com>

This patch adds fallocate(2) punch operation
(FALLOCATE_FL_PUNCH_HOLE) mode support for ldiskfs backend
OSD and for OSC/OST

WC-bug-id: https://jira.whamcloud.com/browse/LU-14160
Lustre-commit: cb037f305c64cd512 ("LU-14160 fallocate: Add punch mode to fallocate")
Signed-off-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/40877
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/cl_object.h |  1 -
 fs/lustre/llite/file.c        | 43 ++++++++++++++-------------
 fs/lustre/mdc/mdc_dev.c       |  3 ++
 fs/lustre/osc/osc_io.c        | 68 +++++++++++++++++++++++++------------------
 fs/lustre/osc/osc_request.c   |  7 -----
 5 files changed, 65 insertions(+), 57 deletions(-)

diff --git a/fs/lustre/include/cl_object.h b/fs/lustre/include/cl_object.h
index 3926aac..b69c04a 100644
--- a/fs/lustre/include/cl_object.h
+++ b/fs/lustre/include/cl_object.h
@@ -1876,7 +1876,6 @@ struct cl_io {
 			/* The following are used for fallocate(2) */
 			int			sa_falloc_mode;
 			loff_t			sa_falloc_offset;
-			loff_t			sa_falloc_len;
 			loff_t			sa_falloc_end;
 		} ci_setattr;
 		struct cl_data_version_io {
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 15072bb1..c8f250c 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -4998,7 +4998,7 @@ int cl_falloc(struct inode *inode, int mode, loff_t offset, loff_t len)
 	struct lu_env *env;
 	struct cl_io *io;
 	u16 refcheck;
-	int rc; loff_t sa_falloc_end;
+	int rc;
 	loff_t size = i_size_read(inode);
 
 	env = cl_env_get(&refcheck);
@@ -5011,34 +5011,32 @@ int cl_falloc(struct inode *inode, int mode, loff_t offset, loff_t len)
 	io->u.ci_setattr.sa_parent_fid = lu_object_fid(&io->ci_obj->co_lu);
 	io->u.ci_setattr.sa_falloc_mode = mode;
 	io->u.ci_setattr.sa_falloc_offset = offset;
-	io->u.ci_setattr.sa_falloc_len = len;
-	io->u.ci_setattr.sa_falloc_end = io->u.ci_setattr.sa_falloc_offset +
-					 io->u.ci_setattr.sa_falloc_len;
+	io->u.ci_setattr.sa_falloc_end = offset + len;
 	io->u.ci_setattr.sa_subtype = CL_SETATTR_FALLOCATE;
-	sa_falloc_end = io->u.ci_setattr.sa_falloc_end;
-	if (sa_falloc_end > size) {
+	if (io->u.ci_setattr.sa_falloc_end > size) {
+		loff_t newsize = io->u.ci_setattr.sa_falloc_end;
+
 		/* Check new size against VFS/VM file size limit and rlimit */
-		rc = inode_newsize_ok(inode, sa_falloc_end);
+		rc = inode_newsize_ok(inode, newsize);
 		if (rc)
 			goto out;
-		if (sa_falloc_end > ll_file_maxbytes(inode)) {
+		if (newsize > ll_file_maxbytes(inode)) {
 			CDEBUG(D_INODE, "file size too large %llu > %llu\n",
-			       (unsigned long long)(sa_falloc_end),
+			       (unsigned long long)newsize,
 			       ll_file_maxbytes(inode));
 			rc = -EFBIG;
 			goto out;
 		}
 	}
 
-again:
-	if (cl_io_init(env, io, CIT_SETATTR, io->ci_obj) == 0)
-		rc = cl_io_loop(env, io);
-	else
-		rc = io->ci_result;
-
-	cl_io_fini(env, io);
-	if (unlikely(io->ci_need_restart))
-		goto again;
+	do {
+		rc = cl_io_init(env, io, CIT_SETATTR, io->ci_obj);
+		if (rc)
+			rc = io->ci_result;
+		else
+			rc = cl_io_loop(env, io);
+		cl_io_fini(env, io);
+	} while (unlikely(io->ci_need_restart));
 
 out:
 	cl_env_put(env, &refcheck);
@@ -5050,6 +5048,9 @@ long ll_fallocate(struct file *filp, int mode, loff_t offset, loff_t len)
 	struct inode *inode = filp->f_path.dentry->d_inode;
 	int rc;
 
+	if (offset < 0 || len <= 0)
+		return -EINVAL;
+
 	/*
 	 * Encrypted inodes can't handle collapse range or zero range or insert
 	 * range since we would need to re-encrypt blocks with a different IV or
@@ -5062,10 +5063,10 @@ long ll_fallocate(struct file *filp, int mode, loff_t offset, loff_t len)
 		return -EOPNOTSUPP;
 
 	/*
-	 * Only mode == 0 (which is standard prealloc) is supported now.
-	 * Punch is not supported yet.
+	 * mode == 0 (which is standard prealloc) and PUNCH is supported.
+	 * Rest of mode options are not supported yet.
 	 */
-	if (mode & ~FALLOC_FL_KEEP_SIZE)
+	if (mode & ~(FALLOC_FL_KEEP_SIZE | FALLOC_FL_PUNCH_HOLE))
 		return -EOPNOTSUPP;
 
 	ll_stats_ops_tally(ll_i2sbi(inode), LPROC_LL_FALLOCATE, 1);
diff --git a/fs/lustre/mdc/mdc_dev.c b/fs/lustre/mdc/mdc_dev.c
index 7807f9e..70f8987 100644
--- a/fs/lustre/mdc/mdc_dev.c
+++ b/fs/lustre/mdc/mdc_dev.c
@@ -1046,6 +1046,9 @@ static int mdc_io_setattr_start(const struct lu_env *env,
 			return rc;
 	}
 
+	if (cl_io_is_fallocate(io))
+		return -EOPNOTSUPP;
+
 	if (oio->oi_lockless == 0) {
 		cl_object_attr_lock(obj);
 		rc = cl_object_attr_get(env, obj, attr);
diff --git a/fs/lustre/osc/osc_io.c b/fs/lustre/osc/osc_io.c
index 9d783e0..3be3cfe 100644
--- a/fs/lustre/osc/osc_io.c
+++ b/fs/lustre/osc/osc_io.c
@@ -530,6 +530,29 @@ static void osc_trunc_check(const struct lu_env *env, struct cl_io *io,
 			     trunc_check_cb, (void *)&size);
 }
 
+/**
+ * Flush affected pages prior punch.
+ * We shouldn't discard them locally first because that could be data loss
+ * if server doesn't support fallocate punch, we also need these data to be
+ * flushed first to prevent re-ordering with the punch
+ */
+static int osc_punch_start(const struct lu_env *env, struct cl_io *io,
+			   struct cl_object *obj)
+{
+	struct osc_object *osc = cl2osc(obj);
+	pgoff_t pg_start = cl_index(obj, io->u.ci_setattr.sa_falloc_offset);
+	pgoff_t pg_end = cl_index(obj, io->u.ci_setattr.sa_falloc_end - 1);
+	int rc;
+
+	rc = osc_cache_writeback_range(env, osc, pg_start, pg_end, 1, 0);
+	if (rc < 0)
+		return rc;
+
+	osc_page_gang_lookup(env, io, osc, pg_start, pg_end, osc_discard_cb,
+			     osc);
+	return 0;
+}
+
 static int osc_io_setattr_start(const struct lu_env *env,
 				const struct cl_io_slice *slice)
 {
@@ -543,19 +566,17 @@ static int osc_io_setattr_start(const struct lu_env *env,
 	unsigned int ia_avalid = io->u.ci_setattr.sa_avalid;
 	enum op_xvalid ia_xvalid = io->u.ci_setattr.sa_xvalid;
 	u64 size = io->u.ci_setattr.sa_attr.lvb_size;
-	u64 end = OBD_OBJECT_EOF;
-	bool io_is_falloc = false;
+	bool io_is_falloc = cl_io_is_fallocate(io);
 	int result = 0;
 
 	/* truncate cache dirty pages first */
-	if (cl_io_is_trunc(io)) {
+	if (cl_io_is_trunc(io))
 		result = osc_cache_truncate_start(env, cl2osc(obj), size,
 						  &oio->oi_trunc);
-	} else if (cl_io_is_fallocate(io)) {
-		io_is_falloc = true;
-		size = io->u.ci_setattr.sa_falloc_offset;
-		end = io->u.ci_setattr.sa_falloc_end;
-	}
+	/* flush local pages prior punching them on server */
+	if (io_is_falloc &&
+	    io->u.ci_setattr.sa_falloc_mode & FALLOC_FL_PUNCH_HOLE)
+		result = osc_punch_start(env, io, obj);
 
 	if (result == 0 && oio->oi_lockless == 0) {
 		cl_object_attr_lock(obj);
@@ -565,14 +586,8 @@ static int osc_io_setattr_start(const struct lu_env *env,
 			unsigned int cl_valid = 0;
 
 			if (ia_avalid & ATTR_SIZE) {
-				if (io_is_falloc) {
-					attr->cat_size =
-						io->u.ci_setattr.sa_attr.lvb_size;
-					attr->cat_kms = attr->cat_size;
-				} else {
-					attr->cat_size = size;
-					attr->cat_kms = size;
-				}
+				attr->cat_size = size;
+				attr->cat_kms = size;
 				cl_valid = CAT_SIZE | CAT_KMS;
 			}
 			if (ia_avalid & ATTR_MTIME_SET) {
@@ -612,17 +627,8 @@ static int osc_io_setattr_start(const struct lu_env *env,
 			oa->o_valid |= OBD_MD_FLMTIME;
 			oa->o_mtime = attr->cat_mtime;
 		}
-		if (ia_avalid & ATTR_SIZE) {
-			if (io_is_falloc) {
-				oa->o_size = size;
-				oa->o_blocks = end;
-				oa->o_valid |= OBD_MD_FLSIZE | OBD_MD_FLBLOCKS;
-			} else {
-				oa->o_size = size;
-				oa->o_blocks = OBD_OBJECT_EOF;
-				oa->o_valid |= OBD_MD_FLSIZE | OBD_MD_FLBLOCKS;
-			}
 
+		if (ia_avalid & ATTR_SIZE || io_is_falloc) {
 			if (oio->oi_lockless) {
 				oa->o_flags = OBD_FL_SRVLOCK;
 				oa->o_valid |= OBD_MD_FLFLAGS;
@@ -646,10 +652,16 @@ static int osc_io_setattr_start(const struct lu_env *env,
 		if (io_is_falloc) {
 			int falloc_mode = io->u.ci_setattr.sa_falloc_mode;
 
+			oa->o_size = io->u.ci_setattr.sa_falloc_offset;
+			oa->o_blocks = io->u.ci_setattr.sa_falloc_end;
+			oa->o_valid |= OBD_MD_FLSIZE | OBD_MD_FLBLOCKS;
 			result = osc_fallocate_base(osc_export(cl2osc(obj)),
 						    oa, osc_async_upcall,
 						    cbargs, falloc_mode);
 		} else if (ia_avalid & ATTR_SIZE) {
+			oa->o_size = size;
+			oa->o_blocks = OBD_OBJECT_EOF;
+			oa->o_valid |= OBD_MD_FLSIZE | OBD_MD_FLBLOCKS;
 			result = osc_punch_send(osc_export(cl2osc(obj)),
 						oa, osc_async_upcall, cbargs);
 		} else {
@@ -682,11 +694,11 @@ void osc_io_setattr_end(const struct lu_env *env,
 	if (result == 0) {
 		if (oio->oi_lockless) {
 			/* lockless truncate */
-			struct osc_device *osd = lu2osc_dev(obj->co_lu.lo_dev);
+			struct osc_device *osc = lu2osc_dev(obj->co_lu.lo_dev);
 
 			LASSERT(cl_io_is_trunc(io) || cl_io_is_fallocate(io));
 			/* XXX: Need a lock. */
-			osd->od_stats.os_lockless_truncates++;
+			osc->od_stats.os_lockless_truncates++;
 		}
 	}
 
diff --git a/fs/lustre/osc/osc_request.c b/fs/lustre/osc/osc_request.c
index 973c504..376afb9 100644
--- a/fs/lustre/osc/osc_request.c
+++ b/fs/lustre/osc/osc_request.c
@@ -454,14 +454,7 @@ int osc_fallocate_base(struct obd_export *exp, struct obdo *oa,
 	struct obd_import *imp = class_exp2cliimp(exp);
 	int rc;
 
-	/*
-	 * Only mode == 0 (which is standard prealloc) is supported now.
-	 * Punch is not supported yet.
-	 */
-	if (mode & ~FALLOC_FL_KEEP_SIZE)
-		return -EOPNOTSUPP;
 	oa->o_falloc_mode = mode;
-
 	req = ptlrpc_request_alloc(class_exp2cliimp(exp),
 				   &RQF_OST_FALLOCATE);
 	if (!req)
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
