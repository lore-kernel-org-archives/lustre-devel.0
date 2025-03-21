Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id EE51AC36001
	for <lustre-devel@archiver.kernel.org>; Fri, 21 Mar 2025 13:25:42 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4ZK2rB3Lddz20vC;
	Fri, 21 Mar 2025 06:10:50 -0700 (PDT)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4ZK2n44VvBz1y1d
 for <lustre-devel@lists.lustre.org>; Fri, 21 Mar 2025 06:08:08 -0700 (PDT)
Received: from star2.ccs.ornl.gov (ltm5-e204-208.ccs.ornl.gov [160.91.203.29])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 7B86788F9E9;
 Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 7892D106BE16; Fri, 21 Mar 2025 09:07:14 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Fri, 21 Mar 2025 09:06:55 -0400
Message-ID: <20250321130711.3257092-13-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250321130711.3257092-1-jsimmons@infradead.org>
References: <20250321130711.3257092-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 12/27] lustre: llite: convert functions to
 static
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
Cc: Arshad Hussain <arshad.hussain@aeoncomputing.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Timothy Day <timday@amazon.com>

Static analysis shows that a number of functions
could be made static. This patch declares several
functions in llite static.

Also, conserve more * in comments.

WC-bug-id: https://jira.whamcloud.com/browse/LU-8191
Lustre-commit: a586a2bbc37879dc2 ("LU-8191 llite: convert functions to static")
Signed-off-by: Timothy Day <timday@amazon.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/51441
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Arshad Hussain <arshad.hussain@aeoncomputing.com>
Reviewed-by: jsimmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dir.c       |  2 +-
 fs/lustre/llite/file.c      |  8 ++++----
 fs/lustre/llite/llite_lib.c |  6 +++---
 fs/lustre/llite/namei.c     |  2 +-
 fs/lustre/llite/pcc.c       |  6 +++---
 fs/lustre/llite/rw.c        |  2 +-
 fs/lustre/llite/vvp_dev.c   | 10 ++--------
 fs/lustre/llite/vvp_io.c    |  2 +-
 8 files changed, 16 insertions(+), 22 deletions(-)

diff --git a/fs/lustre/llite/dir.c b/fs/lustre/llite/dir.c
index a7a419abf45a..0c1b1ed31601 100644
--- a/fs/lustre/llite/dir.c
+++ b/fs/lustre/llite/dir.c
@@ -1346,7 +1346,7 @@ int quotactl_ioctl(struct super_block *sb, struct if_quotactl *qctl)
 	return rc;
 }
 
-int ll_rmfid(struct file *file, void __user *arg)
+static int ll_rmfid(struct file *file, void __user *arg)
 {
 	const struct fid_array __user *ufa = arg;
 	struct inode *inode = file_inode(file);
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index c7f77295d3b3..8564ee4a879c 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -4566,7 +4566,7 @@ ll_file_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	return rc;
 }
 
-loff_t ll_lseek(struct file *file, loff_t offset, int whence)
+static loff_t ll_lseek(struct file *file, loff_t offset, int whence)
 {
 	struct inode *inode = file_inode(file);
 	struct lu_env *env;
@@ -5496,8 +5496,8 @@ int ll_getattr(const struct path *path, struct kstat *stat,
 				 false);
 }
 
-int cl_falloc(struct file *file, struct inode *inode, int mode, loff_t offset,
-	      loff_t len)
+static int cl_falloc(struct file *file, struct inode *inode, int mode,
+		     loff_t offset, loff_t len)
 {
 	loff_t size = i_size_read(inode);
 	struct lu_env *env;
@@ -5559,7 +5559,7 @@ int cl_falloc(struct file *file, struct inode *inode, int mode, loff_t offset,
 	return rc;
 }
 
-long ll_fallocate(struct file *filp, int mode, loff_t offset, loff_t len)
+static long ll_fallocate(struct file *filp, int mode, loff_t offset, loff_t len)
 {
 	struct inode *inode = file_inode(filp);
 	int rc;
diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index 9adb7ef4ffac..b4d5b3dca0a7 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -1897,8 +1897,8 @@ static int ll_md_setattr(struct dentry *dentry, struct md_op_data *op_data)
  * Return:	0 on success
  *		errno on failure
  */
-int ll_io_zero_page(struct inode *inode, pgoff_t index, pgoff_t offset,
-		    unsigned int len)
+static int ll_io_zero_page(struct inode *inode, pgoff_t index, pgoff_t offset,
+			   unsigned int len)
 {
 	struct ll_inode_info *lli = ll_i2info(inode);
 	struct cl_object *clob = lli->lli_clob;
@@ -2753,7 +2753,7 @@ static inline bool ll_default_lmv_inherited(struct lmv_stripe_md *pdmv,
 /* if default LMV is implicitly inherited, subdir default LMV is maintained on
  * client side.
  */
-int ll_dir_default_lmv_inherit(struct inode *dir, struct inode *inode)
+static int ll_dir_default_lmv_inherit(struct inode *dir, struct inode *inode)
 {
 	struct ll_inode_info *plli = ll_i2info(dir);
 	struct ll_inode_info *lli = ll_i2info(inode);
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index 6159f8975847..79df426fcbbb 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -384,7 +384,7 @@ static void ll_lock_cancel_bits(struct ldlm_lock *lock, u64 to_cancel)
 /* Check if the given lock may be downgraded instead of canceling and
  * that convert is really needed.
  */
-int ll_md_need_convert(struct ldlm_lock *lock)
+static int ll_md_need_convert(struct ldlm_lock *lock)
 {
 	struct ldlm_namespace *ns = ldlm_lock_to_ns(lock);
 	struct inode *inode;
diff --git a/fs/lustre/llite/pcc.c b/fs/lustre/llite/pcc.c
index ac9124f9554e..677f5f38f100 100644
--- a/fs/lustre/llite/pcc.c
+++ b/fs/lustre/llite/pcc.c
@@ -795,7 +795,7 @@ pcc_dataset_add(struct pcc_super *super, struct pcc_cmd *cmd)
 	return rc;
 }
 
-struct pcc_dataset *
+static struct pcc_dataset *
 pcc_dataset_get(struct pcc_super *super, enum lu_pcc_type type, u32 id)
 {
 	struct pcc_dataset *dataset;
@@ -2152,8 +2152,8 @@ static int __pcc_inode_create(struct pcc_dataset *dataset,
  * Reset uid, gid or size for the PCC copy masked by @valid.
  * TODO: Set the project ID for PCC copy.
  */
-int pcc_inode_reset_iattr(struct dentry *dentry, unsigned int valid,
-			  kuid_t uid, kgid_t gid, loff_t size)
+static int pcc_inode_reset_iattr(struct dentry *dentry, unsigned int valid,
+				 kuid_t uid, kgid_t gid, loff_t size)
 {
 	struct inode *inode = dentry->d_inode;
 	struct iattr attr;
diff --git a/fs/lustre/llite/rw.c b/fs/lustre/llite/rw.c
index e258d995c54b..04fde756035f 100644
--- a/fs/lustre/llite/rw.c
+++ b/fs/lustre/llite/rw.c
@@ -150,7 +150,7 @@ void ll_ra_stats_inc(struct inode *inode, enum ra_stat which)
 	ll_ra_stats_inc_sbi(sbi, which);
 }
 
-void ll_ra_stats_add(struct inode *inode, enum ra_stat which, long count)
+static void ll_ra_stats_add(struct inode *inode, enum ra_stat which, long count)
 {
 	struct ll_sb_info *sbi = ll_i2sbi(inode);
 
diff --git a/fs/lustre/llite/vvp_dev.c b/fs/lustre/llite/vvp_dev.c
index 298720c5bfc2..0864ac499c4e 100644
--- a/fs/lustre/llite/vvp_dev.c
+++ b/fs/lustre/llite/vvp_dev.c
@@ -42,13 +42,9 @@
 #include "llite_internal.h"
 #include "vvp_internal.h"
 
-/*****************************************************************************
- *
+/*
  * Vvp device and device type functions.
  *
- */
-
-/*
  * vvp_ prefix stands for "Vfs Vm Posix". It corresponds to historical
  * "llite_" (var. "ll_") prefix.
  */
@@ -297,10 +293,8 @@ void vvp_global_fini(void)
 	lu_kmem_fini(vvp_caches);
 }
 
-/*****************************************************************************
- *
+/*
  * mirror obd-devices into cl devices.
- *
  */
 
 int cl_sb_init(struct super_block *sb)
diff --git a/fs/lustre/llite/vvp_io.c b/fs/lustre/llite/vvp_io.c
index acc9c2935485..1eb254b2a687 100644
--- a/fs/lustre/llite/vvp_io.c
+++ b/fs/lustre/llite/vvp_io.c
@@ -974,7 +974,7 @@ static int vvp_io_commit_sync(const struct lu_env *env, struct cl_io *io,
  * v5.2-rc4-224-ge01e060fe0
  *
  */
-void vvp_set_pagevec_dirty(struct pagevec *pvec)
+static void vvp_set_pagevec_dirty(struct pagevec *pvec)
 {
 	struct page *page = pvec->pages[0];
 	struct address_space *mapping = page->mapping;
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
