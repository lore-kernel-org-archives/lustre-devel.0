From: NeilBrown <neilb@suse.com>
Date: Tue, 13 Feb 2018 08:30:48 +1100
Subject: [lustre-devel] [PATCH 5/5] staging: lustre: llite: refine
 ll_find_alias based on d_exact_alias
In-Reply-To: <151847081541.26699.3911837371411314092.stgit@noble>
References: <151847081541.26699.3911837371411314092.stgit@noble>
Message-ID: <151847104807.26699.140278585898570948.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Al Viro <viro@ZenIV.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

The task of ll_find_alias() is now very similar to d_exact_alias().
We cannot use that function directly, but we can copy much of
the structure so that the similarities and differences are more
obvious.
Examining d_exact_alias() shows that the d_lock spinlock does not
need to be held in ll_find_alias as much as it currently is.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/llite/namei.c |   30 ++++++++++++++++++---------
 1 file changed, 20 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index baf94f4bcee9..6c9ec462eb41 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -381,6 +381,10 @@ void ll_i2gids(__u32 *suppgids, struct inode *i1, struct inode *i2)
 
 /*
  * Try to reuse unhashed or invalidated dentries.
+ * This is very similar to d_exact_alias(), and any changes in one should be
+ * considered for inclusion in the other.  The differences are that we don't
+ * need an unhashed alias, and we don't want d_compare to be used for
+ * comparison.
  */
 static struct dentry *ll_find_alias(struct inode *inode, struct dentry *dentry)
 {
@@ -392,19 +396,25 @@ static struct dentry *ll_find_alias(struct inode *inode, struct dentry *dentry)
 	spin_lock(&inode->i_lock);
 	hlist_for_each_entry(alias, &inode->i_dentry, d_u.d_alias) {
 		LASSERT(alias != dentry);
+		/*
+		 * Don't need alias->d_lock here, because aliases with
+		 * d_parent == entry->d_parent are not subject to name or
+		 * parent changes, because the parent inode i_mutex is held.
+		 */
 
-		spin_lock(&alias->d_lock);
-		if (alias->d_parent == dentry->d_parent	     &&
-		    alias->d_name.hash == dentry->d_name.hash       &&
-		    alias->d_name.len == dentry->d_name.len	 &&
+		if (alias->d_parent != dentry->d_parent)
+			continue;
+		if (alias->d_name.hash != dentry->d_name.hash)
+			continue;
+		if (alias->d_name.len != dentry->d_name.len ||
 		    memcmp(alias->d_name.name, dentry->d_name.name,
-			   dentry->d_name.len) == 0) {
-			dget_dlock(alias);
-			spin_unlock(&alias->d_lock);
-			spin_unlock(&inode->i_lock);
-			return alias;
-		}
+			   dentry->d_name.len) != 0)
+			continue;
+		spin_lock(&alias->d_lock);
+		dget_dlock(alias);
 		spin_unlock(&alias->d_lock);
+		spin_unlock(&inode->i_lock);
+		return alias;
 	}
 	spin_unlock(&inode->i_lock);
 
