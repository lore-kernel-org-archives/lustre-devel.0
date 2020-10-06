From: James Simmons <jsimmons@infradead.org>
Date: Mon,  5 Oct 2020 20:06:02 -0400
Subject: [lustre-devel] [PATCH 23/42] lustre: llite: prune invalid dentries
In-Reply-To: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
References: <1601942781-24950-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1601942781-24950-24-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Lai Siyao <lai.siyao@whamcloud.com>

When file LOOKUP lock is canceled on client, mark its dentries
invalid, and also prune them to avoid OOM, to achieve this,
ll_invalidate_aliases() is renamed to ll_prune_aliases(), the latter
calls d_prune_aliases() to prune unused invalid dentries.

The same for negative dentries when parent UPDATE lock is canceled,
rename ll_invalidate_negative_children() to
ll_prune_negative_children().

Since now unused invalid dentries will always be pruned, it's not
necessary to call __d_drop() in d_lustre_invalidate().

It's redundant to take i_lock before d_lustre_invalidate() in
ll_inode_revalidate() because d_lustre_invalidate() takes d_lock,
remove it.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13909
Lustre-commit: 1f0b2a0dca6a3 ("LU-13909 llite: prune invalid dentries")
Signed-off-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/39685
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Reviewed-by: Yingjin Qian <qian@ddn.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dcache.c         | 15 ++++++---------
 fs/lustre/llite/file.c           |  7 ++-----
 fs/lustre/llite/llite_internal.h | 14 ++++++--------
 fs/lustre/llite/namei.c          | 40 +++++++++++++++++++++++++++-------------
 4 files changed, 41 insertions(+), 35 deletions(-)

diff --git a/fs/lustre/llite/dcache.c b/fs/lustre/llite/dcache.c
index e8b6fe8..0a6d773 100644
--- a/fs/lustre/llite/dcache.c
+++ b/fs/lustre/llite/dcache.c
@@ -183,7 +183,8 @@ void ll_intent_release(struct lookup_intent *it)
 	it->it_request = NULL;
 }
 
-void ll_invalidate_aliases(struct inode *inode)
+/* mark aliases invalid and prune unused aliases */
+void ll_prune_aliases(struct inode *inode)
 {
 	struct dentry *dentry;
 
@@ -191,15 +192,11 @@ void ll_invalidate_aliases(struct inode *inode)
 	       PFID(ll_inode2fid(inode)), inode);
 
 	spin_lock(&inode->i_lock);
-	hlist_for_each_entry(dentry, &inode->i_dentry, d_u.d_alias) {
-		CDEBUG(D_DENTRY,
-		       "dentry in drop %pd (%p) parent %p inode %p flags %d\n",
-		       dentry, dentry, dentry->d_parent,
-		       d_inode(dentry), dentry->d_flags);
-
-		d_lustre_invalidate(dentry, 0);
-	}
+	hlist_for_each_entry(dentry, &inode->i_dentry, d_u.d_alias)
+		d_lustre_invalidate(dentry);
 	spin_unlock(&inode->i_lock);
+
+	d_prune_aliases(inode);
 }
 
 int ll_revalidate_it_finish(struct ptlrpc_request *request,
diff --git a/fs/lustre/llite/file.c b/fs/lustre/llite/file.c
index 251cca5..babd24d 100644
--- a/fs/lustre/llite/file.c
+++ b/fs/lustre/llite/file.c
@@ -4614,11 +4614,8 @@ static int ll_inode_revalidate(struct dentry *dentry, enum ldlm_intent_flags op)
 	 * here to preserve get_cwd functionality on 2.6.
 	 * Bug 10503
 	 */
-	if (!d_inode(dentry)->i_nlink) {
-		spin_lock(&inode->i_lock);
-		d_lustre_invalidate(dentry, 0);
-		spin_unlock(&inode->i_lock);
-	}
+	if (!d_inode(dentry)->i_nlink)
+		d_lustre_invalidate(dentry);
 
 	ll_lookup_finish_locks(&oit, inode);
 out:
diff --git a/fs/lustre/llite/llite_internal.h b/fs/lustre/llite/llite_internal.h
index 8a0c40c..7c6eddd 100644
--- a/fs/lustre/llite/llite_internal.h
+++ b/fs/lustre/llite/llite_internal.h
@@ -1103,7 +1103,7 @@ int ll_dir_getstripe(struct inode *inode, void **plmm, int *plmm_size,
 extern const struct dentry_operations ll_d_ops;
 void ll_intent_drop_lock(struct lookup_intent *it);
 void ll_intent_release(struct lookup_intent *it);
-void ll_invalidate_aliases(struct inode *inode);
+void ll_prune_aliases(struct inode *inode);
 void ll_lookup_finish_locks(struct lookup_intent *it, struct inode *inode);
 int ll_revalidate_it_finish(struct ptlrpc_request *request,
 			    struct lookup_intent *it, struct inode *inode);
@@ -1560,21 +1560,19 @@ static inline int d_lustre_invalid(const struct dentry *dentry)
 
 /*
  * Mark dentry INVALID, if dentry refcount is zero (this is normally case for
- * ll_md_blocking_ast), unhash this dentry, and let dcache to reclaim it later;
- * else dput() of the last refcount will unhash this dentry and kill it.
+ * ll_md_blocking_ast), it will be pruned by ll_prune_aliases() and
+ * ll_prune_negative_children(); otherwise dput() of the last refcount will
+ * unhash this dentry and kill it.
  */
-static inline void d_lustre_invalidate(struct dentry *dentry, int nested)
+static inline void d_lustre_invalidate(struct dentry *dentry)
 {
 	CDEBUG(D_DENTRY,
 	       "invalidate dentry %pd (%p) parent %p inode %p refc %d\n",
 	       dentry, dentry,
 	       dentry->d_parent, d_inode(dentry), d_count(dentry));
 
-	spin_lock_nested(&dentry->d_lock,
-			 nested ? DENTRY_D_LOCK_NESTED : DENTRY_D_LOCK_NORMAL);
+	spin_lock(&dentry->d_lock);
 	ll_d2d(dentry)->lld_invalid = 1;
-	if (d_count(dentry) == 0)
-		__d_drop(dentry);
 	spin_unlock(&dentry->d_lock);
 }
 
diff --git a/fs/lustre/llite/namei.c b/fs/lustre/llite/namei.c
index ce6cd19..f9c10d0 100644
--- a/fs/lustre/llite/namei.c
+++ b/fs/lustre/llite/namei.c
@@ -152,22 +152,36 @@ struct inode *ll_iget(struct super_block *sb, ino_t hash,
 	return inode;
 }
 
-static void ll_invalidate_negative_children(struct inode *dir)
+/* mark negative sub file dentries invalid and prune unused dentries */
+static void ll_prune_negative_children(struct inode *dir)
 {
-	struct dentry *dentry, *tmp_subdir;
+	struct dentry *dentry;
+	struct dentry *child;
 
+restart:
 	spin_lock(&dir->i_lock);
 	hlist_for_each_entry(dentry, &dir->i_dentry, d_u.d_alias) {
 		spin_lock(&dentry->d_lock);
-		if (!list_empty(&dentry->d_subdirs)) {
-			struct dentry *child;
-
-			list_for_each_entry_safe(child, tmp_subdir,
-						 &dentry->d_subdirs,
-						 d_child) {
-				if (d_really_is_negative(child))
-					d_lustre_invalidate(child, 1);
+		list_for_each_entry(child, &dentry->d_subdirs, d_child) {
+			if (child->d_inode)
+				continue;
+
+			spin_lock_nested(&child->d_lock, DENTRY_D_LOCK_NESTED);
+			ll_d2d(child)->lld_invalid = 1;
+			if (!d_count(child)) {
+				dget_dlock(child);
+				__d_drop(child);
+				spin_unlock(&child->d_lock);
+				spin_unlock(&dentry->d_lock);
+				spin_unlock(&dir->i_lock);
+
+				CDEBUG(D_DENTRY, "prune negative dentry %pd\n",
+				       child);
+
+				dput(child);
+				goto restart;
 			}
+			spin_unlock(&child->d_lock);
 		}
 		spin_unlock(&dentry->d_lock);
 	}
@@ -345,18 +359,18 @@ static void ll_lock_cancel_bits(struct ldlm_lock *lock, u64 to_cancel)
 							ll_test_inode_by_fid,
 							(void *)&lli->lli_pfid);
 			if (master_inode) {
-				ll_invalidate_negative_children(master_inode);
+				ll_prune_negative_children(master_inode);
 				iput(master_inode);
 			}
 		} else {
-			ll_invalidate_negative_children(inode);
+			ll_prune_negative_children(inode);
 		}
 	}
 
 	if ((bits & (MDS_INODELOCK_LOOKUP | MDS_INODELOCK_PERM)) &&
 	    inode->i_sb->s_root &&
 	    !is_root_inode(inode))
-		ll_invalidate_aliases(inode);
+		ll_prune_aliases(inode);
 
 	if (bits & (MDS_INODELOCK_LOOKUP | MDS_INODELOCK_PERM))
 		forget_all_cached_acls(inode);
-- 
1.8.3.1
