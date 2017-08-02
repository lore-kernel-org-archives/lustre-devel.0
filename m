From: NeilBrown <neilb@suse.com>
Date: Wed, 02 Aug 2017 13:06:18 +1000
Subject: [lustre-devel] [PATCH 4/6] staging: lluste: llite: simplify
	ll_find_alias()
In-Reply-To: <150164273003.13199.7841976922211510658.stgit@noble>
References: <150164273003.13199.7841976922211510658.stgit@noble>
Message-ID: <150164317827.13199.14294676526176745668.stgit@noble>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>, Greg Kroah-Hartman <greg@kroah.com>, Andreas Dilger <andreas.dilger@intel.com>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Now that ll_find_alias is only searching for one type
of dentry, we can return as soon as we find it.
This allows substantial simplification, and brings the
bonus that we don't need to take the d_lock again just
to increment the ref-count.  We can increment it immediately
that the dentry is found.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/llite/namei.c |   23 ++++++++---------------
 1 file changed, 8 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index 329038a10a07..51838eed501a 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -382,13 +382,11 @@ void ll_i2gids(__u32 *suppgids, struct inode *i1, struct inode *i2)
  */
 static struct dentry *ll_find_alias(struct inode *inode, struct dentry *dentry)
 {
-	struct dentry *alias, *invalid_alias;
+	struct dentry *alias;
 
 	if (hlist_empty(&inode->i_dentry))
 		return NULL;
 
-	invalid_alias = NULL;
-
 	spin_lock(&inode->i_lock);
 	hlist_for_each_entry(alias, &inode->i_dentry, d_u.d_alias) {
 		LASSERT(alias != dentry);
@@ -398,22 +396,17 @@ static struct dentry *ll_find_alias(struct inode *inode, struct dentry *dentry)
 		    alias->d_name.hash == dentry->d_name.hash       &&
 		    alias->d_name.len == dentry->d_name.len	 &&
 		    memcmp(alias->d_name.name, dentry->d_name.name,
-			   dentry->d_name.len) == 0)
-			invalid_alias = alias;
-		spin_unlock(&alias->d_lock);
-
-		if (invalid_alias)
-			break;
-	}
-	alias = invalid_alias ?: NULL;
-	if (alias) {
-		spin_lock(&alias->d_lock);
-		dget_dlock(alias);
+			   dentry->d_name.len) == 0) {
+			dget_dlock(alias);
+			spin_unlock(&alias->d_lock);
+			spin_unlock(&inode->i_lock);
+			return alias;
+		}
 		spin_unlock(&alias->d_lock);
 	}
 	spin_unlock(&inode->i_lock);
 
-	return alias;
+	return NULL;
 }
 
 /*
