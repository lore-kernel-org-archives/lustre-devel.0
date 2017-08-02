From: NeilBrown <neilb@suse.com>
Date: Wed, 02 Aug 2017 13:06:18 +1000
Subject: [lustre-devel] [PATCH 3/6] staging: lustre: llite: remove
 directory-specific code from ll_find_alias()
In-Reply-To: <150164273003.13199.7841976922211510658.stgit@noble>
References: <150164273003.13199.7841976922211510658.stgit@noble>
Message-ID: <150164317825.13199.17532329520884202645.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <greg@kroah.com>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Now that ll_find_alias() is never called for directories,
we can remove code that only applies to directories.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/llite/namei.c |   26 ++++++++------------------
 1 file changed, 8 insertions(+), 18 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 5ac340a8ad6f..329038a10a07 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -378,21 +378,15 @@ void ll_i2gids(__u32 *suppgids, struct inode *i1, struct inode *i2)
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
@@ -400,22 +394,18 @@ static struct dentry *ll_find_alias(struct inode *inode, struct dentry *dentry)
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
