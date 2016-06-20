From: Oleg Drokin <green@linuxhacker.ru>
Date: Mon, 20 Jun 2016 16:55:26 -0400
Subject: [lustre-devel] [PATCH v2 03/29] staging/lustre/llite: Get rid of
	ll_lock_dcache/ll_unlock_dcache
In-Reply-To: <1466456152-2199975-1-git-send-email-green@linuxhacker.ru>
References: <1466456152-2199975-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1466456152-2199975-4-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

These are just doing spin_lock/unlock on inode's i_lock,
so just do the spinlock directly to make the code more clear

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/llite/dcache.c         |  4 ++--
 drivers/staging/lustre/lustre/llite/llite_internal.h | 10 ----------
 drivers/staging/lustre/lustre/llite/namei.c          |  8 ++++----
 3 files changed, 6 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dcache.c b/drivers/staging/lustre/lustre/llite/dcache.c
index 9d13d5e..f002b3a 100644
--- a/drivers/staging/lustre/lustre/llite/dcache.c
+++ b/drivers/staging/lustre/lustre/llite/dcache.c
@@ -249,7 +249,7 @@ void ll_invalidate_aliases(struct inode *inode)
 	CDEBUG(D_INODE, "marking dentries for ino "DFID"(%p) invalid\n",
 	       PFID(ll_inode2fid(inode)), inode);
 
-	ll_lock_dcache(inode);
+	spin_lock(&inode->i_lock);
 	hlist_for_each_entry(dentry, &inode->i_dentry, d_u.d_alias) {
 		CDEBUG(D_DENTRY, "dentry in drop %pd (%p) parent %p inode %p flags %d\n",
 		       dentry, dentry, dentry->d_parent,
@@ -257,7 +257,7 @@ void ll_invalidate_aliases(struct inode *inode)
 
 		d_lustre_invalidate(dentry, 0);
 	}
-	ll_unlock_dcache(inode);
+	spin_unlock(&inode->i_lock);
 }
 
 int ll_revalidate_it_finish(struct ptlrpc_request *request,
diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
index 74cd241..098155f 100644
--- a/drivers/staging/lustre/lustre/llite/llite_internal.h
+++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
@@ -1313,16 +1313,6 @@ static inline void ll_set_lock_data(struct obd_export *exp, struct inode *inode,
 		*bits = it->d.lustre.it_lock_bits;
 }
 
-static inline void ll_lock_dcache(struct inode *inode)
-{
-	spin_lock(&inode->i_lock);
-}
-
-static inline void ll_unlock_dcache(struct inode *inode)
-{
-	spin_unlock(&inode->i_lock);
-}
-
 static inline int d_lustre_invalid(const struct dentry *dentry)
 {
 	struct ll_dentry_data *lld = ll_d2d(dentry);
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 6414d52..e4df510 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -140,7 +140,7 @@ static void ll_invalidate_negative_children(struct inode *dir)
 {
 	struct dentry *dentry, *tmp_subdir;
 
-	ll_lock_dcache(dir);
+	spin_lock(&dir->i_lock);
 	hlist_for_each_entry(dentry, &dir->i_dentry, d_u.d_alias) {
 		spin_lock(&dentry->d_lock);
 		if (!list_empty(&dentry->d_subdirs)) {
@@ -155,7 +155,7 @@ static void ll_invalidate_negative_children(struct inode *dir)
 		}
 		spin_unlock(&dentry->d_lock);
 	}
-	ll_unlock_dcache(dir);
+	spin_unlock(&dir->i_lock);
 }
 
 int ll_md_blocking_ast(struct ldlm_lock *lock, struct ldlm_lock_desc *desc,
@@ -317,7 +317,7 @@ static struct dentry *ll_find_alias(struct inode *inode, struct dentry *dentry)
 	discon_alias = NULL;
 	invalid_alias = NULL;
 
-	ll_lock_dcache(inode);
+	spin_lock(&inode->i_lock);
 	hlist_for_each_entry(alias, &inode->i_dentry, d_u.d_alias) {
 		LASSERT(alias != dentry);
 
@@ -342,7 +342,7 @@ static struct dentry *ll_find_alias(struct inode *inode, struct dentry *dentry)
 		dget_dlock(alias);
 		spin_unlock(&alias->d_lock);
 	}
-	ll_unlock_dcache(inode);
+	spin_unlock(&inode->i_lock);
 
 	return alias;
 }
-- 
2.7.4
