From: NeilBrown <neilb@suse.com>
Date: Wed, 19 Jul 2017 09:26:47 +1000
Subject: [lustre-devel] [PATCH 03/12] staging: lustre: llite: fix various
 issues with ll_splice_alias.
In-Reply-To: <150041997277.20736.17112251996623587423.stgit@noble>
References: <150041997277.20736.17112251996623587423.stgit@noble>
Message-ID: <150042040744.20736.6110134708456645941.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <greg@kroah.com>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

1/ The testing of DCACHE_DISCONNECTED is wrong.
  see upstream commit da093a9b76ef ("dcache: d_splice_alias should
  ignore DCACHE_DISCONNECTED")

  As this is a notoriously difficult piece of code to get right,
  it makes sense to use d_splice_alias() directly and no try to
  create a local version of it.

2/ ll_find_alias() currently:
     locks and alias
     checks that it is the one we want
     unlock it
     locks it again
     gets a reference
     unlocks it

   This isn't safe.  Anything could happen to the dentry while we
   don't hold a reference.  We need to dget the reference while
   still holding the lock.

3/ The d_move() in ll_splice_alias() is pointless.  We have
    already checked the hash, name, and parent are the same, and
    these are the only fields that d_move() will change.

4/ The call to d_add() is outside of any locking. This makes it
   possible for two identical dentries to be added to the same
   inode, which would cause confusion.

   Prior to 4.7, i_mutex would have provided exclusion, but since
   the VFS supports parallel lookups, only a shared lock is held
   on i_mutex.

   Because ll_d_init() creates a dentry in a state where
   ll_dcompare will no recognize it, the VFS provides no guarantee
   that we won't have two concurrent calls to ll_lookup_dn() for
   the same parent/name.


So: rename ll_find_alias() to ll_find_invalid_alias() and have it
just focus on finding an invalid alias.

For directories, we can just use d__splice_alias() directly.
There must only be one alias for a directory, and
ll_splice_alias() will find it where it is "invalid" or not.

For non-directories, we call ll_find_invalid_alias(), and either
use the result or call d_add().  We need a lock to protect from
races with other threads calling ll_find_invalid_alias() and
d_add() at the same time. lli_lock seems suitable for this
purpose.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/llite/namei.c |   69 +++++++++++++--------------
 1 file changed, 34 insertions(+), 35 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 293a3180ec70..6204c3e70d45 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -378,75 +378,74 @@ void ll_i2gids(__u32 *suppgids, struct inode *i1, struct inode *i2)
 }
 
 /*
- * try to reuse three types of dentry:
- * 1. unhashed alias, this one is unhashed by d_invalidate (but it may be valid
- *    by concurrent .revalidate).
- * 2. INVALID alias (common case for no valid ldlm lock held, but this flag may
- *    be cleared by others calling d_lustre_revalidate).
- * 3. DISCONNECTED alias.
+ * Try to find an "invalid" alias.  i.e. one that was unhashed by
+ * d_invalidate(), or that was instantiated with no valid ldlm lock.
+ * These can be rehased by d_lustre_revalidate(), which could race
+ * with this code.
  */
-static struct dentry *ll_find_alias(struct inode *inode, struct dentry *dentry)
+static struct dentry *ll_find_invalid_alias(struct inode *inode,
+					    struct dentry *dentry)
 {
-	struct dentry *alias, *discon_alias, *invalid_alias;
+	struct dentry *alias, *invalid_alias = NULL;
 
 	if (hlist_empty(&inode->i_dentry))
 		return NULL;
 
-	discon_alias = NULL;
-	invalid_alias = NULL;
-
 	spin_lock(&inode->i_lock);
 	hlist_for_each_entry(alias, &inode->i_dentry, d_u.d_alias) {
 		LASSERT(alias != dentry);
 
 		spin_lock(&alias->d_lock);
-		if ((alias->d_flags & DCACHE_DISCONNECTED) &&
-		    S_ISDIR(inode->i_mode))
-			/* LASSERT(last_discon == NULL); LU-405, bz 20055 */
-			discon_alias = alias;
-		else if (alias->d_parent == dentry->d_parent	     &&
-			 alias->d_name.hash == dentry->d_name.hash       &&
-			 alias->d_name.len == dentry->d_name.len	 &&
-			 memcmp(alias->d_name.name, dentry->d_name.name,
-				dentry->d_name.len) == 0)
+		if (alias->d_parent == dentry->d_parent       &&
+		    alias->d_name.hash == dentry->d_name.hash &&
+		    alias->d_name.len == dentry->d_name.len   &&
+		    memcmp(alias->d_name.name, dentry->d_name.name,
+			   dentry->d_name.len) == 0) {
+			dget_dlock(alias);
 			invalid_alias = alias;
+		}
 		spin_unlock(&alias->d_lock);
 
 		if (invalid_alias)
 			break;
 	}
-	alias = invalid_alias ?: discon_alias ?: NULL;
-	if (alias) {
-		spin_lock(&alias->d_lock);
-		dget_dlock(alias);
-		spin_unlock(&alias->d_lock);
-	}
 	spin_unlock(&inode->i_lock);
 
-	return alias;
+	return invalid_alias;
 }
 
 /*
- * Similar to d_splice_alias(), but lustre treats invalid alias
- * similar to DCACHE_DISCONNECTED, and tries to use it anyway.
+ * Similar to d_splice_alias(), but also look for an "invalid" alias,
+ * specific to lustre, and use that if found.
  */
 struct dentry *ll_splice_alias(struct inode *inode, struct dentry *de)
 {
-	if (inode) {
-		struct dentry *new = ll_find_alias(inode, de);
+	if (inode && !S_ISDIR(inode->i_mode)) {
+		struct ll_inode_info *lli = ll_i2info(inode);
+		struct dentry *new;
+
+		/* We need lli_lock here as another thread could
+		 * be running this code, and i_lock cannot protect us.
+		 */
+		spin_lock(&lli->lli_lock);
+		new = ll_find_invalid_alias(inode, de);
+		if (!new)
+			d_add(de, inode);
+		spin_lock(&lli->lli_lock);
 
 		if (new) {
-			d_move(new, de);
 			iput(inode);
 			CDEBUG(D_DENTRY,
 			       "Reuse dentry %p inode %p refc %d flags %#x\n",
 			      new, d_inode(new), d_count(new), new->d_flags);
 			return new;
 		}
+		return de;
 	}
-	d_add(de, inode);
-	CDEBUG(D_DENTRY, "Add dentry %p inode %p refc %d flags %#x\n",
-	       de, d_inode(de), d_count(de), de->d_flags);
+	de = d_splice_alias(inode, de);
+	if (!IS_ERR(de))
+		CDEBUG(D_DENTRY, "Add dentry %p inode %p refc %d flags %#x\n",
+		       de, d_inode(de), d_count(de), de->d_flags);
 	return de;
 }
 
