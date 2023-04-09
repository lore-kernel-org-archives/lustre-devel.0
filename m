Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id D397EC77B70
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:20:43 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWJT1LBLz1yGS;
	Sun,  9 Apr 2023 05:15:05 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWGh0w3Nz1y6C
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:13:32 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id CD22E100826F;
 Sun,  9 Apr 2023 08:13:27 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id C0F8F2B4; Sun,  9 Apr 2023 08:13:27 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:12:43 -0400
Message-Id: <1681042400-15491-4-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 03/40] lustre: llite: SIGBUS is possible on a
 race with page reclaim
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
Cc: Patrick Farrell <farr0186@gmail.com>,
 Andrew Perepechko <andrew.perepechko@hpe.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Andrew Perepechko <andrew.perepechko@hpe.com>

We can restart fault handling if page truncation happens
in parallel with the fault handler.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16160
Lustre-commit: b4da788a819f82d35 ("LU-16160 llite: SIGBUS is possible on a race with page reclaim")
Signed-off-by: Andrew Perepechko <andrew.perepechko@hpe.com>
Signed-off-by: Patrick Farrell <farr0186@gmail.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/49647
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_internal.h |  4 ++++
 fs/lustre/llite/llite_lib.c      |  1 +
 fs/lustre/llite/llite_mmap.c     | 19 +++++++++++++++++++
 fs/lustre/llite/vvp_page.c       | 37 +++++++++++++++++++++++++++++++++++++
 fs/lustre/obdclass/cl_page.c     | 18 ------------------
 5 files changed, 61 insertions(+), 18 deletions(-)

diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index c42330e..0dac71d 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -47,6 +47,7 @@
 #include <linux/compat.h>
 #include <linux/aio.h>
 #include <linux/parser.h>
+#include <linux/seqlock.h>
 #include <lustre_crypto.h>
 #include <range_lock.h>
 #include <linux/namei.h>
@@ -287,6 +288,7 @@ struct ll_inode_info {
 	struct mutex			lli_xattrs_enq_lock;
 	struct list_head		lli_xattrs; /* ll_xattr_entry->xe_list */
 	struct list_head		lli_lccs; /* list of ll_cl_context */
+	seqlock_t			lli_page_inv_lock;
 };
 
 static inline void ll_trunc_sem_init(struct ll_trunc_sem *sem)
@@ -1834,4 +1836,6 @@ int ll_file_open_encrypt(struct inode *inode, struct file *filp)
 bool ll_foreign_is_openable(struct dentry *dentry, unsigned int flags);
 bool ll_foreign_is_removable(struct dentry *dentry, bool unset);
 
+int ll_filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf);
+
 #endif /* LLITE_INTERNAL_H */
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 30056a6..f84b6f5 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1213,6 +1213,7 @@ void ll_lli_init(struct ll_inode_info *lli)
 	memset(lli->lli_jobid, 0, sizeof(lli->lli_jobid));
 	/* ll_cl_context initialize */
 	INIT_LIST_HEAD(&lli->lli_lccs);
+	seqlock_init(&lli->lli_page_inv_lock);
 }
 
 int ll_fill_super(struct super_block *sb)
diff --git a/fs/lustre/llite/llite_mmap.c b/fs/lustre/llite/llite_mmap.c
index 4acc7ee..db069de 100644
--- a/fs/lustre/llite/llite_mmap.c
+++ b/fs/lustre/llite/llite_mmap.c
@@ -257,6 +257,25 @@ static inline vm_fault_t to_fault_error(int result)
 	return result;
 }
 
+int ll_filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	struct inode *inode = file_inode(vma->vm_file);
+	int ret;
+	unsigned int seq;
+
+	/* this seqlock lets us notice if a page has been deleted on this inode
+	 * during the fault process, allowing us to catch an erroneous SIGBUS
+	 * See LU-16160
+	 */
+	do {
+		seq = read_seqbegin(&ll_i2info(inode)->lli_page_inv_lock);
+		ret = filemap_fault(vmf);
+	} while (read_seqretry(&ll_i2info(inode)->lli_page_inv_lock, seq) &&
+		 (ret & VM_FAULT_SIGBUS));
+
+	return ret;
+}
+
 /**
  * Lustre implementation of a vm_operations_struct::fault() method, called by
  * VM to server page fault (both in kernel and user space).
diff --git a/fs/lustre/llite/vvp_page.c b/fs/lustre/llite/vvp_page.c
index f359596..30524fd 100644
--- a/fs/lustre/llite/vvp_page.c
+++ b/fs/lustre/llite/vvp_page.c
@@ -63,6 +63,42 @@ static void vvp_page_discard(const struct lu_env *env,
 		ll_ra_stats_inc(vmpage->mapping->host, RA_STAT_DISCARDED);
 }
 
+static void vvp_page_delete(const struct lu_env *env,
+			    const struct cl_page_slice *slice)
+{
+	struct cl_page *cp = slice->cpl_page;
+
+	if (cp->cp_type == CPT_CACHEABLE) {
+		struct page *vmpage = cp->cp_vmpage;
+		struct inode *inode = vmpage->mapping->host;
+
+		LASSERT(PageLocked(vmpage));
+		LASSERT((struct cl_page *)vmpage->private == cp);
+
+		/* Drop the reference count held in vvp_page_init */
+		refcount_dec(&cp->cp_ref);
+
+		ClearPagePrivate(vmpage);
+		vmpage->private = 0;
+
+		/* clearpageuptodate prevents the page being read by the
+		 * kernel after it has been deleted from Lustre, which avoids
+		 * potential stale data reads.  The seqlock allows us to see
+		 * that a page was potentially deleted and catch the resulting
+		 * SIGBUS - see ll_filemap_fault() (LU-16160)
+		 */
+		write_seqlock(&ll_i2info(inode)->lli_page_inv_lock);
+		ClearPageUptodate(vmpage);
+		write_sequnlock(&ll_i2info(inode)->lli_page_inv_lock);
+
+		/*
+		 * The reference from vmpage to cl_page is removed,
+		 * but the reference back is still here. It is removed
+		 * later in cl_page_free().
+		 */
+	}
+}
+
 /**
  * Handles page transfer errors at VM level.
  *
@@ -146,6 +182,7 @@ static void vvp_page_completion_write(const struct lu_env *env,
 }
 
 static const struct cl_page_operations vvp_page_ops = {
+	.cpo_delete		= vvp_page_delete,
 	.cpo_discard		= vvp_page_discard,
 	.io = {
 		[CRT_READ] = {
diff --git a/fs/lustre/obdclass/cl_page.c b/fs/lustre/obdclass/cl_page.c
index 7011235..62d8ee5 100644
--- a/fs/lustre/obdclass/cl_page.c
+++ b/fs/lustre/obdclass/cl_page.c
@@ -704,7 +704,6 @@ void cl_page_discard(const struct lu_env *env,
 static void __cl_page_delete(const struct lu_env *env, struct cl_page *cp)
 {
 	const struct cl_page_slice *slice;
-	struct page *vmpage;
 	int i;
 
 	PASSERT(env, cp, cp->cp_state != CPS_FREEING);
@@ -719,23 +718,6 @@ static void __cl_page_delete(const struct lu_env *env, struct cl_page *cp)
 		if (slice->cpl_ops->cpo_delete)
 			(*slice->cpl_ops->cpo_delete)(env, slice);
 	}
-
-	if (cp->cp_type == CPT_CACHEABLE) {
-		vmpage = cp->cp_vmpage;
-		LASSERT(PageLocked(vmpage));
-		LASSERT((struct cl_page *)vmpage->private == cp);
-
-		/* Drop the reference count held in vvp_page_init */
-		refcount_dec(&cp->cp_ref);
-		ClearPagePrivate(vmpage);
-		vmpage->private = 0;
-
-		/*
-		 * The reference from vmpage to cl_page is removed,
-		 * but the reference back is still here. It is removed
-		 * later in cl_page_free().
-		 */
-	}
 }
 
 /**
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
