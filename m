From: James Simmons <jsimmons@infradead.org>
Date: Mon, 25 May 2020 18:08:06 -0400
Subject: [lustre-devel] [PATCH 29/45] lustre: llite: restore ll_dcompare()
In-Reply-To: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
References: <1590444502-20533-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1590444502-20533-30-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

Revert "LU-9868 llite: Get rid of ll_dcompare" as it is causing
failures in conf-sanity test_32* due to errors with sub-mounted
ext2 filesystem dentries being invalidated.

This reverts commit 8f0a4c7b907a27e77ea0dd80198478747c87bfba.

WC-bug-id: https://jira.whamcloud.com/browse/LU-13486
Lustre-commit: 00fa5e8ef4559 ("LU-13486 llite: restore ll_dcompare()")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/38498
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/dcache.c | 53 +++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 43 insertions(+), 10 deletions(-)

diff --git a/fs/lustre/llite/dcache.c b/fs/lustre/llite/dcache.c
index 5fab108..edcc1a7 100644
--- a/fs/lustre/llite/dcache.c
+++ b/fs/lustre/llite/dcache.c
@@ -61,6 +61,48 @@ static void ll_release(struct dentry *de)
 	call_rcu(&lld->lld_rcu_head, free_dentry_data);
 }
 
+/* Compare if two dentries are the same.  Don't match if the existing dentry
+ * is marked invalid.  Returns 1 if different, 0 if the same.
+ *
+ * This avoids a race where ll_lookup_it() instantiates a dentry, but we get
+ * an AST before calling d_revalidate_it().  The dentry still exists (marked
+ * INVALID) so d_lookup() matches it, but we have no lock on it (so
+ * lock_match() fails) and we spin around real_lookup().
+ *
+ * This race doesn't apply to lookups in d_alloc_parallel(), and for
+ * those we want to ensure that only one dentry with a given name is
+ * in ll_lookup_nd() at a time.  So allow invalid dentries to match
+ * while d_in_lookup().  We will be called again when the lookup
+ * completes, and can give a different answer then.
+ */
+static int ll_dcompare(const struct dentry *dentry,
+		       unsigned int len, const char *str,
+		       const struct qstr *name)
+{
+	if (len != name->len)
+		return 1;
+
+	if (memcmp(str, name->name, len))
+		return 1;
+
+	CDEBUG(D_DENTRY, "found name %.*s(%p) flags %#x refc %d\n",
+	       name->len, name->name, dentry, dentry->d_flags,
+	       d_count(dentry));
+
+	/* mountpoint is always valid */
+	if (d_mountpoint(dentry))
+		return 0;
+
+	/* ensure exclusion against parallel lookup of the same name */
+	if (d_in_lookup((struct dentry *)dentry))
+		return 0;
+
+	if (d_lustre_invalid(dentry))
+		return 1;
+
+	return 0;
+}
+
 /**
  * Called when last reference to a dentry is dropped and dcache wants to know
  * whether or not it should cache it:
@@ -202,16 +244,6 @@ static int ll_revalidate_dentry(struct dentry *dentry,
 {
 	struct inode *dir = d_inode(dentry->d_parent);
 
-	CDEBUG(D_VFSTRACE, "VFS Op:name=%s, flags=%u\n",
-	       dentry->d_name.name, lookup_flags);
-
-	/* mountpoint is always valid */
-	if (d_mountpoint(dentry))
-		return 1;
-
-	if (d_lustre_invalid(dentry))
-		return 0;
-
 	/* If this is intermediate component path lookup and we were able to get
 	 * to this dentry, then its lock has not been revoked and the
 	 * path component is valid.
@@ -258,4 +290,5 @@ static int ll_revalidate_nd(struct dentry *dentry, unsigned int flags)
 	.d_revalidate = ll_revalidate_nd,
 	.d_release = ll_release,
 	.d_delete  = ll_ddelete,
+	.d_compare = ll_dcompare,
 };
-- 
1.8.3.1
