From: NeilBrown <neilb@suse.com>
Date: Tue, 13 Feb 2018 08:30:48 +1100
Subject: [lustre-devel] [PATCH 3/5] staging: lustre: llite: remove
 directory-specific code from ll_find_alias()
In-Reply-To: <151847081541.26699.3911837371411314092.stgit@noble>
References: <151847081541.26699.3911837371411314092.stgit@noble>
Message-ID: <151847104800.26699.1742105991834584712.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Al Viro <viro@ZenIV.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

Now that ll_find_alias() is never called for directories,
we can remove code that only applies to directories.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/llite/namei.c |   26 ++++++++------------------
 1 file changed, 8 insertions(+), 18 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 60fb18f83bf8..2322328155d6 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -380,21 +380,15 @@ void ll_i2gids(__u32 *suppgids, struct inode *i1, struct inode *i2)
 }
 
 /*
- * try to reuse three types of dentry:
- * 1. unhashed alias, this one is unhashed by d_invalidate (but it may be valid
- *    by concurrent .revalidate).
- * 2. INVALID alias (common case for no valid ldlm lock held, but this flag may
- *    be cleared by others calling d_lustre_revalidate).
- * 3. DISCONNECTED alias.
+ * Try to reuse unhashed or invalidated dentries.
  */
 static struct dentry *ll_find_alias(struct inode *inode, struct dentry *dentry)
 {
-	struct dentry *alias, *discon_alias, *invalid_alias;
+	struct dentry *alias, *invalid_alias;
 
 	if (hlist_empty(&inode->i_dentry))
 		return NULL;
 
-	discon_alias = NULL;
 	invalid_alias = NULL;
 
 	spin_lock(&inode->i_lock);
@@ -402,22 +396,18 @@ static struct dentry *ll_find_alias(struct inode *inode, struct dentry *dentry)
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
+		if (alias->d_parent == dentry->d_parent	     &&
+		    alias->d_name.hash == dentry->d_name.hash       &&
+		    alias->d_name.len == dentry->d_name.len	 &&
+		    memcmp(alias->d_name.name, dentry->d_name.name,
+			   dentry->d_name.len) == 0)
 			invalid_alias = alias;
 		spin_unlock(&alias->d_lock);
 
 		if (invalid_alias)
 			break;
 	}
-	alias = invalid_alias ?: discon_alias ?: NULL;
+	alias = invalid_alias ?: NULL;
 	if (alias) {
 		spin_lock(&alias->d_lock);
 		dget_dlock(alias);
