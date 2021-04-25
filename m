Return-Path: <SRS0=Gt0B=JW=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B319FC433B4
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:09:15 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 15B39611ED
	for <lustre-devel@archiver.kernel.org>; Sun, 25 Apr 2021 20:09:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15B39611ED
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A349E21F846;
	Sun, 25 Apr 2021 13:09:01 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 50A6B21F7E2
 for <lustre-devel@lists.lustre.org>; Sun, 25 Apr 2021 13:08:48 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 4858710087D3;
 Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 4364669A64; Sun, 25 Apr 2021 16:08:40 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 25 Apr 2021 16:08:31 -0400
Message-Id: <1619381316-7719-25-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
References: <1619381316-7719-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 24/29] lustre: llite: do fallocate() size
 checks under lock
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

Check about fallocate() range vs file size in vvp_io_setattr_start()
instead of ll_fallocate() so inode size cannot be changed by pending
write or truncate. This implies that IO is initialized already and
requires changes in LOV to update sub-IOs with proper inode size and
valid size attribute values

Fix also vvp_io_setattr_lock() to don't include fallocate_end in
lock range

WC-bug-id: https://jira.whamcloud.com/browse/LU-14433
Luste-commit: f23ac22c4c79750fe ("LU-14433 llite: do fallocate() size checks under lock")
Signed-off-by: Mikhail Pershin <mpershin@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/41668
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/file.c   |  5 -----
 fs/lustre/llite/vvp_io.c | 22 +++++++++++++++++++---
 fs/lustre/lov/lov_io.c   | 28 ++++++++++++++++++++++++++--
 3 files changed, 45 insertions(+), 10 deletions(-)

diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 1ca4589..c049433 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -5028,11 +5028,6 @@ int cl_falloc(struct inode *inode, int mode, loff_t offset, loff_t len)
 			rc = -EFBIG;
 			goto out;
 		}
-		io->u.ci_setattr.sa_attr.lvb_size = sa_falloc_end;
-		if (!(mode & FALLOC_FL_KEEP_SIZE))
-			io->u.ci_setattr.sa_avalid |= ATTR_SIZE;
-	} else {
-		io->u.ci_setattr.sa_attr.lvb_size = size;
 	}
 
 again:
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index cb59e94..38a9430 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -41,6 +41,8 @@
 #include <obd.h>
 #include <linux/pagevec.h>
 #include <linux/memcontrol.h>
+#include <linux/falloc.h>
+
 #include "llite_internal.h"
 #include "vvp_internal.h"
 
@@ -647,7 +649,7 @@ static int vvp_io_setattr_lock(const struct lu_env *env,
 			enqflags = CEF_DISCARD_DATA;
 	} else if (cl_io_is_fallocate(io)) {
 		lock_start = io->u.ci_setattr.sa_falloc_offset;
-		lock_end = io->u.ci_setattr.sa_falloc_end;
+		lock_end = io->u.ci_setattr.sa_falloc_end - 1;
 	} else {
 		unsigned int valid = io->u.ci_setattr.sa_avalid;
 
@@ -715,14 +717,27 @@ static int vvp_io_setattr_start(const struct lu_env *env,
 	struct cl_io *io = ios->cis_io;
 	struct inode *inode = vvp_object_inode(io->ci_obj);
 	struct ll_inode_info *lli = ll_i2info(inode);
+	int mode = io->u.ci_setattr.sa_falloc_mode;
 
 	if (cl_io_is_trunc(io)) {
 		trunc_sem_down_write(&lli->lli_trunc_sem);
 		mutex_lock(&lli->lli_setattr_mutex);
 		inode_dio_wait(inode);
 	} else if (cl_io_is_fallocate(io)) {
-		inode_lock(inode);
+		loff_t size;
+
+		trunc_sem_down_write(&lli->lli_trunc_sem);
+		mutex_lock(&lli->lli_setattr_mutex);
 		inode_dio_wait(inode);
+
+		ll_merge_attr(env, inode);
+		size = i_size_read(inode);
+		if (io->u.ci_setattr.sa_falloc_end > size &&
+		    !(mode & FALLOC_FL_KEEP_SIZE)) {
+			size = io->u.ci_setattr.sa_falloc_end;
+			io->u.ci_setattr.sa_avalid |= ATTR_SIZE;
+		}
+		io->u.ci_setattr.sa_attr.lvb_size = size;
 	} else {
 		mutex_lock(&lli->lli_setattr_mutex);
 	}
@@ -748,7 +763,8 @@ static void vvp_io_setattr_end(const struct lu_env *env,
 		mutex_unlock(&lli->lli_setattr_mutex);
 		trunc_sem_up_write(&lli->lli_trunc_sem);
 	} else if (cl_io_is_fallocate(io)) {
-		inode_unlock(inode);
+		mutex_unlock(&lli->lli_setattr_mutex);
+		trunc_sem_up_write(&lli->lli_trunc_sem);
 	} else {
 		mutex_unlock(&lli->lli_setattr_mutex);
 	}
diff --git a/fs/lustre/lov/lov_io.c b/fs/lustre/lov/lov_io.c
index ae9d547..7da0047 100644
--- a/fs/lustre/lov/lov_io.c
+++ b/fs/lustre/lov/lov_io.c
@@ -681,7 +681,7 @@ static void lov_io_sub_inherit(struct lov_io_sub *sub, struct lov_io *lio,
 			io->u.ci_setattr.sa_falloc_offset = start;
 			io->u.ci_setattr.sa_falloc_end = end;
 		}
-		if (cl_io_is_trunc(io) || cl_io_is_fallocate(io)) {
+		if (cl_io_is_trunc(io)) {
 			loff_t new_size = parent->u.ci_setattr.sa_attr.lvb_size;
 
 			new_size = lov_size_to_stripe(lsm, index, new_size,
@@ -1441,6 +1441,30 @@ static int lov_io_fault_start(const struct lu_env *env,
 	return lov_io_start(env, ios);
 }
 
+static int lov_io_setattr_start(const struct lu_env *env,
+				const struct cl_io_slice *ios)
+{
+	struct lov_io *lio = cl2lov_io(env, ios);
+	struct cl_io *parent = ios->cis_io;
+	struct lov_io_sub *sub;
+	struct lov_stripe_md *lsm = lio->lis_object->lo_lsm;
+
+	if (cl_io_is_fallocate(parent)) {
+		list_for_each_entry(sub, &lio->lis_active, sub_linkage) {
+			loff_t size = parent->u.ci_setattr.sa_attr.lvb_size;
+			int index = lov_comp_entry(sub->sub_subio_index);
+			int stripe = lov_comp_stripe(sub->sub_subio_index);
+
+			size = lov_size_to_stripe(lsm, index, size, stripe);
+			sub->sub_io.u.ci_setattr.sa_attr.lvb_size = size;
+			sub->sub_io.u.ci_setattr.sa_avalid =
+						parent->u.ci_setattr.sa_avalid;
+		}
+	}
+
+	return lov_io_start(env, ios);
+}
+
 static void lov_io_fsync_end(const struct lu_env *env,
 			     const struct cl_io_slice *ios)
 {
@@ -1577,7 +1601,7 @@ static void lov_io_lseek_end(const struct lu_env *env,
 			.cio_iter_fini	= lov_io_iter_fini,
 			.cio_lock	= lov_io_lock,
 			.cio_unlock	= lov_io_unlock,
-			.cio_start	= lov_io_start,
+			.cio_start	= lov_io_setattr_start,
 			.cio_end	= lov_io_end
 		},
 		[CIT_DATA_VERSION] = {
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
